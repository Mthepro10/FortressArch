# FortressArch — Roadmap

## Viziune
Un Arch prietenos, cu straturi de auto-reparare inspirate din felul in care
un organism isi repara tesuturile: snapshot-uri automate, verificare
continua a sanatatii sistemului, rollback de urgenta, protectie proactiva
(nu antivirus clasic), notificari discrete cu escaladare doar cand e
necesar.

## De ce acum, pe Arch
Sisteme imutabile cu auto-rollback exista deja (openSUSE MicroOS, Fedora
Silverblue), dar nu pe Arch — unde update-urile rolling-release chiar rup
sisteme des. Combinatia "Arch + self-healing prietenos din instalare" nu
exista intr-o forma populara.

## Module (in ordinea de constructie, nu de prioritate egala)

### 1. Snapshot + auto-rollback la boot esuat  [ACTIV ACUM]
- Snapshot automat (btrfs/snapper) inainte de update-uri riscante
  (kernel, drivere).
- Contor de boot-uri esuate; dupa 2 esecuri consecutive, rollback automat
  la ultimul snapshot bun + reboot.
- Prerechizit: sistem instalat pe btrfs, snapper configurat.

### 2. Daemon de sanatate
- Ruleaza periodic (systemd timer).
- Verifica: servicii systemd picate, pachete orfane, mismatch
  kernel/DKMS, baza de date pacman corupta, symlink-uri rupte.
- Repara automat DOAR cazuri cunoscute si sigure. Restul -> notificare,
  nu actiune oarba.

### 3. Sandbox proactiv
- Extinde fortress-guard (bubblewrap) existent.
- Izoleaza executii nesigure/necunoscute inainte sa produca daune, nu
  scanare de semnaturi dupa fapt.
- Comutabil global (acelasi flag de sistem ca restul).

### 4. Notificari / UI
- Discret implicit (iconita, log).
- Escaladare la ecran blocant DOAR cand actiunea automata ar putea
  pierde date recente (ex: rollback peste modificari din ultimele ore).
  Userul confirma in <5 min, altfel sistemul alege varianta sigura.

## Flag global
Un singur comutator de sistem controleaza nivelul de protectie
(dezactivabil complet, ca un antivirus, dar nativ, nu proces separat).

## Constrangeri de dezvoltare cunoscute
- Fara masina Arch dedicata de build/test (dual-boot cu doar ~2GB liberi).
- Testare in Docker (imagine archlinux) + eventual VM pentru teste
  end-to-end. Partitia reala de Arch se foloseste doar pentru validare
  finala, dupa testare izolata.
