# XuanWu
XuanWu is a lightweight defense script designed for Linux servers that integrates ipset and iptables to provide a dynamic layer of security. By analyzing server access logs for suspiciously high-frequency IP requests—potential indicators of DDoS and CC attacks—XuanWu temporarily restricts these risky IPs, automatically restoring access after a set period to maintain server accessibility.

Additionally, XuanWu allows configuration based on specific request parameters and user-agent strings, helping to block unwanted bots and spam crawlers that consume server resources and degrade performance. This script strives to mitigate excessive and malicious traffic, preserving system stability and optimizing resource usage.

# How to Install ipset in Linux

To install `ipset` on a Linux system, you can follow these steps depending on your Linux distribution:

## For Debian/Ubuntu-based Distributions

1. **Update the package list**:
   ```bash
   sudo apt update

2. **Install ipset:**
    ```bash
   sudo apt install ipset

## For CentOS/RHEL-based Distributions

1. **Install the EPEL repository (if not already installed):**:
   ```bash
   sudo yum install epel-release

2. **Install ipset:**
    ```bash
   sudo yum install ipset

## For Fedora

1. **Install ipset:**
    ```bash
   sudo dnf install ipset

## For Arch Linux

1. **Install ipset:**
    ```bash
   sudo pacman -S ipset

# How to Install iptables in Linux

`iptables` is typically pre-installed on most Linux distributions. However, if you need to install or reinstall it,
follow the instructions below based on your Linux distribution.

## For Debian/Ubuntu-based Distributions

1. **Update the package listL:**
   ```bash
   sudo apt update

2. **Install iptables:**
    ```bash
   sudo apt install iptables

## For CentOS/RHEL-based Distributions

1. **Install iptables:**
    ```bash
   sudo yum install iptables

## Verify Installation

After installation, you can verify that iptables is installed correctly by checking its version:

```bash
iptables --version
```

## Note

iptables is often installed by default on many systems. You can check if it is already installed by running iptables
--version.
Ensure that you have the necessary permissions to install packages (usually requires root or sudo access).
