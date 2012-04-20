require 'spec_helper'

feature 'list answers' do

  before { visit '/answers' }

  scenario 'provides a new answer button', :js => true do
    page.should have_content('New Answer')
  end

end