require_relative 'faye_helper'
require 'versioning'

class TestModel
  def self.find_by_remote_id
  end
end

class KlassWithFayeVersioning
  include Faye::Versioning
end

describe Faye::Versioning do
  subject { KlassWithFayeVersioning.new }

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

end