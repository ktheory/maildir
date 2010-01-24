require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fileutils'
require 'maildir'

# Require all the serializers
serializers = File.join(File.dirname(__FILE__), "..","lib","maildir","serializer","*")
Dir.glob(serializers).each do |serializer|
  require serializer
end

# Require 'ktheory-fakefs' until issues 28, 29, and 30 are resolved in
# defunkt/fakefs. See http://github.com/defunkt/fakefs/issues
gem "ktheory-fakefs"
require 'fakefs'

# Create a reusable maildir that's cleaned up when the tests are done
def temp_maildir
    Maildir.new("/tmp/maildir_test")
#   return $maildir if $maildir


#   dir_path = Dir.mktmpdir("maildir_test")
# #  at_exit do
# #    puts "Cleaning up temp maildir"
# #    FileUtils.rm_r(dir_path)
# #  end
#   $maildir = Maildir.new(dir_path)
#   setup_subdirs if defined?(Maildir::Subdirs)
#   return $maildir
end

# create the subdir tree:
# | INBOX
# |-- a
# | |-- x
# | |-- y
# |-- b
def setup_subdirs
  %w(a b a.x a.y).each do |x|
    Maildir.new(File.join($maildir.path, ".#{x}"))
  end
end

# Useful for testing that strings defined & not empty
def assert_not_empty(obj, msg='')
  assert !obj.nil? && !obj.empty?, msg
end
