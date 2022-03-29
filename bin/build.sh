#!/bin/sh -eu

APP_NAME="$( grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g' )"
APP_VERSION="$( grep 'version:' mix.exs | cut -d '"' -f2 )"

mix phx.digest.clean --all

mix deps.get --only prod

export MIX_ENV=prod

mix compile
mix assets.deploy
mix release --overwrite

mix phx.digest.clean --all

PKG_NAME="$APP_NAME-$APP_VERSION.pkg"
PROJECT_DIR="$( pwd )"
BUILD_DIR="${PROJECT_DIR}/_build/prod/rel"
TEMPLATE_DIR="${PROJECT_DIR}/bin/pkg"
STAGE_DIR="$( mktemp -d -t "${APP_NAME}-${APP_VERSION}" )"
ARCHIVE_DIR="${PROJECT_DIR}/pkg/"

cp ${TEMPLATE_DIR}/stage/* "${STAGE_DIR}/"
cp "${TEMPLATE_DIR}/stage/+POST_INSTALL" "${STAGE_DIR}/+POST_INSTALL"
chmod +x ${STAGE_DIR}/+POST* || true
chmod +x ${STAGE_DIR}/+PRE* || true

mkdir -p "${STAGE_DIR}/usr/local/etc/rc.d"
cp ${TEMPLATE_DIR}/rc.d/* "${STAGE_DIR}/usr/local/etc/rc.d/"
chmod +x ${STAGE_DIR}/usr/local/etc/rc.d/*

mkdir -p "${STAGE_DIR}/${APP_NAME}/scripts/"
cp ${TEMPLATE_DIR}/scripts/*.sh "${STAGE_DIR}/${APP_NAME}/scripts/"
chmod +x ${STAGE_DIR}/${APP_NAME}/scripts/*

mkdir -p "${STAGE_DIR}/${APP_NAME}"
cp -a "${BUILD_DIR}/${APP_NAME}" "${STAGE_DIR}/"

cd "${STAGE_DIR}" || exit 1
find "${APP_NAME}" -type f -ls| awk '{print "/" $NF}' >> "${STAGE_DIR}/plist"
find "usr" -type f -ls| awk '{print "/" $NF}' >> "${STAGE_DIR}/plist"

cd "${PROJECT_DIR}" || exit 1
mkdir -p "${ARCHIVE_DIR}"

pkg create -m "${STAGE_DIR}/" -r "${STAGE_DIR}/" -p "${STAGE_DIR}/plist" -o "${ARCHIVE_DIR}" 

echo "Package created:"
echo "pkg/${PKG_NAME}"
