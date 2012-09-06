class ChangeModelSchema < ActiveRecord::Migration
  def up
    change_column :posts, :last_update, :integer
  end

  def down
    change_column :posts, :last_update, :datetime
  end
end
