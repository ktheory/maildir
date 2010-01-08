class Maildir::Message
  # COLON seperates the unique name from the info
  COLON = ':'
  # The default info, to which flags are appended
  INFO = "2,"

  include Comparable

  class << self
    # Create a new message in maildir with data.
    # The message is first written to the tmp dir, then moved to new. This is
    # a shortcut for:
    #   message = Maildir::Message.new(maildir)
    #   message.write(data)
    def create(maildir, data)
      message = self.new(maildir)
      message.write(data)
      message
    end

    # The serializer processes data before it is written to disk and after
    # reading from disk.
    attr_accessor :serializer
  end

  # Default serializer
  @serializer = Maildir::Serializer::Base.new

  attr_reader :dir, :unique_name, :info, :old_key

  # Create a new, unwritten message or instantiate an existing message.
  # If key is nil, create a new message:
  #   Message.new(maildir) # => a new, unwritten message
  #
  # If +key+ is not nil, instantiate a message object for the message at
  # +key+.
  #   Message.new(maildir, key) # => an existing message
  def initialize(maildir, key=nil)
    @maildir = maildir
    if key.nil?
      @dir = :tmp
    else
      parse_key(key)
    end

    unless Maildir::SUBDIRS.include? dir
      raise ArgumentError, "State must be in #{Maildir::SUBDIRS.inspect}"
    end

    if :tmp == dir
      @unique_name = Maildir::UniqueName.create
    end
  end

  # Compares messages by their paths.
  # If message is a different class, return nil.
  # Otherwise, return 1, 0, or -1.
  def <=>(message)
    # Return nil if comparing different classes
    return nil unless self.class === message

    self.path <=> message.path
  end

  # Friendly inspect method
  def inspect
    "#<#{self.class} key=#{key} maildir=#{@maildir.inspect}>"
  end

  # Returns the class' serializer
  def serializer
    self.class.serializer
  end

  # Writes data to disk. Can only be called on messages instantiated without
  # a key (which haven't been written to disk). After successfully writing
  # to disk, rename the message to the new dir
  #
  # Returns the message's key
  def write(data)
    raise "Can only write to messages in tmp" unless :tmp == @dir

    # Write out contents to tmp
    serializer.dump(data, path)

    rename(:new)
  end

  # Move a message from new to cur, add info.
  # Returns the message's key
  def process
    rename(:cur, INFO)
  end

  # Set info on a message.
  # Returns the message's key
  def info=(info)
    raise "Can only set info on cur messages" unless :cur == @dir
    rename(:cur, info)
  end

  # Returns an array of single letter flags applied to the message
  def flags
    @info.sub(INFO,'').split('')
  end

  # Sets the flags on a message.
  # Returns the message's key
  def flags=(*flags)
    self.info = INFO + sort_flags(flags.flatten.join(''))
  end

  def add_flag(flag)
    self.flags = (flags << flag.upcase)
  end
  
  def remove_flag(flag)
    self.flags = flags.delete_if{|f| f == flag.upcase}
  end


  # Returns the filename of the message
  def filename
    [unique_name, info].compact.join(COLON)
  end

  # Returns the key to identify the message
  def key
    File.join(dir.to_s, filename)
  end

  # Returns the full path to the message
  def path
    File.join(@maildir.path, key)
  end

  # Returns the message's data from disk
  def data
    serializer.load(path)
  end

  # Deletes the message path and freezes the message object
  def destroy
    File.delete(path)
    freeze
  end

  protected

  # Sets dir, unique_name, and info based on the key
  def parse_key(key)
    @dir, filename = key.split(File::SEPARATOR)
    @dir = @dir.to_sym
    @unique_name, @info = filename.split(COLON)
  end

  # Ensure the flags are uppercase and sorted
  def sort_flags(flags)
    flags.split('').map{|f| f.upcase}.sort!.uniq.join('')
  end

  def old_path
    File.join(@maildir.path, old_key)
  end

  def rename(new_dir, new_info=nil)
    # Safe the old key so we can revert to the old state
    @old_key = key

    # Set the new state
    @dir = new_dir
    @info = new_info if new_info

    begin
      File.rename(old_path, path) unless old_path == path
      return key
    rescue Errno::ENOENT
      # Restore ourselves to the old state
      parse_key(@old_key)
      raise
    end
  end
end
