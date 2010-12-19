# Prefer yajl JSON library
begin
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end

# Serialize messages as JSON
module Maildir::Serializer
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
