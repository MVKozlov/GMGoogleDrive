# New-JwtToken
#   -Algorithm RS256
#   -Secret $rsa
#   -KeyId 'xxx'
#   -Audience "https://oauth2.googleapis.com/token"
#   -Expiration 3600
#   -Issuer ps-xxxxxxxxgserviceaccount.com
#   -Scope 'https://www.googleapis.com/auth/drive'

function GetJWTToken([string]$Issuer, [string]$KeyId, $RSA, [int]$ExpirationSec = 3600) {
    $Header = @{
        alg = 'RS256'
        typ = 'JWT'
        kid = $KeyId
    }

    $iat = [DateTimeOffset]::UtcNow
    $exp = $iat.AddSeconds($ExpirationSec)
    $Payload = @{
        iss = $Issuer
        iat = $iat.ToUnixTimeSeconds()
        exp = $exp.ToUnixTimeSeconds()
        aud = $GDriveOAuth2Audience
        scope = $GDriveAuthScope
    }

    $Header = $Header | ConvertTo-Json -Compress
    $Payload = $Payload | ConvertTo-Json -Compress

    $EncodedHeader = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Header)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    $EncodedPayload = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Payload)).Split('=')[0].Replace('+', '-').Replace('/', '_')

    $ToBeSigned = "$EncodedHeader.$EncodedPayload"
    $toSign = [System.Text.Encoding]::UTF8.GetBytes($ToBeSigned)

    $SigningAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
    $Signature = $RSA.SignData($toSign, $SigningAlgorithm, [Security.Cryptography.RSASignaturePadding]::Pkcs1)
    $Signature = [Convert]::ToBase64String($Signature).Split('=')[0].Replace('+', '-').Replace('/', '_')

    $Token = "$EncodedHeader.$EncodedPayload.$Signature"
    $Token
}
