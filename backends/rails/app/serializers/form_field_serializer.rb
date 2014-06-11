class FormFieldSerializer < ActiveModel::Serializer
  attributes :id, :form_id, :kind, :details
end
