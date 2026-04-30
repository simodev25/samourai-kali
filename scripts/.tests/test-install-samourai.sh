#!/usr/bin/env bash

set -Eeuo pipefail
set -o errtrace
shopt -s inherit_errexit 2>/dev/null || true
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd -P)"
INSTALL_SCRIPT="${REPO_ROOT}/scripts/install-samourai.sh"
REMOTE_INSTALL_SCRIPT="${REPO_ROOT}/scripts/install-remote.sh"
UNINSTALL_SCRIPT="${REPO_ROOT}/scripts/uninstall-samourai.sh"

TMP_ROOT=""

cleanup() {
  if [[ -n "${TMP_ROOT}" && -d "${TMP_ROOT}" ]]; then
    rm -rf "${TMP_ROOT}"
  fi
}

trap cleanup EXIT

fail() {
  printf 'not ok - %s\n' "$*" >&2
  exit 1
}

ok() {
  printf 'ok - %s\n' "$*"
}

assert_file() {
  local -r path="$1"
  [[ -f "${path}" ]] || fail "expected file: ${path}"
}

assert_no_file() {
  local -r path="$1"
  [[ ! -e "${path}" ]] || fail "expected absent path: ${path}"
}

assert_symlink() {
  local -r path="$1"
  [[ -L "${path}" ]] || fail "expected symlink: ${path}"
}

assert_contains() {
  local -r path="$1" pattern="$2"
  grep -qF "${pattern}" "${path}" || fail "expected ${path} to contain: ${pattern}"
}

assert_not_contains() {
  local -r path="$1" pattern="$2"
  if [[ -f "${path}" ]] && grep -qF "${pattern}" "${path}"; then
    fail "expected ${path} not to contain: ${pattern}"
  fi
}

new_git_repo() {
  local dir
  dir="$(mktemp -d "${TMP_ROOT}/repo.XXXXXX")"
  git -C "${dir}" init -q
  printf '%s\n' "${dir}"
}

run_install() {
  "${INSTALL_SCRIPT}" --source "${REPO_ROOT}" --target "$1" --skip-opencode "${@:2}" >/dev/null
}

run_uninstall() {
  "${UNINSTALL_SCRIPT}" --target "$1" --force "${@:2}" >/dev/null
}

run_uninstall_interactive() {
  local -r repo="$1"
  local -r answers="$2"
  printf '%b' "${answers}" | "${UNINSTALL_SCRIPT}" --target "${repo}" >/dev/null
}

test_shell_syntax() {
  bash -n "${INSTALL_SCRIPT}"
  bash -n "${REMOTE_INSTALL_SCRIPT}"
  bash -n "${UNINSTALL_SCRIPT}"
  ok "shell syntax"
}

test_remote_installer_help() {
  local output
  output="$("${REMOTE_INSTALL_SCRIPT}" --help)"

  [[ "${output}" == *"raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit"* ]] || fail "expected remote installer curl example"
  [[ "${output}" == *"--ref <ref>"* ]] || fail "expected remote installer ref option"
  [[ "${output}" == *"Install options are forwarded"* ]] || fail "expected forwarded install options note"

  ok "remote installer help"
}

test_source_layout() {
  [[ -d "${REPO_ROOT}/core/agents" ]] || fail "expected core/agents"
  [[ -d "${REPO_ROOT}/core/commands" ]] || fail "expected core/commands"
  [[ -d "${REPO_ROOT}/core/skills" ]] || fail "expected core/skills"
  [[ -d "${REPO_ROOT}/blueprints" ]] || fail "expected blueprints"
  [[ ! -d "${REPO_ROOT}/adapters/opencode/.opencode/agent" ]] || fail "OpenCode adapter must not own canonical agents"
  [[ ! -d "${REPO_ROOT}/adapters/opencode/.opencode/command" ]] || fail "OpenCode adapter must not own canonical commands"
  [[ ! -d "${REPO_ROOT}/adapters/opencode/.opencode/skills" ]] || fail "OpenCode adapter must not own canonical skills"
  [[ ! -d "${REPO_ROOT}/adapters/vscode/.github/agents" ]] || fail "VS Code adapter must not own generated agents"
  [[ ! -d "${REPO_ROOT}/adapters/vscode/.github/skills" ]] || fail "VS Code adapter must not own generated skills"
  [[ ! -d "${REPO_ROOT}/adapters/vscode/.github/prompts" ]] || fail "VS Code adapter must not own generated prompts"
  ok "source layout"
}

test_docai_paths() {
  local forbidden
  forbidden='doc/changes|doc/spec|doc/decisions|doc/overview|doc/planning|doc/guides|doc/contracts|doc/domain|doc/quality|doc/ops|doc/templates|doc/tools|doc/documentation-handbook|doc/00-index|doc/diagrams'

  if grep -R -n -E "${forbidden}" "${REPO_ROOT}/core" "${REPO_ROOT}/docs" "${REPO_ROOT}/README.md" >/dev/null; then
    grep -R -n -E "${forbidden}" "${REPO_ROOT}/core" "${REPO_ROOT}/docs" "${REPO_ROOT}/README.md" >&2 || true
    fail "expected generated AI documentation paths to use .samourai/docai/"
  fi

  ok "docai paths"
}

test_tmpai_paths() {
  local forbidden
  forbidden='(^|[^/])tmp/(pr|code-review|review-feedback|run-logs-runner|playwright-report|tmpdir)|\./tmp/|`tmp/|"tmp/\*\*"|"tmp/pr/\*\*"'

  if grep -R -n -E "${forbidden}" "${REPO_ROOT}/core" "${REPO_ROOT}/docs" "${REPO_ROOT}/README.md" >/dev/null; then
    grep -R -n -E "${forbidden}" "${REPO_ROOT}/core" "${REPO_ROOT}/docs" "${REPO_ROOT}/README.md" >&2 || true
    fail "expected generated AI temporary paths to use .samourai/tmpai/"
  fi

  ok "tmpai paths"
}

test_project_skill_generation_contract() {
  local command_file="${REPO_ROOT}/core/commands/generate-project-skills.md"
  local readme_file="${REPO_ROOT}/core/skills/project/README.md"

  assert_contains "${command_file}" "domain=<name>"
  assert_contains "${command_file}" "Hard limit: 3 skills per pass, not 3 skills for the whole project."
  assert_contains "${command_file}" ".opencode/skills/project/<domain>/<skill-name>/SKILL.md"
  assert_contains "${command_file}" "Do not generate more than 3 skills in a single pass."
  assert_contains "${command_file}" "Do not treat 3 as a global project limit"
  assert_contains "${readme_file}" "Pas de limite globale à 3 skills pour tout le projet"
  assert_contains "${readme_file}" ".opencode/skills/project/<domain>/<skill-name>/SKILL.md"

  ok "project skill generation contract"
}

test_install_and_uninstall() {
  local repo manifest hash_manifest
  repo="$(new_git_repo)"
  manifest="${repo}/.samourai/install/installed-files.txt"
  hash_manifest="${repo}/.samourai/install/installed-files.sha256"

  run_install "${repo}" --editor opencode

  assert_file "${manifest}"
  assert_file "${hash_manifest}"
  assert_file "${repo}/.opencode/opencode.jsonc"
  assert_file "${repo}/.opencode/agent/pm.md"
  assert_file "${repo}/.opencode/command/bootstrap.md"
  assert_file "${repo}/.samourai/core/governance/conventions/change-lifecycle.md"
  assert_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_file "${repo}/.samourai/core/decisions/README.md"
  assert_file "${repo}/.samourai/blueprints/README.md"
  assert_file "${repo}/.samourai/blueprints/agents/agent.blueprint.yaml"
  assert_file "${repo}/.samourai/blueprints/project-bootstrap/AGENTS.template.md"
  assert_no_file "${repo}/governance/conventions/change-lifecycle.md"
  assert_no_file "${repo}/templates/change-spec-template.md"
  assert_no_file "${repo}/decisions/README.md"
  assert_contains "${repo}/.opencode/opencode.jsonc" ".samourai/core/governance/conventions/change-lifecycle.md"
  assert_contains "${repo}/.gitignore" ".samourai/core/"
  assert_contains "${repo}/.gitignore" ".samourai/install/"
  assert_contains "${repo}/.gitignore" ".samourai/tmpai/"
  assert_contains "${repo}/.gitignore" ".samourai/ai/local/"
  assert_contains "${repo}/.gitignore" "!.samourai/AGENTS.md"
  assert_contains "${repo}/.gitignore" "!.samourai/docai/**"
  assert_contains "${repo}/.gitignore" "!.samourai/ai/agent/**"
  assert_contains "${repo}/.gitignore" "!.samourai/ai/rules/**"
  assert_not_contains "${manifest}" "AGENTS.md"
  assert_contains "${manifest}" ".samourai/core/governance/conventions/change-lifecycle.md"
  assert_contains "${manifest}" ".samourai/core/templates/change-spec-template.md"
  assert_contains "${manifest}" ".samourai/core/decisions/README.md"
  assert_contains "${manifest}" ".samourai/blueprints/README.md"
  assert_contains "${manifest}" ".samourai/blueprints/agents/agent.blueprint.yaml"
  assert_contains "${hash_manifest}" ".opencode/opencode.jsonc"
  assert_no_file "${repo}/AGENTS.md"

  run_install "${repo}"
  assert_file "${manifest}"

  run_uninstall_interactive "${repo}" "o\n\n"
  assert_no_file "${repo}/.opencode/opencode.jsonc"
  assert_no_file "${repo}/.samourai/core/governance/conventions/change-lifecycle.md"
  assert_no_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_no_file "${repo}/.samourai/core/decisions/README.md"
  assert_no_file "${repo}/.samourai/blueprints/README.md"
  assert_no_file "${repo}/.samourai/blueprints/agents/agent.blueprint.yaml"
  assert_no_file "${repo}/.samourai/install/installed-files.txt"
  assert_contains "${repo}/.gitignore" ".samourai/core/"
  assert_contains "${repo}/.gitignore" ".samourai/tmpai/"
  assert_contains "${repo}/.gitignore" ".samourai/ai/local/"

  ok "install, reinstall without force, uninstall"
}

test_install_symlink_stack() {
  local repo stack
  repo="$(new_git_repo)"
  stack="$(dirname "${repo}")/$(basename "${repo}")-samurai"

  run_install "${repo}" --editor opencode --symlink-stack

  assert_symlink "${repo}/.opencode"
  assert_symlink "${repo}/.samourai"
  assert_file "${stack}/.opencode/opencode.jsonc"
  assert_file "${stack}/.opencode/agent/pm.md"
  assert_file "${stack}/.samourai/core/governance/conventions/change-lifecycle.md"
  assert_file "${stack}/.samourai/install/installed-files.txt"
  assert_contains "${repo}/.git/info/exclude" ".opencode"
  assert_contains "${repo}/.git/info/exclude" ".samourai"
  assert_contains "${repo}/.git/info/exclude" "AGENTS.md"
  assert_no_file "${repo}/.gitignore"

  ok "install symlink stack"
}

test_install_symlink_stack_migrates_existing_local_stack() {
  local repo stack
  repo="$(new_git_repo)"
  stack="$(dirname "${repo}")/$(basename "${repo}")-samurai"

  mkdir -p "${repo}/.opencode/agent" "${repo}/.samourai/ai/agent"
  printf 'custom agent\n' > "${repo}/.opencode/agent/custom.md"
  printf 'project profile\n' > "${repo}/.samourai/ai/agent/project-profile.md"
  printf 'root instructions\n' > "${repo}/AGENTS.md"

  run_install "${repo}" --editor opencode --symlink-stack

  assert_symlink "${repo}/.opencode"
  assert_symlink "${repo}/.samourai"
  assert_symlink "${repo}/AGENTS.md"
  assert_file "${stack}/.opencode/agent/custom.md"
  assert_file "${stack}/.opencode/agent/pm.md"
  assert_file "${stack}/.samourai/ai/agent/project-profile.md"
  assert_file "${stack}/AGENTS.md"

  ok "install symlink stack migrates existing local stack"
}

test_list_editors() {
  local output
  output="$("${INSTALL_SCRIPT}" --list-editors)"
  [[ "${output}" == *"opencode"* ]] || fail "expected list-editors to output opencode"
  [[ "${output}" == *"vscode"* ]] || fail "expected list-editors to output vscode"
  ok "list editors"
}

test_default_target_current_directory() {
  local repo
  repo="$(new_git_repo)"

  (
    cd "${repo}"
    "${INSTALL_SCRIPT}" --source "${REPO_ROOT}" --skip-opencode --core-only >/dev/null
  )

  assert_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_file "${repo}/.samourai/install/installed-files.txt"

  ok "default target current directory"
}

test_interactive_vscode() {
  local repo output
  repo="$(new_git_repo)"

  output="$(printf '\n2\nn\n\n' | "${INSTALL_SCRIPT}" --source "${REPO_ROOT}" --target "${repo}" --interactive 2>&1 >/dev/null)"

  assert_file "${repo}/.github/agents/pm.agent.md"
  assert_file "${repo}/.github/prompts/write-spec.prompt.md"
  assert_file "${repo}/.vscode/settings.json"
  assert_no_file "${repo}/.opencode/opencode.jsonc"
  [[ "${output}" == *"Installation Samourai Devkit"* ]] || fail "expected French interactive title"
  [[ "${output}" == *"Dossier du projet cible"* ]] || fail "expected French target prompt"
  [[ "${output}" == *"Quel éditeur veux-tu configurer"* ]] || fail "expected French editor prompt"
  [[ "${output}" == *"Faire d'abord une prévisualisation"* ]] || fail "expected French dry-run prompt"
  [[ "${output}" == *"Continuer ?"* ]] || fail "expected French confirmation prompt"

  ok "interactive vscode"
}

test_doctor() {
  local repo output
  repo="$(new_git_repo)"

  run_install "${repo}" --editor vscode
  output="$("${INSTALL_SCRIPT}" --source "${REPO_ROOT}" --target "${repo}" --doctor)"

  [[ "${output}" == *"Samourai Devkit doctor"* ]] || fail "expected doctor header"
  [[ "${output}" == *"OK   Git repository detected"* ]] || fail "expected git ok"
  [[ "${output}" == *"OK   Samourai core installed"* ]] || fail "expected core ok"
  [[ "${output}" == *"OK   VS Code agents and prompts installed"* ]] || fail "expected vscode ok"
  [[ "${output}" == *"OK   Doctor completed with no blocking issues"* ]] || fail "expected doctor success"

  ok "doctor"
}

test_core_only() {
  local repo manifest
  repo="$(new_git_repo)"
  manifest="${repo}/.samourai/install/installed-files.txt"

  run_install "${repo}" --core-only

  assert_file "${manifest}"
  assert_file "${repo}/.samourai/core/governance/conventions/change-lifecycle.md"
  assert_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_file "${repo}/.samourai/blueprints/README.md"
  assert_no_file "${repo}/.opencode/opencode.jsonc"
  assert_no_file "${repo}/.opencode/agent/pm.md"
  assert_contains "${manifest}" ".samourai/core/templates/change-spec-template.md"
  assert_not_contains "${manifest}" ".opencode/opencode.jsonc"

  run_uninstall "${repo}"
  assert_no_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_no_file "${repo}/.samourai/blueprints/README.md"

  ok "core only"
}

test_editor_all_alias() {
  local repo manifest
  repo="$(new_git_repo)"
  manifest="${repo}/.samourai/install/installed-files.txt"

  run_install "${repo}" --editor all

  assert_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_file "${repo}/.samourai/blueprints/testing/test.blueprint.yaml"
  assert_file "${repo}/.opencode/opencode.jsonc"
  assert_file "${repo}/.github/copilot-instructions.md"
  assert_file "${repo}/.github/agents/pm.agent.md"
  assert_file "${repo}/.github/prompts/plan-change.prompt.md"
  assert_file "${repo}/.github/skills/writing-plans/SKILL.md"
  assert_file "${repo}/.vscode/extensions.json"
  assert_file "${repo}/.vscode/mcp.json"
  assert_file "${repo}/.vscode/settings.json"
  assert_contains "${manifest}" ".opencode/opencode.jsonc"
  assert_contains "${manifest}" ".github/copilot-instructions.md"
  assert_contains "${manifest}" ".github/agents/pm.agent.md"
  assert_contains "${manifest}" ".github/skills/writing-plans/SKILL.md"
  assert_contains "${manifest}" ".vscode/extensions.json"
  assert_contains "${manifest}" ".vscode/mcp.json"
  assert_contains "${manifest}" ".vscode/settings.json"

  ok "editor all alias"
}

test_editor_vscode() {
  local repo manifest
  repo="$(new_git_repo)"
  manifest="${repo}/.samourai/install/installed-files.txt"

  run_install "${repo}" --editor vscode

  assert_file "${repo}/.samourai/core/templates/change-spec-template.md"
  assert_file "${repo}/.samourai/blueprints/README.md"
  assert_file "${repo}/.github/copilot-instructions.md"
  assert_file "${repo}/.github/agents/pm.agent.md"
  assert_file "${repo}/.github/agents/coder.agent.md"
  assert_file "${repo}/.github/prompts/bootstrap.prompt.md"
  assert_file "${repo}/.github/prompts/review.prompt.md"
  assert_file "${repo}/.github/prompts/write-spec.prompt.md"
  assert_file "${repo}/.github/skills/writing-plans/SKILL.md"
  assert_file "${repo}/.vscode/extensions.json"
  assert_file "${repo}/.vscode/mcp.json"
  assert_file "${repo}/.vscode/settings.json"
  assert_no_file "${repo}/.opencode/opencode.jsonc"
  assert_contains "${repo}/.github/copilot-instructions.md" ".samourai/core/governance/conventions/change-lifecycle.md"
  assert_contains "${repo}/.github/agents/pm.agent.md" "model:"
  assert_contains "${repo}/.github/agents/pm.agent.md" "tools:"
  assert_contains "${repo}/.github/agents/pm.agent.md" "tools: ['agent',"
  assert_contains "${repo}/.github/agents/pm.agent.md" "user-invocable: true"
  assert_contains "${repo}/.github/agents/pm.agent.md" "agents: ['architect', 'spec-writer', 'test-plan-writer', 'plan-writer', 'coder'"
  assert_contains "${repo}/.github/agents/coder.agent.md" "agents: ['architect', 'designer', 'editor', 'runner', 'fixer', 'reviewer', 'tdd-orchestrator', 'code-reviewer']"
  assert_contains "${repo}/.github/agents/runner.agent.md" "user-invocable: false"
  assert_contains "${repo}/.github/agents/runner.agent.md" "agents: []"
  assert_not_contains "${repo}/.github/agents/pm.agent.md" "Copyright (c)"
  assert_not_contains "${repo}/.github/prompts/write-spec.prompt.md" "description: Copyright"
  assert_not_contains "${repo}/.github/prompts/write-spec.prompt.md" "github.com/juliusz-cwiakalski"
  assert_contains "${repo}/.vscode/mcp.json" "\"servers\""
  assert_contains "${repo}/.vscode/mcp.json" "\"github\""
  assert_contains "${repo}/.vscode/settings.json" "\"chat.promptFilesLocations\""
  assert_contains "${repo}/.vscode/settings.json" "\"chat.subagents.allowInvocationsFromSubagents\""
  assert_contains "${manifest}" ".github/copilot-instructions.md"
  assert_contains "${manifest}" ".github/agents/pm.agent.md"
  assert_contains "${manifest}" ".github/prompts/review.prompt.md"
  assert_contains "${manifest}" ".github/skills/writing-plans/SKILL.md"
  assert_contains "${manifest}" ".vscode/mcp.json"
  assert_not_contains "${manifest}" ".opencode/opencode.jsonc"

  run_uninstall "${repo}"
  assert_no_file "${repo}/.github/copilot-instructions.md"
  assert_no_file "${repo}/.github/agents/pm.agent.md"
  assert_no_file "${repo}/.github/prompts/review.prompt.md"
  assert_no_file "${repo}/.github/skills/writing-plans/SKILL.md"
  assert_no_file "${repo}/.vscode/extensions.json"
  assert_no_file "${repo}/.vscode/mcp.json"
  assert_no_file "${repo}/.vscode/settings.json"

  ok "editor vscode"
}

test_unknown_editor_fails_before_copy() {
  local repo output
  repo="$(new_git_repo)"

  if output="$("${INSTALL_SCRIPT}" --source "${REPO_ROOT}" --target "${repo}" --skip-opencode --editor codex 2>&1)"; then
    fail "expected unsupported editor to fail"
  fi

  [[ "${output}" == *"Unsupported editor: codex"* ]] || fail "expected unsupported editor message"
  assert_no_file "${repo}/.samourai/core/templates/change-spec-template.md"

  ok "unknown editor fails before copy"
}

test_force_overwrite_audit() {
  local repo overwritten target_file
  repo="$(new_git_repo)"
  target_file="${repo}/.opencode/README.md"
  overwritten="${repo}/.samourai/install/overwritten-files.txt"

  mkdir -p "$(dirname "${target_file}")"
  printf 'local content\n' > "${target_file}"

  run_install "${repo}" --force

  assert_file "${overwritten}"
  assert_contains "${overwritten}" ".opencode/README.md"
  assert_contains "${target_file}" "OpenCode Kit"

  run_uninstall "${repo}"
  assert_file "${target_file}"
  assert_contains "${target_file}" "OpenCode Kit"

  ok "force overwrite audit"
}

test_install_does_not_overwrite_shared_github_files() {
  local repo manifest target_file
  repo="$(new_git_repo)"
  manifest="${repo}/.samourai/install/installed-files.txt"
  target_file="${repo}/.github/copilot-instructions.md"

  mkdir -p "$(dirname "${target_file}")"
  printf 'project copilot instructions\n' > "${target_file}"

  run_install "${repo}" --editor vscode

  assert_contains "${target_file}" "project copilot instructions"
  assert_not_contains "${manifest}" ".github/copilot-instructions.md"

  run_uninstall "${repo}"

  assert_file "${target_file}"
  assert_contains "${target_file}" "project copilot instructions"

  ok "install does not overwrite shared github files"
}

test_uninstall_keeps_modified_installed_file() {
  local repo target_file
  repo="$(new_git_repo)"
  target_file="${repo}/.github/agents/pm.agent.md"

  run_install "${repo}" --editor vscode

  printf '\nlocal user change\n' >> "${target_file}"

  run_uninstall "${repo}"

  assert_file "${target_file}"
  assert_contains "${target_file}" "local user change"

  ok "uninstall keeps modified installed file"
}

test_uninstall_without_manifest() {
  local repo sentinel
  repo="$(new_git_repo)"
  sentinel="${repo}/local-file.txt"
  printf 'keep me\n' > "${sentinel}"

  run_uninstall "${repo}"

  assert_file "${sentinel}"
  assert_contains "${sentinel}" "keep me"

  ok "uninstall without manifest"
}

test_uninstall_removes_dedicated_dirs_without_manifest() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.samourai/core" "${repo}/.samurai/install" "${repo}/.opencode/agent" "${repo}/.docai/changes" "${repo}/.tmpai/logs"
  printf 'core\n' > "${repo}/.samourai/core/file.md"
  printf 'old\n' > "${repo}/.samurai/install/file.txt"
  printf 'agent\n' > "${repo}/.opencode/agent/pm.md"
  printf 'doc\n' > "${repo}/.docai/changes/file.md"
  printf 'tmp\n' > "${repo}/.tmpai/logs/log.txt"

  run_uninstall_interactive "${repo}" "o\nsupprime\nsupprime\nsupprime\nsupprime\nsupprime\n"

  assert_no_file "${repo}/.samourai"
  assert_no_file "${repo}/.samurai"
  assert_no_file "${repo}/.opencode"
  assert_no_file "${repo}/.docai"
  assert_no_file "${repo}/.tmpai"

  ok "uninstall removes dedicated dirs without manifest"
}

test_uninstall_removes_project_artifacts_without_manifest() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.samourai/ai/agent" "${repo}/.samourai/ai/rules" "${repo}/.samourai/docai/changes"
  printf 'See .samourai/AGENTS.md for Samourai instructions\n' > "${repo}/AGENTS.md"
  printf 'project agents\n' > "${repo}/.samourai/AGENTS.md"
  printf 'pm\n' > "${repo}/.samourai/ai/agent/pm-instructions.md"
  printf 'pr\n' > "${repo}/.samourai/ai/agent/pr-instructions.md"
  printf 'profile\n' > "${repo}/.samourai/ai/agent/project-profile.md"
  printf 'bash\n' > "${repo}/.samourai/ai/rules/bash.md"
  printf 'spec\n' > "${repo}/.samourai/docai/changes/spec.md"

  run_uninstall_interactive "${repo}" "o\nsupprime\n"

  assert_no_file "${repo}/AGENTS.md"
  assert_no_file "${repo}/.samourai"

  ok "uninstall removes project artifacts without manifest"
}

test_uninstall_keeps_non_samourai_root_agents_without_manifest() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.samourai/ai/agent"
  printf 'custom agent instructions\n' > "${repo}/AGENTS.md"
  printf 'profile\n' > "${repo}/.samourai/ai/agent/project-profile.md"

  run_uninstall_interactive "${repo}" "o\nsupprime\n"

  assert_file "${repo}/AGENTS.md"
  assert_no_file "${repo}/.samourai"

  ok "uninstall keeps non-samourai root agents without manifest"
}

test_uninstall_cleans_only_legacy_ai_files() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.ai/agent"
  printf 'pm\n' > "${repo}/.ai/agent/pm-instructions.md"
  printf 'pr\n' > "${repo}/.ai/agent/pr-instructions.md"
  printf 'project\n' > "${repo}/.ai/agent/project-profile.md"
  printf 'custom\n' > "${repo}/.ai/custom.md"

  run_uninstall_interactive "${repo}" "o\nsupprime\n"

  assert_no_file "${repo}/.ai/agent/pm-instructions.md"
  assert_no_file "${repo}/.ai/agent/pr-instructions.md"
  assert_no_file "${repo}/.ai/agent/project-profile.md"
  assert_file "${repo}/.ai/custom.md"

  ok "uninstall cleans only legacy ai files"
}

test_uninstall_removes_legacy_ai_local_when_empty() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.ai/local" "${repo}/.ai/rules"
  printf 'context\n' > "${repo}/.ai/local/pm-context.yaml"
  printf 'testing\n' > "${repo}/.ai/rules/testing-strategy.md"

  run_uninstall "${repo}"

  assert_no_file "${repo}/.ai"

  ok "uninstall removes legacy ai local when empty"
}

test_uninstall_removes_samourai_ai_local_but_keeps_project_config() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/.samourai/ai/local" "${repo}/.samourai/ai/agent" "${repo}/.samourai/ai/rules"
  printf 'state\n' > "${repo}/.samourai/ai/local/pm-context.yaml"
  printf 'pm\n' > "${repo}/.samourai/ai/agent/pm-instructions.md"
  printf 'testing\n' > "${repo}/.samourai/ai/rules/testing-strategy.md"

  run_uninstall "${repo}"

  assert_no_file "${repo}/.samourai/ai/local/pm-context.yaml"
  assert_no_file "${repo}/.samourai/ai/local"
  assert_file "${repo}/.samourai/ai/agent/pm-instructions.md"
  assert_file "${repo}/.samourai/ai/rules/testing-strategy.md"

  ok "uninstall removes samourai ai local but keeps project config"
}

test_uninstall_hidden_dir_confirmations() {
  local repo
  repo="$(new_git_repo)"

  run_install "${repo}" --editor vscode

  mkdir -p "${repo}/.github/workflows" "${repo}/.docai/changes" "${repo}/.tmpai/run-logs-runner" "${repo}/.samourai/docai/spec" "${repo}/.samourai/tmpai/run-logs-runner"
  printf 'keep\n' > "${repo}/.github/workflows/keep.yml"
  printf 'docai\n' > "${repo}/.docai/changes/generated.md"
  printf 'tmpai\n' > "${repo}/.tmpai/run-logs-runner/log.txt"
  printf 'new docai\n' > "${repo}/.samourai/docai/spec/generated.md"
  printf 'new tmpai\n' > "${repo}/.samourai/tmpai/run-logs-runner/log.txt"

  run_uninstall_interactive "${repo}" "y\nsupprime\nsupprime\nsupprime\n"

  assert_file "${repo}/.github/workflows/keep.yml"
  assert_no_file "${repo}/.docai"
  assert_no_file "${repo}/.tmpai"
  assert_file "${repo}/.samourai/docai/spec/generated.md"
  assert_no_file "${repo}/.samourai/tmpai"
  assert_no_file "${repo}/.github/agents/pm.agent.md"
  assert_no_file "${repo}/.vscode/settings.json"

  ok "uninstall hidden dir confirmations"
}

test_uninstall_nested_hidden_dir_confirmations() {
  local repo
  repo="$(new_git_repo)"

  mkdir -p "${repo}/nested/target/.github/agents" "${repo}/nested/target/.tmpai"
  printf 'nested github\n' > "${repo}/nested/target/.github/copilot-instructions.md"
  printf 'nested agent\n' > "${repo}/nested/target/.github/agents/pm.agent.md"
  printf 'nested tmp\n' > "${repo}/nested/target/.tmpai/log.txt"

  run_uninstall_interactive "${repo}" "o\n\n"

  assert_file "${repo}/nested/target/.github/copilot-instructions.md"
  assert_file "${repo}/nested/target/.tmpai/log.txt"

  ok "uninstall nested hidden dir confirmations"
}

test_uninstall_never_removes_shared_github_dir() {
  local repo
  repo="$(new_git_repo)"

  run_install "${repo}" --editor vscode

  mkdir -p "${repo}/.github/workflows"
  printf 'workflow\n' > "${repo}/.github/workflows/ci.yml"

  run_uninstall_interactive "${repo}" "o\n"

  assert_file "${repo}/.github/workflows/ci.yml"
  assert_no_file "${repo}/.github/copilot-instructions.md"
  assert_no_file "${repo}/.github/agents/pm.agent.md"
  assert_no_file "${repo}/.github/prompts/review.prompt.md"

  ok "uninstall never removes shared github dir"
}

test_uninstall_skips_nested_git_repo_metadata() {
  local repo nested
  repo="$(new_git_repo)"
  nested="${repo}/vendor/lynis"

  mkdir -p "${nested}/.git" "${nested}/.github/ISSUE_TEMPLATE"
  printf 'bug\n' > "${nested}/.github/ISSUE_TEMPLATE/bug_report.md"

  run_uninstall_interactive "${repo}" "o\n"

  assert_file "${nested}/.github/ISSUE_TEMPLATE/bug_report.md"

  ok "uninstall skips nested git repo metadata"
}

main() {
  TMP_ROOT="$(mktemp -d /tmp/samourai-tests.XXXXXX)"

test_shell_syntax
test_remote_installer_help
test_source_layout
test_docai_paths
test_tmpai_paths
test_project_skill_generation_contract
test_list_editors
test_default_target_current_directory
test_interactive_vscode
test_doctor
test_install_and_uninstall
test_install_symlink_stack
test_install_symlink_stack_migrates_existing_local_stack
  test_core_only
  test_editor_vscode
  test_editor_all_alias
  test_unknown_editor_fails_before_copy
  test_force_overwrite_audit
  test_install_does_not_overwrite_shared_github_files
  test_uninstall_keeps_modified_installed_file
  test_uninstall_without_manifest
test_uninstall_removes_dedicated_dirs_without_manifest
test_uninstall_removes_project_artifacts_without_manifest
test_uninstall_keeps_non_samourai_root_agents_without_manifest
test_uninstall_cleans_only_legacy_ai_files
  test_uninstall_removes_legacy_ai_local_when_empty
  test_uninstall_removes_samourai_ai_local_but_keeps_project_config
  test_uninstall_hidden_dir_confirmations
  test_uninstall_nested_hidden_dir_confirmations
  test_uninstall_never_removes_shared_github_dir
  test_uninstall_skips_nested_git_repo_metadata
}

main "$@"
