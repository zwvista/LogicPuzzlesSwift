# powershell -ExecutionPolicy Bypass -File .\rename_and_replace.ps1

# 协程变量（源字符串和目标字符串）
$SRC = "BootyIsland"
$DST = "Branches"

# 切换到 Branches 目录
Set-Location "$PSScriptRoot\Branches"

# 1. 改文件名
Get-ChildItem -Filter "$SRC*" | ForEach-Object {
    $newName = $_.Name -replace "^$SRC", $DST
    Rename-Item $_.FullName $newName
}

# 2. 改文件内容
Get-ChildItem -Filter "$DST*" | ForEach-Object {
    (Get-Content $_.FullName) -replace $SRC, $DST |
        Set-Content $_.FullName
}
