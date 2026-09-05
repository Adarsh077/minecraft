#!/bin/sh
# Fabric Friends Client Pack installer for Minecraft 1.21.11 / Fabric loader 0.19.3
# POSIX sh. No Java required at any point.
set -eu

FABRIC_MC_VERSION="1.21.11"
FABRIC_LOADER_VERSION="0.19.3"
FABRIC_LOADER_ID="fabric-loader-${FABRIC_LOADER_VERSION}-${FABRIC_MC_VERSION}"
VERSION_MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest_v2.json"
FABRIC_PROFILE_URL="https://meta.fabricmc.net/v2/versions/loader/${FABRIC_MC_VERSION}/${FABRIC_LOADER_VERSION}/profile/json"
# --- modflared forced-tunnels config (written into the game dir during install) ---
FORCED_TUNNELS_JSON='["minecraft.dekhlo.to"]'

# NOTE: midnightlib-fabric- is intentionally NOT server-only: Cull Leaves (and other
# client mods) hard-require it ("midnightlib": "*"), so it must stay in mods/.
SERVER_ONLY_PREFIXES="graves- polymer-bundled- repurposed_structures- FallingTree-"

# --- shader stack (installed for pandit/modi only) ---
# Iris 1.10.7 hard-pins Sodium 0.8.7, which replaces the base 0.8.14-beta.2 for
# shader tiers -- never both. dalit keeps 0.8.14-beta.2 and installs no Iris.
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

# --- resourcepack (downloaded into <gamedir>/resourcepacks/; note the space in the name) ---
RESOURCEPACK_NAME="Presence Footsteps R3.zip"
RESOURCEPACK_SHA256="d33bf876c957a0c2f570f55586948440d9cb849b549d744d26d80733f5ec286f"
RESOURCEPACK_URL="https://cdn.modrinth.com/data/qSJqZIl1/versions/yAgMm4Uo/Presence%20Footsteps%20R3.zip"

# --- 37 mod jars downloaded from the Modrinth CDN: "filename sha256 url" per line ---
# Every URL was resolved by SHA-512 lookup against the Modrinth API, so each serves
# exactly the bytes its SHA-256 names. Do not substitute URLs or versions; keep the
# %2B / %20 escapes intact. Installed to <gamedir>/mods/ (all tiers).
MODS_TABLE='
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
waystones-fabric-1.21.11-21.11.9.jar 6ce002c05655969f528dc1a1eb335a567caa6eaaf95715a86770a066b693f470 https://cdn.modrinth.com/data/LOpKHB2A/versions/MydMW2TT/waystones-fabric-1.21.11-21.11.9.jar
BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar 89d39707bc095516ba1bf4f162628dfba51dd58a3bcac14c74a14ffefc18f00a https://cdn.modrinth.com/data/HXF82T3G/versions/JJKbM72H/BiomesOPlenty-fabric-1.21.11-21.11.0.32.jar
mdm-26.7.0-fabric-1.21.11.jar dded3b56d982410de040d7e0c3f3e068876f126bc4077c9a426d90f1695abe0b https://cdn.modrinth.com/data/TmUXSYKk/versions/q1Kv9EdP/mdm-26.7.0-fabric-1.21.11.jar
balm-fabric-1.21.11-21.11.9.1.jar e957283fcf3d1a3bc1a832db74fa80b03b770eb61d2875de644e66da84bb0390 https://cdn.modrinth.com/data/MBAkmtvl/versions/5POKgjJn/balm-fabric-1.21.11-21.11.9.1.jar
GlitchCore-fabric-1.21.11-21.11.0.4.jar 8c5b3912d167640f1911982781578ccfb3fbb11e73fcee319c7ff44045a6e8ef https://cdn.modrinth.com/data/s3dmwKy5/versions/CO7NeLTt/GlitchCore-fabric-1.21.11-21.11.0.4.jar
architectury-19.0.1-fabric.jar 661395d6f0bef0d3a794e2db74df5600c7387ba6fb946b172315977201a667c7 https://cdn.modrinth.com/data/lhGA9TYQ/versions/uNdfrcQ8/architectury-19.0.1-fabric.jar
'

# --- known mod-name prefixes, used for duplicate-mod detection ---
KNOWN_MOD_PREFIXES="sodium-fabric- iris-fabric- fabric-api- lithium-fabric- ferritecore- Adorn- carryon-fabric- fabric-language-kotlin- FantasticWings- FarmersDelight- ForgeConfigAPIPort- InventoryProfilesNext-fabric- Jade- jei- libIPN-fabric- modflared- PuzzlesLib- StorageDrawers-fabric- TerraBlender-fabric- travelersbackpack-fabric- create-fly- cc-tweaked- expanded_weaponry- animal_feeding_trough- connectiblechains- voxelmap-fabric- entity_texture_features- ImmediatelyFast-Fabric- sound-physics-remastered-fabric- skinlayers3d-fabric- lambdynamiclights- AmbientSounds_FABRIC_ CreativeCore_FABRIC_ PresenceFootsteps- cullleaves-fabric- continuity- cloth-config- midnightlib-fabric- waystones-fabric- BiomesOPlenty-fabric- mdm- balm-fabric- GlitchCore-fabric- architectury-"

TARGET_DIR=""
TMPDIR_CREATED=""
TIER=""
# TIER_SHADERS is derived from the tier below: shaders (Iris + Sodium 0.8.7 swap +
# Complementary) are installed for pandit/modi and NOT for dalit. There is no
# user-facing shader flag.
TIER_SHADERS=""

log() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  printf 'Usage: sh install.sh (--dalit | --pandit | --modi) [--dir DIR]\n' >&2
  printf '  A tier is REQUIRED:\n' >&2
  printf '    --dalit   very low end: no shaders, minimal settings, -Xmx3G\n' >&2
  printf '    --pandit  medium: Complementary shaders (MEDIUM), -Xmx5G\n' >&2
  printf '    --modi    dedicated GPU: Complementary shaders (HIGH), -Xmx8G\n' >&2
}

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
    --dalit)
      [ -z "$TIER" ] || die "Only one tier flag may be given (--dalit / --pandit / --modi)"
      TIER="dalit"
      shift
      ;;
    --pandit)
      [ -z "$TIER" ] || die "Only one tier flag may be given (--dalit / --pandit / --modi)"
      TIER="pandit"
      shift
      ;;
    --modi)
      [ -z "$TIER" ] || die "Only one tier flag may be given (--dalit / --pandit / --modi)"
      TIER="modi"
      shift
      ;;
    *)
      usage
      die "Unknown argument: $1"
      ;;
  esac
done

# A tier flag is REQUIRED -- there is no default.
if [ -z "$TIER" ]; then
  usage
  die "No tier given. Choose exactly one of --dalit / --pandit / --modi."
fi

# --- per-tier settings ---
# All tiers install ALL mods; tiers differ only in shader stack and written config.
# T_SHADERS=1 means this tier gets Iris + the Sodium 0.8.7 swap + Complementary.
case "$TIER" in
    dalit)
      T_RENDER_DISTANCE=5;  T_SIM_DISTANCE=5;  T_GRAPHICS=0; T_PARTICLES=2
      T_MIPMAP=0;           T_BIOME_BLEND=0;   T_MAXFPS=60
      T_ENTITY_SHADOWS=false; T_AO=false;      T_ENTITY_DIST_SCALE=0.5
      T_XMX="3G"
      T_SHADERS=""
      T_COMP_PROFILE=""
      T_SOUND_PHYSICS=false
      T_LAMBDYN="fastest"
      T_CONTINUITY=false
      T_SKINLAYERS=false
      T_SODIUM_ANIMATE_VISIBLE_ONLY=true
      T_SODIUM_RENDER_AHEAD=0
      ;;
    pandit)
      T_RENDER_DISTANCE=9;  T_SIM_DISTANCE=8;  T_GRAPHICS=1; T_PARTICLES=1
      T_MIPMAP=2;           T_BIOME_BLEND=2;   T_MAXFPS=120
      T_ENTITY_SHADOWS=true; T_AO=true;        T_ENTITY_DIST_SCALE=1.0
      T_XMX="5G"
      T_SHADERS="1"
      T_COMP_PROFILE="MEDIUM"
      T_SOUND_PHYSICS=true
      T_LAMBDYN="fancy"
      T_CONTINUITY=true
      T_SKINLAYERS=true
      T_SODIUM_ANIMATE_VISIBLE_ONLY=true
      T_SODIUM_RENDER_AHEAD=2
      ;;
    modi)
      T_RENDER_DISTANCE=16; T_SIM_DISTANCE=12; T_GRAPHICS=2; T_PARTICLES=0
      T_MIPMAP=4;           T_BIOME_BLEND=5;   T_MAXFPS=240
      T_ENTITY_SHADOWS=true; T_AO=true;        T_ENTITY_DIST_SCALE=1.0
      T_XMX="8G"
      T_SHADERS="1"
      T_COMP_PROFILE="HIGH"
      T_SOUND_PHYSICS=true
      T_LAMBDYN="fancy"
      T_CONTINUITY=true
      T_SKINLAYERS=true
      T_SODIUM_ANIMATE_VISIBLE_ONLY=false
      T_SODIUM_RENDER_AHEAD=3
      ;;
esac

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

log "[0/8] Using game directory: $TARGET_DIR"

MODS_DIR="$TARGET_DIR/mods"
mkdir -p "$MODS_DIR"

# --- shader stack is decided by the tier (no user-facing shader flag) ---
TIER_SHADERS="$T_SHADERS"

# Reconcile the Sodium/Iris stack with the tier BEFORE anything downloads or the
# duplicate check runs, so switching tiers never leaves two Sodium jars or a stray
# Iris behind. (shaderpacks/ is left untouched -- the zips are harmless.)
if [ -z "$TIER_SHADERS" ]; then
  # dalit: no shaders. Strip Iris and the Sodium 0.8.7 build left by a shader tier;
  # base Sodium 0.8.14 is (re)downloaded in step [5].
  for f in "$MODS_DIR"/iris-fabric-*.jar; do
    [ -f "$f" ] || continue
    log "Tier '$TIER': removing Iris (this tier has no shaders): $(basename "$f")"
    rm -f "$f"
  done
  for f in "$MODS_DIR"/sodium-fabric-0.8.7*.jar; do
    [ -f "$f" ] || continue
    log "Tier '$TIER': removing shader Sodium build: $(basename "$f")"
    rm -f "$f"
  done
else
  # pandit/modi: Iris 1.10.7 pins Sodium 0.8.7, so remove the base 0.8.14 build left
  # by dalit; Sodium 0.8.7 and Iris are (re)downloaded in step [5].
  _old_sodium="$MODS_DIR/$SODIUM_BASE_JAR"
  if [ -f "$_old_sodium" ]; then
    log "Tier '$TIER': removing base Sodium ($SODIUM_BASE_JAR); Iris requires Sodium 0.8.7"
    rm -f "$_old_sodium"
  fi
fi

# --- effective download table + manifest for this run (depends on the tier's shader stack) ---
# dalit keeps sodium 0.8.14 (in MODS_TABLE) and gets no Iris. pandit/modi drop
# sodium 0.8.14 and add sodium 0.8.7 + Iris.
if [ -n "$TIER_SHADERS" ]; then
  EFFECTIVE_TABLE="$(printf '%s\n' "$MODS_TABLE" | grep -vF "$SODIUM_BASE_JAR ")
$(printf '%s %s %s' "$SODIUM_SHADERS_JAR" "$SODIUM_SHADERS_SHA256" "$SODIUM_SHADERS_URL")
$(printf '%s %s %s' "$IRIS_JAR" "$IRIS_SHA256" "$IRIS_URL")"
  EXPECTED_JAR_COUNT=44
  EXPECTED_SODIUM_JAR="$SODIUM_SHADERS_JAR"
else
  EFFECTIVE_TABLE="$MODS_TABLE"
  EXPECTED_JAR_COUNT=43
  EXPECTED_SODIUM_JAR="$SODIUM_BASE_JAR"
fi

# "filename sha256" pairs (drop the URL column) for the final verification gate.
EFFECTIVE_MANIFEST="$(printf '%s\n' "$EFFECTIVE_TABLE" | while IFS=' ' read -r _ef _es _eu; do
  [ -n "$_ef" ] || continue
  printf '%s %s\n' "$_ef" "$_es"
done)"

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

# --- helper: download a file and verify its SHA-256 (idempotent) ---
# download_verify FILENAME SHA256 URL DESTDIR
# Skips the download if the file is already present with the right hash.
download_verify() {
  _dv_name="$1"
  _dv_sha="$2"
  _dv_url="$3"
  _dv_dir="$4"
  mkdir -p "$_dv_dir"
  _dv_dest="$_dv_dir/$_dv_name"
  if [ -f "$_dv_dest" ] && [ "$(sha256_of "$_dv_dest")" = "$_dv_sha" ]; then
    log "Already present and verified: $_dv_name"
    return 0
  fi
  log "Downloading: $_dv_name"
  _dv_part="$_dv_dest.part"
  fetch "$_dv_url" "$_dv_part"
  _dv_actual="$(sha256_of "$_dv_part")"
  if [ "$_dv_actual" != "$_dv_sha" ]; then
    rm -f "$_dv_part"
    die "SHA-256 mismatch for $_dv_name: expected $_dv_sha, got $_dv_actual (url: $_dv_url)"
  fi
  mv "$_dv_part" "$_dv_dest"
}

# --- helper: merge key/value lines into a colon- or equals-separated text config ---
# Reads "KEY VALUE" pairs on stdin (VALUE = everything after the first space).
# Existing lines for a key are replaced in place; every other line is preserved
# byte-for-byte; keys not already present are appended. The file (and its parent
# directory) is created if absent. Used for options.txt (":") and .properties ("=").
merge_kv_file() {
  _mkv_file="$1"
  _mkv_sep="$2"
  # Pairs are staged through a file (not an awk -v value): macOS/BSD awk hard-errors
  # ("newline in string ... at source line 1") on a -v value containing a literal
  # newline, which every multi-pair caller here (e.g. options.txt's tier settings)
  # produces. GNU awk tolerates it, so this only breaks on macOS. A file read via
  # getline works identically on every awk.
  _mkv_pairs_file="$_mkv_file.pairs.$$"
  cat > "$_mkv_pairs_file"
  mkdir -p "$(dirname "$_mkv_file")"
  [ -f "$_mkv_file" ] || : > "$_mkv_file"
  _mkv_tmp="$_mkv_file.tmp.$$"
  awk -v sep="$_mkv_sep" -v pairs_file="$_mkv_pairs_file" '
    BEGIN {
      while ((getline line < pairs_file) > 0) {
        if (line == "") continue
        p = index(line, " ")
        k = substr(line, 1, p - 1)
        v = substr(line, p + 1)
        key[k] = v
      }
      close(pairs_file)
    }
    {
      handled = 0
      for (k in key) {
        # Tolerate optional whitespace before the separator (a mod may re-save
        # "key = value"); always re-write in canonical "key<sep>value" form.
        if ($0 ~ ("^" k "[ \t]*" sep)) { print k sep key[k]; seen[k] = 1; handled = 1; break }
      }
      if (!handled) print
    }
    END {
      for (k in key) if (!seen[k]) print k sep key[k]
    }
  ' "$_mkv_file" > "$_mkv_tmp" && mv "$_mkv_tmp" "$_mkv_file"
  rm -f "$_mkv_pairs_file"
}

# --- helper: set a quoted-string key in a TOML file (create if absent) ---
# Writes `KEY = "VALUE"`, replacing any existing line for KEY (TOML forbids
# duplicate keys, so this cannot just append). Every other line is preserved.
set_toml_string() {
  _ts_file="$1"
  _ts_key="$2"
  _ts_val="$3"
  mkdir -p "$(dirname "$_ts_file")"
  [ -f "$_ts_file" ] || : > "$_ts_file"
  _ts_tmp="$_ts_file.tmp.$$"
  awk -v k="$_ts_key" -v val="$_ts_val" '
    BEGIN { line = k " = \"" val "\"" }
    $0 ~ ("^[ \t]*" k "[ \t]*=") { if (!seen) { print line; seen = 1 }; next }
    { print }
    END { if (!seen) print line }
  ' "$_ts_file" > "$_ts_tmp" && mv "$_ts_tmp" "$_ts_file"
}

# --- helper: write LambDynamicLights' [light_sources] table with every source off ---
# LambDynamicLights (NightConfig) reads each light source via the path
# "light_sources.<name>" and serialises them as a nested [light_sources] TOML table,
# so we write that exact shape. entities / self / beam / firefly / guardian_laser /
# sonic_boom / glowing_effect are booleans and go to false. creeper and tnt are NOT
# booleans -- they are ExplosiveLightingMode, which in 4.9.1 declares only SIMPLE and
# FANCY (verified in ExplosiveLightingMode.class). There is no OFF, so explosion
# lighting cannot be switched off here at all; "simple" is the cheaper of the two and
# is the floor. A bare `false`, or the string "off", is an invalid enum value that
# byId()/valueOf() silently falls back to the default for, leaving it ON.
# water_sensitive_check is a submersion behaviour flag, not a light source, so it is
# left untouched. Replaces an existing [light_sources] table if present (idempotent),
# otherwise appends one.
set_lambdyn_lights_off() {
  _ll_file="$1"
  mkdir -p "$(dirname "$_ll_file")"
  [ -f "$_ll_file" ] || : > "$_ll_file"
  _ll_tmp="$_ll_file.tmp.$$"
  awk '
    /^[ \t]*\[light_sources\][ \t]*$/ { in_ls = 1; next }
    in_ls && /^[ \t]*\[/            { in_ls = 0 }
    in_ls                          { next }
    /^[ \t]*light_sources\./        { next }
    { print }
    END {
      print "[light_sources]"
      print "\tentities = false"
      print "\tself = false"
      print "\tcreeper = \"simple\""
      print "\ttnt = \"simple\""
      print "\tbeam = false"
      print "\tfirefly = false"
      print "\tguardian_laser = false"
      print "\tsonic_boom = false"
      print "\tglowing_effect = false"
    }
  ' "$_ll_file" > "$_ll_tmp" && mv "$_ll_tmp" "$_ll_file"
}

# --- helper: ensure a pack id is present in options.txt's resourcePacks list ---
# The line is a JSON array: resourcePacks:["vanilla","file/Foo.zip"]. This preserves
# any packs the friend already enabled and appends the given id if it is absent.
# Minecraft 1.21.11 references a resourcepacks/ file as "file/<filename>" -- the
# "file/" prefix is confirmed present in the vanilla client's resource-pack class.
enable_resourcepack() {
  _rp_file="$1"       # options.txt path
  _rp_id="$2"         # e.g. file/Presence Footsteps R3.zip
  mkdir -p "$(dirname "$_rp_file")"
  [ -f "$_rp_file" ] || : > "$_rp_file"
  _rp_line="$(grep '^resourcePacks:' "$_rp_file" 2>/dev/null | head -n 1 || true)"
  if [ -z "$_rp_line" ]; then
    printf '%s\n' "resourcePacks:[\"vanilla\",\"$_rp_id\"]" >> "$_rp_file"
    return 0
  fi
  # Already present? (match the quoted id exactly)
  _rp_quoted="\"$_rp_id\""
  case "$_rp_line" in
    *"$_rp_quoted"*) return 0 ;;
  esac
  _rp_array="${_rp_line#resourcePacks:}"
  if [ "$_rp_array" = "[]" ]; then
    _rp_new="resourcePacks:[\"$_rp_id\"]"
  else
    _rp_new="resourcePacks:${_rp_array%]},\"$_rp_id\"]"
  fi
  _rp_tmp="$_rp_file.tmp.$$"
  awk -v newline="$_rp_new" '
    /^resourcePacks:/ && !done { print newline; done = 1; next }
    { print }
  ' "$_rp_file" > "$_rp_tmp" && mv "$_rp_tmp" "$_rp_file"
}

# --- helper: deep-merge a JSON patch into a JSON file (create if absent) ---
# Prefers python3, then jq. If neither is available and the file is absent, the
# patch is written verbatim (a partial JSON is safe for every consumer here). If
# neither is available and the file already exists, it is left untouched (we must
# not clobber a friend's config) and a warning is logged; return 1 in that case.
json_merge() {
  _jm_file="$1"
  _jm_patch="$2"
  mkdir -p "$(dirname "$_jm_file")"
  if command -v python3 >/dev/null 2>&1; then
    if printf '%s' "$_jm_patch" | python3 -c '
import json, sys
path = sys.argv[1]
patch = json.load(sys.stdin)
try:
    with open(path) as f:
        data = json.load(f)
    if not isinstance(data, dict):
        data = {}
except (FileNotFoundError, ValueError):
    data = {}
def merge(a, b):
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict):
            merge(a[k], v)
        else:
            a[k] = v
merge(data, patch)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
' "$_jm_file"; then
      return 0
    fi
    warn "Failed to write JSON config $_jm_file; leaving it untouched."
    return 1
  elif command -v jq >/dev/null 2>&1; then
    _jm_base="$_jm_file"
    if [ ! -f "$_jm_file" ]; then
      _jm_base="$TMPDIR_CREATED/json_merge_empty.json"
      printf '{}' > "$_jm_base"
    fi
    _jm_tmp="$_jm_file.tmp.$$"
    if printf '%s' "$_jm_patch" | jq -s '.[0] * .[1]' "$_jm_base" - > "$_jm_tmp"; then
      mv "$_jm_tmp" "$_jm_file"
      return 0
    fi
    rm -f "$_jm_tmp"
    warn "Failed to write JSON config $_jm_file; leaving it untouched."
    return 1
  elif [ ! -f "$_jm_file" ]; then
    printf '%s\n' "$_jm_patch" > "$_jm_file"
    return 0
  else
    warn "Neither python3 nor jq available; not merging $_jm_file (leaving your existing config untouched)."
    return 1
  fi
}

# --- helper: report whether a config file will be created or merged (for logging) ---
config_action() {
  if [ -f "$1" ]; then printf 'merged'; else printf 'created'; fi
}

TMPDIR_CREATED="$(mktemp -d)"

# --- A/B: vanilla base version ---
VERSION_DIR="$TARGET_DIR/versions/${FABRIC_MC_VERSION}"
VERSION_JSON="$VERSION_DIR/${FABRIC_MC_VERSION}.json"
VERSION_JAR="$VERSION_DIR/${FABRIC_MC_VERSION}.jar"

if [ -f "$VERSION_JSON" ] && [ -f "$VERSION_JAR" ]; then
  log "[1/8] Vanilla ${FABRIC_MC_VERSION} base version already present, skipping."
else
  log "[1/8] Installing vanilla ${FABRIC_MC_VERSION} base version..."
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
log "[2/8] Installing Fabric loader profile (${FABRIC_LOADER_ID})..."
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
log "[3/8] Registering launcher profile..."
LAUNCHER_PROFILES="$TARGET_DIR/launcher_profiles.json"

# When a tier is set, its RAM allocation goes in the profile's javaArgs field
# (the launcher otherwise applies its own default JVM args). Empty when no tier,
# in which case no javaArgs field is written and existing installs are unchanged.
JAVA_ARGS=""
if [ -n "$TIER" ]; then
  JAVA_ARGS="-Xmx${T_XMX} -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M"
fi

if command -v python3 >/dev/null 2>&1; then
  # This step is a convenience only; a parse error or unwritable file must
  # never abort the install, so its exit status is checked directly (not
  # through a pipe) and converted into a warning.
  if python3 -c '
import json, sys

path = sys.argv[1]
profile_id = sys.argv[2]
java_args = sys.argv[3]

try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, ValueError):
    data = {"profiles": {}, "settings": {}, "version": 3}

if "profiles" not in data or not isinstance(data.get("profiles"), dict):
    data["profiles"] = {}

# Preserve any other fields on our profile object; only our known keys are
# authoritative, and javaArgs is set/removed based on whether a tier was given.
prof = data["profiles"].get("fabric-loader-1.21.11")
if not isinstance(prof, dict):
    prof = {}
prof.setdefault("created", "2026-08-11T00:00:00.000Z")
prof["name"] = "fabric-loader-1.21.11"
prof["type"] = "custom"
prof["lastVersionId"] = profile_id
prof["icon"] = "TNT"
if java_args:
    prof["javaArgs"] = java_args
data["profiles"]["fabric-loader-1.21.11"] = prof

with open(path, "w") as f:
    json.dump(data, f, indent=2)
' "$LAUNCHER_PROFILES" "$PROFILE_ID" "$JAVA_ARGS"; then
    if [ -n "$JAVA_ARGS" ]; then
      log "launcher_profiles.json updated (tier '$TIER': javaArgs -Xmx${T_XMX})."
    else
      log "launcher_profiles.json updated."
    fi
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
  if jq --arg lastVersionId "$PROFILE_ID" --arg javaArgs "$JAVA_ARGS" \
    '.profiles["fabric-loader-1.21.11"] = ((.profiles["fabric-loader-1.21.11"] // {}) + {"name":"fabric-loader-1.21.11","type":"custom","created":((.profiles["fabric-loader-1.21.11"].created) // "2026-08-11T00:00:00.000Z"),"lastVersionId":$lastVersionId,"icon":"TNT"} + (if $javaArgs == "" then {} else {"javaArgs":$javaArgs} end))' \
    "$BASE_JSON" > "$NEW_JSON"; then
    mv "$NEW_JSON" "$LAUNCHER_PROFILES"
    if [ -n "$JAVA_ARGS" ]; then
      log "launcher_profiles.json updated (tier '$TIER': javaArgs -Xmx${T_XMX})."
    else
      log "launcher_profiles.json updated."
    fi
  else
    warn "Failed to update launcher_profiles.json; skipping. Select the ${PROFILE_ID} version manually in TLauncher."
  fi
else
  warn "No python3 or jq available; skipping launcher_profiles.json update. Select the ${PROFILE_ID} version manually in TLauncher."
fi

# --- E: remove server-only jars ---
log "[4/8] Removing server-only jars from mods/ (if present)..."
for prefix in $SERVER_ONLY_PREFIXES; do
  for f in "$MODS_DIR"/"$prefix"*; do
    if [ -f "$f" ]; then
      log "Removing server-only jar: $(basename "$f")"
      rm -f "$f"
    fi
  done
done

# --- F: download + verify every file for this tier from the Modrinth CDN ---
log "[5/8] Downloading and verifying mods, resourcepack, and shaders (this transfers ~145 MB on a fresh install)..."
RESOURCEPACKS_DIR="$TARGET_DIR/resourcepacks"
RESOURCEPACK_DEST="$RESOURCEPACKS_DIR/$RESOURCEPACK_NAME"
SHADERPACKS_DIR="$TARGET_DIR/shaderpacks"

# 5a: every mod jar for this tier -> mods/. Read from a temp file (not a pipe) so
# a download_verify failure aborts the whole script instead of just a subshell.
printf '%s\n' "$EFFECTIVE_TABLE" > "$TMPDIR_CREATED/effective_table.txt"
while IFS=' ' read -r dfname dsha durl; do
  [ -n "$dfname" ] || continue
  download_verify "$dfname" "$dsha" "$durl" "$MODS_DIR"
done < "$TMPDIR_CREATED/effective_table.txt"

# 5b: the resourcepack -> resourcepacks/ (filename has a space; download_verify quotes it)
download_verify "$RESOURCEPACK_NAME" "$RESOURCEPACK_SHA256" "$RESOURCEPACK_URL" "$RESOURCEPACKS_DIR"

# 5c: shader stack -- Complementary shaderpack -> shaderpacks/ (pandit/modi only;
# Iris and Sodium 0.8.7 are part of EFFECTIVE_TABLE above and land in mods/).
if [ -n "$TIER_SHADERS" ]; then
  download_verify "$SHADERPACK_ZIP" "$SHADERPACK_SHA256" "$SHADERPACK_URL" "$SHADERPACKS_DIR"
  log "Shaders installed for '$TIER': Iris, Sodium 0.8.7, Complementary Unbound (shaderpacks/$SHADERPACK_ZIP)."
fi

# --- G: modflared forced-tunnels config (written to both locations modflared reads) ---
log "[6/8] Writing modflared forced_tunnels.json..."
for d in "$TARGET_DIR/config/modflared" "$TARGET_DIR/modflared"; do
  mkdir -p "$d"
  printf '%s\n' "$FORCED_TUNNELS_JSON" > "$d/forced_tunnels.json"
  log "Wrote $d/forced_tunnels.json"
done

# --- G.7: tier config ---
# A tier is always set by this point. Every config path below was verified against
# the mod jar; mods whose path could not be verified are deliberately left unset.
if [ -n "$TIER" ]; then
  log "[7/8] Writing '$TIER' tier config..."

  # options.txt -- vanilla, colon-separated. Merge: replace only the tier keys,
  # keep every other line byte-identical, append any that are absent.
  OPTIONS_TXT="$TARGET_DIR/options.txt"
  _opt_action="$(config_action "$OPTIONS_TXT")"
  printf '%s\n' "renderDistance $T_RENDER_DISTANCE
simulationDistance $T_SIM_DISTANCE
graphicsMode $T_GRAPHICS
particles $T_PARTICLES
mipmapLevels $T_MIPMAP
biomeBlendRadius $T_BIOME_BLEND
maxFps $T_MAXFPS
entityShadows $T_ENTITY_SHADOWS
ao $T_AO
entityDistanceScaling $T_ENTITY_DIST_SCALE" | merge_kv_file "$OPTIONS_TXT" ":"
  log "options.txt ($TIER, $_opt_action): renderDistance=$T_RENDER_DISTANCE simulationDistance=$T_SIM_DISTANCE graphicsMode=$T_GRAPHICS particles=$T_PARTICLES mipmapLevels=$T_MIPMAP biomeBlendRadius=$T_BIOME_BLEND maxFps=$T_MAXFPS entityShadows=$T_ENTITY_SHADOWS ao=$T_AO entityDistanceScaling=$T_ENTITY_DIST_SCALE"

  # Enable the Presence Footsteps resourcepack (all tiers) -- copying it does not
  # switch it on. Merged into resourcePacks so a friend's enabled packs are kept.
  enable_resourcepack "$OPTIONS_TXT" "file/$RESOURCEPACK_NAME"
  log "options.txt ($TIER): resourcePacks += \"file/$RESOURCEPACK_NAME\""

  # Sodium -- config/sodium-options.json. GSON field naming is
  # LOWER_CASE_WITH_UNDERSCORES, so the JSON keys are snake_case (NOT the Java
  # field names). Only confirmed primitive fields; no enum-valued fields.
  SODIUM_JSON="$TARGET_DIR/config/sodium-options.json"
  _sod_action="$(config_action "$SODIUM_JSON")"
  if json_merge "$SODIUM_JSON" "{\"performance\":{\"chunk_builder_threads\":0,\"use_entity_culling\":true,\"use_fog_occlusion\":true,\"use_block_face_culling\":true,\"animate_only_visible_textures\":$T_SODIUM_ANIMATE_VISIBLE_ONLY},\"advanced\":{\"cpu_render_ahead_limit\":$T_SODIUM_RENDER_AHEAD},\"quality\":{\"hidden_fluid_culling\":true}}"; then
    log "config/sodium-options.json ($TIER, $_sod_action): animate_only_visible_textures=$T_SODIUM_ANIMATE_VISIBLE_ONLY cpu_render_ahead_limit=$T_SODIUM_RENDER_AHEAD + culling on"
  fi

  # Sound Physics Remastered -- config/soundphysics.properties, key "enabled".
  SOUNDPHYSICS_PROPS="$TARGET_DIR/config/soundphysics.properties"
  _sp_action="$(config_action "$SOUNDPHYSICS_PROPS")"
  printf '%s\n' "enabled $T_SOUND_PHYSICS" | merge_kv_file "$SOUNDPHYSICS_PROPS" "="
  log "config/soundphysics.properties ($TIER, $_sp_action): enabled=$T_SOUND_PHYSICS"

  # Continuity -- config/continuity.json. Turning it "off" disables both
  # connected and emissive textures; "on" enables them.
  CONTINUITY_JSON="$TARGET_DIR/config/continuity.json"
  _cont_action="$(config_action "$CONTINUITY_JSON")"
  if json_merge "$CONTINUITY_JSON" "{\"connected_textures\":$T_CONTINUITY,\"emissive_textures\":$T_CONTINUITY}"; then
    log "config/continuity.json ($TIER, $_cont_action): connected_textures=$T_CONTINUITY emissive_textures=$T_CONTINUITY"
  fi

  # 3D Skin Layers -- config/skinlayers.json. No single master toggle; the 3D
  # layers are the per-body-part flags, so "off" clears them all, "on" sets them.
  SKINLAYERS_JSON="$TARGET_DIR/config/skinlayers.json"
  _skin_action="$(config_action "$SKINLAYERS_JSON")"
  if json_merge "$SKINLAYERS_JSON" "{\"enableHat\":$T_SKINLAYERS,\"enableJacket\":$T_SKINLAYERS,\"enableLeftSleeve\":$T_SKINLAYERS,\"enableRightSleeve\":$T_SKINLAYERS,\"enableLeftPants\":$T_SKINLAYERS,\"enableRightPants\":$T_SKINLAYERS}"; then
    log "config/skinlayers.json ($TIER, $_skin_action): all 3D layer parts=$T_SKINLAYERS"
  fi

  # LambDynamicLights -- config/lambdynlights.toml, key "mode" (a quoted enum string).
  # The ONLY valid values are fastest / fast / fancy -- there is no "off" (confirmed
  # against DynamicLightsMode in the 4.9.1 jar). Writing "off" is an invalid enum that
  # silently falls back to the default (fancy), leaving lights ON. To disable dynamic
  # lighting for dalit we set the cheapest valid mode AND turn off every source in the
  # [light_sources] table. pandit/modi keep mode="fancy" with the mod's default sources.
  LAMBDYN_TOML="$TARGET_DIR/config/lambdynlights.toml"
  _lamb_action="$(config_action "$LAMBDYN_TOML")"
  set_toml_string "$LAMBDYN_TOML" "mode" "$T_LAMBDYN"
  if [ "$TIER" = "dalit" ]; then
    set_lambdyn_lights_off "$LAMBDYN_TOML"
    log "config/lambdynlights.toml ($TIER, $_lamb_action): mode=\"$T_LAMBDYN\" + all [light_sources] disabled"
  else
    log "config/lambdynlights.toml ($TIER, $_lamb_action): mode=\"$T_LAMBDYN\""
  fi

  # NOTE: Cull Leaves (config/cullleaves.json, key "enabled") and ImmediatelyFast
  # are ON for every tier. Cull Leaves defaults to enabled and ImmediatelyFast
  # has no master enable field (it is a pure optimizer, active once installed),
  # so neither needs a written config -- installing the jar is "on".

  # Iris (pandit/modi only) -- point it at the shaderpack, enable it, and set the
  # tier's Complementary profile. Iris stores the selected pack in
  # config/iris.properties (java.util.Properties) and per-shaderpack options --
  # including the profile -- in shaderpacks/<shaderPack>.txt, where <shaderPack> is
  # exactly the iris.properties "shaderPack" value (the .zip name for a zip pack).
  # Confirmed against the Iris jar: Iris.class resolves
  # getShaderpacksDirectory().resolve(name + ".txt") and reads "profile" via
  # queueShaderPackOptionsFromProperties.
  if [ -n "$TIER_SHADERS" ]; then
    IRIS_PROPERTIES="$TARGET_DIR/config/iris.properties"
    _iris_action="$(config_action "$IRIS_PROPERTIES")"
    printf '%s\n' "shaderPack $SHADERPACK_ZIP
enableShaders true" | merge_kv_file "$IRIS_PROPERTIES" "="
    log "config/iris.properties ($TIER, $_iris_action): shaderPack=$SHADERPACK_ZIP, enableShaders=true"

    SHADERPACK_OPTIONS_TXT="$SHADERPACKS_DIR/$SHADERPACK_ZIP.txt"
    _prof_action="$(config_action "$SHADERPACK_OPTIONS_TXT")"
    printf '%s\n' "profile $T_COMP_PROFILE" | merge_kv_file "$SHADERPACK_OPTIONS_TXT" "="
    log "shaderpacks/$SHADERPACK_ZIP.txt ($TIER, $_prof_action): profile=$T_COMP_PROFILE"
  fi
fi

# --- H: verify all mod jars ---
# dalit: 37 jars, Sodium 0.8.14-beta.2.
# pandit/modi: 38 jars in mods/ (Sodium swapped to 0.8.7, plus Iris); the shaderpack
# zip lives in shaderpacks/ and was verified on download above. The resourcepack
# lives in resourcepacks/ and is verified separately below.
log "[8/8] Verifying all ${EXPECTED_JAR_COUNT} mod jars by SHA-256..."

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

# --- H.2: guarantee exactly one Sodium jar before the manifest check. The
# expected build is tier-decided (dalit -> 0.8.14-beta.2, pandit/modi -> 0.8.7).
# This is the only automatic removal in the gate; it only ever runs on the state
# our own tier logic leaves behind, since H.1 above already aborted on any
# duplicate a user introduced by hand. ---
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

# --- H.4: verify the resourcepack (same SHA-256 gate as the jars) ---
if [ ! -f "$RESOURCEPACK_DEST" ]; then
  die "Missing resourcepack in $RESOURCEPACKS_DIR: $RESOURCEPACK_NAME"
fi
RP_ACTUAL_SHA256="$(sha256_of "$RESOURCEPACK_DEST")"
if [ "$RP_ACTUAL_SHA256" != "$RESOURCEPACK_SHA256" ]; then
  die "SHA-256 mismatch for resourcepack '$RESOURCEPACK_NAME': expected $RESOURCEPACK_SHA256, got $RP_ACTUAL_SHA256"
fi

log "All ${EXPECTED_JAR_COUNT} mod jars + the resourcepack verified."

# --- I: final summary ---
log "Install complete."
log "Game directory: $TARGET_DIR"
log "Select this version in your launcher: $PROFILE_ID"
log "Verified jar count: $VERIFIED_COUNT / $EXPECTED_JAR_COUNT (+ 1 resourcepack)"
if [ -n "$TIER_SHADERS" ]; then
  log "Tier applied: $TIER (RAM -Xmx${T_XMX}; shaders ON: Iris + Sodium 0.8.7 + Complementary $T_COMP_PROFILE)."
else
  log "Tier applied: $TIER (RAM -Xmx${T_XMX}; no shaders, Sodium 0.8.14-beta.2)."
fi
log "Reminder: do not add OptiFine — Sodium is included."

exit 0
