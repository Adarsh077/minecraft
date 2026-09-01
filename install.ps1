<#
Fabric Friends Client Pack installer for Minecraft 1.21.11 / Fabric loader 0.19.3
PowerShell 5.1 compatible. No Java required at any point.
#>

param(
    [string]$Dir = "",
    [string]$Zip = "",
    [switch]$Shaders,
    [switch]$NoShaders
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$FabricMcVersion = "1.21.11"
$FabricLoaderVersion = "0.19.3"
$FabricLoaderId = "fabric-loader-$FabricLoaderVersion-$FabricMcVersion"
$VersionManifestUrl = "https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
$FabricProfileUrl = "https://meta.fabricmc.net/v2/versions/loader/$FabricMcVersion/$FabricLoaderVersion/profile/json"
$PackZipUrl = "https://drive.usercontent.google.com/download?id=1xrjCldCkGCgfdKuBf9tUxS_N4Sfqz-FE&export=download&confirm=t"
$PackZipSha256 = "1c0a7c9fb578d459bf236cc5d9dad597f18fa1b6581486186fdd63ba0e2709d1"
$PackDirInZip = "fabric-1.21.11-friends-client-pack\mods"

$ServerOnlyPrefixes = @("graves-", "polymer-bundled-", "repurposed_structures-", "midnightlib-fabric-", "FallingTree-")

# --- optional -Shaders extras (client-visual only, does not affect server compatibility) ---
# Iris 1.10.7 hard-pins Sodium 0.8.7, which replaces the base pack's 0.8.14-beta.2.
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

# --- 24-jar manifest: filename -> sha256 ---
$Manifest = @{
    "Adorn-7.6.1+1.21.11-fabric.jar"                       = "d431be4ee89d0d71b1ababedaa5275f478cfff5de94eba1165f5cd10d1b676d3"
    "balm-fabric-1.21.11-21.11.9.1.jar"                    = "e957283fcf3d1a3bc1a832db74fa80b03b770eb61d2875de644e66da84bb0390"
    "BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar"          = "89d39707bc095516ba1bf4f162628dfba51dd58a3bcac14c74a14ffefc18f00a"
    "carryon-fabric-1.21.11-2.9.2.jar"                     = "ac6c68baf2cbffef7de6739423aa615f151c8f1601bacf30921c8bd88f3f932d"
    "fabric-api-0.141.6+1.21.11.jar"                       = "bdff7fd7e220085cfad2ff9b1f40dde6534ae0b96cf378f97a374bc54cb9ed0f"
    "fabric-language-kotlin-1.13.13+kotlin.2.4.10.jar"     = "34ccdacf13bb9351fe43ce61912c2e09b72364e43e787d36ba3d2d04dec75a52"
    "FantasticWings-v21.11.1-mc1.21.11-Fabric.jar"         = "b7cc2eb1814fe5c5eb3b0b3e6af399d4be0bcda44af3bd9b02994fdd6f3d7e43"
    "FarmersDelight-1.21.11-3.6.13+refabricated.jar"       = "3b3caa7a3c9b7ddc0a28f620ec729da6ab00a181fd8667de104324a5bb9015d1"
    "ferritecore-8.2.0-fabric.jar"                         = "f76bd760cbf48280cc7c43180f5089a46235fa24d934a8acf3da04a664c2c715"
    "ForgeConfigAPIPort-v21.11.1-mc1.21.11-Fabric.jar"     = "31a0686904fad1cfdeb1d6b011ac1c2280990d6e76ac2416468147e2246b4db1"
    "GlitchCore-fabric-1.21.11-21.11.0.4.jar"              = "8c5b3912d167640f1911982781578ccfb3fbb11e73fcee319c7ff44045a6e8ef"
    "InventoryProfilesNext-fabric-1.21.11-2.2.6.jar"       = "1d971f0f624c8f2d2693004aff96cb9546d65e3ab950d63563c769242d2c6474"
    "Jade-1.21.11-Fabric-21.1.6.jar"                       = "bcf1a7f6f9eb325b89d65bc15b41a35fdca2c2b052e9af772ffdcd70548d2fc8"
    "jei-1.21.11-fabric-27.23.0.71.jar"                    = "e904a724d7e2b5b2382b1f46f8d3efe84cb6a955ee6fe5310e8a173cf881ffb6"
    "libIPN-fabric-1.21.11-6.6.3.jar"                      = "94a52d56ec41e31a98089aeff07baf25534986922d572eac85475b5e2736c9af"
    "lithium-fabric-0.21.4+mc1.21.11.jar"                  = "5135c41da5b43cbdcb29424bde65195143ac4084e23834c8eac065942201c78b"
    "mdm-26.7.0-fabric-1.21.11.jar"                        = "dded3b56d982410de040d7e0c3f3e068876f126bc4077c9a426d90f1695abe0b"
    "modflared-1.6.0+release.129.jar"                      = "5389a4c89dc91ad1edabff96c92d98cec85a5fc0a6e8120885f04cfd3f371943"
    "PuzzlesLib-v21.11.13-mc1.21.11-Fabric.jar"            = "1c7b062f4d4fd4c830dbaa875da01706ef85f072969191d8c1affef693a66b82"
    "sodium-fabric-0.8.14-beta.2+mc1.21.11.jar"            = "24990c1c497bdda4605c595f4ee65aaf32f724b1498a33c63f43cb4500280c51"
    "StorageDrawers-fabric-1.21.11-20.0.0.jar"             = "5910484b2ad3813094600a229ef95bc6947cfe3815869b6fa418b139a037fdf9"
    "TerraBlender-fabric-1.21.11-21.11.0.0.jar"            = "3f0567c194d579677b42dd57eeb912e4e558ca069f4fc525213d182e60113772"
    "travelersbackpack-fabric-1.21.11-10.11.10.jar"        = "d9f42b1bafd29d84fd97b5b6e51c948f0ed7d1251c0deed40e512870ea5980fb"
    "waystones-fabric-1.21.11-21.11.9.jar"                 = "6ce002c05655969f528dc1a1eb335a567caa6eaaf95715a86770a066b693f470"
}

# --- 5 author-hosted mods to fetch directly from Modrinth CDN ---
$AuthorUrls = @(
    "https://cdn.modrinth.com/data/LOpKHB2A/versions/MydMW2TT/waystones-fabric-1.21.11-21.11.9.jar",
    "https://cdn.modrinth.com/data/HXF82T3G/versions/JJKbM72H/BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar",
    "https://cdn.modrinth.com/data/TmUXSYKk/versions/q1Kv9EdP/mdm-26.7.0-fabric-1.21.11.jar",
    "https://cdn.modrinth.com/data/MBAkmtvl/versions/5POKgjJn/balm-fabric-1.21.11-21.11.9.1.jar",
    "https://cdn.modrinth.com/data/s3dmwKy5/versions/CO7NeLTt/GlitchCore-fabric-1.21.11-21.11.0.4.jar"
)

# --- known mod-name prefixes, used for duplicate-mod detection ---
$KnownModPrefixes = @(
    "sodium-fabric-", "iris-fabric-", "fabric-api-", "lithium-fabric-", "ferritecore-",
    "Adorn-", "balm-fabric-", "BiomesOPlenty-fabric-", "carryon-fabric-",
    "fabric-language-kotlin-", "FantasticWings-", "FarmersDelight-", "ForgeConfigAPIPort-",
    "GlitchCore-fabric-", "InventoryProfilesNext-fabric-", "Jade-", "jei-", "libIPN-fabric-",
    "mdm-", "modflared-", "PuzzlesLib-", "StorageDrawers-fabric-", "TerraBlender-fabric-",
    "travelersbackpack-fabric-", "waystones-fabric-"
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

function Get-Sha256($path) {
    return (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()
}

function Get-Sha1($path) {
    return (Get-FileHash -Algorithm SHA1 -Path $path).Hash.ToLowerInvariant()
}

function Invoke-Download($Url, $Dest) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Dest
    } catch {
        Fail "Download failed: $Url ($($_.Exception.Message))"
    }
}

if ($Shaders -and $NoShaders) {
    Fail "-Shaders and -NoShaders cannot both be given"
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

Write-Log "[0/9] Using game directory: $TargetDir"

$ModsDir = Join-Path $TargetDir "mods"
if (-not (Test-Path -Path $ModsDir)) {
    New-Item -ItemType Directory -Force -Path $ModsDir | Out-Null
}

# --- sticky shader-mode detection ---
# If Iris is already installed and neither -Shaders nor -NoShaders was
# passed, treat this run as shader mode anyway so a plain re-run over a
# shader install never mixes two Sodium jars together.
if ((-not $Shaders) -and (-not $NoShaders)) {
    $ExistingIris = Get-ChildItem -Path $ModsDir -Filter "iris-fabric-*.jar" -File -ErrorAction SilentlyContinue
    if ($ExistingIris) {
        $Shaders = $true
        Write-Log "Existing Iris install detected; keeping shaders enabled (pass -NoShaders to remove)."
    }
}

# --- explicit -NoShaders: strip Iris + the shader Sodium build ---
if ($NoShaders) {
    Write-Log "Disabling shaders (-NoShaders)..."
    Get-ChildItem -Path $ModsDir -Filter "iris-fabric-*.jar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Log "Removing: $($_.Name)"
        Remove-Item -Force $_.FullName
    }
    Get-ChildItem -Path $ModsDir -Filter "sodium-fabric-0.8.7*.jar" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Log "Removing: $($_.Name)"
        Remove-Item -Force $_.FullName
    }
    Write-Log "Leaving shaderpacks\ untouched (shader zips are harmless); remove manually if you don't want them."
}

# --- effective manifest for this run (depends on final $Shaders state) ---
$EffectiveManifest = $Manifest.Clone()
$ExpectedJarCount = 24
$ExpectedSodiumJar = $SodiumBaseJar
if ($Shaders) {
    $EffectiveManifest.Remove($SodiumBaseJar)
    $EffectiveManifest[$SodiumShadersJar] = $SodiumShadersSha256
    $EffectiveManifest[$IrisJar] = $IrisSha256
    $ExpectedJarCount = 25
    $ExpectedSodiumJar = $SodiumShadersJar
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("fabric-friends-installer-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

try {

    # --- A/B: vanilla base version ---
    $VersionDir = Join-Path $TargetDir "versions\$FabricMcVersion"
    $VersionJson = Join-Path $VersionDir "$FabricMcVersion.json"
    $VersionJar = Join-Path $VersionDir "$FabricMcVersion.jar"

    if ((Test-Path $VersionJson) -and (Test-Path $VersionJar)) {
        Write-Log "[1/9] Vanilla $FabricMcVersion base version already present, skipping."
    } else {
        Write-Log "[1/9] Installing vanilla $FabricMcVersion base version..."
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
    Write-Log "[2/9] Installing Fabric loader profile ($FabricLoaderId)..."
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
    Write-Log "[3/9] Registering launcher profile..."
    $LauncherProfilesPath = Join-Path $TargetDir "launcher_profiles.json"

    try {
        if (Test-Path $LauncherProfilesPath) {
            $LauncherData = Get-Content -Raw -Path $LauncherProfilesPath | ConvertFrom-Json
        } else {
            $LauncherData = '{"profiles":{},"settings":{},"version":3}' | ConvertFrom-Json
        }

        if ($null -eq $LauncherData.profiles) {
            $LauncherData | Add-Member -MemberType NoteProperty -Name "profiles" -Value (New-Object PSObject) -Force
        }

        $NewProfile = New-Object PSObject
        $NewProfile | Add-Member -MemberType NoteProperty -Name "name" -Value "fabric-loader-1.21.11"
        $NewProfile | Add-Member -MemberType NoteProperty -Name "type" -Value "custom"
        $NewProfile | Add-Member -MemberType NoteProperty -Name "created" -Value "2026-08-11T00:00:00.000Z"
        $NewProfile | Add-Member -MemberType NoteProperty -Name "lastVersionId" -Value $ProfileId
        $NewProfile | Add-Member -MemberType NoteProperty -Name "icon" -Value "TNT"

        if ($LauncherData.profiles.PSObject.Properties.Name -contains "fabric-loader-1.21.11") {
            $LauncherData.profiles."fabric-loader-1.21.11" = $NewProfile
        } else {
            $LauncherData.profiles | Add-Member -MemberType NoteProperty -Name "fabric-loader-1.21.11" -Value $NewProfile -Force
        }

        ($LauncherData | ConvertTo-Json -Depth 10) | Set-Content -Path $LauncherProfilesPath -Encoding UTF8
        Write-Log "launcher_profiles.json updated."
    } catch {
        Write-Warn2 "Failed to update launcher_profiles.json ($($_.Exception.Message)); skipping. Select the $ProfileId version manually in TLauncher."
    }

    # --- E: remove server-only jars ---
    Write-Log "[4/9] Removing server-only jars from mods\ (if present)..."
    foreach ($prefix in $ServerOnlyPrefixes) {
        $matches = Get-ChildItem -Path $ModsDir -Filter "$prefix*" -File -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            Write-Log "Removing server-only jar: $($m.Name)"
            Remove-Item -Force $m.FullName
        }
    }

    # --- F: obtain the bundled pack jars (skip the zip entirely if already good) ---
    Write-Log "[5/9] Obtaining bundled pack jars..."

    # The bundled (zip-sourced) subset of the effective manifest excludes the 5
    # author-hosted (Modrinth) jars and the shader-only files (Iris, shader
    # Sodium), since those are fetched independently, not extracted from the zip.
    $AuthorFilenames = $AuthorUrls | ForEach-Object { [System.IO.Path]::GetFileName($_) }
    $BundledManifest = @{}
    foreach ($fname in $EffectiveManifest.Keys) {
        if ($AuthorFilenames -contains $fname) { continue }
        if ($fname -eq $IrisJar) { continue }
        if ($fname -eq $SodiumShadersJar) { continue }
        $BundledManifest[$fname] = $EffectiveManifest[$fname]
    }

    $BundledAllGood = $true
    foreach ($fname in $BundledManifest.Keys) {
        $btarget = Join-Path $ModsDir $fname
        if (-not (Test-Path $btarget)) {
            $BundledAllGood = $false
            break
        }
        if ((Get-Sha256 -path $btarget) -ne $BundledManifest[$fname]) {
            $BundledAllGood = $false
            break
        }
    }

    if ($BundledAllGood) {
        Write-Log "All bundled pack jars already present and verified; skipping pack download."
    } else {
        $UsingUserZip = -not [string]::IsNullOrEmpty($Zip)
        if ($UsingUserZip) {
            if (-not (Test-Path $Zip)) {
                Fail "-Zip path does not exist: $Zip"
            }
            $PackZipPath = $Zip
        } else {
            $PackZipPath = Join-Path $TempDir "friends-client-pack.zip"
            Write-Log "Downloading pack zip..."
            Invoke-Download -Url $PackZipUrl -Dest $PackZipPath
        }

        # Check it looks like a zip (PK magic), not an HTML interstitial page.
        $FirstBytes = New-Object byte[] 2
        $FileStream = [System.IO.File]::OpenRead($PackZipPath)
        try {
            $FileStream.Read($FirstBytes, 0, 2) | Out-Null
        } finally {
            $FileStream.Close()
        }
        $Magic = [System.Text.Encoding]::ASCII.GetString($FirstBytes)
        if ($Magic -ne "PK") {
            Fail "Downloaded file at $PackZipPath is not a zip (Google Drive may have returned an interstitial page). Download 'Minecraft-Fabric-1.21.11-Friends-Client-Pack.zip' manually from https://drive.google.com/file/d/1xrjCldCkGCgfdKuBf9tUxS_N4Sfqz-FE/view and re-run with -Zip C:\path\to\file.zip"
        }

        if (-not $UsingUserZip) {
            $PackActualSha256 = Get-Sha256 -path $PackZipPath
            if ($PackActualSha256 -ne $PackZipSha256) {
                Fail "SHA-256 mismatch for downloaded pack zip: expected $PackZipSha256, got $PackActualSha256. Download 'Minecraft-Fabric-1.21.11-Friends-Client-Pack.zip' manually from https://drive.google.com/file/d/1xrjCldCkGCgfdKuBf9tUxS_N4Sfqz-FE/view and re-run with -Zip C:\path\to\file.zip"
            }
        } else {
            Write-Log "Note: -Zip provided; skipping the built-in Google Drive hash check (verifying via final per-jar manifest instead)."
        }

        $ExtractDir = Join-Path $TempDir "extracted"
        New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null
        Expand-Archive -Path $PackZipPath -DestinationPath $ExtractDir -Force

        $SrcModsDir = Join-Path $ExtractDir $PackDirInZip
        if (-not (Test-Path $SrcModsDir)) {
            Fail "Expected directory '$PackDirInZip' not found inside the pack zip"
        }

        Get-ChildItem -Path $SrcModsDir -Filter "*.jar" -File | ForEach-Object {
            Copy-Item -Force -Path $_.FullName -Destination (Join-Path $ModsDir $_.Name)
        }
        Write-Log "Bundled pack jars copied to mods\."
    }

    # --- G: 5 author-hosted jars ---
    Write-Log "[6/9] Downloading author-hosted jars from Modrinth CDN..."
    foreach ($url in $AuthorUrls) {
        $fname = [System.IO.Path]::GetFileName($url)
        $dest = Join-Path $ModsDir $fname

        if (-not $Manifest.ContainsKey($fname)) {
            Fail "No manifest entry for expected author-hosted jar: $fname"
        }
        $expectedSha = $Manifest[$fname]

        $skip = $false
        if (Test-Path $dest) {
            $existingSha = Get-Sha256 -path $dest
            if ($existingSha -eq $expectedSha) {
                Write-Log "Already present and verified: $fname"
                $skip = $true
            }
        }

        if (-not $skip) {
            Write-Log "Downloading: $fname"
            $part = "$dest.part"
            Invoke-Download -Url $url -Dest $part
            $actualSha = Get-Sha256 -path $part
            if ($actualSha -ne $expectedSha) {
                Remove-Item -Force $part
                Fail "SHA-256 mismatch for $fname : expected $expectedSha, got $actualSha (url: $url)"
            }
            Move-Item -Force -Path $part -Destination $dest
        }
    }

    # --- G.5: optional shaders (-Shaders, or sticky-detected): Iris + Sodium 0.8.7 + a shader pack ---
    if ($Shaders) {
        Write-Log "[6b/9] Installing shaders (Iris + Sodium 0.8.7 + Complementary Unbound)..."

        $OldSodiumPath = Join-Path $ModsDir $SodiumBaseJar
        if (Test-Path $OldSodiumPath) {
            Write-Log "Removing base Sodium ($SodiumBaseJar) -- Iris 1.10.7 requires Sodium 0.8.7"
            Remove-Item -Force $OldSodiumPath
        }

        $IrisDest = Join-Path $ModsDir $IrisJar
        if ((Test-Path $IrisDest) -and ((Get-Sha256 -path $IrisDest) -eq $IrisSha256)) {
            Write-Log "Already present and verified: $IrisJar"
        } else {
            Write-Log "Downloading: $IrisJar"
            $part = "$IrisDest.part"
            Invoke-Download -Url $IrisUrl -Dest $part
            $actualSha = Get-Sha256 -path $part
            if ($actualSha -ne $IrisSha256) {
                Remove-Item -Force $part
                Fail "SHA-256 mismatch for $IrisJar : expected $IrisSha256, got $actualSha (url: $IrisUrl)"
            }
            Move-Item -Force -Path $part -Destination $IrisDest
        }

        $SodiumDest = Join-Path $ModsDir $SodiumShadersJar
        if ((Test-Path $SodiumDest) -and ((Get-Sha256 -path $SodiumDest) -eq $SodiumShadersSha256)) {
            Write-Log "Already present and verified: $SodiumShadersJar"
        } else {
            Write-Log "Downloading: $SodiumShadersJar"
            $part = "$SodiumDest.part"
            Invoke-Download -Url $SodiumShadersUrl -Dest $part
            $actualSha = Get-Sha256 -path $part
            if ($actualSha -ne $SodiumShadersSha256) {
                Remove-Item -Force $part
                Fail "SHA-256 mismatch for $SodiumShadersJar : expected $SodiumShadersSha256, got $actualSha (url: $SodiumShadersUrl)"
            }
            Move-Item -Force -Path $part -Destination $SodiumDest
        }

        $ShaderpacksDir = Join-Path $TargetDir "shaderpacks"
        New-Item -ItemType Directory -Force -Path $ShaderpacksDir | Out-Null
        $ShaderpackDest = Join-Path $ShaderpacksDir $ShaderpackZip
        if ((Test-Path $ShaderpackDest) -and ((Get-Sha256 -path $ShaderpackDest) -eq $ShaderpackSha256)) {
            Write-Log "Already present and verified: $ShaderpackZip"
        } else {
            Write-Log "Downloading: $ShaderpackZip"
            $part = "$ShaderpackDest.part"
            Invoke-Download -Url $ShaderpackUrl -Dest $part
            $actualSha = Get-Sha256 -path $part
            if ($actualSha -ne $ShaderpackSha256) {
                Remove-Item -Force $part
                Fail "SHA-256 mismatch for $ShaderpackZip : expected $ShaderpackSha256, got $actualSha (url: $ShaderpackUrl)"
            }
            Move-Item -Force -Path $part -Destination $ShaderpackDest
        }

        Write-Log "Shaders installed: Iris, Sodium 0.8.7, Complementary Unbound shaderpack (shaderpacks\$ShaderpackZip)."
    }

    # --- H: verify all mod jars ---
    # Without -Shaders: 24 jars, Sodium 0.8.14-beta.2.
    # With -Shaders: 25 jars in mods\ (Sodium swapped to 0.8.7, plus Iris); the
    # shaderpack zip lives in shaderpacks\ and is verified separately above.
    Write-Log "[7/9] Verifying all $ExpectedJarCount mod jars by SHA-256..."

    # --- H.1: hard-fail on duplicate mods (two files for the same mod). This
    # must run BEFORE the exactly-one-Sodium cleanup below, so a duplicate
    # that was NOT produced by our own controlled mode-switch logic (e.g. a
    # stray copy a user dropped in manually) is reported and aborted rather
    # than silently deleted out from under them. ---
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

    # --- H.2: guarantee exactly one Sodium jar before the manifest check.
    # This is the only automatic removal in the gate; it only ever runs on
    # the state our own mode-switch logic (-Shaders/-NoShaders/sticky
    # detection) leaves behind, since H.1 above already aborted on any
    # duplicate a user introduced by hand. ---
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

    Write-Log "[8/9] All $ExpectedJarCount mod jars verified."

    # --- I: final summary ---
    Write-Log "[9/9] Install complete."
    Write-Log "Game directory: $TargetDir"
    Write-Log "Select this version in your launcher: $ProfileId"
    Write-Log "Verified jar count: $VerifiedCount / $ExpectedJarCount"
    if ($Shaders) {
        Write-Log "Shaders enabled: Iris + Sodium 0.8.7 + Complementary Unbound (shaderpacks\$ShaderpackZip)."
    }
    Write-Log "Reminder: do not add OptiFine - Sodium is included."

} finally {
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force -Path $TempDir -ErrorAction SilentlyContinue
    }
}

exit 0
