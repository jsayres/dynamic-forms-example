from django.core.exceptions import ValidationError
from django.utils.unittest import TestCase

from model_mommy import mommy

from django_site.apps.forms_api.models import FormField


class FormFieldTests(TestCase):

    def test_has_proper_fields(self):
        form_field = FormField()
        field_names = form_field._meta.get_all_field_names()
        for field_name in ['form', 'kind', 'details']:
            self.assertIn(field_name, field_names)

    def test_form_should_not_be_null(self):
        self.assertRaises(ValueError, FormField, form=None)

    def test_kind_should_not_be_null(self):
        form_field = FormField(kind=None)
        self.assertRaises(ValidationError, form_field.full_clean)

    def test_kind_should_not_be_blank(self):
        form_field = FormField(kind='')
        self.assertRaises(ValidationError, form_field.full_clean)

    def test_kind_should_be_valid_choice(self):
        form_field = FormField(kind='fake-kind')
        self.assertRaises(ValidationError, form_field.full_clean)

    def test_details_should_be_a_dict(self):
        form_field = FormField()
        self.assertTrue(isinstance(form_field.details, dict))

    def test_details_cannot_be_null(self):
        self.assertRaises(TypeError, FormField, details=None)

    def test_details_cannot_be_a_string(self):
        self.assertRaises(ValueError, FormField, details='')

    def test_details_can_be_an_empty_dict(self):
        form_field = FormField(details={})
        self.assertRaises(ValidationError, form_field.full_clean)

    def test_is_deleted_when_form_is_deleted(self):
        form_field = mommy.make(FormField)
        id = form_field.id
        form_field.form.delete()
        self.assertFalse(FormField.objects.filter(id=id).exists())
