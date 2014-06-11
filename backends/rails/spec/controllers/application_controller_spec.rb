require 'spec_helper'

describe ApplicationController do

  let(:user) { build(:user) }
  let(:auth) do
    auth = double()
    auth.stub(:current_user)
    auth.stub(:logged_in?)
    auth
  end
  before { AuthenticationService.stub(:new).and_return(auth) }

  describe "#current_user" do
    before { controller.current_user }
    specify { expect(auth).to have_received :current_user }
  end

  describe "#logged_in?" do
    before { controller.logged_in? }
    specify { expect(auth).to have_received :logged_in? }
  end

end
