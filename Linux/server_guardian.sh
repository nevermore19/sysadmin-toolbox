#!/bin/bash

URLS_TO_CHECK=(
    "http://127.0.0.1"
    "http://127.0.0.1/about"
    # ...
)

DISCORD_WEBHOOK_URL=""

# both in %
MAX_CPU_USAGE=80
MIN_FREE_RAM=15

if [ -t 1 ]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    NC='\033[0m'
else
    RED=''
    YELLOW=''
    GREEN=''
    NC=''
fi

echo "=== SERVER GUARDIAN: $(date) ==="

send_discord_alert() {
    local message="$1"

    if [[ -n "$DISCORD_WEBHOOK_URL" && "$DISCORD_WEBHOOK_URL" == https://discord.com/api/webhooks/* ]]; then

        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"**[ALERT]** $message\"}" \
             "$DISCORD_WEBHOOK_URL" > /dev/null 2>&1
    fi
}

echo "[INFO] Starting web endpoints validation..."

for url in "${URLS_TO_CHECK[@]}"; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")

    if [ -z "$HTTP_STATUS" ]; then
        HTTP_STATUS=0
    fi

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo -e "${GREEN}[OK] Endpoint $url is UP (Status: 200)${NC}"
    else
        echo -e "${RED}[ALERT] Endpoint $url is DOWN! Status: $HTTP_STATUS${NC}"
        send_discord_alert "Endpoint $url is DOWN! HTTP status: $HTTP_STATUS"
    fi
done


FREE_RAM_KB=$(LC_ALL=C free | awk '/^Mem:/ {print $4 + $6}')
TOTAL_RAM_KB=$(LC_ALL=C free | awk '/^Mem:/ {print $2}')

if [[ -n "$FREE_RAM_KB" && -n "$TOTAL_RAM_KB" && "$TOTAL_RAM_KB" -gt 0 ]]; then
    RAM_FREE=$(( FREE_RAM_KB * 100 / TOTAL_RAM_KB ))
    
    if [ "$RAM_FREE" -ge "$MIN_FREE_RAM" ]; then
        echo -e "${GREEN}[OK] RAM usage is fine. Free: ${RAM_FREE}%${NC}"
    else
        echo -e "${RED}[ALERT] Low memory! Free RAM: ${RAM_FREE}%${NC}"
        send_discord_alert "Low memory! Free RAM: ${RAM_FREE}%"
    fi
else
    echo -e "${RED}[ERROR] Could not calculate RAM usage${NC}"
fi


read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

TOTAL1=$((user + nice + system + idle + iowait + irq + softirq + steal))
IDLE1=$((idle + iowait))

sleep 1

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

TOTAL2=$((user + nice + system + idle + iowait + irq + softirq + steal))
IDLE2=$((idle + iowait))

TOTAL_DIFF=$((TOTAL2 - TOTAL1))
IDLE_DIFF=$((IDLE2 - IDLE1))

if [ "$TOTAL_DIFF" -gt 0 ]; then
    CPU_USAGE=$((100 * (TOTAL_DIFF - IDLE_DIFF) / TOTAL_DIFF))

    if [ "$CPU_USAGE" -le "$MAX_CPU_USAGE" ]; then
        echo -e "${GREEN}[OK] CPU usage is fine. Current: ${CPU_USAGE}%${NC}"
    else
        echo -e "${RED}[ALERT] High CPU usage! Current: ${CPU_USAGE}%${NC}"
        send_discord_alert "High CPU usage! Current: ${CPU_USAGE}%"
    fi
else
    echo -e "${RED}[ERROR] Could not calculate CPU usage${NC}"
fi