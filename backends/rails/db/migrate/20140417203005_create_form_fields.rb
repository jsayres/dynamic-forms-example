class CreateFormFields < ActiveRecord::Migration
  def change
    create_table :form_fields do |t|
      t.integer :form_id
      t.string :kind
      t.text :details
    end
  end
end
