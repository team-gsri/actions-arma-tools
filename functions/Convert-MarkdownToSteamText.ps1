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
    return $dom.body.childNodes | & $PSScriptRoot/ConvertTo-SteamText.ps1
}
