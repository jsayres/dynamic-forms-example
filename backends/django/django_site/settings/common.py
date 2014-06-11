import os
BASE_DIR = os.path.join(os.path.dirname(__file__), '..', '..')

ALLOWED_HOSTS = []

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_site.apps.forms_api',
    'django_site.apps.form_responses',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django_site.apps.forms_api.middleware.AngularCsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'django_site.urls'
APPEND_TRAILING_SLASH = False

WSGI_APPLICATION = 'django_site.wsgi.application'

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

CSRF_COOKIE_NAME = 'XSRF-TOKEN'

STATIC_URL = '/assets/'
STATIC_ROOT = os.path.join(BASE_DIR, 'public', 'static')
STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'django_site', 'static'),
)

TEMPLATE_DIRS = (
    os.path.join(BASE_DIR, 'django_site', 'templates'),
)

PROJECTS = {
    'main': {
        'name': 'Main Site',
        'layout': 'main.html',
        'root': '/',
    },
    'subproject': {
        'name': 'Sub Project',
        'layout': 'subproject.html',
        'root': '/subproject'
    },
}
