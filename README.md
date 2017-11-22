# eReuse.org Workbench Live
A Debian 9 live ISO that auto-executes eReuse.org Workbench when
booting communicating with an eReuse.org Workbench Server.

## Usage
### Requirements
We use [debian-live](http://debian-live.alioth.debian.org) to build the ISO. So 
[install it](http://debian-live.alioth.debian.org/live-manual/stable/manual/html/live-manual.en.html#108).
In Debian 9 is just `apt install live-build`.

### Build an ISO
Execute (from [here](http://debian-live.alioth.debian.org/live-manual/stable/manual/html/live-manual.en.html#344)): 
```bash
    git clone https://github.com/eReuse/workbench-live.git
    cd workbench-live
    # Obtain last eReuse.org Workbench
    git submodule-init
    git submodule-update
    # Workbench has submodules too, so we get them
    cd config/includes.chroot/opt/workbench
    git submodule-init
    git submodule-update
    # Build
    # Note you can pass parameters to lb config to alter the ISO
    cd ../../../
    sudo lb build
```

### Speed up building
From [the guide](http://debian-live.alioth.debian.org/live-manual/stable/manual/html/live-manual.en.html#826):
"You can speed up downloads considerably if you use a local mirror. [...] 
Set the default for your build system in `/etc/live/build.conf`. 
Simply create this file and in it, set the corresponding `LB_MIRROR_*` variables to your preferred mirror. 
All other mirrors used in the build will be defaulted from these values." For example:

```bash
LB_MIRROR_BOOTSTRAP="http://ftp.caliu.cat/debian/" 
LB_MIRROR_CHROOT_SECURITY="http://security.debian.org/" 
LB_MIRROR_CHROOT_BACKPORTS="http://ftp.caliu.cat/debian/"
```

You can execute a package like `netselect-apt` to know which mirror is the fastest for you.

## Modify the contents
Read 
[the debian-live manual](http://debian-live.alioth.debian.org/live-manual/unstable/manual/html/live-manual.en.html)
as we followed it to build this. Note that at the time of this writing we had to use the *unstable* version of the manual,
as this is the one targeting Debian 9.

### Overview
The structure is as follows:
- `auto/config`: Generic build options like architecture.
- `config/bootloaders/isolinux`: Bootloader params. We changed `isolinux.cfg`timing and `splash.svg`.
- `config/includes.chroot/opt/workbench`: Skeleton where Workbench files will be placed into
  the final ISO (at path `/opt/workbench`).
- `config/hooks/live/0100-workbench.hook.chroot`: A 
  [chroot hook](http://debian-live.alioth.debian.org/live-manual/unstable/manual/html/live-manual.en.html#520)
  that installs Workbench from the files above.
- `config/includes.chroot/home/user`: The home dir of the user the live uses. We add `.bash_history`, `.erwb-help` and
  `.profile` to auto-execute the Workbench after performing login and provide some user feedback.

### Commit
Before committing, ensure you execute `sudo lb clean` just a cautious measure.


### Problem resolution
- If you cancel the `lb build` you won't be able to delete some `chroot` stuff because they are mounted. Just reboot
  and try with `sudo`.
- If you perform changes, try to use `lb clean --purge` to ensure a deep cleaning.