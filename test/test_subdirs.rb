require 'test_helper'
require 'maildir/subdirs'
class TestSubdirs < Test::Unit::TestCase
  context "A maildir" do 
    should "have subdirs" do 
      assert temp_maildir.subdirs.any?
    end
    
    should "be called INBOX" do 
      assert temp_maildir.name == 'INBOX'
    end
    
    should "include direct subdirs" do 
      subdir_names = temp_maildir.subdirs.map(&:name)
      assert subdir_names.include?('a') && subdir_names.include?('b')
    end
    
    should "not include deeper subdirs" do 
      subdir_names = temp_maildir.subdirs.map(&:name)
      assert ! subdir_names.include?('x') && ! subdir_names.include?('a.x')
    end
    
    should "create more subdirs" do 
      temp_maildir.create_subdir("test")
      assert temp_maildir.subdirs.map(&:name).include?("test")
    end
  end
  
  context "A subdir" do 
    should "include more subdirs" do 
      assert_not_empty temp_maildir.subdirs.select{ |sd| sd.name == 'a'}.first.subdirs
    end
  end
end
