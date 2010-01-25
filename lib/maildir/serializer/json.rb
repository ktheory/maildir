require 'json'
# Serialize messages as JSON
class Maildir::Serializer::JSON < Maildir::Serializer::Base
  # Read data from path and parse it as JSON.
  def load(path)
    ::JSON.load(super(path))
  end

  # Dump data as JSON and writes it to path.
  def dump(data, path)
    super(data.to_json, path)
  end
end
