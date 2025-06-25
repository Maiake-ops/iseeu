#!/data/data/com.termux/files/usr/bin/bash

trap cleanup INT

function cleanup() {
    echo "[*] Cleaning up..."
    pkill -f "python3 -m http.server"
    pkill -f "cloudflared tunnel"
    rm -f index.html
    echo "[*] Done. Exiting."
    exit 0
}

read -p "[?] Enter port to use for local server (default 8080): " port
port=${port:-8080}

echo "[*] Killing old servers..."
pkill -f "python3 -m http.server" &>/dev/null
pkill -f "cloudflared tunnel" &>/dev/null

echo "[*] Creating autoplay HTML..."
cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head>
  <title>It Works!</title>
</head>
<body>
  <h1>🔊 Autoplay Test</h1>
  <audio autoplay>
    <source src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" type="audio/mpeg">
    Your browser does not support the audio element.
  </audio>
</body>
</html>
EOF

echo "[*] Starting HTTP server on port $port..."
nohup python3 -m http.server "$port" --bind 127.0.0.1 > /dev/null 2>&1 &

echo "[*] Waiting for HTTP server to be ready..."
until curl -s "http://127.0.0.1:$port" > /dev/null; do
    sleep 1
done

echo "[*] Starting Cloudflared tunnel..."

mkdir -p logs
logfile="logs/log_$(date +'%Y-%m-%d_%H-%M-%S').txt"

# Run cloudflared and extract the trycloudflare URL
cloudflared tunnel --url "http://localhost:$port" 2>&1 | tee "$logfile" | while read -r line; do
    echo "$line"
    if [[ "$line" =~ https://[a-zA-Z0-9-]+\.trycloudflare\.com ]]; then
        echo ""
        echo "[✓] Tunnel is ready at:"
        echo "    ${BASH_REMATCH[0]}"
        echo ""
        echo "[*] Logging to $logfile"
        echo "[*] Press Ctrl+C to stop."
    fi
done
