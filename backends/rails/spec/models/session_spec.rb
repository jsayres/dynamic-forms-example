require 'spec_helper'

describe Session do
  let(:session) { build(:session) }

  subject { session }

  it { should respond_to(:user) }
  it { should respond_to(:key) }
  it { should respond_to(:expires) }

  it { should be_valid }

  describe "#user" do
    before { session.user = nil }

    it { should_not be_valid }
  end

  describe "#key" do
    it "should be set on for new instance" do
      expect(session.key).not_to be_blank
    end

    it "should not be changed when loaded from db" do
      session.save
      expect(Session.last.key).to eq session.key
    end

    context "when set to nil" do
      before { session.key = nil }

      it { should_not be_valid }
    end
  end

  describe "#expires" do
    its(:expires) { should be_blank }

    context "after saving" do
      before { session.save }

      its(:expires) { should_not be_blank }
      its(:expires) { should be > DateTime.current }
    end
  end
end
