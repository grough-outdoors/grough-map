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
-- Name: watercourse_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE watercourse_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order integer
);


ALTER TABLE public.watercourse_classes OWNER TO "grough-map";

--
-- Name: watercourse_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE watercourse_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.watercourse_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: watercourse_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE watercourse_classes_class_id_seq OWNED BY watercourse_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY watercourse_classes ALTER COLUMN class_id SET DEFAULT nextval('watercourse_classes_class_id_seq'::regclass);


--
-- Data for Name: watercourse_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY watercourse_classes (class_id, class_name, class_draw_order) FROM stdin;
\.


--
-- Name: watercourse_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('watercourse_classes_class_id_seq', 1, false);


--
-- Name: PKEY: watercourse_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY watercourse_classes
    ADD CONSTRAINT "PKEY: watercourse_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

