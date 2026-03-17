-- migrate:up
CREATE TABLE gokabot.animes (
    id serial4 NOT NULL,
    "year" int4 NOT NULL,
    season varchar(6) NOT NULL,
    "day" bpchar(3) NOT NULL,
    "time" bpchar(5) NOT NULL,
    station varchar(20) NOT NULL,
    title varchar(100) NOT NULL,
    recommend bool NOT NULL,
    CONSTRAINT animes_constraints UNIQUE ("year", season, title),
    CONSTRAINT animes_pkey PRIMARY KEY (id)
);

-- migrate:down
DROP TABLE gokabot.animes;
