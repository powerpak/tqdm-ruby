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
    # @param options [Hash] options are the same as Enumerable#with_progress
    #
    # @see Enumerable#with_progress
    def with_progress(options = {})
      Tqdm::Decorator.new(self, options).enhance
    end
    alias :tqdm :with_progress

  end

end
