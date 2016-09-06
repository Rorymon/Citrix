<#
.SYNOPSIS
    .
.DESCRIPTION
    This script takes an AppName, a Delivery Group you want to copy the application to and the current Delivery Group it should be removed from. ####
    Before running this script, you should first duplicate the application you want. I usually duplicate, disable and run this script. Created by Rory Monaghan. 
.PARAMETER AppName
    Application Name
.PARAMETER DeliveryGroup
    Delivery Group that the application should be copied to.
.PARAMETER CurrentDeliveryGroup
    Delivery Group the application will be copied from. Note: The application will also be removed from this Delivery Group.
#>



Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$AppName,

   [Parameter(Mandatory=$True)]
   [string]$DeliveryGroup,
	
   [Parameter(Mandatory=$True)]
   [string]$CurrentDeliveryGroup
)


add-pssnapin Citrix*

$app = Get-BrokerApplication -Name $AppName
$app | Add-BrokerApplication -DesktopGroup $DeliveryGroup
$app | Remove-BrokerApplication -DesktopGroup $CurrentDeliveryGroup
