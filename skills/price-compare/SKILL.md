---
name: price-compare
description: 比较淘宝、京东、拼多多等中国电商平台的商品价格。
metadata: {"openclaw":{"emoji":"💰","requires":{"bins":["curl","jq"]}}}
---

# Price Compare

比较中国主流电商平台的商品价格。

## 安装依赖

```bash
brew install curl jq
```

## 快速使用

```bash
# 搜索并比较商品价格
price-compare "iPhone 15"

# 指定平台比较
price-compare "MacBook Pro" --taobao --jd

# 只显示最低价
price-compare "AirPods Pro" --cheapest

# 生成价格对比页面
price-compare "iPad" --html
```

## 命令选项

| 选项 | 说明 |
|-----|------|
| `keyword` | 要搜索的商品名称 |
| `--taobao` | 只搜索淘宝 |
| `--jd` | 只搜索京东 |
| `--pdd` | 只搜索拼多多 |
| `--all` | 搜索所有平台（默认） |
| `--cheapest` | 只显示最低价 |
| `--html` | 生成 HTML 对比页面 |
| `--limit N` | 限制结果数量（默认: 10） |

## 输出示例

```
💰 价格对比: iPhone 15

📦 淘宝
  1. iPhone 15 128GB - ¥5,299
  2. iPhone 15 256GB - ¥6,299
  3. iPhone 15 Pro Max - ¥8,999

📦 京东  
  1. iPhone 15 128GB - ¥5,288 ⭐ 最便宜
  2. iPhone 15 256GB - ¥6,288
  3. iPhone 15 Pro - ¥7,888

📦 拼多多
  1. iPhone 15 128GB - ¥5,199 ⭐ 全网最低
  2. iPhone 15 256GB - ¥6,099

========================================
🏆 全网最低价: ¥5,199 (拼多多)
💰 建议购买: 拼多多
```

## 数据来源

- 淘宝: https://s.taobao.com/search
- 京东: https://search.jd.com/Search
- 拼多多: https://search.pinduoduo.com/search

## 注意事项

- 价格仅供参考，实际价格以购买页面为准
- 部分商品可能缺货或有促销活动
- 建议货比三家后再购买

## HTML 页面

使用 `--html` 选项生成可视化对比页面：

```bash
price-compare "iPhone 15" --html
```

生成的页面包含：
- 📊 多个平台的横向价格对比
- 📈 价格走势图
- 🏆 最低价高亮标注
- 🔗 点击跳转到购买页面
