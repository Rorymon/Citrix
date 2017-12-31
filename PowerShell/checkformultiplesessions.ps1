<#.SYNOPSIS    ..DESCRIPTION    This script takes a Citrix published application and outputs all user's who have more than one active session ####.VARIABLE app    Citrix published application.#>
   $app={Site\Directory\App}
add-pssnapin Citrix*
$users=Get-BrokerSession -MaxRecordCount 3000 -ApplicationInUse $app | Select Username$ht=@{}$users | foreach {$ht["$_"] += 1}$ht.keys | where {$ht["$_"] -gt 1} | foreach {write-host "Multiple sessions active for user $_" }
