#$privateKey = [convert]::FromBase64String($json.private_key -replace "-{5}(BEGIN|END) (ENCRYPTED )?PRIVATE KEY-{5}")

function Import5AsRSA([Byte[]]$private_bytes) {
    $k = [System.Security.Cryptography.CngKey]::Import($private_bytes, [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
    $rsa = [System.Security.Cryptography.RSACng]::new($k)
    $rsa
}

function Import7AsRSA([Byte[]]$private_bytes, [Byte[]]$passwordBytes) {
    $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new()
    $count_read=0
    if ($passwordBytes) {
        $rsa.ImportEncryptedPkcs8PrivateKey($passwordBytes, $private_bytes, [ref]$count_read)
    }
    else {
        $rsa.ImportPkcs8PrivateKey($private_bytes, [ref]$count_read)
    }  
    $rsa
}

function ImportX509AsRSA([System.Security.Cryptography.X509Certificates.X509Certificate2]$key) {
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($key)
    $rsa
}
