
<p align="center">
  <img alt="PDFium binaries" src=".github/images/header.svg" />
</p>

# Pre-compiled binaries of PDFium (LlamaIndex fork)

This repository is a fork of [bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries) that adds extra PDFium API functions useful for advanced PDF text extraction and analysis.

All additional patches live in `patches/llamaparse/`. The patches expose functions for:
- Font type detection (`FPDFFont_GetType`)
- Charcode-based glyph width and path retrieval (`FPDFFont_GetGlyphWidthFromCharCode`, `FPDFFont_GetGlyphPathFromCharCode`)
- Original character code access (`FPDFText_GetCharCode`)
- Annotation object numbers (`FPDFAnnot_GetObjNum`)
- Structure element child object numbers (`FPDF_StructElement_GetChildObjNum`)

## Download

Here are the download links for the latest release:

<table>
  <tr>
    <th>OS</th>
    <th>Env</th>
    <th>CPU</th>
    <th>PDFium</th>
    <th>PDFium V8</th>
  </tr>

  <tr>
    <td rowspan="8">Linux</td>
    <td rowspan="5">glibc</td>
    <td>arm</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-arm.tgz">pdfium-linux-arm.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-linux-arm.tgz">pdfium-v8-linux-arm.tgz</a></td>
  </tr>
  <tr>
    <td>arm64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-arm64.tgz">pdfium-linux-arm64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-linux-arm64.tgz">pdfium-v8-linux-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>ppc64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-ppc64.tgz">pdfium-linux-ppc64.tgz</a></td>
    <td>not available</td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-x64.tgz">pdfium-linux-x64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-linux-x64.tgz">pdfium-v8-linux-x64.tgz</a></td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-x86.tgz">pdfium-linux-x86.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-linux-x86.tgz">pdfium-v8-linux-x86.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="3">musl</td>
    <td>arm64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-musl-arm64.tgz">pdfium-linux-musl-arm64.tgz</a></td>
    <td>not available</td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-musl-x64.tgz">pdfium-linux-musl-x64.tgz</a></td>
    <td>not available</td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-linux-musl-x86.tgz">pdfium-linux-musl-x86.tgz</a></td>
    <td>not available</td>
  </tr>

  <tr>
    <td rowspan="3" colspan="2">macOS</td>
    <td>arm64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-mac-arm64.tgz">pdfium-mac-arm64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-mac-arm64.tgz">pdfium-v8-mac-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-mac-x64.tgz">pdfium-mac-x64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-mac-x64.tgz">pdfium-v8-mac-x64.tgz</a></td>
  </tr>
  <tr>
    <td>univ</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-mac-univ.tgz">pdfium-mac-univ.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-mac-univ.tgz">pdfium-v8-mac-univ.tgz</a></td>
  </tr>

  <tr>
    <td rowspan="3" colspan="2">Windows</td>
    <td>arm64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-win-arm64.tgz">pdfium-win-arm64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-win-arm64.tgz">pdfium-v8-win-arm64.tgz</a></td>
  </tr>
  <tr>
    <td>x64</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-win-x64.tgz">pdfium-win-x64.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-win-x64.tgz">pdfium-v8-win-x64.tgz</a></td>
  </tr>
  <tr>
    <td>x86</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-win-x86.tgz">pdfium-win-x86.tgz</a></td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-v8-win-x86.tgz">pdfium-v8-win-x86.tgz</a></td>
  </tr>

  <tr>
    <td colspan="3">WebAssembly</td>
    <td><a href="https://github.com/run-llama/pdfium-binaries/releases/latest/download/pdfium-wasm.tgz">pdfium-wasm.tgz</a></td>
    <td>not supported</td>
  </tr>
</table>

See the [Releases page](https://github.com/run-llama/pdfium-binaries/releases) to download older versions.

## How to use PDFium in a CMake project

1. Unzip the downloaded package in a folder (e.g., `C:\Libraries\pdfium`)
2. Set the environment variable `PDFium_DIR` to this folder (e.g., `C:\Libraries\pdfium`)
3. In your `CMakeLists.txt`, add

        find_package(PDFium)

4. Then link your executable with PDFium:

        target_link_libraries(my_exe pdfium)

5. On Windows, make sure that `pdfium.dll` can be found by your executable (copy it to the same folder, or add it to the `PATH`).

## Contributing patches to PDFium

1. Obtain PDFium source from https://pdfium.googlesource.com/pdfium/ (requires using Google's toolchain for configuring/building Chromium)
2. Apply the current patchset to PDFium source (from pdfium repo):
   ```
   patch --verbose -p1 <path-to-pdfium-binaries>/patches/llamaparse/pdfium.patch
   ```
3. Make additional changes
    - To test changes, build locally using `build.sh`:
      ```
      PDFium_URL=~/git/my-pdfium-fork/pdfium ./build.sh mac arm64
      ```
      On x64 Linux, replace `mac arm64` with `linux x64`.
4. Generate a new patch with your changes relative to PDFium `main` (from pdfium repo):
   ```
   git diff origin/main > <path-to-pdfium-binaries>/patches/llamaparse/pdfium.patch
   ```
5. Commit and push your new patch in this repository
   - If your patch is large enough to warrant its own patch file, you will also need to add a corresponding `apply_patch` call in `steps/03-patch.sh`

### macOS local development

By default, the build scripts look for Xcode where it is installed on GitHub Actions (`/Applications/Xcode_26.0.app`).
If you have only one Xcode version installed, you may need to edit `steps/01-install.sh` to point to your local Xcode (i.e. `/Applications/Xcode.app`).

## PDFium API documentation

See the [PDFium API documentation on developers.foxit.com](https://developers.foxit.com/resources/pdf-sdk/c_api_reference_pdfium/index.html).

## Acknowledgments

This fork is based on [bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries). Additional patches by [@pmrowla](https://github.com/pmrowla).

**Disclaimer**: This project isn't affiliated with Google or Foxit.

## License

See [LICENSE](LICENSE).
