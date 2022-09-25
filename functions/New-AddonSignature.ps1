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