# best_boy

[![Build Status](https://secure.travis-ci.org/Absolventa/best_boy.png?branch=master)](https://secure.travis-ci.org/Absolventa/best_boy)
[![Dependency Status](https://gemnasium.com/Absolventa/best_boy.png)](https://gemnasium.com/Absolventa/best_boy)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/Absolventa/best_boy)

A simple event logging system for `ActiveRecord` models. `BestBoy` logs actions during the life cycle of a record. For example, you
can track creations, updates, deletions or other events with customized names triggered during controller actions. It uses its own polymorphic
database table to log each event.

### Installation

Add it to your gemfile

    gem 'best_boy'

Install it with Bundler

    bundle install

Install the migrations

    rake best_boy:install:migrations

Mount the best boy backend in your routes.rb

    mount BestBoy::Engine, at: '/best_boy'

Run the generator to create your best_boy config file:

    rails g best_boy:install

### Usage

You need to extend your model:

```Ruby
class Monkey < ActiveRecord::Base
  include BestBoy::Eventable
  has_a_best_boy
end
```

By this, `BestBoy` will automatically log two type of events for all instantiated records: Every time `monkey = Monkey.create(…)` has been invoked,
it will create an event of type `create` and every time you call `monkey.destroy` for a record it will create a `BestBoy::Event` of type `destroy`.

If you want to skip this auto-logging, i.e. you only want to track customized events, just deactivate the callback
logging by setting the parameter :disable_callbacks to true.

```Ruby
class Monkey < ActiveRecord::Base
  include BestBoy::Eventable
  has_a_best_boy disable_callbacks: true
end
```

If you want to track custom events, you need to prepare your controller:

```Ruby
class MonkeysController < ApplicationController
  include BestBoy::Controller

  def feed
    if (monkey = Monkey.find_by(id: params[:id]))
      monkey.feed_with("banana", "apple")
      best_boy_event monkey, "feed", "special_event_source"
    end
    head :ok
  end
end
```

### Test mode

BestBoy features a sandbox mode for your testing environment from version 2.1 onward. It will prevent the creation of BestBoy records. Activate it in your spec_helper.rb or test_helper.rb globally:

    BestBoy.test_mode = true

If you want to test your BestBoy integration, you can run your code like this:

    BestBoy.in_real_mode do
      # your expectations / asserts
    end

Conversely, you can also sandbox a specific code block:

    BestBoy.in_test_mode do
      # database will be spared
    end


### Requesting BestBoy::Event data

`BestBoy` ships with an admin interface, largely configurable to fit right into your existing application. To configure
to your needs, create an initializer, i.e. within `config/initializers/best_boy.rb`:

```Ruby
BestBoy.setup do |config|
  config.base_controller      "MyBaseController"          # default: "ApplicationController"      # declare with Controller should be inherited
  config.before_filter        "comma separated symbols"   # default: nil                          # declare before_filter to use inherited before_filters in admin section
  config.skip_before_filter   "comma separated symbols"   # default: nil                          # declare skip_before_filter to skip inherited before_filters in admin section
  config.skip_after_filter    "comma separated symbols"   # default: nil                          # declare skip_after_filter to skip inherited after_filters in admin section
  config.custom_redirect      "relative path as String"   # default: nil                          # set a path to return back to your existing backend
end
```

### Some thoughts about Performance

When you're running BestBoy for a long time, accessing and processing data in
the backend can take awfully long.

By changing to version 1.4.0, we modified BestBoy's data storage organization to
reduce database queries. This leads to far more acceptable loading times. To do
so, BestBoy creates daily reports, which are aggregations
of the persisted events. When computing statistical data, BestBoy
then uses the aggregated tables.

If you're upgrading BestBoy from an older version, there
is a rake task for 'recovering' these report structure for
an existing set of events. Simply run

    rake best_boy:recover_report_history

If you want to recover this report structure not for the whole lifetime,
you can pass a date as argument to the rake task call:

    rake best_boy:recover_report_history['2010-02-01']

The latter would destroy and recover the all reports created after
beginning of Feb 1st, 2010 up to now.

Budget some time for this task, since it can take long if your BestBoyEvent table has grown very big.

### Changelog

#### HEAD (not released yet)
* Create all BestBoy events within after_commit-hooks
* Drop data structure `BestBoy::MonthReport` and always rely on daily reporting

#### 3.4.0
* Drop support for Rails below v5.0
* Add support for Rails 5.1

#### 3.3.0
* Remove google_visualizr charts

#### 3.2.0
* Fix date-parsing issue
* Add frozen_string_literal magic comments

#### 3.1.0
* Drop support for Rails 4.1
* Add support for Rails 5.0

#### 3.0.0
* Major engine cleanup. Aims Rails >= 4.1 from now on.
* Includes backward incompatible changes. See above hint for more information.
* Uses rails engine naming conventions with an isolated ``BestBoy`` namespace
* serving the necessary migrations from the engines migration folder
* serving all assets via the asset pipeline (used to be an opt-in before)
* removes unnecessary generator boilerplate and config options
* uses Bootstrap 3
* allows per class extending instead of polluting the whole app
* answers to xml requests for easy EXCEL integration


#### 2.2.3
* Rename ``report`` method to a more best_boy specific ``trigger_best_boy_event_report`

#### 2.2.2
* Fix dependency bug with kaminari

#### 2.2.1
* flexibilized report creation method to create reports for a specific date
* no compatibility with Ruby 1.9.3

#### 2.2.0
* Updated dependencies for rspec and kaminari
* Make recover_report_history rake task a noop for no previously tracked BestBoyEvents
* Bugfix for report recovery rake task
* use appraisal for testing against different gemsets and Ruby versions

#### 2.1.3
* Compatible with Rails 4.1
* Loosened kaminari dependency requirements

#### 2.1.0
* Code cleanup - now compatible with RSpec 3 syntax
* Support a "dry-run" test mode
* Reduce public methods added by `BestBoy::Eventable` ([#4](https://github.com/Absolventa/best_boy/issues/4))
* Remove mass-assignments that could cause problems with the protected_attributes gem [#8](https://github.com/Absolventa/best_boy/issues/8)
* Do not expose mixed-in controller method ([#9](https://github.com/Absolventa/best_boy/issues/9)))
* Avoid potential name clashes for callbacks switch ([#10](https://github.com/Absolventa/best_boy/issues/10))



Used gems and resources
-----------------------
* [Twitter Bootstrap](http://twitter.github.com/bootstrap/) in its version 3
* [Stefan Petre](http://www.eyecon.ro/bootstrap-datepicker) for Datepicker in Twitter Bootstrap style


Contributors in alphabetic order
--------------------------------
* [carpodaster](https://github.com/carpodaster)
* [cseydel](https://github.com/cseydel)
* [danscho](https://github.com/danscho)
* [neumanrq](https://github.com/neumanrq)

Thanks
------
We ♥ PRs – thanks to everyone contributing to this project.


See [LICENSE.txt](https://raw.github.com/Absolventa/best_boy/master/LICENSE.txt) for usage and licensing details.
