require 'spec_helper'

class MockCookies < Hash
  def [](key)
    val = super(key)
    val && val[:value]
  end
end

describe AuthenticationService do
  let(:user) { create(:user) }
  let(:cookies) { MockCookies.new }

  subject { AuthenticationService.new(cookies) }

  describe "#authenticate" do
    context "with a valid username/password combo" do
      it "should return the user" do
        expect(subject.authenticate(user.username, user.password)).to eq user
      end
    end

    context "with an invalid username/password combo" do
      it "should return false" do
        expect(subject.authenticate('badusername', 'badpassword')).to be false
      end
    end
  end

  describe "#log_in" do
    it "should create a session and set a session_key in cookies" do
      expect { subject.log_in(user) }.to change { Session.count }.by(1)
      expect(cookies[:session_key]).to_not be_nil
    end
  end

  describe "#authenticate_and_log_in" do
    context "with a valid username/password combo" do
      it "should log in and return the user" do
        u = subject.authenticate_and_log_in(user.username, user.password)
        expect(cookies[:session_key]).to_not be_nil
        expect(u).to eq user
      end
    end

    context "with an invalid username/password combo" do
      it "should return false" do
        u = subject.authenticate_and_log_in('badusername', 'badpassword')
        expect(u).to be false
      end
    end
  end

  describe "#log_out" do
    it "should clear the session_key in cookies" do
      cookies[:session_key] = 'abc123'
      subject.log_out
      expect(cookies[:session_key]).to be_nil
    end
  end

  describe "#current_user" do
    context "when a user has been logged in" do
      it "should return the user" do
        subject.log_in(user)
        expect(subject.current_user).to eq user
      end
    end

    context "when no user has been logged in" do
      it "should return nil" do
        expect(subject.current_user).to be_nil
      end
    end
  end

  describe "#logged_in?" do
    context "when a user has been logged in" do
      it "should be true" do
        subject.log_in(user)
        expect(subject.logged_in?).to be true
      end
    end

    context "when no user has been logged in" do
      it "should be false" do
        expect(subject.logged_in?).to be false
      end
    end
  end
end
