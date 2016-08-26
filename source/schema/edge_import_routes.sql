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

ALTER TABLE ONLY public.edge_import_routes DROP CONSTRAINT "PKEY: edge_import_routes::import_id";
ALTER TABLE public.edge_import_routes ALTER COLUMN import_id DROP DEFAULT;
DROP SEQUENCE public.edge_import_route_import_id_seq;
DROP TABLE public.edge_import_routes;
SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: edge_import_routes; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_import_routes (
    import_id integer NOT NULL,
    route character varying(20),
    class_id integer
);


ALTER TABLE public.edge_import_routes OWNER TO "grough-map";

--
-- Name: edge_import_route_import_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_import_route_import_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_import_route_import_id_seq OWNER TO "grough-map";

--
-- Name: edge_import_route_import_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_import_route_import_id_seq OWNED BY edge_import_routes.import_id;


--
-- Name: import_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_import_routes ALTER COLUMN import_id SET DEFAULT nextval('edge_import_route_import_id_seq'::regclass);


--
-- Name: edge_import_route_import_id_seq; Type: SEQUENCE SET; Schema: public; Owner: grough-map
--

SELECT pg_catalog.setval('edge_import_route_import_id_seq', 1, true);


--
-- Data for Name: edge_import_routes; Type: TABLE DATA; Schema: public; Owner: grough-map
--

COPY edge_import_routes (import_id, route, class_id) FROM stdin;
1	ferry	18
\.


--
-- Name: PKEY: edge_import_routes::import_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_import_routes
    ADD CONSTRAINT "PKEY: edge_import_routes::import_id" PRIMARY KEY (import_id);


--
-- PostgreSQL database dump complete
--

