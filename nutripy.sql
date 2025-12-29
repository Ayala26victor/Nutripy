--
-- PostgreSQL database dump
--

\restrict nOX2BpIf2hJzvAgRHqhdHMe5xkx6L1z6VRlykLGPgL3deFXeGqKiw6iu00wlE9x

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-22 23:04:37

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- TOC entry 229 (class 1259 OID 32925)
-- Name: agenda; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.agenda (
    id integer NOT NULL,
    paciente_id integer NOT NULL,
    doctor_id integer NOT NULL,
    fecha date NOT NULL,
    hora time without time zone NOT NULL,
    motivo character varying(200),
    modalidad character varying(50),
    turno character varying(50),
    edad integer,
    sexo character varying(10)
);


ALTER TABLE public.agenda OWNER TO nutripy_admin;

--
-- TOC entry 228 (class 1259 OID 32924)
-- Name: agenda_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.agenda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agenda_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 228
-- Name: agenda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.agenda_id_seq OWNED BY public.agenda.id;


--
-- TOC entry 225 (class 1259 OID 32768)
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO nutripy_admin;

--
-- TOC entry 224 (class 1259 OID 24598)
-- Name: consulta; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.consulta (
    id integer NOT NULL,
    paciente_id integer,
    resumen text,
    firma_img text,
    firma_cripto text,
    fecha character varying(50)
);


ALTER TABLE public.consulta OWNER TO nutripy_admin;

--
-- TOC entry 223 (class 1259 OID 24597)
-- Name: consulta_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.consulta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consulta_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 223
-- Name: consulta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.consulta_id_seq OWNED BY public.consulta.id;


--
-- TOC entry 227 (class 1259 OID 32814)
-- Name: doctores; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.doctores (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    especialidad character varying(100) NOT NULL,
    telefono character varying(20),
    cedula character varying(20),
    turno character varying(50),
    user_id integer
);


ALTER TABLE public.doctores OWNER TO nutripy_admin;

--
-- TOC entry 226 (class 1259 OID 32813)
-- Name: doctores_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.doctores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.doctores_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 226
-- Name: doctores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.doctores_id_seq OWNED BY public.doctores.id;


--
-- TOC entry 222 (class 1259 OID 24590)
-- Name: pacientes; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.pacientes (
    id integer CONSTRAINT paciente_id_not_null NOT NULL,
    nombre character varying(100),
    cedula character varying(20),
    telefono character varying(20),
    edad integer,
    notas character varying(200),
    sexo character varying(10)
);


ALTER TABLE public.pacientes OWNER TO nutripy_admin;

--
-- TOC entry 221 (class 1259 OID 24589)
-- Name: paciente_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.paciente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paciente_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 221
-- Name: paciente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.paciente_id_seq OWNED BY public.pacientes.id;


--
-- TOC entry 233 (class 1259 OID 57368)
-- Name: recetario; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.recetario (
    id integer NOT NULL,
    paciente_id integer,
    titulo character varying(200) NOT NULL,
    descripcion text,
    archivo character varying(300) NOT NULL,
    fecha_subida timestamp without time zone
);


ALTER TABLE public.recetario OWNER TO nutripy_admin;

--
-- TOC entry 232 (class 1259 OID 57367)
-- Name: recetario_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.recetario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recetario_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 232
-- Name: recetario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.recetario_id_seq OWNED BY public.recetario.id;


--
-- TOC entry 220 (class 1259 OID 24580)
-- Name: user; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(50),
    password character varying(250)
);


ALTER TABLE public."user" OWNER TO nutripy_admin;

--
-- TOC entry 219 (class 1259 OID 24579)
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- TOC entry 231 (class 1259 OID 49153)
-- Name: visitas; Type: TABLE; Schema: public; Owner: nutripy_admin
--

CREATE TABLE public.visitas (
    id integer NOT NULL,
    paciente_id integer NOT NULL,
    paciente_nombre character varying(120) NOT NULL,
    edad integer NOT NULL,
    sexo character varying(10) NOT NULL,
    doctor_id integer NOT NULL,
    doctor_nombre character varying(120) NOT NULL,
    turno character varying(20) NOT NULL,
    modalidad character varying(20) NOT NULL,
    fecha date NOT NULL,
    hora time without time zone NOT NULL,
    motivo character varying(200) NOT NULL,
    firma_img text,
    firma_cripto text
);


ALTER TABLE public.visitas OWNER TO nutripy_admin;

--
-- TOC entry 230 (class 1259 OID 49152)
-- Name: visitas_id_seq; Type: SEQUENCE; Schema: public; Owner: nutripy_admin
--

CREATE SEQUENCE public.visitas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.visitas_id_seq OWNER TO nutripy_admin;

--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 230
-- Name: visitas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nutripy_admin
--

ALTER SEQUENCE public.visitas_id_seq OWNED BY public.visitas.id;


--
-- TOC entry 4847 (class 2604 OID 32928)
-- Name: agenda id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.agenda ALTER COLUMN id SET DEFAULT nextval('public.agenda_id_seq'::regclass);


--
-- TOC entry 4845 (class 2604 OID 24601)
-- Name: consulta id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.consulta ALTER COLUMN id SET DEFAULT nextval('public.consulta_id_seq'::regclass);


--
-- TOC entry 4846 (class 2604 OID 32817)
-- Name: doctores id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.doctores ALTER COLUMN id SET DEFAULT nextval('public.doctores_id_seq'::regclass);


--
-- TOC entry 4844 (class 2604 OID 24593)
-- Name: pacientes id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.pacientes ALTER COLUMN id SET DEFAULT nextval('public.paciente_id_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 57371)
-- Name: recetario id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.recetario ALTER COLUMN id SET DEFAULT nextval('public.recetario_id_seq'::regclass);


--
-- TOC entry 4843 (class 2604 OID 24583)
-- Name: user id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- TOC entry 4848 (class 2604 OID 49156)
-- Name: visitas id; Type: DEFAULT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.visitas ALTER COLUMN id SET DEFAULT nextval('public.visitas_id_seq'::regclass);


--
-- TOC entry 5030 (class 0 OID 32925)
-- Dependencies: 229
-- Data for Name: agenda; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.agenda (id, paciente_id, doctor_id, fecha, hora, motivo, modalidad, turno, edad, sexo) FROM stdin;
14	4	5	2025-12-28	22:41:00	Pérdida de peso 	Presencial	NOCHE	13	M
\.


--
-- TOC entry 5026 (class 0 OID 32768)
-- Dependencies: 225
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.alembic_version (version_num) FROM stdin;
07ba076d9688
\.


--
-- TOC entry 5025 (class 0 OID 24598)
-- Dependencies: 224
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.consulta (id, paciente_id, resumen, firma_img, firma_cripto, fecha) FROM stdin;
\.


--
-- TOC entry 5028 (class 0 OID 32814)
-- Dependencies: 227
-- Data for Name: doctores; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.doctores (id, nombre, especialidad, telefono, cedula, turno, user_id) FROM stdin;
5	Juan Perez	Nutri	0000000	12345	Ambos	\N
\.


--
-- TOC entry 5023 (class 0 OID 24590)
-- Dependencies: 222
-- Data for Name: pacientes; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.pacientes (id, nombre, cedula, telefono, edad, notas, sexo) FROM stdin;
4	Lucio Bernal	123456	1234567890	23	Hola bbbbb	M
11	Maria Ayala	3456789	0994567890	22	Consulta sobre obesidad 	M
\.


--
-- TOC entry 5034 (class 0 OID 57368)
-- Dependencies: 233
-- Data for Name: recetario; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.recetario (id, paciente_id, titulo, descripcion, archivo, fecha_subida) FROM stdin;
\.


--
-- TOC entry 5021 (class 0 OID 24580)
-- Dependencies: 220
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public."user" (id, username, password) FROM stdin;
2	Domiciano Galeano	scrypt:32768:8:1$qNcVxubjn2tedXCq$2cf359fbdae7cbea696f2975cd1913dabad817082694ef4b2d16c8f963554342660378fc64ae7b5d3758638ed3cebabdc769ce2e0061a624e9fbf185f82150b0
3	Wilson Caballero	scrypt:32768:8:1$rc2D7UAvc3zlTuod$a7f07b7c6ac4d06ae83b1158cb9c9fec6ed28395fdad0517d73bbb4cf955ffd93741ed6087334f76c8210f3a62fcba1840fd1e1439a4e5e39981790f89e352b9
1	Victor Ayala	scrypt:32768:8:1$nYKUPjsIm4087xif$2062e760ec763cb78c0c89469282e7cf94c14ad3e50ee48e98cf2942c5feed8e29e95ff278e9a6405dcaf8cfa698950e63b96b0772a66a832df5c5655c8bbfad
4	Luis Perez	scrypt:32768:8:1$X12HeY8ZDr2fTvY2$174e38d0dfbb5d65b11724e1955f3297cdd9d7a9a89e89ff383135d157b26909cc758a40b366036cddc212e7e1a0d5349cf631a536667fac648aabe93347dc17
\.


--
-- TOC entry 5032 (class 0 OID 49153)
-- Dependencies: 231
-- Data for Name: visitas; Type: TABLE DATA; Schema: public; Owner: nutripy_admin
--

COPY public.visitas (id, paciente_id, paciente_nombre, edad, sexo, doctor_id, doctor_nombre, turno, modalidad, fecha, hora, motivo, firma_img, firma_cripto) FROM stdin;
7	4	Lucio Bernal	34	M	5	Juan Perez	MAÑANA	Presencial	2025-12-24	18:40:00	Consulta rutinaria del mes	data:image/png;base64,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
8	4	Lucio Bernal	34	M	5	Juan Perez	Tarde	Presencial	2025-12-24	23:14:00	Consulta aaaa	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAACWCAYAAADwkd5lAAAQAElEQVR4AezdPchs3VUH8FFSWFgYMGAgokLApFILIQFFrcTKtzCgNiqvhZ0JKsFKrVSi+FrYRVSiRDGgKYSAgkoCERQ0lYKCn2DEgEFFUgjJ/j33WTc7587MM8/M+Z7/5azZ32ut/d+X9Z+9z5nzfPkh/4JAEAgCQSAIXIFACOQK0DIkCASBIBAEDocQSP4XBIGlEIjdILBxBEIgG1/AuB8EgkAQWAqBEMhSyMduEAgCQWDjCGyYQDaOfNwPAkEgCGwcgRDIxhcw7geBIBAElkIgBLIU8rEbBDaMQFwPAhAIgUAhEgSCQBAIAs9GIATybMgyIAgEgSAQBCAQAoHC3BJ7QSAIBIEdIBAC2cEiZgpBIAgEgSUQCIEsgXpsBoEgsBQCsTsiAiGQEcGMqiAQBILAPSEQArmn1c5cg0AQCAIjIhACGRHMe1CVOQaBIBAECoEQSCGRNAgEgSAQBJ6FQAjkWXClcxAIAkFgKQTWZzcEsr41iUdBIAgEgU0gEALZxDLFySAQBILA+hAIgaxvTeLRNAhEaxAIAiMjEAIZGdCoCwJBIAjcCwIhkHtZ6cwzCASBIDAyAhcTyMh2oy4IBIEgEAQ2jkAIZOMLGPeDQBAIAkshEAJZCvnYDQIXI5COQWCdCIRA1rku8SoIBIEgsHoEQiCrX6I4GASCQBBYJwL3QCDrRD5eBYEgEAQ2jkAIZOMLGPeDQBAIAkshEAJZCvnYDQL3gEDmuGsEQiC7Xt5MLggEgSAwHQIhkOmwjeYgEASCwK4RCIGsennjXBAIAkFgvQiEQNa7NvEsCASBILBqBEIgq16eOBcEgsBSCMTu0wiEQJ7GKD2CQBAIAkHgCAIhkCOgpCoIBIEgEASeRiAE8jRG6XENAhkTBILA7hEIgex+iTPBIBAEgsA0CIRApsE1WoNAEAgCSyEwm90QyGxQx1AQCAJBYF8IhED2tZ6ZTRAIAkFgNgRCILNBvVtDX99m9p1NfrLJG01+uMnPnhBt+pLWZZ1XvAoCQeAyBEIgl+GUXq8igCT+sVWTP23pB5r8eJPfaPIzJ0SbvsQ4oi6E0gDLFQS2hkAIZGsrtg5/kQeSsPsojz7bMp9p8mdN/mkgrfjKZSyxK+kJxS7GbkY9YiH6vaIgFUEgCCyLwPgEsux8Yn16BH6hmUAeLTkgim84HA5fdjgc3tzkLU2+q4m6XrSXqP+R1ufnmvxmk7qQBLGLsZuxM0EsxE6lRD1yqXFJg0AQWAiBEMhCwG/UrAD//s7332p5JNKSiy/9EYddDCJBLEUq6u1kPn1EG9sEeSARhELHka6pCgJBYA4EQiBzoDydDbuBf2/qP9hkjksALzuOq8YK4EUqCMVO5q3NCFIh6hCLo7FW/fLii50QInHM9bLhjjOZehCYFYEQyKxwj27sJ5rGr2nyQ03muPpA/WsTG0QqBHkgkToak+/JBJHYkdxCZnQQuxt6SpTNmUw83agPAttDIASyvTXrPX7TY+Fzj+nUiW/8ZUNgr/xcaREKMnEPpewK/nyzGxH8q/5Yqi9CsGv7/dbBmBJERE+JsnswpO+jvsilqcgVBO4TgRBIt+4bzjpOmtr9PjAL5GRqm+f088cR16VEov/nm0JEgBBeb/nva4JQWvJwmZPdDXIsUVavH0EcBInQUzrpVceOdiT1oDQfQWCvCIRAtruygll5L0+qPHXq5vnUNi7RL7AL2IhEoK8xsPA0V5UFeruKKkvdrP9YyyAgO5q6mS/vmKxEmX4irx65/F0bWzf72SOIgx1EwiZSkfIxhNIAy7UvBEIg+1rPKWcjMJb+PlhX3ZIpIqngXn58VcsI6oJ5BW9+64cs3Kz/ntZHcFffsmcvNvRDHkjkna133eynU502fVrTw8U+27BDJAiFvYfGfPQIJL9FBEIgW1y1Fz4LVi9yLz7/sCW+AQtaLTvp1QfJSQ09UzlMBPoa5pFjmCirF+jH9p1eOtlGImzYrRC7G23sE2uDTEIk0IhsHoEQyHaX8BsHrn9TK/u2LTgRed9+W/Wol4A5qsKRlfXHaz/W6Rbcu+KkWRgRu40iFPaLTEIkk8If5XMhEAKZC+nx7Ag+ApPHd0vrMNXHN2/HJv/ZGpVbcvXVj+/zVyuccKCdgODdm3C/o4J3Xz9Xnj/8QiYhkrlQj53JEQiBTA7xaAaQhp0FcQxyqeKvbh0/1ORY4LdD+f7WJkU40lZ85RIAq3KOJ77K1jUpX4dk8avXKJpoTE8kfGXG2lhTa3tqDfSLBIFVIRACWdVynHRGcBdgBJpTnf68NQhOw+DZqg/f1j7oaMnDRc+/tpwdyocfU0deyoKY9lZ99HJz+mjDiiuR79rcs1Z2JO6TlG9wrzUIkRQqa0/v2L8QyPoXX1AR3HtP65trX4c4HI8ISm7gfrRvbHkEhERK39ta3bFLOxLpg6666vuJyqw47YOvQL1WV60jnK3XMSJBJsh/rf7HrztHIASy/v8AfzxwsQhC8Bk0vSxqe62V+qDUigevPEEkfYBVf0z0s0vRhnikxE5HulZBdqT8++fKrDi1XseIxDp9vPndz6cVcwWBdSAQAlnHOpzyQuB4e9f4kZa302jJRZeg1H8DF5B6MqAEISAaIpCpK7FLcY/kO6qipXS2ZKxrdD3v7TS6eb52fzt3D/Dnrx1J/zSZHeFw3Q75FwSWRiAEsvQKnLc/DBrv6boLNl3xZBZBnGpERkhF0CJ2N4ik7/+uVtCnJYdLbR4W/Ndj9jcL+nGLaTibR78WjjGt0S16MzYIjIpACGRUOCdVJqj0Boblvq3Pn+uHGHy7LXHm7pirH/ODvbKWF8QEN2NbcXWXd1OVU5+qzEZTWPck4lhRnZ3pRqcUt9eEwK2+hEBuRXDa8YJ5WeiPNNQNdxZ90Nd+qQhGx6TG+yuDlddPEPNtGNkgnrUFtP4psTfK8Q2n8LVTrCkU/tai6pIGgUUQCIEsAvtFRgUIUp37IFJ1fTokEDsEYwT6vl+fd8TjHgnRlwz19P2Hef4JaGwgFeVhnznLQ/vD8py+jGnL0aI1Kp3WFuZ7mV/NK+nGEAiBrHfBBIneO8G9L/9DX2j5PvAbK8D0N79bl1eu97Uaj/4SQYq4gdsfm/Q/wvvf1n/oR6s6CGSOtdhckkjM+zDbv3kNWaN+jQvzeb2ItSDQIRAC6cBYWVaAOOfSv51oFMAF8mr22vHKX5raVVRfx0AVuL6yVQpk3maLaPpvxa3pwGdE4mjLH2s6zPyP/ZlNzmoO5rUWDFsneMtHgsDsCIRAZof8YoN9oLhkkP7Oy/uAYkfhleWnxhszbOvH23Ho0+86KkirRyaCWr9jKX3+WJNHgKu8RNr7vYT9KWzCG/alG4lUPmkQmBWBBQlk1nnuwVgF7lNz0V7BRIBBHgJoTwjDsfoN6/pjr19+bOxv2LPzWP2Q0IG4BLYhkfx86zHs36omu76u08yvrrirbP9ABXzPrfGuJp7JrAuBEMi61qP3ZniPo287lu+DiACDPASXIpVjY47V9Xro0KcPxj3BaCvRB5H090zY3/N9iZr73Cmc4V12+6f1qi5pEJgcgRDI5BBfbaD/Bbo/ndoHDEoFZ2nJ91ampRX4h/coPHXVml9eQx09eehUeipV9w4fZ8QvwXtfTxHOGRWjNPU+jKJwZUr63R6SHq7lWXfTGATGQCAEMgaK0+joA8IlN8K/uXNDwDd+GLx/p+tzLNvvVobk87nHAef+Dsljl8Magnf/e5DDDv9Znx7nIfnvcMqZ0toQCIGsbUW+6E8f/PtAUT2QxLH6ejqrfxLLGMda1aY8FMciSKfq+2+46n7XRxN9SMtedC31MsOvuMi7bXfyf6Bm8N2VSRoE5kIgBHIN0usZ0weQ8urXW2ZIBojGN9RhUFXfuh8cgQx3H9V2ePyHgB6zB7oOJ/4hF/qq+ZiP1TZ2ynbp/L3K7Djt18Q7y/Lq9x0v9hqnFgJZ46q88KkP4H1gfNH64tMuoe+n1r2Qngy0e0JKW69HvToy3K3Qq74XRFBjzt207W304+fI938tsXydw+5SNqzJ/3fG+/tmXXWyQWAaBEIg0+A6htZzj86WfkFy+Iej+nsh+vmthnQoxqr7pI9OPP5bbV31Q7a+8SIJ8lA5+BjWn9I1GDZ6cSm7o0/kCYW/3bX3x55d9a6ymcyKEAiBrGgxBq70AVBQJoMuD8W/ePg8/oEMfEut1v53EuocRTn6kCduzPb91fXSt/W7nL7PMH/K72G/Mcr9N/De1zF0r1XHJV801up7/No4AiGQ9S5gTyCOKU4F4v6x2v9u07HjcGTldSPngqjjHq89aUMeLk9ZGftQOPFBX/mFfI75NKyr/idUjlpdtv9vVK1RFgSCwFEEQiBHYVlFpcBbj+++qXl06r5Df2zxK62fXYSxLfvq1dV41UhXPJx75Unfr78/gkT6NvnhLucSX4y7VZBHPbr7l7cq29B48y53+91I1SUNApMhEAKZDNpRFP9ip0WwtmPwfilPORHNfQCxQ1B3Sv7jRANSeGpsDe0JyjFWb1+fvjwXebALGym5dC76bl2sQc3B2lQ+aRCYHIEQyOQQ32RAIOyDMBL5cNPoqSnirbdva+W6BNH/aQX18h7nlforfeT9rW14saHfsP5cuW6m68OPnjSK2LT1/ZSnEjbJVPq3oNcRZP9/ZQs+35mP+5tuCGTdayog2B2c8lLgdrxV7cpeuS5FNr6dSqt9mDrycKN9WP9UGeHwTb+yJSXqSrzNt/JTpkiMfkFUWr7J71l6vPvd6p7nnLmtCIEQyIoW44QrjiXcFD/3tNWJoU9W25U82elEB8RTgRpRkeF9FTfqTwwfrRqZlbJ611cfWKttj2n/5cD/kz3OMXNaMQIhkBUvTueaQP3uVv6BJgIFcfTUil9yeVWJ34Vo12AcsYvxltyfapV0tOThuuS9Vg8dj3zQ66ktqWbB7HWZTqqtq7o6e2wgokBc2syxHkk+ho0+exJHdjV3850a6z1hl7mMhEAIZCQgZ1LjfVSCNrEDsDMp0x9pma9t8loT7R7j1U58S/eW3F9qbXR4LLhlDx4BFoTlrxGBix8VvOi7Rs+1Y/7gcSD75ihVdcucjF+7mF8d25mzNVi7z/FvhwiEQLa9qL711wz+qDIXpH/S9XHDXUDqqp6VFcCQVB0f1eDPtgyCackkl4cD6lf3Pz2wwKdB1a6KRR4m5cuCNBIEpkPghOYQyAlgNlLd/zakjq0ucd1vPvogKyDdQiKOU4a7D7/JsCu4Re+puSCPIk8B1K7qVN+91fdr5UhySpLeG3aZz8gIhEBGBnRD6hx7FIkI8hWU5S+dhr4CGunf9FtPQzmj/1BThmBaMspFV5EH0iSlmD+V32Nqjczf3BCnI0n5SBBYBIEQyCKwT2L0ucETefS/0xCYBChHWn5LIm8HIVhrk//r5vl/NfH0FtFXW6v6kuudreSmdksOXjGOYPSlkz711whbdBnrD5e50gAACNNJREFUm7cgKr9yGcU9+Bd2SJOMojhKgsC1CIRArkVuHeN6AvBt/7leCUqCMDLpx/otiWBFp6AvaMu75+Boqu/b5+t3JfTR/b7WWI8fIzg66UM+dCq3LhddPXnQbwc1HKh+WLeHMszgby73RpzmHFkpAiGQlS7MhW4JJtW1HmGt8qWpb7JuggvI9NXx06Xj9bPboEOQp0MdeaN9ePxYG6Jiq1U9XPoKjLUzUX5oOPKBaBCOJiRBl/wpQVan2rZUDxPzNn9+w886yUeCwOIIbIFAFgdpxQ4IpuWem9gVaKruOanALzg5fpIK0gKWenaIR4X9xUNtRD+PC9ttaD9lTxtdxuhvHNLRX7Dnt0CJTOgSOKtNPaJRpocOPinvVQoPcy8sYGbue51z5rVBBEIgG1y0zmUB9dNdWaAVkLuqZ2fpFKAr4AtcdhDkPU3bjzbRRvRrxWdfxiEKOgVFuijhu6MagdO9FoRSAdRjwnzhn37Vv1J1f6XQpH9DcStu5irisI41b9ggXZhtZiJx9D4QCIFsf50dEQmqNRPBRzCt8ppTfguQSASZeCxVHZ+H91rcf0EoJe6jyFcqX69S8cZiZUQED2QlOAvKa8OGP3zjL1/5aP52aDCBjfIyEqtB4AwCIZAz4GykScDtb6YLQALSRtx/cNOTWnz+QCsJqC05eI+WXYdv3uZI1JdUWUrcrP+Xx0YvmKSnsLCrEZwRikDdk446bSVFNvwpoacXuh9NXZwYQx/9bPKB8Idt7eaKMOw49DOviw2kYxCYG4EQyNyIT2NPsPFNvrQLmOoEpapbW8o3PgqgH2/O8bklB0HTt++3HA6Hb2ni2Mo3cSKwllRZSuzE6oeVCOTbH8cKyAQ+AjRhg32CGAT2En4I6L0I+L3wuYK/+upbOqTmRrRXX/3oZ7O593B5f9knWs48CT9bMVcQWD8CIZBJ12hW5YKkwFhGBSoBSzATKKt+6VTw5JcgzMfyzatPEAcyEHiv8bPIwdi3tw9lAZnAR4AmbPSiTnsJP4ZChzoPEnzsUXdLDuYDY2JeJeZGtB/aP2tjPGGPfWTo/WXIjq+tW64gsB0EQiDbWatLPBWYBKrqK3gJaIK1oFzButrnSNkUXNn3Tdw3cmW2+VoB9c2tQp+W3HRVIGb3nCK2S4xBECX8GApyUedBAq+CgTUSKNE+lOqDKPQznrDH9jn/0hYEVo9ACGT1S/QsBwUlgUoglO8H+zaMSP6+VSIVQRzBkFb17EuArnsXgmIvSIIgDDbZY7+M8A1x8NU4AbXabk39mJGOuZ7EMhcC86GYlzb+RGZGIOamRyAEMj3GS1jwTVhwlg6DmKMd5CGoC/KkAr28eu0EuUiJQE/0QQrEvQv9kUMvxpF+7gIp0ui/jfftY+UFcbrYR3LykSAQBCZAIAQyAagrUimY1jEKMhHET7kn2Aq6yAIpEGQhJUUQ+uhbevwOhV5EVcIusiDsT00a5Uul/JHnqzQSBILABAiEQCYAdaUqBXW7khKEQtQL/BV0X7h//FMfghiMRQxvbV3pRBQl2uxWCN2ty6xXPdY81zHWrJOLsSCwFgRCIGtZifn8QAAEcRDBXuBHAiXqehm2IwZj5/P6eZaKtPqd0vM0pHcQCAJPIhACeRKiu+qAWAhy6EVAVr8VMMpfR1ghka2sWvwsBDaThkA2s1Rx9JkIIBFDkIg0EgSCwMgIhEBGBjTqVoPA3I/zrmbicSQIzIVACGQupGNnNgQeDTmCc+yWI6xHQJIEgbERCIGMjWj0rQ0BR1ghkbWtSvzZBQIhkF0sYyZxAoFPPdb7bctjdrLEk2l+kOm3MyGsyWCO4jUh8CqBrMm7+BIEbkPgvW24Yyw/ghTgW3Gyq94EbMdDJjMUxUFgLQiEQNayEvFjCgSQh9+wSJHIXDuD/IBxitWMztUhEAJZ3ZLEoZERQB71y/Qpj5fYKdevJaoanzQIbAKBEMgmlilO3oiA4yu/CxHY57gfcqO7GR4EtoFACGQb6xQvb0fAq1nsEhxlIRRkcrvWFxro6u971G9QXrTmMwjsFIFdEchO1yjTGgcB5OEoS4pEvGHYbkTwv9UCPb0Ov0Hpy8kHgV0iEALZ5bJmUicQsPOonYgdAxLxd00+2fp/sMk1ZGIMQmrDHy4ERR4K+QgCe0YgBLLn1c3cjiHgXoi3DheR6POu9vF6EzfZkUzLPnkhDn0RUN/Zq+778p3kM817RCAEco+rnjlDwDETIvGY70dbhT+MhRTsJpACMiF/29qqbMeCNIg6fVvzy+szLUdvS3IFgf0jEALZ/xpnhucRsCN5rXV5d5PaPSASR1zkHa2+yu51IA3Sql9eyMeN8299WZNMELgDBEIg61jkeLE8Au5b2FnYlSASxPKUV8bo668yIhvlp8akPQjsBoEQyG6WMhMZCQEkgEgcbfmTvQiFKLtvQpCGsnp9RzIdNUFgWwiEQLa1XvF2fgQQCrEjcX+DIA3l+b2JxfERiMarEQiBXA1dBgaBIBAE7huBEMh9r39mHwSCQBC4GoEQyNXQZeALBPIZBILAvSIQArnXlc+8g0AQCAI3IhACuRHADA8CQSAILIXA0nZDIEuvQOwHgSAQBDaKQAhkowsXt4NAEAgCSyMQAll6BWJ/OQRiOQgEgZsQCIHcBF8GB4EgEATuF4EQyP2ufWYeBIJAELgJgRsI5Ca7GRwEgkAQCAIbRyAEsvEFjPtBIAgEgaUQCIEshXzsBoEbEMjQILAGBEIga1iF+BAEgkAQ2CACIZANLlpcDgJBIAisAYH7JJA1IB8fgkAQCAIbRyAEsvEFjPtBIAgEgaUQCIEshXzsBoH7RCCz3hECIZAdLWamEgSCQBCYE4EQyJxox1YQCAJBYEcIhEA2tphxNwgEgSCwFgRCIGtZifgRBIJAENgYAiGQjS1Y3A0CQWApBGJ3iEAIZIhIykEgCASBIHARAiGQi2BKpyAQBIJAEBgiEAIZIpLyVAhEbxAIAjtDIASyswXNdIJAEAgCcyHwBQAAAP//rTH1UAAAAAZJREFUAwAWoqRaWDkrJAAAAABJRU5ErkJggg==	C9LZetCcnRLZLVL5nIif8wthYGAR0+398WcLUAQNZhuVR2Rhc3JWvgiKyv7cyHhL2DCw7ooTPd/KkOzUj5s9fiLLVzPYhu1YxTpz8K4PcvEEheDb1OMWvzoBH58izd9/SeWLOjunjHohxVJEsTHfDmyBx/Wp/oiKUYui70XEaRgUExIOTHGeFcu9wAeVRLaU7A4Z8kuXRzCU4vw4otcYwIelunlzUQt2ewK5nbM7GqSMJ2nSJc870E9T+If3/Jqy8Hc4P/dps+XAKCV2q553Bw3H65/XgzRyJM2K7CYgrYGOsLez3zL0Ql1qinVYfN8Ie9V5sJVDy3D60sjnMzZj8A==
\.


--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 228
-- Name: agenda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.agenda_id_seq', 14, true);


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 223
-- Name: consulta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.consulta_id_seq', 1, false);


--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 226
-- Name: doctores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.doctores_id_seq', 6, true);


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 221
-- Name: paciente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.paciente_id_seq', 21, true);


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 232
-- Name: recetario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.recetario_id_seq', 5, true);


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.user_id_seq', 4, true);


--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 230
-- Name: visitas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nutripy_admin
--

SELECT pg_catalog.setval('public.visitas_id_seq', 8, true);


--
-- TOC entry 4863 (class 2606 OID 32935)
-- Name: agenda agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id);


--
-- TOC entry 4859 (class 2606 OID 32773)
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- TOC entry 4857 (class 2606 OID 24606)
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id);


--
-- TOC entry 4861 (class 2606 OID 32822)
-- Name: doctores doctores_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.doctores
    ADD CONSTRAINT doctores_pkey PRIMARY KEY (id);


--
-- TOC entry 4855 (class 2606 OID 24596)
-- Name: pacientes paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.pacientes
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id);


--
-- TOC entry 4867 (class 2606 OID 57379)
-- Name: recetario recetario_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.recetario
    ADD CONSTRAINT recetario_pkey PRIMARY KEY (id);


--
-- TOC entry 4851 (class 2606 OID 24586)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- TOC entry 4853 (class 2606 OID 24588)
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- TOC entry 4865 (class 2606 OID 49172)
-- Name: visitas visitas_pkey; Type: CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.visitas
    ADD CONSTRAINT visitas_pkey PRIMARY KEY (id);


--
-- TOC entry 4870 (class 2606 OID 32936)
-- Name: agenda agenda_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctores(id);


--
-- TOC entry 4871 (class 2606 OID 57344)
-- Name: agenda agenda_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.pacientes(id) ON DELETE CASCADE;


--
-- TOC entry 4868 (class 2606 OID 24607)
-- Name: consulta consulta_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.pacientes(id);


--
-- TOC entry 4869 (class 2606 OID 65536)
-- Name: doctores doctores_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.doctores
    ADD CONSTRAINT doctores_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- TOC entry 4872 (class 2606 OID 65541)
-- Name: recetario recetario_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nutripy_admin
--

ALTER TABLE ONLY public.recetario
    ADD CONSTRAINT recetario_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.pacientes(id) ON DELETE CASCADE;


--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO nutripy_admin;


-- Completed on 2025-12-22 23:04:44

--
-- PostgreSQL database dump complete
--

\unrestrict nOX2BpIf2hJzvAgRHqhdHMe5xkx6L1z6VRlykLGPgL3deFXeGqKiw6iu00wlE9x

