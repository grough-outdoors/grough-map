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

ALTER TABLE ONLY public.surface_classes DROP CONSTRAINT "PKEY: surface_class::class_id";
ALTER TABLE public.surface_classes ALTER COLUMN class_id DROP DEFAULT;
DROP SEQUENCE public.surface_class_class_id_seq;
DROP TABLE public.surface_classes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: surface_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE surface_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order smallint,
    class_below_zones boolean DEFAULT false NOT NULL,
    class_below_relief boolean DEFAULT false NOT NULL
);


ALTER TABLE public.surface_classes OWNER TO "grough-map";

--
-- Name: surface_class_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE surface_class_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.surface_class_class_id_seq OWNER TO "grough-map";

--
-- Name: surface_class_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE surface_class_class_id_seq OWNED BY surface_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY surface_classes ALTER COLUMN class_id SET DEFAULT nextval('surface_class_class_id_seq'::regclass);


--
-- Name: surface_class_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('surface_class_class_id_seq', 20, true);


--
-- Data for Name: surface_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY surface_classes (class_id, class_name, class_draw_order, class_below_zones, class_below_relief) FROM stdin;
8	Quarry	7	f	f
3	Landform	9	f	f
9	Pier	10	f	f
1	Foreshore	5	t	f
2	Woodland	2	t	f
4	Moorland	1	t	f
11	Heath	8	t	f
5	Tidal water	3	t	f
6	Surface water	4	f	f
14	Taxiway	13	f	t
15	Runway	14	f	t
19	Grass	1	f	t
18	Activity area	2	f	t
20	Car park	2	f	t
7	Sand beach	6	t	f
\.


--
-- Name: PKEY: surface_class::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY surface_classes
    ADD CONSTRAINT "PKEY: surface_class::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

