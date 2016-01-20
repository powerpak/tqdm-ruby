require 'tqdm/printer/default_format'
require 'forwardable'

module Tqdm

  # Prints a status line, handling the deletion of previously printed lines with carriage
  # returns as necessary. Instantiated by a `Decorator`.
  #
  # @private
  class Printer
    extend Forwardable

    attr_reader :total, :format, :file

    # Initialize a new StatusPrinter.
    #
    # @param file [File, IO] the status will be printed to this via `#write` and `#flush`
    def initialize(options:)
      @total = options[:total] || total!
      @format = Printer::DefaultFormat.new(total: total, options: options)
      @file = options[:file] || $stderr
      @last_printed_length = 0
    end

    def start
      line(iteration: 0, elapsed_time: 0)
    end

    # Prints a line of text to @file, after deleting the previously printed line
    #
    # @param line [String] a line of text to be printed
    # @return [Integer] the number of bytes written
    def status(iteration:, elapsed_time:)
      meter_line = line(iteration: iteration, elapsed_time: elapsed_time)
      file.write("\r" + meter_line + ' ' * [@last_printed_length - meter_line.size, 0].max)
      file.flush
      @last_printed_length = meter_line.size
    end

    def finish(reprint: false, elapsed_time:)
      line(iteration: total, elapsed_time: elapsed_time) if reprint
      file.write("\n")
    end

    def null_finish
      file.write("\r" + ' ' * @last_printed_length + "\r")
    end

    def_delegators :format, :line, :meter
  end
end
