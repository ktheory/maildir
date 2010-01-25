# implements subdirs as used by the Courier Mail Server (courier-mta.org)
require 'maildir'
module Maildir::Subdirs
  ROOT_NAME = 'INBOX'
  DELIM = '.'

  def self.included(base)
    base.instance_eval do
      alias_method :inspect_without_subdirs, :inspect
      alias_method :inspect, :inspect_with_subdirs
    end
  end

  def name
    root? ? ROOT_NAME : subdir_parts(path).last
  end

  def create_subdir(name)
    raise ArgumentError.new("'name' may not contain delimiter character (#{DELIM})") if name.include?(DELIM)
    full_name = (root? ? [] : subdir_parts(File.basename(path))).push(name).unshift('').join(DELIM)
    md = Maildir.new(File.join(path, full_name), true)
    @subdirs << md if @subdirs
    md
  end

  # returns the logical mailbox path
  def mailbox_path
    @mailbox_path ||= root? ? ROOT_NAME : subdir_parts(File.basename(path)).unshift(ROOT_NAME).join(DELIM)
  end

  # returns an array of Maildir objects representing the direct subdirectories of this Maildir
  def subdirs(only_direct=true)
    if root?
      @subdirs ||= (Dir.entries(path) - %w(. ..)).select {|e|
        e =~ /^\./ && File.directory?(File.join(path, e)) && (only_direct ? subdir_parts(e).size == 1 : true)
      }.map { |e| Maildir.new(File.join(path, e), false) }
    else
      my_parts = subdir_parts(File.basename(path))
      @subdirs ||= root.subdirs(false).select { |md| subdir_parts(File.basename(md.path))[0..-2] == my_parts }
    end
  end

  # Friendly inspect method
  def inspect_with_subdirs
    "#<#{self.class} path=#{@path} mailbox_path=#{mailbox_path}>"
  end

  # returns the Maildir representing the root directory
  def root
    root? ? self : Maildir.new(File.dirname(path), false)
  end

  # returns true if the parent directory doesn't look like a maildir
  def root?
    ! ((Dir.entries(File.dirname(path)) & %w(cur new tmp)).size == 3)
  end

  private

  def subdir_parts(path)
    path.sub!(/\/$/, '') # remove trailing slash
    parts = (path.split(DELIM) - [''])
    # some clients (e.g. Thunderbird) mess up namespaces so subdirs
    # end up looking like '.INBOX.Trash' instead of '.Trash'
    parts.shift if parts.first == ROOT_NAME
    parts
  end
end

Maildir.send(:include, Maildir::Subdirs)
