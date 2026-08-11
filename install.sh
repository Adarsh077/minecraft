#!/bin/sh
# Fabric Friends Client Pack installer for Minecraft 1.21.11 / Fabric loader 0.19.3
# POSIX sh. No Java required at any point.
set -eu

FABRIC_MC_VERSION="1.21.11"
FABRIC_LOADER_VERSION="0.19.3"
FABRIC_LOADER_ID="fabric-loader-${FABRIC_LOADER_VERSION}-${FABRIC_MC_VERSION}"
VERSION_MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
FABRIC_PROFILE_URL="https://meta.fabricmc.net/v2/versions/loader/${FABRIC_MC_VERSION}/${FABRIC_LOADER_VERSION}/profile/json"
PACK_ZIP_URL="https://drive.usercontent.google.com/download?id=1WaCgnbo9m41CGDz1v4XI1ASbP4_LL7O3&export=download&confirm=t"
PACK_ZIP_SHA256="975176a6fdbd5e0da23934a21637f75d6ce5d0aef006f0d3a1067ab3b29b2a20"
PACK_DIR_IN_ZIP="fabric-1.21.11-friends-client-pack/mods"

SERVER_ONLY_PREFIXES="graves- polymer-bundled- repurposed_structures- midnightlib-fabric- FallingTree-"

# --- optional --shaders extras (client-visual only, does not affect server compatibility) ---
# Iris 1.10.7 hard-pins Sodium 0.8.7, which replaces the base pack's 0.8.14-beta.2.
SODIUM_BASE_JAR="sodium-fabric-0.8.14-beta.2+mc1.21.11.jar"
SODIUM_SHADERS_JAR="sodium-fabric-0.8.7+mc1.21.11.jar"
SODIUM_SHADERS_URL="https://cdn.modrinth.com/data/AANobbMI/versions/UddlN6L4/sodium-fabric-0.8.7%2Bmc1.21.11.jar"
SODIUM_SHADERS_SHA256="c08fae86b350aaa8a8f37e7347929df38f01cc2348cf31c322615564bdc53983"
IRIS_JAR="iris-fabric-1.10.7+mc1.21.11.jar"
IRIS_URL="https://cdn.modrinth.com/data/YL57xq9U/versions/fDpuVzVr/iris-fabric-1.10.7%2Bmc1.21.11.jar"
IRIS_SHA256="58c55da18189c91a49f847d3cee451633a23b575fb69c0c5b65ddb274436cb19"
SHADERPACK_ZIP="ComplementaryUnbound_r5.8.1.zip"
SHADERPACK_URL="https://cdn.modrinth.com/data/R6NEzAwj/versions/VMHXIk50/ComplementaryUnbound_r5.8.1.zip"
SHADERPACK_SHA256="bb89b1fc54687d4147a837fb2e3c3f7261a13bee51819761e9b6a91cb7915965"

# --- 23-jar manifest: filename sha256 ---
MANIFEST='
Adorn-7.6.1+1.21.11-fabric.jar d431be4ee89d0d71b1ababedaa5275f478cfff5de94eba1165f5cd10d1b676d3
balm-fabric-1.21.11-21.11.9.1.jar e957283fcf3d1a3bc1a832db74fa80b03b770eb61d2875de644e66da84bb0390
BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar 89d39707bc095516ba1bf4f162628dfba51dd58a3bcac14c74a14ffefc18f00a
carryon-fabric-1.21.11-2.9.2.jar ac6c68baf2cbffef7de6739423aa615f151c8f1601bacf30921c8bd88f3f932d
fabric-api-0.141.6+1.21.11.jar bdff7fd7e220085cfad2ff9b1f40dde6534ae0b96cf378f97a374bc54cb9ed0f
fabric-language-kotlin-1.13.13+kotlin.2.4.10.jar 34ccdacf13bb9351fe43ce61912c2e09b72364e43e787d36ba3d2d04dec75a52
FantasticWings-v21.11.1-mc1.21.11-Fabric.jar b7cc2eb1814fe5c5eb3b0b3e6af399d4be0bcda44af3bd9b02994fdd6f3d7e43
FarmersDelight-1.21.11-3.6.13+refabricated.jar 3b3caa7a3c9b7ddc0a28f620ec729da6ab00a181fd8667de104324a5bb9015d1
ferritecore-8.2.0-fabric.jar f76bd760cbf48280cc7c43180f5089a46235fa24d934a8acf3da04a664c2c715
ForgeConfigAPIPort-v21.11.1-mc1.21.11-Fabric.jar 31a0686904fad1cfdeb1d6b011ac1c2280990d6e76ac2416468147e2246b4db1
GlitchCore-fabric-1.21.11-21.11.0.4.jar 8c5b3912d167640f1911982781578ccfb3fbb11e73fcee319c7ff44045a6e8ef
InventoryProfilesNext-fabric-1.21.11-2.2.6.jar 1d971f0f624c8f2d2693004aff96cb9546d65e3ab950d63563c769242d2c6474
Jade-1.21.11-Fabric-21.1.6.jar bcf1a7f6f9eb325b89d65bc15b41a35fdca2c2b052e9af772ffdcd70548d2fc8
jei-1.21.11-fabric-27.23.0.71.jar e904a724d7e2b5b2382b1f46f8d3efe84cb6a955ee6fe5310e8a173cf881ffb6
libIPN-fabric-1.21.11-6.6.3.jar 94a52d56ec41e31a98089aeff07baf25534986922d572eac85475b5e2736c9af
lithium-fabric-0.21.4+mc1.21.11.jar 5135c41da5b43cbdcb29424bde65195143ac4084e23834c8eac065942201c78b
mdm-26.7.0-fabric-1.21.11.jar dded3b56d982410de040d7e0c3f3e068876f126bc4077c9a426d90f1695abe0b
PuzzlesLib-v21.11.13-mc1.21.11-Fabric.jar 1c7b062f4d4fd4c830dbaa875da01706ef85f072969191d8c1affef693a66b82
sodium-fabric-0.8.14-beta.2+mc1.21.11.jar 24990c1c497bdda4605c595f4ee65aaf32f724b1498a33c63f43cb4500280c51
StorageDrawers-fabric-1.21.11-20.0.0.jar 5910484b2ad3813094600a229ef95bc6947cfe3815869b6fa418b139a037fdf9
TerraBlender-fabric-1.21.11-21.11.0.0.jar 3f0567c194d579677b42dd57eeb912e4e558ca069f4fc525213d182e60113772
travelersbackpack-fabric-1.21.11-10.11.10.jar d9f42b1bafd29d84fd97b5b6e51c948f0ed7d1251c0deed40e512870ea5980fb
waystones-fabric-1.21.11-21.11.9.jar 6ce002c05655969f528dc1a1eb335a567caa6eaaf95715a86770a066b693f470
'

# --- 5 author-hosted mods to fetch directly from Modrinth CDN ---
AUTHOR_URLS='
https://cdn.modrinth.com/data/LOpKHB2A/versions/MydMW2TT/waystones-fabric-1.21.11-21.11.9.jar
https://cdn.modrinth.com/data/HXF82T3G/versions/JJKbM72H/BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar
https://cdn.modrinth.com/data/TmUXSYKk/versions/q1Kv9EdP/mdm-26.7.0-fabric-1.21.11.jar
https://cdn.modrinth.com/data/MBAkmtvl/versions/5POKgjJn/balm-fabric-1.21.11-21.11.9.1.jar
https://cdn.modrinth.com/data/s3dmwKy5/versions/CO7NeLTt/GlitchCore-fabric-1.21.11-21.11.0.4.jar
'

# --- known mod-name prefixes, used for duplicate-mod detection ---
KNOWN_MOD_PREFIXES="sodium-fabric- iris-fabric- fabric-api- lithium-fabric- ferritecore- Adorn- balm-fabric- BiomesOPlenty-fabric- carryon-fabric- fabric-language-kotlin- FantasticWings- FarmersDelight- ForgeConfigAPIPort- GlitchCore-fabric- InventoryProfilesNext-fabric- Jade- jei- libIPN-fabric- mdm- PuzzlesLib- StorageDrawers-fabric- TerraBlender-fabric- travelersbackpack-fabric- waystones-fabric-"

TARGET_DIR=""
ZIP_OVERRIDE=""
TMPDIR_CREATED=""
SHADERS=""
NO_SHADERS=""

log() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

cleanup() {
  if [ -n "$TMPDIR_CREATED" ] && [ -d "$TMPDIR_CREATED" ]; then
    rm -rf "$TMPDIR_CREATED"
  fi
}
trap cleanup EXIT INT TERM

# --- arg parsing ---
while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      [ $# -ge 2 ] || die "--dir requires a value"
      TARGET_DIR="$2"
      shift 2
      ;;
    --zip)
      [ $# -ge 2 ] || die "--zip requires a value"
      ZIP_OVERRIDE="$2"
      shift 2
      ;;
    --shaders)
      SHADERS="1"
      shift
      ;;
    --no-shaders)
      NO_SHADERS="1"
      shift
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

if [ -n "$SHADERS" ] && [ -n "$NO_SHADERS" ]; then
  die "--shaders and --no-shaders cannot both be given"
fi

# --- OS detection ---
if [ -z "$TARGET_DIR" ]; then
  UNAME_S="$(uname -s)"
  case "$UNAME_S" in
    Darwin)
      TARGET_DIR="$HOME/Library/Application Support/minecraft"
      ;;
    *)
      TARGET_DIR="$HOME/.minecraft"
      ;;
  esac
fi

if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
  warn "Game directory did not exist and was created at: $TARGET_DIR"
  warn "Please launch vanilla ${FABRIC_MC_VERSION} once from your launcher first so assets download, then re-run this installer."
fi

log "[0/9] Using game directory: $TARGET_DIR"

MODS_DIR="$TARGET_DIR/mods"
mkdir -p "$MODS_DIR"

# --- sticky shader-mode detection ---
# If Iris is already installed and neither --shaders nor --no-shaders was
# passed, treat this run as shader mode anyway so a plain re-run over a
# shader install never mixes two Sodium jars together.
if [ -z "$SHADERS" ] && [ -z "$NO_SHADERS" ]; then
  for f in "$MODS_DIR"/iris-fabric-*.jar; do
    if [ -f "$f" ]; then
      SHADERS="1"
      log "Existing Iris install detected; keeping shaders enabled (pass --no-shaders to remove)."
      break
    fi
  done
fi

# --- explicit --no-shaders: strip Iris + the shader Sodium build ---
if [ -n "$NO_SHADERS" ]; then
  log "Disabling shaders (--no-shaders)..."
  for f in "$MODS_DIR"/iris-fabric-*.jar; do
    [ -f "$f" ] || continue
    log "Removing: $(basename "$f")"
    rm -f "$f"
  done
  for f in "$MODS_DIR"/sodium-fabric-0.8.7*.jar; do
    [ -f "$f" ] || continue
    log "Removing: $(basename "$f")"
    rm -f "$f"
  done
  log "Leaving shaderpacks/ untouched (shader zips are harmless); remove manually if you don't want them."
fi

# --- effective manifest for this run (depends on final SHADERS state) ---
if [ -n "$SHADERS" ]; then
  EFFECTIVE_MANIFEST="$(printf '%s\n' "$MANIFEST" | grep -vF "$SODIUM_BASE_JAR ")
$(printf '%s %s' "$SODIUM_SHADERS_JAR" "$SODIUM_SHADERS_SHA256")
$(printf '%s %s' "$IRIS_JAR" "$IRIS_SHA256")"
  EXPECTED_JAR_COUNT=24
  EXPECTED_SODIUM_JAR="$SODIUM_SHADERS_JAR"
else
  EFFECTIVE_MANIFEST="$MANIFEST"
  EXPECTED_JAR_COUNT=23
  EXPECTED_SODIUM_JAR="$SODIUM_BASE_JAR"
fi

# --- helper: hash tools ---
sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    die "Neither sha256sum nor shasum is available; cannot verify downloads."
  fi
}

sha1_of() {
  if command -v sha1sum >/dev/null 2>&1; then
    sha1sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 1 "$1" | awk '{print $1}'
  else
    die "Neither sha1sum nor shasum is available; cannot verify vanilla client jar."
  fi
}

# --- helper: download ---
fetch() {
  # fetch URL DEST
  _url="$1"
  _dest="$2"
  if command -v curl >/dev/null 2>&1; then
    if ! curl --fail --location --retry 3 --output "$_dest" "$_url"; then
      die "Download failed: $_url"
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -O "$_dest" "$_url"; then
      die "Download failed: $_url"
    fi
  else
    die "Neither curl nor wget is available; cannot download $_url"
  fi
}

TMPDIR_CREATED="$(mktemp -d)"

# --- A/B: vanilla base version ---
VERSION_DIR="$TARGET_DIR/versions/${FABRIC_MC_VERSION}"
VERSION_JSON="$VERSION_DIR/${FABRIC_MC_VERSION}.json"
VERSION_JAR="$VERSION_DIR/${FABRIC_MC_VERSION}.jar"

if [ -f "$VERSION_JSON" ] && [ -f "$VERSION_JAR" ]; then
  log "[1/9] Vanilla ${FABRIC_MC_VERSION} base version already present, skipping."
else
  log "[1/9] Installing vanilla ${FABRIC_MC_VERSION} base version..."
  mkdir -p "$VERSION_DIR"
  MANIFEST_JSON="$TMPDIR_CREATED/version_manifest_v2.json"
  fetch "$VERSION_MANIFEST_URL" "$MANIFEST_JSON"

  VERSION_URL=""
  if command -v python3 >/dev/null 2>&1; then
    VERSION_URL="$(python3 -c '
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for v in data.get("versions", []):
    if v.get("id") == sys.argv[2]:
        print(v.get("url", ""))
        break
' "$MANIFEST_JSON" "$FABRIC_MC_VERSION")"
  elif command -v jq >/dev/null 2>&1; then
    VERSION_URL="$(jq -r --arg id "$FABRIC_MC_VERSION" '.versions[] | select(.id == $id) | .url' "$MANIFEST_JSON" | head -n 1)"
  else
    VERSION_URL="$(grep -o "\"id\": *\"${FABRIC_MC_VERSION}\"[^}]*\"url\": *\"[^\"]*\"" "$MANIFEST_JSON" | grep -o '"url": *"[^"]*"' | sed 's/"url": *"//; s/"$//' | head -n 1)"
    if [ -z "$VERSION_URL" ]; then
      VERSION_URL="$(tr ',' '\n' < "$MANIFEST_JSON" | grep -B2 "\"id\": *\"${FABRIC_MC_VERSION}\"" | grep '"url"' | sed 's/.*"url": *"//; s/".*//' | head -n 1)"
    fi
  fi

  [ -n "$VERSION_URL" ] || die "Could not find version ${FABRIC_MC_VERSION} in ${VERSION_MANIFEST_URL}"

  fetch "$VERSION_URL" "$VERSION_JSON"

  CLIENT_URL=""
  CLIENT_SHA1=""
  if command -v python3 >/dev/null 2>&1; then
    CLIENT_URL="$(python3 -c '
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(data["downloads"]["client"]["url"])
' "$VERSION_JSON")"
    CLIENT_SHA1="$(python3 -c '
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(data["downloads"]["client"]["sha1"])
' "$VERSION_JSON")"
  elif command -v jq >/dev/null 2>&1; then
    CLIENT_URL="$(jq -r '.downloads.client.url' "$VERSION_JSON")"
    CLIENT_SHA1="$(jq -r '.downloads.client.sha1' "$VERSION_JSON")"
  else
    # No python3, no jq. The version JSON is single-line minified. The
    # "downloads" object's "client" key has a value object with no nested
    # braces (just sha1/size/url), so the literal sequence
    # "downloads": {"client": { ... } is unambiguous -- there is also an
    # unrelated top-level "logging": {"client": {"argument": ...}} object
    # elsewhere in the file, so we must anchor on "downloads":{"client": and
    # not on "client": alone, or a greedy match can grab the wrong one.
    # This also guarantees we get "client", not "client_mappings"/"server"/
    # "server_mappings" (the next key after downloads.client's closing brace).
    CLIENT_FRAGMENT="$(tr -d '\n' < "$VERSION_JSON" | sed -E 's/.*"downloads": *\{"client": *\{([^}]*)\}.*/\1/')"
    CLIENT_URL="$(printf '%s' "$CLIENT_FRAGMENT" | grep -o '"url" *: *"[^"]*"' | head -n 1 | sed 's/.*"url" *: *"//; s/"$//')"
    CLIENT_SHA1="$(printf '%s' "$CLIENT_FRAGMENT" | grep -o '"sha1" *: *"[^"]*"' | head -n 1 | sed 's/.*"sha1" *: *"//; s/"$//')"
  fi

  [ -n "$CLIENT_URL" ] && [ "$CLIENT_URL" != "null" ] || die "Could not read downloads.client.url from ${VERSION_JSON}"
  [ -n "$CLIENT_SHA1" ] && [ "$CLIENT_SHA1" != "null" ] || die "Could not read downloads.client.sha1 from ${VERSION_JSON}"

  fetch "$CLIENT_URL" "$VERSION_JAR"

  ACTUAL_SHA1="$(sha1_of "$VERSION_JAR")"
  if [ "$ACTUAL_SHA1" != "$CLIENT_SHA1" ]; then
    rm -f "$VERSION_JAR"
    die "SHA-1 mismatch for ${VERSION_JAR}: expected $CLIENT_SHA1, got $ACTUAL_SHA1"
  fi
  log "Vanilla ${FABRIC_MC_VERSION} client jar verified."
fi

# --- C: fabric loader profile ---
log "[2/9] Installing Fabric loader profile (${FABRIC_LOADER_ID})..."
PROFILE_JSON="$TMPDIR_CREATED/fabric_profile.json"
fetch "$FABRIC_PROFILE_URL" "$PROFILE_JSON"

if ! grep -q '"inheritsFrom"' "$PROFILE_JSON"; then
  die "Fabric profile response missing \"inheritsFrom\": $FABRIC_PROFILE_URL"
fi
if ! grep -q 'net\.fabricmc\.loader\.impl\.launch\.knot\.KnotClient' "$PROFILE_JSON"; then
  die "Fabric profile response missing KnotClient main class: $FABRIC_PROFILE_URL"
fi

PROFILE_ID=""
if command -v python3 >/dev/null 2>&1; then
  PROFILE_ID="$(python3 -c '
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
print(data["id"])
' "$PROFILE_JSON")"
elif command -v jq >/dev/null 2>&1; then
  PROFILE_ID="$(jq -r '.id' "$PROFILE_JSON")"
else
  PROFILE_ID="$(grep -o '"id" *: *"[^"]*"' "$PROFILE_JSON" | head -n 1 | sed 's/.*"id" *: *"//; s/"$//')"
fi

[ -n "$PROFILE_ID" ] && [ "$PROFILE_ID" != "null" ] || die "Could not read id from Fabric profile response"

if [ "$PROFILE_ID" != "$FABRIC_LOADER_ID" ]; then
  warn "Fabric profile id ($PROFILE_ID) differs from expected ($FABRIC_LOADER_ID); continuing with actual id."
fi

FABRIC_VERSION_DIR="$TARGET_DIR/versions/${PROFILE_ID}"
mkdir -p "$FABRIC_VERSION_DIR"
cp "$PROFILE_JSON" "$FABRIC_VERSION_DIR/${PROFILE_ID}.json"
log "Fabric loader profile written to versions/${PROFILE_ID}/${PROFILE_ID}.json"

# --- D: launcher_profiles.json ---
log "[3/9] Registering launcher profile..."
LAUNCHER_PROFILES="$TARGET_DIR/launcher_profiles.json"

if command -v python3 >/dev/null 2>&1; then
  # This step is a convenience only; a parse error or unwritable file must
  # never abort the install, so its exit status is checked directly (not
  # through a pipe) and converted into a warning.
  if python3 -c '
import json, sys

path = sys.argv[1]
profile_id = sys.argv[2]

try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, ValueError):
    data = {"profiles": {}, "settings": {}, "version": 3}

if "profiles" not in data or not isinstance(data.get("profiles"), dict):
    data["profiles"] = {}

data["profiles"]["fabric-loader-1.21.11"] = {
    "name": "fabric-loader-1.21.11",
    "type": "custom",
    "created": "2026-08-11T00:00:00.000Z",
    "lastVersionId": profile_id,
    "icon": "TNT",
}

with open(path, "w") as f:
    json.dump(data, f, indent=2)
' "$LAUNCHER_PROFILES" "$PROFILE_ID"; then
    log "launcher_profiles.json updated."
  else
    warn "Failed to update launcher_profiles.json; skipping. Select the ${PROFILE_ID} version manually in TLauncher."
  fi
elif command -v jq >/dev/null 2>&1; then
  if [ -f "$LAUNCHER_PROFILES" ]; then
    BASE_JSON="$LAUNCHER_PROFILES"
  else
    BASE_JSON="$TMPDIR_CREATED/base_launcher_profiles.json"
    printf '{"profiles":{},"settings":{},"version":3}' > "$BASE_JSON"
  fi
  NEW_JSON="$TMPDIR_CREATED/launcher_profiles.new.json"
  if jq --arg lastVersionId "$PROFILE_ID" \
    '.profiles["fabric-loader-1.21.11"] = {"name":"fabric-loader-1.21.11","type":"custom","created":"2026-08-11T00:00:00.000Z","lastVersionId":$lastVersionId,"icon":"TNT"}' \
    "$BASE_JSON" > "$NEW_JSON"; then
    mv "$NEW_JSON" "$LAUNCHER_PROFILES"
    log "launcher_profiles.json updated."
  else
    warn "Failed to update launcher_profiles.json; skipping. Select the ${PROFILE_ID} version manually in TLauncher."
  fi
else
  warn "No python3 or jq available; skipping launcher_profiles.json update. Select the ${PROFILE_ID} version manually in TLauncher."
fi

# --- E: remove server-only jars ---
log "[4/9] Removing server-only jars from mods/ (if present)..."
for prefix in $SERVER_ONLY_PREFIXES; do
  for f in "$MODS_DIR"/"$prefix"*; do
    if [ -f "$f" ]; then
      log "Removing server-only jar: $(basename "$f")"
      rm -f "$f"
    fi
  done
done

# --- F: obtain the bundled pack jars (skip the zip entirely if already good) ---
log "[5/9] Obtaining bundled pack jars..."

# The bundled (zip-sourced) subset of the effective manifest excludes the 5
# author-hosted (Modrinth) jars and the shader-only files (Iris, shader
# Sodium), since those are fetched independently, not extracted from the zip.
BUNDLED_MANIFEST="$(printf '%s\n' "$EFFECTIVE_MANIFEST" | while IFS=' ' read -r bfname bsha; do
  [ -n "$bfname" ] || continue
  is_author=0
  for aurl in $AUTHOR_URLS; do
    [ -n "$aurl" ] || continue
    if [ "$(basename "$aurl")" = "$bfname" ]; then
      is_author=1
      break
    fi
  done
  [ "$is_author" = "1" ] && continue
  [ "$bfname" = "$IRIS_JAR" ] && continue
  [ "$bfname" = "$SODIUM_SHADERS_JAR" ] && continue
  printf '%s %s\n' "$bfname" "$bsha"
done)"

BUNDLED_ALL_GOOD=1
printf '%s\n' "$BUNDLED_MANIFEST" | while IFS=' ' read -r bfname bsha; do
  [ -n "$bfname" ] || continue
  btarget="$MODS_DIR/$bfname"
  [ -f "$btarget" ] || { echo "missing"; continue; }
  [ "$(sha256_of "$btarget")" = "$bsha" ] || echo "mismatch"
done > "$TMPDIR_CREATED/bundled_check.txt"
if [ -s "$TMPDIR_CREATED/bundled_check.txt" ]; then
  BUNDLED_ALL_GOOD=0
fi

if [ "$BUNDLED_ALL_GOOD" = "1" ]; then
  log "All bundled pack jars already present and verified; skipping pack download."
else
  if [ -n "$ZIP_OVERRIDE" ]; then
    [ -f "$ZIP_OVERRIDE" ] || die "--zip path does not exist: $ZIP_OVERRIDE"
    PACK_ZIP="$ZIP_OVERRIDE"
  else
    PACK_ZIP="$TMPDIR_CREATED/friends-client-pack.zip"
    log "Downloading pack zip..."
    fetch "$PACK_ZIP_URL" "$PACK_ZIP"
  fi

  # Check it looks like a zip (PK magic), not an HTML interstitial page.
  PACK_MAGIC="$(head -c 2 "$PACK_ZIP" 2>/dev/null || true)"
  if [ "$PACK_MAGIC" != "PK" ]; then
    die "Downloaded file at $PACK_ZIP is not a zip (Google Drive may have returned an interstitial page). Download 'Minecraft-Fabric-1.21.11-Friends-Client-Pack.zip' manually from https://drive.google.com/file/d/1WaCgnbo9m41CGDz1v4XI1ASbP4_LL7O3/view and re-run with --zip /path/to/file.zip"
  fi

  if [ -z "$ZIP_OVERRIDE" ]; then
    PACK_ACTUAL_SHA256="$(sha256_of "$PACK_ZIP")"
    if [ "$PACK_ACTUAL_SHA256" != "$PACK_ZIP_SHA256" ]; then
      die "SHA-256 mismatch for downloaded pack zip: expected $PACK_ZIP_SHA256, got $PACK_ACTUAL_SHA256. Download 'Minecraft-Fabric-1.21.11-Friends-Client-Pack.zip' manually from https://drive.google.com/file/d/1WaCgnbo9m41CGDz1v4XI1ASbP4_LL7O3/view and re-run with --zip /path/to/file.zip"
    fi
  else
    log "Note: --zip provided; skipping the built-in Google Drive hash check (verifying via final per-jar manifest instead)."
  fi

  EXTRACT_DIR="$TMPDIR_CREATED/extracted"
  mkdir -p "$EXTRACT_DIR"

  if command -v unzip >/dev/null 2>&1; then
    unzip -q -o "$PACK_ZIP" -d "$EXTRACT_DIR"
  elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$PACK_ZIP" -C "$EXTRACT_DIR"
  elif tar --version 2>/dev/null | grep -qi bsd; then
    tar -xf "$PACK_ZIP" -C "$EXTRACT_DIR"
  else
    die "No zip extraction tool found (need unzip, bsdtar, or a BSD tar). Please install unzip and re-run."
  fi

  SRC_MODS_DIR="$EXTRACT_DIR/$PACK_DIR_IN_ZIP"
  [ -d "$SRC_MODS_DIR" ] || die "Expected directory '$PACK_DIR_IN_ZIP' not found inside the pack zip"

  for jar in "$SRC_MODS_DIR"/*.jar; do
    [ -f "$jar" ] || continue
    cp "$jar" "$MODS_DIR/"
  done
  log "Bundled pack jars copied to mods/."
fi

# --- G: 5 author-hosted jars ---
log "[6/9] Downloading author-hosted jars from Modrinth CDN..."
for url in $AUTHOR_URLS; do
  [ -n "$url" ] || continue
  fname="$(basename "$url")"
  dest="$MODS_DIR/$fname"

  expected_sha="$(printf '%s' "$MANIFEST" | awk -v f="$fname" '$1==f{print $2}')"
  [ -n "$expected_sha" ] || die "No manifest entry for expected author-hosted jar: $fname"

  if [ -f "$dest" ]; then
    existing_sha="$(sha256_of "$dest")"
    if [ "$existing_sha" = "$expected_sha" ]; then
      log "Already present and verified: $fname"
      continue
    fi
  fi

  log "Downloading: $fname"
  part="$dest.part"
  fetch "$url" "$part"
  actual_sha="$(sha256_of "$part")"
  if [ "$actual_sha" != "$expected_sha" ]; then
    rm -f "$part"
    die "SHA-256 mismatch for $fname: expected $expected_sha, got $actual_sha (url: $url)"
  fi
  mv "$part" "$dest"
done

# --- G.5: optional shaders (--shaders, or sticky-detected): Iris + Sodium 0.8.7 + a shader pack ---
if [ -n "$SHADERS" ]; then
  log "[6b/9] Installing shaders (Iris + Sodium 0.8.7 + Complementary Unbound)..."

  OLD_SODIUM="$MODS_DIR/$SODIUM_BASE_JAR"
  if [ -f "$OLD_SODIUM" ]; then
    log "Removing base Sodium ($SODIUM_BASE_JAR) -- Iris 1.10.7 requires Sodium 0.8.7"
    rm -f "$OLD_SODIUM"
  fi

  iris_dest="$MODS_DIR/$IRIS_JAR"
  if [ -f "$iris_dest" ] && [ "$(sha256_of "$iris_dest")" = "$IRIS_SHA256" ]; then
    log "Already present and verified: $IRIS_JAR"
  else
    log "Downloading: $IRIS_JAR"
    part="$iris_dest.part"
    fetch "$IRIS_URL" "$part"
    actual_sha="$(sha256_of "$part")"
    if [ "$actual_sha" != "$IRIS_SHA256" ]; then
      rm -f "$part"
      die "SHA-256 mismatch for $IRIS_JAR: expected $IRIS_SHA256, got $actual_sha (url: $IRIS_URL)"
    fi
    mv "$part" "$iris_dest"
  fi

  sodium_dest="$MODS_DIR/$SODIUM_SHADERS_JAR"
  if [ -f "$sodium_dest" ] && [ "$(sha256_of "$sodium_dest")" = "$SODIUM_SHADERS_SHA256" ]; then
    log "Already present and verified: $SODIUM_SHADERS_JAR"
  else
    log "Downloading: $SODIUM_SHADERS_JAR"
    part="$sodium_dest.part"
    fetch "$SODIUM_SHADERS_URL" "$part"
    actual_sha="$(sha256_of "$part")"
    if [ "$actual_sha" != "$SODIUM_SHADERS_SHA256" ]; then
      rm -f "$part"
      die "SHA-256 mismatch for $SODIUM_SHADERS_JAR: expected $SODIUM_SHADERS_SHA256, got $actual_sha (url: $SODIUM_SHADERS_URL)"
    fi
    mv "$part" "$sodium_dest"
  fi

  SHADERPACKS_DIR="$TARGET_DIR/shaderpacks"
  mkdir -p "$SHADERPACKS_DIR"
  shaderpack_dest="$SHADERPACKS_DIR/$SHADERPACK_ZIP"
  if [ -f "$shaderpack_dest" ] && [ "$(sha256_of "$shaderpack_dest")" = "$SHADERPACK_SHA256" ]; then
    log "Already present and verified: $SHADERPACK_ZIP"
  else
    log "Downloading: $SHADERPACK_ZIP"
    part="$shaderpack_dest.part"
    fetch "$SHADERPACK_URL" "$part"
    actual_sha="$(sha256_of "$part")"
    if [ "$actual_sha" != "$SHADERPACK_SHA256" ]; then
      rm -f "$part"
      die "SHA-256 mismatch for $SHADERPACK_ZIP: expected $SHADERPACK_SHA256, got $actual_sha (url: $SHADERPACK_URL)"
    fi
    mv "$part" "$shaderpack_dest"
  fi

  log "Shaders installed: Iris, Sodium 0.8.7, Complementary Unbound shaderpack (shaderpacks/$SHADERPACK_ZIP)."
fi

# --- H: verify all mod jars ---
# Without shaders: 23 jars, Sodium 0.8.14-beta.2.
# With shaders: 24 jars in mods/ (Sodium swapped to 0.8.7, plus Iris); the
# shaderpack zip lives in shaderpacks/ and is verified separately above.
log "[7/9] Verifying all ${EXPECTED_JAR_COUNT} mod jars by SHA-256..."

# --- H.1: hard-fail on duplicate mods (two files for the same mod). This
# must run BEFORE the exactly-one-Sodium cleanup below, so a duplicate that
# was NOT produced by our own controlled mode-switch logic (e.g. a stray copy
# a user dropped in manually) is reported and aborted rather than silently
# deleted out from under them. ---
DUP_TMP="$TMPDIR_CREATED/modkeys.txt"
: > "$DUP_TMP"
for f in "$MODS_DIR"/*.jar; do
  [ -f "$f" ] || continue
  bn="$(basename "$f")"
  case "$bn" in
    tl_skin_cape*.jar) continue ;;
  esac
  matched=""
  for prefix in $KNOWN_MOD_PREFIXES; do
    case "$bn" in
      "$prefix"*) matched="$prefix" ;;
    esac
    [ -n "$matched" ] && break
  done
  if [ -n "$matched" ]; then
    printf '%s %s\n' "$matched" "$bn" >> "$DUP_TMP"
  else
    in_manifest="$(printf '%s\n' "$EFFECTIVE_MANIFEST" | awk -v f="$bn" '$1==f{print "1"; exit}')"
    if [ -z "$in_manifest" ]; then
      warn "Unrecognized extra jar in mods/: $bn (not part of the expected pack; leaving in place)"
    fi
  fi
done

for prefix in $KNOWN_MOD_PREFIXES; do
  files="$(awk -v p="$prefix" '$1==p{print $2}' "$DUP_TMP")"
  count=0
  [ -n "$files" ] && count="$(printf '%s\n' "$files" | grep -c .)"
  if [ "$count" -gt 1 ]; then
    expected_name="$(printf '%s\n' "$EFFECTIVE_MANIFEST" | awk -v p="$prefix" -F' ' 'index($1,p)==1{print $1; exit}')"
    printf 'ERROR: Duplicate mod detected for prefix "%s" -- two versions of one mod will crash the game:\n' "$prefix" >&2
    printf '%s\n' "$files" | while IFS= read -r fn; do
      [ -n "$fn" ] || continue
      printf '  - %s\n' "$fn" >&2
    done
    if [ -n "$expected_name" ]; then
      printf '  Keep "%s" (expected) and delete the other file(s) listed above.\n' "$expected_name" >&2
    else
      printf '  Delete all but one of the files listed above.\n' >&2
    fi
    die "Duplicate mod jars found in $MODS_DIR."
  fi
done

# --- H.2: guarantee exactly one Sodium jar before the manifest check. This
# is the only automatic removal in the gate; it only ever runs on the state
# our own mode-switch logic (--shaders/--no-shaders/sticky detection) leaves
# behind, since H.1 above already aborted on any duplicate a user introduced
# by hand. ---
for f in "$MODS_DIR"/sodium-fabric-*.jar; do
  [ -f "$f" ] || continue
  bn="$(basename "$f")"
  if [ "$bn" != "$EXPECTED_SODIUM_JAR" ]; then
    log "Removing unexpected Sodium jar: $bn (keeping $EXPECTED_SODIUM_JAR)"
    rm -f "$f"
  fi
done

# --- H.3: every expected filename exists with the right hash ---
MISSING=""
MISMATCHED=""
VERIFIED_COUNT=0

printf '%s\n' "$EFFECTIVE_MANIFEST" > "$TMPDIR_CREATED/manifest.txt"
while IFS=' ' read -r fname expected; do
  [ -n "$fname" ] || continue
  target="$MODS_DIR/$fname"
  if [ ! -f "$target" ]; then
    MISSING="$MISSING $fname"
    continue
  fi
  actual="$(sha256_of "$target")"
  if [ "$actual" != "$expected" ]; then
    MISMATCHED="$MISMATCHED $fname(expected=$expected,got=$actual)"
    continue
  fi
  VERIFIED_COUNT=$((VERIFIED_COUNT + 1))
done < "$TMPDIR_CREATED/manifest.txt"

if [ -n "$MISSING" ] || [ -n "$MISMATCHED" ]; then
  [ -z "$MISSING" ] || printf 'ERROR: Missing mod jars in %s:%s\n' "$MODS_DIR" "$MISSING" >&2
  [ -z "$MISMATCHED" ] || printf 'ERROR: Mismatched mod jars in %s:%s\n' "$MODS_DIR" "$MISMATCHED" >&2
  die "Mod jar verification failed. See errors above."
fi

log "[8/9] All ${EXPECTED_JAR_COUNT} mod jars verified."

# --- I: final summary ---
log "[9/9] Install complete."
log "Game directory: $TARGET_DIR"
log "Select this version in your launcher: $PROFILE_ID"
log "Verified jar count: $VERIFIED_COUNT / $EXPECTED_JAR_COUNT"
if [ -n "$SHADERS" ]; then
  log "Shaders enabled: Iris + Sodium 0.8.7 + Complementary Unbound (shaderpacks/$SHADERPACK_ZIP)."
fi
log "Reminder: do not add OptiFine — Sodium is included."

exit 0
