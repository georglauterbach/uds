#! /bin/bash

killall -q polybar || :

while read -r MONITOR
do
  BAR='secondary'
  [[ ${MONITOR} == *primary* ]] && BAR='primary'

  MONITOR="$(cut -f 1 -d ':' <<< "${MONITOR}" || :)" polybar \
    --config="${HOME}/.config/polybar/polybar.conf" \
    --reload "${BAR}" &>/dev/null &
done < <(polybar --list-monitors || :)
