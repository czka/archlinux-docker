#!/usr/bin/env python3

# Copyright (c) 2016, Maciej Sieczka. All rights reserved.
#
# This program is free software under the GNU General Public License (>=v2).

import tarfile
import os


class Tarball:
    def __init__(self, infile, outfile):
        self.infile = infile
        self.outfile = outfile

    def drop_lead_comp(self):
        """Removes leading path component (top-level dir) from input tar file."""

        with tarfile.open(self.infile) as tarin, tarfile.open(self.outfile, 'w:gz') as tarout:

            # Identify common top-level dir for all tarball components, and proceed if it's set.
            lead_comp_name = os.path.commonpath(tarin.getnames())

            if lead_comp_name:
                prefix_len = len(lead_comp_name + '/')

                # Remove top-level dir (eg. "root.x86_64" or "root.i686" in Arch Linux bootstrap tarballs) from the
                # archive.
                tarin.members.remove(tarin.getmember(lead_comp_name))

                for m in tarin.members:
                    # Drop top-level dir prefix in all tarball component's paths.
                    m.path = m.path[prefix_len:]
                    # If component is a link, don't fetch its content. There's no point to that, and it helps avoiding
                    # KeyError("linkname 'something' not found") on "broken" symlinks, which are perfectly normal in a
                    # root FS tarball. And for hard links, the link target needs to be stripped of the prefix same as
                    # the file name.
                    if m.linkname:
                        if m.islnk():
                            m.linkname = m.linkname[prefix_len:]
                        tarout.addfile(m)
                    else:
                        tarout.addfile(m, tarin.extractfile(m))


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description="Remove leading path component from input tarball contents and save "
                                                 "the result in output tarball.", add_help=False)

    group = parser.add_argument_group("Arguments")
    group.add_argument("--help", action='store_true', help="Show this help message and exit.")
    args = parser.parse_known_args()

    group.add_argument("--input", metavar='PATH', dest='infile', type=str, help="Input tar[.gz/xz/bz2] file path.",
                       required=True)
    group.add_argument("--output", metavar='PATH', dest='outfile', type=str, help="Output tar.gz file path.",
                       required=True)

    if args[0].help:
        parser.exit(parser.print_help())
    else:
        args = parser.parse_args()

        tarball = Tarball(args.infile, args.outfile)
        tarball.drop_lead_comp()

# An error handling attempt I would like to remember. Note to self: it skips symlinks altogether.
#
# # Handle broken symlinks. They are perfectly normal in a root fs tarball, but tarfile module is not
# # prepared for that. Trying hard not to catch anything other than "linkname 'something' not found".
# try:
#     # Write each modified component to output tarball.
#     tarout.addfile(m, tarin.extractfile(m))
#
# except KeyError as error:
#     if "linkname '" and "' not found" in str(error):
#         print("Warning: the input tarball contains a dead symlink: '%s' to non-existent '%s'. No "
#               "biggy, but you might want to know. It will be included in the output tarball as it "
#               "is. Proceeding..." % (m.name, m.linkname), file=sys.stderr)
#     else:
#         raise

# And a compound list for all tar members:
#
# [m.path[prefix_len:] for m in tarin.members]
