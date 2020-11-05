from schemas import USER_EVENT_SCHEMA, LESSON_EVENT_SCHEMA, SUBSCRIPTION_EVENTS_SCHEMA
from processor import process_subscription, process_user, process_lesson
from validator import validate_schema


def route_event(event):
    event_to_schema = {
        "user": USER_EVENT_SCHEMA,
        "subscription": SUBSCRIPTION_EVENTS_SCHEMA,
        "lesson": LESSON_EVENT_SCHEMA
    }
    event_to_processor = {
        "user": process_user,
        "subscription": process_subscription,
        "lesson": process_lesson
    }
    for event_name, schema in event_to_schema.items():
        if validate_schema(schema, event):
            event_to_processor.get(event_name)(event)
            break
        else:
            print("Given event is not of type {} event.Looking for other match".format(event_name))
