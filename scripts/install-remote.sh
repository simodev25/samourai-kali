#!/usr/bin/env bash
# install-remote.sh — Download Samourai Devkit from GitHub, then run local installer

set -Eeuo pipefail
set -o errtrace
shopt -s inherit_errexit 2>/dev/null || true
IFS=$'\n\t'

readonly APP_NAME="samourai-remote-install"
readonly APP_VERSION="1.0.0"
readonly LOG_TAG="(${APP_NAME})"

DEFAULT_REPO="FR-PAR-SAMOUR-AI/samourai-devkit"
DEFAULT_REF="main"

REPO="${SAMOURAI_REPO:-${DEFAULT_REPO}}"
REF="${SAMOURAI_REF:-${DEFAULT_REF}}"
GITHUB_TOKEN="${SAMOURAI_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
TMP_DIR=""
INSTALL_ARGS=()

log_info() { printf '[INFO]  %s %s\n' "${LOG_TAG}" "$*" >&2; }
log_err() { printf '[ERROR] %s %s\n' "${LOG_TAG}" "$*" >&2; }

die() {
  log_err "$*"
  exit 2
}

cleanup() {
  if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}"
  fi
}

trap cleanup EXIT

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

usage() {
  cat <<USAGE_EOF
Usage: ${APP_NAME} [remote options] -- [install options]
       ${APP_NAME} [install options]

Download Samourai Devkit from GitHub, extract it to a temporary directory, then
run scripts/install-samourai.sh with the provided install options.

Remote options:
  -h, --help            Show this help
  -V, --version         Show version
      --repo <owner/repo>
                          GitHub repository to download
                          Default: ${DEFAULT_REPO}
      --ref <ref>       Branch, tag, or commit archive ref
                          Default: ${DEFAULT_REF}

Install options are forwarded to scripts/install-samourai.sh.

Examples:
  curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/${DEFAULT_REF}/scripts/install-remote.sh | bash
  curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/${DEFAULT_REF}/scripts/install-remote.sh | bash -s -- --target /path/to/project --editor opencode
  curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/${DEFAULT_REF}/scripts/install-remote.sh | bash -s -- --ref v1.0.0 -- --target /path/to/project --core-only

Private repository:
  read -rsp 'GitHub token: ' SAMOURAI_GITHUB_TOKEN; echo; export SAMOURAI_GITHUB_TOKEN
  curl -H "Authorization: Bearer \${SAMOURAI_GITHUB_TOKEN}" -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/${DEFAULT_REF}/scripts/install-remote.sh | bash -s -- --target /path/to/project
  unset SAMOURAI_GITHUB_TOKEN

Environment:
  SAMOURAI_REPO, SAMOURAI_REF, SAMOURAI_GITHUB_TOKEN
USAGE_EOF
}

parse_remote_args() {
  while (($#)); do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -V|--version)
        printf '%s %s\n' "${APP_NAME}" "${APP_VERSION}"
        exit 0
        ;;
      --repo)
        shift
        REPO="${1:?--repo requires owner/repo}"
        ;;
      --ref)
        shift
        REF="${1:?--ref requires a branch, tag, or commit}"
        ;;
      --)
        shift
        INSTALL_ARGS+=("$@")
        break
        ;;
      *)
        INSTALL_ARGS+=("$1")
        ;;
    esac
    shift
  done
}

validate_repo() {
  [[ "${REPO}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "Invalid --repo value: ${REPO}"
  [[ -n "${REF}" ]] || die "--ref cannot be empty"
}

main() {
  local archive_url archive_path kit_dir
  local -a curl_args=(-fsSL)

  parse_remote_args "$@"
  validate_repo
  require_cmd bash
  require_cmd curl
  require_cmd find
  require_cmd head
  require_cmd sort
  require_cmd tar
  require_cmd mktemp

  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/samourai-devkit.XXXXXX")"
  archive_path="${TMP_DIR}/samourai-devkit.tar.gz"
  archive_url="https://github.com/${REPO}/archive/${REF}.tar.gz"

  log_info "Downloading ${REPO}@${REF}"
  if [[ -n "${GITHUB_TOKEN}" ]]; then
    curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  curl "${curl_args[@]}" "${archive_url}" -o "${archive_path}"

  log_info "Extracting archive"
  tar -xzf "${archive_path}" -C "${TMP_DIR}"

  kit_dir="$(find "${TMP_DIR}" -mindepth 1 -maxdepth 1 -type d | sort | head -n 1)"
  [[ -n "${kit_dir}" ]] || die "Downloaded archive did not contain a directory"
  [[ -x "${kit_dir}/scripts/install-samourai.sh" || -f "${kit_dir}/scripts/install-samourai.sh" ]] || die "Downloaded archive is missing scripts/install-samourai.sh"

  log_info "Running local installer from downloaded kit"
  bash "${kit_dir}/scripts/install-samourai.sh" --source "${kit_dir}" "${INSTALL_ARGS[@]}"
}

main "$@"
