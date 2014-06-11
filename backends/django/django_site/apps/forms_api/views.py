from functools import wraps
import json

from django.conf import settings
from django.core.exceptions import ObjectDoesNotExist, ValidationError
from django.http import HttpResponse

from django_site.libs.decorators import staff_or_admin_required
from django_site.libs.http import JSONResponse
from django_site.libs.utils import model_to_dict
from django_site.apps.forms_api.models import FormLockedError
from django_site.apps.forms_api.services import (forms_service,
                                                 form_responses_csv_service)


def _format_date(date):
    return date.strftime('%b %d, %Y %I:%M:%S %p')

def handle_common_errors(view):
    @wraps(view)
    def _wrapped_view(request, *args, **kwargs):
        try:
            return view(request, *args, **kwargs)
        except FormLockedError:
            return JSONResponse({'error': 'Form is locked.'}, 403)
        except ObjectDoesNotExist:
            return JSONResponse({'error': 'Form does not exist.'}, 404)
        except ValidationError as e:
            messages = ['%s: %s' % (field, ' '.join(errors))
                        for field, errors in e.message_dict.items()]
            return JSONResponse({'error': ', '.join(messages)}, 403)
    return _wrapped_view


@staff_or_admin_required
@handle_common_errors
def current_forms(request):
    if request.method == 'POST':
        return _create_form(request)
    else:
        return _get_current_forms(request)


def _create_form(request):
    data = json.loads(request.body)['form']
    data.update({'user': request.user})
    form = forms_service.create(**data)
    return JSONResponse({'number': form.number, 'version': form.version})


def _get_current_forms(request):
    forms = forms_service.current_forms()
    exclude = ['user', 'created', 'modified']
    update = {'username': lambda f: f.user.username,
              'date': lambda f: _format_date(f.modified),
              'prevPublished': lambda f: f.prev_published,
              'numResponses': lambda f: f.num_responses}
    forms_data = [model_to_dict(f, *exclude, **update) for f in forms]
    return JSONResponse({'forms': forms_data})


@staff_or_admin_required
@handle_common_errors
def form_version(request, number, version):
    if request.method == 'PUT':
        return _update_form(request, number, version)
    else:
        return _get_form_version(request, number, version)


def _get_form_version(request, number, version):
    form = forms_service.version(number, version)
    exclude = ['user', 'created', 'modified']
    update = {'username': lambda f: f.user.username,
              'date': lambda f: _format_date(f.modified),
              'fields': lambda f: [model_to_dict(fld, 'form')
                                   for fld in f.formfield_set.all()]}
    return JSONResponse({'form': model_to_dict(form, *exclude, **update)})


def _update_form(request, number, version):
    data = json.loads(request.body).get('form', {})
    if not data:
        return JSONResponse({'error': 'Nothing to update.'}, 403)
    data.update({'number': number, 'version': version, 'user': request.user})
    form = forms_service.update(**data)
    return JSONResponse({'date': str(form.modified)})


@staff_or_admin_required
@handle_common_errors
def publish_form(request, number, version):
    form = forms_service.publish(number, version)
    return JSONResponse({'published': True, 'slug': form.slug})


@staff_or_admin_required
@handle_common_errors
def unpublish_form(request, number, version):
    forms_service.unpublish(number, version)
    return JSONResponse({'published': False})


@staff_or_admin_required
@handle_common_errors
def form_versions(request, number):
    forms = forms_service.versions(number)
    exclude = ['user', 'created', 'modified']
    update = {'username': lambda f: f.user.username,
              'date': lambda f: _format_date(f.modified),
              'fields': lambda f: [model_to_dict(fld, 'form')
                                   for fld in f.formfield_set.all()],
              'numResponses': lambda f: f.num_responses}
    forms_data = [model_to_dict(f, *exclude, **update) for f in forms]
    return JSONResponse({'forms': forms_data})


@staff_or_admin_required
@handle_common_errors
def form_with_responses(request, number, version):
    form = forms_service.form_with_responses(number, version)
    exclude = ['user', 'created', 'modified']
    update = {
        'username': lambda f: f.user.username,
        'date': lambda f: _format_date(f.modified),
        'fields': lambda f: [model_to_dict(fld, 'form')
                             for fld in f.formfield_set.all()],
        'responses': lambda f: [_response_to_dict(r)
                                for r in f.formresponse_set.all()],
    }
    return JSONResponse({'form': model_to_dict(form, *exclude, **update)})


def _response_to_dict(response):
    exclude = ['form', 'user', 'created']
    update = {
        'username': lambda r: r.user.username if r.user else '---',
        'date': lambda r: str(r.created),
        'fieldResponses': lambda r: [
            model_to_dict(fr, 'form_response', 'form_field')
            for fr in r.formfieldresponse_set.all()
        ],
    }
    return model_to_dict(response, *exclude, **update)


@staff_or_admin_required
@handle_common_errors
def form_with_responses_csv(request, number, version):
    form = forms_service.form_with_responses(number, version)
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename=responses.csv'
    form_responses_csv_service.create_csv(form, response)
    return response


@staff_or_admin_required
def projects_list(request):
    projects = {k: v['name'] for k, v in settings.PROJECTS.items()}
    return JSONResponse({'projects': projects})
