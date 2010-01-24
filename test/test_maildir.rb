require 'test_helper'
class TestMaildir < Test::Unit::TestCase

  context "A maildir" do
    setup do
      FakeFS::FileSystem.clear
    end

    should "have a path" do
      assert_not_empty temp_maildir.path
    end

    should "create subdirectories by default" do
      %w(tmp new cur).each do |subdir|
        subdir_path = temp_maildir.send("#{subdir}_path")
        assert File.directory?(subdir_path), "Subdir #{subdir} does not exist"
      end
    end

    should "expand paths" do
      maildir = Maildir.new("~/test_maildir/")
      expanded_path = File.expand_path("~/test_maildir")
      expanded_path = File.join(expanded_path, "/")
      assert_equal expanded_path, maildir.path
    end

    should "not create directories if specified" do
      maildir = Maildir.new("/maildir_without_subdirs", false)
      %w(tmp new cur).each do |subdir|
        subdir_path = maildir.send("#{subdir}_path")
        assert !File.directory?(subdir_path), "Subdir #{subdir} exists"
      end
    end

    should "be identical to maildirs with the same path" do
      new_maildir = Maildir.new(temp_maildir.path)
      assert_equal temp_maildir.path, new_maildir.path
      assert_equal temp_maildir, new_maildir
    end

    should "list a new message" do
      @message = temp_maildir.add("")
      messages = temp_maildir.list(:new)
      assert_equal messages, [@message]
    end

    should "list a cur message" do
      @message = temp_maildir.add("")
      @message.process
      messages = temp_maildir.list(:cur)
      assert_equal messages, [@message]
    end
  end

  context "Maildirs with the same path" do
    should "be identical" do
      another_maildir = Maildir.new(temp_maildir.path, false)
      assert_equal temp_maildir, another_maildir
    end
  end

  context "Maildirs with stale messages in tmp" do
    should "be found" do
      stale_path = File.join(temp_maildir.path, "tmp", "stale_message")
      File.open(stale_path, "w"){|f| f.write("")}
      stale_time = Time.now - 30*24*60*60 # 1 month ago
      File.utime(stale_time, stale_time, stale_path)

      stale_tmp = [temp_maildir.get("tmp/stale_message")]
      assert_equal stale_tmp, temp_maildir.get_stale_tmp
    end
  end
end
