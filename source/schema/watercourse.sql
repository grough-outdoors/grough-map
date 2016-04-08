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
-- Name: watercourse; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE watercourse (
    watercourse_id bigint NOT NULL,
    watercourse_class_id smallint,
    watercourse_width integer,
    watercourse_geom geometry(MultiLineString,27700),
    watercourse_name character varying(100)
);


ALTER TABLE public.watercourse OWNER TO "grough-map";

--
-- Name: watercourse_watercourse_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE watercourse_watercourse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.watercourse_watercourse_id_seq OWNER TO "grough-map";

--
-- Name: watercourse_watercourse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE watercourse_watercourse_id_seq OWNED BY watercourse.watercourse_id;


--
-- Name: watercourse_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY watercourse ALTER COLUMN watercourse_id SET DEFAULT nextval('watercourse_watercourse_id_seq'::regclass);


--
-- Name: PKEY: watercourse::watercourse_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY watercourse
    ADD CONSTRAINT "PKEY: watercourse::watercourse_id" PRIMARY KEY (watercourse_id);


--
-- Name: Idx: watercourse::watercourse_geom; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: watercourse::watercourse_geom" ON watercourse USING gist (watercourse_geom);

ALTER TABLE watercourse CLUSTER ON "Idx: watercourse::watercourse_geom";


--
-- PostgreSQL database dump complete
--

