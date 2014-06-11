from django.core.exceptions import ValidationError
from django.db import IntegrityError
from django.test import TestCase

from model_mommy import mommy

from django_site.apps.forms_api.models import Form


class FormTests(TestCase):

    def test_has_proper_fields(self):
        form = Form()
        field_names = form._meta.get_all_field_names()
        for field_name in ['number', 'version', 'name', 'description',
                           'project', 'slug', 'user', 'published',
                           'current', 'locked', 'created', 'modified']:
            self.assertIn(field_name, field_names)

    def test_ordered_by_number_then_version(self):
        mommy.make(Form, number=1, version=1)
        mommy.make(Form, number=2, version=2)
        mommy.make(Form, number=3, version=1)
        mommy.make(Form, number=2, version=1)
        numbers_and_versions = Form.objects.values_list('number', 'version')
        expected = [(1, 1), (2, 1), (2, 2), (3, 1)]
        self.assertEqual(list(numbers_and_versions), expected)

    def test_number_should_not_be_null(self):
        form = mommy.prepare(Form, number=None)
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_version_should_not_be_null(self):
        form = mommy.prepare(Form, version=None)
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_number_and_version_should_be_unique(self):
        mommy.make(Form, number=2, version=5)
        form = mommy.prepare(Form, number=2, version=5)
        self.assertRaises(IntegrityError, form.save)

    def test_name_should_not_be_null(self):
        form = mommy.prepare(Form, name=None)
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_name_should_not_be_blank(self):
        form = mommy.prepare(Form, name='')
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_description_can_be_null(self):
        form = mommy.prepare(Form, description=None)
        self.assertEqual(form.full_clean(exclude=['user']), None)

    def test_description_can_be_blank(self):
        form = mommy.prepare(Form, description='')
        self.assertEqual(form.full_clean(exclude=['user']), None)

    def test_project_should_not_be_null(self):
        form = mommy.prepare(Form, project=None)
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_project_should_not_be_blank(self):
        form = mommy.prepare(Form, project='')
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_project_should_be_valid_choice(self):
        form = mommy.prepare(Form, project='fake-project')
        self.assertRaises(ValidationError, form.full_clean, exclude=['user'])

    def test_slug_can_be_null(self):
        form = mommy.prepare(Form, slug=None)
        self.assertEqual(form.full_clean(exclude=['user']), None)

    def test_slug_can_be_blank(self):
        form = mommy.prepare(Form, slug='')
        self.assertEqual(form.full_clean(exclude=['user']), None)

    def test_slug_must_be_valid_slug(self):
        pass

    def test_user_should_not_be_null(self):
        self.assertRaises(ValueError, Form, user=None)

    def test_max_number_should_be_0_when_no_forms(self):
        self.assertEqual(Form.objects.max_number(), 0)

    def test_max_number_should_be_highest_form_number(self):
        mommy.make(Form, number=2)
        self.assertEqual(Form.objects.max_number(), 2)

    def test_max_version_should_be_0_when_no_form_with_number(self):
        mommy.make(Form, number=2)
        self.assertEqual(Form.objects.max_version(1), 0)

    def test_max_version_should_be_highest_form_version_for_number(self):
        mommy.make(Form, number=2, version=6)
        self.assertEqual(Form.objects.max_version(2), 6)
