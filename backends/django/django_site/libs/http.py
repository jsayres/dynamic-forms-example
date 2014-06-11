import json

from django.http import HttpResponse


class JSONResponse(HttpResponse):
    def __init__(self, data, status=200):
        super(JSONResponse, self).__init__(
            json.dumps(data), content_type='application/json', status=status
        )
