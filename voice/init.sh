#!/bin/bash

set -eu

JANUS_TEMPLATE_DIR="${JANUS_TEMPLATE_DIR:-/opt/janus/etc/janus}"
JANUS_CONFIG_DIR="${JANUS_CONFIG_DIR:-/janus-config}"

JANUS_SERVER_NAME="${JANUS_SERVER_NAME:-GridVoice}"
JANUS_HTTP_ENABLE="${JANUS_HTTP_ENABLE:-true}"
JANUS_HTTP_PORT="${JANUS_HTTP_PORT:-14223}"
JANUS_HTTP_BASEPATH="${JANUS_HTTP_BASEPATH:-/voice}"
JANUS_HTTPS_ENABLE="${JANUS_HTTPS_ENABLE:-false}"
JANUS_HTTPS_PORT="${JANUS_HTTPS_PORT:-14224}"
JANUS_HTTP_ADMIN_ENABLE="${JANUS_HTTP_ADMIN_ENABLE:-true}"
JANUS_HTTP_ADMIN_PORT="${JANUS_HTTP_ADMIN_PORT:-14225}"
JANUS_HTTP_ADMIN_BASEPATH="${JANUS_HTTP_ADMIN_BASEPATH:-/voiceAdmin}"
JANUS_API_TOKEN="${JANUS_API_TOKEN:-change-me-api-token}"
JANUS_ADMIN_TOKEN="${JANUS_ADMIN_TOKEN:-change-me-admin-token}"

mkdir -p "${JANUS_CONFIG_DIR}"
cp -a "${JANUS_TEMPLATE_DIR}/." "${JANUS_CONFIG_DIR}/"

# Mirror the upstream os-webrtc-janus-docker substitutions for API/admin endpoints.
sed --in-place \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*api_secret[[:space:]]*=.*|api_secret = \"${JANUS_API_TOKEN}\"|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*admin_secret[[:space:]]*=.*|admin_secret = \"${JANUS_ADMIN_TOKEN}\"|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*server_name[[:space:]]*=.*|server_name = \"${JANUS_SERVER_NAME}\"|" \
    "${JANUS_CONFIG_DIR}/janus.jcfg"

sed --in-place \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*http[[:space:]]*=.*|http = ${JANUS_HTTP_ENABLE}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*port[[:space:]]*=.*|port = ${JANUS_HTTP_PORT}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*base_path[[:space:]]*=.*|base_path = \"${JANUS_HTTP_BASEPATH}\"|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*https[[:space:]]*=.*|https = ${JANUS_HTTPS_ENABLE}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*http_port[[:space:]]*=.*|http_port = ${JANUS_HTTPS_PORT}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*admin_http[[:space:]]*=.*|admin_http = ${JANUS_HTTP_ADMIN_ENABLE}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*admin_port[[:space:]]*=.*|admin_port = ${JANUS_HTTP_ADMIN_PORT}|" \
    -e "s|^[[:space:]]*[#;]*[[:space:]]*admin_base_path[[:space:]]*=.*|admin_base_path = \"${JANUS_HTTP_ADMIN_BASEPATH}\"|" \
    "${JANUS_CONFIG_DIR}/janus.transport.http.jcfg"

# Emit effective settings for remote troubleshooting.
grep -E '^[[:space:]]*(api_secret|admin_secret|server_name)[[:space:]]*=' "${JANUS_CONFIG_DIR}/janus.jcfg" || true
grep -E '^[[:space:]]*(http|port|base_path|https|http_port|admin_http|admin_port|admin_base_path)[[:space:]]*=' "${JANUS_CONFIG_DIR}/janus.transport.http.jcfg" || true

printf '[janus-init] Janus config generated in %s\n' "${JANUS_CONFIG_DIR}"