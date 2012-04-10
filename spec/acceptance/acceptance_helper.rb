require 'spec_helper'

Spork.each_run do
  # This code will be run each time you run your specs.
  # Put your acceptance spec helpers inside spec/acceptance/support
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
end