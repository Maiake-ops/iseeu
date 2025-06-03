---

# iSeeU

🌍 **iSeeU - Universal Geolocation Tracker**  
Works on **Kali**, **Ubuntu**, **Fedora**, **Arch**, **macOS**, **Termux (Android)**, and all major Linux distros.

[![GitHub stars](https://img.shields.io/github/stars/Maiake-ops/iseeu?style=social)](https://github.com/Maiake-ops/iseeu)
![Platform](https://img.shields.io/badge/Platform-Linux%20|%20macOS%20|%20Termux%20|%20Fedora%20|%20Arch-blue)

![Demo](https://user-images.githubusercontent.com/3501170/55271108-d11b3180-52fb-11e9-97e2-c930be295147.png)

---

## 📥 Installation & Setup

### 1. Install Git (if needed)

| Platform       | Command                                      |
|----------------|----------------------------------------------|
| Debian/Ubuntu/Kali | `sudo apt update && sudo apt install -y git` |
| Fedora/RHEL    | `sudo dnf install -y git`                    |
| Arch/Manjaro   | `sudo pacman -S git`                         |
| macOS (Homebrew) | `brew install git`                         |
| Termux (Android) | `pkg install -y git`                       |

# 2. Clone the Repo

```bash
git clone https://github.com/Maiake-ops/iseeu.git
cd iseeu
chmod +x *.sh  # Make all scripts executable
```

3. Install Dependencies

Platform	Command

Debian/Ubuntu/Kali: 	sudo apt install -y openssh-client python3
Fedora/RHEL: 	sudo dnf install -y openssh-clients python3
Arch/Manjaro	: sudo pacman -S openssh python
MacOS: brew install openssh python3
Termux (Android):	pkg install -y busybox nmap



---

🚀 Usage

```bash
sh Iseeu.sh          # Start the tracker (for Android only)
bash Iseeu.sh       # Normal startup for (non-MLC only)
./kill-server.sh    # Stop tunnel and web server
./start.sh          # Menu launcher (recommended)
```

if you are on Android if you use bash Iseeu.sh it will freeze because it's a minimal Linux container (MLC)


---

🌟 Features

✔️ All-in-One Installer — Covers Git and dependency setup

✔️ One-Command Launch — Easy for beginners

✔️ Cross-Platform Support — Linux, Termux, macOS, and more

✔️ Serveo Tunnel + Web UI — Collects geolocation from targets



---

📜 Credits

🧠 Original Author: Viral Maniar

🔧 Modded by: Techguys Origin

📦 Repo: github.com/Maiake-ops/iseeu

🌿 Contributor: Natureless1



---

⚠️ Legal Notice

> For educational use and authorized testing only.
❗ Do not use without explicit permission of the target system owner.



---
