require 'spec_helper'

feature 'post synchronization' do

  scenario 'creates a post on the client when the server creates a post', :js => true do
    page.visit '/'
    post = Fabricate(:post)
    page.should have_content(post.title)
    page.should have_content(post.content)
  end

end
