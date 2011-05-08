require 'mail'
class Maildir
  module Serializer
    # Serialize messages as a ruby Mail object
    class Mail < Maildir::Serializer::Base
      # Build a new Mail object from the data at path.
      def load(path)
        ::Mail.new(super(path))
      end

      # Write data to path as a Mail message.
      def dump(data, path)
        super(data.to_s, path)
      end
    end
  end
end
