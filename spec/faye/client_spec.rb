require_relative 'faye_helper'
require 'client'

describe ServerSideClient do
  let(:client) { stub('client',
                      :subscribe => nil,
                      :publish => nil) }
  subject { ServerSideClient.new client }

  describe '.new' do
    it 'assigns the client instance attribute' do
      subject.instance_eval("@client").should eq(client)
    end
  end

  describe '#subscribe' do
    it 'calls subscribe on the client attribute' do
      client.should_receive(:subscribe).with('/server/*')
      subject.subscribe
    end

    it 'calls on_server_message when receiving a message' do
      callback = nil
      client.stub(:subscribe) {|channel, proc| callback = proc}
      subject.subscribe
      message = stub
      subject.should_receive(:on_server_message).with(message)
      callback.call(message)
    end
  end

  describe '#on_server_message' do
    it 'publishes on the channel declared in the message' do
      message = stub
      message.stub(:[]) {|key| key}
      client.should_receive(:publish).with('/sync/channel', an_instance_of(Hash))
      subject.on_server_message(message)
    end
  end

  describe '#publish' do
    before { EM.stub(:add_periodic_timer) {|time, block| block.call } }

    it 'calls publish on the client attribute' do
      client.should_receive(:publish)
      subject.publish
    end
  end
end
