#!/usr/bin/env bash
# =============================================================================
# setup-dev.sh — MCC Taganrog
# Настройка рабочего окружения разработчика для Flutter-проекта.
# Запускается один раз после клонирования (или повторно для обновления).
#
# Использование:
#   curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/setup-dev.sh | bash
# =============================================================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BASE_URL="https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main"

log_info()    { echo -e "${CYAN}[MCC]${NC} $1"; }
log_success() { echo -e "${GREEN}[ ✓ ]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo -e "${CYAN}MCC Taganrog — Developer Setup${NC}"
echo ""

# -----------------------------------------------------------------------------
# Проверка: git репозиторий
# -----------------------------------------------------------------------------
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  log_error "Git репозиторий не найден. Запусти скрипт из корня Flutter-проекта."
fi

# Определяем режим: установка или обновление
if [[ -f ".githooks/commit-msg" ]]; then
  MODE="update"
  log_info "Обновление..."
else
  MODE="install"
  log_info "Установка..."
fi

# -----------------------------------------------------------------------------
# Git hook: commit-msg (проверка Conventional Commits)
# -----------------------------------------------------------------------------
mkdir -p .githooks
curl -fsSL "${BASE_URL}/.githooks/commit-msg" -o .githooks/commit-msg
chmod +x .githooks/commit-msg
git config --local core.hooksPath .githooks/
log_success "commit-msg hook → .githooks/"

# -----------------------------------------------------------------------------
# commitlint.config.js
# -----------------------------------------------------------------------------
curl -fsSL "${BASE_URL}/commitlint.config.js" -o commitlint.config.js
log_success "commitlint.config.js"

# -----------------------------------------------------------------------------
# commitlint — проверяем наличие, устанавливаем глобально если нет
# -----------------------------------------------------------------------------
if command -v commitlint &> /dev/null; then
  log_success "commitlint уже установлен ($(commitlint --version))"
elif [[ -f "node_modules/.bin/commitlint" ]]; then
  log_success "commitlint найден в node_modules"
else
  if command -v npm &> /dev/null; then
    log_info "Устанавливаем commitlint глобально..."
    npm install -g @commitlint/cli @commitlint/config-conventional
    log_success "commitlint установлен"
  else
    log_warning "npm не найден — установи Node.js вручную, затем:"
    log_warning "npm install -g @commitlint/cli @commitlint/config-conventional"
  fi
fi

# -----------------------------------------------------------------------------
# Git alias: pm — push с автосозданием Draft MR
# -----------------------------------------------------------------------------
git config --local alias.pm "push -o merge_request.create -o merge_request.draft"
log_success "git alias 'pm' → push + Draft MR"

# -----------------------------------------------------------------------------
# Итог
# -----------------------------------------------------------------------------
echo ""
if [[ "$MODE" == "install" ]]; then
  echo -e "${GREEN}Готово!${NC} Доступные команды:"
else
  echo -e "${GREEN}Обновлено!${NC} Доступные команды:"
fi
echo "  git pm          первый пуш ветки + автоматически создаёт Draft MR"
echo "  git commit      проверяет формат сообщения (Conventional Commits)"
echo ""
echo "Формат коммитов: feat: | fix: | chore: | docs: | refactor: | ci: | test:"
echo ""
