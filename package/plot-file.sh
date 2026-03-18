#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: $0 FILE [FILE...]" >&2
  exit 1
fi

escape_for_gnuplot() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

if [ "$#" -eq 1 ]; then
  title="$(basename "$1")"
else
  title="$(basename "$1") + $(( $# - 1 )) more"
fi

esc_title="$(escape_for_gnuplot "$title")"
plot_cmd=""

for file in "$@"; do
  esc_file="$(escape_for_gnuplot "$file")"
  label="$(escape_for_gnuplot "$(basename "$file")")"

  if [ -n "$plot_cmd" ]; then
    plot_cmd+=", "
  fi

  plot_cmd+="\"$esc_file\" with lines title \"$label\""
done

exec gnuplot -persist <<EOF
set title "$esc_title"
plot $plot_cmd
EOF
