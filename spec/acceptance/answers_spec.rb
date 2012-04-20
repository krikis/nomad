require 'spec_helper'

feature 'list answers' do

  before { visit '/answers' }

  scenario 'shows a list of answers' do
    page.should have_css('div#answers')
  end

  scenario 'provides a new answer button', :js => true do
  
  end

end