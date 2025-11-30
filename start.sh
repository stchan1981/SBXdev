# 生成 .env 持久化（借鉴 Argosbx 的文件存储）
cat > .env << EOF
UUID=${UUID:-'d5646919-1638-4dc6-9799-d795595c6b65'}
ARGO_AUTH=${ARGO_AUTH:-''}
DISABLE_ARGO=${DISABLE_ARGO:-'false'}
EOF
source .env  # 加载

# 日志文件
LOG_FILE="$HOME/.agsbx.log"
exec >> "$LOG_FILE" 2>&1  # 重定向输出

# 进程检测钩子（借鉴 Argosbx 的 find /proc + pgrep）
check_and_restart() {
  if ! pgrep -f 'node index.js' >/dev/null 2>&1 && ! pgrep -f 'sing-box' >/dev/null 2>&1; then
    echo "$(date): Detected interruption, restarting npm start..." >> "$LOG_FILE"
    sleep 6
    cd "$(dirname "$0")" && npm start >> "$LOG_FILE" 2>&1 &
  fi
}

# 添加到 ~/.bashrc（登录时检查，借鉴 Argosbx 的 if ! pgrep ... then export & bash）
if ! grep -q "agsbx_check" ~/.bashrc; then
  echo "if ! pgrep -f 'node index.js' && ! pgrep -f 'sing-box'; then echo 'Node interrupted, auto-recovering...'; cd ~/'$(basename "$PWD")'/nodejs && export \$(cat .env | xargs) && npm start; fi # agsbx_check" >> ~/.bashrc
  source ~/.bashrc
fi

# crontab @reboot（重启后 10s 恢复，借鉴 Argosbx 的 @reboot sleep 10 && nohup）
(crontab -l 2>/dev/null | grep -v 'agsbx'; echo "@reboot sleep 10 && cd ~/'$(basename "$PWD")'/nodejs && export \$(cat .env | xargs) && npm start") | crontab -

# 每 5min 检查一次（cron 补充）
(crontab -l 2>/dev/null | grep -v 'agsbx'; echo "*/5 * * * * cd ~/'$(basename "$PWD")'/nodejs && [ ! -f .pm2/pids/proxy-node.pid ] && export \$(cat .env | xargs) && pm2 resurrect") | crontab -

echo "$(date): Auto-alive hooks installed: crontab/bashrc/PM2 ready." >> "$LOG_FILE"

# 原清理（保留）
rm -rf fake_useragent_0.2.0.json .npm/boot.log .npm/config.json .npm/sb.log .npm/core .npm/fake_useragent_0.2.0.json .npm/list.txt .npm/tunnel.json .npm/tunnel.yml > /dev/null 2>&1
echo -e "\e[1;32mTelegram:https://t.me/eooce\e[1;35mhttps://t.me/laowang_serv00_bot\e[0m"
echo -e "\e[1;32mYoutube👇https://www.youtube.com/@eooce\e[1;35mhttps://www.youtube.com/@laowang_serv00\e[0m"
echo -e "\e[1;32mGithub👇https://github.com/eooce\e[1;35mhttps://github.com/laowang-serv00\e[0m\n"
sleep 5
clear
