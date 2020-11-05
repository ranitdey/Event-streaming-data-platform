## ![](RackMultipart20201105-4-lyclah_html_5142fe91682defd7.png)

# **Requirement**

We need to design a system which will consume events from sa stream and enrich few events and pass everything to a 
output stream.Here are the expected throughput of the events:
- user events, with average throughput of 20 per second
- subscription events, 5 per second
- lesson events, 100 per second
The max spike on an event throughput is 5x of the average.
##### Detailed requirements:
- The system should store the current state of a user subscription in a database. 
- It needs to be able to store 500M+ rows at a time. This state information should be used to
enrich lesson events by adding subscription_status, subscription_type (from
subscription event) and country (from user event) attributes for all users. This subscription
data should match the language of the lesson. A user can be associated with multiple subscriptions,
each for a different language. A specific lesson can be associated with one language and one user
only.
##### Assumptions:
- Events are pushed to the stream in the correct order for a given user, for
example, a subscription event will never enter the stream before the user (create) event.

# Proposed Architecture Solution:

![Alt image](assets/ALPY22.png?raw=true)


# Event Schemas:
- Lesson 
```
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "lesson/schema.json",
  "description": "Emitted by the backend when a lesson has been completed by a user",
  "title": "lesson",
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
  }
}
```
- user
```
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/user/schema.json",
  "title": "user",
  "description": "Emitted by backend on user change",
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
    }
  }
}
```
- subscription 
```
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/subscription/schema.json",
  "title": "subscription",
  "description": "Emitted by backend on user subscription change",
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
  }
}
```
# Overview of the system:

- The events users, lessons and subscriptions initially come to one stream named input in AWS Kinesis.
- As and when these events come to Kinesis the Event Processor Lambda gets triggered. The Event Processor Lambda then reads records from Kinesis input stream and processes them one by one.
- Event Processor Lambda stores user events in a DynamoDB table named user with a partition key as uuid for later references. It also stores subscription events in the  user_subscription  table with partition key as  user_uuid  and sort key as  language .This is because we know that each user can have multiple subscriptions, and each of those subscriptions are identified by language.
- Then finally for lesson events it queries the user table with uuid and user_subscription table with user_uuid and language to get the data for enrichment and enriches the lesson event.
- Each event gets published to Kinesis output after successful processing.

![](RackMultipart20201105-4-lyclah_html_642f1f0f6bbfb4f1.png)

-
# Assumptions:

  - Events will come in proper order in the input stream.
  - There are no events with broken schema in the system.
  - Max spike of user event is 5x the current average throughput i.e 100/sec
  - Max spike of lesson event is 5x the current average throughput i.e 500/sec
  - Max spike of Subscription event is 5x the current average throughput i.e 25/sec

-
# Capacity Estimation:
- **Incoming traffic to input stream:**
  - On average the input stream will receive 20 user events/sec, 5 subscription events/sec and 100 lesson events/sec.So on average total incoming traffic will be (100+20+5) = **125 events/sec**
  - At max we will receive 5x of the average throughput as spike. Which means we should be able to handle **625 events/sec** throughput approximately.
- **Reads and writes on datastore:**
  - We will have one write request to db while processing one user event and one write request to db while processing one subscription event. On average we will get 20 user events and 5 subscription events per second. So our average db **write throughput** will be **25 writes/sec**. At max we will have 5x traffic which means we will experience **125 writes/sec write throughput.**
  - We will have two read requests to db while processing each lesson event.On average we have 100 events/sec for lesson events. So average db read throughput will be (2*100) = **200 reads/sec.** At max we will have 5x lesson events so our read traffic in db will grow upto **1000 reads/sec.**

-
# Design Choices:
- **DynamoDB as datastore:**
  - We can identify each of our events using unique ids for example  uuid  or  user_uuid  or using  user_uuid  and  language  together as a composite key. Which directs us towards dynamoDB as it is built for this type of use case and it can give read and writes in single digit milliseconds for large amounts of data (&gt; 500M+ rows) also.
  - By looking at the schema of the events we can estimate that all our events will be of size less than 1KB. Which makes this data model ideal for dynamo db as it is built to handle small item size ( limit of 400KB) efficiently.
  - Also as DynamoDB is schemaless we can add and remove keys in our event schema very easily.
  - DynamoDB is managed by aws so we will get the SLA of availability and it is very easy to autoscale it up and down in later point of time.
  - As our scale grows we can adjust consistency levels in dynamoDB. We can make it strongly consistent or we can also go for eventual consistency.
- **Kinesis as event stream:**
  - Kinesis is a reliable and highly scalable service which is designed to optimize data ingestion. We have calculated our max incoming event traffic will be 625 events/sec. This can be easily handled by kinesis with just one shard.
  - We can process events data in realtime with kinesis streams.
  - In future if we get a massive amount of incoming throughput we will be easily able to ingest those to our system using kinesis.
  - We can process the same data from multiple consumers using kinesis. So later on if we get a different consumer wanting to read from kinesis we can do it easily keeping in mind five consumers per shard limit in kinesis
- **Lambda as event consumer:**
  - We can go serverless with Lambda. AWS takes care of scaling and deploying the infra for lambda.Also it is cost effective. Lambda charges based on the number of requests and duration. So we will not be paying anything when events are not coming.
  - With Kinesis Lambda trigger lambda gets a batch of records from kinesis whenever they arrive. We can play with the batch size to get optimal latency in the system.
  - Also kinesis shards are concurrency units for lambda functions.So we can add more shards in kinesis to have more concurrent lambda instances to get faster event consumption.
  - Also we can play with the Lambda memory size in order to achieve optimal latency for event processing.
  - One of the benefits of using Kinesis lambda triggers is every record written in kinesis shard is guaranteed to end up in lambda function.

-
# Failover scenarios and strategies:

We can encounter multiple types of failures in this system. Let&#39;s talk about them one by one:

- **What happens when DynamoDB is not available?**
  - In this scenario we might lose events as our events will not get processed.
    - **Proposed Solution** : We can publish these events to another stream. So that we can process it later on or we can run analytics on it. We need to take care of staleness while processing these failed events.
- **What happens when a corrupted event comes to the input stream?**
  - Currently in the code if any event processing fails it catches exceptions and fails silently.Because if Lambda function returns error then the whole record batch starts processing again from the start. Which means if any corrupted event enters the stream and we do not have silent failures then it will be stuck in a loop and further records will not get processed.
    - **Proposed Solution:** If we encounter failures while processing due to a bad event we can put the event into a Dead Letter Queue and set a Cloudwatch alarm. So that we can run analysis later on.

-
# Way to scale up the system:

As we can see in our system is pretty much scalable and we can easily handle the max spike and average throughput. Let&#39;s discuss few more points while we scale this up:

- When producers produce events to input stream, we can set  uuid  for user event and  user_uuid  for lesson and subscription event as partition key.In this way we can easily add more shards to kinesis stream to scale it up while maintaining the required order. As when we partition in this way all events from one user ends up in one particular shard and gets consumed in order.
- While scaling kinesis we need to scale up DynamoDB reads and writes accordingly. So that event processing rate is greater than the event consumption rate. This will prevent building backpressure.
- We can easily and automatically scale our DynamoDB reads and writes in PROVISIONED mode with auto scaling groups.
- Adding a new Kinesis shard automatically can be a bottleneck. We can solve it using another lambda and cloudwatch alarm. We can trigger a cloudwatch alarm when our kinesis stream limits gets touched. Then from the cloudwatch alarm we can trigger one lambda which will call Kinesis API to update shard count asynchronously.
- In Event Consumer Lambda we can play around with the memory limit to increase the processing power while scaling the system up.

-
# Running the code:

  - Unzip the file.
  - Go to the root folder.
  - Run **make get-lambda-zip** in terminal. This will bundle the dependencies and the source code for lambda into a zip file and it will save it in the /output folder. (Docker is a prerequisite for this step)
  - From the root folder run **terraform init** to initialize modules.(Terraform is a prerequisite for this step)
  - From the root folder run **terraform plan** to check the resource creation plan.(Terraform is a prerequisite for this step)
  - From the root folder run **terraform apply** deploy the infrastructure to AWS. While running this command it will ask for AWS access key , ID and region for deployment.(Terraform is a prerequisite for this step)
  - Run **make run-lambda-tests** in terminal to run unit tests. (Docker is a prerequisite for this step)