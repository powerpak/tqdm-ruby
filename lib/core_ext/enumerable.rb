require "tqdm"

# We enhance all enumerable objects (e.g. `Array`, `Hash`, `Range`, ...) by extending the `Enumerable` module.
# This mixin is only supposed to be present on objects that provide an `#each` method.
#
# @see http://ruby-doc.org/core-2.2.3/Enumerable.html
module Enumerable
  
  # Returns a clone of `self` where all calls to `#each` and related methods will print an animated progress bar 
  # while iterating.
  #
  # @param opts [Hash] more options used to control behavior of the progress bar
  # @option opts [String] :desc a short description added to the beginning of the progress bar
  # @option opts [Integer] :total (self.size) the expected number of iterations
  # @option opts [File, IO] :file ($stderr) a file-like object to output the progress bar to
  # @option opts [Boolean] :leave (false) should the progress bar should stay on screen after it's done?
  # @option opts [Integer] :min_iters see `:min_interval`
  # @option opts [Float] :min_interval If less than min_interval seconds or min_iters iterations have passed since
  #              the last progress meter update, it is not updated again.
  # @return [Enumerable] `self` with the `#each` method wrapped as described above
  def tqdm(opts = {})
    Tqdm::TqdmDecorator.new(self, opts).enhance
  end
  
end