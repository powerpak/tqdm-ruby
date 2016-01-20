require "tqdm"

module Tqdm
  
  N_BARS = 10
  
  module Utils
  
    # Formats a number of seconds into an hh:mm:ss string.
    def format_interval(t)
      mins, s = t.to_i.divmod(60)
      h, m = mins.divmod(60)
      if h > 0 then '%d:%02d:%02d' % [h, m, s]; else '%02d:%02d' % [m, s]; end
    end
  
    # Formats a count (n) of total items processed + an elapsed time into a
    # textual progress meter.
    def format_meter(n, total, elapsed)
      # n - number of finished iterations
      # total - total number of iterations, or nil
      # elapsed - number of seconds passed since start
      total = (n > total ? nil : total) if total
  
      elapsed_str = format_interval(elapsed)
      rate = elapsed && elapsed > 0 ? ('%5.2f' % (n / elapsed)) : '?'
  
      if total
        frac = n.to_f / total
    
        bar_length = (frac * N_BARS).to_i
        bar = '#' * bar_length + '-' * (N_BARS - bar_length)
    
        percentage = '%3d%%' % (frac * 100)
    
        left_str = n > 0 ? (format_interval(elapsed / n * (total - n))) : '?'
    
        '|%s| %d/%d %s [elapsed: %s left: %s, %s iters/sec]' % [bar, n, total, 
            percentage, elapsed_str, left_str, rate]
      else
        '%d [elapsed: %s, %s iters/sec]' % [n, elapsed_str, rate]
      end
    end
    
  end
  
end