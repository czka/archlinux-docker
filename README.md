###About

This is Arch Linux Docker base image build setup that employs the bootstrap tarball distributed by distro authors.
 
It's meant to provide an easy to use solution for building Arch Linux Docker images on **non-Arch Linux hosts**, as an **unprivileged user** (if your Docker instance allows that), which is not possible with the [currently recommended method](https://wiki.archlinux.org/index.php/Docker#Build_Image).


###Usage

- Download an <code>archlinux-bootstrap-<i>date-architecture</i>.tar.gz</code> archive, preferably the newest one (or expect a longer `pacman -Syu` run at `docker build`). From my experience, https://archive.archlinux.org/iso/ is a very fast mirror, but you may want to choose your preferred one on https://www.archlinux.org/download/.

- Run <code>tar_fix.py --input=archlinux-bootstrap-<i>date-architecture</i>.tar.gz --output=bootstrap.tar.gz</code>. This will remove input tarball's top-level directory from all its component paths, and save that in the output tarball. As a result its content starts at `/` rather than `x86_64/` or `i686/`, and so will the filesystem of the Docker image.

- Place this `Dockerfile`, its `.dockerignore` and the `bootstrap.tar.gz` in one directory.

- `cd` to that directory and build the image with a command like `docker build --build-arg architecture=x86_64 --tag archlinux-x86_64-base .`. Mind the dot! Use `--build-arg architecture=i686` if you are building from an i686 `bootstrap.tar.gz`.

###See also

Discussion: https://bbs.archlinux.org/viewtopic.php?pid=1667108#p1667108.
