local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- 1. HAPUS UI LAMA JIKA SUDAH ADA (Biar gak dobel)
local existingGui = CoreGui:FindFirstChild("AntiAfkHub") or player.PlayerGui:FindFirstChild("AntiAfkHub")
if existingGui then
	existingGui:Destroy()
end

-- 2. BUAT SCREEN GUI BARU
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAfkHub"
screenGui.ResetOnSpawn = false

-- Coba pasang ke CoreGui, kalau gagal pasang ke PlayerGui
local success = pcall(function()
	screenGui.Parent = CoreGui
end)
if not success then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 3. BUAT MAIN FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -75) -- Posisi tengah layar
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Active = true
mainFrame.Draggable = true -- Bisa digeser-geser di layar!
mainFrame.Parent = screenGui

-- Corner UI biar melengkung ganteng
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Background Image (Optional)
local bgImage = Instance.new("ImageLabel")
bgImage.Name = "ImageLabel"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://74720230796587"
bgImage.ImageTransparency = 0.8 -- Transparan biar teks tetep kelihatan
bgImage.Parent = mainFrame

-- 4. BUAT TOMBOL ANTI-AFK
local antiAfkButton = Instance.new("TextButton")
antiAfkButton.Name = "AntiAFKButton"
antiAfkButton.Size = UDim2.new(0.8, 0, 0, 45)
antiAfkButton.Position = UDim2.new(0.1, 0, 0.5, -22)
antiAfkButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah (OFF)
antiAfkButton.Text = "Anti-AFK: OFF"
antiAfkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAfkButton.TextSize = 16
antiAfkButton.Font = Enum.Font.SourceSansBold
antiAfkButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = antiAfkButton

---------------------------------------------------------
-- LOGIKA ANTI-AFK (ON / OFF)
---------------------------------------------------------
local antiAfkEnabled = false
local idledConnection = nil

local function toggleAntiAFK()
	antiAfkEnabled = not antiAfkEnabled
	
	if antiAfkEnabled then
		antiAfkButton.Text = "Anti-AFK: ON"
		antiAfkButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Hijau
		
		idledConnection = player.Idled:Connect(function()
			if antiAfkEnabled then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0))
				print("[Anti-AFK] Mencegah disconnect idle.")
			end
		end)
	else
		antiAfkButton.Text = "Anti-AFK: OFF"
		antiAfkButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Merah
		
		if idledConnection then
			idledConnection:Disconnect()
			idledConnection = nil
		end
	end
end

antiAfkButton.MouseButton1Click:Connect(toggleAntiAFK)

---------------------------------------------------------
-- LOGIKA AUTO RECONNECT
---------------------------------------------------------
GuiService.ErrorMessageChanged:Connect(function(errorMessage)
	if errorMessage and errorMessage ~= "" then
		print("[Auto-Reconnect] Terdeteksi error/disconnect. Mencoba rejoin...")
		task.wait(2)
		pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
	end
end)

print("[SUCCESS] Anti-AFK UI Berhasil Dimuat!")
