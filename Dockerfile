FROM scratch
MAINTAINER Maciej Sieczka

# Set the $architecture ARG on your `docker build' command line with `--build-arg architecture=x86_64' or `i686'.
ARG architecture

ADD bootstrap.tar.gz /

RUN if [ "$architecture" != "x86_64" -a "$architecture" != "i686" ]; then \
    printf '\nYou need to specify the architecture with "--build-arg architecture=i686" on your\n\
    \r"docker build" command line. "x86_64" and "i686" are supported. Aborting build!\n\n'; exit 1; fi

RUN \
    # `haveged' is needed for `pacman-key --init` on a low-entropy environment, like a VM. Can't install it proper
    # before initializing the Pacman keyring though. Hack it in (luckily it depends only on glibc).
    curl -LsS https://www.archlinux.org/packages/extra/${architecture}/haveged/download/ | bsdtar -xf - \
    && haveged -w 1024 \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    # Another bit of a hack, until Arch Linux bootstrap tarballs start including `sed' package, which is required by
    # `rankmirrors', which comes with `pacman' package, while that one doesn't depend on `sed'. (Note to self: ask the
    # Arch devs about this; `locale-gen' uses `sed' too). Again, lucky it has very little deps.
    && pacman -U --noconfirm --noprogressbar --arch $architecture https://www.archlinux.org/packages/core/${architecture}/sed/download/ \
    && sed -i "s/^Architecture = auto$/Architecture = $architecture/" /etc/pacman.conf \
    && sed -n 's/^#Server = https/Server = https/p' /etc/pacman.d/mirrorlist > /tmp/mirrorlist \
    && rankmirrors -n 3 /tmp/mirrorlist | tee /etc/pacman.d/mirrorlist \
    && rm /tmp/mirrorlist \
    # Now we can register `haveged' proper (just to remove it proper later on).
    && pacman -Sy --noconfirm --noprogressbar --quiet --dbonly haveged \
    && pacman -S --noconfirm --noprogressbar --quiet haveged \
    # `locale-gen' needs `gzip' (via `localedef', which works on /usr/share/i18n/charmaps/*.gz), `paccache' needs `awk'.
    # Update the system BTW.
    && pacman -Su --noconfirm --noprogressbar --quiet gzip awk \
    # Uninstall `haveged' cleanly, together with whatever else is not needed anymore.
    && pacman -Rncss --noconfirm --noprogressbar haveged \
    # Remove the last leftovers of the initial dirty `haveged' install.
    && rm /.MTREE /.PKGINFO \
    && paccache -r -k0 \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen \
    && echo 'LANG=en_US.UTF-8' > /etc/locale.conf

ENV LANG en_US.UTF-8

# As per https://docs.docker.com/engine/userguide/networking/default_network/configure-dns/, the /etc/hostname,
# /etc/hosts and /etc/resolv.conf should be rather left alone.
