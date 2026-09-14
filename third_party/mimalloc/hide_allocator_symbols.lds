/* Linux version script: make this module's global operator new/delete
   (core/fxcrt/fx_memory_mimalloc.cpp) local, so they are neither exported nor
   preemptible by an allocator in the host process. Everything else keeps its
   default (visibility-driven) export status. */
{
  local:
    _Zn*;
    _Zd*;
};
