require 'test_helper'
class TestMessage < Test::Unit::TestCase


  context "An new, unwritten message" do
    setup do
      @message = Maildir::Message.new(temp_maildir)
    end

    should "be instantiated" do
      assert @message
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

    context "when written with a string" do
      setup do
        @data = "foo\n"
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

      should "be in new dir" do
        assert_equal :new, @message.dir
        assert_match(/new/, @message.path)
      end

      should "have have a file" do
        assert File.exists?(@message.path)
      end

      should "have the correct data" do
        assert @data == @message.contents
      end
    end

    context "when written with an IO object" do
      setup do
        @data = "foo\n"
        @message.write(StringIO.open(@data))
      end

      should "have the correct data" do
        assert @data == @message.contents
      end
    end
  end

  context "A created message" do
    setup do
      @data = "foo\n"
      @message = Maildir::Message.create(temp_maildir, @data)
    end

    should "have the correct data" do
      assert @data == @message.contents
    end

    context "when processed" do
      setup do
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
      context "when destroyed" do
        setup { @message.destroy }
        should "be frozen" do
          assert @message.frozen?, "Message is not frozen"
        end
        should "have a nonexistant path" do
          assert !File.exists?(@message.path), "Message path exists"
        end
      end
    end
  end
end