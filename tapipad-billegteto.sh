#!/bin/sh
#	Created by Volarics Istvan by Voli

#:::::: Fix beallitasok :::::::
#:::::: Beallitasok :::::::::::
#:::::: Fuggvenyek ::::::::::::
#:::::::: Start :::::::::::::::

    Id=$( xinput --list |grep "Touch.ad" |grep "DELL" |sed 's/.*id=//; s/[ \t].*$//; ' )

    Enable=$( xinput --list-props $Id |grep "Device Enabled" |sed 's/.*\([01]\+$\)/\1/ ' )

    case "$Enable" in
	    0)	xinput --enable  $Id
	    ;;
	    1)	xinput --disable $Id
	    ;;
	    *)
		echo TapiPad ID=${Id}, Állapot=${Enable}...
    esac
