require "sequel"
require "tqdm"

module Sequel
  
  class Dataset
    def tqdm(opts = {})
      Tqdm::TqdmDecorator.new(self, {total: count}.merge!(opts)).enhance
    end
  end
  
end