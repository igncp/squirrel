#!/usr/bin/env bash

set -e

rime_version=latest
rime_git_hash=$(curl -s https://api.github.com/repos/rime/librime/git/refs/tags/${rime_version} | jq -r '.object.sha[0:7]')
sparkle_version=2.6.2

# TODO: Use the ones from the submodule, similar to the dynamic libraries
rime_deps_archive="rime-deps-${rime_git_hash}-macOS-universal.tar.bz2"
rime_deps_download_url="https://github.com/rime/librime/releases/download/${rime_version}/${rime_deps_archive}"

sparkle_archive="Sparkle-${sparkle_version}.tar.xz"
sparkle_download_url="https://github.com/sparkle-project/Sparkle/releases/download/${sparkle_version}/${sparkle_archive}"

mkdir -p download && (
  cd download
  [ -z "${no_download}" ] && curl -LO "${rime_deps_download_url}"
  tar --bzip2 -xf "${rime_deps_archive}"
  [ -z "${no_download}" ] && curl -LO "${sparkle_download_url}"
  tar -xJf "${sparkle_archive}"
)

mkdir -p librime/share
mkdir -p Frameworks
cp -R download/share/opencc librime/share/
cp -R download/Sparkle.framework Frameworks/

# skip building librime and opencc-data; use downloaded artifacts
make copy-rime-binaries copy-opencc-data

echo "SQUIRREL_BUNDLED_RECIPES=${SQUIRREL_BUNDLED_RECIPES}"

git submodule update --init plum
# install Rime recipes
rime_dir=plum/output bash plum/rime-install ${SQUIRREL_BUNDLED_RECIPES}
make copy-plum-data
