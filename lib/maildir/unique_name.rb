# Class for generating unique file names for new messages
class Maildir::UniqueName
  require 'thread' # For mutex support
  require 'socket' # For getting the hostname
  class << self
    # Return a thread-safe increasing counter
    def counter
      @counter_mutex ||= Mutex.new
      @counter_mutex.synchronize do
        @counter = @counter.to_i + 1
      end
    end

    def create
      self.new.to_s
    end
  end

  # Return a unique file name based on strategy
  def initialize
    # Use the same time object
    @now = Time.now
  end

  # Return the name as a string
  def to_s
    [left, middle, right].join(".")
  end

  protected
  # The left part of the unique name is the number of seconds from since the
  # UNIX epoch
  def left
    @now.to_i.to_s
  end

  # The middle part contains the microsecond, the process id, and a
  # per-process incrementing counter
  def middle
    "M#{'%06d' % microsecond}P#{process_id}Q#{delivery_count}"
  end

  # The right part is the hostname
  def right
    Socket.gethostname
  end

  def microsecond
    @now.usec.to_s
  end

  def process_id
    Process.pid.to_s
  end

  def delivery_count
    self.class.counter.to_s
  end
end
