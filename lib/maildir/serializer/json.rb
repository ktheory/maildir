# Prefer yajl JSON library
begin
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end

class Maildir
  module Serializer
    # Serialize messages as JSON
    class JSON < Base
      # Read data from path and parse it as JSON.
      def load(path)
        ::JSON.load(super(path))
      end

      # Dump data as JSON and writes it to path.
      def dump(data, path)
        super(data.to_json, path)
      end
    end
  end
end
