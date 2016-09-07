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
-- Name: legend_text; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE legend_text (
    text_id bigint NOT NULL,
    text_geom geometry(Point,27700),
    text_size integer,
    text_bold boolean,
    text_italic boolean,
    text_value character varying(255)
);


ALTER TABLE public.legend_text OWNER TO "grough-map";

--
-- Name: legend_text_text_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE legend_text_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.legend_text_text_id_seq OWNER TO "grough-map";

--
-- Name: legend_text_text_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE legend_text_text_id_seq OWNED BY legend_text.text_id;


--
-- Name: text_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY legend_text ALTER COLUMN text_id SET DEFAULT nextval('legend_text_text_id_seq'::regclass);


--
-- Name: PKEY: legend_text::text_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY legend_text
    ADD CONSTRAINT "PKEY: legend_text::text_id" PRIMARY KEY (text_id);


--
-- PostgreSQL database dump complete
--

