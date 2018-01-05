 <#
.SYNOPSIS
    .
.DESCRIPTION
    This script takes an AD Group and Output Directory as input and outputs ####
    a text file containing all members of the AD Group. Ensure DelProf and cmd are on server or in PVS image. Alternatively deploy with tool like PDQDeploy. Created by Rory Monaghan. 
.PARAMETER cred
    Enter Domain\Username
    .PARAMETER cred    Enter Domain\Username
     Enter Domain\Username. You will get prompted for password when script attempts to execute on each server.   
    .PARAMETER slist    
     Enter Full path to a text file with a list of servers.
#>
　
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$cred,
  [Parameter(Mandatory=$True)]
   [string]$SList
)

　
foreach ($comp in (Get-Content "$SList"))

{

Invoke-Command -ComputerName $comp -credential $cred -ErrorAction Stop -ScriptBlock {Invoke-Expression -Command:"cmd.exe /c '<Insert path to cmd on server>'"}

}

 
