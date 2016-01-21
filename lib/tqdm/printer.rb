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

    # Initialize a new Printer.
    #
    # @param options [Hash] the options for the instantiating Tqdm::Decorator
    #
    # @see Tqdm::Decorator#initialize
    def initialize(options)
      @total = options[:total]
      @format = Printer::DefaultFormat.new(options)
      @file = options[:file] || $stderr
      @last_printed_length = 0
    end
    
    # Pads a status line so that it is long enough to overwrite the previously written line
    #
    # @param iteration [Integer] number of iterations, out of the total, that are completed
    # @param elapsed_time [Float] number of seconds passed since start
    # @return [String] the padded line
    def padded_line(iteration, elapsed_time)
      meter_line = line(iteration, elapsed_time)
      pad_size = [@last_printed_length - meter_line.size, 0].max
      @last_printed_length = meter_line.size
      meter_line + ' ' * pad_size
    end

    # Prints a line of text to @file, after deleting the previously printed line
    #
    # @param iteration [Integer] number of iterations, out of the total, that are completed
    # @param elapsed_time [Float] number of seconds passed since start
    def status(iteration, elapsed_time)
      file.write("\r" + padded_line(iteration, elapsed_time))
      file.flush
    end

    # Prints a line of text to @file, after deleting the previously printed line
    #
    # @param iteration [Integer] number of iterations, out of the total, that are completed
    # @param elapsed_time [Float] number of seconds passed since start
    # @param reprint [Boolean] do we need to reprint the line one last time?
    def finish(iteration, elapsed_time, reprint)
      file.write("\r" + padded_line(iteration, elapsed_time)) if reprint
      file.write("\n")
      file.flush
    end

    # Disappear without a trace.
    def null_finish
      file.write("\r" + ' ' * @last_printed_length + "\r")
    end

    def_delegators :format, :line, :meter
  end
end
