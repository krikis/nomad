class LamportClock < ActiveRecord::Base
  attr_accessible :key, :clock
  validates_uniqueness_of :key

  def self.tick(lamport_key)
    lamport = nil
    transaction do
      lamport = find_or_create_by_key lamport_key
      lamport.update_attributes :clock => (lamport.clock || 0) + 1
    end
    lamport.clock
  end

end
