class CreateFormFieldResponses < ActiveRecord::Migration
  def change
    create_table :form_field_responses do |t|
      t.integer :form_response_id
      t.integer :form_field_id
      t.text :details
    end
  end
end
