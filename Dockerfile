FROM codekoala/arch

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

# remove repo from codekoala
RUN sed -i '/instarch/ d' /etc/pacman.conf

RUN pacman -Syy --noprogressbar --quiet && \
    pacman-db-upgrade && \
    pacman -S archlinux-keyring --noconfirm --noprogressbar --quiet && \
    pacman -Su --noconfirm --noprogressbar --quiet && \
    pacman-db-upgrade && \
    pacman -S --noconfirm --noprogressbar --quiet ghc cabal-install && \
    printf "y\\ny\\n" | pacman -Scc

# Create a separate user to run cabal as. Root access shouldn't typically be
# necessary. Specify the UID so that it is unique including from the host.
# Default GID is 100, on most systems equivalent to group users
ENV HOME /home/build
ENV UID 11235
ENV GID 100
RUN useradd --uid $UID --gid $GID --create-home --home-dir $HOME --comment "Build User" build

# Setup PATH to prioritize local .cabal/bin in ahead of system PATH.
# Additionally set the umask to 002 so that the group has write access inside and outside
# the container.
ADD entrypoint.sh $HOME/entrypoint.sh
RUN chmod +x $HOME/entrypoint.sh

RUN mkdir -p /data && chown -R $UID:$GID /data

WORKDIR /data

ENTRYPOINT ["/home/build/entrypoint.sh"]

USER build

RUN cabal update

CMD ["cabal", "install", "-j"]

