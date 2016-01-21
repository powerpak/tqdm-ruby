module Tqdm
  class Printer
    class DefaultFormat
      PROGRESS_BAR_WIDTH = 10
      SPACE = '-'
      PROGRESS = '#'

      # Initialize a new DefaultFormat.
      #
      # @param options [Hash] the options for the Tqdm::Decorator
      #
      # @see Tqdm::Decorator#initialize
      def initialize(options)
        @total = options[:total]
        @prefix = options[:desc] ? options[:desc] + ': ' : ''
      end

      # Formats the prefix, progress bar and meter as a complete line to be printed
      #
      # @param iteration [Integer] number of finished iterations
      # @param elapsed_time [Float] total number of seconds passed since start
      # @return [String] the complete line to print
      #
      # @see #meter
      def line(iteration, elapsed_time)
        prefix + meter(iteration, total, elapsed_time)
      end

      # Formats a count (n) of total items processed + an elapsed time into a
      # textual progress bar + meter.
      #
      # @param n [Integer] number of finished iterations
      # @param total [Integer, nil] total number of iterations, or nil
      # @param elapsed [Float] number of seconds passed since start
      # @return [String] a textual progress bar + meter
      def meter(n, total, elapsed)
        total = (n > total ? nil : total) if total

        elapsed_str = interval(elapsed)
        rate = elapsed && elapsed > 0 ? ('%5.2f' % (n / elapsed)) : '?'

        if total
          frac = n.to_f / total

          bar_length = (frac * PROGRESS_BAR_WIDTH).to_i
          bar = PROGRESS * bar_length + SPACE * (PROGRESS_BAR_WIDTH - bar_length)

          percentage = '%3d%%' % (frac * 100)

          left_str = n > 0 ? (interval(elapsed / n * (total - n))) : '?'

          '|%s| %d/%d %s [elapsed: %s left: %s, %s iters/sec]' % [bar, n, total,
              percentage, elapsed_str, left_str, rate]
        else
          '%d [elapsed: %s, %s iters/sec]' % [n, elapsed_str, rate]
        end
      end

      private

      attr_reader :total, :prefix

      # Formats a number of seconds into an hh:mm:ss string.
      #
      # @param t [Integer] a number of seconds
      # @return [String] an hh:mm:ss string
      def interval(seconds)
        m, s = seconds.to_i.divmod(60)
        h, m = m.divmod(60)
        if h > 0 then '%d:%02d:%02d' % [h, m, s]; else '%02d:%02d' % [m, s]; end
      end
    end
  end
end
