#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
mod_root="${repo_root}/snekstudio-mods/OBSFramePublisher"
output_dir="${repo_root}/dist/snekstudio-mods"
output_zip="${output_dir}/OBSFramePublisher.zip"

mkdir -p "${output_dir}"
rm -f "${output_zip}"

pushd "${mod_root}" >/dev/null
zip -qr "${output_zip}" Mods
popd >/dev/null

echo "Created ${output_zip}"