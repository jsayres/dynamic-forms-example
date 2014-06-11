class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.integer :number
      t.integer :version
      t.string :name
      t.string :project
      t.string :slug
      t.integer :user_id
      t.boolean :published
      t.boolean :current
      t.boolean :locked

      t.timestamps
    end
  end
end
