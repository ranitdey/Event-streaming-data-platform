import json
from unittest import mock

from consumer_lambda.lambda_handler import consume_event
from consumer_lambda.tests.test_data.kinesis_mock_data import KINESIS_RECORDS


mock_route = "consumer_lambda.lambda_handler.route_event"


class TestLambdaHandler:
    @staticmethod
    @mock.patch(mock_route)
    def test_001_happy_scenario_lambda_handler(mock_route_obj):
        mock_route_obj.return_value = None
        response = consume_event(KINESIS_RECORDS, {})
        assert response["statusCode"] == 200
        assert json.loads(response["body"]) == "Event consumed"
