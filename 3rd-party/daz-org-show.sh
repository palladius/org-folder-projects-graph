#!/usr/bin/env bash

: "${ORGANIZATION:?Need to export ORGANIZATION and it must be non-empty}"

# gcloud format
FORMAT="csv[no-heading](name,displayName.encode(base64))"

# Enumerates Folders recursively
folders()
{
  LINES=("$@")
  for LINE in ${LINES[@]}
  do
    # Parses lines of the form folder,name
    VALUES=(${LINE//,/ })
    FOLDER=${VALUES[0]}
    # Decodes the encoded name
    NAME=$(echo ${VALUES[1]} | base64 --decode)
    echo "Folder: ${FOLDER} (${NAME})"
    folders $(gcloud resource-manager folders list \
      --folder=${FOLDER} \
      --format="${FORMAT}")
  done
}

# Start at the Org
echo "Org: ${ORGANIZATION}"
LINES=$(gcloud resource-manager folders list \
  --organization=${ORGANIZATION} \
  --format="${FORMAT}")

# Descend
folders ${LINES[0]}
