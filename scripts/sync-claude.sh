#!/usr/bin/env bash
# =============================================================================
# sync-claude.sh — MCC Taganrog dev-tools
# Синхронизирует ~/.claude/ с MCC сервером по SSH.
# Запускается разработчиком локально после изменения Claude-конфигов.
#
# Использование:
#   bash sync-claude.sh user@mac-mini.local
#   bash sync-claude.sh                        # возьмёт SERVER_SSH из env или спросит
#   bash sync-claude.sh --dry-run user@host    # показать что будет синхронизировано
#
# Что синхронизируется: CLAUDE.md, settings.json, skills/, commands/, rules/
# Что пропускается:     projects/, todos/, plans/, .cache/, *.jsonl
# =============================================================================

set -e
set -o pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[ ✓ ]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# -----------------------------------------------------------------------------
# Аргументы
# -----------------------------------------------------------------------------
DRY_RUN=false
SERVER_ARG=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=true ;;
    --help|-h)
      echo "Использование: sync-claude.sh [--dry-run] [user@host]"
      echo ""
      echo "  user@host    SSH адрес сервера"
      echo "               Также можно задать через переменную SERVER_SSH в окружении."
      echo "  --dry-run    показать что будет синхронизировано, ничего не менять"
      echo ""
      echo "Что синхронизируется:"
      echo "  ~/.claude/CLAUDE.md, settings.json, skills/, commands/, rules/"
      echo ""
      echo "Что пропускается (машино-специфичное):"
      echo "  projects/, todos/, plans/, .cache/, *.jsonl"
      exit 0
      ;;
    -*) log_error "Неизвестный флаг: $1" ;;
    *)  SERVER_ARG="$1" ;;
  esac
  shift
done

# -----------------------------------------------------------------------------
# Определяем адрес сервера
# -----------------------------------------------------------------------------
SERVER="${SERVER_ARG:-${SERVER_SSH:-}}"

if [[ -z "$SERVER" ]]; then
  echo ""
  read -rp "SSH адрес сервера (например, andrey@mac-mini.local): " SERVER
  [[ -z "$SERVER" ]] && log_error "Адрес сервера не может быть пустым"
fi

# -----------------------------------------------------------------------------
# Источник
# -----------------------------------------------------------------------------
SRC="$HOME/.claude/"

if [[ ! -d "$SRC" ]]; then
  log_error "Директория ~/.claude/ не найдена. Claude Code установлен?"
fi

DST="${SERVER}:~/.claude/"

# -----------------------------------------------------------------------------
# Шапка
# -----------------------------------------------------------------------------
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${CYAN}sync-claude (dry run)${NC}"
  echo -e "${CYAN}Ничего не изменяется — только предпросмотр.${NC}"
else
  echo -e "${CYAN}sync-claude${NC}"
fi
echo ""
echo -e "  Источник : ${BLUE}${SRC}${NC}"
echo -e "  Сервер   : ${BLUE}${DST}${NC}"
echo ""

# -----------------------------------------------------------------------------
# Проверка SSH доступа
# -----------------------------------------------------------------------------
if [[ "$DRY_RUN" != "true" ]]; then
  log_info "Проверяем SSH соединение с ${SERVER}..."
  if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$SERVER" true 2>/dev/null; then
    log_error "Нет SSH доступа к ${SERVER}. Проверь ключи и адрес."
  fi
  log_success "SSH соединение установлено"
  echo ""
fi

# -----------------------------------------------------------------------------
# Синхронизация
#
# Пропускаем машино-специфичные данные:
#   projects/ — история диалогов и memory по проектам
#   todos/    — задачи текущей сессии
#   plans/    — файлы планирования
#   .cache/   — кэш моделей
#   *.jsonl   — логи диалогов (могут лежать в корне ~/.claude/)
# -----------------------------------------------------------------------------
log_info "Синхронизируем конфиги..."
echo ""

RSYNC_OPTS=(
  -avz
  --progress
  --exclude="projects/"
  --exclude="todos/"
  --exclude="plans/"
  --exclude=".cache/"
  --exclude="*.jsonl"
)

[[ "$DRY_RUN" == "true" ]] && RSYNC_OPTS+=(--dry-run)

rsync "${RSYNC_OPTS[@]}" "$SRC" "$DST"

# -----------------------------------------------------------------------------
# Итог
# -----------------------------------------------------------------------------
echo ""
if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${CYAN}Dry run завершён. Для реальной синхронизации запусти без --dry-run.${NC}"
else
  log_success "Готово. ~/.claude/ синхронизирован → ${SERVER}"
  echo ""
  echo "Что синхронизировано: CLAUDE.md, settings.json, skills/, commands/, rules/"
  echo "Пропущено:            projects/, todos/, plans/, .cache/, *.jsonl"
fi
echo ""
