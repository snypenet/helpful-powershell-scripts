param(
    [Parameter(Mandatory = $true)]
    [string]
    $Path,
    [Parameter(Mandatory = $true)]
    [string]
    $Name,
    [Parameter(Mandatory = $true)]
    [int]
    $Season,
	[string]
	$Extension = "mkv",
    [Parameter(Mandatory = $true)]
    [int]
    $StartingEpisode,
    [switch]
    $WhatIf
)
if (-Not (Test-Path $Path)) {
    Write-Error "$Path is not found"
    return
}

$files = Get-ChildItem -Path $Path -Filter "*.$Extension" | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) })}

$count = $StartingEpisode
foreach($file in $files) {
    $directory = Split-Path -Path $file
    $newName = "$directory/$Name S$Season E$count.$Extension"
    Write-Host "Renaming $file to $newName"
    if (-Not $WhatIf) {
        Move-item $file $newName
    }
    $count += 1
}
