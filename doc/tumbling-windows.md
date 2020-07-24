# Tumbling Windows

## Problem

You have time-series events in a Kafka topic, and you want to group them into fixed-size, non-overlapping, contiguous time intervals.

## Example use case

This example takes a stream of movie ratings events, and maintains tumbling windows counting the total number of ratings that each movie has received.

## Create a Stream

Create a Kafka topic and stream to represent ratings of movies.

```sql
CREATE STREAM movie_ratings (title VARCHAR KEY, release_year INT, rating DOUBLE, timestamp VARCHAR)
    WITH (kafka_topic='movie_ratings',
          timestamp='timestamp',
          timestamp_format='yyyy-MM-dd HH:mm:ss',
          partitions=1,
          value_format='avro');
```

## Populate the stream with events

```sql
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 8.2, '2019-07-09 01:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 4.5, '2019-07-09 05:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Die Hard', 1998, 5.1, '2019-07-09 07:00:00');

INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Tree of Life', 2011, 4.9, '2019-07-09 09:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Tree of Life', 2011, 5.6, '2019-07-09 08:00:00');

INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 3.6, '2019-07-09 12:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 6.0, '2019-07-09 15:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('A Walk in the Clouds', 1995, 4.6, '2019-07-09 22:00:00');

INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('The Big Lebowski', 1998, 9.9, '2019-07-09 05:00:00');
INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('The Big Lebowski', 1998, 4.2, '2019-07-09 02:00:00');

INSERT INTO movie_ratings (title, release_year, rating, timestamp) VALUES ('Super Mario Bros.', 1993, 3.5, '2019-07-09 18:00:00');
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Run the following transient query to figure out how many ratings were given to each movie in 6 hour tumbling intervals

```sql
SELECT title,
       COUNT(*) AS rating_count,
       WINDOWSTART AS window_start,
       WINDOWEND AS window_end
FROM movie_ratings
WINDOW TUMBLING (SIZE 6 HOURS)
GROUP BY title
EMIT CHANGES
LIMIT 11;
```

*window start/end as a number*

## Perform a persistent query

```sql
CREATE TABLE rating_count
    WITH (kafka_topic='rating_count') AS
    SELECT title, COUNT(*) AS rating_count, WINDOWSTART AS window_start, WINDOWEND AS window_end
    FROM movie_ratings
    WINDOW TUMBLING (SIZE 6 HOURS)
    GROUP BY title;
```

The aggregation results for each (6h-long) window can’t be stored forever as storage space is finite. The amount of time ksqlDB stores windowed results for is the retention time.

With ksqlDB >= 0.8.0, this retention time is configurable in the aggregation statement itself by specifying a retention clause, such as RETENTION 7 DAYS:

```sql
CREATE TABLE ...
    WINDOW TUMBLING (SIZE 6 HOURS, RETENTION 7 DAYS)
```

## Window start/end converted to a string

```sql
SELECT title,
       rating_count,
       TIMESTAMPTOSTRING(window_start, 'yyy-MM-dd HH:mm:ss', 'UTC') as window_start,
       TIMESTAMPTOSTRING(window_end, 'yyy-MM-dd HH:mm:ss', 'UTC') as window_end
FROM rating_count
EMIT CHANGES
LIMIT 11;
```

*window start/end as a string*

## Print the content of the underlying Kafka topic for the table

```sql
PRINT rating_count FROM BEGINNING LIMIT 11;
```

Notice that the key for each message contains some strange characters that aren’t quite printable:

```
rowtime: 2019/07/09 01:00:00.000 Z, key: [Die Hard@1562630400000/-], value: {"RATING_COUNT": 1, "WINDOW_START": 1562630400000, "WINDOW_END": 1562652000000}
```

ksqlDB has combined the grouping key (movie title) with its window boundaries using a format that’s not quite printable in this format.

## Statements in a file

The statements that create the stream and table can be written to a file and used outside the CLI session.

Check how it is done in the `src/tumbling-windows/statements.sql` file.

## Resources

[Tutorials - Create Tumbling Windows](https://kafka-tutorials.confluent.io/create-tumbling-windows/ksql.html)
