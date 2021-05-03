<#
.SYNOPSIS
    .
.DESCRIPTION
    This script creates a GUI which allows users to input an application name to discover which users and groups are assigned to it ####
    Created by Rory Monaghan. 
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#---------------------------------------------------------[Form]--------------------------------------------------------
[System.Windows.Forms.Application]::EnableVisualStyles()
$domainprefix = <Domain>
$adminaddressapps = <DDC>
$FormatEnumerationLimit=-1

$AssignmentSearchForm                    = New-Object system.Windows.Forms.Form
$AssignmentSearchForm.ClientSize         = '480,300'
$AssignmentSearchForm.text               = "Citrix RemotePC Assignments"
$AssignmentSearchForm.BackColor          = "#ffffff"
$AssignmentSearchForm.TopMost            = $false
$AssignmentSearchForm.AutoSize           = $true
$AssignmentSearchForm.Icon               = "C:\toolicon.ico"

$Title                           = New-Object system.Windows.Forms.Label
$Title.text                      = "Enter Machine Name:"
$Title.AutoSize                  = $true
$Title.width                     = 25
$Title.height                    = 10
$Title.location                  = New-Object System.Drawing.Point(20,20)
$Title.Font                      = 'Microsoft Sans Serif,13'

$AppName                   = New-Object system.Windows.Forms.Label
$AppName.text              = "Assignments:"
$AppName.AutoSize          = $true
$AppName.width             = 40
$AppName.height            = 10
$AppName.location          = New-Object System.Drawing.Point(20,115)
$AppName.Font              = 'Microsoft Sans Serif,10,style=Bold'
$AppName.Visible           = $false

$AppFound                    = New-Object system.Windows.Forms.Label
$AppFound.AutoSize           = $true
$AppFound.width              = 25
$AppFound.height             = 10
$AppFound.location           = New-Object System.Drawing.Point(100,115)
$AppFound.Font               = 'Microsoft Sans Serif,10'
$AppFound.Visible            = $false

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(20,50)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$AssignmentSearchForm.Controls.Add($textBox)


$SearchAppsBtn                   = New-Object system.Windows.Forms.Button
$SearchAppsBtn.BackColor         = "#429ce3"
$SearchAppsBtn.text              = "Search"
$SearchAppsBtn.width             = 90
$SearchAppsBtn.height            = 30
$SearchAppsBtn.location          = New-Object System.Drawing.Point(370,250)
$SearchAppsBtn.Font              = 'Microsoft Sans Serif,10'
$SearchAppsBtn.ForeColor         = "#0000f"
$SearchAppsBtn.Visible           = $true
$SearchAppsBtn.AutoSize          = $true
$SearchAppsBtn.Anchor            = 'right,bottom' 

$clearBtn                       = New-Object system.Windows.Forms.Button
$clearBtn.BackColor             = "#ffffff"
$clearBtn.text                  = "Clear"
$clearBtn.width                 = 90
$clearBtn.height                = 30
$clearBtn.location              = New-Object System.Drawing.Point(300,45)
$clearBtn.Font                  = 'Microsoft Sans Serif,10'
$clearBtn.ForeColor             = "#000"
$clearBtn.Visible               = $false

$RemoveBtn                       = New-Object system.Windows.Forms.Button
$RemoveBtn.BackColor             = "#0000f"
$RemoveBtn.text                  = "Remove"
$RemoveBtn.width                 = 90
$RemoveBtn.height                = 30
$RemoveBtn.location              = New-Object System.Drawing.Point(300,115)
$RemoveBtn.Font                  = 'Microsoft Sans Serif,10'
$RemoveBtn.ForeColor             = "#000"
$RemoveBtn.Visible               = $false

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(20,115)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 70
$listBox.SelectionMode = 'MultiExtended'

$AssignmentSearchForm.controls.AddRange(@($Title,$Description,$AppName,$AppFound,$SearchAppsBtn,$listBox,$RemoveBtn,$clearBtn))

#-----------------------------------------------------------[Web Form]------------------------------------------------------------

$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

#-----------------------------------------------------------[Functions]------------------------------------------------------------

$SearchAppsBtn.Add_Click({
  
add-pssnapin Citrix*

$strinput = $textBox.Text
$RemoveBtn.Visible = $true
$RemotePCCatalog = <Add Machine Catalog Name>
$DDC = <Add FQDN of Citrix DDC>

[bool]$strinput
if (!$strinput) { 

[System.Windows.MessageBox]::Show('Please enter machine name to search','Search input','Ok','Error')

}
else
{

$appas = Get-BrokerDesktop -PublishedName $strinput -CatalogName $RemotePCCatalog | Select AssociatedUserNames | Format-Table -AutoSize | Out-String


$appas = $appas -replace ‘[{}]’

$appas = $appas -replace 'AssociatedUserNames' 

$appas = $appas -replace '-------------------'                       
                       
$array= $appas.Split(",")

$array = $array.TrimStart()

$array | ForEach-Object {
    $listbox.Items.Add($_) | Out-Null
}


$clearBtn.Visible = $true


}


[bool]$appas
if (!$appas) { 

#$SearchResults.text = "No Results Found for $strinput"
#$SearchResults.ForeColor = "Red"

}


})

$clearBtn.Add_Click({
$SearchResults.text = ""
$clearBtn.Visible = $false
$appas = ""
$strinput = ""
$textbox.Text = ""
$AssignmentSearchForm.Refresh()
$SearchResults.ResetForeColor()

})

$RemoveBtn.Add_Click({
add-pssnapin Citrix*
$strinput = $textBox.Text
$RemotePC = "$domainprefix\$strinput"
$SelectedUser = $listBox.GetItemText($listBox.SelectedItem)
$SelectedUser = $SelectedUser.ToString().TrimEnd()
write-host $SelectedUser
#$SelectedUser = $listBox.SelectedItems


$scriptblock = { add-pssnapin Citrix*

                Remove-BrokerUser -Name $SelectedUser -AdminAddress $DDC -Machine $RemotePC
                 }

& $scriptblock

})


[void]$AssignmentSearchForm.ShowDialog()

