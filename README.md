# cabal-build [![](https://badge.imagelayers.io/marcelhuberfoo/cabal-build.svg)](https://imagelayers.io/?images=marcelhuberfoo/cabal-build 'Get your own badge on imagelayers.io')

This is a base image for building packages with [Haskell's][haskell] [Cabal][cabal]. (And 
pretty much the rest of the [Haskell Platform][haskell-platform].)

This Dockerfile is based on [suitupalex/cabal-build][suitupalex].

## Purpose

This docker image builds on top of my minimal Arch Linux [marcelhuberfoo/arch][dockerarch] image for the
purpose of building projects using [Cabal][cabal].  It provides several features of which some are already present in the base image:

* A non-root user and group `docky` for executing programs inside the container.
* A umask of 0002 for user `docky`.
* Exported variables `UNAME`, `GNAME`, `UID` and `GID` to make use of the user settings from within scripts.
* Timezone (`/etc/localtime`) is linked to `Europe/Zurich`, adjust if required in a derived image.
* An external build source folder can be mapped to the volume `/data`. This volume will be the default working directory.
* The [Cabal][cabal] bin directory (`/home/docky/.cabal/bin`) is automatically prepended to the `PATH` variable.

## Usage

This library is useful with simple `.cabal`s from the command line.
For example:

```bash
docker run --interactive --tty --rm --volume /tmp/my-data:/data marcelhuberfoo/cabal-build
```

This will execute the default command `cabal install -j`.

Other commands can also be executed.  For example, to update dependencies:

```bash
docker run -i -t --rm -v /tmp/my-data:/data marcelhuberfoo/cabal-build cabal update
```

## Permissions

This image provides a user and group `docky` to run `cabal` as user `docky`.

If you map in the `/data` volume, permissions on the host folder must allow user or group `docky` to write to it. I recommend adding at least a group `docky` with GID of `654321` to your host system and change the group of the folder to `docky`. Don't forget to add yourself to the `docky` group.
The user `docky` has a `UID` of `654321` and a `GID` of `654321` which should not interfere with existing ids on regular Linux systems.

Add user and group docky, group might be sufficient:
```bash
groupadd -g 654321 docky
useradd --system --uid 654321 --gid docky --shell '/sbin/nologin' docky
```

Add yourself to the docky group:
```bash
gpasswd --add myself docky
```

Set group permissions to the entire project directory:
```bash
chmod -R g+w /tmp/my-data
chgrp -R docky /tmp/my-data
```

### Dockerfile build

Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM marcelhuberfoo/cabal-build
MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>
USER root
RUN pacman --sync --noconfirm --noprogressbar --quiet somepackage
```

[haskell]: https://haskell.org
[cabal]: https://haskell.org/haskellwiki/Cabal
[haskell-platform]: https://haskell.org/platform
[suitupalex]: https://registry.hub.docker.com/u/suitupalex/cabal-build/
[dockerarch]: https://registry.hub.docker.com/u/marcelhuberfoo/arch/
