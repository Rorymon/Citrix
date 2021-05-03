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

$adminaddressepic = "C1VPWCTXDCAP05.slhnaz.org"
$adminaddressapps = "C1VPWCTXDCAP20.slhnaz.org"
$FormatEnumerationLimit=-1

$AssignmentSearchForm                    = New-Object system.Windows.Forms.Form
$AssignmentSearchForm.ClientSize         = '480,300'
$AssignmentSearchForm.text               = "Search Citrix Assignments"
$AssignmentSearchForm.BackColor          = "#ffffff"
$AssignmentSearchForm.TopMost            = $false
$AssignmentSearchForm.AutoSize           = $true
$AssignmentSearchForm.Icon               = "C:\toolicon.ico"

$Title                           = New-Object system.Windows.Forms.Label
$Title.text                      = "Enter App Name:"
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

$AllBtn                   = New-Object system.Windows.Forms.Button
$AllBtn.BackColor         = "#429ce3"
$AllBtn.text              = "View All"
$AllBtn.width             = 90
$AllBtn.height            = 30
$AllBtn.location          = New-Object System.Drawing.Point(275,250)
$AllBtn.Font              = 'Microsoft Sans Serif,10'
$AllBtn.ForeColor         = "#0000f"
$AllBtn.Visible           = $true
$AllBtn.AutoSize          = $true
$AllBtn.Anchor            = 'right,bottom'

$SearchResults                    = New-Object system.Windows.Forms.Label
$SearchResults.AutoSize           = $true
$SearchResults.location           = New-Object System.Drawing.Point(20,115)
$SearchResults.Font               = 'Microsoft Sans Serif,10'
$SearchResults.Visible            = $false
 

$clearBtn                       = New-Object system.Windows.Forms.Button
$clearBtn.BackColor             = "#ffffff"
$clearBtn.text                  = "Clear"
$clearBtn.width                 = 90
$clearBtn.height                = 30
$clearBtn.location              = New-Object System.Drawing.Point(300,45)
$clearBtn.Font                  = 'Microsoft Sans Serif,10'
$clearBtn.ForeColor             = "#000"
$clearBtn.Visible               = $false

$AssignmentSearchForm.controls.AddRange(@($Title,$Description,$AppName,$AppFound,$SearchAppsBtn,$AllBtn,$SearchResults,$clearBtn))

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

$DDC01 = <Add DDC FQDN>
$DDC02 = <Add DDC FQDN for Second Site>

[bool]$strinput
if (!$strinput) { 

[System.Windows.MessageBox]::Show('Please enter an application name to search','Search input','Ok','Error')

}
else
{

$appas = Get-BrokerApplication -AdminAddress C1VPWCTXDCAP20.slhnaz.org -Enabled $true | Where-Object {$_.ApplicationName  -like "*$strinput*"} | Select ApplicationName, AssociatedUserFullNames | Format-Table -AutoSize | Out-String
$appas += Get-BrokerApplication -AdminAddress C1VPWCTXDCAP05.slhnaz.org -Enabled $true | Where-Object {$_.ApplicationName  -like "*$strinput*"} | Select ApplicationName, AssociatedUserFullNames | Format-Table -AutoSize | Out-String

}


$SearchResults.Visible = $true
$clearBtn.Visible = $true
$appas = $appas -replace ‘[{}]’
$SearchResults.text = $appas

[bool]$appas
if (!$appas) { 

$SearchResults.text = "No Results Found for $strinput"
$SearchResults.ForeColor = "Red"

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

$AllBtn.Add_Click({
$appassignmentreportdir = "C:\Users\Public\AssignmentReports"
Remove-Item $appassignmentreportdir\*

add-pssnapin Citrix*

If(!(test-path $appassignmentreportdir))
{
      New-Item -ItemType Directory -Force -Path $appassignmentreportdir
}


$primreport = Get-BrokerApplication -AdminAddress $DDC01 -Enabled $true | Where-Object {$_.ApplicationName  -like "*$strinput*"} | Select ApplicationName, AssociatedUserFullNames | Format-Table -AutoSize | Out-File "$appassignmentreportdir\AppList1.txt"
$secreport = Get-BrokerApplication -AdminAddress $DDC02 -Enabled $true | Where-Object {$_.ApplicationName  -like "*$strinput*"} | Select ApplicationName, AssociatedUserFullNames | Format-Table -AutoSize | Out-File "$appassignmentreportdir\AppList2.txt"

$primreport = "$appassignmentreportdir\AppList1.txt"
$secreport = "$appassignmentreportdir\AppList2.txt"

$import = get-content $primreport
$import | Select-Object -Skip 2 | Foreach {$_ -replace '}', ""} | Set-Content "$appassignmentreportdir\AppList1.txt" | Format-Table -AutoSize

$import = get-content $secreport
$import | Select-Object -Skip 2 | Foreach {$_ -replace '}', ""} | Set-Content "$appassignmentreportdir\AppList2.txt" | Format-Table -AutoSize

$csv1 = "$appassignmentreportdir\AppList1.txt"
$csv2 = "$appassignmentreportdir\AppList2.txt"

$import = get-content $csv1
$import | Select-Object -Skip 1 | Set-Content "$appassignmentreportdir\AppList1.txt" | Format-Table -AutoSize

$import = get-content $csv2
$import | Select-Object -Skip 1 | Set-Content "$appassignmentreportdir\AppList2.txt" | Format-Table -AutoSize


Get-Content $csv1, $csv2 | Set-Content "$appassignmentreportdir\WorkingDoc.csv"

$file = import-csv "$appassignmentreportdir\WorkingDoc.csv" -delimiter "{" -Header "Application" , "Assignments" | export-csv "$appassignmentreportdir\WorkingDocFin.csv"

@(Import-Csv "$appassignmentreportdir\WorkingDocFin.csv") | Export-Csv "$appassignmentreportdir\WorkingDoc.txt" -NoTypeInformation

Import-Csv $appassignmentreportdir\WorkingDocFin.csv | sort -Property Application | Export-Csv -Path $appassignmentreportdir\AppListComplete.csv -NoTypeInformation 

$html= Import-CSV "$appassignmentreportdir\AppListComplete.csv" | ConvertTo-Html -PreContent "<h1>Application Assignments</h1>`n<h5>Generated on $(Get-Date)</h5>" -Head $css -Body "This report lists all application assignments for the apps published from the Epic and Apps farms." | Out-File "$appassignmentreportdir\AppAssignmentsReport.html"

Invoke-Item "$appassignmentreportdir\AppAssignmentsReport.html"

})


[void]$AssignmentSearchForm.ShowDialog()

