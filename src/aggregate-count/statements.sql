CREATE STREAM MOVIE_TICKET_SALES (title VARCHAR, sale_ts VARCHAR, ticket_total_value INT)
    WITH (kafka_topic='movie-ticket-sales',
          partitions=1,
          value_format='avro',
          TIMESTAMP='sale_ts',
          TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');

CREATE TABLE MOVIE_TICKETS_SOLD AS
    SELECT TITLE,
           COUNT(TICKET_TOTAL_VALUE) AS TICKETS_SOLD
    FROM MOVIE_TICKET_SALES
    GROUP BY TITLE
    EMIT CHANGES;
