# CloudShroud
CloudShroud is a helper template in Cloudformation which will launch a Strongswan server in your VPC, and automate many of the tasks for setting up a VPN.
The goal of this project is to simplify the process of setting up a custom VPN endpoint as much as possible while still affording great flexibility and
features.

# Unique Features
- Automatic support for IKEv1 or IKEv2 without further configuration by user
- Policy-based or Route-based VPN implementations
- Dynamic or 1:1 NAT over IPSEC
- Automatic support for most IKEv1 or IKEv2 ciphers without further configuration by user
- Other parameters which are normally manually configured, are automatically handled (ie. phase1 and phase2 lifetimes)

# Setup Instructions
1) Log into your AWS management console, and go to the "CloudFormation" service page
2) Create a new 
