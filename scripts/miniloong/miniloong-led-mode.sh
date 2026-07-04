#!/bin/bash

CONFIG_FILE="/home/ark/.config/miniloong_led_mode"
LED_SYSFS="/sys/class/leds/aw20036_led"
LED_SERVICE="miniloong_led.service"

# Defaults
LED_MODE="battery"
LED_BRIGHTNESS="80"
LED_EFFECT="solid"

# New config format written by EmulationStation:
#   line 1 = mode      battery/red/green/blue/yellow/cyan/magenta/off
#   line 2 = brightness percent, 1-100
#   line 3 = effect    solid/breathe/blink
#
# Backward compatible with the old one-line format.
if [ -f "$CONFIG_FILE" ]; then
    LED_MODE="$(sed -n '1p' "$CONFIG_FILE" | tr -d '\r\n[:space:]' | tr '[:upper:]' '[:lower:]')"
    LED_BRIGHTNESS="$(sed -n '2p' "$CONFIG_FILE" | tr -d '\r\n[:space:]')"
    LED_EFFECT="$(sed -n '3p' "$CONFIG_FILE" | tr -d '\r\n[:space:]' | tr '[:upper:]' '[:lower:]')"
fi

LED_MODE="${LED_MODE:-battery}"
LED_BRIGHTNESS="${LED_BRIGHTNESS:-80}"
LED_EFFECT="${LED_EFFECT:-solid}"

# Validate mode.
case "$LED_MODE" in
    battery|red|green|blue|yellow|cyan|magenta|rainbow|off) ;;
    *) LED_MODE="battery" ;;
esac

# Validate effect. Battery mode ignores effect, but keep a valid default.
case "$LED_EFFECT" in
    solid|breathe|blink) ;;
    *) LED_EFFECT="solid" ;;
esac

# Validate brightness as a percentage.
case "$LED_BRIGHTNESS" in
    ''|*[!0-9]*) LED_BRIGHTNESS="80" ;;
esac

if [ "$LED_BRIGHTNESS" -lt 1 ]; then
    LED_BRIGHTNESS="1"
elif [ "$LED_BRIGHTNESS" -gt 100 ]; then
    LED_BRIGHTNESS="100"
fi

write_led_attr() {
    local attr="$1"
    local value="$2"

    if [ -e "$LED_SYSFS/$attr" ]; then
        echo "$value" | sudo tee "$LED_SYSFS/$attr" >/dev/null
    fi
}

stop_battery_led_service() {
    if systemctl is-active --quiet "$LED_SERVICE"; then
        sudo systemctl stop "$LED_SERVICE"
    fi

    if systemctl is-enabled --quiet "$LED_SERVICE" 2>/dev/null; then
        sudo systemctl disable "$LED_SERVICE" >/dev/null 2>&1
    fi
}

start_battery_led_service() {
    sudo systemctl enable "$LED_SERVICE" >/dev/null 2>&1
    sudo systemctl restart "$LED_SERVICE"
}

# Convert menu brightness percentage to the LED driver's range.
# The Miniloong custom driver normally uses miniloong_brightness.
# If max_brightness exists and is >100, scale percentage to that range.
DRIVER_BRIGHTNESS="$LED_BRIGHTNESS"
if [ -f "$LED_SYSFS/max_brightness" ]; then
    MAX_BRIGHTNESS="$(cat "$LED_SYSFS/max_brightness" 2>/dev/null)"
    case "$MAX_BRIGHTNESS" in
        ''|*[!0-9]*) MAX_BRIGHTNESS="100" ;;
    esac

    if [ "$MAX_BRIGHTNESS" -gt 100 ]; then
        DRIVER_BRIGHTNESS=$(( LED_BRIGHTNESS * MAX_BRIGHTNESS / 100 ))
        [ "$DRIVER_BRIGHTNESS" -lt 1 ] && DRIVER_BRIGHTNESS="1"
    fi
fi

# Apply brightness in both battery and fixed-color modes.
write_led_attr "miniloong_brightness" "$DRIVER_BRIGHTNESS"

case "$LED_MODE" in
    battery)
        # Battery mode keeps the service in charge/state-driven control.
        # Brightness is still applied above.
        start_battery_led_service
        ;;

    off)
        stop_battery_led_service
        write_led_attr "miniloong_effect" "solid"
        write_led_attr "miniloong_color" "off"
        ;;

    red|green|blue|yellow|cyan|magenta)
        stop_battery_led_service
        write_led_attr "miniloong_effect" "$LED_EFFECT"
        write_led_attr "miniloong_color" "$LED_MODE"
        ;;

    rainbow)
        stop_battery_led_service
        write_led_attr "miniloong_rainbow_rate" "255"
        write_led_attr "miniloong_effect" "$LED_MODE"
        ;;
esac

exit 0
