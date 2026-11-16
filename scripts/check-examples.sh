#!/usr/bin/env bash
# Runs `gon check` on every example listed in expected.txt and compares the exit
# code and the per-code diagnostic counts. Usage: scripts/check-examples.sh [gon]
set -u
gon=${1:-gon}
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0
n=0
while IFS='|' read -r dir operands want_exit want_codes; do
  case "$dir" in ''|\#*) continue ;; esac
  dir=$(echo "$dir" | xargs); operands=$(echo "$operands" | xargs)
  want_exit=$(echo "$want_exit" | xargs); want_codes=$(echo "$want_codes" | xargs)

  out=$(cd "$root/$dir" && $gon check $operands 2>&1)
  got_exit=$?
  got_codes=$(printf '%s\n' "$out" | grep -o 'G[NW][0-9][0-9]*' | sort | uniq -c \
    | awk '{printf "%s%s=%s", (NR>1?" ":""), $2, $1}')
  n=$((n+1))
  if [ "$got_exit" != "$want_exit" ] || [ "$got_codes" != "$want_codes" ]; then
    echo "FAIL $dir ($operands)"
    echo "  want: exit $want_exit  [$want_codes]"
    echo "  got:  exit $got_exit  [$got_codes]"
    printf '%s\n' "$out" | sed 's/^/    | /'
    fail=1
  else
    echo "ok   $dir ($operands): exit $got_exit [$got_codes]"
  fi
done < "$root/expected.txt"

echo "$n examples checked"
exit $fail
