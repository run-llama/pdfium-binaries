#!/bin/bash -eux

IS_DEBUG=${PDFium_IS_DEBUG:-false}
OS=${PDFium_TARGET_OS:?}
VERSION=${PDFium_VERSION:-}
PATCHES="$PWD/patches"
BUILD_TYPE=${PDFium_BUILD_TYPE:-shared}

SOURCE=${PDFium_SOURCE_DIR:-pdfium}
BUILD=${PDFium_BUILD_DIR:-pdfium/out}

STAGING="$PWD/staging"
STAGING_BIN="$STAGING/bin"
STAGING_LIB="$STAGING/lib"

mkdir -p "$STAGING"
rm -rf "$STAGING"/*
mkdir -p "$STAGING_LIB"

case "$BUILD_TYPE" in
  shared)
    CMAKE_CONFIG_FILE="PDFiumConfig.cmake"
    ;;
  static)
    CMAKE_CONFIG_FILE="PDFiumStaticConfig.cmake"
    ;;
esac
sed "s/#VERSION#/${VERSION:-0.0.0.0}/" <"$PATCHES/$CMAKE_CONFIG_FILE" >"$STAGING/PDFiumConfig.cmake"

cp LICENSE "$STAGING"
cat >>"$STAGING/LICENSE" <<END

This package also includes third-party software. See the licenses/ directory for their respective licenses.
END

cp "$BUILD/args.gn" "$STAGING"
cp -R "$SOURCE/public" "$STAGING/include"
rm -f "$STAGING/include/DEPS"
rm -f "$STAGING/include/README"
rm -f "$STAGING/include/PRESUBMIT.py"

# llamaparse: with pdf_use_mimalloc the allocator lives entirely inside the
# library. Fail the build if any allocator symbol (mimalloc, operator
# new/delete, libc malloc family) leaks into the export table -- a host that
# bound to one of these could free our memory with its own allocator.
verify_allocator_exports() {
  local lib="$1"
  # Only meaningful when mimalloc is linked in. Builds without it (32-bit,
  # ppc64, ...) export libc++'s own operator new/delete exactly as they always
  # did; that is not a leak of ours, so leave those export tables alone.
  if ! grep -q '^pdf_use_mimalloc = true' "$BUILD/args.gn"; then
    echo "allocator export check skipped: pdf_use_mimalloc is off for this build"
    return 0
  fi
  local tools="$SOURCE/third_party/llvm-build/Release+Asserts/bin"
  local exports
  case "$OS" in
    linux|android) exports=$("$tools/llvm-nm" -D --defined-only "$lib" | awk '{print $3}') ;;
    mac|ios) exports=$("$tools/llvm-nm" -gU "$lib" | awk '{print $3}') ;;
    win) exports=$("$tools/llvm-readobj" --coff-exports "$lib" | awk '/Name:/{print $2}') ;;
    *) return 0 ;;
  esac
  local leaked
  leaked=$(printf '%s\n' "$exports" | grep -E '^_{0,2}(mi_|Zn|Zd|malloc$|free$|calloc$|realloc$|posix_memalign$|aligned_alloc$)' || true)
  if [ -n "$leaked" ]; then
    echo "ERROR: allocator symbols exported from $lib:" >&2
    echo "$leaked" >&2
    exit 1
  fi
  echo "allocator export check passed: $lib ($(printf '%s\n' "$exports" | grep -c .) exports)"
}

case "$OS-$BUILD_TYPE" in
  android-shared|linux-shared)
    mv "$BUILD/libpdfium.so" "$STAGING_LIB"
    verify_allocator_exports "$STAGING_LIB/libpdfium.so"
    ;;

  android-static|linux-static|mac-static|ios-static)
    mv "$BUILD/obj/libpdfium.a" "$STAGING_LIB"
    ;;

  mac-shared|ios-shared)
    mv "$BUILD/libpdfium.dylib" "$STAGING_LIB"
    verify_allocator_exports "$STAGING_LIB/libpdfium.dylib"
    ;;

  emscripten-*)
    mv "$BUILD/obj/libpdfium.a" "$STAGING_LIB"
    rm -rf "$STAGING/include/cpp"
    rm "$STAGING/PDFiumConfig.cmake"
    ;;

  wasi-*)
    mv "$BUILD/obj/libpdfium.a" "$STAGING_LIB"
    # Ship WASI sysroot libraries so consumers can resolve all C/C++ runtime
    # symbols at link time. Without these, libc/libc++ functions appear as
    # unresolved "env::" imports in the final .wasm binary.
    #
    # In WASI SDK 24+:
    #   - C libs (libc, wasi-emulated-*) are under $WASI_SYSROOT/lib/wasm32-wasip1/
    #   - C++ libs (libc++, libc++abi) are under $WASI_SDK_PATH/lib/wasm32-wasip1/
    SYSROOT_LIB="${WASI_SYSROOT:?}/lib/wasm32-wasip1"
    cp "$SYSROOT_LIB/libc.a"                    "$STAGING_LIB"
    cp "$SYSROOT_LIB/libc++.a"                  "$STAGING_LIB"
    cp "$SYSROOT_LIB/libc++abi.a"               "$STAGING_LIB"
    cp "$SYSROOT_LIB/libwasi-emulated-mman.a"   "$STAGING_LIB"
    cp "$SYSROOT_LIB/libwasi-emulated-signal.a" "$STAGING_LIB"
    # libsetjmp defines the `__c_longjmp` wasm exception tag referenced by
    # any object compiled with `-mllvm -wasm-enable-sjlj` (libjpeg's error
    # handler, FreeType's sfnt loader). Without it, the link fails with
    # `undefined symbol: __c_longjmp` once consumers stop passing
    # `--allow-undefined` to wasm-ld (Rust 1.96+ default).
    cp "$SYSROOT_LIB/libsetjmp.a"               "$STAGING_LIB"
    ;;

  win-shared)
    mv "$BUILD/pdfium.dll.lib" "$STAGING_LIB"
    mkdir -p "$STAGING_BIN"
    mv "$BUILD/pdfium.dll" "$STAGING_BIN"
    verify_allocator_exports "$STAGING_BIN/pdfium.dll"
    [ "$IS_DEBUG" == "true" ] && mv "$BUILD/pdfium.dll.pdb" "$STAGING_BIN"
    ;;

  win-shared)
    mv "$BUILD/obj/pdfium.lib" "$STAGING_LIB"
    ;;
esac

if [ -n "$VERSION" ]; then
  cat >"$STAGING/VERSION" <<END
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
BUILD=$(echo "$VERSION" | cut -d. -f3)
PATCH=$(echo "$VERSION" | cut -d. -f4)
END
fi
