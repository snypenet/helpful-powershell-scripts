param(
  [Parameter(Mandatory = $true)]
  [string]
  $FileName
)

Write-Host "Formatting Output..."

$colorMatches = @{
    "0" = 'black';
    "1" = 'bold';
    "30" = 'black';
    "31" = 'red';
    "32" = 'green';
    "33" = 'yellow';
    "34" = 'blue';
    "35" = 'magenta';
    "36" = 'cyan';
    "37" = 'white';
    "90" = 'grey';
}

$formattedFileName = $FileName.Replace(".plan", ".plan.html")

if (Test-Path $formattedFileName) {
    Remove-Item $formattedFileName
}

Add-Content $formattedFileName "<!doctype html>
    <html>
    <head>
      <meta charset='utf-8' />
      <style>
        .bold {
          font-weight: bold;
        }
        .black {
          color: black;
        }
        .red {
          color: red;
        }
        .green {
          color: green;
        }
        .yellow {
          color: rgb(185, 185, 1);
        }
        .blue {
          color: blue;
        }
        .magenta {
          color: magenta;
        }
        .cyan {
          color: cyan;
        }
        .white {
          color: white;
        }
        .grey {
          color: grey;
        }
      </style>
    </head>
    <body><pre><code>"

    foreach($line in Get-Content $FileName) {
        $line = $line.Replace("", " ")
        $characterAccumulator = ""
        $formattingCount = 0
        foreach($character in [char[]]$line) {
            $characterAccumulator += $character
            if (($character -eq " " -or $character -eq "\n") -and $formattingCount -gt 0) {
                $characterAccumulator = $characterAccumulator + "</span>"
                $formattingCount--
            } elseif ($characterAccumulator -Match '\[\d{1,2}m') {
                foreach($match in $colorMatches.Keys) {
                    $snapshot = $characterAccumulator
                    $characterAccumulator = $characterAccumulator.Replace("[$($match)m", "<span class='$($colorMatches[$match])'>")
                    if($snapshot -ne $characterAccumulator) {
                        $formattingCount++
                        break
                    } 
                }
            }
        }
        for($c = $formattingCount; $c -gt 0; $c--) {
            $characterAccumulator = $characterAccumulator + "</span>"
        }

        Add-Content $formattedFileName $characterAccumulator
    }

    Add-Content $formattedFileName "</code></pre></body>"

    Write-Host "All Done"
