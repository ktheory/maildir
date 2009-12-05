require 'test_helper'
class TestUniqueName < Test::Unit::TestCase

  context "A UniqueName" do
    setup do
      @raw_name = Maildir::UniqueName.new
      @name = @raw_name.to_s
      @now = @raw_name.send(:instance_variable_get, :@now)
    end

    should "be initialized" do
      assert @raw_name
    end

    should "have a name" do
      assert_not_empty @name
    end

    should "begin with timestamp" do
      assert_match /^#{@now.to_i}/, @name
    end

    should "end with hostname" do
      assert_match /#{Socket.gethostname}$/, @name
    end

    should "be unique when created in the same microsecond" do
      @new_name = Maildir::UniqueName.new
      # Set @now be identical in both UniqueName instances
      @new_name.send(:instance_variable_set, :@now, @now)
      assert_not_equal @name, @new_name.to_s
    end

  end

  context "The UniqueName counter" do
    should "increment when called" do
      value1 = Maildir::UniqueName.counter
      value2 = Maildir::UniqueName.counter
      assert_equal value1+1, value2
    end
  end
end