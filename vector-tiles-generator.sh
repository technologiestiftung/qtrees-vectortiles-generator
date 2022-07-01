#/bin/bash
source .env && export PGPASSWORD PGUSER PGHOST PGDATABASE && docker run -v $LOCALDIR:/home  osgeo/gdal:alpine-small-latest ogr2ogr -f GeoJSON /home/out.full.geojson "PG:host='$PGHOST' dbname='$PGDATABASE' user='$PGUSER' password='$PGPASSWORD'" -sql "SELECT * from api.trees;"
docker run -v $LOCALDIR:/home klokantech/tippecanoe tippecanoe -zg -o /home/trees.mbtiles --force --drop-densest-as-needed --extend-zooms-if-still-dropping /home/out.full.geojson
cp trees.mbtiles /var/lib/docker/volumes/mbtileserver_mbtileserver/_data/
docker restart mbtileserver
