require "tqdm"

# This is where the real magic begins
# All enumerable objects (e.g.) Arrays will have these methods added to them
module Enumerable
  
  # Upgrades an Enumerable so that any subsequent call to .each will spit out a progress bar
  # opts is a hash that can include:
  #   desc: Short string, describing the progress, added to the beginning of the line
  #   total: Expected number of iterations, if not given, self.size is used
  #   file: A file-like object to output the progress message to, by default, $stderr
  #   leave: A boolean (default False) should the progress bar should stay on screen after it's done?
  #   min_interval: See below
  #   min_iters: If less than min_interval seconds or min_iters iterations have passed since
  #              the last progress meter update, it is not updated again.
  def tqdm(opts = {})
    Tqdm::TqdmDecorator.new(self, opts).enhance
  end
  
end