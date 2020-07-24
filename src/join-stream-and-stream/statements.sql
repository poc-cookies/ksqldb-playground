CREATE STREAM JSS_ORDERS (ROWKEY INT KEY, order_ts VARCHAR, total_amount DOUBLE, customer_name VARCHAR)
    WITH (kafka_topic='jss_orders',
          partitions=4,
          value_format='avro',
          TIMESTAMP='order_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');

CREATE STREAM JSS_SHIPMENTS (ROWKEY VARCHAR KEY, shipment_id VARCHAR, ship_ts VARCHAR, order_id INT, warehouse VARCHAR)
    WITH (kafka_topic='jss_shipments',
          partitions=4,
          value_format='avro',
          TIMESTAMP='ship_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');

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
