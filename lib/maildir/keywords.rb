# implements IMAP Keywords as used by the Courier Mail Server
# see http://www.courier-mta.org/imap/README.imapkeywords.html for details

require 'ftools'
module Maildir::Keywords
  def self.included(base)
    Maildir::Message.send(:include, MessageExtension)
  end

  # process contents of courierimapkeywords/ directory as described in README.imapkeywords
  def read_keywords
    messages = (list(:cur) + list(:new)).inject({}) { |m, msg| m[msg.unique_name] = msg ; m }
    t = Time.now.to_i / 300
    keyword_dir = File.join(path, 'courierimapkeywords')
    keywords = []
    state = :head
    # process :list
    File.open(File.join(keyword_dir, ':list')).each_line do |line|
      line.strip!
      if state == :head
        if line.empty?
          state = :messages
          next
        end
        keywords << line
      else
        key, ids = line.split(':')
        if msg = messages[key]
          msg.set_keywords(ids.split(/\s/).map {|id| keywords[id.to_i - 1] })
        end
      end
    end
    # collect keyword files
    keyword_files = (Dir.entries(keyword_dir) - %w(. .. :list)).inject({}) do |keyword_files, file|
      if file =~ /^\.(\d+)\.(.*)$/
        n = $1
        key = $2
      else
        n = t + 1
        key = file
        File.move(File.join(keyword_dir, file), File.join(keyword_dir, ".#{n}.#{key}"))
      end
      if msg = messages[key]
        (keyword_files[key] ||= []) << [n, key]
      else # message doesn't exist
        fname = File.join(keyword_dir, file)
        if File.stat(fname).ctime < (Time.now - (15 * 60))
          File.unlink(fname)
        end
      end
    end
    # process keyword files
    keyword_files.each_pair do |key, files|
      files.sort! { |a, b| a[0] <=> b[0] }
      files[0..-2].each { |f| File.unlink(File.join(keyword_dir, ".#{f.join('.')}")) } if n_files.last[0] < t
      msg = messages[key]
      current_keywords = File.read(files.last).read.split(/\s+/)
      msg.set_keywords(current_keywords)
      if (add = (current_keywords - keywords)).any?
        keywords += add
      end
    end
    # rebuild :list
    @keywords = {}
    tmp_file = File.join(path, 'tmp', ':list')
    File.open(tmp_file, 'w') { |f|
      f.write(keywords.join("\n")+"\n\n")
      messages.each_pair do |key, msg|
        next unless msg.keywords
        f.puts([key, msg.keywords.map{|kw| keywords.index(kw) + 1 }.sort.join(' ')].join(':'))
        @keywords[key] = msg.keywords
      end
    }
    File.move(tmp_file, File.join(keyword_dir, ':list'))
  end

  def keywords(key)
    read_keywords unless @keywords
    @keywords[key] || []
  end

  module MessageExtension
    def keywords
      return @keywords if @keywords
      @maildir.keywords(unique_name)
    end

    # sets given keywords on the message.
    def keywords=(list)
      tmp_fname = File.join(maildir.path, 'tmp', unique_name)
      File.open(tmp_fname, 'w') { |f| f.write(list.join("\n")) }
      File.move(tmp_fname, File.join(maildir.path, 'courierimapkeywords', unique_name))
    end

    # sets @keywords to the given list
    def set_keywords(list)
      @keywords = list
    end
  end
end

Maildir.send(:include, Maildir::Keywords)
