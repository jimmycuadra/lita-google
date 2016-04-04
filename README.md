# lita-google

[![Build Status](https://travis-ci.org/jimmycuadra/lita-google.png?branch=master)](https://travis-ci.org/jimmycuadra/lita-google)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-google.png)](https://codeclimate.com/github/jimmycuadra/lita-google)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-google/badge.png)](https://coveralls.io/r/jimmycuadra/lita-google)

**lita-google** is a handler for [Lita](http://lita.io/) that searches Google and replies with the first link.

## Installation

Add lita-google to your Lita instance's Gemfile:

``` ruby
gem "lita-google"
```

## Configuration

### Optional attributes

* `safe_search` (String, Symbol) - The safe search setting to use. Possible values are `:active`, `:moderate`, and `:off`. Default: `:active`.

* `excluded_domains` (Array<String>) - Domains from which you never want to see results.

### Example

```
Lita.configure do |config|
  config.handlers.google.safe_search = :off
  config.handlers.google.excluded_domains = ["gawker.com", "funnyjunk.com", "dailymail.co.uk"]
end
```

## Usage

```
You: Lita, google ruby
Lita: Ruby Programming Language - https://www.ruby-lang.org/
```

## License

[MIT](http://opensource.org/licenses/MIT)
