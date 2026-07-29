-- =========================================================
-- TOKISAKI KURUMI HUB ⏱️ - SCRIPT LIMITED EDITION BY NIGHTMARE ⚡
-- =========================================================

-- Fix Blur / Buram saat Script di-Run
task.spawn(function()
    task.wait(0.5)
    for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end)

-- 1. Get Roblox Services & Player Data
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StatsService = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name
local DisplayName = LocalPlayer.DisplayName

-- 2. FULL CONFIG SYSTEM
local ConfigFile = "KurumiHub_AdvancedConfig.json"

local ConfigData = {
    Theme = "Darker",
    UISizeX = 480,
    UISizeY = 360,
    SpeedEnabled = false,
    SpeedValue = 1,
    FlyEnabled = false,
    FlyValue = 1,
    InfiniteJumpEnabled = false,
    GodModeEnabled = false,
    AutoRespawnEnabled = false,
    FreezePlayerEnabled = false,
    AntiAfkEnabled = false,
    FullbrightEnabled = false,
    RemoveEffectsEnabled = false,
    PlayerEspEnabled = false,
    AdminKickEnabled = false,
    ClientStatusEnabled = true,
    FreecamEnabled = false,
    FreecamSpeed = 2
}

if isfile and isfile(ConfigFile) then
    local success, result = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    if success and type(result) == "table" then
        for k, v in pairs(result) do ConfigData[k] = v end
    end
end

local function saveConfig()
    if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(ConfigData)) end) end
end

-- 3. Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 4. Create Main UI Window
local Window = Fluent:CreateWindow({
    Title = "Tokisaki Kurumi hub⏱️",
    SubTitle = "Script Limited Edition By Nightmare ⚡ | " .. DisplayName,
    TabWidth = 130,
    Size = UDim2.fromOffset(ConfigData.UISizeX or 480, ConfigData.UISizeY or 360),
    Acrylic = false,
    Theme = ConfigData.Theme,
    MinimizeKey = Enum.KeyCode.RightControl
})

-- 5. Enhanced Dynamic Resizer (Bisa Diperkecil & Diperbesar Bebas)
task.spawn(function()
    task.wait(0.8)
    local mainFrame = nil
    
    -- Cari Frame Utama Fluent UI
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local canvas = gui:FindFirstChild("CanvasGroup") or gui:FindFirstChild("Main") or gui:FindFirstChild("Holder")
            if canvas then
                mainFrame = canvas
                break
            end
        end
    end

    if not mainFrame then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local canvas = gui:FindFirstChild("CanvasGroup") or gui:FindFirstChild("Main")
                    if canvas then
                        mainFrame = canvas
                        break
                    end
                end
            end
        end
    end

    if mainFrame then
        -- Force Override agar GUI BISA DIPERKECIL tanpa tertahan konten
        mainFrame.ClipsDescendants = true
        mainFrame.AutomaticSize = Enum.AutomaticSize.None

        for _, child in pairs(mainFrame:GetDescendants()) do
            if child:IsA("GuiObject") then
                child.AutomaticSize = Enum.AutomaticSize.None
            end
        end

        mainFrame.Size = UDim2.fromOffset(ConfigData.UISizeX or 480, ConfigData.UISizeY or 360)

        -- Buat Tombol Grip Kanan Bawah
        local resizeGrip = Instance.new("TextButton")
        resizeGrip.Name = "KurumiResizeGrip"
        resizeGrip.Size = UDim2.fromOffset(22, 22)
        resizeGrip.Position = UDim2.new(1, -22, 1, -22)
        resizeGrip.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        resizeGrip.BackgroundTransparency = 0.15
        resizeGrip.Text = "↘"
        resizeGrip.TextColor3 = Color3.fromRGB(255, 255, 255)
        resizeGrip.TextSize = 14
        resizeGrip.Font = Enum.Font.GothamBold
        resizeGrip.ZIndex = 999999
        resizeGrip.Active = true
        resizeGrip.Parent = mainFrame

        local gripCorner = Instance.new("UICorner")
        gripCorner.CornerRadius = UDim.new(0, 6)
        gripCorner.Parent = resizeGrip

        local gripStroke = Instance.new("UIStroke")
        gripStroke.Color = Color3.fromRGB(255, 255, 255)
        gripStroke.Thickness = 1.5
        gripStroke.Parent = resizeGrip

        local dragging = false
        local dragStart = Vector3.new()
        local startSize = Vector2.new()

        resizeGrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startSize = mainFrame.AbsoluteSize
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    ConfigData.UISizeX = math.floor(mainFrame.AbsoluteSize.X)
                    ConfigData.UISizeY = math.floor(mainFrame.AbsoluteSize.Y)
                    saveConfig()
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                -- Batas minimal diperkecil: 330px x 240px
                local newX = math.clamp(startSize.X + delta.X, 330, 1000)
                local newY = math.clamp(startSize.Y + delta.Y, 240, 800)
                
                mainFrame.Size = UDim2.fromOffset(newX, newY)
            end
        end)
    end
end)

-- 6. Create UI Tabs
local ProfileTab = Window:AddTab({ Title = "Profile", Icon = "user" })
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local AutoTab = Window:AddTab({ Title = "Automatic", Icon = "wand" })
local MiscTab = Window:AddTab({ Title = "Misc & ESP", Icon = "eye" })
local ThemeTab = Window:AddTab({ Title = "Themes & Settings", Icon = "palette" })

---------------------------------------------------------
-- DIRECT TOGGLE BUTTON FOR FLUENT (OPEN / CLOSE HUB)
---------------------------------------------------------
if CoreGui:FindFirstChild("KurumiToggleGui") then
    CoreGui.KurumiToggleGui:Destroy()
end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "KurumiToggleGui"
ToggleGui.Parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenHUB"
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Position = UDim2.new(0, 15, 0.35, 0)
ToggleBtn.Size = UDim2.fromOffset(48, 48)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "K"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 105, 180)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(255, 105, 180)
BtnStroke.Thickness = 2
BtnStroke.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if Window then
        Window:Minimize()
    end
end)

---------------------------------------------------------
-- OVERLAY CLIENT STATUS GUI (2-Line Layout)
---------------------------------------------------------
if CoreGui:FindFirstChild("KurumiClientStatusGui") then
    CoreGui.KurumiClientStatusGui:Destroy()
end

local StatusGui = Instance.new("ScreenGui")
StatusGui.Name = "KurumiClientStatusGui"
StatusGui.Parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")

local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Parent = StatusGui
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusFrame.BackgroundTransparency = 0.25
StatusFrame.Position = UDim2.new(0, 15, 0.04, 0)
StatusFrame.Size = UDim2.fromOffset(380, 40)
StatusFrame.Active = true
StatusFrame.Draggable = true
StatusFrame.Visible = ConfigData.ClientStatusEnabled

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 6)
FrameCorner.Parent = StatusFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 105, 180)
FrameStroke.Thickness = 1.2
FrameStroke.Parent = StatusFrame

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusFrame
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 8, 0, 0)
StatusText.Size = UDim2.new(1, -16, 1, 0)
StatusText.Font = Enum.Font.GothamBold
StatusText.Text = "⚡ FPS: -- | 📡 Ping: --ms | 👥 Players: --\n💻 CPU: --% | 🎮 GPU: --% | ⏱️ Server Age: --"
StatusText.TextColor3 = Color3.fromRGB(240, 240, 240)
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Center
StatusText.TextYAlignment = Enum.TextYAlignment.Center

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
        if ConfigData.ClientStatusEnabled and StatusFrame.Visible then
            local success, pingVal = pcall(function() return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local ping = success and pingVal or 0
            local playerOnline = #Players:GetPlayers()
            local cpuUsage = math.clamp(math.floor((StatsService.PerformanceStats.CPU:GetValue() or 5)), 1, 99)
            local gpuUsage = math.clamp(math.floor((StatsService.PerformanceStats.GPU:GetValue() or 8)), 1, 99)

            local uptimeSec = math.floor(workspace.DistributedGameTime)
            local hours = math.floor(uptimeSec / 3600)
            local mins = math.floor((uptimeSec % 3600) / 60)
            local secs = uptimeSec % 60
            local uptimeStr = string.format("%02dh %02dm %02ds", hours, mins, secs)

            StatusText.Text = string.format(
                "⚡ FPS: %d  |  📡 Ping: %dms  |  👥 Players: %d\n💻 CPU: %d%%  |  🎮 GPU: %d%%  |  ⏱️ Server Age: %s",
                fps, ping, playerOnline, cpuUsage, gpuUsage, uptimeStr
            )
        end
    end
end)

---------------------------------------------------------
-- TAB 1: PROFILE
---------------------------------------------------------
ProfileTab:AddParagraph({ Title = "👤 User Profile", Content = "Display Name: " .. DisplayName .. "\nUsername: @" .. Username })
ProfileTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

ProfileTab:AddToggle("ClientStatusToggle", {
    Title = "Show Client Status GUI",
    Description = "Menampilkan/menyembunyikan GUI overlay FPS, Ping, CPU, GPU, Players & Server Age",
    Default = ConfigData.ClientStatusEnabled,
    Callback = function(Value)
        ConfigData.ClientStatusEnabled = Value
        StatusFrame.Visible = Value
        saveConfig()
    end
})

---------------------------------------------------------
-- TAB 2: MAIN (WALKSPEED, FLY, ADVANCED GOD MODE)
---------------------------------------------------------
local normalSpeed = 16

RunService.Heartbeat:Connect(function()
    if ConfigData.SpeedEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = ConfigData.SpeedValue * 50
        end
    end
end)

MainTab:AddToggle("SpeedToggle", {
    Title = "WalkSpeed Toggle",
    Default = ConfigData.SpeedEnabled,
    Callback = function(Value)
        ConfigData.SpeedEnabled = Value
        saveConfig()
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = normalSpeed
        end
    end
})

MainTab:AddInput("SpeedInput", {
    Title = "WalkSpeed Value (0.1 - 100)",
    Description = "Ketik 100 untuk kecepatan 5000 | Ketik 0.1 - 0.9 untuk kecepatan normal/agak cepat",
    Default = tostring(ConfigData.SpeedValue),
    Numeric = false, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            num = math.clamp(num, 0.1, 100)
            ConfigData.SpeedValue = num
            saveConfig()
        end
    end
})

MainTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- FLY SYSTEM
local bodyGyro, bodyVelocity
local flyConnection

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
    if not ConfigData.FlyEnabled then return end
    
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

    flyConnection = RunService.RenderStepped:Connect(function()
        if not char or not char:FindFirstChild("Humanoid") then
            stopFlying()
            return
        end
        local camera = workspace.CurrentCamera
        local moveDir = char.Humanoid.MoveDirection
        local actualFlySpeed = ConfigData.FlyValue * 50

        if moveDir.Magnitude > 0 then
            bodyVelocity.velocity = camera.CFrame.LookVector * (moveDir.Magnitude * actualFlySpeed)
        else
            bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        end
        bodyGyro.cframe = camera.CFrame
    end)
end

MainTab:AddToggle("FlyToggle", {
    Title = "Fly Toggle",
    Default = ConfigData.FlyEnabled,
    Callback = function(Value)
        ConfigData.FlyEnabled = Value
        saveConfig()
        if Value then startFlying() else stopFlying() end
    end
})

MainTab:AddInput("FlyInput", {
    Title = "Fly Speed Value (0.1 - 100)",
    Description = "Ketik 100 untuk terbang kecepatan 5000 | Ketik 0.1 - 0.9 untuk terbang lambat/sedang",
    Default = tostring(ConfigData.FlyValue),
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            num = math.clamp(num, 0.1, 100)
            ConfigData.FlyValue = num
            saveConfig()
        end
    end
})

MainTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if ConfigData.InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

MainTab:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Description = "Melompat terus-menerus tanpa batas di udara",
    Default = ConfigData.InfiniteJumpEnabled,
    Callback = function(Value)
        ConfigData.InfiniteJumpEnabled = Value
        saveConfig()
    end
})

MainTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- ADVANCED GOD MODE
local godModeConnection = nil

local function toggleGodMode(state)
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")

    if state then
        if workspace:FindFirstChild("FallenPartsDestroyHeight") then
            workspace.FallenPartsDestroyHeight = -999999
        end

        godModeConnection = RunService.Stepped:Connect(function()
            if ConfigData.GodModeEnabled and char and char.Parent then
                if hum then
                    hum.MaxHealth = 1e9
                    hum.Health = 1e9
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    
                    if hum:GetState() == Enum.HumanoidStateType.Dead then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end

                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = false
                        v.Velocity = Vector3.new(0, 0, 0)
                    elseif v:IsA("TouchTransporter") or v:IsA("TouchInterest") then
                        v:Destroy()
                    end
                end
            end
        end)
    else
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum.MaxHealth = 100
            hum.Health = 100
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanTouch = true
            end
        end
        if workspace:FindFirstChild("FallenPartsDestroyHeight") then
            workspace.FallenPartsDestroyHeight = -500
        end
    end
end

MainTab:AddToggle("GodModeToggle", {
    Title = "Advanced God Mode (Anti-KillBrick)",
    Description = "Kebal dari lingkungan, void, lava, & jebakan map",
    Default = ConfigData.GodModeEnabled,
    Callback = function(Value)
        ConfigData.GodModeEnabled = Value
        saveConfig()
        toggleGodMode(Value)
    end
})

local function toggleFreezePlayer(state)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Anchored = state
    end
end

MainTab:AddToggle("FreezePlayerToggle", {
    Title = "Freeze Player",
    Description = "Mengunci posisi karakter agar tidak dapat bergerak",
    Default = ConfigData.FreezePlayerEnabled,
    Callback = function(Value)
        ConfigData.FreezePlayerEnabled = Value
        saveConfig()
        toggleFreezePlayer(Value)
    end
})

MainTab:AddButton({
    Title = "Reset Character (Unstuck)",
    Description = "Mematikan paksa & respawn karakter meskipun God Mode aktif",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum.MaxHealth = 100
            hum.Health = 0
            
            task.delay(0.1, function()
                if char and char.Parent then
                    char:BreakJoints()
                end
            end)
        end
    end
})

local FreecamToggleElement = nil

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if ConfigData.FlyEnabled then startFlying() end
    if ConfigData.GodModeEnabled then toggleGodMode(true) end
    if ConfigData.FreezePlayerEnabled then toggleFreezePlayer(true) end
    
    if ConfigData.FreecamEnabled and FreecamToggleElement then
        FreecamToggleElement:SetValue(false)
    end
end)

---------------------------------------------------------
-- TAB 3: AUTOMATIC
---------------------------------------------------------
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd
local origGlobalShadows = Lighting.GlobalShadows
local origAmbient = Lighting.Ambient

local fullbrightConnection
local function applyFullbright(state)
    if state then
        fullbrightConnection = RunService.Heartbeat:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
    else
        if fullbrightConnection then fullbrightConnection:Disconnect() fullbrightConnection = nil end
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClockTime
        Lighting.FogEnd = origFogEnd
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.Ambient = origAmbient
    end
end

AutoTab:AddToggle("FullbrightToggle", {
    Title = "Auto Light (Fullbright)",
    Description = "Membuat seluruh area map terang secara otomatis",
    Default = ConfigData.FullbrightEnabled,
    Callback = function(Value)
        ConfigData.FullbrightEnabled = Value
        saveConfig()
        applyFullbright(Value)
    end
})

local function removeEffects()
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("Atmosphere") then
            obj.Enabled = not ConfigData.RemoveEffectsEnabled
        end
    end
end

AutoTab:AddToggle("RemoveEffectsToggle", {
    Title = "Remove Effects",
    Description = "Menghapus Blur, Kabut, SunRays, & Efek Visual yang mengganggu",
    Default = ConfigData.RemoveEffectsEnabled,
    Callback = function(Value)
        ConfigData.RemoveEffectsEnabled = Value
        saveConfig()
        removeEffects()
    end
})

Lighting.ChildAdded:Connect(function(child)
    if ConfigData.RemoveEffectsEnabled then
        if child:IsA("PostEffect") or child:IsA("BlurEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("SunRaysEffect") or child:IsA("Atmosphere") then
            child.Enabled = false
        end
    end
end)

---------------------------------------------------------
-- TAB 4: MISC & ESP (FREECAM, SERVER HOP, AUTOEXECUTE)
---------------------------------------------------------

-- FREECAM SYSTEM (Mobile Friendly)
local freecamPart = nil
local fcConnection = nil
local fcGui = nil
local fcUp = false
local fcDown = false

local function toggleFreecam(state)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    
    if state then
        if not hum or not hrp then return end
        
        hrp.Anchored = true 
        
        freecamPart = Instance.new("Part")
        freecamPart.Name = "KurumiFreecamPart"
        freecamPart.Anchored = true
        freecamPart.CanCollide = false
        freecamPart.Transparency = 1
        freecamPart.Size = Vector3.new(1, 1, 1)
        freecamPart.CFrame = cam.CFrame
        freecamPart.Parent = workspace
        
        cam.CameraSubject = freecamPart
        
        if CoreGui:FindFirstChild("KurumiFreecamUI") then
            CoreGui.KurumiFreecamUI:Destroy()
        end

        fcGui = Instance.new("ScreenGui", CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui"))
        fcGui.Name = "KurumiFreecamUI"
        
        local btnUp = Instance.new("TextButton", fcGui)
        btnUp.Size = UDim2.new(0, 50, 0, 50)
        btnUp.Position = UDim2.new(1, -70, 0.45, -60)
        btnUp.Text = "UP\n(E)"
        btnUp.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btnUp.BackgroundTransparency = 0.2
        btnUp.TextColor3 = Color3.fromRGB(255, 105, 180)
        btnUp.Font = Enum.Font.GothamBold
        btnUp.TextSize = 11
        Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", btnUp).Color = Color3.fromRGB(255, 105, 180)
        
        local btnDown = Instance.new("TextButton", fcGui)
        btnDown.Size = UDim2.new(0, 50, 0, 50)
        btnDown.Position = UDim2.new(1, -70, 0.45, 0)
        btnDown.Text = "DOWN\n(Q)"
        btnDown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btnDown.BackgroundTransparency = 0.2
        btnDown.TextColor3 = Color3.fromRGB(255, 105, 180)
        btnDown.Font = Enum.Font.GothamBold
        btnDown.TextSize = 11
        Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", btnDown).Color = Color3.fromRGB(255, 105, 180)

        local btnExit = Instance.new("TextButton", fcGui)
        btnExit.Size = UDim2.new(0, 110, 0, 36)
        btnExit.Position = UDim2.new(0.5, -55, 0.88, 0)
        btnExit.Text = "❌ EXIT FREECAM"
        btnExit.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        btnExit.BackgroundTransparency = 0.15
        btnExit.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnExit.Font = Enum.Font.GothamBold
        btnExit.TextSize = 11
        Instance.new("UICorner", btnExit).CornerRadius = UDim.new(0, 18)
        
        local exitStroke = Instance.new("UIStroke", btnExit)
        exitStroke.Color = Color3.fromRGB(255, 255, 255)
        exitStroke.Thickness = 1.5

        btnUp.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcUp = true end end)
        btnUp.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcUp = false end end)
        
        btnDown.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcDown = true end end)
        btnDown.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then fcDown = false end end)

        btnExit.MouseButton1Click:Connect(function()
            if FreecamToggleElement then
                FreecamToggleElement:SetValue(false)
            else
                toggleFreecam(false)
            end
        end)

        fcConnection = RunService.RenderStepped:Connect(function()
            if not freecamPart or not hum then return end
            
            local speed = ConfigData.FreecamSpeed or 2
            local actualSpeed = speed
            
            local yMove = 0
            if fcUp or UserInputService:IsKeyDown(Enum.KeyCode.E) then yMove = 1 end
            if fcDown or UserInputService:IsKeyDown(Enum.KeyCode.Q) then yMove = -1 end
            
            local moveDir = hum.MoveDirection
            local lookVector = cam.CFrame.LookVector
            
            freecamPart.CFrame = freecamPart.CFrame + (moveDir * actualSpeed) + (Vector3.new(0, yMove, 0) * actualSpeed)
            cam.CFrame = CFrame.new(freecamPart.Position, freecamPart.Position + lookVector)
        end)
    else
        if fcConnection then fcConnection:Disconnect() fcConnection = nil end
        if freecamPart then freecamPart:Destroy() freecamPart = nil end
        if fcGui then fcGui:Destroy() fcGui = nil end
        if hum then cam.CameraSubject = hum end
        if hrp and not ConfigData.FreezePlayerEnabled then hrp.Anchored = false end
    end
end

FreecamToggleElement = MiscTab:AddToggle("FreecamToggle", {
    Title = "Free Cam (Mobile Support)",
    Description = "Kamera bebas. Gunakan Joystick HP / WASD untuk bergerak.",
    Default = ConfigData.FreecamEnabled,
    Callback = function(Value)
        ConfigData.FreecamEnabled = Value
        saveConfig()
        toggleFreecam(Value)
    end
})

MiscTab:AddInput("FreecamSpeed", {
    Title = "Free Cam Speed (1 - 10)",
    Default = tostring(ConfigData.FreecamSpeed),
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            ConfigData.FreecamSpeed = math.clamp(num, 0.1, 10)
            saveConfig()
        end
    end
})

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- ESP SYSTEM
local function updatePlayerESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                if ConfigData.PlayerEspEnabled then
                    local espFolder = hrp:FindFirstChild("Kurumi_PlayerESP")
                    if not espFolder then
                        espFolder = Instance.new("Folder")
                        espFolder.Name = "Kurumi_PlayerESP"
                        espFolder.Parent = hrp

                        local highlight = Instance.new("Highlight")
                        highlight.Name = "Glow"
                        highlight.FillColor = Color3.fromRGB(255, 105, 180)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.65
                        highlight.OutlineTransparency = 0.1
                        highlight.Adornee = char
                        highlight.Parent = espFolder

                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ItemTag"
                        billboard.Adornee = hrp
                        billboard.Size = UDim2.new(0, 200, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = espFolder

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "TagText"
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextSize = 13
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.Parent = billboard

                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Color3.fromRGB(0, 0, 0)
                        stroke.Thickness = 1.5
                        stroke.Parent = textLabel
                    end

                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myHrp and espFolder:FindFirstChild("ItemTag") and espFolder.ItemTag:FindFirstChild("TagText") then
                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                        espFolder.ItemTag.TagText.Text = plr.Name .. " [" .. tostring(dist) .. "m]"
                        espFolder.ItemTag.Enabled = true
                        if espFolder:FindFirstChild("Glow") then espFolder.Glow.Enabled = true end
                    end
                else
                    if hrp:FindFirstChild("Kurumi_PlayerESP") then
                        hrp.Kurumi_PlayerESP:Destroy()
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        updatePlayerESP()
        task.wait(0.4)
    end
end)

MiscTab:AddToggle("PlayerEspToggle", {
    Title = "Player Name & Distance ESP",
    Default = ConfigData.PlayerEspEnabled,
    Callback = function(Value)
        ConfigData.PlayerEspEnabled = Value
        saveConfig()
        updatePlayerESP()
    end
})

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- SERVER HOP SYSTEM
local function serverHop(mode)
    Fluent:Notify({ Title = "Server Hop", Content = "Sedang mencari server " .. mode .. "...", Duration = 3 })
    
    local sortOrder = (mode == "New") and "Asc" or "Desc"
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=" .. sortOrder .. "&limit=100"
    
    local success, rawData = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and rawData then
        local decodeSuccess, parsed = pcall(function()
            return HttpService:JSONDecode(rawData)
        end)
        
        if decodeSuccess and parsed and parsed.data then
            local candidates = {}
            for _, server in ipairs(parsed.data) do
                if type(server) == "table" and server.id ~= game.JobId and server.playing and server.maxPlayers and server.playing < server.maxPlayers then
                    table.insert(candidates, server)
                end
            end
            
            if #candidates > 0 then
                table.sort(candidates, function(a, b)
                    if mode == "New" then
                        return a.playing < b.playing
                    else
                        return a.playing > b.playing
                    end
                end)
                
                TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[1].id, LocalPlayer)
            else
                Fluent:Notify({ Title = "Server Hop", Content = "Tidak ada server " .. mode .. " yang tersedia!", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "Server Hop", Content = "Gagal memproses data server Roblox!", Duration = 3 })
        end
    else
        Fluent:Notify({ Title = "Server Hop", Content = "Gagal mengambil daftar server dari Roblox API!", Duration = 3 })
    end
end

MiscTab:AddButton({
    Title = "🌐 Server Hop (New Server / Sepi)",
    Description = "Pindah ke server yang baru dibuat atau jumlah player sedikit",
    Callback = function()
        serverHop("New")
    end
})

MiscTab:AddButton({
    Title = "🔥 Server Hop (Old Server / Ramai)",
    Description = "Pindah ke server yang sudah lama berjalan atau player ramai",
    Callback = function()
        serverHop("Old")
    end
})

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- AUTOEXECUTE SYSTEM
MiscTab:AddButton({
    Title = "💾 Save to Autoexec Folder",
    Description = "Menyimpan script loader langsung ke folder autoexec executor kamu",
    Callback = function()
        local autoexecScript = [[-- Tokisaki Kurumi Hub Autoexec
repeat task.wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
]]
        local success = pcall(function()
            if writefile then
                writefile("autoexec/KurumiHub.lua", autoexecScript)
            end
        end)
        
        if success then
            Fluent:Notify({ Title = "Autoexecute", Content = "Script berhasil disimpan ke folder autoexec!", Duration = 4 })
        else
            Fluent:Notify({ Title = "Autoexecute", Content = "Executor kamu tidak mendukung penulisan folder autoexec!", Duration = 4 })
        end
    end
})

MiscTab:AddButton({
    Title = "📋 Copy Script Loader to Clipboard",
    Description = "Salin script ke clipboard untuk dipasang di folder autoexec manual",
    Callback = function()
        local copyFn = setclipboard or toclipboard
        if copyFn then
            copyFn([[-- Tokisaki Kurumi Hub Autoexec Loader
repeat task.wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
]])
            Fluent:Notify({ Title = "Autoexecute", Content = "Script loader berhasil disalin ke Clipboard!", Duration = 3 })
        else
            Fluent:Notify({ Title = "Autoexecute", Content = "Executor kamu tidak mendukung setclipboard!", Duration = 3 })
        end
    end
})

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- ANTI-AFK
local idledConnection = nil
local function toggleAntiAfk(state)
    if state then
        if not idledConnection then
            idledConnection = LocalPlayer.Idled:Connect(function()
                if ConfigData.AntiAfkEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
            end)
        end
    else
        if idledConnection then
            idledConnection:Disconnect()
            idledConnection = nil
        end
    end
end

MiscTab:AddToggle("AntiAfkToggle", {
    Title = "Anti-AFK",
    Description = "Mencegah keluar server karena diam terlalu lama",
    Default = ConfigData.AntiAfkEnabled,
    Callback = function(Value)
        ConfigData.AntiAfkEnabled = Value
        saveConfig()
        toggleAntiAfk(Value)
    end
})

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- ADMIN / STAFF DETECTION & AUTO KICK
local function checkAdmin(plr)
    if not ConfigData.AdminKickEnabled or plr == LocalPlayer then return end
    
    local isAdmin = false
    local playerNameLower = plr.Name:lower()
    local displayNameLower = plr.DisplayName:lower()
    
    local keywords = {"admin", "mod", "staff", "owner", "dev", "developer", "helper", "trial", "operator"}
    for _, keyword in ipairs(keywords) do
        if string.find(playerNameLower, keyword) or string.find(displayNameLower, keyword) then
            isAdmin = true
            break
        end
    end
    
    pcall(function()
        if game.CreatorType == Enum.CreatorType.Group then
            local rankInGroup = plr:GetRankInGroup(game.CreatorId)
            if rankInGroup >= 10 then 
                isAdmin = true 
            end
        elseif game.CreatorType == Enum.CreatorType.User then
            if plr.UserId == game.CreatorId then
                isAdmin = true
            end
        end
    end)

    if isAdmin then 
        LocalPlayer:Kick("\n[Kurumi Hub Protection]\nDetected Staff/Admin/Mod (" .. plr.Name .. ") in server. Account safe kicked!") 
    end
end

MiscTab:AddToggle("AdminKickToggle", {
    Title = "Auto Kick On Admin/Staff Join",
    Description = "Otomatis keluar server jika mendeteksi Admin, Mod, Staff, atau Developer",
    Default = ConfigData.AdminKickEnabled,
    Callback = function(Value)
        ConfigData.AdminKickEnabled = Value
        saveConfig()
        if ConfigData.AdminKickEnabled then
            for _, plr in pairs(Players:GetPlayers()) do 
                checkAdmin(plr) 
            end
        end
    end
})

Players.PlayerAdded:Connect(checkAdmin)

---------------------------------------------------------
-- TAB 5: THEMES & SETTINGS
---------------------------------------------------------
local themes = {"Darker", "Rose", "Amethyst", "Dark", "Aqua"}

ThemeTab:AddParagraph({ Title = "🎨 UI Theme Selection", Content = "Pilih tema warna tampilan Tokisaki Kurumi hub" })

for _, t in pairs(themes) do
    ThemeTab:AddButton({
        Title = t .. " Theme",
        Callback = function()
            Fluent:SetTheme(t)
            ConfigData.Theme = t
            saveConfig()
        end
    })
end

ThemeTab:AddParagraph({ Title = "-----------------------------------", Content = "" })
ThemeTab:AddParagraph({ Title = "⚙️ Script Configuration", Content = "Atur file konfigurasi script secara manual" })

ThemeTab:AddButton({
    Title = "💾 Save Config Manually",
    Description = "Simpan paksa semua pengaturan saat ini",
    Callback = function()
        saveConfig()
        Fluent:Notify({
            Title = "Tokisaki Kurumi hub⏱️",
            Content = "Semua konfigurasi berhasil disimpan!",
            Duration = 3
        })
    end
})

ThemeTab:AddButton({
    Title = "🔄 Reset Config (Default)",
    Description = "Hapus data config saat ini (Butuh re-execute script)",
    Callback = function()
        if isfile(ConfigFile) then
            delfile(ConfigFile)
        end
        Fluent:Notify({
            Title = "Tokisaki Kurumi hub⏱️",
            Content = "Config telah di-reset! Silakan Execute ulang script ini.",
            Duration = 5
        })
    end
})
