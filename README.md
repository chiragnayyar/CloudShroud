[![CloudShroud Tutorial](https://s3-us-west-2.amazonaws.com/cloudshroud/Screen+Shot+2017-07-24+at+2.24.53+PM.png)](https://youtu.be/syA0ElQFw9Q)

### Video Quickview
Time [00:00](https://youtu.be/syA0ElQFw9Q?t=0m0s) Intro to CloudShroud and Key Features<br />
Time [04:20](https://youtu.be/syA0ElQFw9Q?t=4m20s) How to launch a CloudShroud stack<br />
Time [05:00](https://youtu.be/syA0ElQFw9Q?t=5m) Discussion about available parameters and options<br />
Time [15:36](https://youtu.be/syA0ElQFw9Q?t=15m36s) How to NAT your VPC over VPN<br />
Time [21:57](https://youtu.be/syA0ElQFw9Q?t=21m57s) How to automate a VPN setup to another VPC<br />
Time [25:55](https://youtu.be/syA0ElQFw9Q?t=25m55s) Post stack deployment checklist<br />
Time [29:01](https://youtu.be/syA0ElQFw9Q?t=29m1s) How VPC Auto Config works<br />
Time [32:02](https://youtu.be/syA0ElQFw9Q?t=32m2s) How SSH into your \*swan EC2<br />




# CloudShroud
CloudShroud is a helper template for Cloudformation which will launch a (Open|Strong)swan server in your VPC depending on your custom requirements, and automate many of the tasks for setting up a VPN. 

The goal of this project is to simplify the process of setting up a custom VPN endpoint as much as possible while still affording great flexibility and
features.

## Launch Instructions
1) Click here 
<a href="https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=CloudShroud&templateURL=https://s3-us-west-2.amazonaws.com/cloudshroud/cloudshroud.json"><img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png"/></a>
2) Ensure that you are in the AWS Region that you want to deploy in, and click *_Next_*

## Stack Termination Instructions
**_VERY IMPORTANT!!_**
The (Open|Strong)swan EC2 runs cleanup scripts everytime that the server is stopped. BE SURE TO STOP the ec2 prior to deleting your Cloudformation stack. This will ensure that the EC2 has enough time to remove all created Security Group and VPC route table dependencies before the EC2 itself is terminated during stack deletion.

If you don't stop the EC2 prior to stack deletion it can cause the stack to hang and you will manually have to remove Security Group and VPC route table entries.

Also, if you have a lot of Security Groups and/or VPC route tables with a lot of entries, the scripts may take a while to complete.

I'm currently looking at a better cleanup system.

## Unique Features
- Support for most IKEv1 and IKEv2 ciphers. 
- 1:1 or Dynamic NAT over IPSEC
- Support for policy-based and route-based VPN
- Easy automation of necessary Security Group and VPC route table entries

## Current Limitations
- Template can only be use to create a single tunnel to a single remote site
- CloudShroud launches a single (Open|Strong)swan EC2 (no high-availability)
- Does not support BGP

## Short-term feature additions
- Tunnel monitoring through Cloudwatch
- (Open|Strong)swan EC2 failure detection and automatic recovery
- Log push to S3
- Create multiple site VPNs through Cloudformation parameter updates

## Long-term feature additions
- High-availability (Open|Strong)swan clustering for active/active or active/pass tunnel failover
- Routing options over HA tunnels: Equal-cost multi-pathing, stateful session tracking, round-robin load balancing

## Input Parameters Explained
Most of the parameters during initial stack deployment are self-explanatory, but there are a few advanced that deserve additional elaboration.

#### **_VPC Auto Config_**:
You can choose 'True' in the dropdown if you want CloudShroud to automatically update your local VPC route table(s) and Security Group(s) with the appropriate entries to allow full-open communication between your local VPC and the remote network. If you choose false then you will need to update the route table(s) and SG(s) manually.

#### **_VPN to Remote VPC_**:
This option can be used if you want to establish a VPN to an AWS Virtual Private Gateway (VGW) that is attached to another VPC. Simply specify the vgw ID (vgw-xxxxxxxx) that you want to connect to, and CloudShroud will create the tunnel and bring it up.

If you specify 'Custom' in this field, ALL subsequent input parameters in the template will be evaluated and used to create your VPN. If you specify a vgw ID in this field instead, ALL other subsequent parameters will be IGNORED except for *_Remote Network_* and *_Local NAT_*

#### **_VPN Routing Type_**: 
There are two very common VPN implementations, route-based and policy-based. Firewalls that use route-based VPN rely on virtual tunnel interfaces and a local route table as its VPN traffic selectors, whereas a firewall that uses policy-based VPN does not require creating a virtual tunnel interface and uses policy definitions as its traffic selectors. Check with your remote peer to see which type of firewall device they are using. You will notice that there are some firewall presets available (ie cisco-asa, cisco-ios).

It's also important to note that if you choose a RouteType of 'policy-based' (or a firewall preset that uses policy-based, such as the cisco-asa) *AND* IKEversion 'ikev1', CloudShroud will launch an Openswan server rather than Strongswan. Strongswan is used for any other implementations including IKEv1/IKEv2 route-based or IKEv2 policy-based VPN. Openswan seems to handle multiple child SAs with IKEv1 better than Strongswan, hence the exception.

#### **Local NAT Host(s) or Network**: 
You can choose to NAT your entire VPC (ie. VPC actual 10.0.0.0/16 --> VPC nat 172.16.0.0/16, etc) OR you can do a 1:1 NAT of individual IPs in your VPC. If you choose to do the latter you will need to specify each 'real' host IP in your VPC followed by the corresponding IP that you want to NAT it to. You can do this for as many hosts as you want (ie. HOST, NATIP, HOST, NATIP, etc) .

You CANNOT combine NAT networks *_ NAT_* individual hosts - it's one or the other. Either specify a single NAT CIDR that you want your VPC translated to OR specify a comma delimited list of HOST, NATIPs.

It's important to note that if you choose to NAT your VPC, you use a NAT CIDR that is the same network mask of your VPC or longer. Also, you should not choose a NAT CIDR or NAT IPs that are specified in the *LAN(s) behind remote VPN peer* parameter. If you do it can cause confusion in the VPN traffic selectors.

#### **Local/Remote VTI IPs**:
These IPs are only relevant if the remote peer's firewall is using route-based VPN, and you are NOT connecting to a VGW. You can leave these IP settings alone unless your peer partner specifically requests that they are changed to avoid conflict.

## Swan EC2 Access and Commands
After launching the CloudShroud template, and it completes deployment you can SSH directly into the (Open|Strong)swan EC2 using the keypair that you specified during initial deployment. You can find the public IP of the EC2 under the *outputs* tab of the Cloudformation stack details

This public IP will be used to SSH into the server as well the IP that your remote partner will use to establish the VPN with your AWS VPC.

#### To SSH into your swan EC2
sudo ssh -i MyPrivateKey.pem ec2-user@\<PUBLIC IP OF SWAN EC2\><br />

#### Helpful server commands
- To restart the VPN service<br />
(strongswan) sudo strongswan restart<br />
(openswan) sudo service ipsec restart<br />

- To see general phase1/phase2 VPN debug<br />
(strongswan) sudo strongswan statusall<br />
(openswan) sudo ipsec auto --status<br />

- To see child SAs that formed between the peers (for both strongswan and openswan)<br />
sudo ip xfrm state<br />

- Further debug info<br />
sudo tail /var/log/secure<br />
sudo tail /var/log/messages<br />

- File Locations<br />
Most of the files specifically related to CloudShroud can be found in /etc/cloudshroud/. This includes the (open|strong)swan conf file and secrets file as well as the dependent variables file.

The cleanup script that runs at boot/stop/reboot can be found in /etc/init.d/cloudshroud-cleanup. This is responsible to add SG and VPC route table entries so that your EC2 can communicate with the onprem. It will remove the entries at shutdown so that you don't manually have to do this before possible stack termination.
