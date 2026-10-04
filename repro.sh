#!/usr/bin/env bash
# Shows that `roc check` on sub/Builtin.roc panics only while main.roc exists.
set -u
cd "$(dirname "$0")"
roc version

echo; echo "== with main.roc"
roc check sub/Builtin.roc

echo; echo "== without main.roc"
dir=$PWD
while [ "$dir" != / ]; do
	dir=$(dirname "$dir")
	if [ -f "$dir/main.roc" ]; then
		echo "warning: $dir/main.roc also exists above this repo and will trigger the panic"
	fi
done
mv main.roc main.roc.off
trap 'mv main.roc.off main.roc' EXIT
roc check sub/Builtin.roc
