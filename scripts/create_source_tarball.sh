#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
version="$(tr -d '\n' < "${repo_root}/VERSION")"
package_name="obs-snekstudio-source"
archive_root="${package_name}-${version}"
dist_dir="${repo_root}/dist"
archive_path="${dist_dir}/${archive_root}.tar.gz"

mkdir -p "${dist_dir}"

tar \
	-C "${repo_root}" \
	--exclude='./.venv' \
	--exclude='./.vscode' \
	--exclude='./build' \
	--exclude='./dist' \
	--exclude='./stage' \
	--exclude='./__pycache__' \
	--transform "s,^\./,${archive_root}/," \
	-czf "${archive_path}" \
	.

echo "Created ${archive_path}"
sha256sum "${archive_path}"