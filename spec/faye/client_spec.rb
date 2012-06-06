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
      message = {'versions' => stub, 'client_id' => 'some_unique_id'}
      subject.should_receive(:handle_versions).with(model, message['versions'], message['client_id'], {})
      subject.process_message(model, message)
    end

    it 'handles updates if present' do
      message = {'updates' => stub, 'client_id' => 'some_unique_id'}
      subject.should_receive(:handle_updates).with(model, message['updates'], message['client_id'], {})
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
    let(:version) { stub }
    let(:model)   { TestModel }

    it 'checks the version of each entry' do
      subject.should_receive(:check_version).with(model, version, 'client_id', {})
      subject.handle_versions(model, [version], 'client_id', {})
    end
  end

  describe '#check_version' do
    let(:version) { {'id' => 'some_id',
                     'version' => 'some_version'} }
    let(:model)   { TestModel }
    before do
      TestModel.stub(:find_by_remote_id)
      subject.stub(:json_for => 'some_json')
    end

    it 'tries to find an updated version' do
      model.should_receive(:find_by_remote_id).with('some_id')
      subject.check_version(model, version, 'client_id', {})
    end

    it 'returns true if no object is found' do
      subject.check_version(model, version, 'client_id', {}).should be_true
    end

    context 'when an object is found' do
      let(:remote_version) { stub(:obsoletes?  => false,
                                  :supersedes? => false) }
      let(:object) { stub(:attributes => {},
                          :remote_id => 'some_id',
                          :remote_version => remote_version) }
      before { TestModel.stub(:find_by_remote_id).and_return(object) }

      it 'checks whether its version supersedes the client\'s version' do
        remote_version.should_receive(:supersedes?).with('some_version')
        subject.check_version(model, version, 'client_id', {})
      end

      context 'and the version was expected to be new' do
        let(:version) { {'id' => 'some_id',
                         'version' => 'some_version',
                         'is_new' => true} }

        it 'does not collect the JSON of the object' do
          subject.should_not_receive(:json_for)
          subject.check_version(model, version, 'client_id', {})
        end

        it 'files the version for conflict resolution' do
          results = {}
          subject.check_version(model, version, 'client_id', results)
          results['resolve'].should eq(['some_id'])
          results['update'].should be_blank
        end

        it 'returns false' do
          subject.check_version(model, version, 'client_id', {}).should be_false
        end
      end

      context 'and the version is obsolete' do
        let(:remote_version) { stub(:obsoletes?  => true,
                                    :supersedes? => false) }

        it 'returns false' do
          subject.check_version(model, version, 'client_id', {}).should be_false
        end
      end

      context 'and the object supersedes the client version' do
        let(:remote_version) { stub(:obsoletes?  => false,
                                    :supersedes? => true) }

        it 'collects the JSON of the object' do
          subject.should_receive(:json_for).with(object).once()
          subject.check_version(model, version, 'client_id', {})
        end

        it 'fills the udpate hash with id and json' do
          results = {}
          subject.check_version(model, version, 'client_id', results)
          results['update'].should eq({'some_id' => 'some_json'})
          results['resolve'].should be_blank
        end

        it 'returns false' do
          subject.check_version(model, version, 'client_id', {}).should be_false
        end
      end

      context 'and the object does not supersede the client version' do
        it 'returns true and the object' do
          subject.check_version(model, version, 'client_id', {}).should eq([true, object])
        end
      end
    end
  end

  describe '#handle_updates' do
    let(:update) { stub }
    let(:model)  { TestModel }
    let(:object) { stub }
    before do
      subject.stub(:check_version => [true, object],
                   :process_update => nil)
    end

    it 'checks the version of each update' do
      subject.should_receive(:check_version).with(model, update, 'client_id', an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end

    it 'issues an update if the version check is successful' do
      subject.should_receive(:process_update).with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end

    it 'issues no update if the version check was unsuccessful' do
      subject.stub(:check_version => [false, object])
      subject.should_not_receive(:process_update).with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end
  end

  describe '#process_update' do
    let(:update) { {'id' => 'some_id',
                    'attributes' => {'attribute' => 'some_value'},
                    'version' => 'some_version'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil)
    end

    context 'when no object is passed in' do
      before { model.stub(:create => object) }

      it 'creates an object with the given id for remote_id' do
        model.should_receive(:create).with(:remote_id => 'some_id')
        subject.process_update(model, nil, update, {})
      end
    end

    it 'updates the object with the attributes provided' do
      object.should_receive(:update_attributes).
        with('attribute' => 'some_value')
      subject.process_update(model, object, update, {})
    end

    it 'sets the object version' do
      object.should_receive(:update_attribute).
        with(:remote_version, 'some_version')
      subject.process_update(model, object, update, {})
    end

    it 'returns an acknowledgement for the created object' do
      results = {}
      subject.process_update(model, object, update, results)
      results['ack']['some_id'].should eq('some_version')
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
