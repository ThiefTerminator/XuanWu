# XuanWu
XuanWu is a lightweight defense script designed for Linux servers that integrates ipset and iptables to provide a dynamic layer of security. By analyzing server access logs for suspiciously high-frequency IP requests—potential indicators of DDoS and CC attacks—XuanWu temporarily restricts these risky IPs, automatically restoring access after a set period to maintain server accessibility.

Additionally, XuanWu allows configuration based on specific request parameters and user-agent strings, helping to block unwanted bots and spam crawlers that consume server resources and degrade performance. This script strives to mitigate excessive and malicious traffic, preserving system stability and optimizing resource usage.
