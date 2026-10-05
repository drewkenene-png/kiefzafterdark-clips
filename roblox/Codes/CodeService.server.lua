--[[
	CodeService (Script)
	Put this in: ServerScriptService

	Handles code redemption on the server. Players can never fake a reward
	because the client only sends the text they typed; everything else
	happens here.

	YOU NEED TO HOOK UP ONE THING: the three give* functions in the
	REWARDS section. Each has a TODO showing where to call your game's
	own coin, potion and research systems.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Codes = require(ServerScriptService:WaitForChild("CodesConfig"))

-- DataStores. Change the names if you ever need to wipe all redemptions.
local redeemedStore = DataStoreService:GetDataStore("PromoCodes_Redeemed_v1")
local usageStore = DataStoreService:GetDataStore("PromoCodes_Usage_v1")

-- Remote the client GUI calls. Created here so you don't have to add it by hand.
local remote = ReplicatedStorage:FindFirstChild("RedeemCode")
if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = "RedeemCode"
	remote.Parent = ReplicatedStorage
end

-- Simple anti-spam: one attempt per player every 2 seconds.
local lastAttempt = {}
local COOLDOWN = 2

-- Cache of which codes each player has used, loaded on join.
local redeemedCache = {}

local function loadRedeemed(player)
	local ok, data = pcall(function()
		return redeemedStore:GetAsync(tostring(player.UserId))
	end)
	redeemedCache[player] = (ok and data) or {}
	if not ok then
		warn("[Codes] Could not load redeemed codes for", player.Name, data)
	end
end

local function saveRedeemed(player)
	local data = redeemedCache[player]
	if not data then return end
	local ok, err = pcall(function()
		redeemedStore:SetAsync(tostring(player.UserId), data)
	end)
	if not ok then
		warn("[Codes] Could not save redeemed codes for", player.Name, err)
	end
end

Players.PlayerAdded:Connect(loadRedeemed)
Players.PlayerRemoving:Connect(function(player)
	saveRedeemed(player)
	redeemedCache[player] = nil
	lastAttempt[player] = nil
end)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(loadRedeemed, p)
end
game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		saveRedeemed(p)
	end
end)

-- Parse "YYYY-MM-DD" into a unix time at the END of that day (UTC).
local function expiryToTime(dateString)
	local y, m, d = dateString:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	if not y then return nil end
	return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 23, min = 59, sec = 59 })
end

-- Try to claim one global use of a limited code. Returns true if we got one.
local function claimGlobalUse(codeName, maxUses)
	local gotOne = false
	local ok, err = pcall(function()
		usageStore:UpdateAsync(codeName, function(current)
			current = current or 0
			if current >= maxUses then
				gotOne = false
				return nil -- cancel the write
			end
			gotOne = true
			return current + 1
		end)
	end)
	if not ok then
		warn("[Codes] Usage store error for", codeName, err)
		return false
	end
	return gotOne
end

----------------------------------------------------------------------
-- REWARDS. This is the part you connect to your game.
----------------------------------------------------------------------

local function giveCoins(player, amount)
	-- TODO: replace with your real coin system.
	-- Default guess: a leaderstats IntValue called "Coins".
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if coins then
		coins.Value += amount
		return true
	end
	warn("[Codes] No leaderstats.Coins found for", player.Name, "- hook giveCoins to your coin system")
	return false
end

local function givePotion(player, potionId, amount)
	-- TODO: replace with your real potion inventory.
	-- Default guess: a folder player.Potions with an IntValue per PotionId.
	local inv = player:FindFirstChild("Potions")
	if not inv then
		inv = Instance.new("Folder")
		inv.Name = "Potions"
		inv.Parent = player
	end
	local slot = inv:FindFirstChild(potionId)
	if not slot then
		slot = Instance.new("IntValue")
		slot.Name = potionId
		slot.Parent = inv
	end
	slot.Value += amount
	return true
end

local function giveResearch(player, amount)
	-- TODO: replace with your Research Points system.
	local stats = player:FindFirstChild("leaderstats")
	local rp = stats and stats:FindFirstChild("Research")
	if rp then
		rp.Value += amount
		return true
	end
	warn("[Codes] No leaderstats.Research found for", player.Name, "- hook giveResearch to your RP system")
	return false
end

local function describe(reward)
	if reward.Type == "Coins" then
		return reward.Amount .. " Coins"
	elseif reward.Type == "Potion" then
		return reward.Amount .. "x " .. reward.PotionId .. " Potion"
	elseif reward.Type == "Research" then
		return reward.Amount .. " Research Points"
	elseif reward.Type == "Bundle" then
		local parts = {}
		for _, item in ipairs(reward.Items) do
			table.insert(parts, describe(item))
		end
		return table.concat(parts, " + ")
	end
	return "a reward"
end

local function giveReward(player, reward)
	if reward.Type == "Coins" then
		return giveCoins(player, reward.Amount)
	elseif reward.Type == "Potion" then
		return givePotion(player, reward.PotionId, reward.Amount or 1)
	elseif reward.Type == "Research" then
		return giveResearch(player, reward.Amount)
	elseif reward.Type == "Bundle" then
		local allOk = true
		for _, item in ipairs(reward.Items) do
			if not giveReward(player, item) then
				allOk = false
			end
		end
		return allOk
	end
	warn("[Codes] Unknown reward type", reward.Type)
	return false
end

----------------------------------------------------------------------
-- REDEEM
----------------------------------------------------------------------

-- Returns (success: boolean, message: string)
remote.OnServerInvoke = function(player, rawCode)
	-- Anti-spam
	local now = os.clock()
	if lastAttempt[player] and now - lastAttempt[player] < COOLDOWN then
		return false, "Slow down."
	end
	lastAttempt[player] = now

	-- Sanitise input
	if typeof(rawCode) ~= "string" then
		return false, "Invalid code."
	end
	local code = rawCode:gsub("%s+", ""):upper()
	if #code == 0 or #code > 32 then
		return false, "Invalid code."
	end

	local entry = Codes[code]
	if not entry or entry.Enabled == false then
		return false, "That code doesn't exist."
	end

	-- Expiry
	if entry.Expires then
		local expiresAt = expiryToTime(entry.Expires)
		if expiresAt and os.time() > expiresAt then
			return false, "That code has expired."
		end
	end

	-- Already used by this player?
	local used = redeemedCache[player]
	if not used then
		loadRedeemed(player)
		used = redeemedCache[player]
	end
	if used[code] then
		return false, "You already used that code."
	end

	-- Global limit
	if entry.MaxUses then
		if not claimGlobalUse(code, entry.MaxUses) then
			return false, "That code has run out."
		end
	end

	-- Mark as used first so a crash mid-reward can't double-pay
	used[code] = os.time()
	saveRedeemed(player)

	local ok = giveReward(player, entry.Reward)
	if not ok then
		return true, "Code accepted, but a reward hook isn't connected yet. Check the server output."
	end

	return true, "You got " .. describe(entry.Reward) .. "!"
end

local codeCount = 0
for _ in pairs(Codes) do
	codeCount += 1
end
print("[Codes] CodeService ready.", codeCount, "codes loaded.")
