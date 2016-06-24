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
-- Name: licence; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE licence (
    licence_id integer NOT NULL,
    licence_name character varying(100),
    licence_url character varying(255),
    licence_short character varying(5)
);


ALTER TABLE public.licence OWNER TO "grough-map";

--
-- Name: licence_licence_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE licence_licence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.licence_licence_id_seq OWNER TO "grough-map";

--
-- Name: licence_licence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE licence_licence_id_seq OWNED BY licence.licence_id;


--
-- Name: licence_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY licence ALTER COLUMN licence_id SET DEFAULT nextval('licence_licence_id_seq'::regclass);


--
-- Data for Name: licence; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY licence (licence_id, licence_name, licence_url, licence_short) FROM stdin;
1	OS OpenData	http://www.rowmaps.com/datasets/oslicensing/os-opendata-licence.pdf	OS
2	Open Government Licence v2 (OGL)	http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/	OGLv2
3	Open Government Licence v3 (OGL)	http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/	OGLv3
4	Open Database License (ODbL)	http://opendatacommons.org/licenses/odbl/	ODbL
\.


--
-- Name: licence_licence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('licence_licence_id_seq', 4, true);


--
-- Name: PKEY: licence::licence_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY licence
    ADD CONSTRAINT "PKEY: licence::licence_id" PRIMARY KEY (licence_id);


--
-- Name: Idx: licence::licence_short; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE UNIQUE INDEX "Idx: licence::licence_short" ON licence USING btree (licence_short);

ALTER TABLE licence CLUSTER ON "Idx: licence::licence_short";


--
-- PostgreSQL database dump complete
--

