--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4 (Homebrew)

-- Started on 2024-12-05 00:04:39 CST

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
-- TOC entry 223 (class 1259 OID 16923)
-- Name: pricing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pricing (
    id integer NOT NULL,
    menu_item_id bigint,
    price numeric(10,2),
    CONSTRAINT check_price_positive CHECK ((price >= (0)::numeric))
);


ALTER TABLE public.pricing OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16922)
-- Name: Pricing_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Pricing_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Pricing_id_seq" OWNER TO postgres;

--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 222
-- Name: Pricing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Pricing_id_seq" OWNED BY public.pricing.id;


--
-- TOC entry 218 (class 1259 OID 16534)
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    address character varying(46) NOT NULL,
    zip character varying(6) NOT NULL
);


ALTER TABLE public.address OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16526)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    username character varying(16) NOT NULL,
    email character varying(32) NOT NULL,
    phone_number character varying(20) NOT NULL,
    member boolean NOT NULL,
    user_id bigint NOT NULL,
    "First_name" character varying(12) NOT NULL,
    "Last_name" character varying(16) NOT NULL,
    CONSTRAINT check_email_format CHECK (((email)::text ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
    CONSTRAINT check_phone_number CHECK (((phone_number)::text ~ '^\+?[1-9]\d{1,19}$'::text))
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17102)
-- Name: customer_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_user_id_seq OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16521)
-- Name: franchise; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.franchise (
    id bigint NOT NULL,
    "City" character varying(45) NOT NULL,
    "State" character varying(16) NOT NULL,
    address character varying(46),
    zip character varying(6)
);


ALTER TABLE public.franchise OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16914)
-- Name: menu_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu_item (
    menu_item_id bigint NOT NULL,
    item_name character varying(15) NOT NULL,
    type_of_menu_item character varying(10) NOT NULL,
    quantity bigint,
    CONSTRAINT check_quantity_positive CHECK ((quantity >= 0))
);


ALTER TABLE public.menu_item OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16913)
-- Name: menu_item_menu_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.menu_item_menu_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_item_menu_item_id_seq OWNER TO postgres;

--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 220
-- Name: menu_item_menu_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.menu_item_menu_item_id_seq OWNED BY public.menu_item.menu_item_id;


--
-- TOC entry 227 (class 1259 OID 17011)
-- Name: menu_item_relationships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu_item_relationships (
    parent_item_id bigint NOT NULL,
    child_item_id bigint NOT NULL,
    relationship_type character varying(20)
);


ALTER TABLE public.menu_item_relationships OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16937)
-- Name: menu_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menu_items (
    menu_id bigint NOT NULL,
    menu_item_id bigint NOT NULL
);


ALTER TABLE public.menu_items OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17082)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_id integer NOT NULL,
    menu_item_id bigint NOT NULL,
    quantity integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16943)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    "Menu_items_id" bigint,
    "Franchise_id" bigint NOT NULL,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    total_amount numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'pending'::character varying,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17078)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 228
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 217 (class 1259 OID 16531)
-- Name: payment_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_cards (
    id bigint NOT NULL,
    card_num character varying(19),
    user_id bigint,
    date_exp character varying(4),
    bank character varying(10),
    CONSTRAINT check_card_num CHECK (((card_num)::text ~ '^\d{13,19}$'::text))
);


ALTER TABLE public.payment_cards OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16549)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    card_id "char" NOT NULL,
    amount bigint NOT NULL,
    cust_id bigint NOT NULL,
    CONSTRAINT check_positive_amount CHECK ((amount > 0))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17105)
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_transaction_id_seq OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16946)
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    transaction_id bigint DEFAULT nextval('public.transactions_transaction_id_seq'::regclass) NOT NULL,
    payment_id bigint,
    cash boolean NOT NULL,
    amount bigint NOT NULL,
    order_id bigint NOT NULL,
    cust_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_transaction_amount_positive CHECK ((amount > 0))
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- TOC entry 3491 (class 2604 OID 17106)
-- Name: menu_item menu_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_item ALTER COLUMN menu_item_id SET DEFAULT nextval('public.menu_item_menu_item_id_seq'::regclass);


--
-- TOC entry 3493 (class 2604 OID 17131)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3492 (class 2604 OID 17108)
-- Name: pricing id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricing ALTER COLUMN id SET DEFAULT nextval('public."Pricing_id_seq"'::regclass);


--
-- TOC entry 3706 (class 0 OID 16534)
-- Dependencies: 218
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.address (address, zip) FROM stdin;
456 Oak Avenue	75001
123 Main Street	60601
789 Pine Boulevard	94102
654 Elm Street	98101
321 Maple Road	33101
\.


--
-- TOC entry 3704 (class 0 OID 16526)
-- Dependencies: 216
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (username, email, phone_number, member, user_id, "First_name", "Last_name") FROM stdin;
jsmith	john.smith@email.com	+12345678901	t	1	John	Smith
mjohnson	mary.johnson@email.com	+12345678902	f	2	Mary	Johnson
rwilson	robert.wilson@email.com	+12345678903	t	3	Robert	Wilson
sbrown	sarah.brown@email.com	+12345678904	f	4	Sarah	Brown
dtaylor	david.taylor@email.com	+12345678905	t	5	David	Taylor
janderson	jane.anderson@email.com	+12345678906	t	6	Jane	Anderson
mlee	michael.lee@email.com	+12345678907	f	7	Michael	Lee
agarcia	anna.garcia@email.com	+12345678908	t	8	Anna	Garcia
wmiller	william.miller@email.com	+12345678909	f	9	William	Miller
ldavis	lisa.davis@email.com	+12345678910	t	10	Lisa	Davis
guest_customer	guest@restaurant.com	+10000000000	f	0	Guest	Customer
\.


--
-- TOC entry 3703 (class 0 OID 16521)
-- Dependencies: 215
-- Data for Name: franchise; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.franchise (id, "City", "State", address, zip) FROM stdin;
2	Dallas	Texas	456 Oak Avenue	75001
5	Seattle	Washington	654 Elm Street	98101
4	Miami	Florida	321 Maple Road	33101
1	Chicago	Illinois	123 Main Street	60601
3	San Francisco	California	789 Pine Boulevard	94102
\.


--
-- TOC entry 3709 (class 0 OID 16914)
-- Dependencies: 221
-- Data for Name: menu_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menu_item (menu_item_id, item_name, type_of_menu_item, quantity) FROM stdin;
1	Spring Rolls	Appetizer	100
2	Egg Rolls	Appetizer	100
4	Wonton Soup	Appetizer	100
5	Hot&Sour Soup	Appetizer	100
7	Sweet&Sour	Main	50
8	Beef&Broccoli	Main	50
9	Chow Mein	Main	50
10	Mapo Tofu	Main	50
11	Fried Rice	Rice	100
12	Lo Mein	Noodles	100
13	White Rice	Rice	200
14	Dan Dan Noodle	Noodles	50
15	Chow Fun	Noodles	50
17	Chinese Tea	Drink	200
18	Soda	Drink	200
19	Herbal Tea	Drink	100
21	Moon Cake	Dessert	50
22	Egg Custard	Dessert	50
23	Sweet Bun	Dessert	50
24	Mango Pudding	Dessert	50
25	Fortune Cookie	Dessert	500
6	Kung Pao Ckn	Main	50
3	Crab Rangoons	Appetizer	100
16	Green Tea	Drink	100
20	 Apple Juice	Drink	100
\.


--
-- TOC entry 3715 (class 0 OID 17011)
-- Dependencies: 227
-- Data for Name: menu_item_relationships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menu_item_relationships (parent_item_id, child_item_id, relationship_type) FROM stdin;
\.


--
-- TOC entry 3712 (class 0 OID 16937)
-- Dependencies: 224
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menu_items (menu_id, menu_item_id) FROM stdin;
\.


--
-- TOC entry 3717 (class 0 OID 17082)
-- Dependencies: 229
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_id, menu_item_id, quantity, created_at) FROM stdin;
16	1	1	2024-12-02 17:15:19.591232
16	24	1	2024-12-02 17:15:19.591232
16	20	1	2024-12-02 17:15:19.591232
17	17	1	2024-12-02 17:15:19.591232
17	18	1	2024-12-02 17:15:19.591232
17	16	1	2024-12-02 17:15:19.591232
17	25	1	2024-12-02 17:15:19.591232
18	8	1	2024-12-02 17:15:19.591232
18	9	1	2024-12-02 17:15:19.591232
19	21	1	2024-12-02 17:15:19.591232
19	25	1	2024-12-02 17:15:19.591232
19	22	1	2024-12-02 17:15:19.591232
20	11	1	2024-12-02 17:15:19.591232
20	6	1	2024-12-02 17:15:19.591232
20	18	1	2024-12-02 17:15:19.591232
21	6	1	2024-12-02 17:15:19.591232
21	12	1	2024-12-02 17:15:19.591232
22	16	1	2024-12-02 17:15:19.591232
22	24	1	2024-12-02 17:15:19.591232
23	14	1	2024-12-02 17:19:19.693918
23	6	1	2024-12-02 17:19:19.693918
23	19	1	2024-12-02 17:19:19.693918
23	8	1	2024-12-02 17:19:19.693918
24	1	1	2024-12-02 17:19:19.693918
24	4	1	2024-12-02 17:19:19.693918
24	24	1	2024-12-02 17:19:19.693918
24	21	1	2024-12-02 17:19:19.693918
24	16	1	2024-12-02 17:19:19.693918
25	11	1	2024-12-02 17:19:19.693918
25	14	1	2024-12-02 17:19:19.693918
29	22	1	2024-12-02 20:24:36.49285
29	4	1	2024-12-02 20:24:36.49285
29	24	1	2024-12-02 20:24:36.49285
\.


--
-- TOC entry 3713 (class 0 OID 16943)
-- Dependencies: 225
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, "Menu_items_id", "Franchise_id", order_date, total_amount, created_at, status) FROM stdin;
1	\N	1	2024-12-01 20:57:56.680292	15.00	2024-12-01 20:57:56.680292	pending
16	\N	1	2024-12-01 21:51:46.237976	15.00	2024-12-01 21:51:46.237976	pending
17	\N	1	2024-12-01 21:52:30.759734	12.00	2024-12-01 21:52:30.759734	pending
18	\N	1	2024-12-01 21:52:45.897937	29.00	2024-12-01 21:52:45.897937	pending
19	\N	1	2024-12-01 21:53:45.410763	12.00	2024-12-01 21:53:45.410763	pending
20	\N	1	2024-12-01 21:55:08.74313	30.00	2024-12-01 21:55:08.74313	pending
21	\N	1	2024-12-01 22:02:44.947645	28.00	2024-12-01 22:02:44.947645	pending
22	\N	1	2024-12-01 22:10:23.308392	10.00	2024-12-01 22:10:23.308392	pending
23	\N	1	2024-12-01 22:40:49.792451	49.00	2024-12-01 22:40:49.792451	pending
24	\N	1	2024-12-01 22:41:51.583348	27.00	2024-12-01 22:41:51.583348	pending
25	\N	1	2024-12-01 23:06:33.545941	26.00	2024-12-01 23:06:33.545941	pending
29	\N	2	2024-12-02 20:24:36.49285	15.00	2024-12-02 20:24:36.49285	pending
\.


--
-- TOC entry 3705 (class 0 OID 16531)
-- Dependencies: 217
-- Data for Name: payment_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_cards (id, card_num, user_id, date_exp, bank) FROM stdin;
\.


--
-- TOC entry 3707 (class 0 OID 16549)
-- Dependencies: 219
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, card_id, amount, cust_id) FROM stdin;
\.


--
-- TOC entry 3711 (class 0 OID 16923)
-- Dependencies: 223
-- Data for Name: pricing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pricing (id, menu_item_id, price) FROM stdin;
1	1	6.00
2	2	5.00
3	3	7.00
4	4	5.00
5	5	5.00
6	6	15.00
7	7	14.00
8	8	16.00
9	9	13.00
10	10	14.00
11	11	12.00
12	12	13.00
13	13	3.00
14	14	14.00
15	15	14.00
16	16	5.00
17	17	3.00
18	18	3.00
19	19	4.00
20	20	4.00
21	21	6.00
22	22	5.00
23	23	4.00
24	24	5.00
25	25	0.99
\.


--
-- TOC entry 3714 (class 0 OID 16946)
-- Dependencies: 226
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (transaction_id, payment_id, cash, amount, order_id, cust_id, created_at) FROM stdin;
1	\N	t	49	23	6	2024-12-01 22:40:49.792451
2	\N	t	27	24	6	2024-12-01 22:41:51.583348
3	\N	t	26	25	7	2024-12-01 23:06:33.545941
4	\N	t	15	29	8	2024-12-02 20:24:36.49285
\.


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 222
-- Name: Pricing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Pricing_id_seq"', 1, false);


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 230
-- Name: customer_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_user_id_seq', 1, false);


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 220
-- Name: menu_item_menu_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.menu_item_menu_item_id_seq', 25, true);


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 228
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 38, true);


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 231
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 4, true);


--
-- TOC entry 3513 (class 2606 OID 16530)
-- Name: customer Customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "Customer_pkey" PRIMARY KEY (user_id);


--
-- TOC entry 3511 (class 2606 OID 16525)
-- Name: franchise Franchise_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT "Franchise_pkey" PRIMARY KEY (id);


--
-- TOC entry 3532 (class 2606 OID 16951)
-- Name: menu_items Menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT "Menu_pkey" PRIMARY KEY (menu_id);


--
-- TOC entry 3534 (class 2606 OID 17039)
-- Name: orders Orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "Orders_pkey" PRIMARY KEY (id);


--
-- TOC entry 3518 (class 2606 OID 16797)
-- Name: payment_cards Payment_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_cards
    ADD CONSTRAINT "Payment_cards_pkey" PRIMARY KEY (id);


--
-- TOC entry 3523 (class 2606 OID 16553)
-- Name: payments Payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "Payments_pkey" PRIMARY KEY (payment_id);


--
-- TOC entry 3530 (class 2606 OID 16928)
-- Name: pricing Pricing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricing
    ADD CONSTRAINT "Pricing_pkey" PRIMARY KEY (id);


--
-- TOC entry 3537 (class 2606 OID 16957)
-- Name: transactions Transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "Transactions_pkey" PRIMARY KEY (transaction_id);


--
-- TOC entry 3521 (class 2606 OID 17072)
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address, zip);


--
-- TOC entry 3528 (class 2606 OID 16921)
-- Name: menu_item menu_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_item
    ADD CONSTRAINT menu_item_pkey PRIMARY KEY (menu_item_id);


--
-- TOC entry 3540 (class 2606 OID 17015)
-- Name: menu_item_relationships menu_item_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_item_relationships
    ADD CONSTRAINT menu_item_relationships_pkey PRIMARY KEY (parent_item_id, child_item_id);


--
-- TOC entry 3543 (class 2606 OID 17146)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id, menu_item_id);


--
-- TOC entry 3516 (class 2606 OID 16826)
-- Name: customer unique_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- TOC entry 3514 (class 1259 OID 17066)
-- Name: idx_customer_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_email ON public.customer USING btree (email);


--
-- TOC entry 3525 (class 1259 OID 17065)
-- Name: idx_menu_item_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_menu_item_type ON public.menu_item USING btree (type_of_menu_item);


--
-- TOC entry 3526 (class 1259 OID 16958)
-- Name: idx_menu_items_menu_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_menu_items_menu_item_id ON public.menu_item USING btree (menu_item_id);


--
-- TOC entry 3541 (class 1259 OID 17157)
-- Name: idx_order_items_composite; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_composite ON public.order_items USING btree (order_id, menu_item_id);


--
-- TOC entry 3535 (class 1259 OID 16960)
-- Name: idx_orders_franchise_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_franchise_id ON public.orders USING btree ("Franchise_id");


--
-- TOC entry 3519 (class 1259 OID 16667)
-- Name: idx_payment_cards_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payment_cards_user_id ON public.payment_cards USING btree (user_id);


--
-- TOC entry 3524 (class 1259 OID 16669)
-- Name: idx_payments_cust_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_cust_id ON public.payments USING btree (cust_id);


--
-- TOC entry 3538 (class 1259 OID 16961)
-- Name: idx_transactions_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_order_id ON public.transactions USING btree (order_id);


--
-- TOC entry 3546 (class 2606 OID 16584)
-- Name: payments Cust_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "Cust_id" FOREIGN KEY (cust_id) REFERENCES public.customer(user_id);


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 3546
-- Name: CONSTRAINT "Cust_id" ON payments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON CONSTRAINT "Cust_id" ON public.payments IS 'This is to connect customer to payments';


--
-- TOC entry 3552 (class 2606 OID 16962)
-- Name: transactions Customer_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "Customer_id" FOREIGN KEY (cust_id) REFERENCES public.customer(user_id);


--
-- TOC entry 3549 (class 2606 OID 16967)
-- Name: orders Franchise; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "Franchise" FOREIGN KEY ("Franchise_id") REFERENCES public.franchise(id);


--
-- TOC entry 3548 (class 2606 OID 16972)
-- Name: menu_items Menu_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT "Menu_item_id" FOREIGN KEY (menu_item_id) REFERENCES public.menu_item(menu_item_id);


--
-- TOC entry 3550 (class 2606 OID 16977)
-- Name: orders Menu_items_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "Menu_items_id" FOREIGN KEY ("Menu_items_id") REFERENCES public.menu_item(menu_item_id) NOT VALID;


--
-- TOC entry 3553 (class 2606 OID 17040)
-- Name: transactions Order_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT "Order_id" FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 3547 (class 2606 OID 16929)
-- Name: pricing Pricing_menu_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricing
    ADD CONSTRAINT "Pricing_menu_item_id_fkey" FOREIGN KEY (menu_item_id) REFERENCES public.menu_item(menu_item_id);


--
-- TOC entry 3544 (class 2606 OID 17073)
-- Name: franchise fk_address; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.franchise
    ADD CONSTRAINT fk_address FOREIGN KEY (address, zip) REFERENCES public.address(address, zip);


--
-- TOC entry 3551 (class 2606 OID 16992)
-- Name: orders fk_orders_franchise_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_franchise_id FOREIGN KEY ("Franchise_id") REFERENCES public.franchise(id) ON DELETE CASCADE;


--
-- TOC entry 3545 (class 2606 OID 16748)
-- Name: payment_cards fk_payment_cards_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_cards
    ADD CONSTRAINT fk_payment_cards_user_id FOREIGN KEY (user_id) REFERENCES public.customer(user_id) ON DELETE CASCADE;


--
-- TOC entry 3554 (class 2606 OID 17109)
-- Name: transactions fk_transactions_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_customer FOREIGN KEY (cust_id) REFERENCES public.customer(user_id) ON DELETE CASCADE;


--
-- TOC entry 3555 (class 2606 OID 17045)
-- Name: transactions fk_transactions_order_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_order_id FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3556 (class 2606 OID 17021)
-- Name: menu_item_relationships menu_item_relationships_child_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_item_relationships
    ADD CONSTRAINT menu_item_relationships_child_item_id_fkey FOREIGN KEY (child_item_id) REFERENCES public.menu_item(menu_item_id);


--
-- TOC entry 3557 (class 2606 OID 17016)
-- Name: menu_item_relationships menu_item_relationships_parent_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menu_item_relationships
    ADD CONSTRAINT menu_item_relationships_parent_item_id_fkey FOREIGN KEY (parent_item_id) REFERENCES public.menu_item(menu_item_id);


--
-- TOC entry 3558 (class 2606 OID 17152)
-- Name: order_items order_items_menu_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_item(menu_item_id);


--
-- TOC entry 3559 (class 2606 OID 17147)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


-- Completed on 2024-12-05 00:04:42 CST

--
-- PostgreSQL database dump complete
--

