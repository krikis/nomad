source 'https://rubygems.org'

gem 'rails', '3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'ryansch-andand'
gem 'jquery-rails'
gem 'rails-backbone'
gem 'backbone-support'
gem 'haml-rails'
gem 'haml_assets'
gem 'coffee-filter'
gem 'sanitize'
gem 'faye'
gem 'thin'

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

group :development do
  gem 'pry'
end

group :test, :development do
  gem 'jasminerice'
end

group :test do
  gem 'rspec-rails', '~> 2.6'
  gem 'shoulda-matchers'
  gem 'fabrication'
  gem 'timecop'

  gem 'spork', '~> 0.9.0.rc9'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'fuubar'
  gem 'database_cleaner'
  gem 'guard-jasmine'
  gem 'poltergeist'
  # gem 'launchy'
  gem 'guard-livereload'
  gem 'guard-pow'
  gem 'guard-shell'

  # gem 'cucumber-rails'
  # gem 'guard-cucumber'

  # gem 'jasmine-headless-webkit', :git => "git://github.com/dzello/jasmine-headless-webkit.git"
  # gem 'guard-jasmine-headless-webkit' # works with qt 4.7.4
  # gem 'capybara-webkit'
  # gem 'steak'
  # gem 'factory_girl_rails'
end

group :mac_development do
  # bundle config without :linux_development
  gem 'rb-fsevent'
  gem 'rb-readline'
  gem 'growl'
end

group :linux_development do
  # bundle config without :mac_development
  gem 'rb-inotify'
  gem 'libnotify'
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
