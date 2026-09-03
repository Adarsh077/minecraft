<#
Fabric Friends Client Pack installer for Minecraft 1.21.11 / Fabric loader 0.19.3
PowerShell 5.1 compatible. No Java required at any point.

A tier is REQUIRED: -dalit (bare minimum), -pandit (medium), or -modi (high).
Every file is downloaded from the Modrinth CDN and verified by SHA-256.
#>

param(
    [string]$Dir = "",
    [switch]$dalit,
    [switch]$pandit,
    [switch]$modi
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$FabricMcVersion = "1.21.11"
$FabricLoaderVersion = "0.19.3"
$FabricLoaderId = "fabric-loader-$FabricLoaderVersion-$FabricMcVersion"
$VersionManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
$FabricProfileUrl = "https://meta.fabricmc.net/v2/versions/loader/$FabricMcVersion/$FabricLoaderVersion/profile/json"

# --- modflared forced-tunnels config (written into the game dir during install) ---
$ForcedTunnelsJson = '["minecraft.dekhlo.to"]'

# NOTE: midnightlib-fabric- is intentionally NOT server-only: Cull Leaves (and other
# client mods) hard-require it ("midnightlib": "*"), so it must stay in mods\.
$ServerOnlyPrefixes = @("graves-", "polymer-bundled-", "repurposed_structures-", "FallingTree-")

# --- shader stack (installed for pandit/modi only) ---
# Iris 1.10.7 hard-pins Sodium 0.8.7, which replaces the base 0.8.14-beta.2 for
# shader tiers -- never both. dalit keeps 0.8.14-beta.2 and installs no Iris.
$SodiumBaseJar = "sodium-fabric-0.8.14-beta.2+mc1.21.11.jar"
$SodiumShadersJar = "sodium-fabric-0.8.7+mc1.21.11.jar"
$SodiumShadersUrl = "https://cdn.modrinth.com/data/AANobbMI/versions/UddlN6L4/sodium-fabric-0.8.7%2Bmc1.21.11.jar"
$SodiumShadersSha256 = "c08fae86b350aaa8a8f37e7347929df38f01cc2348cf31c322615564bdc53983"
$IrisJar = "iris-fabric-1.10.7+mc1.21.11.jar"
$IrisUrl = "https://cdn.modrinth.com/data/YL57xq9U/versions/fDpuVzVr/iris-fabric-1.10.7%2Bmc1.21.11.jar"
$IrisSha256 = "58c55da18189c91a49f847d3cee451633a23b575fb69c0c5b65ddb274436cb19"
$ShaderpackZip = "ComplementaryUnbound_r5.8.1.zip"
$ShaderpackUrl = "https://cdn.modrinth.com/data/R6NEzAwj/versions/VMHXIk50/ComplementaryUnbound_r5.8.1.zip"
$ShaderpackSha256 = "bb89b1fc54687d4147a837fb2e3c3f7261a13bee51819761e9b6a91cb7915965"

# --- resourcepack (downloaded into <gamedir>\resourcepacks\; note the space in the name) ---
$ResourcepackName = "Presence Footsteps R3.zip"
$ResourcepackSha256 = "d33bf876c957a0c2f570f55586948440d9cb849b549d744d26d80733f5ec286f"
$ResourcepackUrl = "https://cdn.modrinth.com/data/qSJqZIl1/versions/yAgMm4Uo/Presence%20Footsteps%20R3.zip"

# --- 37 mod jars downloaded from the Modrinth CDN: "filename sha256 url" per line ---
# Every URL was resolved by SHA-512 lookup against the Modrinth API, so each serves
# exactly the bytes its SHA-256 names. Do not substitute URLs or versions; keep the
# %2B / %20 escapes intact. Installed to <gamedir>\mods\ (all tiers).
$ModsTable = @"
Adorn-7.6.1+1.21.11-fabric.jar d431be4ee89d0d71b1ababedaa5275f478cfff5de94eba1165f5cd10d1b676d3 https://cdn.modrinth.com/data/E6FUtRJh/versions/tyOUUBLZ/Adorn-7.6.1%2B1.21.11-fabric.jar
AmbientSounds_FABRIC_v6.3.5_mc1.21.11.jar e2a657ad18fcc4382418dcff9ddc411ae4912001c8cb90766020bb7cfdcbb9fb https://cdn.modrinth.com/data/fM515JnW/versions/JZUqW70J/AmbientSounds_FABRIC_v6.3.5_mc1.21.11.jar
animal_feeding_trough-1.2.0+1.21.11.jar e4a62c4a6427a3779c3507c41901a57238d44c7665f29bdb9c4b5f653d3ab92c https://cdn.modrinth.com/data/bRFWnJ87/versions/aTRE6QT1/animal_feeding_trough-1.2.0%2B1.21.11.jar
carryon-fabric-1.21.11-2.9.2.jar ac6c68baf2cbffef7de6739423aa615f151c8f1601bacf30921c8bd88f3f932d https://cdn.modrinth.com/data/joEfVgkn/versions/KOFV3duz/carryon-fabric-1.21.11-2.9.2.jar
cc-tweaked-1.21.11-fabric-1.117.1.jar ba773f0a6a942a8f5d628689470299ebe5e362a931993bda8c4f232f42556494 https://cdn.modrinth.com/data/gu7yAYhd/versions/IikPYYtH/cc-tweaked-1.21.11-fabric-1.117.1.jar
cloth-config-21.11.153-fabric.jar 8a40c84e5ecde525acfb6c4e13b8002dacfca3ef9534d7faf6e8049656f423c8 https://cdn.modrinth.com/data/9s6osm5g/versions/xuX40TN5/cloth-config-21.11.153-fabric.jar
connectiblechains-2.5.7+1.21.11.jar ee37964f95329511c789c323d7d3b047423e0b69f93ba26f751a293183e354dd https://cdn.modrinth.com/data/ykSfIgTw/versions/h8RIIOQq/connectiblechains-2.5.7%2B1.21.11.jar
continuity-3.0.1-beta.1+1.21.11.jar 1d4d4e86fb20bd0b078fcc518f4641d21985cc8bfaefa6dd49cfa1beff52ac83 https://cdn.modrinth.com/data/1IjD5062/versions/mX1iknM1/continuity-3.0.1-beta.1%2B1.21.11.jar
create-fly-1.21.11-6.0.9-5.jar 55f59380921fada030cd1adaba950393d492f731c2e4d982294d34258c739b9b https://cdn.modrinth.com/data/dKvj0eNn/versions/fn0H9rSj/create-fly-1.21.11-6.0.9-5.jar
CreativeCore_FABRIC_v2.14.11_mc1.21.11.jar a8e759b023b2de920022d32d1e09bd3c6c9ad32546ccc114f1951100c58984d8 https://cdn.modrinth.com/data/OsZiaDHq/versions/jyLHWJlj/CreativeCore_FABRIC_v2.14.11_mc1.21.11.jar
cullleaves-fabric-4.1.1.1+1.21.11.jar fc82497837bdb26d50468383da79fd12aecb2a51d09d94c892baaa55cd3829d3 https://cdn.modrinth.com/data/GNxdLCoP/versions/yrL6pwHZ/cullleaves-fabric-4.1.1.1%2B1.21.11.jar
entity_texture_features-7.2.1-1.21.11-fabric.jar a5630cef60a8d13d77f2fd9e56de6fd0381187a1bfca4713e8e5f276f235c50e https://cdn.modrinth.com/data/BVzZfTc1/versions/9uQFLvtW/entity_texture_features-7.2.1-1.21.11-fabric.jar
expanded_weaponry-0.8.jar 4c1175a1e31780d05c3cc7b2c924a20d0df887c712218e8cc3c8d49c7200b1be https://cdn.modrinth.com/data/q8rZUpjS/versions/91zQqaH6/expanded_weaponry-0.8.jar
fabric-api-0.141.6+1.21.11.jar bdff7fd7e220085cfad2ff9b1f40dde6534ae0b96cf378f97a374bc54cb9ed0f https://cdn.modrinth.com/data/P7dR8mSH/versions/6qAuTtLR/fabric-api-0.141.6%2B1.21.11.jar
fabric-language-kotlin-1.13.13+kotlin.2.4.10.jar 34ccdacf13bb9351fe43ce61912c2e09b72364e43e787d36ba3d2d04dec75a52 https://cdn.modrinth.com/data/Ha28R6CL/versions/bdhiINYC/fabric-language-kotlin-1.13.13%2Bkotlin.2.4.10.jar
FantasticWings-v21.11.1-mc1.21.11-Fabric.jar b7cc2eb1814fe5c5eb3b0b3e6af399d4be0bcda44af3bd9b02994fdd6f3d7e43 https://cdn.modrinth.com/data/iGEcTqwK/versions/5zJKhkHi/FantasticWings-v21.11.1-mc1.21.11-Fabric.jar
FarmersDelight-1.21.11-3.6.13+refabricated.jar 3b3caa7a3c9b7ddc0a28f620ec729da6ab00a181fd8667de104324a5bb9015d1 https://cdn.modrinth.com/data/7vxePowz/versions/yXs9snmN/FarmersDelight-1.21.11-3.6.13%2Brefabricated.jar
ferritecore-8.2.0-fabric.jar f76bd760cbf48280cc7c43180f5089a46235fa24d934a8acf3da04a664c2c715 https://cdn.modrinth.com/data/uXXizFIs/versions/Ii0gP3D8/ferritecore-8.2.0-fabric.jar
ForgeConfigAPIPort-v21.11.1-mc1.21.11-Fabric.jar 31a0686904fad1cfdeb1d6b011ac1c2280990d6e76ac2416468147e2246b4db1 https://cdn.modrinth.com/data/ohNO6lps/versions/uXrWPsCu/ForgeConfigAPIPort-v21.11.1-mc1.21.11-Fabric.jar
ImmediatelyFast-Fabric-1.14.3+1.21.11.jar c6e939744ed80345a1a70c351c481b8832d33970d6574b8d444dfe750abc2a86 https://cdn.modrinth.com/data/5ZwdcRci/versions/4EwhsTu7/ImmediatelyFast-Fabric-1.14.3%2B1.21.11.jar
InventoryProfilesNext-fabric-1.21.11-2.2.6.jar 1d971f0f624c8f2d2693004aff96cb9546d65e3ab950d63563c769242d2c6474 https://cdn.modrinth.com/data/O7RBXm3n/versions/YKjWPbto/InventoryProfilesNext-fabric-1.21.11-2.2.6.jar
Jade-1.21.11-Fabric-21.1.6.jar bcf1a7f6f9eb325b89d65bc15b41a35fdca2c2b052e9af772ffdcd70548d2fc8 https://cdn.modrinth.com/data/nvQzSEkH/versions/swJhAyak/Jade-1.21.11-Fabric-21.1.6.jar
jei-1.21.11-fabric-27.23.0.71.jar e904a724d7e2b5b2382b1f46f8d3efe84cb6a955ee6fe5310e8a173cf881ffb6 https://cdn.modrinth.com/data/u6dRKJwZ/versions/vyofGDrh/jei-1.21.11-fabric-27.23.0.71.jar
lambdynamiclights-4.9.1+1.21.11.jar 99bcfbb13cbd7c98ec9574c2959a1c6a145aac26efed54bcb32ebf08abf9282c https://cdn.modrinth.com/data/yBW8D80W/versions/5Tp7kdU0/lambdynamiclights-4.9.1%2B1.21.11.jar
libIPN-fabric-1.21.11-6.6.3.jar 94a52d56ec41e31a98089aeff07baf25534986922d572eac85475b5e2736c9af https://cdn.modrinth.com/data/onSQdWhM/versions/ByG214OZ/libIPN-fabric-1.21.11-6.6.3.jar
lithium-fabric-0.21.4+mc1.21.11.jar 5135c41da5b43cbdcb29424bde65195143ac4084e23834c8eac065942201c78b https://cdn.modrinth.com/data/gvQqBUqZ/versions/Ow7wA0kG/lithium-fabric-0.21.4%2Bmc1.21.11.jar
midnightlib-fabric-1.9.3+1.21.11.jar 515dcc1602a3e560c2e8c7c5672af661a92bbddb1a6e2acaead3176773cf446f https://cdn.modrinth.com/data/codAaoxh/versions/jkodor79/midnightlib-fabric-1.9.3%2B1.21.11.jar
modflared-1.6.0+release.129.jar 5389a4c89dc91ad1edabff96c92d98cec85a5fc0a6e8120885f04cfd3f371943 https://cdn.modrinth.com/data/uRHq6kbO/versions/ylsFkqBg/modflared-1.6.0%2Brelease.129.jar
PresenceFootsteps-1.12.4+1.21.11.jar c333a4f82696b38ed0fd0558878dce67489c6105b00fafe01cccba73155ae569 https://cdn.modrinth.com/data/rcTfTZr3/versions/xjmToylJ/PresenceFootsteps-1.12.4%2B1.21.11.jar
PuzzlesLib-v21.11.13-mc1.21.11-Fabric.jar 1c7b062f4d4fd4c830dbaa875da01706ef85f072969191d8c1affef693a66b82 https://cdn.modrinth.com/data/QAGBst4M/versions/xTX7sOwU/PuzzlesLib-v21.11.13-mc1.21.11-Fabric.jar
skinlayers3d-fabric-1.11.2-mc1.21.11.jar 31243ee08b76b3dab71d7761963f317125c536f6b8984795e7b02811b4f80e97 https://cdn.modrinth.com/data/zV5r3pPn/versions/3kCdl1bI/skinlayers3d-fabric-1.11.2-mc1.21.11.jar
sodium-fabric-0.8.14-beta.2+mc1.21.11.jar 24990c1c497bdda4605c595f4ee65aaf32f724b1498a33c63f43cb4500280c51 https://cdn.modrinth.com/data/AANobbMI/versions/vqUoGREs/sodium-fabric-0.8.14-beta.2%2Bmc1.21.11.jar
sound-physics-remastered-fabric-1.21.11-1.5.1.jar 17a4c14f58b739d275089262fc2015ff1548425202e6e4d7ce8cecf3122cdbca https://cdn.modrinth.com/data/qyVF9oeo/versions/pfqxi9qs/sound-physics-remastered-fabric-1.21.11-1.5.1.jar
StorageDrawers-fabric-1.21.11-20.0.0.jar 5910484b2ad3813094600a229ef95bc6947cfe3815869b6fa418b139a037fdf9 https://cdn.modrinth.com/data/guitPqEi/versions/Q9r8LMQL/StorageDrawers-fabric-1.21.11-20.0.0.jar
TerraBlender-fabric-1.21.11-21.11.0.0.jar 3f0567c194d579677b42dd57eeb912e4e558ca069f4fc525213d182e60113772 https://cdn.modrinth.com/data/kkmrDlKT/versions/chxo508B/TerraBlender-fabric-1.21.11-21.11.0.0.jar
travelersbackpack-fabric-1.21.11-10.11.10.jar d9f42b1bafd29d84fd97b5b6e51c948f0ed7d1251c0deed40e512870ea5980fb https://cdn.modrinth.com/data/rlloIFEV/versions/LfmQsEdR/travelersbackpack-fabric-1.21.11-10.11.10.jar
voxelmap-fabric-1.21.11-1.15.13.jar 1fe8ed68c671a6c4a80e064a8178102d674df0bec7aebb06bb857aafadf2d0a7 https://cdn.modrinth.com/data/wkzK5379/versions/tRdGJKGE/voxelmap-fabric-1.21.11-1.15.13.jar
"@

# --- known mod-name prefixes, used for duplicate-mod detection ---
$KnownModPrefixes = @(
    "sodium-fabric-", "iris-fabric-", "fabric-api-", "lithium-fabric-", "ferritecore-",
    "Adorn-", "carryon-fabric-", "fabric-language-kotlin-", "FantasticWings-",
    "FarmersDelight-", "ForgeConfigAPIPort-", "InventoryProfilesNext-fabric-", "Jade-",
    "jei-", "libIPN-fabric-", "modflared-", "PuzzlesLib-", "StorageDrawers-fabric-",
    "TerraBlender-fabric-", "travelersbackpack-fabric-", "create-fly-", "cc-tweaked-",
    "expanded_weaponry-", "animal_feeding_trough-", "connectiblechains-", "voxelmap-fabric-",
    "entity_texture_features-", "ImmediatelyFast-Fabric-", "sound-physics-remastered-fabric-",
    "skinlayers3d-fabric-", "lambdynamiclights-", "AmbientSounds_FABRIC_", "CreativeCore_FABRIC_",
    "PresenceFootsteps-", "cullleaves-fabric-", "continuity-", "cloth-config-", "midnightlib-fabric-"
)

function Write-Log($msg) {
    Write-Host $msg
}

function Write-Warn2($msg) {
    Write-Warning $msg
}

function Fail($msg) {
    Write-Error $msg
    exit 1
}

function Show-Usage {
    Write-Host "Usage: install.ps1 (-dalit | -pandit | -modi) [-Dir DIR]"
    Write-Host "  A tier is REQUIRED:"
    Write-Host "    -dalit   very low end: no shaders, minimal settings, -Xmx3G"
    Write-Host "    -pandit  medium: Complementary shaders (MEDIUM), -Xmx5G"
    Write-Host "    -modi    dedicated GPU: Complementary shaders (HIGH), -Xmx8G"
}

function Get-Sha256($path) {
    return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()
}

function Get-Sha1($path) {
    return (Get-FileHash -Algorithm SHA1 -Path $path).Hash.ToLowerInvariant()
}

function Invoke-Download($Url, $Dest) {
    try {
        # Invoke-WebRequest follows 3xx redirects by default (Modrinth serves direct URLs).
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Dest
    } catch {
        Fail "Download failed: $Url ($($_.Exception.Message))"
    }
}

# Download a file and verify its SHA-256 (idempotent: skips if already correct).
function Invoke-DownloadVerify($Name, $Sha, $Url, $DestDir) {
    if (-not (Test-Path -LiteralPath $DestDir)) { New-Item -ItemType Directory -Force -Path $DestDir | Out-Null }
    $dest = Join-Path $DestDir $Name
    if ((Test-Path -LiteralPath $dest) -and ((Get-Sha256 -path $dest) -eq $Sha)) {
        Write-Log "Already present and verified: $Name"
        return
    }
    Write-Log "Downloading: $Name"
    $part = "$dest.part"
    Invoke-Download -Url $Url -Dest $part
    $actual = Get-Sha256 -path $part
    if ($actual -ne $Sha) {
        Remove-Item -Force -LiteralPath $part
        Fail "SHA-256 mismatch for $Name : expected $Sha, got $actual (url: $Url)"
    }
    Move-Item -Force -LiteralPath $part -Destination $dest
}

# --- config-writing helpers ---
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-ConfigAction($path) {
    if (Test-Path -LiteralPath $path) { return "merged" } else { return "created" }
}

# Merge "key<sep>value" entries into a colon- or equals-separated text config.
# Existing lines for a key are replaced in place; every other line is preserved;
# absent keys are appended. Used for options.txt (":") and .properties ("=").
function Merge-KvFile($path, $sep, $pairs) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $lines = @()
    if (Test-Path -LiteralPath $path) { $lines = @(Get-Content -LiteralPath $path) }
    $seen = @{}
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($line in $lines) {
        $replaced = $false
        foreach ($k in $pairs.Keys) {
            # Tolerate optional whitespace before the separator (a mod may re-save "key = value").
            if ($line -match ("^" + [regex]::Escape($k) + "[ \t]*" + [regex]::Escape($sep))) {
                if (-not $seen.ContainsKey($k)) { $out.Add("$k$sep$($pairs[$k])"); $seen[$k] = $true }
                $replaced = $true
                break
            }
        }
        if (-not $replaced) { $out.Add($line) }
    }
    foreach ($k in $pairs.Keys) { if (-not $seen.ContainsKey($k)) { $out.Add("$k$sep$($pairs[$k])") } }
    [System.IO.File]::WriteAllText($path, ($out -join "`n") + "`n", $Utf8NoBom)
}

# Recursively convert a PSCustomObject (from ConvertFrom-Json) into nested hashtables.
function ConvertTo-HashtableDeep($obj) {
    if ($null -eq $obj) { return @{} }
    $ht = @{}
    foreach ($p in $obj.PSObject.Properties) {
        if ($p.Value -is [System.Management.Automation.PSCustomObject]) {
            $ht[$p.Name] = ConvertTo-HashtableDeep $p.Value
        } else {
            $ht[$p.Name] = $p.Value
        }
    }
    return $ht
}

function Merge-HashtableDeep($base, $patch) {
    foreach ($k in @($patch.Keys)) {
        if (($patch[$k] -is [hashtable]) -and $base.ContainsKey($k) -and ($base[$k] -is [hashtable])) {
            Merge-HashtableDeep $base[$k] $patch[$k]
        } else {
            $base[$k] = $patch[$k]
        }
    }
}

# Deep-merge a hashtable patch into a JSON file (create if absent). Booleans and
# ints in the patch serialize as JSON true/false/numbers.
function Merge-JsonFile($path, $patch) {
    $base = @{}
    if (Test-Path -LiteralPath $path) {
        try {
            $existing = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
            $base = ConvertTo-HashtableDeep $existing
        } catch {
            $base = @{}
        }
    }
    Merge-HashtableDeep $base $patch
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, (($base | ConvertTo-Json -Depth 10) + "`n"), $Utf8NoBom)
}

# Set a quoted-string key in a TOML file (create if absent), replacing any existing
# line for the key (TOML forbids duplicate keys, so this cannot just append).
function Set-TomlString($path, $key, $val) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $line = "$key = `"$val`""
    $out = New-Object System.Collections.Generic.List[string]
    $seen = $false
    if (Test-Path -LiteralPath $path) {
        foreach ($l in @(Get-Content -LiteralPath $path)) {
            if ($l -match ("^[ \t]*" + [regex]::Escape($key) + "[ \t]*=")) {
                if (-not $seen) { $out.Add($line); $seen = $true }
            } else {
                $out.Add($l)
            }
        }
    }
    if (-not $seen) { $out.Add($line) }
    [System.IO.File]::WriteAllText($path, ($out -join "`n") + "`n", $Utf8NoBom)
}

# Write LambDynamicLights' [light_sources] table with every source off (dalit only).
# LambDynamicLights (NightConfig) reads each source via the path "light_sources.<name>"
# and serialises them as a nested [light_sources] TOML table, so we write that exact
# shape. entities / self / beam / firefly / guardian_laser / sonic_boom /
# glowing_effect are booleans and go to false. creeper and tnt are NOT booleans --
# they are ExplosiveLightingMode, which in 4.9.1 declares only SIMPLE and FANCY
# (verified in ExplosiveLightingMode.class). There is no OFF, so explosion lighting
# cannot be switched off here at all; "simple" is the cheaper of the two and is the
# floor. A bare false, or the string "off", is an invalid enum value that
# byId()/valueOf() silently falls back to the default for, leaving it ON.
# water_sensitive_check is a submersion behaviour flag, not a light source, so it is
# left untouched. Replaces an existing [light_sources] table if present (idempotent),
# otherwise appends one.
function Set-LambdynLightsOff($path) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (-not (Test-Path -LiteralPath $path)) { [System.IO.File]::WriteAllText($path, "", $Utf8NoBom) }
    $out = New-Object System.Collections.Generic.List[string]
    $inLs = $false
    foreach ($l in @(Get-Content -LiteralPath $path)) {
        if ($l -match '^[ \t]*\[light_sources\][ \t]*$') { $inLs = $true; continue }
        if ($inLs -and ($l -match '^[ \t]*\[')) { $inLs = $false }
        if ($inLs) { continue }
        if ($l -match '^[ \t]*light_sources\.') { continue }
        $out.Add($l)
    }
    $out.Add("[light_sources]")
    $out.Add("`tentities = false")
    $out.Add("`tself = false")
    $out.Add("`tcreeper = `"simple`"")
    $out.Add("`ttnt = `"simple`"")
    $out.Add("`tbeam = false")
    $out.Add("`tfirefly = false")
    $out.Add("`tguardian_laser = false")
    $out.Add("`tsonic_boom = false")
    $out.Add("`tglowing_effect = false")
    [System.IO.File]::WriteAllText($path, ($out -join "`n") + "`n", $Utf8NoBom)
}

# Ensure a pack id is present in options.txt's resourcePacks list (a JSON array),
# preserving any packs the friend already enabled. Minecraft 1.21.11 references a
# resourcepacks\ file as "file/<filename>" (the "file/" prefix is confirmed present
# in the vanilla client's resource-pack class).
function Enable-Resourcepack($path, $id) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    if (-not (Test-Path -LiteralPath $path)) { [System.IO.File]::WriteAllText($path, "", $Utf8NoBom) }
    $lines = @(Get-Content -LiteralPath $path)
    $line = $lines | Where-Object { $_ -like "resourcePacks:*" } | Select-Object -First 1
    if ($null -eq $line) {
        Add-Content -LiteralPath $path -Value "resourcePacks:[`"vanilla`",`"$id`"]"
        return
    }
    if ($line.Contains("`"$id`"")) { return }
    $array = $line.Substring("resourcePacks:".Length)
    if ($array -eq "[]") {
        $new = "resourcePacks:[`"$id`"]"
    } else {
        $new = "resourcePacks:" + $array.Substring(0, $array.Length - 1) + ",`"$id`"]"
    }
    $out = New-Object System.Collections.Generic.List[string]
    $done = $false
    foreach ($l in $lines) {
        if ((-not $done) -and ($l -like "resourcePacks:*")) { $out.Add($new); $done = $true }
        else { $out.Add($l) }
    }
    [System.IO.File]::WriteAllText($path, ($out -join "`n") + "`n", $Utf8NoBom)
}

# --- tier selection (mutually exclusive, REQUIRED) ---
$Tier = ""
$TierCount = 0
if ($dalit)  { $Tier = "dalit";  $TierCount++ }
if ($pandit) { $Tier = "pandit"; $TierCount++ }
if ($modi)   { $Tier = "modi";   $TierCount++ }
if ($TierCount -gt 1) {
    Show-Usage
    Fail "Only one tier flag may be given (-dalit / -pandit / -modi)"
}
if ($Tier -eq "") {
    Show-Usage
    Fail "No tier given. Choose exactly one of -dalit / -pandit / -modi."
}

# --- per-tier settings ---
# All tiers install all 37 mod jars and the resourcepack; tiers differ in the shader
# stack and written config. options.txt / .properties booleans are strings; JSON
# booleans are [bool]. $T_Shaders indicates whether this tier gets Iris + Sodium 0.8.7.
if ($Tier -eq "dalit") {
    $T_RenderDistance = 5;  $T_SimDistance = 5;  $T_Graphics = 0; $T_Particles = 2
    $T_Mipmap = 0;          $T_BiomeBlend = 0;   $T_MaxFps = 60
    $T_EntityShadows = "false"; $T_Ao = "false"; $T_EntityDistScale = "0.5"
    $T_Xmx = "3G"
    $T_Shaders = $false
    $T_CompProfile = ""
    $T_SoundPhysics = "false"
    $T_Lambdyn = "fastest"
    $T_Continuity = $false
    $T_Skinlayers = $false
    $T_SodiumAnimateVisibleOnly = $true
    $T_SodiumRenderAhead = 0
} elseif ($Tier -eq "pandit") {
    $T_RenderDistance = 9;  $T_SimDistance = 8;  $T_Graphics = 1; $T_Particles = 1
    $T_Mipmap = 2;          $T_BiomeBlend = 2;   $T_MaxFps = 120
    $T_EntityShadows = "true"; $T_Ao = "true";   $T_EntityDistScale = "1.0"
    $T_Xmx = "5G"
    $T_Shaders = $true
    $T_CompProfile = "MEDIUM"
    $T_SoundPhysics = "true"
    $T_Lambdyn = "fancy"
    $T_Continuity = $true
    $T_Skinlayers = $true
    $T_SodiumAnimateVisibleOnly = $true
    $T_SodiumRenderAhead = 2
} elseif ($Tier -eq "modi") {
    $T_RenderDistance = 16; $T_SimDistance = 12; $T_Graphics = 2; $T_Particles = 0
    $T_Mipmap = 4;          $T_BiomeBlend = 5;   $T_MaxFps = 240
    $T_EntityShadows = "true"; $T_Ao = "true";   $T_EntityDistScale = "1.0"
    $T_Xmx = "8G"
    $T_Shaders = $true
    $T_CompProfile = "HIGH"
    $T_SoundPhysics = "true"
    $T_Lambdyn = "fancy"
    $T_Continuity = $true
    $T_Skinlayers = $true
    $T_SodiumAnimateVisibleOnly = $false
    $T_SodiumRenderAhead = 3
}

# --- OS default game directory ---
if ([string]::IsNullOrEmpty($Dir)) {
    $Dir = Join-Path $env:APPDATA ".minecraft"
}
$TargetDir = $Dir

if (-not (Test-Path -Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    Write-Warn2 "Game directory did not exist and was created at: $TargetDir"
    Write-Warn2 "Please launch vanilla $FabricMcVersion once from your launcher first so assets download, then re-run this installer."
}

Write-Log "[0/8] Using game directory: $TargetDir"

$ModsDir = Join-Path $TargetDir "mods"
if (-not (Test-Path -Path $ModsDir)) {
    New-Item -ItemType Directory -Force -Path $ModsDir | Out-Null
}

# --- reconcile the Sodium/Iris stack with the tier BEFORE anything downloads or the
# duplicate check runs, so switching tiers never leaves two Sodium jars or a stray
# Iris behind. (shaderpacks\ is left untouched -- the zips are harmless.)
if (-not $T_Shaders) {
    # dalit: no shaders. Strip Iris and the Sodium 0.8.7 build left by a shader tier;
    # base Sodium 0.8.14 is (re)downloaded in step [5].
    Get-ChildItem -Path $ModsDir -Filter "iris-fabric-*.jar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Log "Tier '$Tier': removing Iris (this tier has no shaders): $($_.Name)"
        Remove-Item -Force $_.FullName
    }
    Get-ChildItem -Path $ModsDir -Filter "sodium-fabric-0.8.7*.jar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Log "Tier '$Tier': removing shader Sodium build: $($_.Name)"
        Remove-Item -Force $_.FullName
    }
} else {
    # pandit/modi: Iris 1.10.7 pins Sodium 0.8.7, so remove the base 0.8.14 build left
    # by dalit; Sodium 0.8.7 and Iris are (re)downloaded in step [5].
    $OldSodiumPath = Join-Path $ModsDir $SodiumBaseJar
    if (Test-Path -LiteralPath $OldSodiumPath) {
        Write-Log "Tier '$Tier': removing base Sodium ($SodiumBaseJar); Iris requires Sodium 0.8.7"
        Remove-Item -Force $OldSodiumPath
    }
}

# --- effective download table + manifest for this run (depends on the tier's shader stack) ---
# dalit keeps sodium 0.8.14; pandit/modi drop it and add sodium 0.8.7 + Iris.
$EffectiveRows = @()
foreach ($rawLine in ($ModsTable -split "`n")) {
    $l = $rawLine.Trim()
    if ($l -eq "") { continue }
    $parts = $l -split " "
    if ($T_Shaders -and ($parts[0] -eq $SodiumBaseJar)) { continue }
    $EffectiveRows += ,@($parts[0], $parts[1], $parts[2])
}
if ($T_Shaders) {
    $EffectiveRows += ,@($SodiumShadersJar, $SodiumShadersSha256, $SodiumShadersUrl)
    $EffectiveRows += ,@($IrisJar, $IrisSha256, $IrisUrl)
    $ExpectedJarCount = 38
    $ExpectedSodiumJar = $SodiumShadersJar
} else {
    $ExpectedJarCount = 37
    $ExpectedSodiumJar = $SodiumBaseJar
}

# filename -> sha256 map for the final verification gate and the dup-check.
$EffectiveManifest = @{}
foreach ($row in $EffectiveRows) { $EffectiveManifest[$row[0]] = $row[1] }

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("fabric-friends-installer-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

try {

    # --- A/B: vanilla base version ---
    $VersionDir = Join-Path $TargetDir "versions\$FabricMcVersion"
    $VersionJson = Join-Path $VersionDir "$FabricMcVersion.json"
    $VersionJar = Join-Path $VersionDir "$FabricMcVersion.jar"

    if ((Test-Path $VersionJson) -and (Test-Path $VersionJar)) {
        Write-Log "[1/8] Vanilla $FabricMcVersion base version already present, skipping."
    } else {
        Write-Log "[1/8] Installing vanilla $FabricMcVersion base version..."
        New-Item -ItemType Directory -Force -Path $VersionDir | Out-Null

        $ManifestPath = Join-Path $TempDir "version_manifest_v2.json"
        Invoke-Download -Url $VersionManifestUrl -Dest $ManifestPath

        $ManifestData = Get-Content -Raw -Path $ManifestPath | ConvertFrom-Json
        $VersionEntry = $ManifestData.versions | Where-Object { $_.id -eq $FabricMcVersion } | Select-Object -First 1
        if ($null -eq $VersionEntry) {
            Fail "Could not find version $FabricMcVersion in $VersionManifestUrl"
        }

        Invoke-Download -Url $VersionEntry.url -Dest $VersionJson

        $VersionData = Get-Content -Raw -Path $VersionJson | ConvertFrom-Json
        $ClientUrl = $VersionData.downloads.client.url
        $ClientSha1 = $VersionData.downloads.client.sha1

        if ([string]::IsNullOrEmpty($ClientUrl)) {
            Fail "Could not read downloads.client.url from $VersionJson"
        }
        if ([string]::IsNullOrEmpty($ClientSha1)) {
            Fail "Could not read downloads.client.sha1 from $VersionJson"
        }

        Invoke-Download -Url $ClientUrl -Dest $VersionJar

        $ActualSha1 = Get-Sha1 -path $VersionJar
        if ($ActualSha1 -ne $ClientSha1) {
            Remove-Item -Force $VersionJar
            Fail "SHA-1 mismatch for $VersionJar : expected $ClientSha1, got $ActualSha1"
        }
        Write-Log "Vanilla $FabricMcVersion client jar verified."
    }

    # --- C: fabric loader profile ---
    Write-Log "[2/8] Installing Fabric loader profile ($FabricLoaderId)..."
    $ProfileJsonPath = Join-Path $TempDir "fabric_profile.json"
    Invoke-Download -Url $FabricProfileUrl -Dest $ProfileJsonPath

    $ProfileRaw = Get-Content -Raw -Path $ProfileJsonPath
    if ($ProfileRaw -notmatch '"inheritsFrom"') {
        Fail "Fabric profile response missing `"inheritsFrom`": $FabricProfileUrl"
    }
    if ($ProfileRaw -notmatch [regex]::Escape("net.fabricmc.loader.impl.launch.knot.KnotClient")) {
        Fail "Fabric profile response missing KnotClient main class: $FabricProfileUrl"
    }

    $ProfileData = $ProfileRaw | ConvertFrom-Json
    $ProfileId = $ProfileData.id
    if ([string]::IsNullOrEmpty($ProfileId)) {
        Fail "Could not read id from Fabric profile response"
    }
    if ($ProfileId -ne $FabricLoaderId) {
        Write-Warn2 "Fabric profile id ($ProfileId) differs from expected ($FabricLoaderId); continuing with actual id."
    }

    $FabricVersionDir = Join-Path $TargetDir "versions\$ProfileId"
    New-Item -ItemType Directory -Force -Path $FabricVersionDir | Out-Null
    Copy-Item -Force -Path $ProfileJsonPath -Destination (Join-Path $FabricVersionDir "$ProfileId.json")
    Write-Log "Fabric loader profile written to versions\$ProfileId\$ProfileId.json"

    # --- D: launcher_profiles.json ---
    Write-Log "[3/8] Registering launcher profile..."
    $LauncherProfilesPath = Join-Path $TargetDir "launcher_profiles.json"

    # The tier's RAM allocation goes in the profile's javaArgs field (the launcher
    # otherwise applies its own default JVM args).
    $JavaArgs = "-Xmx$T_Xmx -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"

    try {
        if (Test-Path $LauncherProfilesPath) {
            $LauncherData = Get-Content -Raw -Path $LauncherProfilesPath | ConvertFrom-Json
        } else {
            $LauncherData = '{"profiles":{},"settings":{},"version":3}' | ConvertFrom-Json
        }

        if ($null -eq $LauncherData.profiles) {
            $LauncherData | Add-Member -MemberType NoteProperty -Name "profiles" -Value (New-Object PSObject) -Force
        }

        # Preserve any other fields on our profile object; only our known keys are authoritative.
        if ($LauncherData.profiles.PSObject.Properties.Name -contains "fabric-loader-1.21.11") {
            $NewProfile = $LauncherData.profiles."fabric-loader-1.21.11"
        } else {
            $NewProfile = New-Object PSObject
        }
        if (-not ($NewProfile.PSObject.Properties.Name -contains "created")) {
            $NewProfile | Add-Member -MemberType NoteProperty -Name "created" -Value "2026-08-11T00:00:00.000Z" -Force
        }
        $NewProfile | Add-Member -MemberType NoteProperty -Name "name" -Value "fabric-loader-1.21.11" -Force
        $NewProfile | Add-Member -MemberType NoteProperty -Name "type" -Value "custom" -Force
        $NewProfile | Add-Member -MemberType NoteProperty -Name "lastVersionId" -Value $ProfileId -Force
        $NewProfile | Add-Member -MemberType NoteProperty -Name "icon" -Value "TNT" -Force
        $NewProfile | Add-Member -MemberType NoteProperty -Name "javaArgs" -Value $JavaArgs -Force

        if ($LauncherData.profiles.PSObject.Properties.Name -contains "fabric-loader-1.21.11") {
            $LauncherData.profiles."fabric-loader-1.21.11" = $NewProfile
        } else {
            $LauncherData.profiles | Add-Member -MemberType NoteProperty -Name "fabric-loader-1.21.11" -Value $NewProfile -Force
        }

        ($LauncherData | ConvertTo-Json -Depth 10) | Set-Content -Path $LauncherProfilesPath -Encoding UTF8
        Write-Log "launcher_profiles.json updated (tier '$Tier': javaArgs -Xmx$T_Xmx)."
    } catch {
        Write-Warn2 "Failed to update launcher_profiles.json ($($_.Exception.Message)); skipping. Select the $ProfileId version manually in TLauncher."
    }

    # --- E: remove server-only jars ---
    Write-Log "[4/8] Removing server-only jars from mods\ (if present)..."
    foreach ($prefix in $ServerOnlyPrefixes) {
        $found = Get-ChildItem -Path $ModsDir -Filter "$prefix*" -File -ErrorAction SilentlyContinue
        foreach ($m in $found) {
            Write-Log "Removing server-only jar: $($m.Name)"
            Remove-Item -Force $m.FullName
        }
    }

    # --- F: download + verify every file for this tier from the Modrinth CDN ---
    Write-Log "[5/8] Downloading and verifying mods, resourcepack, and shaders (this transfers ~145 MB on a fresh install)..."
    $ResourcepacksDir = Join-Path $TargetDir "resourcepacks"
    $ResourcepackDest = Join-Path $ResourcepacksDir $ResourcepackName
    $ShaderpacksDir = Join-Path $TargetDir "shaderpacks"

    # 5a: every mod jar for this tier -> mods\
    foreach ($row in $EffectiveRows) {
        Invoke-DownloadVerify $row[0] $row[1] $row[2] $ModsDir
    }

    # 5b: the resourcepack -> resourcepacks\ (filename has a space)
    Invoke-DownloadVerify $ResourcepackName $ResourcepackSha256 $ResourcepackUrl $ResourcepacksDir

    # 5c: shader stack -- Complementary shaderpack -> shaderpacks\ (pandit/modi only;
    # Iris and Sodium 0.8.7 are part of $EffectiveRows above and land in mods\).
    if ($T_Shaders) {
        Invoke-DownloadVerify $ShaderpackZip $ShaderpackSha256 $ShaderpackUrl $ShaderpacksDir
        Write-Log "Shaders installed for '$Tier': Iris, Sodium 0.8.7, Complementary Unbound (shaderpacks\$ShaderpackZip)."
    }

    # --- G: modflared forced-tunnels config (written to both locations modflared reads) ---
    Write-Log "[6/8] Writing modflared forced_tunnels.json..."
    foreach ($d in @((Join-Path $TargetDir "config\modflared"), (Join-Path $TargetDir "modflared"))) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
        $ForcedTunnelsPath = Join-Path $d "forced_tunnels.json"
        [System.IO.File]::WriteAllText($ForcedTunnelsPath, $ForcedTunnelsJson + "`n", $Utf8NoBom)
        Write-Log "Wrote $ForcedTunnelsPath"
    }

    # --- G.7: tier config ---
    # A tier is always set by this point. Every config path below was verified against
    # the mod jar; mods whose path could not be verified are deliberately left unset.
    Write-Log "[7/8] Writing '$Tier' tier config..."

    # options.txt -- vanilla, colon-separated. Merge: replace only the tier keys,
    # keep every other line, append any that are absent.
    $OptionsTxt = Join-Path $TargetDir "options.txt"
    $optAction = Get-ConfigAction $OptionsTxt
    $optPairs = [ordered]@{
        "renderDistance"        = $T_RenderDistance
        "simulationDistance"    = $T_SimDistance
        "graphicsMode"          = $T_Graphics
        "particles"             = $T_Particles
        "mipmapLevels"          = $T_Mipmap
        "biomeBlendRadius"      = $T_BiomeBlend
        "maxFps"                = $T_MaxFps
        "entityShadows"         = $T_EntityShadows
        "ao"                    = $T_Ao
        "entityDistanceScaling" = $T_EntityDistScale
    }
    Merge-KvFile $OptionsTxt ":" $optPairs
    Write-Log "options.txt ($Tier, $optAction): renderDistance=$T_RenderDistance simulationDistance=$T_SimDistance graphicsMode=$T_Graphics particles=$T_Particles mipmapLevels=$T_Mipmap biomeBlendRadius=$T_BiomeBlend maxFps=$T_MaxFps entityShadows=$T_EntityShadows ao=$T_Ao entityDistanceScaling=$T_EntityDistScale"

    # Enable the Presence Footsteps resourcepack (all tiers) -- copying it does not
    # switch it on. Merged into resourcePacks so a friend's enabled packs are kept.
    Enable-Resourcepack $OptionsTxt "file/$ResourcepackName"
    Write-Log "options.txt ($Tier): resourcePacks += `"file/$ResourcepackName`""

    # Sodium -- config\sodium-options.json. GSON field naming is
    # LOWER_CASE_WITH_UNDERSCORES, so the JSON keys are snake_case (NOT the Java
    # field names). Only confirmed primitive fields; no enum-valued fields.
    $SodiumJson = Join-Path $TargetDir "config\sodium-options.json"
    $sodAction = Get-ConfigAction $SodiumJson
    Merge-JsonFile $SodiumJson @{
        performance = @{
            chunk_builder_threads         = 0
            use_entity_culling            = $true
            use_fog_occlusion             = $true
            use_block_face_culling        = $true
            animate_only_visible_textures = $T_SodiumAnimateVisibleOnly
        }
        advanced = @{ cpu_render_ahead_limit = $T_SodiumRenderAhead }
        quality  = @{ hidden_fluid_culling = $true }
    }
    Write-Log "config\sodium-options.json ($Tier, $sodAction): animate_only_visible_textures=$T_SodiumAnimateVisibleOnly cpu_render_ahead_limit=$T_SodiumRenderAhead + culling on"

    # Sound Physics Remastered -- config\soundphysics.properties, key "enabled".
    $SoundPhysicsProps = Join-Path $TargetDir "config\soundphysics.properties"
    $spAction = Get-ConfigAction $SoundPhysicsProps
    Merge-KvFile $SoundPhysicsProps "=" ([ordered]@{ "enabled" = $T_SoundPhysics })
    Write-Log "config\soundphysics.properties ($Tier, $spAction): enabled=$T_SoundPhysics"

    # Continuity -- config\continuity.json. "off" disables connected + emissive textures.
    $ContinuityJson = Join-Path $TargetDir "config\continuity.json"
    $contAction = Get-ConfigAction $ContinuityJson
    Merge-JsonFile $ContinuityJson @{ connected_textures = $T_Continuity; emissive_textures = $T_Continuity }
    Write-Log "config\continuity.json ($Tier, $contAction): connected_textures=$T_Continuity emissive_textures=$T_Continuity"

    # 3D Skin Layers -- config\skinlayers.json. No single master toggle; the 3D layers
    # are the per-body-part flags, so "off" clears them all, "on" sets them.
    $SkinlayersJson = Join-Path $TargetDir "config\skinlayers.json"
    $skinAction = Get-ConfigAction $SkinlayersJson
    Merge-JsonFile $SkinlayersJson @{
        enableHat        = $T_Skinlayers
        enableJacket     = $T_Skinlayers
        enableLeftSleeve = $T_Skinlayers
        enableRightSleeve = $T_Skinlayers
        enableLeftPants  = $T_Skinlayers
        enableRightPants = $T_Skinlayers
    }
    Write-Log "config\skinlayers.json ($Tier, $skinAction): all 3D layer parts=$T_Skinlayers"

    # LambDynamicLights -- config\lambdynlights.toml, key "mode" (a quoted enum string).
    # The ONLY valid values are fastest / fast / fancy -- there is no "off" (confirmed
    # against DynamicLightsMode in the 4.9.1 jar). Writing "off" is an invalid enum that
    # silently falls back to the default (fancy), leaving lights ON. To disable dynamic
    # lighting for dalit we set the cheapest valid mode AND turn off every source in the
    # [light_sources] table. pandit/modi keep mode="fancy" with the mod's default sources.
    $LambdynToml = Join-Path $TargetDir "config\lambdynlights.toml"
    $lambAction = Get-ConfigAction $LambdynToml
    Set-TomlString $LambdynToml "mode" $T_Lambdyn
    if ($Tier -eq "dalit") {
        Set-LambdynLightsOff $LambdynToml
        Write-Log "config\lambdynlights.toml ($Tier, $lambAction): mode=`"$T_Lambdyn`" + all [light_sources] disabled"
    } else {
        Write-Log "config\lambdynlights.toml ($Tier, $lambAction): mode=`"$T_Lambdyn`""
    }

    # NOTE: Cull Leaves (config\cullleaves.json, key "enabled") and ImmediatelyFast are
    # ON for every tier. Cull Leaves defaults to enabled and ImmediatelyFast has no
    # master enable field (a pure optimizer, active once installed), so neither needs
    # a written config -- installing the jar is "on".

    # Iris (pandit/modi only) -- point it at the shaderpack, enable it, and set the
    # tier's Complementary profile. Iris stores the selected pack in
    # config\iris.properties (java.util.Properties) and per-shaderpack options --
    # including the profile -- in shaderpacks\<shaderPack>.txt, where <shaderPack> is
    # exactly the iris.properties "shaderPack" value (the .zip name for a zip pack).
    # Confirmed against the Iris jar: Iris.class resolves
    # getShaderpacksDirectory().resolve(name + ".txt") and reads "profile" via
    # queueShaderPackOptionsFromProperties.
    if ($T_Shaders) {
        $IrisProperties = Join-Path $TargetDir "config\iris.properties"
        $irisAction = Get-ConfigAction $IrisProperties
        Merge-KvFile $IrisProperties "=" ([ordered]@{ "shaderPack" = $ShaderpackZip; "enableShaders" = "true" })
        Write-Log "config\iris.properties ($Tier, $irisAction): shaderPack=$ShaderpackZip, enableShaders=true"

        $ShaderpackOptionsTxt = Join-Path $ShaderpacksDir "$ShaderpackZip.txt"
        $profAction = Get-ConfigAction $ShaderpackOptionsTxt
        Merge-KvFile $ShaderpackOptionsTxt "=" ([ordered]@{ "profile" = $T_CompProfile })
        Write-Log "shaderpacks\$ShaderpackZip.txt ($Tier, $profAction): profile=$T_CompProfile"
    }

    # --- H: verify all mod jars ---
    # dalit: 37 jars, Sodium 0.8.14-beta.2.
    # pandit/modi: 38 jars in mods\ (Sodium swapped to 0.8.7, plus Iris); the shaderpack
    # zip lives in shaderpacks\ and was verified on download. The resourcepack lives in
    # resourcepacks\ and is verified separately below.
    Write-Log "[8/8] Verifying all $ExpectedJarCount mod jars by SHA-256..."

    # --- H.1: hard-fail on duplicate mods (two files for the same mod). This must run
    # BEFORE the exactly-one-Sodium cleanup below, so a duplicate that was NOT produced
    # by our own tier logic (e.g. a stray copy a user dropped in manually) is reported
    # and aborted rather than silently deleted out from under them. ---
    $ModKeyFiles = @{}
    $AllJars = Get-ChildItem -Path $ModsDir -Filter "*.jar" -File -ErrorAction SilentlyContinue
    foreach ($jarFile in $AllJars) {
        $bn = $jarFile.Name
        if ($bn -like "tl_skin_cape*.jar") { continue }

        $matched = $null
        foreach ($prefix in $KnownModPrefixes) {
            if ($bn.StartsWith($prefix)) {
                $matched = $prefix
                break
            }
        }

        if ($matched) {
            if (-not $ModKeyFiles.ContainsKey($matched)) {
                $ModKeyFiles[$matched] = @()
            }
            $ModKeyFiles[$matched] += $bn
        } else {
            if (-not $EffectiveManifest.ContainsKey($bn)) {
                Write-Warn2 "Unrecognized extra jar in mods\: $bn (not part of the expected pack; leaving in place)"
            }
        }
    }

    foreach ($prefix in $KnownModPrefixes) {
        if (-not $ModKeyFiles.ContainsKey($prefix)) { continue }
        $files = $ModKeyFiles[$prefix]
        if ($files.Count -gt 1) {
            $expectedName = $EffectiveManifest.Keys | Where-Object { $_.StartsWith($prefix) } | Select-Object -First 1
            Write-Host ("ERROR: Duplicate mod detected for prefix `"$prefix`" -- two versions of one mod will crash the game:") -ForegroundColor Red
            foreach ($fn in $files) {
                Write-Host "  - $fn" -ForegroundColor Red
            }
            if ($expectedName) {
                Write-Host ("  Keep `"$expectedName`" (expected) and delete the other file(s) listed above.") -ForegroundColor Red
            } else {
                Write-Host "  Delete all but one of the files listed above." -ForegroundColor Red
            }
            Fail "Duplicate mod jars found in $ModsDir."
        }
    }

    # --- H.2: guarantee exactly one Sodium jar before the manifest check. The expected
    # build is tier-decided (dalit -> 0.8.14-beta.2, pandit/modi -> 0.8.7). This is the
    # only automatic removal in the gate; it only ever runs on the state our own tier
    # logic leaves behind, since H.1 above already aborted on any duplicate a user
    # introduced by hand. ---
    Get-ChildItem -Path $ModsDir -Filter "sodium-fabric-*.jar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -ne $ExpectedSodiumJar) {
            Write-Log "Removing unexpected Sodium jar: $($_.Name) (keeping $ExpectedSodiumJar)"
            Remove-Item -Force $_.FullName
        }
    }

    # --- H.3: every expected filename exists with the right hash ---
    $Missing = @()
    $Mismatched = @()
    $VerifiedCount = 0

    foreach ($fname in $EffectiveManifest.Keys) {
        $expected = $EffectiveManifest[$fname]
        $target = Join-Path $ModsDir $fname
        if (-not (Test-Path $target)) {
            $Missing += $fname
            continue
        }
        $actual = Get-Sha256 -path $target
        if ($actual -ne $expected) {
            $Mismatched += "$fname(expected=$expected,got=$actual)"
            continue
        }
        $VerifiedCount++
    }

    if ($Missing.Count -gt 0 -or $Mismatched.Count -gt 0) {
        if ($Missing.Count -gt 0) {
            Write-Host ("ERROR: Missing mod jars in $ModsDir : " + ($Missing -join ", ")) -ForegroundColor Red
        }
        if ($Mismatched.Count -gt 0) {
            Write-Host ("ERROR: Mismatched mod jars in $ModsDir : " + ($Mismatched -join ", ")) -ForegroundColor Red
        }
        Fail "Mod jar verification failed. See errors above."
    }

    # --- H.4: verify the resourcepack (same SHA-256 gate as the jars) ---
    if (-not (Test-Path -LiteralPath $ResourcepackDest)) {
        Fail "Missing resourcepack in $ResourcepacksDir : $ResourcepackName"
    }
    $RpActual = Get-Sha256 -path $ResourcepackDest
    if ($RpActual -ne $ResourcepackSha256) {
        Fail "SHA-256 mismatch for resourcepack '$ResourcepackName' : expected $ResourcepackSha256, got $RpActual"
    }

    Write-Log "All $ExpectedJarCount mod jars + the resourcepack verified."

    # --- I: final summary ---
    Write-Log "Install complete."
    Write-Log "Game directory: $TargetDir"
    Write-Log "Select this version in your launcher: $ProfileId"
    Write-Log "Verified jar count: $VerifiedCount / $ExpectedJarCount (+ 1 resourcepack)"
    if ($T_Shaders) {
        Write-Log "Tier applied: $Tier (RAM -Xmx$T_Xmx; shaders ON: Iris + Sodium 0.8.7 + Complementary $T_CompProfile)."
    } else {
        Write-Log "Tier applied: $Tier (RAM -Xmx$T_Xmx; no shaders, Sodium 0.8.14-beta.2)."
    }
    Write-Log "Reminder: do not add OptiFine - Sodium is included."

} finally {
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force -Path $TempDir -ErrorAction SilentlyContinue
    }
}

exit 0
