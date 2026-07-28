-- =========================================================
-- KURUMI HUB ⏳ - SCRIPT LIMITED EDITION V1 🌸TOKISAKI KURUMI HUB🌸
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
    ClientStatusEnabled = true
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

-- 4. Create Main UI Window (Updated Title)
local Window = Fluent:CreateWindow({
    Title = "Kurumi Hub ⏳",
    SubTitle = "Script Limited edition v1 🌸Tokisaki Kurumi Hub🌸 | " .. DisplayName,
    TabWidth = 130,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = ConfigData.Theme,
    MinimizeKey = Enum.KeyCode.RightControl
})

-- 5. Create UI Tabs
local ProfileTab = Window:AddTab({ Title = "Profile", Icon = "user" })
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local AutoTab = Window:AddTab({ Title = "Automatic", Icon = "wand" })
local MiscTab = Window:AddTab({ Title = "Misc & ESP", Icon = "eye" })
local ThemeTab = Window:AddTab({ Title = "Themes Custom", Icon = "palette" })

---------------------------------------------------------
-- FIX DIRECT TOGGLE BUTTON FOR FLUENT (OPEN / CLOSE)
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
-- OVERLAY CLIENT STATUS GUI (Optimized Low CPU usage)
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
StatusFrame.Position = UDim2.new(0, 15, 0.05, 0)
StatusFrame.Size = UDim2.fromOffset(380, 26)
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
StatusText.Text = "FPS: -- | Ping: --ms | CPU: --% | GPU: --% | Players: --"
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

            StatusText.Text = string.format(
                "⚡ FPS: %d  |  📡 Ping: %dms  |  💻 CPU: %d%%  |  🎮 GPU: %d%%  |  👥 Players: %d",
                fps, ping, cpuUsage, gpuUsage, playerOnline
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
    Description = "Menampilkan/menyembunyikan GUI overlay FPS, Ping, CPU, GPU, & Players",
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
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = ConfigData.SpeedValue * 20
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
    Title = "WalkSpeed Value (0.1 - 10)",
    Default = tostring(ConfigData.SpeedValue),
    Numeric = false, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            num = math.clamp(num, 0.1, 10)
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
        local actualFlySpeed = ConfigData.FlyValue * 20

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
    Title = "Fly Speed Value (0.1 - 10)",
    Default = tostring(ConfigData.FlyValue),
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            num = math.clamp(num, 0.1, 10)
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

---------------------------------------------------------
-- ADVANCED GOD MODE & ANTI-DESTRUCTION SYSTEM
---------------------------------------------------------
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

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if ConfigData.FlyEnabled then startFlying() end
    if ConfigData.GodModeEnabled then toggleGodMode(true) end
    if ConfigData.FreezePlayerEnabled then toggleFreezePlayer(true) end
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
-- TAB 4: MISC & ESP
---------------------------------------------------------
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
-- TAB 5: THEMES CUSTOM
---------------------------------------------------------
local themes = {"Darker", "Rose", "Amethyst", "Dark", "Aqua"}

ThemeTab:AddParagraph({ Title = "🎨 UI Theme Selection", Content = "Pilih tema warna tampilan Kurumi Hub" })

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
