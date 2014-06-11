from django.conf import settings
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.db import models

from django_site.apps.forms_api.fields import DictField
from django_site.apps.forms_api.managers import FormManager


class FormLockedError(Exception):
    pass


class Form(models.Model):
    class Meta:
        ordering = ['number', 'version']
        unique_together = ('number', 'version')

    PROJECT_CHOICES = map(lambda k: (k, settings.PROJECTS[k]['name']),
                          settings.PROJECTS)

    number = models.PositiveIntegerField()
    version = models.PositiveIntegerField()
    name = models.CharField(max_length=100)
    project = models.CharField(max_length=30, choices=PROJECT_CHOICES)
    description = models.TextField(blank=True)
    slug = models.CharField(max_length=100, blank=True)
    user = models.ForeignKey(User)
    current = models.BooleanField(default=False)
    published = models.BooleanField(default=False)
    locked = models.BooleanField(default=False)
    created = models.DateTimeField(auto_now_add=True)
    modified = models.DateTimeField(auto_now=True)

    objects = FormManager()


class FormField(models.Model):
    KIND_CHOICES = (
        ('info', 'Information Field'),
        ('short-answer', 'Short Answer Field'),
        ('long-answer', 'Long Answer Field'),
        ('single-choice', 'Single Choice Field'),
        ('multiple-choice', 'Multiple Choice Field'),
        ('address', 'Address Field'),
    )

    form = models.ForeignKey(Form)
    kind = models.CharField(max_length=20, choices=KIND_CHOICES)
    details = DictField(blank=True)


class FormResponse(models.Model):
    form = models.ForeignKey(Form)
    user = models.ForeignKey(User, blank=True, null=True)
    created = models.DateTimeField(auto_now_add=True)


class FormFieldResponse(models.Model):
    form_response = models.ForeignKey(FormResponse)
    form_field = models.ForeignKey(FormField)
    details = DictField(blank=True)

    def clean(self):
        validators = {
            'info': self.validate_info_response,
            'short-answer': self.validate_short_answer_response,
            'long-answer': self.validate_long_answer_response,
            'single-choice': self.validate_single_choice_response,
            'multiple-choice': self.validate_multiple_choice_response,
            'address': self.validate_address_response,
        }
        return validators[self.form_field.kind]()

    def validate_info_response(self):
        raise ValidationError({'info field': ['cannot have response']})

    def validate_short_answer_response(self):
        self._check_if_response_required_and_blank()

    def validate_long_answer_response(self):
        self._check_if_response_required_and_blank()

    def validate_single_choice_response(self):
        self._check_if_response_required_and_blank()
        choices = self.form_field.details.get('choices', [])
        choice_labels = map(lambda c: c['label'], choices)
        answer = self.details.get('answer', '')
        if answer is not '' and answer not in choice_labels:
            raise ValidationError({'answer': ['must be a valid choice']})

    def validate_multiple_choice_response(self):
        self._clean_multiple_choice_answers()
        required = self.form_field.details.get('required', False)
        answers = self.details['answers']
        selected_answers = [a for a in answers if a['selected']]
        errors = {}
        if required and len(selected_answers) is 0:
            errors['answer'] = ['is required']
        choices = self.form_field.details.get('choices', [])
        choice_labels = [c['label'] for c in choices]
        for i, answer_label in enumerate(map(lambda a: a['label'], answers)):
            if answer_label not in choice_labels:
                errors[answer_label] = ['is not a valid choice']
                del answers[i]
        if errors:
            raise ValidationError(errors)

    def validate_address_response(self):
        if self.form_field.details.get('required', False):
            errors = {}
            for address_field in ['addressLine1', 'city', 'state', 'zip']:
                if not self.details.get(address_field, ''):
                    errors[address_field] = ['cannot be blank']
            if errors:
                raise ValidationError(errors)

    def _check_if_response_required_and_blank(self):
        required = self.form_field.details.get('required', False)
        answer = self.details.get('answer', '')
        if required and answer == '':
            raise ValidationError({'answer': ['cannot be blank']})

    def _clean_multiple_choice_answers(self):
        answers = []
        for answer in self.details.get('answers', []):
            label = answer.get('label', '')
            selected = answer.get('selected') in ['1', 'true', 'True', True]
            answers.append({'label': label, 'selected': selected})
        answer_labels = map(lambda a: a['label'], answers)
        choices = self.form_field.details.get('choices', [])
        for choice in choices:
            if choice['label'] not in answer_labels:
                choice.update({'selected': False})
                answers.append(choice)
        self.details['answers'] = answers
