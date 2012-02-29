class Maildir
  module Serializer
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
        File.open(path,'rb') do |f|
          f.read
        end
      end

      # Writes data to path. Returns number of bytes written.
      # If data acts like an IO object (i.e., data responds to the read method),
      # we call data.read or the more efficient IO.copy_stream available in
      # ruby 1.9.1.
      def dump(data, path)
        if data.respond_to?(:read)
          if IO.respond_to?(:copy_stream)
            IO.copy_stream(data, path)
          else
            write(data.read, path)
          end
        else
          write(data, path)
        end
      end

      protected
      def write(data, path)
        File.open(path, "w") {|file| file.write(data)}
      end
    end
  end
end
