# Join a Stream and a Stream together

## Problem

You have two Kafka topics whose events share a common identifying attribute and correlate during some period of time. You want to join the topics together and create a new one based on that attribute, where the new events are enriched from the original topics.

## Example use case

This example takes two streams containing events for orders and shipments and joins these two streams to create a new, enriched one. The new stream will tell us which orders have been successfully shipped, how long it took for them to ship, and which warehouse they shipped from.

## Create streams

#### Orders stream

```sql
CREATE STREAM JSS_ORDERS (ROWKEY INT KEY, order_ts VARCHAR, total_amount DOUBLE, customer_name VARCHAR)
    WITH (kafka_topic='jss_orders',
          partitions=4,
          value_format='avro',
          TIMESTAMP='order_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');
```

#### Shipments stream

```sql
CREATE STREAM JSS_SHIPMENTS (ROWKEY VARCHAR KEY, shipment_id VARCHAR, ship_ts VARCHAR, order_id INT, warehouse VARCHAR)
    WITH (kafka_topic='jss_shipments',
          partitions=4,
          value_format='avro',
          TIMESTAMP='ship_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');
```

For joins to work correctly, the topics need to be `co-partitioned`:
- all topics have the same number of partitions
- all topics are keyed the same way

You can learn more about partitioning requirements in [the full doc](https://docs.ksqldb.io/en/latest/developer-guide/joins/partition-data/).

## Populate the streams with events

#### Orders

```sql
INSERT INTO jss_orders (rowkey, order_ts, total_amount, customer_name) VALUES (1, '2019-03-29T06:01:18Z', 133548.84, 'Ricardo Ferreira');
INSERT INTO jss_orders (rowkey, order_ts, total_amount, customer_name) VALUES (2, '2019-03-29T17:02:20Z', 164839.31, 'Tim Berglund');
INSERT INTO jss_orders (rowkey, order_ts, total_amount, customer_name) VALUES (3, '2019-03-29T13:44:10Z', 90427.66, 'Robin Moffatt');
INSERT INTO jss_orders (rowkey, order_ts, total_amount, customer_name) VALUES (4, '2019-03-29T11:58:25Z', 33462.11, 'Viktor Gamov');
```

#### Shipments

```sql
INSERT INTO jss_shipments (shipment_id, ship_ts, order_id, warehouse) VALUES ('ship-ch83360', '2019-03-31T18:13:39Z', 1, 'UPS');
INSERT INTO jss_shipments (shipment_id, ship_ts, order_id, warehouse) VALUES ('ship-xf72808', '2019-03-31T02:04:13Z', 2, 'UPS');
INSERT INTO jss_shipments (shipment_id, ship_ts, order_id, warehouse) VALUES ('ship-kr47454', '2019-03-31T20:47:09Z', 3, 'DHL');
```

## Compute the results from the beginning of the streams

```sql
SET 'auto.offset.reset' = 'earliest';
```

## Perform a transient query

The new stream will be enriched from the originals to contain more information about the orders that have shipped.

```sql
SELECT o.rowkey AS order_id,
       TIMESTAMPTOSTRING(o.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS order_ts,
       o.total_amount,
       o.customer_name,
       s.shipment_id,
       TIMESTAMPTOSTRING(s.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS shipment_ts,
       s.warehouse,
       (s.rowtime - o.rowtime) / 1000 / 60 AS ship_time
FROM jss_orders o INNER JOIN jss_shipments s
WITHIN 7 DAYS
ON o.rowkey = s.order_id
EMIT CHANGES
LIMIT 3;
```

- a window duration of seven days is specified to denote the amount of time joins will be allowed to occur within
- join time windows allow us to control for the amount of buffer space that is allowed
- join time windows are useful for modeling an SLA

## Perform a persistent query

```sql
CREATE STREAM jss_shipped_orders AS
    SELECT o.rowkey AS order_id,
           TIMESTAMPTOSTRING(o.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS order_ts,
           o.total_amount,
           o.customer_name,
           s.shipment_id,
           TIMESTAMPTOSTRING(s.rowtime, 'yyyy-MM-dd HH:mm:ss', 'UTC') AS shipment_ts,
           s.warehouse,
           (s.rowtime - o.rowtime) / 1000 / 60 AS ship_time
    FROM jss_orders o INNER JOIN jss_shipments s
    WITHIN 7 DAYS
    ON o.rowkey = s.order_id;
```

## Inspect the resulting stream's underlying topic

```sql
PRINT JSS_SHIPPED_ORDERS FROM BEGINNING LIMIT 3;
```

## Statements in a file

The statements that create the streams can be written to a file and used outside the CLI session.

Check how it is done in the `src/join-stream-and-stream/statements.sql` file.

## Resources

[Tutorial - join a stream and a stream](https://kafka-tutorials.confluent.io/join-a-stream-to-a-stream/ksql.html)
