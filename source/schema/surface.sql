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
-- Name: surface; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE surface (
    surface_id bigint NOT NULL,
    surface_class_id smallint,
    surface_geom geometry(MultiPolygon,27700)
);


ALTER TABLE public.surface OWNER TO "grough-map";

--
-- Name: surface_surface_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE surface_surface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.surface_surface_id_seq OWNER TO "grough-map";

--
-- Name: surface_surface_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE surface_surface_id_seq OWNED BY surface.surface_id;


--
-- Name: surface_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY surface ALTER COLUMN surface_id SET DEFAULT nextval('surface_surface_id_seq'::regclass);


--
-- Name: PKEY: surface::surface_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY surface
    ADD CONSTRAINT "PKEY: surface::surface_id" PRIMARY KEY (surface_id);


--
-- Name: Idx: surface::surface_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: surface::surface_geom" ON surface USING gist (surface_geom);

ALTER TABLE surface CLUSTER ON "Idx: surface::surface_geom";


--
-- PostgreSQL database dump complete
--

