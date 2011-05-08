require 'test/unit'
require 'shoulda'
require 'maildir'

# Require all the serializers
serializers = File.expand_path('../../lib/maildir/serializer/*.rb', __FILE__)
Dir.glob(serializers).each do |serializer|
  require serializer
end

require 'fakefs'

# Create a reusable maildir that's cleaned up when the tests are done
def temp_maildir
  Maildir.new("/tmp/maildir_test")
end

# create the subdir tree:
# | INBOX
# |-- a
# | |-- x
# | |-- y
# |-- b
def setup_subdirs(maildir)
  %w(a b a.x a.y).each do |x|
    Maildir.new(File.join(maildir.path, ".#{x}"))
  end
end

# Test that objects are neither nil nor empty
def assert_not_empty(obj, msg='')
  assert !obj.nil? && !obj.empty?, msg
end
