
* Import p12 into Local Computers Personal store
* make sure certificate is with server authentication extension and uses sha256rsa algorithm
* fire PowerShell

```
Get-Childitem Cert:\LocalMachine\My
$path = (gwmi -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").__path
swmi -Path $path -argument @{SSLCertificateSHA1Hash="THUMBPRINT"}
```
