class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.boolean :admin
      t.boolean :staff
      t.boolean :active

      t.timestamps
    end
  end
end
