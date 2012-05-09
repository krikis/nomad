require_relative 'acceptance_helper'

feature 'fetch updates from server' do

  scenario 'publishes a message to the server on connect', :js => true do
    page.visit '/'
    
  end

end
