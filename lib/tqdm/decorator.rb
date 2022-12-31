require 'tqdm/printer'

module Tqdm

  # Decorates the #each method of an `Enumerable` by wrapping it so that each
  # iteration produces a pretty progress bar printed to the console or a file handle.
  #
  # @note The `Enumerable` is cloned before it is enhanced; it is not modified directly.
  #
  # @example Enhances `arr` so that an animated progress bar prints while iterating.
  #   arr = (0...1000)
  #   arr_tqdm = Decorator.new(arr).enhance
  #   arr_tqdm.each { |x| sleep 0.01 }
  class Decorator
    
    extend Forwardable

    attr_reader :printer, :enumerable, :iteration, :start_time

    # Initialize a new Decorator. Typically you wouldn't use this object, but
    # would immediately call `#enhance` to retrieve the enhanced `Enumerable`.
    #
    # @param enumerable [Enumerable] the Enumerable object to be enhanced
    # @param options [Hash] more options used to control behavior of the progress bar
    # @option options [String] :desc a short description added to the beginning of the progress bar
    # @option options [Integer] :total (self.size) the expected number of iterations
    # @option options [File, IO] :file ($stderr) a file-like object to output the progress bar to
    # @option options [Boolean] :leave (false) should the progress bar should stay on screen after it's done?
    # @option options [Integer] :min_iters see `:min_interval`
    # @option options [Float] :min_interval If less than min_interval seconds or min_iters iterations have passed since
    #              the last progress meter update, it is not updated again.
    #
    # @example
    #   a = (1...1000)
    #   Decorator.new(a).enhance.each { |x| sleep 0.01 }
    #
    # @example
    #   a = [1, 2, 3, 4]
    #   Decorator.new(a, file: $stdout, leave: true)
    def initialize(enumerable, options={})
      @enumerable = enumerable
      options.merge!(total: total!) unless options[:total]
      @printer = Printer.new(options)
      @min_iterations = options[:min_iters] || 1
      @min_interval = options[:min_interval] || 0.5
      @leave = options[:leave] || false
      @force_refreeze = false
    end

    # Starts the textual progress bar.
    def start!
      @iteration = @last_printed_iteration = 0
      @start_time = @last_print_time = current_time!
    end

    # Called everytime the textual progress bar might need to be updated (i.e. on
    # every iteration). We still check whether the update is appropriate to print to
    # the progress bar before doing so, according to the `:min_iters` and `:min_interval`
    # options.
    #
    # @see #initialize
    def increment!
      @iteration += 1

      return unless (iteration - last_printed_iteration) >= @min_iterations
      # We check the counter first, to reduce the overhead of Time.now
      return unless (current_time! - last_print_time) >= @min_interval
      return if iteration == total && !@leave

      printer.status(iteration, elapsed_time!) 
      @last_printed_iteration = iteration
      @last_print_time = current_time
    end

    # Prints the final state of the textual progress bar. Based on the `:leave` option, this
    # may include deleting it entirely.
    def finish!
      return printer.null_finish unless @leave

      printer.finish(iteration, elapsed_time!, reprint?)
    end

    # Enhances the wrapped `Enumerable`.
    #
    # @note The `Enumerable` is cloned (shallow copied) before it is enhanced; it is not modified directly.
    #
    # @return [Enumerable] a clone of Enumerable enhanced so that every call to `#each` animates the
    #   progress bar.
    def enhance
      decorate_enumerable_each
      enhanced.freeze if @force_refreeze
      enhanced
    end

    private

    def decorate_enumerable_each
      tqdm = self
      enhanced.define_singleton_method(:each) do |*args, &block|
        tqdm.start!
        result = super(*args) do |*items|
          block.call *items if block
          tqdm.increment!
        end
        tqdm.finish!
        result
      end
    end

    def enhanced
      @enhanced ||= enumerable_unfrozen
    end

    # Uses progressively more invasive techniques to return an unfrozen copy of @enumerable
    # Significantly, for some classes like Sequel::Dataset, both #clone and #dup re-freeze
    #    the object, so we have to drop back to Object#clone
    def enumerable_unfrozen
      unfrozen = enumerable.clone(freeze: false)
      return unfrozen unless unfrozen.frozen?
      unfrozen = enumerable.dup
      return unfrozen unless unfrozen.frozen?
      @force_refreeze = true
      unfrozen = Object.instance_method(:clone).bind(enumerable).call(freeze: false)
      unfrozen
    end

    def total!
      enumerable.size rescue enumerable.count rescue nil
    end

    def last_printed_iteration
      @last_printed_iteration ||= iteration
    end

    def last_print_time
      @last_print_time ||= start_time
    end

    def current_time
      @current_time ||= current_time!
    end

    def current_time!
      @current_time = Time.now
    end

    def elapsed_time!
      current_time! - start_time
    end

    def reprint?
      last_printed_iteration < iteration
    end
    
    def_delegator :printer, :total
  end
end
