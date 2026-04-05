#!/bin/bash
# @tool_name: WIPWN
# @version: 3.0.1
# @description: Advanced WiFi Penetration & hacking using termux (rooted).
# @author: Mohammad Alamin
# @github: github.com/anbuinfosec
# @cmd: curl -sLo wipwn.sh https://anbuinfosec.me/code/wipwn.sh | bash

B="\e[1m"
R="\e[0m"
C_SUC="\e[1;32m"
C_ERR="\e[1;31m"
C_WRN="\e[1;33m"
C_INF="\e[1;36m"
C_LIME="\e[38;5;154m"
C_GOLD="\e[38;5;214m"
C_CYAN="\e[38;5;51m"

success() { echo -e "${B}${C_SUC}[+]${R} ${C_LIME}${1}${R}"; }
error()   { echo -e "${B}${C_ERR}[-]${R} ${1}"; }
warn()    { echo -e "${B}${C_WRN}[!]${R} ${C_GOLD}${1}${R}"; }
info()    { echo -e "${B}${C_INF}[i]${R} ${1}"; }

process() {
    local msg="$1"
    shift
    "$@" > /dev/null 2>&1 &
    local pid=$!
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        for i in {0..9}; do
            echo -ne "\r${B}${C_INF}[${frames:$i:1}]${R} ${msg}..."
            sleep 0.1
        done
    done
    wait $pid
    local status=$?
    echo -ne "\r\033[K"
    return $status
}

trap 'echo -e "\n"; warn "Installation Interrupted. Cleaning up..."; exit 1' SIGINT

clear
echo -e "${B}${C_CYAN}"
echo "        ╔═════════════════════════════════════╗"
echo "        ║           WIPWN INSTALLER           ║"
echo "        ║           VERSION: 3.0.1            ║"
echo "        ║        AUTHOR: Mohammad Alamin      ║"
echo "        ║   GITHUB: github.com/anbuinfosec    ║"
echo "        ╚═════════════════════════════════════╝"
echo -e "${R}"

info "Starting WIPWN automated installation protocol..."
sleep 1

process "Updating system repositories" pkg update -y
process "Upgrading core packages" pkg upgrade -y
success "System environment is up to date."

for pkg in git python sudo ncurses-utils; do
    if ! command -v $pkg &>/dev/null; then
        process "Installing dependency: $pkg" pkg install $pkg -y
        success "$pkg installed successfully."
    else
        info "$pkg is already installed."
    fi
done

if [ -d "$HOME/wipwn" ]; then
    warn "Existing WIPWN directory detected. Re-cloning..."
    rm -rf "$HOME/wipwn"
fi

if process "Cloning WIPWN repository" git clone https://github.com/anbuinfosec/wipwn "$HOME/wipwn"; then
    success "Repository cloned to $HOME/wipwn"
else
    error "Failed to clone repository. Check your internet connection."
    exit 1
fi

cd "$HOME/wipwn" || exit

if [ -f "requirements.txt" ]; then
    process "Installing Python requirements" pip install -r requirements.txt
    success "Python dependencies satisfied."
fi

if [ -f "main.py" ]; then
    chmod +x main.py
    success "Main execution engine verified."
fi

echo -e "\n${B}${C_CYAN}▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰"
info "WIPWN INSTALLATION COMPLETE."
info "Path: cd $HOME/wipwn"
info "Run : python main.py"
echo -e "▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰${R}"
