# mimalloc (vendored)

mimalloc v3.1.5, https://github.com/microsoft/mimalloc, MIT (see LICENSE).
`include/` and `src/` are verbatim; `BUILD.gn` is ours.

`steps/03-patch.sh` copies this directory to `pdfium/third_party/mimalloc`.
When the `pdf_use_mimalloc` GN arg is on (set by `steps/05-configure.sh` for
linux, mac and win), PDFium's own allocation funnels -- fxcrt's
`FX_Alloc`/`FX_StringAlloc`/`FX_AlignedAlloc` family and the module's global
C++ `operator new`/`delete` -- call `mi_*` directly (see
`core/fpdfapi/../fxcrt/fx_memory_mimalloc.cpp` in `patches/llamaparse/pdfium.patch`).

This is deliberately NOT a malloc override: libc `malloc` is untouched, nothing
allocator-related is exported, and the host process (node, python) keeps its own
allocator. `steps/07-stage.sh` fails the build if any allocator symbol leaks
into the export table.
