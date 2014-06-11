from django.conf.urls import patterns, url

from django_site.apps.form_responses.views import (
    fill_out_form, response_done, project_forms
)


urlpatterns = patterns(
    '',
    url(r'^([\w-]+?)/?$', project_forms, name='project_forms'),
    url(r'^([\w-]+?)/([\w-]+?)/?$', fill_out_form, name='fill_out_form'),
    url(r'^([\w-]+?)/([\w-]+?)/done/?$', response_done, name='response_done'),
)
