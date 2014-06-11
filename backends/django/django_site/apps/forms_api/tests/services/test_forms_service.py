from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.test import TestCase

from model_mommy import mommy

from django_site.apps.forms_api.models import (
    Form, FormField, FormResponse, FormFieldResponse, FormLockedError
)
from django_site.apps.forms_api.services import forms_service
from django_site.libs.utils import model_to_dict


class CurrentFormsTests(TestCase):

    def test_lists_current_forms(self):
        mommy.make(Form, number=1, current=True)
        mommy.make(Form, number=2)
        self.assertEqual(len(forms_service.current_forms()), 1)

    def test_adds_prev_published_annotation_to_each_form(self):
        mommy.make(Form, number=1, version=1, published=True)
        mommy.make(Form, number=1, version=2, current=True)
        mommy.make(Form, number=2, version=1, current=True)
        self.assertTrue(forms_service.current_forms()[0].prev_published)
        self.assertFalse(forms_service.current_forms()[1].prev_published)

    def test_adds_num_responses_annotation_to_each_form(self):
        form = mommy.make(Form, number=1, version=1, current=True)
        mommy.make(FormResponse, form=form, _quantity=2)
        self.assertEqual(forms_service.current_forms()[0].num_responses, 2)

    def test_provides_empty_query_list_when_no_forms(self):
        self.assertEqual(len(forms_service.current_forms()), 0)


class CreateTests(TestCase):

    def test_increases_number_when_unspecified(self):
        user = mommy.make(Form, number=3).user
        new_form = mommy.prepare(Form, user=user)
        form_data = model_to_dict(new_form, 'number')
        form = forms_service.create(**form_data)
        self.assertEqual(form.number, 4)

    def test_increases_version_when_unspecified_and_number_specified(self):
        user = mommy.make(Form, number=3, version=4).user
        new_form = mommy.prepare(Form, number=3, user=user)
        form_data = model_to_dict(new_form, 'version')
        form = forms_service.create(**form_data)
        self.assertEqual(form.version, 5)

    def test_sets_new_form_current_and_previous_forms_old(self):
        user = mommy.make(Form, number=3, version=1, current=True).user
        form = mommy.prepare(Form, number=3, user=user)
        form_data = model_to_dict(form)
        form = forms_service.create(**form_data)
        self.assertTrue(form.current)
        self.assertFalse(Form.objects.get(number=3, version=1).current)

    def test_creates_any_specified_form_fields(self):
        form = mommy.prepare(Form, user=mommy.make(User))
        form_data = model_to_dict(form)
        form_data['fields'] = [{'form': form, 'kind': 'info'}]
        form = forms_service.create(**form_data)
        self.assertEqual(form.formfield_set.first().kind, 'info')

    def test_raises_error_when_params_invalid(self):
        form_data = model_to_dict(mommy.prepare(Form))
        self.assertRaises(ValidationError, forms_service.create, **form_data)


class UpdateTests(TestCase):

    def test_updates_and_returns_form_if_not_locked(self):
        mommy.make(Form, number=3, version=2, name='x')
        form = forms_service.update(3, 2, name='y')
        self.assertIsInstance(form, Form)
        self.assertEqual(form.name, 'y')
        self.assertEqual(Form.objects.get(id=form.id).name, 'y')

    def test_destroys_old_fields_and_creates_new_ones(self):
        form = mommy.make(Form, number=3, version=2, name='x')
        field = mommy.make(FormField, form=form, kind='info')
        new_field = mommy.prepare(FormField, kind='short-answer')
        new_field_data = model_to_dict(new_field)
        forms_service.update(3, 2, fields=[new_field_data])
        self.assertRaises(FormField.DoesNotExist,
                          FormField.objects.get, id=field.id)
        fields = FormField.objects.filter(form=form)
        self.assertEqual(len(fields), 1)
        self.assertEqual(fields[0].kind, 'short-answer')

    def test_raises_error_when_form_locked(self):
        mommy.make(Form, number=3, version=2, name='x', locked=True)
        self.assertRaises(FormLockedError,
                          forms_service.update, 3, 2, name='y')

    def test_raises_error_when_params_invalid(self):
        mommy.make(Form, number=3, version=2)
        self.assertRaises(ValueError,
                          forms_service.update, 3, 2, user=None)
        self.assertRaises(ValidationError,
                          forms_service.update, 3, 2, name='')

    def test_raises_error_when_form_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist,
                          forms_service.update, 3, 2, name='y')


class VersionsTests(TestCase):

    def test_returns_list_of_forms_with_specified_number(self):
        form1 = mommy.make(Form, number=3, version=1)
        form2 = mommy.make(Form, number=3, version=2)
        mommy.make(Form, number=4, version=1)
        forms = forms_service.versions(3)
        self.assertEqual(len(forms), 2)
        self.assertEqual(forms[0].id, form1.id)
        self.assertEqual(forms[1].id, form2.id)

    def test_each_form_includes_user_loaded(self):
        mommy.make(Form, number=3, version=2)
        form = forms_service.versions(3)[0]
        with self.assertNumQueries(0):
            form.user.username

    def test_each_form_includes_fields_loaded(self):
        form = mommy.make(Form, number=3, version=2)
        mommy.make(FormField, form=form, kind='info')
        form = forms_service.versions(3)[0]
        with self.assertNumQueries(0):
            fields = form.formfield_set.all()
            self.assertEqual(len(fields), 1)

    def test_adds_num_responses_annotation_to_each_form(self):
        form = mommy.make(Form, number=3, version=3)
        mommy.make(FormResponse, form=form, _quantity=2)
        self.assertEqual(forms_service.versions(3)[0].num_responses, 2)

    def test_raises_error_when_form_number_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist, forms_service.versions, 1)


class VersionTests(TestCase):

    def test_returns_form_with_specified_number_and_version(self):
        form = mommy.make(Form, number=3, version=2)
        self.assertEqual(forms_service.version(3, 2).id, form.id)

    def test_form_includes_user_loaded(self):
        mommy.make(Form, number=3, version=2)
        form = forms_service.version(3, 2)
        with self.assertNumQueries(0):
            form.user.username

    def test_form_includes_fields_loaded(self):
        form = mommy.make(Form, number=3, version=2)
        mommy.make(FormField, form=form, kind='info')
        form = forms_service.version(3, 2)
        with self.assertNumQueries(0):
            fields = form.formfield_set.all()
            self.assertEqual(len(fields), 1)

    def test_raises_error_when_form_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist, forms_service.version, 3, 2)


class PublishTests(TestCase):

    def test_published_specified_form_and_unpublished_other_versions(self):
        mommy.make(Form, number=3, version=1, published=True)
        mommy.make(Form, number=3, version=2)
        forms_service.publish(3, 2)
        forms = Form.objects.all()
        self.assertFalse(forms[0].published)
        self.assertTrue(forms[1].published)

    def test_marks_published_form_as_locked(self):
        mommy.make(Form, number=3, version=2)
        form = forms_service.publish(3, 2)
        self.assertTrue(form.locked)

    def test_sets_unique_slug_on_form(self):
        mommy.make(Form, number=1, version=1, name='Test Form')
        mommy.make(Form, number=2, version=1, name='Test Form')
        form1 = forms_service.publish(1, 1)
        form2 = forms_service.publish(2, 1)
        self.assertEqual(form1.slug, 'test-form')
        self.assertEqual(form2.slug, 'test-form-1')

    def test_raises_error_when_form_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist, forms_service.publish, 3, 2)


class UnpublishTests(TestCase):

    def test_unpublishes_specified_form(self):
        mommy.make(Form, number=3, version=2, published=True)
        form = forms_service.unpublish(3, 2)
        self.assertFalse(form.published)

    def test_raises_error_when_form_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist, forms_service.unpublish, 3, 2)


class FormWithResponsesTests(TestCase):

    def test_returns_form_with_responses_and_fields_loaded(self):
        form1 = mommy.make(Form, number=1, version=1)
        field1 = mommy.make(FormField, form=form1, kind='short-answer')
        response1 = mommy.make(FormResponse, form=form1)
        field_response1 = mommy.make(
            FormFieldResponse,
            form_response=response1,
            form_field=field1,
            details={'answer': 'ok'}
        )
        form2 = forms_service.form_with_responses(1, 1)
        with self.assertNumQueries(0):
            field2 = form2.formfield_set.all()[0]
            response2 = form2.formresponse_set.all()[0]
            field_response2 = response2.formfieldresponse_set.all()[0]
            self.assertEqual(form1.id, form2.id)
            self.assertEqual(field1.id, field2.id)
            self.assertEqual(response1.id, response2.id)
            self.assertEqual(field_response1.id, field_response2.id)

    def test_returns_form_with_empty_responses_list_if_no_responses(self):
        mommy.make(Form, number=1, version=1)
        form2 = forms_service.form_with_responses(1, 1)
        self.assertEqual(list(form2.formresponse_set.all()), [])

    def test_raises_error_when_form_does_not_exist(self):
        self.assertRaises(Form.DoesNotExist,
                          forms_service.form_with_responses, 1, 1)


class PublishedFormTests(TestCase):

    def test_returns_published_form_with_specified_project_and_slug(self):
        form = mommy.make(Form, published=True)
        published_form = forms_service.published_form(form.project, form.slug)
        self.assertEqual(published_form.id, form.id)

    def test_form_includes_user_loaded(self):
        form = mommy.make(Form, published=True)
        published_form = forms_service.published_form(form.project, form.slug)
        with self.assertNumQueries(0):
            published_form.user.username

    def test_form_includes_fields_loaded(self):
        form = mommy.make(Form, published=True)
        mommy.make(FormField, form=form, kind='info')
        published_form = forms_service.published_form(form.project, form.slug)
        with self.assertNumQueries(0):
            fields = published_form.formfield_set.all()
            self.assertEqual(len(fields), 1)

    def test_raises_error_when_form_does_not_exist(self):
        form = mommy.make(Form, )
        self.assertRaises(
            Form.DoesNotExist,
            forms_service.published_form, form.project, form.slug
        )


class PublishedFormsTests(TestCase):

    def test_returns_list_of_published_forms_for_specified_project(self):
        p1, p2 = [c[0] for c in Form.PROJECT_CHOICES][0:2]
        form1 = mommy.make(Form, number=1, project=p1, published=True)
        mommy.make(Form, number=2, project=p2, published=True)
        mommy.make(Form, number=3, project=p1, published=False)
        form4 = mommy.make(Form, number=4, project=p1, published=True)
        published_forms = forms_service.published_forms(p1)
        self.assertEqual(len(published_forms), 2)
        self.assertEqual(published_forms[0].id, form1.id)
        self.assertEqual(published_forms[1].id, form4.id)

    def test_each_form_includes_user_loaded(self):
        form = mommy.make(Form, published=True)
        published_form = forms_service.published_forms(form.project)[0]
        with self.assertNumQueries(0):
            published_form.user.username

    def test_each_form_includes_fields_loaded(self):
        form = mommy.make(Form, published=True)
        mommy.make(FormField, form=form, kind='info')
        published_form = forms_service.published_forms(form.project)[0]
        with self.assertNumQueries(0):
            fields = published_form.formfield_set.all()
            self.assertEqual(len(fields), 1)


class CreateResponsesTests(TestCase):

    def test_creates_response_from_form_and_supplied_attributes(self):
        form = mommy.make(Form)
        for i, kind in enumerate(map(lambda c: c[0], FormField.KIND_CHOICES)):
            if kind in ['single-choice', 'multiple-choice']:
                details = {'choices': [{'label': 'A'}, {'label': 'B'}]}
            else:
                details = {}
            id = i + 1
            mommy.make(FormField, id=id, form=form, kind=kind, details=details)
        data = {
            '1': {'answer': 'none'},
            '2': {'answer': 'short-answer'},
            '3': {'answer': 'long-answer'},
            '4': {'answer': 'A'},
            '5': {'answers': [{'label': 'B', 'selected': True}]},
            '6': {'addressLine1': '1', 'addressLine2': '2', 'city': 'c',
                  'state': 's', 'zip': '00000'},
        }
        response = forms_service.create_response(form, data)
        for field_response in response.formfieldresponse_set.all():
            id = str(field_response.form_field_id)
            self.assertEqual(field_response.details, data[id])

    def test_sets_user_if_specified(self):
        form = mommy.make(Form)
        user = mommy.make(User)
        response = forms_service.create_response(form, {}, user)
        self.assertEqual(user, response.user)

    def test_raises_error_and_stores_messages_when_attributes_invalid(self):
        form = mommy.make(Form)
        details = {'required': True}
        mommy.make(FormField, form=form, kind='short-answer', details=details)
        mommy.make(FormField, form=form, kind='single-choice', details=details)
        with self.assertRaises(ValidationError) as cm:
            forms_service.create_response(form, {})
        errors = cm.exception.error_dict
        self.assertEqual(len(errors), 2)
        for field in form.formfield_set.all():
            self.assertIn(str(field.id), errors)
            self.assertIsInstance(errors[str(field.id)], ValidationError)
