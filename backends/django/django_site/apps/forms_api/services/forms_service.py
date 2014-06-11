import re

from django.core.exceptions import ValidationError
from django.db.models import Count
from django.utils.text import slugify

from django_site.apps.forms_api.models import (
    Form, FormField, FormResponse, FormFieldResponse, FormLockedError
)


__all__ = ['current_forms', 'create']

ALLOWED_UPDATE_ATTRS = ['name', 'description', 'project', 'user', 'fields']
ALLOWED_CREATE_ATTRS = ['number', 'version'] + ALLOWED_UPDATE_ATTRS


def _filter_data(data, allowed):
    return {key: data[key] for key in allowed if key in data}


def _validate_and_save_form_data(form_data, form=None):
    fields = form_data.pop('fields', [])
    if form is None:
        form = Form(**form_data)
    else:
        for key, value in form_data.items():
            setattr(form, key, value)
    form.full_clean()
    form.save()
    return _validate_and_save_fields(form, fields)


def _validate_and_save_fields(form, fields):
    for field_data in fields:
        field_data['form'] = form
        field = FormField(**field_data)
        field.full_clean()
        field.save()
    return form


def _make_unique_slug(form):
    slug = slugify(form.name)
    used_slugs = (Form.objects
                  .filter(published=True, slug__startswith=slug)
                  .values_list('slug', flat=True))
    if slug in used_slugs:
        slug_matches = [re.match('%s-(\d+)$' % slug, s) for s in used_slugs]
        slug_nums = [int(m.group(1)) for m in slug_matches if m]
        slug_num = (max(slug_nums) if slug_nums else 0) + 1
        slug = '%s-%d' % (slug, slug_num)
    return slug


def current_forms():
    prev_pub = Form.objects.filter(published=True, current=False)
    numbers = [str(n) for n in prev_pub.values_list('number', flat=True)]
    prev_pub_sql = ("number IN (%s)" % ','.join(numbers) if len(numbers) > 0
                    else "FALSE")
    return (Form.objects.filter(current=True)
            .annotate(num_responses=Count('formresponse'))
            .extra(select={'prev_published': prev_pub_sql}))


def create(**form_data):
    form_data = _filter_data(form_data, ALLOWED_CREATE_ATTRS)
    if 'number' in form_data and form_data['number'] > 0:
        next_version = Form.objects.max_version(form_data['number']) + 1
        form_data['version'] = next_version
    else:
        form_data['number'] = Form.objects.max_number() + 1
        form_data['version'] = 1
    form_data['current'] = True
    Form.objects.filter(number=form_data['number']).update(current=False)
    return _validate_and_save_form_data(form_data)


def update(number, version, **form_data):
    form_data = _filter_data(form_data, ALLOWED_UPDATE_ATTRS)
    form = Form.objects.get(number=number, version=version)
    if form.locked:
        raise FormLockedError
    FormField.objects.filter(form=form).delete()
    return _validate_and_save_form_data(form_data, form)


def versions(number):
    forms = (Form.objects
             .select_related('user')
             .prefetch_related('formfield_set')
             .filter(number=number)
             .annotate(num_responses=Count('formresponse')))
    if not forms:
        raise Form.DoesNotExist
    return forms


def version(number, version):
    return (Form.objects
            .select_related('user')
            .prefetch_related('formfield_set')
            .get(number=number, version=version))


def publish(number, version):
    Form.objects.filter(number=number).update(published=False)
    form = Form.objects.get(number=number, version=version)
    form.published = True
    form.locked = True
    form.slug = _make_unique_slug(form)
    form.save()
    return form


def unpublish(number, version):
    form = Form.objects.get(number=number, version=version)
    form.published = False
    form.save()
    return form


def form_with_responses(number, version):
    return (Form.objects
            .prefetch_related('formfield_set',
                              'formresponse_set__formfieldresponse_set')
            .get(number=number, version=version))


def published_form(project, slug):
    return (Form.objects
            .select_related('user')
            .prefetch_related('formfield_set')
            .get(project=project, slug=slug, published=True))


def published_forms(project):
    return (Form.objects
            .select_related('user')
            .prefetch_related('formfield_set')
            .filter(project=project, published=True))


def create_response(form, field_response_data, user=None):
    fields = filter(lambda f: f.kind != 'info', form.formfield_set.all())
    field_responses = _build_field_responses(fields, field_response_data)
    _validate_field_responses(field_responses)
    form_response = FormResponse.objects.create(form=form, user=user)
    for field_response in field_responses:
        field_response.form_response = form_response
        field_response.save()
    return form_response


def _build_field_responses(fields, field_response_data):
    field_responses = []
    for field in fields:
        details = field_response_data.get(str(field.id), {})
        field_response = FormFieldResponse(form_field=field, details=details)
        field_responses.append(field_response)
    return field_responses


def _validate_field_responses(field_responses):
    errors = {}
    for field_response in field_responses:
        try:
            field_response.clean()
        except ValidationError as e:
            errors[str(field_response.form_field.id)] = e
    if errors:
        raise ValidationError(errors)
