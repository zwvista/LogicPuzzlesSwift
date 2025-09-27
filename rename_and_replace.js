// node rename_and_replace.js

const fs = require("fs");
const path = require("path");

// 配置变量（源字符串和目标字符串）
const SRC = "BootyIsland";
const DST = "Branches";

// Branches 目录路径（脚本所在目录下的 Branches）
const dir = path.join(__dirname, "Branches");

// 1. 批量改文件名
fs.readdirSync(dir)
  .filter(name => name.startsWith(SRC))
  .forEach(oldName => {
    const newName = DST + oldName.slice(SRC.length);
    fs.renameSync(path.join(dir, oldName), path.join(dir, newName));
    console.log(`重命名: ${oldName} -> ${newName}`);
  });

// 2. 批量改文件内容
fs.readdirSync(dir)
  .filter(name => name.startsWith(DST))
  .forEach(file => {
    const filePath = path.join(dir, file);
    let content = fs.readFileSync(filePath, "utf8");
    if (content.includes(SRC)) {
      content = content.replace(new RegExp(SRC, "g"), DST);
      fs.writeFileSync(filePath, content, "utf8");
      console.log(`替换内容: ${file}`);
    }
  });

console.log("✅ 执行完成");
