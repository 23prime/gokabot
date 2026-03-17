-- migrate:up
CREATE SCHEMA IF NOT EXISTS gokabot;

-- migrate:down
DROP SCHEMA gokabot;
