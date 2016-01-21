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
  
  def timecop_loop(enumerable, options = {})
    enumerable.tqdm(options).each do |x|
      Timecop.travel 1
    end
  end

  context 'that has zero elements' do
    let(:enumerable) { (0...0) }
    
    context 'with default options' do
      it 'never displays a progress bar' do
        final_stderr = with_stderr { timecop_loop(enumerable) }
        expect(final_stderr).to eq "\r\r"
      end
    end
    
    context 'with leave: true' do
      it 'never displays a progress bar' do
        final_stderr = with_stderr { timecop_loop(enumerable, leave: true) }
        expect(final_stderr).to eq "\n"
      end
    end
  end

  context 'that has one element' do
    let(:enumerable) { (0...1) }
    
    context 'with default options' do
      it 'never displays a progress bar' do
        final_stderr = with_stderr { timecop_loop(enumerable) }
        expect(final_stderr).to eq "\r\r"
      end
    end
    
    context 'with leave: true' do
      it 'displays a progress bar once at 100%' do
        final_stderr = with_stderr { timecop_loop(enumerable, leave: true) }
        expect(final_stderr).to eq "" \
          "\r|##########| 1/1 100% [elapsed: 00:01 left: 00:00,  1.00 iters/sec]" \
          "\n"
      end
    end

  end

  context 'that has several (five) elements' do
    let(:enumerable) { (0...5) }
    
    context 'with default options' do
      it 'displays a progress bar for the first four steps and deletes it' do
        final_stderr = with_stderr { timecop_loop(enumerable) }

        expect(final_stderr).to eq "" \
          "\r|##--------| 1/5  20% [elapsed: 00:01 left: 00:04,  1.00 iters/sec]" \
          "\r|####------| 2/5  40% [elapsed: 00:02 left: 00:03,  1.00 iters/sec]" \
          "\r|######----| 3/5  60% [elapsed: 00:03 left: 00:02,  1.00 iters/sec]" \
          "\r|########--| 4/5  80% [elapsed: 00:04 left: 00:01,  1.00 iters/sec]" \
          "\r                                                                   " \
          "\r"
      end
    end
    
    context 'with leave: true' do
      it 'displays a progress bar with as many steps as elements and leaves it' do
        final_stderr = with_stderr { timecop_loop(enumerable, leave: true) }

        expect(final_stderr).to eq "" \
          "\r|##--------| 1/5  20% [elapsed: 00:01 left: 00:04,  1.00 iters/sec]" \
          "\r|####------| 2/5  40% [elapsed: 00:02 left: 00:03,  1.00 iters/sec]" \
          "\r|######----| 3/5  60% [elapsed: 00:03 left: 00:02,  1.00 iters/sec]" \
          "\r|########--| 4/5  80% [elapsed: 00:04 left: 00:01,  1.00 iters/sec]" \
          "\r|##########| 5/5 100% [elapsed: 00:05 left: 00:00,  1.00 iters/sec]" \
          "\n"
      end
    end
  end
end
