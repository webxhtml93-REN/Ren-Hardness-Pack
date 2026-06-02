# Ren Tiered Hardness Mod

Standalone [7 Days to Die](https://7daystodie.com/) mod for **V 2.6**. Apply **Steel Polish** to any hardened block to advance it one durability tier — no base mod required, and no escalating resource cost per tier.

## Upgrade chain

| Stage           |      HP | Step     |
|-----------------|--------:|----------|
| Vanilla Steel   |   7,000 | —        |
| Stainless Steel |  40,000 | +33,000  |
| T1 Hard Steel   |  60,000 | +20,000  |
| T2 Hard Steel   |  90,000 | +30,000  |
| T3 Hard Steel   | 120,000 | +30,000  |

Higher tiers also raise explosion resistance and structural stability. T3 is the maximum and cannot be hardened further.

Craft **Steel Polish** at a workbench (10 Oil + 250 Forged Steel → 200 Polish; unlocked via Advanced Engineering), then apply it with a construction tool (claw hammer / nailgun) to bump a block one tier.

## Installation

1. Download `Ren-Tiered-Hardness-Mod.zip` from the [latest release](https://github.com/webxhtml93-REN/Ren-Hardness-Pack/releases/latest).
2. Extract it.
3. Copy the `Ren-Tiered-Hardness-Mod` folder into your `7 Days To Die/Mods/` folder.
4. Launch the game.

The zip extracts to a single mod folder — no restructuring needed.

## Compatibility

- **Game build:** 7 Days to Die **V 2.6** (stable) — verified loading in-game with no errors.
- **Type:** XML-only (no DLLs, no Harmony patches).
- **EAC:** Because there is no DLL, this mod loads with **EAC (anti-cheat) enabled** — you do **not** need to disable it. (Only DLL/code mods require EAC off.)
- **Multiplayer:** install on **both the server and every client** so the block/item data matches on both sides. EAC can remain on for a server you control.

## Building from source

```powershell
.\build.ps1
```

Packages the `Ren-Tiered-Hardness-Mod` folder into `Release\Ren-Tiered-Hardness-Mod.zip`. Dev-only files (e.g. `BlockNameReferences.txt`) are excluded from the package automatically.

## License / Author

Author: **Nyce** · <https://nyce-network.com/>
