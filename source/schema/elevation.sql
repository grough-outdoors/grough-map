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
-- Name: elevation; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE elevation (
    elevation_id bigint NOT NULL,
    elevation_level double precision,
    elevation_geom geometry(LineString,27700)
);


ALTER TABLE public.elevation OWNER TO "grough-map";

--
-- Name: elevation_elevation_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE elevation_elevation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elevation_elevation_id_seq OWNER TO "grough-map";

--
-- Name: elevation_elevation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE elevation_elevation_id_seq OWNED BY elevation.elevation_id;


--
-- Name: elevation_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY elevation ALTER COLUMN elevation_id SET DEFAULT nextval('elevation_elevation_id_seq'::regclass);


--
-- Name: PKEY: elevation::elevation_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY elevation
    ADD CONSTRAINT "PKEY: elevation::elevation_id" PRIMARY KEY (elevation_id);


--
-- Name: Idx: elevation::elevation_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: elevation::elevation_geom" ON elevation USING gist (elevation_geom);

ALTER TABLE elevation CLUSTER ON "Idx: elevation::elevation_geom";


--
-- PostgreSQL database dump complete
--

