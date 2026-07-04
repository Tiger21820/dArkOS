#!/bin/bash

# Miniloong AW20036 charge/battery LED daemon
#
# Requires the patched Miniloong AW20036 driver exposing:
#   /sys/class/leds/aw20036_led/miniloong_color
#   /sys/class/leds/aw20036_led/miniloong_effect
#   /sys/class/leds/aw20036_led/miniloong_brightness
#   /sys/class/leds/aw20036_led/miniloong_pulse_rate
#   /sys/class/leds/aw20036_led/miniloong_blink_rate

LED="/sys/class/leds/aw20036_led"
CONFIG_FILE="/home/ark/.config/miniloong_led_mode"

if [ -f "$CONFIG_FILE" ]; then
  BRIGHTNESS="$(sed -n '2p' "$CONFIG_FILE" | tr -d '\r\n[:space:]')"
else
  BRIGHTNESS=16
fi

# Charging pulse: slow/comfortable.
PULSE_ON_MS="${PULSE_ON_MS:-800}"
PULSE_OFF_MS="${PULSE_OFF_MS:-800}"

# Critical low battery: fast blinking.
BLINK_ON_MS="${BLINK_ON_MS:-150}"
BLINK_OFF_MS="${BLINK_OFF_MS:-150}"

POLL_NORMAL="${POLL_NORMAL:-10}"
POLL_CHARGING="${POLL_CHARGING:-5}"

last_state=""

write_attr() {
    local attr="$1"
    local value="$2"

    if [ -w "$LED/$attr" ]; then
        echo "$value" > "$LED/$attr"
    fi
}

led_available() {
    [ -d "$LED" ] &&
    [ -w "$LED/miniloong_color" ] &&
    [ -w "$LED/miniloong_effect" ] &&
    [ -w "$LED/miniloong_brightness" ]
}

battery_available() {
    [ -r "$BAT" ] && [ -r "/sys/class/power_supply/battery/status" ]
}

apply_common_settings() {
    write_attr trigger none
    write_attr miniloong_brightness "$BRIGHTNESS"
    write_attr miniloong_pulse_rate "$PULSE_ON_MS $PULSE_OFF_MS"
    write_attr miniloong_blink_rate "$BLINK_ON_MS $BLINK_OFF_MS"
}

set_led_state() {
    local color="$1"
    local effect="$2"

    apply_common_settings
    write_attr miniloong_color "$color"
    write_attr miniloong_effect "$effect"
}

while true; do
    if [[ -f /tmp/battery.percent ]]; then
      BAT="/tmp/battery.percent"
    else
      BAT="/sys/class/power_supply/battery/capacity"
    fi

    if ! led_available || ! battery_available; then
        sleep 5
        continue
    fi

    CAPACITY="$(cat "$BAT" 2>/dev/null)"
    STATUS="$(cat "/sys/class/power_supply/battery/status" 2>/dev/null)"

    case "$CAPACITY" in
        ''|*[!0-9]*)
            sleep 5
            continue
            ;;
    esac

    #
    # Charging state overrides normal capacity color.
    #
    # Charging and <100%  = pulsing green
    # Full or >=100%      = solid green
    # Discharging >=75%   = solid green
    # Discharging 30-74%  = solid yellow
    # Discharging 10-29%  = solid red
    # Discharging <10%    = fast blinking red
    #
    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -lt 100 ]; then
        STATE="CHARGING"
        COLOR="green"
        EFFECT="pulse"
        SLEEP_TIME="$POLL_CHARGING"
    elif [ "$STATUS" = "Full" ] || [ "$CAPACITY" -ge 100 ]; then
        STATE="FULL"
        COLOR="green"
        EFFECT="solid"
        SLEEP_TIME="$POLL_CHARGING"
    elif [ "$CAPACITY" -ge 75 ]; then
        STATE="GREEN"
        COLOR="green"
        EFFECT="solid"
        SLEEP_TIME="$POLL_NORMAL"
    elif [ "$CAPACITY" -ge 30 ]; then
        STATE="YELLOW"
        COLOR="yellow"
        EFFECT="solid"
        SLEEP_TIME="$POLL_NORMAL"
    elif [ "$CAPACITY" -ge 10 ]; then
        STATE="RED"
        COLOR="red"
        EFFECT="solid"
        SLEEP_TIME="$POLL_NORMAL"
    else
        STATE="LOW"
        COLOR="red"
        EFFECT="blink"
        SLEEP_TIME="$POLL_CHARGING"
    fi

    if [ "$STATE" != "$last_state" ]; then
        set_led_state "$COLOR" "$EFFECT"
        last_state="$STATE"
    fi

    sleep "$SLEEP_TIME"
done
