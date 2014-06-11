class CreateFormResponses < ActiveRecord::Migration
  def change
    create_table :form_responses do |t|
      t.integer :form_id
      t.integer :user_id

      t.timestamps
    end
  end
end
