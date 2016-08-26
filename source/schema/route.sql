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
-- Name: route; Type: TABLE; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE TABLE route (
    route_id bigint NOT NULL,
    route_class_id integer,
    route_name character varying(255),
    route_ref character varying(50)
);


ALTER TABLE public.route OWNER TO "grough-map";

--
-- Name: route_route_id_seq; Type: SEQUENCE; Schema: public; Owner: grough-map
--

CREATE SEQUENCE route_route_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.route_route_id_seq OWNER TO "grough-map";

--
-- Name: route_route_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: grough-map
--

ALTER SEQUENCE route_route_id_seq OWNED BY route.route_id;


--
-- Name: route_id; Type: DEFAULT; Schema: public; Owner: grough-map
--

ALTER TABLE ONLY route ALTER COLUMN route_id SET DEFAULT nextval('route_route_id_seq'::regclass);


--
-- Name: PKEY: route::route_id; Type: CONSTRAINT; Schema: public; Owner: grough-map; Tablespace: 
--

ALTER TABLE ONLY route
    ADD CONSTRAINT "PKEY: route::route_id" PRIMARY KEY (route_id);


--
-- Name: Idx: route::route_id; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: route::route_id" ON route USING btree (route_ref);

ALTER TABLE route CLUSTER ON "Idx: route::route_id";


--
-- Name: Idx: route::route_name; Type: INDEX; Schema: public; Owner: grough-map; Tablespace: 
--

CREATE INDEX "Idx: route::route_name" ON route USING btree (route_name);


--
-- PostgreSQL database dump complete
--

