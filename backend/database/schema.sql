--
-- PostgreSQL database dump
--

\restrict u903hDAFh8bx3eM4fcjHyQbPCmZ2hHRATzDelLQbV61BtZVhnTXs6LhgRQAkvLQ

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    province character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_id_seq OWNED BY public.cities.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    office_name character varying(255) NOT NULL,
    address text,
    city character varying(255),
    contact_phone character varying(255),
    pic_name character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection character varying(255) NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    merchant_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    invoice_number character varying(50) NOT NULL,
    issued_at timestamp(0) without time zone NOT NULL,
    due_date date,
    total_amount numeric(12,2) NOT NULL,
    status character varying(255) DEFAULT 'unpaid'::character varying NOT NULL,
    paid_at date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT invoices_status_check CHECK (((status)::text = ANY ((ARRAY['unpaid'::character varying, 'paid'::character varying, 'cancelled'::character varying])::text[])))
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menus (
    id bigint NOT NULL,
    merchant_id bigint NOT NULL,
    category_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    price numeric(12,2) NOT NULL,
    photo_path character varying(255) NOT NULL,
    is_available boolean DEFAULT true NOT NULL,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;


--
-- Name: merchants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.merchants (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    company_name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    address character varying(255),
    city character varying(255),
    contact_phone character varying(255),
    contact_email character varying(255),
    description character varying(255),
    logo_path character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    min_order_pax integer DEFAULT 10 NOT NULL,
    total_orders integer DEFAULT 0 NOT NULL,
    rating_avg numeric(2,1) DEFAULT '0'::numeric NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL
);


--
-- Name: merchants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.merchants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merchants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.merchants_id_seq OWNED BY public.merchants.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    menu_id bigint NOT NULL,
    menu_name character varying(255) NOT NULL,
    price numeric(12,2) NOT NULL,
    quantity integer NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    merchant_id bigint NOT NULL,
    delivery_date date NOT NULL,
    delivery_address text NOT NULL,
    notes text,
    total_amount numeric(12,2) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'confirmed'::character varying, 'delivered'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    merchant_id bigint NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    role character varying(255) NOT NULL,
    phone character varying(20),
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['merchant'::character varying, 'customer'::character varying])::text[])))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: cities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN id SET DEFAULT nextval('public.cities_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: menus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus ALTER COLUMN id SET DEFAULT nextval('public.menus_id_seq'::regclass);


--
-- Name: merchants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants ALTER COLUMN id SET DEFAULT nextval('public.merchants_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (1, 'Nasi Box', 'nasi-box', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (2, 'Prasmanan', 'prasmanan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (3, 'Vegetarian', 'vegetarian', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (4, 'Snack', 'snack', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (5, 'Jajanan Pasar', 'jajanan-pasar', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (6, 'Minuman', 'minuman', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (7, 'Paket Diet', 'paket-diet', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (8, 'Seafood', 'seafood', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (9, 'Bakery', 'bakery', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.categories (id, name, slug, created_at, updated_at) VALUES (10, 'Tumpeng', 'tumpeng', '2026-10-09 00:15:26', '2026-10-09 00:15:26');


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (1, 'Banda Aceh', 'Aceh', '2026-10-09 00:15:25', '2026-10-09 00:15:25');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (2, 'Sabang', 'Aceh', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (3, 'Langsa', 'Aceh', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (4, 'Lhokseumawe', 'Aceh', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (5, 'Subulussalam', 'Aceh', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (6, 'Medan', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (7, 'Binjai', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (8, 'Tebing Tinggi', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (9, 'Pematangsiantar', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (10, 'Tanjungbalai', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (11, 'Sibolga', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (12, 'Padangsidempuan', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (13, 'Gunungsitoli', 'Sumatera Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (14, 'Padang', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (15, 'Bukittinggi', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (16, 'Padang Panjang', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (17, 'Pariaman', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (18, 'Payakumbuh', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (19, 'Sawahlunto', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (20, 'Solok', 'Sumatera Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (21, 'Pekanbaru', 'Riau', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (22, 'Dumai', 'Riau', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (23, 'Batam', 'Kepulauan Riau', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (24, 'Tanjungpinang', 'Kepulauan Riau', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (25, 'Jambi', 'Jambi', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (26, 'Sungai Penuh', 'Jambi', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (27, 'Palembang', 'Sumatera Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (28, 'Lubuklinggau', 'Sumatera Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (29, 'Pagar Alam', 'Sumatera Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (30, 'Prabumulih', 'Sumatera Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (31, 'Pangkalpinang', 'Kepulauan Bangka Belitung', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (32, 'Bengkulu', 'Bengkulu', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (33, 'Bandar Lampung', 'Lampung', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (34, 'Metro', 'Lampung', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (35, 'Jakarta Pusat', 'DKI Jakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (36, 'Jakarta Utara', 'DKI Jakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (37, 'Jakarta Barat', 'DKI Jakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (38, 'Jakarta Selatan', 'DKI Jakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (39, 'Jakarta Timur', 'DKI Jakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (40, 'Bandung', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (41, 'Banjar', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (42, 'Bekasi', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (43, 'Bogor', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (44, 'Cimahi', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (45, 'Cirebon', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (46, 'Depok', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (47, 'Sukabumi', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (48, 'Tasikmalaya', 'Jawa Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (49, 'Semarang', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (50, 'Magelang', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (51, 'Pekalongan', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (52, 'Salatiga', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (53, 'Surakarta', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (54, 'Tegal', 'Jawa Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (55, 'Yogyakarta', 'DI Yogyakarta', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (56, 'Surabaya', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (57, 'Batu', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (58, 'Blitar', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (59, 'Kediri', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (60, 'Madiun', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (61, 'Malang', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (62, 'Mojokerto', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (63, 'Pasuruan', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (64, 'Probolinggo', 'Jawa Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (65, 'Serang', 'Banten', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (66, 'Cilegon', 'Banten', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (67, 'Tangerang', 'Banten', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (68, 'Tangerang Selatan', 'Banten', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (69, 'Denpasar', 'Bali', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (70, 'Mataram', 'Nusa Tenggara Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (71, 'Bima', 'Nusa Tenggara Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (72, 'Kupang', 'Nusa Tenggara Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (73, 'Pontianak', 'Kalimantan Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (74, 'Singkawang', 'Kalimantan Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (75, 'Palangka Raya', 'Kalimantan Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (76, 'Banjarmasin', 'Kalimantan Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (77, 'Banjarbaru', 'Kalimantan Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (78, 'Balikpapan', 'Kalimantan Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (79, 'Samarinda', 'Kalimantan Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (80, 'Bontang', 'Kalimantan Timur', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (81, 'Tarakan', 'Kalimantan Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (82, 'Manado', 'Sulawesi Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (83, 'Bitung', 'Sulawesi Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (84, 'Tomohon', 'Sulawesi Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (85, 'Kotamobagu', 'Sulawesi Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (86, 'Gorontalo', 'Gorontalo', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (87, 'Palu', 'Sulawesi Tengah', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (88, 'Makassar', 'Sulawesi Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (89, 'Palopo', 'Sulawesi Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (90, 'Parepare', 'Sulawesi Selatan', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (91, 'Kendari', 'Sulawesi Tenggara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (92, 'Baubau', 'Sulawesi Tenggara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (93, 'Ambon', 'Maluku', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (94, 'Tual', 'Maluku', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (95, 'Ternate', 'Maluku Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (96, 'Tidore Kepulauan', 'Maluku Utara', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (97, 'Jayapura', 'Papua', '2026-10-09 00:15:26', '2026-10-09 00:15:26');
INSERT INTO public.cities (id, name, province, created_at, updated_at) VALUES (98, 'Sorong', 'Papua Barat', '2026-10-09 00:15:26', '2026-10-09 00:15:26');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (1, 11, 'PT Maju Jaya', 'Jl. Sudirman No. 25', 'Jakarta', '081298760001', 'Budi Santoso', '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (2, 12, 'PT Sentosa Abadi', 'Jl. Dago No. 11', 'Bandung', '081298760002', 'Siti Aminah', '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (3, 13, 'PT Cipta Karya', 'Jl. Darmo No. 30', 'Surabaya', '081298760003', 'Agus Wijaya', '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (4, 14, 'PT Mitra Sukses', 'Jl. Kaliurang No. 6', 'Yogyakarta', '081298760004', 'Dewi Lestari', '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (5, 15, 'PT Bina Usaha', 'Jl. Pahlawan No. 9', 'Semarang', '081298760005', 'Hendra Gunawan', '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (6, 16, 'PT Karya Mandiri', 'Jl. Imam Bonjol No. 14', 'Medan', '081298760006', 'Rina Marlina', '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (7, 17, 'PT Sumber Rejeki', 'Jl. Veteran No. 21', 'Makassar', '081298760007', 'Fajar Nugroho', '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (8, 18, 'PT Anugrah Sejati', 'Jl. Teuku Umar No. 17', 'Denpasar', '081298760008', 'Lina Kartika', '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (9, 19, 'PT Bumi Perkasa', 'Jl. R Sukamto No. 2', 'Palembang', '081298760009', 'Yoga Pratama', '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (10, 20, 'PT Cahaya Timur', 'Jl. Jendral Sudirman No. 13', 'Balikpapan', '081298760010', 'Maya Puspita', '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.customers (id, user_id, office_name, address, city, contact_phone, pic_name, created_at, updated_at) VALUES (11, 22, 'PT Rival Testing', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Jakarta', '081300000001', 'Rival', '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.favorites (id, customer_id, merchant_id, created_at, updated_at) VALUES (1, 11, 11, '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (1, 1, 'INV-20261009-0001', '2026-10-09 00:15:36', '2026-10-16', 110000.00, 'unpaid', NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (2, 2, 'INV-20261009-0002', '2026-10-09 00:15:36', '2026-10-16', 352000.00, 'paid', '2026-10-09', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (3, 3, 'INV-20261009-0003', '2026-10-09 00:15:36', '2026-10-16', 324000.00, 'unpaid', NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (4, 4, 'INV-20261009-0004', '2026-10-09 00:15:36', '2026-10-16', 455000.00, 'paid', '2026-10-09', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (5, 5, 'INV-20261009-0005', '2026-10-09 00:15:36', '2026-10-16', 518000.00, 'unpaid', NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (6, 6, 'INV-20261009-0006', '2026-10-09 00:15:36', '2026-10-16', 240000.00, 'paid', '2026-10-09', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (7, 7, 'INV-20261009-0007', '2026-10-09 00:15:36', '2026-10-16', 432000.00, 'unpaid', NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (8, 8, 'INV-20261009-0008', '2026-10-09 00:15:36', '2026-10-16', 629000.00, 'paid', '2026-10-09', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (9, 9, 'INV-20261009-0009', '2026-10-09 00:15:36', '2026-10-16', 324000.00, 'unpaid', NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (10, 10, 'INV-20261009-0010', '2026-10-09 00:15:36', '2026-10-16', 513000.00, 'paid', '2026-10-09', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (11, 11, 'INV-RIVAL-001', '2026-10-09 00:15:37', '2026-10-27', 9418000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (12, 12, 'INV-RIVAL-002', '2026-10-09 00:15:37', '2026-10-23', 512000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (13, 13, 'INV-RIVAL-003', '2026-10-09 00:15:37', '2026-10-21', 1007000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (14, 14, 'INV-RIVAL-004', '2026-10-09 00:15:37', '2026-10-27', 437000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (15, 15, 'INV-RIVAL-005', '2026-10-09 00:15:37', '2026-09-27', 1292000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (16, 16, 'INV-RIVAL-006', '2026-10-09 00:15:37', '2026-09-25', 808000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (17, 17, 'INV-RIVAL-007', '2026-10-09 00:15:37', '2026-09-25', 128000.00, 'paid', '2026-09-19', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (18, 18, 'INV-RIVAL-008', '2026-10-09 00:15:37', '2026-09-30', 683000.00, 'paid', '2026-09-24', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (19, 19, 'INV-RIVAL-009', '2026-10-09 00:15:37', '2026-09-16', 862000.00, 'unpaid', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.invoices (id, order_id, invoice_number, issued_at, due_date, total_amount, status, paid_at, created_at, updated_at) VALUES (20, 20, 'INV-RIVAL-010', '2026-10-09 00:15:37', '2026-10-10', 315000.00, 'cancelled', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (1, 1, 6, 'Es Teh & Jus Segar', 'Es teh manis dan jus buah segar dalam kemasan cup.', 11000.00, 'menus/minuman-segar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (2, 1, 1, 'Nasi Box Rendang Spesial', 'Nasi putih, rendang daging sapi premium, dan sambal ijo.', 32000.00, 'menus/nasi-box-rendang.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (3, 2, 7, 'Nasi Box Rendah Kalori', 'Nasi merah, ikan panggang, dan sayuran kukus untuk diet.', 27000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (4, 2, 8, 'Nasi Box Seafood', 'Nasi putih, cumi saus padang, udang goreng tepung, dan lalapan.', 35000.00, 'menus/nasi-box-seafood.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (5, 2, 8, 'Nasi Box Seafood Spesial', 'Nasi putih, aneka seafood saus padang, dan lalapan.', 37000.00, 'menus/nasi-box-seafood.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (6, 3, 4, 'Snack Box Rapat', 'Aneka camilan ringan dan air mineral untuk kebutuhan rapat.', 16000.00, 'menus/snack-box-kue-kering.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (7, 3, 7, 'Nasi Box Rendah Kalori', 'Nasi merah, ikan panggang, dan sayuran kukus untuk diet.', 27000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (8, 3, 8, 'Nasi Box Seafood Spesial', 'Nasi putih, aneka seafood saus padang, dan lalapan.', 37000.00, 'menus/nasi-box-seafood.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (9, 4, 5, 'Paket Jajanan Pasar', 'Aneka jajanan pasar tradisional: klepon, lemper, risoles.', 18000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (10, 4, 7, 'Nasi Box Rendah Kalori', 'Nasi merah, ikan panggang, dan sayuran kukus untuk diet.', 27000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (11, 5, 2, 'Paket Prasmanan Lengkap', 'Paket prasmanan untuk 30 orang: nasi, 3 lauk, sayur, buah, dan kerupuk.', 420000.00, 'menus/prasmanan-sederhana.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (12, 5, 9, 'Bakery Box Meeting', 'Aneka roti manis dan kue bakery untuk kebutuhan meeting.', 21000.00, 'menus/bakery-box.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (13, 5, 1, 'Nasi Box Ayam Bakar', 'Nasi putih, ayam bakar bumbu kecap, tempe, sambal, dan lalapan.', 25000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (14, 6, 2, 'Paket Prasmanan Sederhana', 'Paket prasmanan untuk 20 orang: nasi, 2 lauk, sayur, dan kerupuk.', 350000.00, 'menus/prasmanan-sederhana.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (15, 6, 4, 'Snack Box Kue Kering', 'Aneka kue kering dan air mineral dalam kemasan box.', 15000.00, 'menus/snack-box-kue-kering.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (16, 6, 5, 'Paket Jajanan Pasar', 'Aneka jajanan pasar tradisional: klepon, lemper, risoles.', 18000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (17, 6, 1, 'Nasi Box Ayam Kecap', 'Nasi putih, ayam kecap pedas manis, tempe, dan lalapan.', 24000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (18, 6, 8, 'Nasi Box Seafood', 'Nasi putih, cumi saus padang, udang goreng tepung, dan lalapan.', 35000.00, 'menus/nasi-box-seafood.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (19, 7, 5, 'Jajanan Pasar Komplit', 'Jajanan pasar lengkap: klepon, lemper, risoles, dan kue lapis.', 19000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (20, 7, 2, 'Paket Prasmanan Sederhana', 'Paket prasmanan untuk 20 orang: nasi, 2 lauk, sayur, dan kerupuk.', 350000.00, 'menus/prasmanan-sederhana.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (21, 7, 1, 'Nasi Box Rendang Spesial', 'Nasi putih, rendang daging sapi premium, dan sambal ijo.', 32000.00, 'menus/nasi-box-rendang.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (22, 8, 5, 'Paket Jajanan Pasar', 'Aneka jajanan pasar tradisional: klepon, lemper, risoles.', 18000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (23, 8, 6, 'Es Teh & Jus Segar', 'Es teh manis dan jus buah segar dalam kemasan cup.', 11000.00, 'menus/minuman-segar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (24, 8, 3, 'Nasi Box Vegetarian', 'Nasi putih, tahu tempe bacem, sayur lodeh, dan sambal.', 22000.00, 'menus/nasi-box-vegetarian.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (25, 8, 1, 'Nasi Box Ayam Bakar', 'Nasi putih, ayam bakar bumbu kecap, tempe, sambal, dan lalapan.', 25000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (26, 9, 3, 'Nasi Box Tahu Tempe', 'Nasi putih, tahu tempe goreng, orek tempe, dan lalapan.', 20000.00, 'menus/nasi-box-vegetarian.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (27, 9, 9, 'Bakery Box Meeting', 'Aneka roti manis dan kue bakery untuk kebutuhan meeting.', 21000.00, 'menus/bakery-box.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (28, 9, 5, 'Jajanan Pasar Komplit', 'Jajanan pasar lengkap: klepon, lemper, risoles, dan kue lapis.', 19000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (29, 9, 7, 'Nasi Box Rendah Kalori', 'Nasi merah, ikan panggang, dan sayuran kukus untuk diet.', 27000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (30, 10, 5, 'Jajanan Pasar Komplit', 'Jajanan pasar lengkap: klepon, lemper, risoles, dan kue lapis.', 19000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (31, 10, 6, 'Paket Minuman Segar', 'Es teh manis, es jeruk, dan air mineral kemasan.', 10000.00, 'menus/minuman-segar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (32, 10, 1, 'Nasi Box Ayam Kecap', 'Nasi putih, ayam kecap pedas manis, tempe, dan lalapan.', 24000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (33, 10, 7, 'Nasi Box Diet Sehat', 'Nasi merah, dada ayam panggang, dan sayuran kukus rendah kalori.', 28000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (34, 10, 1, 'Nasi Box Ayam Bakar', 'Nasi putih, ayam bakar bumbu kecap, tempe, sambal, dan lalapan.', 25000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (35, 11, 1, 'Nasi Box Ayam Geprek', 'Menu Nasi Box Ayam Geprek dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 23000.00, 'menus/nasi-box-ayam-bakar.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (36, 11, 1, 'Nasi Box Rendang Spesial', 'Menu Nasi Box Rendang Spesial dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 32000.00, 'menus/nasi-box-rendang.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (37, 11, 2, 'Prasmanan Syukuran', 'Menu Prasmanan Syukuran dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 380000.00, 'menus/prasmanan-sederhana.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (38, 11, 3, 'Nasi Box Tahu Tempe', 'Menu Nasi Box Tahu Tempe dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 20000.00, 'menus/nasi-box-vegetarian.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (39, 11, 4, 'Snack Box Rapat', 'Menu Snack Box Rapat dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 16000.00, 'menus/snack-box-kue-kering.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (40, 11, 5, 'Jajanan Pasar Komplit', 'Menu Jajanan Pasar Komplit dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 19000.00, 'menus/jajanan-pasar.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (41, 11, 6, 'Es Teh & Jus Segar', 'Menu Es Teh & Jus Segar dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 11000.00, 'menus/minuman-segar.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (42, 11, 7, 'Nasi Box Diet Sehat', 'Menu Nasi Box Diet Sehat dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 29000.00, 'menus/diet-sehat.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (43, 11, 8, 'Nasi Box Seafood Spesial', 'Menu Nasi Box Seafood Spesial dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 37000.00, 'menus/nasi-box-seafood.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.menus (id, merchant_id, category_id, name, description, price, photo_path, is_available, deleted_at, created_at, updated_at) VALUES (44, 11, 9, 'Bakery Box Meeting', 'Menu Bakery Box Meeting dari Katering Rival Testing, cocok untuk kebutuhan kantor.', 21000.00, 'menus/bakery-box.jpg', true, NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: merchants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (1, 1, 'Katering Berkah', 'katering-berkah', 'Jl. Merdeka No. 10', 'Jakarta', '081234560001', 'merchant1@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Jakarta.', 'merchants/logos/merchant-1.png', true, '2026-10-09 00:15:29', '2026-10-09 00:15:29', 10, 120, 4.8, 96);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (2, 2, 'Katering Sari Rasa', 'katering-sari-rasa', 'Jl. Asia Afrika No. 22', 'Bandung', '081234560002', 'merchant2@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Bandung.', 'merchants/logos/merchant-2.png', true, '2026-10-09 00:15:30', '2026-10-09 00:15:30', 15, 98, 4.7, 80);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (3, 3, 'Katering Nusantara', 'katering-nusantara', 'Jl. Pemuda No. 5', 'Surabaya', '081234560003', 'merchant3@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Surabaya.', 'merchants/logos/merchant-3.png', true, '2026-10-09 00:15:30', '2026-10-09 00:15:30', 10, 85, 4.6, 70);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (4, 4, 'Katering Dapur Ibu', 'katering-dapur-ibu', 'Jl. Malioboro No. 15', 'Yogyakarta', '081234560004', 'merchant4@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Yogyakarta.', 'merchants/logos/merchant-4.png', true, '2026-10-09 00:15:30', '2026-10-09 00:15:30', 20, 64, 4.5, 52);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (5, 5, 'Katering Rasa Nusantara', 'katering-rasa-nusantara', 'Jl. Pandanaran No. 8', 'Semarang', '081234560005', 'merchant5@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Semarang.', 'merchants/logos/merchant-5.png', true, '2026-10-09 00:15:31', '2026-10-09 00:15:31', 10, 72, 4.6, 58);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (6, 6, 'Katering Mitra Boga', 'katering-mitra-boga', 'Jl. Gatot Subroto No. 33', 'Medan', '081234560006', 'merchant6@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Medan.', 'merchants/logos/merchant-6.png', true, '2026-10-09 00:15:31', '2026-10-09 00:15:31', 25, 45, 4.3, 36);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (7, 7, 'Katering Sedap Malam', 'katering-sedap-malam', 'Jl. Pettarani No. 12', 'Makassar', '081234560007', 'merchant7@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Makassar.', 'merchants/logos/merchant-7.png', true, '2026-10-09 00:15:31', '2026-10-09 00:15:31', 15, 53, 4.4, 41);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (8, 8, 'Katering Bunda Catering', 'katering-bunda-catering', 'Jl. Sunset Road No. 7', 'Denpasar', '081234560008', 'merchant8@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Denpasar.', 'merchants/logos/merchant-8.png', true, '2026-10-09 00:15:32', '2026-10-09 00:15:32', 10, 39, 4.2, 30);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (9, 9, 'Katering Gurih Lezat', 'katering-gurih-lezat', 'Jl. Sudirman No. 19', 'Palembang', '081234560009', 'merchant9@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Palembang.', 'merchants/logos/merchant-9.png', true, '2026-10-09 00:15:32', '2026-10-09 00:15:32', 20, 28, 4.1, 22);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (10, 10, 'Katering Sejahtera', 'katering-sejahtera', 'Jl. MT Haryono No. 4', 'Balikpapan', '081234560010', 'merchant10@gmail.com', 'Katering harian untuk kantor dengan menu bervariasi di Balikpapan.', 'merchants/logos/merchant-10.png', true, '2026-10-09 00:15:32', '2026-10-09 00:15:32', 10, 17, 4.0, 13);
INSERT INTO public.merchants (id, user_id, company_name, slug, address, city, contact_phone, contact_email, description, logo_path, is_active, created_at, updated_at, min_order_pax, total_orders, rating_avg, rating_count) VALUES (11, 21, 'Katering Rival Testing', 'katering-rival-testing', 'Jl. Testing Raya No. 99', 'Jakarta', '081200000001', 'rival@merchant.com', 'Akun merchant khusus untuk testing fitur, berisi menu dan pesanan contoh.', 'merchants/logos/rival-merchant.png', true, '2026-10-09 00:15:37', '2026-10-09 00:15:37', 10, 999, 4.5, 2);


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.migrations (id, migration, batch) VALUES (1, '0001_01_01_000000_create_users_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (2, '0001_01_01_000001_create_cache_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (3, '0001_01_01_000002_create_jobs_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (4, '2026_10_07_051623_create_personal_access_tokens_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (5, '2026_10_07_154125_create_merchants_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (6, '2026_10_07_154551_create_customers_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (7, '2026_10_07_154833_create_categories_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (8, '2026_10_07_154948_create_menus_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (9, '2026_10_07_155447_create_orders_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (10, '2026_10_07_155902_create_order_items_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (11, '2026_10_07_160224_create_invoices_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (12, '2026_10_08_092957_fix_orders_status_check_constraint', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (13, '2026_10_08_094735_create_cities_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (14, '2026_10_08_121050_add_order_stats_to_merchants_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (15, '2026_10_08_121753_add_rating_stats_to_merchants_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (16, '2026_10_08_121754_create_reviews_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (17, '2026_10_08_121755_create_favorites_table', 1);


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (1, 1, 1, 'Es Teh & Jus Segar', 11000.00, 10, 110000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (2, 2, 2, 'Nasi Box Rendang Spesial', 32000.00, 11, 352000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (3, 3, 3, 'Nasi Box Rendah Kalori', 27000.00, 12, 324000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (4, 4, 4, 'Nasi Box Seafood', 35000.00, 13, 455000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (5, 5, 5, 'Nasi Box Seafood Spesial', 37000.00, 14, 518000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (6, 6, 6, 'Snack Box Rapat', 16000.00, 15, 240000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (7, 7, 7, 'Nasi Box Rendah Kalori', 27000.00, 16, 432000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (8, 8, 8, 'Nasi Box Seafood Spesial', 37000.00, 17, 629000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (9, 9, 9, 'Paket Jajanan Pasar', 18000.00, 18, 324000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (10, 10, 10, 'Nasi Box Rendah Kalori', 27000.00, 19, 513000.00, '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (11, 11, 36, 'Nasi Box Rendang Spesial', 32000.00, 12, 384000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (12, 11, 37, 'Prasmanan Syukuran', 380000.00, 23, 8740000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (13, 11, 44, 'Bakery Box Meeting', 21000.00, 14, 294000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (14, 12, 36, 'Nasi Box Rendang Spesial', 32000.00, 16, 512000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (15, 13, 40, 'Jajanan Pasar Komplit', 19000.00, 24, 456000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (16, 13, 42, 'Nasi Box Diet Sehat', 29000.00, 19, 551000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (17, 14, 40, 'Jajanan Pasar Komplit', 19000.00, 9, 171000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (18, 14, 41, 'Es Teh & Jus Segar', 11000.00, 11, 121000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (19, 14, 42, 'Nasi Box Diet Sehat', 29000.00, 5, 145000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (20, 15, 43, 'Nasi Box Seafood Spesial', 37000.00, 23, 851000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (21, 15, 44, 'Bakery Box Meeting', 21000.00, 21, 441000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (22, 16, 35, 'Nasi Box Ayam Geprek', 23000.00, 19, 437000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (23, 16, 41, 'Es Teh & Jus Segar', 11000.00, 10, 110000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (24, 16, 42, 'Nasi Box Diet Sehat', 29000.00, 9, 261000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (25, 17, 39, 'Snack Box Rapat', 16000.00, 8, 128000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (26, 18, 38, 'Nasi Box Tahu Tempe', 20000.00, 24, 480000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (27, 18, 42, 'Nasi Box Diet Sehat', 29000.00, 7, 203000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (28, 19, 35, 'Nasi Box Ayam Geprek', 23000.00, 16, 368000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (29, 19, 39, 'Snack Box Rapat', 16000.00, 20, 320000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (30, 19, 42, 'Nasi Box Diet Sehat', 29000.00, 6, 174000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.order_items (id, order_id, menu_id, menu_name, price, quantity, subtotal, created_at, updated_at) VALUES (31, 20, 44, 'Bakery Box Meeting', 21000.00, 15, 315000.00, '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (1, 1, 1, '2026-10-10', 'Jl. Sudirman No. 25', 'Tolong diantar sebelum jam 11 siang.', 110000.00, 'pending', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (2, 2, 1, '2026-10-11', 'Jl. Dago No. 11', 'Tolong diantar sebelum jam 11 siang.', 352000.00, 'confirmed', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (3, 3, 2, '2026-10-12', 'Jl. Darmo No. 30', 'Tolong diantar sebelum jam 11 siang.', 324000.00, 'delivered', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (4, 4, 2, '2026-10-13', 'Jl. Kaliurang No. 6', 'Tolong diantar sebelum jam 11 siang.', 455000.00, 'completed', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (5, 5, 2, '2026-10-14', 'Jl. Pahlawan No. 9', 'Tolong diantar sebelum jam 11 siang.', 518000.00, 'pending', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (6, 6, 3, '2026-10-15', 'Jl. Imam Bonjol No. 14', 'Tolong diantar sebelum jam 11 siang.', 240000.00, 'confirmed', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (7, 7, 3, '2026-10-16', 'Jl. Veteran No. 21', 'Tolong diantar sebelum jam 11 siang.', 432000.00, 'delivered', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (8, 8, 3, '2026-10-17', 'Jl. Teuku Umar No. 17', 'Tolong diantar sebelum jam 11 siang.', 629000.00, 'completed', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (9, 9, 4, '2026-10-18', 'Jl. R Sukamto No. 2', 'Tolong diantar sebelum jam 11 siang.', 324000.00, 'pending', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (10, 10, 4, '2026-10-19', 'Jl. Jendral Sudirman No. 13', 'Tolong diantar sebelum jam 11 siang.', 513000.00, 'confirmed', '2026-10-09 00:15:36', '2026-10-09 00:15:36');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (11, 11, 11, '2026-10-20', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Mohon sertakan sendok dan tisu.', 9418000.00, 'pending', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (12, 11, 11, '2026-10-16', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Mohon sertakan sendok dan tisu.', 512000.00, 'pending', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (13, 11, 11, '2026-10-14', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Tolong diantar sebelum jam 11 siang.', 1007000.00, 'confirmed', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (14, 11, 11, '2026-10-20', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Antar ke lobby lantai 1, hubungi satpam.', 437000.00, 'confirmed', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (15, 11, 11, '2026-09-20', 'Jl. Uji Coba No. 7, Jakarta Selatan', NULL, 1292000.00, 'delivered', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (16, 11, 11, '2026-09-18', 'Jl. Uji Coba No. 7, Jakarta Selatan', NULL, 808000.00, 'delivered', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (17, 11, 11, '2026-09-18', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Mohon sertakan sendok dan tisu.', 128000.00, 'completed', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (18, 11, 11, '2026-09-23', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Antar ke lobby lantai 1, hubungi satpam.', 683000.00, 'completed', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (19, 11, 11, '2026-09-09', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Antar ke lobby lantai 1, hubungi satpam.', 862000.00, 'completed', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.orders (id, customer_id, merchant_id, delivery_date, delivery_address, notes, total_amount, status, created_at, updated_at) VALUES (20, 11, 11, '2026-10-03', 'Jl. Uji Coba No. 7, Jakarta Selatan', 'Antar ke lobby lantai 1, hubungi satpam.', 315000.00, 'cancelled', '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.reviews (id, order_id, customer_id, merchant_id, rating, comment, created_at, updated_at) VALUES (1, 17, 11, 11, 5, 'Makanannya enak dan datang tepat waktu, recommended untuk katering kantor.', '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.reviews (id, order_id, customer_id, merchant_id, rating, comment, created_at, updated_at) VALUES (2, 18, 11, 11, 5, 'Makanannya enak dan datang tepat waktu, recommended untuk katering kantor.', '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (1, 'Katering Berkah', 'merchant1@gmail.com', NULL, '$2y$12$vDgLg/BGFKGzAo6yZWygHOwuzioijkJ3DSS2m7SSLjy82BwPOv/Ve', 'merchant', '081234560001', NULL, '2026-10-09 00:15:28', '2026-10-09 00:15:28');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (2, 'Katering Sari Rasa', 'merchant2@gmail.com', NULL, '$2y$12$0NFN9xrgapmP/RAC2fqFHOEMSfTy1oQ./7AOV5se4YIMjxjTPhSq.', 'merchant', '081234560002', NULL, '2026-10-09 00:15:30', '2026-10-09 00:15:30');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (3, 'Katering Nusantara', 'merchant3@gmail.com', NULL, '$2y$12$43tWerEmm0t.NkCtA3BTMe4J0oKHZGfdCD1v.cepZ4f40qKDYOOt2', 'merchant', '081234560003', NULL, '2026-10-09 00:15:30', '2026-10-09 00:15:30');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (4, 'Katering Dapur Ibu', 'merchant4@gmail.com', NULL, '$2y$12$gqq/Lp3l88sdVfeY1jUs/eyB.n6lv3CTOuhLVwI.uzNuVzNlDZptW', 'merchant', '081234560004', NULL, '2026-10-09 00:15:30', '2026-10-09 00:15:30');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (5, 'Katering Rasa Nusantara', 'merchant5@gmail.com', NULL, '$2y$12$o.77uz5.9TKbKgAFNv754Ov3YPu31QKh62QO49FeCG6hCdzwfV.uK', 'merchant', '081234560005', NULL, '2026-10-09 00:15:31', '2026-10-09 00:15:31');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (6, 'Katering Mitra Boga', 'merchant6@gmail.com', NULL, '$2y$12$FcJmLsrkvCAaR33Q1uVVrulqPCblM/u9NUSALdNyci20IBrOm.upq', 'merchant', '081234560006', NULL, '2026-10-09 00:15:31', '2026-10-09 00:15:31');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (7, 'Katering Sedap Malam', 'merchant7@gmail.com', NULL, '$2y$12$U.XiMPMicbhnuAmmTfdsL.feNc5OGDJ5RCLAbHtpDCPCh044bzk/2', 'merchant', '081234560007', NULL, '2026-10-09 00:15:31', '2026-10-09 00:15:31');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (8, 'Katering Bunda Catering', 'merchant8@gmail.com', NULL, '$2y$12$uQqHzs3aHcsmvEzFXHoq8eaYgknzn9rn1dr.NVEt42uWT93J38Nxq', 'merchant', '081234560008', NULL, '2026-10-09 00:15:32', '2026-10-09 00:15:32');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (9, 'Katering Gurih Lezat', 'merchant9@gmail.com', NULL, '$2y$12$k0H6NtNRX6GL4UVXaOeKze5gptOQ58lr3NfBXqqoGHqZelAFE5urK', 'merchant', '081234560009', NULL, '2026-10-09 00:15:32', '2026-10-09 00:15:32');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (10, 'Katering Sejahtera', 'merchant10@gmail.com', NULL, '$2y$12$CQU2WIFKMG9BhSkjDzpOi.HVmjktjK01udcd./.4kBfqM/8G2IRfK', 'merchant', '081234560010', NULL, '2026-10-09 00:15:32', '2026-10-09 00:15:32');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (11, 'PT Maju Jaya', 'customer1@gmail.com', NULL, '$2y$12$zgL2EZBsB0imXOoH1lTGZOB8S0sVS6IcUIFlw8KCtACNX94PmqpRe', 'customer', '081298760001', NULL, '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (12, 'PT Sentosa Abadi', 'customer2@gmail.com', NULL, '$2y$12$3DY7e97mfJvnI1lBI1xoA.gFhOcOu1DnMiO.7lfkl10W0c66dd2Te', 'customer', '081298760002', NULL, '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (13, 'PT Cipta Karya', 'customer3@gmail.com', NULL, '$2y$12$weNpEnGZvEEX9hHZeOnLY.8fVZ1MEi0vea7WJ.BWTTlFrv2YOdaDy', 'customer', '081298760003', NULL, '2026-10-09 00:15:33', '2026-10-09 00:15:33');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (14, 'PT Mitra Sukses', 'customer4@gmail.com', NULL, '$2y$12$GtzoCi8u/j6sj4iwNKEJ5./xapj30ZrMNdAiPhBWtJgjyw9.yIK9q', 'customer', '081298760004', NULL, '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (15, 'PT Bina Usaha', 'customer5@gmail.com', NULL, '$2y$12$6pWeYrs6Ckwm9DD8Ea7i3usxWy90nG87CVE0tyVe4N1i4QCku6oxK', 'customer', '081298760005', NULL, '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (16, 'PT Karya Mandiri', 'customer6@gmail.com', NULL, '$2y$12$NnHjLjhVMa2lwB37fzH2uOvVd3gnmCWzVy9ElG9GIeOERj78jzCjG', 'customer', '081298760006', NULL, '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (17, 'PT Sumber Rejeki', 'customer7@gmail.com', NULL, '$2y$12$r3chsakBDhkFJKQT5uOEseTg/D1yJNPwHuEW.Y6Wgicmbx8EK4LRi', 'customer', '081298760007', NULL, '2026-10-09 00:15:34', '2026-10-09 00:15:34');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (18, 'PT Anugrah Sejati', 'customer8@gmail.com', NULL, '$2y$12$6eajW5z5/mAKLy8s3b0fxOkItqT6mB7ZK7.6ZgCKq9ruUmnzbN4NG', 'customer', '081298760008', NULL, '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (19, 'PT Bumi Perkasa', 'customer9@gmail.com', NULL, '$2y$12$nmwJWR4R5UOrTHx9QZO9juiUN3iR8V3vSfUAbNyZFOd1bSBs2cHNy', 'customer', '081298760009', NULL, '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (20, 'PT Cahaya Timur', 'customer10@gmail.com', NULL, '$2y$12$z8NBboBujCTADWjKbwQ53.6ZiEtNTZymaerwUXVaBaW2agvPtmcMK', 'customer', '081298760010', NULL, '2026-10-09 00:15:35', '2026-10-09 00:15:35');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (21, 'Katering Rival Testing', 'rival@merchant.com', NULL, '$2y$12$EBvpHgYlOTmzBAZb.T8YB.Lzw4JRAibiHozVRUmPwrAJTiqHIc10m', 'merchant', '081200000001', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');
INSERT INTO public.users (id, name, email, email_verified_at, password, role, phone, remember_token, created_at, updated_at) VALUES (22, 'PT Rival Testing', 'rival@customer.com', NULL, '$2y$12$Eld.Y3BZnqCjDgMBoLZGgeO1e1xmSNAUUcSppH0OF/QYaIFw6C7me', 'customer', '081300000001', NULL, '2026-10-09 00:15:37', '2026-10-09 00:15:37');


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 10, true);


--
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cities_id_seq', 98, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 11, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: favorites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.favorites_id_seq', 1, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoices_id_seq', 20, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: menus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.menus_id_seq', 44, true);


--
-- Name: merchants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.merchants_id_seq', 11, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 17, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 31, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 20, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 22, true);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: categories categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_unique UNIQUE (slug);


--
-- Name: cities cities_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_unique UNIQUE (name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_unique UNIQUE (user_id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: favorites favorites_customer_id_merchant_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_customer_id_merchant_id_unique UNIQUE (customer_id, merchant_id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_unique UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: merchants merchants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_pkey PRIMARY KEY (id);


--
-- Name: merchants merchants_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_slug_unique UNIQUE (slug);


--
-- Name: merchants merchants_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_user_id_unique UNIQUE (user_id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: reviews reviews_order_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_order_id_unique UNIQUE (order_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: failed_jobs_connection_queue_failed_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX failed_jobs_connection_queue_failed_at_index ON public.failed_jobs USING btree (connection, queue, failed_at);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: merchants_city_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX merchants_city_index ON public.merchants USING btree (city);


--
-- Name: orders_delivery_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX orders_delivery_date_index ON public.orders USING btree (delivery_date);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: customers customers_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_merchant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_merchant_id_foreign FOREIGN KEY (merchant_id) REFERENCES public.merchants(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: menus menus_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;


--
-- Name: menus menus_merchant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_merchant_id_foreign FOREIGN KEY (merchant_id) REFERENCES public.merchants(id) ON DELETE CASCADE;


--
-- Name: merchants merchants_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.merchants
    ADD CONSTRAINT merchants_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_menu_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_menu_id_foreign FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: orders orders_merchant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_merchant_id_foreign FOREIGN KEY (merchant_id) REFERENCES public.merchants(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_merchant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_merchant_id_foreign FOREIGN KEY (merchant_id) REFERENCES public.merchants(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict u903hDAFh8bx3eM4fcjHyQbPCmZ2hHRATzDelLQbV61BtZVhnTXs6LhgRQAkvLQ

