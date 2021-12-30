#!/bin/sh
set -eux

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) DIFF [SOFTWARE]"
    echo "Updates the software installation af SOFTWARE with the provided " \
         "diff DIFF"
    echo "SOFTWARE defaults to '/opt/software'"
    exit 1
fi

diff_file=$1
software=${2:-/opt/software}

temp_tar=$(mktemp -p /tmp patched.tar.XXXXXX)
temp_dir=$(mktemp -d -p /tmp software-new.XXXXXX)
/usr/local/bin/tar-patch "$diff_file" "$software" "$temp_tar"
tar xf "$temp_tar" -C "$temp_dir"
rsync --delete --update -rhlpgo --stats --progress "$temp_dir"/ \
    "$software"
rm -r "$temp_dir" "$temp_tar" "$diff_file"
