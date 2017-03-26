#!/bin/bash

# this script will setup the VPN controller box for the first time, and create necessary files.
target="192.168.11.126"

function update_f {

expect -c '
puts ""
puts "Checking VPN endpoint versions..."

log_user 0
spawn ssh -q -i healthcheck.key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vyos@'$target' 
set timeout 2

proc update_fun {} {
	puts "please wait,this make take a few minutes."
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
expect "~$ "
send "show system image\r"

expect -re {.*VyOS-(\d+\.\d+\.\d+?)} {

set output $expect_out(1,string)
}

if {![info exists output]} {
	puts ""
	puts "Vyos is out of date."
	set running [update_fun]

} elseif {$output == "1.1.7"} {
	puts ""
	puts "Vyos is up to date with version $output"
	
} else {
	puts ""
	puts "Vyos is out of date."
	set running [update_fun]
}
'
}

function ssh_keys_f {
	if [ -f "healthcheck.key" ]
	then 
		update_f
	else
		ssh-keygen -t rsa -b 1024 -N "" -f healthcheck.key >> /dev/null
		cat healthcheck.key.pub | ssh -i healthcheck.key -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vyos@$target 'sudo cat - >> .ssh/authorized_keys'
		update_f
	fi
}
if [ -f "healthcheck.key" ]
then 
	ssh_keys_f 
else

	if [[ $(ssh-add -l) =~ .*has\ +no\ +identities\. ]]
		then
				echo ""
				printf "You have not enabled 'ssh agent fowarding' on your client machine.\nThis is needed in order to properly update CloudShroud.\nPlease enable this and try again.\n"
				echo ""
				exit 0
		else
				echo "SSH Agent Forwarder enabled."
				echo "continuing with setup...."
				ssh_keys_f 
		fi
fi