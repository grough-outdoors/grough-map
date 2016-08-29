--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: source; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE source (
    source_id integer NOT NULL,
    source_name character varying(100),
    source_org character varying(100),
    source_url character varying(100),
    source_licence character varying(5) DEFAULT 'OGLv3'::character varying NOT NULL,
    source_category character varying(100),
    source_constraints text[],
    source_disclaimers text[],
    source_date date,
    source_statement character varying(255)
);


ALTER TABLE public.source OWNER TO "grough-map";

--
-- Name: source_source_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE source_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.source_source_id_seq OWNER TO "grough-map";

--
-- Name: source_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE source_source_id_seq OWNED BY source.source_id;


--
-- Name: source_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY source ALTER COLUMN source_id SET DEFAULT nextval('source_source_id_seq'::regclass);


--
-- Name: PKEY: source::source_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY source
    ADD CONSTRAINT "PKEY: source::source_id" PRIMARY KEY (source_id);


--
-- PostgreSQL database dump complete
--

