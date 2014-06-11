require 'spec_helper'

describe FormField do
  
  let(:field) { build(:form_field) }

  subject { field }

  it { should respond_to(:form) }
  it { should respond_to(:kind) }
  it { should respond_to(:details) }

  it { should be_valid }

  describe "#form" do
    context "when nil" do
      before { field.form = nil }
      it { should_not be_valid }
    end
  end

  describe "#kind" do
    context "when nil" do
      before { field.kind = nil }
      it { should_not be_valid }
    end

    context "when not in KINDS" do
      before { field.kind = 'no-good-project' }
      it { should_not be_valid }
    end
  end

  describe "#details" do
    it "should be a Hash" do
      hash = { required: true, question: "What is the answer?" }
      field.details = hash
      field.save
      expect(field.details).to eq hash
    end
  end

end
