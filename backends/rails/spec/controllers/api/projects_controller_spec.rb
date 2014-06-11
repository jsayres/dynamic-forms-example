require 'spec_helper'

describe Api::ProjectsController do

  describe "GET 'index'" do
    it "should return a json list of project keys" do
      get :index
      json = JSON.parse(response.body)
      expect(json["projects"].keys).to eq PROJECTS.keys
      expect(json["projects"].values).to eq PROJECTS.map { |k, v| v[:name] }
    end
  end

end

