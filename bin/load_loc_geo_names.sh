#!/usr/bin/env zsh

# This gets the data from id.loc.gov and extracts the labels for the geographic terms.
# invoke with `JOBS=8` to use 8 parallel jobs.
#
set -euo pipefail
unsetopt BG_NICE

output="lib/gis_robot_suite/gazetteer.csv"
jq_filter="${0:A:h}/load_loc_geo_names.jq"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/load_loc_geo_names.XXXXXX")"
rows="${work_dir}/rows"
output_tmp="${work_dir}/gazetteer.csv"
jobs="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '4')}"
trap 'rm -r -- "$work_dir"' EXIT

if [[ "$jobs" != <-> ]] || (( jobs < 1 )); then
  printf 'JOBS must be a positive integer, got %s.\n' "$jobs" >&2
  exit 1
fi

: > "$rows"

extract_geographic_terms() {
  local prefix="$1"
  local collection="$2"

  jq \
    --arg prefix "$prefix" \
    --arg collection "$collection" \
    --stream \
    -nr \
    -f "$jq_filter"
}

dispatch_records() {
  ruby -e '
    begin
      outputs = ARGV.map { |path| File.open(path, "w") }
      STDIN.each_line.with_index do |line, index|
        outputs[index % outputs.length].write(line)
      end
    ensure
      outputs&.each(&:close)
    end
  ' "$@"
}

load_authority() {
  local authority="$1"
  local prefix="$2"
  local collection="$3"
  local archive="${authority}.madsrdf.jsonld.gz"
  local authority_dir="${work_dir}/${authority}"
  local dispatcher_status=0
  local worker_status=0
  local -a fifos worker_rows worker_pids

  if [[ ! -f "$archive" ]]; then
    printf 'Downloading %s...\n' "$archive" >&2
    curl \
      --location \
      --fail \
      --show-error \
      --retry 3 \
      --output "$archive" \
      "https://id.loc.gov/download/authorities/${archive}"
  else
    printf 'Using cached %s.\n' "$archive" >&2
  fi

  mkdir "$authority_dir"

  for ((worker = 1; worker <= jobs; worker++)); do
    local fifo="${authority_dir}/worker-${worker}.fifo"
    local worker_output="${authority_dir}/worker-${worker}.csv"

    mkfifo "$fifo"
    fifos+=("$fifo")
    worker_rows+=("$worker_output")
    extract_geographic_terms "$prefix" "$collection" < "$fifo" > "$worker_output" &
    worker_pids+=($!)
  done

  printf 'Extracting geographic terms from %s with %s workers...\n' \
    "$archive" "$jobs" >&2

  # Each line in the archive is a complete JSON document. Dispatching whole lines
  # keeps records intact while allowing jq to parse several documents at once.
  gzip --decompress --stdout "$archive" |
    dispatch_records "${fifos[@]}" || dispatcher_status=$?

  for pid in "${worker_pids[@]}"; do
    if ! wait "$pid"; then
      worker_status=1
    fi
  done

  if (( dispatcher_status != 0 || worker_status != 0 )); then
    printf 'Failed to extract geographic terms from %s.\n' "$archive" >&2
    return 1
  fi

  cat "${worker_rows[@]}" >> "$rows"
}

load_authority \
  "names" \
  "http://id.loc.gov/authorities/names/" \
  "http://id.loc.gov/authorities/names/collection_NamesAuthorizedHeadings"
load_authority \
  "subjects" \
  "http://id.loc.gov/authorities/subjects/" \
  "http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings"

printf 'Sorting combined geographic terms...\n' >&2
{
  printf '%s\n' '"l_kw","lc_id"'
  LC_ALL=C sort "$rows"
} > "$output_tmp"

mv "$output_tmp" "$output"
printf 'Wrote %s.\n' "$output" >&2
