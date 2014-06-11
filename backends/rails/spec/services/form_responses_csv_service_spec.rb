require 'spec_helper'

describe FormResponsesCsvService do

  describe "::create_csv" do
    it "should genereate a csv object from the form data" do
      form = build(:form, number: 1, version: 1, name: 'Form 1')
      form.fields = [:info_field, :short_answer_field, :long_answer_field,
                     :single_choice_field, :multiple_choice_field,
                     :address_field].map { |f| build(f) }
      form.responses = (1..3).map do |row|
        field_responses = [:short_answer_response, :long_answer_response,
                           :single_choice_response, :multiple_choice_response,
                           :address_response].map { |fr| build(fr) }
        build(:form_response, field_responses: field_responses)
      end

      csv = subject.create_csv(form)

      rows = CSV.parse(csv)
      expect(rows.length).to eq 4
      rows.each { |row| expect(row.length).to eq 7 }
    end
  end

end
