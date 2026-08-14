# Work Register

## Scope

This document tracks assigned and unassigned work for the `master` generation that starts from commit `6a288db`.

Out of scope: numbered release execution and final release verification.

Release line: master
Milestone index: 6a288db
Canonical path: `docs/milestone-6a288db.md`
Canonical branch or ref: master
Git upstream: origin/master
Remote tracker: `jeonghanlee/procServ-env`; GitHub milestone: none

Next session entry point: On a disposable Linux host that permits root-owned test directories below `/tmp`, work as a regular user. Run `sudo -n true`, then create and remove an empty workspace below `/tmp` with `mktemp` and `rmdir`. After the sudo check, workspace creation, and workspace removal all succeed, record G1 Complete, restore M1 to In progress, and run `tests/test-install-privilege.bash --system` from the repository root.

## Milestone

### Work

| Group | ID | Work unit | Type | Status | Ready | Deps | Done when / Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Privilege handling | M1 | Honor the configured sudo decision in `src_install` | Milestone | Blocked | No | G1 | `src_install` follows `SUDO`; M1 / T1 and M1 / T2 pass; issue #1 is closed or an owner exception is recorded; [detail](#m1---honor-the-configured-sudo-decision-in-src_install) |
| Privilege handling | G1 | Provide a privileged disposable Linux test environment | External gate | Open | No | | M1 / T2 can run with authorized non-interactive `sudo`; [detail](#g1---provide-a-privileged-disposable-linux-test-environment) |

### Decisions

No decisions recorded.

### Milestone Details

#### M1 - Honor the configured sudo decision in `src_install`

Origin: 6a288db / M1
Identity History: none
GitHub Issue: [#1](https://github.com/jeonghanlee/procServ-env/issues/1)
Status: Blocked

##### Summary

Make the `src_install` recipe follow the privilege decision already calculated in `configure/CONFIG_SRC`, so a writable Linux destination does not invoke `sudo` while a protected destination still does.

##### Scope

Update `src_install` in `configure/RULES_INSTALL` to use the selected `SUDO` value and add regression coverage through the shipped top-level Makefile and real procServ source tree.

Out of scope: changing privilege detection in `configure/CONFIG_SRC`, changing `uninstall` or `src_uninstall`, and changing Darwin behavior.

##### Completion Criteria

- On Linux, a real build and install to a writable temporary destination succeeds without a `SUDO_CMD=` override and without invoking `sudo`.
- On Linux, a real build and install to a protected temporary destination invokes `sudo` and succeeds when the test environment grants the required privilege.
- The regression checks use the shipped Makefile graph and real cloned procServ source; no internal function, recipe, or fixture is replaced.
- GitHub issue #1 is observed closed, or Closure Evidence records an explicit owner exception.

##### Dependencies And Decisions

- G1; resume as In progress after the external test environment is available.

##### Implementation Plan

Plan Status: accepted
Plan Acceptance: Owner approval in chat, 2026-08-14
Implementation Authorization: Owner approval in chat, 2026-08-14
Superseded Plan Artifacts: none

1. Change only the `src_install` recipe prefix from `SUDO_CMD` to the configured `SUDO` value.
2. Add `tests/test-install-privilege.bash` to drive the shipped top-level Makefile against the real cloned procServ source for writable and protected temporary destinations.
3. Run the checks on Linux and retain the command output and installed-tree observations as evidence.
4. Compare the final issue projection with GitHub issue #1 before closure.

##### Test Plan

| Label | Layer | Method | Environment | Expected Result |
| --- | --- | --- | --- | --- |
| T1 | Integration | Run the shipped `init`, `conf`, `build`, and `install` path with a pre-created writable temporary installation root and the real procServ source | Linux host with build prerequisites, `sudo`, `which`, and a user-writable temporary directory | Installation succeeds, the installed tree exists, and no `sudo` process is invoked |
| T2 | Integration | Run the shipped `init`, `conf`, `build`, and `install` path with a pre-created root-owned temporary installation root and the real procServ source | Disposable Linux system with a root-owned temporary directory and authorized non-interactive `sudo` | Installation succeeds, the installed tree exists, and `sudo` is invoked for `src_install` |

##### Verification Results

| Label | Observed At | Environment | Result | Evidence |
| --- | --- | --- | --- | --- |
| T1 | 2026-08-14T12:23:58-07:00 | Debian 13.6, Linux 6.12.100+deb13-amd64, x86_64 | Pass | `env MAKE=/bin/false MAKE_COMMAND=/bin/false MAKEFLAGS=-e GNUMAKEFLAGS=-e MFLAGS=-e MAKEFILES=/dev/null MAKEOVERRIDES=SUDO_CMD SUDO_CMD= SUDO=/bin/false ./tests/test-install-privilege.bash --local`; overrides cleared before Make execution; real procServ source commit `073f290012bd5c09666e066d3491c034f08c3bfe`; install completed with the normal `make` command and without `sudo`; installed `bin/procServ` observed; successful workspace cleanup observed |
| T2 | Not run | Disposable Linux protected temporary destination | Pending | none |

##### Closure Evidence

- None.

##### GitHub Projection

Title: Avoid unconditional sudo invocation in src_install
Labels: `bug`
GitHub Milestone: none
Observed State: open
Observed Labels: `bug`
Observed Milestone: none
Last Compared: 2026-08-14T09:27:57-07:00; remote update 2026-08-13T08:04:52Z
Projection Drift: The live issue body does not include the accepted Implementation Plan, M1 / T1 result, or G1; no GitHub mutation is authorized.

#### G1 - Provide a privileged disposable Linux test environment

Origin: 6a288db / G1
GitHub Issue: none
Status: Open

##### Summary

The owner or operator must provide a disposable Linux environment with authorized non-interactive `sudo` so M1 / T2 can install to a protected temporary destination. The current container sets `NoNewPrivs: 1`, so `sudo` cannot elevate privilege and M1 remains Blocked.

##### Completion Criteria

- `sudo -n true` succeeds as a regular user in the disposable test environment.
- The operator confirms that the host is disposable and permits root-owned temporary test directories below `/tmp`.
- The regular user can create a temporary workspace below `/tmp` without changing repository files.

##### Verification Results

| Observed At | Result | Evidence |
| --- | --- | --- |
| 2026-08-14T09:48:32-07:00 | Open | `tests/test-install-privilege.bash --system` exited 1 before T2; `sudo` reported that `no new privileges` prevents elevation; `/proc/self/status` reported `NoNewPrivs: 1` |

##### Closure Evidence

- None.

## Backlog

Backlog rows are unassigned and excluded from the milestone tally.

### Work

| Group | ID | Work unit | Type | Status | Ready | Deps | Done when / Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Privilege handling | M2 | Assess sudo selection in uninstall recipes | Milestone | Open | No | | The owner resolves priority and scope from the audit evidence; [detail](#m2---assess-sudo-selection-in-uninstall-recipes) |
| Privilege handling | M3 | Correct privilege detection for an absent install destination | Milestone | Open | No | | The owner assigns or otherwise resolves the observed detection defect; [detail](#m3---correct-privilege-detection-for-an-absent-install-destination) |

### Backlog Details

#### M2 - Assess sudo selection in uninstall recipes

Origin: 6a288db / M2
Identity History: none
GitHub Issue: none
Status: Open

##### Summary

Determine whether the top-level `uninstall` and `src_uninstall` recipes should follow the configured `SUDO` value instead of invoking `SUDO_CMD` unconditionally. This assessment remains separate from GitHub issue #1.

##### Scope

Audit both uninstall recipes, compare their privilege requirements with writable and protected installation roots, and collect real-path observations for an owner scope decision.

Out of scope: changing either uninstall recipe before the owner assigns and accepts a defined change.

##### Completion Criteria

- The audit identifies the command selected by each uninstall recipe for writable and protected temporary installation roots.
- The audit records whether each real uninstall removes the installed tree and whether invoking `sudo` is necessary.
- The owner records a dated decision to assign, defer, transfer, or retire the work.

##### Dependencies And Decisions

- Owner condition: priority and change scope are unresolved; remain Open until the owner records a decision.

##### Implementation Plan

Plan Status: draft
Plan Acceptance: none
Implementation Authorization: none
Superseded Plan Artifacts: none

1. Inspect `uninstall`, `src_uninstall`, and the `SUDO` selection in `configure/CONFIG_SRC` as one command path.
2. Run the real install and uninstall path with a writable temporary installation root and retain process and filesystem evidence.
3. Run the same path on a disposable Linux system with a protected temporary installation root and authorized `sudo`.
4. Present the observations for an owner decision without changing the uninstall recipes.

##### Test Plan

| Label | Layer | Method | Environment | Expected Result |
| --- | --- | --- | --- | --- |
| T1 | System observation | Run the shipped real install and uninstall path with a writable temporary installation root | Linux host with build prerequisites and a user-writable temporary directory | Evidence identifies the selected privilege command and whether the installed tree is removed |
| T2 | System observation | Run the shipped real install and uninstall path with a protected temporary installation root | Disposable Linux system with a root-owned temporary directory and authorized non-interactive `sudo` | Evidence identifies the selected privilege command and whether the installed tree is removed |

##### Verification Results

| Label | Observed At | Environment | Result | Evidence |
| --- | --- | --- | --- | --- |
| T1 | Not run | Linux writable temporary destination | Pending | none |
| T2 | Not run | Disposable Linux protected temporary destination | Pending | none |

##### Closure Evidence

- None.

#### M3 - Correct privilege detection for an absent install destination

Origin: 6a288db / M3
Identity History: none
GitHub Issue: none
Status: Open

##### Summary

Correct the Linux privilege decision for a writable installation destination that does not yet exist. The current `test -w $(INSTALL_LOCATION)/..` expression fails before the shell can resolve `..` when the `INSTALL_LOCATION` component is absent, so `SUDO_INFO` incorrectly selects `sudo`.

##### Scope

Define and verify parent-directory resolution for existing and absent Linux installation destinations before evaluating writability.

Out of scope: the M1 `src_install` command selection, uninstall behavior, and Darwin privilege policy.

##### Completion Criteria

- An absent installation destination under a writable parent selects an empty `SUDO` value.
- An existing writable installation destination continues to select an empty `SUDO` value.
- A destination under a protected parent continues to select `sudo`.
- The real shipped configuration and install path verify all three cases without replacing the detection logic or Makefile path.

##### Dependencies And Decisions

- Owner condition: priority and assignment are unresolved; remain Open until the owner records a decision.
- Observation: A pre-T1 exploratory run on 2026-08-14 selected `/usr/bin/sudo` for an absent destination under a writable temporary workspace. Recheck with the shipped `print-SUDO_INFO` target and an absent destination below a writable parent.

##### Implementation Plan

Plan Status: draft
Plan Acceptance: none
Implementation Authorization: none
Superseded Plan Artifacts: none

1. Reproduce the decision with existing writable, absent writable, and protected destination paths through the shipped configuration.
2. Select a parent-directory expression that remains valid when the destination does not exist.
3. Update only the Linux writability decision and preserve the current Darwin policy.
4. Run the real install path for all three destination states and retain the observations.

##### Test Plan

| Label | Layer | Method | Environment | Expected Result |
| --- | --- | --- | --- | --- |
| T1 | Configuration | Evaluate the shipped configuration with an existing writable installation destination | Linux host with a user-writable temporary directory | `SUDO_INFO` is `0` and `SUDO` is empty |
| T2 | Integration | Run the shipped real install path with an absent destination below a writable parent | Linux host with build prerequisites and a user-writable temporary directory | Installation succeeds without invoking `sudo` |
| T3 | Integration | Run the shipped real install path with a destination below a protected parent | Disposable Linux system with authorized non-interactive `sudo` | Installation invokes `sudo` and succeeds |

##### Verification Results

| Label | Observed At | Environment | Result | Evidence |
| --- | --- | --- | --- | --- |
| T1 | Not run | Linux existing writable destination | Pending | none |
| T2 | Not run | Linux absent writable destination | Pending | none |
| T3 | Not run | Disposable Linux protected destination | Pending | none |

##### Closure Evidence

- None.
