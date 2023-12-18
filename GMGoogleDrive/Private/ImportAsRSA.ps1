# https://stackoverflow.com/questions/11506891/how-to-load-the-rsa-public-key-from-file-in-c-sharp/32243171#32243171
# ------- Parses binary ans.1 RSA private key; returns RSACryptoServiceProvider  ---
function GetIntegerSize([System.IO.BinaryReader]$br) {
    $bt = 0
    $count = 0
    $bt = $br.ReadByte()
    if ($bt -ne 0x02) { # expect integer
        return 0
    }
    $bt = $br.ReadByte()

    if ($bt -eq 0x81) {
        $count = $br.ReadByte() # data size in next byte
    }
    elseif ($bt -eq 0x82)
    {
        $highbyte = $br.ReadByte() # data size in next 2 bytes
        $lowbyte = $br.ReadByte()
        [byte[]]$modint = @( $lowbyte, $highbyte, 0x00, 0x00 );
        $count = [BitConverter]::ToInt32($modint, 0);
    }
    else
    {
        $count = $bt;     # we already have the data size
    }

    while ($br.ReadByte() -eq 0x00) # remove high order zeros in data
    {
        $count -= 1;
    }
    [void]$br.BaseStream.Seek(-1, 'Current');     # last ReadByte wasn't a removed zero, so back up a byte

    $count;
}

function DecodeRSAPrivateKey([byte[]]$privkey) {
    # ---------  Set up stream to decode the asn.1 encoded RSA private key  ------
    $m = New-Object System.IO.MemoryStream @(,$privkey)
    $br = New-Object System.IO.BinaryReader $m
    try {
        $twobytes = $br.ReadUInt16();      # header sequence
        if ($twobytes -eq 0x8130) {        # data read as little endian order (actual data order for Sequence is 30 81)
            [void]$br.ReadByte()                 # advance 1 byte
        }
        elseif ($twobytes -eq 0x8230) {
            [void]$br.ReadInt16()                # advance 2 bytes
        }
        else {
            throw "Invalid RSA format/1"
        }
        if ($br.ReadUInt16() -ne 0x0102) { # version number
            throw "Invalid RSA format/2"
        }
        if ($br.ReadByte() -ne 0x00) {     # zero
            throw "Invalid RSA format/3"
        }
        # ------  all private key components are Integer sequences ----
        $count = GetIntegerSize($br);
        $MODULUS = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $E = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $D = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $P = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $Q = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $DP = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $DQ = $br.ReadBytes($count);
        $count = GetIntegerSize($br);
        $IQ = $br.ReadBytes($count);
    }
    finally {
        $br.Close()
        $m.Close()
    }

    # ------- create RSACryptoServiceProvider instance and initialize with public key -----
    $RSA = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $RSAparams = New-Object System.Security.Cryptography.RSAParameters
    $RSAparams.Modulus = $MODULUS
    $RSAparams.Exponent = $E
    $RSAparams.D = $D
    $RSAparams.P = $P
    $RSAparams.Q = $Q
    $RSAparams.DP = $DP
    $RSAparams.DQ = $DQ
    $RSAparams.InverseQ = $IQ
    $RSA.ImportParameters($RSAparams)
    $RSA
}

function Import5AsRSA([byte[]]$private_bytes) {
    try {
        Write-Verbose " try pkcs8"
        $k = [System.Security.Cryptography.CngKey]::Import($private_bytes, [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
        $rsa = New-Object System.Security.Cryptography.RSACng $k
        $rsa
    }
    catch {
        Write-Verbose " try pkcs1"
        DecodeRSAPrivateKey $private_bytes
    }
}

function Import7AsRSA([byte[]]$private_bytes, [byte[]]$passwordBytes) {
    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $count_read=0
    try {
        Write-Verbose " try pkcs8"
        if ($passwordBytes) {
            $rsa.ImportEncryptedPkcs8PrivateKey($passwordBytes, $private_bytes, [ref]$count_read)
        }
        else {
            $rsa.ImportPkcs8PrivateKey($private_bytes, [ref]$count_read)
        }
    }
    catch {
        Write-Verbose " try pkcs1"
        $rsa.ImportRSAPrivateKey($private_bytes, [ref]$count_read)
    }
    $rsa
}

function ImportX509AsRSA([System.Security.Cryptography.X509Certificates.X509Certificate2]$key) {
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($key)
    $rsa
}
