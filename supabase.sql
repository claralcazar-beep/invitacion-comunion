-- Ejecutar en Supabase → SQL Editor → New query → Run
create table if not exists public.confirmaciones (
  id          bigint generated always as identity primary key,
  creado_en   timestamptz not null default now(),
  nombre      text not null,
  telefono    text,
  asiste      boolean not null default true,
  adultos     smallint not null default 1 check (adultos between 0 and 15),
  ninos       smallint not null default 0 check (ninos between 0 and 15),
  mensaje     text
);

-- Seguridad: cualquiera con el link puede REGISTRAR (insert) pero nadie puede LEER la lista desde la web.
alter table public.confirmaciones enable row level security;

create policy "invitados pueden registrarse"
  on public.confirmaciones for insert
  to anon
  with check (true);

-- La lista solo la ves tú, en Supabase → Table Editor → confirmaciones.

-- Vista resumen (totales):
create or replace view public.resumen_confirmaciones as
select
  count(*) filter (where asiste)              as familias_confirmadas,
  coalesce(sum(adultos) filter (where asiste),0) as total_adultos,
  coalesce(sum(ninos)   filter (where asiste),0) as total_ninos,
  count(*) filter (where not asiste)          as no_asisten
from public.confirmaciones;
