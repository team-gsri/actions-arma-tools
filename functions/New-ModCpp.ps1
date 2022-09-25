[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { Throw '-Target must ba a valid directory' } })]
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
    [string]
    $Image
)

Begin {
    $filename = Join-Path -Path $Target -ChildPath 'mod.cpp'
}

Process {

    @"
name = "${Name}";
actionName = "Website";
action = "${Url}";
author = "${Author}";
"@ | Set-Content $filename

    if ($Image -ne '') {
        @"
picture = "${Image}";
logo = "${Image}";
logoOver = "${Image}";
overviewPicture = "${Image}";
"@ | Add-Content $filename
    }

}