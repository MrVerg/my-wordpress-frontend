$ftpHost = "ftpupload.net"
$ftpUser = "if0_40824595"
$ftpPass = "xd0CBwFM43"
$localPath = "C:\xampp\htdocs\impresos-lebu"
$remoteRoot = "/htdocs/impresos-lebu" # Carpeta específica

Write-Host "Iniciando subida FTP a $ftpHost en la carpeta $remoteRoot..."

function Create-FtpDirectory {
    param($remoteDir)
    $parts = $remoteDir.Split("/")
    $current = ""
    foreach ($part in $parts) {
        if ($part -eq "") { continue }
        $current += "/" + $part
        $uri = "ftp://$ftpHost$current"
        $request = [System.Net.FtpWebRequest]::Create($uri)
        $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        try {
            $response = $request.GetResponse()
            $response.Close()
            Write-Host "Directorio creado: $current"
        }
        catch {
            # El directorio probablemente ya existe
        }
    }
}

function Upload-File {
    param($lFile, $rFile)
    $uri = "ftp://$ftpHost$rFile"
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($lFile)
        $requestStream = $request.GetRequestStream()
        $requestStream.Write($fileBytes, 0, $fileBytes.Length)
        $requestStream.Close()
        Write-Host "Subido: $rFile"
    }
    catch {
        Write-Host "Error subiendo $rFile : $($_.Exception.Message)"
    }
}

# 1. Crear el directorio raíz del proyecto
Create-FtpDirectory $remoteRoot

# 2. Subir archivos base del raíz de wordpress
$baseFiles = Get-ChildItem -Path $localPath -File
foreach ($f in $baseFiles) {
    if ($f.Name -eq "wp-config.php") { continue }
    Upload-File $f.FullName "$remoteRoot/$($f.Name)"
}

# 3. Subir carpetas esenciales
$folders = @("wp-content", "wp-includes", "wp-admin")
foreach ($folderName in $folders) {
    $folderPath = Join-Path $localPath $folderName
    if (Test-Path $folderPath) {
        Create-FtpDirectory "$remoteRoot/$folderName"
        $files = Get-ChildItem -Path $folderPath -Recurse -File
        foreach ($file in $files) {
            $rel = $file.FullName.Substring($localPath.Length).Replace("\", "/")
            $rem = "$remoteRoot$rel"
            
            # Asegurar que el directorio padre existe
            $parentPathRel = $rel.Substring(0, $rel.LastIndexOf("/"))
            Create-FtpDirectory "$remoteRoot$parentPathRel"
            
            Upload-File $file.FullName $rem
        }
    }
}

# 4. Subir wp-config.php definitivo
$prodConfig = "c:\Users\sever\Studio\my-wordpress-website\my-wordpress-website\WP-CONFIG-PARA-INFINITYFREE.txt"
if (Test-Path $prodConfig) {
    Upload-File $prodConfig "$remoteRoot/wp-config.php"
}

Write-Host "¡Subida a $remoteRoot completada!"
