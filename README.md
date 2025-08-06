# Red Hat Linux 9 Family

It is recommended to click the star at the top right of this repository to stay updated and remain in contact for any future issues or updates.

## Ansible roles for Red Hat Linux 9 Family hardening and audit

Please read the following instruction before perfmorming the installation or configuration

## Overview

This project contains ansible roles that can be used for hardening or auditing a machine with Red Hat Linux 9 Family System (Rocky 9, CentOS Stream 9, RHEL 9).
If you have found any errors in the script or you have any suggestions on how to improve it, please send an email to maciek.serek.ms@gmail.com

## Ansible

Ansible is an open source software tool that provides simple but powerful automation for cross-platform computer support. Ansible does not depend on agent software and has no additional security infrastruture.

## CIS
CIS - Center for Information Security is an independent, non-profit organization with a mission to provide a secure online experience for all. With major data breaches being reporte all too frequently, organizations are now placing increased ephasis on the security of personal, private, and sensitive information. 
https://www.cisecurity.org/

## Red Hat Linux 9 Family
Continuously delivered distro that tracks just ahead of Red Hat Enterprise Linux (RHEL) development, positioned as a midstream between Fedora Linux and RHEL. For anyone interested in participating and collaborating in the RHEL ecosystem, CentOS Stream is your reliable platform for innovation.
https://www.centos.org/centos-stream/

## Software and benchmark versions

This script was made based on these versions:
Ansible version: 2.16.8
CentOS Stream version 9
Rocky Linux 9
RHEL 9
CIS Benchmark versions:
- Red Hat Enterprise Linux v2.0.0
- Rocky Linux 9 v2.0.0

## Installation and Configuration

1. Go to the directory where ansible is installed.
2. Clone GitLab repository to your local machine. 
3. Adjust ansible configuration file -> ansible.cfg.

ex.
```
inventory -> location of the inventory file
stdout_callback -> type of plugin
remote_port -> sets the default SSH port on all of your systems
remote_user -> this is the default username ansible will connect as for /usr/bin/ansible-playbook
log_path -> ansible will log information about executions at the designated location
private_key_file -> path to your private key
ACTION_WARNINGS -> generates a warning when received from a task action
ssh_args -> a specific set of options to ansible
control_path -> this is the location to save ControlPath sockets
pipelining -> method of speeding up your ssh connections
```

4. Go into Inventory and modify hosts.yml file to your needs

```
<name of the host group>
  hosts:
    <name of the host 1>:
	  ansible_host: <address>
	<name of the host 2>:
	  ansible_host: <address>
	<name of the host 3>:
	  ansible_host: <address>
```

ex.
```
all:
  hosts:
    audit_host: 
      ansible_host: localhost
    hardening_host: 
      ansible_host: localhost
```

Then ensure the playbook you are running (playbooks/hardening.yml by default) is configured to run the hosts you added to the inventory.
By default the hardening.yml playbook uses the 'host: hardening_hosts' option, which in the default inventory will run on a single machine.

If you want to run the script on multiple machines, change the host option in the playbook to the name of the group you created in the inventory, that will make the script run on all of the hosts in that group. 


5. In the "defaults" folder within the role folder you will find the "main.yml" file.
It contains configuration of the ansible script. Editing it will allow you to customize the hardening/auditing process.

The first section contains credentials for the user created by the script. By default this task is disabled. 
It is not recommended to run the script with the 'root' user, as the script will block ssh access via the 'root' user.
If you still want to run the script as root, you should change the 'create_user' variable to 'true', in order to create a sudo user and not lose ssh access to the machine.
Please remember to change the credentials, if you decide to use them. 
```
create_user: false
uusername: randomuser
upassword: 'randompassword'

```

Next section allows you to skip whole sections of the CIS benchmark. If you want to harden/audit your system, but don't want to run the whole script this allows you to quickly skip parts of it.
```
section_1: true
section_2: true
section_3: true
section_4: true
section_5: true
section_6: true
```

In the next section you can turn on/off every individual rule in the CIS benchmark, allowing you for greater customization of what you want to be hardened.
```
rule_1_1_1_1: true # 
rule_1_1_1_2: true # 
rule_1_1_1_3: true # 
...
rule_6_2_14: true #
rule_6_2_15: true #
rule_6_2_16: true # 
```


Last sections allows you to edit individual variables used within the benchmark rules such as SELinux policy or the ntp server.
Before running the script you should make sure to go over those variables and edit them accordingly to your needs.

Make sure to edit or check the following:
- Edit all passwords in the configuration file
- Choose time synchronization daemon
- Choose firewall (firewalld by default)
- Choose logging module (rsyslog by default)
- Configure sshd to allow or block certain users/groups
- Selinux policy (Permissive | Enforcing)
- Do you want to block user account after being inactive? (rule 5.6.1.4)
- Do you want the system to shutdown when there is not enough disk space left for audit logs? (rule 4.1.2.3)
- If you are using an Openstack machine and you don't want to use firewall on it, simply change the firewall to none.


6. Before running the script make sure to install required ansible modules
```
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
```

7. 
If you want to audit your machine, execute playbook audit.yml
```
ansible-playbook playbooks/audit.yml -kK --become
```
If you want to harden your machine, execute playbook hardening.yml
```
ansible-playbook playbooks/hardening.yml -kK --become
```

Command options used:
-K: ask for privilege escalation password
-k: ask for connection password
--become: run operations with become (does not imply password prompting)

If you are using a machine that requires a key for SSH connection instead of password, you can just run the playbook with '--key-file <PRIVATE_KEY_FILE>' option.

```
ansible-playbook playbooks/audit.yml -K --become --key-file <PRIVATE_KEY_FILE>
```

You still need to pass the password needed for privilege escalation, as one of the tasks(5.3.4) in the script will force the use of password for use of sudo.
If you do not have password on your user before running the script with that task(5.3.4) active, it will cause you to lose access to sudo and will cause the script to crash.



8. Every task in the script is tagged, you can use those tags to skip tasks with certain tags or run only tasks with certain tasks.
To run tasks with a tag use option --tags "<list,of,tags>"
To skip tasks with a certain tags use --skip-tags "<list,of,tags>"
List of relevant tags:
    - level1_workstation
    - level1_server
	- level2_workstation
    - level2_server
	
Each task is also tagged with it's number from CIS Benchmark as well as the section of the benchmark it is from. So you can use it to run/skip only a certain task/section. 
Section tags: s1,s2,s3,s4,s5,s6
Rule number tags look as follow: r<rule.number> eq. "r4.2.1.3" 

By default, all tasks are executed so if you want to run a level2 profile, you can just run the script without any tags.
If you want to run the script at profile level 1 you can either run the script with the '--tags "level1_server"' or '--skip-tags "level2_server"' options.



## Manual rules

Not all rules and recommendations from the Benchmark are covered by the script and need to be configured manually.
The script will run a check to see if those are configured but it will not change the configuration.

- 1.1.1.9 Ensure unused filesystems kernel modules are not available
- Rules: 1.1.2-1.1.7 involve creating and configuring separate partitions for certain folders such as /var, /home etc.
- Rules from section 1.2 
- 1.3.1.6 Ensure no unconfined services exist
- 1.4.1 Ensure bootloader password is set
- 1.6.1.6 Ensure no unconfined services exist
- 1.6.6 Ensure system wide crypto policy disables chacha20-poly1305 for ssh
- 1.6.7 Ensure system wide crypto policy disables EtM for ssh
- 2.1.22 Ensure only approved services are listening on a network interface
- 3.1.1 Ensure IPv6 status is identified 
- 4.2.1 Ensure firewalld drops unnecessary services and ports
- 4.3.2 Ensure nftables established connections are configured
- 5.1.7 Ensure sshd access is configured 
- 5.3.3.2.3 Ensure password complexity is configured
- 5.4.1.1 Ensure password expiration is configured
- 5.4.1.2 Ensure minimum password days is configured 
- 5.4.1.5 Ensure inactive password lock is configured
- 6.2.1.2 Ensure journald log file access is configured
- 6.2.1.3 Ensure journald log file rotation is configured
- 6.2.2.1.2 Ensure systemd-journal-upload authentication is configured
- 6.2.3.5 Ensure rsyslog logging is configured 
- 6.2.3.6 Ensure rsyslog is configured to send logs to a remote log host
- 6.2.3.8 Ensure rsyslog logrotate is configured 
- 6.3.3.21 Ensure the running and on disk configuration is the same
- 7.1.13 Ensure SUID and SGID files are reviewed
***

