class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.string :remote_id
      t.string :remote_version

      t.timestamps
    end
  end
end
