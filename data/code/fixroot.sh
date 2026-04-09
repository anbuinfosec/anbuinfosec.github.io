#!/bin/bash

B="\e[1m"
R="\e[0m"
C_SUC="\e[1;32m"
C_ERR="\e[1;31m"
C_WRN="\e[1;33m"
C_ASK="\e[1;34m"
C_INF="\e[1;36m"
C_LIME="\e[38;5;154m"
C_GOLD="\e[38;5;214m"
C_CYAN="\e[38;5;51m"

success() { echo -e "${B}${C_SUC}[+]${R} ${C_LIME}${1}${R}"; }
error()   { echo -e "${B}${C_ERR}[-]${R} ${1}"; }
warn()    { echo -e "${B}${C_WRN}[!]${R} ${C_GOLD}${1}${R}"; }
ask()     { echo -ne "${B}${C_ASK}[?]${R} ${1}"; }
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

trap 'echo -e "\n"; warn "Protocol Interrupted. Exiting..."; exit 1' SIGINT

clear
echo -e "${B}${C_CYAN}"
echo "        ╔═════════════════════════════════════╗"
echo "        ║              FIX ROOT               ║"
echo "        ║           VERSION: 1.0.0            ║"
echo "        ║        AUTHOR: Mohammad Alamin      ║"
echo "        ║   GITHUB: github.com/anbuinfosec    ║"
echo "        ╚═════════════════════════════════════╝"
echo -e "${R}"

info "Scanning environment for 'tsu' stability..."
sleep 0.5

if command -v tsu &>/dev/null; then
    if ! tsu -c "echo stability_test" &>/dev/null; then
        warn "Corrupted 'tsu' detected. Initiating purge protocol..."
        if process "Uninstalling broken tsu" pkg uninstall tsu -y; then
            success "Conflict resolved: tsu removed."
        fi
    else
        info "Existing 'tsu' is stable. Skipping removal."
    fi
else
    info "No 'tsu' binaries found in PATH."
fi

process "Synchronizing Termux repositories" pkg update -y
process "Upgrading core components" pkg upgrade -y

if ! command -v sudo &>/dev/null; then
    if process "Injecting sudo framework" pkg install sudo -y; then
        success "Sudo framework successfully integrated."
    fi
else
    info "Sudo framework already active."
fi

echo -e "\n${B}${C_INF}[*] Starting Advanced Root Matrix Scan...${R}"
SU_PATHS=(
    /system/bin/su /system/xbin/su /sbin/su /su/bin/su 
    /magisk/.core/bin/su /data/adb/magisk/su /system/product/bin/su
    /debug_ramdisk/su /system/sbin/su /su/xbin/su
)

find_root() {
    if [[ "$(id -u 2>/dev/null)" == "0" ]]; then
        success "Session is already elevated (UID 0)."
        return 0
    fi

    for path in "${SU_PATHS[@]}"; do
        if [[ -x "$path" ]]; then
            info "Potential target detected at: $path"
            if "$path" -c "id" &>/dev/null; then
                success "Root binary verified: $path"
                echo ""
                ask "Elevate terminal to Root Matrix now? [y/n]: "
                read -r opt
                if [[ "$opt" =~ ^[Yy]$ ]]; then
                    success "Switching to Root Shell. Stay safe, User."
                    exec "$path" -c "sh"
                else
                    warn "Root elevation declined."
                    return 0
                fi
            fi
        fi
    done

    error "No valid root binary detected."
    warn "Check Magisk/KernelSU status."
}

find_root

echo -e "\n${B}${C_CYAN}▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰"
info "PROTOCOL COMPLETE. AUTHOR: Mohammad Alamin"
echo -e "GITHUB: https://github.com/anbuinfosec"
echo -e "▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰▰${R}"
