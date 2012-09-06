class CreateLamportClocks < ActiveRecord::Migration
  def change
    create_table :lamport_clocks do |t|
      t.string  :key
      t.integer :clock
      t.timestamps
    end
  end
end
