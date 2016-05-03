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
-- Name: raw_obstructions; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE raw_obstructions (
    obs_id bigint NOT NULL,
    obs_geom geometry(MultiLineString,27700)
);


ALTER TABLE public.raw_obstructions OWNER TO "grough-map";

--
-- Name: raw_obstructions_obs_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE raw_obstructions_obs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.raw_obstructions_obs_id_seq OWNER TO "grough-map";

--
-- Name: raw_obstructions_obs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE raw_obstructions_obs_id_seq OWNED BY raw_obstructions.obs_id;


--
-- Name: obs_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY raw_obstructions ALTER COLUMN obs_id SET DEFAULT nextval('raw_obstructions_obs_id_seq'::regclass);


--
-- Name: PKEY: raw_obstructions::obs_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY raw_obstructions
    ADD CONSTRAINT "PKEY: raw_obstructions::obs_id" PRIMARY KEY (obs_id);


--
-- Name: Idx: raw_obstructions::obs_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: raw_obstructions::obs_geom" ON raw_obstructions USING gist (obs_geom);

ALTER TABLE raw_obstructions CLUSTER ON "Idx: raw_obstructions::obs_geom";


--
-- PostgreSQL database dump complete
--

