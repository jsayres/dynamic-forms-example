require 'spec_helper'

describe SessionsController do

  let(:user) { create(:user) }
  let(:auth) { AuthenticationService.new(cookies) }

  describe "GET 'new'" do
    it "should render the login form" do
      get :new
      expect(response).to be_success
      expect(response).to render_template(:new)
    end
  end

  describe "POST 'create'" do
    context "when successful" do
      it "should log the user in and redirect to root if no 'next' param is supplied" do
        post :create, username: user.username, password: user.password
        expect(auth.logged_in?).to be_true
        expect(response).to redirect_to root_path
      end

      it "should log the user in and redirect to the 'next' url if suppied" do
        post :create, username: user.username, password: user.password, next: '/other'
        expect(auth.logged_in?).to be_true
        expect(response).to redirect_to '/other'
      end
    end

    context "when unsuccessful" do
      it "should show login page again set the flash with a failure message" do
        post :create, username: user.username, password: 'bad_password'
        expect(auth.logged_in?).to be_false
        expect(flash[:alert]).not_to be_nil
        expect(response).to render_template(:new)
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "should log out the user and redirect to root" do
      auth.log_in(user)
      delete :destroy
      expect(auth.logged_in?).to be_false
      expect(response).to redirect_to root_path
    end
  end

end
