require_relative 'faye_helper'
require 'server'

describe SyncServer do

  describe '.new' do
    it 'sets the port to 9292 by default' do
      server = SyncServer.new
      server.instance_eval('@port').should eq(9292)
    end

    it 'sets the server port to the port provided' do
      server = SyncServer.new(8000)
      server.instance_eval('@port').should eq(8000)
    end

    it 'sets the secure flag if "ssl" was provided as argument' do
      server = SyncServer.new(9292, 'ssl')
      server.instance_eval('@secure').should be_true
    end
  end

  describe 'run' do
    subject { SyncServer.new }
    before do
      Faye::WebSocket.stub(:load_adapter)
      EM.stub(:run) {|&block| block.call}
      subject.stub(:setup_server)
      subject.stub(:setup_server_side_client)
    end

    it 'loads the "thin" adapter' do
      Faye::WebSocket.should_receive(:load_adapter).with('thin')
      subject.run
    end

    it 'starts an EventMachine run block' do
      EM.should_receive(:run)
      subject.run
    end

    it 'sets up the server' do
      subject.should_receive(:setup_server)
      subject.run
    end

    it 'sets up the server side client' do
      subject.should_receive(:setup_server_side_client)
      subject.run
    end
  end

  describe '#setup_server' do
    subject { SyncServer.new }
    let(:adapter) { stub 'adapter'}
    before do
      adapter.stub(:run) {|app, options, &block| block.call}
      Rack::Handler.stub(:get => adapter)
    end

    it 'runs the adapter providing the server application and port' do
      adapter.should_receive(:run).with(App, :Port => an_instance_of(Fixnum))
      subject.setup_server
    end
  end

  describe '#setup_server_side_client' do
    subject { SyncServer.new }
    let(:client)             { stub 'client' }
    let(:server_side_client) { stub 'server_side_client',
                                    :subscribe => nil }
    before do
      App.stub(:get_client => client)
      ServerSideClient.stub(:new).and_return(server_side_client)
    end

    it 'creates a new ServerSideClient providing it the servers client' do
      ServerSideClient.should_receive(:new).with(client)
      subject.setup_server_side_client
    end

    it 'subscribes the client for server messages' do
      server_side_client.should_receive(:subscribe)
      subject.setup_server_side_client
    end
  end

end