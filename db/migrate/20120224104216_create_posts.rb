class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :content
      t.string :remote_id
      t.text :remote_version
      t.datetime :last_update

      t.timestamps
    end
  end
end
