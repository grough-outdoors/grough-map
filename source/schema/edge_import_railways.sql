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
-- Name: edge_import_railways; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_import_railways (
    import_id integer NOT NULL,
    railway character varying(20),
    class_id integer
);


ALTER TABLE public.edge_import_railways OWNER TO "grough-map";

--
-- Name: edge_import_railways_import_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_import_railways_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_import_railways_import_id_seq OWNER TO "grough-map";

--
-- Name: edge_import_railways_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_import_railways_import_id_seq OWNED BY edge_import_railways.import_id;


--
-- Name: import_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_import_railways ALTER COLUMN import_id SET DEFAULT nextval('edge_import_railways_import_id_seq'::regclass);


--
-- Data for Name: edge_import_railways; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY edge_import_railways (import_id, railway, class_id) FROM stdin;
2	storage	13
3	light_rail	13
4	preserved	13
5	subway	13
6	heritage	13
7	transfer_table	13
8	course	13
9	tram	13
11	level_crossing	13
12	crossing	13
13	incline	13
15	rail	13
14	monorail	16
10	funicular	16
1	narrow_gauge	16
\.


--
-- Name: edge_import_railways_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('edge_import_railways_import_id_seq', 15, true);


--
-- Name: PKEY: edge_import_railways::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_import_railways
    ADD CONSTRAINT "PKEY: edge_import_railways::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

