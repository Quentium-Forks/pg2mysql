load $BATS_TEST_DIRNAME/common.bash

setup() {
    setup_common
}

teardown() {
    teardown_common
}

@test "Network type MySQL does not support" {
     pg2mysql.pl <<PGDUMP > out.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: network_types; Type: TABLE; Schema: public; Owner: timsehn
--

CREATE TABLE public.network_types (
    pk integer NOT NULL,
    c1 cidr,
    c2 inet,
    c3 macaddr
);


ALTER TABLE public.network_types OWNER TO timsehn;

--
-- Data for Name: network_types; Type: TABLE DATA; Schema: public; Owner: timsehn
--

INSERT INTO public.network_types VALUES (1, '192.168.100.128/25', '192.168.100.128/25', '08:00:2b:01:02:03');

--
-- Name: network_types network_types_pkey; Type: CONSTRAINT; Schema: public; Owner: timsehn
--

ALTER TABLE ONLY public.network_types
    ADD CONSTRAINT network_types_pkey PRIMARY KEY (pk);


--
-- PostgreSQL database dump complete
--
PGDUMP

     dolt sql < out.sql

     run dolt sql -q "use public; show create table network_types;"
     [ $status -eq 0 ]
     [[ "$output" =~ "varchar(32)" ]] || false
     [[ ! "$output" =~ "cidr" ]] || false
     [[ ! "$output" =~ "inet" ]] || false
     [[ ! "$output" =~ "macaddr" ]] || false

     run dolt sql -q "use public; select * from network_types;"
     [ $status -eq 0 ]
     [[ "$output" =~ "192.168.100.128/25" ]] || false
     [[ "$output" =~ "08:00:2b:01:02:03" ]] || false
}
