#!/bin/sh
# Keep regenerable build caches out of iCloud Drive.
#
# iCloud skips anything whose name ends in ".nosync". Each cache directory is
# moved to <name>.nosync and replaced by a symlink, so Quarto, knitr and the
# decks keep using the usual paths. Safe to re-run; run it once on each Mac.
#
#   sh _build/nosync.sh

set -eu
cd "$(dirname "$0")/.."

for dir in .output .quarto .stancache; do
  target="$dir.nosync"

  if [ -L "$dir" ]; then
    continue # already set up
  elif [ -d "$dir" ] && [ -e "$target" ]; then
    echo "skipping $dir: both $dir and $target exist; delete one and re-run" >&2
    continue
  elif [ -d "$dir" ]; then
    mv "$dir" "$target"
  else
    mkdir -p "$target"
  fi

  ln -s "$target" "$dir"
  echo "$dir -> $target"
done
