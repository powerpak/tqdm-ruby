require "tqdm/version"
require "tqdm/utils"
require "core_ext/enumerable"

module Tqdm
    
  class StatusPrinter
    def initialize(file)
      @file = file
      @last_printed_len = 0
    end
  
    def print_status(s)
      @file.write("\r" + s + ' ' * [@last_printed_len - s.size, 0].max)
      @file.flush
      @last_printed_len = s.size
    end
  end
  
  
  class TqdmDecorator
    
    include Utils
    
    def initialize(enumerable, opts={})
      @enumerable = enumerable
      @total = opts[:total] || @enumerable.size rescue nil
      @prefix = opts[:desc] ? opts[:desc] + ': ' : ''
      @file = opts[:file] || $stderr
      @sp = StatusPrinter.new(@file)
      @min_iters = opts[:min_iters] || 1
      @min_interval = opts[:min_interval] || 0.5
      @leave = opts[:leave] || false
    end
    
    def start!
      @start_t = @last_print_t = Time.now
      @last_print_n = 0
      @n = 0
      
      @sp.print_status(@prefix + format_meter(0, @total, 0))
    end
    
    def increment!
      @n += 1
  
      if @n - @last_print_n >= @min_iters
        # We check the counter first, to reduce the overhead of time.time()
        cur_t = Time.now
        if cur_t - @last_print_t >= @min_interval
          @sp.print_status(@prefix + format_meter(@n, @total, cur_t - @start_t))
          @last_print_n = @n
          @last_print_t = cur_t
        end
      end
    end
    
    def finish!
      if !@leave
        @sp.print_status('')
        $stdout.write("\r")
      else
        if @last_print_n < @n
          @sp.print_status(@prefix + format_meter(@n, @total, Time.now - start_t))
        end
        @file.write("\n")
      end
    end
    
    def enhance
      tqdm = self
      
      enhanced = @enumerable.clone
      enhanced.define_singleton_method(:each) do |*args, &block|
        tqdm.start!
        super(*args) do |item|
          block.call item
          tqdm.increment!
        end
        tqdm.finish!
      end
      
      enhanced
    end

  end
  
end
