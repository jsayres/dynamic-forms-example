class FormResponse < ActiveRecord::Base

  belongs_to :form, inverse_of: :responses
  belongs_to :user
  has_many :field_responses,
    class_name: "FormFieldResponse",
    dependent: :destroy,
    inverse_of: :form_response

  validates :form, presence: true

end
