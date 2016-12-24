###About

This is Arch Linux Docker base image build setup that employs the bootstrap tarball distributed by distro authors.
 
It's meant to provide an easy to use solution for building Arch Linux Docker images on **non-Arch Linux hosts** (and as an unprivileged user if your Docker instance allows that, but please mind [there are good reasons](http://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/) [why it shouldn't](https://docs.docker.com/engine/security/security/#/docker-daemon-attack-surface)), which is not possible with the [currently recommended method](https://wiki.archlinux.org/index.php/Docker#Build_Image).


###Usage

- `git clone` this repository.

- `cd` to a directory where you have cloned it.

- Download an <code>archlinux-bootstrap-<i>date-architecture</i>.tar.gz</code> archive there, preferably the newest one (or expect a longer `pacman -Syu` run at `docker build`, and, if your tarball is relatively old, some incompatibilities to manifest; Arch changes fast). From my experience, https://archive.archlinux.org/iso/ is a very fast mirror, but you may want to choose your preferred one on https://www.archlinux.org/download/.

- Run <code>./tar_fix.py --input=archlinux-bootstrap-<i>date-architecture</i>.tar.gz --output=bootstrap.tar.gz</code>. This will remove input tarball's top-level directory from all its component paths, and save that in the output tarball. As a result its content starts at `/` rather than `x86_64/` or `i686/`, and so will the filesystem of the Docker image. `tar_fix.py` needs Python 3.5. It will fail with Python 2, and even with 3.4, like in [issue #1](https://github.com/czka/archlinux-docker/issues/1).

- Make sure you have my `Dockerfile`, `.dockerignore` and the `bootstrap.tar.gz` in one directory.

- Build the image with a command like `docker build --build-arg architecture=x86_64 --tag archlinux-x86_64-base .`. **Mind the dot!** Use `--build-arg architecture=i686` if you are building from an i686 `bootstrap.tar.gz`.

###See also

Discussion: https://bbs.archlinux.org/viewtopic.php?pid=1667108#p1667108.
