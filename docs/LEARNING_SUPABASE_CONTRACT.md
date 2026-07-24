# Contrato Supabase — Aprender e Praticar

Documento de handoff para quem configura o banco. O app Flutter já lê estas tabelas via `LearningContentService` / `LearningRepository`.

## Tabelas de conteúdo (leitura do aluno)

### `lesson_categories`

| Coluna | Tipo | Notas |
|--------|------|--------|
| `id` | text PK | Ex.: `cat-1` |
| `title_pt` / `title_en` | text | Fallback: `title` |
| `description_pt` / `description_en` | text | Fallback: `description` |
| `icon` | text | Chave Material (ex.: `school`, `front_hand`) |
| `color` | text | Hex, ex.: `#2D78BB` |
| `order_index` | int | Ordenação |

### `lessons`

| Coluna | Tipo | Notas |
|--------|------|--------|
| `id` | text PK | Ex.: `les-1-1` |
| `category_id` | text FK → `lesson_categories.id` | |
| `title_pt` / `title_en` | text | |
| `summary_pt` / `summary_en` | text | |
| `estimated_minutes` | int | default 5 |
| `difficulty_pt` / `difficulty_en` | text | |
| `objectives_pt` / `objectives_en` | text[] | |
| `references_pt` / `references_en` | text[] | |
| `related_sign_ids` | text[] | IDs do `signs_dictionary` |
| `order_index` | int | |
| `status` | text | `draft` \| `published` \| `archived` — aluno só vê `published` |
| `created_by` | uuid nullable | Para o Estúdio |

### `lesson_sections`

| Coluna | Tipo | Notas |
|--------|------|--------|
| `id` | uuid PK | |
| `lesson_id` | text FK | |
| `title_pt` / `title_en` | text | |
| `body_pt` / `body_en` | text | |
| `bullets_pt` / `bullets_en` | text[] | |
| `highlight_pt` / `highlight_en` | text | |
| `order_index` | int | |

O app mapeia cada seção para blocos visuais (`heading`, `text`, `bullets`, `highlight`).

### `lesson_exercises`

| Coluna | Tipo | Notas |
|--------|------|--------|
| `id` | text PK | |
| `lesson_id` | text FK | |
| `type` | text | `multipleChoice`, `trueFalse`, `matching`, `recognizeSymbol`, `chooseCorrectWriting` |
| `prompt_pt` / `prompt_en` | text | |
| `correct_option_id` | text | |
| `explanation_pt` / `explanation_en` | text | |
| `media_url` | text nullable | Imagem/URL do enunciado |
| `media_asset` | text nullable | Asset local opcional |
| `order_index` | int | |

### `exercise_options`

| Coluna | Tipo |
|--------|------|
| `id` | text PK |
| `exercise_id` | text FK |
| `label_pt` / `label_en` | text |
| `media_url` | text nullable |
| `media_asset` | text nullable |

### `exercise_pairs`

| Coluna | Tipo |
|--------|------|
| `id` | uuid PK |
| `exercise_id` | text FK |
| `left_pt` / `left_en` | text |
| `right_pt` / `right_en` | text |
| `order_index` | int |

## Progresso (sync futuro)

### `user_lesson_progress`

| Coluna | Tipo |
|--------|------|
| `user_id` | uuid PK (parte) → `auth.users` |
| `lesson_id` | text PK (parte) → `lessons` |
| `status` | text: `not_started` \| `in_progress` \| `completed` |
| `best_score` | numeric |
| `attempts` | int |
| `completed_at` | timestamptz |
| `updated_at` | timestamptz |

RLS: usuário só lê/escreve o próprio progresso.

## Papéis (Estúdio)

### `user_roles`

| Coluna | Tipo |
|--------|------|
| `user_id` | uuid |
| `role` | `learner` \| `author` \| `admin` |
| PK | (`user_id`, `role`) |

RLS: usuário lê os próprios papéis; só `admin` concede papéis.

## RLS mínimo de conteúdo

- SELECT em categorias/seções/exercícios vinculados a `lessons.status = 'published'` para autenticados.
- INSERT/UPDATE em `lessons` / `lesson_sections` apenas para `author` ou `admin`.
- Não alterar providers OAuth (Google/Apple) ao criar estas políticas.

## Como validar

```sql
select c.id, c.title_pt, count(l.id) as lessons
from lesson_categories c
left join lessons l on l.category_id = c.id and l.status = 'published'
group by c.id, c.title_pt
order by c.order_index;
```

Quando houver pelo menos uma categoria com lições publicadas, o app usa **somente** o Supabase (o JSON local vira fallback offline).

## Prioridade de conteúdo (S6 — popular)

Ao seedar / publicar, priorizar nesta ordem:

1. **Comece aqui** — o que é SignWriting, Libras vs português, visão expressiva/receptiva  
2. **Ler sinais** — área do sinal, configurações de mão, contato, movimentos básicos  
3. Demais módulos do JSON atual como rascunho até receberem blocos visuais + exercícios  

Meta inicial: ~8–12 lições completas com objetivo, texto, placeholder visual e 3+ exercícios.

## App Flutter já preparado

| Peça | Arquivo |
|------|---------|
| Contrato de leitura | `lib/services/learning_content_service.dart` |
| Repo mock/remoto | `lib/services/learning_repository.dart` |
| Progresso + sync | `lib/services/learning_progress_repository.dart` |
| Authoring (inline) | `lib/views/screens/learn_practice_screen.dart` |
| Papéis | `lib/services/authorization_service.dart` |
