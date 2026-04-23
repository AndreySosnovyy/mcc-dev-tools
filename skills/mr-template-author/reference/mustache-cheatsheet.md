# Mustache cheatsheet — для MCC MR templates

[Mustache](https://mustache.github.io/mustache.5.html) — logic-less шаблонизатор. В MCC он рендерит MR description без HTML-escape (markdown-режим), без custom helper'ов, только базовый набор конструкций.

## Базовые конструкции

| Конструкция | Поведение |
|---|---|
| `{{name}}` | Подставить значение `name`. Если `null` / `undefined` / `false` — пустая строка. Если число — `String(n)`. |
| `{{#name}}block{{/name}}` | Условный блок. Рендерится если `name` truthy. **Если `name` — массив, итерируется по элементам**, контекст внутри = текущий элемент. |
| `{{^name}}block{{/name}}` | Inverted: рендерится если `name` falsy / `null` / пустой массив. Используется для «иначе» / «когда нет данных». |
| `{{.}}` | Implicit iterator — текущий элемент массива внутри секции. Используй внутри `{{#array}}...{{/array}}`. |
| `{{commit_messages_all.1}}` | Доступ ко второму элементу массива (index `1`). Полезный трюк для условия «if length ≥ 2». |
| `{{{name}}}` | Тройные фигурные скобки — без HTML-escape. **Не нужны в MCC** — escape отключён глобально. |
| `{{!comment}}` | Комментарий. Не рендерится. |

## Что в Mustache **нельзя**

- Логические операторы (`{{#a && b}}` — нет такого синтаксиса).
- Сравнения (`{{#count > 5}}` — нельзя).
- Выполнение кода (нет `eval`, `if/else`, `for`, переменных).
- Helper-функции (типа Handlebars `{{uppercase name}}` — отсутствуют).

Если нужна логика — она ДОЛЖНА быть в context-builder'е (Node.js код в `mrTemplateVars.js`). Для template-author'а это означает: спросить нужен ли новый derived placeholder и попросить добавить его в SCHEMA, а не пытаться обойти логически в шаблоне.

## Полезные паттерны

### «Если не пусто, показать заголовок и список»

❌ **Неправильно** (двойной рендер):

```mustache
{{#changed_files_list}}
**Файлы:**
{{#changed_files_list}}
- `{{.}}`
{{/changed_files_list}}
{{/changed_files_list}}
```

Тут внешний `{{#changed_files_list}}` итерирует массив (например, 3 файла), и заголовок «Файлы:» рендерится 3 раза.

✅ **Правильно** (через guard-bool):

```mustache
{{#has_changed_files}}
**Файлы:**
{{#changed_files_list}}
- `{{.}}`
{{/changed_files_list}}
{{/has_changed_files}}
```

`has_changed_files` — derived bool в SCHEMA, true если массив не пуст. Внешняя секция — guard, не итерация.

### «Если массив длинее 1 элемента»

```mustache
{{#commit_messages_all.1}}
Это будет показано если в commit_messages_all 2+ элементов.
{{/commit_messages_all.1}}
```

`.1` — доступ ко второму элементу. Если он есть → секция truthy. Это единственный способ «сравнить длину массива» в logic-less Mustache.

### «Опциональная ссылка»

`commit_url`, `slack_thread_link`, `user_name` — могут быть `null`. Оборачивай в условие:

```mustache
{{#commit_url}}
[коммит {{commit_sha_short}}]({{commit_url}})
{{/commit_url}}
{{^commit_url}}
коммит {{commit_sha_short}} _(ссылка недоступна)_
{{/commit_url}}
```

### «Multi-line поле в blockquote»

`prompt` уже преобразован: каждый `\n` стал `\n> `. Просто:

```mustache
> {{prompt}}
```

Не нужно вручную делать `> {{line1}}\n> {{line2}}`.

## Приоритет inverted-секций

`{{^name}}` смотрит на «truthy». В MCC контексте:

| Значение | `{{#name}}` рендерит? | `{{^name}}` рендерит? |
|---|---|---|
| `null` | нет | да |
| `false` | нет | да |
| `''` (пустая строка) | нет | да |
| `[]` (пустой массив) | нет | да |
| `0` (число) | **нет** | **да** ⚠️ |
| `'text'` | да | нет |
| `[item]` | да (итерируется) | нет |
| `1` (число) | да | нет |

⚠️ **Гочa с числами:** `{{#diff_files_count}}...{{/diff_files_count}}` НЕ покажет блок если `diff_files_count === 0`. Если важно показать «0 файлов», используй текст напрямую без guard'а: `Файлов изменено: {{diff_files_count}}` — даст `Файлов изменено: 0`.

## Отладка

- Локально (на сервере MCC) — `mcc mr-template preview <name>` рендерит на mock-данных.
- Проверка плейсхолдеров — `mcc mr-template vars` (список всех известных) или `mcc mr-template set <name>` (warning'и о неизвестных).
- `validateTemplate(text)` (внутренний API) — возвращает `{ok, unknown: [...]}`. Неизвестные плейсхолдеры не блокируют активацию (warning), но рендерятся как пустая строка.
