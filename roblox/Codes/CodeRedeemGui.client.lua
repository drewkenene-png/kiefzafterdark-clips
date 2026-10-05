--[[
	CodeRedeemGui (LocalScript)
	Put this in: StarterPlayer > StarterPlayerScripts

	Builds the whole "Enter Code" popup in code so you don't have to
	make any GUI by hand. A small "CODES" button sits on the left side
	of the screen. Click it to open the box.

	If your game already has its own code GUI, skip this file and just
	call ReplicatedStorage.RedeemCode:InvokeServer(codeText) from it.
	It returns (success, message).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("RedeemCode")

-- Colours. Change to match your game.
local BG = Color3.fromRGB(28, 24, 44)
local PANEL = Color3.fromRGB(42, 36, 66)
local ACCENT = Color3.fromRGB(124, 58, 237)
local GOOD = Color3.fromRGB(72, 199, 116)
local BAD = Color3.fromRGB(230, 80, 90)
local TEXT = Color3.fromRGB(245, 245, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "CodeRedeemGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = parent
end

-- Open button -----------------------------------------------------------
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenCodes"
openBtn.Size = UDim2.fromOffset(90, 36)
openBtn.Position = UDim2.new(0, 12, 0.5, -18)
openBtn.BackgroundColor3 = ACCENT
openBtn.Text = "CODES"
openBtn.TextColor3 = TEXT
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.AutoButtonColor = true
openBtn.Parent = gui
corner(openBtn, 8)

-- Panel -----------------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(320, 190)
panel.Position = UDim2.new(0.5, -160, 0.5, -95)
panel.BackgroundColor3 = BG
panel.Visible = false
panel.Parent = gui
corner(panel, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = ACCENT
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 36)
title.Position = UDim2.fromOffset(16, 8)
title.BackgroundTransparency = 1
title.Text = "Enter a code"
title.TextColor3 = TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 10)
closeBtn.BackgroundColor3 = PANEL
closeBtn.Text = "X"
closeBtn.TextColor3 = TEXT
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = panel
corner(closeBtn, 8)

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -32, 0, 40)
box.Position = UDim2.fromOffset(16, 56)
box.BackgroundColor3 = PANEL
box.PlaceholderText = "TYPE CODE HERE"
box.PlaceholderColor3 = Color3.fromRGB(150, 145, 170)
box.Text = ""
box.TextColor3 = TEXT
box.Font = Enum.Font.GothamBold
box.TextSize = 18
box.ClearTextOnFocus = false
box.Parent = panel
corner(box, 8)

local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(1, -32, 0, 40)
redeemBtn.Position = UDim2.fromOffset(16, 104)
redeemBtn.BackgroundColor3 = ACCENT
redeemBtn.Text = "REDEEM"
redeemBtn.TextColor3 = TEXT
redeemBtn.Font = Enum.Font.GothamBold
redeemBtn.TextSize = 18
redeemBtn.Parent = panel
corner(redeemBtn, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -32, 0, 28)
status.Position = UDim2.fromOffset(16, 152)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = TEXT
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Parent = panel

-- Behaviour -------------------------------------------------------------
local function setStatus(msg, colour)
	status.Text = msg
	status.TextColor3 = colour or TEXT
end

local function shake()
	local origin = panel.Position
	for i = 1, 4 do
		local dx = (i % 2 == 0) and 6 or -6
		TweenService:Create(panel, TweenInfo.new(0.04), { Position = origin + UDim2.fromOffset(dx, 0) }):Play()
		task.wait(0.04)
	end
	TweenService:Create(panel, TweenInfo.new(0.04), { Position = origin }):Play()
end

local busy = false
local function redeem()
	if busy then return end
	local code = box.Text
	if code:gsub("%s", "") == "" then
		setStatus("Type a code first.", BAD)
		return
	end
	busy = true
	redeemBtn.Text = "..."
	setStatus("Checking...", TEXT)

	local ok, success, message = pcall(remote.InvokeServer, remote, code)
	if not ok then
		success, message = false, "Something went wrong. Try again."
	end

	if success then
		setStatus(message, GOOD)
		box.Text = ""
	else
		setStatus(message, BAD)
		task.spawn(shake)
	end

	redeemBtn.Text = "REDEEM"
	busy = false
end

local function open()
	panel.Visible = true
	panel.Size = UDim2.fromOffset(0, 0)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(320, 190),
		Position = UDim2.new(0.5, -160, 0.5, -95),
	}):Play()
	setStatus("", TEXT)
	task.delay(0.1, function() box:CaptureFocus() end)
end

local function close()
	panel.Visible = false
end

openBtn.MouseButton1Click:Connect(function()
	if panel.Visible then close() else open() end
end)
closeBtn.MouseButton1Click:Connect(close)
redeemBtn.MouseButton1Click:Connect(redeem)
box.FocusLost:Connect(function(enterPressed)
	if enterPressed then redeem() end
end)
