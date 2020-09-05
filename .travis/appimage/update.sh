#!/bin/bash

if [ -f /usr/bin/zenity ]; then
	zenity --question --timeout=10 --title="PCSX2 updater" --text="New update available. Update now?" --icon-name=PCSX2 --window-icon=PCSX2.svg --height=80 --width=400
else
	dialog --title PCSX2 --timeout 10 --yesno "New update available. Update now?" 0 0
fi
	
answer=$?

if [ "$answer" -eq 0 ]; then 
	export LD_PRELOAD="$APPDIR/usr/lib/updater/libcurl.so.4"
	$APPDIR/usr/bin/AppImageUpdate $PWD/PCSX2-x86_64.AppImage && $PWD/PCSX2-x86_64.AppImage
elif [ "$answer" -eq 1 ]; then
	$APPDIR/AppRun-patched
else 
	$APPDIR/AppRun-patched
fi
exit 0
