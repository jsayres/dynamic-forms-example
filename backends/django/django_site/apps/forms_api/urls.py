from django.conf.urls import patterns, url

from django_site.apps.forms_api.views import (
    projects_list, current_forms, form_versions, form_version, publish_form,
    unpublish_form, form_with_responses, form_with_responses_csv
)


urlpatterns = patterns(
    '',
    url(r'^projects/?$',
        projects_list, name='api-projects_list'),
    url(r'^forms/?$',
        current_forms, name='api-current_forms'),
    url(r'^forms/(\d+)/versions/?$',
        form_versions, name='api-form_versions'),
    url(r'^forms/(\d+)/versions/(\d+)/?$',
        form_version, name='api-form_version'),
    url(r'^forms/(\d+)/versions/(\d+)/publish/?$',
        publish_form, name='api-publish_form'),
    url(r'^forms/(\d+)/versions/(\d+)/unpublish/?$',
        unpublish_form, name='api-unpublish_form'),
    url(r'^forms/(\d+)/versions/(\d+)/responses/?$',
        form_with_responses, name='api-form_with_responses'),
    url(r'^forms/(\d+)/versions/(\d+)/responses.csv/?$',
        form_with_responses_csv, name='api-form_with_responses_csv'),
)
