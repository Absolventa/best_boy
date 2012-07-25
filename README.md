best_boy
========
[![Build Status](https://secure.travis-ci.org/Absolventa/best_boy.png?branch=master)](https://secure.travis-ci.org/Absolventa/best_boy)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/Absolventa/best_boy)

A simple event driven logging for ActiveRecord models.
This gem moved from cseydel/best_boy to absolventa/best_boy


What does this gem do?
----------------------

best_boy logs "create" and "delete" events as well as custom events triggered in controller actions. It uses an own polimorphic database table to log each event.
At the moment, best_boy only provides support for ActiveRecord models.


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


Update to fit the asset-pipeline
--------------------------------

If you were using the gem without asset-pipeline and want to update your project to fit new rails versions, simply delete all best_boy files in your public folder.

If you need to precompile assets, maybe for deployment on heroku cedar stack, please add the following flag to your best_boy initializer.

    config.precompile_assets = true


Update from version 0.1.0
-------------------------

Rerun the generator to get needed migrations

    rails g best_boy

Run the migration

    rake db:migrate


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
    config.custom_redirect      "relative path as String"   # default: nil                          # set a path to return back to your existing backend

After installation you can access it through:
    
    <your application path>/best_boy_admin


Used gems and resource
----------------------
[Twitter Bootstrap](http://twitter.github.com/bootstrap/) in its version 2.0.4

[Stefan Petre](http://www.eyecon.ro/bootstrap-datepicker) for Datepicker in Twitter Bootstrap style

[Winston Teo Yong Wei](https://github.com/winston/google_visualr) Google_Visulr in its version 2.1.2

Thanks
------

Big thanks to each contributor on Impressionist. This gem helped me a long way to get here in modelling and creating a gem.

Copyright (c) 2012 Absolventa GmbH. See LICENSE.txt for further details.