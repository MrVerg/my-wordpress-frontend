$ftpHost = "ftpupload.net"
$ftpUser = "if0_40824595"
$ftpPass = "xd0CBwFM43"

Write-Host "Consultando estructura de directorios en el FTP..."

$uri = "ftp://$ftpHost/"
$request = [System.Net.FtpWebRequest]::Create($uri)
$request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
$request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails

try {
    $response = $request.GetResponse()
    $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
    $content = $reader.ReadToEnd()
    Write-Host "Contenido del servidor FTP:"
    Write-Host $content
    $reader.Close()
    $response.Close()
}
catch {
    Write-Host "Error al conectar al FTP: $($_.Exception.Message)"
}
