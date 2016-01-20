module Tqdm

  # Prints a status line, handling the deletion of previously printed lines with carriage
  # returns as necessary. Instantiated by a `Decorator`.
  #
  # @private
  class StatusPrinter
    # Initialize a new StatusPrinter.
    #
    # @param file [File, IO] the status will be printed to this via `#write` and `#flush`
    def initialize(file)
      @file = file
      @last_printed_len = 0
    end

    # Prints a line of text to @file, after deleting the previously printed line
    #
    # @param line [String] a line of text to be printed
    # @return [Integer] the number of bytes written
    def print_status(line)
      @file.write("\r" + line + ' ' * [@last_printed_len - line.size, 0].max)
      @file.flush
      @last_printed_len = line.size
    end
  end
end
