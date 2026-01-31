#!/usr/bin/env sh
set -eux

while read -r repo version tarball bin; do
  [ -z "$repo" ] && continue

  curl -L "https://github.com/${repo}/releases/download/${version}/${tarball}" |
    tar -xz -C /tmp

  install -m 0755 "/tmp/${bin}" "/usr/bin/${bin}"
  rm -f "/tmp/${bin}"
done </usr/local/share/bins.list
