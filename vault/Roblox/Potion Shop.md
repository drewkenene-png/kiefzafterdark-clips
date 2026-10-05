# Potion Shop

#roblox #project

The potion stall in the game. Seven potions, each with a `PotionId`, sold through the Research Points shop window.

## Potions
| Potion | Id | Liquid look | Drink effect |
|---|---|---|---|
| [[Roblox/Potions/Speed Potion\|Speed]] | `Speed` | cyan, streaky | move faster for a while |
| [[Roblox/Potions/XP Potion\|XP]] | `XP` | green, rising sparkles | more XP per action |
| [[Roblox/Potions/Luck Potion\|Luck]] | `Luck` | emerald, clover particles | better drop rates |
| [[Roblox/Potions/Giant Potion\|Giant]] | `Giant` | orange-red, thick bubbles | player grows in size |
| [[Roblox/Potions/Coin Potion\|Coin]] | `Coin` | gold, spinning coin flecks | more coins per action |
| [[Roblox/Potions/Celestial Potion\|Celestial]] | `Celestial` | deep purple, stars | rare / cosmic bonus |
| [[Roblox/Potions/Golden Potion\|Golden]] | `Golden` | molten gold, glow | premium all-round boost |

## What we're building
- [ ] Potions hover and bob on the shelf #todo
- [ ] Bounce when the player looks at or hovers a potion #todo
- [ ] Hover card shows name + effect, pulling from the same data the shop window uses #todo
- [ ] Liquid colour and particles match the described effect #todo
- [ ] Drink effect actually runs when a potion is used #todo
- [ ] Rebuild station and blender models if the old ones don't fit #todo

## Notes
- Hover card should read the **same potion data module** the Research Points shop uses, so text never drifts from the real effect.
- Keep effects server-side, with the client only doing visuals.

## Related
- [[Roblox/Roblox Dev Notes]]
