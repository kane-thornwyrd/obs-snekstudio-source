# Arch Packaging

This directory now serves two different use cases:

- `PKGBUILD` is the local build recipe for testing package layout from this working tree.
- `PKGBUILD-git.template` and `PKGBUILD-release.template` are AUR-oriented templates.

## Current AUR Blockers

The repository now has a public upstream GitHub URL:

- `https://github.com/kane-thornwyrd/obs-snekstudio-source`

The project now also declares an upstream software license:

- `GPL-3.0-or-later`

That resolves the previous source-location and license blockers for the VCS package.

The remaining blocker is only for the stable non-VCS package:

1. A public tagged release archive, if you want the stable non-VCS package.

   The GitHub repository is already public, so `obs-snekstudio-source-git` is structurally viable. The stable `obs-snekstudio-source` package still assumes tags or release archives such as `v0.1.0` on GitHub.

## Recommended Submission Path

Until you publish versioned release tarballs, the easiest AUR path is:

- submit `obs-snekstudio-source-git` first using `PKGBUILD-git.template`
- submit the stable `obs-snekstudio-source` package later using `PKGBUILD-release.template`

That follows the AUR guideline split between VCS packages and versioned source packages.

## Files For An AUR Repository

For an AUR repository, keep only the packaging files, not the full upstream source tree. At minimum, that repository should contain:

- `PKGBUILD`
- `.SRCINFO`
- `obs-snekstudio-source.install`
- `LICENSE`

If you need additional helper files later, add them explicitly.

If you want a prepared starting point instead of assembling those files yourself,
use [packaging/aur/obs-snekstudio-source-git](packaging/aur/obs-snekstudio-source-git), which already contains the git package repository payload with maintainer metadata filled in.

## Pre-Submission Checklist

1. Copy one of the template PKGBUILDs to `PKGBUILD` in your AUR repo.
2. If you use the release template, make sure the `v${pkgver}` tag exists and replace the checksum with a real one.
3. If upstream signs tags or archives, add `validpgpkeys=()`.
4. Copy the packaging-source `LICENSE` file from this directory into the AUR repo.
5. Run `makepkg --printsrcinfo > .SRCINFO`.
6. Run `namcap PKGBUILD` if `namcap` is installed.
7. Run `shellcheck --shell=bash --exclude=SC2034,SC2154,SC2164 PKGBUILD` if `shellcheck` is installed.
8. Commit `PKGBUILD`, `.SRCINFO`, `obs-snekstudio-source.install`, and `LICENSE` to the AUR repo.

## Local Validation Tips

For the local draft package in this repo:

```bash
cd packaging/arch
rm -f obs-snekstudio-source-0.1.0.tar.gz
makepkg --printsrcinfo
```

For a prepared AUR repo:

```bash
makepkg --printsrcinfo > .SRCINFO
```

If you have `namcap` available:

```bash
namcap PKGBUILD
```