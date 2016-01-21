require 'spec_helper'
require 'timecop'
require_relative '../lib/tqdm'

describe 'When enumerating over an object' do
  before { Timecop.freeze }
  after  { Timecop.return }

  def with_stderr(&block)
    old_stderr = $stderr
    $stderr    = StringIO.new

    block.call

    return $stderr.string
  ensure
    $stderr = old_stderr
  end

  context 'that has zero elements' do
    it 'never displays a progress bar' do
      final_stderr = with_stderr do
        (0..0).tqdm.each do |x|
          Timecop.travel 1
        end
      end

      expect(final_stderr).to eq "\r\r"
    end
  end

  context 'that has 1 element' do
    it 'displays a progress bar once at 100%' do
      final_stderr = with_stderr do
        (0..1).tqdm.each do |x|
          Timecop.travel 1
        end
      end

      expect(final_stderr).to eq "" \
        "\r|##########| 2/2 100% [elapsed: 00:02 left: 00:00,  1.00 iters/sec]" \
        "\r                                                                   " \
        "\r"
    end

  end

  context 'that has many elements' do
    it 'displays a progress bar once at 100%' do
      final_stderr = with_stderr do
        (0..5).tqdm.each do |x|
          Timecop.travel 1
        end
      end

      expect(final_stderr).to eq "" \
        "\r|###-------| 2/6  33% [elapsed: 00:02 left: 00:04,  1.00 iters/sec]" \
        "\r|#####-----| 3/6  50% [elapsed: 00:03 left: 00:03,  1.00 iters/sec]" \
        "\r|######----| 4/6  66% [elapsed: 00:04 left: 00:02,  1.00 iters/sec]" \
        "\r|########--| 5/6  83% [elapsed: 00:05 left: 00:01,  1.00 iters/sec]" \
        "\r|##########| 6/6 100% [elapsed: 00:06 left: 00:00,  1.00 iters/sec]" \
        "\r                                                                   " \
        "\r"
    end
  end
end
