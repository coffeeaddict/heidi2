source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'mongoid', '~> 3.1'
platform :ruby do
  gem 'bson_ext'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails',   '~> 2.2.6'
  gem 'therubyracer', '0.10', :platform => :ruby
  gem 'therubyrhino', :platform => :jruby
  gem 'uglifier', '>= 1.0.3'
end

# for rails
gem 'prototype-rails'
gem 'less-rails-bootstrap'
gem 'turbolinks'
gem 'faye'
gem 'devise'
gem 'kindergarten'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'thin'
gem 'kaminari'
gem 'celluloid'
gem 'celluloid-io'

# for heidi
gem 'grit'
gem 'delayed_job_mongoid'
gem 'daemons'
gem 'riak-client'
gem 'simple_shell', '1.1.0'

# for coolness
gem 'github-markdown'
gem 'gemoji'

group :development do
  gem 'rspec-rails'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-rails-mocha'
  gem 'mongoid-rspec'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem "shoulda-matchers"
end
