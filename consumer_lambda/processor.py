from db_writer import put, get
import os
from publisher import publish_to_stream


def process_subscription(event):
    if "user_uuid" and "language" in event:
        put(event, os.environ["subscription_table_name"])
        publish_to_stream(os.environ["output_stream_name"], os.environ["region"], event, "user_uuid")
    else:
        print("user uuid and language is required for processing subscription event")


def process_user(event):
    if "uuid" in event:
        put(event, os.environ["user_table_name"])
        publish_to_stream(os.environ["output_stream_name"], os.environ["region"], event, "uuid")
    else:
        print("user uuid is required for processing user event")


def process_lesson(event):
    enriched_lesson = lesson_enricher(event)
    if enriched_lesson:
        publish_to_stream(os.environ["output_stream_name"], os.environ["region"], enriched_lesson, "user_uuid")
    else:
        print("Bad event payload encountered")


def lesson_enricher(event):
    if "user_uuid" and "language" in event:
        search_subscription_state_query = {"user_uuid": event["user_uuid"], "language": event["language"]}
        search_user_query = {"uuid": event["user_uuid"]}
        user = get(search_user_query, os.environ["user_table_name"])
        subscription_state = get(search_subscription_state_query, os.environ["subscription_table_name"])
        if user and subscription_state:
            event["subscription_status"] = subscription_state["subscription_status"]
            event["subscription_type"] = subscription_state["subscription_type"]
            event["country"] = user["country"]
            return event
        else:
            print("Enrichment process failed due to unavailable user or subscription state")
    else:
        print("user uuid and language is required to enrich lesson event")
