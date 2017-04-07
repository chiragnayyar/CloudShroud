#!/bin/bash
echo ""
echo "*****************************************************************************" | fold -w 80
echo "                      !! Welcome to CloudShroud !!                      "
echo "*****************************************************************************" | fold -w 80
echo ""
greeting () {
echo "Let's get started! What would you like to do?"
echo "a) Create a new VPN connection to a partner"
echo "b) Modify an existing VPN connection"
echo "c) Delete an existing VPN connection"
echo "d) Directly access the CLI of a VPN endpoint (advanced)"
echo "e) Check for updates"
IFS= read -r -p "> " user_input
  }
greeting
user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]' | xargs)
	if [ "$user_input" == "a" ]
	then 
		echo "You want to create a new VPN with a partner. This setup wizard will take you through most of the common parameters needed to build a connection." | fold -w 80
		
		echo "Do you want to setup a 'policy-based' or 'route-based' VPN?"
		echo "a) Policy-based VPN"
		echo "b) Route-based VPN"
		echo "c) I have no clue. Help me out!"
		echo "d) Go back to last question."
		echo "e) Return to main menu"
		
		
		
		
		echo "b)Dynamic (BGP)"
				
				echo ""
				echo "*****************************************************************************" | fold -w 80
				echo "             PHASE 1 (aka. IKE or ISAKMP) Settings                           " | fold -w 80
				echo "*****************************************************************************" | fold -w 80
				
				echo "What is the public IP of the peer that you want to establish a VPN with?"
				echo "a) Enter IP"
				echo "b) Go back to last question
				
				echo ""
				echo "What version of IKE do you want to use?"
				echo "a) IKEv1 (most common)"
				echo "b) IKEv2"
				echo "c) I have no clue what to use. Help me out!"
				
					echo "What encryption strength do you want to use for phase 1?"
					echo "a) AES128"
					echo "b) AES192"
					echo "c) AES256"
					echo "d) 3DES"
					echo "e) I have no clue what to use. Help me out!"
					
						echo "What type of authentication do you want to use for phase 1?"
						echo "a) sha1"
						echo "b) sha256"
						echo "c) md5"
						echo "d) I have no clue what to use. Help me out!"

							 echo "What diffie-hellman group number do you want to use for phase 1? You can choose 2, 5, or anything between 14-26. You can also type \"H\" or \"help\" if you need help."
							 
									 
								   echo "Enter a preshared key (PSK) given to you by your partner, or generate a new one to give to your partner" | fold -w 80
								   echo "a) I have a PSK already"
								   echo "b) I need to generate a new PSK"
								   
				
				echo ""
				echo "*****************************************************************************" | fold -w 80
				echo "                     PHASE 2 (aka. IPSEC) Settings                           " | fold -w 80
				echo "*****************************************************************************" | fold -w 80
				
					echo "What encryption strength do you want to use for phase 2?"
					echo "a) AES128"
					echo "b) AES192"
					echo "c) AES256"
					echo "d) 3DES"
					echo "e) I have no clue what to use. Help me out!"
					
						echo "What type of authentication do you want to use for phase 2?"
						echo "a) sha1"
						echo "b) sha256"
						echo "c) sha512"
						echo "d) md5"
						echo "d) I have no clue what to use. Help me out!"
						
							echo "Do you want to enable Perfect Forward Secrecy (PFS) for this connection?"
							echo "a) Yes"
							echo "b) No"
							echo "c) I have no clue what to use. Help me out!"

							 echo "What diffie-hellman group number do you want to use for PFS? You can choose 2, 5, or anything between 14-26. You can also type \"H\" or \"help\" if you need help."
							 
								echo "Specify the network(s) behind the remote VPN peer that you want to communicate with over the tunnel. Separate networks by commas. For example \"172.17.0.0/24,10.0.0.0/16\" . You can also type \"H\" or \"help\" if you need help)."
							 

		
		
	elif [ "$user_input" == "b" ]
	then 
		echo "let's connect to the endpoints"
	elif [ "$user_input" == "c" ]
	then
		./update_endpoints
	else
		echo "oops, something isn't right..."
fi