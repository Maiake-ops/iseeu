#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PORT=8080

echo -e "${GREEN}[*] Attempting graceful shutdown of all services...${NC}"

# Kill Python HTTP server
PY_PID=$(pgrep -f "python3 -m http.server")
if [ -n "$PY_PID" ]; then
    kill "$PY_PID" && echo -e "${GREEN}[✓] Python server (PID $PY_PID) stopped.${NC}" || echo -e "${RED}[✗] Failed to stop Python server.${NC}"
else
    echo -e "${RED}[-] Python server not running.${NC}"
fi

# Kill Cloudflared
CF_PID=$(pgrep -f "cloudflared tunnel")
if [ -n "$CF_PID" ]; then
    kill "$CF_PID" && echo -e "${GREEN}[✓] Cloudflared (PID $CF_PID) stopped.${NC}" || echo -e "${RED}[✗] Failed to stop Cloudflared.${NC}"
else
    echo -e "${RED}[-] Cloudflared not running.${NC}"
fi

# Kill netcat logger
NC_PID=$(pgrep -f "nc -l")
if [ -n "$NC_PID" ]; then
    kill "$NC_PID" && echo -e "${GREEN}[✓] Netcat logger (PID $NC_PID) stopped.${NC}" || echo -e "${RED}[✗] Failed to stop Netcat.${NC}"
else
    echo -e "${RED}[-] Netcat not running.${NC}"
fi

# Check if port is still in use
if lsof -i :"$PORT" >/dev/null 2>&1; then
    echo -e "${RED}[!] Port $PORT still in use. Attempting force close...${NC}"
    fuser -k "$PORT"/tcp && echo -e "${GREEN}[✓] Port $PORT freed.${NC}" || echo -e "${RED}[✗] Could not free port $PORT.${NC}"
else
    echo -e "${GREEN}[✓] Port $PORT is free.${NC}"
fi

echo -e "${GREEN}[✓] Cleanup complete.${NC}"