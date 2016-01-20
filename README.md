# tqdm-ruby

tqdm-ruby is a small utility to show a progress indicator while iterating through an Enumerable object.

It is a port of the awesome tdqm library for python: <a href="https://github.com/tqdm/tqdm" target="_blank">https://github.com/tqdm/tqdm</a>.

Call #tqdm on any `Enumerable`, which enhances the object will produce a progress bar.

    require 'tqdm'
    (0...1000).tqdm.each {|x| sleep 0.1 }

The default output looks like this:



## Install

Add this line to your application's Gemfile:

    gem 'tqdm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tqdm

## Usage

Any `Enumerable` object will gain access to the `#tqdm` method, which returns an enhanced object wherein any iteration through the object automatically produces the progress bar. By default, the 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
