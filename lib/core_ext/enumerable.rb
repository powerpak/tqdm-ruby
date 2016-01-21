require 'tqdm'

# We enhance all enumerable objects (e.g. `Array`, `Hash`, `Range`, ...) by extending the `Enumerable` module.
# This mixin is only supposed to be present on objects that provide an `#each` method.
#
# @see http://ruby-doc.org/core-2.2.3/Enumerable.html
module Enumerable

  # Returns a *clone* of `self` where all calls to `#each` and related methods will print an animated progress bar 
  # while iterating.
  #
  # @param options [Hash] more options used to control behavior of the progress bar
  # @option options [String] :desc a short description added to the beginning of the progress bar
  # @option options [Integer] :total (self.size) the expected number of iterations
  # @option options [File, IO] :file ($stderr) a file-like object to output the progress bar to
  # @option options [Boolean] :leave (false) should the progress bar should stay on screen after it's done?
  # @option options [Integer] :min_iters see `:min_interval`
  # @option options [Float] :min_interval If less than min_interval seconds or min_iters iterations have passed since
  #              the last progress meter update, it is not updated again.
  # @return [Enumerable] `self` with the `#each` method wrapped as described above
  def with_progress(options = {})
    Tqdm::Decorator.new(self, options).enhance
  end
  alias :tqdm :with_progress

end
