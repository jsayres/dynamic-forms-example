module FormResponsesCsvService
  extend self
  
  def create_csv(form)
    CSV.generate do |csv|
      non_info_fields = form.fields.reject { |f| f.kind == 'info' }
      field_headers = non_info_fields.map { |f| header(f) }
      csv << ["User", "Date"] + field_headers
      form.responses.each do |response|
        response_cells = response.field_responses.each_with_index.map do |fr, i|
          cell(non_info_fields[i], fr)
        end
        username = response.user ? response.user.username : ''
        csv << [username, response.updated_at] + response_cells
      end
    end
  end

  private

  def header(field)
    header_method = field.kind.underscore.concat('_header').to_sym
    send(header_method, field.details)
  end

  def short_answer_header(details)
    question_with_label(details)
  end

  def long_answer_header(details)
    question_with_label(details)
  end

  def single_choice_header(details)
    details[:question]
  end

  def multiple_choice_header(details)
    details[:question]
  end

  def address_header(details)
    details[:question]
  end

  def question_with_label(details)
    [details[:question], details[:label]].reject(&:blank?).join("\n\n")
  end

  def cell(field, field_response)
    cell_method = field.kind.underscore.concat('_cell').to_sym
    send(cell_method, field_response.details)
  end

  def short_answer_cell(details)
    details[:answer]
  end

  def long_answer_cell(details)
    details[:answer]
  end

  def single_choice_cell(details)
    details[:answer]
  end

  def multiple_choice_cell(details)
    details[:answers].select { |a| a[:selected] }.map { |a| a[:label] }.join(", ")
  end

  def address_cell(details)
    [
      details[:addressLine1],
      details[:addressLine2],
      "#{details[:city]}, #{details[:state]} #{details[:zip]}"
    ].reject(&:blank?).join("\n")
  end

end

