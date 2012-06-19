best_boy
========
[![Build Status](https://secure.travis-ci.org/cseydel/best_boy.png?branch=master)](https://secure.travis-ci.org/cseydel/best_boy)

A simple event driven logging for ActiveRecord models.


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

Generate the BestBoyEvent table migration

    rails g best_boy

This will install following files into your application
    config/initializers/best_boy.rb
    db_migrate/create_best_boy_events_table.rb
    public/javascripts/bootstrap_datepicker.js
    public/stylesheets/bootstrap.css
    public/stylesheets/bootstrap_datepicker.css

See usage section for version information.

Run the migration

    rake db:migrate


Usage
-----

In model context:
    
    has_a_best_boy

This will log "create" and "delete" event for each instance.

In controller context:

    best_boy_event object, event

This will log custom events for a object and a event phrase.
If no Object is given, it will raise an exception as well as if no event is provided.


BestBoyEvent table
------------------

    t.integer   "owner_id"      # owner model id
    t.string    "owner_type"    # owner model class type
    t.string    "event"         # event (create, delete)
    t.datetime  "updated_at"    # last update timestamp
    t.datetime  "created_at"    # creation timestamp

Getting BestBoyEvents
---------------------

BestBoy comes with an admin interface, largely configurable to fit right into your existing application.
Following configurations can be done:

    config.orm                  "symbole"                   # default: :active_record               # for now only active_record is supported
    config.base_controller      "String"                    # default: "ApplicationController"      # declare with Controller should be inherited
    config.before_filter        "comma separated symbols"   # default: nil                          # declare before_filter to use inherited before_filters in admin section
    config.skip_before_filter   "comma separated symbols"   # default: nil                          # declare skip_before_filter to skip inherited before_filters in admin section
    config.custom_redirect      "relative path as String"   # default: nil                          # set a path to return back to your existing backend

Used gems and resource
----------------------
[Twitter Bootstrap](http://twitter.github.com/bootstrap/) in its version 2.0.4
[Stefan Petre](http://www.eyecon.ro/bootstrap-datepicker) for Datepicker in Twitter Bootstrap style

Thanks
------

Big thanks to each contributor on Impressionist. This gem helped me a long way to get here in modelling and creating a gem.

Famous last words
-----------------
It's my first gem, be gentle ;)



Copyright (c) 2012 Christoph Seydel. See LICENSE.txt for further details.