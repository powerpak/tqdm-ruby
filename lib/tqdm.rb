require 'tqdm/version'
require 'tqdm/decorator'
require 'core_ext/enumerable'

# Add a progress bar to your loops in a second.
# A port of Python's [tqdm library](https://github.com/tqdm/tqdm), although we're currently
# closer to the feature set of [@noamraph's original release](https://github.com/noamraph/tqdm).
#
# Specifically, `Tqdm` enhances `Enumerable` by printing a progress indicator whenever
# iterating with `#each` or its close relatives.
#
# @author Theodore Pak
# @see https://github.com/tqdm/tqdm
module Tqdm

  class << self
    # Upgrades `Sequel::Datasets` with the #with_progress method.
    # @see Enumerable#with_progress
    def enhance_sequel!
      require 'tqdm/sequel'
    end
  end

end
