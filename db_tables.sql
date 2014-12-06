CREATE TABLE event
(
  id bigint NOT NULL,
  event_type character varying(10),
  date_from timestamp without time zone,
  CONSTRAINT pk1 PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);