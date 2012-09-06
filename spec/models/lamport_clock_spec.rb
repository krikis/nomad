require 'spec_helper'

describe LamportClock do

  describe '.tick_sync_session' do
    it 'creates a new clock with the given key when it does not exist' do
      LamportClock.tick 'sync_session'
      LamportClock.find_by_key('sync_session').should be
    end

    it 'finds a clock with the given key when it does exist' do
      clock = LamportClock.create :key => 'sync_session'
      LamportClock.tick 'sync_session'
      LamportClock.count.should eq(1)
    end

    it 'initializes the lamport clock to 1 when it is undefined' do
      clock = LamportClock.create :key => 'sync_session'
      LamportClock.tick 'sync_session'
      LamportClock.find_by_key('sync_session').clock.should eq(1)
    end

    it 'increments the lamport clock with the given key' do
      clock = LamportClock.create :key => 'sync_session', :clock => 3
      LamportClock.tick 'sync_session'
      LamportClock.find_by_key('sync_session').clock.should eq(4)
    end
  end

end
