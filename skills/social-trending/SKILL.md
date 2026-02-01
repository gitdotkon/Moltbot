---
name: social-trending
description: 抓取百度、微博、B站、抖音等平台的热门榜单，存储到MongoDB并生成展示页面，支持每小时自动更新。
metadata: {"openclaw":{"emoji":"🔥","requires":{"bins":["curl","jq","docker","mongosh"]}}}
---

# Social Trending

抓取社交媒体热门榜单，存储到 MongoDB 并生成可视化展示页面。

## 安装依赖

```bash
# macOS
brew install curl jq

# 确保 MongoDB 容器已启动
docker start mongodb
```

## MongoDB 配置

| 环境变量 | 说明 | 默认值 |
|---------|------|-------|
| `MONGO_HOST` | MongoDB 主机 | `localhost` |
| `MONGO_PORT` | MongoDB 端口 | `27017` |
| `MONGO_USER` | 用户名 | `admin` |
| `MONGO_PASS` | 密码 | `password` |

**MongoDB 信息：**
- 数据库: `social_trending`
- 集合: `trending`
- 容器名称: `mongodb`

## 快速使用

```bash
# 抓取所有平台热门（保存到 MongoDB）
trending fetch

# 抓取指定平台
trending fetch baidu
trending fetch weibo
trending fetch bilibili
trending fetch douyin

# 查看 MongoDB 中的数据统计
trending show

# 生成静态展示页面
trending html

# 设置定时任务（每小时自动更新）
trending schedule
```

## 命令详解

### fetch [platform]
抓取热门榜单并保存到 MongoDB。

| 平台 | 参数 | 说明 |
|-----|------|------|
| 百度 | `baidu` | 百度热搜榜 |
| 微博 | `weibo` | 微博热搜榜 |
| B站 | `bilibili` | B站热门视频 |
| 抖音 | `douyin` | 抖音热门视频 |

### show
显示 MongoDB 中的数据统计。

### html
从 MongoDB 读取最新数据，生成静态 HTML 展示页面。

**输出文件**: `~/www/trending.html`

**页面特性**:
- 响应式设计，支持手机/电脑
- 百度热搜（绿色）
- 微博热搜（粉红色）
- B站热门（蓝色）
- 抖音热门（黑色）
- 热搜标题带**链接**，点击可跳转
- 每小时更新（自动）
- 5分钟自动刷新

### schedule
设置系统定时任务，自动每小时：
1. 抓取最新热门数据
2. 保存到 MongoDB
3. 生成更新页面

## 数据存储

**MongoDB 结构**:
```json
{
  "_id": ObjectId("..."),
  "platform": "baidu",
  "timestamp": ISODate("2026-01-31T14:00:00Z"),
  "items": [
    {"title": "热搜标题", "link": "https://example.com"},
    ...
  ],
  "createdAt": ISODate("2026-01-31T14:00:00Z")
}
```

**索引**:
- `{platform: 1, timestamp: -1}` - 按平台和时间查询

## 查看 MongoDB 数据

```bash
# 连接 MongoDB
mongosh -u admin -p password --authenticationDatabase admin social_trending

# 查看所有记录
db.trending.find().sort({timestamp: -1}).limit(10)

# 查看各平台数量
db.trending.aggregate([
  {$group: {_id: "$platform", count: {$sum: 1}}}
])
```

## 更新频率

- **默认**: 每 60 分钟自动更新一次
- **自定义**: 设置 `INTERVAL` 环境变量（分钟）

```bash
# 每30分钟更新
INTERVAL=30 ./trending schedule
```

## 输出示例

```bash
$ trending fetch
[14:00:00] 📊 开始抓取热门榜单: all
================================
[14:00:00] 🔥 抓取百度热搜...
✅ 百度热搜: 10 条
[14:00:00] 🔥 抓取微博热搜...
✅ 微博热搜: 10 条
[14:00:01] 🔥 抓取B站热门...
✅ B站热门: 10 条
[14:00:01] 🔥 抓取抖音热门...
✅ 抖音热门: 10 条
================================
📊 共抓取: 40 条热门
💾 已保存到 MongoDB (social_trending)

$ trending html
📄 生成静态页面...
✅ 页面已生成: /Users/kon/www/trending.html
💡 用浏览器打开查看: file:///Users/kon/www/trending.html
```

## 页面预览

生成的页面包含：
- 🎨 四平台卡片式布局
- 📱 响应式设计
- 🔗 热搜标题带可点击链接
- 🔄 自动/手动刷新
- 🎯 实时数据展示
