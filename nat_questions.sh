#!/bin/bash

MAC_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
VPC_NET=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$MAC_ADDRESS"/subnet-ipv4-cidr-block)

nat_host_or_net_f () {
	echo ""
	echo "Do you have only individual host IPs that need to be NAT'd or your entire VPC network (ie. 10.0.0.0/24)? "
	echo "a) Individual Host IPs"
	echo "b) Entire VPC network"
	echo "c) What's the difference?"
	echo "d) Go back to previous question"
	echo "e) Go back to main menu"
IFS= read -r -p "> " nat_host_or_net
nat_host_or_net=$(echo "$nat_host_or_net" | tr '[:upper:]' '[:lower:]')

	# check user answer
	if [ "$nat_host_or_net" == "a" ]
	then
		local_actual_host_f () {
		echo ""
		echo "A host IP in your VPC that needs to be NAT'd"
			IFS= read -r -p "> " local_actual_host
			local_actual_host=$(echo "$local_actual_host" | xargs)
				if [[ "$local_actual_host" =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]
				then
					local_actual_host=$local_actual_host
				elif [[ "$local_actual_host" =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|[1-2][0-9]|3[0-2])$ ]]
				then
					echo "It looks like you are trying to NAT a network block instead of host. Please choose the a host IP (in format x.x.x.x)"
					nat_host_or_net_f
				else
					echo "Please choose a valid host IP"
					local_actual_host_f
				fi
				}
				local_actual_host_f
		
	elif [ "$nat_host_or_net" == "b" ]
	then 
		local_actual_net_f () {

		[[ "$VPC_NET" =~ /([0-9]|[1-2][0-9]|3[0-2]) ]]
		vpc_mask=$(echo ${BASH_REMATCH[1]})
		
		echo ""
		echo "Note: when NAT'ing your VPC, the NAT network host bits will be identical to the host bits of your actual VPC network during translation. For example, a host in your VPC that is assigned an actual address of x.x.x.40 will translate to y.y.y.40. For this reason you will want to use a NAT network mask which is the SAME as your VPC network mask (ie. /$vpc_mask)"
		echo ""
		echo "It looks like your actual VPC network is $VPC_NET. What network do you want to NAT your VPC to for this VPN?"
			IFS= read -r -p "> " local_actual_net
			local_actual_net=$(echo "$local_actual_net" | xargs)
			
			if [[ "$local_actual_net" =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/([0-9]|[1-2][0-9]|3[0-2])$ ]] && [ "$local_actual_net" != "$VPC_NET" ]
			then				
				[[ "$local_actual_net" =~ /([0-9]|[1-2][0-9]|3[0-2]) ]]
				nat_mask=$(echo ${BASH_REMATCH[1]})				
				if [ "$nat_mask" == "$vpc_mask" ] 
				then
					local_actual_net=$local_actual_net
				elif [[ "$local_actual_net" =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ ]]
				then
					echo "It looks like you are trying to NAT a single host rather than a network. Please choose the a valid network (in format x.x.x.x/x)"
					nat_host_or_net_f
				else
					echo "Please choose a valid NAT network with the same mask as your VPC (/$vpc_mask)"
					local_actual_net_f
				fi
				
			else
				echo "Please choose a valid /$vpc_mask network which is NOT the same as your VPC network"
				local_actual_net_f
			fi
			}
			local_actual_net_f
		
		
	elif [ "$nat_host_or_net" == "c" ] 
	then
		echo ""
		cat /etc/cloudshroud/descriptions/nat_host_or_net_description
		nat_host_or_net_f
	elif [ "$nat_host_or_net" == "d" ]
	then
		routing_type_f
		nat_questions_f
	elif [ "$nat_host_or_net" == "e" ]
	then
		body_f
	else
		echo "Please choose a valid option"
		nat_host_or_net_f
	fi
}
nat_host_or_net_f
					