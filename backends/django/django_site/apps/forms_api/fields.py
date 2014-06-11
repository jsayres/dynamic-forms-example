from django.db import models
from django.utils.six import with_metaclass
import json


class DictField(with_metaclass(models.SubfieldBase, models.TextField)):

    description = "A dict encoded as a json TextField"

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('default', lambda: {})
        super(DictField, self).__init__(*args, **kwargs)

    def get_prep_value(self, value):
        return json.dumps(value)

    def to_python(self, value):
        return value if isinstance(value, dict) else json.loads(value)
