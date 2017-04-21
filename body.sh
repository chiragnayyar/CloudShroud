#!/bin/bash

echo ""
echo "*****************************************************************************" 
echo "                      !! Welcome to CloudShroud !!                      "
echo "*****************************************************************************" 
echo ""
body_f () {
	echo ""
	echo "Let's get started! What would you like to do?"
	echo "a) Create a new VPN connection to a partner"
	echo "b) Modify an existing VPN connection"
	echo "c) Delete an existing VPN connection"
	echo "d) Directly access the CLI of a VPN endpoint (advanced)"
	echo "e) Check for updates"
	echo "f) Go to controlbox CLI"
IFS= read -r -p "> " user_answer

user_input=$(echo "$user_answer" | tr '[:upper:]' '[:lower:]' | xargs)

# Check to make sure the initial setup has been completed
if [ "$(cat /etc/cloudshroud/.initial_setup)" == "1" ]
		then 

		if [ "$user_input" == "a" ]
				then new_vpn_name_f () {
					echo ""
					echo "Give your new VPN a meaningful name that will help you easily identify it (Max32 characters which include lower/upper case A-Z and/or digits). You can also type the word \"main\" to go back to the main menu."
					IFS= read -r -p "> " new_vpn_name
					new_vpn_name=$(echo "$new_vpn_name" | xargs)
					
					if [[ "$new_vpn_name" =~ ^[a-zA-Z0-9]{1,32}$ ]] && [ "$(echo $new_vpn_name | tr '[:upper:]' '[:lower:]' | xargs)" != "main" ]
					then
						echo ""
						echo "$new_vpn_name will be the name of this VPN..."
					elif [ "$(echo $new_vpn_name | tr '[:upper:]' '[:lower:]' | xargs)" == "main" ]
					then 
						body_f
					else
						echo "Invalid name: Please ensure the name is 1-32 characters, and is only using lower/upper case A-Z and/or digits"
						new_vpn_name_f
					fi
		
			}		
	
								
				echo ""
				echo "*****************************************************************************" 
				echo "             PHASE 1 (aka. IKE or ISAKMP) Settings                           " 
				echo "*****************************************************************************" 


				pub_peer_ip_f () {
					echo ""
					echo "What is the public IP of the peer that you want to establish a VPN with (in the form x.x.x.x)? You can also type \"main\" to go back to the main menu"
				IFS= read -r -p "> " peer_pub_ip
				peer_pub_ip=$(echo "$peer_pub_ip" | xargs)

				if [[ $peer_pub_ip =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]
				  then
					echo ""
					echo "Setting $peer_pub_ip as the IP of the remote VPN peer..."
				  elif [ "$peer_pub_ip" == "main" ]
				  then
					body_f
				  else
					echo "Please enter a valid IP"
					pub_peer_ip_f
				fi
			}	
	

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
					echo ""
					echo "Setting ikev1 as the version for this VPN..."
					ike_version=ikev1

				elif [ "$ike_version" == "c" ]
				then
					echo ""
					sudo cat /etc/cloudshroud/descriptions/ikeversion_description 
					ike_version_f

				elif [ "$ike_version" == "d" ] 
				then 
					pub_peer_ip_f
					ike_version_f

				elif [ "$ike_version" == "e" ]
				then 
					body_f
				else
				   echo "Please choose a valid option"
				   ike_version_f
				fi
			}	
	

				ike_encrypt_f () {
					echo ""
					echo "What encryption strength do you want to use for phase 1? Hit ENTER to use the default"
					echo "a) AES128 (default)"
					echo "b) AES192"
					echo "c) AES256"
					echo "d) 3DES"
					echo "e) What is this?"
					echo "f) Go back to previous question"
				    echo "g) Go back to main menu"
				IFS= read -r -p "> " ike_encrypt
				ike_encrypt=$(echo "$ike_encrypt" | tr '[:upper:]' '[:lower:]')
				
				# create the menu options array
				declare -A ike_encrypt_options=( ["a"]="aes128" ["b"]="aes192" ["c"]="aes256" ["d"]="3des" )
				
				# check user answer
				if [ "$(echo $ike_encrypt | xargs)" == "a" ] || [ "$(echo $ike_encrypt | xargs)" == "b" ] || [ "$(echo $ike_encrypt | xargs)" == "c" ] || [ "$(echo $ike_encrypt | xargs)" == "d" ]
				then 
					ike_encrypt=${ike_encrypt_options["$(echo $ike_encrypt| xargs)"]}
					echo ""
					echo "Setting $ike_encrypt as the encryption for this VPN..."
				elif [ "$(echo $ike_encrypt)" = "" ]
				then
					echo ""
					echo "Setting aes128 as the encryption for this VPN..."
					ike_encrypt=aes128
				elif [ "$ike_encrypt" == "e" ]
				then
					echo ""
					sudo cat /etc/cloudshroud/descriptions/ikeencrypt_description
					ike_encrypt_f

				elif [ "$ike_encrypt" == "f" ] 
				then 
					ike_version_f
					ike_encrypt_f

				elif [ "$ike_encrypt" == "g" ]
				then 
					body_f
				else
				   echo "Please choose a valid option"
				   ike_encrypt_f
				fi
			}
	
				
				ike_auth_f () {
				    echo ""
					echo "What type of authentication do you want to use for phase 1?"
					echo "a) SHA1 (default)"
					echo "b) SHA256"
					echo "c) MD5"
					echo "d) What is this?"
					echo "e) Go back to previous question"
					echo "f) Go back to main menu"
				IFS= read -r -p "> " ike_auth
				ike_auth=$(echo "$ike_auth" | tr '[:upper:]' '[:lower:]')
				
				# create the menu options array
				declare -A ike_auth_options=( ["a"]="sha1" ["b"]="sha256" ["c"]="md5" )
				
				# check user answer
				if [ "$(echo $ike_auth | xargs)" == "a" ] || [ "$(echo $ike_auth | xargs)" == "b" ] || [ "$(echo $ike_auth | xargs)" == "c" ]
				then 
					ike_auth=${ike_auth_options["$(echo $ike_auth| xargs)"]}
					echo ""
					echo "Setting $ike_auth as the authentication for this VPN..."
				elif [ "$(echo $ike_auth)" = "" ]
				then
					echo ""
					echo "Setting sha1 as the encryption for this VPN..."
					ike_auth=sha1
				elif [ "$ike_auth" == "d" ] 
				then 
					echo ""
					sudo cat /etc/cloudshroud/descriptions/ikeauth_description
					ike_auth_f

				elif [ "$ike_auth" == "e" ]
				then 
					ike_encrypt_f
					ike_auth_f
				elif [ "ike_auth" == "f" ]
				then
					body_f
				else
				   echo "Please choose a valid option"
				   ike_auth_f
				fi
			}
	
				
				ike_dh_f () {
					 echo ""
					 echo "What DH group number do you want to use for phase 1? You can type 2, 5, or any number between 14-26, OR you can hit ENTER to use default (DH group 2). "
					 echo "a) What is this?"
					 echo "b) Go back to previous question"
					 echo "c) Go back to main menu"
 				IFS= read -r -p "> " ike_dh
				ike_dh=$(echo "$ike_dh" | tr '[:upper:]' '[:lower:]')
				
				
				# check user answer
				if [[ $(echo $ike_dh) =~ ^(2|5|1[4-9]|2[0-6])$ ]]
				then 
					ike_dh=$(echo "$ike_dh" | xargs)
					echo ""
					echo "Setting $ike_dh as the IKE DH group for this VPN..."
				elif [ "$(echo $ike_dh)" = "" ]
				then
					echo ""
					echo "Setting DH group 2 as the encryption for this VPN..."
					ike_dh="2"
				elif [ "$ike_dh" == "a" ] 
				then 
					echo ""
					sudo cat /etc/cloudshroud/descriptions/ikedh_description
					ike_dh_f

				elif [ "$ike_dh" == "b" ]
				then 
					ike_auth_f
					ike_dh_f
				elif [ "$ike_dh" == "c" ]
				then
					body_f
				else
				   echo "Please choose a valid option"
				   ike_dh_f
				fi
			}
				
				ike_psk_f () {
				   echo ""
				   echo "You will need to specify a Preshared Key for this connection (10-32 alphanumberic characters). Please choose one of the following options"
				   echo "a) I already have a PSK that I want use"
				   echo "b) I need to generate a new PSK"
				   echo "c) What is this?"
				   echo "e) Go back to previous question"
				   echo "f) Go back to main menu"
				IFS= read -r -p "> " ike_psk
				ike_psk=$(echo "$ike_psk" | tr '[:upper:]' '[:lower:]' | xargs)

				# check user answer
				if [ "$(echo $ike_psk)" == "a" ]
				then 
				enter_psk_f () {
					echo ""
					echo "Please enter the preshared Key, or type \"goback\" to go back to the previous menu options"
					IFS= read -r -p "> " ike_enter
					ike_enter=$(echo "$ike_enter" | tr '[:upper:]' '[:lower:]' | xargs)
					  if [ "$(echo ike_enter)" == "goback" ]
					   then 
					      ike_psk_f
						  enter_psk_f
					   elif [[ "$(echo ike_enter)" =~ ([a-zA-Z0-9]{10,32}) ]]
					   then
						  echo "$ike_enter will be used as the Preshared Key for both tunnels of this VPN"
					   else 
						  echo ""
					      echo "Please choose an Preshared Key made of 10-32 alphanumeric characters"
						  enter_psk_f 
					  fi
					}
					enter_psk_f
					
				elif [ "$(echo $ike_psk)" == "b" ]
				then
					ike_psk=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
					echo ""
					echo "$ike_psk will be used as the Preshared Key for both tunnels of this VPN"
				elif [ "$ike_psk" == "c" ]				
				then 
					echo ""
					sudo cat /etc/cloudshroud/descriptions/ikepsk_description
					ike_psk_f

				elif [ "$ike_psk" == "e" ]a
				then 
					ike_dh_f
					ike_psk_f
				elif [ "$ike_psk" == "f" ]
				then
					body_f
				else
				   echo "Please choose a valid option"
				   ike_psk_f
				fi
			}
				
				
				

			
			
	
	new_vpn_name_f			
	pub_peer_ip_f
	ike_version_f
	ike_encrypt_f
	ike_auth_f
	ike_dh_f
	ike_psk_f

				
				
				
				
				
				
				
		elif [ "$user_input" == "c" ]
		then 
			echo "boo"
		elif [ "$user_input" == "e" ]
		then
			. /etc/cloudshroud/update_endpoints.sh
		elif [ "$user_input" == "f" ]
		then
			bash
		else
			echo "oops, something isn't right..."
	fi


elif [ "$(cat /etc/cloudshroud/.initial_setup)" == "0" ] && [ "$user_input" == "e" ]
then
	. /etc/cloudshroud/update_endpoints.sh
elif [ "$(cat /etc/cloudshroud/.initial_setup)" == "0" ] && [ "$user_input" == "f" ]
then
	bash
	
else
	echo "You must choose 'e) Check for updates' to complete initial setup of CloudShroud before you can do anything else"
	body_f
fi
}
body_f