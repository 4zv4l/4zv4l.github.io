#!/usr/bin/env bash


get_config() {

	NM_conf_path="/etc/NetworkManager/NetworkManager.conf"
	NM_conf_backend=$(/usr/bin/crudini --get /etc/NetworkManager/NetworkManager.conf device wifi.backend 2>/dev/null)
	STATUS_NM=$?

	NM_confd_path="/etc/NetworkManager/conf.d/wifi.backend.conf"
	NM_confd_backend=$(/usr/bin/crudini --get /etc/NetworkManager/conf.d/wifi.backend.conf device wifi.backend 2>/dev/null)
	STATUS_NMD=$?

	if [ $STATUS_NM -eq 0 ]
	        then

		echo "$NM_conf_backend $NM_conf_path"

	elif [ -f  /etc/NetworkManager/conf.d/wifi.backend.conf ]
		then
		if [ $STATUS_NMD -eq 0 ]
	        then
			echo "$NM_confd_backend $NM_confd_path"
		else
			echo "not_configured"
		fi
	else
		echo "not_configured"
	fi
}



show_config(){
	if [ "$1" == "not_configured" ]
	then echo "The backend is not configured, so Networkmanager will default to wpa_supplicant"
	else echo "The backend is $1 and its is set in $2"
	fi
}

set_backend(){
	#Arguments: $1 wanted backend, $2 existing backend (or not_configured), $3 existing config path

	if [ "$EUID" -ne 0 ]
		then echo "Please run as root as such modifications need more privilege"
	exit
		fi


if ! [ -x /usr/bin/crudini ]
	then apt install crudini
fi
	case $1 in
		wpa_supplicant)
		BACKEND=wpa_supplicant;;
		iwd)
		BACKEND=iwd;;
		*)
		echo "Backend can be either wpa_supplicant or iwd. Other values are not accepted. Sorry not sorry."
		exit 1;;
	esac
	# Possible improvement: cleanly remove data accordingly to $2 $3 (existing config)
	# For now on, I bruteforce it by deleting configs even if not existing, and touch'ing file even when it already exists
	/usr/bin/crudini --del /etc/NetworkManager/conf.d/wifi.backend.conf device wifi.backend
	/usr/bin/crudini --del /etc/NetworkManager/NetworkManager.conf device wifi.backend
	touch /etc/NetworkManager/conf.d/wifi.backend.conf
	/usr/bin/crudini --set /etc/NetworkManager/conf.d/wifi.backend.conf device wifi.backend	$BACKEND
	/usr/bin/crudini --set /etc/iwd/main.conf Settings AutoConnect True

	dirnetplan="/etc/netplan"
	echo "Backing up ${dirnetplan} as VPN or personnal wifi info could be stored here"

	rsync -a ${dirnetplan}/ ${dirnetplan}.bak.$(date +"%Y-%m-%d-%H-%M-%S")

	# Not sure whether we should delete all /etc/NetworkManager/system-connections/ or /etc/netplan/*.yaml
	# So I decided to remove only the Wifis with "Odoo-" in their name.
	# We could also be more aggresive and rm -r /etc/netplan/*)



	if [ $(ls ${dirnetplan}/* -l 2>/dev/null | wc -l) -gt 0 ]
		then
			rm -r ${dirnetplan}/*
		else
			echo "No netplan files to delete - so not deleting anything"
	fi

	echo "Forgetting all wifi networks on NetworkManager side"

	nmcli -t -f TYPE,UUID,NAME con | grep "802-11-wireless" | cut --delimiter ":" --fields 2 | xargs -n 1 -I % nmcli connection delete %

	if [ "$BACKEND" == "iwd" ]
	then
		if ! [ -x /usr/libexec/iwd ]
			then
				echo "iwd was not installed yet. Installing it"
				apt install iwd -y
		fi
		systemctl mask wpa_supplicant.service --now
		systemctl unmask iwd.service
		if ! dpkg -s iwd > /dev/null 2>&1;
			then apt install iwd.service
		systemctl enable iwd.service --now
		systemctl restart NetworkManager.service
		fi

	else
		systemctl mask iwd.service --now
		systemctl unmask wpa_supplicant.service
		systemctl enable wpa_supplicant.service --now
		systemctl restart NetworkManager

	fi

	echo "$1 set up as wifi backend. You might need to re-enter wifi password for previously known networks"
	request_reboot
}

show_help() {
	echo "Usage: $(basename $0) [OPTIONS]"
	echo "Options:"
	echo "  -h, --help	Displays this help message"
	echo "  -b, --backend	Sets a backend. Argument can be either iwd or wpa_supplicant"
	echo "  -s, --show	Displays the currently used backend"
	exit 0
}

request_reboot() {

	echo 'Change have been made and you should probably reboot the computer. Reboot now? (y/n)'
	read RESPONSE
	if [[ "$RESPONSE" =~ ^[Yy]$  ]]
		then reboot
        else
		echo "OK, won't reboot the system right now. But don't forget to do it yourself at some point!"
	fi
}


case $1 in
	-h | --help)
	show_help;;
	-s | --show)
	show_config $(get_config);;
	-b | --backend)
	set_backend $2 $(get_config);;
	*)
	echo "Unknown argument"
	show_help;;
esac
