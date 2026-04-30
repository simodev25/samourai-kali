#!/usr/bin/env bash
# install-samourai.sh — Install Samourai Devkit into a local project

set -Eeuo pipefail
set -o errtrace
shopt -s inherit_errexit 2>/dev/null || true
IFS=$'\n\t'

readonly APP_NAME="samourai-install"
readonly APP_VERSION="1.0.0"
readonly LOG_TAG="(${APP_NAME})"

readonly EXIT_SUCCESS=0
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3
readonly EXIT_RUNTIME=4

DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"
SKIP_OPENCODE="${SKIP_OPENCODE:-false}"
ALLOW_NON_ROOT="${ALLOW_NON_ROOT:-false}"
EDITORS="${EDITORS:-opencode}"
CORE_ONLY="${CORE_ONLY:-false}"
INTERACTIVE="${INTERACTIVE:-false}"
DOCTOR="${DOCTOR:-false}"
SYMLINK_STACK="${SYMLINK_STACK:-false}"
STACK_DIR="${STACK_DIR:-}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
TARGET_DIR="$(pwd -P)"
CLIENT_DIR=""

readonly STATE_DIR_REL=".samourai/install"
readonly MANIFEST_ADDED_REL="${STATE_DIR_REL}/installed-files.txt"
readonly MANIFEST_UPDATED_REL="${STATE_DIR_REL}/overwritten-files.txt"
readonly MANIFEST_HASH_REL="${STATE_DIR_REL}/installed-files.sha256"
readonly LAST_SUMMARY_REL="${STATE_DIR_REL}/last-install-summary.txt"
readonly CORE_SOURCE_REL="core"
readonly BLUEPRINTS_SOURCE_REL="blueprints"
readonly OPENCODE_SOURCE_REL="adapters/opencode/.opencode"
readonly VSCODE_SOURCE_REL="adapters/vscode"

readonly OPENCODE_ADAPTER_FILES=(
  "README.md"
  ".gitignore"
  "opencode.jsonc"
)

_added=0
_updated=0
_skipped=0

declare -a ADDED_THIS_RUN=()
declare -a UPDATED_THIS_RUN=()

declare -a SYMLINK_STACK_ENTRIES=(
  ".opencode"
  ".samourai"
  "AGENTS.md"
)

_on_err() {
  local -r line="$1" cmd="$2" code="$3"
  log_err "line ${line}: '${cmd}' exited with ${code}"
}

_on_interrupt() {
  log_warn "Interrupted"
  exit 130
}

trap '_on_err $LINENO "$BASH_COMMAND" $?' ERR
trap '_on_interrupt' INT TERM

log_info()  { printf '[INFO]  %s %s\n' "${LOG_TAG}" "$*"; }
log_warn()  { printf '[WARN]  %s %s\n' "${LOG_TAG}" "$*"; }
log_err()   { printf '[ERROR] %s %s\n' "${LOG_TAG}" "$*" >&2; }
log_debug() { [[ "${VERBOSE}" == "true" ]] && printf '[DEBUG] %s %s\n' "${LOG_TAG}" "$*"; true; }

die() {
  log_err "$*"
  exit "${EXIT_USAGE}"
}

prompt_line() {
  local -r label="$1"
  local -r default_value="$2"
  local answer

  if [[ -n "${default_value}" ]]; then
    printf '%s [%s]: ' "${label}" "${default_value}" >&2
  else
    printf '%s: ' "${label}" >&2
  fi

  if read -r answer; then
    printf '%s\n' "${answer:-${default_value}}"
  else
    printf '%s\n' "${default_value}"
  fi
}

confirm_yes() {
  local -r label="$1"
  local answer

  printf '%s [Y/n]: ' "${label}" >&2
  if ! read -r answer; then
    return 0
  fi

  case "${answer}" in
    n|N|no|No|NO) return 1 ;;
    *) return 0 ;;
  esac
}

confirm_no() {
  local -r label="$1"
  local answer

  printf '%s [y/N]: ' "${label}" >&2
  if ! read -r answer; then
    return 1
  fi

  case "${answer}" in
    y|Y|yes|Yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

doctor_ok() { printf 'OK   %s\n' "$*"; }
doctor_warn() { printf 'WARN %s\n' "$*"; }
doctor_fail() { printf 'FAIL %s\n' "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

run_cmd() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    local rendered_cmd
    printf -v rendered_cmd '%q ' "$@"
    log_info "[DRY-RUN] Would execute: ${rendered_cmd% }"
    return 0
  fi
  "$@"
}

safe_relative_path() {
  local -r p="$1"
  [[ -n "${p}" ]] || return 1
  [[ "${p}" != /* ]] || return 1
  [[ "${p}" != *".."* ]] || return 1
  return 0
}

ensure_project_root() {
  local -r dir="$1"

  if [[ -d "${dir}/.git" ]]; then
    return 0
  fi

  local git_root
  git_root="$(git -C "${dir}" rev-parse --show-toplevel 2>/dev/null || true)"

  if [[ -z "${git_root}" ]]; then
    die "Target is not inside a git repository: ${dir}"
  fi

  if [[ "${ALLOW_NON_ROOT}" == "true" ]]; then
    log_warn "Target is not repo root. Continuing because --allow-non-root is set."
    log_warn "Target: ${dir}"
    log_warn "Git root: ${git_root}"
    return 0
  fi

  log_err "Target is not a git root."
  log_err "Target:  ${dir}"
  log_err "Git root: ${git_root}"
  die "Run from project root or use --allow-non-root"
}

resolve_paths() {
  SOURCE_DIR="$(cd -- "${SOURCE_DIR}" && pwd -P)" || die "Invalid source directory: ${SOURCE_DIR}"
  TARGET_DIR="$(cd -- "${TARGET_DIR}" && pwd -P)" || die "Invalid target directory: ${TARGET_DIR}"

  [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/governance" ]] || die "Invalid source: missing ${CORE_SOURCE_REL}/governance (${SOURCE_DIR})"
  [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/templates" ]] || die "Invalid source: missing ${CORE_SOURCE_REL}/templates (${SOURCE_DIR})"
  [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/agents" ]] || die "Invalid source: missing ${CORE_SOURCE_REL}/agents (${SOURCE_DIR})"
  [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/commands" ]] || die "Invalid source: missing ${CORE_SOURCE_REL}/commands (${SOURCE_DIR})"
  [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/skills" ]] || die "Invalid source: missing ${CORE_SOURCE_REL}/skills (${SOURCE_DIR})"
  [[ -d "${SOURCE_DIR}/${BLUEPRINTS_SOURCE_REL}" ]] || die "Invalid source: missing ${BLUEPRINTS_SOURCE_REL} (${SOURCE_DIR})"

  if editor_enabled "opencode"; then
    [[ -f "${SOURCE_DIR}/${OPENCODE_SOURCE_REL}/opencode.jsonc" ]] || die "Invalid source: missing ${OPENCODE_SOURCE_REL}/opencode.jsonc (${SOURCE_DIR})"
  fi

  if editor_enabled "vscode"; then
    [[ -f "${SOURCE_DIR}/${VSCODE_SOURCE_REL}/.github/copilot-instructions.md" ]] || die "Invalid source: missing ${VSCODE_SOURCE_REL}/.github/copilot-instructions.md (${SOURCE_DIR})"
    [[ -f "${SOURCE_DIR}/${VSCODE_SOURCE_REL}/.vscode/mcp.json" ]] || die "Invalid source: missing ${VSCODE_SOURCE_REL}/.vscode/mcp.json (${SOURCE_DIR})"
  fi
}

resolve_symlink_stack_dir() {
  [[ "${SYMLINK_STACK}" == "true" ]] || return 0

  CLIENT_DIR="${TARGET_DIR}"

  if [[ -z "${STACK_DIR}" ]]; then
    local client_parent client_name
    client_parent="$(dirname -- "${CLIENT_DIR}")"
    client_name="$(basename -- "${CLIENT_DIR}")"
    STACK_DIR="${client_parent}/${client_name}-samurai"
  fi

  if [[ -d "${STACK_DIR}" ]]; then
    STACK_DIR="$(cd -- "${STACK_DIR}" && pwd -P)" || die "Invalid stack directory: ${STACK_DIR}"
  else
    local stack_parent stack_name
    stack_parent="$(dirname -- "${STACK_DIR}")"
    stack_name="$(basename -- "${STACK_DIR}")"
    stack_parent="$(cd -- "${stack_parent}" && pwd -P)" || die "Invalid stack parent directory: ${stack_parent}"
    STACK_DIR="${stack_parent}/${stack_name}"
  fi

  if [[ "${STACK_DIR}" == "${CLIENT_DIR}" ]]; then
    die "Stack directory must be separate from target project"
  fi

  case "${STACK_DIR}" in
    "${CLIENT_DIR}"/*)
      die "Stack directory must not be inside target project: ${STACK_DIR}"
      ;;
  esac
}

list_editors() {
  printf '%s\n' "opencode" "vscode"
}

interactive_editor_default() {
  if [[ "${CORE_ONLY}" == "true" ]]; then
    printf '4\n'
    return 0
  fi

  case "${EDITORS}" in
    opencode) printf '1\n' ;;
    vscode) printf '2\n' ;;
    all|opencode,vscode|vscode,opencode) printf '3\n' ;;
    *) printf '1\n' ;;
  esac
}

run_interactive_setup() {
  local target_answer editor_answer default_editor

  printf '\n' >&2
  printf 'Installation Samourai Devkit\n' >&2
  printf '%s\n' '-------------------------' >&2
  printf 'Mode guidé. Appuie sur Entrée pour accepter une valeur par défaut.\n\n' >&2

  target_answer="$(prompt_line "Dossier du projet cible" "${TARGET_DIR}")"
  [[ -n "${target_answer}" ]] || die "Le dossier du projet cible est obligatoire"
  TARGET_DIR="${target_answer}"

  default_editor="$(interactive_editor_default)"
  printf '\nQuel éditeur veux-tu configurer ?\n' >&2
  printf '  1. OpenCode (recommandé)\n' >&2
  printf '  2. VS Code / GitHub Copilot\n' >&2
  printf '  3. OpenCode + VS Code\n' >&2
  printf '  4. Core seulement\n' >&2
  editor_answer="$(prompt_line "Choix" "${default_editor}")"

  case "${editor_answer}" in
    1) EDITORS="opencode"; CORE_ONLY=false ;;
    2) EDITORS="vscode"; CORE_ONLY=false; SKIP_OPENCODE=true ;;
    3) EDITORS="all"; CORE_ONLY=false ;;
    4) CORE_ONLY=true ;;
    *) die "Choix éditeur invalide: ${editor_answer}" ;;
  esac

  if editor_enabled "opencode"; then
    if confirm_yes "Installer OpenCode automatiquement s'il est absent ?"; then
      SKIP_OPENCODE=false
    else
      SKIP_OPENCODE=true
    fi
  fi

  if confirm_no "Faire d'abord une prévisualisation sans écrire de fichiers ?"; then
    DRY_RUN=true
  fi

  printf '\nInstallation prévue:\n' >&2
  printf '  Projet cible: %s\n' "${TARGET_DIR}" >&2
  if [[ "${CORE_ONLY}" == "true" ]]; then
    printf '  Éditeur: core seulement\n' >&2
  else
    printf '  Éditeur: %s\n' "${EDITORS}" >&2
  fi
  printf '  Prévisualisation: %s\n' "${DRY_RUN}" >&2
  printf '  Écrasement forcé: %s\n' "${FORCE}" >&2
  printf '\n' >&2

  confirm_yes "Continuer ?" || die "Installation annulée"
}

run_doctor() {
  local failures=0
  local git_root

  SOURCE_DIR="$(cd -- "${SOURCE_DIR}" && pwd -P)" || die "Invalid source directory: ${SOURCE_DIR}"
  TARGET_DIR="$(cd -- "${TARGET_DIR}" && pwd -P)" || die "Invalid target directory: ${TARGET_DIR}"

  printf 'Samourai Devkit doctor\n'
  printf '%s\n' '----------------------'
  printf 'Target: %s\n\n' "${TARGET_DIR}"

  if git_root="$(git -C "${TARGET_DIR}" rev-parse --show-toplevel 2>/dev/null)"; then
    doctor_ok "Git repository detected: ${git_root}"
  else
    doctor_fail "Target is not inside a Git repository"
    ((failures++)) || true
  fi

  if [[ -d "${TARGET_DIR}/.samourai/core" ]]; then
    doctor_ok "Samourai core installed: .samourai/core"
  else
    doctor_warn "Samourai core not installed"
  fi

  if [[ -f "${TARGET_DIR}/${MANIFEST_ADDED_REL}" ]]; then
    doctor_ok "Install manifest found: ${MANIFEST_ADDED_REL}"
  else
    doctor_warn "Install manifest not found"
  fi

  if [[ -f "${TARGET_DIR}/.opencode/opencode.jsonc" ]]; then
    doctor_ok "OpenCode adapter installed"
  else
    doctor_warn "OpenCode adapter not installed"
  fi

  if command -v opencode >/dev/null 2>&1; then
    doctor_ok "OpenCode CLI available: $(command -v opencode)"
  else
    doctor_warn "OpenCode CLI not found in PATH"
  fi

  if [[ -f "${TARGET_DIR}/.github/agents/pm.agent.md" && -f "${TARGET_DIR}/.github/prompts/write-spec.prompt.md" ]]; then
    doctor_ok "VS Code agents and prompts installed"
  else
    doctor_warn "VS Code agents/prompts not fully installed"
  fi

  if [[ -f "${TARGET_DIR}/.vscode/settings.json" ]]; then
    doctor_ok "VS Code settings found"
    if command -v node >/dev/null 2>&1; then
      if node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "${TARGET_DIR}/.vscode/settings.json" >/dev/null 2>&1; then
        doctor_ok "VS Code settings JSON is valid"
      else
        doctor_fail "VS Code settings JSON is invalid"
        ((failures++)) || true
      fi
    else
      doctor_warn "Node not found; skipped VS Code settings JSON validation"
    fi
  else
    doctor_warn "VS Code settings not installed"
  fi

  if [[ -f "${TARGET_DIR}/.samourai/AGENTS.md" ]]; then
    doctor_ok "Project agent instructions found: .samourai/AGENTS.md"
  elif [[ -f "${TARGET_DIR}/AGENTS.md" ]]; then
    doctor_ok "Root AGENTS.md compatibility entrypoint found"
  else
    doctor_warn ".samourai/AGENTS.md not found; run /bootstrap after installation"
  fi

  printf '\n'
  if [[ "${failures}" -gt 0 ]]; then
    doctor_fail "Doctor found ${failures} blocking issue(s)"
    exit "${EXIT_CONFIG}"
  fi

  doctor_ok "Doctor completed with no blocking issues"
}

validate_editors() {
  local editor
  local -a _editors

  if [[ "${CORE_ONLY}" == "true" ]]; then
    return 0
  fi

  [[ -n "${EDITORS}" ]] || die "--editor requires a non-empty value"

  IFS=',' read -r -a _editors <<< "${EDITORS}"
  for editor in "${_editors[@]}"; do
    case "${editor}" in
      all|opencode|vscode) ;;
      "") die "--editor contains an empty entry" ;;
      *) die "Unsupported editor: ${editor}. Supported editors: opencode, vscode" ;;
    esac
  done
}

editor_enabled() {
  local -r wanted="$1"
  local editor
  local -a _editors

  if [[ "${CORE_ONLY}" == "true" ]]; then
    return 1
  fi

  IFS=',' read -r -a _editors <<< "${EDITORS}"
  for editor in "${_editors[@]}"; do
    case "${editor}" in
      all|"${wanted}") return 0 ;;
      opencode) [[ "${wanted}" == "opencode" ]] && return 0 ;;
      vscode) [[ "${wanted}" == "vscode" ]] && return 0 ;;
      "") ;;
      *) return 1 ;;
    esac
  done

  return 1
}

collect_core_files() {
  local -a files=()
  local rel

  while IFS= read -r rel; do
    files+=("${rel}")
  done < <(cd "${SOURCE_DIR}/${CORE_SOURCE_REL}" && find governance -type f | sort)

  while IFS= read -r rel; do
    files+=("${rel}")
  done < <(cd "${SOURCE_DIR}/${CORE_SOURCE_REL}" && find templates -type f | sort)

  if [[ -d "${SOURCE_DIR}/${CORE_SOURCE_REL}/decisions" ]]; then
    while IFS= read -r rel; do
      files+=("${rel}")
    done < <(cd "${SOURCE_DIR}/${CORE_SOURCE_REL}" && find decisions -type f | sort)
  fi

  printf '%s\n' "${files[@]}" | awk 'NF && !seen[$0]++'
}

collect_opencode_files() {
  local -a files=("${OPENCODE_ADAPTER_FILES[@]}")

  printf '%s\n' "${files[@]}" | awk 'NF && !seen[$0]++'
}

collect_blueprint_files() {
  (cd "${SOURCE_DIR}/${BLUEPRINTS_SOURCE_REL}" && find . -type f | sed 's#^\./##' | sort)
}

collect_core_agent_files() {
  (cd "${SOURCE_DIR}/${CORE_SOURCE_REL}/agents" && find . -maxdepth 1 -type f -name '*.md' | sed 's#^\./##' | sort)
}

collect_core_command_files() {
  (cd "${SOURCE_DIR}/${CORE_SOURCE_REL}/commands" && find . -maxdepth 1 -type f -name '*.md' | sed 's#^\./##' | sort)
}

collect_core_skill_files() {
  (cd "${SOURCE_DIR}/${CORE_SOURCE_REL}/skills" && find . -type f | sed 's#^\./##' | sort)
}

collect_vscode_adapter_files() {
  (cd "${SOURCE_DIR}/${VSCODE_SOURCE_REL}" && find .github .vscode -type f | sed 's#^\./##' | sort)
}

source_base_for_scope() {
  local -r scope="$1"

  case "${scope}" in
    core) printf '%s/%s\n' "${SOURCE_DIR}" "${CORE_SOURCE_REL}" ;;
    blueprints) printf '%s/%s\n' "${SOURCE_DIR}" "${BLUEPRINTS_SOURCE_REL}" ;;
    opencode) printf '%s/%s\n' "${SOURCE_DIR}" "${OPENCODE_SOURCE_REL}" ;;
    opencode-agent|vscode-agent) printf '%s/%s/agents\n' "${SOURCE_DIR}" "${CORE_SOURCE_REL}" ;;
    opencode-command|vscode-prompt) printf '%s/%s/commands\n' "${SOURCE_DIR}" "${CORE_SOURCE_REL}" ;;
    opencode-skill|vscode-skill) printf '%s/%s/skills\n' "${SOURCE_DIR}" "${CORE_SOURCE_REL}" ;;
    vscode) printf '%s/%s\n' "${SOURCE_DIR}" "${VSCODE_SOURCE_REL}" ;;
    *) die "Internal error: unknown source scope ${scope}" ;;
  esac
}

target_relative_path() {
  local -r scope="$1"
  local -r rel="$2"

  case "${scope}" in
    core)
      printf '.samourai/core/%s\n' "${rel}"
      ;;
    blueprints)
      printf '.samourai/blueprints/%s\n' "${rel}"
      ;;
    opencode)
      printf '.opencode/%s\n' "${rel}"
      ;;
    opencode-agent)
      printf '.opencode/agent/%s\n' "${rel}"
      ;;
    opencode-command)
      printf '.opencode/command/%s\n' "${rel}"
      ;;
    opencode-skill)
      printf '.opencode/skills/%s\n' "${rel}"
      ;;
    vscode)
      printf '%s\n' "${rel}"
      ;;
    vscode-agent)
      printf '.github/agents/%s.agent.md\n' "${rel%.md}"
      ;;
    vscode-prompt)
      printf '.github/prompts/%s.prompt.md\n' "${rel%.md}"
      ;;
    vscode-skill)
      printf '.github/skills/%s\n' "${rel}"
      ;;
    *)
      die "Internal error: unknown target scope ${scope}"
      ;;
  esac
}

strip_frontmatter() {
  local -r src="$1"

  awk '
    BEGIN { front = 0 }
    NR == 1 && $0 == "---" { front = 1; next }
    front && $0 == "---" { front = 0; next }
    !front { print }
  ' "${src}"
}

strip_source_metadata() {
  awk '
    /^# Copyright \(c\)/ { next }
    /^# MIT License - see LICENSE file for full terms$/ { next }
    /^source: https?:\/\// { next }
    $0 ~ ("cwiak" "alski") { next }
    $0 ~ ("agentic-delivery" "-os") { next }
    { print }
  '
}

extract_description() {
  local -r src="$1"
  awk -F': ' '/^description: /{print $2; exit}' "${src}"
}

extract_prompt_description() {
  local -r src="$1"

  awk '
    BEGIN { front = 0 }
    NR == 1 && $0 == "---" { front = 1; next }
    front && $0 == "---" { front = 0; next }
    !front && /^# / {
      sub(/^# /, "")
      print
      exit 0
    }
  ' "${src}"
}

vscode_agent_model() {
  local -r name="$1"

  case "${name}" in
    coder|fixer|designer) printf "['Claude Sonnet 4.5', 'GPT-5.2', 'GPT-5']\n" ;;
    runner|committer) printf "['GPT-5 mini', 'GPT-5.2']\n" ;;
    external-researcher) printf "['GPT-5.2', 'Claude Sonnet 4.5']\n" ;;
    *) printf "['GPT-5.2', 'Claude Sonnet 4.5', 'GPT-5']\n" ;;
  esac
}

vscode_agent_tools() {
  local -r name="$1"

  case "${name}" in
    runner|committer)
      printf "['agent', 'read/terminalLastCommand', 'github/*']\n"
      ;;
    spec-writer|plan-writer|test-plan-writer|doc-syncer|editor|image-reviewer)
      printf "['agent', 'search/codebase', 'search/usages', 'web/fetch', 'github/*', 'context7/*', 'deepwiki/*']\n"
      ;;
    reviewer|code-reviewer|external-researcher)
      printf "['agent', 'search/codebase', 'search/usages', 'web/fetch', 'github/*', 'context7/*', 'deepwiki/*']\n"
      ;;
    *)
      printf "['agent', 'edit', 'search/codebase', 'search/usages', 'web/fetch', 'read/terminalLastCommand', 'github/*', 'context7/*', 'deepwiki/*']\n"
      ;;
  esac
}

vscode_agent_subagents() {
  local -r name="$1"

  case "${name}" in
    pm)
      printf "['architect', 'spec-writer', 'test-plan-writer', 'plan-writer', 'coder', 'reviewer', 'runner', 'fixer', 'doc-syncer', 'committer', 'pr-manager', 'external-researcher']\n"
      ;;
    bootstrapper)
      printf "['architect', 'external-researcher', 'toolsmith']\n"
      ;;
    coder)
      printf "['architect', 'designer', 'editor', 'runner', 'fixer', 'reviewer', 'tdd-orchestrator', 'code-reviewer']\n"
      ;;
    reviewer|code-reviewer)
      printf "['architect', 'runner', 'fixer', 'external-researcher']\n"
      ;;
    fixer)
      printf "['runner', 'code-reviewer']\n"
      ;;
    tdd-orchestrator)
      printf "['coder', 'runner', 'fixer', 'reviewer']\n"
      ;;
    toolsmith)
      printf "['pm', 'architect', 'bootstrapper', 'spec-writer', 'test-plan-writer', 'plan-writer', 'coder', 'designer', 'editor', 'reviewer', 'fixer', 'runner', 'doc-syncer', 'committer', 'pr-manager', 'external-researcher', 'image-generator', 'image-reviewer', 'code-reviewer', 'tdd-orchestrator']\n"
      ;;
    *)
      printf '[]\n'
      ;;
  esac
}

vscode_agent_user_invocable() {
  local -r name="$1"

  case "${name}" in
    spec-writer|test-plan-writer|plan-writer|runner|fixer|doc-syncer|committer|pr-manager|review-feedback-applier)
      printf 'false\n'
      ;;
    *)
      printf 'true\n'
      ;;
  esac
}

render_vscode_agent_content() {
  local -r src="$1"
  local -r rel="$2"
  local -r name="${rel%.md}"
  local description
  local subagents
  description="$(extract_description "${src}")"
  [[ -n "${description}" ]] || description="Samourai ${name} agent"
  subagents="$(vscode_agent_subagents "${name}")"

  {
    printf -- '---\n'
    printf 'name: %s\n' "${name}"
    printf 'description: %s\n' "${description}"
    printf 'model: %s\n' "$(vscode_agent_model "${name}")"
    printf 'tools: %s\n' "$(vscode_agent_tools "${name}")"
    printf 'user-invocable: %s\n' "$(vscode_agent_user_invocable "${name}")"
    printf 'agents: %s\n' "${subagents}"
    printf 'handoffs:\n'
    printf '  - label: Review result\n'
    printf '    agent: reviewer\n'
    printf '    prompt: Review the result against Samourai artifacts, repository rules, and acceptance criteria.\n'
    printf '    send: false\n'
    printf -- '---\n\n'
    printf 'You are the Samourai `%s` agent running inside VS Code Copilot.\n\n' "${name}"
    if [[ "${subagents}" != "[]" ]]; then
      printf 'When the task benefits from isolated context or role-specific execution, use VS Code subagents through the `agent` tool. Prefer the custom agents listed in this file frontmatter and pass each subagent only the context needed for its task. Merge the returned result into the current workflow before continuing.\n\n'
    fi
    printf 'Use `.samourai/core/**` for reusable Samourai governance, templates, and process references. Do not copy core kit files into project-owned doc folders unless the workflow explicitly asks for generated project artifacts.\n\n'
    strip_frontmatter "${src}" | strip_source_metadata
  }
}

render_vscode_prompt_content() {
  local -r src="$1"
  local -r rel="$2"
  local -r name="${rel%.md}"
  local description
  description="$(extract_prompt_description "${src}")"
  [[ -n "${description}" ]] || description="Samourai command: ${name}"

  {
    printf -- '---\n'
    printf 'description: %s\n' "${description}"
    printf 'agent: agent\n'
    printf -- '---\n\n'
    printf 'Run the Samourai command `%s` in VS Code Copilot.\n\n' "/${name}"
    printf 'Use `.samourai/core/**` as the canonical Samourai core reference and keep generated project artifacts under `.samourai/docai/**` or other workflow-specific project-owned paths.\n\n'
    strip_frontmatter "${src}" | strip_source_metadata
  }
}

write_rendered_file() {
  local -r dest="$1"
  local -r content="$2"

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would write: ${dest}"
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"
  printf '%s' "${content}" > "${dest}"
}

copy_relative_file() {
  local -r scope="$1"
  local -r rel="$2"

  if ! safe_relative_path "${rel}"; then
    log_warn "Skipping unsafe relative path: ${rel}"
    ((_skipped++)) || true
    return 0
  fi

  local src_base
  src_base="$(source_base_for_scope "${scope}")"

  local -r src="${src_base}/${rel}"
  local dest_rel
  dest_rel="$(target_relative_path "${scope}" "${rel}")"

  if ! safe_relative_path "${dest_rel}"; then
    log_warn "Skipping unsafe target path: ${dest_rel}"
    ((_skipped++)) || true
    return 0
  fi

  local -r dest="${TARGET_DIR}/${dest_rel}"

  if [[ ! -f "${src}" ]]; then
    log_warn "Source file missing, skipped: ${src}"
    ((_skipped++)) || true
    return 0
  fi

  if [[ -e "${dest}" ]]; then
    if [[ "${FORCE}" == "true" ]]; then
      if [[ "${scope}" == "vscode-agent" ]]; then
        write_rendered_file "${dest}" "$(render_vscode_agent_content "${src}" "${rel}")"
      elif [[ "${scope}" == "vscode-prompt" ]]; then
        write_rendered_file "${dest}" "$(render_vscode_prompt_content "${src}" "${rel}")"
      else
        run_cmd mkdir -p "$(dirname "${dest}")"
        run_cmd cp "${src}" "${dest}"
      fi
      log_info "update ${dest_rel}"
      ((_updated++)) || true
      UPDATED_THIS_RUN+=("${dest_rel}")
    else
      log_info "skip   ${dest_rel} (already exists, use --force to overwrite)"
      ((_skipped++)) || true
    fi
  else
    if [[ "${scope}" == "vscode-agent" ]]; then
      write_rendered_file "${dest}" "$(render_vscode_agent_content "${src}" "${rel}")"
    elif [[ "${scope}" == "vscode-prompt" ]]; then
      write_rendered_file "${dest}" "$(render_vscode_prompt_content "${src}" "${rel}")"
    else
      run_cmd mkdir -p "$(dirname "${dest}")"
      run_cmd cp "${src}" "${dest}"
    fi
    log_info "add    ${dest_rel}"
    ((_added++)) || true
    ADDED_THIS_RUN+=("${dest_rel}")
  fi
}

ensure_gitignore_entry() {
  local -r gitignore="${TARGET_DIR}/.gitignore"
  local -r entry="$1"

  if [[ -f "${gitignore}" ]] && grep -qF "${entry}" "${gitignore}" 2>/dev/null; then
    log_debug "skip   .gitignore entry '${entry}' (already present)"
    return 0
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would add '${entry}' to ${gitignore}"
    return 0
  fi

  if [[ ! -f "${gitignore}" ]]; then
    printf '%s\n' "${entry}" > "${gitignore}"
  else
    printf '\n%s\n' "${entry}" >> "${gitignore}"
  fi
  log_info "add    .gitignore entry '${entry}'"
}

ensure_samourai_gitignore_entries() {
  ensure_gitignore_entry ".samourai/core/"
  ensure_gitignore_entry ".samourai/install/"
  ensure_gitignore_entry ".samourai/tmpai/"
  ensure_gitignore_entry ".samourai/ai/local/"
  ensure_gitignore_entry "!.samourai/"
  ensure_gitignore_entry "!.samourai/AGENTS.md"
  ensure_gitignore_entry "!.samourai/docai/"
  ensure_gitignore_entry "!.samourai/docai/**"
  ensure_gitignore_entry "!.samourai/ai/"
  ensure_gitignore_entry "!.samourai/ai/agent/"
  ensure_gitignore_entry "!.samourai/ai/agent/**"
  ensure_gitignore_entry "!.samourai/ai/rules/"
  ensure_gitignore_entry "!.samourai/ai/rules/**"
  ensure_gitignore_entry "!.samourai/ai/context/"
  ensure_gitignore_entry "!.samourai/ai/context/**"
}

ensure_git_info_exclude_entry() {
  local -r entry="$1"
  local -r exclude="${CLIENT_DIR}/.git/info/exclude"

  if [[ -f "${exclude}" ]] && grep -qF "${entry}" "${exclude}" 2>/dev/null; then
    log_debug "skip   .git/info/exclude entry '${entry}' (already present)"
    return 0
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would add '${entry}' to ${exclude}"
    return 0
  fi

  mkdir -p "$(dirname "${exclude}")"
  if [[ ! -f "${exclude}" ]]; then
    printf '%s\n' "${entry}" > "${exclude}"
  else
    printf '\n%s\n' "${entry}" >> "${exclude}"
  fi
  log_info "add    .git/info/exclude entry '${entry}'"
}

ensure_symlink_stack_excludes() {
  ensure_git_info_exclude_entry ".opencode"
  ensure_git_info_exclude_entry ".samourai"
  ensure_git_info_exclude_entry "AGENTS.md"
}

prepare_symlink_stack_target() {
  [[ "${SYMLINK_STACK}" == "true" ]] || return 0

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would create stack directory: ${STACK_DIR}"
  else
    mkdir -p "${STACK_DIR}"
  fi

  local entry client_path stack_path
  for entry in "${SYMLINK_STACK_ENTRIES[@]}"; do
    client_path="${CLIENT_DIR}/${entry}"
    stack_path="${STACK_DIR}/${entry}"

    [[ -e "${client_path}" || -L "${client_path}" ]] || continue

    if [[ -L "${client_path}" ]]; then
      log_debug "skip   ${entry} (already a symlink)"
      continue
    fi

    if [[ -e "${stack_path}" || -L "${stack_path}" ]]; then
      log_warn "keep   ${entry} in target project (stack path already exists: ${stack_path})"
      log_warn "       Move it manually or use --force only after backing up local changes."
      continue
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
      log_info "[DRY-RUN] Would move ${client_path} to ${stack_path}"
    else
      mkdir -p "$(dirname "${stack_path}")"
      mv "${client_path}" "${stack_path}"
    fi
    log_info "move   ${entry} -> ${STACK_DIR}/${entry}"
  done
}

link_stack_entry() {
  local -r entry="$1"
  local -r client_path="${CLIENT_DIR}/${entry}"
  local -r stack_path="${STACK_DIR}/${entry}"

  [[ -e "${stack_path}" || -L "${stack_path}" ]] || return 0

  if [[ -L "${client_path}" ]]; then
    local current_target
    current_target="$(readlink "${client_path}")"
    if [[ "${current_target}" == "${stack_path}" ]]; then
      log_debug "skip   ${entry} symlink (already correct)"
      return 0
    fi
    if [[ "${FORCE}" != "true" ]]; then
      log_warn "skip   ${entry} symlink (already points to ${current_target}; use --force to replace)"
      return 0
    fi
    run_cmd rm -f "${client_path}"
  elif [[ -e "${client_path}" ]]; then
    log_warn "skip   ${entry} symlink (target project path exists and is not a symlink)"
    return 0
  fi

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would link ${client_path} -> ${stack_path}"
    return 0
  fi

  ln -s "${stack_path}" "${client_path}"
  log_info "link   ${entry} -> ${stack_path}"
}

link_symlink_stack_entries() {
  [[ "${SYMLINK_STACK}" == "true" ]] || return 0

  local entry
  for entry in "${SYMLINK_STACK_ENTRIES[@]}"; do
    link_stack_entry "${entry}"
  done

  ensure_symlink_stack_excludes
}

persist_manifest_entries() {
  local -r rel_path="$1"
  shift
  local -a entries=("$@")

  if [[ "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  [[ "${#entries[@]}" -gt 0 ]] || return 0

  local -r manifest_path="${TARGET_DIR}/${rel_path}"
  local -r manifest_dir="$(dirname "${manifest_path}")"
  local tmp
  tmp="$(mktemp)"

  mkdir -p "${manifest_dir}"

  {
    [[ -f "${manifest_path}" ]] && cat "${manifest_path}"
    printf '%s\n' "${entries[@]}"
  } | awk 'NF && !seen[$0]++' > "${tmp}"

  mv "${tmp}" "${manifest_path}"
}

file_sha256() {
  sha256sum "$1" | awk '{print $1}'
}

persist_installed_hashes() {
  local -a entries=("$@")

  if [[ "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  [[ "${#entries[@]}" -gt 0 ]] || return 0

  local -r manifest_path="${TARGET_DIR}/${MANIFEST_HASH_REL}"
  local -r manifest_dir="$(dirname "${manifest_path}")"
  local tmp hash rel_path abs_path
  tmp="$(mktemp)"

  mkdir -p "${manifest_dir}"

  [[ -f "${manifest_path}" ]] && cat "${manifest_path}" > "${tmp}"

  for rel_path in "${entries[@]}"; do
    abs_path="${TARGET_DIR}/${rel_path}"
    [[ -f "${abs_path}" ]] || continue
    hash="$(file_sha256 "${abs_path}")"
    printf '%s\t%s\n' "${hash}" "${rel_path}" >> "${tmp}"
  done

  awk -F '\t' 'NF >= 2 { rows[$2] = $0; if (!seen[$2]++) order[++n] = $2 } END { for (i = 1; i <= n; i++) print rows[order[i]] }' "${tmp}" > "${tmp}.dedup"
  mv "${tmp}.dedup" "${manifest_path}"
  rm -f "${tmp}"
}

write_last_summary() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  local -r summary_path="${TARGET_DIR}/${LAST_SUMMARY_REL}"
  mkdir -p "$(dirname "${summary_path}")"

  cat > "${summary_path}" <<SUMMARY_EOF
installed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
source_dir: ${SOURCE_DIR}
target_dir: ${TARGET_DIR}
added: ${_added}
updated: ${_updated}
skipped: ${_skipped}
SUMMARY_EOF
}

print_next_steps() {
  log_info "Done — ${_added} added, ${_updated} updated, ${_skipped} skipped"
  log_info "Install manifest: ${TARGET_DIR}/${MANIFEST_ADDED_REL}"
  log_info "Overwrite manifest: ${TARGET_DIR}/${MANIFEST_UPDATED_REL}"
  if [[ "${SYMLINK_STACK}" == "true" ]]; then
    log_info "Samourai stack: ${STACK_DIR}"
  fi

  printf '\n'
  printf 'Next steps\n'
  printf '%s\n' '----------'
  printf '1. Open the target project:\n'
  if [[ "${SYMLINK_STACK}" == "true" ]]; then
    printf '   cd %s\n' "${CLIENT_DIR}"
  else
    printf '   cd %s\n' "${TARGET_DIR}"
  fi

  if editor_enabled "opencode"; then
    printf '2. Start OpenCode:\n'
    printf '   opencode\n'
    printf '3. Bootstrap the project:\n'
    printf '   /bootstrap\n'
    printf '4. Try a first safe workflow:\n'
    printf '   @pm propose a small documentation-only change to validate Samourai setup\n'
  elif editor_enabled "vscode"; then
    printf '2. Open the project in VS Code.\n'
    printf '3. Open Copilot Chat and run the generated bootstrap prompt.\n'
    printf '4. If VS Code subagents are unavailable, use the generated prompt files manually.\n'
  else
    printf '2. Core resources are installed under .samourai/core/.\n'
    printf '3. Install an editor adapter later when you are ready.\n'
  fi

  printf '\n'
  printf 'User guide: %s/docs/guide-utilisateur-fr.md\n' "${SOURCE_DIR}"
}

install_opencode() {
  if [[ "${SKIP_OPENCODE}" == "true" ]]; then
    log_info "Skipping OpenCode installation (--skip-opencode)"
    return 0
  fi

  if command -v opencode >/dev/null 2>&1; then
    log_info "OpenCode already available: $(command -v opencode)"
    return 0
  fi

  require_cmd curl
  require_cmd bash

  log_info "Installing OpenCode (official installer)..."
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would execute: curl -fsSL https://opencode.ai/install | bash"
  else
    curl -fsSL https://opencode.ai/install | bash
  fi

  if command -v opencode >/dev/null 2>&1; then
    log_info "OpenCode installed successfully: $(command -v opencode)"
  else
    log_warn "OpenCode installer completed, but 'opencode' is not yet in PATH for this shell."
    log_warn "Open a new shell, then run: opencode --help"
  fi
}

usage() {
  cat <<USAGE_EOF
Usage: ${APP_NAME} [options]

Install Samourai Devkit into a local project (mode local only).
Manifest-based copy, clear logs, safe defaults.

Options:
  -h, --help              Show this help
  -V, --version           Show version
      --source <dir>      Source kit directory (default: repo containing this script)
      --target <dir>      Target project directory (default: current directory)
  -i, --interactive       Guided setup for humans
      --doctor            Diagnose a target project without installing files
  -f, --force             Overwrite existing files in target
  -n, --dry-run           Preview without writing
  -v, --verbose           Debug output
      --skip-opencode     Do not run OpenCode installer
      --editor <list>      Comma-separated editor adapters to install (default: opencode)
                           Supported: opencode, vscode, all
      --core-only          Install only .samourai/core resources, no editor adapter
      --list-editors       List supported editor adapters and exit
      --allow-non-root    Allow install into a git subdirectory
      --symlink-stack     Install Samourai files in a sibling <project>-samurai
                           directory and symlink .opencode/.samourai into target
      --stack-dir <dir>    Custom stack directory for --symlink-stack

Examples:
  ./scripts/install-samourai.sh --target /path/to/project
  ./scripts/install-samourai.sh --interactive
  ./scripts/install-samourai.sh --target /path/to/project --doctor
  ./scripts/install-samourai.sh --target /path/to/project --editor opencode
  ./scripts/install-samourai.sh --target /path/to/project --editor vscode
  ./scripts/install-samourai.sh --target /path/to/project --editor opencode,vscode
  ./scripts/install-samourai.sh --target /path/to/project --core-only
  ./scripts/install-samourai.sh --target /path/to/project --force
  ./scripts/install-samourai.sh --target /path/to/project --dry-run
  ./scripts/install-samourai.sh --target /path/to/project --symlink-stack

Environment:
  DRY_RUN, VERBOSE, FORCE, SKIP_OPENCODE, ALLOW_NON_ROOT, EDITORS, CORE_ONLY, INTERACTIVE, DOCTOR, SYMLINK_STACK, STACK_DIR
USAGE_EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -V|--version) printf '%s %s\n' "${APP_NAME}" "${APP_VERSION}"; exit 0 ;;
      --source) shift; SOURCE_DIR="${1:?--source requires a path}" ;;
      --target) shift; TARGET_DIR="${1:?--target requires a path}" ;;
      -i|--interactive) INTERACTIVE=true ;;
      --doctor) DOCTOR=true ;;
      -f|--force) FORCE=true ;;
      -n|--dry-run) DRY_RUN=true ;;
      -v|--verbose) VERBOSE=true ;;
      --skip-opencode) SKIP_OPENCODE=true ;;
      --editor) shift; EDITORS="${1:?--editor requires a comma-separated list}" ;;
      --core-only) CORE_ONLY=true ;;
      --symlink-stack) SYMLINK_STACK=true ;;
      --stack-dir) shift; STACK_DIR="${1:?--stack-dir requires a path}"; SYMLINK_STACK=true ;;
      --list-editors) list_editors; exit 0 ;;
      --allow-non-root) ALLOW_NON_ROOT=true ;;
      --) shift; break ;;
      -*) die "Unknown option: $1" ;;
      *) die "Unexpected argument: $1" ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  if [[ "${INTERACTIVE}" == "true" ]]; then
    run_interactive_setup
  fi
  if [[ "${DOCTOR}" == "true" ]]; then
    run_doctor
    exit 0
  fi
  validate_editors
  resolve_paths
  resolve_symlink_stack_dir
  ensure_project_root "${TARGET_DIR}"

  require_cmd cp
  require_cmd mkdir
  require_cmd find
  require_cmd awk
  require_cmd git
  if [[ "${SYMLINK_STACK}" == "true" ]]; then
    require_cmd ln
    require_cmd readlink
    require_cmd mv
    prepare_symlink_stack_target
    TARGET_DIR="${STACK_DIR}"
  fi

  log_info "=== Samourai Local Install ==="
  log_info "Source: ${SOURCE_DIR}"
  if [[ "${SYMLINK_STACK}" == "true" ]]; then
    log_info "Target project: ${CLIENT_DIR}"
    log_info "Stack target: ${TARGET_DIR}"
    log_info "Mode: symlink stack"
  else
    log_info "Target: ${TARGET_DIR}"
  fi
  log_info "Core: .samourai/core"
  if [[ "${CORE_ONLY}" == "true" ]]; then
    log_info "Editors: none (--core-only)"
  else
    log_info "Editors: ${EDITORS}"
  fi
  [[ "${FORCE}" == "true" ]] && log_info "Mode: force overwrite"

  if editor_enabled "opencode"; then
    install_opencode
  fi

  while IFS= read -r rel_path; do
    copy_relative_file core "${rel_path}"
  done < <(collect_core_files)

  while IFS= read -r rel_path; do
    copy_relative_file blueprints "${rel_path}"
  done < <(collect_blueprint_files)

  if editor_enabled "opencode"; then
    while IFS= read -r rel_path; do
      copy_relative_file opencode "${rel_path}"
    done < <(collect_opencode_files)

    while IFS= read -r rel_path; do
      copy_relative_file opencode-agent "${rel_path}"
    done < <(collect_core_agent_files)

    while IFS= read -r rel_path; do
      copy_relative_file opencode-command "${rel_path}"
    done < <(collect_core_command_files)

    while IFS= read -r rel_path; do
      copy_relative_file opencode-skill "${rel_path}"
    done < <(collect_core_skill_files)
  fi

  if editor_enabled "vscode"; then
    while IFS= read -r rel_path; do
      copy_relative_file vscode "${rel_path}"
    done < <(collect_vscode_adapter_files)

    while IFS= read -r rel_path; do
      copy_relative_file vscode-agent "${rel_path}"
    done < <(collect_core_agent_files)

    while IFS= read -r rel_path; do
      copy_relative_file vscode-prompt "${rel_path}"
    done < <(collect_core_command_files)

    while IFS= read -r rel_path; do
      copy_relative_file vscode-skill "${rel_path}"
    done < <(collect_core_skill_files)
  fi

  if [[ "${SYMLINK_STACK}" == "true" ]]; then
    link_symlink_stack_entries
  else
    ensure_samourai_gitignore_entries
  fi

  persist_manifest_entries "${MANIFEST_ADDED_REL}" ${ADDED_THIS_RUN[@]+"${ADDED_THIS_RUN[@]}"}
  persist_manifest_entries "${MANIFEST_UPDATED_REL}" ${UPDATED_THIS_RUN[@]+"${UPDATED_THIS_RUN[@]}"}
  persist_installed_hashes ${ADDED_THIS_RUN[@]+"${ADDED_THIS_RUN[@]}"}
  write_last_summary

  printf '\n'
  print_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
