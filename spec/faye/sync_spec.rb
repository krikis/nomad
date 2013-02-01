require_relative 'faye_helper'
require 'sync'

class TestModel
  def self.find_by_remote_id
  end

  def self.where
  end

  def self.transaction(&block)
    block.call
  end
end

class KlassWithFayeSync
  include Faye::Sync
end

describe Faye::Sync do

  subject { KlassWithFayeSync.new }

  describe '#initresults' do
    let(:time) { mock }
    before { LamportClock.stub(:tick).and_return(time) }

    it 'initializes the unicast message' do
      subject.init_results['unicast'].should be
    end

    it 'initializes the unicast meta tag' do
      results = subject.init_results({'client_id' => 'some_id'})
      results['unicast']['meta'].should eq({'client' => 'some_id',
                                            'unicast' => true})
    end

    it 'initializes the resolve list' do
      subject.init_results['unicast']['resolve'].should eq([])
    end

    it 'initializes the rebase list' do
      subject.init_results['unicast']['update'].should eq({})
    end

    it 'initializes the multicast message' do
      subject.init_results['multicast'].should be
    end

    it 'initializes the multicast meta tag' do
      subject.init_results({'client_id' => 'some_id'})['multicast']['meta'].
        should eq({'client' => 'some_id'})
    end

    it 'initializes the create list' do
      subject.init_results['multicast']['create'].should eq({})
    end

    it 'initializes the update list' do
      subject.init_results['multicast']['update'].should eq({})
    end
  end

  describe '#add_missed_objects' do
    let(:lamport_clock) { 5 }
    let(:model)         { TestModel }
    let(:object)        { mock(:last_update => lamport_clock) }
    let(:other_object)  { mock(:last_update => lamport_clock - 1) }
    let(:objects) do
      mock(:where => [object]).tap do |mock|
        mock.stub(:each){|&block| [object].each &block}
        mock.stub(:map) {|&block| [object].map &block}
      end
    end
    let(:results) { {'meta' => {}} }
    before do
      model.stub(:where => objects, :all => objects)
      subject.stub(:add_update_for => nil)
    end

    it 'queries the model for all recently updated/created objects' do
      model.should_receive(:where).with(['last_update > ?', lamport_clock])
      subject.add_missed_objects(model, {'last_synced' => lamport_clock}, results)
    end

    it 'queries the model for all objects when no timestamp is given' do
      model.should_receive(:all)
      subject.add_missed_objects(model, {}, results)
    end

    it 'filters out objects that are already synced when sync sessions are specified' do
      objects.should_receive(:where).with('last_update not in (?)', [4, 6, 7])
      subject.add_missed_objects(model,
                                 {'sync_sessions' => [4, 6, 7]},
                                 results)
    end

    it 'does not filter out objects when no sync sessions are specified' do
      objects.should_not_receive(:where)
      subject.add_missed_objects(model, {}, results)
    end

    it 'files each object for sync' do
      subject.should_receive(:add_update_for).with(object, results)
      subject.add_missed_objects(model,
                                 {'last_synced' => 'lamport_clock'},
                                 results)
    end

    it 'sets the most recent lamport clock to the results' do
      subject.add_missed_objects(model, {}, results)
      results['meta']['timestamp'].should eq(lamport_clock)
    end
  end

  describe '#add_update_for' do
    let(:object) do
      stub(:remote_id => 'some_id',
           :last_update => @time = mock(:> => false))
    end
    let(:results) { {'update' => {}, 'meta' => {'timestamp' => mock}}}
    before { subject.stub(:json_for => 'some_json') }

    it 'adds an update for the object to the hash provided' do
      subject.add_update_for(object, results)
      results['update']['some_id'].should eq('some_json')
    end
  end

  describe '#json_for' do
    it 'filters out the id, remote_id and last_update attributes' do
      object = stub(:attributes => {:attribute => 'value',
                                    :id => 1,
                                    :remote_id => 'some_id',
                                    :last_update => 'last_update',
                                    :remote_version => 'some_hash'})
      json = subject.json_for(object)
      json.should eq({:attribute => 'value', :remote_version => 'some_hash'})
    end

    it 'filters out attributes with no value' do
      object = stub(:attributes => {:attribute => 'value',
                                    :other_attribute => nil})
      json = subject.json_for(object)
      json.should eq({:attribute => 'value'})
    end
  end

  describe '#process_message' do
    let(:model)   { TestModel }
    let(:message) { {'client_id' => 'some_id'} }
    let(:results) { mock }
    before do
      subject.stub(:handle_creates => @create_ids = mock,
                   :handle_updates => @update_ids = mock)
    end

    it 'handles new versions if present' do
      subject.should_receive(:handle_new_versions).
        with(model, message['new_versions'] = mock, results)
      subject.process_message(model, message, results)
    end

    it 'handles versions if present' do
      subject.should_receive(:handle_versions).
        with(model, message['versions'] = mock, 'some_id', results)
      subject.process_message(model, message, results)
    end

    it 'handles creates if present' do
      subject.should_receive(:handle_creates).
        with(model, message['creates'] = mock, results)
      subject.process_message(model, message, results)
    end

    it 'handles updates if present' do
      subject.should_receive(:handle_updates).
        with(model, message['updates'] = mock, message['client_id'], results)
      subject.process_message(model, message, results)
    end

    it 'handles destroys if present' do

    end

    it 'returns the ids of created and updated objects' do
      message = {'client_id' => 'some_id', 'creates' => mock, 'updates' => mock}
      processed = subject.process_message(model, message, results)
      processed.should eq({:create_ids => @create_ids, :update_ids => @update_ids})
    end
  end

  describe '#handle_creates' do
    let(:create)  { stub }
    let(:model)   { TestModel }
    let(:results) { {'meta' => {}} }
    before do
      subject.stub(:check_new_version => true,
                   :process_create => nil)
    end

    it 'handles each create in a single transaction' do
      TestModel.should_receive(:transaction).once
      subject.should_not_receive(:check_new_version)
      subject.should_not_receive(:process_create)
      subject.handle_creates(model, [create], results)
    end

    it 'checks the version of each create' do
      subject.should_receive(:check_new_version).with(model, create, results)
      subject.handle_creates(model, [create], results)
    end

    it 'issues a create when the version check is successful' do
      subject.should_receive(:process_create).with(model, create)
      subject.handle_creates(model, [create], results)
    end

    it 'issues no create when the version check is unsuccessful' do
      subject.stub(:check_new_version => false)
      subject.should_not_receive(:process_create)
      subject.handle_creates(model, [create], results)
    end

    it 'returns the compacted output of the process_create method calls' do
      subject.stub(:process_create).and_return(nil, create_id = mock)
      create_ids = subject.handle_creates(model, [create, create], results)
      create_ids.should eq([create_id])
    end
  end

  describe '#process_create' do
    let(:create) { {'id' => 'some_id',
                    'attributes' => {'attribute' => 'some_value'},
                    'version' => 'some_version',
                    'created_at' => 'created_at',
                    'updated_at' => 'updated_at'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :valid? => true,
           :id => @id = mock)
    end
    let(:time)    { mock }
    let(:results) { {'meta' => {'timestamp' => time}} }
    before do
      model.stub(:new => object)
      subject.stub(:set_attributes => nil,
                   :add_create_for => nil)
    end

    it 'creates a new object' do
      model.should_receive(:new).with()
      subject.process_create(model, create)
    end

    it 'sets the object attributes' do
      subject.should_receive(:set_attributes).with(object, create)
      subject.process_create(model, create)
    end

    it 'returns the object id' do
      subject.process_create(model, create).should eq(@id)
    end

    context 'when the object is not valid' do
      before { object.stub(:valid? => false) }

      it 'does not return the object id' do
        subject.process_create(model, create).should_not be
      end
    end
  end

  describe '#set_attributes' do
    let(:attributes) { {'id' => 'some_id',
                        'attributes' => {'attribute' => 'some_value'},
                        'version' => 'some_version',
                        'created_at' => 'created_at',
                        'updated_at' => 'updated_at'} }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :remote_id => nil,
           :valid? => true)
    end

    it 'sets the object remote_id' do
      object.should_receive(:update_attribute).
        with(:remote_id, 'some_id')
      subject.set_attributes(object, attributes)
    end

    it 'preserves the object remote_id if it preexists' do
      object.stub(:remote_id => 'remote_id')
      object.should_not_receive(:update_attribute).
        with(:remote_id, 'some_id')
      subject.set_attributes(object, attributes)
    end

    it 'updates the object with the attributes provided' do
      object.should_receive(:update_attributes).
        with('attribute' => 'some_value')
      subject.set_attributes(object, attributes)
    end

    it 'sets the object version' do
      object.should_receive(:update_attribute).
        with(:remote_version, 'some_version')
      subject.set_attributes(object, attributes)
    end

    it 'sets the object created_at' do
      object.should_receive(:update_attribute).
        with(:created_at, 'created_at')
      subject.set_attributes(object, attributes)
    end

    it 'sets the object updated_at' do
      object.should_receive(:update_attribute).
        with(:updated_at, 'updated_at')
      subject.set_attributes(object, attributes)
    end

    it 'preserves the updated_at attribute when given' do
      object = Post.new
      time = Time.zone.local(2012,4,12,14,30,32)
      attributes = {'id' => 'some_id',
                    'attributes' => {'created_at' => Time.zone.now},
                    'version' => 'some_version',
                    'created_at' => Time.zone.now,
                    'updated_at' => time.as_json}
      subject.set_attributes(object, attributes)
      object.updated_at.should eq(time)
    end
  end

  describe '#handle_updates' do
    let(:update)  { mock }
    let(:model)   { TestModel }
    let(:object)  { mock }
    let(:results) { {'unicast' =>   {'meta' => {}},
                     'multicast' => {'meta' => {}}} }
    before do
      subject.stub(:check_version => [true, object],
                   :process_update => nil)
    end

    it 'handles each update in a single transaction' do
      TestModel.should_receive(:transaction).once
      subject.should_not_receive(:check_version)
      subject.should_not_receive(:process_update)
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'checks the version of each update' do
      subject.should_receive(:check_version).
        with(model, update, 'client_id', results)
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'issues an update when the version check is successful' do
      subject.should_receive(:process_update).
        with(model, object, update)
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'issues no update when the version check is unsuccessful' do
      subject.stub(:check_version => [false, object])
      subject.should_not_receive(:process_update)
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'returns the compacted output of the process_update method calls' do
      subject.stub(:process_update).and_return(nil, update_id = mock)
      update_ids = subject.handle_updates(model, [update, update], 'client_id', results)
      update_ids.should eq([update_id])
    end
  end

  describe '#process_update' do
    let(:update) { {'id' => 'some_id',
                    'attributes' => {'attribute' => 'some_value'},
                    'version' => 'some_version',
                    'created_at' => 'created_at',
                    'updated_at' => 'updated_at'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :remote_id => 'some_id',
           :valid? => true,
           :id => @id = mock)
    end
    let(:time)    { stub }
    let(:results) { {'meta' => {'timestamp' => time}} }
    before { subject.stub(:add_update_for => nil) }

    context 'when no object is passed in' do
      before do
        object.stub(:remote_id => nil)
        model.stub(:new => object)
      end

      it 'creates an object' do
        model.should_receive(:new).with()
        subject.process_update(model, nil, update)
      end
    end

    it 'does not create a new object when an object is passed in' do
      model.should_not_receive(:new)
      subject.process_update(model, object, update)
    end

    it 'sets the object attributes' do
      subject.should_receive(:set_attributes).with(object, update)
      subject.process_update(model, object, update)
    end

    it 'returns the object id' do
      subject.process_update(model, object, update).should eq(@id)
    end

    context 'when the object is not valid' do
      before { object.stub(:valid? => false) }

      it 'does not return the object id' do
        subject.process_update(model, object, update).should_not be
      end
    end
  end

  describe '#version_processed_objects' do
    let(:model) do
      TestModel.tap do |model|
        model.stub(:where => model)
        model.stub(:update_all => nil)
      end
    end
    let(:model_name) { "#{TestModel}" }
    let!(:processed) do
      {:create_ids => @create_ids = mock,
       :update_ids => @update_ids = mock}
    end
    let(:results) { {'meta' => {}} }
    before { LamportClock.stub(:tick => @clock = mock) }

    it 'wraps the versioning in a single transaction' do
      TestModel.should_receive(:transaction).once
      LamportClock.should_not_receive(:tick)
      model.should_not_receive(:update_all)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'increments the lamport clock for the model' do
      LamportClock.should_receive(:tick).with(model_name).once
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'does not increment the lamport clock when nothing is processed' do
      LamportClock.should_not_receive(:tick)
      subject.version_processed_objects(model, {}, model_name, results)
    end

    it 'queries the created objects' do
      model.should_receive(:where).with(:id => @create_ids)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'sets the last_update timestamp of all created objects' do
      model.stub(:where).with(:id => @create_ids)
           .and_return(query_result = mock(:update_all => nil))
      query_result.should_receive(:update_all).with(:last_update => @clock)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'does not query created objects when no creates are processed' do
      processed.delete :create_ids
      model.should_not_receive(:where).with(:id => @create_ids)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'queries the updated objects' do
      model.should_receive(:where).with(:id => @update_ids)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'sets the last_update timestamp of all updated objects' do
      model.stub(:where).with(:id => @update_ids)
           .and_return(query_result = mock(:update_all => nil))
      query_result.should_receive(:update_all).with(:last_update => @clock)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'does not query updated objects when no updates are processed' do
      processed.delete :update_ids
      model.should_not_receive(:where).with(:id => @update_ids)
      subject.version_processed_objects(model, processed, model_name, results)
    end

    it 'sets the updated lamport clock in the results' do
      subject.version_processed_objects(model, processed, model_name, results)
      results['meta']['timestamp'].should eq(@clock)
    end
  end

  describe '#add_processed_objects' do
    let(:model) do
      TestModel.tap do |model|
        model.stub(:where => [])
      end
    end
    let!(:processed) do
      {:create_ids => @create_ids = mock,
       :update_ids => @update_ids = mock}
    end
    let(:results) { {'meta' => {}} }

    it 'queries the created objects' do
      model.should_receive(:where).with(:id => @create_ids)
      subject.add_processed_objects(model, processed, results)
    end

    it 'adds each created object to the results' do
      model.stub(:where).with(:id => @create_ids).and_return([(object = mock)])
      subject.should_receive(:add_create_for).with(object, results)
      subject.add_processed_objects(model, processed, results)
    end

    it 'does not query created objects when no creates are processed' do
      processed.delete :create_ids
      model.should_not_receive(:where).with(:id => @create_ids)
      subject.add_processed_objects(model, processed, results)
    end

    it 'queries the updated objects' do
      model.should_receive(:where).with(:id => @update_ids)
      subject.add_processed_objects(model, processed, results)
    end

    it 'adds each created object to the results' do
      model.stub(:where).with(:id => @update_ids).and_return([(object = mock)])
      subject.should_receive(:add_update_for).with(object, results)
      subject.add_processed_objects(model, processed, results)
    end

    it 'does not query updated objects when no updates are processed' do
      processed.delete :update_ids
      model.should_not_receive(:where).with(:id => @update_ids)
      subject.add_processed_objects(model, processed, results)
    end
  end

  describe '#add_create_for' do
    let(:object) { stub(:remote_id => 'some_id') }
    let(:results) { {'create' => {}}}
    before { subject.stub(:json_for => 'some_json') }

    it 'adds a create for the object to the hash provided' do
      subject.add_create_for(object, results)
      results['create']['some_id'].should eq('some_json')
    end
  end

end