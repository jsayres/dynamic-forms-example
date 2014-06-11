require 'spec_helper'

describe Api::FormsController do

  let(:auth) { AuthenticationService.new(cookies) }
  let(:user) { create(:user, active: true, staff: true) }

  describe "GET 'index'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :get, :index

    it "should provide a json list of current forms" do
      create(:form, current: true)
      auth.log_in(user)
      get :index
      json = JSON.parse(response.body)
      expect(json['forms'].length).to eq 1
      expect(json['forms'][0]['current']).to be true
    end
  end

  describe "POST 'create'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :post, :create

    it "should create a form and return a json response with number and version" do
      auth.log_in(user)
      post :create, form: attributes_for(:form, number: 2, version: 3)
      expect(JSON.parse(response.body)).to eq({"number" => 2, "version" => 1})
    end

    it "should return a 403 error if the form is not valid" do
      auth.log_in(user)
      post :create, form: attributes_for(:form, number: 2, version: 3, name: nil)
      expect(response.status).to eq 403
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "GET 'versions'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :get, :versions, {number: 1}

    it "should provide a json list of current versions for the specified form number" do
      create(:form, number: 1, version: 1)
      auth.log_in(user)
      get :versions, number: 1
      json = JSON.parse(response.body)
      expect(json['forms'].length).to eq 1
      expect(json['forms'][0]['version']).to eq 1
    end

    it "should return a 404 error if the form number doesn't exist" do
      auth.log_in(user)
      get :versions, number: 1
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "GET 'version'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :get, :version, {number: 1, version: 1}

    it "should provide the json encoded form version" do
      create(:form, number: 1, version: 2)
      auth.log_in(user)
      get :version, number: 1, version: 2
      json = JSON.parse(response.body)
      expect(json['form']['number']).to eq 1
      expect(json['form']['version']).to eq 2
    end

    it "should return a 404 error if the form doesn't exist" do
      auth.log_in(user)
      get :version, number: 1, version: 2
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "PUT 'update'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :put, :update, {number: 1, version: 1}

    it "should return a 403 error if the form is locked" do
      create(:form, number: 1, version: 2, name: 'old name', locked: true)
      auth.log_in(user)
      get :update, number: 1, version: 2, form: {name: 'new name'}
      expect(response.status).to eq 403
      expect(JSON.parse(response.body).keys).to include('error')
    end

    it "should update the form and return the modified date" do
      create(:form, number: 1, version: 2, name: 'old name')
      auth.log_in(user)
      get :update, number: 1, version: 2, form: {name: 'new name'}
      expect(JSON.parse(response.body).keys).to eq ['date']
    end

    it "should set the current user to the user of the updated form" do
      create(:form, number: 1, version: 2, name: 'old name')
      auth.log_in(user)
      get :update, number: 1, version: 2, form: {name: 'new name'}
      expect(Form.find_by(number: 1, version: 2).user).to eq user
    end

    it "should return a 404 error if the form doesn't exist" do
      auth.log_in(user)
      get :update, number: 1, version: 2, form: {}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "POST 'publish'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :post, :publish, {number: 1, version: 1}

    it "should publish the form and return the published status" do
      create(:form, number: 1, version: 2)
      auth.log_in(user)
      post :publish, number: 1, version: 2
      expect(JSON.parse(response.body)['published']).to be true
    end

    it "should return a 404 error if the form doesn't exist" do
      auth.log_in(user)
      post :publish, number: 1, version: 2
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "POST 'unpublish'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :post, :unpublish, {number: 1, version: 1}

    it "should unpublish the form and return the published status" do
      create(:form, number: 1, version: 2, published: true)
      auth.log_in(user)
      post :unpublish, number: 1, version: 2
      expect(JSON.parse(response.body)['published']).to be false
    end

    it "should return a 404 error if the form doesn't exist" do
      auth.log_in(user)
      post :unpublish, number: 1, version: 2
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

  describe "GET 'responses'" do
    it_behaves_like "requires an active, logged-in staff or admin user", :get, :responses, {number: 1, version: 1}

    context "when the form exists" do
      before do
        f = create(:form, number: 1, version: 2)
        fld = f.fields.create(attributes_for(:short_answer_field))
        r = f.responses.create
        r.field_responses.create(attributes_for(:short_answer_response))
      end

      it "should provide a json encoded form with the responses" do
        auth.log_in(user)
        get :responses, number: 1, version: 2
        json = JSON.parse(response.body)
        expect(json['form']['responses'].length).to eq 1
      end

      it "should provide a csv table when the format is csv" do
        auth.log_in(user)
        get :responses, format: :csv, number: 1, version: 2
        expect(CSV.parse(response.body).length).to eq 2
      end
    end

    it "should return a 404 error if the form doesn't exist" do
      auth.log_in(user)
      post :responses, number: 1, version: 2
      expect(response.status).to eq 404
      expect(JSON.parse(response.body).keys).to include('error')
    end
  end

end
