#!/bin/bash

echo ""
echo "*****************************************************************************" | fold -w 80
echo "                      !! Welcome to CloudShroud !!                      "
echo "*****************************************************************************" | fold -w 80
echo ""
greeting_f () {
	echo ""
	echo "Let's get started! What would you like to do?"
	echo "a) Create a new VPN connection to a partner"
	echo "b) Modify an existing VPN connection"
	echo "c) Delete an existing VPN connection"
	echo "d) Directly access the CLI of a VPN endpoint (advanced)"
	echo "e) Check for updates"
IFS= read -r -p "> " user_answer

user_input=$(echo "$user_answer" | tr '[:upper:]' '[:lower:]' | xargs)
if [ "$user_input" == "a" ]
then new_vpn_name_f () {
	echo ""
	echo "Give your new VPN a meaningful name that will help you easily identify it (Max32 characters which include lower/upper case A-Z and/or digits). You can also type the word \"main\" to go back to the main menu." | fold -w 80
	IFS= read -r -p "> " new_vpn_name
	new_vpn_name=$(echo "$new_vpn_name" | xargs)
	
	if [[ "$new_vpn_name" =~ ^[a-zA-Z0-9]{1,32}$ ]] && [ "$(echo $new_vpn_name | tr '[:upper:]' '[:lower:]' | xargs)" != "main" ]
	then
		echo ""
		echo "$new_vpn_name will be the name of this VPN..."
	elif [ "$(echo $new_vpn_name | tr '[:upper:]' '[:lower:]' | xargs)" == "main" ]
	then 
		greeting_f
	else
		echo "Invalid name: Please ensure the name is no less than 1 character, no more than 32, and is only using lower/upper case A-Z and/or digits"
		new_vpn_name_f
	fi
	}
	new_vpn_name_f
				
echo ""
echo "*****************************************************************************" | fold -w 80
echo "             PHASE 1 (aka. IKE or ISAKMP) Settings                           " | fold -w 80
echo "*****************************************************************************" | fold -w 80


pub_peer_ip_f () {
	echo ""
	echo "What is the public IP of the peer that you want to establish a VPN with (in the form xx.xx.xx.xx) ? You can also type \"main\" to go back to the main menu" | fold -w 80
IFS= read -r -p "> " peer_pub_ip
peer_pub_ip=$(echo "$peer_pub_ip" | xargs)

if [[ $peer_pub_ip =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]
  then
	echo "Setting $peer_pub_ip as the IP of the remote VPN peer..."
  elif [ "$peer_pub_ip" == "main" ]
  then
	greeting_f
  else
	echo "Please enter a valid IP"
	pub_peer_ip_f
fi
}
pub_peer_ip_f

ike_version_f () {
	echo ""
	echo "What version of IKE do you want to use? Hit ENTER to use the default"
	echo "a) IKEv1 (default)"
	echo "b) IKEv2"
	echo "c) What is this?"
	echo "d) Go back to previous question"
	echo "e) Go back to main menu"
IFS= read -r -p "> " ike_version
ike_version=$(echo "$ike_version" | tr '[:upper:]' '[:lower:]')

# create the menu options array
declare -A ike_version_options=( ["a"]="ikev1" ["b"]="ikev2" ) 

# Check user answer
if [ "$(echo $ike_version | xargs)" == "a" ] || [ "$(echo $ike_version | xargs)" == "b" ]
then
	ike_version=${ike_version_options["$(echo $ike_version | xargs)"]}
	echo ""
	echo "Setting $ike_version as the version for this VPN..."
	
elif [ "$(echo $ike_version)" = "" ]
then	
    echo "Setting IKEv1 as the version for this VPN..."
	ike_version=ikev1

elif [ "$ike_version" == "c" ]
then
	echo ""
	sudo cat /etc/cloudshroud/descriptions/ikeversion_description | fold -w 80
	ike_version_f

elif [ "$ike_version" == "d" ] 
then 
	pub_peer_ip_f

elif [ "$ike_version" == "e" ]
then 
    greeting_f
else
   echo "Please choose a valid option"
   ike_version_f
fi
}
ike_version_f









		
	elif [ "$user_input" == "c" ]
	then 
		echo "boo"
	elif [ "$user_input" == "e" ]
	then
		. /etc/cloudshroud/update_endpoints.sh
	else
		echo "oops, something isn't right..."
fi
}
greeting_f