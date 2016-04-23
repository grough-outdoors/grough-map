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
-- Name: elevation_source; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE elevation_source (
    source_id bigint NOT NULL,
    source_lidar boolean,
    source_geom geometry(MultiPolygon,27700)
);


ALTER TABLE public.elevation_source OWNER TO "grough-map";

--
-- Name: elevation_source_source_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE elevation_source_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elevation_source_source_id_seq OWNER TO "grough-map";

--
-- Name: elevation_source_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE elevation_source_source_id_seq OWNED BY elevation_source.source_id;


--
-- Name: source_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY elevation_source ALTER COLUMN source_id SET DEFAULT nextval('elevation_source_source_id_seq'::regclass);


--
-- Name: PKEY: elevation_source::source_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY elevation_source
    ADD CONSTRAINT "PKEY: elevation_source::source_id" PRIMARY KEY (source_id);


--
-- Name: Idx: elevation_source::source_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: elevation_source::source_geom" ON elevation_source USING gist (source_geom);

ALTER TABLE elevation_source CLUSTER ON "Idx: elevation_source::source_geom";


--
-- PostgreSQL database dump complete
--

