#!/bin/bash

DAEMON="/usr/local/bin/batteryplus"
DAEMON_NAME=$(basename "$DAEMON")
CONF_FILE="/etc/batteryplus/batteryplus.conf"

# Ensure config exists with defaults if empty
ensure_conf() {
  if [ ! -f "$CONF_FILE" ]; then
    sudo mkdir -p "$(dirname "$CONF_FILE")"
    cat > "$CONF_FILE" <<'EOF'
# data_dir is required and should be an absolute path to a persistent directory
# possible modes: voltage(default) and pmic
[Config]
mode=voltage
data_dir=/home/ark/.config/batteryplus
V_EMPTY_CHG=3400
V_EMPTY_DIS=3250
EOF
  fi
}

set_mode() {
    MODE="$(cat /home/ark/.config/.BRMODE | tr '[:upper:]' '[:lower:]' 2>/dev/null)"

    if [[ "$MODE" == "native" ]]; then
	  sudo systemctl disable batteryplus
	  sudo rm /tmp/battery.percent
	  sudo systemctl stop batteryplus
	  exit 0
	else
	  sudo systemctl enable batteryplus &
	fi

    if grep -qE '^[[:space:]]*mode[[:space:]]*=' "$CONF_FILE"; then
        sudo sed -i -E "s|^[[:space:]]*mode[[:space:]]*=.*|mode=$MODE|" "$CONF_FILE"
    else
        sudo sed -i "/^\[Config\]/a mode=$MODE" "$CONF_FILE"
    fi
}

do_initialize() {
    BOOT_BOARD="/home/ark/.config/.DEVICE"

    [ -f "$CONF_FILE" ] || return 0

    DATA_DIR=$(sed -nE 's/^[[:space:]]*data_dir[[:space:]]*=[[:space:]]*(.+)[[:space:]]*$/\1/p' "$CONF_FILE" | head -n 1)

    [ -n "$DATA_DIR" ] || return 0
    [ -f "$BOOT_BOARD" ] || return 0

    mkdir -p "$DATA_DIR"

    DATA_BOARD="$DATA_DIR/darkos.board"
    CAL_FLAG="$DATA_DIR/batteryplus-calibrated"
    MAP_FILE="$DATA_DIR/batteryplus-voltage.map"
    PERCENT_FILE="/tmp/battery.percent"
    RESTORE_FILE="$DATA_DIR/batteryplus-restore.state"

    if [ ! -f "$DATA_BOARD" ]; then
        cp -f "$BOOT_BOARD" "$DATA_BOARD"
    else
        if ! cmp -s "$BOOT_BOARD" "$DATA_BOARD"; then
            cp -f "$BOOT_BOARD" "$DATA_BOARD"

            # Device changed, remove learned calibration and device specific data
            rm -f "$CAL_FLAG"
            rm -f "$MAP_FILE"
            rm -f "$RESTORE_FILE"
        fi
    fi

    # Always remove file in case mode changed so generates new
    sudo rm -f "$PERCENT_FILE"
}

start_daemon() {
    echo "Starting $DAEMON_NAME."

    if sudo "$DAEMON"; then
        echo "$DAEMON_NAME started OK"
        return 0
    fi

    echo "$DAEMON_NAME failed to start"
    return 1
}

stop_daemon() {
    echo "Stopping $DAEMON_NAME."

    if ! systemctl is-active --quiet batteryplus.service; then
        echo "$DAEMON_NAME is not running."
        return 0
    fi

    systemctl is-active --quiet batteryplus.service && sudo systemctl stop batteryplus || {
        echo "$DAEMON_NAME is not running."
        return 0
    }

    echo "$DAEMON_NAME stopped"
}

# Sanity check
[ -e "$DAEMON" ] || exit 0

case "$1" in
    start)
        ensure_conf
        set_mode
        do_initialize
        start_daemon || exit 1
        ;;
    stop)
        stop_daemon || exit 1
        ;;
    restart)
        stop_daemon || exit 1
        sleep 0.5
        ensure_conf
        set_mode
        do_initialize
        start_daemon || exit 1
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 1
        ;;
esac


