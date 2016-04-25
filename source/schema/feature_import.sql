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
-- Name: feature_import; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE feature_import (
    import_id integer NOT NULL,
    import_field character varying(20),
    import_value character varying(20),
    import_class_id smallint,
    import_point boolean DEFAULT false NOT NULL,
    import_line boolean DEFAULT false NOT NULL,
    import_polygon_edge boolean DEFAULT false NOT NULL,
    import_polygon_centroid boolean DEFAULT false NOT NULL,
    import_line_middle boolean DEFAULT false NOT NULL
);


ALTER TABLE public.feature_import OWNER TO "grough-map";

--
-- Name: feature_import_import_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE feature_import_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feature_import_import_id_seq OWNER TO "grough-map";

--
-- Name: feature_import_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE feature_import_import_id_seq OWNED BY feature_import.import_id;


--
-- Name: import_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY feature_import ALTER COLUMN import_id SET DEFAULT nextval('feature_import_import_id_seq'::regclass);


--
-- Data for Name: feature_import; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY feature_import (import_id, import_field, import_value, import_class_id, import_point, import_line, import_polygon_edge, import_polygon_centroid, import_line_middle) FROM stdin;
1	barrier	bar	1	f	t	f	f	f
25	barrier	pen_gate	5	t	f	f	f	f
6	barrier	church_gates	5	t	f	f	f	f
3	barrier	cattle_grid	7	t	f	f	f	f
2	barrier	bump_gate	5	t	f	f	f	f
4	barrier	city_wall	2	f	t	t	f	f
5	barrier	castle_wall	2	f	t	t	f	f
7	barrier	crash_barrier	2	f	t	t	f	f
8	barrier	cycle_barrier	2	f	t	t	f	f
10	barrier	embankment	8	f	t	t	f	f
11	barrier	earthworks	8	f	t	t	f	f
12	barrier	earth_bank	8	f	t	t	f	f
13	barrier	fence	1	f	t	t	f	f
14	barrier	hedge	3	f	t	t	f	f
15	barrier	wall	2	f	t	t	f	f
16	barrier	flood_bank	8	f	t	t	f	f
18	barrier	garden	1	f	t	t	f	f
21	barrier	guard_rail	1	f	t	t	f	f
22	barrier	hand_rail_fence	1	f	t	t	f	f
24	barrier	moat	8	f	t	t	f	f
29	barrier	wire	1	f	t	t	f	f
30	barrier	wire_fence	1	f	t	t	f	f
31	aerialway	cable_car	9	f	t	f	f	f
32	aerialway	gondola	9	f	t	f	f	f
33	aerialway	chair_lift	10	f	t	f	f	f
34	aerialway	mixed_lift	10	f	t	f	f	f
35	aerialway	drag_lift	10	f	t	f	f	f
36	aerialway	t-bar	10	f	t	f	f	f
37	aerialway	j-bar	10	f	t	f	f	f
38	aerialway	platter	10	f	t	f	f	f
39	aerialway	zip_line	11	f	t	f	f	f
41	aerialway	canopy	11	f	t	f	f	f
42	power	line	4	f	t	f	f	f
43	power	minor_line	4	f	t	f	f	f
44	power	tower	12	t	f	f	f	f
17	barrier	flood_gate	5	t	f	f	f	t
19	barrier	gate	5	t	f	f	f	t
20	barrier	gates	5	t	f	f	f	t
23	barrier	lift_gate	5	t	f	f	f	t
26	barrier	stile	6	t	f	f	f	t
27	barrier	swing_gate	5	t	f	f	f	t
28	barrier	ticket_gate	5	t	f	f	f	t
40	aerialway	pylon	12	t	f	f	t	f
92	man_made	lighthouse	46	t	f	f	t	f
49	man_made	mast	14	t	f	f	t	f
52	highway	ford	17	t	f	f	t	t
67	amenity	fountain	32	t	f	f	t	f
53	highway	stepping_stones	18	t	f	f	t	t
69	natural	well	31	t	f	f	t	f
70	natural	cave	30	t	f	f	t	f
54	waterway	weir	19	t	t	t	t	t
55	waterway	dam	20	f	t	t	t	t
68	man_made	mineshaft	33	t	f	f	t	f
71	natural	shake_hole	34	t	f	f	t	f
72	natural	sinkhole	34	t	f	f	t	f
93	man_made	groyne	2	f	t	f	f	f
56	waterway	lock	21	t	f	f	t	t
57	waterway	slipway	22	t	f	t	t	t
77	amenity	shelter	35	t	t	f	t	f
78	historic	memorial	36	t	f	f	t	f
96	man_made	viaduct	47	f	t	f	t	f
98	highway	stile	6	t	f	f	f	t
58	waterway	jetty	23	t	f	t	t	t
99	barrier	kissing_gate	5	t	f	f	f	t
100	barrier	swing_gate	5	t	f	f	f	t
79	man_made	survey_point	37	t	f	f	f	f
80	man_made	flagpole	38	t	f	f	f	f
81	man_made	telephone_box	39	t	f	f	t	f
45	man_made	cairn	13	t	f	f	t	f
46	man_made	tower	14	t	f	f	t	f
47	man_made	water_tower	15	t	f	f	t	f
48	man_made	communications_tower	14	t	f	f	t	f
59	waterway	dock	24	t	f	f	t	t
60	waterway	sluice_gate	25	t	f	f	t	t
61	waterway	boat_lift	26	t	f	t	t	t
62	waterway	aqueduct	27	t	f	f	t	t
63	waterway	pond	28	t	f	f	t	t
64	natural	spring	29	t	f	f	t	f
65	natural	cave_entrance	30	t	f	f	t	f
66	man_made	water_well	31	t	f	f	t	f
85	man_made	air_shaft	33	t	f	f	t	f
86	man_made	boundary_stone	40	t	f	f	f	f
87	man_made	communications_dish	41	t	f	f	t	f
88	man_made	storage_tank	42	t	f	t	t	f
89	man_made	silo	43	t	f	t	t	f
90	man_made	chimney	44	t	f	t	t	f
91	man_made	spoil_heap	45	t	f	f	t	f
101	landuse	quarry	49	t	f	f	t	f
102	leisure	picnic_table	50	t	f	f	f	f
\.


--
-- Name: feature_import_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('feature_import_import_id_seq', 102, true);


--
-- Name: PKEY: feature_import::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_import
    ADD CONSTRAINT "PKEY: feature_import::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

