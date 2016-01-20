require 'sequel'
require 'tqdm'

# @see Sequel::Dataset
module Sequel

  # In order to use `Tqdm` with Sequel Datasets, we can simply extend `Sequel::Dataset`
  # with the same `#with_progress` method
  #
  # @see Enumerable#with_progress
  # @see http://sequel.jeremyevans.net/
  # @see http://sequel.jeremyevans.net/rdoc/classes/Sequel/Dataset.html
  class Dataset

    # Returns a clone of `self` where all calls to `#each` and related methods will print an animated progress bar
    # while iterating.
    #
    # @see Enumerable#with_progress
    def with_progress(opts = {})
      Tqdm::TqdmDecorator.new(self, opts).enhance
    end

  end

end
