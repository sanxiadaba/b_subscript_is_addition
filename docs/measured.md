# 本机实测输出（原样粘贴）

> ★ **这个文件是生成的，不是手写的。** 由 `pnpm wf publish <期>` 从
> `build/verify/OUTPUT.txt` 复制而来；路径已改成相对写法，**行数与内容未改**。
> 重新跑一遍：`pwsh -File src/run.ps1`（见 README 的「复现」）。

```text
=== environment ===
gcc.exe (i686-posix-dwarf-rev0, Built by MinGW-W64 project) 4.9.4

=== a[i] vs i[a]: one expression per line ===
compiler: ZERO warnings, exit 0
A1 arr[2] = 30
A2 2[arr] = 30
A3 p[2] = 30
A4 2[p] = 30
A5 *(p+2) = 30
A6 (2+p)[0] = 30
A7 (p+2)[0] = 30
A8 hello[1] = e
A9 1[hello] = e

=== sizeof and decay ===
compiler: ZERO warnings, exit 0
B1 sizeof(arr) = 20
B2 sizeof(p) = 4
B3 f(arr) = 4
B4 n1/n2 (sizeof(arr)/sizeof(p)) = 5
B5 sizeof(arr)/sizeof(*arr) = 5

=== disassembly: q[i] and i[q] (i686, -O2) ===
-- get_i --
   0:	8b 54 24 08          	mov    0x8(%esp),%edx
   4:	8b 44 24 04          	mov    0x4(%esp),%eax
   8:	8b 04 90             	mov    (%eax,%edx,4),%eax
   b:	c3                   	ret
   c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
-- get_commuted --
  10:	8b 54 24 08          	mov    0x8(%esp),%edx
  14:	8b 44 24 04          	mov    0x4(%esp),%eax
  18:	8b 04 90             	mov    (%eax,%edx,4),%eax
  1b:	c3                   	ret
  1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
-- get_char --
  20:	8b 44 24 08          	mov    0x8(%esp),%eax
  24:	8b 54 24 04          	mov    0x4(%esp),%edx
  28:	0f be 04 02          	movsbl (%edx,%eax,1),%eax
  2c:	c3                   	ret
  2d:	90                   	nop
  2e:	90                   	nop
  2f:	90                   	nop

(reading: mov (%eax,%edx,4) -- that 4 is sizeof(int); with char* it becomes 1)

=== c_asm.disasm (instructions only, for on-screen use) ===
mov	0x8(%esp),%edx
mov	0x4(%esp),%eax
mov	(%eax,%edx,4),%eax
ret
lea	0x0(%esi,%eiz,1),%esi
mov	0x8(%esp),%edx
mov	0x4(%esp),%eax
mov	(%eax,%edx,4),%eax
ret
lea	0x0(%esi,%eiz,1),%esi
mov	0x8(%esp),%eax
mov	0x4(%esp),%edx
movsbl	(%edx,%eax,1),%eax
ret
nop
nop
nop

=== negative subscript on an ARRAY (compiler warns) ===
WARN: <repo>/episodes\2026-09-25-subscript-is-addition\build\verify\d_bounds.c:3:16: warning: array subscript is below array bounds [-Warray-bounds]

=== negative subscript on a POINTER (silent) ===
compiler: ZERO warnings, exit 0

=== nested subscripts: calls and expressions inside [] ===
compiler: ZERO warnings, exit 0
C1 p[idx()] = 30
C2 idx()[p] = 30
C3 (2+1)[arr] = 40
C4 1[p+1] = 30
C5 idx()[p+0] = 30
C6 2[p+1] = 40
C7 (1+1)[arr+2] = 50
C8 arr[2+1] = 40
C9 p[idx()+0] = 30
C10 p[1+1] = 30
C11 arr[1+2] = 40

=== 2D array: chained subscripts are two additions ===
compiler: ZERO warnings, exit 0
D1 m[1][2] = 6
D2 *(*(m+1)+2) = 6
D3 2[1[m]] = 6
D4 m[1][2] = 6

=== the literal type of arr[2] is int, not int* ===
DIAG: i_type.c:5:16: warning: initialization makes pointer from integer without a cast

=== sizeof arr[2] vs sizeof(int*) -- the numeric side-note ===
compiler: ZERO warnings, exit 0
J1 sizeof(arr[2]) = 4
J2 sizeof(int*)   = 4
J3 sizeof(arr)    = 20

=== end ===
```
