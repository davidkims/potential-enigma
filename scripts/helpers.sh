#!/usr/bin/env bash
retry() {
  local max="$1"; shift; local sleep_s="$1"; shift
  local n=0;
  until "$@"; do
    n=$((n+1)); [ "$n" -ge "$max" ] && { echo "[RETRY] give up: $*"; return 1; }
    echo "[RETRY] $n/$max failed: $* — sleep ${sleep_s}s"; sleep "$sleep_s";
  done
}
