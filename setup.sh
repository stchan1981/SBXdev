#!/bin/bash

# ==============================================================
# SAP BAS Proxy Auto-Deploy Script (Xray + Cloudflare Tunnel)
# Warning: For educational/testing purposes only.
# ==============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
INSTALL_DIR="$HOME/.sap-proxy"
XRAY_VERSION="v1.8.4" # 或 latest
PORT=8001
WS_PATH="/ray"
UUID=$(cat /proc/sys/kernel/random/uuid)
CF_TOKEN=""
DOMAIN=""

# 帮助函数
usage() {
    echo -e "${BLUE}Usage:${NC} $0 -t <CF_TOKEN> -d <DOMAIN> [-u <UUID>]"
    echo -e "  -t  Cloudflare Tunnel Token (Required)"
    echo -e "  -d  Your Custom Domain (Required for link generation, e.g., sap.example.com)"
    echo -e "  -u  Custom UUID (Optional, auto-generated if not set)"
    exit 1
}

# 解析参数
while getopts "t:d:u:" opt; do
  case $opt in
    t) CF_TOKEN="$OPTARG" ;;
    d) DOMAIN="$OPTARG" ;;
    u) UUID="$OPTARG" ;;
    *) usage ;;
  esac
done

# 检查必填项
if [ -z "$CF_TOKEN" ] || [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Token and Domain are required.${NC}"
    usage
fi

echo -e "${GREEN}>>> Starting Deployment...${NC}"
echo -e "    Domain: $DOMAIN"
echo -e "    UUID:   $UUID"
echo -e "    Dir:    $INSTALL_DIR"

# 1. 创建目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 2. 下载 Xray
if [ ! -f "xray" ]; then
    echo -e "${YELLOW}>>> Downloading Xray Core...${NC}"
    wget -q -O xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"
    unzip -q -o xray.zip
    rm xray.zip
    chmod +x xray
fi

# 3. 下载 Cloudflared
if [ ! -f "cloudflared" ]; then
    echo -e "${YELLOW}>>> Downloading Cloudflared...${NC}"
    wget -q -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x cloudflared
fi

# 4. 生成 Xray 配置文件 (config.json)
echo -e "${YELLOW}>>> Generating Config...${NC}"
cat > config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": $PORT,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "$UUID", "level": 0 } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "$WS_PATH" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF

# 5. 生成启动/守护脚本 (run.sh)
cat > run.sh <<EOF
#!/bin/bash
cd "$INSTALL_DIR"

# Start Xray
if ! pgrep -x "xray" > /dev/null; then
    nohup ./xray -c config.json > /dev/null 2>&1 &
fi

# Start Cloudflared
if ! pgrep -f "cloudflared tunnel" > /dev/null; then
    nohup ./cloudflared tunnel --no-autoupdate run --token $CF_TOKEN > /dev/null 2>&1 &
fi
EOF
chmod +x run.sh

# 6. 添加到 .bashrc 实现持久化
if ! grep -q "$INSTALL_DIR/run.sh" ~/.bashrc; then
    echo -e "${YELLOW}>>> Adding hook to .bashrc...${NC}"
    echo "" >> ~/.bashrc
    echo "# Auto start SAP Proxy" >> ~/.bashrc
    echo "bash $INSTALL_DIR/run.sh" >> ~/.bashrc
fi

# 7. 启动服务
echo -e "${YELLOW}>>> Starting Services...${NC}"
bash ./run.sh
sleep 3

# 8. 生成并打印 VLESS 链接
# VLESS Link Format: vless://uuid@host:443?security=tls&encryption=none&type=ws&path=/ray&sni=host#name
VLESS_LINK="vless://${UUID}@${DOMAIN}:443?security=tls&encryption=none&type=ws&path=${WS_PATH//\//%2F}&host=${DOMAIN}&sni=${DOMAIN}#SAP-BAS-Proxy"

echo -e "\n${GREEN}=======================================================${NC}"
echo -e "${GREEN}   DEPLOYMENT SUCCESSFUL!   ${NC}"
echo -e "${GREEN}=======================================================${NC}"
echo -e "Node Info:"
echo -e "  Address: ${BLUE}${DOMAIN}${NC}"
echo -e "  Port:    ${BLUE}443${NC}"
echo -e "  UUID:    ${BLUE}${UUID}${NC}"
echo -e "  Path:    ${BLUE}${WS_PATH}${NC}"
echo -e "-------------------------------------------------------"
echo -e "${YELLOW}VLESS Link (Copy and Import to v2rayN/Shadowrocket):${NC}"
echo -e "\n${VLESS_LINK}\n"
echo -e "-------------------------------------------------------"
