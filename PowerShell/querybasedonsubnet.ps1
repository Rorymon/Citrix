<#

.SYNOPSIS

.

.DESCRIPTION

This script takes a subnet e.g. 10.64 as input and outputs session info: UserName and Delivery Group. Run this on your Delivery Controller. Script by Rory Monaghan.

.PARAMETER SubNet

A SubNet e.g. 10.64


#>

add-pssnapin Citrix*

Param(

[Parameter(Mandatory=$True,Position=1)]

[string]$SubNet

)

Get-BrokerSession -ClientAddress "$SubNet.*" | Select  UserName,DesktopGroupName
