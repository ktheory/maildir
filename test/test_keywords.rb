require 'test_helper'
require 'maildir/keywords'
class TestKeywords < Test::Unit::TestCase
  context "A message" do
    setup do
      @data = "foo\n"
      @msg = Maildir::Message.create(temp_maildir, @data)
    end

    should "remember keywords" do
      kw = %w(Junk Seen)
      @msg.keywords = kw
      assert (@msg.keywords & kw).size == 2
    end
  end
end
