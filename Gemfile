source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.0.1'
  # gem 'twitter-bootstrap-rails'
  gem 'haml_coffee_assets'
  gem 'execjs'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'rails-backbone'
gem 'backbone-support'
gem 'haml-rails'
gem 'haml_assets'
gem 'coffee-filter'
gem 'sanitize'

group :test, :development do
  gem 'rspec-rails', '~> 2.6'
  gem 'fabrication'
  gem 'timecop'

  gem 'spork', '~> 0.9.0.rc9' # Spork keeps a process running to speed up tests
  gem 'guard-spork'           # Guard/Spork integration
  gem 'guard-rspec'           # Guard automatically runs tests
  gem 'guard-cucumber'
  gem 'fuubar'
  # gem 'jasmine-headless-webkit', :git => "git://github.com/dzello/jasmine-headless-webkit.git"
  # gem 'guard-jasmine-headless-webkit' # works with qt 4.7.4
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'jasminerice'
  gem 'guard-jasmine'

  require 'rbconfig'
  case RbConfig::CONFIG['host_os']
  when /darwin/
    gem 'rb-fsevent'
    gem 'rb-readline'
    gem 'growl'
  when /linux/
    gem 'rb-inotify'
    gem 'libnotify'
  end
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
