class AddDescriptionToForm < ActiveRecord::Migration
  def change
    add_column :forms, :description, :text
  end
end
