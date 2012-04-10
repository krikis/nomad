require 'acceptance/acceptance_helper'

feature 'Sync task', %q{
  In order to keep the list of tasks in sync accross users
  As a user updating a task
  I want the task shown to another user being updated accordingly
} do

  scenario 'first scenario' do
    true.should == true
  end

end
