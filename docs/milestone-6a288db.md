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

Next session entry point: Every assigned row in `## Milestone` is Complete. The only remaining work is the unassigned Backlog row M2 (assess sudo selection in the uninstall recipes), which stays Open until the owner records a dated decision on its priority and change scope.

## Milestone

### Work

| Group | ID | Work unit | Type | Status | Ready | Deps | Done when / Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Privilege handling | M1 | Honor the configured sudo decision in `src_install` | Milestone | Complete | No | G1 | `src_install` follows `SUDO`; M1 / T1 and M1 / T2 pass; issue #1 is closed or an owner exception is recorded; [detail](#m1---honor-the-configured-sudo-decision-in-src_install) |
| Privilege handling | G1 | Provide a privileged disposable Linux test environment | External gate | Complete | No | | M1 / T2 and M3 / T3 can run with authorized non-interactive `sudo`; [detail](#g1---provide-a-privileged-disposable-linux-test-environment) |
| Privilege handling | M3 | Correct privilege detection for an absent install destination | Milestone | Complete | No | G1 | The privilege decision is correct for existing writable, absent writable, and protected destinations; [detail](#m3---correct-privilege-detection-for-an-absent-install-destination) |

### Decisions

No decisions recorded.

### Assignment History

| Work Identity | From Canonical | To Canonical | Target Commit | Authority Moved At |
| --- | --- | --- | --- | --- |
| `docs/milestone-6a288db.md` / M3 | `docs/milestone-6a288db.md` / Backlog | `docs/milestone-6a288db.md` / Milestone | this synchronization commit | this synchronization commit |

### Milestone Details

#### M1 - Honor the configured sudo decision in `src_install`

Origin: 6a288db / M1
Identity History: none
GitHub Issue: [#1](https://github.com/jeonghanlee/procServ-env/issues/1)
Status: Complete

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

- G1 completed on 2026-08-15; the recorded executable status In progress is restored.

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
| T2 | 2026-08-15T01:57:36-07:00 | Debian GNU/Linux 13 (trixie), Linux 6.12.74+deb13+1-cloud-amd64, x86_64, disposable libvirt guest `procserv-debian13-test` provisioned by `cloud-provision`, regular user `vmadmin` with `NOPASSWD` sudo | Pass | `./tests/test-install-privilege.bash --system` from the repository root exited 0; real procServ source commit `073f290012bd5c09666e066d3491c034f08c3bfe`; the shipped install path invoked `/usr/bin/sudo make -C procServ-src install` for the root-owned destination; installed `bin/procServ` observed; no leftover workspace under `/tmp` after the run |

##### Closure Evidence

- Deliverable carried by commit `43b4f56`; M1 / T1 passed 2026-08-14 and M1 / T2 passed 2026-08-15 on the real shipped install path.
- GitHub issue #1 was observed `CLOSED` at 2026-08-15T02:07:25-07:00; remote update 2026-08-15T09:07:19Z. Recheck with `gh issue view 1 --repo jeonghanlee/procServ-env --json state`.

##### GitHub Projection

Title: Avoid unconditional sudo invocation in src_install
Labels: `bug`
GitHub Milestone: none
Observed State: closed
Observed Labels: `bug`
Observed Milestone: none
Last Compared: 2026-08-15T02:07:25-07:00; remote update 2026-08-15T09:07:19Z
Projection Drift: The live issue body still omits the accepted Implementation Plan and the M1 / T1 and M1 / T2 results; a closing comment recording the fix commit and the verified destinations was added instead.

#### G1 - Provide a privileged disposable Linux test environment

Origin: 6a288db / G1
GitHub Issue: none
Status: Complete

##### Summary

The owner or operator must provide a disposable Linux environment with authorized non-interactive `sudo` so M1 / T2 and M3 / T3 can install to a protected temporary destination. The current container sets `NoNewPrivs: 1`, so `sudo` cannot elevate privilege and both milestones remain Blocked.

##### Completion Criteria

- `sudo -n true` succeeds as a regular user in the disposable test environment.
- The operator confirms that the host is disposable and permits root-owned temporary test directories below `/tmp`.
- The regular user can create a temporary workspace below `/tmp` without changing repository files.

##### Verification Results

| Observed At | Result | Evidence |
| --- | --- | --- |
| 2026-08-14T09:48:32-07:00 | Open | `tests/test-install-privilege.bash --system` exited 1 before T2; `sudo` reported that `no new privileges` prevents elevation; `/proc/self/status` reported `NoNewPrivs: 1` |
| 2026-08-14T17:30:11-07:00 | Open | `./tests/test-install-privilege.bash --system` exited 1 before creating a workspace or cloning source; `sudo` reported an invalid container ownership for `/etc/sudo.conf` and that `no new privileges` prevents elevation |
| 2026-08-15T01:56:29-07:00 | Complete | Disposable libvirt guest `procserv-debian13-test`, Debian GNU/Linux 13 (trixie), Linux 6.12.74+deb13+1-cloud-amd64, provisioned with `bin/create_vm.bash -o debian13 -p procserv` from `cloud-provision`; as regular user `vmadmin`, `sudo -n true` succeeded, `mktemp -d /tmp/g1check.XXXXXX` and `rmdir` succeeded, and `/proc/self/status` reported `NoNewPrivs: 0` |

##### Closure Evidence

- Owner decision in chat, 2026-08-15: a disposable `cloud-provision` guest is the sanctioned privileged test environment; the guest is discarded after use.
- All three completion criteria were observed in that guest on 2026-08-15.

#### M3 - Correct privilege detection for an absent install destination

Origin: 6a288db / M3
Identity History: none
GitHub Issue: none
Status: Complete

##### Summary

On Linux, base the privilege decision on `INSTALL_LOCATION` when it exists and otherwise on the nearest existing path, so an absent destination below a writable path selects an empty `SUDO` value.

##### Scope

Define and verify parent-directory resolution for existing and absent Linux installation destinations before evaluating writability.

Out of scope: the M1 `src_install` command selection, uninstall behavior, and Darwin privilege policy.

##### Completion Criteria

- An absent installation destination under a writable parent selects an empty `SUDO` value.
- An existing writable installation destination continues to select an empty `SUDO` value.
- A destination under a protected parent continues to select `sudo`.
- The real shipped configuration and install path verify all three cases without replacing the detection logic or Makefile path.

##### Dependencies And Decisions

- G1 completed on 2026-08-15; the recorded executable status was restored and the work then completed.
- Owner decision: assigned to the current Milestone, plan accepted, and implementation authorized in chat, 2026-08-14.
- Observation: A pre-T1 exploratory run on 2026-08-14 selected `/usr/bin/sudo` for an absent destination under a writable temporary workspace. Recheck with the shipped `print-SUDO_INFO` target and an absent destination below a writable parent.

##### Implementation Plan

Plan Status: accepted
Plan Acceptance: Owner approval in chat, 2026-08-14
Implementation Authorization: Owner approval in chat, 2026-08-14
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
| T1 | 2026-08-14T17:30:11-07:00 | Debian 13, Linux 6.12.100+deb13-amd64, x86_64 | Pass | `env MAKE=/bin/false MAKE_COMMAND=/bin/false MAKEFLAGS=-e GNUMAKEFLAGS=-e MFLAGS=-e MAKEFILES=/dev/null MAKEOVERRIDES=SUDO_CMD SUDO_CMD= SUDO=/bin/false ./tests/test-install-privilege.bash --local`; overrides cleared before Make execution; existing writable destination selected `SUDO_INFO=0` and empty `SUDO`; real procServ source commit `073f290012bd5c09666e066d3491c034f08c3bfe`; install completed without `sudo`; installed `bin/procServ` observed |
| T2 | 2026-08-14T17:30:11-07:00 | Debian 13, Linux 6.12.100+deb13-amd64, x86_64 | Pass | Same real-path command and source as T1; three absent destination components below a writable existing path selected `SUDO_INFO=0` and empty `SUDO`; the shipped configure, build, and install path created the destination without `sudo`; installed `bin/procServ` observed; successful workspace cleanup observed |
| T3 | 2026-08-15T01:57:36-07:00 | Debian GNU/Linux 13 (trixie), Linux 6.12.74+deb13+1-cloud-amd64, x86_64, disposable libvirt guest `procserv-debian13-test` provisioned by `cloud-provision`, regular user `vmadmin` with `NOPASSWD` sudo | Pass | `./tests/test-install-privilege.bash --system` from the repository root exited 0; real procServ source commit `073f290012bd5c09666e066d3491c034f08c3bfe`; the protected destination selected the expected privilege command and the shipped install path invoked `/usr/bin/sudo make -C procServ-src install`; installed `bin/procServ` observed; no leftover workspace under `/tmp` after the run |

##### Closure Evidence

- Third-person review accepted the implementation after its findings were corrected; the second-person pass found no remaining reader-facing issue, 2026-08-15.
- All three completion criteria are observed: M3 / T1 and M3 / T2 on 2026-08-14, M3 / T3 on 2026-08-15 after G1 completed.

## Backlog

Backlog rows are unassigned and excluded from the milestone tally.

### Work

| Group | ID | Work unit | Type | Status | Ready | Deps | Done when / Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Privilege handling | M2 | Assess sudo selection in uninstall recipes | Milestone | Open | No | | The owner resolves priority and scope from the audit evidence; [detail](#m2---assess-sudo-selection-in-uninstall-recipes) |

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
