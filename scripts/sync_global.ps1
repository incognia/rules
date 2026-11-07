<#
.SYNOPSIS
    Install the repository's skills, Warp workflows and rules into the global
    locations each tool reads, on native Windows (PowerShell 7 or Windows
    PowerShell 5.1). Counterpart of scripts/sync_global.sh, which covers
    macOS, Linux and WSL.

.DESCRIPTION
    1. Mirrors every .agents/skills/<name>/ into ~/.agents/skills (files
       deleted inside a skill are pruned) and removes skills it installed
       earlier that no longer exist in the repository.
    2. Links ~/.claude/commands/<name>.md to each installed SKILL.md, only for
       skills from this repository, never overwriting a command it does not
       own, and removes dangling links. When Windows refuses the symbolic link
       (Developer Mode off and no elevation) it copies the file instead and
       records it in .rules-managed-commands, so later runs keep it updated.
    3. When Antigravity CLI is installed, links each installed skill directory
       into ~/.gemini/antigravity-cli/skills/ (symbolic link, or a junction
       when that is refused) and removes dangling links there.
    4. Copies .warp/workflows/*.yaml to %APPDATA%\warp\Warp\data\workflows and
       removes workflows it installed earlier that left the repository.
    5. When the clone is not ~/rules itself, copies cot/, rulesets/,
       templates/ and scripts/atlassian/ to ~/rules, plus .env readable only
       by the current user.

    The managed lists (.rules-managed-skills, .rules-managed-workflows) use the
    same format as sync_global.sh, so both scripts can share a destination.

.PARAMETER UserHome
    Home directory to install into (default: $HOME). Meant for tests.

.EXAMPLE
    .\scripts\sync_global.ps1

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File $HOME\rules\scripts\sync_global.ps1

.NOTES
    Author: Rodrigo Álvarez (incognia) <incognia@gmail.com>
    Licence: GNU General Public License v3.0 (GPLv3)
#>

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$UserHome = $HOME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

trap {
    Write-Host "x Synchronisation aborted: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

function Stop-Sync([string]$Message) {
    Write-Host "Error: $Message" -ForegroundColor Red
    exit 1
}

if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    Stop-Sync 'this script is for native Windows; on macOS, Linux and WSL run scripts/sync_global.sh'
}

# ------------------------------------------------------------------ helpers

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Get-FullPath([string]$Path) {
    if ($Path.StartsWith('\??\')) { $Path = $Path.Substring(4) }
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
}

# Names read back from a managed list, ignoring blanks and anything path-like.
function Read-ManagedList([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return @() }
    return @(Get-Content -LiteralPath $Path | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and $_ -notmatch '[\\/]' -and $_ -ne '.' -and $_ -ne '..' })
}

# LF line endings and no BOM, so sync_global.sh (WSL) can read the same list.
function Write-ManagedList([string]$Path, [string[]]$Names) {
    $tmp = "$Path.tmp"
    $text = (@($Names) | ForEach-Object { "$_`n" }) -join ''
    [System.IO.File]::WriteAllText($tmp, $text, $Utf8NoBom)
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

# robocopy copies hidden files and, with -Purge, deletes what the source no
# longer has (the equivalent of rsync -a --delete). Exit codes 0-7 mean success.
function Copy-Tree([string]$Source, [string]$Destination, [switch]$Purge) {
    $roboArgs = @($Source, $Destination, '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:1', '/W:1')
    if ($Purge) { $roboArgs += '/PURGE' }
    & robocopy @roboArgs | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy failed (exit $LASTEXITCODE) copying $Source to $Destination"
    }
    $global:LASTEXITCODE = 0
}

function Get-ItemOrNull([string]$Path) {
    return Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
}

function Test-IsLink($Item) {
    return $null -ne $Item -and ($Item.LinkType -eq 'SymbolicLink' -or $Item.LinkType -eq 'Junction')
}

function Get-LinkTarget($Item) {
    $target = @($Item.Target)[0]
    if (-not $target) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($target)) {
        $target = Join-Path (Split-Path -Parent $Item.FullName) $target
    }
    return Get-FullPath $target
}

# True when a link target lives inside the skills directory this script manages.
function Test-PointsIntoSkills([string]$Target) {
    return $Target -and $Target.StartsWith($SkillsDst + '\', [System.StringComparison]::OrdinalIgnoreCase)
}

# Removes a link without touching its target (Remove-Item -Recurse on a
# directory link can delete the target's contents in Windows PowerShell 5.1).
function Remove-Link($Item) {
    if ($Item -is [System.IO.DirectoryInfo]) {
        [System.IO.Directory]::Delete($Item.FullName, $false)
    } else {
        [System.IO.File]::Delete($Item.FullName)
    }
}

# Symbolic link first; returns $false when Windows refuses it.
function New-SymbolicLinkSafe([string]$Path, [string]$Target) {
    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# ------------------------------------------------------------------ locate the repository

$RepoRoot = Get-FullPath (Join-Path $PSScriptRoot '..')
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.agents\skills') -PathType Container) -or
    -not (Test-Path -LiteralPath (Join-Path $RepoRoot '.warp\workflows') -PathType Container) -or
    -not (Test-Path -LiteralPath (Join-Path $RepoRoot 'scripts\sync_global.ps1') -PathType Leaf)) {
    Stop-Sync "$RepoRoot does not look like a clone of the rules repository.
  git clone git@github.com:incognia/rules.git `$HOME\rules; & `$HOME\rules\scripts\sync_global.ps1"
}

$UserHome = Get-FullPath $UserHome

Write-Host 'Platform: windows (PowerShell)'
Write-Host "Repository: $RepoRoot"
Write-Host ''

# ------------------------------------------------------------------ skills

$SkillsSrc = Join-Path $RepoRoot '.agents\skills'
$SkillsDst = Join-Path $UserHome '.agents\skills'

Write-Host '=== Skills ==='
New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null
$ManagedSkillsFile = Join-Path $SkillsDst '.rules-managed-skills'

# Legacy skills that were renamed or removed before the managed list existed.
foreach ($legacy in 'changelog', 'cad-access') {
    $installed = Join-Path $SkillsDst $legacy
    if ((Test-Path -LiteralPath $installed) -and -not (Test-Path -LiteralPath (Join-Path $SkillsSrc $legacy))) {
        Remove-Item -LiteralPath $installed -Recurse -Force
        Write-Host "  - removed legacy skill: $legacy"
    }
}

# Remove skills installed earlier by this script that left the repository.
foreach ($managed in Read-ManagedList $ManagedSkillsFile) {
    $installed = Join-Path $SkillsDst $managed
    if (-not (Test-Path -LiteralPath (Join-Path $SkillsSrc $managed) -PathType Container) -and
        (Test-Path -LiteralPath $installed)) {
        Remove-Item -LiteralPath $installed -Recurse -Force
        Write-Host "  - removed obsolete skill: $managed"
    }
}

$skillNames = @()
foreach ($dir in Get-ChildItem -LiteralPath $SkillsSrc -Directory | Sort-Object Name) {
    Copy-Tree $dir.FullName (Join-Path $SkillsDst $dir.Name) -Purge
    $skillNames += $dir.Name
    Write-Host "  + $($dir.Name)"
}
Write-ManagedList $ManagedSkillsFile $skillNames
Write-Host "  $($skillNames.Count) skills synchronised -> $SkillsDst"
Write-Host ''

# ------------------------------------------------------------------ Claude Code
# ~/.claude/commands/<name>.md -> installed SKILL.md, so Claude Code exposes
# /<name>. The link points at the copy in SkillsDst, as in sync_global.sh.

Write-Host '=== Claude Code ==='
$CommandsDir = Join-Path $UserHome '.claude\commands'
New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
$ManagedCommandsFile = Join-Path $CommandsDir '.rules-managed-commands'
$previousCopies = Read-ManagedList $ManagedCommandsFile

$copies = @()
$linked = 0
foreach ($name in $skillNames) {
    $src = Join-Path $SkillsDst "$name\SKILL.md"
    $link = Join-Path $CommandsDir "$name.md"
    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { continue }

    $item = Get-ItemOrNull $link
    if ($null -ne $item) {
        if (Test-IsLink $item) {
            if (-not (Test-PointsIntoSkills (Get-LinkTarget $item))) {
                Write-Host "  ! $name.md is a link not managed by this script; left untouched"
                continue
            }
        } elseif ($previousCopies -notcontains "$name.md") {
            Write-Host "  ! $name.md already exists as a regular file; left untouched"
            continue
        }
        Remove-Link $item
    }

    if (New-SymbolicLinkSafe $link $src) {
        Write-Host "  + $name.md -> $src"
    } else {
        Copy-Item -LiteralPath $src -Destination $link -Force
        $copies += "$name.md"
        Write-Host "  + $name.md (copy: symbolic links are not allowed; enable Developer Mode)"
    }
    $linked++
}

# Remove dangling links into the skills directory and copies of removed skills.
foreach ($item in @(Get-ChildItem -LiteralPath $CommandsDir -Filter '*.md' -Force)) {
    if (Test-IsLink $item) {
        $target = Get-LinkTarget $item
        if ((Test-PointsIntoSkills $target) -and -not (Test-Path -LiteralPath $target)) {
            Remove-Link $item
            Write-Host "  - removed dangling link: $($item.Name)"
        }
    } elseif ($previousCopies -contains $item.Name -and $copies -notcontains $item.Name -and
              $skillNames -notcontains $item.BaseName) {
        Remove-Item -LiteralPath $item.FullName -Force
        Write-Host "  - removed obsolete copy: $($item.Name)"
    }
}
Write-ManagedList $ManagedCommandsFile $copies
Write-Host "  $linked skills linked -> $CommandsDir"
Write-Host ''

# ------------------------------------------------------------------ Antigravity CLI
# Antigravity CLI does not read ~/.agents/skills; each installed skill
# directory is linked into ~/.gemini/antigravity-cli/skills/. A junction needs
# no privilege, so it is the fallback when a symbolic link is refused.

$AgyHome = Join-Path $UserHome '.gemini\antigravity-cli'
if (Test-Path -LiteralPath $AgyHome -PathType Container) {
    Write-Host '=== Antigravity CLI ==='
    $AgySkillsDir = Join-Path $AgyHome 'skills'
    New-Item -ItemType Directory -Force -Path $AgySkillsDir | Out-Null

    $agyLinked = 0
    foreach ($name in $skillNames) {
        $src = Join-Path $SkillsDst $name
        $link = Join-Path $AgySkillsDir $name
        if (-not (Test-Path -LiteralPath (Join-Path $src 'SKILL.md') -PathType Leaf)) { continue }

        $item = Get-ItemOrNull $link
        if ($null -ne $item) {
            if (-not (Test-IsLink $item)) {
                Write-Host "  ! $name already exists as a regular directory; left untouched"
                continue
            }
            if (-not (Test-PointsIntoSkills (Get-LinkTarget $item))) {
                Write-Host "  ! $name is a link not managed by this script; left untouched"
                continue
            }
            Remove-Link $item
        }
        if (-not (New-SymbolicLinkSafe $link $src)) {
            New-Item -ItemType Junction -Path $link -Target $src | Out-Null
        }
        $agyLinked++
        Write-Host "  + $name -> $src"
    }

    foreach ($item in @(Get-ChildItem -LiteralPath $AgySkillsDir -Force)) {
        if (-not (Test-IsLink $item)) { continue }
        $target = Get-LinkTarget $item
        if ((Test-PointsIntoSkills $target) -and -not (Test-Path -LiteralPath $target)) {
            Remove-Link $item
            Write-Host "  - removed dangling link: $($item.Name)"
        }
    }
    Write-Host "  $agyLinked skills linked -> $AgySkillsDir"
    Write-Host ''
}

# ------------------------------------------------------------------ Warp workflows

Write-Host '=== Workflows ==='
$WorkflowsSrc = Join-Path $RepoRoot '.warp\workflows'
if ($env:APPDATA) {
    $WorkflowsDst = Join-Path $env:APPDATA 'warp\Warp\data\workflows'
} else {
    $WorkflowsDst = Join-Path $UserHome '.warp\workflows'
    Write-Host "  Note: APPDATA not set, using $WorkflowsDst"
}
New-Item -ItemType Directory -Force -Path $WorkflowsDst | Out-Null
$ManagedWorkflowsFile = Join-Path $WorkflowsDst '.rules-managed-workflows'

foreach ($managed in Read-ManagedList $ManagedWorkflowsFile) {
    $installed = Join-Path $WorkflowsDst $managed
    if (-not (Test-Path -LiteralPath (Join-Path $WorkflowsSrc $managed) -PathType Leaf) -and
        (Test-Path -LiteralPath $installed -PathType Leaf)) {
        Remove-Item -LiteralPath $installed -Force
        Write-Host "  - removed obsolete workflow: $managed"
    }
}

$workflowNames = @()
foreach ($wf in Get-ChildItem -LiteralPath $WorkflowsSrc -Filter '*.yaml' -File | Sort-Object Name) {
    Copy-Item -LiteralPath $wf.FullName -Destination (Join-Path $WorkflowsDst $wf.Name) -Force
    $workflowNames += $wf.Name
    Write-Host "  + $($wf.Name)"
}
Write-ManagedList $ManagedWorkflowsFile $workflowNames
Write-Host "  $($workflowNames.Count) workflows synchronised -> $WorkflowsDst"
Write-Host ''

# ------------------------------------------------------------------ rules content

Write-Host '=== Rules (cot, rulesets, templates, scripts/atlassian, .env) ==='
$RulesDst = Join-Path $UserHome 'rules'
$rulesResolved = if (Test-Path -LiteralPath $RulesDst) { Get-FullPath (Resolve-Path -LiteralPath $RulesDst).ProviderPath } else { $RulesDst }

if ($RepoRoot -ieq $rulesResolved) {
    Write-Host "  The clone is $RulesDst itself; nothing to copy."
} elseif (Test-Path -LiteralPath (Join-Path $RulesDst '.git')) {
    Write-Host "  ! $RulesDst is another git checkout; not copying into it (update it with git pull)."
} else {
    foreach ($part in 'cot', 'rulesets', 'templates', 'scripts\atlassian') {
        Copy-Tree (Join-Path $RepoRoot $part) (Join-Path $RulesDst $part)
        Write-Host "  + $part -> $(Join-Path $RulesDst $part)"
    }
    $envSrc = Join-Path $RepoRoot '.env'
    if (Test-Path -LiteralPath $envSrc -PathType Leaf) {
        $envDst = Join-Path $RulesDst '.env'
        Copy-Item -LiteralPath $envSrc -Destination $envDst -Force
        # Equivalent of mode 600: no inherited entries, only the current user.
        $me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls $envDst /inheritance:r /grant:r "${me}:(R,W)" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ! could not restrict the permissions of $envDst (icacls exit $LASTEXITCODE)"
        } else {
            Write-Host "  + .env -> $envDst (current user only, untracked)"
        }
        $global:LASTEXITCODE = 0
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $RulesDst '.env') -PathType Leaf)) {
    Write-Host "  ! No $(Join-Path $RulesDst '.env'): copy .env.example to .env and fill in the Atlassian credentials"
}
Write-Host ''

Write-Host 'Synchronisation complete.'
exit 0
