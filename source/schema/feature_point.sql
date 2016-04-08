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
-- Name: feature_point; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE feature_point (
    feature_id bigint NOT NULL,
    feature_class_id smallint,
    feature_geom geometry(Point,27700)
);


ALTER TABLE public.feature_point OWNER TO "grough-map";

--
-- Name: feature_point_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE feature_point_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feature_point_feature_id_seq OWNER TO "grough-map";

--
-- Name: feature_point_feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE feature_point_feature_id_seq OWNED BY feature_point.feature_id;


--
-- Name: feature_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY feature_point ALTER COLUMN feature_id SET DEFAULT nextval('feature_point_feature_id_seq'::regclass);


--
-- Name: PKEY: feature_point::feature_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_point
    ADD CONSTRAINT "PKEY: feature_point::feature_id" PRIMARY KEY (feature_id);


--
-- Name: Idx: feature_point::feature_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: feature_point::feature_geom" ON feature_point USING gist (feature_geom);

ALTER TABLE feature_point CLUSTER ON "Idx: feature_point::feature_geom";


--
-- PostgreSQL database dump complete
--

