# Arch Packaging

This directory now serves two different use cases:

- `PKGBUILD` is the local build recipe for testing package layout from this working tree.
- `PKGBUILD-git.template` and `PKGBUILD-release.template` are AUR-oriented templates.

## Current AUR Blockers

The project is closer to AUR-ready, but not fully ready to submit yet. Two upstream decisions are still missing:

1. A public canonical source location.

   AUR packages cannot rely on local-only source paths like `../../dist/...`. You need either:

   - a public git repository for an `-git` package, or
   - a public tagged release archive for a versioned package.

2. An upstream software license.

   The `license=()` field in a `PKGBUILD` must describe the upstream software license, not the packaging files. This repository does not currently declare one. Until it does, the package cannot honestly advertise a final SPDX license value.

   The local draft `PKGBUILD` uses a temporary `LicenseRef-UPSTREAM-NO-LICENSE` placeholder only so local validation tools can run. That placeholder is not acceptable as a final AUR submission state.

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
- `LICENSE.0BSD`

If you need additional helper files later, add them explicitly.

## Pre-Submission Checklist

1. Copy one of the template PKGBUILDs to `PKGBUILD` in your AUR repo.
2. Replace the placeholder upstream URL variables.
3. Replace the placeholder `license=()` value with the real upstream SPDX expression.
4. If you use the release template, replace the checksum with a real one.
5. If upstream signs tags or archives, add `validpgpkeys=()`.
6. Run `makepkg --printsrcinfo > .SRCINFO`.
7. Run `namcap PKGBUILD` if `namcap` is installed.
8. Run `shellcheck --shell=bash --exclude=SC2034,SC2154,SC2164 PKGBUILD` if `shellcheck` is installed.
9. Commit `PKGBUILD`, `.SRCINFO`, `obs-snekstudio-source.install`, and `LICENSE.0BSD` to the AUR repo.

## Local Validation Tips

For the local draft package in this repo:

```bash
cd packaging/arch
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