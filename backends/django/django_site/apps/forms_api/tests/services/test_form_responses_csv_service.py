import csv
from cStringIO import StringIO

from django.http import HttpResponse
from django.utils.unittest import TestCase

from model_mommy import mommy

from django_site.apps.forms_api.models import (Form, FormField, FormResponse,
                                               FormFieldResponse)
from django_site.apps.forms_api.services import form_responses_csv_service


class FormResponsesCsvServiceTests(TestCase):

    def test_create_csv_generates_csv_from_form_data(self):
        form = mommy.make(Form, number=1, version=1, name='Form 1')
        mommy.make(FormField, form=form, kind='info')
        field1 = mommy.make(FormField, form=form, kind='short-answer',
                            details={'question': 'What is the short answer?'})
        field2 = mommy.make(FormField, form=form, kind='long-answer',
                            details={'question': 'What is the long answer?'})
        field3 = mommy.make(FormField, form=form, kind='single-choice',
                            details={'question': 'Which answer is correct?',
                                     'choices': [{'label': 'A'},
                                                 {'label': 'B'},
                                                 {'label': 'C'}]})
        field4 = mommy.make(FormField, form=form, kind='multiple-choice',
                            details={'question': 'Which answers are correct?',
                                     'choices': [{'label': 'A'},
                                                 {'label': 'B'},
                                                 {'label': 'C'}]})
        field5 = mommy.make(FormField, form=form, kind='address',
                            details={'question': 'What is your address?'})
        response = mommy.make(FormResponse, form=form)
        mommy.make(FormFieldResponse, form_response=response,
                   form_field=field1, details={'answer': 'a'})
        mommy.make(FormFieldResponse, form_response=response,
                   form_field=field2, details={'answer': 'b'})
        mommy.make(FormFieldResponse, form_response=response,
                   form_field=field3, details={'answer': 'C'})
        mommy.make(
            FormFieldResponse, form_response=response, form_field=field4,
            details={'answers': [{'label': 'A', 'selected': False},
                                 {'label': 'B', 'selected': True},
                                 {'label': 'C', 'selected': True}]}
        )
        mommy.make(
            FormFieldResponse, form_response=response, form_field=field5,
            details={'addressLine1': 'line1', 'addressLine2': 'line2',
                     'city': 'c', 'state': 's', 'zip': 'z'}
        )
        out = HttpResponse(content_type='text/csv')
        form_responses_csv_service.create_csv(form, out)
        rows = list(csv.reader(StringIO(out.content)))
        self.assertEqual(len(rows), 2)
        self.assertEqual(len(rows[0]), 7)
        self.assertEqual(len(rows[1]), 7)
        self.assertIn('---', rows[1][0])
        self.assertIn(str(response.created.year), rows[1][1])
        self.assertIn('a', rows[1][2])
        self.assertIn('b', rows[1][3])
        self.assertIn('C', rows[1][4])
        self.assertIn('B', rows[1][5])
        self.assertNotIn('A', rows[1][5])
        self.assertIn('B', rows[1][5])
        self.assertIn('line1', rows[1][6])
