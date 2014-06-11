require 'spec_helper'

describe StaticPagesController do

  describe "GET 'main'" do
    before { get :main }

    its(:response) { should be_success }
  end

  describe "GET 'subproject'" do
    before { get :subproject }

    its(:response) { should be_success }
  end

  describe "GET 'admin'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :get, :admin
  end

end
