# Minecraft Fabric 1.21.11 — Friends Modpack Installer

One command. Installs Fabric loader + all 24 mods. **No Java needed.**

## Install — with shaders

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.sh | sh -s -- --shaders
```

**Windows** (PowerShell)

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.ps1))) -Shaders
```

## Install — without shaders

**Linux / macOS**

```sh
curl -fsSL https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.sh | sh
```

**Windows** (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Adarsh077/minecraft/main/install.ps1 | iex
```

## Then

1. Launch **vanilla 1.21.11** once first if you never have — that downloads sounds and assets.
2. In your launcher pick version **`fabric-loader-0.19.3-1.21.11`**.
   TLauncher hides it until you enable *custom / other versions* in the version dropdown settings.
3. Multiplayer → add the server address.

Shaders: Options → Video Settings → Shader Packs → pick one → Apply.

**Do not install OptiFine.** Sodium is already included and conflicts with it.

## What you get

| | |
|---|---|
| Loader | Fabric 0.19.3, Minecraft 1.21.11 |
| Mods | 24 jars, versions pinned and SHA-256 verified |
| Performance | Sodium, Lithium, FerriteCore |
| Client | JEI, Jade, Inventory Profiles Next, Modflared |
| Gameplay | Waystones, Biomes O' Plenty, Farmer's Delight, Traveler's Backpack, Storage Drawers, Carry On, Adorn, MDM, Fantastic Wings |
| With shaders | Iris + Sodium 0.8.7 + Complementary Unbound |

Everyone on the server needs the same mods, or you get kicked on join.
Shaders are client-only — safe to enable or skip individually.

## Options

| Linux / macOS | Windows | Meaning |
|---|---|---|
| `--shaders` | `-Shaders` | Also install Iris + a shader pack |
| `--no-shaders` | `-NoShaders` | Remove Iris, restore base Sodium |
| `--dir PATH` | `-Dir PATH` | Custom game directory |
| `--zip PATH` | `-Zip PATH` | Use a local pack zip instead of downloading |

Default game directory: `~/.minecraft` (Linux), `~/Library/Application Support/minecraft` (macOS), `%APPDATA%\.minecraft` (Windows).

## Notes

**Re-running is safe.** Nothing already correct is re-downloaded; corrupt or missing jars
are replaced automatically. Once shaders are installed, a plain re-run keeps them — use
`--no-shaders` to remove them.

**Iris pins Sodium 0.8.7**, older than the `0.8.14-beta.2` the base pack ships, so the
shader install swaps it. Two Sodium jars would crash the game, and the installer fails
loudly rather than letting that happen.

**Prefer to read it first?** Piping a URL into a shell runs whatever the server sends.
Clone instead, then `sh install.sh --shaders`, or on Windows
`powershell -ExecutionPolicy Bypass -File .\install.ps1 -Shaders`.
