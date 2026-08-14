#!/bin/bash -p

set -euo pipefail
if [[ "$-" != *p* ]]; then
    printf "%s\n" "ERROR: Run this script directly so Bash privileged mode is active." >&2
    exit 1
fi
unset BASH_ENV ENV GNUMAKEFLAGS MAKE MAKE_COMMAND MAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS SUDO SUDO_CMD
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
umask 022

SCRIPT_DIR=""
PROJECT_ROOT=""
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly SCRIPT_DIR PROJECT_ROOT

MODE="local"
MODE_SET=0
WORKSPACE=""
TEST_PROJECT=""
TEST_SOURCE_RELATIVE="procServ-src"
SOURCE_REPO=""
SOURCE_TAG=""
SOURCE_COMMIT=""
INSTALL_LOCATION=""
INSTALL_PREFIX=""
INSTALL_LOG=""
INSTALL_BIN=""
SUDO_BIN=""

function die {
    printf "ERROR: %s\n" "$1" >&2
    exit 1
}

function pass {
    printf "[ PASS ] %s\n" "$1"
}

function usage {
    printf "Usage: %s [--local | --system]\n" "${0##*/}"
    printf "  --local   Test installation to a user-writable destination.\n"
    printf "  --system  Test installation to a protected destination with real sudo.\n"
}

function parse_args {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --local)
                [[ "$MODE_SET" -eq 0 ]] || die "Select only one test mode."
                MODE="local"
                MODE_SET=1
                ;;
            --system)
                [[ "$MODE_SET" -eq 0 ]] || die "Select only one test mode."
                MODE="system"
                MODE_SET=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                [[ $# -eq 0 ]] || die "Positional arguments are not supported."
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                die "Unexpected argument: $1"
                ;;
        esac
        shift
    done
}

function require_command {
    local command_name="$1"
    local command_path=""

    if ! command_path="$(command -v "$command_name" 2>/dev/null)"; then
        die "Required command not found: ${command_name}"
    fi
    [[ -x "$command_path" ]] || die "Required command is not executable: ${command_path}"
}

function resolve_workspace {
    local resolved=""

    [[ -n "$WORKSPACE" ]] || return 1
    [[ "$WORKSPACE" =~ ^/tmp/procserv-install-test\.[A-Za-z0-9]+$ ]] || return 1
    [[ -d "$WORKSPACE" && ! -L "$WORKSPACE" ]] || return 1
    if ! resolved="$(realpath -e -- "$WORKSPACE")"; then
        return 1
    fi
    [[ "$resolved" == "$WORKSPACE" ]] || return 1
    printf "%s\n" "$resolved"
}

function cleanup {
    local rc=$?
    local keep="${KEEP_WORKSPACE:-0}"
    local user_id=""
    local group_id=""
    local cleanup_target=""

    trap - EXIT
    [[ -n "$WORKSPACE" ]] || exit "$rc"

    if [[ "$rc" -ne 0 || "$keep" -eq 1 ]]; then
        printf "Workspace retained: %s\n" "$WORKSPACE"
        exit "$rc"
    fi
    if ! cleanup_target="$(resolve_workspace)"; then
        printf "ERROR: Refusing to clean an invalid workspace: %s\n" "$WORKSPACE" >&2
        exit 1
    fi
    if [[ "$MODE" == "system" ]]; then
        user_id="$(id -u)"
        group_id="$(id -g)"
        if ! "$SUDO_BIN" -n /bin/chown -R -- "${user_id}:${group_id}" "${cleanup_target:?}"; then
            printf "ERROR: Workspace ownership cleanup failed: %s\n" "$cleanup_target" >&2
            exit 1
        fi
    fi
    if ! /bin/chmod -R u+rwX -- "${cleanup_target:?}"; then
        printf "ERROR: Workspace mode cleanup failed: %s\n" "$cleanup_target" >&2
        exit 1
    fi
    if ! /bin/rm -rf -- "${cleanup_target:?}"; then
        printf "ERROR: Workspace removal failed: %s\n" "$cleanup_target" >&2
        exit 1
    fi
    exit "$rc"
}

function validate_environment {
    local keep="${KEEP_WORKSPACE:-0}"
    local source_relative=""
    local source_status=""
    local sudo_configured=""

    [[ "$EUID" -ne 0 ]] || die "Run this script as a regular user."
    [[ "$keep" == "0" || "$keep" == "1" ]] || die "KEEP_WORKSPACE must be 0 or 1."

    require_command bash
    require_command git
    require_command grep
    require_command install
    require_command make
    require_command mktemp
    require_command realpath
    require_command stat
    require_command sudo
    require_command tee
    require_command which

    INSTALL_BIN="$(command -v install)"
    SUDO_BIN="$(command -v sudo)"
    [[ -s "${PROJECT_ROOT}/Makefile" ]] || die "Project Makefile is missing or empty."
    [[ -s "${PROJECT_ROOT}/configure/RULES_INSTALL" ]] || die "RULES_INSTALL is missing or empty."

    source_relative="$(make -s --no-print-directory -C "$PROJECT_ROOT" print-SRC_PATH)"
    SOURCE_TAG="$(make -s --no-print-directory -C "$PROJECT_ROOT" print-SRC_TAG)"
    sudo_configured="$(make -s --no-print-directory -C "$PROJECT_ROOT" print-SUDO_CMD)"
    [[ -n "$source_relative" ]] || die "SRC_PATH resolved to an empty value."
    [[ -n "$SOURCE_TAG" ]] || die "SRC_TAG resolved to an empty value."
    [[ "$sudo_configured" == "$SUDO_BIN" ]] || die "SUDO_CMD does not match the validated sudo path."
    if ! SOURCE_REPO="$(realpath -e -- "${PROJECT_ROOT}/${source_relative}")"; then
        die "Configured source repository does not exist: ${source_relative}"
    fi
    [[ -d "${SOURCE_REPO}/.git" ]] || die "Configured source path is not a Git repository: ${SOURCE_REPO}"
    source_status="$(git -C "$SOURCE_REPO" status --porcelain)"
    [[ -z "$source_status" ]] || die "Configured source repository has local changes: ${SOURCE_REPO}"
    if ! SOURCE_COMMIT="$(git -C "$SOURCE_REPO" rev-parse "${SOURCE_TAG}^{commit}")"; then
        die "Configured source revision does not resolve: ${SOURCE_TAG}"
    fi

    if [[ "$MODE" == "system" ]] && ! "$SUDO_BIN" -n true; then
        die "System mode requires authorized non-interactive sudo."
    fi
}

function prepare_workspace {
    WORKSPACE="$(mktemp -d /tmp/procserv-install-test.XXXXXX)"
    TEST_PROJECT="${WORKSPACE}/project"
    trap cleanup EXIT

    git clone --quiet --local --no-hardlinks "$PROJECT_ROOT" "$TEST_PROJECT"
    install -m 0644 "${PROJECT_ROOT}/configure/RULES_INSTALL" "${TEST_PROJECT}/configure/RULES_INSTALL"
    make --no-print-directory -C "$TEST_PROJECT" init \
        SRC_GITURL="$SOURCE_REPO" \
        SRC_PATH="$TEST_SOURCE_RELATIVE" \
        SRC_TAG="$SOURCE_COMMIT"

    [[ "$(git -C "${TEST_PROJECT}/${TEST_SOURCE_RELATIVE}" rev-parse HEAD)" == "$SOURCE_COMMIT" ]] || \
        die "Cloned procServ source does not match the configured revision."
    [[ -z "$(git -C "${TEST_PROJECT}/${TEST_SOURCE_RELATIVE}" status --porcelain)" ]] || \
        die "Cloned procServ source is not clean."
}

function configure_and_build {
    make --no-print-directory -C "$TEST_PROJECT" conf build \
        INSTALL_LOCATION="$INSTALL_LOCATION" \
        SRC_PATH="$TEST_SOURCE_RELATIVE"
}

function install_and_capture {
    INSTALL_LOG="${WORKSPACE}/install-${MODE}.log"
    make --no-print-directory -C "$TEST_PROJECT" install \
        INSTALL_LOCATION="$INSTALL_LOCATION" \
        SRC_PATH="$TEST_SOURCE_RELATIVE" \
        VERBOSE=1 2>&1 | tee "$INSTALL_LOG"
    [[ -s "$INSTALL_LOG" ]] || die "Install log is missing or empty."

    INSTALL_PREFIX="$(make -s --no-print-directory -C "$TEST_PROJECT" print-INSTALL_LOCATION_APPNAME \
        INSTALL_LOCATION="$INSTALL_LOCATION" \
        SRC_PATH="$TEST_SOURCE_RELATIVE")"
    [[ -x "${INSTALL_PREFIX}/bin/procServ" ]] || die "Installed procServ executable was not found."
}

function run_local_test {
    mkdir -p "${WORKSPACE}/writable"
    INSTALL_LOCATION="${WORKSPACE}/writable/install"
    mkdir -p "$INSTALL_LOCATION"

    configure_and_build
    install_and_capture
    if grep -Eq '(^|[[:space:]/])sudo([[:space:]]|$)' "$INSTALL_LOG"; then
        die "Writable installation invoked sudo."
    fi
    pass "Writable installation completed without sudo."
    pass "Installed executable exists at ${INSTALL_PREFIX}/bin/procServ."
}

function run_system_test {
    local system_workspace=""
    local protected_parent=""
    local parent_uid=""
    local install_uid=""

    if ! system_workspace="$(resolve_workspace)"; then
        die "System test workspace is invalid."
    fi
    INSTALL_LOCATION="${system_workspace}/protected/install"
    "$SUDO_BIN" -n "$INSTALL_BIN" -d -o root -g root -m 0755 "$INSTALL_LOCATION"
    protected_parent="$(realpath -e -- "${INSTALL_LOCATION}/..")"
    parent_uid="$(stat -c '%u' "$protected_parent")"
    install_uid="$(stat -c '%u' "$INSTALL_LOCATION")"
    [[ "$parent_uid" -eq 0 && "$install_uid" -eq 0 ]] || \
        die "Protected installation path is not root-owned."
    [[ ! -w "$protected_parent" ]] || die "Protected installation parent is writable by the test user."
    [[ ! -w "$INSTALL_LOCATION" ]] || die "Protected installation destination is writable by the test user."

    configure_and_build
    install_and_capture
    if ! grep -Eq '(^|[[:space:]/])sudo([[:space:]]|$)' "$INSTALL_LOG"; then
        die "Protected installation did not invoke sudo."
    fi
    pass "Protected installation completed with sudo."
    pass "Installed executable exists at ${INSTALL_PREFIX}/bin/procServ."
}

function main {
    parse_args "$@"
    validate_environment
    prepare_workspace

    case "$MODE" in
        local) run_local_test ;;
        system) run_system_test ;;
        *) die "Unsupported test mode: ${MODE}" ;;
    esac
}

main "$@"
