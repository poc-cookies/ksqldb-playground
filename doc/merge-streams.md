# Merge Streams

## Problem

You have many Kafka topics with events in them, and you want to merge them all into a single topic.

## Example use case

This example merges all of the song play events coming from a set of Kafka topics into a single topic.

## Create Streams

A stream for rock songs:

```sql
CREATE STREAM rock_songs (artist VARCHAR, title VARCHAR)
    WITH (kafka_topic='rock_songs', partitions=1, value_format='avro');
```

A stream for classical songs:

```sql
CREATE STREAM classical_songs (artist VARCHAR, title VARCHAR)
    WITH (kafka_topic='classical_songs', partitions=1, value_format='avro');
```

A stream for all songs:

```sql
CREATE STREAM all_songs (artist VARCHAR, title VARCHAR, genre VARCHAR)
    WITH (kafka_topic='all_songs', partitions=1, value_format='avro');
```

## Populate the streams with Events

Rock songs:

```sql
INSERT INTO rock_songs (artist, title) VALUES ('Metallica', 'Fade to Black');
INSERT INTO rock_songs (artist, title) VALUES ('Smashing Pumpkins', 'Today');
INSERT INTO rock_songs (artist, title) VALUES ('Pink Floyd', 'Another Brick in the Wall');
INSERT INTO rock_songs (artist, title) VALUES ('Van Halen', 'Jump');
INSERT INTO rock_songs (artist, title) VALUES ('Led Zeppelin', 'Kashmir');
```

Classical music:

```sql
INSERT INTO classical_songs (artist, title) VALUES ('Wolfgang Amadeus Mozart', 'The Magic Flute');
INSERT INTO classical_songs (artist, title) VALUES ('Johann Pachelbel', 'Canon');
INSERT INTO classical_songs (artist, title) VALUES ('Ludwig van Beethoven', 'Symphony No. 5');
INSERT INTO classical_songs (artist, title) VALUES ('Edward Elgar', 'Pomp and Circumstance');
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Merge the streams

```sql
INSERT INTO all_songs SELECT artist, title, 'rock' AS genre FROM rock_songs;
INSERT INTO all_songs SELECT artist, title, 'classical' AS genre FROM classical_songs;
```

## Describe the stream that contains all the songs

```sql
DESCRIBE EXTENDED ALL_SONGS;
```

## Print the content of the all songs stream's underlying topic

```sql
SELECT artist, title, genre FROM all_songs EMIT CHANGES LIMIT 9;
```

## Statements in a file

The statements that create the streams can be written to a file and used outside the CLI session.

Check how it is done in the `src/merge-streams/statements.sql` file.

## Resources

[Tutorials - Merge many streams into one stream](https://kafka-tutorials.confluent.io/merge-many-streams-into-one-stream/ksql.html)
