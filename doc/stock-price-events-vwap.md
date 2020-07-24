# Stock Price events & VWAP

## Problem

You have events in a Kafka topic, and you want to transform the values using a stateless scalar function not already provided by KSQL.

## Example use case

This example takes a topic of stock price events and calculates the volume-weighted average price (VWAP) for each event, publishing the result to a new topic.

There is no built-in function for VWAP, so we'll write a custom KSQL UDF that performs the calculation.

## Create the stock quote stream

```sql
CREATE STREAM raw_quotes(ticker varchar KEY, bid int, ask int, bidqty int, askqty int)
    WITH (kafka_topic='stockquotes', value_format='avro', partitions=1);
```

## Populate the stream with events

```sql
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 15, 25, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   25, 35, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 35, 45, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 45, 55, 100, 100);

INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 10, 20, 50, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   30, 40, 100, 50);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 30, 40, 50, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 50, 60, 100, 50);

INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 15, 20, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   25, 35, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 35, 45, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 45, 55, 100, 100);
```

## Compute the results from the beginning of the stream

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Run a transient query to compute the vwap values

```sql
SELECT ticker, vwap(bid, bidqty, ask, askqty) AS vwap FROM raw_quotes EMIT CHANGES LIMIT 12;
```

## Create a persistent query to the vwap values

```sql
CREATE STREAM vwap WITH (kafka_topic = 'vwap', partitions = 1) AS
    SELECT ticker,
           vwap(bid, bidqty, ask, askqty) AS vwap
    FROM raw_quotes
    EMIT CHANGES;
```

## Print the content of the vwap stream's underlying topic

```sql
PRINT vwap FROM BEGINNING LIMIT 12;
```

## Resources

[Tutorials - How to build a UDF to transform events](https://kafka-tutorials.confluent.io/udf/ksql.html)
