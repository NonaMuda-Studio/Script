-- 1. Ambil Informasi Pemain Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name
local DisplayName = LocalPlayer.DisplayName

-- Ambil Asset ID Foto Headshot Avatar (Format bawaan Roblox UI)
local HeadshotAsset = "rbxthumb://type=AvatarHeadShot&id=" .. UserId .. "&w=420&h=420"

-- 2. Memuat Pustaka FluentModded
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyuaK/FluentModded/main/main.lua"))()

-- 3. Mendaftarkan Tema Kustom
Fluent:RegisterCustomTheme("NeonPink", {
    Accent = Color3.fromRGB(255, 20, 147),
    AcrylicMain = Color3.fromRGB(25, 10, 20),
    Text = Color3.fromRGB(255, 240, 250),
    IconColor = Color3.fromRGB(255, 105, 180),
    IconSize = 15
})

Fluent:RegisterCustomTheme("CustomUngu", {
    Accent = Color3.fromRGB(138, 43, 226),
    AcrylicMain = Color3.fromRGB(18, 10, 28),
    Text = Color3.fromRGB(240, 230, 255),
    IconColor = Color3.fromRGB(186, 85, 211),
    IconSize = 15
})

Fluent:RegisterCustomTheme("CustomMerah", {
    Accent = Color3.fromRGB(255, 30, 30),
    AcrylicMain = Color3.fromRGB(25, 10, 10),
    Text = Color3.fromRGB(255, 230, 230),
    IconColor = Color3.fromRGB(255, 75, 75),
    IconSize = 15
})

Fluent:RegisterCustomTheme("CustomBiru", {
    Accent = Color3.fromRGB(0, 191, 255),
    AcrylicMain = Color3.fromRGB(10, 18, 28),
    Text = Color3.fromRGB(230, 245, 255),
    IconColor = Color3.fromRGB(30, 144, 255),
    IconSize = 15
})

-- 4. Membuat Jendela UI Utama
local Window = Fluent:CreateWindow({
    Title = "My Custom Hub",
    SubTitle = "Welcome, " .. DisplayName,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "NeonPink",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true
})

-- 5. Membuat Tab
local ProfileTab = Window:AddTab({ Title = "Profile", Icon = "solar:user-bold" })
local MainTab = Window:AddTab({ Title = "Main", Icon = "solar:home-bold" })
local ThemeTab = Window:AddTab({ Title = "Pengaturan Warna", Icon = "solar:palette-bold" })

-- 6. Menampilkan UI Karakter & USN di Tab Profile
ProfileTab:AddParagraph({
    Title = "👤 Profil Pengguna",
    Content = "Display Name: " .. DisplayName .. "\nUsername: @" .. Username .. "\nUser ID: " .. UserId
})

-- Menampilkan Foto Wajah Avatar
ProfileTab:AddImage({
    Title = "Foto Avatar Roblox Kamu",
    Image = HeadshotAsset,
    Size = UDim2.fromOffset(100, 100)
})

-- 7. Tombol Pengisi Tema Warna
ThemeTab:AddButton({
    Title = "Tema Neon Pink",
    Callback = function() Fluent:SetTheme("NeonPink") end
})
ThemeTab:AddButton({
    Title = "Tema Ungu",
    Callback = function() Fluent:SetTheme("CustomUngu") end
})
ThemeTab:AddButton({
    Title = "Tema Merah",
    Callback = function() Fluent:SetTheme("CustomMerah") end
})
ThemeTab:AddButton({
    Title = "Tema Biru",
    Callback = function() Fluent:SetTheme("CustomBiru") end
})

-- 8. Menyiapkan SaveManager & InterfaceManager
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyuaK/FluentModded/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyuaK/FluentModded/main/Addons/InterfaceManager.lua"))()

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("MyHubConfig")
SaveManager:SetFolder("MyHubConfig/configs")

InterfaceManager:BuildInterfaceSection(ThemeTab)
SaveManager:BuildConfigSection(ThemeTab)

SaveManager:LoadAutoloadConfig()
