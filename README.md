# openswan

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openswan](#setup)
    * [What openswan affects](#what-openswan-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openswan](#beginning-with-openswan)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module allows for an easy VPN server configuration.
This is especially useful for mobile devices, it works out-of-the-box with iOS and OSX.

## Module Description

The module installs a server, which you can also configure through the module.
Furthermore, users can be added directly with their respective passwords.

## Setup

### What openswan affects

* OpenSWAN
* Sysctl
* Iptables
* ppp

### Beginning with openswan

Just install the module and call it, just set the IP and gateway of your server and define a secret.
Next you can use the users class to add any user to the system

## Usage

````puppet
class { 'openswan': ip => $::ipaddress_eth0, gateway => '111.222.33.44', secret => 'somerandomstring', range => 100, block => 2 }
````

This creates an openswan server on the IP of `eth0` with the specified gatewy (since facter cannot determine the gateway, you will have to provide it yourself).
Additionally a random string is defined.
The block and range combination yield the VPN ip's to be in the range of `192.168.100.1`-`192.168.100.250`.
If you'd like to use the `10.x.x.x` range, provide `block => 1` instead.
This will yield an VPN ip range o f`10.100.100.1`-`10.100.100.250`.

Fair word of warning: the range you specify here should not be in use on any of the NAT layers you may be connecting through, or the VPN cannot be built!
Hence if your internal home network uses `192.168.178.x`, you cannot use this range.
Because of this reason, the module defaults to the `10.112.112.1`-`10.112.112.250` range (I have not seen this one in use so decided it was a safe bet).

## Development

In case you have any suggestions or problems, please create an issue directly on Github.
https://github.com/rogierslag/rogierslag-openswan/issues
