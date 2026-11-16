-- TIPNOVA: seguimiento entre creadores
-- Ejecutar UNA SOLA VEZ en Supabase > SQL Editor > New query.
-- No modifica ni elimina las tablas ni publicaciones existentes.

create table if not exists public.tip_follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  followed_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint tip_follows_no_self check (follower_id <> followed_id),
  constraint tip_follows_pk primary key (follower_id, followed_id)
);

alter table public.tip_follows enable row level security;

grant select, insert, delete on public.tip_follows to anon, authenticated;

drop policy if exists "Anyone can view creator follows" on public.tip_follows;
create policy "Anyone can view creator follows"
  on public.tip_follows for select
  using (true);

drop policy if exists "Users can follow as themselves" on public.tip_follows;
create policy "Users can follow as themselves"
  on public.tip_follows for insert
  to authenticated
  with check (auth.uid() = follower_id);

drop policy if exists "Users can unfollow as themselves" on public.tip_follows;
create policy "Users can unfollow as themselves"
  on public.tip_follows for delete
  to authenticated
  using (auth.uid() = follower_id);

create index if not exists tip_follows_followed_id_idx
  on public.tip_follows (followed_id);
