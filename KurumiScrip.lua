-- 1. Get Roblox Services & Player Data
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local Username = LocalPlayer.Name
local DisplayName = LocalPlayer.DisplayName

-- 2. FULL CONFIG SYSTEM
local ConfigFile = "KurumiHub_FullConfig.json"

local ConfigData = {
    Theme = "Darker",
    SpeedEnabled = false,
    SpeedValue = 50,
    FlyEnabled = false,
    FlyValue = 50,
    AntiAfkEnabled = false,
    PlayerEspEnabled = false,
    AdminKickEnabled = false
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
    Title = "Kurumi Hub ⏳",
    SubTitle = "Speed Fly ESP Only | " .. DisplayName,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = ConfigData.Theme,
    MinimizeKey = Enum.KeyCode.RightControl
})

-- 5. Create UI Tabs
local ProfileTab = Window:AddTab({ Title = "Profile", Icon = "user" })
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local MiscTab = Window:AddTab({ Title = "Misc & ESP", Icon = "eye" })
local ThemeTab = Window:AddTab({ Title = "Theme", Icon = "palette" })

---------------------------------------------------------
-- TAB 1: PROFILE
---------------------------------------------------------
ProfileTab:AddParagraph({ Title = "👤 User Profile", Content = "Display Name: " .. DisplayName .. "\nUsername: @" .. Username })

---------------------------------------------------------
-- TAB 2: MAIN (Movement & Anti-AFK)
---------------------------------------------------------
local normalSpeed = 16

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if ConfigData.SpeedEnabled then
            hum.WalkSpeed = ConfigData.SpeedValue
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
    Title = "WalkSpeed Value (Ketik Angka)",
    Default = tostring(ConfigData.SpeedValue),
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            ConfigData.SpeedValue = num
            saveConfig()
        end
    end
})

MainTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- Logika Fly
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

        if moveDir.Magnitude > 0 then
            bodyVelocity.velocity = camera.CFrame.LookVector * (moveDir.Magnitude * ConfigData.FlyValue)
        else
            bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        end
        bodyGyro.cframe = camera.CFrame
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if ConfigData.FlyEnabled then startFlying() end
end)

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
    Title = "Fly Speed Value (Ketik Angka)",
    Default = tostring(ConfigData.FlyValue),
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            ConfigData.FlyValue = num
            saveConfig()
        end
    end
})

MainTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- Anti-AFK
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

MainTab:AddToggle("AntiAfkToggle", {
    Title = "Anti-AFK",
    Default = ConfigData.AntiAfkEnabled,
    Callback = function(Value)
        ConfigData.AntiAfkEnabled = Value
        saveConfig()
        toggleAntiAfk(Value)
    end
})

---------------------------------------------------------
-- TAB 3: PLAYER ESP SYSTEM ONLY
---------------------------------------------------------

local function createSmartESP(obj, targetPart, getDisplayTextFunc, folderName, configKey, fillColor, textColor)
    if targetPart:FindFirstChild(folderName) then return end

    local espFolder = Instance.new("Folder")
    espFolder.Name = folderName
    espFolder.Parent = targetPart

    local highlight = Instance.new("Highlight")
    highlight.Name = "Glow"
    highlight.FillColor = fillColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.1
    highlight.Enabled = ConfigData[configKey]
    highlight.Parent = espFolder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ItemTag"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 230, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ConfigData[configKey]
    billboard.Parent = espFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextColor3 = textColor
    textLabel.Text = "Loading..."
    textLabel.Parent = billboard

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 1.5
    stroke.Parent = textLabel

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not targetPart or not targetPart.Parent or not obj or not obj.Parent then
            if connection then connection:Disconnect() end
            return
        end

        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if ConfigData[configKey] and hrp then
            local myPos = hrp.Position
            local distance = math.floor((myPos - targetPart.Position).Magnitude)
            textLabel.Text = getDisplayTextFunc() .. " [" .. tostring(distance) .. "m]"
            
            billboard.Enabled = true
            highlight.Enabled = true
        else
            billboard.Enabled = false
            highlight.Enabled = false
        end
    end)
end

-- PLAYER ESP ONLY
local function applyPlayerEsp(plr)
    if plr == LocalPlayer then return end
    local function setupEsp(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        createSmartESP(char, hrp, function() return plr.Name end, "Kurumi_PlayerESP", "PlayerEspEnabled", Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 255, 255))
    end
    if plr.Character then setupEsp(plr.Character) end
    plr.CharacterAdded:Connect(setupEsp)
end

MiscTab:AddToggle("PlayerEspToggle", {
    Title = "Player ESP",
    Default = ConfigData.PlayerEspEnabled,
    Callback = function(Value)
        ConfigData.PlayerEspEnabled = Value
        saveConfig()
        for _, plr in pairs(Players:GetPlayers()) do applyPlayerEsp(plr) end
    end
})
Players.PlayerAdded:Connect(applyPlayerEsp)

MiscTab:AddParagraph({ Title = "-----------------------------------", Content = "" })

-- AUTO KICK IF ADMIN JOINS
local function checkAdmin(plr)
    if not ConfigData.AdminKickEnabled or plr == LocalPlayer then return end
    local isAdmin = false
    if plr:GetRankInGroup(game.CreatorId) >= 200 or plr.AccountAge < 1 then isAdmin = true end
    if isAdmin then LocalPlayer:Kick("\n[Kurumi Hub Protection]\nAn Admin/Moderator (" .. plr.Name .. ") joined the server. Account kicked safely!") end
end

MiscTab:AddToggle("AdminKickToggle", {
    Title = "Auto Kick On Admin Join",
    Default = ConfigData.AdminKickEnabled,
    Callback = function(Value)
        ConfigData.AdminKickEnabled = Value
        saveConfig()
        if ConfigData.AdminKickEnabled then
            for _, plr in pairs(Players:GetPlayers()) do checkAdmin(plr) end
        end
    end
})
Players.PlayerAdded:Connect(checkAdmin)

---------------------------------------------------------
-- TAB 4: THEME SETTINGS & RESET CONFIG
---------------------------------------------------------
local themes = {"Darker", "Rose", "Amethyst", "Dark", "Aqua"}

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

ThemeTab:AddButton({
    Title = "🔄 Reset All Configs",
    Description = "Deletes all saved configs & reverts back to default",
    Callback = function()
        if delfile and isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        Fluent:Notify({ Title = "Config Reset!", Content = "All configurations deleted. Please re-execute script.", Duration = 4 })
    end
})

---------------------------------------------------------
-- 6. FLOATING TOGGLE BUTTON (KURUMI ⏳) - AUTO CLEANUP
---------------------------------------------------------
if CoreGui:FindFirstChild("KurumiToggleGui") then
    CoreGui.KurumiToggleGui:Destroy()
end
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if playerGui and playerGui:FindFirstChild("KurumiToggleGui") then
    playerGui.KurumiToggleGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "KurumiToggleGui"
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or playerGui
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.Size = UDim2.fromOffset(60, 60)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "KURUMI\n⏳"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 11
ToggleBtn.Active = true
ToggleBtn.Draggable = true
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if Window and Window.Minimize then Window:Minimize() end
end)

---------------------------------------------------------
-- 7. INITIALIZE SAVED STATES ON EXECUTE
---------------------------------------------------------
if ConfigData.AntiAfkEnabled then toggleAntiAfk(true) end
if ConfigData.FlyEnabled then startFlying() end
if ConfigData.PlayerEspEnabled then
    for _, plr in pairs(Players:GetPlayers()) do applyPlayerEsp(plr) end
end
if ConfigData.AdminKickEnabled then
    for _, plr in pairs(Players:GetPlayers()) do checkAdmin(plr) end
end

GuiService.ErrorMessageChanged:Connect(function(errorMessage)
    if errorMessage and errorMessage ~= "" then
        task.wait(2)
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
end)

Fluent:Notify({ Title = "Kurumi Hub ⏳", Content = "Script loaded successfully with Player ESP only!", Duration = 5 })
