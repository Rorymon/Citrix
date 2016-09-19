<#
.SYNOPSIS
    .
.DESCRIPTION
    This script takes an AD Group and Output Directory as input and outputs ####
    a text file containing all members of the AD Group. Change Output and text file location, hardcoded for this script. Created by Rory Monaghan. 

#>



add-pssnapin Citrix*


$OutputDir="C:\Output"

$csvContents = @() # Create the empty array that will eventually be the CSV file



foreach ($user in (Get-Content "C:\UserCountTesting\76Using65.txt"))

{

$ConnectSession = Get-XASession -BrowserName connect | Where-Object { $_.AccountName -match $user } 
if ($ConnectSession) {
$row = New-Object System.Object
$row | Add-Member -MemberType NoteProperty -Name "User" -Value $user # create a property called UserID. This will be the UserID column
Get-XASession | Where-Object { $_.AccountName -match $user } | Send-XASessionMessage -MessageTitle "Attn: Staff Members" -MessageBody "You are receiving this notification because the new Connect-PRD icon 
has been published to your facility and your login.

PLEASE begin using the Connect-PRD icon.  If you experience any issues 
with the new icon, call the Service Desk at 480-882-4357, and continue to use the Connect icon.

If you have not received the new Connect-PRD icon, please call the Service Desk at 480-882-4357, 
and continue to use the Connect icon.

If you are a staff member who uses a eSignature pad workstation, a recent fix was distributed to the PC’s. 
If you are continuing to experience eSig related issue with Connect-PRD, please call the Service Desk at 480-882-4357 to
report the error. 
 

Best Regards, 
HonorHealth Citrix Team"
$row | Add-Member -MemberType NoteProperty -Name "User" -Value $user -force
#$row | Add-Member -MemberType NoteProperty -Name "Status" -Value # create a property called UserID. This will be the UserID column
#$row | Add-Member -MemberType NoteProperty -Name "Status" -Value "Notified" # create a property called UserID. This will be the UserID column
$csvContents += $row # append the new data to the array
#write-host ("$user is currently using Connect on Session Host: $ConnectSession")
write-host ("$user is currently using Connect on Session Host")
}
else
{
#$row = New-Object System.Object
#$row | Add-Member -MemberType NoteProperty -Name "User" -Value $user # create a property called UserID. This will be the UserID column
#$row | Add-Member -MemberType NoteProperty -Name "Status" -Value "Not Used" # create a property called UserID. This will be the UserID column
#$csvContents += $row # append the new data to the array
write-host ("$user is not using Connect")
}
}


$csvContents | Export-CSV -Path "C:\Output\ADGroup-New.csv"

$csv = Get-Content "C:\Output\ADGroup-New.csv"

$csv = $csv[1..($csv.count - 1)]

$csv > "C:\Output\ADGroup-New.csv"

