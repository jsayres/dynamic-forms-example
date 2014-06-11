from django.conf import settings
from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from django_site.apps.forms_api.models import (
    Form, FormField, FormResponse, FormFieldResponse
)


class Command(BaseCommand):
    help = """
        Clear out all forms and responses and
        create a sample form with all fields
    """

    def handle(self, *args, **options):
        Form.objects.all().delete()
        FormField.objects.all().delete()
        FormResponse.objects.all().delete()
        FormFieldResponse.objects.all().delete()

        User.objects.all().delete()
        user = User.objects.create_user('user1', 'x@none.com', 'password123')
        user.is_staff = True
        user.save()
        form = Form.objects.create(number=1, version=1, name='Sample Form',
                                   project=settings.PROJECTS.keys()[0],
                                   user=user, current=True)
        FormField.objects.create(
            form=form,
            kind='info',
            details={'text': 'This is a sample form.'}
        )
        FormField.objects.create(
            form=form,
            kind='short-answer',
            details={'question': 'What is the answer?', 'required': True}
        )
        FormField.objects.create(
            form=form,
            kind='long-answer',
            details={'question': 'Provide some details.', 'required': True}
        )
        FormField.objects.create(
            form=form,
            kind='single-choice',
            details={
                'question': 'Pick an answer.',
                'choices': [{'label': 'A'}, {'label': 'B'}, {'label': 'C'}],
                'required': True
            }
        )
        FormField.objects.create(
            form=form,
            kind='multiple-choice',
            details={
                'question': 'Select one or more answers.',
                'choices': [{'label': 'A'}, {'label': 'B'}, {'label': 'C'}],
                'required': True
            }
        )
        FormField.objects.create(
            form=form,
            kind='address',
            details={'question': 'Enter your address.', 'required': True}
        )
