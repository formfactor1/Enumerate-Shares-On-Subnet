<#
.Title
Enumerate windows server shares using active directory and ping.
.Description
The script imports server active directory objects, then pings them and if online, enumerates the share using net view
.Instructions
Run as an administrator on a domain controller. Modify line 30 to control where the results file is output.
.Disclaimer
This script is provided as is. WatchPoint and Nathan Studebaker is not responsible for use of the script, any modifications to the script, and any outcome from using this script.
.Author
Nathan Studebaker

#>
#Import AD module requirement
Import-Module ActiveDirectory

#Search AD for 'Windows Server' operating system. Any member or dc will have this description automatically 
$wservers = Get-ADComputer -Filter {OperatingSystem -Like '*Server*'} -property * | select-object Name,DNSHostName,OperatingSystem | export-csv .\servers.csv -notypeinformation -encoding ASCII -force

#import servernames so it's a strig
$wstrings = import-csv .\servers.csv | Select DNSHostName -ExpandProperty DNSHostName 

foreach ($server in $wstrings)
{
    $server.tostring()
    $status = (Test-Connection $server -Count 1 -Quiet)
    if ($status -eq $true)
    
    {
    cmd /C net view $server >> C:\temp\server-shares.txt
    }
    else
    {
    $server | export-csv .\servers-not-found.csv 
    }
    
} 