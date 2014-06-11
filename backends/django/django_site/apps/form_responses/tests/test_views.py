from django.conf import settings
from django.contrib import messages
from django.contrib.messages.storage.base import Message, BaseStorage
from django.core.urlresolvers import reverse
from django.http import Http404
from django.template.defaultfilters import title
from django.test import TestCase
from django.test.client import RequestFactory

from model_mommy import mommy

from django_site.apps.form_responses.views import (
    fill_out_form, response_done, project_forms
)
from django_site.apps.forms_api.models import Form, FormField, FormResponse


class MockMessageStorage(BaseStorage):

    def __init__(self, request, *args, **kwargs):
        self._stored_messages = []
        super(MockMessageStorage, self).__init__(request, *args, **kwargs)

    def _get(self, *args, **kwargs):
        loaded_messages = self._stored_messages
        self._stored_messages = []
        return (loaded_messages, True)

    def _store(self, messages, *args, **kwargs):
        self._stored_messages.extend(messages)
        return []


class ResponseFormDisplayTests(TestCase):

    def setUp(self):
        self.project = settings.PROJECTS.keys()[0]
        self.url = reverse('fill_out_form', args=[self.project, 'form-1'])
        self.request = RequestFactory().get(self.url)

    def test_renders_the_form_template_and_handles_markdown(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        # mommy.make(FormField, form=form, kind='short-answer',
        #            details={'question': '# Answer the question.'})
        mommy.make(FormField, form=form, kind='multiple-choice',
                   details={'question': '# Pick some answers.',
                            'choices': [{'label': 'A'}, {'label': 'B'}]})
        response = fill_out_form(self.request, form.project, form.slug)
        self.assertContains(response, '<h1>Pick some answers.</h1>')
        self.assertContains(response, 'value="A"')
        self.assertContains(response, 'value="B"')

    def test_returns_404_error_if_form_does_not_exist(self):
        self.assertRaises(Http404, fill_out_form, self.request, 'x', 'x')


class CreateResponseTests(TestCase):

    def setUp(self):
        self.project = settings.PROJECTS.keys()[0]
        self.url = reverse('fill_out_form', args=[self.project, 'form-1'])
        data = {
            'responses[1][answers][0][label]': 'A',
            'responses[1][answers][0][selected]': False,
            'responses[1][answers][1][label]': 'B',
            'responses[1][answers][1][selected]': False,
        }
        self.request = RequestFactory().post(self.url, data)
        self.request._messages = MockMessageStorage(self.request)

    def test_creates_response_and_redirects_to_done_page(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        mommy.make(FormField, id=1, form=form, kind='multiple-choice',
                   details={'choices': [{'label': 'A'}, {'label': 'B'}]})
        response = fill_out_form(self.request, form.project, form.slug)
        self.assertEqual(response.status_code, 302)
        url = reverse('response_done', args=[form.project, 'form-1'])
        self.assertEqual(response.url, url)
        form_response = FormResponse.objects.last()
        field_response = form_response.formfieldresponse_set.first()
        self.assertEqual(form_response.form_id, form.id)
        self.assertEqual(field_response.details['answers'][0]['label'], 'A')
        self.assertFalse(field_response.details['answers'][0]['selected'])
        self.assertEqual(field_response.details['answers'][1]['label'], 'B')
        self.assertFalse(field_response.details['answers'][1]['selected'])

    def test_sets_message_to_enable_done_view(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        mommy.make(FormField, id=1, form=form, kind='multiple-choice',
                   details={'choices': [{'label': 'A'}, {'label': 'B'}]})
        fill_out_form(self.request, form.project, form.slug)
        self.assertEqual(len(self.request._messages._queued_messages), 1)
        msg = self.request._messages._queued_messages[0]
        self.assertEqual(msg.level, messages.SUCCESS)
        self.assertEqual(msg.message, 'DONE')

    def test_rerenders_form_with_error_messages_if_response_invalid(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        mommy.make(FormField, id=1, form=form, kind='multiple-choice',
                   details={'question': 'Pick your answers',
                            'choices': [{'label': 'A'}, {'label': 'B'}],
                            'required': True})
        response = fill_out_form(self.request, form.project, form.slug)
        self.assertContains(response, 'Pick your answers')
        self.assertContains(response, 'class="error"')

    def test_returns_404_error_if_form_does_not_exist(self):
        self.assertRaises(Http404, fill_out_form, self.request, 'x', 'x')


class DonePageTests(TestCase):

    def setUp(self):
        self.project = settings.PROJECTS.keys()[0]
        self.url = reverse('response_done', args=[self.project, 'form-1'])
        self.request = RequestFactory().get(self.url)
        self.request._messages = MockMessageStorage(self.request)
        self.done_message = Message(messages.SUCCESS, 'DONE')
        self.misc_message = Message(messages.SUCCESS, 'x')

    def test_template_is_rendered_if_done_message_is_set(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        self.request._messages._store([self.done_message])
        response = response_done(self.request, form.project, form.slug)
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'success')
        self.assertEqual(len(self.request._messages._get()[0]), 0)

    def test_redirects_to_project_if_done_message_is_not_set(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        self.request._messages._store([self.misc_message])
        response = response_done(self.request, form.project, form.slug)
        self.assertEqual(response.status_code, 302)
        self.assertEqual(response.url, settings.PROJECTS[form.project]['root'])

    def test_returns_404_error_if_form_does_not_exist(self):
        self.assertRaises(Http404, response_done, self.request, 'x', 'x')


class ProjectFormsListTests(TestCase):

    def setUp(self):
        self.project = settings.PROJECTS.keys()[0]
        self.url = reverse('project_forms', args=[self.project])
        self.request = RequestFactory().get(self.url)

    def test_lists_the_published_forms(self):
        form = mommy.make(Form, project=self.project,
                          slug='form-1', published=True)
        response = project_forms(self.request, form.project)
        self.assertContains(response, title(form.name))
        url = reverse('fill_out_form', args=[form.project, form.slug])
        form_link = 'href="%s"' % url
        self.assertContains(response, form_link)

    def test_returns_404_error_for_non_existent_project(self):
        self.assertRaises(Http404, project_forms, self.request, 'x')
