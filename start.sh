#!/bin/bash
# [所有原 export 参数齐全]
export UUID=${UUID:-'fdeeda45-0a8e-4570-bcc6-d68c995f5830'}
export NEZHA_SERVER=${NEZHA_SERVER:-''}
export NEZHA_PORT=${NEZHA_PORT:-''}
export NEZHA_KEY=${NEZHA_KEY:-''}
export ARGO_DOMAIN=${ARGO_DOMAIN:-''}
export ARGO_AUTH=${ARGO_AUTH:-''}
export CFIP=${CFIP:-'cf.877774.xyz'}
export CFPORT=${CFPORT:-'443'}
export NAME=${NAME:-''}
export FILE_PATH=${FILE_PATH:-'./.npm'}
export ARGO_PORT=${ARGO_PORT:-'8001'}
export TUIC_PORT=${TUIC_PORT:-''}
export HY2_PORT=${HY2_PORT:-''}
export REALITY_PORT=${REALITY_PORT:-''}
export CHAT_ID=${CHAT_ID:-''}
export BOT_TOKEN=${BOT_TOKEN:-''}
export UPLOAD_URL=${UPLOAD_URL:-''}
export DISABLE_ARGO=${DISABLE_ARGO:-'false'}

# 加载 .env 如果存在（新增）
if [ -f ".env" ]; then
  source .env
fi

# 原 base64 解码执行（完整字符串，从你的消息复制，确保无截断）
echo "aWYgWyAtZiAiLmVudiIgXTsgdGhlbgogICAgIyDkvb/nlKggc2VkIOenu+mZpCBleHBvcnQg5YWz6ZSu5a2X77yM5bm26L+H5ruk5rOo6YeK6KGMCiAgICBzZXQgLW8gYWxsZXhwb3J0ICAjIOS4tOaXtuW8gOWQr+iHquWKqOWvvOWHuuWPmOmHjwogICAgc291cmNlIDwoZ3JlcCAtdiAnXiMnIC5lbnYgfCBzZWQgJ3MvXmV4cG9ydCAvLycgKQogICAgc2V0ICtvIGFsbGV4cG9ydCAgIyDlhbPpl63oh6rliqjlr7zlh7oKZmkKClsgISAtZCAiJHtGSUxFX1BBVEh9IiBdICYmIG1rZGlyIC1wICIke0ZJTEVfUEFUSH0iCgpkZWxldGVfb2xkX25vZGVzKCkgewogIFtbIC16ICRVUExPQURfVVJMIHx8ICEgLWYgIiR7RklMRV9QQVRIfS9zdWIudHh0IiBdXSAmJiByZXR1cm4KICBvbGRfbm9kZXM9JChiYXNlNjQgLWQgIiR7RklMRV9QQVRIfS9zdWIudHh0IiB8IGdyZXAgLUUgJyh2bGVzc3x2bWVzc3x0cm9qYW58aHlzdGVyaWEyfHR1aWMpOi8vJykKICBbWyAteiAkb2xkX25vZGVzIF1dICYmIHJldHVybgoKICBqc29uX2RhdGE9J3sibm9kZXMiOiBbJwogIGZvciBub2RlIGluICRvbGRfbm9kZXM7IGRvCiAgICAgIGpzb25fZGF0YSs9IlwiJG5vZGVcIiwiCiAgZG9uZQogIGpzb25fZGF0YT0ke2pzb25
