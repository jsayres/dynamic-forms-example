from django.contrib.auth.models import User
from django.contrib.sessions.middleware import SessionMiddleware
from django.core.urlresolvers import reverse
from django.test import TestCase
from django.test.client import RequestFactory

from django_site.libs.views import logout


class LogoutTests(TestCase):

    def setUp(self):
        self.url = reverse('logout')
        self.request = RequestFactory().get(self.url)
        SessionMiddleware().process_request(self.request)
        user = User.objects.create_user('test_user', 'email@none.com', 'pass')
        self.request.user = user

    def test_logs_out_user_and_redirects_with_303_status(self):
        response = logout(self.request)
        self.assertFalse(self.request.user.is_authenticated())
        self.assertEqual(response.url, reverse('main'))
        self.assertEqual(response.status_code, 303)

    def test_redirects_to_next_page_if_given(self):
        url = '/next/url'
        response = logout(self.request, next_page=url)
        self.assertEqual(response.url, url)
