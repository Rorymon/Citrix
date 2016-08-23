<#
.SYNOPSIS
    .
.DESCRIPTION
    This script takes an AD Group and Output Directory as input and outputs ####
    a text file containing all members of the AD Group. Created by Rory Monaghan. 
.PARAMETER ADGroup
    An Active Directory Group in your current Domain. e.g. DGG-AppVAdmins
.PARAMETER OutputDir
    Specifies a path to output a text file to. This text file will contain all members of the
    provided Active Directory group.
#>



Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$ADGroup,

   [Parameter(Mandatory=$True)]
   [string]$AppName,
	
   [Parameter(Mandatory=$True)]
   [string]$OutputDir
)

add-pssnapin Citrix*

if (!(Test-Path $OutputDir)){ 
New-Item -path $OutputDir -type directory -Force
}

If (Test-Path "$OutputDir\ADGroup-$ADGroup.txt"){
  "$OutputDir\ADGroup-$ADGroup.txt already exists, please re-run the script using a different output directory or delete the original file"
}Else{
  Get-ADGroupMember -identity $ADGroup | select SamAccountName | Out-File "$OutputDir\ADGroup-$ADGroup.txt"
  (type "$OutputDir\ADGroup-$ADGroup.txt") -notmatch "name" | out-file "$OutputDir\ADGroup-$ADGroup.txt"
  (type "$OutputDir\ADGroup-$ADGroup.txt") -notmatch "----" | out-file "$OutputDir\ADGroup-$ADGroup.txt"
  (gc "$OutputDir\ADGroup-$ADGroup.txt" | select -Skip 1) | sc "$OutputDir\ADGroup-$ADGroup.txt"
}

$csvContents = @() # Create the empty array that will eventually be the CSV file


foreach ($user in (Get-Content "$OutputDir\ADGroup-$ADGroup.txt"))

{


write-host ($user)
$ConnectSession = Get-BrokerSession -ApplicationInUse $AppName | Where-Object { $_.BrokerUser -match $user }
if ($ConnectSession) {
$row = New-Object System.Object
$row | Add-Member -MemberType NoteProperty -Name "User" -Value $user # create a property called UserID. This will be the UserID column
Get-BrokerSession -ApplicationInUse $AppName | Where-Object { $_.BrokerUser -match $user } | Send-BrokerSessionMessage -MessageStyle Information -Text "This is a test from the Citrix team" -Title "Citrix Team"
$row | Add-Member -MemberType NoteProperty -Name "Status" -Value "Notified" # create a property called UserID. This will be the UserID column
$csvContents += $row # append the new data to the array
write-host ("$user is currently using Connect on Session Host: $ConnectSession")
}
else
{
$row = New-Object System.Object
$row | Add-Member -MemberType NoteProperty -Name "User" -Value $user # create a property called UserID. This will be the UserID column
$row | Add-Member -MemberType NoteProperty -Name "Status" -Value "Not Used" # create a property called UserID. This will be the UserID column
$csvContents += $row # append the new data to the array
write-host ("$user is not using $AppName")
}
}


$csvContents | Export-CSV -Path "$OutputDir\ADGroup-$ADGroup.cvs"

$csv = Get-Content "$OutputDir\ADGroup-$ADGroup.cvs"

$csv = $csv[1..($csv.count - 1)]

$csv > "$OutputDir\ADGroup-$ADGroup.csv"
