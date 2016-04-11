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
    import_polygon_edge boolean DEFAULT false NOT NULL
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

COPY feature_import (import_id, import_field, import_value, import_class_id, import_point, import_line, import_polygon_edge) FROM stdin;
1	barrier	bar	1	f	t	f
17	barrier	flood_gate	5	t	f	f
19	barrier	gate	5	t	f	f
20	barrier	gates	5	t	f	f
23	barrier	lift_gate	5	t	f	f
25	barrier	pen_gate	5	t	f	f
26	barrier	stile	6	t	f	f
27	barrier	swing_gate	5	t	f	f
28	barrier	ticket_gate	5	t	f	f
6	barrier	church_gates	5	t	f	f
3	barrier	cattle_grid	7	t	f	f
2	barrier	bump_gate	5	t	f	f
4	barrier	city_wall	2	f	t	t
5	barrier	castle_wall	2	f	t	t
7	barrier	crash_barrier	2	f	t	t
8	barrier	cycle_barrier	2	f	t	t
10	barrier	embankment	8	f	t	t
11	barrier	earthworks	8	f	t	t
12	barrier	earth_bank	8	f	t	t
13	barrier	fence	1	f	t	t
14	barrier	hedge	3	f	t	t
15	barrier	wall	2	f	t	t
16	barrier	flood_bank	8	f	t	t
18	barrier	garden	1	f	t	t
21	barrier	guard_rail	1	f	t	t
22	barrier	hand_rail_fence	1	f	t	t
24	barrier	moat	8	f	t	t
29	barrier	wire	1	f	t	t
30	barrier	wire_fence	1	f	t	t
31	aerialway	cable_car	9	f	t	f
32	aerialway	gondola	9	f	t	f
33	aerialway	chair_lift	10	f	t	f
34	aerialway	mixed_lift	10	f	t	f
35	aerialway	drag_lift	10	f	t	f
36	aerialway	t-bar	10	f	t	f
37	aerialway	j-bar	10	f	t	f
38	aerialway	platter	10	f	t	f
39	aerialway	zip_line	11	f	t	f
40	aerialway	pylon	12	t	f	f
41	aerialway	canopy	11	f	t	f
42	power	line	4	f	t	f
43	power	minor_line	4	f	t	f
44	power	tower	12	t	f	f
\.


--
-- Name: feature_import_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('feature_import_import_id_seq', 44, true);


--
-- Name: PKEY: feature_import::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_import
    ADD CONSTRAINT "PKEY: feature_import::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

