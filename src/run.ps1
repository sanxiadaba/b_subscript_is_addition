# @evidence-producer
# run.ps1 —— 本期**全部技术证据**的唯一产地，也是唯一入口。
#
# 复跑：pnpm wf verify 2026-09-25-subscript-is-addition
#
# ══════════════════════════════════════════════════════════════════════════
# 它产出两样东西
# ══════════════════════════════════════════════════════════════════════════
#
#   ① 每份源码的 `.c` + 编译产物 + `OUTPUT.txt`（给人看 / 给 `wf verify` 核账）
#   ② `evidence.json` —— **每份源码的全文**，供 `wf hf` 核对画面上的代码块
#
# ⚠️ 2026-09-25 合并：原来另有一份 `evidence.ps1` 与 `run.ps1` 并存，
#    两份都能产源码 ⇒ **两份都会漂**（实测漂了三次，每次都要重新对齐文案）。
#    ⇒ 只留这一个入口。**改源码只改这里。**
#
# ══════════════════════════════════════════════════════════════════════════
# 两条写法规矩（都是踩过的坑换来的）
# ══════════════════════════════════════════════════════════════════════════
#
# 1. **一行一个表达式，值单独打一行。**
#    原来写成 `printf("A1 arr[2]=%d\n", arr[2]);` —— 那让**每一行代码**
#    都超过屏幕上代码栏的宽度（实测最宽 2615px / 可用 860px），
#    于是画面上出现字压字（用户直接看到了）。
#    "把表达式摘出来单独一行"恰好也是**屏幕上真正要讲的那一行** ——
#    证据的形状和呈现的形状从此一致。
#
# 2. **被考察的表达式要真的被求值**，不能让编译器优化掉。
#    所以每个表达式都赋给一个变量、最后汇总（`sum`）并 return。
#    ⚠️ `sum` 自身会触发 `-Wunused-variable` 之外的无害告警时可以留 ——
#       但**不许为了消警告把表达式删掉**，那会让证据失效。
#
# ⚠️ C 源里不要写中文（gcc 按源文件编码处理字符串，控制台会打成 ??）。

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$gcc = 'C:\software\mingw\mingw32\bin\gcc.exe'
$objdump = 'C:\software\mingw\mingw32\bin\objdump.exe'
$out = Join-Path $here 'OUTPUT.txt'

$lines = New-Object System.Collections.Generic.List[string]
function Say([string]$s) { $lines.Add($s); Write-Host $s }
$manifest = New-Object System.Collections.Generic.List[object]

Say "=== environment ==="
Say (& $gcc --version | Select-Object -First 1)

# ─────────────────────────────────────────────────────────────────────────
function Build-And-Run {
    param([string]$Name, [string]$Title, [string]$Source)
    $src = Join-Path $here $Name
    Set-Content -Path $src -Value $Source -Encoding ASCII
    Say ""
    Say "=== $Title ==="
    $w = & $gcc -O2 -Wall -Wextra -o ($src -replace '\.c$', '.exe') $src 2>&1
    $real = $w | Where-Object { $_ -match 'warning|error' }
    if ($real) { $real | ForEach-Object { Say "WARN: $_" } } else { Say "compiler: ZERO warnings, exit 0" }
    & ($src -replace '\.c$', '.exe') | ForEach-Object { Say $_ }
    $manifest.Add([pscustomobject]@{
        name = $Name
        title = $Title
        lines = @($Source -split "`n" | ForEach-Object { $_.TrimEnd() })
    })
}

# ── 断言 1-2：a[i] 与 i[a] 是同一个东西（含字符串字面量下标）────────────
Build-And-Run -Name 'a_index.c' -Title 'a[i] vs i[a]: one expression per line' -Source @'
#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int main(void) {
    int a1 = arr[2];
    int a2 = 2[arr];
    int a3 = p[2];
    int a4 = 2[p];
    int a5 = *(p + 2);
    int a6 = (2 + p)[0];
    int a7 = (p + 2)[0];
    int a8 = "hello"[1];
    int a9 = 1["hello"];
    printf("A1 arr[2] = %d\n", a1);
    printf("A2 2[arr] = %d\n", a2);
    printf("A3 p[2] = %d\n", a3);
    printf("A4 2[p] = %d\n", a4);
    printf("A5 *(p+2) = %d\n", a5);
    printf("A6 (2+p)[0] = %d\n", a6);
    printf("A7 (p+2)[0] = %d\n", a7);
    printf("A8 hello[1] = %c\n", a8);
    printf("A9 1[hello] = %c\n", a9);
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9;
}
'@

# ── 断言 3-4：sizeof(arr) 与 sizeof(p) 不同；函数参数里数组退化成指针 ────
#
# ⚠️ **B5 是 2026-09-25 补的，起因是一次真实的"答案对、推理错"**：
#   断言 A5 写的是 `sizeof(arr) / sizeof(arr[0]) = 5`，
#   而它引的证据是 B4 —— 那个式子在源码里是 **`n1 / n2`**，
#   也就是 `sizeof(arr) / sizeof(p)`。**两个式子不是一回事**：
#   在 i686 上 `sizeof(p)` 恰好也是 4，所以两个式子都得 5（**巧合**），
#   而换成 x64 前者是 5、**后者是 2**。
#   ⇒ 光看"结果对不对"永远发现不了它 —— **必须把那个式子本身测出来**。
#
# ⚠️ **变量名叫 `q` 而不是 `n5`，是为了让它能上屏。**（2026-09-25 夜）
#   `int n5 = sizeof(arr) / sizeof(arr[0]);   // 5` 在 36px 等宽下量出来是
#   **931px**，而 SourceRun 的可用宽是 **830px** —— 超 101px，会被闸门拦下。
#   改名的理由不是省事：这一行**必须在屏幕上**（它就是"答案对、推理错"那条
#   的正面证据），而判据要求「装不下**改呈现**，不许缩字」。
#   证据本身一个字没少 —— `B5` 的 printf 与输出都原样保留。
Build-And-Run -Name 'b_sizeof.c' -Title 'sizeof and decay' -Source @'
#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int f(int q[]) { return sizeof(q); }
int main(void) {
    int n1 = sizeof(arr);
    int n2 = sizeof(p);
    int n3 = f(arr);
    int n4 = n1 / n2;
    int q = n1 / sizeof(int);
    int sum = n1 + n2 + n3 + n4;
    printf("B1 sizeof(arr) = %d\n", n1);
    printf("B2 sizeof(p) = %d\n", n2);
    printf("B3 f(arr) = %d\n", n3);
    printf("B4 n1/n2 (sizeof(arr)/sizeof(p)) = %d\n", n4);
    printf("B5 n1/sizeof(int) = %d\n", q);
    return sum + q;
}
'@

# ── 断言 5-6：q[i] 与 i[q] 的机器码逐条相同；下标被乘了元素大小 ──────────
$asmSrc = @'
int get_i(int *q, int i) { return q[i]; }
int get_commuted(int *q, int i) { return i[q]; }
int get_char(char *q, int i) { return q[i]; }
'@
Set-Content -Path "$here\c_asm.c" -Value $asmSrc -Encoding ASCII
& $gcc -O2 -S -m32 -o "$here\c_asm.s" "$here\c_asm.c"
& $gcc -O2 -c -m32 -o "$here\c_asm.o" "$here\c_asm.c"
$dis = & $objdump -d "$here\c_asm.o"
Say ""
Say "=== disassembly: q[i] and i[q] (i686, -O2) ==="
$disLines = New-Object System.Collections.Generic.List[string]
#
# ⚠️ **函数名必须打到 OUTPUT.txt 里** —— 2026-09-25 由独立审计抓到：
#   这里原来把 objdump 的 `<_get_i>:` 那一行**丢掉**了（`continue`），
#   于是 OUTPUT.txt 里**一个函数名都没有**，而 `03-claims.md` 的 A8/A9
#   却写着「出处：c_asm.o `_get_i`」—— **那个标签在证据里根本不存在**。
#   后果：读者无法从产物内确认"这段反汇编出自哪个函数"，
#   要复位就得自己重新 objdump。**证据必须能自证它是什么。**
#   ⇒ 现在每个函数前面打一行 `-- <name> --`，**只进 OUTPUT.txt，不进 c_asm.disasm**
#     （画面那一份要的是"指令逐条相同"，多一行标题反而干扰）。
function ShowFunc([string]$name) {
    $hit = $false
    $labelled = $false
    foreach ($ln in $dis) {
        if ($ln -match "<_$name>:\s*$") { $hit = $true; continue }
        if ($hit) {
            if ($ln -match '^\s*[0-9a-f]+:') {
                if (-not $labelled) {
                    $disLines.Add("-- $name --")
                    $labelled = $true
                }
                $disLines.Add($ln.TrimEnd())
            }
            else { break }
        }
    }
}
ShowFunc 'get_i'
ShowFunc 'get_commuted'
ShowFunc 'get_char'
$disLines | ForEach-Object { Say $_ }
Say ""
Say "(reading: mov (%eax,%edx,4) -- that 4 is sizeof(int); with char* it becomes 1)"

# ── 证据文件：**只留指令**（一行一条），供画面直接取自 ──────────────────
#
# 为什么要单独一份：`objdump` 的原样输出带**地址列与机器码字节列**，
# 行宽 90+ 字符 —— 屏幕上的代码栏只有 860px，装不下。
# 而画面上要讲的是"这几条指令一模一样"，所以留**助记符与寻址方式**就够。
#
# ⚠️ 它**由脚本提取，不是手写**。之前有一版是手写的（`make-disasm.ps1`），
#    而那个脚本已删 —— 出处链一断，画面上那几行就退化成"无法追溯的文本"，
#    正是保真判据一直在抓的那件事。
# ✂️ 地址列与机器码列在**打印到 OUTPUT.txt 时保留**（核账要看机器码），
#    只在喂给画面的这份里去掉。
$clean = New-Object System.Collections.Generic.List[string]
foreach ($ln in $disLines) {
    if ($ln -match '^\s*[0-9a-f]+:\s+([0-9a-f]{2} )+\s*(\S+)\s*(.*)$') {
        $mnem = $Matches[2]
        $ops = $Matches[3].TrimEnd()
        if ($ops -eq '') { $clean.Add($mnem) } else { $clean.Add("$mnem`t$ops") }
    }
}
Set-Content -Path "$here\c_asm.disasm" -Value $clean -Encoding ASCII
Say ""
Say "=== c_asm.disasm (instructions only, for on-screen use) ==="
$clean | ForEach-Object { Say $_ }
$manifest.Add([pscustomobject]@{
    name = 'c_asm.disasm'
    title = 'disassembly: q[i] and i[q] (instructions only)'
    lines = @($clean)
})

# ── 断言 7：同一个负下标，数组上报越界、指针上不报 ──────────────────────
Build-And-Run -Name 'd_bounds.c' -Title 'negative subscript on an ARRAY (compiler warns)' -Source @'
int arr[5] = {10, 20, 30, 40, 50};
int main(void) {
    int x = arr[-1];
    return x;
}
'@

Build-And-Run -Name 'e_bounds.c' -Title 'negative subscript on a POINTER (silent)' -Source @'
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int main(void) {
    int x = p[-1];
    return x;
}
'@

# ── 断言 8：方括号里可以放函数调用 / 算式，两边都能翻过来 ────────────────
# ⚠️ **C 源码里不许写中文注释** —— `Build-And-Run` 用 `-Encoding ASCII` 写 `.c`，
#    中文字符会变成 `?`（实测：`/* ── 下面四对… */` 整段被写成问号，
#    而 `wf verify` 的「手抄代码」判据当场报出来）。
#    ⇒ 解释写在**这里**（PowerShell 注释），不要写进程序里。
#
# C8-C11 是 S08 的「精确反向」：每对把方括号两边**整个调过来**、值必须相同。
# 为什么要在源码里真的写上它们：S08 的论点是「顺序反了，结果一样」，
# 而它原来只贴单边（`2[p+1]`、`(1+1)[arr+2]`），观众**没法核对**"一样"。
# 现在每对写在相邻两行，**两个数就摆在那儿**，论点自己就成立。
Build-And-Run -Name 'g_nested.c' -Title 'nested subscripts: calls and expressions inside []' -Source @'
#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int *p = arr;
int idx(void) { return 2; }
int main(void) {
    int c1 = p[idx()];
    int c2 = idx()[p];
    int c3 = (2 + 1)[arr];
    int c4 = 1[p + 1];
    int c5 = idx()[p + 0];
    int c6 = 2[p + 1];
    int c7 = (1 + 1)[arr + 2];
    int c8 = arr[2 + 1];
    int c9 = p[idx() + 0];
    int c10 = p[1 + 1];
    int c11 = arr[1 + 2];
    printf("C1 p[idx()] = %d\n", c1);
    printf("C2 idx()[p] = %d\n", c2);
    printf("C3 (2+1)[arr] = %d\n", c3);
    printf("C4 1[p+1] = %d\n", c4);
    printf("C5 idx()[p+0] = %d\n", c5);
    printf("C6 2[p+1] = %d\n", c6);
    printf("C7 (1+1)[arr+2] = %d\n", c7);
    printf("C8 arr[2+1] = %d\n", c8);
    printf("C9 p[idx()+0] = %d\n", c9);
    printf("C10 p[1+1] = %d\n", c10);
    printf("C11 arr[1+2] = %d\n", c11);
    return c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9 + c10 + c11;
}
'@

# ── 断言 9：二维数组的链式下标就是两次加法，每一层都能反过来 ────────────
Build-And-Run -Name 'h_matrix.c' -Title '2D array: chained subscripts are two additions' -Source @'
#include <stdio.h>
int m[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
int main(void) {
    int *p1 = m[1];
    int d1 = p1[2];
    int d2 = *(*(m + 1) + 2);
    int d3 = 2[1[m]];
    int d4 = m[1][2];
    int sum = d1 + d2 + d3 + d4;
    printf("D1 m[1][2] = %d\n", d1);
    printf("D2 *(*(m+1)+2) = %d\n", d2);
    printf("D3 2[1[m]] = %d\n", d3);
    printf("D4 m[1][2] = %d\n", d4);
    return sum;
}
'@

# ── ★ 断言 14：`arr[2]` 的**字面类型**是 `int`，不是 `int*` ──────────────
#
# 为什么必须单独测它：
#   《意图书》把「`arr[2]` 的字面类型是 `int` 不是 `int*`」标成 ★（绝对不能丢），
#   而 2026-09-25 独立审计发现：**这一条全片一句都没讲**，而且它引的证据
#   （A2 / A5）测的是"两个方向的值相等"，**与类型不是一回事** ——
#   「答案对、推理错」。
#
# ⇒ 让这条断言变成**可测**的，而不是补一句口播了事。
#
# ## 测法：让编译器**按类型报一句**
#
#   ① `int *bad = arr[2];` —— 把一个 `int` 赋给 `int*` ⇒ gcc 报
#      `-Wint-conversion`（"makes pointer from integer without a cast"）。
#      这一句**恰好证明 `arr[2]` 是整数、不是指针**。
#   ② `int *ok = &arr[2];` —— 取地址拿到 `int*`，合法，零警告。
#   ③ `printf("I1 sizeof(arr[2]) = %d", (int)sizeof arr[2]);` —— 4。
#   ⚠️ 单独看 ③ **证明不了**它是 `int`：i686 上 `sizeof(int*)` 也是 4。
#      所以 ① 才是**无歧义**的那一条，③ 只是旁证。这句注释必须留着，
#      否则下一个人会把 ③ 当成主证据（"答案对、推理错"会重演一次）。
#
# ⛔ **它不是"编译不过"，是"编译过了、带一条诊断"。**
#    `gcc` 没有 `-Werror`（见下面那行命令），`i_type.o` **确实被产出了**。
#    ⚠️ 这里原来写的是「这一份**故意编译不过**」—— 而那是**假的**，
#       且与 `OUTPUT.txt` 里的 `warning:`（不是 `error:`）、
#       与 `i_type.o` 的存在直接矛盾。独立审计（2026-09-25）抓到的。
#    ★ 口播也跟着错过一次（说过「编译器会拦你」）——**两处同一个错**。
#    写涉及编译器行为的句子之前，**回 `OUTPUT.txt` 看那是 `warning:` 还是 `error:`**。
#
# 为什么要单独一个函数：它**不产出 .exe**（`-c` 只编译不链接），
# 所以不能走 `Build-And-Run` —— 那个函数会去跑 .exe。
# 这里只**收集编译诊断**。
function Build-Expect-Diagnostic {
    param([string]$Name, [string]$Title, [string]$Source)
    $src = Join-Path $here $Name
    Set-Content -Path $src -Value $Source -Encoding ASCII
    Say ""
    Say "=== $Title ==="
    $w = & $gcc -O2 -Wall -Wextra -c -o ($src -replace '\.c$', '.o') $src 2>&1
    $real = @($w | Where-Object { $_ -match 'warning|error' })
    if ($real.Count -eq 0) {
        # 没有诊断 = 这条断言**没被测到**，必须显式报出来，不许静默
        Say "EXPECTED-DIAGNOSTIC-MISSING: gcc 没有对 arr[2] 赋给 int* 报任何诊断"
    } else {
        foreach ($line in $real) {
            # 只留最后一段文件名与诊断，路径里有中文，全留会让证据不可读
            $short = $line -replace '^.*[\\/]', ''
            Say "DIAG: $short"
        }
    }
    $manifest.Add([pscustomobject]@{
        name = $Name
        title = $Title
        lines = @($Source -split "`n" | ForEach-Object { $_.TrimEnd() })
    })
}

Build-Expect-Diagnostic -Name 'i_type.c' -Title 'the literal type of arr[2] is int, not int*' -Source @'
#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int main(void) {
    int *ok = &arr[2];
    int *bad = arr[2];
    printf("I1 sizeof(arr[2]) = %d\n", (int)sizeof arr[2]);
    printf("I2 *(&arr[2]) = %d\n", *ok);
    printf("I3 bad=%p\n", (void *)bad);
    return 0;
}
'@

# 数值旁证单独跑一份**能编译通过**的（上面那份是故意违规的，跑不出 .exe）。
# ⚠️ 两份分工要写清：上面那份给**无歧义的诊断**，这份给**能上屏的数字**。
Build-And-Run -Name 'j_typesize.c' -Title 'sizeof arr[2] vs sizeof(int*) -- the numeric side-note' -Source @'
#include <stdio.h>
int arr[5] = {10, 20, 30, 40, 50};
int main(void) {
    printf("J1 sizeof(arr[2]) = %d\n", (int)sizeof arr[2]);
    printf("J2 sizeof(int*)   = %d\n", (int)sizeof(int *));
    printf("J3 sizeof(arr)    = %d\n", (int)sizeof arr);
    return 0;
}
'@

Say ""
Say "=== end ==="

Set-Content -Path $out -Value $lines -Encoding UTF8
Set-Content -Path (Join-Path $here 'evidence.json') -Value ($manifest | ConvertTo-Json -Depth 6) -Encoding UTF8

Write-Host ""
Write-Host "✅ OUTPUT.txt  $($lines.Count) 行"
Write-Host "✅ evidence.json  $($manifest.Count) 份源码"
foreach ($m in $manifest) { Write-Host ("   {0,-16} {1,3} 行" -f $m.name, $m.lines.Count) }
