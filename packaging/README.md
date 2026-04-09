# Packaging Notes

This repository now includes draft packaging definitions for Arch, Debian, and NixOS.

The Arch packaging directory now separates local testing from AUR submission prep. See [packaging/arch/README.md](packaging/arch/README.md) for the AUR-oriented templates and the remaining submission blockers.

Before building the Arch package, create a local source tarball:

```bash
./scripts/create_source_tarball.sh
```

## Arch

```bash
cd packaging/arch
makepkg -si
```

The Arch package definition expects the tarball at `../../dist/obs-snekstudio-source-0.1.0.tar.gz`.
The local draft `PKGBUILD` uses a placeholder homepage URL only to keep local linting sane; do not treat it as AUR-ready metadata.

For AUR work, do not submit the local `PKGBUILD` as-is. Use one of the templates in [packaging/arch/README.md](packaging/arch/README.md) and replace the placeholder source and license metadata first.

## Debian

Build from the repository root:

```bash
dpkg-buildpackage -us -uc
```

The `debian/control` file uses a placeholder maintainer identity that should be adjusted before redistribution.

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

These packaging definitions are local-build oriented. If you plan to publish them broadly, clean up maintainer metadata, source URLs, checksums, and licensing first.