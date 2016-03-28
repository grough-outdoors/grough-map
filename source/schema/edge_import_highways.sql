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
-- Name: edge_import_highways; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_import_highways (
    import_id integer NOT NULL,
    highway character varying(20),
    class_id integer
);


ALTER TABLE public.edge_import_highways OWNER TO "grough-map";

--
-- Name: edge_import_highways_import_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_import_highways_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_import_highways_import_id_seq OWNER TO "grough-map";

--
-- Name: edge_import_highways_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_import_highways_import_id_seq OWNED BY edge_import_highways.import_id;


--
-- Name: import_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_import_highways ALTER COLUMN import_id SET DEFAULT nextval('edge_import_highways_import_id_seq'::regclass);


--
-- Data for Name: edge_import_highways; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY edge_import_highways (import_id, highway, class_id) FROM stdin;
1	unsurfaced	8
2	footway	10
3	motorway	1
4	layby	7
5	bus_stop	7
6	stepping_stones	10
7	access	7
8	motorway_link	1
19	road	8
10	steps	11
11	bridleway	8
12	pedestrian	10
13	ford	9
34	raceway	7
9	trail	10
14	cycleway	8
15	trunk_link	2
16	living_street	6
17	residential	6
18	manoeuvring_forecour	7
20	primary	3
21	secondary	4
22	track	8
23	tertiary	5
24	trunk	2
25	tertiary_link	5
26	secondary_link	4
27	primary_link	3
28	escape	7
29	service	7
30	byway	8
31	bus_guideway	6
32	path	10
33	unclassified	6
\.


--
-- Name: edge_import_highways_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('edge_import_highways_import_id_seq', 34, true);


--
-- Name: PKEY: edge_import_osm_highways::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_import_highways
    ADD CONSTRAINT "PKEY: edge_import_osm_highways::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

