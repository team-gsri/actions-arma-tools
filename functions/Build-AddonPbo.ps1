[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Source must ba a valid directory' } })]
    [string]
    $Source,

    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Target must ba a valid directory' } })]
    [string]
    $Target,

    [Parameter(Mandatory)]
    [string]
    $Prefix,

    [Parameter(Mandatory)]
    [string]
    $Includes = '*.paa;*.png;*.jpg;*.xml;*.sqf;*.rtm;*.fsm;*.sqm;*.lip;*.ext;*.ogg;*.wss;*.txt;*.rvmat',

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
