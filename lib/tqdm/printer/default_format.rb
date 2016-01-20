module Tqdm
  class Printer
    class DefaultFormat
      SPACE = '-'
      PROGRESS = '#'


      def initialize(total:, options:)
        @total = total
        @prefix = options[:desc] ? options[:desc] + ': ' : ''
      end

      def line(iteration:, elapsed_time:)
        prefix + meter(iteration, total, elapsed_time)
      end

      # Formats a count (n) of total items processed + an elapsed time into a
      # textual progress bar + meter.
      #
      # @param n [Integer] number of finished iterations
      # @param total [Integer, nil] total number of iterations, or nil
      # @param elapsed [Integer] number of seconds passed since start
      # @return [String] a textual progress bar + meter
      def meter(n, total, elapsed)
        total = (n > total ? nil : total) if total

        elapsed_str = interval(elapsed)
        rate = elapsed && elapsed > 0 ? ('%5.2f' % (n / elapsed)) : '?'

        if total
          frac = n.to_f / total

          bar_length = (frac * N_BARS).to_i
          bar = PROGRESS * bar_length + SPACE * (N_BARS - bar_length)

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
