# Building the FortressArch ISO

This profile is a delta on top of Arch's official `releng` archiso profile.
We do not maintain our own profiledef.sh or pacman.conf — we reuse the
official ones and only add what FortressArch needs.

## Requirements

Run this inside an Arch environment (VM), not on Windows or Ubuntu:

```
sudo pacman -S archiso git
```

## Steps

1. Copy the official releng profile to a working directory:

```
cp -r /usr/share/archiso/configs/releng ~/fortressarch-iso
cd ~/fortressarch-iso
```

2. Merge our extra packages into packages.x86_64:

```
cat ~/FortressArch/iso/packages-extra.txt >> packages.x86_64
```

3. Merge our airootfs overlay into the profile's airootfs:

```
cp -r ~/FortressArch/iso/airootfs-overlay/* airootfs/
```

4. Append our customization step to the end of airootfs/root/customize_airootfs.sh:

```
cat ~/FortressArch/iso/customize-fortress.sh >> airootfs/root/customize_airootfs.sh
```

5. Edit profiledef.sh: add the following entries inside the existing
   file_permissions=(...) array (do not replace the array, add to it):

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

6. Also edit profiledef.sh: change `iso_name`, `iso_label`, and
   `iso_publisher` to FortressArch instead of Arch Linux.

7. Build the ISO:

```
mkarchiso -v -w /tmp/archiso-work -o ~/fortressarch-out .
```

The resulting ISO appears in ~/fortressarch-out.

## Known gaps for this stage

- snapper is installed but not configured with `snapper -c root create-config /`
  inside the ISO, because there is no real target root filesystem yet at
  build time. This has to happen after the live installer creates the real
  partitions — this is exactly what Calamares needs to do in the next
  project phase, not something archiso itself can do.
- No graphical installer yet. Booting this ISO currently drops into a live
  shell, not a friendly installer. That is the next module (Calamares).
- Not tested yet. This is a first pass, written without an Arch machine
  available to actually run mkarchiso.
