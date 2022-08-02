param(
  [Parameter(Mandatory = $true)]
  [string]
  $FileName
)

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

$formattedFileName = $FileName + ".html"

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

    foreach($line in Get-Content $fileName) {
        $formattedLine = $line.Replace("[0m", "").Replace("ΓöÇ", "").Replace("", "")
        foreach($match in $colorMatches.Keys) {
            $pattern = "[$($match)m"
            if ($formattedLine.Contains($pattern)) {
                $formattedLine = "<span class='$($colorMatches[$match])'>$($formattedLine.Replace($pattern, ''))</span>"
                break
            }
        }
        Add-Content $formattedFileName $formattedLine
    }

    Add-Content $formattedFileName "</code></pre></body>"
