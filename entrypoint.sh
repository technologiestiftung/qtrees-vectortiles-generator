#!/usr/bin/env bash
set -e
IFS=$'\n\t'

echo "system: Running $0"
echo "system: Creating tileset directory...$TILESET_DIR"
mkdir -p "$TILESET_DIR"
mkdir -p "$TMP_DIR"

echo "system: Removing old geojson files..."
rm -f "$TMP_DIR"/out.full.geojson || true

echo "ogr2ogr: Creating geojson file from sql query"
ogr2ogr \
  -f GeoJSON "$TMP_DIR"/out.full.geojson \
  "PG:host='$POSTGRES_HOST' \
  dbname='$POSTGRES_DB' \
  user='$POSTGRES_USER' \
  password='$POSTGRES_PASSWORD'" \
  -sql @"$WORK_DIR"/ogr2ogr.sql

echo "tippecanoe: Creating tileset..."
tippecanoe \
  -zg \
  -o "$TMP_DIR"/trees.mbtiles \
  --force \
  --drop-densest-as-needed \
  --extend-zooms-if-still-dropping \
  "$TMP_DIR"/out.full.geojson

echo "system: Copying tileset to tileset directory..."
cp "$TMP_DIR"/trees.mbtiles "$TILESET_DIR"

echo "mbtileserver: Starting tile server with args: $*"
mbtileserver "$@"
