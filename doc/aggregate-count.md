# Aggregate Count

## Problem

You have data in a Kafka topic and want to count the number of events based on some criteria.

## Example use case

This example takes a stream of individual movie ticket sales events and counts the total number of tickets sold per movie.

## Create a Stream

```sql
CREATE STREAM MOVIE_TICKET_SALES (title VARCHAR, sale_ts VARCHAR, ticket_total_value INT)
    WITH (KAFKA_TOPIC='movie-ticket-sales',
          PARTITIONS=1,
          VALUE_FORMAT='avro');
```

This line of ksqlDB DDL creates a stream and its underlying Kafka topic to represent the annual sales totals.

If the topic already exists, then ksqlDB simply registers it as the source of data underlying the new stream.

## Populate the stream with events

```sql
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('Aliens', '2019-07-18T10:00:00Z', 10);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('Die Hard', '2019-07-18T10:00:00Z', 12);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('Die Hard', '2019-07-18T10:01:00Z', 12);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Godfather', '2019-07-18T10:01:31Z', 12);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('Die Hard', '2019-07-18T10:01:36Z', 24);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Godfather', '2019-07-18T10:02:00Z', 18);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Big Lebowski', '2019-07-18T11:03:21Z', 12);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Big Lebowski', '2019-07-18T11:03:50Z', 12);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Godfather', '2019-07-18T11:40:00Z', 36);
INSERT INTO MOVIE_TICKET_SALES (title, sale_ts, ticket_total_value) VALUES ('The Godfather', '2019-07-18T11:40:09Z', 18);
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Buffer the aggregates as ksqlDB builds them (for test purposes only)

```sql
SET 'ksql.streams.cache.max.bytes.buffering' = '10000000';
```

## Perform a transient query

```sql
SELECT TITLE,
       COUNT(TICKET_TOTAL_VALUE) AS TICKETS_SOLD
FROM MOVIE_TICKET_SALES
GROUP BY TITLE
EMIT CHANGES
LIMIT 3;
```

After we stop a transient query, it is gone and will not keep processing the input stream.

## Perform a persistent query

```sql
CREATE TABLE MOVIE_TICKETS_SOLD AS
    SELECT TITLE,
           COUNT(TICKET_TOTAL_VALUE) AS TICKETS_SOLD
    FROM MOVIE_TICKET_SALES
    GROUP BY TITLE
    EMIT CHANGES;
```

## Inspect the output

```sql
PRINT MOVIE_TICKETS_SOLD FROM BEGINNING LIMIT 3;
```

```sql
SELECT * FROM MOVIE_TICKETS_SOLD EMIT CHANGES;
```

## Statements in a file

The statements that create the `MOVIE_TICKET_SALES` stream and the `MOVIE_TICKETS_SOLD` table can be written to a file and used outside the CLI session.

Check how it is done in the `src/aggregate-count/statements.sql` file.

## Resources

[Tutorial - Stateful Aggregation Count](https://kafka-tutorials.confluent.io/create-stateful-aggregation-count/ksql.html)
