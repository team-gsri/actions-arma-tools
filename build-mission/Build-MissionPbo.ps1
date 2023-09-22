[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Source must ba a valid directory' })]
    [string]
    $Source,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Target must ba a valid directory' })]
    [string]
    $Target,

    [Parameter()]
    [string]
    $BriefingName = '',

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ArmaToolsPath must be a directory' })]
    [string]
    $ArmaToolsPath = ${env:ARMA3TOOLS}
)

Begin {

    $cfgConvertExe = Join-Path -Path $ArmaToolsPath -ChildPath 'CfgConvert/CfgConvert.exe'
    if (-Not (Test-Path -Path $cfgConvertExe -PathType Leaf)) {
        Throw 'CfgConvert.exe not found'
    }

    $fileBankExe = Join-Path -Path $ArmaToolsPath -ChildPath 'FileBank/FileBank.exe'
    if (-Not (Test-Path -Path $fileBankExe -PathType Leaf)) {
        Throw 'FileBank.exe not found'
    }

    $missionFilename = Join-Path $Source -ChildPath 'mission.sqm'
    if (-Not (Test-Path -Path $missionFilename -PathType Leaf)) {
        Throw 'mission.sqm file not found'
    }

    $Source = Resolve-Path $Source.TrimEnd('/\')
    $Target = Resolve-Path $Target.TrimEnd('/\')
    $BriefingName = $BriefingName -Replace ( '"', '' )

}

Process {

    if ($BriefingName -ne '') {
        $(Get-Content $missionFilename) -Replace (
            'briefingName="[^"]*";',
            "briefingName=""$BriefingName"";"
        ) | Set-Content -LiteralPath $missionFilename
    }

    & $cfgConvertExe -bin -dst "$missionFilename" "$missionFilename"
    & $fileBankExe -dst $Target $Source

}