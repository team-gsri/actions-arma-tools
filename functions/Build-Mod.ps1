[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Source must ba a valid directory' } })]
    [string]
    $Source,

    [Parameter()]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Source must ba a valid directory' } })]
    [string]
    $Target = ${env:RUNNER_TEMP},

    [Parameter(Mandatory)]
    [ValidatePattern('[\w.-_]+')]
    [string]
    $Name,

    [Parameter()]
    [string]
    $Product,

    [Parameter(Mandatory)]
    [version]
    $Version,

    [Parameter()]
    [ValidatePattern('[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')]
    [string]
    $Url = 'https://www.gsri.team',

    [Parameter()]
    [string]
    $Author = 'www.gsri.team',

    [Parameter()]
    [ValidateScript({ if (Test-Path $_ -PathType Leaf) { $true } else { Throw '-Image must ba a valid file' } })]
    [string]
    $Image,

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ArmaToolsPath must be a directory' })]
    [string]
    $ArmaToolsPath = ${env:ARMA3TOOLS}
)

Begin {

    if (!(Test-Path -Path $Target/$Name/addons -PathType Container)) {
        New-Item -Path $Target/$Name/addons -ItemType Directory | Out-Null
    }

    if (!(Test-Path -Path $Target/$Name/keys -PathType Container)) {
        New-Item -Path $Target/$Name/keys -ItemType Directory | Out-Null
    }

}

Process {

    # copy and sign pbo files
    $keypair = & $PSScriptRoot\New-BohemiaKeyPair.ps1 -Target $Target/$Name/keys -Authority "${Name}-${Version}" -ArmaToolsPath $ArmaToolsPath
    Get-ChildItem -Path $Source -Recurse -Filter '*.pbo' |`
        Copy-Item -Destination $Target/$Name/addons -PassThru |`
        & $PSScriptRoot\New-AddonSignature.ps1 -Key $keypair.PrivateKey -ArmaToolsPath $ArmaToolsPath
    Remove-Item -Force $keypair.PrivateKey

    # make mod.cpp and copy image
    & $PSScriptRoot\New-ModCpp.ps1 -Target $Target/$Name -Name "${Product} ${Version}" -Url $Url -Author $Author -Image $Image
    Copy-Item -Path $Image -Destination $Target/$Name

    # compress to zip file
    Compress-Archive "$Target/$Name" "$Target/$Name.zip"
}