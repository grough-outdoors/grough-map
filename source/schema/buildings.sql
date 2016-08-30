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
-- Name: buildings; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE buildings (
    building_geom geometry(MultiPolygon,27700),
    building_geom_source text,
    building_geom_source_id bigint,
    building_layer integer,
    building_id bigint NOT NULL
);


ALTER TABLE public.buildings OWNER TO "grough-map";

--
-- Name: buildings_building_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE buildings_building_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.buildings_building_id_seq OWNER TO "grough-map";

--
-- Name: buildings_building_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE buildings_building_id_seq OWNED BY buildings.building_id;


--
-- Name: building_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY buildings ALTER COLUMN building_id SET DEFAULT nextval('buildings_building_id_seq'::regclass);


--
-- Name: Con: buildings::building_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY buildings
    ADD CONSTRAINT "Con: buildings::building_id" PRIMARY KEY (building_id);


--
-- Name: Idx: buildings::building_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: buildings::building_geom" ON buildings USING gist (building_geom);

ALTER TABLE buildings CLUSTER ON "Idx: buildings::building_geom";


--
-- PostgreSQL database dump complete
--

