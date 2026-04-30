#!/usr/bin/env bash
# uninstall-samourai.sh — Remove files installed by install-samourai.sh

set -Eeuo pipefail
set -o errtrace
shopt -s inherit_errexit 2>/dev/null || true
IFS=$'\n\t'

readonly APP_NAME="samourai-uninstall"
readonly APP_VERSION="1.0.0"
readonly LOG_TAG="(${APP_NAME})"

readonly EXIT_SUCCESS=0
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3
readonly EXIT_RUNTIME=4

DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"
ALLOW_NON_ROOT="${ALLOW_NON_ROOT:-false}"

TARGET_DIR="$(pwd -P)"

readonly STATE_DIR_REL=".samourai/install"
readonly MANIFEST_ADDED_REL="${STATE_DIR_REL}/installed-files.txt"
readonly MANIFEST_UPDATED_REL="${STATE_DIR_REL}/overwritten-files.txt"
readonly MANIFEST_HASH_REL="${STATE_DIR_REL}/installed-files.sha256"
readonly LAST_SUMMARY_REL="${STATE_DIR_REL}/last-install-summary.txt"

_removed=0
_skipped=0
_manifest_found=false

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
    return 0
  fi

  log_err "Target is not a git root."
  log_err "Target:  ${dir}"
  log_err "Git root: ${git_root}"
  die "Run from project root or use --allow-non-root"
}

confirm_action() {
  local -r message="$1"

  if [[ "${FORCE}" == "true" || "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  printf '%s [o/N] ' "${message}"
  local answer
  if ! read -r answer; then
    answer=""
  fi
  case "${answer}" in
    [oO]|[oO][uU][iI]|[yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

confirm_delete_dir() {
  local -r rel_dir="$1"
  local -r loss="$2"

  if [[ "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  printf '\nDossier restant: %s\n' "${rel_dir}" >&2
  printf 'Si tu le supprimes, tu perds: %s\n' "${loss}" >&2
  printf 'Supprimer ce dossier ? Tape "supprime" pour confirmer [laisser vide = garder]: ' >&2

  local answer
  if ! read -r answer; then
    answer=""
  fi
  case "${answer}" in
    supprime|SUPPRIME|Supprime) return 0 ;;
    *) return 1 ;;
  esac
}

remove_file_if_exists() {
  local -r path="$1"
  local -r label="$2"

  if [[ -f "${path}" || -L "${path}" ]]; then
    run_cmd rm -f "${path}"
    log_info "remove ${label}"
    ((_removed++)) || true
  else
    log_debug "skip   ${label} (not found)"
    ((_skipped++)) || true
  fi
}

file_sha256() {
  sha256sum "$1" | awk '{print $1}'
}

installed_file_expected_hash() {
  local -r rel_path="$1"
  local -r hash_manifest="${TARGET_DIR}/${MANIFEST_HASH_REL}"

  [[ -f "${hash_manifest}" ]] || return 1
  awk -F '\t' -v p="${rel_path}" '$2 == p { value = $1 } END { if (value != "") print value }' "${hash_manifest}"
}

should_remove_installed_file() {
  local -r abs_path="$1"
  local -r rel_path="$2"
  local expected actual

  [[ -f "${abs_path}" ]] || return 0

  expected="$(installed_file_expected_hash "${rel_path}" || true)"
  [[ -n "${expected}" ]] || return 0

  actual="$(file_sha256 "${abs_path}")"
  if [[ "${actual}" != "${expected}" ]]; then
    log_warn "keep   ${rel_path} (modifié depuis l'installation; suppression ignorée)"
    ((_skipped++)) || true
    return 1
  fi

  return 0
}

prune_empty_dir() {
  local -r dir="$1"
  local -r label="$2"

  if [[ -d "${dir}" && -z "$(ls -A "${dir}" 2>/dev/null)" ]]; then
    run_cmd rmdir "${dir}"
    log_info "remove ${label}/ (empty)"
  fi
}

dir_loss_description() {
  local name="$1"
  name="${name##*/}"

  case "${name}" in
    .samourai|.samurai) printf 'le core Samourai installé, les manifests et l’état local d’installation; les artefacts projet sous .samourai/docai ne sont pas supprimés automatiquement' ;;
    .opencode) printf 'les agents, commandes, skills et la configuration OpenCode générés par Samourai' ;;
    .github) printf 'les agents, prompts, skills GitHub Copilot et instructions Copilot générés par Samourai; attention si ton projet utilise déjà .github pour workflows ou templates' ;;
    .vscode) printf 'les réglages VS Code/MCP/extensions générés par Samourai; attention si ton projet utilise déjà .vscode pour ses propres réglages' ;;
    .ai) printf 'les anciennes instructions IA/Samourai locales; attention si ton projet utilise déjà .ai pour ses propres fichiers' ;;
    .docai|docai) printf 'les specs, plans, décisions, changements et documents générés par Samourai/IA' ;;
    .tmpai|tmpai) printf 'les logs, brouillons de PR, reviews, rapports et fichiers de debug temporaires générés par les agents' ;;
    *) printf 'les fichiers restants dans ce dossier' ;;
  esac
}

delete_dir_if_confirmed() {
  local -r rel_dir="$1"
  local -r dir="${TARGET_DIR}/${rel_dir}"
  local loss

  [[ -d "${dir}" ]] || return 0

  if [[ "${FORCE}" == "true" && "${DRY_RUN}" != "true" ]]; then
    if dir_has_overwritten_entry "${rel_dir}"; then
      log_warn "keep   ${rel_dir}/ (contient un fichier qui existait avant l'installation)"
      return 0
    fi
    run_cmd rm -rf "${dir}"
    log_info "remove ${rel_dir}/ (force)"
    return 0
  fi

  loss="$(dir_loss_description "${rel_dir}")"

  if confirm_delete_dir "${rel_dir}" "${loss}"; then
    run_cmd rm -rf "${dir}"
    log_info "remove ${rel_dir}/ (confirmed)"
  else
    log_info "keep   ${rel_dir}/"
  fi
}

dir_has_overwritten_entry() {
  local -r rel_dir="$1"
  local -r overwritten_manifest="${TARGET_DIR}/${MANIFEST_UPDATED_REL}"

  [[ -f "${overwritten_manifest}" ]] || return 1
  awk -v prefix="${rel_dir}/" '$0 == prefix || index($0, prefix) == 1 { found = 1 } END { exit found ? 0 : 1 }' "${overwritten_manifest}"
}

is_nested_git_repo_dir() {
  local -r abs_dir="$1"
  local current="${abs_dir}"

  while [[ "${current}" != "${TARGET_DIR}" && "${current}" != "/" ]]; do
    if [[ -d "${current}/.git" ]]; then
      return 0
    fi
    current="$(dirname -- "${current}")"
  done

  return 1
}

has_samourai_marker() {
  local -r abs_dir="$1"
  local -r name="${abs_dir##*/}"

  case "${name}" in
    .samourai|.samurai|.opencode|.docai|.tmpai|docai|tmpai)
      return 0
      ;;
  esac

  return 1
}

remove_installed_files() {
  local -r manifest_path="${TARGET_DIR}/${MANIFEST_ADDED_REL}"

  if [[ ! -f "${manifest_path}" ]]; then
    log_warn "Install manifest not found: ${manifest_path}"
    log_warn "Nothing to uninstall automatically."
    return 0
  fi

  local rel_path abs_path
  while IFS= read -r rel_path; do
    [[ -n "${rel_path}" ]] || continue

    if ! safe_relative_path "${rel_path}"; then
      log_warn "Skipping unsafe manifest entry: ${rel_path}"
      continue
    fi

    abs_path="${TARGET_DIR}/${rel_path}"
    should_remove_installed_file "${abs_path}" "${rel_path}" || continue
    remove_file_if_exists "${abs_path}" "${rel_path}"
  done < "${manifest_path}"
}

cleanup_state() {
  remove_file_if_exists "${TARGET_DIR}/${MANIFEST_ADDED_REL}" "${MANIFEST_ADDED_REL}"
  remove_file_if_exists "${TARGET_DIR}/${MANIFEST_HASH_REL}" "${MANIFEST_HASH_REL}"
  remove_file_if_exists "${TARGET_DIR}/${LAST_SUMMARY_REL}" "${LAST_SUMMARY_REL}"

  prune_empty_dir "${TARGET_DIR}/.samourai/install" ".samourai/install"
  prune_empty_dir "${TARGET_DIR}/.samourai" ".samourai"
  prune_empty_dir "${TARGET_DIR}/.samurai/install" ".samurai/install"
  prune_empty_dir "${TARGET_DIR}/.samurai" ".samurai"
}

cleanup_final_state() {
  remove_file_if_exists "${TARGET_DIR}/${MANIFEST_UPDATED_REL}" "${MANIFEST_UPDATED_REL}"

  prune_empty_dir "${TARGET_DIR}/.samourai/install" ".samourai/install"
  prune_empty_dir "${TARGET_DIR}/.samourai" ".samourai"
  prune_empty_dir "${TARGET_DIR}/.samurai/install" ".samurai/install"
  prune_empty_dir "${TARGET_DIR}/.samurai" ".samurai"
}

cleanup_empty_scaffold_dirs() {
  # Remove only empty directories, bottom-up. Never force-delete non-empty directories.
  local d

  if [[ -d "${TARGET_DIR}/.opencode/skills" ]]; then
    while IFS= read -r d; do
      prune_empty_dir "${d}" "${d#${TARGET_DIR}/}"
    done < <(find "${TARGET_DIR}/.opencode/skills" -type d | sort -r)
  fi

  prune_empty_dir "${TARGET_DIR}/.opencode/agent" ".opencode/agent"
  prune_empty_dir "${TARGET_DIR}/.opencode/command" ".opencode/command"
  prune_empty_dir "${TARGET_DIR}/.opencode/skills" ".opencode/skills"
  prune_empty_dir "${TARGET_DIR}/.opencode" ".opencode"

  prune_empty_dir "${TARGET_DIR}/docs" "docs"

  prune_empty_dir "${TARGET_DIR}/.samourai/core/decisions" ".samourai/core/decisions"
  prune_empty_dir "${TARGET_DIR}/.samourai/core/governance/conventions" ".samourai/core/governance/conventions"
  prune_empty_dir "${TARGET_DIR}/.samourai/core/governance/lifecycle" ".samourai/core/governance/lifecycle"
  prune_empty_dir "${TARGET_DIR}/.samourai/core/governance/policies" ".samourai/core/governance/policies"
  prune_empty_dir "${TARGET_DIR}/.samourai/core/governance" ".samourai/core/governance"
  prune_empty_dir "${TARGET_DIR}/.samourai/core/templates" ".samourai/core/templates"
  prune_empty_dir "${TARGET_DIR}/.samourai/core" ".samourai/core"
  if [[ -d "${TARGET_DIR}/.samourai/blueprints" ]]; then
    while IFS= read -r d; do
      prune_empty_dir "${d}" "${d#${TARGET_DIR}/}"
    done < <(find "${TARGET_DIR}/.samourai/blueprints" -type d | sort -r)
  fi
  prune_empty_dir "${TARGET_DIR}/.samourai/blueprints" ".samourai/blueprints"
  prune_empty_dir "${TARGET_DIR}/.samourai/tmpai" ".samourai/tmpai"

  if [[ -d "${TARGET_DIR}/plugins" ]]; then
    while IFS= read -r d; do
      prune_empty_dir "${d}" "${d#${TARGET_DIR}/}"
    done < <(find "${TARGET_DIR}/plugins" -type d | sort -r)
  fi

  prune_empty_dir "${TARGET_DIR}/plugins" "plugins"
  prune_empty_dir "${TARGET_DIR}/.samourai" ".samourai"
  prune_empty_dir "${TARGET_DIR}/.samurai" ".samurai"
}

cleanup_legacy_ai_files() {
  local rel_file abs_file
  local legacy_files=(
    ".ai/agent/pm-instructions.md"
    ".ai/agent/pr-instructions.md"
    ".ai/agent/project-profile.md"
    ".ai/rules/bash.md"
    ".ai/rules/testing-strategy.md"
    ".ai/local/bootstrapper-context.yaml"
    ".ai/local/pm-context.yaml"
  )
  local local_files=(
    ".samourai/ai/local/bootstrapper-context.yaml"
    ".samourai/ai/local/pm-context.yaml"
  )

  if [[ "${FORCE}" != "true" && "${DRY_RUN}" != "true" && -d "${TARGET_DIR}/.ai" ]]; then
    local found=false
    for rel_file in "${legacy_files[@]}"; do
      [[ -e "${TARGET_DIR}/${rel_file}" ]] && found=true
    done

    if [[ "${found}" == "true" ]]; then
      printf '\nDossier partagé restant: .ai\n' >&2
      printf 'Le script peut supprimer uniquement les anciens fichiers Samourai connus dans .ai, pas le dossier complet.\n' >&2
      printf 'Supprimer ces fichiers ? Tape "supprime" pour confirmer [laisser vide = garder]: ' >&2

      local answer
      if ! read -r answer; then
        answer=""
      fi
      [[ "${answer}" == "supprime" || "${answer}" == "SUPPRIME" || "${answer}" == "Supprime" ]] || {
        log_info "keep   .ai/ (fichiers legacy gardés)"
        legacy_files=()
      }
    fi
  fi

  for rel_file in "${legacy_files[@]}" "${local_files[@]}"; do
    abs_file="${TARGET_DIR}/${rel_file}"
    remove_file_if_exists "${abs_file}" "${rel_file}"
  done

  prune_empty_dir "${TARGET_DIR}/.samourai/ai/local" ".samourai/ai/local"
  prune_empty_dir "${TARGET_DIR}/.samourai/ai" ".samourai/ai"
  prune_empty_dir "${TARGET_DIR}/.ai/rules" ".ai/rules"
  prune_empty_dir "${TARGET_DIR}/.ai/local" ".ai/local"
  prune_empty_dir "${TARGET_DIR}/.ai/agent" ".ai/agent"
  prune_empty_dir "${TARGET_DIR}/.ai" ".ai"
}

confirm_delete_project_artifacts() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    return 0
  fi

  printf '\nArtefacts projet Samourai détectés\n' >&2
  printf 'Cela peut inclure AGENTS.md, .samourai/AGENTS.md, .samourai/ai/** et .samourai/docai/**.\n' >&2
  printf 'Si tu les supprimes, tu perds le profil projet, les instructions agents, specs, plans, décisions et documents générés.\n' >&2
  printf 'Supprimer ces artefacts ? Tape "supprime" pour confirmer [laisser vide = garder]: ' >&2

  local answer
  if ! read -r answer; then
    answer=""
  fi
  case "${answer}" in
    supprime|SUPPRIME|Supprime) return 0 ;;
    *) return 1 ;;
  esac
}

is_samourai_root_agents_file() {
  local -r file="${TARGET_DIR}/AGENTS.md"

  [[ -f "${file}" ]] || return 1
  grep -Eq 'Samourai|\.samourai/AGENTS\.md|samourai' "${file}"
}

cleanup_project_generated_artifacts() {
  local has_artifacts=false
  local rel_path
  local paths=(
    "AGENTS.md"
    ".samourai/AGENTS.md"
    ".samourai/ai/agent/pm-instructions.md"
    ".samourai/ai/agent/pr-instructions.md"
    ".samourai/ai/agent/project-profile.md"
    ".samourai/ai/rules/bash.md"
    ".samourai/ai/rules/testing-strategy.md"
    ".samourai/docai"
  )

  [[ "${_manifest_found}" == "false" ]] || return 0

  for rel_path in "${paths[@]}"; do
    [[ -e "${TARGET_DIR}/${rel_path}" ]] && has_artifacts=true
  done

  [[ "${has_artifacts}" == "true" ]] || return 0

  if [[ "${FORCE}" != "true" && "${DRY_RUN}" != "true" ]]; then
    if ! confirm_delete_project_artifacts; then
      log_info "keep   project-generated Samourai artifacts"
      return 0
    fi
  fi

  if is_samourai_root_agents_file; then
    remove_file_if_exists "${TARGET_DIR}/AGENTS.md" "AGENTS.md"
  elif [[ -f "${TARGET_DIR}/AGENTS.md" ]]; then
    log_warn "keep   AGENTS.md (does not look like a Samourai-generated entrypoint)"
  fi

  remove_file_if_exists "${TARGET_DIR}/.samourai/AGENTS.md" ".samourai/AGENTS.md"
  remove_file_if_exists "${TARGET_DIR}/.samourai/ai/agent/pm-instructions.md" ".samourai/ai/agent/pm-instructions.md"
  remove_file_if_exists "${TARGET_DIR}/.samourai/ai/agent/pr-instructions.md" ".samourai/ai/agent/pr-instructions.md"
  remove_file_if_exists "${TARGET_DIR}/.samourai/ai/agent/project-profile.md" ".samourai/ai/agent/project-profile.md"
  remove_file_if_exists "${TARGET_DIR}/.samourai/ai/rules/bash.md" ".samourai/ai/rules/bash.md"
  remove_file_if_exists "${TARGET_DIR}/.samourai/ai/rules/testing-strategy.md" ".samourai/ai/rules/testing-strategy.md"

  if [[ -d "${TARGET_DIR}/.samourai/docai" ]]; then
    run_cmd rm -rf "${TARGET_DIR}/.samourai/docai"
    log_info "remove .samourai/docai/ (confirmed)"
  fi

  prune_empty_dir "${TARGET_DIR}/.samourai/ai/agent" ".samourai/ai/agent"
  prune_empty_dir "${TARGET_DIR}/.samourai/ai/rules" ".samourai/ai/rules"
  prune_empty_dir "${TARGET_DIR}/.samourai/ai/context" ".samourai/ai/context"
  prune_empty_dir "${TARGET_DIR}/.samourai/ai" ".samourai/ai"
  prune_empty_dir "${TARGET_DIR}/.samourai" ".samourai"
}

cleanup_shared_editor_dirs() {
  local d

  if [[ -d "${TARGET_DIR}/.github/skills" ]]; then
    while IFS= read -r d; do
      prune_empty_dir "${d}" "${d#${TARGET_DIR}/}"
    done < <(find "${TARGET_DIR}/.github/skills" -type d | sort -r)
  fi

  prune_empty_dir "${TARGET_DIR}/.github/agents" ".github/agents"
  prune_empty_dir "${TARGET_DIR}/.github/prompts" ".github/prompts"
  prune_empty_dir "${TARGET_DIR}/.github/skills" ".github/skills"
  prune_empty_dir "${TARGET_DIR}/.github" ".github"

  prune_empty_dir "${TARGET_DIR}/.vscode" ".vscode"

  prune_empty_dir "${TARGET_DIR}/.ai" ".ai"
}

cleanup_hidden_ai_dirs() {
  local rel_dir abs_dir
  local nested_dirs=()

  # Dedicated Samourai/AI directories can be removed as directories after explicit confirmation.
  # Shared editor/project directories (.github, .vscode, .ai) are handled only by manifest entries
  # plus empty-directory pruning; never rm -rf those containers.
  for rel_dir in .opencode .samourai/core .samourai/blueprints .samourai/install .samourai/tmpai .docai .tmpai .samurai; do
    delete_dir_if_confirmed "${rel_dir}"
  done

  # Then catch nested accidental installs, without entering common dependency/cache dirs.
  mapfile -t nested_dirs < <(
    find "${TARGET_DIR}" -maxdepth 4 \
      \( -path "${TARGET_DIR}/.git" -o -path "${TARGET_DIR}/node_modules" -o -path "${TARGET_DIR}/vendor" -o -path "${TARGET_DIR}/.venv" -o -path "${TARGET_DIR}/venv" \) -prune \
      -o -type d \( -name .samurai -o -name .opencode -o -name .docai -o -name .tmpai -o -path "${TARGET_DIR}/.samourai/tmpai" \) -print \
      | sort
  )

  for abs_dir in "${nested_dirs[@]}"; do
    rel_dir="${abs_dir#${TARGET_DIR}/}"
    [[ "${rel_dir}" != "${abs_dir}" ]] || continue
    [[ "${rel_dir}" == */* ]] || continue
    if is_nested_git_repo_dir "${abs_dir}"; then
      log_debug "skip   ${rel_dir}/ (nested git repository)"
      continue
    fi
    if ! has_samourai_marker "${abs_dir}"; then
      log_debug "skip   ${rel_dir}/ (no Samourai marker)"
      continue
    fi
    delete_dir_if_confirmed "${rel_dir}"
  done
}

usage() {
  cat <<USAGE_EOF
Usage: ${APP_NAME} [options]

Uninstall files that were installed by scripts/install-samourai.sh.
First removes files tracked in .samourai/install/installed-files.txt.
Then prunes empty shared editor directories and asks in French before deleting
remaining dedicated Samourai/AI directories, including nested accidental installs.
Shared project directories like .github, .vscode and .ai are never removed with rm -rf.
Legacy Samourai files inside .ai are removed separately, then .ai is pruned only if empty.

Options:
  -h, --help              Show this help
  -V, --version           Show version
      --target <dir>      Target project directory (default: current directory)
  -f, --force             Skip prompts and delete dedicated Samourai directories
  -n, --dry-run           Preview without deleting
  -v, --verbose           Debug output
      --allow-non-root    Allow uninstall in a git subdirectory

Example:
  ./scripts/uninstall-samourai.sh --target /path/to/project

Environment:
  DRY_RUN, VERBOSE, FORCE, ALLOW_NON_ROOT
USAGE_EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -V|--version) printf '%s %s\n' "${APP_NAME}" "${APP_VERSION}"; exit 0 ;;
      --target) shift; TARGET_DIR="${1:?--target requires a path}" ;;
      -f|--force) FORCE=true ;;
      -n|--dry-run) DRY_RUN=true ;;
      -v|--verbose) VERBOSE=true ;;
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

  TARGET_DIR="$(cd -- "${TARGET_DIR}" && pwd -P)" || die "Invalid target directory: ${TARGET_DIR}"
  ensure_project_root "${TARGET_DIR}"

  log_info "=== Samourai Local Uninstall ==="
  log_info "Target: ${TARGET_DIR}"
  [[ -f "${TARGET_DIR}/${MANIFEST_ADDED_REL}" ]] && _manifest_found=true

  if ! confirm_action "Supprimer les fichiers Samourai listés dans ${MANIFEST_ADDED_REL} ?"; then
    log_info "Aborted"
    return 0
  fi

  remove_installed_files
  cleanup_state
  cleanup_empty_scaffold_dirs
  cleanup_shared_editor_dirs
  cleanup_legacy_ai_files
  cleanup_project_generated_artifacts
  cleanup_hidden_ai_dirs
  cleanup_shared_editor_dirs
  cleanup_final_state

  printf '\n'
  log_info "Done — ${_removed} removed, ${_skipped} not found"
  log_info "Note: .gitignore entries are intentionally preserved for safety."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
