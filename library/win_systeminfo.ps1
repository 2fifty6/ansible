#!powershell
#
# WANT_JSON
# POWERSHELL_COMMON

# This is basically like facter for Windows
$data = Get-CimInstance Win32_OperatingSystem

$result = New-Object psobject @{
    changed = $false
    data = $data
};

Exit-Json $result;
