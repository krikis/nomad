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
      client.should_receive(:subscribe)
      subject.subscribe
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
