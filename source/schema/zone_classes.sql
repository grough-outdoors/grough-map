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

ALTER TABLE ONLY public.zone_classes DROP CONSTRAINT "PKEY: zone_classes::class_id";
ALTER TABLE public.zone_classes ALTER COLUMN class_id DROP DEFAULT;
DROP SEQUENCE public.zone_classes_class_id_seq;
DROP TABLE public.zone_classes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: zone_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE zone_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order smallint
);


ALTER TABLE public.zone_classes OWNER TO "grough-map";

--
-- Name: zone_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE zone_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zone_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: zone_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE zone_classes_class_id_seq OWNED BY zone_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY zone_classes ALTER COLUMN class_id SET DEFAULT nextval('zone_classes_class_id_seq'::regclass);


--
-- Data for Name: zone_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY zone_classes (class_id, class_name, class_draw_order) FROM stdin;
1	Countryside and Rights of Way Access Land	1
3	National Park	2
2	Military Danger Area	3
4	Nature Reserve	\N
5	Doorstep Green	\N
6	Millennium Green	\N
7	Country Park	\N
\.


--
-- Name: zone_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('zone_classes_class_id_seq', 7, true);


--
-- Name: PKEY: zone_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY zone_classes
    ADD CONSTRAINT "PKEY: zone_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

