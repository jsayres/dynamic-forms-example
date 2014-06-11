from django import template
from django.utils.safestring import mark_safe

from markdown import markdown as md

register = template.Library()


@register.filter
def underscore(value):
    """Replaces dashes with underscores"""
    return value.replace('-', '_')


@register.filter
def markdown(value):
    """Renders the text as markdown"""
    return mark_safe(md(value))


@register.filter
def selected_labels(answers):
    """
    Expects a list of dicts: [{'label': <string>, 'selected': True|False}]
    and returns a list of labels from the dicts that had selected as True.
    """
    is_selected = lambda answer: answer.get('selected')
    get_label = lambda answer: answer.get('label', '')
    return map(get_label, filter(is_selected, answers))
