import os

from django_site.settings.common import *  # noqa


SECRET_KEY = '$u0dj_on(mdn&*xukru#e+#hl7+%&@tf&*$jhue$+k#67u59x*'

DEBUG = True
TEMPLATE_DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'django_site_dev',
    }
}

FRONTEND_DIR = os.environ.get(
    'FRONTEND_DIR',
    os.path.join(BASE_DIR, '..', '..', 'frontend', 'lineman-angular')
)
