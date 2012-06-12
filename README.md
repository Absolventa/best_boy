best_boy
========

A simple event driven logging for ActiveRecord models.
This gem is not tested for now. I will add testing asap.


What does this gem do?
----------------------

best_boy logs create and delete events in its first iteration. It uses an own polimorphic database table to log each event.
At the moment, best_boy only provides support for ActiveRecord models.


Installation
------------

Add it to your gemfile

    gem 'best_boy'

Install it with Bundler

    bundle install

Generate the BestBoyEvent table migration

    rails g best_boy

Run the migration

    rake db:migrate


Usage
-----

In model context:
    
    has_a_best_boy

This will log create and delete event for each instance.

In controller context:

    best_boy_event object, event

This will log custom events for a object and a event phrase.
If no Object is givin, it will raise an exception as well as if no event is provided.


BestBoyEvent table
------------------

    t.integer   "owner_id"      # owner model id
    t.string    "owner_type"    # owner model class type
    t.string    "event"         # event (create, delete)
    t.datetime  "updated_at"    # last update timestamp
    t.datetime  "created_at"    # creation timestamp

Getting BestBoyEvents
---------------------

The table is namespaced, so you can access for statistics maybe with BestBoy::BestBoyEvent.where...


Famous last words
-----------------
It's my first gem, be gentle ;)

Copyright (c) 2012 Christoph Seydel. See LICENSE.txt for further details.