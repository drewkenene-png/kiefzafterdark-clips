--[[
	CodesConfig (ModuleScript)
	Put this in: ServerScriptService

	This is the ONLY file you edit to add, change or kill codes.

	Each code:
	  Reward   = what they get. Types below.
	  Expires  = optional. Date "YYYY-MM-DD" (UTC). Leave out for no expiry.
	  MaxUses  = optional. Total redemptions across ALL players. Leave out for unlimited.
	  Enabled  = set to false to turn a code off without deleting it.

	Reward types:
	  { Type = "Coins",    Amount = 500 }
	  { Type = "Potion",   PotionId = "Speed", Amount = 1 }
	  { Type = "Research", Amount = 100 }
	  { Type = "Bundle",   Items = { {Type="Coins",Amount=250}, {Type="Potion",PotionId="Luck",Amount=2} } }

	PotionIds: Speed, XP, Luck, Giant, Coin, Celestial, Golden
	Codes are NOT case sensitive. "RELEASE" and "release" are the same.
]]

local function coins(n) return { Type = "Coins", Amount = n } end
local function potion(id, n) return { Type = "Potion", PotionId = id, Amount = n or 1 } end
local function bundle(...) return { Type = "Bundle", Items = { ... } } end

return {
	-------------------------------------------------- Launch
	RELEASE      = { Reward = coins(1000) },
	WELCOME      = { Reward = bundle(coins(500), potion("Speed")) },
	FREEPOTION   = { Reward = potion("Luck") },
	FLOATINGGUYS = { Reward = coins(750) },
	FLOATING     = { Reward = potion("XP") },
	EARLYACCESS  = { Reward = bundle(coins(1500), potion("Celestial")) },

	-------------------------------------------------- Milestones (off until you hit them)
	["1KVISITS"]  = { Reward = potion("Giant"), Enabled = false },
	["10KVISITS"] = { Reward = bundle(coins(2500), potion("Luck")), Enabled = false },
	["100LIKES"]  = { Reward = potion("Celestial"), Enabled = false },
	["1KLIKES"]   = { Reward = potion("Golden"), Enabled = false },

	-------------------------------------------------- Limited
	FIRST100 = { Reward = potion("Golden"), MaxUses = 100 },
	WEEKEND  = { Reward = potion("Luck", 2), Expires = "2026-10-12" },

	-------------------------------------------------- Secret (hide in clips)
	POTIONMASTER = { Reward = bundle(
		potion("Speed"), potion("XP"), potion("Luck"), potion("Giant"),
		potion("Coin"), potion("Celestial"), potion("Golden")
	) },
	BLENDER    = { Reward = potion("Celestial", 2) },
	NIGHTSHIFT = { Reward = coins(3000) },
}
