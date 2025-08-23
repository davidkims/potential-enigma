#!/usr/bin/env bash
set -Eeuo pipefail
BASE_PATH="${BASE_PATH:-.github/echo_enigma}"
TOTAL_DIRS="${TOTAL_DIRS:-500}"
DEPTH="${DEPTH:-3}"
FANOUT="${FANOUT:-5}"
FILES_PER_DIR="${FILES_PER_DIR:-1}"
REPORT_DIR="${REPORT_DIR:-site/reports}"
LOG_DIR="${LOG_DIR:-.github/echo_enigma/logs}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
echo "[ECHO] BASE_PATH=$BASE_PATH TOTAL_DIRS=$TOTAL_DIRS DEPTH=$DEPTH FANOUT=$FANOUT FILES_PER_DIR=$FILES_PER_DIR"
mkdir -p "$BASE_PATH" "$REPORT_DIR" "$LOG_DIR"
REPORT_CSV="$REPORT_DIR/dir_report_$TS.csv"
TREE_LOG="$LOG_DIR/tree_$TS.log"
echo "seq,rel_path,created_files" > "$REPORT_CSV"
make_path_by_index () {
  local idx="$1" depth="$2" fanout="$3"; local path=""; local rem="$idx"
  for ((level=1; level<=depth; level++)); do
    local d=$(( rem % fanout )); rem=$(( rem / fanout ))
    path="${path}/l${level}_$(printf "%03d" "$d")"
  done
  printf "%s" "$path"
}
created=0
for ((i=0; i<TOTAL_DIRS; i++)); do
  rel="$(make_path_by_index "$i" "$DEPTH" "$FANOUT")/n$(printf "%05d" "$i")"
  dir="$BASE_PATH$rel"; mkdir -p "$dir"; cnt=0
  for ((f=1; f<=FILES_PER_DIR; f++)); do
    echo "# keep: $TS $i $f" > "$dir/.keep.$f"; cnt=$((cnt+1))
  done
  if [ ! -f "$dir/README.md" ]; then
    printf "%s\n" "# Enigma Node $(printf "%05d" "$i")" > "$dir/README.md"
    printf "%s\n" "- Timestamp: $TS" >> "$dir/README.md"
    printf "%s\n" "- Depth: $DEPTH / Fanout: $FANOUT" >> "$dir/README.md"
    printf "%s\n" "- Auto-generated" >> "$dir/README.md"
    cnt=$((cnt+1))
  fi
  echo "$i,$rel,$cnt" >> "$REPORT_CSV"
  created=$((created+1))
done
echo "[ECHO] Created dirs: $created"
tree -a -L "$DEPTH" "$BASE_PATH" > "$TREE_LOG" || true
echo "[OK] report: $REPORT_CSV"
echo "[OK] tree:   $TREE_LOG"
