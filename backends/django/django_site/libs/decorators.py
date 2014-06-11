from functools import wraps

from django.shortcuts import redirect
from django.core.urlresolvers import reverse

from django_site.libs.http import JSONResponse


def staff_or_admin_required(view):
    @wraps(view)
    def _wrapped_view(request, *args, **kwargs):
        is_api = request.path.startswith('/api')
        user = request.user
        if not user.is_authenticated():
            return (JSONResponse({'error': 'Login required'}, status=401)
                    if is_api else
                    redirect(reverse('login')))
        authorized = user.is_active and (user.is_staff or user.is_superuser)
        if not authorized:
            return (JSONResponse({'error': 'User not authorized'}, status=403)
                    if is_api else
                    redirect(reverse('login')))
        return view(request, *args, **kwargs)
    return _wrapped_view
