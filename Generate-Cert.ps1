Param(
    [Parameter(Mandatory=$true)]
    [string]
    $CertName,
    [switch]
    $CreatePfx,
    [string]
    $Provider="Microsoft Enhanced RSA and AES Cryptographic Provider",
	[string[]]
	$SubjectAltNames
)

$CertName = $CertName.Trim()

if ($SubjectAltNames.Length -gt 0) {
	if (Test-Path "$CertName-csr.cnf") {
		Remove-Item "$CertName-csr.cnf" 
	}
	if (Test-Path "$CertName-cert.cnf") {
		Remove-Item "$CertName-cert.cnf" 
	}

	Add-Content "$CertName-csr.cnf" "
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
[ req_distinguished_name ]
countryName = Country Code (US)
stateOrProvinceName = State
localityName = City
organizationName = Org Name
commonName = Common Name (e.g. server FQDN or YOUR name)
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
"
	
	for($i = 0; $i -lt $SubjectAltNames.Length; $i++) {
		Add-Content "$CertName-csr.cnf" "DNS.$($i + 1)=$($SubjectAltNames[$i])" 
	}

	Add-Content "$CertName-cert.cnf" "
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
"
	for($i = 0; $i -lt $SubjectAltNames.Length; $i++) {
		Add-Content "$CertName-cert.cnf" "DNS.$($i + 1)=$($SubjectAltNames[$i])" 
	}
	
	& openssl req -newkey rsa:2048 -nodes -keyout "$CertName.key" -out "$CertName.csr" -config "$CertName-csr.cnf"
	& openssl x509 -signkey "$CertName.key" -in "$CertName.csr" -req -days 1825 -out "$CertName.crt" -extfile "$CertName-cert.cnf"

	if ($CreatePfx) {
		Write-Host "Generating PFX"
		& openssl pkcs12 -inkey "$CertName.key" -in "$CertName.crt" -export -out "$CertName.pfx" -CSP $Provider
	}
} else {
	& openssl req -newkey rsa:2048 -nodes -keyout "$CertName.key" -out "$CertName.csr"
	& openssl x509 -signkey "$CertName.key" -in "$CertName.csr" -req -days 1825 -out "$CertName.crt"

	if ($CreatePfx) {
		Write-Host "Generating PFX"
		& openssl pkcs12 -inkey "$CertName.key" -in "$CertName.crt" -export -out "$CertName.pfx" -CSP $Provider
	}
}

