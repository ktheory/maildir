module Maildir::Serializer
  # The Maildir::Serializer::Base class reads & writes data to disk as a
  # string. Other serializers (e.g. Maildir::Serializer::Mail) can extend this
  # class to do some pre- and post-processing of the string.
  #
  # The Serializer API has two methods:
  #   load(path) # => returns data
  #   dump(data, path) # => returns number of bytes written
  class Base
    # Reads the file at path. Returns the contents of path.
    def load(path)
      File.read(path)
    end

    # Writes data to path. Returns number of bytes written.
    def dump(data, path)
      File.open(path, "w") {|file| file.write(data)}
    end
  end
end