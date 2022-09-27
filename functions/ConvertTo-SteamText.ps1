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
