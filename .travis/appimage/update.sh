#!/bin/bash

$APPDIR/usr/bin/zenity --question --timeout=10 --title="PCSX2 updater" --text="New update available. Update now?" --icon-name=PCSX2 --window-icon=PCSX2.svg --height=80 --width=400
answer=$?

if [ "$answer" -eq 0 ]; then 
	export LD_PRELOAD="$APPDIR/usr/lib/updater/libcurl.so.4"
	$APPDIR/usr/bin/AppImageUpdate $PWD/PCSX2-x86_64.AppImage && $PWD/PCSX2-x86_64.AppImage
elif [ "$answer" -eq 1 ]; then
	$APPDIR/AppRun-patched
elif [ "$answer" -eq 5 ]; then
	$APPDIR/AppRun-patched
fi
exit 0
