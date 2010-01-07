require 'fileutils' # For create_directories
class Maildir

  SUBDIRS = [:tmp, :new, :cur].freeze
  READABLE_DIRS = SUBDIRS.reject{|s| :tmp == s}.freeze

  attr_reader :path

  # Create a new maildir at +path+. If +create+ is true, will ensure that the
  # required subdirectories exist.
  def initialize(path, create = true)
    @path = File.join(path, '/') # Ensure path has a trailing slash
    create_directories if create
  end

  # Maildirs are indentical if they have the same path
  def ==(maildir)
    return false unless Maildir === maildir
    maildir.path == self.path
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
      FileUtils.mkdir_p(self.send("#{subdir}_path"))
    end
  end

  def list(new_or_cur)
    list_keys(new_or_cur).map{|key| get_message(key)}
  end

  def list_keys(new_or_cur)
    new_or_cur = new_or_cur.to_sym
    unless [:new, :cur].include? new_or_cur
      raise ArgumentError, "first arg must be new or cur"
    end
    get_dir_listing(new_or_cur)
  end

  # Writes data object out as a new message. See
  # Maildir::Message.create for more.
  def add_message(data)
    Maildir::Message.create(self, data)
  end

  def get_message(key)
    Maildir::Message.new(self, key)
  end

  protected
  def get_dir_listing(new_or_cur)
    search_path = File.join(self.path, new_or_cur.to_s, '*')
    results = Dir.glob(search_path)

    # Remove the maildir's path from the beginning of the message path
    @dir_listing_regexp ||= /^#{Regexp.quote(self.path)}/
    results.each do |message_path|
      message_path.sub!(@dir_listing_regexp, "")
    end
  end
end
require 'maildir/unique_name'
require 'maildir/serializer/base'
require 'maildir/message'