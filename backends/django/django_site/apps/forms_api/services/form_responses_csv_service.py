import csv


def create_csv(form, out):
    writer = csv.writer(out)
    fields = filter(lambda f: f.kind != 'info', form.formfield_set.all())
    writer.writerow(['User', 'Date'] + map(_get_header, fields))
    for response in form.formresponse_set.all():
        username = response.user.username if response.user else '---'
        date = str(response.created)
        response_cells = map(_get_cell, response.formfieldresponse_set.all())
        writer.writerow([username, date] + response_cells)


def _get_header(field):
    return {
        'short-answer': _question_with_label,
        'long-answer': _question_with_label,
        'single-choice': _question_only,
        'multiple-choice': _question_only,
        'address': _question_only,
    }[field.kind](field.details)


def _question_with_label(details):
    header_items = [details.get(k, '') for k in ['question', 'label']]
    return '\n\n'.join(filter(bool, header_items))


def _question_only(details):
    return details.get('question', '')


def _get_cell(field_response):
    return {
        'short-answer': _answer_only,
        'long-answer': _answer_only,
        'single-choice': _answer_only,
        'multiple-choice': _selections,
        'address': _address,
    }[field_response.form_field.kind](field_response.details)


def _answer_only(details):
    return details.get('answer', '')


def _selections(details):
    answers = details.get('answers', [])
    selected_answers = filter(lambda a: a.get('selected'), answers)
    selected_labels = map(lambda a: a.get('label', ''), selected_answers)
    return ', '.join(selected_labels)


def _address(details):
    keys = ['addressLine1', 'addressLine2', 'city', 'state', 'zip']
    line1, line2, city, state, zip = [details.get(k, '') for k in keys]
    lines = [line1, line2, '%s, %s %s' % (city, state, zip)]
    return '\n'.join(filter(bool, lines))
