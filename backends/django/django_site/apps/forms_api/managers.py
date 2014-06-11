from django.db.models import Manager, Max


class FormManager(Manager):

    def max_number(self):
        data = self.get_queryset().aggregate(Max('number'))
        return data['number__max'] or 0

    def max_version(self, number):
        query = self.get_queryset().filter(number=number)
        data = query.aggregate(Max('version'))
        return data['version__max'] or 0
