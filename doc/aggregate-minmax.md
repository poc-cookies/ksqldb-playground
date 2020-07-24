# Aggregate min/max

## Problem

You have data in a Kafka topic and want to get the minimum or maximum value of a field.

## Example use case

This example takes a stream of movie annual sales events and calculates the maximum and minimum revenue of movies by year.

## Create the movie sales stream

```sql
CREATE STREAM MOVIE_SALES (title VARCHAR, release_year INT, total_sales INT)
    WITH (kafka_topic='movie-sales', partitions=1, value_format='avro');
```

## Populate the stream with events

```sql
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Avengers: Endgame', 2019, 856980506);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Captain Marvel', 2019, 426829839);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Toy Story 4', 2019, 401486230);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('The Lion King', 2019, 385082142);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Black Panther', 2018, 700059566);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Avengers: Infinity War', 2018, 678815482);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Deadpool 2', 2018, 324512774);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Beauty and the Beast', 2017, 517218368);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Wonder Woman', 2017, 412563408);
INSERT INTO MOVIE_SALES (title, release_year, total_sales) VALUES ('Star Wars Ep. VIII: The Last Jedi', 2017, 517218368);
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Buffer the aggregates as ksqlDB builds them (for test purposes only)

```sql
SET 'ksql.streams.cache.max.bytes.buffering' = '10000000';
```

## Run a transient query to compute the min and max

```sql
SELECT RELEASE_YEAR,
       MIN(TOTAL_SALES) AS MIN__TOTAL_SALES,
       MAX(TOTAL_SALES) AS MAX__TOTAL_SALES
FROM MOVIE_SALES
GROUP BY RELEASE_YEAR
EMIT CHANGES
LIMIT 2;
```

## Create a persistent query to compute the min and max

```sql
CREATE TABLE MOVIE_FIGURES_BY_YEAR AS
    SELECT RELEASE_YEAR,
           MIN(TOTAL_SALES) AS MIN__TOTAL_SALES,
           MAX(TOTAL_SALES) AS MAX__TOTAL_SALES
    FROM MOVIE_SALES
    GROUP BY RELEASE_YEAR
    EMIT CHANGES;
```

## Terminate a persistent query (in case you need to remove a table)

```sql
TERMINATE <query_id>;
```

- `query_id` can be obtained by running the `show queries` command

## Inspect the min and max table

```sql
PRINT MOVIE_FIGURES_BY_YEAR FROM BEGINNING LIMIT 2;
```

## Statements in a file

The statements that create the stream and table can be written to a file and used outside the CLI session.

Check how it is done in the `src/aggregate-minmax/statements.sql` file.

## Resources

[Tutorial - Find the min/max in a stream of events](https://kafka-tutorials.confluent.io/create-stateful-aggregation-minmax/ksql.html)
