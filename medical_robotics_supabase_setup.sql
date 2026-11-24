-- MEDICAL ROBOTICS: run this whole script in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_site_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 120),
  category text not null,
  summary text not null check (char_length(summary) between 1 and 240),
  content text not null,
  images jsonb not null default '[]'::jsonb,
  video_urls jsonb not null default '[]'::jsonb,
  published_at timestamptz not null default now(),
  author_id uuid not null references auth.users(id)
);

alter table public.admin_users enable row level security;
alter table public.articles enable row level security;

drop policy if exists "Admins can read own admin record" on public.admin_users;
create policy "Admins can read own admin record" on public.admin_users
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Anyone can read published articles" on public.articles;
create policy "Anyone can read published articles" on public.articles
for select to anon, authenticated using (true);

drop policy if exists "Site admins can publish articles" on public.articles;
create policy "Site admins can publish articles" on public.articles
for insert to authenticated with check (public.is_site_admin() and author_id = auth.uid());

drop policy if exists "Site admins can update articles" on public.articles;
create policy "Site admins can update articles" on public.articles
for update to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

drop policy if exists "Site admins can delete articles" on public.articles;
create policy "Site admins can delete articles" on public.articles
for delete to authenticated using (public.is_site_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('article-images', 'article-images', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Public can view article images" on storage.objects;
create policy "Public can view article images" on storage.objects
for select to anon, authenticated using (bucket_id = 'article-images');

drop policy if exists "Site admins can upload article images" on storage.objects;
create policy "Site admins can upload article images" on storage.objects
for insert to authenticated with check (bucket_id = 'article-images' and public.is_site_admin());

drop policy if exists "Site admins can update article images" on storage.objects;
create policy "Site admins can update article images" on storage.objects
for update to authenticated using (bucket_id = 'article-images' and public.is_site_admin())
with check (bucket_id = 'article-images' and public.is_site_admin());

drop policy if exists "Site admins can delete article images" on storage.objects;
create policy "Site admins can delete article images" on storage.objects
for delete to authenticated using (bucket_id = 'article-images' and public.is_site_admin());

-- After signing in once through the site, copy your user UUID from
-- Supabase Dashboard > Authentication > Users and run:
-- insert into public.admin_users (user_id) values ('PASTE-YOUR-AUTH-USER-UUID-HERE');
