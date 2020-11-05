USER_EVENT_SCHEMA = {
    "type": "object",
    "properties": {
        "operation": {
            "type": "string",
            "description": "create or update"
        },
        "name": {
            "type": "string",
            "description": "user name"
        },
        "uuid": {
            "type": "string",
            "description": "uuid of the user"
        },
        "firstname": {
            "type": "string"
        },
        "lastname": {
            "type": "string"
        },
        "country": {
            "type": "string",
            "description": "country the user is registered in"
        },
        "active": {
            "type": "boolean",
            "description": "is the user active in the system"
        },
    },
    "required": [
            "name",
            "uuid",
            "firstname",
            "lastname",
            "country",
            "active",
            "operation"
        ]
}

LESSON_EVENT_SCHEMA = {
    "type": "object",
    "properties": {
        "content_release_id": {
            "type": "string",
            "description": "content release version where this lesson was completed"
        },
        "title": {
            "type": "string",
            "description": "title of the lesson"
        },
        "language": {
            "type": "string",
            "description": "language of the lesson"
        },
        "course_uuid": {
            "type": "string",
            "description": "UUID of the course"
        },
        "course_title": {
            "type": "string",
            "description": "Title of the course"
        },
        "number_of_lessons_in_course": {
            "type": "integer",
            "description": "Number of lessons in course"
        },
        "completed_lessons_in_course": {
            "type": "integer",
            "description": "Number of completed lessons in course (including current one)"
        },
        "percentage_completed_in_course": {
            "type": "integer",
            "description": "Percentage of this course already completed by this user"
        },
        "user_uuid": {
            "type": "string",
            "description": "uuid of the user"
        }
    },
    "required": [
        "user_uuid",
        "percentage_completed_in_course",
        "completed_lessons_in_course",
        "number_of_lessons_in_course",
        "course_title",
        "course_uuid",
        "language",
        "title",
        "content_release_id"
    ]


}

SUBSCRIPTION_EVENTS_SCHEMA = {
    "properties": {
        "operation": {
            "type": "string",
            "description": "create or update"
        },
        "name": {
            "type": "string",
            "description": "subscription name"
        },
        "user_uuid": {
            "type": "string",
            "description": "uuid of the user"
        },
        "language": {
            "type": "string",
            "description": "language of the lesson"
        },
        "subscription_status": {
            "type": "string"
        },
        "subscription_type": {
            "type": "string"
        },
        "subscription_period": {
            "type": "integer",
            "description": "period of subscription in days"
        }
    },
    "required": [
        "subscription_period",
        "subscription_type",
        "subscription_status",
        "language",
        "user_uuid",
        "name",
        "operation"
    ]
}
