-- =========================================================
--  AFK-Stats GUI (FIXED INPUT & AUTO-SAVE CONFIG)
-- =========================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local ConfigFile = "AFK_Stats_Config.json"

-- Configuration Default
local config = {
    IsLocked = true,          -- Default locked agar aman dari tersenggol
    AntiAfk = false,          -- Default Anti-AFK
    StatsVisible = true,      -- Default Panel Stats muncul
    Positions = {             -- Posisi presisi awal
        StatsToggleBtn = {0, 15, 0, 52},
        AfkToggleBtn   = {0, 90, 0, 52},
        LockToggleBtn  = {0, 183, 0, 52},
        StatsFrame     = {0.5, -180, 0, 42}
    }
}

-- Logika Simpan & Load Config JSON
local function saveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(config))
        end)
    end
end

local function loadConfig()
    if readfile and isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result.IsLocked ~= nil then config.IsLocked = result.IsLocked end
            if result.AntiAfk ~= nil then config.AntiAfk = result.AntiAfk end
            if result.StatsVisible ~= nil then config.StatsVisible = result.StatsVisible end
            if result.Positions and type(result.Positions) == "table" then
                for k, v in pairs(result.Positions) do
                    config.Positions[k] = v
                end
            end
        end
    end
end

loadConfig()

-- Proteksi Parent GUI
local ParentGui
if gethui then
    ParentGui = gethui()
elseif syn and syn.protect_gui then
    ParentGui = Instance.new("Folder")
    syn.protect_gui(ParentGui)
    ParentGui.Parent = CoreGui
else
    ParentGui = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
end

-- Cleanup GUI lama
if ParentGui:FindFirstChild("AFKStatsGUI") then
    ParentGui:FindFirstChild("AFKStatsGUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AFKStatsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

---------------------------------------------------------
-- LOGIKA INPUT & DRAG HANYA PADA OBJEK (BUG-FREE)
---------------------------------------------------------
local function setupInteractions(guiObject, onClick, posKey)
    local isDragging = false
    local dragStart, startPos
    local hasMoved = false

    -- Mulai Drag jika Unlocked
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hasMoved = false
            if not config.IsLocked then
                isDragging = true
                dragStart = input.Position
                startPos = guiObject.Position
            end
        end
    end)

    -- Proses Geser Posisi
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and not config.IsLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Selesai Drag
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging then
                isDragging = false
                if hasMoved and posKey then
                    config.Positions[posKey] = {
                        guiObject.Position.X.Scale, guiObject.Position.X.Offset,
                        guiObject.Position.Y.Scale, guiObject.Position.Y.Offset
                    }
                    saveConfig()
                end
            end
        end
    end)

    -- Event Klik Resmi Roblox
    if guiObject:IsA("GuiButton") then
        guiObject.Activated:Connect(function()
            if not hasMoved then
                if onClick then
                    onClick()
                end
            end
            hasMoved = false
        end)
    end
end

---------------------------------------------------------
-- 1. TOMBOL TOGGLE GUI
---------------------------------------------------------
local function setSavedPosition(guiObj, posKey)
    local p = config.Positions[posKey]
    if p then
        guiObj.Position = UDim2.new(p[1], p[2], p[3], p[4])
    end
end

-- A. Tombol Stats
local StatsToggleBtn = Instance.new("TextButton")
StatsToggleBtn.Name = "StatsToggleBtn"
StatsToggleBtn.Size = UDim2.fromOffset(70, 32)
setSavedPosition(StatsToggleBtn, "StatsToggleBtn")
StatsToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
StatsToggleBtn.Text = "📊 Stats"
StatsToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 160)
StatsToggleBtn.Font = Enum.Font.GothamBold
StatsToggleBtn.TextSize = 11
StatsToggleBtn.Parent = ScreenGui

local Corner1 = Instance.new("UICorner", StatsToggleBtn)
Corner1.CornerRadius = UDim.new(0, 6)
local Stroke1 = Instance.new("UIStroke", StatsToggleBtn)
Stroke1.Color = Color3.fromRGB(0, 255, 160)
Stroke1.Thickness = 1.2

-- B. Tombol Anti-AFK
local AfkToggleBtn = Instance.new("TextButton")
AfkToggleBtn.Name = "AfkToggleBtn"
AfkToggleBtn.Size = UDim2.fromOffset(88, 32)
setSavedPosition(AfkToggleBtn, "AfkToggleBtn")
AfkToggleBtn.Font = Enum.Font.GothamBold
AfkToggleBtn.TextSize = 10
AfkToggleBtn.Parent = ScreenGui

local Corner2 = Instance.new("UICorner", AfkToggleBtn)
Corner2.CornerRadius = UDim.new(0, 6)
local Stroke2 = Instance.new("UIStroke", AfkToggleBtn)
Stroke2.Color = Color3.fromRGB(255, 255, 255)
Stroke2.Thickness = 1.2

-- C. Tombol Lock / Unlock Posisi GUI
local LockToggleBtn = Instance.new("TextButton")
LockToggleBtn.Name = "LockToggleBtn"
LockToggleBtn.Size = UDim2.fromOffset(85, 32)
setSavedPosition(LockToggleBtn, "LockToggleBtn")
LockToggleBtn.Font = Enum.Font.GothamBold
LockToggleBtn.TextSize = 10
LockToggleBtn.Parent = ScreenGui

local Corner3 = Instance.new("UICorner", LockToggleBtn)
Corner3.CornerRadius = UDim.new(0, 6)
local Stroke3 = Instance.new("UIStroke", LockToggleBtn)
Stroke3.Thickness = 1.2

---------------------------------------------------------
-- 2. PANEL PERFORMANCE STATS
---------------------------------------------------------
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.fromOffset(360, 58)
setSavedPosition(StatsFrame, "StatsFrame")
StatsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
StatsFrame.BackgroundTransparency = 0.25
StatsFrame.Visible = config.StatsVisible
StatsFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner", StatsFrame)
FrameCorner.CornerRadius = UDim.new(0, 8)
local FrameStroke = Instance.new("UIStroke", StatsFrame)
FrameStroke.Color = Color3.fromRGB(0, 255, 160)
FrameStroke.Thickness = 1.2

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 3)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📊 AFK-Stats GUI"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = StatsFrame

local StatsText = Instance.new("TextLabel")
StatsText.Name = "StatsText"
StatsText.Size = UDim2.new(1, -12, 0, 30)
StatsText.Position = UDim2.new(0, 6, 0, 23)
StatsText.BackgroundTransparency = 1
StatsText.Font = Enum.Font.GothamMedium
StatsText.Text = "⚡ FPS: --  |  📡 Ping: --ms  |  👥 Players: --\n💻 CPU: --%  |  🎮 GPU: --%  |  ⏱️ Server Age: --"
StatsText.TextColor3 = Color3.fromRGB(240, 240, 240)
StatsText.TextSize = 10
StatsText.TextXAlignment = Enum.TextXAlignment.Center
StatsText.Parent = StatsFrame

---------------------------------------------------------
-- 3. UPDATER VISUAL STATUS
---------------------------------------------------------
local function updateLockVisual()
    if config.IsLocked then
        LockToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        LockToggleBtn.Text = "🔒 Lock: ON"
        LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Stroke3.Color = Color3.fromRGB(255, 100, 100)
    else
        LockToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        LockToggleBtn.Text = "🔓 Lock: OFF"
        LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Stroke3.Color = Color3.fromRGB(100, 255, 100)
    end
end

local idledConnection = nil
local function updateAfkVisual()
    if config.AntiAfk then
        AfkToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        AfkToggleBtn.Text = "🛡️ AFK: ON"
        if not idledConnection then
            idledConnection = LocalPlayer.Idled:Connect(function()
                if config.AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
            end)
        end
    else
        AfkToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        AfkToggleBtn.Text = "🛡️ AFK: OFF"
    end
end

updateLockVisual()
updateAfkVisual()

---------------------------------------------------------
-- 4. BINDING HANDLER
---------------------------------------------------------

-- Switch Stats
setupInteractions(StatsToggleBtn, function()
    StatsFrame.Visible = not StatsFrame.Visible
    config.StatsVisible = StatsFrame.Visible
    saveConfig()
end, "StatsToggleBtn")

-- Switch AFK
setupInteractions(AfkToggleBtn, function()
    config.AntiAfk = not config.AntiAfk
    updateAfkVisual()
    saveConfig()
end, "AfkToggleBtn")

-- Switch Lock Mode
setupInteractions(LockToggleBtn, function()
    config.IsLocked = not config.IsLocked
    updateLockVisual()
    saveConfig()
end, "LockToggleBtn")

-- Panel Stats Drag
setupInteractions(StatsFrame, nil, "StatsFrame")

---------------------------------------------------------
-- 5. REAL-TIME STATS LOOP
---------------------------------------------------------
local lastTime = os.clock()
local frameCount = 0
local fps = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = currentTime
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if StatsFrame.Visible then
            local success, pingVal = pcall(function() 
                return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) 
            end)
            local ping = success and pingVal or 0
            local playerOnline = #Players:GetPlayers()
            
            local cpuUsage = math.clamp(math.floor((StatsService.PerformanceStats.CPU:GetValue() or 5)), 1, 99)
            local gpuUsage = math.clamp(math.floor((StatsService.PerformanceStats.GPU:GetValue() or 8)), 1, 99)

            local uptimeSec = math.floor(workspace.DistributedGameTime)
            local hours = math.floor(uptimeSec / 3600)
            local mins = math.floor((uptimeSec % 3600) / 60)
            local secs = uptimeSec % 60
            local uptimeStr = string.format("%02dh %02dm %02ds", hours, mins, secs)

            StatsText.Text = string.format(
                "⚡ FPS: %d  |  📡 Ping: %dms  |  👥 Players: %d\n💻 CPU: %d%%  |  🎮 GPU: %d%%  |  ⏱️ Server Age: %s",
                fps, ping, playerOnline, cpuUsage, gpuUsage, uptimeStr
            )
        end
    end
end)
