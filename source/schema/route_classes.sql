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
-- Name: route_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE route_classes (
    class_id integer NOT NULL,
    class_name character varying(100)
);


ALTER TABLE public.route_classes OWNER TO "grough-map";

--
-- Name: route_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE route_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: route_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE route_classes_class_id_seq OWNED BY route_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY route_classes ALTER COLUMN class_id SET DEFAULT nextval('route_classes_class_id_seq'::regclass);


--
-- Data for Name: route_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY route_classes (class_id, class_name) FROM stdin;
1	National cycle network
2	Regional cycle network
3	Local cycle network
4	Other cycle route
5	National trail
6	Other trail
\.


--
-- Name: route_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('route_classes_class_id_seq', 6, true);


--
-- Name: PKEY: route_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY route_classes
    ADD CONSTRAINT "PKEY: route_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

