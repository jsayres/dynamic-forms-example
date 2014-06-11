class FormResponseSerializer < ActiveModel::Serializer

  attributes :id, :form_id, :username, :date
  has_many :field_responses, key: :fieldResponses

  def username
    object.user ? object.user.username : ''
  end

  def date
    object.updated_at
  end

end
