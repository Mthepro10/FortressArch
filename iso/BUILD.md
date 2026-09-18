# Building the FortressArch ISO

This profile is a delta on top of Arch's official `releng` archiso profile.
We do not maintain our own profiledef.sh or pacman.conf — we reuse the
official ones and only add what FortressArch needs.

This is the full, current build flow, meant to be done in ONE pass.

## Requirements

Run this inside an Arch environment (VM), not on Windows or Ubuntu:

```
sudo pacman -S archiso git base-devel pacman-contrib
```

## Step 1: build our own packages on the host, before touching archiso

```
cd ~/FortressArch/fortress-guard
makepkg -s --noconfirm

cd ~/FortressArch/packaging/fortressarch-selfheal
makepkg -s --noconfirm
```

## Step 2: set up the profile

```
rm -rf ~/fortressarch-iso /tmp/archiso-work
cp -r /usr/share/archiso/configs/releng ~/fortressarch-iso
cd ~/fortressarch-iso
```

## Step 3: merge our packages list

```
cat ~/FortressArch/iso/packages-extra.txt >> packages.x86_64
```

## Step 4: merge our airootfs overlay

```
cp -r ~/FortressArch/iso/airootfs-overlay/* airootfs/
```

## Step 5: append our customization step

```
cat ~/FortressArch/iso/customize-fortress.sh >> airootfs/root/customize_airootfs.sh
```

## Step 6: add our own local package repo (fortress-guard + fortressarch-selfheal)

```
mkdir -p airootfs/root/local-repo
cp ~/FortressArch/fortress-guard/*.pkg.tar.zst airootfs/root/local-repo/
cp ~/FortressArch/packaging/fortressarch-selfheal/*.pkg.tar.zst airootfs/root/local-repo/
repo-add airootfs/root/local-repo/custom.db.tar.gz airootfs/root/local-repo/*.pkg.tar.zst
```

Edit `pacman.conf` (the one in this profile directory, not the system one):

```
nano pacman.conf
```

Add this near the top, before the `[core]` section:

```
[custom]
SigLevel = Optional TrustAll
Server = file:///root/local-repo
```

## Step 7: edit profiledef.sh

```
nano profiledef.sh
```

Add these lines inside the existing `file_permissions=(...)` array (do
not replace the array, add to it):

```
["/usr/local/bin/fortress-boot-attempt.sh"]="0:0:755"
["/usr/local/bin/fortress-boot-rollback.sh"]="0:0:755"
["/usr/local/bin/fortress-boot-success.sh"]="0:0:755"
["/usr/local/bin/fortress-health-check.sh"]="0:0:755"
["/usr/local/bin/fortress-ignore-edit.sh"]="0:0:755"
["/usr/local/bin/fortress-ignore-lock.sh"]="0:0:755"
["/usr/local/bin/fortress-snapshot.sh"]="0:0:755"
["/usr/local/bin/fortress-state-setup.sh"]="0:0:755"
["/usr/local/bin/fortress-survival-exit.sh"]="0:0:755"
["/usr/local/bin/fortress-survival-mode.sh"]="0:0:755"
["/usr/local/bin/fortress-notify-daemon.sh"]="0:0:755"
["/usr/local/bin/fortress-warning-dialog.py"]="0:0:755"
["/etc/sudoers.d/fortress-survival"]="0:0:440"
```

Also change `iso_name`, `iso_label`, and `iso_publisher` to FortressArch.

## Step 8: build

```
sudo mkarchiso -v -w /tmp/archiso-work -o ~/fortressarch-out .
```

The resulting ISO appears in ~/fortressarch-out.

## After booting the ISO: installing with archinstall

archinstall is included in the live environment. Boot the ISO, run
`archinstall`, go through the guided steps, and when it asks for
additional packages, type:

```
fortress-guard fortressarch-selfheal
```

archinstall's pacstrap step will pull both from our local repo (already
registered in this image's pacman.conf) and run their install hooks on
the real target automatically. This handles enabling services,
validating the sudoers file, enabling os-prober for dual boot, and
configuring snapper plus state isolation on the target disk — no manual
steps needed after install.

## Known gaps

- Not tested yet end to end. This is a first pass through the full
  archinstall-based flow, written without an Arch machine available to
  run it directly.
- Watch closely for whether pacstrap can actually reach a repo at
  `file:///root/local-repo` in the target chroot context; if not, the
  packages may need to be copied to a path reachable from both the live
  root and the pacstrap chroot instead.
