[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$VenvPath = Join-Path $ProjectRoot '.venv-model-recovery'
$RequirementsPath = Join-Path $ProjectRoot 'requirements-model-recovery.txt'

function Find-UsablePython {
    $candidates = @(
        @{ Command = 'py'; Arguments = @('-3.12') },
        @{ Command = 'py'; Arguments = @('-3.11') },
        @{ Command = 'python'; Arguments = @() },
        @{ Command = 'python3'; Arguments = @() }
    )

    foreach ($candidate in $candidates) {
        $resolved = Get-Command $candidate.Command -ErrorAction SilentlyContinue
        if ($null -eq $resolved) {
            continue
        }

        try {
            $command = $candidate.Command
            $commandArguments = @($candidate.Arguments)
            $versionOutput = & $command @commandArguments --version 2>&1
            if ($LASTEXITCODE -eq 0 -and "$versionOutput" -match '^Python 3\.(11|12)\.') {
                return @{
                    Command = $candidate.Command
                    Arguments = $candidate.Arguments
                    Version = "$versionOutput"
                }
            }
        }
        catch {
            continue
        }
    }

    return $null
}

$Python = Find-UsablePython
if ($null -eq $Python) {
    Write-Host 'No usable Python 3.11 or 3.12 command was found.' -ForegroundColor Yellow
    Write-Host 'Windows Store Python aliases do not count as a working installation.'
    Write-Host 'Install Python 3.11 or 3.12 from python.org or a trusted package manager, then rerun this script.'
    Write-Host 'During installation, enable the option to add Python to PATH.'
    exit 2
}

if (-not (Test-Path -LiteralPath $RequirementsPath)) {
    Write-Error "Requirements file not found: $RequirementsPath"
    exit 3
}

Write-Host "Using $($Python.Version)"
Write-Host "Creating virtual environment: $VenvPath"
$pythonCommand = $Python.Command
$pythonArguments = @($Python.Arguments)
& $pythonCommand @pythonArguments -m venv $VenvPath

$VenvPython = Join-Path $VenvPath 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $VenvPython)) {
    Write-Error "Virtual environment creation did not produce: $VenvPython"
    exit 4
}

Write-Host 'Upgrading pip...'
& $VenvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to upgrade pip in the model-recovery environment.'
    exit 5
}

Write-Host 'Installing model-recovery requirements...'
& $VenvPython -m pip install -r $RequirementsPath
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to install model-recovery requirements.'
    exit 6
}

Write-Host ''
Write-Host 'Model-recovery environment is ready.' -ForegroundColor Green
Write-Host 'Next commands:'
Write-Host ".\.venv-model-recovery\Scripts\python.exe tools\inspect_tflite.py"
Write-Host ".\.venv-model-recovery\Scripts\python.exe tools\run_tflite_inference.py --help"
