
DROP TABLE IF EXISTS public.user_order;
DROP TABLE IF EXISTS public.user_stock;
DROP TABLE IF EXISTS public.user_info;
DROP TABLE IF EXISTS public.stock;

CREATE TABLE IF NOT EXISTS public.stock
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    ticker character varying(20) COLLATE pg_catalog."default" NOT NULL,
    initial_price decimal  NOT NULL,
    company_name character varying(250) COLLATE pg_catalog."default" NOT NULL,
    volume integer NOT NULL,
    current_price decimal  NOT NULL,
    todays_max_price decimal ,
    todays_min_price decimal ,
    todays_open_price decimal ,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    update_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT stock_pkey PRIMARY KEY (id),
    CONSTRAINT unique_ticker UNIQUE(ticker)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.stock
    OWNER to postgres;



-- Table: public.user_info


CREATE TABLE IF NOT EXISTS public.user_info
(
    id character varying(250) COLLATE pg_catalog."default" NOT NULL,
    full_name character varying(250) COLLATE pg_catalog."default" NOT NULL,
    username character varying(250) COLLATE pg_catalog."default" NOT NULL,
    email character varying(250) COLLATE pg_catalog."default" NOT NULL,
    type character varying(50) COLLATE pg_catalog."default" NOT NULL,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    update_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    cash_balance decimal  NOT NULL,
    CONSTRAINT user_info_pkey PRIMARY KEY (id),
    CONSTRAINT user_info_email_key UNIQUE (email)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_info
    OWNER to postgres;



-- Table: public.user_order



CREATE TABLE IF NOT EXISTS public.user_order
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    user_id character varying(250) COLLATE pg_catalog."default" NOT NULL,
    stock_id integer NOT NULL,
    order_nature character varying(250) COLLATE pg_catalog."default" NOT NULL,
    quantity integer NOT NULL,
    status character varying(250) COLLATE pg_catalog."default" NOT NULL,
    status_reason character varying(250) COLLATE pg_catalog."default" NOT NULL,
    order_type character varying(250) COLLATE pg_catalog."default" NOT NULL,
    limit_price decimal ,
    limit_expiration timestamp without time zone,
    transaction_execution_price decimal ,
    create_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    update_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT user_order_pkey PRIMARY KEY (id),
    CONSTRAINT fk_userid
    FOREIGN KEY (user_id)
    REFERENCES user_info(id),
    CONSTRAINT fk_stockid
    FOREIGN KEY (stock_id)
    REFERENCES stock(id)

)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_order
    OWNER to postgres;


-- Table: public.user_stock



CREATE TABLE IF NOT EXISTS public.user_stock
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    user_id character varying(250) COLLATE pg_catalog."default" NOT NULL,
    stock_id integer NOT NULL,
    quantity integer NOT NULL,
    update_date timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT user_stock_pkey PRIMARY KEY (id),
    CONSTRAINT user_stock_user_id_stock_id_key UNIQUE (user_id, stock_id),
    CONSTRAINT fk_userid
    FOREIGN KEY (user_id)
    REFERENCES user_info(id),
    CONSTRAINT fk_stockid
    FOREIGN KEY (stock_id)
    REFERENCES stock(id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.user_stock
    OWNER to postgres;