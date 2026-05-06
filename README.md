
<p align="center">
  <img alt="PDFium binaries" src=".github/images/header.svg" />
</p>

# Pre-compiled binaries of PDFium

## LlamaParse overview

This repository is a fork of the [pdfium-binaries](https://github.com/bblanchon/pdfium-binaries) used for automatically building PDFium with LlamaParse specific additions.
LlamaParse changes live in `patches/llamaparse`.

Most platforms supported in the original pdfium-binaries have been removed or disabled in this fork.
Currently we build for the following platforms (both with and without `v8` JS engine):

- `linux-arm64`
- `linux-x64`
- `mac-arm64`

Currently Parse only uses non-v8 `linux-x64` builds in production.
Everything else is built for local development and testing.

If for some reason you need another platform, if it's supported in the original pdfium-binaries it should still work in this fork (LlamaParse patches should never be platform specific).
To re-enable a platform, re-add it to `.github/workflows/build-all.yml` (refer to the original repo for anything else that may need to be turned on for certain platforms).

## To make modifications to PDFium:

1. Obtain PDFium source from https://pdfium.googlesource.com/pdfium/ (requires using Google's toolchain for configuring/building Chromium)
2. Apply the current LlamaParse patchset to PDFium source (from pdfium repo):
   ```
   patch --verbose -p1 <path-to-pdfium-binaries>/patches/llamaparse/pdfium.patch
   ```
3. Make additional changes
    - To test changes, the simplest way to build is to run `build.sh` from this pdfium-binaries with `PDFium_URL` set in your environment to use your local PDFium source dir like:
      ```
      PDFium_URL=~git/my-pdfium-fork/pdfium ./build.sh mac arm64
      ```
      On x64 Linux, replace `mac arm64` with `linux x64`.
    - After you have a local pdfium-binaries build, you can then copy `staging/*` into the platform repo `llamaparse/pdfium/pdfium-binaries/` directory
    - If you set a branch name in your local PDFium dir, pass `-b <branch-name>` into `./build.sh`.
4. Generate a new patch with your changes relative to PDFium `main` (from pdfium repo):
   ```
   git diff origin/main > <path-to-pdfium-binaries>/patches/llamaparse/pdfium.patch
   ```
5. Commit/push/etc your new patch in this pdfium-binaries fork
   - If your patch is large enough to warrant it's own patch file, you need will also to add a corresponding `apply_patch` call in `steps/03-patch.sh`

### macOS local development:

By default, the pdfium-binaries build scripts look for Xcode 26 where it is installed on Github Actions (`/Applications/Xcode_26.0.app`).
If you have only one Xcode version installed, you may need to edit `steps/01-install.sh` to find Xcode on your local machine (i.e. `/Applications/Xcode.app` with no version string by default).

---

[![Patches](https://github.com/bblanchon/pdfium-binaries/actions/workflows/patch.yml/badge.svg?branch=master)](https://github.com/bblanchon/pdfium-binaries/actions/workflows/patch.yml)
[![Total downloads](https://img.shields.io/github/downloads/bblanchon/pdfium-binaries/total)](https://github.com/bblanchon/pdfium-binaries/releases/)

[![Latest release](https://img.shields.io/github/v/release/bblanchon/pdfium-binaries?display_name=release&label=github)](https://github.com/bblanchon/pdfium-binaries/releases/latest/)
[![Nuget](https://img.shields.io/nuget/v/bblanchon.PDFium)](https://www.nuget.org/packages/bblanchon.PDFium/)
[![Conda](https://img.shields.io/conda/v/bblanchon/pdfium-binaries?label=conda)](https://anaconda.org/bblanchon/pdfium-binaries)

This project hosts pre-compiled binaries of the [PDFium library](https://pdfium.googlesource.com/pdfium/), an open-source library for PDF manipulation and rendering.

Builds have been triggered automatically every Monday since 2017.

**Disclaimer**: This project isn't affiliated with Google or Foxit.

## Download

Here are the download links for latest release:

<table>
  <tr>
    <th>OS</th>
    <th>Env</th>
    <th>CPU</th>
    <th>PDFium</th>
    <th>PDFium V8</th>
  </tr>

  <tr>
    <td rowspan="4" colspan=2>Android</td>
    <td>arm</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-android-arm.tgz">pdfium-android-arm.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-android-arm.tgz">pdfium-v8-android-arm.tgz</a></td>
  </tr>
  <tr>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-android-arm64.tgz">pdfium-android-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-android-arm64.tgz">pdfium-v8-android-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-android-x64.tgz">pdfium-android-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-android-x64.tgz">pdfium-v8-android-x64.tgz</a></td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-android-x86.tgz">pdfium-android-x86.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-android-x86.tgz">pdfium-v8-android-x86.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="5">iOS</td>
    <td rowspan="2">catalyst</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-ios-catalyst-arm64.tgz">pdfium-ios-catalyst-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-ios-catalyst-arm64.tgz">pdfium-v8-ios-catalyst-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-ios-catalyst-x64.tgz">pdfium-ios-catalyst-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-ios-catalyst-x64.tgz">pdfium-v8-ios-catalyst-x64.tgz</a></td>
  </tr>

  <tr>
    <td>device</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-ios-device-arm64.tgz">pdfium-ios-device-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-ios-device-arm64.tgz">pdfium-v8-ios-device-arm64.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="2">simulator</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-ios-simulator-arm64.tgz">pdfium-ios-simulator-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-ios-simulator-arm64.tgz">pdfium-v8-ios-simulator-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-ios-simulator-x64.tgz">pdfium-ios-simulator-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-ios-simulator-x64.tgz">pdfium-v8-ios-simulator-x64.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="8">Linux</td>
    <td rowspan="5">glibc</td>
    <td>arm</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-arm.tgz">pdfium-linux-arm.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-linux-arm.tgz">pdfium-v8-linux-arm.tgz</a></td>
  </tr>
  <tr>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-arm64.tgz">pdfium-linux-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-linux-arm64.tgz">pdfium-v8-linux-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>ppc64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-ppc64.tgz">pdfium-linux-ppc64.tgz</a></td>
    <td>not tested yet</td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-x64.tgz">pdfium-linux-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-linux-x64.tgz">pdfium-v8-linux-x64.tgz</a></td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-x86.tgz">pdfium-linux-x86.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-linux-x86.tgz">pdfium-v8-linux-x86.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="3">musl</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-musl-arm64.tgz">pdfium-linux-musl-arm64.tgz</a></td>
    <td>failing (#192)</td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-musl-x64.tgz">pdfium-linux-musl-x64.tgz</a></td>
    <td>failing (#191)</td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux-musl-x86.tgz">pdfium-linux-musl-x86.tgz</a></td>
    <td>failing (#193)</td>
  </tr>

  <tr>
    <td rowspan="3" colspan="2">macOS</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-mac-arm64.tgz">pdfium-mac-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-mac-arm64.tgz">pdfium-v8-mac-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-mac-x64.tgz">pdfium-mac-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-mac-x64.tgz">pdfium-v8-mac-x64.tgz</a></td>
  </tr>
  <tr>
    <td>univ</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-mac-univ.tgz">pdfium-mac-univ.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-mac-univ.tgz">pdfium-v8-mac-univ.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="3" colspan="2">Windows</td>
    <td>arm64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-win-arm64.tgz">pdfium-win-arm64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-win-arm64.tgz">pdfium-v8-win-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-win-x64.tgz">pdfium-win-x64.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-win-x64.tgz">pdfium-v8-win-x64.tgz</a></td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-win-x86.tgz">pdfium-win-x86.tgz</a></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-v8-win-x86.tgz">pdfium-v8-win-x86.tgz</a></td>
  </tr>

  <tr>
    <td colspan="3">WebAssembly<sup>1</sup></td>
    <td><a href="https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-wasm.tgz">pdfium-wasm.tgz</a></td>
    <td>not supported</td>
  </tr>
</table>

<small>1: WebAssembly build is experimental; please [provide feedback](https://github.com/bblanchon/pdfium-binaries/issues/28).</small>

See the [Releases page](https://github.com/bblanchon/pdfium-binaries/releases) to download older versions of PDFium.

### NuGet Packages

The following NuGet packages are available:

<table>
  <tr>
    <th>OS</th>
    <th>PDFium</th>
    <th>PDFium V8</th>
  </tr>

  <tr>
    <td>All (meta package)</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium/">bblanchon.PDFium</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8/">bblanchon.PDFiumV8</a></td>
  </tr>

  <tr>
    <td>Android</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.Android/">bblanchon.PDFium.Android</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8.Android/">bblanchon.PDFiumV8.Android</a></td>
  </tr>

  <tr>
    <td>iOS</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.iOS/">bblanchon.PDFium.iOS</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8.iOS/">bblanchon.PDFiumV8.iOS</a></td>
  </tr>

  <tr>
    <td>Linux</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.Linux/">bblanchon.PDFium.Linux</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8.Linux/">bblanchon.PDFiumV8.Linux</a></td>
  </tr>

  <tr>
    <td>macOS</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.macOS/">bblanchon.PDFium.macOS</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8.macOS/">bblanchon.PDFiumV8.macOS</a></td>
  </tr>

  <tr>
    <td>Windows</td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.Win32/">bblanchon.PDFium.Win32</a></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFiumV8.Win32/">bblanchon.PDFiumV8.Win32</a></td>
  </tr>

  <tr>
    <td>WebAssembly<sup>1</sup></td>
    <td><a href="https://www.nuget.org/packages/bblanchon.PDFium.WebAssembly/">bblanchon.PDFium.WebAssembly</a></td>
    <td>not supported</td>
  </tr>
</table>

<small>1: WebAssembly build is experimental; please [provide feedback](https://github.com/bblanchon/pdfium-binaries/issues/28).</small>

**HELP WANTED!**  
I can provide packages for your favorite package manager, but I need help from someone who knows the format. Contact me via [GitHub issues](https://github.com/bblanchon/pdfium-binaries/issues) if you want to help.

## Documentation

### PDFium API documentation

Please find the [documentation of the PDFium API on developers.foxit.com](https://developers.foxit.com/resources/pdf-sdk/c_api_reference_pdfium/index.html).

### How to use PDFium in a CMake project

1. Unzip the downloaded package in a folder (e.g., `C:\Libraries\pdfium`)
2. Set the environment variable `PDFium_DIR` to this folder (e.g., `C:\Libraries\pdfium`)
3. In your `CMakeLists.txt`, add

        find_package(PDFium)

4. Then link your executable with PDFium:

        target_link_libraries(my_exe pdfium)

5. On Windows, make sure that `pdfium.dll` can be found by your executable (copy it on the same folder, or put it on the `PATH`).


## Related projects

The following projects use (or recommend using) our PDFium builds:

| Name                           | Language | Description                                                                             |
| :----------------------------- | :------- | :-------------------------------------------------------------------------------------- |
| [dart_pdf][dart_pdf]           | Dart     | PDF creation module for dart/flutter                                                    |
| [DtronixPdf][dtronixpdf]       | C#       | PDF viewer and editor toolset                                                           |
| [go-pdfium][go-pdfium]         | Go       | Go wrapper around PDFium with image rendering and text extraction                       |
| [libvips][libvips]             | C        | A performant image processing library                                                   |
| [PDFium RS][pdfium_rs]         | Rust     | Rust wrapper around PDFium                                                              |
| [pdfium-render][pdfium-render] | Rust     | A high-level idiomatic Rust wrapper around PDFium                                       |
| [pdfium-vfp][pdfium-vfp]       | VFP      | PDF Viewer component for Visual FoxPro                                                  |
| [pdfium.vapi][pdfium-vapi]     | Vala     | Vala vapi binding and GTK demo app to display PDF content                               |
| [PDFiumCore][pdfiumcore]       | C#       | .NET Standard P/Invoke bindings for PDFium                                              |
| [PdfiumLib][pdfiumlib]         | Pascal   | An interface to libpdfium for Delphi                                                    |
| [PdfLibCore][pdflibcore]       | C#       | A fast PDF editing and reading library for modern .NET Core applications                |
| [PDFtoImage][pdftoimage]       | C#       | .NET library to render PDF content into images                                          |
| [PDFtoZPL][pdftozpl]           | C#       | A .NET library to convert PDF files (and bitmaps) into Zebra Programming Language code  |
| [PDFx][pdfx]                   | Dart     | Flutter Render & show PDF documents on Web, MacOs 10.11+, Android 5.0+, iOS and Windows |
| [PyPDFium2][pypdfium2]         | Python   | Python bindings to PDFium                                                               |
| [Spacedrive][spacedrive]       | Rust/TS  | Cross-platform file manager, powered by a virtual distributed filesystem                |
| [wxPDFView][wxpdfview]         | C++      | wxWidgets components to display PDF content                                             |

*Did we miss a project? Please open a PR!*  


## Contributors

<table>
  <thead>
    <tr>
      <th></th>
      <th>Username</th>
      <th>Contributions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="https://github.com/bblanchon.png" width="48" height="48" alt="Benoit Blanchon"></td>
      <td><a href="https://github.com/bblanchon"><code>@bblanchon</code></a></td>
      <td>Main contributor</td>
    </tr>
    <tr>
      <td><img src="https://github.com/ChristofferGreen.png" width="48" height="48" alt="Christoffer Green"></td>
      <td><a href="https://github.com/ChristofferGreen"><code>@ChristofferGreen</code></a></td>
      <td>Linux ARM build</td>
    </tr>
    <tr>
      <td><img src="https://github.com/jerbob92.png" width="48" height="48" alt="Jeroen Bobbeldijk"></td>
      <td><a href="https://github.com/jerbob92"><code>@jerbob92</code></a></td>
      <td>Musl and WebAssembly builds</td>
    </tr>
    <tr>
      <td><img src="https://github.com/mara004.png" width="48" height="48" alt="mara004"></td>
      <td><a href="https://github.com/mara004"><code>@mara004</code></a></td>
      <td>Conda packages. ppc64 build. Constant aid.</td>
    </tr>
    <tr>
      <td><img src="https://github.com/mgiessing.png" width="48" height="48" alt="Marvin Gießing"></td>
      <td><a href="https://github.com/mgiessing"><code>@mgiessing</code></a></td>
      <td>ppc64 build</td>
    </tr>
    <tr>
      <td><img src="https://github.com/sungaila.png" width="48" height="48" alt="David Sungaila"></td>
      <td><a href="https://github.com/sungaila"><code>@sungaila</code></a></td>
      <td>NuGet packages</td>
    </tr>
    <tr>
      <td><img src="https://github.com/TcT2k.png" width="48" height="48" alt="Tobias Taschner"></td>
      <td><a href="https://github.com/TcT2k"><code>@TcT2k</code></a></td>
      <td>macOS and V8 builds</td>
    </tr>
  </tbody>
</table

[dart_pdf]: https://github.com/DavBfr/dart_pdf
[dtronixpdf]: https://github.com/Dtronix/DtronixPdf
[go-pdfium]: https://github.com/klippa-app/go-pdfium
[libvips]: https://github.com/libvips/libvips
[pdfium_rs]: https://github.com/asafigan/pdfium_rs
[pdfium-render]: https://github.com/ajrcarey/pdfium-render
[pdfium-vapi]: https://github.com/taozuhong/pdfium.vapi
[pdfium-vfp]: https://github.com/dmitriychunikhin/pdfium-vfp
[pdfiumcore]: https://github.com/Dtronix/PDFiumCore
[pdfiumlib]: https://github.com/ahausladen/PdfiumLib
[pdflibcore]: https://github.com/jbaarssen/PdfLibCore
[pdftoimage]: https://github.com/sungaila/PDFtoImage
[pdftozpl]: https://github.com/sungaila/PDFtoZPL
[pdfx]: https://github.com/scerio/packages.flutter/tree/main/packages/pdfx
[pypdfium2]: https://github.com/pypdfium2-team/pypdfium2
[spacedrive]: https://github.com/spacedriveapp/spacedrive
[wxpdfview]: https://github.com/TcT2k/wxPDFView
