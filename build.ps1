# =============================================================================
# build.ps1  —  Ren Tiered Hardness Mod  —  Package Builder
# Patched by Osamu_Ren
#
# Packages the standalone Ren-Tiered-Hardness-Mod into a distributable zip.
# (This is now a single self-contained mod — no merge step required.)
#
# Usage:  .\build.ps1
# Output: Release\Ren-Tiered-Hardness-Mod-1.0\   (drop into Mods/)
#         Release\Ren-Tiered-Hardness-Mod-1.0.zip (distribute this)
# =============================================================================

$ErrorActionPreference = "Stop"

$ModName   = "Ren-Tiered-Hardness-Mod-1.0"
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

# ── Copy the mod, excluding any stray build artifacts ─────────────────────────
Copy-Item "$Src\*" $OutMod -Recurse -Force

# ── Write ReadMe ──────────────────────────────────────────────────────────────
@'
Ren Tiered Hardness Mod v1.0  (standalone)
==========================================
Author : Nyce
Website: https://nyce-network.com/

INSTALLATION
------------
1. Extract Ren-Tiered-Hardness-Mod-1.0.zip
2. Copy the Ren-Tiered-Hardness-Mod-1.0 folder into:
       7 Days To Die/Mods/
3. Start the game.

No base mod and no additional steps required.

WHAT THIS MOD ADDS
------------------
Craft Steel Polish at a workbench, then apply it to any hardened block to
advance it one tier. Each step greatly increases durability:

  Vanilla Steel Block
    -> Stainless Steel    ( 40,000 HP)
    -> T1 Hard Steel      ( 60,000 HP)
    -> T2 Hard Steel      ( 90,000 HP)
    -> T3 Hard Steel      (120,000 HP)

Higher tiers also increase explosion resistance and structural stability.
T3 is the maximum and cannot be hardened further.

CRAFTING STEEL POLISH
---------------------
Workbench required.
  Ingredients : 10x Oil + 250x Forged Steel
  Output      : 200x Steel Polish
  Unlock      : Advanced Engineering
'@ | Set-Content "$OutMod\ReadMe.txt" -Encoding UTF8

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
