local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local screenGui = script.Parent
local mainFrame = screenGui:WaitForChild("MainFrame")
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
	-- Hanya mencoba teleport jika string error tidak kosong (artinya memang ada disconnect/error)
	if errorMessage and errorMessage ~= "" then
		print("[Auto-Reconnect] Terdeteksi error/disconnect. Mencoba rejoin...")
		task.wait(2)
		
		-- Memakai pcall agar jika teleport gagal, script tidak berhenti total
		pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
	end
end)
