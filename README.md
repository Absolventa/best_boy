best_boy
========
[![Build Status](https://secure.travis-ci.org/Absolventa/best_boy.png?branch=master)](https://secure.travis-ci.org/Absolventa/best_boy)
[![Dependency Status](https://gemnasium.com/Absolventa/best_boy.png)](https://gemnasium.com/Absolventa/best_boy)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/Absolventa/best_boy)
[![best_boy API Documentation](https://www.omniref.com/ruby/gems/best_boy.png)](https://www.omniref.com/ruby/gems/best_boy)

A simple event driven logging for ActiveRecord models.
BestBoy is able to log model-based "create", "update" and "delete" events as well as custom events triggered in controller actions.
It uses its own polymorphic database table to log each event.


Rails version support
----------------------

BestBoy 3 and above only supports Rails >= 4.


Changes in version 3
----------------------

Best Boy version 3 comes with some incompatible backwards changes. However, it's totally worth it because BestBoy now follows best practices of a rails eninge.
This and additional changes of version 3 includes

* serving the necessary migrations from the engines migration folder
* serving all assets via the asset pipeline (used to be a opt-in before)
* removes unnecessary generator boilerplate and config options
* using the newest Bootstrap version (3)


Installation
------------

Add it to your gemfile

    gem 'best_boy'

Install it with Bundler

    bundle install

Install the migrations

    rake best_boy:install:migrations

Mount the best boy backend in your routes.rb

    mount BestBoy::Engine => "/best_boy"

Run the generator to create your best_boy config file:

    rails g best_boy




Usage
-----

In model context:

    has_a_best_boy

This will log "create" and "delete" event for each instance.

If you do not want to selflog create and delete events, maybe because you will sort it semantically with a create source, just deactivate the callback logging by setting the parameter :disable_callbacks to true.

    has_a_best_boy :disable_callbacks => true

In controller context:

    best_boy_event object, event, event_source = nil

This will log custom events for a object and a event phrase. You can specify this event with a event_source parameter to log maybe seperate create actions.

If no object is given, it will raise an exception as well as if no event is provided.


#### Test mode

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



Getting BestBoyEvents
---------------------

BestBoy comes with an admin interface, largely configurable to fit right into your existing application.

Following configurations can be done:

    config.precompile_assets    "boolean"                   # default: false                        # if you need best_boy to precompile its assets for the asset-pipeline
    config.base_controller      "String"                    # default: "ApplicationController"      # declare with Controller should be inherited
    config.before_filter        "comma separated symbols"   # default: nil                          # declare before_filter to use inherited before_filters in admin section
    config.skip_before_filter   "comma separated symbols"   # default: nil                          # declare skip_before_filter to skip inherited before_filters in admin section
    config.skip_after_filter    "comma separated symbols"   # default: nil                          # declare skip_after_filter to skip inherited after_filters in admin section
    config.custom_redirect      "relative path as String"   # default: nil                          # set a path to return back to your existing backend


Some thoughts about Performance
-------------------------------

When you're running BestBoy for a long time, accessing and processing data in
the backend can take awfully long.

By changing to version 1.4.0, we modified BestBoy's data storage organization to
reduce database queries. This leads to far more acceptable loading times. To do
so, BestBoy creates daily and monthly reports, which are aggregations
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


Changelog
---------
#### 3.0.0
* Major engine cleanup. Aims Rails >= 4 from now on.
* Incompatible backwards changes. See above hint for more information.

#### 2.2.3
* Rename ``report``method to a more best_boy specific ``trigger_best_boy_event_report`

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
* [Twitter Bootstrap](http://twitter.github.com/bootstrap/) in its version 2.0.4
* [Stefan Petre](http://www.eyecon.ro/bootstrap-datepicker) for Datepicker in Twitter Bootstrap style
* [Winston Teo Yong Wei](https://github.com/winston/google_visualr) Google_Visualr in its version 2.1.2


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
