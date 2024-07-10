drop schema
    public cascade;

create schema
    public;

grant
    usage
    on
    schema
    public to postgres, anon, authenticated, service_role;

grant all privileges on all
    tables in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all
    functions in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all
    sequences in schema public to postgres, anon, authenticated, service_role;

alter
    default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;
alter
    default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter
    default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;

create extension if not exists moddatetime;

-- drop extension timescaledb;
-- create extension if not exists timescaledb;

create table businesses
(
    id               uuid                     default extensions.uuid_generate_v4() primary key,
    created_at       timestamp with time zone default now(),
    name             text not null
);

create table employees
(
    id          uuid references auth.users on delete cascade primary key,
    created_at  timestamp with time zone default now(),
    name        text                                         not null,
    business_id uuid references businesses on delete cascade not null
);

create table qrs
(
    id          uuid                     default extensions.uuid_generate_v4() primary key,
    created_at  timestamp with time zone default now(),
    updated_at  timestamp with time zone default now(),
    business_id uuid references businesses on delete cascade not null,
    name        text,
    fts         tsvector generated always as (to_tsvector('turkish', (name))) stored,
    scan_counts int                      default 0           not null
);

create index qrs_business_id_pkey on qrs using btree (business_id);

create table qr_menus
(
    id          uuid                     default extensions.uuid_generate_v4() primary key,
    created_at  timestamp with time zone default now(),
    business_id uuid references businesses on delete cascade not null,
    name        text                                         not null,
    active      boolean                  default true        not null
);

create index qr_menus_business_id_pkey on qr_menus using btree (business_id);

create table qr_menu_items
(
    id         uuid                     default extensions.uuid_generate_v4() primary key,
    created_at timestamp with time zone default now(),
    qr_menu_id uuid references qr_menus on delete cascade not null,
    active     boolean                  default true      not null,
    notify     boolean                  default true      not null,
    sort_order int                      default 0         not null,
    tags       text[]
);

create index qr_menu_items_qr_menu_id_pkey on qr_menu_items using btree (qr_menu_id);

create table qr_menu_item_translations
(
    id              uuid                     default extensions.uuid_generate_v4() primary key,
    created_at      timestamp with time zone default now(),
    qr_menu_item_id uuid references qr_menu_items on delete cascade not null,
    language        text                                            not null,
    name            text                                            not null,
    description     text,
    image           text,
    price           numeric                                         not null,
    currency        text                                            not null
);

create index qr_menu_item_translations_qr_menu_id_pkey on qr_menu_item_translations using btree (qr_menu_item_id);

create table qr_scans
(
    scan_at     timestamp with time zone default now(),
    qr_id       uuid references qrs on delete cascade        not null,
    business_id uuid references businesses on delete cascade not null
);

create index qr_scans_business_id_pkey on qr_scans using btree (business_id);
create index qr_scans_qr_id_scan_at_pkey on qr_scans (qr_id, scan_at desc);

select extensions.create_hypertable('qr_scans', 'scan_at');

create trigger qrs_handle_updated_at
    before update
    on qrs
    for each row
execute procedure moddatetime(updated_at);

create
    or replace function update_qrs_table_scan_counts() returns trigger
    language plpgsql
    security definer as
$$
begin

    update qrs
    set scan_counts = qrs.scan_counts + 1
    where id = NEW.qr_id;
    return NEW;
end;
$$;

create trigger
    trigger_qrs_table_scan_counts
    after
        insert
    on qr_scans
    for each row
execute
    procedure update_qrs_table_scan_counts();

insert into businesses (id, name)
values ('1315c5d3-e635-4e4e-af53-85a7fe65bd4e',
        'CoffieMachine'),
       ('c581cb3a-8f85-47a8-b158-e71a47d499fb',
        'ChikenRun'),
       ('459fe8d3-2c2c-499f-9383-efa977c0e0a5',
        'Milk Way')
;

insert into qr_menus (id, business_id, name)
values ('8ba7e95a-c7ea-40ed-a7e9-5ac7ea40ed39', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', 'Menu 1'),
       ('0f6a968f-6336-4ec5-aa96-8f6336bec58e', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', 'Menu 2');

insert into employees (id, name, business_id)
values ('49d8b61f-f907-493c-8a17-fb8054b44978', 'cihan', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e');

insert into qrs (id, business_id, name)
values ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', ''),
       ('382a32a5-8afa-4c01-aa32-a58afa7c018f', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', 'masa 12'),
       ('0d3eaf4a-9416-4d88-beaf-4a94168d8818', 'c581cb3a-8f85-47a8-b158-e71a47d499fb', 'masa 145');

insert into qr_scans (qr_id, business_id, scan_at)
values ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '1 day'),
       ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '2 day'),
       ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '3 day'),
       ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '4 day'),
       ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '5 day'),
       ('7aa1da39-8646-47cd-a1da-39864687cde8', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '6 day'),
       ('382a32a5-8afa-4c01-aa32-a58afa7c018f', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '7 day'),
       ('382a32a5-8afa-4c01-aa32-a58afa7c018f', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '8 day'),
       ('382a32a5-8afa-4c01-aa32-a58afa7c018f', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '9 day'),
       ('382a32a5-8afa-4c01-aa32-a58afa7c018f', '1315c5d3-e635-4e4e-af53-85a7fe65bd4e', now() - interval '9 day');


-- drop function if exists qr_scans_this_month(qr_id_param UUID);
-- CREATE OR REPLACE FUNCTION qr_scans_this_month(qr_id_param UUID)
--     RETURNS INTEGER AS
-- $$
-- BEGIN
--     RETURN (SELECT COUNT(*)
--             FROM qr_scans
--             WHERE qr_id = qr_id_param
--               AND time_bucket('1 month', scan_at) = time_bucket('1 month', CURRENT_TIMESTAMP));
-- END;
-- $$ LANGUAGE plpgsql;
--
-- select qr_scans_this_month('7aa1da39-8646-47cd-a1da-39864687cde8');

-- alter table user_profiles
--     enable row level security;
--
-- create policy "user_profiles read to everyone."
--     on user_profiles for select
--     to anon, authenticated
--     using (true);
--
-- create policy "user_profiles create only authenticated"
--     on user_profiles
--     for insert to authenticated
--     with check (true);
--
-- create policy "user_profiles update only authenticated owner"
--     on user_profiles for update
--     to authenticated
--     using ((select auth.uid()) = id)
--     with check ((select auth.uid()) = id);
--
-- -- MARK: - USER PROFILES
-- create table
--     user_followers
-- (
--     user_id     uuid references user_profiles on delete cascade not null, -- takip eden
--     followed_id uuid references user_profiles on delete cascade not null, -- takip edilen
--     created_at  timestamp with time zone default now()          not null,
--     constraint user_followers_pkey primary key (user_id, followed_id)
-- );
--
-- alter table user_followers
--     enable row level security;
--
-- create policy "user_followers scans only authenticated owner"
--     on user_followers
--     for select
--     using ((select auth.uid()) = user_id);
--
-- create policy "user_followers create only authenticated"
--     on user_followers
--     for insert to authenticated
--     with check (true);
--
-- create policy "user_followers delete only authenticated owner"
--     on user_followers
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- create policy "user_followers update only authenticated owner"
--     on user_followers
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create table
--     posts
-- (
--     id              uuid                     default extensions.uuid_generate_v4() primary key,
--     user_id         uuid references user_profiles on delete cascade not null,
--     created_at      timestamp with time zone default now()          not null,
--     updated_at      timestamp with time zone,
--
--     content         text,
--     images          text[],
--     video           text,
--
--     fts             tsvector generated always as (to_tsvector('turkish', (content))) stored,
--
--     like_counts     int                      default 0              not null,
--     comment_counts  int                      default 0              not null,
--     comment_enabled boolean                  default true           not null
-- );
--
-- create index posts_user_id_pkey on posts using btree (user_id);
--
-- alter table posts
--     enable row level security;
--
-- create policy "posts scans to everyone"
--     on posts
--     for select
--     using (true);
--
-- create policy "posts create only authenticated"
--     on posts
--     for insert to authenticated
--     with check (true);
--
-- create policy "posts update only authenticated owner"
--     on posts
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "posts delete only authenticated owner"
--     on posts
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- create table post_tags
-- (
--     post_id uuid references posts on delete cascade not null,
--     tag     text                                    not null,
--     constraint post_tags_pkey primary key (post_id, tag)
-- );
--
-- -- MARK: - POST LIKES
-- create table
--     post_likes
-- (
--     user_id    uuid references user_profiles on delete cascade not null,
--     post_id    uuid references posts on delete cascade         not null,
--     created_at timestamp with time zone default now()          not null,
--     constraint post_likes_pkey primary key (user_id, post_id)
-- );
--
-- drop function if exists is_posts_likes_by_user(user_id_param UUID, post_ids UUID[]);
--
-- CREATE
--     OR REPLACE FUNCTION is_posts_likes_by_user(user_id_param UUID, post_ids UUID[])
--     RETURNS TABLE
--             (
--                 post_id  UUID,
--                 is_liked BOOLEAN
--             )
-- AS
-- $$
-- BEGIN
--     RETURN QUERY
--         SELECT p.id                                                                                        as post_id,
--                EXISTS (SELECT 1 FROM post_likes pl WHERE pl.user_id = user_id_param AND pl.post_id = p.id) as is_liked
--         FROM posts p
--         WHERE p.id = ANY (post_ids);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- create
--     or replace function update_posts_table_likes_count() returns trigger
--     language plpgsql
--     security definer as
-- $$
-- begin
--     if
--         (TG_OP = 'DELETE') then
--         update posts
--         set like_counts = like_counts - 1
--         where id = OLD.post_id;
--     elsif
--         (TG_OP = 'INSERT') then
--         update posts
--         set like_counts = like_counts + 1
--         where id = NEW.post_id;
--     end if;
--     return NEW;
-- end;
-- $$;
--
-- create trigger
--     trigger_posts_table_likes_count_update
--     after
--         insert
--         or
--         delete
--     on post_likes
--     for each row
-- execute
--     procedure update_posts_table_likes_count();
--
-- alter table post_likes
--     enable row level security;
--
-- create policy "post_likes scans to everyone"
--     on post_likes
--     for select
--     using (true);
--
-- create policy "post_likes create only authenticated"
--     on post_likes
--     for insert to authenticated
--     with check (true);
--
-- create policy "post_likes update only authenticated owner"
--     on post_likes
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "post_likes delete only authenticated owner"
--     on post_likes
--     for delete
--     using ((select auth.uid()) = user_id);
--
--
-- -- MARK: - POST REPORTS
--
-- create table post_reports
-- (
--     user_id    uuid references user_profiles on delete cascade not null,
--     post_id    uuid references posts on delete cascade         not null,
--     created_at timestamp with time zone default now()          not null,
--     constraint post_reports_pkey primary key (user_id, post_id)
-- );
--
-- alter table post_reports
--     enable row level security;
--
-- create policy "post_reports scans to everyone"
--     on post_reports
--     for select
--     using (true);
--
-- create policy "post_reports create only authenticated"
--     on post_reports
--     for insert to authenticated
--     with check (true);
--
-- create policy "post_reports update only authenticated owner"
--     on post_reports
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "post_reports delete only authenticated owner"
--     on post_reports
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- CREATE OR REPLACE FUNCTION check_post_report_count()
--     RETURNS TRIGGER AS
-- $$
-- DECLARE
--     report_count INTEGER;
-- BEGIN
--     SELECT COUNT(*)
--     INTO report_count
--     FROM post_reports
--     WHERE post_id = NEW.post_id;
--
--     IF report_count > 10 THEN
--         DELETE
--         FROM posts
--         WHERE id = NEW.post_id;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER check_report_count_trigger
--     AFTER INSERT
--     ON post_reports
--     FOR EACH ROW
-- EXECUTE FUNCTION check_post_report_count();
--
-- -- MARK: - POST COMMENTS
--
-- create table
--     post_comments
-- (
--     id         uuid                     default extensions.uuid_generate_v4() primary key,
--     user_id    uuid references user_profiles on delete cascade not null,
--     post_id    uuid references posts on delete cascade         not null,
--
--     created_at timestamp with time zone default now()          not null,
--     updated_at timestamp with time zone,
--     comment    text                                            not null
-- );
--
-- alter table post_comments
--     enable row level security;
--
-- create policy "post_comments scans to everyone"
--     on post_comments
--     for select
--     using (true);
--
-- create policy "post_comments create only authenticated"
--     on post_comments
--     for insert to authenticated
--     with check (true);
--
-- create policy "post_comments update only authenticated owner"
--     on post_comments
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "post_comments delete only authenticated owner"
--     on post_comments
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- create
--     or replace function update_posts_table_comments_count() returns trigger
--     language plpgsql
--     security definer as
-- $$
-- begin
--     if
--         (TG_OP = 'DELETE') then
--         update posts
--         set comment_counts = comment_counts - 1
--         where id = OLD.post_id;
--     elsif
--         (TG_OP = 'INSERT') then
--         update posts
--         set comment_counts = comment_counts + 1
--         where id = NEW.post_id;
--     end if;
--     return NEW;
-- end;
-- $$;
--
-- create trigger
--     trigger_posts_table_comments_count
--     after
--         insert
--         or
--         delete
--     on post_comments
--     for each row
-- execute
--     procedure update_posts_table_comments_count();
--
--
-- -- MARK: - POST COMMENT REPORTS
--
-- create table post_comment_reports
-- (
--     user_id         uuid references user_profiles on delete cascade not null,
--     post_comment_id uuid references post_comments on delete cascade not null,
--     created_at      timestamp with time zone default now()          not null,
--     constraint post_comment_reports_pkey primary key (user_id, post_comment_id)
-- );
--
-- alter table post_comment_reports
--     enable row level security;
--
-- create policy "post_comment_reports scans to everyone"
--     on post_comment_reports
--     for select
--     using (true);
--
-- create policy "post_comment_reports create only authenticated"
--     on post_comment_reports
--     for insert to authenticated
--     with check (true);
--
-- create policy "post_comment_reports update only authenticated owner"
--     on post_comment_reports
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "post_reports delete only authenticated owner"
--     on post_comment_reports
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- CREATE OR REPLACE FUNCTION check_post_comment_report_count()
--     RETURNS TRIGGER AS
-- $$
-- DECLARE
--     report_count INTEGER;
-- BEGIN
--     SELECT COUNT(*)
--     INTO report_count
--     FROM post_comment_reports
--     WHERE post_comment_id = NEW.post_comment_id;
--
--     IF report_count > 10 THEN
--         DELETE
--         FROM post_comments
--         WHERE id = NEW.post_comment_id;
--     END IF;
--
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER check_post_comment_report_count_trigger
--     AFTER INSERT
--     ON post_comment_reports
--     FOR EACH ROW
-- EXECUTE FUNCTION check_post_comment_report_count();
--
-- -- MARK: - DISCUSSIONS
--
-- create type discussion_categories as enum ('general', 'technology', 'science', 'politics', 'sports', 'health', 'entertainment', 'education', 'business', 'other');
--
-- create table discussions
-- (
--     id            uuid                     default extensions.uuid_generate_v4() primary key,
--     user_id       uuid references user_profiles on delete cascade                                         not null,
--     created_at    timestamp with time zone default now()                                                  not null,
--     updated_at    timestamp with time zone,
--
--     category      discussion_categories,
--     title         text                                                                                    not null,
--     content       text,
--     images        text[],
--     video         text,
--
--     fts           tsvector generated always as (to_tsvector('turkish', (title || ' ' || content))) stored not null,
--
--     points        int                      default 0                                                      not null,
--     view_counts   int                      default 0                                                      not null,
--     answer_counts int                      default 0                                                      not null,
--     answer_id     uuid
-- );
--
-- create index discussions_fts_pkey on discussions using gin (fts);
-- create index discussions_user_id_pkey on discussions using btree (user_id);
--
-- alter table discussions
--     enable row level security;
--
-- create policy "discussions scans to everyone"
--     on discussions
--     for select
--     using (true);
--
-- create policy "discussions create only authenticated"
--     on discussions
--     for insert to authenticated
--     with check (true);
--
-- create policy "discussions update only authenticated owner"
--     on discussions
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "discussions delete only authenticated owner"
--     on discussions
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- create table discussion_answers
-- (
--     id             uuid                     default extensions.uuid_generate_v4() primary key,
--     user_id        uuid references user_profiles on delete cascade not null,
--     discussion_id  uuid references discussions on delete cascade   not null,
--     created_at     timestamp with time zone default now()          not null,
--     updated_at     timestamp with time zone,
--     content        text,
--
--     points         int                      default 0              not null,
--     comment_counts int                      default 0              not null
-- );
--
--
-- ALTER TABLE discussions
--     ADD FOREIGN KEY (answer_id) REFERENCES discussion_answers (id) ON DELETE CASCADE;
--
-- create index discussion_answers_user_id_pkey on discussion_answers using btree (user_id);
--
-- alter table discussion_answers
--     enable row level security;
--
-- create policy "discussion_answers scans to everyone"
--     on discussion_answers
--     for select
--     using (true);
--
-- create policy "discussion_answers create only authenticated"
--     on discussion_answers
--     for insert to authenticated
--     with check (true);
--
-- create policy "discussion_answers update only authenticated owner"
--     on discussion_answers
--     for update to authenticated
--     using ((select auth.uid()) = user_id)
--     with check ((select auth.uid()) = user_id);
--
-- create policy "discussion_answers delete only authenticated owner"
--     on discussion_answers
--     for delete
--     using ((select auth.uid()) = user_id);
--
-- create type discussion_vote_type as enum ('up', 'down');
--
-- create or replace function discussion_answer_set_correct(discussion_id_param UUID, answer_id_param UUID)
--     returns void
--     language plpgsql
--     security definer as
-- $$
-- begin
--
--     update discussions
--     set answer_id = answer_id_param
--     where id = discussion_id_param;
--
-- end;
-- $$;
--
-- create table discussion_votes
-- (
--     user_id       uuid references user_profiles on delete cascade not null,
--     discussion_id uuid references discussions on delete cascade   not null,
--     type          discussion_vote_type                            not null,
--     created_at    timestamp with time zone default now()          not null,
--     constraint discussion_votes_pkey primary key (user_id, discussion_id)
-- );
--
--
-- create table discussion_bookmarks
-- (
--     user_id       uuid references user_profiles on delete cascade not null,
--     discussion_id uuid references discussions on delete cascade   not null,
--     created_at    timestamp with time zone default now()          not null,
--     constraint discussion_bookmarks_pkey primary key (user_id, discussion_id)
-- );
--
-- create type discussion_answer_vote_type as enum ('up', 'down');
--
-- create table discussion_answer_votes
-- (
--     user_id       uuid references user_profiles on delete cascade      not null,
--     discussion_id uuid references discussions on delete cascade        not null,
--     answer_id     uuid references discussion_answers on delete cascade not null,
--     type          discussion_answer_vote_type                          not null,
--     created_at    timestamp with time zone default now()               not null,
--     constraint discussion_answer_votes_pkey primary key (user_id, discussion_id, answer_id)
-- );
--
-- drop function if exists is_discussion_vote_by_user(user_id_param UUID, discussion_ids UUID[]);
--
-- CREATE
--     OR REPLACE FUNCTION is_discussion_vote_by_user(user_id_param UUID, discussion_ids UUID[])
--     RETURNS TABLE
--             (
--                 discussion_id UUID,
--                 TYPE          discussion_vote_type
--             )
-- AS
-- $$
-- BEGIN
--     RETURN QUERY
--         SELECT d.id    as discussion_id,
--                CASE
--                    WHEN dv.user_id IS NULL THEN NULL
--                    WHEN dv.type = 'up' THEN 'up'::discussion_vote_type
--                    WHEN dv.type = 'down' THEN 'down'::discussion_vote_type
--                    END as type
--         FROM discussions d
--                  LEFT JOIN discussion_votes dv ON dv.user_id = user_id_param AND dv.discussion_id = d.id
--         WHERE d.id = ANY (discussion_ids);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- --
--
-- drop function if exists is_discussion_answers_vote_by_user(user_id_param UUID, answers_ids UUID[]);
--
-- CREATE
--     OR REPLACE FUNCTION is_discussion_answers_vote_by_user(user_id_param UUID, answers_ids UUID[])
--     RETURNS TABLE
--             (
--                 answer_id UUID,
--                 TYPE      discussion_answer_vote_type
--             )
-- AS
-- $$
-- BEGIN
--     RETURN QUERY
--         SELECT a.id    as answer_id,
--                CASE
--                    WHEN av.user_id IS NULL THEN NULL
--                    WHEN av.type = 'up' THEN 'up'::discussion_answer_vote_type
--                    WHEN av.type = 'down' THEN 'down'::discussion_answer_vote_type
--                    END as type
--         FROM public.discussion_answers a
--                  LEFT JOIN discussion_answer_votes av ON av.user_id = user_id_param AND av.answer_id = a.id
--         WHERE a.id = ANY (answers_ids);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- drop function if exists followers_posts(current_user_id uuid, limits int, offsets int);
-- create
--     or replace function followers_posts(current_user_id uuid, limits int, offsets int)
--     RETURNS table
--             (
--                 id                 uuid,
--                 content            text,
--                 user_id            uuid,
--                 created_at         timestamp with time zone,
--                 updated_at         timestamp with time zone,
--                 images             text[],
--                 video              text,
--                 like_counts        int,
--                 comment_counts     int,
--                 user_profile_photo text,
--                 user_username      text,
--                 user_created_at    timestamp with time zone
--             )
-- AS
-- $$
-- BEGIN
--     RETURN QUERY select posts.id,
--                         posts.content,
--                         posts.user_id,
--                         posts.created_at,
--                         posts.updated_at,
--                         posts.images,
--                         posts.video,
--                         posts.like_counts,
--                         posts.comment_counts,
--                         user_profiles.profile_photo,
--                         user_profiles.username,
--                         user_profiles.created_at
--
--                  from posts
--                           join user_followers ON posts.user_id = user_followers.followed_id
--                           join user_profiles on posts.user_id = user_profiles.id
--                  where user_followers.user_id = current_user_id
--                  order by posts.created_at desc
--                  limit limits offset offsets;
-- END;
-- $$
--     LANGUAGE 'plpgsql';
--
-- create or replace function update_discussions_table_view_counts(discussion_id uuid) returns void
--     language plpgsql
--     security definer as
-- $$
-- begin
--     update discussions
--     set view_counts = view_counts + 1
--     where id = discussion_id;
-- end;
-- $$;
--
-- create
--     or replace function update_discussions_table_answers_count() returns trigger
--     language plpgsql
--     security definer as
-- $$
-- begin
--     if
--         (TG_OP = 'DELETE') then
--         update discussions
--         set answer_counts = answer_counts - 1
--         where id = OLD.discussion_id;
--     elsif
--         (TG_OP = 'INSERT') then
--         update discussions
--         set answer_counts = answer_counts + 1
--         where id = NEW.discussion_id;
--     end if;
--     return NEW;
-- end;
-- $$;
--
-- create trigger
--     trigger_discussions_table_answers_count_update
--     after
--         insert or delete
--     on discussion_answers
--     for each row
-- execute
--     procedure update_discussions_table_answers_count();
--
--
-- create
--     or replace function update_discussions_table_points_count() returns trigger
--     language plpgsql
--     security definer as
-- $$
-- begin
--     if
--         (TG_OP = 'DELETE') then
--         update discussions
--         set points = points - 1
--         where id = OLD.discussion_id;
--     elsif
--         (TG_OP = 'INSERT') then
--         if (NEW.type = 'up') then
--             update discussions
--             set points = points + 1
--             where id = NEW.discussion_id;
--         elsif (NEW.type = 'down') then
--             update discussions
--             set points = points - 1
--             where id = NEW.discussion_id;
--         end if;
--     end if;
--     return NEW;
-- end;
-- $$;
--
-- create trigger
--     trigger_discussions_table_points_count_update
--     after
--         insert
--         or
--         delete
--     on discussion_votes
--     for each row
-- execute
--     procedure update_discussions_table_points_count();
--
--
--
-- create
--     or replace function update_discussion_answers_table_points_count() returns trigger
--     language plpgsql
--     security definer as
-- $$
-- begin
--     if
--         (TG_OP = 'DELETE') then
--         update discussion_answers
--         set points = points - 1
--         where id = OLD.answer_id;
--     elsif
--         (TG_OP = 'INSERT') then
--         if (NEW.type = 'up') then
--             update discussion_answers
--             set points = points + 1
--             where id = NEW.answer_id;
--         elsif (NEW.type = 'down') then
--             update discussion_answers
--             set points = points - 1
--             where id = NEW.answer_id;
--         end if;
--     end if;
--     return NEW;
-- end;
-- $$;
--
-- create trigger
--     trigger_discussions_table_points_count_update
--     after
--         insert
--         or
--         delete
--     on discussion_answer_votes
--     for each row
-- execute
--     procedure update_discussion_answers_table_points_count();
--
-- insert into user_profiles (id, username)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'cihan'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e', 'burrcuu'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4', 'cansu');
--
-- insert into user_followers (user_id, followed_id)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4');
--
-- insert into posts (id, user_id, content, created_at)
-- values ('3a27023c-7afa-4d4b-9791-756ae8c0e7a1', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam id ligula a urna placerat dapibus et eu urna. Morbi sodales enim eget tortor ornare, nec iaculis purus ultricies. Nam tempor augue sit amet pharetra feugiat. Nam a lorem vulputate, tempus ligula quis, mattis nisi. Fusce turpis tellus, tincidunt non posuere et, molestie sit amet nisl. Donec tortor dui, porttitor id mauris nec, sodales rutrum ipsum. Proin tristique feugiat condimentum.
--
-- Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sagittis, ex a elementum sollicitudin, est turpis tincidunt mauris, non convallis elit magna vel eros. Donec pretium volutpat sapien at convallis. Etiam finibus dignissim maximus. Cras sagittis neque et ante tincidunt consectetur. Nullam fermentum sapien eu metus malesuada, vel placerat est semper. Curabitur mollis convallis quam, in ornare purus ornare id. Phasellus sit amet tortor massa. Nulla molestie sapien et laoreet sagittis.
--
-- Aliquam erat volutpat. Integer ornare eleifend auctor. Nulla rutrum ullamcorper nulla, vitae rhoncus dolor. Curabitur hendrerit pretium purus, in rutrum est tempor ut. Suspendisse vestibulum ante quis ipsum ornare, id scelerisque ante placerat. Ut nisl ligula, sodales et rhoncus eget, pharetra laoreet mi. Praesent dolor arcu, maximus sed augue sit amet, vestibulum ultrices leo. Sed nisi dolor, sollicitudin in diam ut, volutpat convallis augue. In tortor nunc, mollis in sodales vitae, elementum id ante. Interdum et malesuada fames ac ante ipsum primis in faucibus. Proin ac mauris tempor, convallis risus id, mollis tellus. Morbi at porta est, in gravida felis. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
--
-- Sed in ex eu lectus mattis pellentesque a vitae neque. Aenean sed sapien odio. Suspendisse in mauris pharetra, cursus nisi sit amet, consectetur odio. Etiam ac rhoncus quam. Proin a arcu et ex euismod porta in sit amet diam. Mauris nibh orci, venenatis eu tempor a, molestie sed dolor. Phasellus luctus odio aliquam, convallis erat vel, suscipit est. Ut mattis elementum ipsum, vel porta metus rhoncus sed. Cras accumsan urna iaculis mauris facilisis, quis lacinia velit bibendum. Sed dui magna, vestibulum eu est molestie, tincidunt tristique mi. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam purus ante, congue vehicula velit sed, pretium luctus dolor.
--
-- Donec mattis, massa ac accumsan tempor, libero augue sollicitudin lorem, ut consectetur sapien ex a tortor. Mauris egestas nisi augue, at euismod velit aliquam a. Integer tellus nulla, malesuada a mi mollis, tristique eleifend est. Cras vitae consequat libero. Cras feugiat enim eu aliquam luctus. Fusce ornare tempor luctus. Nam non ullamcorper magna, eu cursus leo. Maecenas pellentesque nisl eget ante porttitor, sed lacinia augue ultrices. Quisque gravida libero est, nec vulputate tortor iaculis eu. Curabitur ultrices urna libero. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer in eleifend enim, non vestibulum arcu. Pellentesque lorem massa, convallis ut elit non, dapibus mollis augue. Nam rhoncus blandit nunc, id dictum quam consectetur vitae.
--
-- Generated 5 paragraphs, 472 words, 3149 bytes of Lorem Ipsum',
--         now()),
--        ('3a27023c-7afa-4d4b-9791-756ae8c0e7a2', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         'This is my second post',
--         now() - interval '2 month'),
--        ('3a27023c-7afa-4d4b-9791-756ae8c0e7a3', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         'This is my thrid post',
--         now() - interval '3 month');
--
-- insert into post_comments (id, user_id, post_id, comment)
-- values ('11f64f8e-c60a-4eb0-9c78-0d1493f15952', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15953', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15954', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15955', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15956', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15957', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15958', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15959', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15960', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15961', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15962', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15963', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment');
--
--
-- insert into post_comments (user_id, post_id, comment)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment This is my first comment'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment This is my second comment'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment This is my third comment'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment This is my fourth comment'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment This is my fifth comment'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment This is my sixth comment');
--
-- insert into post_likes (user_id, post_id)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', '3a27023c-7afa-4d4b-9791-756ae8c0e7a3');
--
--
-- insert into discussions (id, user_id, title, content)
-- values ('3a27023c-7afa-4d4b-9791-756ae8c0e7a1', '8198da01-b78b-488e-917c-fb7c8df7d0b0', 'Hello World 1',
--         'This is my first post'),
--        ('3a27023c-7afa-4d4b-9791-756ae8c0e7a2', '8198da01-b78b-488e-917c-fb7c8df7d0b0', 'Hello World 2',
--         'This is my second post');
--
-- insert into discussions (user_id, title, content)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'Hello World 3', 'This is my third post'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4', 'Hello World 4', 'This is my fourth post'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e', 'Hello World 5', 'This is my fifth post'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e', 'Hello World 6', 'This is my sixth post'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4', 'Hello World 7', 'This is my seventh post'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'Hello World 8', 'This is my eighth post'),
--        ('a817bedd-dd12-4043-9be9-fb6f948b0cd4', 'Hello World 9', 'This is my ninth post'),
--        ('c9c07ce8-fd55-41ce-9e55-b6006abc820e', 'Hello World 10', 'This is my tenth post'),
--        ('8198da01-b78b-488e-917c-fb7c8df7d0b0', 'Hello World 11', 'This is my eleventh post');
-- insert into discussion_votes (user_id, discussion_id, type)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', '3a27023c-7afa-4d4b-9791-756ae8c0e7a1', 'up');
--
-- insert into discussion_answers (id, user_id, discussion_id, content)
-- values ('11f64f8e-c60a-4eb0-9c78-0d1493f15952', '8198da01-b78b-488e-917c-fb7c8df7d0b0',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a2', 'Caniss nocere in pius revalia!'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15953', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a2', 'Not order or heavens, visualize the totality.'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15954', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1', 'Try roasting chickpeas paste varnished with worcestershire sauce.'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15955', 'a817bedd-dd12-4043-9be9-fb6f948b0cd4',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'Pins laugh with horror at the rough madagascar! The rough madagascar is a rough madagascar.'),
--        ('11f64f8e-c60a-4eb0-9c78-0d1493f15956', 'c9c07ce8-fd55-41ce-9e55-b6006abc820e',
--         '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         'The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. The cosmonaut is virtually chemical. ');
--
--
-- insert into discussion_answer_votes (user_id, discussion_id, answer_id, type)
-- values ('8198da01-b78b-488e-917c-fb7c8df7d0b0', '3a27023c-7afa-4d4b-9791-756ae8c0e7a1',
--         '11f64f8e-c60a-4eb0-9c78-0d1493f15952', 'up');
--
-- -- insert into storage.buckets (id, name, public)
-- -- values ('assets', 'assets', true);
-- --
-- -- create policy "assets scans to everyone"
-- --     on storage.objects
-- --     for select
-- --     using (
-- --     bucket_id = 'assets'
-- --         and
-- --     true);
-- --
-- -- create policy "assets upload only authenticated"
-- --     on storage.objects
-- --     for insert to authenticated
-- --     with check (bucket_id = 'assets');
-- --
-- -- create policy "assets delete only authenticated own objects"
-- --     on storage.objects
-- --     for delete to authenticated
-- --     using (
-- --     bucket_id = 'assets'
-- --         and
-- --     owner = (select auth.uid())
-- --     );
