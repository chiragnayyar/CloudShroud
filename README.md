# CloudShroud
CloudShroud is a helper template in Cloudformation which will launch a Strongswan server in your VPC, and automate many of the tasks for setting up a VPN.
The goal of this project is to simplify the process of setting up a custom VPN endpoint as much as possible while still affording great flexibility and
features.

## Unique Features
- Support for most IKEv1 and IKEv2 ciphers. 
- 1:1 or Dynamic NAT over IPSEC
- Support for policy-based and route-based VPN
- Easy automation of necessary Security Group and VPC route table entries

## Current Limitations
- Template can only be use to create a single tunnel to a single remote site
- CloudShroud launches a single Strongswan EC2 (no high-availability)

## Short-term feature additions
- Tunnel monitoring through Cloudwatch
- Strongswan EC2 failure detection and automatic recovery
- Log push to S3
- Create multiple site VPNs through Cloudformation parameter updates

## Long-term feature additions
- High-availability Strongswan clustering for active/active or active/pass tunnel failover
- Routing options over HA tunnels: Equal-cost multi-pathing, stateful session tracking, round-robin load balancing

## Stack Launch Instructions
1) Copy the 'CloudShroud_template.json' template above to your local computer
2) Log into your AWS management console, and go to the "CloudFormation" service page
3) Click "Create New Stack", and browse to the 'CloudShroud_template.json' on your local computer
4) On the next page you will fill out parameters for your VPN. Note that some sections are optional (and marked as so)

## Stack Deletion Instructions
**_VERY IMPORTANT!!_**
The Strongswan EC2 runs cleanup scripts everytime that the server is stopped. BE SURE TO STOP the ec2 prior to deleting your Cloudformation stack. This will ensure that the EC2 has enough time to remove all created Security Group and VPC route table dependencies before the EC2 itself is terminated during stack deletion.

If you don't stop the EC2 prior to stack deletion it can cause the stack to hang and you will manually have to remove Security Group and VPC route table entries.

Also, if you have a lot of Security Groups and/or VPC route tables with a lot of entries, the scripts may take a while to complete.

I'm currently looking at a better cleanup system.

## Advanced Settings and Caveats
Most of the parameters during initial stack deployment are self-explanatory, but there are a few advanced settings that deserve additional elaboration
### **VPN Routing Type**: 
There are two very common VPN implementations which are route-based and policy-based. Firewalls that use route-based VPN rely on virtual tunnel interfaces and a local route table as its VPN traffic selectors, whereas a firewall that uses policy-based VPN does not require creating a virtual tunnel interface and uses policy definitions as its traffic selectors. Check with your remote peer to see which type of device they are using. You will notice that there are some presets available (ie CiscoASA, CiscoIOS), but these are still experimental for now.

### **Local NAT Host(s) or Network**: 
You can choose to NAT your entire VPC (ie. VPC actual 10.0.0.0/16 --> VPC nat 172.16.0.0/16, etc) OR you can do a 1:1 NAT of individual IPs in your VPC. If you choose to do the latter you will need to specify each 'real' host IP in your VPC followed by the corresponding IP that you want to NAT it to. You can do this for as many hosts as you want (ie. HOST, NATIP, HOST, NATIP, etc) .

You CANNOT combine NAT'ing networks AND NAT'ing individual hosts - it's one or the other. Either specify a single NAT CIDR that you want your VPC translated to OR specify a comma delimited list of HOST, NATIPs.

It's important to note that if you choose to NAT your VPC, you use a NAT CIDR that is the same network mask of your VPC or longer. Also, you should not choose a NAT CIDR or NAT IPs that are specified in the *LAN(s) behind remote VPN peer* parameter. If you do it can cause confusion in the VPN traffic selectors.

### **Local/Remote VTI IPs**:
These IPs are only relevant to the remote peer if their firewall is using route-based VPN. You can leave these IP settings alone unless your peer partner specifically requests that they are changed to avoid conflict.



