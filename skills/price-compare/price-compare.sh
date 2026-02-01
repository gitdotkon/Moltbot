#!/bin/bash

# Price Compare - 电商价格比较工具

set -e

# 配置
MAX_ITEMS="${MAX_ITEMS:-10}"
TRENDING_DIR="${TRENDING_DIR:-$HOME/www}"
OUTPUT_FILE="$TRENDING_DIR/price-compare.html"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 模拟电商数据（实际使用需要爬虫或API）
get_taobao_data() {
    local keyword=$1
    cat << EOF
[
    {"name": "$keyword 基础款", "price": 5299, "link": "https://taobao.com/item/1"},
    {"name": "$keyword 标准版", "price": 6299, "link": "https://taobao.com/item/2"},
    {"name": "$keyword 升级版", "price": 7999, "link": "https://taobao.com/item/3"},
    {"name": "$keyword 旗舰款", "price": 9999, "link": "https://taobao.com/item/4"}
]
EOF
}

get_jd_data() {
    local keyword=$1
    cat << EOF
[
    {"name": "$keyword 基础款", "price": 5288, "link": "https://jd.com/item/1"},
    {"name": "$keyword 标准版", "price": 6288, "link": "https://jd.com/item/2"},
    {"name": "$keyword 升级版", "price": 7888, "link": "https://jd.com/item/3"},
    {"name": "$keyword 旗舰款", "price": 9888, "link": "https://jd.com/item/4"}
]
EOF
}

get_pdd_data() {
    local keyword=$1
    cat << EOF
[
    {"name": "$keyword 基础款", "price": 5199, "link": "https://pinduoduo.com/item/1"},
    {"name": "$keyword 标准版", "price": 6099, "link": "https://pinduoduo.com/item/2"},
    {"name": "$keyword 升级版", "price": 7599, "link": "https://pinduoduo.com/item/3"},
    {"name": "$keyword 旗舰款", "price": 9599, "link": "https://pinduoduo.com/item/4"}
]
EOF
}

# 搜索所有平台
search_all() {
    local keyword=$1
    log "🔍 搜索: $keyword"
    echo "================================"
    
    # 淘宝
    if [ "$TAOBAO" = "true" ] || [ "$ALL" = "true" ]; then
        info "📦 淘宝"
        local taobao_data=$(get_taobao_data "$keyword")
        echo "$taobao_data" | jq -r '.[] | "  - \(.name): ¥\(format_price .price)\n"' 2>/dev/null || true
    fi
    
    # 京东
    if [ "$JD" = "true" ] || [ "$ALL" = "true" ]; then
        info "📦 京东"
        local jd_data=$(get_jd_data "$keyword")
        echo "$jd_data" | jq -r '.[] | "  - \(.name): ¥\(format_price .price)\n"' 2>/dev/null || true
    fi
    
    # 拼多多
    if [ "$PDD" = "true" ] || [ "$ALL" = "true" ]; then
        info "📦 拼多多"
        local pdd_data=$(get_pdd_data "$keyword")
        echo "$pdd_data" | jq -r '.[] | "  - \(.name): ¥\(format_price .price)\n"' 2>/dev/null || true
    fi
    
    echo "================================"
    info "💡 提示: 使用 --html 生成可视化对比页面"
}

# 格式化价格
format_price() {
    printf "%'d" $1 | sed 's/,//g'
}

# 查找最低价
find_cheapest() {
    local keyword=$1
    log "🔍 搜索最低价: $keyword"
    echo "================================"
    
    local all_prices=()
    local all_sources=()
    
    # 收集所有价格
    while IFS= read -r price; do
        all_prices+=("$price")
    done < <(echo "$(get_taobao_data "$keyword")$(get_jd_data "$keyword")$(get_pdd_data "$keyword")" | jq -r '.[].price' 2>/dev/null)
    
    # 找出最低价
    local min_price=999999
    for price in "${all_prices[@]}"; do
        if [ "$price" -lt "$min_price" ]; then
            min_price=$price
        fi
    done
    
    log "🏆 全网最低价: ¥$(format_price $min_price)"
}

# 生成 HTML 页面
generate_html() {
    local keyword=$1
    log "📄 生成价格对比页面..."
    
    local taobao_data=$(get_taobao_data "$keyword")
    local jd_data=$(get_jd_data "$keyword")
    local pdd_data=$(get_pdd_data "$keyword")
    
    # 生成 HTML
    cat > "$OUTPUT_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>电商价格对比</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; min-height: 100vh; }
        .header { background: linear-gradient(135deg, #ff6b6b 0%, #feca57 100%); color: white; padding: 30px 20px; text-align: center; }
        .header h1 { font-size: 28px; margin-bottom: 10px; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .platforms { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; margin-top: 20px; }
        .card { background: white; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); overflow: hidden; }
        .card-header { padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
        .card-header.taobao { background: #ff6700; color: white; }
        .card-header.jd { background: #c00; color: white; }
        .card-header.pdd { background: #e02e24; color: white; }
        .card-title { font-size: 18px; font-weight: 600; }
        .card-body { padding: 15px; }
        .price-list { list-style: none; }
        .price-item { padding: 12px 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .price-item:last-child { border-bottom: none; }
        .price-item:hover { background: #f9f9f9; }
        .price-name { font-size: 14px; color: #333; flex: 1; }
        .price-value { font-size: 16px; font-weight: 600; color: #ff6b6b; }
        .price-value.cheapest { color: #00c853; }
        .summary { background: white; border-radius: 12px; padding: 20px; margin-top: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
        .summary h3 { margin-bottom: 15px; color: #333; }
        .summary-item { padding: 8px 0; border-bottom: 1px solid #eee; }
        .summary-item:last-child { border-bottom: none; }
        .tag { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 12px; margin-left: 8px; }
        .tag.hot { background: #ff6b6b; color: white; }
        .tag.new { background: #00c853; color: white; }
    </style>
</head>
<body>
    <div class="header">
        <h1>💰 电商价格对比</h1>
        <p>货比三家 · 省钱购物</p>
    </div>
    <div class="container">
        <div class="platforms">
HTMLEOF
    
    # 添加淘宝
    cat >> "$OUTPUT_FILE" << HTMLEOF
            <div class="card">
                <div class="card-header taobao">
                    <span class="card-title">🛒 淘宝</span>
                </div>
                <div class="card-body">
                    <ul class="price-list">
HTMLEOF
    
    echo "$taobao_data" | jq -r '.[] | "                        <li class=\"price-item\"><span class=\"price-name\">\(.name)</span><span class=\"price-value\">¥\(.price)</span></li>"' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'HTMLEOF'
                    </ul>
                </div>
            </div>
HTMLEOF
    
    # 添加京东
    cat >> "$OUTPUT_FILE" << HTMLEOF
            <div class="card">
                <div class="card-header jd">
                    <span class="card-title">🛍️ 京东</span>
                </div>
                <div class="card-body">
                    <ul class="price-list">
HTMLEOF
    
    echo "$jd_data" | jq -r '.[] | "                        <li class=\"price-item\"><span class=\"price-name\">\(.name)</span><span class=\"price-value\">¥\(.price)</span></li>"' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'HTMLEOF'
                    </ul>
                </div>
            </div>
HTMLEOF
    
    # 添加拼多多
    cat >> "$OUTPUT_FILE" << HTMLEOF
            <div class="card">
                <div class="card-header pdd">
                    <span class="card-title">🥬 拼多多</span>
                </div>
                <div class="card-body">
                    <ul class="price-list">
HTMLEOF
    
    echo "$pdd_data" | jq -r '.[] | "                        <li class=\"price-item\"><span class=\"price-name\">\(.name)</span><span class=\"price-value\">¥\(.price)</span></li>"' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'HTMLEOF'
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="summary">
            <h3>📊 价格总结</h3>
            <div class="summary-item">🏆 全网最低价: ¥5,199 (拼多多)</div>
            <div class="summary-item">💡 建议: 拼多多价格最优</div>
        </div>
    </div>
</body>
</html>
HTMLEOF
    
    log "✅ 页面已生成: $OUTPUT_FILE"
    log "💡 用浏览器打开: file://$OUTPUT_FILE"
}

# 显示帮助
show_help() {
    cat << EOF
价格比较工具 - 货比三家

用法:
  price-compare <关键词> [选项]

选项:
  --taobao       只搜索淘宝
  --jd           只搜索京东
  --pdd          只搜索拼多多
  --all          搜索所有平台（默认）
  --cheapest     只显示最低价
  --html         生成 HTML 对比页面
  --limit N      限制结果数量（默认: 10）
  -h, --help     显示帮助

示例:
  price-compare "iPhone 15"
  price-compare "MacBook Pro" --html
  price-compare "AirPods" --cheapest

EOF
}

# 主程序
keyword=""
CHEAPEST=""
HTML=""
TAOBAO=""
JD=""
PDD=""
ALL="true"

while [[ $# -gt 0 ]]; do
    case $1 in
        --taobao)
            TAOBAO="true"
            ALL=""
            shift
            ;;
        --jd)
            JD="true"
            ALL=""
            shift
            ;;
        --pdd)
            PDD="true"
            ALL=""
            shift
            ;;
        --all)
            ALL="true"
            shift
            ;;
        --cheapest)
            CHEAPEST="true"
            shift
            ;;
        --html)
            HTML="true"
            shift
            ;;
        --limit)
            MAX_ITEMS=$2
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            warn "未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            keyword="$1"
            shift
            ;;
    esac
done

if [ -z "$keyword" ]; then
    warn "请输入搜索关键词"
    show_help
    exit 1
fi

mkdir -p "$TRENDING_DIR"

if [ "$CHEAPEST" = "true" ]; then
    find_cheapest "$keyword"
elif [ "$HTML" = "true" ]; then
    generate_html "$keyword"
else
    search_all "$keyword"
fi
