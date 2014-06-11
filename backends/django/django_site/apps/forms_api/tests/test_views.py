from cStringIO import StringIO
import csv
import json

from django.conf import settings
from django.contrib.auth.models import AnonymousUser, User
from django.core.urlresolvers import reverse
from django.test import TestCase
from django.test.client import RequestFactory

from model_mommy import mommy

from django_site.apps.forms_api.models import (
    Form, FormField, FormFieldResponse
)
from django_site.apps.forms_api.views import (
    current_forms, publish_form, unpublish_form, form_versions, form_version,
    form_with_responses, form_with_responses_csv, projects_list
)
from django_site.libs.utils import model_to_dict


class AuthTests(object):

    def setUp(self):
        self.setUpRequest()
        self.request.user = AnonymousUser()

    def setUpRequest(self):
        pass

    def _create_user(self, password='pass', **extra):
        user = mommy.prepare(User, **extra)
        user.set_password(password)
        user.save()
        return user

    def _create_and_login_user(self, **extra):
        self.request.user = self._create_user(**extra)
        return self.request.user

    def test_returns_401_if_user_not_logged_in(self):
        response = projects_list(self.request)
        self.assertEqual(response.status_code, 401)

    def test_returns_403_if_user_logged_in_but_not_active(self):
        self._create_and_login_user(is_active=False)
        response = projects_list(self.request)
        self.assertEqual(response.status_code, 403)

    def test_returns_403_if_user_logged_in_but_not_staff_or_admin(self):
        self._create_and_login_user()
        response = projects_list(self.request)
        self.assertEqual(response.status_code, 403)


class CurrentFormsListTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-current_forms')
        self.request = RequestFactory().get(self.url)

    def test_provides_json_list_of_current_forms(self):
        self._create_and_login_user(is_staff=True)
        mommy.make(Form, current=True)
        response = current_forms(self.request)
        response_data = json.loads(response.content)
        self.assertEqual(len(response_data['forms']), 1)
        self.assertTrue(response_data['forms'][0]['current'])


class CreateFormTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-current_forms')
        self.request = self._create_request()

    def _create_request(self, data={}):
        return RequestFactory().post(self.url, json.dumps(data),
                                     content_type='application/json')

    def _set_request_data(self, form, *exclude, **update):
        data = {'form': model_to_dict(form, *exclude, **update)}
        new_request = self._create_request(data)
        new_request.user = self.request.user
        self.request = new_request

    def test_creates_form_and_returns_json_number_and_version(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.prepare(Form, number=2, version=3)
        self._set_request_data(form, 'user', 'created', 'modified')
        response = current_forms(self.request)
        self.assertJSONEqual(response.content, {'number': 2, 'version': 1})

    def test_returns_403_error_if_form_invalid(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.prepare(Form, number=2, name='')
        self._set_request_data(form, 'user', 'created', 'modified')
        response = current_forms(self.request)
        self.assertEqual(response.status_code, 403)
        self.assertIn('error', json.loads(response.content))


class UpdateFormTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-form_version', args=[1, 2])
        self.request = self._create_request()

    def _create_request(self, data={}):
        return RequestFactory().put(self.url, json.dumps(data),
                                    content_type='application/json')

    def _set_request_data(self, form, *exclude, **update):
        data = {'form': model_to_dict(form, *exclude, **update)}
        new_request = self._create_request(data)
        new_request.user = self.request.user
        self.request = new_request

    def test_updates_form_and_returns_modified_date(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2, name='old')
        self._set_request_data(form, 'user', 'created', 'modified', name='new')
        response = form_version(self.request, 1, 2)
        self.assertIn('date', json.loads(response.content))

    def test_returns_403_error_if_form_locked(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2, name='old', locked=True)
        self._set_request_data(form, 'user', 'created', 'modified', name='new')
        response = form_version(self.request, 1, 2)
        self.assertEqual(response.status_code, 403)
        self.assertIn('error', json.loads(response.content))

    def test_sets_form_user_to_current_user(self):
        user = self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2, name='old')
        self._set_request_data(form, 'user', 'created', 'modified', name='new')
        form_version(self.request, 1, 2)
        self.assertEqual(Form.objects.get(id=form.id).user_id, user.id)

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.prepare(Form, number=1, version=2, name='old')
        self._set_request_data(form, 'user', 'created', 'modified', name='new')
        response = form_version(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))

    def test_returns_403_error_if_form_data_invalid(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2, name='old')
        self._set_request_data(form, 'user', 'created', 'modified', name='')
        response = form_version(self.request, 1, 2)
        self.assertEqual(response.status_code, 403)
        self.assertIn('error', json.loads(response.content))


class PublishFormTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-publish_form', args=[1, 2])
        self.request = RequestFactory().post(self.url, {},
                                             content_type='application/json')

    def test_publishes_form_and_returns_published_status_and_slug(self):
        self._create_and_login_user(is_staff=True)
        mommy.make(Form, number=1, version=2)
        response = publish_form(self.request, 1, 2)
        response_data = json.loads(response.content)
        self.assertTrue(response_data['published'])
        self.assertIn('slug', response_data)

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = publish_form(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class UnpublishFormTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-unpublish_form', args=[1, 2])
        self.request = RequestFactory().post(self.url, {},
                                             content_type='application/json')

    def test_unpublishes_form_and_returns_published_status(self):
        self._create_and_login_user(is_staff=True)
        mommy.make(Form, number=1, version=2, published=True)
        response = unpublish_form(self.request, 1, 2)
        self.assertJSONEqual(response.content, {'published': False})

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = unpublish_form(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class FormVersionsListTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-form_versions', args=[1])
        self.request = RequestFactory().get(self.url)

    def test_provides_json_list_of_versions_for_number(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=1)
        mommy.make(FormField, form=form, kind='info')
        response = form_versions(self.request, form.number)
        forms_data = json.loads(response.content)['forms']
        self.assertEqual(len(forms_data), 1)
        self.assertEqual(forms_data[0]['version'], 1)
        self.assertEqual(forms_data[0]['fields'][0]['kind'], 'info')

    def test_returns_404_error_if_number_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = form_versions(self.request, 1)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class FormVersionTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-form_version', args=[1, 2])
        self.request = RequestFactory().get(self.url)

    def test_provides_json_form_for_number_and_version(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2)
        mommy.make(FormField, form=form, kind='info')
        response = form_version(self.request, 1, 2)
        form_data = json.loads(response.content)['form']
        self.assertEqual(form_data['version'], 2)
        self.assertEqual(form_data['fields'][0]['kind'], 'info')

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = form_version(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class FormWithResponsesListTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-form_with_responses', args=[1, 2])
        self.request = RequestFactory().get(self.url)

    def test_provides_json_form_for_number_and_version_with_responses(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2)
        field = mommy.make(FormField, form=form, kind='short-answer')
        mommy.make(FormFieldResponse,
                   form_response__form=form,
                   form_field=field,
                   details={'answer': 'ok'})
        response = form_with_responses(self.request, 1, 2)
        form_data = json.loads(response.content)['form']
        self.assertEqual(form_data['version'], 2)
        self.assertEqual(form_data['fields'][0]['kind'], 'short-answer')
        self.assertEqual(len(form_data['responses']), 1)
        details = form_data['responses'][0]['fieldResponses'][0]['details']
        self.assertEqual(details['answer'], 'ok')

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = form_with_responses(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class FormWithResponsesListCsvTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-form_with_responses_csv', args=[1, 2])
        self.request = RequestFactory().get(self.url)

    def test_provides_csv_download_of_responses(self):
        self._create_and_login_user(is_staff=True)
        form = mommy.make(Form, number=1, version=2)
        field = mommy.make(FormField, form=form, kind='short-answer')
        mommy.make(FormFieldResponse,
                   form_response__form=form,
                   form_field=field,
                   details={'answer': 'ok'})
        response = form_with_responses_csv(self.request, 1, 2)
        self.assertIn('text/csv', response['Content-Type'])
        self.assertIn('attachment; filename=', response['Content-Disposition'])
        rows = list(csv.reader(StringIO(response.content)))
        self.assertEqual(len(rows), 2)
        self.assertEqual(len(rows[0]), 3)
        self.assertEqual(len(rows[1]), 3)
        self.assertEqual(rows[1][2], 'ok')

    def test_returns_404_error_if_form_does_not_exist(self):
        self._create_and_login_user(is_staff=True)
        response = form_with_responses_csv(self.request, 1, 2)
        self.assertEqual(response.status_code, 404)
        self.assertIn('error', json.loads(response.content))


class ProjectsListTests(AuthTests, TestCase):

    def setUpRequest(self):
        self.url = reverse('api-projects_list')
        self.request = RequestFactory().get(self.url)

    def test_provides_json_list_of_projects(self):
        self._create_and_login_user(is_staff=True)
        response = projects_list(self.request)
        projects = json.loads(response.content)['projects']
        self.assertEqual(len(projects), len(settings.PROJECTS))
        for key, value in projects.items():
            self.assertEqual(value, settings.PROJECTS[key]['name'])
