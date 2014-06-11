require 'spec_helper'

describe FormResponsesController do

  let(:form) do
    create(:form, published: true) do |f|
      create(:short_answer_field, form: f, details: {required: true})
    end
  end

  describe "GET 'new'" do
    it "should render the form for the user to fill out" do
      get :new, project: form.project, slug: form.slug
      expect(response).to render_template(:new)
      expect(assigns(:form)).to eq form
    end

    it "should return a 404 error if the form doesn't exist" do
      get :new, project: 'abc', slug: '123'
      expect(response.status).to eq 404
      expect(response).to render_template('static_pages/404.html')
    end
  end

  describe "POST 'create'" do
    it "should create a new form response and redirect to the done page" do
      params = {
        project: form.project,
        slug: form.slug,
        responses: {form.fields[0].id.to_s => {answer: 'the answer'}}
      }
      expect { post :create, params }.to change { FormResponse.count }.by(1)
      expect(FormFieldResponse.last.details[:answer]).to eq 'the answer'
      expect(response).to redirect_to(form_response_created_path(form.project, form.slug))
    end

    it "should re-render the form with error messages if the repsonse is not valid" do
      post :create, project: form.project, slug: form.slug, responses: {}
      expect(response.status).to eq 200
      expect(response).to render_template(:new)
      errors = assigns(:field_responses)[form.fields[0].id].errors
      expect(errors.full_messages.length).to eq 1
    end
  end

  describe "GET 'done'" do
    it "should only be displayed if the flash is set" do
      get :done, {project: form.project, slug: form.slug}, nil, {done: true}
      expect(response).to render_template(:done)
    end

    it "should redirect to the project's root if the flash is not set" do
      get :done, project: form.project, slug: form.slug
      expect(response).to redirect_to(PROJECTS[form.project][:root])
    end

    it "should return a 404 error if the form doesn't exist" do
      get :done, project: 'abc', slug: '123'
      expect(response.status).to eq 404
      expect(response).to render_template('static_pages/404.html')
    end
  end

  describe "GET 'project_forms'" do
    it "should be render the proper template" do
      get :project_forms, project: PROJECTS.keys[0]
      expect(response).to render_template(:project_forms)
    end

    it "should return a 404 for a non-existent project" do
      get :project_forms, project: 'bad-project-no'
      expect(response.status).to eq 404
      expect(response).to render_template('static_pages/404.html')
    end
  end

end
