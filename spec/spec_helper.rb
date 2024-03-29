require 'rubygems'
require 'spork'
# uncomment the following line to use spork with the debugger
# require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # Require rails
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/poltergeist'
  require 'andand'

  # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
  # order to ease the transition to Capybara we set the default here. If you'd
  # prefer to use XPath just remove this line and adjust any selectors in your
  # steps to use the XPath syntax.
  Capybara.default_selector = :css

  # Capybara.javascript_driver = :webkit
  Capybara.javascript_driver = :poltergeist
  # Capybara.app_host = "http://nomad.dev/"
  # Capybara.run_server = false

  # Start faye server
  require_relative 'support/faye_server_helper'
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each do |file|
    # skip faye_server as it is included in the spork prefork block
    next if file =~ /support\/faye_server_helper.rb/
    require file
  end

  RSpec.configure do |config|
    config.mock_with :rspec

    config.before(:suite) do
      Fabrication.clear_definitions
      DatabaseCleaner.clean_with :truncation
    end

    config.before(:each) do
      Capybara.reset_sessions!
      if example.metadata[:js]
        DatabaseCleaner.strategy = :truncation
      else
        DatabaseCleaner.strategy = :transaction
        DatabaseCleaner.start
      end
    end

    config.after(:each) do
      if example.metadata[:js]
        page.execute_script('window.localStorage.clear()')
      end
      DatabaseCleaner.clean
    end

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end
end