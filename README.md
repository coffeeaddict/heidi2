# Heidi2 [say it as: Heidi-Zwei]

The redo of [https://github.com/organisedminds/heidi](Heidi), the naive CI
herder girl.

The original Heidi was a bit too naive (or at least the implementation was)
and she started to crumble when there where to many builds.

## CI herder girl?

Heidi2 is a self-deployable Continious Integration platform.

Not Enterprisy-Style, like Travis, Hudson or Jenkins, but plain and simple;
*"Bauern-Art CI"*.

The Heidi philosophy:

  *Not all things need to be tested against every setup. Your thing needs to be
tested against just your setup.*

## Deployment robot?

Will be/have, not yet

## Status

Beta, I am using Heidi2 at [http://organisedminds.com](OrganisedMinds) with
relative success. If your project is not to complex in it's setup, you could
very well benefit from Heidi

## Install

Heidi2 is a Rails application and should be treated as such.

### Heidi2

1. Clone/checkout heidi2 from github.
2. Edit ```config/heidi2.rb``` and make the necessary changes.
3. Run ```./script/create_admin.rb``` to create an initial user.
4. Run ```rails runner script/build_worker.rb``` to have a build worker
5. Run ```rails server``` and visit http://localhost:3000/

### Real-time updates

1. Install node-js
2. Do (as root) ```npm install -g forever```
2. Do ```npm install faye```
3. Run ```forever start ./script/faye_server.js```

## Setup

### Create a project

Visit the website at `http://localhost:3000/` and hit 'New Project'

Pick a nice name, hit 'Create project' and voila; presto! You are done.

### Add one or more repositories

A project can have many many repositories (if one repo fails, the project
fails) so for your website project, that depends on your custom private
utilities gem, you probably want to add both the website and the private-utils
repository to the project.

Repositories have a name, and a URI (in case of Heidi2 that would be 'heidi2'
and 'git://github.com/coffeeaddict/heidi2')

### Attach github events

Now that you have both the project and the repositories setup, it is time for
Heidi2 to start building your stuff. When you visit the page off a repository,
you'll notice an input field labeled 'Github webhook url' - you can use the URL
in that field for a webhook in your Github repository.

## What is left TODO

* Add more tests, especially for building stuff
* Switch from delayed-job and custom celluloid worker to Sidekiq (maybe)
* Add ACL for users
* Add a user and ACL manager
* API?
* Integrate clippy.js

## Contributing to heidi

* Checkout the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to
  have your own version, or is otherwise necessary, that is fine, but please
  isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Hartog C. de Mik. See LICENSE.txt for further details.

