best_boy
========
[![Build Status](https://secure.travis-ci.org/Absolventa/best_boy.png?branch=master)](https://secure.travis-ci.org/Absolventa/best_boy)
[![Dependency Status](https://gemnasium.com/Absolventa/best_boy.png)](https://gemnasium.com/Absolventa/best_boy)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/Absolventa/best_boy)

A simple event driven logging for ActiveRecord models.


What does this gem do?
----------------------

best_boy logs "create" and "delete" events as well as custom events triggered by controller actions. It uses its own polymorphic database table to log each event.
At the moment, best_boy only provides support for ActiveRecord models.


Rails version support
----------------------

best_boy supports rails 3.2.x in its versions 1.1.x. At this point there is a feature stop and it will only provide fixes for its current features.
Rails 4.0 support is provided in best_boy's versions 1.2.0 up to the current version.


Installation
------------

Add it to your gemfile

    gem 'best_boy'

Install it with Bundler

    bundle install

If you do NOT want to use the asset-pipeline, run the generator as followed

    rails g best_boy

This will install following files into your application

    config/initializers/best_boy.rb

    db_migrate/create_best_boy_events_table.rb

    public/javascripts/bootstrap_datepicker.js

    public/stylesheets/bootstrap.css

    public/stylesheets/bootstrap_datepicker.css

In case you want the gem be compatible with the asset-pipeline, add a flag to the generator call:

    rails g best_boy --asset

See usage section for version information.

Run the migration

    rake db:migrate


Changelog
---------
#### 2.2.0
* Updated dependencies for rspec and kaminari
* Make recover_report_history rake task a noop for no previously tracked BestBoyEvents
* Bugfix for report recovery rake task
* use appraisal for testing against different gemsets andRRuby versions

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


Upgrading to Version 2
--------------------------------

From v2.x, BestBoy uses aggregated tables for the admin panel. You need
to copy the new migrations to your app by running

    rails g best_boy --asset

again. This generator will also ask you to overwrite your existing initializer - just
reject this pressing 'n' for not overwriting your settings. Don't forget to run

    rake db:migrate

and

    rake best_boy:recover_report_history

in the context of your mother app afterwards. See also section "Some thoughts about Performance"
for more details about new data organization.


Update to fit the asset-pipeline
--------------------------------

If you were using the gem without asset-pipeline and want to update your project to fit new rails versions, simply delete all best_boy files in your public folder.

If you need to precompile assets, maybe for deployment on heroku cedar stack, please add the following flag to your best_boy initializer.

    config.precompile_assets = true


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

If no Object is given, it will raise an exception as well as if no event is provided.

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


BestBoyEvent table
------------------

    t.integer   "owner_id"      # owner model id
    t.string    "owner_type"    # owner model class type
    t.string    "event"         # event (create, delete)
    t.string    "event_source"  # event_source parameter for specific action tracking
    t.datetime  "updated_at"    # last update timestamp
    t.datetime  "created_at"    # creation timestamp

Getting BestBoyEvents
---------------------

BestBoy comes with an admin interface, largely configurable to fit right into your existing application.

Following configurations can be done:

    config.precompile_assets    "boolean"                   # default: false                        # if you need best_boy to precompile its assets for the asset-pipeline
    config.orm                  "symbole"                   # default: :active_record               # for now only active_record is supported
    config.base_controller      "String"                    # default: "ApplicationController"      # declare with Controller should be inherited
    config.before_filter        "comma separated symbols"   # default: nil                          # declare before_filter to use inherited before_filters in admin section
    config.skip_before_filter   "comma separated symbols"   # default: nil                          # declare skip_before_filter to skip inherited before_filters in admin section
    config.skip_after_filter    "comma separated symbols"   # default: nil                          # declare skip_after_filter to skip inherited after_filters in admin section
    config.custom_redirect      "relative path as String"   # default: nil                          # set a path to return back to your existing backend

After installation you can access it through:

    <your application path>/best_boy_admin

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

    bundle exec rake best_boy:recover_report_history

If you want to recover this report structure not for the whole lifetime,
you can pass a date as argument to the rake task call:

    bundle exec rake best_boy:recover_report_history['2010-02-01']

The latter would destroy and recover the all reports created after
beginning of Feb 1st, 2010 up to now.

Budget some time for this task, since it can take long if your BestBoyEvent table has grown very big.

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
We ♥ PRs – thanks to everyone contributing to this project. Big thanks to each contributor on Impressionist. This gem helped me ([cseydel](https://github.com/cseydel)) a long way to get here in modelling and creating a gem.


See [LICENSE.txt](https://raw.github.com/Absolventa/best_boy/master/LICENSE.txt) for usage and licensing details.
