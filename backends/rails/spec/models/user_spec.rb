require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  subject { user }

  it { should respond_to(:username) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:admin) }
  it { should respond_to(:staff) }
  it { should respond_to(:active) }

  it { should be_valid }

  describe "#username" do
    context "when nil" do
      before { user.username = nil }

      it { should_not be_valid }
    end

    context "when empty" do
      before { user.username = '' }

      it { should_not be_valid }
    end

    context "when too long" do
      before { user.username = 'a' * 31 }

      it { should_not be_valid }
    end

    context "when too short" do
      before { user.username = 'a' * 4 }

      it { should_not be_valid }
    end

    context "when a duplicate is built" do
      let!(:user2) { create(:user, username: user.username) }

      it { should_not be_valid }
    end

    context "when has characters other than alphanumeric or '_-.'" do
      before { user.username = '@ b@d us+r n*me!' }

      it { should_not be_valid }
    end

    context "when only has characters that are alphanumeric or '_-.'" do
      before { user.username = 'A-good_user.name' }

      it { should be_valid }
    end
  end

  describe "#email" do
    context "when nil" do
      before { user.email = nil }

      it { should_not be_valid }
    end

    context "when empty" do
      before { user.email = '' }

      it { should_not be_valid }
    end

    context "when too long" do
      before { user.email = 'a' * 51 }

      it { should_not be_valid }
    end

    context "when too short" do
      before { user.email = 'a' * 7 }

      it { should_not be_valid }
    end

    context "when a duplicate is built" do
      let!(:user2) { create(:user, email: user.email) }

      it { should_not be_valid }
    end

    context "when one with different caps is built" do
      let!(:user2) { create(:user, email: user.email) }
      before { user.email.upcase! }

      it { should_not be_valid }
    end

    context "when the format is invalid" do
      it "should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org exapmle.user@foo.
                       foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        addresses.each do |address|
          user.email = address
          expect(user).not_to be_valid
        end
      end
    end

    context "when the format is valid" do
      it "should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |address|
          user.email = address
          expect(user).to be_valid
        end
      end
    end

    context "when mixed case" do
      it "should be saved as lower case" do
        user.email = 'AmIxEdCaSe@NoNe.CoM'
        user.save
        expect(user.reload.email).to eq 'amixedcase@none.com'
      end
    end
  end

  describe "#password" do
    context "when not supplied" do

      context "on create" do
        let(:user) { build(:user, password: '') }

        it { should_not be_valid }
      end

      context "on update" do
        let(:user) { create(:user) }
        before { user.update_attributes(password: '') }

        it { should be_valid }
      end
    end

    context "when password does not match confirmation" do
      before { user.password_confirmation = 'wrong_pass' }

      it { should_not be_valid }
    end

    context "when password is too short" do
      before { user.password = user.password_confirmation = 'a' * 9 }

      it { should_not be_valid }
    end
  end

  describe "#authenticate" do
    before { user.save }
    let(:found_user) { User.find(user.id) }

    it "should return the user when password is valid" do
      expect(found_user.authenticate(user.password)).to eq user
    end

    it "should return false when password is invalid" do
      expect(found_user.authenticate('bad_password')).to be_false
    end
  end

  describe "#admin" do
    context "when nil" do
      before { user.admin = nil }

      it { should_not be_valid }
    end
  end

  describe "#staff" do
    context "when nil" do
      before { user.staff = nil }

      it { should_not be_valid }
    end
  end

  describe "#active" do
    context "when nil" do
      before { user.active = nil }

      it { should_not be_valid }
    end
  end
end
