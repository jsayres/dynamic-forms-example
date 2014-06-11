require 'spec_helper'

describe "Authentication Pages" do

  subject { page }

  describe "logging in" do
    before { visit login_path }

    it "should have a proper title and inputs" do
      expect(page).to have_selector('h1', text: 'Log In')
      expect(page).to have_selector('input[name=username]')
      expect(page).to have_selector('input[name=password]')
    end

    context "when form is filled in and submitted" do

      context "with valid information" do
        let(:user) { create(:user) }
        before do
          fill_in "username", with: user.username
          fill_in "password", with: user.password
          click_button "Log In"
        end

        it "should log the user in and redirect to root path" do
          expect(current_path).to eq root_path
        end

        describe "logging out" do
          before do
            visit login_path
            click_link 'Log Out'
          end

          it "should log the user out and redirect to root path" do
            expect(current_path).to eq root_path
            visit login_path
            expect(page).to have_link('Log In')
          end
        end
      end

      context "with invalid information" do
        before { click_button "Log In" }

        it "should show login form again with failure feedback" do
          expect(page).to have_selector('.alert', text: "not correct")
          expect(page).to have_selector('h1', text: 'Log In')
          expect(page).to have_selector('input[name=username]')
          expect(page).to have_selector('input[name=password]')
        end
      end
    end
  end


end
