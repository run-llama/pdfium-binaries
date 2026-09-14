# Print the export names of a PE (DLL). Stdlib only; used by steps/07-stage.sh
# on Windows, where the bundled LLVM package ships no llvm-readobj.
import struct, sys
d = open(sys.argv[1], 'rb').read()
pe = struct.unpack_from('<I', d, 0x3c)[0]
assert d[pe:pe+4] == b'PE\0\0', 'not a PE file'
nsec, opt_size = struct.unpack_from('<H', d, pe+6)[0], struct.unpack_from('<H', d, pe+20)[0]
opt = pe + 24
magic = struct.unpack_from('<H', d, opt)[0]
dd = opt + (96 if magic == 0x10b else 112)          # data directories
exp_rva, exp_size = struct.unpack_from('<II', d, dd)
secs = []
for i in range(nsec):
    s = opt + opt_size + i*40
    vsize, va, rsize, raw = struct.unpack_from('<IIII', d, s+8)
    secs.append((va, max(vsize, rsize), raw))
def off(rva):
    for va, size, raw in secs:
        if va <= rva < va + size:
            return raw + (rva - va)
    raise SystemExit(f'RVA {rva:#x} outside all sections')
if exp_rva == 0:
    raise SystemExit('no export directory')
e = off(exp_rva)
nnames, names_rva = struct.unpack_from('<I', d, e+24)[0], struct.unpack_from('<I', d, e+32)[0]
p = off(names_rva)
for i in range(nnames):
    rva = struct.unpack_from('<I', d, p + 4*i)[0]
    o = off(rva)
    print(d[o:d.index(b'\0', o)].decode())
