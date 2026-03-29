#!/bin/bash

HDMI_STATUS=$(cat /sys/class/drm/card0-HDMI-A-1/status 2>/dev/null)

if [ "$HDMI_STATUS" = "connected" ]; then
    echo "Switching audio to HDMI"
    cp /home/ark/.asoundrchdmi /home/ark/.asoundrc
else
    cp /home/ark/.asoundrcbak /home/ark/.asoundrc
fi
