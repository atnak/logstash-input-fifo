# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket" # for Socket.gethostname

# Read events from a single file or fifo (named pipe).
#
# Unlike the 'file' input, this input reads the specified file or named
# pipe once from top to bottom then finish.  This is suited for reading
# events out of a static file that does not grow over time, or reading
# from a named pipe into which events are written by a process.
#
# If the `reopen_after_eof` option (default: false) is set to true, the
# named pipe will be re-opened and re-read upon reaching EOF.  This may
# be required if events are written by a process that does not keep the
# descriptor open across writes.
#
# Because setting `reopen_after_eof` to true is not useful for static
# files and can degrade system health, specifying anything other than a
# named pipe for `path` when `reopen_after_eof` is true is disallowed
# and will result in an error.
#
# By default, each event is assumed to be one line.  The multiline filter
# may be used to join consecutive lines
class LogStash::Inputs::Fifo < LogStash::Inputs::Base
  config_name "fifo"

  default :codec, "line"

  # The path to the named pipe or file to use as the input.
  # This must be an absolute path and cannot be relative.
  #
  # This file will be read from top to bottom and its contents used as
  # the input.
  config :path, :validate => :string, :required => true

  # Configure whether the file will be read through once (default) or
  # if it will be re-opened and re-read upon reaching EOF.  Setting this
  # to true may be required for a named pipe written by a process that
  # does not keep it open across writes.
  #
  # When this is set to false, specifing anything other than a named
  # pipe to `path` will result in an error.
  config :reopen_after_eof, :validate => :boolean, :default => false

  READ_SIZE = 16384

  public
  def register
    @host = Socket.gethostname
    open_close_file
    fix_streaming_codecs
  end # def register

  def run(queue)
    while !stop?
      begin
        data = @file.read(READ_SIZE)
      rescue => e
        # ignore exceptions during shutdown
        break if stop?
        raise
      end

      decode_events(data) do |event|
        decorate(event)
        event.set("host", @host) if !event.include?("host")
        queue << event
      end

      if not data
        if @reopen_after_eof
          open_close_file
        else
          do_stop
        end
      end
    end # loop
  end # def run

  def stop
    open_close_file true
  end # def stop

  private
  def decode_events(data, &block)
    if data
      @codec.decode(data, &block)
    else
      # Handle EOF (weird that logstash-input-stdin doesn't do this and just discards)
      @codec.flush(&block)
    end
  end # def decode_events

  private
  def open_close_file(close_only = false)
    @file.close rescue nil if defined? @file and @file
    @file = nil
    return if close_only

    @file = File.open(@path)
    if @reopen_after_eof and not @file.stat.pipe?
      raise ArgumentError.new("The 'reopen_after_eof' option is set but 'path' is not a named pipe: " + @path)
    end
  end # def open_close_file
end # class LogStash::Inputs::Fifo
