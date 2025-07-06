#!/usr/bin/env bash
{
for l_pam_file in system-auth password-auth; do
l_authselect_file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$l_pam_file"
sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+even_deny_root)(.*$)/\1\4/' "$l_authselect_file"
sed -ri 's/(^\s*auth\s+(.*)\s+pam_faillock\.so.*)(\s+root_unlock_time\s*=\s*\S+)(.*$)/\1\4/' "$l_authselect_file"
done
authselect apply-changes
}