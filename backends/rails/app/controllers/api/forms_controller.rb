class Api::FormsController < ApplicationController

  before_action :require_staff_or_admin

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid
  rescue_from Form::Locked, with: :locked

  def index
    render json: FormsService.current_forms, each_serializer: CurrentFormSerializer
  end

  def create
    attrs = params.permit![:form].merge(user: auth.current_user)
    form = FormsService.create(attrs)
    render json: {number: form.number, version: form.version}
  end

  def versions
    forms = FormsService.versions(params[:number])
    render json: forms, each_serializer: FormVersionSerializer
  end

  def version
    form = FormsService.version(params[:number], params[:version])
    render json: form, serializer: FormVersionSerializer, root: :form
  end

  def update
    number, version, form_attrs = params.permit!.values_at(:number, :version, :form)
    form_attrs[:user] = auth.current_user
    form = FormsService.update(number, version, form_attrs)
    render json: {date: form.updated_at}
  end

  def publish
    form = FormsService.publish(params[:number], params[:version])
    render json: {slug: form.slug, published: true}
  end

  def unpublish
    FormsService.unpublish(params[:number], params[:version])
    render json: {published: false}
  end

  def responses
    form = FormsService.form_with_responses(params[:number], params[:version])
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment; filename=responses.csv'
        send_data FormResponsesCsvService.create_csv(form)
      end
      format.any { render json: form }
    end
  end

  private

  def not_found(exception)
    render json: {error: exception.message}, status: 404
  end

  def invalid(exception)
    render json: {error: exception.message}, status: 403
  end

  def locked
    render json: {error: 'The form is locked.'}, status: 403
  end

end
