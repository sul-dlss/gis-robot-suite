#!/usr/bin/env zsh

# This gets Natural Earth's 1:10m land, minor islands, lakes, and country and state/province border
# lines, and saves just their geometry as FlatGeoBuf for the basemap under vector thumbnails
# (GisRobotSuite::NaturalEarthBasemap).
#
set -euo pipefail

output_dir="${0:A:h:h}/config/natural_earth"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/load_natural_earth.XXXXXX")"
trap 'rm -r -- "$work_dir"' EXIT

# Natural Earth's name for each layer, and ours
typeset -A layers=(
  physical/ne_10m_land land
  physical/ne_10m_minor_islands minor_islands
  physical/ne_10m_lakes lakes
  cultural/ne_10m_admin_0_boundary_lines_land countries
  cultural/ne_10m_admin_1_states_provinces_lines states
)

mkdir -p "$output_dir"
for source name in "${(@kv)layers}"; do
  layer="${source:t}"
  curl --fail --silent --show-error --location --output "${work_dir}/${layer}.zip" "https://naciscdn.org/naturalearth/10m/${source}.zip"
  printf '%s: Natural Earth %s\n' "$name" "$(unzip -p "${work_dir}/${layer}.zip" "${layer}.VERSION.txt")"
  ogr2ogr -f FlatGeobuf -overwrite -nln "$name" -nlt PROMOTE_TO_MULTI -dialect SQLITE \
    -sql "SELECT GEOMETRY FROM \"${layer}\" WHERE GEOMETRY IS NOT NULL" \
    "${output_dir}/${name}.fgb" "/vsizip/${work_dir}/${layer}.zip/${layer}.shp"
done
