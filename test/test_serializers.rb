require 'test_helper'
class TestSerializers < Test::Unit::TestCase


  serializers = [
    # Test the base serializer with a string
    [Maildir::Serializer::Base,    lambda {|data| data}],
    # Test base serializer with IO object
    [Maildir::Serializer::Base,    lambda {|data| s = StringIO.new(data); s.rewind; s}],
    [Maildir::Serializer::Mail,    lambda {|data| Mail.new(data).to_s}],
    [Maildir::Serializer::Marshal, lambda {|data| Marshal.dump(data)}],
    [Maildir::Serializer::JSON,    lambda {|data| JSON.dump(data)}],
    [Maildir::Serializer::YAML,    lambda {|data| YAML.dump(data)}]
  ]

  serializers.each do |klass, dumper|
    # NB: dumper.object_id makes test names unique
    context "A message serialized with #{klass} (#{dumper.object_id})" do
      setup do
        FakeFS::FileSystem.clear
        @data = case klass.new
        when Maildir::Serializer::Mail
          Mail.new
        when Maildir::Serializer::Marshal, Maildir::Serializer::JSON, Maildir::Serializer::YAML
          # Test a few common types
          [1, nil, {"foo" => true}]
        when Maildir::Serializer::Base
          "Hello World!"
        else
          raise "Unknown class #{klass.inspect}"
        end

        # Set the message serializer
        Maildir::Message.serializer = klass.new
        @message = temp_maildir.add(@data)
      end

      should "have the correct data" do
        assert_equal @data, @message.data
      end

      should "have serialized data on disk" do
        expected_data = dumper.call(@data)
        # Read the expected_data if @data is an IO object
        expected_data = expected_data.read if expected_data.respond_to?(:read)
        assert_equal expected_data, File.read(@message.path)
      end
    end
  end
end
