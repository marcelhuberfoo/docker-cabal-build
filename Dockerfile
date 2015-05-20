FROM marcelhuberfoo/arch

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

RUN pacman -Syy --noconfirm reflector
RUN reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Syyu --noconfirm && \
    pacman-db-upgrade && \
    pacman -S --noconfirm ghc cabal-install && \
    printf "y\\ny\\n" | pacman -Scc

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p -m 0775 /data /caballogs && chown -R $UID:$GID /data /caballogs
RUN gosu $UNAME bash -c 'mkdir -p -m 0775 $HOME/.cabal && ln -s /caballogs $HOME/.cabal/logs'

VOLUME ["/data", "/caballogs"]
WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]

RUN gosu $UNAME bash -c 'cabal update'

CMD ["cabal", "install", "-j"]

