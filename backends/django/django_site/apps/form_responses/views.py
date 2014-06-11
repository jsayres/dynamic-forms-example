from functools import wraps
import re

from django.conf import settings
from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist, ValidationError
from django.core.urlresolvers import reverse
from django.http import Http404
from django.shortcuts import redirect, render

from django_site.apps.forms_api.services import forms_service


def handle_not_found(view):
    @wraps(view)
    def _wrapped_view(request, *args, **kwargs):
        try:
            return view(request, *args, **kwargs)
        except ObjectDoesNotExist:
            raise Http404
    return _wrapped_view


@handle_not_found
def fill_out_form(request, project, slug):
    form = forms_service.published_form(project, slug)
    if request.method == 'POST':
        return _create_response(request, form)
    else:
        return _render_form(request, form)
    return _render_form(request, form)


def _create_response(request, form):
    field_response_data = _extract_field_response_data(request.POST)
    try:
        forms_service.create_response(form, field_response_data)
        messages.success(request, 'DONE')
    except ValidationError as e:
        errors = e.error_dict
        return _render_form(request, form, field_response_data, errors)
    return redirect(reverse('response_done', args=(form.project, form.slug)))


def _render_form(request, form, responses={}, errors={}):
    fields = []
    for field in form.formfield_set.all():
        id = str(field.id)
        fields.append((field, responses.get(id, {}), errors.get(id)))
    layout = 'layouts/%s' % settings.PROJECTS[form.project]['layout']
    return render(request,
                  'form_responses/render_form.html',
                  {'form': form, 'fields': fields, 'layout': layout})


def _extract_field_response_data(querydict):
    data = {}
    is_response_item = lambda item: item[0].startswith('responses')
    for key, value in filter(is_response_item, sorted(querydict.items())):
        response_keys = re.findall('\[(.+?)\]', key)
        _add_to_dict(data, response_keys, value)
    for key, value in data.items():
        data[key] = _dict_to_list(value)
    return data


def _add_to_dict(_dict, key_list, value):
    key = key_list.pop(0)
    if len(key_list) == 0:
        _dict[key] = value
    else:
        _add_to_dict(_dict.setdefault(key, {}), key_list, value)
    return _dict


def _dict_to_list(_dict):
    get_new_value = lambda v: _dict_to_list(v) if isinstance(v, dict) else v
    if all(map(lambda k: k.isdigit(), _dict.keys())):
        return map(get_new_value, sorted(_dict.values()))
    else:
        return dict(map(lambda key: (key, get_new_value(_dict[key])), _dict))


@handle_not_found
def response_done(request, project, slug):
    forms_service.published_form(project, slug)
    msgs = messages.get_messages(request)
    check_msg = lambda m: m.level == messages.SUCCESS and m.message == 'DONE'
    if len(filter(check_msg, msgs)) == 0:
        return redirect(settings.PROJECTS[project]['root'])
    layout = 'layouts/%s' % settings.PROJECTS[project]['layout']
    return render(request, 'form_responses/done.html', {'layout': layout})


def project_forms(request, project):
    if project not in settings.PROJECTS:
        raise Http404
    forms = forms_service.published_forms(project)
    layout = 'layouts/%s' % settings.PROJECTS[project]['layout']
    return render(request,
                  'form_responses/project_forms.html',
                  {'layout': layout, 'forms': forms})
