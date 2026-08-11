# Fabric Friends Installer

One-shot installer for **Fabric loader 0.19.3 + Minecraft 1.21.11 + a fixed 23-mod client
pack**, into an existing Minecraft/TLauncher game directory. **Java is not required** at
any point — the scripts never download or run the `fabric-installer` jar; they fetch the
Fabric loader profile JSON directly from Fabric's meta API instead.

## Quick install (run from anywhere, nothing to clone)

**Linux and macOS** — same command on both:

```sh
curl -fsSL https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.sh | sh
```

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.ps1 | iex
```

### With shaders

To also install Iris and a shader pack, the flag has to be passed through to the
piped script:

```sh
curl -fsSL https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.sh | sh -s -- --shaders
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.ps1))) -Shaders
```

Any other flag from the table below works the same way — `sh -s -- <flags>` on
Linux/macOS, and the `scriptblock` form on Windows.

## Usage from a clone

If you'd rather read the script before running it (piping a URL into a shell runs
whatever the server sends, so this is the cautious option):

### Linux / macOS

```sh
chmod +x install.sh
./install.sh
```

### Windows

The script is signed by nothing, so PowerShell's default execution policy will block it
when run from a file. Run it explicitly with the bypass flag:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## Flags

| sh | PowerShell | Meaning |
|---|---|---|
| `--dir PATH` | `-Dir PATH` | Use a custom game directory instead of the default `.minecraft` |
| `--zip PATH` | `-Zip PATH` | Use a local copy of the mod pack zip instead of downloading it |
| `--shaders` | `-Shaders` | Also install Iris + a shader pack (client-visual only, see below) |
| `--no-shaders` | `-NoShaders` | Remove Iris + the shader Sodium build, and restore base Sodium |

`--shaders`/`-Shaders` and `--no-shaders`/`-NoShaders` cannot be given together; the
installer exits with an error if both are passed.

Default game directory:
- Linux: `$HOME/.minecraft`
- macOS: `$HOME/Library/Application Support/minecraft`
- Windows: `%APPDATA%\.minecraft`

## Before you run it

Launch **vanilla Minecraft 1.21.11** once from your launcher first, so the game's assets
(sounds, language files, etc.) download normally. The installer only places the version
JSON/jar, the loader profile, and the mods — it does not fetch assets.

## After it finishes

The script prints the version id to select (`fabric-loader-0.19.3-1.21.11`). It also tries
to register a `fabric-loader-1.21.11` entry in `launcher_profiles.json` automatically. If
TLauncher doesn't show it in the dropdown, make sure **custom/other versions** are enabled
in TLauncher's version list settings, then pick it manually.

## Optional shaders (`--shaders` / `-Shaders`)

Passing this flag additionally installs **Iris** and the **Complementary Unbound**
shader pack. This is purely client-visual and does not affect compatibility with
other players on the server.

Iris 1.10.7 hard-pins Sodium `0.8.7`, which is older than the `0.8.14-beta.2` the
base pack ships. When `--shaders`/`-Shaders` is used, the installer removes
`sodium-fabric-0.8.14-beta.2+mc1.21.11.jar` from `mods/` and installs
`sodium-fabric-0.8.7+mc1.21.11.jar` instead — without this swap Iris refuses to
load. The shader pack itself is placed in `shaderpacks/`, not `mods/`. With
`--shaders`/`-Shaders` the final verification checks 24 jars in `mods/` (23 base +
Iris, with Sodium swapped to `0.8.7`) instead of 23.

**Shader mode is sticky.** If Iris is already installed in `mods/` and you re-run
the installer with neither `--shaders`/`-Shaders` nor `--no-shaders`/`-NoShaders`,
the installer detects the existing Iris jar and keeps shaders enabled — it will
never leave you with two Sodium jars at once just because a plain re-run assumed
a fresh, non-shader install. To go back to the base (non-shader) pack, pass
`--no-shaders`/`-NoShaders` explicitly.

## Removing shaders (`--no-shaders` / `-NoShaders`)

Passing this flag removes `iris-fabric-*.jar` and the shader Sodium build
(`sodium-fabric-0.8.7*.jar`) from `mods/`, and restores the base
`sodium-fabric-0.8.14-beta.2+mc1.21.11.jar`, ending back at the 23-jar base
manifest. It leaves `shaderpacks/` untouched — shader-pack zips are harmless
sitting on disk even without Iris, and you may want to keep them for later;
delete that directory manually if you don't.

## Duplicate-mod protection

Before the final verification, the installer checks `mods/` for two files
belonging to the same mod (for example, both Sodium builds present at once) and
**hard-fails with a nonzero exit code** if it finds one, naming both files and
which one to delete — this check runs first, so it also catches a duplicate
Sodium jar you (or another tool) dropped in by hand. Two versions of the same
mod loaded together crashes the game on launch.

Separately, the installer's own shader/no-shader logic keeps exactly one Sodium
jar as part of switching modes: `--shaders`/`-Shaders` and `--no-shaders`/
`-NoShaders` (and the sticky-mode detection above) each remove the Sodium build
their mode doesn't want before the duplicate check ever runs, so a normal mode
switch never trips it. A single unrecognized extra jar that isn't part of the
pack only produces a warning; `tl_skin_cape*.jar` files are always left alone
and never flagged.

## Do not add OptiFine

The pack already includes **Sodium** for rendering performance. Installing OptiFine
alongside it will conflict — do not add it.

## Re-running

The installer is idempotent: re-running it will not re-download anything that already
verifies against its expected hash. In particular, if all 18 bundled pack jars are
already present in `mods/` and match their expected hashes, the installer skips
downloading/extracting the pack zip entirely (no ~27MB Google Drive fetch on a
routine re-run) — it only fetches and re-extracts the zip when at least one bundled
jar is missing or corrupted, and it still repairs just that jar from the zip in
that case.
