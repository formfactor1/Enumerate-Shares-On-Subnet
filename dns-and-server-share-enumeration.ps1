#ping sweep the network
$start = 200
$end = 206
$start..$end | foreach {
$ip = "192.168.15.0" -replace "0$",$_
Write-Host "Pinging $IP" -Foregroundcolor Cyan
$status = (Test-Connection $ip -Count 1 -Quiet)

$ErrorActionPreference = "silentlycontinue"
$Result = $null

# Pass the IP to .Net for name resolution.

$Result = [System.Net.Dns]::gethostentry($IP)

# process the results

If ($Result)
{
$MyResult = [string]$Result.HostName
write-Host "Resolved. Enumerating shares from $MyResult" -ForegroundColor Green
cmd /C net view $hostname >> .\ping-sweep-server-shares2.txt
}
Else
{
$MyResult = "unresolved"
Write-Host "Hostname for $IP $MyResult" -foregroundcolor Red
$ip >> .\ping-sweep-servers-no-response.csv 
}

# Send it to the output

#$MyResult
}