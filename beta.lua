-- =========================================================
-- SHIRONEKO HUB 🐈 - ULTIMATE ALL-IN-ONE (STRICT QUEUE & PET ZONE EDITION)
-- =========================================================

-- 1. ANTI-DUPLICATE EXECUTION SYSTEM
if getgenv().ShiroNekoLoaded then
    warn("⚠️ ShiroNeko Hub sudah berjalan! Menghindari eksekusi ganda.")
    return 
end
getgenv().ShiroNekoLoaded = true

-- 2. SYSTEM CLEANUP & CONNECTIONS TRACKER
local ScriptRunning = true
local ActiveConnections = {}

local function AddConnection(conn)
    table.insert(ActiveConnections, conn)
    return conn
end

local function StopEverything()
    ScriptRunning = false
    for _, conn in pairs(ActiveConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    ActiveConnections = {}
    getgenv().ShiroNekoLoaded = false
    print("✅ ShiroNeko Hub: Semua proses dan listener berhasil dihentikan.")
end

-- 3. SERVICES & SETUP
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local MarketService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- GAG Remote Events
local GameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
local PetsService = GameEvents and GameEvents:FindFirstChild("PetsService")
local PetCooldownsUpdated = GameEvents and GameEvents:FindFirstChild("PetCooldownsUpdated")
local PetZoneAbility = GameEvents and GameEvents:FindFirstChild("PetZoneAbility")

local lastOriginalSpeed = 16

-- Safe Protector Parent
local ParentGui
if gethui then
    ParentGui = gethui()
elseif syn and syn.protect_gui then
    ParentGui = Instance.new("Folder")
    syn.protect_gui(ParentGui)
    ParentGui.Parent = game:GetService("CoreGui")
else
    ParentGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui") or playerGui
end

-- Clean Old GUIs
if playerGui:FindFirstChild("NeonLoadingScreen") then playerGui.NeonLoadingScreen:Destroy() end
if playerGui:FindFirstChild("MainHubGui") then playerGui.MainHubGui:Destroy() end
if ParentGui:FindFirstChild("AFKStatsGUI") then ParentGui:FindFirstChild("AFKStatsGUI"):Destroy() end
if ParentGui:FindFirstChild("ShiroNekoFreecamUI") then ParentGui:FindFirstChild("ShiroNekoFreecamUI"):Destroy() end

-- Anti-Blur System
task.spawn(function()
    task.wait(0.5)
    for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end)

-- Sound Loading
local loadingSound = Instance.new("Sound")
loadingSound.Name = "CustomLoadingSound"
loadingSound.SoundId = "rbxassetid://112510022853483"
loadingSound.Volume = 0.8
loadingSound.Parent = SoundService

-- 4. CONFIG, WEBHOOK & THEME ENGINE
local ConfigFile = "ShiroNeko_AdvancedConfig.json"

local config = {
    IsLocked = false,
    AntiAfk = false,
    StatsVisible = true,
    SpeedEnabled = false,
    SpeedValue = 1,
    FlyEnabled = false,
    FlyValue = 1,
    InfiniteJumpEnabled = false,
    FreezePlayerEnabled = false,
    FullbrightEnabled = false,
    RemoveEffectsEnabled = false,
    PlayerEspEnabled = false,
    EspBoxEnabled = false,
    AdminKickEnabled = false,
    FreecamEnabled = false,
    FreecamSpeed = 2,
    ZoomEnabled = false,
    DiscordWebhookURL = "",
    DiscordPingID = "",
    AllowPing = true,
    CurrentTheme = "Default",
    -- Fitur Pet (GAG)
    AutoPickPlaceEnabled = false,
    SelectedPetUUIDs = {}, -- List UUID yang dicentang user
    DelayToPick = 0.05,
    DelayToPlace = 0.05,
    -- Fitur Kustom Pet Zone Visual
    CustomZoneEnabled = false,
    CustomZoneRadius = 500,
    Positions = {
        StatsFrame = {0.5, -180, 0, 42}
    }
}

local toggleUpdateCallbacks = {}

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
            return HttpService:JSONEncode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            for k, v in pairs(result) do
                config[k] = v
            end
        end
    end
end

loadConfig()

-- 🐾 LOGIK HOOKING PET ZONE VISUAL RADIUS (PET ZONE ABILITY)
if PetZoneAbility and getconnections then
    task.spawn(function()
        task.wait(1)
        pcall(function()
            for _, connection in ipairs(getconnections(PetZoneAbility.OnClientEvent)) do
                local originalFunc = connection.Function
                if originalFunc then
                    connection:Disable()
                    AddConnection(PetZoneAbility.OnClientEvent:Connect(function(uuid, active, radius, petObj, abilityName, ...)
                        local visualRadius = radius
                        if config.CustomZoneEnabled then
                            visualRadius = tonumber(config.CustomZoneRadius) or radius
                        end
                        originalFunc(uuid, active, visualRadius, petObj, abilityName, ...)
                    end))
                end
            end
        end)
    end)
end

-- 🐾 LOGIK DETECTION & QUEUE SYSTEM AUTOPICK/PLACE PET (GAG)
local processingPets = {}
local petQueue = {}
local isProcessingQueue = false

local function GetEquippedPetsList()
    local petList = {}
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local petContainer = pGui 
        and pGui:FindFirstChild("ActivePetUI")
        and pGui.ActivePetUI:FindFirstChild("Frame")
        and pGui.ActivePetUI.Frame:FindFirstChild("Main")
        and pGui.ActivePetUI.Frame.Main:FindFirstChild("PetDisplay")
        and pGui.ActivePetUI.Frame.Main.PetDisplay:FindFirstChild("ScrollingFrame")

    if petContainer then
        for _, petFrame in ipairs(petContainer:GetChildren()) do
            if petFrame:IsA("GuiObject") and (string.sub(petFrame.Name, 1, 1) == "{" or #petFrame.Name > 10) then
                local uuid = petFrame.Name
                local petTypeLabel = petFrame:FindFirstChild("PET_TYPE", true)
                local petNameLabel = petFrame:FindFirstChild("PET_NAME", true)
                local petName = (petTypeLabel and petTypeLabel.Text) or (petNameLabel and petNameLabel.Text) or "Unknown Pet"
                table.insert(petList, {uuid = uuid, name = petName})
            end
        end
    end
    return petList
end

local function getPetNameFromUI(uuid)
    for _, pet in ipairs(GetEquippedPetsList()) do
        if pet.uuid == uuid then return pet.name end
    end
    return nil
end

local function isPetSelected(uuid)
    if not config.SelectedPetUUIDs or next(config.SelectedPetUUIDs) == nil then
        return true
    end
    return config.SelectedPetUUIDs[uuid] == true
end

-- QUEUE WORKER: Diproses 1 per 1 secara Antrean Ketat
local function processPetQueue()
    if isProcessingQueue then return end
    isProcessingQueue = true

    task.spawn(function()
        while #petQueue > 0 and ScriptRunning do
            local petUUID = table.remove(petQueue, 1)

            if isPetSelected(petUUID) and PetsService then
                local targetCF = CFrame.new(-12.321571350098, 0, -70.503242492676, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                local pickDelay = tonumber(config.DelayToPick) or 0.05
                local placeDelay = tonumber(config.DelayToPlace) or 0.05
                local petName = getPetNameFromUI(petUUID) or ("Pet " .. string.sub(petUUID, 1, 6))

                print("⚡ [Queue Process] Memproses Pet: " .. petName .. " [" .. string.sub(petUUID, 1, 8) .. "...]")

                -- 1. UNEQUIP (PICK) PET INI
                PetsService:FireServer("UnequipPet", petUUID)
                task.wait(pickDelay)

                -- 2. EQUIP (PLACE) PET INI
                PetsService:FireServer("EquipPet", petUUID, targetCF)
                task.wait(placeDelay)

                print("✅ [Queue Process] " .. petName .. " Selesai! Melanjut ke pet berikutnya...")
            end

            processingPets[petUUID] = nil
        end
        isProcessingQueue = false
    end)
end

local function enqueuePet(petUUID)
    if processingPets[petUUID] then return end
    processingPets[petUUID] = true
    table.insert(petQueue, petUUID)
    processPetQueue()
end

-- Listener Cooldown Event Pet
if PetCooldownsUpdated then
    AddConnection(PetCooldownsUpdated.OnClientEvent:Connect(function(petUUID, cooldownData)
        if not config.AutoPickPlaceEnabled or not PetsService then return end

        local isFinished = false
        if type(cooldownData) == "table" then
            for _, cd in ipairs(cooldownData) do
                if cd.Time and cd.Time <= 0 then
                    isFinished = true
                    break
                end
            end
        end

        if isFinished and isPetSelected(petUUID) then
            enqueuePet(petUUID)
        end
    end))
end

local webhookSent = false
local function sendWebhookNotification(reason, isTest)
    local webhookUrl = config.DiscordWebhookURL
    if not webhookUrl or webhookUrl == "" or not string.find(webhookUrl, "discord.com/api/webhooks") then
        return false, "URL Webhook tidak valid!"
    end

    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not requestFunc then return false, "Executor tidak mendukung HTTP Request!" end

    local placeName = "Unknown Game"
    pcall(function()
        local info = MarketService:GetProductInfo(game.PlaceId)
        placeName = info.Name
    end)

    local mentionText = ""
    if config.AllowPing then
        if config.DiscordPingID and config.DiscordPingID ~= "" then
            local cleanID = string.gsub(config.DiscordPingID, "[<@>]", "")
            mentionText = "<@" .. cleanID .. ">"
        else
            mentionText = "@everyone"
        end
    end

    local payload = {
        ["content"] = mentionText ~= "" and mentionText or nil,
        ["embeds"] = {{
            ["title"] = "ShiroNeko Hub 🐈",
            ["color"] = 16711680,
            ["description"] = string.format(
                "**-> Disconnection :**\n\n| Username: %s\n| Game: [%s]\n\n**-> Disconnection Message :**\n```\n%s\n```",
                LocalPlayer.Name,
                placeName,
                reason or "Your connection timed out. Check your internet connection and try again.\n(Error Code: 266)"
            )
        }}
    }

    local success, err = pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)

    return success, err
end

local function sendWebhookDisconnect(reason)
    if webhookSent then return end
    webhookSent = true
    sendWebhookNotification(reason, false)
end

-- Theme Manager
local ThemeUIElements = {
    Strokes = {},
    Titles = {},
    TabButtons = {}
}

local RainbowConnection = nil
local ColorThemes = {
    ["Default"]   = Color3.fromRGB(0, 240, 255),
    ["Merah"]     = Color3.fromRGB(255, 50, 50),
    ["Biru"]      = Color3.fromRGB(30, 144, 255),
    ["Pink"]      = Color3.fromRGB(255, 105, 180),
    ["Hijau"]     = Color3.fromRGB(50, 205, 50),
    ["Ungu"]      = Color3.fromRGB(138, 43, 226),
    ["Kuning"]    = Color3.fromRGB(255, 215, 0),
    ["Orange"]    = Color3.fromRGB(255, 140, 0),
    ["Gold"]      = Color3.fromRGB(212, 175, 55),
    ["Cyberpunk"] = Color3.fromRGB(255, 0, 128)
}

local function ApplyTheme(themeName)
    config.CurrentTheme = themeName
    saveConfig()

    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end

    if themeName == "Rainbow" then
        RainbowConnection = AddConnection(RunService.RenderStepped:Connect(function()
            local hue = (tick() % 5) / 5
            local rainbowColor = Color3.fromHSV(hue, 0.8, 1)

            for _, stroke in ipairs(ThemeUIElements.Strokes) do
                if stroke and stroke.Parent then stroke.Color = rainbowColor end
            end
            for _, label in ipairs(ThemeUIElements.Titles) do
                if label and label.Parent then label.TextColor3 = rainbowColor end
            end
            for _, btn in pairs(ThemeUIElements.TabButtons) do
                if btn and btn.Parent and btn.BackgroundColor3 ~= Color3.fromRGB(30, 25, 42) then
                    btn.BackgroundColor3 = rainbowColor
                end
            end
        end))
    else
        local targetColor = ColorThemes[themeName] or ColorThemes["Default"]
        for _, stroke in ipairs(ThemeUIElements.Strokes) do
            if stroke and stroke.Parent then stroke.Color = targetColor end
        end
        for _, label in ipairs(ThemeUIElements.Titles) do
            if label and label.Parent then label.TextColor3 = targetColor end
        end
        for _, btn in pairs(ThemeUIElements.TabButtons) do
            if btn and btn.Parent and btn.BackgroundColor3 ~= Color3.fromRGB(30, 25, 42) then
                btn.BackgroundColor3 = targetColor
            end
        end
    end
end

local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    AddConnection(guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))

    AddConnection(guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end))
end

-- 5. PANEL STATS DISPLAY
local AfkScreenGui = Instance.new("ScreenGui")
AfkScreenGui.Name = "AFKStatsGUI"
AfkScreenGui.ResetOnSpawn = false
AfkScreenGui.Parent = ParentGui

local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Size = UDim2.fromOffset(360, 58)

if config.Positions and config.Positions.StatsFrame then
    local p = config.Positions.StatsFrame
    StatsFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
else
    StatsFrame.Position = UDim2.new(0.5, -180, 0, 42)
end

StatsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
StatsFrame.BackgroundTransparency = 0.25
StatsFrame.Visible = config.StatsVisible
StatsFrame.Parent = AfkScreenGui

Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)
local FrameStroke = Instance.new("UIStroke", StatsFrame)
FrameStroke.Color = Color3.fromRGB(0, 240, 255)
FrameStroke.Thickness = 1.2
table.insert(ThemeUIElements.Strokes, FrameStroke)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 3)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📊 AFK-Stats GUI"
TitleLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = StatsFrame
table.insert(ThemeUIElements.Titles, TitleLabel)

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, -12, 0, 30)
StatsText.Position = UDim2.new(0, 6, 0, 23)
StatsText.BackgroundTransparency = 1
StatsText.Font = Enum.Font.GothamMedium
StatsText.Text = "⚡ FPS: --  |  📡 Ping: --ms  |  👥 Players: --\n💻 CPU: --%  |  🎮 GPU: --%  |  ⏱️ Server Age: --"
StatsText.TextColor3 = Color3.fromRGB(240, 240, 240)
StatsText.TextSize = 10
StatsText.TextXAlignment = Enum.TextXAlignment.Center
StatsText.Parent = StatsFrame

local isDraggingStats = false
local dragStartStats, startPosStats

AddConnection(StatsFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not config.IsLocked then
        isDraggingStats = true
        dragStartStats = input.Position
        startPosStats = StatsFrame.Position
    end
end))

AddConnection(UserInputService.InputChanged:Connect(function(input)
    if isDraggingStats and not config.IsLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartStats
        StatsFrame.Position = UDim2.new(
            startPosStats.X.Scale, startPosStats.X.Offset + delta.X,
            startPosStats.Y.Scale, startPosStats.Y.Offset + delta.Y
        )
    end
end))

AddConnection(StatsFrame.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDraggingStats then
        isDraggingStats = false
        config.Positions.StatsFrame = {
            StatsFrame.Position.X.Scale, StatsFrame.Position.X.Offset,
            StatsFrame.Position.Y.Scale, StatsFrame.Position.Y.Offset
        }
        saveConfig()
    end
end))

local lastTime = os.clock()
local frameCount = 0
local fps = 0

AddConnection(RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = currentTime
    end
end))

task.spawn(function()
    while ScriptRunning do
        task.wait(1)
        if StatsFrame and StatsFrame.Visible then
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

-- 6. LOGIK CORE FITUR & FREECAM
AddConnection(RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if config.SpeedEnabled then
            local multiplier = tonumber(config.SpeedValue) or 1
            hum.WalkSpeed = lastOriginalSpeed * multiplier
        end
    end
end))

local bodyGyro, bodyVelocity, flyConnection
local function stopFlying()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

local function startFlying()
    stopFlying()
    if not config.FlyEnabled then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = root.CFrame
    bodyGyro.Parent = root

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.velocity = Vector3.new(0, 0, 0)
    bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root

    if hum then hum.PlatformStand = true end

    flyConnection = AddConnection(RunService.RenderStepped:Connect(function()
        if not char or not char:FindFirstChild("Humanoid") then stopFlying() return end
        local cam = workspace.CurrentCamera
        local moveDir = char.Humanoid.MoveDirection
        local actualFlySpeed = config.FlyValue * 25

        if moveDir.Magnitude > 0 then
            bodyVelocity.velocity = cam.CFrame.LookVector * (moveDir.Magnitude * actualFlySpeed)
        else
            bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        end
        bodyGyro.cframe = cam.CFrame
    end))
end

AddConnection(UserInputService.JumpRequest:Connect(function()
    if config.InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

local idledConnection = nil
local function updateAfkLogic()
    if config.AntiAfk then
        if not idledConnection then
            idledConnection = AddConnection(LocalPlayer.Idled:Connect(function()
                if config.AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
            end))
        end
    else
        if idledConnection then idledConnection:Disconnect() idledConnection = nil end
    end
end

AddConnection(RunService.RenderStepped:Connect(function()
    if config.ZoomEnabled then
        LocalPlayer.CameraMaxZoomDistance = 5000
    end
end))

local freecamPart, fcConnection, fcGui
local fcUp, fcDown = false, false
local hiddenGuis = {}

local function toggleFreecam(state)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    local mainHub = playerGui:FindFirstChild("MainHubGui")

    if state then
        if not hum or not hrp then return end
        hrp.Anchored = true 
        
        if mainHub then mainHub.Enabled = false end
        if AfkScreenGui then AfkScreenGui.Enabled = false end

        hiddenGuis = {}
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "ShiroNekoFreecamUI" and gui.Name ~= "MainHubGui" then
                table.insert(hiddenGuis, gui)
                gui.Enabled = false
            end
        end

        freecamPart = Instance.new("Part")
        freecamPart.Name = "ShiroNekoFreecamPart"
        freecamPart.Anchored = true
        freecamPart.CanCollide = false
        freecamPart.Transparency = 1
        freecamPart.Size = Vector3.new(1, 1, 1)
        freecamPart.CFrame = cam.CFrame
        freecamPart.Parent = workspace
        
        cam.CameraSubject = freecamPart
        
        if ParentGui:FindFirstChild("ShiroNekoFreecamUI") then ParentGui.ShiroNekoFreecamUI:Destroy() end

        fcGui = Instance.new("ScreenGui", ParentGui)
        fcGui.Name = "ShiroNekoFreecamUI"
        
        local btnUp = Instance.new("TextButton", fcGui)
        btnUp.Size = UDim2.new(0, 50, 0, 50)
        btnUp.Position = UDim2.new(1, -70, 0.45, -60)
        btnUp.Text = "UP\n(E)"
        btnUp.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btnUp.BackgroundTransparency = 0.2
        btnUp.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnUp.Font = Enum.Font.GothamBold
        btnUp.TextSize = 11
        Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)
        
        local btnDown = Instance.new("TextButton", fcGui)
        btnDown.Size = UDim2.new(0, 50, 0, 50)
        btnDown.Position = UDim2.new(1, -70, 0.45, 0)
        btnDown.Text = "DOWN\n(Q)"
        btnDown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btnDown.BackgroundTransparency = 0.2
        btnDown.TextColor3 = Color3.fromRGB(0, 240, 255)
        btnDown.Font = Enum.Font.GothamBold
        btnDown.TextSize = 11
        Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)

        local btnExit = Instance.new("TextButton", fcGui)
        btnExit.Size = UDim2.new(0, 120, 0, 40)
        btnExit.Position = UDim2.new(0.5, -60, 0.88, 0)
        btnExit.Text = "❌ EXIT FREECAM"
        btnExit.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
        btnExit.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnExit.Font = Enum.Font.GothamBold
        btnExit.TextSize = 12
        Instance.new("UICorner", btnExit).CornerRadius = UDim.new(0, 18)

        btnUp.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcUp = true end end)
        btnUp.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcUp = false end end)
        
        btnDown.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcDown = true end end)
        btnDown.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcDown = false end end)

        btnExit.MouseButton1Click:Connect(function()
            config.FreecamEnabled = false
            toggleFreecam(false)
            if toggleUpdateCallbacks["FreecamEnabled"] then
                toggleUpdateCallbacks["FreecamEnabled"](false)
            end
            saveConfig()
        end)

        fcConnection = AddConnection(RunService.RenderStepped:Connect(function()
            if not freecamPart or not hum then return end
            local speed = config.FreecamSpeed or 2
            local yMove = 0
            if fcUp or UserInputService:IsKeyDown(Enum.KeyCode.E) then yMove = 1 end
            if fcDown or UserInputService:IsKeyDown(Enum.KeyCode.Q) then yMove = -1 end
            
            local moveDir = hum.MoveDirection
            local lookVector = cam.CFrame.LookVector
            
            freecamPart.CFrame = freecamPart.CFrame + (moveDir * speed) + (Vector3.new(0, yMove, 0) * speed)
            cam.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + lookVector)
        end))
    else
        if fcConnection then fcConnection:Disconnect() fcConnection = nil end
        if freecamPart then freecamPart:Destroy() freecamPart = nil end
        if fcGui then fcGui:Destroy() fcGui = nil end
        
        if hum then cam.CameraSubject = hum end
        if hrp and not config.FreezePlayerEnabled then hrp.Anchored = false end
        
        if mainHub then mainHub.Enabled = true end
        if AfkScreenGui then AfkScreenGui.Enabled = true end

        for _, gui in pairs(hiddenGuis) do
            if gui and gui.Parent then
                gui.Enabled = true
            end
        end
        hiddenGuis = {}
    end
end

-- ESP System
local ESP_Table = {}
local function AddESP(plr)
    if plr == LocalPlayer or ESP_Table[plr] then return end
    ESP_Table[plr] = {}

    local Box = Instance.new("BoxHandleAdornment")
    Box.Color3 = Color3.new(0, 0.9, 1)
    Box.Transparency = 0.8
    Box.Size = Vector3.new(3.2, 5.5, 3.2)
    Box.AlwaysOnTop = true
    Box.ZIndex = 999
    Box.Visible = false
    Box.Parent = Camera
    ESP_Table[plr].Box = Box

    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 180, 0, 20)
    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false
    Billboard.Parent = Camera
    ESP_Table[plr].Billboard = Billboard

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextStrokeTransparency = 0.2
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Parent = Billboard
    ESP_Table[plr].Label = Label
end

local function RemoveESP(plr)
    if ESP_Table[plr] then
        pcall(function()
            if ESP_Table[plr].Box then ESP_Table[plr].Box:Destroy() end
            if ESP_Table[plr].Billboard then ESP_Table[plr].Billboard:Destroy() end
        end)
        ESP_Table[plr] = nil
    end
end

AddConnection(RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP_Table[plr] then AddESP(plr) end

            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")

            if config.PlayerEspEnabled and head then
                ESP_Table[plr].Billboard.Adornee = head
                ESP_Table[plr].Billboard.Enabled = true
                if myHRP then
                    local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
                    ESP_Table[plr].Label.Text = plr.Name .. " [" .. dist .. "m]"
                else
                    ESP_Table[plr].Label.Text = plr.Name
                end
            else
                ESP_Table[plr].Billboard.Enabled = false
            end

            if config.EspBoxEnabled then
                ESP_Table[plr].Box.Adornee = hrp
                ESP_Table[plr].Box.Visible = true
            else
                ESP_Table[plr].Box.Visible = false
            end
        else
            RemoveESP(plr)
        end
    end
end))

AddConnection(Players.PlayerRemoving:Connect(RemoveESP))

-- 7. LOADING SCREEN
local function StartLoadingScreen(hubName, creatorName, onComplete)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeonLoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    screenGui.Parent = playerGui

    local mainCard = Instance.new("Frame")
    mainCard.Size = UDim2.new(0.65, 0, 0.60, 0)
    mainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCard.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainCard.Parent = screenGui

    Instance.new("UICorner", mainCard).CornerRadius = UDim.new(0, 14)
    local cardStroke = Instance.new("UIStroke", mainCard)
    cardStroke.Color = Color3.fromRGB(0, 240, 255)
    cardStroke.Thickness = 2.5

    local hubTitle = Instance.new("TextLabel")
    hubTitle.Size = UDim2.new(1, -40, 0, 50)
    hubTitle.Position = UDim2.new(0, 20, 0.08, 0)
    hubTitle.BackgroundTransparency = 1
    hubTitle.Text = hubName or "ShiroNeko Hub"
    hubTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    hubTitle.TextSize = 30
    hubTitle.Font = Enum.Font.Arcade
    hubTitle.Parent = mainCard

    local loadingTitle = Instance.new("TextLabel")
    loadingTitle.Size = UDim2.new(1, -40, 0, 30)
    loadingTitle.Position = UDim2.new(0, 20, 0.24, 0)
    loadingTitle.BackgroundTransparency = 1
    loadingTitle.Text = "Loading System........."
    loadingTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    loadingTitle.TextSize = 22
    loadingTitle.Font = Enum.Font.Arcade
    loadingTitle.Parent = mainCard

    local outerBar = Instance.new("Frame")
    outerBar.Size = UDim2.new(0.9, 0, 0, 38)
    outerBar.Position = UDim2.new(0.05, 0, 0.48, 0)
    outerBar.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    outerBar.Parent = mainCard

    local innerBar = Instance.new("Frame")
    innerBar.Size = UDim2.new(0, 0, 1, 0)
    innerBar.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    innerBar.Parent = outerBar

    local percentText = Instance.new("TextLabel")
    percentText.Size = UDim2.new(0.9, 0, 0, 30)
    percentText.Position = UDim2.new(0.05, 0, 0.65, 0)
    percentText.BackgroundTransparency = 1
    percentText.Text = "0%"
    percentText.TextColor3 = Color3.fromRGB(0, 240, 255)
    percentText.TextSize = 22
    percentText.Font = Enum.Font.Arcade
    percentText.TextXAlignment = Enum.TextXAlignment.Right
    percentText.Parent = mainCard

    pcall(function() loadingSound:Play() end)

    task.spawn(function()
        for i = 0, 100 do
            percentText.Text = i .. "%"
            innerBar.Size = UDim2.new(i / 100, 0, 1, 0)
            if i <= 60 then task.wait(0.005) elseif i > 60 and i < 89 then task.wait(0.01) elseif i == 89 then task.wait(0.2) else task.wait(0.005) end
        end

        screenGui:Destroy()
        if loadingSound then loadingSound:Destroy() end
        if onComplete then onComplete() end
    end)
end

-- 8. SHIRONEKO MAIN HUB UI
local function ShowMainUI()
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "MainHubGui"
    mainGui.ResetOnSpawn = false
    mainGui.DisplayOrder = 999999
    mainGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 28)
    mainFrame.Active = true
    mainFrame.Parent = mainGui

    MakeDraggable(mainFrame)
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", mainFrame)
    frameStroke.Color = Color3.fromRGB(0, 240, 255)
    frameStroke.Thickness = 1.5
    table.insert(ThemeUIElements.Strokes, frameStroke)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 35)
    title.Position = UDim2.new(0, 12, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "ShiroNeko Hub 🐈 | Strict Queue Edition"
    title.TextColor3 = Color3.fromRGB(0, 240, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    table.insert(ThemeUIElements.Titles, title)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.fromOffset(28, 28)
    minimizeBtn.Position = UDim2.new(1, -68, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 75)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = mainFrame
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.fromOffset(50, 50)
    openBtn.Position = UDim2.new(0, 20, 0.2, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    openBtn.Text = "🐈"
    openBtn.TextSize = 26
    openBtn.Visible = false
    openBtn.Parent = mainGui
    MakeDraggable(openBtn)
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    local openBtnStroke = Instance.new("UIStroke", openBtn)
    openBtnStroke.Color = Color3.fromRGB(0, 240, 255)
    table.insert(ThemeUIElements.Strokes, openBtnStroke)

    minimizeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false openBtn.Visible = true end)
    openBtn.MouseButton1Click:Connect(function() openBtn.Visible = false mainFrame.Visible = true end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        if mainFrame:FindFirstChild("ConfirmOverlay") then return end

        local confirmOverlay = Instance.new("Frame")
        confirmOverlay.Name = "ConfirmOverlay"
        confirmOverlay.Size = UDim2.new(1, 0, 1, 0)
        confirmOverlay.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
        confirmOverlay.BackgroundTransparency = 0.25
        confirmOverlay.ZIndex = 100
        confirmOverlay.Parent = mainFrame
        Instance.new("UICorner", confirmOverlay).CornerRadius = UDim.new(0, 8)

        local confirmBox = Instance.new("Frame")
        confirmBox.Size = UDim2.new(0, 310, 0, 150)
        confirmBox.Position = UDim2.new(0.5, -155, 0.5, -75)
        confirmBox.BackgroundColor3 = Color3.fromRGB(24, 18, 34)
        confirmBox.ZIndex = 101
        confirmBox.Parent = confirmOverlay
        Instance.new("UICorner", confirmBox).CornerRadius = UDim.new(0, 8)
        local boxStroke = Instance.new("UIStroke", confirmBox)
        boxStroke.Color = Color3.fromRGB(230, 50, 50)
        boxStroke.Thickness = 1.5

        local warnTitle = Instance.new("TextLabel")
        warnTitle.Size = UDim2.new(1, 0, 0, 30)
        warnTitle.Position = UDim2.new(0, 0, 0, 10)
        warnTitle.BackgroundTransparency = 1
        warnTitle.Text = "⚠️ WARNING"
        warnTitle.TextColor3 = Color3.fromRGB(230, 50, 50)
        warnTitle.Font = Enum.Font.GothamBold
        warnTitle.TextSize = 15
        warnTitle.ZIndex = 102
        warnTitle.Parent = confirmBox

        local warnDesc = Instance.new("TextLabel")
        warnDesc.Size = UDim2.new(1, -20, 0, 40)
        warnDesc.Position = UDim2.new(0, 10, 0, 42)
        warnDesc.BackgroundTransparency = 1
        warnDesc.Text = "Are you sure you want to close this GUI?"
        warnDesc.TextColor3 = Color3.fromRGB(220, 220, 220)
        warnDesc.Font = Enum.Font.GothamMedium
        warnDesc.TextSize = 11
        warnDesc.TextWrapped = true
        warnDesc.ZIndex = 102
        warnDesc.Parent = confirmBox

        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0, 110, 0, 32)
        yesBtn.Position = UDim2.new(0, 30, 1, -44)
        yesBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 12
        yesBtn.ZIndex = 102
        yesBtn.Parent = confirmBox
        Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)

        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0, 110, 0, 32)
        noBtn.Position = UDim2.new(1, -140, 1, -44)
        noBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
        noBtn.Text = "No"
        noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 12
        noBtn.ZIndex = 102
        noBtn.Parent = confirmBox
        Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)

        yesBtn.MouseButton1Click:Connect(function()
            StopEverything()
            mainGui:Destroy()
            if AfkScreenGui then AfkScreenGui:Destroy() end
        end)

        noBtn.MouseButton1Click:Connect(function()
            confirmOverlay:Destroy()
        end)
    end)

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Size = UDim2.new(0, 140, 1, -45)
    sidebar.Position = UDim2.new(0, 8, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    sidebar.ScrollBarThickness = 2
    sidebar.Parent = mainFrame
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

    local sidebarList = Instance.new("UIListLayout", sidebar)
    sidebarList.Padding = UDim.new(0, 4)

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -160, 1, -45)
    contentArea.Position = UDim2.new(0, 152, 0, 40)
    contentArea.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    contentArea.Parent = mainFrame
    Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 6)

    local tabNames = {"Home", "Main", "Pet (GAG)", "ESP & Visual", "Misc", "Webhook", "Settings", "Themes"}
    local tabs = {}
    local tabButtons = {}

    local function SwitchTab(selectedName)
        for name, frame in pairs(tabs) do frame.Visible = (name == selectedName) end
        for name, btn in pairs(tabButtons) do
            if name == selectedName then
                local activeColor = ColorThemes[config.CurrentTheme] or ColorThemes["Default"]
                btn.BackgroundColor3 = activeColor
                btn.TextColor3 = Color3.fromRGB(10, 10, 15)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 25, 42)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end

    local function CreateToggle(parent, text, configKey, defaultState, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(38, 30, 52)
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 44, 0, 20)
        toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 10
        toggleBtn.Parent = frame
        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

        local currentState = defaultState
        local function updateVisual(val)
            currentState = val
            toggleBtn.BackgroundColor3 = currentState and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(180, 50, 50)
            toggleBtn.Text = currentState and "ON" or "OFF"
        end
        updateVisual(currentState)

        if configKey then
            toggleUpdateCallbacks[configKey] = updateVisual
        end

        toggleBtn.MouseButton1Click:Connect(function()
            currentState = not currentState
            updateVisual(currentState)
            if callback then callback(currentState) end
        end)
    end

    local function CreateButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(45, 38, 62)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function CreateInput(parent, text, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(38, 30, 52)
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.48, 0, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.50, -8, 0, 22)
        box.Position = UDim2.new(0.50, 0, 0.5, -11)
        box.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        box.Text = tostring(defaultVal or "")
        box.TextColor3 = Color3.fromRGB(0, 240, 255)
        box.Font = Enum.Font.GothamBold
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.Parent = frame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

        box.FocusLost:Connect(function()
            if callback then callback(box.Text) end
        end)
    end

    for _, tabName in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(30, 25, 42)
        btn.Text = "  " .. tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        tabButtons[tabName] = btn
        ThemeUIElements.TabButtons[tabName] = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.Visible = false
        page.Parent = contentArea

        local pageList = Instance.new("UIListLayout", page)
        pageList.Padding = UDim.new(0, 6)

        tabs[tabName] = page
        btn.MouseButton1Click:Connect(function() SwitchTab(tabName) end)
    end

    -- TAB 1: HOME
    CreateToggle(tabs["Home"], "Show Stats Display", "StatsVisible", config.StatsVisible, function(s) config.StatsVisible = s StatsFrame.Visible = s saveConfig() end)
    CreateToggle(tabs["Home"], "Lock Stats Drag", "IsLocked", config.IsLocked, function(s) config.IsLocked = s saveConfig() end)
    CreateToggle(tabs["Home"], "Anti-AFK System", "AntiAfk", config.AntiAfk, function(s) config.AntiAfk = s updateAfkLogic() saveConfig() end)
    CreateToggle(tabs["Home"], "Zoom Out (X5000)", "ZoomEnabled", config.ZoomEnabled, function(s) config.ZoomEnabled = s if not s then LocalPlayer.CameraMaxZoomDistance = 128 end saveConfig() end)

    -- TAB 2: MAIN
    CreateToggle(tabs["Main"], "WalkSpeed Toggle", "SpeedEnabled", config.SpeedEnabled, function(s) 
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if s then
            if hum then lastOriginalSpeed = hum.WalkSpeed end
            config.SpeedEnabled = true
        else
            config.SpeedEnabled = false
            if hum then hum.WalkSpeed = lastOriginalSpeed end
        end
        saveConfig()
    end)
    CreateInput(tabs["Main"], "Speed Multiplier (1 = Normal)", config.SpeedValue, function(v) config.SpeedValue = tonumber(v) or 1 saveConfig() end)
    CreateToggle(tabs["Main"], "Fly Toggle", "FlyEnabled", config.FlyEnabled, function(s) config.FlyEnabled = s saveConfig() if s then startFlying() else stopFlying() end end)
    CreateInput(tabs["Main"], "Fly Speed Value (1-100)", config.FlyValue, function(v) config.FlyValue = tonumber(v) or 1 saveConfig() end)
    CreateToggle(tabs["Main"], "Infinite Jump", "InfiniteJumpEnabled", config.InfiniteJumpEnabled, function(s) config.InfiniteJumpEnabled = s saveConfig() end)
    CreateToggle(tabs["Main"], "Freeze Player", "FreezePlayerEnabled", config.FreezePlayerEnabled, function(s) config.FreezePlayerEnabled = s if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = s end saveConfig() end)
    CreateButton(tabs["Main"], "Unstuck / Reset Character", function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) hum.Health = 0 end
    end)

    -- 🐾 TAB 3: PET (GAG) - STRICT QUEUE PET & CUSTOM ZONE
    local petTab = tabs["Pet (GAG)"]

    CreateToggle(petTab, "Auto Pick & Place (CD Queue)", "AutoPickPlaceEnabled", config.AutoPickPlaceEnabled, function(s)
        config.AutoPickPlaceEnabled = s
        saveConfig()
    end)

    CreateInput(petTab, "Delay To Pick (Detik)", config.DelayToPick or 0.05, function(v)
        config.DelayToPick = tonumber(v) or 0.05
        saveConfig()
    end)

    CreateInput(petTab, "Delay To Place (Detik)", config.DelayToPlace or 0.05, function(v)
        config.DelayToPlace = tonumber(v) or 0.05
        saveConfig()
    end)

    -- ⚡ FITUR BARU: CUSTOM PET ZONE VISUAL RADIUS
    CreateToggle(petTab, "Custom Pet Zone Visual", "CustomZoneEnabled", config.CustomZoneEnabled, function(s)
        config.CustomZoneEnabled = s
        saveConfig()
    end)

    CreateInput(petTab, "Pet Zone Visual Size", config.CustomZoneRadius or 500, function(v)
        config.CustomZoneRadius = tonumber(v) or 500
        saveConfig()
    end)

    -- Container Panel List Pet
    local listHeader = Instance.new("Frame")
    listHeader.Size = UDim2.new(1, 0, 0, 28)
    listHeader.BackgroundColor3 = Color3.fromRGB(38, 30, 52)
    listHeader.Parent = petTab
    Instance.new("UICorner", listHeader).CornerRadius = UDim.new(0, 4)

    local listTitle = Instance.new("TextLabel")
    listTitle.Size = UDim2.new(0.4, 0, 1, 0)
    listTitle.Position = UDim2.new(0, 8, 0, 0)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = "🐾 Select Target Pets:"
    listTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 11
    listTitle.TextXAlignment = Enum.TextXAlignment.Left
    listTitle.Parent = listHeader

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.55, -4, 0, 20)
    searchBox.Position = UDim2.new(0.43, 0, 0.5, -10)
    searchBox.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    searchBox.PlaceholderText = "🔍 Search Pet Name..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.Parent = listHeader
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

    local petListFrame = Instance.new("ScrollingFrame")
    petListFrame.Size = UDim2.new(1, 0, 0, 120)
    petListFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    petListFrame.ScrollBarThickness = 3
    petListFrame.Parent = petTab
    Instance.new("UICorner", petListFrame).CornerRadius = UDim.new(0, 4)

    local petListLayout = Instance.new("UIListLayout", petListFrame)
    petListLayout.Padding = UDim.new(0, 3)

    local currentPetItems = {}

    local function PopulatePetList(filterText)
        filterText = filterText and string.lower(filterText) or ""
        
        for _, v in ipairs(petListFrame:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        currentPetItems = {}

        local equipped = GetEquippedPetsList()
        if #equipped == 0 then
            local emptyText = Instance.new("TextLabel")
            emptyText.Size = UDim2.new(1, 0, 1, 0)
            emptyText.BackgroundTransparency = 1
            emptyText.Text = "⚠️ No Equipped Pets Found in UI!"
            emptyText.TextColor3 = Color3.fromRGB(180, 180, 180)
            emptyText.Font = Enum.Font.GothamMedium
            emptyText.TextSize = 10
            emptyText.Parent = petListFrame
            return
        end

        for _, pet in ipairs(equipped) do
            local fullName = pet.name
            local uuid = pet.uuid
            local shortUuid = string.sub(uuid, 1, 8)
            local displayText = fullName .. " (" .. shortUuid .. ")"

            if filterText == "" or string.find(string.lower(displayText), filterText, 1, true) then
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, -6, 0, 26)
                itemFrame.BackgroundColor3 = Color3.fromRGB(32, 26, 44)
                itemFrame.Parent = petListFrame
                Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 4)

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, -45, 1, 0)
                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = displayText
                nameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
                nameLbl.Font = Enum.Font.Gotham
                nameLbl.TextSize = 10
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.Parent = itemFrame

                local checkBtn = Instance.new("TextButton")
                checkBtn.Size = UDim2.new(0, 34, 0, 18)
                checkBtn.Position = UDim2.new(1, -38, 0.5, -9)
                checkBtn.Font = Enum.Font.GothamBold
                checkBtn.TextSize = 9
                checkBtn.Parent = itemFrame
                Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 3)

                local isChecked = config.SelectedPetUUIDs[uuid] == true
                local function updateCheckVisual()
                    checkBtn.BackgroundColor3 = isChecked and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(60, 55, 75)
                    checkBtn.Text = isChecked and "✓" or "x"
                end
                updateCheckVisual()

                checkBtn.MouseButton1Click:Connect(function()
                    isChecked = not isChecked
                    config.SelectedPetUUIDs[uuid] = isChecked and true or nil
                    updateCheckVisual()
                    saveConfig()
                end)

                currentPetItems[uuid] = {frame = itemFrame, setChecked = function(val)
                    isChecked = val
                    config.SelectedPetUUIDs[uuid] = isChecked and true or nil
                    updateCheckVisual()
                end}
            end
        end

        petListFrame.CanvasSize = UDim2.new(0, 0, 0, petListLayout.AbsoluteContentSize.Y + 10)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        PopulatePetList(searchBox.Text)
    end)

    -- Action Buttons Area
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, 0, 0, 28)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = petTab

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.32, -2, 1, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(45, 38, 62)
    refreshBtn.Text = "🔄 Refresh"
    refreshBtn.TextColor3 = Color3.fromRGB(0, 240, 255)
    refreshBtn.Font = Enum.Font.GothamMedium
    refreshBtn.TextSize = 10
    refreshBtn.Parent = btnContainer
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

    local selectAllBtn = Instance.new("TextButton")
    selectAllBtn.Size = UDim2.new(0.32, -2, 1, 0)
    selectAllBtn.Position = UDim2.new(0.34, 0, 0, 0)
    selectAllBtn.BackgroundColor3 = Color3.fromRGB(45, 38, 62)
    selectAllBtn.Text = "Select All"
    selectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectAllBtn.Font = Enum.Font.GothamMedium
    selectAllBtn.TextSize = 10
    selectAllBtn.Parent = btnContainer
    Instance.new("UICorner", selectAllBtn).CornerRadius = UDim.new(0, 4)

    local deselectAllBtn = Instance.new("TextButton")
    deselectAllBtn.Size = UDim2.new(0.32, -2, 1, 0)
    deselectAllBtn.Position = UDim2.new(0.68, 0, 0, 0)
    deselectAllBtn.BackgroundColor3 = Color3.fromRGB(45, 38, 62)
    deselectAllBtn.Text = "Deselect All"
    deselectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deselectAllBtn.Font = Enum.Font.GothamMedium
    deselectAllBtn.TextSize = 10
    deselectAllBtn.Parent = btnContainer
    Instance.new("UICorner", deselectAllBtn).CornerRadius = UDim.new(0, 4)

    refreshBtn.MouseButton1Click:Connect(function()
        PopulatePetList(searchBox.Text)
    end)

    selectAllBtn.MouseButton1Click:Connect(function()
        for _, pet in ipairs(GetEquippedPetsList()) do
            config.SelectedPetUUIDs[pet.uuid] = true
        end
        PopulatePetList(searchBox.Text)
        saveConfig()
    end)

    deselectAllBtn.MouseButton1Click:Connect(function()
        config.SelectedPetUUIDs = {}
        PopulatePetList(searchBox.Text)
        saveConfig()
    end)

    CreateButton(petTab, "⚡ Reset/Replace Selected Pets (Strict Queue)", function()
        if not PetsService then 
            warn("⚠️ PetsService tidak ditemukan!") 
            return 
        end
        
        local equipped = GetEquippedPetsList()
        if #equipped == 0 then return end

        print("⚡ [ShiroNeko GAG] Memasukkan semua pet terpilih ke Antrean (Strict Queue)...")

        for _, pet in ipairs(equipped) do
            if isPetSelected(pet.uuid) then
                enqueuePet(pet.uuid)
            end
        end
    end)

    -- Initial Scan List
    task.spawn(function()
        task.wait(0.5)
        PopulatePetList("")
    end)

    -- TAB 4: ESP & VISUAL
    CreateToggle(tabs["ESP & Visual"], "Free Cam (Mobile Support)", "FreecamEnabled", config.FreecamEnabled, function(s) config.FreecamEnabled = s toggleFreecam(s) saveConfig() end)
    CreateInput(tabs["ESP & Visual"], "Free Cam Speed (1-10)", config.FreecamSpeed, function(v) config.FreecamSpeed = tonumber(v) or 2 saveConfig() end)
    CreateToggle(tabs["ESP & Visual"], "Player Name & Distance ESP", "PlayerEspEnabled", config.PlayerEspEnabled, function(s) config.PlayerEspEnabled = s saveConfig() end)
    CreateToggle(tabs["ESP & Visual"], "3D Hitbox Box ESP", "EspBoxEnabled", config.EspBoxEnabled, function(s) config.EspBoxEnabled = s saveConfig() end)
    CreateToggle(tabs["ESP & Visual"], "Fullbright (Auto Light)", "FullbrightEnabled", config.FullbrightEnabled, function(s)
        config.FullbrightEnabled = s saveConfig()
        if s then Lighting.Brightness = 2 Lighting.ClockTime = 14 else Lighting.Brightness = 1 end
    end)

    -- TAB 5: MISC
    CreateButton(tabs["Misc"], "🌐 Server Hop (New Server)", function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100"
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res then
            local data = HttpService:JSONEncode(res).data
            for _, srv in ipairs(data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                    break
                end
            end
        end
    end)

    CreateButton(tabs["Misc"], "🔥 Server Hop (Old Server)", function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Desc&limit=100"
        local s, res = pcall(function() return game:HttpGet(url) end)
        if s and res then
            local data = HttpService:JSONEncode(res).data
            for _, srv in ipairs(data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                    break
                end
            end
        end
    end)

    CreateButton(tabs["Misc"], "💾 Save to Autoexec Folder", function()
        if writefile then
            pcall(function() writefile("autoexec/ShiroNekoHub.lua", [[repeat task.wait() until game:IsLoaded()]]) end)
        end
    end)

    -- TAB 6: WEBHOOK
    CreateInput(tabs["Webhook"], "Webhook URL", config.DiscordWebhookURL or "", function(url)
        config.DiscordWebhookURL = url
        saveConfig()
    end)

    CreateInput(tabs["Webhook"], "Ping Message/ID", config.DiscordPingID or "", function(id)
        config.DiscordPingID = id
        saveConfig()
    end)

    CreateToggle(tabs["Webhook"], "Allow Ping On Disconnect", "AllowPing", config.AllowPing, function(s)
        config.AllowPing = s
        saveConfig()
    end)

    CreateButton(tabs["Webhook"], "🧪 Test Webhook Connection", function()
        if not config.DiscordWebhookURL or config.DiscordWebhookURL == "" then
            warn("[ShiroNeko Hub] Silakan paste URL Webhook terlebih dahulu!")
            return
        end

        local success, err = sendWebhookNotification("Koneksi berhasil! Webhook ShiroNeko Hub terhubung dengan lancar.", true)
        if success then
            print("[ShiroNeko Hub] Webhook Test terkirim ke Discord!")
        else
            warn("[ShiroNeko Hub] Gagal mengirim Webhook Test: ", tostring(err))
        end
    end)

    -- TAB 7: SETTINGS
    CreateButton(tabs["Settings"], "💾 Save Config Manually", function() saveConfig() end)
    CreateButton(tabs["Settings"], "🔄 Reset Config to Default", function()
        if delfile and isfile and isfile(ConfigFile) then pcall(function() delfile(ConfigFile) end) end
    end)

    -- TAB 8: THEMES
    local availableThemes = {"Default", "Rainbow", "Merah", "Biru", "Pink", "Hijau", "Ungu", "Kuning", "Orange", "Gold", "Cyberpunk"}

    for _, theme in ipairs(availableThemes) do
        CreateButton(tabs["Themes"], "🎨 Theme: " .. theme, function()
            ApplyTheme(theme)
        end)
    end

    SwitchTab("Home")
    ApplyTheme(config.CurrentTheme or "Default")
end

-- 9. DISCONNECT & KICK LISTENERS
AddConnection(LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        sendWebhookDisconnect("Player Ancestry Removed (Server Disconnected / Kicked)")
    end
end))

task.spawn(function()
    local robloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 10)
    if robloxPromptGui then
        local promptOverlay = robloxPromptGui:WaitForChild("promptOverlay", 10)
        if promptOverlay then
            AddConnection(promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then
                    local messageFrame = child:FindFirstChild("MessageArea")
                    local errorText = "Disconnected / Kicked from Game"
                    if messageFrame and messageFrame:FindFirstChild("ErrorFrame") then
                        local label = messageFrame.ErrorFrame:FindFirstChild("ErrorMessage")
                        if label and label.Text ~= "" then
                            errorText = label.Text
                        end
                    end
                    sendWebhookDisconnect(errorText)
                end
            end))
        end
    end
end)

-- 10. JALANKAN SCRIPT
StartLoadingScreen("ShiroNeko Hub", "Kurumi X Nahida", function()
    ShowMainUI()
    print("🐈 ShiroNeko Hub berhasil di-load!")
end)
