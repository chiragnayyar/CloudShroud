# CloudShroud
CloudShroud is a helper template in Cloudformation which will launch a Strongswan server in your VPC, and automate many of the tasks for setting up a VPN.
The goal of this project is to simplify the process of setting up a custom VPN endpoint as much as possible while still affording great flexibility and
features.

# Unique Features
- Support for most IKEv1 and IKEv2 ciphers. 
- 1:1 or Dynamic NAT over IPSEC
- Support for policy-based and route-based VPN
- Easy automation of necessary Security Group and VPC route table entries

# Current Limitations
- Template can only be use to create a single tunnel to a single remote site
- CloudShroud launches a single Strongswan EC2 (no high-availability)

# Short-term feature additions
- Tunnel monitoring through Cloudwatch
- Strongswan EC2 failure detection and automatic recovery
- Log push to S3
- Create multiple site VPNs through Cloudformation parameter updates

# Long-term feature additions
- High-availability Strongswan clustering for active/active or active/pass tunnel failover
- Routing options over HA tunnels: Equal-cost multi-pathing, stateful session tracking, round-robin load balancing

# Stack Launch Instructions
1) Copy the 'CloudShroud_template.json' template above to your local computer
2) Log into your AWS management console, and go to the "CloudFormation" service page
3) Click "Create New Stack", and browse to the 'CloudShroud_template.json' on your local computer
4) On the next page you will fill out parameters for your VPN. Note that some sections are optional (and marked as so)


# Parameter Descriptions
Most of the parameters are self-explanatory, but there are a few that deserve a little extra comment:
- 


# Stack Deletion Instructions
***VERY IMPORTANT***
The Strongswan EC2 runs cleanup scripts everytime that the server is stopped. BE SURE TO STOP the ec2 prior to deleting your Cloudformation stack. This will ensure that the EC2 has enough time to remove all created Security Group and VPC route table dependencies before the EC2 itself is terminated during stack deletion.

If you don't stop the EC2 prior to stack deletion it can cause the stack to hang and you will manually have to remove Security Group and VPC route table entries.



