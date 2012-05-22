require 'spec_helper'

describe 'layouts/application' do

  it 'sets @development to Rails.env.development?' do
    render
    rendered.should =~ /this.development = false/
  end

  it 'sets @clientId to the session\'s id' do
    controller.request.stub(:session_options => {:id => 'some_unique_id'})
    render
    rendered.should =~ /this.clientId = 'some_unique_id'/
  end
end