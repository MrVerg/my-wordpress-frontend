$ftpHost = "ftpupload.net"
$ftpUser = "if0_40824595"
$ftpPass = "xd0CBwFM43"
$localPath = "C:\xampp\htdocs\impresos-lebu"
$remoteRoot = "/htdocs"

function Upload-File {
    param($localFile, $remoteFile)
    $uri = New-Object System.Uri("ftp://$ftpHost$remoteFile")
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($localFile)
        $request.ContentLength = $fileBytes.Length
        $requestStream = $request.GetRequestStream()
        $requestStream.Write($fileBytes, 0, $fileBytes.Length)
        $requestStream.Close()
        Write-Host "Uploaded: $remoteFile"
    } catch {
        Write-Host "Error uploading $remoteFile: $_"
    }
}

function Create-FtpDirectory {
    param($remoteDir)
    $uri = New-Object System.Uri("ftp://$ftpHost$remoteDir")
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    try {
        $response = $request.GetResponse()
        $response.Close()
    } catch {
        # Directory might already exist
    }
}

# 1. Create production wp-config.php
$wpConfigContent = @"
<?php
define( 'DB_NAME', 'if0_40824595_test' );
define( 'DB_USER', 'if0_40824595' );
define( 'DB_PASSWORD', 'xd0CBwFM43' );
define( 'DB_HOST', 'sql310.infinityfree.com' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );
define('AUTH_KEY',         '$(New-Guid)');
define('SECURE_AUTH_KEY',  '$(New-Guid)');
define('LOGGED_IN_KEY',    '$(New-Guid)');
define('NONCE_KEY',        '$(New-Guid)');
define('AUTH_SALT',        '$(New-Guid)');
define('SECURE_AUTH_SALT', '$(New-Guid)');
define('LOGGED_IN_SALT',   '$(New-Guid)');
define('NONCE_SALT',       '$(New-Guid)');
`$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) { define( 'ABSPATH', __DIR__ . '/' ); }
require_once ABSPATH . 'wp-settings.php';
"@
[System.IO.File]::WriteAllText("$localPath\wp-config-production.php", $wpConfigContent)

# 2. Upload files (Simplified for this turn, focus on main files first)
$files = Get-ChildItem -Path $localPath -Recurse -File
foreach ($file in $files) {
    $relativePath = $file.FullName.Replace($localPath, "").Replace("\", "/")
    $remoteFile = "$remoteRoot$relativePath"
    
    # Ensure directory exists (simplified - check parents)
    # This is a bit complex for a one-liner, but we'll try to push main files first.
    if ($relativePath -notmatch "/") {
        Upload-File $file.FullName $remoteFile
    }
}
