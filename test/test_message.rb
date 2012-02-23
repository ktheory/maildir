require 'test_helper'
class TestMessage < Test::Unit::TestCase

  context "A message" do
    setup do
      FakeFS::FileSystem.clear
      @maildir = temp_maildir
      @message = Maildir::Message.new(@maildir)
    end

    should "use serializer of its maildir" do
      @maildir.serializer = :foo
      assert_equal @message.serializer, :foo
    end
  end

  context "An new, unwritten message" do
    setup do
      FakeFS::FileSystem.clear
      @message = Maildir::Message.new(temp_maildir)
    end

    should "be in :tmp" do
      assert_equal :tmp, @message.dir
      assert_match(/tmp/, @message.path)
    end

    should "have a unique name" do
      assert_not_empty @message.unique_name
    end

    should "have a file name" do
      assert_not_empty @message.filename
    end

    should "have no info" do
      assert_nil @message.info
    end

    should "not be able to set info" do
      assert_raises RuntimeError do
        @message.info= "2,FRS"
      end
    end
  end

  context "A written message" do
    setup do
      FakeFS::FileSystem.clear
      @message = Maildir::Message.new(temp_maildir)
      @data = "foo"
      @message.write(@data)
    end

    should "not be writable" do
      assert_raise RuntimeError do
        @message.write("nope!")
      end
    end

    should "have no info" do
      assert_nil @message.info
    end

    should "not be able to set info" do
      assert_raises RuntimeError do
        @message.info= "2,FRS"
      end
    end

    should "be in new" do
      assert_equal :new, @message.dir
      assert_match(/new/, @message.path)
    end

    should "have a file" do
      assert File.exists?(@message.path)
    end

    should "have the correct data" do
      assert_equal @data, @message.data
    end

    should "have empty flags" do
      assert_equal [], @message.flags
    end
  end

  context "A processed message" do
    setup do
      FakeFS::FileSystem.clear
      @data = "foo"
      @message = Maildir::Message.create(temp_maildir, @data)
      @message.process
    end

    should "not be writable" do
      assert_raise RuntimeError do
        @message.write("nope!")
      end
    end

    should "be in cur" do
      assert_equal :cur, @message.dir
    end

    should "have info" do
      assert_equal Maildir::Message::INFO, @message.info
    end

    should "set info" do
      info = "2,FRS"
      @message.info = "2,FRS"
      assert_equal @message.info, info
      assert_match /#{info}$/, @message.path
    end

    should "add and remove flags" do
      @message.add_flag('S')
      assert_equal ['S'], @message.flags

      # Test lowercase
      @message.add_flag('r')
      assert_equal ['R', 'S'], @message.flags

      @message.remove_flag('S')
      assert_equal ['R'], @message.flags

      # Test lowercase
      @message.remove_flag('r')
      assert_equal [], @message.flags
    end

    flag_tests = {
      "FRS" => ['F', 'R', 'S'],
      "Sr" => ['R', 'S'], # test capitalization & sorting
      '' => []
    }
    flag_tests.each do |arg, results|
      should "set flags: #{arg}" do
        @message.flags = arg
        assert_equal results, @message.flags
        path_suffix = "#{Maildir::Message::INFO}#{results.join('')}"
        assert_match /#{path_suffix}$/, @message.path
      end
    end
  end

  context "Destroying a message" do
    setup do
      FakeFS::FileSystem.clear
      @message = Maildir::Message.create(temp_maildir, "foo")
    end

    should "freeze it" do
      @message.destroy
      assert @message.frozen?, "Message is not frozen"
    end

    should "delete the path" do
      @message.destroy
      assert !File.exists?(@message.path), "Message path exists"
    end

    should "return 1" do
      assert_equal 1, @message.destroy
    end

    should "return false if the path doesn't exist" do
      File.delete(@message.path)
      assert_equal false, @message.destroy
    end
  end

  context "A message with a bad path" do
    setup do
      FakeFS::FileSystem.clear
      @message = temp_maildir.add("")
      File.delete(@message.path)
    end

    should "raise error for data" do
      assert_raise Errno::ENOENT do
        @message.data
      end
      assert @message.frozen?
    end

    should "not be processed" do
      old_key = @message.key
      assert_equal false, @message.process
      assert @message.frozen?
    end


    should "reset to the old key after attempt to process" do
      old_key = @message.key
      @message.process
      assert_equal old_key, @message.key
    end
  end

  context "Different messages" do
    setup do
      FakeFS::FileSystem.clear
    end

    should "differ" do
      @message1 = temp_maildir.add("")
      @message2 = temp_maildir.add("")
      assert_equal -1, @message1 <=> @message2
      assert_equal 1,  @message2 <=> @message1
      assert_not_equal @message1, @message2
    end
  end

  context "Identical messages" do
    setup do
      FakeFS::FileSystem.clear
    end

    should "be identical" do
      @message1 = temp_maildir.add("")
      another_message1 = temp_maildir.get(@message1.key)
      assert_equal @message1, another_message1
    end
  end

  context "Message#utime" do
    setup do
      FakeFS::FileSystem.clear
    end

    should "update the messages mtime" do
      @message = temp_maildir.add("")
      time = Time.now - 60

      @message.utime(time, time)

      # Time should be within 1 second of each other
      assert_in_delta time, @message.mtime, 1
    end

    # atime not currently supported in FakeFS
    should_eventually "update the messages atime" do
      @message = temp_maildir.add("")
      time = Time.now - 60

      @message.utime(time, time)

      # Time should be within 1 second of each other
      assert_in_delta time, @message.atime, 1
    end
  end
end
