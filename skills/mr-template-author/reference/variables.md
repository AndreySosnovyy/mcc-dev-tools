# MR Template — реестр плейсхолдеров

> Auto-generated from `slack-bot/src/mrTemplateVars.js` (SCHEMA).
> Не редактируй вручную — пересобери через `node scripts/gen-template-vars-docs.js`.

Всего плейсхолдеров: **57**.

## Синтаксис

Шаблоны написаны на [Mustache](https://mustache.github.io/mustache.5.html) (logic-less). Базовые конструкции:

| Конструкция | Что делает |
|---|---|
| `{{name}}` | Подставить значение `name` (без HTML-escape — рендер в markdown-режиме). |
| `{{#name}}...{{/name}}` | Условный блок: рендерится если `name` truthy. Для массива — итерируется по элементам. |
| `{{^name}}...{{/name}}` | Inverted: рендерится если `name` falsy / null / пустой массив. |
| `{{.}}` | Implicit iterator — текущий элемент массива внутри секции. |
| `{{commit_messages_all.1}}` | Доступ ко второму элементу массива (трюк для «if length ≥ 2»). |

## Гочи

- **`changed_files_list` итерируется как массив.** Чтобы НЕ получить двойной рендер, оборачивай его в guard `{{#has_changed_files}}...{{/has_changed_files}}`, а не во внешний `{{#changed_files_list}}`.
- **`prompt`** автоматически преобразован для blockquote: каждая строка содержит `\n> `. Просто используй `> {{prompt}}` — multi-line отрендерится корректно.
- **`review_text_full`** до подстановки уже прошёл markdown-sanitizer: внешние `![](http...)` заменены на `[внешняя картинка]`, `</details>`/`</summary>` escape'нуты. Можно вставлять без обёрток.
- **`*_url` поля** могут быть `null` — оборачивай в `{{#commit_url}}[link]({{commit_url}}){{/commit_url}}`.

## Категории

### Task identity

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{task_id}}` | string | да | `56a4e329` | Уникальный ID задачи (8 hex) |
| `{{started_at_iso}}` | string | да | `2026-04-22T14:31:17.000Z` | ISO timestamp старта |
| `{{duration_sec}}` | number | да | `14` | Длительность задачи (сек) |
| `{{duration_human}}` | string | да | `2m 34s` | Читабельная длительность |
| `{{user_id}}` | string | да | `U0123ABCDEF` | Slack user ID автора |
| `{{user_name}}` | string | нет | `Andrey Sosnovyy` | Имя автора (если resolved) |
| `{{role}}` | string | да | `developer` | Роль автора на момент запуска |
| `{{mode_label}}` | string | да | `Coder` | Режим работы (для UI) |
| `{{command}}` | string | нет | `cc` | Исходная команда (cc/ccy/ask) |

### Prompt и контекст

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{prompt}}` | string | да | `пофикси баг в login` | Задача от пользователя (sanitized) |
| `{{prompt_truncated}}` | string | да | `…` | Первые 500 символов prompt |
| `{{flag_noreview}}` | boolean | да | `false` | Был ли [noreview] prefix |
| `{{flag_bigreview}}` | boolean | да | `false` | Был ли [bigreview] prefix |
| `{{flag_autoconfirm}}` | boolean | да | `false` | ccy (без подтверждения) |
| `{{target_override}}` | string | нет | `develop` | Явно переопределённая target-ветка |
| `{{thread_history_used}}` | boolean | да | `true` | Использовалась ли история Slack-треда |
| `{{thread_history_count}}` | number | нет | `4` | Сообщений в истории треда |
| `{{is_retry}}` | boolean | да | `false` | Это retry упавшей задачи |
| `{{retry_of_task_id}}` | string | нет | `a3b4c5d6` | taskId исходной задачи (если retry) |

### Git state

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{source_branch}}` | string | да | `cc/56a4e329` | Ветка с изменениями |
| `{{target_branch}}` | string | да | `develop` | Target-ветка MR |
| `{{target_branch_source}}` | string | нет | `dev_branch` | Источник target (override/mr_target_branch/dev_branch/default_branch/main_fallback) |
| `{{base_ref}}` | string | нет | `origin/develop` | Git-ref базовой точки |
| `{{base_ref_commit}}` | string | нет | `deadbeef12` | Short SHA base ref |
| `{{commit_sha_short}}` | string | нет | `a1b2c3d4e5` | Short SHA последнего коммита (10 chars) |
| `{{commit_url}}` | string | нет | `https://gitlab.com/acme/app/-/commit/a1b2c3d4e5` | Ссылка на коммит в GitLab |
| `{{commit_title}}` | string | да | `fix: login edge case` | Subject первого коммита |
| `{{commit_messages_all}}` | array | да | `["fix: A", "fix: B"]` | Subject всех коммитов MR (array of string) |
| `{{commit_count}}` | number | да | `2` | Количество коммитов в MR |
| `{{diff_files_count}}` | number | да | `3` | Файлов изменено |
| `{{diff_added}}` | number | да | `47` | Строк добавлено |
| `{{diff_deleted}}` | number | да | `12` | Строк удалено |
| `{{changed_files_list}}` | array | нет | `["lib/main.dart", "lib/auth/login.dart"]` | Top-N изменённых файлов (array of string) |
| `{{has_changed_files}}` | boolean | да | `true` | Derived: changed_files_list не пуст. Используй как guard-секцию вокруг итерации changed_files_list — иначе двойной рендер. |
| `{{changed_files_extra_count}}` | number | нет | `0` | Сколько файлов осталось за пределами top-N |

### AI review

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{review_enabled}}` | boolean | да | `true` | Был ли review запланирован |
| `{{review_status}}` | string | да | `success` | success / noreview / skipped / skipped_config_off / skipped_generated / timeout / timeout_with_partial / cancelled_with_partial / failed / push_failed / null |
| `{{review_status_ok}}` | boolean | да | `true` | Derived: review прошёл успешно |
| `{{review_reason_human}}` | string | нет | `превысил лимит времени` | Человекочитаемая причина fail/skip |
| `{{review_duration_sec}}` | number | нет | `8` | Время выполнения review (сек) |
| `{{review_timeout_sec}}` | number | да | `180` | Timeout review в секундах. Category-driven (trivial=60 / small=90 / medium=180 / large=360 / dep-only=60 / tests-only=120 / noop=30). cc bigreview promote'ит category + увеличивает timeout (до 480 на large) |
| `{{review_model}}` | string | да | `opus` | Модель для review |
| `{{review_text_full}}` | string | нет | `### Findings
…` | Полный markdown от Opus (sanitized) |
| `{{review_cancelled_by_user}}` | boolean | да | `false` | Был ли review отменён пользователем |
| `{{review_was_partial}}` | boolean | да | `false` | Review v2: partial output из-за timeout (использован partial.md) |
| `{{review_skipped_generated}}` | boolean | да | `false` | Review v2: skip при noop + skip_generated_only=true |
| `{{review_generated_files_count}}` | number | нет | `3` | Review v2: количество сгенерированных файлов если skipped_generated |
| `{{review_category}}` | string | нет | `medium` | Review v2: вычисленная category (trivial/small/medium/large/dependency-only/tests-only) |

### Cost / tokens

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{coder_tokens_in}}` | number | да | `6` | Input tokens coder |
| `{{coder_tokens_out}}` | number | да | `447` | Output tokens coder |
| `{{coder_tokens_cache_read}}` | number | нет | `60000` | Cache read tokens |
| `{{coder_num_turns}}` | number | нет | `18` | Количество turn-ов в сессии |
| `{{model_short}}` | string | да | `sonnet` | Короткое имя модели |

### System context

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{project}}` | string | да | `acme-flutter` | Имя проекта MCC |
| `{{gitlab_project_url}}` | string | да | `https://gitlab.com/acme/app` | URL GitLab-проекта |
| `{{draft_mr_actual}}` | boolean | да | `true` | MR создан как Draft |

### Slack

| Плейсхолдер | Тип | Обяз. | Пример | Описание |
|---|---|---|---|---|
| `{{slack_thread_link}}` | string | нет | `https://acme.slack.com/archives/C.../p...` | Permalink на Slack-тред (если config on) |

## Связанные модули

- `slack-bot/src/mrTemplateVars.js` — этот SCHEMA + `buildContext` + `validateTemplate`.
- `slack-bot/src/mrTemplateRender.js` — Mustache-рендер, sanitize пайплайн, blob-gate.
- `slack-bot/src/mrTemplateLoader.js` — priority chain (per-project → bot-default → minimal fallback).
- `slack-bot/src/commands/mrTemplate.js` — Slack-команды `mcc mr-template`.
- `templates/mr/default.md`, `templates/mr/minimal.md` — канонические шаблоны MCC.
