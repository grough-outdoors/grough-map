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

ALTER TABLE ONLY public.place_classes DROP CONSTRAINT "PKEY: place_classes::class_id";
ALTER TABLE public.place_classes ALTER COLUMN class_id DROP DEFAULT;
DROP SEQUENCE public.place_classes_class_id_seq;
DROP TABLE public.place_classes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: place_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE place_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order smallint,
    class_text_size double precision,
    class_wrap_width smallint
);


ALTER TABLE public.place_classes OWNER TO "grough-map";

--
-- Name: place_classes_class_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE place_classes_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.place_classes_class_id_seq OWNER TO "grough-map";

--
-- Name: place_classes_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE place_classes_class_id_seq OWNED BY place_classes.class_id;


--
-- Name: class_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY place_classes ALTER COLUMN class_id SET DEFAULT nextval('place_classes_class_id_seq'::regclass);


--
-- Data for Name: place_classes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY place_classes (class_id, class_name, class_draw_order, class_text_size, class_wrap_width) FROM stdin;
3	City	1	70	400
6	Town	2	55	100
7	Settlement	10	28	1
8	Forest	7	0	1
11	Moor	9	0	1
5	Suburb	4	40	50
4	Hamlet	5	32	1
2	Village	3	43	50
1	Farm	11	0	1
9	Hill	8	32	100
10	Mountain	6	55	100
\.


--
-- Name: place_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('place_classes_class_id_seq', 11, true);


--
-- Name: PKEY: place_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY place_classes
    ADD CONSTRAINT "PKEY: place_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

