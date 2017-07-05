#!powershell
#
# WANT_JSON
# POWERSHELL_COMMON

# This module attempts to provide a feature parity on Windows as the lineinfile module
# provides for *nix-based hosts
$params = Parse-Args $args

# dest
$dest = Get-Attr $params "dest" $FALSE
If ($dest -eq $FALSE){
  Fail-Json (New-Object psobject) "missing required argument; dest"
}

# state
$state = Get-Attr $params "state" $FALSE
If ($state -eq $FALSE) {
  $state = "present"
}
ElIf ($state -ne "absent"){
  Fail-Json (New-Object psobject) "invalid value for argument; state"
}

$line = Get-Attr $params "line" $FALSE
If ($line -eq $FALSE){
  If ($state -eq "present"){
    Fail-Json (New-Object psobject) "missing required argument; line"
  }
}

$regexp = Get-Attr $params "regexp" $FALSE


$changed=$false
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$md5orig = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($dest)))

If ($state -eq "present"){
  If ($regexp -ne $FALSE){
    (Get-Content ($dest)) | Foreach-Object {$_ -replace $regexp, ($line)} | Set-Content  ($dest)
  }
  # TODO any other options
} Else {
  # state -eq absent
  if( $regexp -ne $FALSE){
    (Get-Content ($dest)) | Where-Object {$_ -notmatch $regexp} | Set-Content  ($dest)
  }
}

$md5new = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($dest)))
$result = New-Object psobject @{
    changed = $md5orig.CompareTo($md5new)
};

Exit-Json $result;
