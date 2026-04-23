{{#is_retry}}> Повторная попытка задачи `{{retry_of_task_id}}`{{/is_retry}}

## Описание

{{commit_title}}

{{#commit_messages_all.1}}
**Коммиты ({{commit_count}}):**
{{#commit_messages_all}}
- {{.}}
{{/commit_messages_all}}
{{/commit_messages_all.1}}

## Контекст

Исходный запрос пользователя{{#user_name}} ({{user_name}}){{/user_name}}:

> {{prompt}}

{{#thread_history_used}}_В контекст была включена история Slack-треда._{{/thread_history_used}}

{{#target_override}}
> ⚠️ Target-ветка переопределена флагом: `{{target_branch}}`
{{/target_override}}

## Изменения

| Метрика | Значение |
|---|---|
| Файлов изменено | {{diff_files_count}} |
| Добавлено строк | +{{diff_added}} |
| Удалено строк | −{{diff_deleted}} |
| Коммитов | {{commit_count}} |
| Source → Target | `{{source_branch}}` → `{{target_branch}}` |
| Базовый ref | `{{base_ref}}` |

{{#has_changed_files}}
**Затронутые файлы:**
{{#changed_files_list}}
- `{{.}}`
{{/changed_files_list}}
{{#changed_files_extra_count}}
_… и ещё {{changed_files_extra_count}} файлов_
{{/changed_files_extra_count}}
{{/has_changed_files}}

{{#review_enabled}}
## AI Review

{{#review_status_ok}}
<details>
<summary>Pre-MR review (модель: <code>{{review_model}}</code>, {{review_duration_sec}}s{{#review_was_partial}}, частично{{/review_was_partial}}) — раскрыть</summary>

{{review_text_full}}

{{#review_was_partial}}

> ⚠️ Review не уложился в отведённое время ({{review_timeout_sec}}s), показан частичный результат. Полный review через `cc bigreview <task>` в треде.
{{/review_was_partial}}

</details>
{{/review_status_ok}}

{{^review_status_ok}}
{{#review_skipped_generated}}
> Review пропущен: diff состоит только из сгенерированных файлов ({{review_generated_files_count}}).
{{/review_skipped_generated}}
{{^review_skipped_generated}}
{{#review_cancelled_by_user}}
> Review был пропущен пользователем во время выполнения.
{{/review_cancelled_by_user}}
{{^review_cancelled_by_user}}
> ⚠️ Review не выполнен: **{{review_status}}**{{#review_reason_human}} — {{review_reason_human}}{{/review_reason_human}}.
{{/review_cancelled_by_user}}
{{/review_skipped_generated}}
{{/review_status_ok}}
{{/review_enabled}}

## Чеклист ревьюера

- [ ] Изменения соответствуют исходному запросу
- [ ] Поведение проверено локально (если применимо)
- [ ] Тесты добавлены/обновлены (если применимо)
- [ ] Документация обновлена (если применимо)

---

_{{mode_label}} · модель `{{model_short}}` · {{duration_human}} · tokens in/out/cache: {{coder_tokens_in}}/{{coder_tokens_out}}/{{coder_tokens_cache_read}}_

_commit [`{{commit_sha_short}}`]({{commit_url}}) · task `{{task_id}}`{{#flag_autoconfirm}} · auto-confirm{{/flag_autoconfirm}}{{#slack_thread_link}} · [Slack-тред]({{slack_thread_link}}){{/slack_thread_link}}_

_auto-created by MCC Taganrog_
