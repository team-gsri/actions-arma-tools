[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Target must ba a valid directory' } })]
    [string]
    $Target,

    [Parameter(Mandatory)]
    [ValidatePattern('[\w-.]+')]
    [string]
    $Authority,

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ArmaToolsPath must be a directory' })]
    [string]
    $ArmaToolsPath = ${env:ARMA3TOOLS}
)

Begin {

    $dsCreateKeyExe = Join-Path -Path $ArmaToolsPath -ChildPath 'DSSignFile/DSCreateKey.exe'
    if (-Not (Test-Path -Path $dsCreateKeyExe -PathType Leaf)) {
        Throw 'DSCreateKey.exe not found'
    }

    $Target = Resolve-Path $Target.TrimEnd('/\')

}

Process {
    Push-Location
    Set-Location $Target
    & $dsCreateKeyExe $Authority
    Pop-Location
}

End {
    return @{
        PublicKey  = Join-Path -Path $Target -ChildPath "${Authority}.bikey"
        PrivateKey = Join-Path -Path $Target -ChildPath "${Authority}.biprivatekey"
    }
}