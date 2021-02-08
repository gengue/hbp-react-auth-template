CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE SCHEMA auth;
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  _new record;
begin
  _new := new;
  _new. "updated_at" = now();
  return _new;
end;
$$;
CREATE TABLE auth.account_providers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    account_id uuid NOT NULL,
    auth_provider text NOT NULL,
    auth_provider_unique_id text NOT NULL
);
CREATE TABLE auth.account_roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    account_id uuid NOT NULL,
    role text NOT NULL
);
CREATE TABLE auth.accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    active boolean DEFAULT false NOT NULL,
    email public.citext,
    new_email public.citext,
    password_hash text,
    default_role text DEFAULT 'user'::text NOT NULL,
    is_anonymous boolean DEFAULT false NOT NULL,
    custom_register_data jsonb,
    otp_secret text,
    mfa_enabled boolean DEFAULT false NOT NULL,
    ticket uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ticket_expires_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT proper_email CHECK ((email OPERATOR(public.~*) '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::public.citext)),
    CONSTRAINT proper_new_email CHECK ((new_email OPERATOR(public.~*) '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::public.citext))
);
CREATE TABLE auth.providers (
    provider text NOT NULL
);
CREATE TABLE auth.refresh_tokens (
    refresh_token uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    account_id uuid NOT NULL
);
CREATE TABLE auth.roles (
    role text NOT NULL
);
CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    display_name text,
    avatar_url text
);
ALTER TABLE ONLY auth.account_providers
    ADD CONSTRAINT account_providers_account_id_auth_provider_key UNIQUE (account_id, auth_provider);
ALTER TABLE ONLY auth.account_providers
    ADD CONSTRAINT account_providers_auth_provider_auth_provider_unique_id_key UNIQUE (auth_provider, auth_provider_unique_id);
ALTER TABLE ONLY auth.account_providers
    ADD CONSTRAINT account_providers_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth.account_roles
    ADD CONSTRAINT account_roles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_email_key UNIQUE (email);
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_new_email_key UNIQUE (new_email);
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_user_id_key UNIQUE (user_id);
ALTER TABLE ONLY auth.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (provider);
ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (refresh_token);
ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role);
ALTER TABLE ONLY auth.account_roles
    ADD CONSTRAINT user_roles_account_id_role_key UNIQUE (account_id, role);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE TRIGGER set_auth_account_providers_updated_at BEFORE UPDATE ON auth.account_providers FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
CREATE TRIGGER set_auth_accounts_updated_at BEFORE UPDATE ON auth.accounts FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
ALTER TABLE ONLY auth.account_providers
    ADD CONSTRAINT account_providers_account_id_fkey FOREIGN KEY (account_id) REFERENCES auth.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY auth.account_providers
    ADD CONSTRAINT account_providers_auth_provider_fkey FOREIGN KEY (auth_provider) REFERENCES auth.providers(provider) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY auth.account_roles
    ADD CONSTRAINT account_roles_account_id_fkey FOREIGN KEY (account_id) REFERENCES auth.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY auth.account_roles
    ADD CONSTRAINT account_roles_role_fkey FOREIGN KEY (role) REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_default_role_fkey FOREIGN KEY (default_role) REFERENCES auth.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_account_id_fkey FOREIGN KEY (account_id) REFERENCES auth.accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;

INSERT INTO auth.roles (role)
    VALUES ('user'), ('anonymous'), ('me'), ('staff');

INSERT INTO auth.providers (provider)
    VALUES ('github'), ('facebook'), ('twitter'), ('google'), ('apple'),  ('linkedin'), ('windowslive'), ('spotify');

INSERT INTO public.users (id, created_at, updated_at, display_name, avatar_url) VALUES ('d50f7358-b0cf-4fff-b1dd-119790510933', '2021-02-07 20:17:41.837993+00', '2021-02-07 20:17:41.837993+00', 'genesis@sqila.co', NULL);
INSERT INTO public.users (id, created_at, updated_at, display_name, avatar_url) VALUES ('a8bf9ce3-0175-42e6-9e2d-4b78255b5abf', '2021-02-07 20:18:07.650122+00', '2021-02-07 20:18:07.650122+00', 'deyby@sqila.co', NULL);
INSERT INTO public.users (id, created_at, updated_at, display_name, avatar_url) VALUES ('27def7a8-ef2f-4c02-a6ab-18073510e006', '2021-02-07 20:18:13.0162+00', '2021-02-07 20:18:13.0162+00', 'raul@sqila.co', NULL);
INSERT INTO auth.accounts (id, created_at, updated_at, user_id, active, email, new_email, password_hash, default_role, is_anonymous, custom_register_data, otp_secret, mfa_enabled, ticket, ticket_expires_at) VALUES ('16989a7f-8af2-46dc-aafb-061bb787b1e9', '2021-02-07 20:17:41.837993+00', '2021-02-07 20:17:41.837993+00', 'd50f7358-b0cf-4fff-b1dd-119790510933', true, 'genesis@sqila.co', NULL, '$2a$10$gWqKOcBlvsc7b7Up7NStPOMnUJpVXy8r6usWDvnvGya0eci3yw0M2', 'user', false, NULL, NULL, false, 'dbdfad0e-a301-4d0f-8c50-dbe8e21ff877', '2021-02-07 21:17:41.751+00');
INSERT INTO auth.accounts (id, created_at, updated_at, user_id, active, email, new_email, password_hash, default_role, is_anonymous, custom_register_data, otp_secret, mfa_enabled, ticket, ticket_expires_at) VALUES ('9ab886f3-dfbb-4cfa-972d-570cfed37fea', '2021-02-07 20:18:07.650122+00', '2021-02-07 20:18:07.650122+00', 'a8bf9ce3-0175-42e6-9e2d-4b78255b5abf', true, 'deyby@sqila.co', NULL, '$2a$10$fzEarJlSlxhuDb/qDQ3nQeYzHszzwFu57OyyK05tLpACWjksjLTZG', 'staff', false, NULL, NULL, false, 'b9b11260-5c7c-4b11-8818-286f631862ca', '2021-02-07 21:18:07.575+00');
INSERT INTO auth.accounts (id, created_at, updated_at, user_id, active, email, new_email, password_hash, default_role, is_anonymous, custom_register_data, otp_secret, mfa_enabled, ticket, ticket_expires_at) VALUES ('bd5df045-6520-46f8-8a13-7025a23152cc', '2021-02-07 20:18:13.0162+00', '2021-02-07 20:18:13.0162+00', '27def7a8-ef2f-4c02-a6ab-18073510e006', true, 'raul@sqila.co', NULL, '$2a$10$q6uF6tL8JGu8qJKMqMUmdu7Cly7DGLqBL82zCyEy3XIWcSn3Z4JrC', 'staff', false, NULL, NULL, false, 'b58ce909-8c0f-4fe5-918c-bd30ca1c7057', '2021-02-07 21:18:12.919+00');
INSERT INTO auth.account_roles (id, created_at, account_id, role) VALUES ('accd5db7-e1b4-4f1e-96ad-a67df95f56f0', '2021-02-07 20:17:41.837993+00', '16989a7f-8af2-46dc-aafb-061bb787b1e9', 'staff');
INSERT INTO auth.account_roles (id, created_at, account_id, role) VALUES ('c448c61d-0d6a-41bd-a6b3-64debef3236c', '2021-02-07 20:18:07.650122+00', '9ab886f3-dfbb-4cfa-972d-570cfed37fea', 'staff');
INSERT INTO auth.account_roles (id, created_at, account_id, role) VALUES ('c9ebda6e-41b7-4159-a9e2-969e02cdb6f3', '2021-02-07 20:18:13.0162+00', 'bd5df045-6520-46f8-8a13-7025a23152cc', 'staff');
