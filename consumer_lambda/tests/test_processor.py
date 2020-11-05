from unittest import mock

from consumer_lambda.processor import lesson_enricher
from consumer_lambda.tests.test_data.events_mock_data import USER_AND_SUBSCRIPTION_FAT_MOCK_RESPONSE, LESSON_MOCK_EVENT

mock_db_get = "consumer_lambda.processor.get"
mock_db_put = "consumer_lambda.processor.put"
mock_publisher = "consumer_lambda.processor.publish_to_stream"


class TestProcessor:

    @staticmethod
    @mock.patch(mock_db_get, return_value=USER_AND_SUBSCRIPTION_FAT_MOCK_RESPONSE)
    def test_001_test_lesson_enricher_happy(mock_db_get_obj):
        response = lesson_enricher(LESSON_MOCK_EVENT)
        assert response["country"] == "in"
        assert response["subscription_type"] == "free_tier"
        assert response["subscription_status"] == "active"

    @staticmethod
    @mock.patch(mock_db_get, return_value=None)
    def test_002_test_lesson_enricher_with_invalid_user_and_subscription(mock_db_get_obj):
        response = lesson_enricher(LESSON_MOCK_EVENT)
        assert response is None

    @staticmethod
    @mock.patch(mock_db_get, return_value=None)
    def test_003_test_lesson_enricher_with_bad_event(mock_db_get_obj):
        response = lesson_enricher({"course_uuid": "4444"})
        assert response is None
