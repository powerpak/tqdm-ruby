require "tqdm/version"
require "tqdm/utils"
require "core_ext/enumerable"

# Add a progress bar to your loops in a second.
# A port of Python's [tqdm library](https://github.com/tqdm/tqdm), although we're currently 
# closer to the feature set of [@noamraph's original release](https://github.com/noamraph/tqdm).
#
# Specifically, `Tqdm` enhances `Enumerable` by printing a progress indicator whenever 
# iterating with `#each` or its close relatives.
#
# @author Theodore Pak
# @see https://github.com/tqdm/tqdm
module Tqdm
  
  # The default width of the progress bar, in characters.
  N_BARS = 10
  
  class << self
    # Upgrades `Sequel::Datasets` with the #tqdm method.
    # @see Enumerable#tqdm
    def enhance_sequel!
      require "tqdm/sequel"
    end
  end
  
  # Prints a status line, handling the deletion of previously printed lines with carriage 
  # returns as necessary. Instantiated by a `TqdmDecorator`.
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
  
  
  # Decorates the #each method of an `Enumerable` by wrapping it so that each
  # iteration produces a pretty progress bar printed to the console or a file handle.
  #
  # @note The `Enumerable` is cloned before it is enhanced; it is not modified directly.
  #
  # @example Enhances `arr` so that an animated progress bar prints while iterating.
  #   arr = (0...1000)
  #   arr_tqdm = TqdmDecorator.new(arr).enhance
  #   arr_tqdm.each { |x| sleep 0.01 }
  class TqdmDecorator
    
    include Utils

    # Initialize a new TqdmDecorator. Typically you wouldn't use this object, but
    # would immediately call `#enhance` to retrieve the enhanced `Enumerable`.
    #
    # @param enumerable [Enumerable] the Enumerable object to be enhanced
    # @param opts [Hash] more options used to control behavior of the progress bar
    # @option opts [String] :desc a short description added to the beginning of the progress bar
    # @option opts [Integer] :total (enumerable.size || enumerable.count) the expected number of iterations
    # @option opts [File, IO] :file ($stderr) a file-like object to output the progress bar to
    # @option opts [Boolean] :leave (false) should the progress bar should stay on screen after it's done?
    # @option opts [Integer] :min_iters see `:min_interval`
    # @option opts [Float] :min_interval If less than min_interval seconds or min_iters iterations have passed since
    #              the last progress meter update, it is not updated again.
    #
    # @example
    #   a = (1...1000)
    #   TqdmDecorator.new(a).enhance.each { |x| sleep 0.01 }
    #
    # @example
    #   a = [1, 2, 3, 4]
    #   TqdmDecorator.new(a, file: $stdout, leave: true)
    def initialize(enumerable, opts={})
      @enumerable = enumerable
      @total = opts[:total] || @enumerable.size rescue @enumerable.count rescue nil
      @prefix = opts[:desc] ? opts[:desc] + ': ' : ''
      @file = opts[:file] || $stderr
      @sp = StatusPrinter.new(@file)
      @min_iters = opts[:min_iters] || 1
      @min_interval = opts[:min_interval] || 0.5
      @leave = opts[:leave] || false
    end
    
    # Starts the textual progress bar.
    def start!
      @start_t = @last_print_t = Time.now
      @last_print_n = 0
      @n = 0
      
      @sp.print_status(@prefix + format_meter(0, @total, 0))
    end
    
    # Called everytime the textual progress bar might need to be updated (i.e. on
    # every iteration). We still check whether the update is appropriate to print to
    # the progress bar before doing so, according to the `:min_iters` and `:min_interval`
    # options.
    #
    # @see #initialize
    def increment!
      @n += 1
  
      if @n - @last_print_n >= @min_iters
        # We check the counter first, to reduce the overhead of Time.now
        cur_t = Time.now
        if cur_t - @last_print_t >= @min_interval
          @sp.print_status(@prefix + format_meter(@n, @total, cur_t - @start_t))
          @last_print_n = @n
          @last_print_t = cur_t
        end
      end
    end
    
    # Prints the final state of the textual progress bar. Based on the `:leave` option, this
    # may include deleting it entirely.
    def finish!
      if !@leave
        @sp.print_status('')
        @file.write("\r")
      else
        if @last_print_n < @n
          @sp.print_status(@prefix + format_meter(@n, @total, Time.now - @start_t))
        end
        @file.write("\n")
      end
    end
    
    # Enhances the wrapped `Enumerable`, or the object provided as the sole argument, 
    # with an `#each` singleton method that animates the progress bar.
    #
    # @note When called without an argument, the wrapped `Enumerable` is **cloned** (shallow copied) 
    # before it is enhanced; it is not modified directly.
    #
    # @param enumerable [Enumerable] the object to enhance with the new `#each` singleton method
    # @return [Enumerable] the enhanced object
    def enhance(enumerable = nil)
      tqdm = self
      
      enumerable ||= @enumerable.clone
      # Because this utilizes &block it currently incurs a pretty significant performance penalty.
      # http://mudge.name/2011/01/26/passing-blocks-in-ruby-without-block.html
      #
      # It would be much cheaper to somehow use def and yield, although we have to do that while
      # somehow getting `tqdm` into scope.
      enumerable.define_singleton_method(:each) do |*args, &block|
        tqdm.start!
        super(*args) do |item|
          block.call(item) if block
          tqdm.increment!
        end
        tqdm.finish!
      end
      
      enumerable
    end
    
    # Enhances the wrapped `Enumerable` directly with an `#each` singleton method that animates 
    # the progress bar.
    #
    # @note **Warning:** The `Enumerable` is **not** cloned before it is enhanced with this method.
    # Because this modifies the callee directly, it is harder to reason about downstream effects.
    # However, in theory,
    #
    # @return [Enumerable] the enhanced object
    def enhance!
      enhance(@enumerable)
    end

  end
  
end
