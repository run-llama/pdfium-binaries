#!/bin/bash -eux
OS=${PDFium_TARGET_OS:?}
SOURCE=${PDFium_SOURCE_DIR:-pdfium}
BUILD=${PDFium_BUILD_DIR:-$SOURCE/out}
TARGET_CPU=${PDFium_TARGET_CPU:?}
TARGET_ENVIRONMENT=${PDFium_TARGET_ENVIRONMENT:-}
ENABLE_V8=${PDFium_ENABLE_V8:-false}
IS_DEBUG=${PDFium_IS_DEBUG:-false}
BUILD_TYPE=${PDFium_BUILD_TYPE:-shared}
# WASI SDK — set by 04-install-wasi-sdk.sh; fall back to empty so the
# non-wasi path never fails an unbound-variable check.
WASI_SDK_PATH=${WASI_SDK_PATH:-}
WASI_SYSROOT=${WASI_SYSROOT:-}

mkdir -p "$BUILD"

(
  echo "is_debug = $IS_DEBUG"
  if [ "$IS_DEBUG" != "true" ]; then
    echo "symbol_level = 0"
    # ThinLTO requires lld (LLVM linker), which is only available with clang.
    # Skip it for: emscripten/wasi (use their own toolchains) and musl
    # (GCC-based cross toolchain, no lld).
    if [ "$OS" != "emscripten" ] && [ "$OS" != "wasi" ] && [ "$TARGET_ENVIRONMENT" != "musl" ]; then
      echo "use_thin_lto = true"
    fi
    echo "chrome_pgo_phase = 0"
  fi
  echo "pdf_is_standalone = true"
  echo "pdf_use_partition_alloc = false"
  echo "target_cpu = \"$TARGET_CPU\""
  echo "target_os = \"$OS\""
  echo "pdf_enable_v8 = $ENABLE_V8"
  echo "pdf_enable_xfa = $ENABLE_V8"
  echo "treat_warnings_as_errors = false"
  echo "is_component_build = false"

  if [ "$ENABLE_V8" == "true" ]; then
    echo "v8_use_external_startup_data = false"
    echo "v8_enable_i18n_support = false"
  fi

  if [ "$BUILD_TYPE" == "static" ]; then
    echo "pdf_is_complete_lib = true"
  fi

  case "$OS" in
    android)
      echo "clang_use_chrome_plugins = false"
      echo "default_min_sdk_version = 23"
      ;;
    ios)
      [ -n "$TARGET_ENVIRONMENT" ] && echo "target_environment = \"$TARGET_ENVIRONMENT\""
      echo "ios_enable_code_signing = false"
      echo "use_blink = true"
      [ "$ENABLE_V8" == "true" ] && [ "$TARGET_CPU" == "arm64" ] && echo 'arm_control_flow_integrity = "none"'
      echo "clang_use_chrome_plugins = false"
      ;;
    linux)
      echo "clang_use_chrome_plugins = false"
      # AOTW, //build/config/sysroot.gni lacks handling of ppc64, so we manually
      # set the sysroot to ensure working builds with proper glibc requirement.
      if [ "$TARGET_CPU" == "ppc64" ]; then
        echo "use_sysroot = true"
        echo "sysroot = \"//build/linux/debian_bullseye_ppc64el-sysroot\""
      fi
      ;;
    mac)
      echo "clang_use_chrome_plugins = false"
      ;;
    emscripten)
      echo 'pdf_is_complete_lib = true'
      echo 'is_clang = false'
      echo 'use_custom_libcxx = false'
      if [ "$ENABLE_V8" == "true" ]; then
        # Set a toolchain with the same bitness as the target CPU
        echo "v8_snapshot_toolchain = \"//build/toolchain/linux:x86\""
        # Don't try to build libc++ because it requires GCC 14+
        echo 'use_custom_libcxx_for_host = false'
      fi
      ;;
    wasi)
      # Validate that the WASI SDK was installed by 04-install-wasi-sdk.sh
      if [ -z "$WASI_SYSROOT" ]; then
        echo "ERROR: WASI_SYSROOT is not set. Was 04-install-wasi-sdk.sh run?" >&2
        exit 1
      fi

      # WASI builds are always fully static — no dynamic linking in the runtime
      echo 'pdf_is_complete_lib = true'

      # Use Chromium's bundled clang (default) — it already supports
      # --target=wasm32-wasi and knows all the flags the build system emits.
      # The toolchain.gn passes --target and --sysroot via extra_cflags.
      echo 'is_clang = true'
      echo 'clang_use_chrome_plugins = false'

      # No system libcxx — the WASI sysroot provides libc; we use it directly
      echo 'use_custom_libcxx = false'
      echo 'use_custom_libcxx_for_host = false'

      # Point GN at the WASI sysroot for all includes and libs
      echo "sysroot = \"$WASI_SYSROOT\""
      echo 'use_sysroot = true'

      # WASI has no POSIX threads, no sandbox, no glib
      echo 'use_glib = false'

      # V8 does not support WASI; guard here rather than relying on the caller
      if [ "$ENABLE_V8" == "true" ]; then
        echo "ERROR: V8 is not supported on WASI." >&2
        exit 1
      fi
      ;;
  esac

  case "$TARGET_ENVIRONMENT" in
    musl)
      echo 'is_musl = true'
      echo 'is_clang = false'
      echo 'use_custom_libcxx = false'
      echo 'use_custom_libcxx_for_host = false'
      echo 'use_glib = false'
      # The musl cross toolchain ships its own sysroot (with musl libc headers
      # and libs). Chromium's default Linux sysroot is debian/glibc, which is
      # incompatible (missing bits/libc-header-start.h, mismatched libc ABI).
      # Disable use_sysroot so the GCC invocation does not get
      # --sysroot=.../debian_bullseye_*-sysroot injected.
      echo 'use_sysroot = false'
      # The musl cross toolchain is GCC-based, so lld is not available.
      # Chromium's build asserts use_lld whenever (Thin)LTO is enabled, and
      # use_lld defaults to true only with is_clang=true. Disable both LTO
      # and lld explicitly so the GCC+ld.bfd toolchain is used end-to-end.
      echo 'use_thin_lto = false'
      echo 'use_lld = false'
      [ "$ENABLE_V8" == "true" ] && case "$TARGET_CPU" in
        arm)
            echo "v8_snapshot_toolchain = \"//build/toolchain/linux:clang_x86_v8_arm\""
            ;;
        arm64)
            echo "v8_snapshot_toolchain = \"//build/toolchain/linux:clang_x64_v8_arm64\""
            ;;
        *)
            echo "v8_snapshot_toolchain = \"//build/toolchain/linux:$TARGET_CPU\""
            ;;
      esac
      ;;
  esac
) | sort > "$BUILD/args.gn"

# Generate Ninja files
pushd "$SOURCE"
gn gen "$BUILD"
popd
