#!/bin/sh
# Created by Voli; volaricsi@volarics.hu

ListUsers(){
    loginctl  list-users|grep -v -e "UID" -e "users listed." -e "^$"|sed 's/^ *[0-9]\+ *//g; '
}


grep -q close /proc/acpi/button/lid/*/state
    if [ $? = 0 ]; then
	for user in $( ListUsers ) ; do
	    su -c  "xset -display :0.0 dpms force off" - $user
	done
fi

grep -q open /proc/acpi/button/lid/*/state
    if [ $? = 0 ]; then
	for user in $( ListUsers ) ; do
	    su -c  "xset -display :0 dpms force on" - $user
	done
fi