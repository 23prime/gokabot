-- migrate:up
CREATE TABLE gokabot.gokabous (
    id serial4 NOT NULL,
    reg_date date NOT NULL,
    sentence varchar(300) NOT NULL,
    CONSTRAINT gokabous_pkey PRIMARY KEY (id)
);

-- migrate:down
DROP TABLE gokabot.gokabous;
