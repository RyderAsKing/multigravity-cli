#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

MG_VERSION="${MG_VERSION:-@MG_VERSION@}"

mg_main() {
  case ${1:-help} in
    version | help | -h | --help)
      mg_dispatch "$@"
      return
      ;;
  esac
  mg_config_init
  trap mg_cleanup EXIT
  mg_dispatch "$@"
}
