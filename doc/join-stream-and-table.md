# Join Stream and Table

## Problem

You have events in a Kafka topic and a table of reference data. You want to join each event in the stream to a piece of data in the table based on a common key.

## Example use case

This example creates a table that aggregates rows from the orders stream, while also joining the stream on the products table to enrich the orders data.

## Statements in a file

The statements that create the `products` and `orders` streams and the `order_metrics` table can be written to a file and used outside the CLI session.

Check how it is done in the `src/join-stream-and-table/statements.sql` file.

## Resources

[Tutorial - Join a Stream to a Table](https://kafka-tutorials.confluent.io/join-a-stream-to-a-table/ksql.html)
