require_relative 'faye_helper'
require 'sync'

class TestModel
  def self.find_by_remote_id
  end
end

class KlassWithFayeSync
  include Faye::Sync
end

describe Faye::Sync do
  subject { KlassWithFayeSync.new }

  describe '#process_message' do
    let(:model)   { TestModel }
    before do
      @results = stub
      subject.stub(:init_results => @results,
                   :publish_results => nil)
    end

    it 'initializes the results hash' do
      subject.should_receive(:init_results)
      subject.process_message(model, {})
    end

    it 'handles new versions if present' do
      message = {'new_versions' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_new_versions).
        with(model, message['new_versions'], @results)
      subject.process_message(model, message)
    end

    it 'handles versions if present' do
      message = {'versions' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_versions).
        with(model, message['versions'], 'some_id', @results)
      subject.process_message(model, message)
    end

    it 'handles creates if present' do
      message = {'creates' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_creates).
        with(model, message['creates'], @results)
      subject.process_message(model, message)
    end

    it 'handles updates if present' do
      message = {'updates' => stub, 'client_id' => 'some_id'}
      subject.should_receive(:handle_updates).
        with(model, message['updates'], 'some_id', @results)
      subject.process_message(model, message)
    end

    it 'handles destroys if present' do

    end

    it 'returns the results' do
      subject.process_message(model, {}).should eq(@results)
    end
  end

  describe '#initresults' do
    before do
      @time = stub
      Time.stub(:now => @time)
    end

    it 'initializes the unicast message' do
      subject.init_results['unicast'].should be
    end

    it 'initializes the unicast meta tag' do
      subject.init_results['unicast']['meta'].
        should eq({'timestamp' => @time})
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
      subject.init_results['multicast']['meta'].
        should eq({'timestamp' => @time})
    end

    it 'initializes the create list' do
      subject.init_results['multicast']['create'].should eq({})
    end

    it 'initializes the update list' do
      subject.init_results['multicast']['update'].should eq({})
    end
  end

  describe '#handle_new_versions' do
    let(:new_version) { stub }
    let(:model)       { TestModel }
    let(:results)     { {'unicast' => {'meta' => {}}} }
    before { subject.stub(:check_new_version) }

    it 'checks the version of each entry' do
      subject.should_receive(:check_new_version).
        with(model, new_version, an_instance_of(Hash))
      subject.handle_new_versions(model, [new_version], results)
    end

    it 'flags the unicast results as preSync results' do
      subject.handle_new_versions(model, [new_version], results)
      results['unicast']['meta']['preSync'].should be_true
    end

    it 'files all id conflicts for unicast' do
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
    let(:model)       { TestModel }
    let(:results)     { {'resolve' => []} }
    before do
      TestModel.stub(:find_by_remote_id)
      subject.stub(:json_for => 'some_json')
    end

    it 'tries to find an updated version' do
      model.should_receive(:find_by_remote_id).with('some_id')
      subject.check_new_version(model, new_version, results)
    end

    it 'returns true if no object is found' do
      subject.check_new_version(model, new_version, results).should be_true
    end

    context 'when an object is found' do
      let(:object) { stub }
      before { TestModel.stub(:find_by_remote_id).and_return(object) }

      it 'files the version for conflict resolution' do
        subject.check_new_version(model, new_version, results)
        results['resolve'].should eq(['some_id'])
        results['update'].should be_blank
      end

      it 'returns false' do
        subject.check_new_version(model, new_version, results).should be_false
      end
    end
  end

  describe '#handle_versions' do
    let(:version) { stub }
    let(:model)   { TestModel }
    let(:results) { {'unicast' => {'meta' => {}}} }
    before { subject.stub(:check_version) }

    it 'checks the version of each entry' do
      subject.should_receive(:check_version).
        with(model, version, 'client_id', an_instance_of(Hash))
      subject.handle_versions(model, [version], 'client_id', results)
    end

    it 'flags the unicast results as preSync results' do
      subject.handle_versions(model, [version], 'client_id', results)
      results['unicast']['meta']['preSync'].should be_true
    end

    it 'files all update conflicts for unicast' do
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
    let(:results) { {'update' => {}}}
    before { subject.stub(:json_for => 'some_json') }

    it 'adds an update for the object to the hash provided' do
      subject.add_update_for(object, results)
      results['update']['some_id'].should eq('some_json')
    end
  end

  describe '#handle_creates' do
    let(:create)  { stub }
    let(:model)   { TestModel }
    let(:results) { {'unicast' =>   {'meta' => {}},
                     'multicast' => {'meta' => {}}} }
    before do
      subject.stub(:check_new_version => true,
                   :process_create => nil)
    end

    it 'checks the version of each create' do
      subject.should_receive(:check_new_version).
        with(model, create, an_instance_of(Hash))
      subject.handle_creates(model, [create], results)
    end

    it 'files all id conflicts for unicast' do
      subject.stub(:check_new_version) do |_, _, unicast|
        unicast['id'] = 'conflict'
      end
      subject.handle_creates(model, [create], results)
      results['unicast']['id'].should eq('conflict')
    end

    it 'issues a create when the version check is successful' do
      subject.should_receive(:process_create).
        with(model, create, an_instance_of(Hash))
      subject.handle_creates(model, [create], results)
    end

    it 'issues no create when the version check is unsuccessful' do
      subject.stub(:check_new_version => false)
      subject.should_not_receive(:process_create)
      subject.handle_creates(model, [create], results)
    end

    it 'files all successful creates for multicast' do
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
                    'version' => 'some_version',
                    'created_at' => 'created_at',
                    'updated_at' => 'updated_at'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :valid? => true)
    end
    let(:time)    { stub }
    let(:results) { {'meta' => {'timestamp' => time}} }
    before do
      model.stub(:new => object)
      subject.stub(:set_attributes => nil,
                   :add_create_for => nil)
    end

    it 'creates a new object' do
      model.should_receive(:new).with()
      subject.process_create(model, create, results)
    end

    it 'sets the object attributes' do
      subject.should_receive(:set_attributes).with(object, create, time)
      subject.process_create(model, create, results)
    end

    it 'adds a create for the object when it was successfully created' do
      subject.should_receive(:add_create_for).with(object, results)
      subject.process_create(model, create, results)
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

    it 'sets the object last update time if provided' do
      time = stub
      object.should_receive(:update_attribute).
        with(:last_update, time)
      subject.set_attributes(object, attributes, time)
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
      time = DateTime.new(2012,4,12,14,30,32)
      attributes = {'id' => 'some_id',
                    'attributes' => {'created_at' => Time.now},
                    'version' => 'some_version',
                    'created_at' => Time.now,
                    'updated_at' => time.as_json}
      subject.set_attributes(object, attributes)
      object.updated_at.should eq(time)
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

  describe '#handle_updates' do
    let(:update)  { stub }
    let(:model)   { TestModel }
    let(:object)  { stub }
    let(:results) { {'unicast' =>   {'meta' => {}},
                     'multicast' => {'meta' => {}}} }
    before do
      subject.stub(:check_version => [true, object],
                   :process_update => nil)
    end

    it 'checks the version of each update' do
      subject.should_receive(:check_version).
        with(model, update, 'client_id', an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'files all update conflicts for unicast' do
      subject.stub(:check_version) do |_, _, _, unicast|
        unicast['update'] = 'conflict'
      end
      subject.handle_updates(model, [update], 'client_id', results)
      results['unicast']['update'].should eq('conflict')
    end

    it 'issues an update when the version check is successful' do
      subject.should_receive(:process_update).
        with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'issues no update when the version check is unsuccessful' do
      subject.stub(:check_version => [false, object])
      subject.should_not_receive(:process_update).
        with(model, object, update, an_instance_of(Hash))
      subject.handle_updates(model, [update], 'client_id', results)
    end

    it 'files all successful updates for multicast' do
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
                    'version' => 'some_version',
                    'created_at' => 'created_at',
                    'updated_at' => 'updated_at'} }
    let(:model)  { TestModel }
    let(:object) do
      stub(:update_attributes => nil,
           :update_attribute => nil,
           :remote_id => 'some_id',
           :valid? => true)
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
        subject.process_update(model, nil, update, results)
      end
    end

    context 'when an object is passed in' do
      it 'does not create a new object' do
        model.should_not_receive(:new)
        subject.process_update(model, object, update, results)
      end
    end

    it 'sets the object attributes' do
      subject.should_receive(:set_attributes).with(object, update, time)
      subject.process_update(model, object, update, results)
    end

    it 'adds an update for the object when it successfully updated' do
      subject.should_receive(:add_update_for).with(object, results)
      subject.process_update(model, object, update, results)
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

end