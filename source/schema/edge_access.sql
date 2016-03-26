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
-- Name: edge_access; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_access (
    access_id integer NOT NULL,
    access_name character varying(100)
);


ALTER TABLE public.edge_access OWNER TO "grough-map";

--
-- Name: edge_access_access_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_access_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_access_access_id_seq OWNER TO "grough-map";

--
-- Name: edge_access_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_access_access_id_seq OWNED BY edge_access.access_id;


--
-- Name: access_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_access ALTER COLUMN access_id SET DEFAULT nextval('edge_access_access_id_seq'::regclass);


--
-- Data for Name: edge_access; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY edge_access (access_id, access_name) FROM stdin;
1	Public road
2	Private road
5	Permissive path
6	Byway open to all traffic
7	Pedestrianised road
8	Bridleway or cycle path
10	Restricted byway
11	Restricted use path
9	Railway
3	Footpath
4	Legal footpath
12	Unknown access
\.


--
-- Name: edge_access_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('edge_access_access_id_seq', 12, true);


--
-- Name: PKEY: edge_access::access_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_access
    ADD CONSTRAINT "PKEY: edge_access::access_id" PRIMARY KEY (access_id);


--
-- PostgreSQL database dump complete
--

