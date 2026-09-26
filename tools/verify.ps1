# tools/verify.ps1 —— 在**你自己的机器上**复核这个仓库的可复现性。
#
# 做法：跑一遍 src/run.ps1，把输出的正文与 docs/measured.md 逐行比对。
# 预期结果是「**只有一行不同**」—— 就是那行包含源文件路径的 gcc 诊断。
# 那一行在本仓库里被写成了 <repo>/… 的相对写法（因为本机路径对读者没有意义）。
#
# 用法：  pwsh -File tools/verify.ps1
# 退出码：0 = 可复现；1 = 对不上（会印出差异）

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot
Push-Location $here
try {
    Write-Host '=== 跑 src/run.ps1 ===' -ForegroundColor Cyan
    $raw = & pwsh -NoProfile -File (Join-Path $here 'src/run.ps1') 2>&1

    # 正文到 '=== end ===' 为止（脚本后面那几行是它自己的汇总，不进 OUTPUT.txt）
    $live = @()
    foreach ($l in $raw) { $live += [string]$l; if ([string]$l -match '^=== end ===$') { break } }

    $md = Get-Content (Join-Path $here 'docs/measured.md') -Raw
    $m = [regex]::Match($md, '(?s)```text\r?\n(.*?)\r?\n```').Groups[1].Value -split "`n"

    Write-Host ("复现 " + $live.Count + " 行 / 仓库 " + $m.Count + " 行")
    if ($live.Count -ne $m.Count) {
        Write-Host '❌ 行数不同 —— 这一份证据不可复现。' -ForegroundColor Red
        exit 1
    }

    $diff = @()
    for ($i = 0; $i -lt $live.Count; $i++) {
        if ($live[$i] -ne $m[$i]) { $diff += $i }
    }

    if ($diff.Count -eq 0) {
        Write-Host '✅ 逐行完全相同（这个仓库是在与你相同的环境下生成的）。' -ForegroundColor Green
        exit 0
    }
    if ($diff.Count -eq 1 -and $m[$diff[0]] -match '^WARN: <repo>/') {
        Write-Host '✅ 可复现 —— 只有那行 gcc 诊断里的路径不同，这是预期的。' -ForegroundColor Green
        Write-Host ('   你这里：' + $live[$diff[0]])
        Write-Host ('   仓库里：' + $m[$diff[0]])
        Write-Host '   （相对路径对读者更有用；除此之外一个字符都不差。）'
        exit 0
    }

    Write-Host ('❌ ' + $diff.Count + ' 行对不上：') -ForegroundColor Red
    foreach ($i in $diff) {
        Write-Host ('   L' + ($i + 1))
        Write-Host ('     你这里：' + $live[$i])
        Write-Host ('     仓库里：' + $m[$i])
    }
    exit 1
}
finally { Pop-Location }
