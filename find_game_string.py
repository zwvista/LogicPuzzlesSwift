#!/usr/bin/env python3
"""
递归检查指定子目录下所有Swift文件，查找包含字母数字+Game.的字符串（如xxxGame.），
排除文件名以相同Game名称开头的文件
"""

import os
import sys
import re
from pathlib import Path

# 可配置的搜索路径（相对于当前目录或绝对路径）
# 例如：'LogicPuzzlesSwift/Puzzles' 或 'Puzzles' 或 './src/games'
SEARCH_SUBDIR = 'LogicPuzzlesSwift/Puzzles'

def find_game_pattern_in_swift_files(root_dir, search_subdir):
    """
    在指定子目录下递归查找所有Swift文件中包含"字母数字+Game."的字符串，
    排除文件名以相同Game名称开头的文件
    
    Args:
        root_dir: 要搜索的根目录路径
        search_subdir: 要搜索的子目录路径（相对于root_dir）
    """
    # 编译正则表达式：匹配字母数字+Game. (大小写敏感)
    pattern = re.compile(r'[A-Za-z][A-Za-z0-9]*Game\.')
    
    # 存储找到的结果
    results = []
    
    # 构建搜索目录路径
    search_dir = os.path.join(root_dir, search_subdir)
    
    # 检查搜索目录是否存在
    if not os.path.exists(search_dir):
        print(f"错误: 搜索目录不存在: {search_dir}")
        return results
    
    if not os.path.isdir(search_dir):
        print(f"错误: {search_dir} 不是一个目录")
        return results
    
    # 递归遍历搜索目录
    for root, dirs, files in os.walk(search_dir):
        for file in files:
            # 只处理.swift文件
            if not file.endswith('.swift'):
                continue
            
            file_path = os.path.join(root, file)
            file_name_without_ext = os.path.splitext(file)[0]
            
            try:
                # 读取文件内容
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.splitlines()
                    
                # 逐行检查
                for line_num, line in enumerate(lines, 1):
                    # 查找所有匹配项
                    matches = list(re.finditer(pattern, line))
                    
                    for match in matches:
                        matched_text = match.group()
                        # 提取Game名称（去掉"Game."）
                        game_name = matched_text[:-5]  # 去掉"Game."，保留前面的字符
                        
                        # 检查文件名是否以game_name开头（大小写敏感）
                        if file_name_without_ext.startswith(game_name):
                            continue
                        
                        # 计算该行中这个模式出现的总次数
                        count = len(re.findall(pattern, line))
                        
                        # 获取相对路径（相对于根目录）
                        rel_path = os.path.relpath(file_path, root_dir)
                        
                        results.append({
                            'file': file_path,
                            'rel_path': rel_path,
                            'line_num': line_num,
                            'content': line.strip(),
                            'matched_text': matched_text,
                            'game_name': game_name,
                            'count': count
                        })
                        
            except UnicodeDecodeError:
                # 如果文件编码不是UTF-8，尝试其他编码
                try:
                    with open(file_path, 'r', encoding='utf-8-sig') as f:
                        content = f.read()
                        lines = content.splitlines()
                        
                    for line_num, line in enumerate(lines, 1):
                        matches = list(re.finditer(pattern, line))
                        
                        for match in matches:
                            matched_text = match.group()
                            game_name = matched_text[:-5]
                            
                            if file_name_without_ext.startswith(game_name):
                                continue
                            
                            count = len(re.findall(pattern, line))
                            
                            rel_path = os.path.relpath(file_path, root_dir)
                            
                            results.append({
                                'file': file_path,
                                'rel_path': rel_path,
                                'line_num': line_num,
                                'content': line.strip(),
                                'matched_text': matched_text,
                                'game_name': game_name,
                                'count': count
                            })
                except Exception as e:
                    print(f"警告: 无法读取文件 {file_path}: {e}")
                    
            except Exception as e:
                print(f"警告: 处理文件 {file_path} 时出错: {e}")
    
    return results

def print_results(results):
    """
    打印搜索结果
    
    Args:
        results: 搜索结果列表
    """
    if not results:
        print("未找到任何包含'字母数字+Game.'模式的Swift文件")
        return
    
    print(f"找到 {len(results)} 个匹配项:\n")
    print("-" * 80)
    
    current_file = None
    for result in results:
        if result['file'] != current_file:
            if current_file is not None:
                print()
            print(f"📁 {result['rel_path']}")
            print("-" * 40)
            current_file = result['file']
        
        print(f"  第 {result['line_num']:4d} 行: {result['content']}")
        print(f"         匹配: {result['matched_text']} (Game名称: {result['game_name']})")
    
    print("\n" + "=" * 80)
    print(f"总计: {len(results)} 个匹配项")
    
    # 统计文件数量
    unique_files = set(result['file'] for result in results)
    print(f"涉及文件: {len(unique_files)} 个")
    
    # 统计不同的Game名称
    game_names = set(result['game_name'] for result in results)
    print(f"不同的Game名称: {sorted(game_names)}")

def save_results_to_file(results, output_file="game_pattern_search_results.txt"):
    """
    将结果保存到文件
    
    Args:
        results: 搜索结果列表
        output_file: 输出文件名
    """
    if not results:
        return
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("查找结果: '字母数字+Game.' 模式在Swift文件中\n")
        f.write(f"搜索目录: {SEARCH_SUBDIR}\n")
        f.write("搜索模式: [A-Za-z][A-Za-z0-9]*Game. (大小写敏感)\n")
        f.write("排除条件: 文件名以相同的Game名称开头\n")
        f.write("=" * 80 + "\n\n")
        
        current_file = None
        for result in results:
            if result['file'] != current_file:
                if current_file is not None:
                    f.write("\n")
                f.write(f"文件: {result['rel_path']}\n")
                f.write("-" * 40 + "\n")
                current_file = result['file']
            
            f.write(f"  行 {result['line_num']:4d}: {result['content']}\n")
            f.write(f"         匹配: {result['matched_text']} (Game名称: {result['game_name']})\n")
        
        f.write("\n" + "=" * 80 + "\n")
        f.write(f"总计: {len(results)} 个匹配项\n")
        unique_files = set(result['file'] for result in results)
        f.write(f"涉及文件: {len(unique_files)} 个\n")
        game_names = set(result['game_name'] for result in results)
        f.write(f"不同的Game名称: {sorted(game_names)}\n")
    
    print(f"\n结果已保存到: {output_file}")

def main():
    """
    主函数
    """
    # 默认搜索当前目录
    root_dir = "."
    
    # 如果提供了命令行参数，使用第一个参数作为根目录
    if len(sys.argv) > 1:
        root_dir = sys.argv[1]
    
    # 检查根目录是否存在
    if not os.path.exists(root_dir):
        print(f"错误: 根目录 '{root_dir}' 不存在")
        sys.exit(1)
    
    if not os.path.isdir(root_dir):
        print(f"错误: '{root_dir}' 不是一个目录")
        sys.exit(1)
    
    print(f"开始搜索根目录: {os.path.abspath(root_dir)}")
    print(f"搜索子目录: {SEARCH_SUBDIR}")
    print(f"搜索模式: '[A-Za-z][A-Za-z0-9]*Game.' (大小写敏感)")
    print(f"排除条件: 文件名以相同的Game名称开头")
    print("-" * 80)
    
    # 执行搜索
    results = find_game_pattern_in_swift_files(root_dir, SEARCH_SUBDIR)
    
    # 打印结果
    print_results(results)
    
    # 如果有结果，保存到文件
    if results:
        save_results_to_file(results)

if __name__ == "__main__":
    main()