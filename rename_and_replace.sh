#!/bin/bash
set -e

# 协程变量（源字符串和目标字符串）
SRC="PowerGrid"
DST="WishSandwich"

# 切换到 Branches 目录
cd "$(dirname "$0")/LogicPuzzlesSwift/Puzzles/WishSandwich"

# 1. 改文件名
for f in ${SRC}*; do
  newname="${DST}${f#${SRC}}"
  mv "$f" "$newname"
done

# 2. 改文件内容
for f in ${DST}*; do
  sed -i '' "s/${SRC}/${DST}/g" "$f"
done
