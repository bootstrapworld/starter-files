#! /usr/bin/env bash

backend_flag=""
if [[ "$1" == "-TS" ]]; then
  backend_flag="--backend ts"
fi

pyret_files_dir=$(pwd)
cd "$pyret_files_dir"

echo Checking Starter Files for compilation errors... ☠️
while IFS= read -r pyret_file; do
  echo "$pyret_file"
  if ! npx pyret $backend_flag --builtin-js-dir js-extras/ -c "$pyret_file" 2>&1 | grep -q 'Cleaning up'; then
    echo WARNING: Could not compile "$pyret_file"
  fi
done < <(find . -type f -name \*.arr | sed 's|^\./||')
