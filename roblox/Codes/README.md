# Promo codes

Players type a code, press Redeem, and get free stuff once per account.

## Put it in Studio

| File | Make this in Studio | Where |
|---|---|---|
| `CodesConfig.lua` | **ModuleScript** named `CodesConfig` | ServerScriptService |
| `CodeService.server.lua` | **Script** named `CodeService` | ServerScriptService |
| `CodeRedeemGui.client.lua` | **LocalScript** named `CodeRedeemGui` | StarterPlayer → StarterPlayerScripts |

For each one: right-click the folder → Insert Object → pick the type → rename it → open it, delete the default text, paste the whole file.

Already have your own code GUI? Skip the LocalScript. From your GUI call
`ReplicatedStorage.RedeemCode:InvokeServer(codeText)`. It returns `success, message`.

Turn on saving: **Game Settings → Security → Enable Studio Access to API Services**, or codes won't remember who used them during Studio tests.

## The codes

| Code | Reward | Notes |
|---|---|---|
| `RELEASE` | 1,000 Coins | |
| `WELCOME` | 500 Coins + Speed Potion | |
| `FREEPOTION` | Luck Potion | |
| `FLOATINGGUYS` | 750 Coins | |
| `FLOATING` | XP Potion | |
| `EARLYACCESS` | 1,500 Coins + Celestial Potion | |
| `FIRST100` | Golden Potion | first 100 players only |
| `WEEKEND` | 2 Luck Potions | expires 2026-10-12, change the date each time |
| `POTIONMASTER` | one of every potion | secret, hide in a clip |
| `BLENDER` | 2 Celestial Potions | secret |
| `NIGHTSHIFT` | 3,000 Coins | secret |
| `1KVISITS` `10KVISITS` `100LIKES` `1KLIKES` | see config | off until you flip `Enabled = true` |

## Add or change codes

Only edit `CodesConfig`:

```lua
SUMMER = { Reward = coins(2000), Expires = "2026-08-31", MaxUses = 500 },
```

`Enabled = false` turns a code off without deleting it.

## Connect rewards to your game

`CodeService` has three small functions in the REWARDS section: `giveCoins`, `givePotion`, `giveResearch`. Each has a TODO. Out of the box they guess at `leaderstats.Coins`, a `Potions` folder on the player, and `leaderstats.Research`. Swap those lines for whatever your game really uses.

## Safety built in

- All checking is server-side. Players can't fake a reward.
- One use per player per code, saved to DataStore.
- Optional expiry and global use cap.
- 2 second cooldown per player.
- Code is marked used before the reward is paid, so a crash can't double-pay.
