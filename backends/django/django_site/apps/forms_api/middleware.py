from django.middleware.csrf import CsrfViewMiddleware


class AngularCsrfViewMiddleware(CsrfViewMiddleware):

    def process_view(self, request, callback, callback_args, callback_kwargs):
        csrf_header = request.META.get('HTTP_X_XSRF_TOKEN')
        if csrf_header:
            request.META['HTTP_X_CSRFTOKEN'] = csrf_header
        super(AngularCsrfViewMiddleware, self).process_view(
            request, callback, callback_args, callback_kwargs
        )
