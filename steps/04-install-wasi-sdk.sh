#!/usr/bin/env bash
# steps/04-install-wasi-sdk.sh
#
# Downloads and installs the WASI SDK for wasm32-wasi builds.
# Expects WASI_SDK_VERSION to be set in the environment (e.g. "24").
# After this script runs, downstream scripts (05-configure.sh, 06-build.sh)
# can rely on:
#   WASI_SDK_PATH   – root of the unpacked SDK  (also written to $GITHUB_ENV)
#   PATH            – prepended with $WASI_SDK_PATH/bin

set -euo pipefail

# ── Validate required env ────────────────────────────────────────────────────
: "${WASI_SDK_VERSION:?WASI_SDK_VERSION must be set}"

# ── Derive full version tag & download URL ───────────────────────────────────
# Releases follow the pattern wasi-sdk-24.0 on GitHub; the tarball name embeds
# the patch level. We default patch to .0 unless WASI_SDK_VERSION already
# contains a dot (e.g. "24.1").
if [[ "$WASI_SDK_VERSION" == *.* ]]; then
  WASI_SDK_FULL_VERSION="$WASI_SDK_VERSION"
else
  WASI_SDK_FULL_VERSION="${WASI_SDK_VERSION}.0"
fi

WASI_SDK_MAJOR="${WASI_SDK_VERSION%%.*}"

# Pick the right host triple for the runner OS
case "$(uname -s)" in
  Linux)  HOST_TRIPLE="x86_64-linux"  ;;
  Darwin) HOST_TRIPLE="x86_64-macos"  ;;
  *)
    echo "Unsupported host OS for WASI SDK: $(uname -s)" >&2
    exit 1
    ;;
esac

TARBALL="wasi-sdk-${WASI_SDK_FULL_VERSION}-${HOST_TRIPLE}.tar.gz"
DOWNLOAD_URL="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_MAJOR}/${TARBALL}"

INSTALL_DIR="${HOME}/wasi-sdk"

# ── Download ─────────────────────────────────────────────────────────────────
echo "::group::Download WASI SDK ${WASI_SDK_FULL_VERSION}"
echo "URL: ${DOWNLOAD_URL}"
mkdir -p "${INSTALL_DIR}"
curl -fsSL --retry 5 --retry-delay 5 \
  -o "/tmp/${TARBALL}" \
  "${DOWNLOAD_URL}"
echo "::endgroup::"

# ── Unpack ───────────────────────────────────────────────────────────────────
echo "::group::Unpack WASI SDK"
tar -xzf "/tmp/${TARBALL}" -C "${INSTALL_DIR}" --strip-components=1
rm -f "/tmp/${TARBALL}"
echo "Installed to: ${INSTALL_DIR}"
ls "${INSTALL_DIR}"
echo "::endgroup::"

# ── Verify clang target ──────────────────────────────────────────────────────
echo "::group::Verify wasm32-wasi clang"
WASI_CLANG="${INSTALL_DIR}/bin/clang"
if [[ ! -x "$WASI_CLANG" ]]; then
  echo "ERROR: clang not found at ${WASI_CLANG}" >&2
  exit 1
fi
"${WASI_CLANG}" --version
# Quick smoke-test: compile an empty translation unit to wasm32-wasi
echo "int main(){return 0;}" | \
  "${WASI_CLANG}" --target=wasm32-wasi \
    --sysroot="${INSTALL_DIR}/share/wasi-sysroot" \
    -x c - -o /tmp/wasi-smoke-test.wasm
echo "Smoke test passed: wasm32-wasi compilation OK"
rm -f /tmp/wasi-smoke-test.wasm
echo "::endgroup::"

# ── Export to subsequent steps via $GITHUB_ENV ───────────────────────────────
{
  echo "WASI_SDK_PATH=${INSTALL_DIR}"
  echo "WASI_SYSROOT=${INSTALL_DIR}/share/wasi-sysroot"
  # Prepend to PATH so wasm32-wasi clang/ar/etc. are found first
  echo "PATH=${INSTALL_DIR}/bin:${PATH}"
} >> "${GITHUB_ENV}"

echo "WASI SDK ${WASI_SDK_FULL_VERSION} installed successfully."
echo "  WASI_SDK_PATH  = ${INSTALL_DIR}"
echo "  WASI_SYSROOT   = ${INSTALL_DIR}/share/wasi-sysroot"
