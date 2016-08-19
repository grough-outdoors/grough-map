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
    class_wrap_width smallint,
    class_aggregate_radius integer,
    class_label boolean DEFAULT true,
    class_prefer_no_expansion boolean DEFAULT false NOT NULL,
    class_label_with_type boolean DEFAULT false NOT NULL,
    class_label_min_km2 double precision DEFAULT 0 NOT NULL,
    class_allow_text_scale boolean DEFAULT false NOT NULL
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

COPY place_classes (class_id, class_name, class_draw_order, class_text_size, class_wrap_width, class_aggregate_radius, class_label, class_prefer_no_expansion, class_label_with_type, class_label_min_km2, class_allow_text_scale) FROM stdin;
10	Mountain	6	55	100	4000	t	f	f	0	f
13	Large waterbody	7	100	100	2000	f	f	f	0	f
2	Village	3	55	50	1500	t	f	f	0	f
9	Hill	8	40	100	3000	t	f	f	0	f
4	Hamlet	5	40	150	1000	t	f	f	0	f
7	Settlement	6	40	150	1000	t	f	f	0	f
11	Moor	9	60	150	3000	t	f	f	0	t
14	Golf course	100	35	120	2000	t	t	t	0.200000000000000011	f
15	Public common	100	35	120	1000	t	t	f	0.100000000000000006	t
17	University	100	35	120	3000	t	t	t	0.100000000000000006	f
18	Airport	100	35	120	5000	t	f	f	0	t
19	Tourist attraction	100	35	120	1000	t	t	f	0.25	f
20	Park	100	35	120	1000	t	f	f	0.100000000000000006	t
21	College	100	35	120	1000	t	t	t	0.100000000000000006	f
22	Cemetery	100	35	120	1000	t	f	t	0.0800000000000000017	f
23	Hospital	100	35	120	1000	t	f	t	0	f
24	Stadium	100	35	120	1000	t	f	f	0.100000000000000006	f
25	Recreation ground	100	35	120	100	t	f	t	0.100000000000000006	f
26	Sports centre	100	35	120	1000	t	t	f	0.100000000000000006	f
27	Industrial park	100	35	120	2500	t	t	t	0.5	t
28	Conservation area	100	35	120	100	t	t	f	0.5	t
29	Military establishment	100	35	120	3000	t	f	f	0.25	t
30	Museum	100	35	120	1000	t	t	f	0.25	t
16	School	100	30	200	1000	t	t	t	0.100000000000000006	f
1	Farm	11	33	120	500	t	f	f	0	f
12	Small waterbody	7	30	150	1500	t	t	f	0	t
8	Forest	7	30	150	2000	t	f	f	0	t
5	Suburb	4	50	50	1500	t	f	f	0	f
3	City	1	105	400	5000	t	f	f	0	f
31	Port or marina	100	35	120	1000	t	f	f	0.100000000000000006	t
33	Bay	100	35	120	1000	t	t	f	0.100000000000000006	t
34	Island	100	35	120	1000	t	f	f	0.100000000000000006	t
32	Tidal flats	100	35	120	1000	t	f	f	0.25	t
35	Farm estate	100	35	120	1000	t	f	f	0.25	t
6	Town	2	80	100	2500	t	f	f	0	f
\.


--
-- Name: place_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('place_classes_class_id_seq', 35, true);


--
-- Name: PKEY: place_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY place_classes
    ADD CONSTRAINT "PKEY: place_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

