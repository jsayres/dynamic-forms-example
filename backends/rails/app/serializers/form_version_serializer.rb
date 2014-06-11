class FormVersionSerializer < ActiveModel::Serializer

  attributes :id, :number, :version, :name, :project, :slug, :username, :date, :published, :numResponses, :current, :locked
  has_many :fields

  def username
    object.user.username
  end

  def date
    object.updated_at
  end

  def numResponses
    object.respond_to?(:num_responses) && object.num_responses
  end

end
