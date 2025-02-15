class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false, foreign_key: true, index: true
      t.string :description, null: false
      t.integer :accept, null: false
      t.boolean :test_user, null: false

      t.timestamps
    end

    add_check_constraint :posts, 'accept IN (0, 1)', name: 'accept_boolean_check'
  end
end
