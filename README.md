# CloudShroud
CloudShroud is a helper template in Cloudformation which will launch a Strongswan server in your VPC, and automate many of the tasks for setting up a VPN.
The goal of this project is to simplify the process of setting up a custom VPN endpoint as much as possible while still affording great flexibility and
features.

# Unique Features
- Automatic support for IKEv1 or IKEv2 without further configuration by user
- Optional choice of Policy-based or Route-based VPN with ease of a switch
- Dynamic NAT or 1:1 NAT over IPSEC
- Automatic support for most IKEv1 or IKEv2 ciphers without further configuration by user. See complete list of ciphers here:
  IKEv1 https://wiki.strongswan.org/projects/strongswan/wiki/IKEv1CipherSuites
  IKEv2 https://wiki.strongswan.org/projects/strongswan/wiki/IKEv2CipherSuites 
- Other parameters which are normally manually configured, are automatically handled (ie. phase1 and phase2 lifetimes)
- VPC route table routes and Security Groups are automatically configured to allow onprem traffic from VPN tunnel

# Setup Instructions
1) Copy the 'CloudShroud_template.json' template above to your local computer
2) Log into your AWS management console, and go to the "CloudFormation" service page
3) 
