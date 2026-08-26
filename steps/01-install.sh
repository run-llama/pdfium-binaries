#!/bin/bash -eux

PATH_FILE=${GITHUB_PATH:-$PWD/.path}
TARGET_OS=${PDFium_TARGET_OS:?}
TARGET_ENVIRONMENT=${PDFium_TARGET_ENVIRONMENT:-}
TARGET_CPU=${PDFium_TARGET_CPU:?}
CURRENT_CPU=${PDFium_CURRENT_CPU:-x64}
MUSL_URL=${MUSL_URL:-https://musl.cc}
ENABLE_V8=${PDFium_ENABLE_V8:-false}

DepotTools_URL='https://chromium.googlesource.com/chromium/tools/depot_tools.git'
DepotTools_DIR="$PWD/depot_tools"
# Must match SDK_VERSION in the pinned build repo's vs_toolchain.py /
# toolchain/win/setup_toolchain.py; GitHub runner images lag behind, so the
# win install step below installs this SDK when it's missing.
# (Ported from upstream bblanchon/pdfium-binaries commit 9dd99a89.)
WindowsSDK_VERSION='10.0.28000.0'
WindowsSDK_URL='https://go.microsoft.com/fwlink/?linkid=2370315'
WindowsSDK_DIR="/c/Program Files (x86)/Windows Kits/10/bin/$WindowsSDK_VERSION"

# Download depot_tools if not exists in this location
if [ ! -d "$DepotTools_DIR" ]; then
  git clone "$DepotTools_URL" "$DepotTools_DIR"
fi

echo "$DepotTools_DIR" >> "$PATH_FILE"

case "$TARGET_OS" in
  android)
    sudo apt-get update
    sudo apt-get install -y unzip

    # pdfium installs its version of the NDK, but we need one for compiling the example
    ANDROID_NDK_VERSION="r25c"
    ANDROID_NDK_FOLDER="android-ndk-$ANDROID_NDK_VERSION"
    ANDROID_NDK_ZIP="android-ndk-$ANDROID_NDK_VERSION-linux.zip"
    if [ ! -d "$ANDROID_NDK_FOLDER" ];
    then
      [ -f "$ANDROID_NDK_ZIP" ] || curl -Os "https://dl.google.com/android/repository/$ANDROID_NDK_ZIP"
      unzip -o -q "$ANDROID_NDK_ZIP"
      rm -f "$ANDROID_NDK_ZIP"
    fi
    echo "$PWD/$ANDROID_NDK_FOLDER/toolchains/llvm/prebuilt/linux-x86_64/bin" >> "$PATH_FILE"
    ;;

  linux)
    sudo apt-get update
    sudo apt-get install -y cmake pkg-config

    if [ "$TARGET_ENVIRONMENT" == "musl" ]; then

      # EXPECTED_TOOLPREFIX is what patches/musl/toolchain.gn invokes the
      # compiler as (e.g. x86_64-linux-musl-gcc). Different mirrors ship
      # toolchains with different binary prefixes (e.g. musl.cc uses
      # x86_64-linux-musl-, cross-tools/musl-cross uses x86_64-unknown-linux-musl-),
      # so we normalize via symlinks below.
      case "$TARGET_CPU" in
        x86)
          MUSL_VERSION="i686-linux-musl-cross"
          MUSL_MIRROR_VERSION="i686-unknown-linux-musl.tar.xz"
          EXPECTED_TOOLPREFIX="i686-linux-musl"
          PACKAGES="g++ g++-multilib"
          ;;

        x64)
          MUSL_VERSION="x86_64-linux-musl-cross"
          MUSL_MIRROR_VERSION="x86_64-unknown-linux-musl.tar.xz"
          EXPECTED_TOOLPREFIX="x86_64-linux-musl"
          PACKAGES="g++"
          ;;

        arm)
          MUSL_VERSION="arm-linux-musleabihf-cross"
          MUSL_MIRROR_VERSION="arm-unknown-linux-musleabihf.tar.xz"
          EXPECTED_TOOLPREFIX="arm-linux-musleabihf"
          PACKAGES="g++"
          ;;

        arm64)
          MUSL_VERSION="aarch64-linux-musl-cross"
          MUSL_MIRROR_VERSION="aarch64-unknown-linux-musl.tar.xz"
          EXPECTED_TOOLPREFIX="aarch64-linux-musl"
          PACKAGES="g++"
          ;;
      esac

      if [ ! -d "$MUSL_VERSION" ]; then
        # musl.cc / more.musl.cc are frequently unreachable from Azure-hosted
        # GitHub Actions runners (outbound to those hosts is blocked / times out).
        # Prefer GitHub-hosted mirrors first since GitHub.com is always reachable
        # from GHA runners, then fall back to the canonical musl.cc URLs.
        #
        # Allow overriding/extending the mirror list via the MUSL_URL env/secret:
        #   * If MUSL_URL is set to a full "https://host/path" prefix, the script
        #     will try "$MUSL_URL/$MUSL_VERSION.tgz" first.
        MUSL_MIRRORS=()
        if [ -n "${MUSL_URL:-}" ] && [ "$MUSL_URL" != "https://musl.cc" ]; then
          MUSL_MIRRORS+=("$MUSL_URL/$MUSL_VERSION.tgz")
        fi
        MUSL_MIRRORS+=(
          # GitHub-hosted mirrors of the musl.cc tarballs (reachable from GHA).
          "https://github.com/cross-tools/musl-cross/releases/latest/download/${MUSL_MIRROR_VERSION}"
          # Canonical mirrors (often unreachable from Azure runners, kept as last-resort).
          "https://musl.cc/$MUSL_VERSION.tgz"
          "https://more.musl.cc/11.2.1/x86_64-linux-musl/$MUSL_VERSION.tgz"
          "https://more.musl.cc/10/x86_64-linux-musl/$MUSL_VERSION.tgz"
        )
        downloaded=0
        for url in "${MUSL_MIRRORS[@]}"; do
          echo "Trying $url"
          # Derive output filename from the URL
          out_file="${url##*/}"
          if curl -fL --connect-timeout 15 --max-time 300 --retry 3 --retry-delay 5 -o "$out_file" "$url"; then
            case "$out_file" in
              *.tar.xz)
                valid=$(file "$out_file" 2>/dev/null | grep -qi 'XZ\|xz compressed' && echo 1 || echo 0)
                extract_cmd="tar xJf"
                ;;
              *.tgz|*.tar.gz)
                valid=$([ -s "$out_file" ] && file "$out_file" 2>/dev/null | grep -qi 'gzip' && echo 1 || echo 0)
                extract_cmd="tar xzf"
                ;;
              *)
                valid=0
                extract_cmd="tar xf"
                ;;
            esac
            if [ "$valid" -eq 1 ]; then
              downloaded=1
              break
            else
              echo "Downloaded file from $url is not a valid archive, trying next mirror..."
              rm -f "$out_file"
            fi
          fi
          echo "Download failed from $url, trying next mirror..."
        done

        if [ "$downloaded" -ne 1 ]; then
          echo "Failed to download $MUSL_VERSION from all mirrors" >&2
          exit 1
        fi

        # Extract into a fresh staging dir so we can discover the real top
        # level directory name (it differs between mirrors).
        rm -rf .musl_extract
        mkdir -p .musl_extract
        $extract_cmd "$out_file" -C .musl_extract
        rm -f "$out_file"
        # Some mirror tarballs (notably cross-tools/musl-cross) ship directory
        # entries with read-only permissions that tar preserves on extraction.
        # That leaves .musl_extract and/or its children without write access,
        # which breaks the rename / cleanup below with EACCES. Force write
        # permission on everything we just extracted before touching it.
        chmod -R u+w .musl_extract

        # Locate the toolchain root: the dir that contains a bin/ subdirectory
        # with a *-gcc binary. We accept any binary prefix here and normalize
        # below.
        TOOLCHAIN_GCC=$(find .musl_extract -maxdepth 4 -type f -name '*-gcc' \
                          -path '*/bin/*' 2>/dev/null | head -n1 || true)
        if [ -z "$TOOLCHAIN_GCC" ]; then
          # Some tarballs ship the gcc binary as a symlink instead of a regular
          # file — broaden the search.
          TOOLCHAIN_GCC=$(find .musl_extract -maxdepth 4 -name '*-gcc' \
                            -path '*/bin/*' 2>/dev/null | head -n1 || true)
        fi
        if [ -z "$TOOLCHAIN_GCC" ]; then
          echo "ERROR: could not find a *-gcc binary in the extracted toolchain" >&2
          find .musl_extract -maxdepth 5 -printf '%p\n' | head -50 >&2 || true
          exit 1
        fi
        TOOLCHAIN_BIN_DIR=$(dirname "$TOOLCHAIN_GCC")
        TOOLCHAIN_ROOT=$(dirname "$TOOLCHAIN_BIN_DIR")
        # The actual binary prefix shipped by this mirror (e.g.
        # "x86_64-linux-musl" from musl.cc, "x86_64-unknown-linux-musl" from
        # cross-tools/musl-cross).
        ACTUAL_GCC_NAME=$(basename "$TOOLCHAIN_GCC")
        ACTUAL_TOOLPREFIX="${ACTUAL_GCC_NAME%-gcc}"
        echo "Detected musl toolchain at: $TOOLCHAIN_ROOT (toolprefix: $ACTUAL_TOOLPREFIX)"

        # Move the discovered toolchain to the canonical $MUSL_VERSION dir.
        rm -rf "$MUSL_VERSION"
        mv "$TOOLCHAIN_ROOT" "$MUSL_VERSION"
        rm -rf .musl_extract

        # Normalize binary names: if the mirror ships a different toolprefix
        # than what patches/musl/toolchain.gn expects, create symlinks so
        # both names resolve.
        if [ "$ACTUAL_TOOLPREFIX" != "$EXPECTED_TOOLPREFIX" ]; then
          echo "Creating $EXPECTED_TOOLPREFIX-* symlinks (mirror ships $ACTUAL_TOOLPREFIX-*)"
          (
            cd "$MUSL_VERSION/bin"
            for f in "$ACTUAL_TOOLPREFIX"-*; do
              [ -e "$f" ] || continue
              suffix="${f#$ACTUAL_TOOLPREFIX-}"
              target="$EXPECTED_TOOLPREFIX-$suffix"
              [ -e "$target" ] || ln -s "$f" "$target"
            done
          )
        fi

        # Sanity check: the binary the build will invoke must exist and be
        # executable now.
        if [ ! -x "$MUSL_VERSION/bin/$EXPECTED_TOOLPREFIX-g++" ]; then
          echo "ERROR: $MUSL_VERSION/bin/$EXPECTED_TOOLPREFIX-g++ not found after install" >&2
          ls -la "$MUSL_VERSION/bin" >&2 || true
          exit 1
        fi
      fi
      echo "$PWD/$MUSL_VERSION/bin" >> "$PATH_FILE"
      # Also export PATH for the current step so subsequent commands in this
      # same script (apt-get etc.) can find the toolchain if needed.
      export PATH="$PWD/$MUSL_VERSION/bin:$PATH"

      sudo apt-get install -y $PACKAGES

    else # i.e. not musl

      case "$TARGET_CPU" in
        arm)
          sudo apt-get install -y libc6-i386 gcc-10-multilib g++-10-arm-linux-gnueabihf gcc-10-arm-linux-gnueabihf
          ;;

        arm64)
          sudo apt-get install -y libc6-i386 gcc-10-multilib g++-10-aarch64-linux-gnu gcc-10-aarch64-linux-gnu
          ;;

        ppc64)
          sudo apt-get install -y gcc-11-multilib g++-11-powerpc64le-linux-gnu gcc-11-powerpc64le-linux-gnu
          sudo update-alternatives --install /usr/bin/powerpc64le-linux-gnu-gcc powerpc64le-linux-gnu-gcc /usr/bin/powerpc64le-linux-gnu-gcc-11 100
          sudo update-alternatives --install /usr/bin/powerpc64le-linux-gnu-g++ powerpc64le-linux-gnu-g++ /usr/bin/powerpc64le-linux-gnu-g++-11 100
          sudo update-alternatives --set powerpc64le-linux-gnu-gcc /usr/bin/powerpc64le-linux-gnu-gcc-11
          sudo update-alternatives --set powerpc64le-linux-gnu-g++ /usr/bin/powerpc64le-linux-gnu-g++-11
          ;;

        x86)
          sudo apt-get install -y g++-multilib
          ;;

        x64)
          sudo apt-get install -y g++
          ;;
      esac

    fi
    ;;

  win)
    if [ ! -d "$WindowsSDK_DIR/$TARGET_CPU" ]; then
      WindowsSDK_INSTALLER="$TEMP/winsdksetup.exe"

      curl -sL -o "$WindowsSDK_INSTALLER" "$WindowsSDK_URL"

      MSYS2_ARG_CONV_EXCL="*" "$WindowsSDK_INSTALLER" \
        /features \
        "OptionId.DesktopCPP$TARGET_CPU" \
        /ceip off \
        /quiet \
        /norestart
    fi

    echo "$WindowsSDK_DIR/$CURRENT_CPU" >> "$PATH_FILE"
    ;;

  mac|ios)
    sudo xcode-select -s "/Applications/Xcode_26.0.app"
    ;;

  emscripten)
    if [ "$ENABLE_V8" == "true" ]; then
      sudo apt-get update
      # We need to install the snapshot toolchain for x86
      sudo apt-get install -y g++-multilib
    fi
esac
