# FortressArch Roadmap

## Vision

A friendly Arch Linux experience with layers of self-healing inspired by
how an organism repairs itself: automatic snapshots, continuous health
checks, emergency rollback, proactive protection (not a classic
antivirus), and discreet notifications that escalate only when needed.

## Why Arch, why now

Immutable systems with auto-rollback already exist (openSUSE MicroOS,
Fedora Silverblue), but not on Arch, where rolling-release updates break
systems more often. The combination of "Arch plus friendly self-healing
out of the box" does not exist in a popular form yet.

## Modules

### 1. Snapshot and auto-rollback on boot failure

Status: scripts drafted, untested on real hardware.

- Automatic snapshot (btrfs/snapper) before risky updates (kernel,
  drivers).
- Failed boot counter; after 2 consecutive failures, automatic rollback
  to the last good snapshot and reboot.
- Requires a btrfs root filesystem with snapper configured.

### 2. Health monitoring daemon

Status: first script drafted.

- Runs periodically via a systemd timer.
- Checks: failed systemd units, orphan packages, broken symlinks.
- Restarts failed units once. Does not remove packages automatically.
  Everything else is only logged, not acted on blindly.

### 3. Proactive sandboxing

Status: initial CLI wrapper drafted (fortress-guard).

- Extends the existing fortress-guard tool.
- Isolates unsafe or unknown command execution before it can cause
  damage, instead of scanning for known signatures afterwards.
- No separate mode toggle. If the command runs under sudo, it is
  trusted and runs directly. If not, and it matches a known dangerous
  pattern, it runs sandboxed instead.

### 4. Notifications and UI

Status: not started.

- Discreet by default (icon, log).
- Escalates to a blocking screen only when an automatic action could
  lose recent data (for example, rolling back over changes made in the
  last few hours). The user confirms within 5 minutes, otherwise the
  system picks the safe option automatically.

## Known development constraints

No dedicated Arch machine for build and test (dual boot with about 2GB
free). Testing happens in Docker with an Arch image, and eventually a
VM for end to end testing. The real Arch partition is only used for a
final manual validation, after isolated testing passes.
