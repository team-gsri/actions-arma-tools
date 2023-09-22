function New-AddonSignature {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateScript({ if (Test-Path $_ -PathType Leaf) { $true } else { Throw '-Path  must ba a valid file' } })]
        [string[]]
        $Path,

        [Parameter(Mandatory)]
        [ValidateScript({ if (Test-Path $_ -PathType Leaf) { $true } else { Throw '-Key  must ba a valid file' } })]
        [string]
        $Key,

        [Parameter()]
        [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ArmaToolsPath must be a directory' })]
        [string]
        $ArmaToolsPath = ${env:ARMA3TOOLS}
    )

    Begin {

        $dsSignExe = Join-Path -Path $ArmaToolsPath -ChildPath 'DSSignFile/DSSignFile.exe'
        if (-Not (Test-Path -Path $dsSignExe -PathType Leaf)) {
            Throw 'DSSignFile.exe not found'
        }

    }

    Process {
        & $dsSignExe $Key $Path
    }
}

function New-ModCpp {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Target must be a directory' })]
        [string]
        $Target,

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter()]
        [ValidatePattern('[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')]
        [string]
        $Url = 'https://www.gsri.team',

        [Parameter()]
        [string]
        $Author = 'www.gsri.team',

        [Parameter()]
        [ValidateScript({ Test-Path $_ -PathType Leaf || Throw '-Image must be a file' })]
        [string]
        $Image
    )

    Begin {
        $filename = Join-Path -Path $Target -ChildPath 'mod.cpp'
        $imagePath = Split-Path $Image -Leaf
    }

    Process {
        @"
name = "${Name}";
actionName = "Website";
action = "${Url}";
author = "${Author}";
picture = "${imagePath}";
logo = "${imagePath}";
logoOver = "${imagePath}";
overviewPicture = "${imagePath}";
"@ | Set-Content $filename
    }
}

function New-BohemiaKeyPair {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Target must be a directory' })]
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
}

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Source must be a directory' })]
    [string]
    $Source,

    [Parameter(Mandatory)]
    [ValidatePattern('[\w.-_]+')]
    [string]
    $Name,

    [Parameter(Mandatory)]
    [string]
    $Product,

    [Parameter(Mandatory)]
    [version]
    $Version,

    [Parameter(Mandatory)]
    [ValidatePattern('[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')]
    [string]
    $Url,

    [Parameter(Mandatory)]
    [string]
    $Author,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf || Throw '-Image must be a valid file' })]
    [string]
    $Image,

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-Target must be a directory' })]
    [string]
    $Target = ${env:RUNNER_TEMP},

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
    $keypair = New-BohemiaKeyPair -Target $Target/$Name/keys -Authority "${Name}-${Version}" -ArmaToolsPath $ArmaToolsPath

    Get-ChildItem -Path $Source -Recurse -Filter '*.pbo' |`
        Copy-Item -Destination $Target/$Name/addons -PassThru |`
        New-AddonSignature -Key $keypair.PrivateKey -ArmaToolsPath $ArmaToolsPath

    Remove-Item -Force $keypair.PrivateKey
    New-ModCpp -Target $Target/$Name -Name "${Product} ${Version}" -Url $Url -Author $Author -Image $Image
    Copy-Item -Path $Image -Destination $Target/$Name
    Compress-Archive "$Target/$Name" "$Target/$Name.zip"
}