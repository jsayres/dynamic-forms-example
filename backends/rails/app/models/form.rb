class Form < ActiveRecord::Base

  class Locked < StandardError; end

  default_scope { order(:number, :version) }

  def self.max_number
    maximum(:number) || 0
  end

  def self.max_version(number)
    where(number: number).maximum(:version) || 0
  end

  belongs_to :user
  has_many :fields, class_name: "FormField", dependent: :destroy, inverse_of: :form
  has_many :responses, class_name: "FormResponse", dependent: :destroy, inverse_of: :form

  validates :number, presence: true
  validates :version, presence: true,
    uniqueness: { scope: :number, message: "already exists for this form number" }
  validates :name, presence: true
  validates :project, presence: true, inclusion: { in: PROJECTS.keys }
  validates :user, presence: true

end
