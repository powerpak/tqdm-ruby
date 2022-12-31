# tqdm-ruby
![Build Status](https://github.com/powerpak/tqdm-ruby/actions/workflows/ruby-ci.yml/badge.svg?branch=master&event=push) [![Gem Version](https://badge.fury.io/rb/tqdm.svg)](https://badge.fury.io/rb/tqdm)

tqdm-ruby allows you to add a progress indicator to your loops with minimal effort.

It is a port of the excellent [tqdm library][tqdm] for python. tqdm (read taqadum, تقدّم) means "progress" in Arabic.

Calling `#tqdm` (or `#with_progress`) on any `Enumerable` returns an enhanced clone that animates a meter during iteration.

```ruby
require 'tqdm'
(0...1000).tqdm.each { |x| sleep 0.01 }
```

The default output is sent to `$stderr` and looks like this:

![|####------| 492/1000  49% [elapsed: 00:05 left: 00:05, 88.81 iters/sec]](http://i.imgur.com/6y0t7XS.gif)

It works equally well from within irb, [pry](http://pryrepl.org/), and [iRuby notebooks](https://github.com/SciRuby/iruby) as seen here:

![iRuby notebook screencap](http://i.imgur.com/DilrHuX.gif)

*Why not progressbar, ruby-progressbar, powerbar, or any of the [other gems][]?* These typically have a bucketload of formatting options and you have to manually send updates to the progressbar object to use them. tqdm pleasantly encourages the laziest usage scenario, in that you "set it and forget it".

[tqdm]: https://github.com/tqdm/tqdm
[other gems]: https://www.ruby-toolbox.com/categories/CLI_Progress_Bars

## Install

Install it globally from [Rubygems](https://rubygems.org/gems/tqdm):

    $ gem install tqdm    # (might need sudo for a system ruby)

*or* add this line to your application's Gemfile:

    gem 'tqdm'

And then execute:

    $ bundle

## Usage

All `Enumerable` objects gain access to the `#with_progress` method (aliased as `#tqdm`), which returns an enhanced object wherein any iteration (by calling `#each` or any of its relatives: `#each_with_index`, `#map`, `#select`, etc.) produces an animated progress bar on `$stderr`.

```ruby
require 'tqdm'
num = 1629241972611353
(2..Math.sqrt(num)).with_progress.reject { |x| num % x > 0 }.map { |x| [x, num/x] }
# ... Animates a progress bar while calculating...
# => [[32599913, 49976881]]
```

Options can be provided as a hash, e.g., `.with_progress(desc: "copying", leave: true)`. The following options are available:

- `desc`: Short string, describing the progress, added to the beginning of the line
- `total`: Expected number of iterations, if not given, `self.size || self.count` is used
- `file`: A file-like object to output the progress message to, by default, `$stderr`
- `leave`: A boolean (default `false`). Should the progress bar should stay on screen after it's done?
- `min_interval`: Default is `0.5`. If less than `min_interval` seconds or `min_iters` iterations have passed since the last progress meter update, it is not re-printed (decreasing IO thrashing).
- `min_iters`: Default is `1`. See previous.

[Sequel](http://sequel.jeremyevans.net/) is an amazing database library for Ruby. tqdm can enhance its [`Dataset`](http://sequel.jeremyevans.net/rdoc/classes/Sequel/Dataset.html) objects to show progress while iterating (same options as above):

```ruby
require 'tqdm/sequel'   # Automatically requires tqdm and sequel

# In-memory database for demonstration purposes
DB = Sequel.sqlite
DB.create_table :items do
  primary_key :id
  Float :price
end

# Show progress during big inserts (this isn't new)
(0..100000).with_progress.each { DB[:items].insert(price: rand * 100) }

# Show progress during long SELECT queries
DB[:items].where{ price > 10 }.with_progress.each { |row| "do some processing here" }
```

## TODO

1. Performance improvements
2. Add benchmark suite, expand test coverage
3. Add smoothing for speed estimates
4. Support unicode output (smooth blocks)
5. By default, resize to the apparent width of the output terminal

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
