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
-- Name: edge; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE edge (
    edge_id bigint NOT NULL,
    edge_class_id integer,
    edge_access_id integer,
    edge_name character varying(255),
    edge_geom geometry(LineString,27700),
    edge_level integer,
    edge_bridge boolean,
    edge_tunnel boolean,
    edge_source_id bigint,
    edge_oneway boolean,
    edge_roundabout boolean,
    edge_slip boolean
);


ALTER TABLE public.edge OWNER TO "grough-map";

--
-- Name: edge_edge_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE edge_edge_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edge_edge_id_seq OWNER TO "grough-map";

--
-- Name: edge_edge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE edge_edge_id_seq OWNED BY edge.edge_id;


--
-- Name: edge_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY edge ALTER COLUMN edge_id SET DEFAULT nextval('edge_edge_id_seq'::regclass);


--
-- Name: PKEY: edge::edge_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY edge
    ADD CONSTRAINT "PKEY: edge::edge_id" PRIMARY KEY (edge_id);


--
-- Name: Idx: edge::edge_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: edge::edge_geom" ON edge USING gist (edge_geom);

ALTER TABLE edge CLUSTER ON "Idx: edge::edge_geom";


--
-- PostgreSQL database dump complete
--

