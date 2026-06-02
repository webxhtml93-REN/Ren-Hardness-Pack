# =============================================================================
# build.ps1  —  Ren Tiered Hardness Mod  —  Package Builder
# Patched by Osamu_Ren
#
# Packages the standalone Ren-Tiered-Hardness-Mod into a distributable zip.
# (This is now a single self-contained mod — no merge step required.)
#
# Usage:  .\build.ps1
# Output: Release\Ren-Tiered-Hardness-Mod\   (drop into Mods/)
#         Release\Ren-Tiered-Hardness-Mod.zip (distribute this)
# =============================================================================

$ErrorActionPreference = "Stop"

$ModName   = "Ren-Tiered-Hardness-Mod"
$ScriptDir = $PSScriptRoot
$Src       = "$ScriptDir\$ModName"
$OutDir    = "$ScriptDir\Release"
$OutMod    = "$OutDir\$ModName"
$OutZip    = "$OutDir\$ModName.zip"

if (-not (Test-Path $Src)) {
    Write-Error "Source not found: $Src"
    exit 1
}

Write-Host "Building $ModName..."

# ── Clean and stage ───────────────────────────────────────────────────────────
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force $OutMod | Out-Null

# ── Copy the mod, excluding dev-only files and stray build artifacts ──────────
Copy-Item "$Src\*" $OutMod -Recurse -Force
# Dev reference docs / junk that end users do not need:
foreach ($junk in @('BlockNameReferences.txt','bin','obj','.vs')) {
    $p = Join-Path $OutMod $junk
    if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}
Get-ChildItem $OutMod -Recurse -Include *.pdb,*.bak,*.tmp,*~ -ErrorAction SilentlyContinue | Remove-Item -Force

# ── Write end-user README.md ──────────────────────────────────────────────────
@'
# Ren Tiered Hardness Mod (v1.4)

Standalone 7 Days to Die mod for **V 2.6**. Apply **Steel Polish** to any
hardened block to advance it one durability tier. No base mod, no escalating
resource cost per tier.

## Upgrade chain

| Stage           |      HP |
|-----------------|--------:|
| Vanilla Steel   |   7,000 |
| Stainless Steel |  40,000 |
| T1 Hard Steel   |  60,000 |
| T2 Hard Steel   |  90,000 |
| T3 Hard Steel   | 120,000 |

Higher tiers also raise explosion resistance and stability. T3 is the maximum.

Craft Steel Polish at a workbench (10 Oil + 250 Forged Steel -> 200 Polish;
unlocked via Advanced Engineering), then apply it with a construction tool
(claw hammer / nailgun) to bump a block one tier.

## Installation

1. Extract `Ren-Tiered-Hardness-Mod.zip`.
2. Copy the `Ren-Tiered-Hardness-Mod` folder into `7 Days To Die/Mods/`.
3. Start the game.

## EAC & multiplayer

XML-only (no DLL), so it loads with **EAC (anti-cheat) enabled** -- you do not
need to disable anti-cheat. Only DLL/code mods require EAC off.

For multiplayer, install on **both the server and every client** so the
block/item data matches on both sides; EAC can stay on for a server you control.
'@ | Set-Content "$OutMod\README.md" -Encoding UTF8

# ── Package as zip ────────────────────────────────────────────────────────────
if (Test-Path $OutZip) { Remove-Item $OutZip -Force }
Compress-Archive -Path $OutMod -DestinationPath $OutZip

# ── Report ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Build complete. Output:"
Get-ChildItem $OutMod -Recurse -File | ForEach-Object {
    Write-Host "  $($_.FullName.Replace($OutMod, $ModName))"
}
Write-Host ""
Write-Host "  Zip : $OutZip ($([math]::Round((Get-Item $OutZip).Length / 1KB, 2)) KB)"
Write-Host ""
Write-Host "Installation: copy '$ModName' into 7 Days To Die/Mods/"
