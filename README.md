# tqdm-ruby

tqdm-ruby is a small utility to show a progress indicator while iterating through an Enumerable object.

It is a port of the excellent [tdqm library][tqdm] for python.

Call `#tqdm` on any `Enumerable`, which enhances the object so that iterating over it will produce an animated progress bar on `$stderr`.

```ruby
require 'tqdm'
(0...1000).tqdm.each {|x| sleep 0.01 }
```

The default output looks like this:

![|####------| 492/1000  49% [elapsed: 00:05 left: 00:05, 88.81 iters/sec]](http://i.imgur.com/6y0t7XS.gif)

It works equally well from within irb, [pry](http://pryrepl.org/), and [Jupyter notebooks](https://jupyter.org/).

*Why not progressbar, ruby-progressbar, etc.?* These have a bazillion formatting options and you have to update the progressbar object yourself. [tqdm][] strives for the laziest possible interface, in that you "set it and forget it".

[tqdm]: https://github.com/tqdm/tqdm

## Install

Install it globally from [Rubygems](https://rubygems.org/gems/tqdm):

    $ gem install tqdm    # (might need sudo on OS X)

*or* add this line to your application's Gemfile:

    gem 'tqdm'

And then execute:

    $ bundle

## Usage

All `Enumerable` objects gain access to the `#tqdm` method, which returns an enhanced object wherein any iteration (by calling `#each` or any of its relatives, e.g., `#each_with_index`, `#each_with_object`, etc.) produces an animated progress bar on `$stderr`.

Options can be provided for `#tqdm`:

```ruby
require 'tqdm'
(0...1000).tqdm(desc: "demo", leave: true).each {|x| sleep 0.01 }
```

The following options are available:

- `desc`: Short string, describing the progress, added to the beginning of the line
- `total`: Expected number of iterations, if not given, `self.size` is used
- `file`: A file-like object to output the progress message to, by default, `$stderr`
- `leave`: A boolean (default false). Should the progress bar should stay on screen after it's done?
- `min_interval`: Default is `0.5`. If less than `min_interval` seconds or `min_iters` iterations have passed since the last progress meter update, it is not re-printed (decreases IO thrashing).
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
(0..100000).tqdm.each {|x| DB[:items].insert(price: rand * 100) }

# Show progress during long SELECT queries
DB[:items].where{ price > 10 }.tqdm.each {|row| "do some processing here" }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
