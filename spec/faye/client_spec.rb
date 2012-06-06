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

  describe '#process_message' do
    let(:model)   { TestModel }
    before do
      subject.stub(:publish_results)
    end

    it 'handles versions if present' do
      message = {'versions' => stub}
      subject.should_receive(:handle_versions).with(model, message['versions'], {})
      subject.process_message(model, message)
    end

    it 'handles updates if present' do
      message = {'updates' => stub}
      subject.should_receive(:handle_updates).with(model, message['updates'], {})
      subject.process_message(model, message)
    end

    it 'handles creates if present' do
      message = {'creates' => stub}
      subject.should_receive(:handle_creates).with(model, message['creates'])
      subject.process_message(model, message)
    end

    it 'handles destroys if present' do

    end

    it 'publishes the results' do
      message = {}
      subject.should_receive(:publish_results).with(message, an_instance_of(Hash))
      subject.process_message(model, message)
    end
  end

  describe '#handle_versions' do
    let(:versions)       { [{'id' => 'some_id',
                             'version' => 'some_version'},
                            {'id' => 'other_id',
                             'version' => 'other_version'}] }
    let(:model)          { TestModel }
    let(:remote_version) { stub(:supersedes? => true) }
    let(:object)         { stub(:attributes => {},
                                :remote_id => 'some_id',
                                :remote_version => remote_version) }
    before do
      TestModel.stub(:find_by_remote_id).and_return(object, nil)
      subject.stub(:json_for => 'some_json')
    end

    it 'collects for each version an updated version if any exists' do
      model.should_receive(:find_by_remote_id).with('some_id')
      model.should_receive(:find_by_remote_id).with('other_id')
      subject.handle_versions(model, versions, {})
    end

    it 'checks for each found object whether its version
        supersedes the client\'s version' do
      remote_version.should_receive(:supersedes?).with('some_version')
      subject.handle_versions(model, versions, {})
    end

    it 'collects the JSON of all superseding objects' do
      subject.should_receive(:json_for).with(object).once()
      subject.handle_versions(model, versions, {})
    end

    it 'fills the udpates hash with ids for keys and json for values' do
      results = {}
      subject.handle_versions(model, versions, results)
      results['update'].should eq({'some_id' => 'some_json'})
      results['resolve'].should be_blank
    end

    context 'when a new model preexists on the server' do
      let(:versions) { [{'id' => 'some_id',
                         'version' => 'some_version',
                         'is_new' => true}] }

      it 'does not collect the JSON of the object' do
        subject.should_not_receive(:json_for)
        subject.handle_versions(model, versions, {})
      end

      it 'returns a conflict' do
        results = {}
        subject.handle_versions(model, versions, results)
        results['resolve'].should eq(['some_id'])
        results['update'].should be_blank
      end
    end
  end

  describe '#handle_updates' do
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
        acks['some_id'].should eq('some_version')
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
        acks['some_id'].should eq('some_version')
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
    it 'filters out the id and remote_id attribute in the JSON' do
      object = stub(:attributes => {:attribute => 'value',
                                    :id => 1,
                                    :remote_id => 'some_id',
                                    :remote_version => 'some_hash'})
      json = subject.json_for(object)
      json.should eq({:attribute => 'value', :remote_version => 'some_hash'})
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
