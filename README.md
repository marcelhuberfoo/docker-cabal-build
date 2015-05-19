# cabal-build
This is a base image for building [Haskell's][haskell] [Cabal][cabal]. (And 
pretty much the rest of the [Haskell Platform][haskell-platform].)

This image is based on suitupalex/cabal-build.

## Purpose
This docker image builds on top of Arch Linux's marcelhuberfoo/arch image for the
purpose of building projects using [Cabal][cabal].  It provides several key features:

* A non-root user (`build`) for executing the image build.  This is important
  for security purposes and to ensure that the package doesn't require root
  permissions to be built.
* Access to the build location will be in the volume located at `/data`.  This
  directory will be the default working directory.
* The [Cabal][cabal] bin directory is automatically included in `PATH` using the
  `/home/build/.cabal/bin` directory.

## Usage
This library is useful with simple `.cabal`s from the command line.
For example:

```bash
docker run --interactive --tty --rm --volume /tmp/my-data:/data marcelhuberfoo/cabal-build

# Using short-options:
docker run -i -t --rm -v /tmp/my-data:/data marcelhuberfoo/cabal-build
```

This will execute the default command (`cabal install -j`).

Other commands can also be executed.  For example, to update dependencies:

```bash
docker run -i -t --rm -v /tmp/my-data:/data marcelhuberfoo/cabal-build cabal update
```

## Permissions
This image uses a `build` user to run [Cabal][cabal]. This means that your file permissions
must allow this user to write to certain folders inside your project directory. The `build`
user has a `UID` of `11235` and a `GID` of `100` which is equal to the `users` group on most
Linux systems. You have to ensure that such a `UID:GID` combination is allowed to write to
your mapped volume. The easiest way is to add group write permissions for the mapped volume
and change the group id of the volume to 100.

```bash
# To give permissions to the entire project directory, do:
chmod -R g+w /tmp/my-data
chgrp -R 100 /tmp/my-data
```

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM marcelhuberfoo/cabal-build

USER root

RUN pacman --sync --noconfirm --noprogressbar --quiet somepackage

USER build
```

You can then build this docker image and run it against your `.cabal`
volume like normal (this example assumes the `.cabal` and `Dockerfile` are
in your current directory):

```bash
docker build --tag my-data .
docker run -i -t --rm -v "$(pwd):/data" my-data
docker run -i -t --rm -v "$(pwd):/data" my-data cabal update
```

[haskell]: https://haskell.org
[cabal]: https://haskell.org/haskellwiki/Cabal
[haskell-platform]: https://haskell.org/platform
[nubs]: https://registry.hub.docker.com/u/nubs/npm-build/
