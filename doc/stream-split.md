# Stream Split

## Problem

You have events in a single Kafka topic, and you want to split it so that the events are placed into subtopics.

## Example use case

This example takes a stream of appearances of an actor or actress in a film events, and splits it into substreams based on the genre.

## Create a Stream

Create a Kafka topic and stream to represent the actors.

```sql
CREATE STREAM actingevents (name VARCHAR, title VARCHAR, genre VARCHAR)
    WITH (KAFKA_TOPIC = 'acting-events', PARTITIONS = 1, VALUE_FORMAT = 'AVRO');
```

## Populate the Stream with Events

```sql
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Bill Murray', 'Ghostbusters', 'fantasy');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Christian Bale', 'The Dark Knight', 'crime');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Diane Keaton', 'The Godfather: Part II', 'crime');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Jennifer Aniston', 'Office Space', 'comedy');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Judy Garland', 'The Wizard of Oz', 'fantasy');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Keanu Reeves', 'The Matrix', 'fantasy');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Laura Dern', 'Jurassic Park', 'fantasy');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Matt Damon', 'The Martian', 'drama');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Meryl Streep', 'The Iron Lady', 'drama');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Russell Crowe', 'Gladiator', 'drama');
INSERT INTO ACTINGEVENTS (name, title, genre) VALUES ('Will Smith', 'Men in Black', 'comedy');
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Perform a transient query

#### find all of the drama films

```sql
SELECT NAME, TITLE FROM ACTINGEVENTS WHERE GENRE='drama' EMIT CHANGES LIMIT 3;
```

#### get a list of all films that aren’t drama or fantasy

```sql
SELECT NAME, TITLE FROM ACTINGEVENTS WHERE GENRE != 'drama' AND GENRE != 'fantasy' EMIT CHANGES LIMIT 4;
```

## Print the Stream’s Underlying Topic

```sql
PRINT 'acting-events' FROM BEGINNING LIMIT 4;
```

## Statements in a file

The statements that create the streams and substreams can be written to a file and used outside the CLI session.

Check how it is done in the `src/stream-split/statements.sql` file.

## Resources

[Tutorials - Split a Stream of Events into Substreams](https://kafka-tutorials.confluent.io/split-a-stream-of-events-into-substreams/ksql.html)
