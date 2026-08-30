-- ============================================
-- NEXUS UI - PROFILE CARD DEMO FOR EXECUTOR
-- ============================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- Deteksi lokasi penyimpanan GUI yang aman untuk Executor
local targetParent = (gethui and gethui()) or CoreGui or localPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika sudah ada
if targetParent:FindFirstChild("NexusProfileUI") then
    targetParent.NexusProfileUI:Destroy()
end

-- 1. Buat ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexusProfileUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

-- 2. Frame Utama (Window)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 210)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Bar Judul Window
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 23)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "• Your Title v1.0 by Player"
titleText.TextColor3 = Color3.fromRGB(160, 160, 200)
titleText.TextSize = 13
titleText.Font = Enum.Font.GothamMedium
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -26, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- 3. Kartu Profil (Profile Card)
local profileCard = Instance.new("Frame")
profileCard.Name = "ProfileCard"
profileCard.Size = UDim2.new(1, -24, 0, 155)
profileCard.Position = UDim2.new(0, 12, 0, 42)
profileCard.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
profileCard.BorderSizePixel = 0
profileCard.Parent = mainFrame

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 8)
cardCorner.Parent = profileCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(45, 45, 65)
cardStroke.Thickness = 1
cardStroke.Parent = profileCard

-- Header Kartu ("• Profile")
local cardHeader = Instance.new("TextLabel")
cardHeader.Size = UDim2.new(1, -20, 0, 20)
cardHeader.Position = UDim2.new(0, 12, 0, 8)
cardHeader.BackgroundTransparency = 1
cardHeader.Text = "• Profile"
cardHeader.TextColor3 = Color3.fromRGB(130, 120, 230)
cardHeader.TextSize = 13
cardHeader.Font = Enum.Font.GothamBold
cardHeader.TextXAlignment = Enum.TextXAlignment.Left
cardHeader.Parent = profileCard

-- Foto Avatar Lingkaran
local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 75, 0, 75)
avatarImage.Position = UDim2.new(0, 12, 0, 36)
avatarImage.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
avatarImage.BorderSizePixel = 0
avatarImage.Parent = profileCard

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarImage

-- Mengambil Foto Avatar Player
task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        localPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size150x150
    )
    if isReady then
        avatarImage.Image = content
    end
end)

-- Kontainer Teks Informasi Profil
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, -110, 0, 95)
infoContainer.Position = UDim2.new(0, 100, 0, 34)
infoContainer.BackgroundTransparency = 1
infoContainer.Parent = profileCard

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 3)
layout.Parent = infoContainer

-- Username (@Name)
local usernameLabel = Instance.new("TextLabel")
usernameLabel.LayoutOrder = 1
usernameLabel.Size = UDim2.new(1, 0, 0, 22)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = "@" .. localPlayer.Name
usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
usernameLabel.TextSize = 16
usernameLabel.Font = Enum.Font.GothamBold
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = infoContainer

-- Helper function untuk membuat baris detail
local function createInfoRow(order, labelText, valueText)
    local row = Instance.new("TextLabel")
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 16)
    row.BackgroundTransparency = 1
    row.Text = string.format('<font color="#6E6E8E">%s</font> <font color="#A0A0B0">%s</font>', labelText, valueText)
    row.RichText = true
    row.TextSize = 12
    row.Font = Enum.Font.GothamMedium
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = infoContainer
end

-- Memasukkan Data Player
createInfoRow(2, "Display Name:", localPlayer.DisplayName)
createInfoRow(3, "User ID:", tostring(localPlayer.UserId))
createInfoRow(4, "Account Age:", tostring(localPlayer.AccountAge) .. " Days")
