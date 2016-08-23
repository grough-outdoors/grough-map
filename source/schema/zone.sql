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
-- Name: zone; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE zone (
    zone_id bigint NOT NULL,
    zone_class_id smallint,
    zone_geom geometry(MultiPolygon,27700),
    zone_name character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.zone OWNER TO "grough-map";

--
-- Name: zone_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE zone_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zone_zone_id_seq OWNER TO "grough-map";

--
-- Name: zone_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE zone_zone_id_seq OWNED BY zone.zone_id;


--
-- Name: zone_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY zone ALTER COLUMN zone_id SET DEFAULT nextval('zone_zone_id_seq'::regclass);


--
-- Name: PKEY: zone::zone_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY zone
    ADD CONSTRAINT "PKEY: zone::zone_id" PRIMARY KEY (zone_id);


--
-- Name: Idx: zone::zone_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: zone::zone_geom" ON zone USING gist (zone_geom);

ALTER TABLE zone CLUSTER ON "Idx: zone::zone_geom";


--
-- PostgreSQL database dump complete
--

