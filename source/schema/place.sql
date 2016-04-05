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
-- Name: place; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE place (
    place_id bigint NOT NULL,
    place_class_id smallint,
    place_centre_geom geometry(Point,27700),
    place_geom geometry(MultiPolygon,27700),
    place_name character varying(100)
);


ALTER TABLE public.place OWNER TO "grough-map";

--
-- Name: place_place_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE place_place_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.place_place_id_seq OWNER TO "grough-map";

--
-- Name: place_place_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE place_place_id_seq OWNED BY place.place_id;


--
-- Name: place_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY place ALTER COLUMN place_id SET DEFAULT nextval('place_place_id_seq'::regclass);


--
-- Name: PKEY: place::place_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY place
    ADD CONSTRAINT "PKEY: place::place_id" PRIMARY KEY (place_id);


--
-- Name: Idx: place::place_centre_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: place::place_centre_geom" ON place USING gist (place_centre_geom);


--
-- Name: Idx: place::place_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: place::place_geom" ON place USING gist (place_geom);

ALTER TABLE place CLUSTER ON "Idx: place::place_geom";


--
-- PostgreSQL database dump complete
--

