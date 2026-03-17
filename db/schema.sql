\restrict dbmate

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gokabot; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gokabot;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: animes; Type: TABLE; Schema: gokabot; Owner: -
--

CREATE TABLE gokabot.animes (
    id integer NOT NULL,
    year integer NOT NULL,
    season character varying(6) NOT NULL,
    day character(3) NOT NULL,
    "time" character(5) NOT NULL,
    station character varying(20) NOT NULL,
    title character varying(100) NOT NULL,
    recommend boolean NOT NULL
);


--
-- Name: animes_id_seq; Type: SEQUENCE; Schema: gokabot; Owner: -
--

CREATE SEQUENCE gokabot.animes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: animes_id_seq; Type: SEQUENCE OWNED BY; Schema: gokabot; Owner: -
--

ALTER SEQUENCE gokabot.animes_id_seq OWNED BY gokabot.animes.id;


--
-- Name: cities; Type: TABLE; Schema: gokabot; Owner: -
--

CREATE TABLE gokabot.cities (
    id integer NOT NULL,
    name character varying(300) NOT NULL,
    jp_name character varying(300)
);


--
-- Name: gokabous; Type: TABLE; Schema: gokabot; Owner: -
--

CREATE TABLE gokabot.gokabous (
    id integer NOT NULL,
    reg_date date NOT NULL,
    sentence character varying(300) NOT NULL
);


--
-- Name: gokabous_id_seq; Type: SEQUENCE; Schema: gokabot; Owner: -
--

CREATE SEQUENCE gokabot.gokabous_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gokabous_id_seq; Type: SEQUENCE OWNED BY; Schema: gokabot; Owner: -
--

ALTER SEQUENCE gokabot.gokabous_id_seq OWNED BY gokabot.gokabous.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: gokabot; Owner: -
--

CREATE TABLE gokabot.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: yukarin_mails; Type: TABLE; Schema: gokabot; Owner: -
--

CREATE TABLE gokabot.yukarin_mails (
    id integer NOT NULL,
    mail_date date NOT NULL,
    subject character varying(20) NOT NULL,
    body text NOT NULL
);


--
-- Name: yukarin_mails_id_seq; Type: SEQUENCE; Schema: gokabot; Owner: -
--

CREATE SEQUENCE gokabot.yukarin_mails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: yukarin_mails_id_seq; Type: SEQUENCE OWNED BY; Schema: gokabot; Owner: -
--

ALTER SEQUENCE gokabot.yukarin_mails_id_seq OWNED BY gokabot.yukarin_mails.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: animes id; Type: DEFAULT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.animes ALTER COLUMN id SET DEFAULT nextval('gokabot.animes_id_seq'::regclass);


--
-- Name: gokabous id; Type: DEFAULT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.gokabous ALTER COLUMN id SET DEFAULT nextval('gokabot.gokabous_id_seq'::regclass);


--
-- Name: yukarin_mails id; Type: DEFAULT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.yukarin_mails ALTER COLUMN id SET DEFAULT nextval('gokabot.yukarin_mails_id_seq'::regclass);


--
-- Name: animes animes_constraints; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.animes
    ADD CONSTRAINT animes_constraints UNIQUE (year, season, title);


--
-- Name: animes animes_pkey; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.animes
    ADD CONSTRAINT animes_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pk; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.cities
    ADD CONSTRAINT cities_pk PRIMARY KEY (id);


--
-- Name: gokabous gokabous_pkey; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.gokabous
    ADD CONSTRAINT gokabous_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: yukarin_mails yukarin_mails_pkey; Type: CONSTRAINT; Schema: gokabot; Owner: -
--

ALTER TABLE ONLY gokabot.yukarin_mails
    ADD CONSTRAINT yukarin_mails_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: cities_jp_name_idx; Type: INDEX; Schema: gokabot; Owner: -
--

CREATE INDEX cities_jp_name_idx ON gokabot.cities USING btree (jp_name);


--
-- Name: cities_name_idx; Type: INDEX; Schema: gokabot; Owner: -
--

CREATE INDEX cities_name_idx ON gokabot.cities USING btree (name);


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO gokabot.schema_migrations (version) VALUES
    ('20260121140511'),
    ('20260121233325'),
    ('20260121234520'),
    ('20260121234833'),
    ('20260317000000');
