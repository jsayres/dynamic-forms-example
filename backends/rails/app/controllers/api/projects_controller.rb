class Api::ProjectsController < ApplicationController

  def index
    projects = {}
    PROJECTS.each { |k, v| projects[k] = v[:name] }
    render json: {projects: projects}
  end

end
