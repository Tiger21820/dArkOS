#!/bin/bash

function get_refresh() {
   grep -oP 'panel_miniloong_pocket1\.preferred_refresh_hz=\K\S+' /boot/extlinux/extlinux.conf
}

function set_refresh() {
   if test ! -z "${1}"
   then
     sudo sed -i "s/panel_miniloong_pocket1\.preferred_refresh_hz=[^ ]*/panel_miniloong_pocket1.preferred_refresh_hz=${1}/" /boot/extlinux/extlinux.conf
   fi
}

cmd=${1}
shift
$cmd "$1" "$2"

exit 0