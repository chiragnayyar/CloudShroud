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
  }
greeting_f
user_input=$(echo "$user_answer" | tr '[:upper:]' '[:lower:]' | xargs)
	if [ "$user_input" == "a" ]
	then 
		echo "You want to create a new VPN with a partner. This setup wizard will take you through most of the common parameters needed to build a connection." | fold -w 80	
		echo "Do you want to setup a 'policy-based' or 'route-based' VPN?"
		echo "a) Policy-based VPN"
		echo "b) Route-based VPN"
		echo "c) I have no clue. Help me out!"
		echo "d) Go back to last question."
		echo "e) Return to main menu"
		
				
echo ""
echo "*****************************************************************************" | fold -w 80
echo "             PHASE 1 (aka. IKE or ISAKMP) Settings                           " | fold -w 80
echo "*****************************************************************************" | fold -w 80


pub_peer_ip_f () {
	echo ""
	echo "What is the public IP of the peer that you want to establish a VPN with? (You can also type \"main\" to go back to the main menu)" | fold -w 80
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
	echo "What version of IKE do you want to use?"
	echo "a) IKEv1 (most common)"
	echo "b) IKEv2"
	echo "c) What is this?"
	echo "d) Go back to previous question"
	echo "e) Go back to main menu"
IFS= read -r -p "> " ike_version
ike_version=$(echo "$ike_version" | xargs)

# create the menu options array
declare -A ike_version_options=( ["a"]="ikev1" ["b"]="ikev2" ) 

# Check user answer
if [ "$ike_version" == "a" ] || [ "$ike_version" == "b" ]
then
	ike_version=${ike_version_options[$ike_version]}
	echo "Setting $ike_version as the version for this VPN..."
elif [ "$ike_version" == "c" ]
then
	echo ""
	cat /etc/cloudshroud/descriptions/ikeversion_description | fold -w 80
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



		
	elif [ "$user_input" == "b" ]
	then 
		echo "let's connect to the endpoints"
	elif [ "$user_input" == "c" ]
	then
		./update_endpoints
	else
		echo "oops, something isn't right..."
fi