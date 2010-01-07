require 'test_helper'

# Require all the serializers
path = File.join(File.dirname(__FILE__), "..","lib","maildir","serializer","*")
Dir.glob(path).each do |file|
  require file
end

class TestSerializers < Test::Unit::TestCase

  serializers = [
    [Maildir::Serializer::Mail,    lambda {|data| Mail.new(data).to_s}],
    [Maildir::Serializer::Marshal, lambda {|data| Marshal.dump(data)}],
    [Maildir::Serializer::JSON,    lambda {|data| JSON.dump(data)}],
    [Maildir::Serializer::YAML,    lambda {|data| YAML.dump(data)}]
  ]

  serializers.each do |klass, dumper|
    context "A message serialized with #{klass}" do
      setup do
        @data = case klass.new
        when Maildir::Serializer::Mail
          Mail.new
        else
          # Test a few common data structures
          [1, nil, {"foo" => true}]
        end

        # Set the message serializer
        Maildir::Message.serializer = klass.new
        @message = temp_maildir.add(@data)
      end

      should "have the correct data" do
        assert_equal @data, @message.data
      end

      should "have serialized data on disk" do
        assert_equal dumper.call(@data), File.read(@message.path)
      end
    end
  end
end
