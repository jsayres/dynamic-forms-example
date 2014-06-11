class FormResponsesController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :render_404_page
  rescue_from ActiveRecord::RecordInvalid, with: :render_form

  before_action :get_published_form, except: :project_forms

  def new
    FormsService.build_response(@form, {})
    render_form
  end

  def create
    FormsService.create_response(@form, params.permit![:responses], auth.current_user)
    flash[:done] = true
    redirect_to form_response_created_path(@form.project, @form.slug)
  end

  def done
    if flash[:done]
      render layout: project_info[:layout]
    else
      redirect_to project_info[:root]
    end
  end

  def project_forms
    if project_info.nil?
      render_404_page
    else
      @forms = FormsService.published_forms(params[:project])
      render :project_forms, layout: project_info[:layout]
    end
  end

  private

  def get_published_form
    @form = FormsService.published_form(params[:project], params[:slug])
  end

  def project_info
    PROJECTS[params[:project]]
  end

  def render_form
    form_response = @form.responses.proxy_association.target[0]
    @field_responses = field_responses_hash(form_response)
    render :new, layout: project_info[:layout]
  end

  def field_responses_hash(form_response)
    Hash[form_response.field_responses.map { |fr| [fr.form_field.id, fr] }]
  end

end
