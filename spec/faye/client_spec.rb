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

    it 'handles new versions if present' do
      message = {'new_versions' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_new_versions).
        with(model, message['new_versions'], {})
      subject.process_message(model, message)
    end

    it 'handles versions if present' do
      message = {'versions' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_versions).
        with(model, message['versions'], 'some_id', {})
      subject.process_message(model, message)
    end

    it 'handles creates if present' do
      message = {'creates' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_creates).
        with(model, message['creates'], {})
      subject.process_message(model, message)
    end

    it 'handles updates if present' do
      message = {'updates' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_updates).
        with(model, message['updates'], 'some_id', {})
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

  describe '#handle_new_versions' do
    let(:new_version) { stub }
    let(:model)   { TestModel }
    before { subject.stub(:check_new_version) }

    it 'checks the version of each entry' do
      subject.should_receive(:check_new_version).with(model, new_version, an_instance_of(Hash))
      subject.handle_new_versions(model, [new_version], {})
    end

    it 'flags the results as preSync results' do
      results = {}
      subject.handle_new_versions(model, [new_version], results)
      results['meta']['preSync'].should be_true
    end

    it 'files all id conflicts for unicast' do
      results = {}
      subject.stub(:check_new_version) do |_, _, unicast|
        unicast['id'] = 'conflict'
      end
      subject.handle_new_versions(model, [new_version], results)
      results['unicast']['id'].should eq('conflict')
    end
  end

  describe '#check_new_version' do
    let(:new_version) { {'id' => 'some_id',
                         'version' => 'some_version'} }
    let(:model)   { TestModel }
    before do
      TestModel.stub(:find_by_remote_id)
      subject.stub(:json_for => 'some_json')
    end

    it 'tries to find an updated version' do
      model.should_receive(:find_by_remote_id).with('some_id')
      subject.check_new_version(model, new_version, {})
    end

    it 'returns true if no object is found' do
      subject.check_new_version(model, new_version, {}).should be_true
    end

    context 'when an object is found' do
      let(:object) { stub }
      before { TestModel.stub(:find_by_remote_id).and_return(object) }

      it 'files the version for conflict resolution' do
        results = {}
        subject.check_new_version(model, new_version, results)
        results['resolve'].should eq(['some_id'])
        results['update'].should be_blank
      end

      it 'returns false' do
        subject.check_new_version(model, new_version, {}).should be_false
      end
    end
  end

  describe '#handle_versions' do
    let(:version) { stub }
    let(:model)   { TestModel }
    before { subject.stub(:check_version) }

    it 'checks the version of each entry' do
      subject.should_receive(:check_version).
        with(model, version, 'client_id', an_instance_of(Hash))
      subject.handle_versions(model, [version], 'client_id', {})
    end

    it 'flags the results as preSync results' do
      results = {}
      subject.handle_versions(model, [version], 'client_id', results)
      results['meta']['preSync'].should be_true
    end

    it 'files all update conflicts for unicast' do
      results = {}
      subject.stub(:check_version) do |_, _, _, unicast|
        unicast['update'] = 'conflict'
      end
      subject.handle_versions(model, [version], 'client_id', results)
      results['unicast']['update'].should eq('conflict')
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

      it 'checks whether its version makes the client\'s version obsolete' do
        remote_version.should_receive(:obsoletes?).
          with('some_version', 'client_id')
        subject.check_version(model, version, 'client_id', {})
      end

      context 'and the version is obsolete' do
        let(:remote_version) { stub(:obsoletes?  => true,
                                    :supersedes? => false) }

        it 'returns false' do
          subject.check_version(model, version, 'client_id', {}).
            should be_false
        end
      end

      it 'checks whether its version supersedes the client\'s version' do
        remote_version.should_receive(:supersedes?).with('some_version')
        subject.check_version(model, version, 'client_id', {})
      end

      context 'and the object supersedes the client version' do
        let(:remote_version) { stub(:obsoletes?  => false,
                                    :supersedes? => true) }
        before { subject.stub(:add_update_for => nil) }

        it 'adds an update for the object when it successfully updated' do
          results = {}
          subject.should_receive(:add_update_for).with(object, results)
          subject.check_version(model, version, 'client_id', results)
        end

        it 'returns false' do
          subject.check_version(model, version, 'client_id', {}).
            should be_false
        end
      end

      context 'and the object does not supersede the client version' do
        it 'returns true and the object' do
          subject.check_version(model, version, 'client_id', {}).
            should eq([true, object])
        end
      end
    end
  end

  describe '#add_update_for' do
    let(:object) { stub(:remote_id => 'some_id') }
    before { subject.stub(:json_for => 'some_json') }

    it 'adds an update for the object to the hash provided' do
      results = {}
      subject.add_update_for(object, results)
      results['update']['some_id'].should eq('some_json')
    end
  end

  describe '#handle_creates' do
    let(:create) { stub }
    let(:model)  { TestModel }
    before do
      subject.stub(:check_new_version => true,
                   :process_create => nil)
    end

    it 'checks the version of each create' do
      subject.should_receive(:check_new_version).
        with(model, create, an_instance_of(Hash))
      subject.handle_creates(model, [create], {})
    end

    it 'files all id conflicts for unicast' do
      results = {}
      subject.stub(:check_new_version) do |_, _, unicast|
        unicast['id'] = 'conflict'
      end
      subject.handle_creates(model, [create], results)
      results['unicast']['id'].should eq('conflict')
    end

    it 'issues a create when the version check is successful' do
      subject.should_receive(:process_create).
        with(model, create, an_instance_of(Hash))
      subject.handle_creates(model, [create], {})
    end

    it 'issues no create when the version check is unsuccessful' do
      subject.stub(:check_new_version => false)
      subject.should_not_receive(:process_create)
      subject.handle_creates(model, [create], {})
    end

    it 'files all successful creates for multicast' do
      results = {}
      subject.stub(:process_create) do |_, _, multicast|
        multicast['successful'] = 'create'
      end
      subject.handle_creates(model, [create], results)
      results['multicast']['successful'].should eq('create')
    end
  end

  describe '#process_create' do
    let(:create) { {'id' => 'some_id',
                    'attributes' => {'attribute' => 'some_value'},
                    'version' => 'some_version'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :valid? => true)
    end
    before do
      model.stub(:new => object)
      subject.stub(:add_create_for => nil)
    end

    it 'creates a new object' do
      model.should_receive(:new).with()
      subject.process_create(model, create, {})
    end

    it 'sets the object remote_id' do
      object.should_receive(:update_attribute).
        with(:remote_id, 'some_id')
      subject.process_create(model, create, {})
    end

    it 'updates the object with the attributes provided' do
      object.should_receive(:update_attributes).
        with('attribute' => 'some_value')
      subject.process_create(model, create, {})
    end

    it 'sets the object version' do
      object.should_receive(:update_attribute).
        with(:remote_version, 'some_version')
      subject.process_create(model, create, {})
    end

    it 'adds a create for the object when it was successfully created' do
      creates = stub
      subject.should_receive(:add_create_for).with(object, creates)
      subject.process_create(model, create, creates)
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
      subject.should_receive(:check_version).
        with(model, update, 'client_id', an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end

    it 'files all update conflicts for unicast' do
      results = {}
      subject.stub(:check_version) do |_, _, _, unicast|
        unicast['update'] = 'conflict'
      end
      subject.handle_updates(model, [update], 'client_id', results)
      results['unicast']['update'].should eq('conflict')
    end

    it 'issues an update when the version check is successful' do
      subject.should_receive(:process_update).
        with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end

    it 'issues no update when the version check is unsuccessful' do
      subject.stub(:check_version => [false, object])
      subject.should_not_receive(:process_update).
        with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', {})
    end

    it 'files all successful updates for multicast' do
      results = {}
      subject.stub(:process_update) do |_, _, _, multicast|
        multicast['successful'] = 'update'
      end
      subject.handle_updates(model, [update], 'client_id', results)
      results['multicast']['successful'].should eq('update')
    end
  end

  describe '#process_update' do
    let(:update) { {'id' => 'some_id',
                    'attributes' => {'attribute' => 'some_value'},
                    'version' => 'some_version'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :remote_id => 'some_id',
           :valid? => true)
    end
    before { subject.stub(:add_update_for => nil) }

    context 'when no object is passed in' do
      before do
        object.stub(:remote_id => nil)
        model.stub(:new => object)
      end

      it 'creates an object' do
        model.should_receive(:new).with()
        subject.process_update(model, nil, update, {})
      end

      it 'sets the object remote_id' do
        object.should_receive(:update_attribute).
          with(:remote_id, 'some_id')
        subject.process_update(model, nil, update, {})
      end
    end

    context 'when an object is passed in' do
      it 'does not create a new object' do
        model.should_not_receive(:new)
        subject.process_update(model, object, update, {})
      end

      it 'does not set the object remote_id' do
        object.should_not_receive(:update_attribute).
          with(:remote_id, 'some_id')
        subject.process_update(model, object, update, {})
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

    it 'adds an update for the object when it successfully updated' do
      updates = stub
      subject.should_receive(:add_update_for).with(object, updates)
      subject.process_update(model, object, update, updates)
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
    let(:unicast)   { stub }
    let(:multicast) { stub }
    let(:results)   { {'unicast' => unicast,
                       'multicast' => multicast} }

    it 'publishes the multicast results to all clients' do
      message = {'model_name' => 'TestModel'}
      client.should_receive(:publish).with('/sync/TestModel', multicast)
      subject.publish_results(message, results)
    end

    context 'when a client id is provided' do
      let(:message) { {'client_id' => 'some_unique_id',
                       'model_name' => 'TestModel'} }

      it 'publishes the unicast results to the sending client' do
        client.should_receive(:publish).
          with('/sync/TestModel/some_unique_id', unicast)
        subject.publish_results(message, results)
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

  describe '#publish' do
    before { EM.stub(:add_periodic_timer) {|time, &block| block.call } }

    it 'calls publish on the client attribute' do
      client.should_receive(:publish)
      subject.publish
    end
  end
end
