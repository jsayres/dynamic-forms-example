from django.core.exceptions import ValidationError
from django.utils.unittest import TestCase

from model_mommy import mommy
from model_mommy.recipe import Recipe

from django_site.apps.forms_api.models import FormFieldResponse


class FormFieldResponseTests(TestCase):

    def test_has_proper_fields(self):
        form_field_response = FormFieldResponse()
        field_names = form_field_response._meta.get_all_field_names()
        for field_name in ['form_response', 'form_field', 'details']:
            self.assertIn(field_name, field_names)

    def test_form_response_should_not_be_null(self):
        self.assertRaises(ValueError, FormFieldResponse, form_response=None)

    def test_form_field_should_not_be_null(self):
        self.assertRaises(ValueError, FormFieldResponse, form_field=None)

    def test_details_should_be_a_dict(self):
        form_field_response = FormFieldResponse()
        self.assertTrue(isinstance(form_field_response.details, dict))

    def test_details_cannot_be_null(self):
        self.assertRaises(TypeError, FormFieldResponse, details=None)

    def test_details_cannot_be_a_string(self):
        self.assertRaises(ValueError, FormFieldResponse, details='')

    def test_is_deleted_when_form_response_is_deleted(self):
        form_field_response = mommy.make(FormFieldResponse)
        id = form_field_response.id
        self.assertTrue(FormFieldResponse.objects.filter(id=id).exists())
        form_field_response.form_field.delete()
        self.assertFalse(FormFieldResponse.objects.filter(id=id).exists())

    def test_is_deleted_when_form_field_is_deleted(self):
        form_field_response = mommy.make(FormFieldResponse)
        id = form_field_response.id
        form_field_response.form_field.delete()
        self.assertFalse(FormFieldResponse.objects.filter(id=id).exists())


class InfoResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(FormFieldResponse, form_field__kind='info')

    def test_should_never_pass(self):
        for details in [{}, {'answer': 'no good'}]:
            field_response = self.recipe.prepare(details=details)
            self.assertRaises(ValidationError, field_response.clean)


class ShortAnswerResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(
            FormFieldResponse,
            form_field__kind='short-answer',
            form_field__details={'required': True}
        )

    def test_should_pass_when_required_and_answer_not_blank(self):
        field_response = self.recipe.prepare(details={'answer': 'ok'})
        self.assertEqual(field_response.clean(), None)

    def test_should_not_pass_when_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_pass_when_not_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)

    def test_should_pass_when_not_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)


class LongAnswerResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(
            FormFieldResponse,
            form_field__kind='long-answer',
            form_field__details={'required': True}
        )

    def test_should_pass_when_required_and_answer_not_blank(self):
        field_response = self.recipe.prepare(details={'answer': 'ok'})
        self.assertEqual(field_response.clean(), None)

    def test_should_not_pass_when_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_pass_when_not_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)

    def test_should_pass_when_not_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)


class SingleChoiceResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(
            FormFieldResponse,
            form_field__kind='single-choice',
            form_field__details={
                'choices': [{'label': 'A'}, {'label': 'B'}, {'label': 'C'}],
                'required': True
            }
        )

    def test_should_pass_when_required_and_answer_valid_choice(self):
        field_response = self.recipe.prepare(details={'answer': 'B'})
        self.assertEqual(field_response.clean(), None)

    def test_should_not_pass_when_required_and_answer_non_choice(self):
        field_response = self.recipe.prepare(details={'answer': 'X'})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_not_required_and_answer_non_choice(self):
        field_response = self.recipe.prepare(details={'answer': 'X'})
        field_response.form_field.details['required'] = False
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_pass_when_not_required_and_answer_not_provided(self):
        field_response = self.recipe.prepare(details={})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)

    def test_should_pass_when_not_required_and_answer_blank(self):
        field_response = self.recipe.prepare(details={'answer': ''})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)


class MultipleChoiceResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(
            FormFieldResponse,
            form_field__kind='multiple-choice',
            form_field__details={
                'choices': [{'label': 'A'}, {'label': 'B'}, {'label': 'C'}],
                'required': True
            }
        )

    def test_should_set_left_out_answers_to_false(self):
        field_response = self.recipe.prepare(
            details={'answers': [{'label': 'B', 'selected': True}]}
        )
        field_response.clean()
        self.assertItemsEqual(field_response.details, {'answers': [
            {'label': 'A', 'selected': False},
            {'label': 'B', 'selected': True},
            {'label': 'C', 'selected': False},
        ]})

    def test_should_pass_when_required_and_at_least_one_answer_selected(self):
        field_response = self.recipe.prepare(
            details={'answers': [
                {'label': 'A', 'selected': True},
                {'label': 'B', 'selected': False},
                {'label': 'C', 'selected': False},
            ]}
        )
        self.assertEqual(field_response.clean(), None)

    def test_should_not_pass_when_required_and_any_answer_non_choice(self):
        field_response = self.recipe.prepare(
            details={'answers': [
                {'label': 'A', 'selected': True},
                {'label': 'X', 'selected': False},
                {'label': 'C', 'selected': False},
            ]}
        )
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_no_answers_provided(self):
        field_response = self.recipe.prepare(details={})
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_required_and_all_answers_false(self):
        field_response = self.recipe.prepare(
            details={'answers': [
                {'label': 'A', 'selected': False},
                {'label': 'B', 'selected': False},
                {'label': 'C', 'selected': False},
            ]}
        )
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_not_pass_when_not_required_and_any_answer_non_choice(self):
        field_response = self.recipe.prepare(
            details={'answers': [
                {'label': 'A', 'selected': True},
                {'label': 'X', 'selected': False},
                {'label': 'C', 'selected': False},
            ]}
        )
        field_response.form_field.details['required'] = False
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_pass_when_not_required_and_no_answers_provided(self):
        field_response = self.recipe.prepare(details={})
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)

    def test_should_pass_when_not_required_and_all_answers_false(self):
        field_response = self.recipe.prepare(
            details={'answers': [
                {'label': 'A', 'selected': False},
                {'label': 'B', 'selected': False},
                {'label': 'C', 'selected': False},
            ]}
        )
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)


class AddressResponseTests(TestCase):

    def setUp(self):
        self.recipe = Recipe(
            FormFieldResponse,
            form_field__kind='address',
            form_field__details={'required': True}
        )

    def test_should_pass_when_required_and_only_addr2_blank(self):
        field_response = self.recipe.prepare(details={
            'addressLine1': 'x', 'city': 'x', 'state': 'x', 'zip': 'x'
        })
        self.assertEqual(field_response.clean(), None)

    def test_should_not_pass_when_required_and_any_field_but_addr2_blank(self):
        field_response = self.recipe.prepare(details={
            'addressLine1': '', 'city': 'x', 'state': 'x', 'zip': 'x'
        })
        self.assertRaises(ValidationError, field_response.clean)

    def test_should_pass_when_not_required_and_all_fields_blank(self):
        field_response = self.recipe.prepare()
        field_response.form_field.details['required'] = False
        self.assertEqual(field_response.clean(), None)
