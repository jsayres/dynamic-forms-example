require 'spec_helper'

describe Form do

  let(:form) { build(:form, number: 1, version: 1) }

  subject { form }

  it { should respond_to(:number) }
  it { should respond_to(:version) }
  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:project) }
  it { should respond_to(:slug) }
  it { should respond_to(:user) }
  it { should respond_to(:published) }
  it { should respond_to(:current) }
  it { should respond_to(:locked) }
  it { should respond_to(:fields) }
  it { should respond_to(:responses) }

  it { should be_valid }

  describe "default scope" do
    it "should be ordered by number, then version" do
      create(:form, number: 3, version: 1)
      create(:form, number: 2, version: 2)
      create(:form, number: 1, version: 1)
      create(:form, number: 2, version: 1)
      forms_info = Form.all.pluck(:number, :version)
      expect(forms_info).to eq [[1, 1], [2, 1], [2, 2], [3, 1]]
    end
  end

  describe "#number" do
    it "should not be valid when nil" do
      form.number = nil
      expect(form).not_to be_valid
    end
  end

  describe "#version" do
    it "should not be vaild when nil" do
      form.version = nil
      expect(form).not_to be_valid
    end
  end

  describe "#number and #version combo" do
    context "on create, when a form with same combo already exists" do
      it "should not be valid" do
        create(:form, number: 2, version: 3)
        form.number = 2
        form.version = 3
        expect(form.save).to be false
        expect(form).not_to be_valid
      end
    end
  end

  describe "#name" do
    it "should not be valid when nil" do
      form.name = nil
      expect(form).not_to be_valid
    end
  end

  describe "#description" do
    it "should be valid when nil" do
      form.description = nil
      expect(form).to be_valid
    end
  end

  describe "#project" do
    it "should not be valid when nil" do
      form.project = nil
      expect(form).not_to be_valid
    end

    it "should not be valid if not in PROJECTS list" do
      form.project = 'no-good-project'
      expect(form).not_to be_valid
    end
  end

  describe "#user" do
    it "should not be valid when nil" do
      form.user = nil
      expect(form).not_to be_valid
    end
  end

  describe "#fields" do
    it "should be destroyed when form is destroyed" do
      form.save
      form.fields.create(kind: 'info')
      form.destroy
      expect(FormField.count).to eq 0
    end
  end

  describe "#responses" do
    it "should be destroyed when form is destroyed" do
      form.save
      form.responses.create()
      form.destroy
      expect(FormResponse.count).to eq 0
    end
  end

  describe ".max_number" do
    it "should return the max form number" do
      form.number = 3
      form.save
      expect(Form.max_number).to eq 3
    end

    it "should return zero if no forms" do
      expect(Form.max_number).to eq 0 
    end
  end

  describe ".max_version" do
    it "should return the max form version for the specified number" do
      form.number = 3
      form.version = 5
      form.save
      expect(Form.max_version(3)).to eq 5
    end

    it "should return zero if there are no forms with the specified number" do
      expect(Form.max_version(3)).to eq 0 
    end
  end

end
