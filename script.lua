local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Mencegah error script.Parent dengan mencari ScreenGui di PlayerGui atau CoreGui
local playerGui = player:WaitForChild("PlayerGui")

-- Mencari ScreenGui (Pastikan nama ScreenGui Anda sesuai, misal: "ScreenGui" atau "MyHub")
-- Jika UI dimasukkan lewat executor ke CoreGui, ganti playerGui menjadi CoreGui
local screenGui = playerGui:FindFirstChildOfClass("ScreenGui") or CoreGui:FindFirstChildOfClass("ScreenGui")

if not screenGui then
	warn("[Script Error] ScreenGui tidak ditemukan di PlayerGui/CoreGui!")
	return
end

local mainFrame = screenGui:WaitForChild("MainFrame", 10) -- Timeout 10 detik agar tidak infinity wait

if not mainFrame then
	warn("[Script Error] MainFrame tidak ditemukan di dalam ScreenGui!")
	return
end

local antiAfkButton = mainFrame:WaitForChild("AntiAFKButton")
local bgImage = mainFrame:WaitForChild("ImageLabel")

-- ID Gambar
bgImage.Image = "rbxassetid://74720230796587"

---------------------------------------------------------
-- 1. SISTEM ANTI-AFK (ON / OFF)
---------------------------------------------------------
local antiAfkEnabled = false
local idledConnection = nil

local function toggleAntiAFK()
	antiAfkEnabled = not antiAfkEnabled
	
	if antiAfkEnabled then
		antiAfkButton.Text = "Anti-AFK: ON"
		antiAfkButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Warna Hijau
		
		-- Mencegah Disconnect saat Karakter Idle
		idledConnection = player.Idled:Connect(function()
			if antiAfkEnabled then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0))
				print("[Anti-AFK] Mencegah disconnect idle.")
			end
		end)
	else
		antiAfkButton.Text = "Anti-AFK: OFF"
		antiAfkButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Warna Merah
		
		if idledConnection then
			idledConnection:Disconnect()
			idledConnection = nil
		end
	end
end

antiAfkButton.MouseButton1Click:Connect(toggleAntiAFK)

---------------------------------------------------------
-- 2. SISTEM AUTO RECONNECT (PROSES TELEPORT SAAT ERROR)
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
