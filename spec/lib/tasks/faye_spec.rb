require 'spec_helper'
require 'rake'

describe 'faye' do

  describe 'rake faye' do
    let(:rake) { Rake.application }
    let(:server) { stub 'server',
                        :run => nil }
    before do
      rake.init
      rake.load_rakefile
      Rake::Task.define_task(:environment)
      SyncServer.stub(:new).and_return(server)
    end

    it 'has an environment prerequisite' do
      rake['faye'].prerequisites.should include('environment')
    end

    it 'creates a new syncserver with given port and ssl options' do
      SyncServer.should_receive(:new).with(9292, 'ssl')
      rake['faye'].invoke(9292, 'ssl', false)
      rake['faye'].reenable
    end

    it 'calls #run on the new syncserver' do
      server.should_receive :run
      rake['faye'].invoke(9292, 'ssl', false)
      rake['faye'].reenable
    end
  end

end
