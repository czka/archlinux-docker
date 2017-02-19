FROM scratch
MAINTAINER Maciej Sieczka

# Set the $architecture ARG on your `docker build' command line with `--build-arg architecture=x86_64' or `i686'.
ARG architecture

ADD bootstrap.tar.gz /

RUN if [ "$architecture" != "x86_64" -a "$architecture" != "i686" ]; then \
    printf '\nYou need to specify the architecture with "--build-arg architecture=i686" on your\n\
    \r"docker build" command line. "x86_64" and "i686" are supported. Aborting build!\n\n'; exit 1; fi

RUN pacman-key --init \
    && pacman-key --populate archlinux \
    # Unfortunately this hack has to stay until Arch Linux bootstrap tarballs start including `sed' package, which is
    # required by `rankmirrors', which comes with `pacman' package, while that one doesn't depend on `sed'. (Note to
    # self: ask the Arch devs about this; `locale-gen' uses `sed' too).
    && pacman -U --noconfirm --noprogressbar --arch $architecture https://www.archlinux.org/packages/core/${architecture}/sed/download/ \
    && sed -i "s/^Architecture = auto$/Architecture = $architecture/" /etc/pacman.conf \
    && sed -n 's/^#Server = https/Server = https/p' /etc/pacman.d/mirrorlist > /tmp/mirrorlist \
    && rankmirrors -n 3 /tmp/mirrorlist | tee /etc/pacman.d/mirrorlist \
    && rm /tmp/mirrorlist \
    # `locale-gen' needs `gzip' (via `localedef', which works on /usr/share/i18n/charmaps/*.gz), `paccache' needs `awk'.
    && pacman -Syu --noconfirm --noprogressbar --quiet gzip awk \
    && paccache -r -k0 \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen \
    && echo 'LANG=en_US.UTF-8' > /etc/locale.conf

ENV LANG en_US.UTF-8

# As per https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/, the /etc/hostname,
# /etc/hosts and /etc/resolv.conf should be rather left alone.
