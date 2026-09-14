-- ============================================================
-- Setup Supabase para o formulário de candidaturas da Supreme
-- Corre isto uma vez no SQL Editor do teu projeto (supabase.com/dashboard)
-- ============================================================

-- 1) Tabela de candidaturas
create table if not exists public.candidaturas (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  nome text not null,
  idade int not null,
  modalidade text not null check (modalidade in ('part-time','full-time','freelancer')),
  experiencia boolean not null,
  detalhes text,
  cv_path text,
  cv_filename text
);

-- 2) Ativa Row Level Security (RLS)
alter table public.candidaturas enable row level security;

-- 3) Permite que qualquer visitante da página (anon) CRIE candidaturas,
--    mas ninguém pode ler, editar ou apagar a partir do browser.
--    Tu continuas a ver tudo no Table Editor do Supabase (usa a service role).
drop policy if exists "Qualquer pessoa pode candidatar-se" on public.candidaturas;

create policy "Qualquer pessoa pode candidatar-se"
  on public.candidaturas
  for insert
  to anon
  with check (true);

-- ============================================================
-- 4) Bucket de Storage para os CVs
--    Cria manualmente em Storage → New bucket → nome "cvs" → Public: OFF
--    (ou corre o insert abaixo, se o teu projeto permitir)
-- ============================================================
insert into storage.buckets (id, name, public)
values ('cvs', 'cvs', false)
on conflict (id) do nothing;

-- 5) Permite que qualquer visitante FAÇA UPLOAD de um CV para o bucket,
--    mas não pode listar nem descarregar ficheiros de outras pessoas.
drop policy if exists "Qualquer pessoa pode enviar o seu CV" on storage.objects;

create policy "Qualquer pessoa pode enviar o seu CV"
  on storage.objects
  for insert
  to anon
  with check (bucket_id = 'cvs');

-- ============================================================
-- Para consultares os CVs mais tarde: Storage → bucket "cvs" no dashboard
-- (aí entras com a tua conta, não com o anon key, por isso as políticas
-- acima não te bloqueiam a ti).
-- ============================================================
