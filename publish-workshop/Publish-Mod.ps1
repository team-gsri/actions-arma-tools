function ConvertTo-SteamText {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [pscustomobject]
        $Node
    )

    Process {
        switch -regex ($Node.nodeName) {
            "H[1-9]" {
                return "[h1]$($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)[/h1]"
            }
            "UL" {
                return "[list]$($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)[/list]"
            }
            "LI" {
                return "[*]$($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)"
            }
            "P" {
                return -Join ($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)
            }
            "STRONG" {
                return "[b]$($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)[/b]"
            }
            "A" {
                return "[url=$($Node.href)]$($Node.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1)[/url]"
            }
            "#text" {
                return $Node.textContent -Replace ('"', '&quot;')
            }
            Default {
                return ""
            }
        }
    }
}

function Convert-MarkdownToSteam {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object[]]
        $Content
    )

    Process {
        $markdown = ($Content -Join "`n") | ConvertFrom-Markdown
        $dom = New-Object -Com 'HTMLFile'
        $dom.write([System.Text.Encoding]::Unicode.GetBytes($markdown.Html))
        return $dom.body.childNodes | ConvertTo-SteamText
    }
}

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [int]
    $AppId,

    [Parameter(Mandatory)]
    [ValidatePattern('[0-9]+')]
    [string]
    $ItemId,

    [Parameter(Mandatory)]
    [string]
    $Title,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-ContentPath must ba a valid directory' })]
    [string]
    $ContentPath,

    [Parameter()]
    [ValidateScript({ Test-Path $_ -PathType Container || Throw '-SteamCmd must ba a valid directory' })]
    [string]
    $SteamCmd = ${env:SteamCmd},

    [Parameter()]
    [string]
    $SteamLogin = ${env:STEAM_LOGIN},
)

Begin {

    if ($SteamLogin -eq '') {
        Throw 'SteamLogin is missing'
    }

    $Title = $Title -Replace ('"', '')
    $workshopItemFile = New-TemporaryFile
    $changenote = $(gh release view --json body -q .body)
    $changenote = Convert-MarkdownToSteamText -Content $changenote
}

Process {

    @"
"workshopitem"
{
    "appid"            "$AppId"
    "publishedfileid"  "$ItemId"
    "contentfolder"    "$ContentPath"
    "changenote"       "$changenote"
    "title"            "$Title"
}
"@ | Set-Content $workshopItemFile
    & $SteamCmd +login $SteamLogin +workshop_build_item $workshopItemFile +quit
}

End {
    Remove-Item $workshopItemFile -Force
}
