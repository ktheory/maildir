class Maildir
  module Serializer
    # Serialize messages as Marshalled ruby objects
    class Marshal < Maildir::Serializer::Base
      # Read data from path and unmarshal it.
      def load(path)
        ::Marshal.load(super(path))
      end

      # Marshal data and write it to path.
      def dump(data, path)
        super(::Marshal.dump(data), path)
      end
    end
  end
end
