#!/bin/bash
# server-stats.sh
# Script to analyse basic server performance stats

echo "================ Server Performance Stats ================"

# Uptime, OS version, Load average
echo "Hostname         : $(hostname)"
echo "OS Version       : $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo "Kernel Version   : $(uname -r)"
echo "Uptime           : $(uptime -p)"
echo "Load Average     : $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Logged-in Users  : $(who | wc -l)"
echo

# CPU Usage
cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
cpu_usage=$(echo "100 - $cpu_idle" | bc)
echo "Total CPU Usage  : $cpu_usage%"

# Memory Usage
mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_free=$(free -m | awk '/Mem:/ {print $4}')
mem_percent=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')
echo "Total Memory     : ${mem_total} MB"
echo "Used Memory      : ${mem_used} MB"
echo "Free Memory      : ${mem_free} MB"
echo "Memory Usage     : $mem_percent%"
echo

# Disk Usage
echo "Disk Usage:"
df -h --total | grep "total" | awk '{print "  Used: "$3 " / Total: "$2 " (Free: "$4 ", Usage: "$5 ")"}'
echo

# Top 5 processes by CPU
echo "Top 5 Processes by CPU Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
echo

# Top 5 processes by Memory
echo "Top 5 Processes by Memory Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6
echo

# Stretch goal: failed login attempts (Debian/Ubuntu systems)
if [ -f /var/log/auth.log ]; then
    echo "Failed Login Attempts (last 10):"
    grep "Failed password" /var/log/auth.log | tail -n 10
elif [ -f /var/log/secure ]; then
    echo "Failed Login Attempts (last 10):"
    grep "Failed password" /var/log/secure | tail -n 10
else
    echo "Failed Login Attempts: Log file not found"
fi

echo "=========================================================="

