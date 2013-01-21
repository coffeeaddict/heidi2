# Heidi2 [say it as: Heidi-Zwei]

The reincarnation of Heidi, the naive CI herder girl.

Heidi was a bit too naive (or at least the implementation) and started to
crumble when there where to many builds.

## CI herder girl?

Continious Integration, not Enterprisy-Travis-Style, but plain and simple;
*"Bauern-Art"*.

The Heidi philosophy:

  *Not all things need to be tested against everything. Your thing needs to be
  tested against just your setup.*

## Deployment robot?

Will be/have, not yet

## Status

Alpha, I will start to use Heidi2 IRL soon, and it will bring, w/o doubt
many changes.

## Install

Heidi2 is a Rails application and should be treated as such.

### Heidi2

1. Clone/checkout heidi2 from github.
2. Edit ```config/heidi2.rb``` and make the necessary changes.
3. Run ```./script/create_admin.rb``` to create an initial user.
4. Run ```rails server``` and visit http://localhost:3000/

### Real-time updates

1. Install node-js
2. Do (as root) ```npm install -g forever```
2. Do ```npm install faye```
3. Run ```forever start ./script/faye_server.js```

## Contributing to heidi

* Checkout the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Hartog C. de Mik. See LICENSE.txt for
further details.

