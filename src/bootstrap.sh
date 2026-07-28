#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

MG_VERSION="${MG_VERSION:-@MG_VERSION@}"
MG_BUILD_COMMIT="${MG_BUILD_COMMIT:-@MG_COMMIT@}"
MG_REPOSITORY="RyderAsKing/multigravity-cli"
MG_RELEASE_WORKFLOW="release.yml"
MG_ARCHIVE_FORMAT=1
MG_MAX_ARCHIVE_BYTES=$((512 * 1024 * 1024))
MG_MAX_EXTRACTED_BYTES=$((2 * 1024 * 1024 * 1024))
MG_MAX_ARCHIVE_ENTRIES=10000

mg_main() {
  case ${1:-help} in
    version | help | -h | --help | completion)
      mg_dispatch "$@"
      return
      ;;
  esac
  mg_config_init
  trap mg_cleanup EXIT
  mg_dispatch "$@"
}
