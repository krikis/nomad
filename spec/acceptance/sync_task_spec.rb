require_relative 'acceptance_helper'

feature 'post synchronization' do

  scenario 'creates a post on the client when the server creates a post', :js => true do
    page.visit '/'
    post = Fabricate(:post, :id => "post_id")
    client = Faye::Client.new('http://nomad.dev:9292/faye')

    client.subscribe('/server/posts') {|message| }

    client.publish('/sync/posts', {"create" => { post.id => post.as_json }})

    page.should have_content(post.title)
    page.should have_content(post.content)
  end

end
