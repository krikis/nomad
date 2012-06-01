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
    let(:model)   { TestModel }
    before do
      subject.stub(:handle_changes)
      subject.stub(:publish_results)
    end

    it 'handles changes if present' do
      message = {'changes' => [{}]}
      subject.should_receive(:handle_changes).with(model, message['changes'])
      subject.process_message(model, message)
    end

    it 'handles creates if present' do
      message = {'creates' => [{}]}
      subject.should_receive(:handle_creates).with(model, message['creates'])
      subject.process_message(model, message)
    end

    it 'handles updates if present' do

    end

    it 'handles destroys if present' do

    end

    it 'publishes the results' do
      message = {}
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
    let(:object)  { stub(:attributes => {},
                         :remote_id => 'some_id') }
    before do
      TestModel.stub(:where).and_return([object], [])
      subject.stub(:json_for => 'some_json')
    end

    it 'collects for each object an updated version if any' do
      model.should_receive(:where).with(['remote_id is ? and remote_version is not ?', 'some_id', 'some_version'])
      model.should_receive(:where).with(['remote_id is ? and remote_version is not ?', 'other_id', 'other_version'])
      subject.handle_changes(model, changes)
    end

    it 'collects the JSON of all found objects' do
      subject.should_receive(:json_for).with(object).once()
      subject.handle_changes(model, changes)
    end

    it 'returns a hash with ids for keys and json for values' do
      subject.handle_changes(model, changes).
        should eq({'some_id' => 'some_json'})
    end
  end

  describe '#handle_creates' do
    let(:creates) { [{'id' => 'some_id',
                      'attributes' => {'attribute' => 'some_value'},
                      'version' => 'some_version'}] }
    let(:model)   { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil)
    end
    before do
      model.stub(:where).and_return([])
      model.stub(:create).and_return(object)
    end

    it 'checks if an object with the provided id already exists' do
      model.should_receive(:where).with(:remote_id => 'some_id')
      subject.handle_creates(model, creates)
    end

    context 'when no such object exists' do
      it 'creates an object for each entry' do
        model.should_receive(:create).with(:remote_id => 'some_id')
        subject.handle_creates(model, creates)
      end

      it 'updates the obect with the attributes provided' do
        object.should_receive(:update_attributes).
          with('attribute' => 'some_value')
        subject.handle_creates(model, creates)
      end

      it 'sets the object version' do
        object.should_receive(:update_attribute).
          with(:remote_version, 'some_version')
        subject.handle_creates(model, creates)
      end

      it 'returns an acknowledgement for the created object' do
        conflicts, acks = subject.handle_creates(model, creates)
        acks.should include('some_id')
        conflicts.should be_blank
      end
    end

    context 'when such object exists' do
      before { TestModel.stub(:where).and_return([object]) }

      it 'does not create the object' do
        model.should_not_receive(:create)
        subject.handle_creates(model, creates)
      end

      it 'returns the conflicting id' do
        conflicts, acks = subject.handle_creates(model, creates)
        conflicts.should include('some_id')
        acks.should be_blank
      end
    end
  end

  describe '#json_for' do
    it 'filters out the id, remote_id and remote_version attribute in the JSON' do
      object = stub(:attributes => {:attribute => 'value',
                                    :id => 1,
                                    :remote_id => 'some_id',
                                    :remote_version => 'some_hash'})
      json = subject.json_for(object)
      json.should eq({:attribute => 'value'})
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
