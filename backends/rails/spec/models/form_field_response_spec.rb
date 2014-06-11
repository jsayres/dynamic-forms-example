require 'spec_helper'

describe FormFieldResponse do

  let(:field_response) { build(:form_field_response) }

  subject { field_response }

  it { should respond_to(:form_response) }
  it { should respond_to(:form_field) }
  it { should respond_to(:details) }

  it { should be_valid }

  describe "#form_response" do
    context "when nil" do
      before { field_response.form_response = nil }
      it { should_not be_valid }
    end
  end

  describe "#form_field" do
    context "when nil" do
      before { field_response.form_field = nil }
      it { should_not be_valid }
    end
  end

  describe "#details" do
    it "should be a Hash" do
      hash = { answer: "Here is my answer" }
      field_response.details = hash
      field_response.save
      expect(field_response.details).to eq hash
    end
  end


  describe "field details validations" do
    describe "info field" do
      it "should never be valid" do
        field_response.form_field = build(:info_field)
        expect(field_response).to_not be_valid
      end
    end

    describe "short-answer field" do
      context "when required" do
        before do
          details = {required: true}
          field_response.form_field = build(:short_answer_field, details: details)
        end

        it "should be valid when answer is not blank" do
          field_response.details[:answer] = 'an answer'
          expect(field_response).to be_valid
        end

        it "should be invalid if answer is blank" do
          field_response.details[:answer] = ''
          expect(field_response).to_not be_valid
        end
      end

      context "when not required" do
        it "should be valid even if blank" do
          details = {required: false}
          field_response.form_field = build(:short_answer_field, details: details)
          field_response.details[:answer] = ''
          expect(field_response).to be_valid
        end
      end
    end

    describe "long-answer field" do
      context "when required" do
        before do
          details = {required: true}
          field_response.form_field = build(:long_answer_field, details: details)
        end

        it "should be valid when answer is not blank" do
          field_response.details[:answer] = 'an answer'
          expect(field_response).to be_valid
        end

        it "should be invalid if answer is blank" do
          field_response.details[:answer] = ''
          expect(field_response).to_not be_valid
        end
      end

      context "when not required" do
        it "should be valid even if blank" do
          details = {required: false}
          field_response.form_field = build(:long_answer_field, details: details)
          field_response.details[:answer] = ''
          expect(field_response).to be_valid
        end
      end
    end

    describe "single-choice field" do
      context "when required" do
        before do
          details = {required: true, choices: [{label: 'A'}, {label: 'B'}]}
          field_response.form_field = build(:single_choice_field, details: details)
        end

        it "should be valid when answer is valid choice" do
          field_response.details[:answer] = 'A'
          expect(field_response).to be_valid
        end

        it "should be invalid if answer is not a valid choice" do
          field_response.details[:answer] = 'X'
          expect(field_response).to_not be_valid
        end

        it "should be invalid if answer is blank" do
          field_response.details[:answer] = ''
          expect(field_response).to_not be_valid
        end
      end

      context "when not required" do
        before do
          details = {required: false, choices: [{label: 'A'}, {label: 'B'}]}
          field_response.form_field = build(:single_choice_field, details: details)
        end

        it "should be invalid if answer is not a valid choice" do
          field_response.details[:answer] = 'X'
          expect(field_response).to_not be_valid
        end

        it "should be valid even if blank" do
          field_response.details[:answer] = ''
          expect(field_response).to be_valid
        end
      end
    end

    describe "multiple-choice field" do
      context "when required" do
        before do
          details = {required: true, choices: [{label: 'A'}, {label: 'B'}]}
          field_response.form_field = build(:multiple_choice_field, details: details)
        end

        it "should be valid when at least one choice is selected" do
          field_response.details[:answers] = [
            {label: 'A', selected: true}, {label: 'B', selected: false}
          ]
          expect(field_response).to be_valid
        end

        it "should set any left out answers to false" do
          field_response.details[:answers] = [{label: 'A', selected: true}]
          expect(field_response).to be_valid
          expect(field_response.details[:answers][1]).to eq(label: 'B', selected: false)
        end

        it "should be invalid if any answer is not a valid choice" do
          field_response.details[:answers] = [
            {label: 'A', selected: true}, {label: 'X', selected: false}
          ]
          expect(field_response).to_not be_valid
        end

        it "should be invalid if no choices are selected" do
          field_response.details[:answers] = [
            {label: 'A', selected: false}, {label: 'B', selected: false}
          ]
          expect(field_response).to_not be_valid
        end
      end

      context "when not required" do
        before do
          details = {required: false, choices: [{label: 'A'}, {label: 'B'}]}
          field_response.form_field = build(:multiple_choice_field, details: details)
        end

        it "should be invalid if any answer is not a valid choice" do
          field_response.details[:answers] = [
            {label: 'A', selected: true}, {label: 'X', selected: false}
          ]
          expect(field_response).to_not be_valid
        end

        it "should be valid if no choices are selected" do
          field_response.details[:answers] = [
            {label: 'A', selected: false}, {label: 'B', selected: false}
          ]
          expect(field_response).to be_valid
        end
      end
    end

    describe "address field" do
      context "when required" do
        before do
          details = {required: true}
          field_response.form_field = build(:address_field, details: details)
        end

        it "should be valid when addressLine1, city, state, and zip are provided" do
          field_response.details = {addressLine1: 'x', city: 'x', state: 'x', zip: 'x'}
          expect(field_response).to be_valid
        end

        it "should not be valid when any field other than addressLine2 is blank" do
          field_response.details = {addressLine1: '', city: 'x', state: 'x', zip: 'x'}
          expect(field_response).to_not be_valid
        end
      end

      context "when not required" do
        it "should be valid even if all fields are blank" do
          details = {required: false}
          field_response.form_field = build(:address_field, details: details)
          field_response.details = {}
          expect(field_response).to be_valid
        end
      end
    end
  end
end
