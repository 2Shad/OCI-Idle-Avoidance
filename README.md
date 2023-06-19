## OCI-Idle-Avoidance
A set of scripts designed to maintain a minimum level of CPU usage on Oracle Cloud VMs, preventing them from being reclaimed due to idling. Ideal for environments with fluctuating resource demands.

### Overview
This repository contains scripts to help maintain a minimum level of CPU usage on a virtual machine (VM) to prevent Oracle Cloud Infrastructure (OCI) from shutting it down due to idling. This is in response to a policy change in OCI where VMs can be reclaimed if they idle for a certain period.

The scripts work by monitoring the CPU usage and spinning up "load generator" Python scripts to consume CPU cycles when usage drops below a certain level. If a user's VM is running services that require a lot of resources at times and idles at other times, this script will ensure that the CPU usage stays above the OCI threshold, ensuring the VM remains active even during idle times.

### Structure
This repository contains two scripts: 
1. A Bash script (`load_controller.sh`): This script continuously monitors the CPU usage and spins up "load generator" Python scripts when the CPU usage drops below 15%. It also manages the load generators, stopping them when CPU usage is above 20%, and stopping all of them when CPU usage is above 80%. The script makes sure the CPU load stays within a reasonable range, giving more important tasks the resources they need while ensuring the VM doesn't fall into the idle state. 

2. A Python script (`load_generator.py`): This script runs a loop that consumes CPU cycles. The number of cycles consumed per second can be configured by adjusting the argument passed to the script.

## Requirements

This script requires:

1. Python 3.x
2. `sysstat` package

The Python 3.x is a requirement for running the `load_generator.py` script that generates load on the CPU.

The `sysstat` package is used to gather system statistics, specifically CPU usage. It includes the `mpstat` command which we use in our shell script to monitor CPU usage.

To install these:

**Python 3.x:**

Python 3 is usually preinstalled in most Linux distributions. If not, you can install it using your system's package manager. For example, on Ubuntu, you can install it via:

```
sudo apt-get install python3
```

**sysstat:**

You can install the `sysstat` package using your system's package manager. For example, on Ubuntu, you can install it via:

```
sudo apt-get install sysstat
```

### How to Use
Before running the script, ensure it has the necessary permissions to execute:

```bash
chmod +x load_controller.sh
```

To run the script, it is recommended to use a tool like `screen` which allows you to run the script in the background while you go about your day. 

First, start a new `screen` session:

```bash
screen
```

Then, run the script:

```bash
./load_controller.sh
```

You can now leave the script running in the background by detaching from the `screen` session. To do this, press `Ctrl + A` and then `D`. Now you can move on with your day, with the assurance that your VM is busy working away!

When you want to stop the script, you can reattach to the `screen` session:

```bash
screen -r
```

Then, stop the script by pressing `Ctrl + C`. This will also stop all running load generators. Finally, exit the `screen` session:

```bash
exit
```

Remember, a busy VM is a happy VM! Happy computing!
