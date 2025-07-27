local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "WaymarkerGUI"

-- Main frame
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.125, 0, 0.125, 0)
frame.Size = UDim2.new(0.75, 0, 0.75, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Top bar
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local title = Instance.new("TextLabel", topBar)
title.Text = "Waymaker"
title.Size = UDim2.new(0.5, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local min = Instance.new("TextButton", topBar)
min.Text = "-"
min.Size = UDim2.new(0, 30, 1, 0)
min.Position = UDim2.new(1, -60, 0, 0)

local close = Instance.new("TextButton", topBar)
close.Text = "X"
close.Size = UDim2.new(0, 30, 1, 0)
close.Position = UDim2.new(1, -30, 0, 0)

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Text = "O"
toggleBtn.Position = UDim2.new(0.5, -25, 0.9, 0)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Visible = false

local function makeBtn(parent, name, pos, txt)
	local btn = Instance.new("TextButton", parent)
	btn.Name = name
	btn.Position = pos
	btn.Size = UDim2.new(0, 200, 0, 40)
	btn.Text = txt
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	return btn
end

local status = makeBtn(frame, "Status", UDim2.new(0,10,0,40), "Status: Waiting")
status.TextScaled = true

local place = makeBtn(frame, "Place", UDim2.new(0,10,0,90), "Place Waymarker")
local gotoBtn = makeBtn(frame, "GoTo", UDim2.new(0,10,0,140), "Go to Waymarker")
local renameBtn = makeBtn(frame, "Rename", UDim2.new(0,10,0,190), "Rename")
local repeatBtn = makeBtn(frame, "Repeat", UDim2.new(0,10,0,240), "Repeat: OFF")

local renameBox = Instance.new("TextBox", frame)
renameBox.Size = UDim2.new(0, 200, 0, 30)
renameBox.Position = UDim2.new(0, 10, 0, 290)
renameBox.PlaceholderText = "Enter new name"
renameBox.Visible = false
renameBox.ClearTextOnFocus = true
renameBox.Font = Enum.Font.SourceSans
renameBox.TextSize = 20

-- List layout
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0, 220, 0, 40)
scroll.Size = UDim2.new(1, -230, 1, -50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.BackgroundColor3 = Color3.fromRGB(40,40,40)

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Data
local waymarkers = {}
local selected = nil
local count = 0
local repeating = false

local function updateCanvas()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

local function createBillboard(waypointName)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 3, 0)

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = waypointName
	label.TextColor3 = Color3.new(1, 1, 0)
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true

	return billboard
end

local function addWaymarker(pos)
	count += 1
	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1,1,1)
	part.Position = pos
	part.Name = "WaymarkerPart"

	local name = "Waymarker " .. count
	local bb = createBillboard(name)
	bb.Parent = part

	local btn = Instance.new("TextButton", scroll)
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.LayoutOrder = count

	btn.MouseButton1Click:Connect(function()
		selected = count
		status.Text = "Selected " .. waymarkers[selected].name
	end)

	waymarkers[count] = {
		position = pos,
		part = part,
		button = btn,
		billboard = bb,
		name = name,
	}
	updateCanvas()
end

place.MouseButton1Click:Connect(function()
	local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if pos then
		addWaymarker(pos.Position)
		status.Text = "Added waymarker at " .. tostring(pos.Position)
	end
end)

gotoBtn.MouseButton1Click:Connect(function()
	if selected and waymarkers[selected] then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(waymarkers[selected].position)
		end
	end
end)

renameBtn.MouseButton1Click:Connect(function()
	if selected and waymarkers[selected] then
		renameBox.Visible = true
		renameBox:CaptureFocus()
	end
end)

renameBox.FocusLost:Connect(function(enterPressed)
	if enterPressed and selected and waymarkers[selected] then
		local newName = renameBox.Text
		if newName ~= "" then
			waymarkers[selected].name = newName
			waymarkers[selected].button.Text = newName
			waymarkers[selected].billboard.TextLabel.Text = newName
			status.Text = "Renamed to " .. newName
		end
	end
	renameBox.Text = ""
	renameBox.Visible = false
end)

repeatBtn.MouseButton1Click:Connect(function()
	if not selected or not waymarkers[selected] then
		status.Text = "Select a waymarker first"
		return
	end

	repeating = not repeating
	repeatBtn.Text = "Repeat: " .. (repeating and "ON" or "OFF")
	status.Text = repeating and ("Repeating teleport to " .. waymarkers[selected].name) or "Repeat disabled"
end)

runService.RenderStepped:Connect(function()
	if repeating and selected and waymarkers[selected] and player.Character then
		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(waymarkers[selected].position)
		end
	end
end)

-- GUI toggle logic
min.MouseButton1Click:Connect(function()
	frame.Visible = false
	toggleBtn.Visible = true
end)

close.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	toggleBtn.Visible = false
end)
