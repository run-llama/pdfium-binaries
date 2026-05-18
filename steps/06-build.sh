#!/bin/bash -eux

SOURCE=${PDFium_SOURCE_DIR:-pdfium}
BUILD_DIR=${PDFium_BUILD_DIR:-$SOURCE/out}
TARGET_CPU=${PDFium_TARGET_CPU:?}
IS_DEBUG=${PDFium_IS_DEBUG:-false}

# Debug: show the toolchain and config that were actually used
echo "=== toolchain.gn ==="
cat "$SOURCE/build/toolchain/wasi/BUILD.gn" || true
echo "=== config.gn ==="
cat "$SOURCE/build/config/wasi/BUILD.gn" || true
echo "=== stub headers ==="
ls -la "$SOURCE/build/config/wasi/include/" || true
echo "=== ninja compile command for unifiedcache.o ==="
ninja -C "$BUILD_DIR" -t commands obj/third_party/icu/icuuc_private/unifiedcache.o 2>/dev/null || true

ninja -C "$BUILD_DIR" pdfium
