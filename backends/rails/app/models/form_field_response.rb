class FormFieldResponse < ActiveRecord::Base

  belongs_to :form_response, inverse_of: :field_responses
  belongs_to :form_field

  validates :form_response, presence: true
  validates :form_field, presence: true
  validate :validate_response_details

  serialize :details, Hash

  private

  def validate_response_details
    unless form_field.nil?
      send("validate_#{form_field.kind.underscore}_response".to_sym)
    end
  end

  def validate_info_response
    errors.add(:info_field, "cannot have a response")
  end

  def validate_short_answer_response
    check_if_response_required_and_blank
  end

  def validate_long_answer_response
    check_if_response_required_and_blank
  end

  def validate_single_choice_response
    check_if_response_required_and_blank
    answer = details.fetch(:answer, "")
    ok_choices = form_field.details.fetch(:choices, []).map { |c| c[:label] }
    if !answer.empty? && !ok_choices.include?(answer)
      errors.add(:answer, "must be a valid choice")
    end
  end

  def validate_multiple_choice_response
    answers = clean_multiple_choice_answers!
    ok_choices = form_field.details.fetch(:choices, []).map { |c| c[:label] }
    submitted_choices = answers.map { |a| a[:label] }
    selected_choices = answers.select { |a| a[:selected] }.map { |a| a[:label] }
    if form_field.details[:required] && selected_choices.empty?
      errors.add(:answer, "required")
    end
    if submitted_choices.select { |c| !ok_choices.include?(c) }.any?
      errors.add(:answer, "must be a valid choice")
    end
  end

  def clean_multiple_choice_answers!
    answers = details.fetch(:answers, []).each_with_object({}) do |a, obj|
      obj[a[:label]] = ['1', 'true', true].include?(a[:selected])
    end
    choices = form_field.details.fetch(:choices, []).each_with_object({}) do |c, obj|
      obj[c[:label]] = false
    end
    details[:answers] = choices.merge(answers).map { |k, v| {label: k, selected: v} }
  end

  def validate_address_response
    if form_field.details[:required]
      [:addressLine1, :city, :state, :zip].each do |field|
        errors.add(field, "required") if details.fetch(field, "").empty?
      end
    end
  end

  def check_if_response_required_and_blank
    if form_field.details[:required]
      answer = details.fetch(:answer, "")
      errors.add(:answer, "required") if answer.empty?
    end
  end

end
