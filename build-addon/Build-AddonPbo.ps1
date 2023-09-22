[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Source must be a directory' })]
    [string]
    $Source,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Target must be a directory' })]
    [string]
    $Target,

    [Parameter(Mandatory)]
    [string]
    $Prefix,

    [Parameter(Mandatory)]
    [string]
    $Includes,

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ArmaToolsPath must be a directory' })]
    [string]
    $ArmaToolsPath = ${env:ARMA3TOOLS}
)

Begin {

    $addonBuilderExe = Join-Path -Path $ArmaToolsPath -ChildPath 'AddonBuilder/AddonBuilder.exe'
    if (-Not (Test-Path -Path $addonBuilderExe -PathType Leaf)) {
        Throw 'AddonBuilder.exe not found'
    }

    $Source = Resolve-Path $Source.TrimEnd('/\')
    $Target = Resolve-Path $Target.TrimEnd('/\')

    $includesFilename = New-TemporaryFile
    Set-Content -Path $includesFilename -Value $Includes

}

Process {
    if ($PSCmdlet.ShouldProcess($Source)) {
        & $addonBuilderExe $Source $Target "-toolsDirectory=$ArmaToolsPath" -clear "-prefix=$Prefix" "-include=$includesFilename"
    }
}

End {
    Remove-Item $includesFilename -Force
}
