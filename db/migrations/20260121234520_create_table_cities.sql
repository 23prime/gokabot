-- migrate:up
CREATE TABLE gokabot.cities (
    id int4 NOT NULL,
    "name" varchar(300) NOT NULL,
    jp_name varchar(300) NULL,
    CONSTRAINT cities_pk PRIMARY KEY (id)
);
CREATE INDEX cities_jp_name_idx ON gokabot.cities (jp_name);
CREATE INDEX cities_name_idx ON gokabot.cities ("name");

-- migrate:down
DROP TABLE gokabot.cities;
