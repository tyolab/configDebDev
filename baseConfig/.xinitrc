#!/bin/bash



## Taken from Lane Aasen's Github on configs ##
#set up terminus (and other) fonts
xset +fp /usr/share/fonts/local
xset fp rehash

#prepare xmonad
xrdb -merge ~/.Xresources

# Set the cursor to the standard pointer, pointing to top left corner.
xsetroot -cursor_name left_ptr

# Start Virtualbox Gues Additions with screen resizing and clipboard support
VBoxClient --clipboard
VBoxClient --display


# For now DWM will be launched
#dwm

# Sets a background image for us!
feh --bg-fill  ~/.xmonad/jewel-joehesus.jpg

xmonad	
