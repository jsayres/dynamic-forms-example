from django.utils.unittest import TestCase

from model_mommy import mommy

from django_site.apps.forms_api.models import FormResponse


class FormResponseTests(TestCase):

    def test_has_proper_fields(self):
        form_response = FormResponse()
        field_names = form_response._meta.get_all_field_names()
        for field_name in ['form', 'user']:
            self.assertIn(field_name, field_names)

    def test_form_should_not_be_null(self):
        self.assertRaises(ValueError, FormResponse, form=None)

    def test_user_can_be_null(self):
        form_response = FormResponse(user=None)
        self.assertEqual(form_response.user, None)

    def test_is_deleted_when_form_is_deleted(self):
        form_response = mommy.make(FormResponse)
        id = form_response.id
        form_response.form.delete()
        self.assertFalse(FormResponse.objects.filter(id=id).exists())
