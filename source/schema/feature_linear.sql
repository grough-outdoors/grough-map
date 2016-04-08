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
-- Name: feature_linear; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE feature_linear (
    feature_id bigint NOT NULL,
    feature_class_id smallint,
    feature_geom geometry(MultiLineString,27700)
);


ALTER TABLE public.feature_linear OWNER TO "grough-map";

--
-- Name: feature_linear_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE feature_linear_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feature_linear_feature_id_seq OWNER TO "grough-map";

--
-- Name: feature_linear_feature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE feature_linear_feature_id_seq OWNED BY feature_linear.feature_id;


--
-- Name: feature_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY feature_linear ALTER COLUMN feature_id SET DEFAULT nextval('feature_linear_feature_id_seq'::regclass);


--
-- Name: PKEY: feature_linear::feature_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY feature_linear
    ADD CONSTRAINT "PKEY: feature_linear::feature_id" PRIMARY KEY (feature_id);


--
-- Name: Idx: feature_linear::feature_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: feature_linear::feature_geom" ON feature_linear USING gist (feature_geom);

ALTER TABLE feature_linear CLUSTER ON "Idx: feature_linear::feature_geom";


--
-- PostgreSQL database dump complete
--

