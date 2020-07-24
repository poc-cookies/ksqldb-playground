CREATE STREAM actingevents (name VARCHAR, title VARCHAR, genre VARCHAR)
    WITH (kafka_topic = 'acting-events', partitions = 1, value_format = 'AVRO');

CREATE STREAM actingevents_drama AS
    SELECT NAME, TITLE
    FROM ACTINGEVENTS
    WHERE GENRE='drama';

CREATE STREAM actingevents_fantasy AS
    SELECT NAME, TITLE
    FROM ACTINGEVENTS
    WHERE GENRE='fantasy';

CREATE STREAM actingevents_other AS
    SELECT NAME, TITLE
    FROM ACTINGEVENTS
    WHERE GENRE != 'drama' AND GENRE != 'fantasy';
