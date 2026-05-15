#!/bin/bash

CARD=0

# If headphone jack is reported as plugged, use headphones only.
# Otherwise restore speaker path.
if [[ "$(dmesg | grep 'headset status is ' | tail -1)" == *"headset status is in"* ]]; then
    amixer -c "$CARD" set 'Playback Path' 'HP'
else
    amixer -c "$CARD" set 'Playback Path' 'SPK'
fi
