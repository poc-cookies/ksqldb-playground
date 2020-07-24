# Local Kafka

Some ksqlDB examples to demonstrate real use cases.

## Prerequisites

1. Docker
2. A running multi-container Docker application (defined in the `./docker-compose.yml` file)

## Launch

```shell
docker-compose up -d
```

## Fire up the ksqlDB CLI

```shell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

## Inspect topics / streams / tables / functions

#### List topics/streams/tables

```sql
show {topics|streams|tables|functions};
```

#### See some additional info about a function

```sql
DESCRIBE FUNCTION ABS;
```

## Tests

`ksql-test-runner` expects the following files as input:

- a JSON file describing the desired input data
- a JSON file containing the intended output results
- a file of ksqlDB queries to run

Run the following command to test your ksql statements:

```shell
docker exec ksqldb-cli ksql-test-runner \
  -i /opt/app/test/${input} \
  -o /opt/app/test/${output} \
  -s /opt/app/src/${statements}
```

*The testing tool processes input messages for each query one-by-one and writes the generated message(s) for each input message into the result topic (every possible intermediate result is created).*

## Take it to production

Launch your statements into production by sending them to the ksqlDB server REST endpoint with the following command:

```shell
./deploy.sh
```

## /ksql and /query API endpoints

The `/ksql` resource runs a sequence of SQL statements. All statements, except those starting with SELECT, can be run on this endpoint. To run SELECT statements use the /query endpoint.

```shell
curl -X "POST" "http://localhost:8088/ksql" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -d $'{
  "ksql": "LIST STREAMS;",
  "streamsProperties": {}
}'
```

The `/query` resource lets you stream the output records of a SELECT statement via a chunked transfer encoding. The response is streamed back until the LIMIT specified in the statement is reached, or the client closes the connection. If no LIMIT is specified in the statement, then the response is streamed until the client closes the connection.

```shell
curl -X "POST" "http://localhost:8088/query" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -d $'{
  "ksql": "select * from ${table_name} emit changes;",
  "streamsProperties": {}
}'
```

## Shut Down

```shell
docker-compose down
```

## Resources

[Kafka Tutorials](https://kafka-tutorials.confluent.io)

[Develop ksqlDB Applications](https://docs.ksqldb.io/en/latest/developer-guide/)

[Stream Processing Cookbook](https://www.confluent.io/stream-processing-cookbook)
