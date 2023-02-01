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

$files = Get-ChildItem -Path $Path -Filter "*.mkv"
Write-Host $files

$count = $StartingEpisode
foreach($file in $files) {
    $directory = Split-Path -Path $file
    $newName = "$directory/$Name S$Season E$count.mkv"
    Write-Host "Renaming $file to $newName"
    if (-Not $WhatIf) {
        Move-item $file $newName
    }
    $count += 1
}
