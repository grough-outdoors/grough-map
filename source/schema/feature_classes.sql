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
-- Name: feature_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE feature_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order smallint
);


ALTER TABLE public.feature_classes OWNER TO "grough-map";

--
-- Name: feature_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE feature_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feature_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: feature_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE feature_classes_class_id_seq OWNED BY feature_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY feature_classes ALTER COLUMN class_id SET DEFAULT nextval('feature_classes_class_id_seq'::regclass);


--
-- Data for Name: feature_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY feature_classes (class_id, class_name, class_draw_order) FROM stdin;
1	Fence	\N
2	Wall	\N
3	Hedge	\N
4	Overhead cables	\N
5	Gate	\N
6	Stile	\N
7	Cattle grid	\N
8	Earthworks	\N
\.


--
-- Name: feature_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('feature_classes_class_id_seq', 8, true);


--
-- Name: PKEY: feature_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_classes
    ADD CONSTRAINT "PKEY: feature_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

