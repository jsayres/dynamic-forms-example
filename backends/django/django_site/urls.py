from django.conf.urls import patterns, include, url
from django.views.generic.base import TemplateView

from django_site.libs.decorators import staff_or_admin_required


urlpatterns = patterns(
    '',
    url(r'^$',
        TemplateView.as_view(template_name='pages/main.html'),
        name='main'),
    url(r'^subproject/?$',
        TemplateView.as_view(template_name='pages/subproject.html'),
        name='subproject'),
    url(r'^admin',
        staff_or_admin_required(
            TemplateView.as_view(template_name='admin/admin.html')
        ),
        name='admin'),
    url(r'^login/?$',
        'django.contrib.auth.views.login',
        {'template_name': 'auth/login.html'},
        name='login'),
    url(r'^logout/?$',
        'django_site.libs.views.logout',
        name='logout'),
    url(r'^api/', include('django_site.apps.forms_api.urls')),
    url(r'^forms/', include('django_site.apps.form_responses.urls')),
)
