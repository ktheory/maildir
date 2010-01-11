require 'test_helper'
class TestMaildir < Test::Unit::TestCase

  context "A maildir" do
    should "have a path" do
      assert_not_empty temp_maildir.path
    end

    should "create subdirectories by default" do
      %w(tmp new cur).each do |subdir|
        subdir_path = temp_maildir.send("#{subdir}_path")
        assert File.directory?(subdir_path), "Subdir #{subdir} does not exist"
      end
    end

    should "not create directories if specified" do
      tmp_dir = Dir.mktmpdir('new_maildir_test')
      maildir = Maildir.new(tmp_dir, false)
      %w(tmp new cur).each do |subdir|
        subdir_path = maildir.send("#{subdir}_path")
        assert !File.directory?(subdir_path), "Subdir #{subdir} exists"
      end
      FileUtils.rm_r(tmp_dir)
    end
    
    should "be identical to maildirs with the same path" do
      new_maildir = Maildir.new(temp_maildir.path)
      assert_equal temp_maildir.path, new_maildir.path
      assert_equal temp_maildir, new_maildir
    end
    
    context "with a message" do
      setup do
        @message = temp_maildir.add("")
      end

      should "list the message in it's keys" do
        messages = temp_maildir.list(:new)
        assert messages.include?(@message)
      end
    end
  end

  context "Maildirs with the same path" do
    should "be identical" do
      another_maildir = Maildir.new(temp_maildir.path, false)
      assert_equal temp_maildir, another_maildir
    end
  end

end
