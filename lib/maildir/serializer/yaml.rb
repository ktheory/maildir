require 'yaml'
class Maildir
  module Serializer
    # Serialize messages as YAML
    class YAML < Maildir::Serializer::Base
      # Read data from path and parse it as YAML.
      def load(path)
        ::YAML.load(super(path))
      end

      # Dump data as YAML and writes it to path.
      def dump(data, path)
        super(data.to_yaml, path)
      end
    end
  end
end
