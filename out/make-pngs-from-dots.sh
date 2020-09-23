#!/bin/bash

FILES=${1:-*.dot}

process_file() {
  SRC="$1"
  OUT="$(basename $1 .dot)".png

  # version with no projects
  SRC_NP="$(basename $1 .dot)"_NP.dot
  OUT_NP="$(basename $1 .dot)"_NP.png

  SRC_TXT="$(basename $1 .dot)".txt
  OUT_TXT_NP="$(basename $1 .dot)"_NP.txt
  if [ -f "$OUT" ]; then
    echo "File exists, skipping: $OUT"
  else
   #dot -Tps -l lib.ps file.gv -o file.ps
    dot -Tpng "$SRC" -o "$OUT"
  fi
  cat "$SRC" | grep -v 'projects/' >"$SRC_NP"
  dot -Tpng "$SRC_NP" -o "$OUT_NP"

  cat "$SRC_TXT" | egrep -v '🍕' > "$OUT_TXT_NP"
}




for F in $FILES ; do
  #echo "file $F"
  process_file "$F"
done
