class FormField < ActiveRecord::Base

  KINDS = [
    'info',
    'address',
    'short-answer',
    'long-answer',
    'single-choice',
    'multiple-choice'
  ]

  belongs_to :form, inverse_of: :fields

  validates :form, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }

  serialize :details, Hash
           
end
