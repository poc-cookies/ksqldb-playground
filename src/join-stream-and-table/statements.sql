CREATE TABLE products (product_name VARCHAR PRIMARY KEY, cost DOUBLE)
    WITH (kafka_topic='products', partitions=1, value_format='avro');

CREATE STREAM orders (product_name VARCHAR)
    WITH (kafka_topic='orders', partitions=1, value_format='avro');

CREATE TABLE order_metrics AS
    SELECT p.product_name, COUNT(*) AS count, SUM(p.cost) AS revenue
    FROM orders o JOIN products p ON p.product_name = o.product_name
    GROUP BY p.product_name EMIT CHANGES;
