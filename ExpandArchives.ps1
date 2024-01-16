param(
    [String]
    $Source,
    [String]
    $Destination
)

$archives = Get-ChildItem -Path $Source -Filter "*.zip" -File
Write-Host "Found $($archives.Length) archives to unpack"
$rootFolder = $Source.TrimEnd("/").TrimEnd("\")
$processedFolder = "$rootFolder/processed_archives"

foreach($archive in $archives) {
    Write-Host "Processing $($archive.FullName)"
    Expand-Archive -LiteralPath $archive.FullName
    $expandedArchiveName = $archive.Name.Replace(".zip", "")
    $expandedArchiveFullName = "$rootFolder\$expandedArchiveName" 
    $subFolders = Get-ChildItem -Path $expandedArchiveFullName -Directory
    foreach($subFolder in $subFolders) {
        Write-Host "Copying $($subFolder.FullName)"
        Copy-Item -LiteralPath $subFolder.FullName -Destination $Destination -Recurse
    }

    Write-Host "Deleting $expandedArchiveFullName"
    Remove-Item -LiteralPath $expandedArchiveFullName -Force -Recurse
    
    Write-Host "Moving $($archive.FullName) to processed_archives"
    Move-Item -LiteralPath $archive.FullName -Destination $processedFolder -Force
}

Write-Host "Done"