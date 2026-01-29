#!/bin/bash

event_num="3"
event_type="EV_KEY"
event_btn_a="BTN_EAST"
event_btn_b="BTN_SOUTH"
event_btn_x="BTN_NORTH"
event_btn_y="BTN_WEST"
event_btn_r1="BTN_TR"
event_btn_r2="BTN_TR2"
event_btn_l1="BTN_TL"
event_btn_l2="BTN_TL2"
event_btn_hk="BTN_MODE"

if [[ -e "/dev/input/by-path/platform-fe5b0000.i2c-event" ]]; then
  event_num="4"
elif [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  event_btn_b="BTN_EAST"
  event_btn_a="BTN_SOUTH"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]] \
     || [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] \
     || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-joystick" ]]; then
  event_num="2"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  event_num=`ls -l /dev/input/by-path/platform-singleadc-joypad-event-joystick | awk '{print $11}' | cut -b 9`
  if [[ -e "/home/ark/.config/.DEVICE" ]]; then
    if [ "$(cat /home/ark/.config/.DEVICE)" == "RG503" ] \
       || [ "$(cat /home/ark/.config/.DEVICE)" == "RGB30" ] \
       || [ "$(cat /home/ark/.config/.DEVICE)" == "RK2023" ]; then
      event_btn_hk="BTN_THUMBR"
    fi
  fi
fi

function Test_Button_A(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_a
}

function Test_Button_B(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_b
}

function Test_Button_X(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_x
}

function Test_Button_Y(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_y
}

function Test_Button_HK(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_hk
}

function Test_Button_R1(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_r1
}

function Test_Button_R2(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_r2
}

function Test_Button_L1(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_l1
}

function Test_Button_L2(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_l2
}
