class CurrentFormSerializer < ActiveModel::Serializer

  attributes :id, :number, :version, :name, :project, :slug, :username, :date, :published, :prevPublished, :numResponses, :current, :locked

  def username
    object.user.username
  end

  def date
    object.updated_at
  end

  def prevPublished
    object.respond_to?(:prev_published) && object.prev_published
  end

  def numResponses
    object.respond_to?(:num_responses) && object.num_responses
  end

end
