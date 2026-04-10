# Packaging Notes

This repository now includes draft packaging definitions for Arch, Debian, and NixOS.

Release artifacts can now be built automatically by GitHub Actions through [.github/workflows/release-artifacts.yml](.github/workflows/release-artifacts.yml). Pushing a tag matching `v$(cat VERSION)` or manually dispatching that workflow will build release assets and upload them to the matching GitHub release.

The Arch packaging directory now separates local testing from AUR submission prep. See [packaging/arch/README.md](packaging/arch/README.md) for the AUR-oriented templates and the remaining submission blockers.
The public upstream repository is now [https://github.com/kane-thornwyrd/obs-snekstudio-source](https://github.com/kane-thornwyrd/obs-snekstudio-source).
The project license is now `GPL-3.0-or-later`.

Before building the Arch package, create a local source tarball:

```bash
./scripts/create_source_tarball.sh
```

## Arch

```bash
rm -f packaging/arch/obs-snekstudio-source-0.1.0.tar.gz
cd packaging/arch
makepkg -si
```

The Arch package definition expects the tarball at `../../dist/obs-snekstudio-source-0.1.0.tar.gz`.
The `rm -f` line is intentional: `makepkg` caches the downloaded tarball inside `packaging/arch/`, so you need to clear that copy after regenerating `dist/obs-snekstudio-source-0.1.0.tar.gz`.
The local draft `PKGBUILD` is now lint-clean for local builds, but the stable AUR package still depends on a public tagged release archive and a real checksum.

For AUR work, do not submit the local `PKGBUILD` as-is. Use one of the templates in [packaging/arch/README.md](packaging/arch/README.md) and generate `.SRCINFO` from the chosen template.

An actual AUR-ready repository payload for the git package now exists in [packaging/aur/obs-snekstudio-source-git](packaging/aur/obs-snekstudio-source-git).

## Debian

Build from the repository root:

```bash
dpkg-buildpackage -us -uc
```

The Debian metadata currently names Jean-Cedric Therond as maintainer. Adjust it if you redistribute the package under a different maintainer identity.

## NixOS

Build the package directly:

```bash
nix-build packaging/nix/default.nix
```

Use it from NixOS with:

```nix
{ pkgs, ... }:
let
  snekstudioSource = pkgs.callPackage /path/to/repo/packaging/nix/default.nix { };
in {
  programs.obs-studio = {
    enable = true;
    plugins = [ snekstudioSource ];
  };
}
```

## Installed Artifacts

All package definitions install the same payload:

- the OBS plugin shared library
- the demo publisher binary `snekstudio-demo-publisher`
- the protocol header
- the basic project docs

These packaging definitions are local-build oriented. If you plan to publish them broadly, clean up maintainer metadata and, for the stable Arch package, publish tags and checksums first.

## GitHub Release Artifacts

The GitHub release workflow currently publishes:

- a source tarball built by `scripts/create_source_tarball.sh`
- a generic staged Linux bundle containing the installed plugin payload
- the Arch package built from `packaging/arch/PKGBUILD`
- a `SHA256SUMS.txt` manifest for the uploaded assets