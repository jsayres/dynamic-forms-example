require 'spec_helper'

describe FormResponse do
  
  let(:response) { build(:form_response) }

  subject { response }

  it { should respond_to(:form) }
  it { should respond_to(:user) }
  it { should respond_to(:field_responses) }

  it { should be_valid }

  describe "#form" do
    context "when nil" do
      before { response.form = nil }
      it { should_not be_valid }
    end
  end

  describe "#field_responses" do
    context "when response is destroyed" do
      before do
        response.form.save
        field = response.form.fields.create(kind: 'short-answer')
        response.save
        response.field_responses.create(form_field: field)
        response.destroy
      end

      it "should also destroy the response's field_responses" do
        expect(FormFieldResponse.count).to eq 0
      end
    end
  end
end
