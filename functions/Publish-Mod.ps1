[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()]
    [int]
    $AppId = 107410,

    [Parameter(Mandatory)]
    [ValidatePattern('[0-9]+')]
    [string]
    $ItemId,

    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Content must ba a valid directory' } })]
    [string]
    $Content,

    [Parameter()]
    [ValidateScript({ if (Test-Path $_ -PathType Leaf) { $true } else { Throw 'Steamcmd.exe not found' } })]
    [string]
    $SteamCmd = $env:SteamCmd
)

Begin {

    if ($env:STEAM_LOGIN -eq '') {
        Throw 'STEAM_LOGIN environment variable is missing'
    }

    if ($env:STEAM_PASSWD -eq '') {
        Throw 'STEAM_PASSWD environment variable is missing'
    }

    $workshopItemFile = New-TemporaryFile
    $changenote = $(gh release view --json body -q .body) -Replace ('"', '')
}

Process {

    @"
"workshopitem"
{
    "appid"            "$AppId"
    "publishedfileid"  "$ItemId"
    "contentfolder"    "$Content"
    "changenote"       "$changenote"
}
"@ | Set-Content $workshopItemFile
    & $SteamCmd +login $env:STEAM_LOGIN $env:STEAM_PASSWD +workshop_build_item $workshopItemFile +quit
}

End {
    Remove-Item $workshopItemFile -Force
}
