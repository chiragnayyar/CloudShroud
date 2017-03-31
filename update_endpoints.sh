#!/bin/bash

# this script will setup the CloudShroud controlbox and VPN endpoints for the first time, and create necessary files.

# Retrieve the private and public IPs of the VPN endpoints based on their tag, name=value
cloudshrouda_private=$(aws ec2 describe-instances --region $MYREGION --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=CloudShroudEC2A" --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress[]' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

cloudshroudb_private=$(aws ec2 describe-instances --region $MYREGION --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=CloudShroudEC2B" --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress[]' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

cloudshrouda_public=$(aws ec2 describe-instances --region $MYREGION --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=CloudShroudEC2A" --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp[]' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

cloudshroudb_public=$(aws ec2 describe-instances --region $MYREGION --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=CloudShroudEC2B" --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp[]' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")

# Make sure CloudShroud subnet route table has IGW default route
aws ec2 create-route --region $MYREGION --route-table-id $MYROUTETABLE --destination-cidr-block 0.0.0.0/0 --gateway-id $MYIGW > /dev/null

# Function to check the OS version of VYos and update if needed.
function update_f () {

expect -c '
puts ""
puts "Checking if VPN endpoint '$2' needs to be updated..."

log_user 0
set timeout 2
spawn ssh -q -i .ssh/healthcheck.key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vyos@'$1' 

proc update_fun {} {
	puts "please wait, this may take a few minutes."
	puts "updating to latest version..."
	puts ""
send "\r"
expect "~$ "
set timeout 180
send "add system image http://packages.vyos.net/iso/release/1.1.7/vyos-1.1.7-amd64.iso\r"

expect "\[no\] "
send "yes\r"

expect ": "
send "\r"

expect ": "
send "\r"

expect ": "
send "\r"
	puts "Done!!"

expect "~$ "
send "exit\r"
	
	}

expect {
	timeout {puts "connection timed out"; exit}
	"connection refused" exit
	"unknown host" exit
	"no route" exit
	"~$ "
	}
send "show system image\r"

expect -re {.*VyOS-(\d+\.\d+\.\d+?)} {

set output $expect_out(1,string)
}

if {![info exists output]} {
	puts ""
	puts "Endpoint is out of date."
	set running [update_fun]

} elseif {$output == "1.1.7"} {
	puts ""
	puts "Endpoint is up to date with VYos version $output"
	
} else {
	puts ""
	puts "Endpoint is out of date."
	set running [update_fun]
}
'
}

# Function to create SSH keys between CloudShroud controlbox and VPN endpoints.
function replace_key_f {
	cat .ssh/healthcheck.key.pub | ssh -i .ssh/healthcheck.key -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vyos@$1 'sudo cat - >> healthcheck.key.pub'
	}

# Function to make the SSH public keys permanent on the Vyos VPN endpoints so that they persist through reboot.	
function make_key_perm_f {
 
expect -c '
log_user 0
set timeout 2
spawn ssh -q -i .ssh/healthcheck.key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vyos@'$1'
expect {
	timeout {puts "connection timed out"; exit}
	"connection refused" exit
	"unknown host" exit
	"no route" exit
	"~$ "
	}
send "mv healthcheck.key.pub .ssh/healthcheck.key.pub\r"

expect "~$ "
send "configure\r"

expect "# "
send "loadkey vyos .ssh/healthcheck.key.pub\r"

expect "# "
send "commit\r"

expect "# "
send "save\r"

expect "# "
send "exit\r"

expect "~$ "
send "exit\r"
'
}

# Function to check that SSH key exists or create if non-existent. Then it proceeds forward to check VYos update status
function ssh_keys_f {
	if [ -f ".ssh/healthcheck.key" ]
	then 
		update_f $cloudshrouda_private $cloudshrouda_public
		update_f $cloudshroudb_private $cloudshroudb_public
	else
		ssh-keygen -t rsa -b 1024 -N "" -f .ssh/healthcheck.key >> /dev/null
		replace_key_f $cloudshrouda_private
		replace_key_f $cloudshroudb_private
		make_key_perm_f $cloudshrouda_private
		make_key_perm_f $cloudshroudb_private
		update_f $cloudshrouda_private $cloudshrouda_public
		update_f $cloudshroudb_private $cloudshroudb_public
	fi
}
if [ -f ".ssh/healthcheck.key" ]
then 
    echo "SSH keys between controlbox and VPN endpoints have been created."
	ssh_keys_f 
else

# Check if SSH agent-forwarding is enabled. This is required for initial CloudShroud setup.
	if [[ $(ssh-add -l) =~ 2048 ]]
		then
				echo "SSH Agent Forwarder enabled."
				echo "continuing with setup...."
				ssh_keys_f 
		
		else
				echo ""
				printf "You do not have SSH agent forwarding enabled. Please enable this feature on your\n Windows or Mac client machine and add your EC2's private key to the forwarder\n prior to running CloudShroud initial setup.\n (TIP: Google 'setting up ssh agent forwarding')\n"
				echo ""
				exit 0

		fi
fi