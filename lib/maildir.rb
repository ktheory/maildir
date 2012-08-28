require 'fileutils' # For create_directories
class Maildir

  module Serializer
    autoload :Base,    'maildir/serializer/base'
    autoload :Mail,    'maildir/serializer/mail'
    autoload :Marshal, 'maildir/serializer/marshal'
    autoload :JSON,    'maildir/serializer/json'
    autoload :YAML,    'maildir/serializer/yaml'
  end

  SUBDIRS = [:tmp, :new, :cur].freeze

  include Comparable

  attr_reader :path
  attr_accessor :serializer

  # Default serializer.
  @@serializer = Maildir::Serializer::Base.new

  # Gets the default serializer.
  def self.serializer
    @@serializer
  end

  # Sets the default serializer.
  def self.serializer=(serializer)
    @@serializer = serializer
  end

  # Create a new maildir at +path+. If +create+ is true, will ensure that the
  # required subdirectories exist.
  def initialize(path, create = true)
    @path = File.expand_path(path)
    @path = File.join(@path, '/') # Ensure path has a trailing slash
    @path_regexp = /^#{Regexp.quote(@path)}/ # For parsing directory listings
    create_directories if create
  end

  # Returns own serializer or falls back to default.
  def serializer
    @serializer || @@serializer
  end

  # Compare maildirs by their paths.
  # If maildir is a different class, return nil.
  # Otherwise, return 1, 0, or -1.
  def <=>(maildir)
    # Return nil if comparing different classes
    return nil unless self.class === maildir

    self.path <=> maildir.path
  end

  # Friendly inspect method
  def inspect
    "#<#{self.class} path=#{@path}>"
  end

  # define methods tmp_path, new_path, & cur_path
  SUBDIRS.each do |subdir|
    define_method "#{subdir}_path" do
      File.join(path, subdir.to_s)
    end
  end

  # Ensure subdirectories exist. This can safely be called multiple times, but
  # must hit the disk. Avoid calling this if you're certain the directories
  # exist.
  def create_directories
    SUBDIRS.each do |subdir|
      subdir_path = File.join(path, subdir.to_s)
      FileUtils.mkdir_p(subdir_path)
    end
  end

  # Returns an arry of messages from :new or :cur directory, sorted by key.
  # If options[:flags] is specified and directory is :cur, returns messages with flags specified
  # 
  # E.g.
  # maildir.list(:cur, :flags => 'F') # => lists all messages with flag 'F'
  # maildir.list(:cur, :flags => 'FS') # => lists all messages with flag 'F' and 'S'; Flags must be specified in acending ASCII order ('FS' and not 'SF')
  # maildir.list(:cur, :flags => '') # => lists all messages without any flags
  # This option does not work for :new directory
  #
  # If options[:limit] is specified, returns only so many keys.
  #
  # E.g.
  #  maildir.list(:new) # => all new messages
  #  maildir.list(:cur, :limit => 10) # => 10 oldest messages in cur
  def list(dir, options = {})
    unless SUBDIRS.include? dir.to_sym
      raise ArgumentError, "dir must be :new, :cur, or :tmp"
    end

    # Set flags to filter messages
    # Silently ignored if dir is :new
    flags = (dir.to_sym == :cur) ? options[:flags] : nil
    keys = get_dir_listing(dir, :flags => flags)

    # Sort the keys (chronological order)
    # TODO: make sorting configurable
    keys.sort!

    # Apply the limit after sorting
    if limit = options[:limit]
      keys = keys[0,limit]
    end

    # Map keys to message objects
    keys.map{|key| get(key)}
  end

  # Writes data object out as a new message. Returns a Maildir::Message. See
  # Maildir::Message.create for more.
  def add(data)
    Maildir::Message.create(self, data)
  end

  # Returns a message object for key
  def get(key)
    Maildir::Message.new(self, key)
  end

  # Deletes the message for key by calling destroy() on the message.
  def delete(key)
    get(key).destroy
  end

  # Finds messages in the tmp folder that have not been modified since
  # +time+. +time+ defaults to 36 hours ago.
  def get_stale_tmp(time = Time.now - 129600)
    list(:tmp).select do |message|
      (mtime = message.mtime) && mtime < time
    end
  end

  protected
  # Returns an array of keys in dir
  def get_dir_listing(dir, options={})
  	filter = "*"
  	filter = "#{filter}:2,#{options[:flags]}" if options[:flags]
    search_path = File.join(self.path, dir.to_s, filter)
    keys = Dir.glob(search_path)
    #  Remove the maildir's path from the keys
    keys.each do |key|
      key.sub!(@path_regexp, "")
    end
  end
end
require 'maildir/unique_name'
require 'maildir/serializer/base'
require 'maildir/message'
