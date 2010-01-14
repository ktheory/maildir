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
end

# Useful for testing that strings defined & not empty
def assert_not_empty(obj, msg='')
  assert !obj.nil? && !obj.empty?, msg
end
