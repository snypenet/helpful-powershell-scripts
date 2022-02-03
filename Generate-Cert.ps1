Param(
    [Parameter(Mandatory=$true)]
    [string]
    $CertName,
    [switch]
    $CreatePfx,
    [string]
    $Provider="Microsoft Enhanced RSA and AES Cryptographic Provider"
)

$CertName = $CertName.Trim()

& openssl req -newkey rsa:2048 -nodes -keyout "$CertName.key" -out "$CertName.csr"
& openssl x509 -signkey "$CertName.key" -in "$CertName.csr" -req -days 1825 -out "$CertName.crt"

if ($CreatePfx) {
    Write-Host "Generating PFX"
    & openssl pkcs12 -inkey "$CertName.key" -in "$CertName.crt" -export -out "$CertName.pfx" -CSP $Provider
}
