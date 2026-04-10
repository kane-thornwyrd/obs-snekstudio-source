#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
snekstudio_root="${repo_root}/SnekStudio"
mods_dir="${repo_root}/dist/snekstudio-mods"

launch_mode="source"

if [[ "${1-}" == "--system" ]]; then
	launch_mode="system"
	shift
elif [[ "${1-}" == "--source" ]]; then
	shift
fi

bash "${script_dir}/build_snekstudio_mod_zip.sh"

export SNEKSTUDIO_MODS_PATHS="${mods_dir}${SNEKSTUDIO_MODS_PATHS:+:${SNEKSTUDIO_MODS_PATHS}}"

if [[ "${launch_mode}" == "system" ]]; then
	snekstudio_bin="${SNEKSTUDIO_EXECUTABLE:-$(command -v snekstudio || true)}"
	if [[ -z "${snekstudio_bin}" ]]; then
		echo "No system-wide snekstudio executable found. Set SNEKSTUDIO_EXECUTABLE or use --source." >&2
		exit 1
	fi

	exec "${snekstudio_bin}" "$@"
fi

cd "${snekstudio_root}"
exec godot --path . "$@"