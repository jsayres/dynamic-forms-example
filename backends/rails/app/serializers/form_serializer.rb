class FormSerializer < ActiveModel::Serializer

  attributes :id, :number, :version, :name, :project, :slug, :username, :date, :published, :current, :locked
  has_many :fields
  has_many :responses

  def username
    object.user.username
  end

  def date
    object.updated_at
  end

end
