import json

from django.utils.unittest import TestCase

from django_site.apps.forms_api.fields import DictField


class DictFieldTests(TestCase):

    def test_get_internal_type(self):
        self.assertEqual(DictField().get_internal_type(), "TextField")

    def test_default_should_be_empty_dict(self):
        self.assertEqual(DictField().get_default(), {})

    def test_get_prep_value(self):
        field = DictField()
        data = {'answer': 42, 'question': 'see earth'}
        self.assertEqual(field.get_prep_value(data), json.dumps(data))

    def test_to_python(self):
        field = DictField()
        data = {'answer': 42, 'question': 'see earth'}
        data_json = json.dumps(data)
        self.assertEqual(field.to_python(data_json), data)
