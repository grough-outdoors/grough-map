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
-- Name: edge_route; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge_route (
    relation_id bigint NOT NULL,
    relation_edge_id bigint,
    relation_route_id integer
);


ALTER TABLE public.edge_route OWNER TO "grough-map";

--
-- Name: edge_route_relation_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_route_relation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_route_relation_id_seq OWNER TO "grough-map";

--
-- Name: edge_route_relation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_route_relation_id_seq OWNED BY edge_route.relation_id;


--
-- Name: relation_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge_route ALTER COLUMN relation_id SET DEFAULT nextval('edge_route_relation_id_seq'::regclass);


--
-- Name: PKEY: edge_route::relation_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge_route
    ADD CONSTRAINT "PKEY: edge_route::relation_id" PRIMARY KEY (relation_id);


--
-- PostgreSQL database dump complete
--

