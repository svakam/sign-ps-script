# Credit to https://adamtheautomator.com/how-to-sign-powershell-script/ for creating self-signed cert, adding to stores, testing the additions, and 
# signing the script.
# RUN THIS SCRIPT AS ADMINISTRATOR

# if current self-signed cert doesn't exist in personal or if expired, create new one
$codeCertificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}
$certExpiration = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=ATA Authenticode"} | Select-Object NotAfter

if (!$codeCertificate -or !$certExpiration -or $certExpiration > Get-Date) { 
    Write-Output "Self-signed cert doesn't exist in local system, or current self-signed certificate is expired. Creating ATA Authenticode cert in cert stores..." 

    # Generate a self-signed Authenticode certificate in the local computer's personal certificate store.
     $authenticode = New-SelfSignedCertificate -Subject "ATA Authenticode" -CertStoreLocation Cert:\LocalMachine\My -Type CodeSigningCert

     # Add the self-signed Authenticode certificate to the computer's root certificate store.
    ## Create an object to represent the LocalMachine\Root certificate store.
     $rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")
    ## Open the root certificate store for reading and writing.
     $rootStore.Open("ReadWrite")
    ## Add the certificate stored in the $authenticode variable.
     $rootStore.Add($authenticode)
    ## Close the root certificate store.
     $rootStore.Close()
 
    # Add the self-signed Authenticode certificate to the computer's trusted publishers certificate store.
    ## Create an object to represent the LocalMachine\TrustedPublisher certificate store.
     $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPublisher","LocalMachine")
    ## Open the TrustedPublisher certificate store for reading and writing.
     $publisherStore.Open("ReadWrite")
    ## Add the certificate stored in the $authenticode variable.
     $publisherStore.Add($authenticode)
    ## Close the TrustedPublisher certificate store.
     $publisherStore.Close()

     # Confirm if the self-signed Authenticode certificate exists in the computer's Personal certificate store
     Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}
    # Confirm if the self-signed Authenticode certificate exists in the computer's Root certificate store
     Get-ChildItem Cert:\LocalMachine\Root | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}
    # Confirm if the self-signed Authenticode certificate exists in the computer's Trusted Publishers certificate store
     Get-ChildItem Cert:\LocalMachine\TrustedPublisher | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}

     # Get the code-signing certificate from the local computer's certificate store with the name *ATA Authenticode* and store it to the $codeCertificate variable.
    $codeCertificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}

}

# Prompt user for script path
$scriptPath = Read-Host -Prompt "Enter full file path of the script to be signed: "

# Sign the PowerShell script
# PARAMETERS:
# FilePath - Specifies the file path of the PowerShell script to sign, eg. C:\ATA\myscript.ps1.
# Certificate - Specifies the certificate to use when signing the script.
# TimeStampServer - Specifies the trusted timestamp server that adds a timestamp to your script's digital signature. Adding a timestamp ensures that your code will not expire when the signing certificate expires.
Set-AuthenticodeSignature -FilePath $scriptPath -Certificate $codeCertificate -TimeStampServer http://timestamp.digicert.com

# Verify signed script
Get-AuthenticodeSignature -FilePath $scriptPath | Select-Object -Property *