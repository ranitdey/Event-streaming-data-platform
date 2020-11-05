from jsonschema import validate, ValidationError


def validate_schema(schema, event):
    try:
        validate(instance=event, schema=schema)
    except ValidationError:
        return False
    return True
