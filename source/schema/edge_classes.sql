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

ALTER TABLE ONLY public.edge_classes DROP CONSTRAINT "PKEY: edge_classes::class_id";
ALTER TABLE public.edge_classes ALTER COLUMN class_id DROP DEFAULT;
DROP SEQUENCE public.edge_classes_class_id_seq;
DROP TABLE public.edge_classes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: edge_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_default_access_id integer,
    class_draw_order integer,
    class_label boolean
);


ALTER TABLE public.edge_classes OWNER TO "grough-map";

--
-- Name: edge_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: edge_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_classes_class_id_seq OWNED BY edge_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_classes ALTER COLUMN class_id SET DEFAULT nextval('edge_classes_class_id_seq'::regclass);


--
-- Data for Name: edge_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY edge_classes (class_id, class_name, class_default_access_id, class_draw_order, class_label) FROM stdin;
11	Steps	3	2	f
14	Parking	2	3	f
9	Ford	6	4	f
8	Track	6	5	t
17	Right of way	4	6	t
7	Service road	2	7	f
6	Minor road	1	8	f
5	Local street	1	9	t
4	B road	1	10	t
3	A road	1	11	t
2	Trunk road	1	12	t
1	Motorway	1	13	t
13	Railway	9	-1	t
10	Path	3	1	t
16	Other railway	9	-1	t
18	Ferry	15	-1	t
\.


--
-- Name: edge_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('edge_classes_class_id_seq', 18, true);


--
-- Name: PKEY: edge_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_classes
    ADD CONSTRAINT "PKEY: edge_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

