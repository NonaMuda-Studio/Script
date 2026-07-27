local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- 1. HAPUS UI LAMA JIKA ADA
local existingGui = CoreGui:FindFirstChild("AntiAfkHub") or player.PlayerGui:FindFirstChild("AntiAfkHub")
if existingGui then
	existingGui:Destroy()
end

-- 2. BUAT SCREEN GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAfkHub"
screenGui.ResetOnSpawn = false

local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- 3. MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Title & Minimize Button
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -35, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "NonaMuda Hub v3"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 3)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = mainFrame

-- Container Konten
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

---------------------------------------------------------
-- HELPER: FUNGSI MEMBUAT BARIS (Input | Label | Toggle)
---------------------------------------------------------
local function createFeatureRow(posY, labelText, defaultVal, hasInput)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(0.9, 0, 0, 35)
	rowFrame.Position = UDim2.new(0.05, 0, 0, posY)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = contentFrame

	local inputBox = nil
	if hasInput then
		-- Box Input Angka
		inputBox = Instance.new("TextBox")
		inputBox.Size = UDim2.new(0, 45, 1, 0)
		inputBox.Position = UDim2.new(0, 0, 0, 0)
		inputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		inputBox.Text = tostring(defaultVal)
		inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		inputBox.TextSize = 14
		inputBox.Font = Enum.Font.SourceSansBold
		inputBox.Parent = rowFrame

		local inCorner = Instance.new("UICorner")
		inCorner.CornerRadius = UDim.new(0, 4)
		inCorner.Parent = inputBox
	end

	-- Label Nama Fitur
	local label = Instance.new("TextLabel")
	label.Size = hasInput and UDim2.new(0, 100, 1, 0) or UDim2.new(0, 150, 1, 0)
	label.Position = hasInput and UDim2.new(0, 50, 0, 0) or UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 13
	label.Font = Enum.Font.SourceSansBold
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = rowFrame

	-- Tombol ON / OFF
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 70, 1, 0)
	toggleBtn.Position = UDim2.new(1, -70, 0, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah (OFF)
	toggleBtn.Text = "OFF"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 13
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.Parent = rowFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = toggleBtn

	return inputBox, toggleBtn
end

-- Membuat 3 Baris Fitur
local speedInput, speedToggle = createFeatureRow(10, "Walk Speed", 50, true)
local flyInput, flyToggle     = createFeatureRow(55, "Fly Speed", 15, true)
local _, afkToggle             = createFeatureRow(100, "Anti-AFK", 0, false)

---------------------------------------------------------
-- LOGIKA MINIMIZE
---------------------------------------------------------
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		mainFrame:TweenSize(UDim2.new(0, 260, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
		minimizeBtn.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 260, 0, 200), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
		minimizeBtn.Text = "-"
	end
end)

---------------------------------------------------------
-- 1. LOGIKA CUSTOM SPEED
---------------------------------------------------------
local speedEnabled = false
local normalSpeed = 16

local function updateSpeed()
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		local targetSpeed = tonumber(speedInput.Text) or 50
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = speedEnabled and targetSpeed or normalSpeed
	end
end

speedToggle.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	speedToggle.Text = speedEnabled and "ON" or "OFF"
	speedToggle.BackgroundColor3 = speedEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
	updateSpeed()
end)

speedInput.FocusLost:Connect(function()
	if speedEnabled then updateSpeed() end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	if speedEnabled then updateSpeed() end
end)

---------------------------------------------------------
-- 2. LOGIKA FLY (Mobile & PC)
---------------------------------------------------------
local flying = false
local bodyGyro, bodyVelocity

flyToggle.MouseButton1Click:Connect(function()
	flying = not flying
	flyToggle.Text = flying and "ON" or "OFF"
	flyToggle.BackgroundColor3 = flying and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)

	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart

	if flying then
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.cframe = root.CFrame
		bodyGyro.Parent = root

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
		bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Parent = root

		task.spawn(function()
			while flying and char and char:FindFirstChild("Humanoid") do
				RunService.RenderStepped:Wait()
				local camera = workspace.CurrentCamera
				local moveDir = char.Humanoid.MoveDirection
				local currentFlySpeed = tonumber(flyInput.Text) or 15

				if moveDir.Magnitude > 0 then
					bodyVelocity.velocity = camera.CFrame.LookVector * (moveDir.Magnitude * currentFlySpeed)
				else
					bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
				end
				bodyGyro.cframe = camera.CFrame
			end
		end)
	else
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
	end
end)

---------------------------------------------------------
-- 3. LOGIKA ANTI-AFK
---------------------------------------------------------
local antiAfkEnabled = false
local idledConnection = nil

afkToggle.MouseButton1Click:Connect(function()
	antiAfkEnabled = not antiAfkEnabled
	afkToggle.Text = antiAfkEnabled and "ON" or "OFF"
	afkToggle.BackgroundColor3 = antiAfkEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)

	if antiAfkEnabled then
		idledConnection = player.Idled:Connect(function()
			if antiAfkEnabled then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0))
			end
		end)
	else
		if idledConnection then idledConnection:Disconnect() idledConnection = nil end
	end
end)

---------------------------------------------------------
-- 4. LOGIKA AUTO RECONNECT
---------------------------------------------------------
GuiService.ErrorMessageChanged:Connect(function(errorMessage)
	if errorMessage and errorMessage ~= "" then
		task.wait(2)
		pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
	end
end)
