{{#is_retry}}> Повторная попытка задачи `{{retry_of_task_id}}`{{/is_retry}}

## Описание

{{commit_title}}

## Контекст

> {{prompt}}

{{#target_override}}> ⚠️ Target переопределён: `{{target_branch}}`{{/target_override}}

**Изменения:** {{diff_files_count}} файл(ов) · +{{diff_added}} / −{{diff_deleted}}{{#commit_count}} · коммитов {{commit_count}}{{/commit_count}}

{{#review_enabled}}
{{#review_status_ok}}
<details>
<summary>Pre-MR review ({{review_model}}, {{review_duration_sec}}s)</summary>

{{review_text_full}}

</details>
{{/review_status_ok}}
{{^review_status_ok}}
> Review не выполнен: {{review_reason_human}}
{{/review_status_ok}}
{{/review_enabled}}

---
_{{mode_label}} · `{{model_short}}` · {{duration_human}} · [`{{commit_sha_short}}`]({{commit_url}}) · task `{{task_id}}`{{#flag_autoconfirm}} · auto-confirm{{/flag_autoconfirm}}_
