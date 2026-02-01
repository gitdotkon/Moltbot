#!/usr/bin/env python3
"""生成社交媒体热门榜单 HTML 页面"""

import json
import os
import subprocess
from datetime import datetime

# MongoDB 配置
MONGO_HOST = os.environ.get('MONGO_HOST', 'localhost')
MONGO_PORT = os.environ.get('MONGO_PORT', '27017')
MONGO_USER = os.environ.get('MONGO_USER', 'admin')
MONGO_PASS = os.environ.get('MONGO_PASS', 'password')
MONGO_DB = 'social_trending'

TRENDING_DIR = os.environ.get('TRENDING_DIR', os.path.expanduser('~/www'))
OUTPUT_FILE = os.path.join(TRENDING_DIR, 'trending.html')


def run_mongo(query):
    """执行 MongoDB 查询"""
    cmd = [
        'docker', 'exec', 'mongodb', 'mongosh',
        '-u', MONGO_USER, '-p', MONGO_PASS,
        '--authenticationDatabase', 'admin',
        MONGO_DB, '--quiet', '--eval', query
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return result.stdout.strip()
    except Exception as e:
        print(f"MongoDB 查询失败: {e}")
        return None


def get_latest_data(platform):
    """获取指定平台的最新数据"""
    query = f'''
    var doc = db.trending.findOne({{platform: "{platform}"}});
    if (doc) {{
        var items = doc.items.map(function(i) {{
            if (typeof i === 'object' && i.title) {{
                return i;
            }} else {{
                return {{title: String(i), link: '#'}};
            }}
        }});
        print(JSON.stringify({{
            timestamp: doc.timestamp.getTime(),
            items: items
        }}));
    }} else {{
        print("null");
    }}
    '''
    result = run_mongo(query)
    if result and result != 'null':
        try:
            return json.loads(result)
        except Exception as e:
            print(f"解析失败: {e}, 结果: {result[:200]}")
            return None
    return None


def format_items(items, platform):
    """格式化列表项（带链接）"""
    if not items:
        return '<li class="empty">暂无数据</li>'
    
    html = ''
    for i, item in enumerate(items[:20], 1):
        # 根据排名设置样式
        rank_class = ''
        if i == 1:
            rank_class = 'top'
        elif i == 2:
            rank_class = 'top-2'
        elif i == 3:
            rank_class = 'top-3'
        
        # 解析数据
        if isinstance(item, dict):
            title = item.get('title', str(item))
            link = item.get('link', '#')
        else:
            title = str(item)
            link = '#'
        
        html += f'''
            <li class="hot-item">
                <span class="hot-rank {rank_class}">{i}</span>
                <div class="hot-content">
                    <a href="{link}" target="_blank" class="hot-title">{title}</a>
                </div>
            </li>'''
    return html


def generate_html():
    """生成 HTML 页面"""
    print("📄 生成静态页面...")
    
    # 获取数据
    baidu_data = get_latest_data('baidu')
    weibo_data = get_latest_data('weibo')
    bilibili_data = get_latest_data('bilibili')
    douyin_data = get_latest_data('douyin')
    
    # 格式化时间（转换为年月日 时分格式）
    def format_time(data):
        if data and 'timestamp' in data:
            try:
                ts = int(data['timestamp']) / 1000
                return datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M')
            except:
                return '时间错误'
        return '暂无数据'
    
    baidu_time = format_time(baidu_data)
    weibo_time = format_time(weibo_data)
    bilibili_time = format_time(bilibili_data)
    douyin_time = format_time(douyin_data)
    
    # 获取列表
    baidu_items = baidu_data.get('items', []) if baidu_data else []
    weibo_items = weibo_data.get('items', []) if weibo_data else []
    bilibili_items = bilibili_data.get('items', []) if bilibili_data else []
    douyin_items = douyin_data.get('items', []) if douyin_data else []
    
    baidu_list_html = format_items(baidu_items, 'baidu')
    weibo_list_html = format_items(weibo_items, 'weibo')
    bilibili_list_html = format_items(bilibili_items, 'bilibili')
    douyin_list_html = format_items(douyin_items, 'douyin')
    
    # 生成 HTML
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>社交媒体热门榜单</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; min-height: 100vh; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px 20px; text-align: center; }}
        .header h1 {{ font-size: 28px; margin-bottom: 10px; }}
        .header p {{ opacity: 0.8; font-size: 14px; }}
        .container {{ max-width: 1400px; margin: 0 auto; padding: 20px; }}
        .platforms {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; margin-top: 20px; }}
        .card {{ background: white; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); overflow: hidden; }}
        .card-header {{ padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }}
        .card-header.baidu {{ background: #4CAF50; color: white; }}
        .card-header.weibo {{ background: #E91E63; color: white; }}
        .card-header.bilibili {{ background: #00A1D6; color: white; }}
        .card-header.douyin {{ background: #000000; color: white; }}
        .card-title {{ font-size: 18px; font-weight: 600; }}
        .card-time {{ font-size: 11px; opacity: 0.8; white-space: nowrap; margin-left: 10px; }}
        .card-body {{ padding: 15px; }}
        .hot-list {{ list-style: none; }}
        .hot-item {{ padding: 12px 10px; border-bottom: 1px solid #eee; display: flex; align-items: center; gap: 12px; }}
        .hot-item:last-child {{ border-bottom: none; }}
        .hot-item:hover {{ background: #f9f9f9; }}
        .hot-rank {{ width: 24px; height: 24px; border-radius: 50%; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: #666; flex-shrink: 0; }}
        .hot-rank.top {{ background: #ff4757; color: white; }}
        .hot-rank.top-2 {{ background: #ff6b81; color: white; }}
        .hot-rank.top-3 {{ background: #ffa502; color: white; }}
        .hot-content {{ flex: 1; }}
        .hot-title {{ font-size: 14px; color: #333; line-height: 1.4; text-decoration: none; display: block; }}
        .hot-title:hover {{ color: #667eea; }}
        .refresh-btn {{ position: fixed; bottom: 30px; right: 30px; width: 56px; height: 56px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; cursor: pointer; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4); font-size: 24px; display: flex; align-items: center; justify-content: center; transition: transform 0.2s; }}
        .refresh-btn:hover {{ transform: scale(1.1); }}
        .empty {{ text-align: center; padding: 40px; color: #999; }}
        @media (max-width: 600px) {{ .platforms {{ grid-template-columns: 1fr; }} }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🔥 社交媒体热门榜单</h1>
        <p>实时抓取 · 每小时更新</p>
    </div>
    <div class="container">
        <div class="platforms">
            <div class="card">
                <div class="card-header baidu">
                    <span class="card-title">🔍 百度热搜</span>
                    <span class="card-time">更新时间: {baidu_time}</span>
                </div>
                <div class="card-body">
                    <ul class="hot-list" id="baidu-list">{baidu_list_html}</ul>
                </div>
            </div>
            <div class="card">
                <div class="card-header weibo">
                    <span class="card-title">💕 微博热搜</span>
                    <span class="card-time">更新时间: {weibo_time}</span>
                </div>
                <div class="card-body">
                    <ul class="hot-list" id="weibo-list">{weibo_list_html}</ul>
                </div>
            </div>
            <div class="card">
                <div class="card-header bilibili">
                    <span class="card-title">📺 B站热门</span>
                    <span class="card-time">更新时间: {bilibili_time}</span>
                </div>
                <div class="card-body">
                    <ul class="hot-list" id="bilibili-list">{bilibili_list_html}</ul>
                </div>
            </div>
            <div class="card">
                <div class="card-header douyin">
                    <span class="card-title">🎵 抖音热门</span>
                    <span class="card-time">更新时间: {douyin_time}</span>
                </div>
                <div class="card-body">
                    <ul class="hot-list" id="douyin-list">{douyin_list_html}</ul>
                </div>
            </div>
        </div>
    </div>
    <button class="refresh-btn" onclick="location.reload()">🔄</button>
    <script>
        setTimeout(() => location.reload(), 300000); // 5分钟自动刷新
    </script>
</body>
</html>'''
    
    # 保存文件
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"✅ 页面已生成: {OUTPUT_FILE}")
    print(f"💡 用浏览器打开查看: file://{OUTPUT_FILE}")


if __name__ == '__main__':
    generate_html()
