-- As relações internas do Mini AVA são dependentes da lição/módulo.
-- Com ON DELETE CASCADE, o Postgres executa toda a remoção na mesma
-- transação: qualquer erro cancela a operação inteira.

alter table public.exercise_options
  drop constraint if exists exercise_options_exercise_id_fkey,
  add constraint exercise_options_exercise_id_fkey
    foreign key (exercise_id)
    references public.lesson_exercises (id)
    on delete cascade;

alter table public.exercise_pairs
  drop constraint if exists exercise_pairs_exercise_id_fkey,
  add constraint exercise_pairs_exercise_id_fkey
    foreign key (exercise_id)
    references public.lesson_exercises (id)
    on delete cascade;

alter table public.lesson_sections
  drop constraint if exists lesson_sections_lesson_id_fkey,
  add constraint lesson_sections_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade;

alter table public.lesson_exercises
  drop constraint if exists lesson_exercises_lesson_id_fkey,
  add constraint lesson_exercises_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade;

alter table public.lesson_blocks
  drop constraint if exists lesson_blocks_lesson_id_fkey,
  add constraint lesson_blocks_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade;

alter table public.lesson_sources
  drop constraint if exists lesson_sources_lesson_id_fkey,
  add constraint lesson_sources_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade;

alter table public.lesson_media
  drop constraint if exists lesson_media_lesson_id_fkey,
  add constraint lesson_media_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade;

alter table public.user_lesson_progress
  drop constraint if exists user_lesson_progress_lesson_id_fkey,
  add constraint user_lesson_progress_lesson_id_fkey
    foreign key (lesson_id)
    references public.lessons (id)
    on delete cascade,
  drop constraint if exists user_lesson_progress_category_id_fkey,
  add constraint user_lesson_progress_category_id_fkey
    foreign key (category_id)
    references public.lesson_categories (id)
    on delete cascade;

alter table public.lessons
  drop constraint if exists lessons_category_id_fkey,
  add constraint lessons_category_id_fkey
    foreign key (category_id)
    references public.lesson_categories (id)
    on delete cascade;
