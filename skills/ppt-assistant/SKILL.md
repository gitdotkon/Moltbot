---
name: ppt-assistant
description: 生成PPT演示文稿，支持从GitHub、StackOverflow等开源网站搜索资料，定期更新模板和内容。
metadata: {"openclaw":{"emoji":"📊","requires":{"bins":["python3"]}}}
---

# PPT Assistant

生成 PPT 演示文稿，支持从 GitHub、StackOverflow 等开源网站搜索资料。

## 安装依赖

```bash
# 创建虚拟环境并安装依赖
uv venv ~/.venv/ppt
source ~/.venv/ppt/bin/activate
uv pip install python-pptx requests beautifulsoup4

# 或使用pip
pip3 install python-pptx requests beautifulsoup4
```

## 快速使用

```bash
# 生成基础PPT
ppt create "主题演讲"

# 带内容大纲
ppt create "技术分享" --outline "1.介绍\n2.原理\n3.实践\n4.总结"

# 从搜索生成PPT
ppt search "React Hooks 教程" --sources github,stackoverflow

# 更新模板
ppt update-templates

# 定时更新（每天）
ppt schedule
```

## 命令详解

### create [主题]
生成基础 PPT 演示文稿。

| 选项 | 说明 |
|-----|------|
| `--outline` | 大纲内容（用 \n 分隔） |
| `--slides` | 幻灯片数量（默认5） |
| `--output` | 输出文件路径 |

### search [关键词]
从开源网站搜索并生成 PPT。

| 选项 | 说明 |
|-----|------|
| `--sources` | 数据源（github,stackoverflow,dev.to,medium） |
| `--limit` | 结果数量（默认10） |
| `--output` | 输出文件 |

### update-templates
从开源模板网站更新模板。

### schedule
设置定时任务（每天更新模板）。

## 示例

```bash
# 创建项目汇报PPT
ppt create "Q1项目汇报" --outline "项目概述\n进度回顾\n问题分析\n下一步计划"

# 搜索技术文章生成PPT
ppt search "Python异步编程" --sources github,stackoverflow --limit 20

# 从模板创建
ppt create "产品发布" --slides 8
```

## 数据来源

- **GitHub**: 搜索热门项目、趋势
- **StackOverflow**: 热门问答、技术解决方案
- **Dev.to**: 技术博客文章
- **Medium**: 技术深度文章

## 定时更新

设置每天自动更新模板和热门内容：

```bash
ppt schedule
```

## 模板类型

| 模板 | 说明 |
|-----|------|
| modern | 现代简约风格 |
| business | 商务风格 |
| tech | 技术风格 |
| creative | 创意风格 |

## 高级用法（Python脚本）

```bash
# 直接使用Python脚本
python3 ppt_gen.py create "我的PPT" --outline "第一部分\\n第二部分\\n第三部分"

# 搜索并生成
python3 ppt_gen.py search "机器学习" --sources github,stackoverflow --limit 15

# 更新模板
python3 ppt_gen.py update-templates
```
