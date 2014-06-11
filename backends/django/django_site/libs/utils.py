def model_to_dict(model, *exclude, **update):
    field_names = [f.name for f in model._meta.fields if f.name not in exclude]
    data = {name: getattr(model, name) for name in field_names}
    for key, value in update.items():
        data[key] = value(model) if hasattr(value, '__call__') else value
    return data
