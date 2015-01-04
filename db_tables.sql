CREATE TABLE event
(
  id bigint NOT NULL,
  event_type character varying(10),
  date_from timestamp without time zone,
  num_value numeric(8,2),
  CONSTRAINT pk1 PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);
