-- migrate:up
CREATE TABLE gokabot.yukarin_mails (
    id serial4 NOT NULL,
    mail_date date NOT NULL,
    subject varchar(20) NOT NULL,
    body text NOT NULL,
    CONSTRAINT yukarin_mails_pkey PRIMARY KEY (id)
);

-- migrate:down
DROP TABLE gokabot.yukarin_mails;
