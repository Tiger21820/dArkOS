#!/bin/bash
#
# miniloong-refresh-confirm.sh
#
# Run early in dArkOS's boot sequence (after the display/panel is up,
# before or during frontend launch). Shows a "keep this refresh rate?"
# prompt only when the kernel is actually configured for 90Hz or
# 120Hz, and silently reverts the config back to 60Hz if VOLUME DOWN
# isn't pressed within the timeout.
#
# Gating: reads preferred_refresh_hz straight off /proc/cmdline, since
# that's what the currently-running kernel actually booted with --
# more reliable than trusting the extlinux.conf file, which might have
# been hand-edited since the last boot without a reboot having
# happened yet.
#
# Input detection: evtest --query is a STATE check, not a blocking
# listener -- it inspects whether the given key is *currently held*
# at that instant and returns immediately (exit code 10 if active,
# 0 if not, matching evtest's query-mode convention used elsewhere for
# things like lid-switch checks in udev rules). To "watch for N
# seconds" this polls the state repeatedly rather than blocking on one
# call.
sudo chmod 666 /dev/tty1

set -uo pipefail
# Note: NOT using -e here. evtest --query exits non-zero (0 or 10) as
# its normal/expected result, not an error -- set -e would abort the
# script on the very first poll otherwise. Errors we do care about
# (e.g. the sed rewrite failing) are checked explicitly below instead.

CMDLINE_PARAM="panel_miniloong_pocket1.preferred_refresh_hz"
EXTLINUX_CONF="/boot/extlinux/extlinux.conf"   # adjust to your actual path
INPUT_DEVICE="/dev/input/event1"
CONFIRM_TIMEOUT=10                              # seconds
POLL_INTERVAL=0.2                               # seconds between polls (sleep parses this fine without bc)
MAX_POLLS=50                                    # CONFIRM_TIMEOUT / POLL_INTERVAL, computed by hand to avoid needing bc for the division
CONFIRM_FLAG="/tmp/.refresh_rate_confirmed"     # cleared each boot (tmpfs)
EVTEST_ACTIVE_EXIT_CODE=10

current_hz=$(grep -oP "${CMDLINE_PARAM}=\K\S+" /proc/cmdline 2>/dev/null || echo "60")

# --- Gate: only proceed if we're running at a non-default rate ---
if [ "${current_hz}" = "60" ]; then
	sudo systemctl disable firstboot
	sudo rm -- "$0"
	exit 0
fi

# Already confirmed earlier this boot (e.g. this script gets re-run by
# a frontend restart) -- don't nag twice per session.
if [ -f "${CONFIRM_FLAG}" ]; then
	sudo systemctl disable firstboot
	sudo rm -- "$0"
	exit 0
fi

revert_to_60hz() {
	echo "No confirmation received -- reverting to 60Hz and rebooting." 2>&1 > /dev/tty1
	if sudo sed -i \
		"s/${CMDLINE_PARAM}=[^ ]*/${CMDLINE_PARAM}=60/" \
		"${EXTLINUX_CONF}"; then
		sync
		sudo reboot
	else
		echo "ERROR: failed to rewrite ${EXTLINUX_CONF}; NOT rebooting." 2>&1 > /dev/tty1
		echo "Check the path/permissions and revert preferred_refresh_hz manually." 2>&1 > /dev/tty1
		exit 1
	fi
}

sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz

# --- Show the prompt ---
# Replace this block with however dArkOS actually renders on-screen text
# (a fbink/plymouth call, an SDL splash, whatever the frontend uses).
echo "Display is running at ${current_hz}Hz." 2>&1 > /dev/tty1
echo "Press VOLUME DOWN within ${CONFIRM_TIMEOUT} seconds to keep this setting." 2>&1 > /dev/tty1
echo "Otherwise it will revert to 60Hz automatically." 2>&1 > /dev/tty1

confirmed=false

for (( poll_count=0; poll_count<MAX_POLLS; poll_count++ )); do
	evtest --query "${INPUT_DEVICE}" EV_KEY KEY_VOLUMEDOWN
	rc=$?

	if [ "${rc}" -eq "${EVTEST_ACTIVE_EXIT_CODE}" ]; then
		confirmed=true
		break
	fi

	sleep "${POLL_INTERVAL}"
done

if [ "${confirmed}" = true ]; then
	echo "VOLUME DOWN detected -- keeping ${current_hz}Hz." 2>&1 > /dev/tty1
	touch "${CONFIRM_FLAG}"
	sudo systemctl disable firstboot
	sudo rm -- "$0"
	sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	exit 0
else
	sudo systemctl disable firstboot
	sudo rm -- "$0"
	revert_to_60hz
fi