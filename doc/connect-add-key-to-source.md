# Add key to data ingested through Kafka Connect

## Problem

You have data in a source system (such as a database) that you want to stream into Kafka using Kafka Connect. You want to add a key to the data as part of the ingest.

## Example use case

This example streams the data about cities from a database into Kafka and keys the resulting Kafka messages by the `city_id` field.

## Create data

Create a file `cities.sql` with commands to pre-populate the database table with city information:

```sql
DROP TABLE IF EXISTS cities;
CREATE TABLE cities (city_id INTEGER PRIMARY KEY NOT NULL, name VARCHAR(255), state VARCHAR(255));
INSERT INTO cities (city_id, name, state) VALUES (1, 'Raleigh', 'NC');
INSERT INTO cities (city_id, name, state) VALUES (2, 'Mountain View', 'CA');
INSERT INTO cities (city_id, name, state) VALUES (3, 'Knoxville', 'TN');
INSERT INTO cities (city_id, name, state) VALUES (4, 'Houston', 'TX');
INSERT INTO cities (city_id, name, state) VALUES (5, 'Olympia', 'WA');
INSERT INTO cities (city_id, name, state) VALUES (6, 'Bismarck', 'ND');
```

## Check the source data

Run the following command to check the data in the source database after the `postgres` container has started:

```shell
echo 'SELECT * FROM cities;' | docker exec -i postgres bash -c 'psql -U $POSTGRES_USER $POSTGRES_DB'
```

## Create the Connector

Execute the following script from the ksqlDB prompt to create the JDBC source connector:

```sql
CREATE SOURCE CONNECTOR JDBC_SOURCE_POSTGRES_01 WITH (
    'connector.class'= 'io.confluent.connect.jdbc.JdbcSourceConnector',
    'connection.url'= 'jdbc:postgresql://postgres:5432/postgres',
    'connection.user'= 'postgres',
    'connection.password'= 'postgres',
    'mode'= 'incrementing',
    'incrementing.column.name'= 'city_id',
    'topic.prefix'= 'postgres_',
    'transforms'= 'copyFieldToKey,extractValuefromStruct',
    'transforms.copyFieldToKey.type'= 'org.apache.kafka.connect.transforms.ValueToKey',
    'transforms.copyFieldToKey.fields'= 'city_id',
    'transforms.extractValuefromStruct.type'= 'org.apache.kafka.connect.transforms.ExtractField$Key',
    'transforms.extractValuefromStruct.field'= 'city_id',
    'key.converter' = 'org.apache.kafka.connect.converters.IntegerConverter'
);
```

## Check that the connector is running:

#### List connectors

```sql
SHOW CONNECTORS;
```

#### Inspect connector details

```sql
DESCRIBE CONNECTOR JDBC_SOURCE_POSTGRES_01;
```

## Consume events from the output topic

```sql
PRINT postgres_cities FROM BEGINNING LIMIT 6;
```

## Declare the topic as a ksqlDB table

```sql
CREATE TABLE CITIES (ROWKEY INT PRIMARY KEY) WITH (KAFKA_TOPIC='postgres_cities', VALUE_FORMAT='AVRO');
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Perform a transient query

```sql
SELECT ROWKEY AS CITY_ID, NAME, STATE FROM CITIES EMIT CHANGES LIMIT 6;
```

## Resources

[Tutorials - Add key to data ingested through Kafka Connect](https://kafka-tutorials.confluent.io/connect-add-key-to-source/ksql.html)

[Getting Started with Kafka Connect](https://docs.confluent.io/current/connect/userguide.html)
