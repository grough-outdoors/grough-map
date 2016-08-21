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

ALTER TABLE ONLY public.feature_classes DROP CONSTRAINT "PKEY: feature_classes::class_id";
ALTER TABLE public.feature_classes ALTER COLUMN class_id DROP DEFAULT;
DROP SEQUENCE public.feature_classes_class_id_seq;
DROP TABLE public.feature_classes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: feature_classes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE feature_classes (
    class_id integer NOT NULL,
    class_name character varying(100),
    class_draw_order smallint,
    class_subsurface boolean DEFAULT false NOT NULL,
    class_surface boolean DEFAULT true NOT NULL,
    class_overhead boolean DEFAULT false NOT NULL,
    class_plural_name character varying(100),
    class_radius integer DEFAULT 25,
    class_label boolean DEFAULT false NOT NULL,
    class_label_rank smallint,
    class_symbolised boolean DEFAULT false,
    class_location_fixed boolean DEFAULT false
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

COPY feature_classes (class_id, class_name, class_draw_order, class_subsurface, class_surface, class_overhead, class_plural_name, class_radius, class_label, class_label_rank, class_symbolised, class_location_fixed) FROM stdin;
50	Picnic site	\N	f	t	f	Picnic site	70	t	1	t	f
51	Pier	\N	f	t	f	Piers	100	t	5	f	f
40	BS	\N	f	t	f	BSs	40	t	1	f	f
52	Obstruction	\N	f	t	f	Obstructions	125	f	\N	f	f
24	Dock	\N	f	t	f	Docks	200	t	5	f	f
53	Castle	\N	f	t	f	Castles	300	t	5	f	f
54	Ruin	\N	f	t	f	Ruins	300	t	5	f	f
55	Fort	\N	f	t	f	Forts	500	t	5	f	f
56	Wreck	\N	f	t	f	Wrecks	250	t	1	f	f
25	Sluice gate	\N	f	t	f	Sluice gates	125	t	2	f	f
57	Beacon	\N	f	t	f	Beacons	250	t	1	f	f
58	Buoy	\N	f	t	f	Buoys	250	t	1	f	f
59	Windmill	\N	f	t	f	Windmills	200	t	1	f	f
60	Wind turbine	\N	f	t	f	Wind farm	400	t	1	f	f
62	Terminal	\N	f	t	f	Terminals	250	t	1	f	f
3	Hedge	\N	f	t	f	\N	125	f	\N	f	f
4	Overhead cables	\N	f	f	t	\N	125	f	\N	f	f
8	Earthworks	\N	f	t	f	\N	125	f	1	f	f
9	Cablecar or gondola	\N	f	f	t	\N	125	t	10	f	f
10	Ski lift	\N	f	f	t	\N	125	t	10	f	f
11	Zip line	\N	f	f	t	\N	125	t	10	f	f
27	Aqueduct	\N	f	t	f	Aqueduct	125	t	5	f	f
47	Viaduct	\N	f	t	f	Viaducts	125	t	6	f	f
1	Fence	\N	f	t	f	\N	125	f	\N	f	f
2	Wall	\N	f	t	f	\N	125	f	\N	f	f
20	Dam	\N	f	t	f	Dam	125	f	8	f	f
49	Quarry	\N	f	t	f	Quarries	500	t	7	f	f
7	CG	\N	f	t	f	CGs	40	t	1	f	f
6	Stile	\N	f	t	f	Stiles	40	f	1	f	f
5	Gate	\N	f	t	f	Gates	40	f	1	f	f
12	Pylon	\N	f	t	f	Pylons	40	f	\N	f	f
13	Cairn	\N	f	t	f	Cairns	40	t	3	f	f
14	Tower	\N	f	t	f	Towers	40	f	8	f	f
15	Water tower	\N	f	t	f	Water towers	40	t	8	f	f
16	WC	\N	f	t	f	WCs	40	t	5	f	f
18	Stepping stones	\N	f	t	f	Stepping stones	40	t	4	f	f
17	Ford	\N	f	t	f	Fords	100	t	4	f	f
19	Weir	\N	f	t	f	Weirs	70	t	4	f	f
21	Lock	\N	f	t	f	Locks	70	t	5	f	f
22	Slipway	\N	f	t	f	Slipway	40	t	5	f	f
23	Jetty	\N	f	t	f	Jetties	40	t	5	f	f
26	Boat lift	\N	f	t	f	Boat lifts	40	t	7	f	f
28	Pond	\N	f	t	f	Ponds	40	t	3	f	f
29	Spring	\N	f	t	f	Springs	40	t	2	f	f
30	Cave	\N	f	t	f	Caves	40	t	4	f	f
31	Well	\N	f	t	f	Wells	40	t	2	f	f
32	Fountain	\N	f	t	f	Fountains	40	t	2	f	f
33	Shaft	\N	f	t	f	Shafts	100	t	3	f	f
34	Shake hole	\N	f	t	f	Shake holes	100	t	2	f	f
35	Shelter	\N	f	t	f	Shelters	40	t	4	t	f
36	Meml	\N	f	t	f	Memls	70	t	4	f	f
37	Survey point	\N	f	t	f	Survey points	40	t	10	t	f
38	Flagpole	\N	f	t	f	Flagpoles	50	t	5	t	f
39	Phone	\N	f	t	f	Phones	40	t	5	f	f
41	Dish	\N	f	t	f	Dishes	40	t	6	f	f
42	Tank	\N	f	t	f	Tanks	40	t	4	f	f
43	Silo	\N	f	t	f	Silos	40	t	4	f	f
44	Chimney	\N	f	t	f	Chimneys	40	t	4	f	f
45	Spoil	\N	f	t	f	Spoil	125	t	1	f	f
46	Lighthouse	\N	f	t	f	Lighthouses	40	t	7	t	f
63	Mean High Water	\N	f	t	f	Mean High Water	0	f	1	f	f
64	Mean Low Water	\N	f	t	f	Mean Low Water	0	f	1	f	f
61	Rail station	\N	f	t	f	Rail station	100	t	1	t	t
\.


--
-- Name: feature_classes_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('feature_classes_class_id_seq', 64, true);


--
-- Name: PKEY: feature_classes::class_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_classes
    ADD CONSTRAINT "PKEY: feature_classes::class_id" PRIMARY KEY (class_id);


--
-- PostgreSQL database dump complete
--

