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
      client.stub(:subscribe) {|channel, &proc| callback = proc}
      subject.subscribe
      message = stub
      subject.should_receive(:on_server_message).with(message)
      callback.call(message)
    end
  end

  describe '#on_server_message' do
    context 'when the model in the message is a valid constant' do
      context 'and it responds to find_by_id' do
        let(:message) { {'client_id' => 'some_unique_id',
                         'model_name' => 'Post',
                         'object_ids' => ['some_id']} }

        it 'collects the most recent version of the objects in the message' do
          Post.should_receive(:find_by_id).with('some_id')
          subject.on_server_message(message)
        end

        it 'publishes to the sending client only if a client_id was provided' do
          client.should_receive(:publish).with('/sync/Post/some_unique_id', an_instance_of(Hash))
          subject.on_server_message(message)
        end

        it 'publishes to the provided channel if there is no client_id' do
          client.should_receive(:publish).with('/sync/Post', an_instance_of(Hash))
          subject.on_server_message({'model_name' => 'Post',
                                     'object_ids' => ['some_id']})
        end

        it 'publishes the JSON for the collected objects' do
          json_object = stub
          Post.stub(:find_by_id).and_return(stub(:to_json => json_object))
          client.should_receive(:publish).with(an_instance_of(String), {'objects' => [json_object]})
          subject.on_server_message(message)
        end
      end

      context 'and it does not respond to find_by_id' do
        let(:message) { {'model_name' => 'Rails', 'object_ids' => ['some_id']} }
        it 'does not try to collect objects' do
          Test.should_not_receive(:find_by_id)
          subject.on_server_message(message)
        end
      end
    end

    context 'when the model in the message is no valid constant' do
      let(:model) { 'NotAnExistingConstant' }
      let(:message) { {'model_name' => model, 'object_ids' => ['some_id']} }
      it 'does not try to constantize it' do
        model.should_not_receive(:constantize)
        subject.on_server_message(message)
      end
    end
  end

  describe '#publish' do
    before { EM.stub(:add_periodic_timer) {|time, &block| block.call } }

    it 'calls publish on the client attribute' do
      client.should_receive(:publish)
      subject.publish
    end
  end
end
