<#
.Title
Enumerate windows shares using WMI and Powershell.
.Description
The script scans a subnet and if the host is online, it will attempt to enumerate the any shares using wmi.
.Instructions
Modify lines 16 and 17 to reflect the start and end ip address for the subnet. Modify line 20 to reflect the internal IP address subnet
.Disclaimer
This script is provided as is. WatchPoint and Nathan Studebaker is not responsible for use of the script, any modifications to the script, and any outcome from using this script.
.Author
Nathan Studebaker

#>
######################Beginning of script######################
#Use Test-Connection to ping sweep the entire subnet network. Modify the #$start, $end and $ip variables to match your network.
$start = 1
$end = 254
$start..$end | foreach {
#Modify the subnet address
$ip = "192.168.15.0" -replace "0$",$_
#Output status
Write-Host "Pinging $IP" -Foregroundcolor Cyan
$status = (Test-Connection $ip -Count 1 -Quiet)
$ErrorActionPreference = "silentlycontinue"
$Result = $null
 #Pass the IP address to .Net for DNS name resolution.
 $Result = [System.Net.Dns]::gethostentry($IP)

#Begin processing the results
#If the ping result is true then enumerate the shares. Optionally you can change #the bolded file name
If ($Result)
{
$MyResult = [string]$Result.HostName
write-Host "Resolved. Enumerating shares from $MyResult" -ForegroundColor Green
get-wmiobject win32_share -computer $ip | where {$_.name -NotLike "*$"} | sort-object -property path | select-object __server,Name,Path | export-csv .\wmi-server-shares-temp.csv -notypeinformation -encoding ASCII -force -Append
}

#If the ping result is false, don’t enumerate but export to a csv. Optionally you can #change the bolded file name.
Else
{
$MyResult = "unresolved"
Write-Host "Hostname for $IP $MyResult" -foregroundcolor Red
$ip | export-csv .\wmi-servers-not-resolved.csv -notypeinformation -encoding ASCII -force -Append
}

#UNCPath. Optionally you can change the bolded file name
$folder = import-csv .\wmi-server-shares-temp.csv | Select-Object -ExpandProperty Name
foreach ($i in $folder)
{
$uncpath = ForEach-Object {("\\"+$MyResult + "\" +$i)}
Write-Host "$uncpath"
import-csv .\wmi-server-shares-temp.csv | Select *, @{Name="UNCPath";Expression={$uncpath}} | export-csv .\wmi-server-shares.csv -Append -Force -NoTypeInformation
}
}
########################End of script#########################