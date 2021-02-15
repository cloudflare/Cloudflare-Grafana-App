#!/bin/sh

set -eu

version="$(jq -r '.info.version' 'dist/plugin.json')"

if test -f "cloudflare-grafana-app-${version}.zip"
then
	printf >&2 'File already exists: %s\n' "cloudflare-grafana-app-${version}.zip"
	exit 1
fi

if [ -z ${GRAFANA_API_KEY+x} ]
then
	echo >&2 'GRAFANA_API_KEY must be set.'
fi

PATH="$PATH:node_modules/.bin" make

npx @grafana/toolkit plugin:sign

tmp="$(mktemp -d)"

cp -r -- dist "${tmp}/cloudflare-app"

(
	cd -- "$tmp"
	zip -qr "cloudflare-grafana-app-${version}.zip" -- 'cloudflare-app'
)

mv -- "$tmp/cloudflare-grafana-app-${version}.zip" .
