module FormsService
  extend self

  def current_forms
    prev_published = Form.where(published: true, current: false).pluck(:number)
    select_str = prev_published.any? ? "number IN (#{prev_published.join(',')})" : "FALSE"
    Form
      .joins("LEFT OUTER JOIN form_responses ON forms.id = form_responses.form_id")
      .includes(:user, :fields)
      .select("forms.*, #{select_str} as prev_published, count(form_responses.*) as num_responses")
      .where(current: true)
      .group("forms.id")
  end

  def create(attrs)
    attrs[:number] ||= Form.max_number + 1
    attrs[:version] = Form.max_version(attrs[:number]) + 1
    attrs[:fields] = build_fields(attrs[:fields])
    Form.where(number: attrs[:number]).update_all(current: false)
    Form.create!(filter_create_form_attrs(attrs).merge(current: true))
  end

  def versions(number)
    forms = Form
      .joins("LEFT OUTER JOIN form_responses ON forms.id = form_responses.form_id")
      .includes(:user, :fields)
      .select("forms.*, count(form_responses.*) as num_responses")
      .where(number: number)
      .group("forms.id")
    raise ActiveRecord::RecordNotFound if forms.length == 0
    forms
  end

  def version(number, version)
    Form.includes(:user, :fields).find_by!(number: number, version: version)
  end

  def update(number, version, attrs)
    form = Form.find_by!(number: number, version: version)
    raise Form::Locked if form.locked
    form.fields.destroy_all
    attrs[:fields] = build_fields(attrs[:fields])
    form.update!(filter_update_form_attrs(attrs))
    form
  end

  def publish(number, version)
    Form.where(number: number).update_all(published: false)
    form = Form.find_by!(number: number, version: version)
    form.update!(slug: make_unique_slug(form), published: true, locked: true)
    form
  end

  def unpublish(number, version)
    form = Form.find_by!(number: number, version: version)
    form.update!(published: false, slug: '')
    form
  end

  def form_with_responses(number, version)
    Form
      .includes(:user, :fields, responses: [:user, :field_responses])
      .find_by!(number: number, version: version)
  end

  def published_form(project, slug)
    Form
      .includes(:user, :fields)
      .find_by!(published: true, project: project, slug: slug)
  end

  def published_forms(project)
    Form.includes(:user, :fields).where(published: true, project: project)
  end

  def build_response(form, details_attrs, user = nil)
    form_response = form.responses.build(user: user)
    non_info_fields(form.fields).each do |field|
      attrs = {form_field: field, details: details_attrs.fetch(field.id.to_s, {})}
      form_response.field_responses.build(attrs)
    end
    form_response
  end

  def create_response(form, details_attrs, user = nil)
    form_response = build_response(form, details_attrs, user)
    form_response.save!
    form_response
  end

  private

  def filter_create_form_attrs(attrs)
    allowed_attrs = [:number, :version, :name, :description, :project, :user, :fields]
    attrs.select { |k, v| allowed_attrs.include?(k.to_sym) }
  end

  def filter_update_form_attrs(attrs)
    allowed_attrs = [:name, :description, :project, :user, :fields]
    attrs.select { |k, v| allowed_attrs.include?(k.to_sym) }
  end

  def build_fields(fields)
    (fields || []).map do |field_attrs|
      FormField.new(filter_field_attrs(field_attrs))
    end
  end

  def filter_field_attrs(attrs)
    allowed_attrs = [:kind, :details]
    attrs.select { |k, v| allowed_attrs.include?(k.to_sym) }
  end

  def non_info_fields(fields)
    fields.reject { |field| field.kind == 'info' }
  end

  def make_unique_slug(form)
    slug = form.name.parameterize
    used_slugs = Form.where("published = TRUE AND slug LIKE ?", "#{slug}%").pluck(:slug)
    if used_slugs.empty? or !used_slugs.include?(slug)
      slug
    else
      nums = used_slugs.map { |s| s.match(/^#{slug}-(\d+)$/) { |m| m[1].to_i } }.compact
      slug_num = (nums.max || 0) + 1
      "#{slug}-#{slug_num}"
    end
  end

end

