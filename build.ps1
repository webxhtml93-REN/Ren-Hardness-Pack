# =============================================================================
# build.ps1  —  Ren Hardness Complete Mod  —  Zero-Touch Package Builder
# Patched by Osamu_Ren
#
# Merges Ren-Hardness-Mod + Ren-Tiered-Hardness-Mod into a single
# installable 7 Days to Die mod folder, then zips it for distribution.
#
# Usage:  .\build.ps1
# Output: Release\Ren-Hardness-Complete-Mod-1.0\   (drop into Mods/)
#         Release\Ren-Hardness-Complete-Mod-1.0.zip (distribute this)
# =============================================================================

$ErrorActionPreference = "Stop"

$ModName   = "Ren-Hardness-Complete-Mod-1.0"
$ScriptDir = $PSScriptRoot
$Src1      = "$ScriptDir\Ren-Hardness-Mod-1.0"
$Src2      = "$ScriptDir\Ren-Tiered-Hardness-Mod-1.0"
$OutMod    = "$ScriptDir\Release\$ModName"
$OutConfig = "$OutMod\Config"
$OutZip    = "$ScriptDir\Release\$ModName.zip"

# ── Validate sources ──────────────────────────────────────────────────────────
foreach ($src in @($Src1, $Src2)) {
    if (-not (Test-Path $src)) {
        Write-Error "Source not found: $src"
        exit 1
    }
}

# ── Clean and scaffold output ─────────────────────────────────────────────────
Write-Host "Building $ModName..."
if (Test-Path "$ScriptDir\Release") { Remove-Item "$ScriptDir\Release" -Recurse -Force }
New-Item -ItemType Directory -Force $OutConfig | Out-Null

# ── Helper: merge two 7D2D mod XML files ─────────────────────────────────────
# Each mod XML has a custom root element whose children are patch operations.
# We import all children from both into a single new root, preserving order:
#   Phase 1 ops first  (Ren-Hardness-Mod)
#   Phase 2 ops second (Ren-Tiered-Hardness-Mod)
# This guarantees Phase 2 XPath targets created by Phase 1 already exist.
function Merge-ModXml {
    param(
        [string]$Path1,
        [string]$Path2,
        [string]$NewRoot,
        [string]$OutPath,
        [string]$Phase1Label,
        [string]$Phase2Label
    )
    $xml1   = [xml](Get-Content $Path1 -Raw -Encoding UTF8)
    $xml2   = [xml](Get-Content $Path2 -Raw -Encoding UTF8)
    $merged = [xml]"<$NewRoot/>"
    $root   = $merged.DocumentElement

    $root.AppendChild($merged.CreateComment(" Merged by build.ps1 - Patched by Osamu_Ren ")) | Out-Null
    $root.AppendChild($merged.CreateComment(" == Phase 1: $Phase1Label == ")) | Out-Null
    foreach ($node in $xml1.DocumentElement.ChildNodes) {
        $root.AppendChild($merged.ImportNode($node, $true)) | Out-Null
    }
    $root.AppendChild($merged.CreateComment(" == Phase 2: $Phase2Label == ")) | Out-Null
    foreach ($node in $xml2.DocumentElement.ChildNodes) {
        $root.AppendChild($merged.ImportNode($node, $true)) | Out-Null
    }

    $merged.Save($OutPath)
}

# ── Merge XML config files ────────────────────────────────────────────────────
Write-Host "  Merging blocks.xml..."
Merge-ModXml `
    "$Src1\Config\blocks.xml" `
    "$Src2\Config\blocks.xml" `
    "renHardnessComplete" `
    "$OutConfig\blocks.xml" `
    "Stainless Steel" `
    "Tiered Hard Steel T1-T3"

Write-Host "  Merging materials.xml..."
Merge-ModXml `
    "$Src1\Config\materials.xml" `
    "$Src2\Config\materials.xml" `
    "renHardnessComplete" `
    "$OutConfig\materials.xml" `
    "Stainless Steel" `
    "Tiered Hard Steel T1-T3"

# ── Copy single-source files ──────────────────────────────────────────────────
Write-Host "  Copying items.xml and recipes.xml..."
Copy-Item "$Src1\Config\items.xml"   "$OutConfig\items.xml"
Copy-Item "$Src1\Config\recipes.xml" "$OutConfig\recipes.xml"

# ── Merge localization.txt ────────────────────────────────────────────────────
Write-Host "  Merging localization.txt..."
$loc1     = Get-Content "$Src1\Config\localization.txt" -Encoding UTF8
$loc2     = Get-Content "$Src2\Config\localization.txt" -Encoding UTF8
$loc2Data = $loc2 | Where-Object { $_ -notmatch "^#" -and $_ -notmatch "^Key," -and $_.Trim() -ne "" }
($loc1 + $loc2Data) | Set-Content "$OutConfig\localization.txt" -Encoding UTF8

# ── ModInfo.xml ───────────────────────────────────────────────────────────────
Write-Host "  Writing ModInfo.xml..."
@'
<?xml version="1.0" encoding="UTF-8" ?>
<!-- Patched by Osamu_Ren -->
<xml>
	<Name value="Ren-Hardness-Complete-Mod" />
	<DisplayName value="Ren Hardness Complete Mod" />
	<Description value="Adds Stainless Steel and three tiers of Ultra-Hard Steel. Apply Steel Polish to any hardened block to advance its tier - no workbench needed. Steel -> Stainless -> T1 (30k HP) -> T2 (60k) -> T3 (120k HP)." />
	<Author value="Nyce" />
	<Version value="1.0" />
	<Website value="https://nyce-network.com/" />
</xml>
'@ | Set-Content "$OutMod\ModInfo.xml" -Encoding UTF8

# ── ReadMe.txt ────────────────────────────────────────────────────────────────
Write-Host "  Writing ReadMe.txt..."
@'
Ren Hardness Complete Mod v1.0
==============================
Author : Nyce
Website: https://nyce-network.com/

INSTALLATION
------------
1. Extract Ren-Hardness-Complete-Mod-1.0.zip
2. Copy the Ren-Hardness-Complete-Mod-1.0 folder into:
       7 Days To Die/Mods/
3. Start the game.

No additional steps required.

WHAT THIS MOD ADDS
------------------
Apply Steel Polish to any hardened block to advance its tier.
No new workbench crafting required beyond crafting the Polish itself.

Upgrade chain:
  Vanilla Steel Block
    -> Stainless Steel    (30,000 HP | +explosion resistance)
    -> T1 Hard Steel      (45,000 HP | hardened grade)
    -> T2 Hard Steel      (60,000 HP | double durability)
    -> T3 Hard Steel     (120,000 HP | maximum hardness)

Each higher tier also increases explosion resistance and structural
stability. T3 cannot be hardened further.

CRAFTING STEEL POLISH
---------------------
Workbench required.
  Ingredients : 10x Oil + 250x Forged Steel
  Output      : 200x Steel Polish
  Unlock      : Advanced Engineering (Tier 2+)

Repair any tier block with Steel Polish (1 per repair).
'@ | Set-Content "$OutMod\ReadMe.txt" -Encoding UTF8

# ── Package as zip ────────────────────────────────────────────────────────────
Write-Host "  Packaging zip..."
if (Test-Path $OutZip) { Remove-Item $OutZip -Force }
Compress-Archive -Path $OutMod -DestinationPath $OutZip

# ── Report ────────────────────────────────────────────────────────────────────
$files = Get-ChildItem $OutMod -Recurse -File
Write-Host ""
Write-Host "Build complete. Output:"
$files | ForEach-Object { Write-Host "  $($_.FullName.Replace($OutMod, $ModName))" }
Write-Host ""
Write-Host "  Zip : $OutZip ($([math]::Round((Get-Item $OutZip).Length / 1KB, 2)) KB)"
Write-Host ""
Write-Host "Installation: copy '$ModName' into 7 Days To Die/Mods/"
