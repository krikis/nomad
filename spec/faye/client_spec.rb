require_relative 'faye_helper'
require 'client'

class TestModel
  def self.find_by_remote_id
  end
end

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
      let(:model) { Faye }
      let(:message) { {'model_name' => "#{model}"} }

      context 'and it responds to find_by_remote_id' do
        let(:model) { TestModel }
        let(:message) { {'model_name' => "#{model}"} }

        it 'processes the message' do
          subject.should_receive(:process_message).with(model, message)
          subject.on_server_message(message)
        end
      end

      context 'and it does not respond to find_by_remote_id' do
        it 'does not process the message' do
          subject.should_not_receive(:process_message)
          subject.on_server_message(message)
        end
      end
    end

    context 'when the model in the message is no valid constant' do
      let(:model) { 'NotAnExistingConstant' }
      let(:message) { {'model_name' => model} }

      it 'does not process the message' do
        subject.should_not_receive(:process_message)
        subject.on_server_message(message)
      end
    end
  end

  describe '#publish_results' do
    let(:message)   { {'model_name' => 'TestModel'} }
    let(:unicast)   { stub }
    let(:multicast) { stub }
    let(:results)   { {'unicast'   => unicast,
                       'multicast' => multicast} }

    context 'when there were creates in the received message' do
      before { message['creates'] = [stub] }
      it 'publishes the multicast results to all clients' do
        client.should_receive(:publish).with('/sync/TestModel', multicast)
        subject.publish_results(message, results)
      end
    end

    context 'when there were updates in the received message' do
      before { message['updates'] = [stub] }

      it 'publishes the multicast results to all clients' do
        client.should_receive(:publish).with('/sync/TestModel', multicast)
        subject.publish_results(message, results)
      end
    end

    context 'when a client id is provided' do
      before { message['client_id'] = 'some_unique_id' }

      context 'and there were new_versions in the received message' do
        before { message['new_versions'] = [stub] }

        it 'publishes the unicast results to the sending client' do
          client.should_receive(:publish).
            with('/sync/TestModel/some_unique_id', unicast)
          subject.publish_results(message, results)
        end
      end

      context 'and there were versions in the received message' do
        before { message['versions'] = [stub] }

        it 'publishes the unicast results to the sending client' do
          client.should_receive(:publish).
            with('/sync/TestModel/some_unique_id', unicast)
          subject.publish_results(message, results)
        end
      end

      context 'and there were creates in the received message' do
        before { message['creates'] = [stub] }

        it 'publishes the unicast results to the sending client' do
          client.should_receive(:publish).
            with('/sync/TestModel/some_unique_id', unicast)
          subject.publish_results(message, results)
        end
      end

      context 'and there were updates in the received message' do
        before { message['updates'] = [stub] }

        it 'publishes the unicast results to the sending client' do
          client.should_receive(:publish).
            with('/sync/TestModel/some_unique_id', unicast)
          subject.publish_results(message, results)
        end
      end
    end

    context 'when no client id is provided' do
      let(:message) { {'model_name' => 'TestModel'} }
      it 'it does not publish the unicast results' do
        client.should_not_receive(:publish).
          with(an_instance_of(String), unicast)
        subject.publish_results(message, results)
      end
    end
  end
end
