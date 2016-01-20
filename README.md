# tqdm-ruby

tqdm-ruby is a small utility to show a progress indicator while iterating through an Enumerable object.

It is a port of the excellent tdqm library for python: <a href="https://github.com/tqdm/tqdm" target="_blank">https://github.com/tqdm/tqdm</a>.

Call #tqdm on any `Enumerable`, which enhances the object so that iterating over it will produce an animated progress bar on `$stderr`.

    require 'tqdm'
    (0...1000).tqdm.each {|x| sleep 0.01 }

The default output looks like this:

    |####------| 492/1000  49% [elapsed: 00:05 left: 00:05, 88.81 iters/sec]

It works equally well from within [pry](http://pryrepl.org/) and [Jupyter notebooks](https://jupyter.org/).

## Install

Add this line to your application's `Gemfile`:

    gem 'tqdm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tqdm

## Usage

All `Enumerable` objects gain access to the `#tqdm` method, which returns an enhanced object wherein any iteration (by calling `#each` or any of its relatives, e.g., `#each_with_index`, `#each_with_object`, etc.) produces an animated progress bar on $stderr.

    require 'tqdm'
    (0...100).tqdm.each {|x| sleep 0.01 }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
