from django.contrib.auth import logout as auth_logout
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect


def logout(request, next_page=None):
    if next_page is None:
        next_page = reverse('main')
    auth_logout(request)
    return HttpResponseRedirect(next_page, status=303)
