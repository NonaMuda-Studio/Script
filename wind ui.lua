-- ========================================================
--         WIND UI - UNIFIED PROFILE CARD SCRIPT (FIXED)
-- ========================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- Load Library Wind UI (Repository Resmi GitHub)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Ambil Nama Game Secara Otomatis
local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name
end)

-- Membuat Window Utama
local Window = WindUI:CreateWindow({
    Title = "Script Hub",
    Author = "v1.0",
    Folder = "WindUI_Config",
    Icon = "user",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 420),
    Transparent = true,
    Resizable = true
})

-- Membuat Tab Utama
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })
local MainTab = Window:Tab({ Title = "Main", Icon = "layout-grid" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

---------------------------------------------------------
-- TAB HOME: 1 CARD PROFIL MENYATU (NATIVE WIND UI)
---------------------------------------------------------
HomeTab:Section({ Title = "User Profile" })

-- Card Profil Tunggal: Avatar di Kiri, Rincian di Kanan
HomeTab:Paragraph({
    Title = "@" .. LocalPlayer.Name,
    Desc = "Display Name: " .. LocalPlayer.DisplayName .. 
           "\nUser ID: " .. tostring(LocalPlayer.UserId) .. 
           "\nAccount Age: " .. tostring(LocalPlayer.AccountAge) .. " Days" ..
           "\nGame: " .. gameName,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    ImageSize = 64
})

---------------------------------------------------------
-- TAB MAIN: FITUR FITUR SCRIPT
---------------------------------------------------------
MainTab:Section({ Title = "Fitur Utama" })

MainTab:Toggle({
    Title = "Speed Boost",
    Desc = "Meningkatkan kecepatan jalan karakter",
    Value = false,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value and 50 or 16
        end
    end
})

MainTab:Button({
    Title = "Test Notification",
    Desc = "Tampilkan notifikasi tes",
    Callback = function()
        WindUI:Notify({
            Title = "Informasi",
            Content = "Script berjalan dengan lancar!",
            Duration = 3
        })
    end
})

---------------------------------------------------------
-- TAB SETTINGS: PENGATURAN TEMA
---------------------------------------------------------
SettingsTab:Section({ Title = "Pengaturan UI" })

SettingsTab:Dropdown({
    Title = "Pilih Tema",
    Desc = "Ganti warna tampilan GUI secara langsung",
    Values = { "Dark", "Light", "Rose", "Aqua", "Midnight", "Amber" },
    Default = "Dark",
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})

-- Buka Tab Home saat script pertama di-run
Window:SelectTab(1)
