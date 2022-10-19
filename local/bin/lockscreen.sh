#!/bin/bash

dunstctl set-paused true
sleep 0.1
betterlockscreen --wall
dunstctl set-paused false
