require_relative 'faye_helper'
require 'client'

class TestModel
  def self.where
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

      context 'and it responds to where' do
        let(:model) { TestModel }
        let(:message) { {'model_name' => "#{model}"} }

        it 'processes the message' do
          subject.should_receive(:process_message).with(model, message)
          subject.on_server_message(message)
        end
      end

      context 'and it does not respond to where' do
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

  describe '#process_message' do
    let(:message) { {'changes' => [{'id' => 'some_id',
                                    'old_version' => 'some_version'}]} }
    let(:model)   { TestModel }
    before do
      subject.stub(:handle_changes)
      subject.stub(:publish_results)
    end

    it 'handles changes' do
      subject.should_receive(:handle_changes).with(model, message['changes'])
      subject.process_message(model, message)
    end

    it 'handles creates' do

    end

    it 'handles updates' do

    end

    it 'handles destroys' do

    end

    it 'publishes the results' do
      subject.should_receive(:publish_results).with(message, an_instance_of(Hash))
      subject.process_message(model, message)
    end
  end

  describe '#handle_changes' do
    let(:changes) { [{'id' => 'some_id',
                      'old_version' => 'some_version'},
                      {'id' => 'other_id',
                       'old_version' => 'other_version'}] }
    let(:model)   { TestModel }
    let(:object)  { stub(:id => 'some_id') }
    before do
      TestModel.stub(:where).and_return([object], [])
      subject.stub(:jsonify => 'some_json')
    end

    it 'collects for each object an updated version if any' do
      TestModel.should_receive(:where).with(['id is ? and version is not ?', 'some_id', 'some_version'])
      TestModel.should_receive(:where).with(['id is ? and version is not ?', 'other_id', 'other_version'])
      subject.handle_changes(model, changes)
    end

    it 'collects the JSON of all found objects' do
      subject.should_receive(:jsonify).with(object).once()
      subject.handle_changes(model, changes)
    end

    it 'returns a hash with ids for keys and json for values' do
      subject.handle_changes(model, changes).
        should eq({'some_id' => 'some_json'})
    end
  end

  describe '#jsonify' do
    it 'filters out the id and version attribute in the JSON' do
      object = stub(:id => 'some_id')
      object.should_receive(:to_json).with(:except => [:id, :version])
      subject.jsonify(object)
    end
  end

  describe '#publish_results' do
    let(:results) { stub }

    context 'when a client id is provided' do
      let(:message) { {'client_id' => 'some_unique_id',
                       'model_name' => 'TestModel'} }

      it 'publishes to the sending client only' do
        client.should_receive(:publish).with('/sync/TestModel/some_unique_id', results)
        subject.publish_results(message, results)
      end
    end

    context 'when no client id is provided' do
      let(:message) { {'model_name' => 'TestModel'} }
      it 'publishes to the global channel' do
        client.should_receive(:publish).with('/sync/TestModel', results)
        subject.publish_results(message, results)
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
