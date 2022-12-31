require 'spec_helper'
require 'timecop'
require_relative '../lib/tqdm'
require_relative '../lib/tqdm/sequel'

describe 'When enumerating over a Sequel dataset' do
  before { Timecop.freeze }
  after  { Timecop.return }
    
  def timecop_loop(dataset, options = {})
    dataset.tqdm(options).each do |x|
      Timecop.travel 1
    end
  end

  context 'that has several (five) elements' do
    let(:database) do
      db = Sequel.sqlite
      db.create_table :items do
        primary_key :id
        Float :price
      end
    
      (0...5).each { db[:items].insert(price: rand * 100) }
    
      db
    end
    
    context 'with default options' do
      it 'displays a progress bar for the first four steps and deletes it' do
        final_stderr = with_stderr { timecop_loop(database[:items]) }

        expect(final_stderr).to eq "" \
          "\r|##--------| 1/5  20% [elapsed: 00:01 left: 00:04,  1.00 iters/sec]" \
          "\r|####------| 2/5  40% [elapsed: 00:02 left: 00:03,  1.00 iters/sec]" \
          "\r|######----| 3/5  60% [elapsed: 00:03 left: 00:02,  1.00 iters/sec]" \
          "\r|########--| 4/5  80% [elapsed: 00:04 left: 00:01,  1.00 iters/sec]" \
          "\r                                                                   " \
          "\r"
      end

      it 'returns a re-frozen object' do
        enhanced = nil
        with_stderr { enhanced = timecop_loop(database[:items]) }
        expect(enhanced.frozen?).to be_truthy
      end

      it 'returns an object inheriting from Sequel::Dataset' do
        enhanced = nil
        with_stderr { enhanced = timecop_loop(database[:items]) }
        expect(enhanced).to be_kind_of(Sequel::Dataset)
      end
    end
    
    context 'with leave: true' do
      it 'displays a progress bar with as many steps as elements and leaves it' do
        final_stderr = with_stderr { timecop_loop(database[:items], leave: true) }

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
