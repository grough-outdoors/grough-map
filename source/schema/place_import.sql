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
-- Name: place_import; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE place_import (
    import_id integer NOT NULL,
    import_field character varying(20),
    import_value character varying(20),
    import_class_id smallint
);


ALTER TABLE public.place_import OWNER TO "grough-map";

--
-- Name: place_import_import_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE place_import_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.place_import_import_id_seq OWNER TO "grough-map";

--
-- Name: place_import_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE place_import_import_id_seq OWNED BY place_import.import_id;


--
-- Name: import_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY place_import ALTER COLUMN import_id SET DEFAULT nextval('place_import_import_id_seq'::regclass);


--
-- Data for Name: place_import; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY place_import (import_id, import_field, import_value, import_class_id) FROM stdin;
1	landuse	farmyard	1
2	leisure	golf_course	14
3	leisure	common	15
4	amenity	school	16
5	amenity	university	17
6	aeroway	aerodrome	18
7	landuse	forest	8
8	tourism	attraction	19
9	natural	moor	11
10	natural	heath	11
11	natural	scrub	11
12	natural	wetland	11
13	natural	fell	11
14	landuse	meadow	11
15	leisure	park	20
16	amenity	college	21
17	landuse	cemetery	22
18	amenity	hospital	23
19	leisure	stadium	24
20	landuse	recreation_ground	25
21	leisure	sports_centre	26
22	landuse	industrial	27
23	landuse	conservation	28
24	landuse	military	29
25	tourism	museum	30
26	natural	wood	8
27	natural	forest	8
\.


--
-- Name: place_import_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('place_import_import_id_seq', 27, true);


--
-- Name: PKEY: place_import::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY place_import
    ADD CONSTRAINT "PKEY: place_import::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

