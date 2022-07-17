FROM golang:1.18.4-bullseye


ARG TIPPICANOE_TAG=1.36.0
ARG MBTILESERVER_TAG=0.8.2
ARG GDAL_VERSION=3.2.2+dfsg-2+deb11u1
ARG TILESET_DIR=/tileset
ARG TMP_DIR=/tmp

ENV WORK_DIR /usr/app
ENV TILESET_DIR $TILESET_DIR
ENV TMP_DIR $TMP_DIR

RUN apt-get update && apt-get install -y \
  ca-certificates \
  openssl \
  curl \
  make \
  git \
  build-essential \
  libsqlite3-dev \
  zlib1g-dev \
  gdal-bin=${GDAL_VERSION} \
  bash \
  g++
RUN go install github.com/consbio/mbtileserver@v${MBTILESERVER_TAG}
WORKDIR ${WORK_DIR}
RUN git clone --depth 1 --branch ${TIPPICANOE_TAG} https://github.com/mapbox/tippecanoe.git && \
  cd tippecanoe && \
  make -j && \
  make install && \
  cd .. && \
  rm -rf tippecanoe
COPY ogr2ogr.sql ogr2ogr.sql
COPY entrypoint.sh entrypoint.sh
EXPOSE 8000
ENTRYPOINT [ "/usr/app/entrypoint.sh" ]
