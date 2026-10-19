-- =========================================================
--  ANIME HUB + FLOATING STATS GUI (EXACT MATCH ESP FIXED)
-- =========================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 2. Download Background (saberv2)
local imageUrl = "https://raw.githubusercontent.com/NonaMuda-Studio/Script/main/Wallpaper%20UI/Kafka.png"
local fileName = "anime_bg_kafka.png"

if not isfile(fileName) then
    pcall(function()
        writefile(fileName, game:HttpGet(imageUrl))
    end)
end

---------------------------------------------------------
-- CONFIG SYSTEM (AUTO LOAD & SAVE ENGINE)
---------------------------------------------------------
local ConfigFileName = "AnimeHub_Config_" .. LocalPlayer.UserId .. ".json"

local AttackModes = { "Semua Metode", "Tool Activate", "Klik Layar (VIM)", "VirtualUser" }
local MagnetRanges = { "50 studs", "100 studs", "200 studs", "500 studs" }
local WalkSpeeds = { "16 (Default)", "32", "50", "100", "200", "500" }
local FlySpeeds = { "50", "100", "200", "500", "1000" }
local FreecamSpeeds = { "20", "50", "100", "300", "1000" }
local ZoomOptions = { "128 (Default)", "500", "1000", "5000" }

local DisplayStats = true
local LockStats = false
local AntiAfk = false
local FreezePosition = false
local AutoAttack = false
local AttackMode = "Semua Metode"
local MagnetNPC = false
local MagnetBoss = false
local MagnetRangeText = "100 studs"
local WalkSpeedOn = false
local WalkSpeedText = "50"
local FlySpeedText = "100"
local FreecamSpeedText = "50"
local ZoomOn = false
local ZoomText = "1000"
local EspChest = false
local EspCrystalSeed = false
local EspTracer = false
local EspSlime = false
local EspHogyoku = false
local EspFragment = false
local FragNotify = false

local LastFragCount = 0

local function AutoSave()
    local configData = {
        DisplayStats = DisplayStats,
        LockStats = LockStats,
        AntiAfk = AntiAfk,
        FreezePosition = FreezePosition,
        AutoAttack = AutoAttack,
        AttackMode = AttackMode,
        MagnetNPC = MagnetNPC,
        MagnetBoss = MagnetBoss,
        MagnetRangeText = MagnetRangeText,
        WalkSpeedOn = WalkSpeedOn,
        WalkSpeedText = WalkSpeedText,
        FlySpeedText = FlySpeedText,
        FreecamSpeedText = FreecamSpeedText,
        ZoomOn = ZoomOn,
        ZoomText = ZoomText,
        EspChest = EspChest,
        EspCrystalSeed = EspCrystalSeed,
        EspTracer = EspTracer,
        EspSlime = EspSlime,
        EspHogyoku = EspHogyoku,
        EspFragment = EspFragment,
        FragNotify = FragNotify
    }
    pcall(function()
        writefile(ConfigFileName, HttpService:JSONEncode(configData))
    end)
end

if isfile(ConfigFileName) then
    pcall(function()
        local content = readfile(ConfigFileName)
        local data = HttpService:JSONDecode(content)
        if data then
            if data.DisplayStats ~= nil then DisplayStats = data.DisplayStats end
            if data.LockStats ~= nil then LockStats = data.LockStats end
            if data.AntiAfk ~= nil then AntiAfk = data.AntiAfk end
            if data.FreezePosition ~= nil then FreezePosition = data.FreezePosition end
            if data.AutoAttack ~= nil then AutoAttack = data.AutoAttack end
            if data.AttackMode ~= nil then AttackMode = data.AttackMode end
            if data.MagnetNPC ~= nil then MagnetNPC = data.MagnetNPC end
            if data.MagnetBoss ~= nil then MagnetBoss = data.MagnetBoss end
            if data.MagnetRangeText ~= nil then MagnetRangeText = data.MagnetRangeText end
            if data.WalkSpeedOn ~= nil then WalkSpeedOn = data.WalkSpeedOn end
            if data.WalkSpeedText ~= nil then WalkSpeedText = data.WalkSpeedText end
            if data.FlySpeedText ~= nil then FlySpeedText = data.FlySpeedText end
            if data.FreecamSpeedText ~= nil then FreecamSpeedText = data.FreecamSpeedText end
            if data.ZoomOn ~= nil then ZoomOn = data.ZoomOn end
            if data.ZoomText ~= nil then ZoomText = data.ZoomText end
            if data.EspChest ~= nil then EspChest = data.EspChest end
            if data.EspCrystalSeed ~= nil then EspCrystalSeed = data.EspCrystalSeed end
            if data.EspTracer ~= nil then EspTracer = data.EspTracer end
            if data.EspSlime ~= nil then EspSlime = data.EspSlime end
            if data.EspHogyoku ~= nil then EspHogyoku = data.EspHogyoku end
            if data.EspFragment ~= nil then EspFragment = data.EspFragment end
            if data.FragNotify ~= nil then FragNotify = data.FragNotify end
        end
    end)
end

if not table.find(AttackModes, AttackMode) then
    AttackMode = "Semua Metode"
end

if not table.find(MagnetRanges, MagnetRangeText) then
    MagnetRangeText = "100 studs"
end

if not table.find(WalkSpeeds, WalkSpeedText) then
    WalkSpeedText = "50"
end

if not table.find(FlySpeeds, FlySpeedText) then
    FlySpeedText = "100"
end

if not table.find(FreecamSpeeds, FreecamSpeedText) then
    FreecamSpeedText = "50"
end

if not table.find(ZoomOptions, ZoomText) then
    ZoomText = "1000"
end

-- 3. Window UI Utama
local Window = WindUI:CreateWindow({
    Title = "Anime Hub",
    Author = "Lineage Piece",
    Icon = "sparkles",
    Theme = "Dark",
    Transparent = true,
    Background = isfile(fileName) and getcustomasset(fileName) or "",
    BackgroundImageTransparency = 0.35,
    Size = UDim2.fromOffset(99990, 99990),
    Resizable = true,
})

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

if ParentGui:FindFirstChild("FloatingStatsGui") then
    ParentGui:FindFirstChild("FloatingStatsGui"):Destroy()
end

local OverlayScreenGui = Instance.new("ScreenGui")
OverlayScreenGui.Name = "FloatingStatsGui"
OverlayScreenGui.ResetOnSpawn = false
OverlayScreenGui.DisplayOrder = 1
OverlayScreenGui.IgnoreGuiInset = true
OverlayScreenGui.Parent = ParentGui

---------------------------------------------------------
-- FLOATING STATS GUI
---------------------------------------------------------
local StatsOverlay = Instance.new("Frame")
StatsOverlay.Name = "StatsOverlay"
StatsOverlay.Size = UDim2.fromOffset(340, 52)
StatsOverlay.Position = UDim2.new(1, -350, 0, 10)
StatsOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
StatsOverlay.BackgroundTransparency = 0.25
StatsOverlay.Visible = DisplayStats
StatsOverlay.Parent = OverlayScreenGui

local OverlayCorner = Instance.new("UICorner", StatsOverlay)
OverlayCorner.CornerRadius = UDim.new(0, 8)

local OverlayStroke = Instance.new("UIStroke", StatsOverlay)
OverlayStroke.Color = Color3.fromRGB(255, 80, 120)
OverlayStroke.Thickness = 1.2

local OverlayTitle = Instance.new("TextLabel")
OverlayTitle.Name = "OverlayTitle"
OverlayTitle.Size = UDim2.new(1, 0, 0, 16)
OverlayTitle.Position = UDim2.new(0, 0, 0, 3)
OverlayTitle.BackgroundTransparency = 1
OverlayTitle.Text = "📊 AFK-Stats GUI"
OverlayTitle.TextColor3 = Color3.fromRGB(255, 150, 180)
OverlayTitle.Font = Enum.Font.GothamBold
OverlayTitle.TextSize = 10
OverlayTitle.Parent = StatsOverlay

local OverlayText = Instance.new("TextLabel")
OverlayText.Name = "OverlayText"
OverlayText.Size = UDim2.new(1, -10, 0, 28)
OverlayText.Position = UDim2.new(0, 5, 0, 20)
OverlayText.BackgroundTransparency = 1
OverlayText.Font = Enum.Font.GothamMedium
OverlayText.TextColor3 = Color3.fromRGB(240, 240, 240)
OverlayText.TextSize = 9.5
OverlayText.Text = "⚡ FPS: -- | 📡 Ping: --ms | 👥 Players: --\n💻 CPU: --% | 🎮 GPU: --% | ⏱️ Server Age: --"
OverlayText.Parent = StatsOverlay

local isDraggingOverlay = false
local dragStartPos, startOverlayPos

StatsOverlay.InputBegan:Connect(function(input)
    if not LockStats and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        isDraggingOverlay = true
        dragStartPos = input.Position
        startOverlayPos = StatsOverlay.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingOverlay and not LockStats and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        StatsOverlay.Position = UDim2.new(
            startOverlayPos.X.Scale, startOverlayPos.X.Offset + delta.X,
            startOverlayPos.Y.Scale, startOverlayPos.Y.Offset + delta.Y
        )
    end
end)

StatsOverlay.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingOverlay = false
    end
end)

---------------------------------------------------------
-- VARIABEL & SYSTEM ENGINE
---------------------------------------------------------
local LockedCFrame = nil
local idledConnection = nil

local ActiveESPs = {}

local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then gameName = info.Name end
end)

if AntiAfk then
    idledConnection = LocalPlayer.Idled:Connect(function()
        if AntiAfk then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if FreezePosition then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            if not LockedCFrame then LockedCFrame = root.CFrame end
            root.CFrame = LockedCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.Anchored = true
        end
    else
        if LockedCFrame then
            LockedCFrame = nil
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
        end
    end
end)

---------------------------------------------------------
-- TAB 1: HOME
---------------------------------------------------------
local HomeTab = Window:Tab({ Title = "Home", Icon = "home" })

HomeTab:Section({ Title = "• Player Profile" })

local ProfileInfo = string.format(
    "👤 Username: @%s\n🏷️ Display Name: %s\n🆔 User ID: %d\n📅 Account Age: %d Days\n🎮 Game: %s",
    LocalPlayer.Name, LocalPlayer.DisplayName, LocalPlayer.UserId, LocalPlayer.AccountAge, gameName
)

HomeTab:Paragraph({
    Title = "Informasi Akun",
    Desc = ProfileInfo,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    ImageSize = 60
})

HomeTab:Section({ Title = "📊 Real-Time Performance Stats" })

local StatsParagraph = HomeTab:Paragraph({
    Title = "Performance Stats",
    Desc = "⚡ FPS: --  |  📡 Ping: --ms  |  👥 Players: --\n💻 CPU: --%  |  🎮 GPU: --%  |  ⏱️ Server Age: --"
})

HomeTab:Section({ Title = "⚙️ Pengaturan Stats GUI Overlay" })

HomeTab:Toggle({
    Title = "Display Stats GUI",
    Desc = "Tampilkan / Sembunyikan Mini Stats GUI di kanan atas",
    Value = DisplayStats,
    Callback = function(State)
        DisplayStats = State
        StatsOverlay.Visible = State
        AutoSave()
    end,
})

HomeTab:Toggle({
    Title = "Lock Stats GUI",
    Desc = "Kunci posisi Stats GUI kanan atas agar tidak bisa digeser",
    Value = LockStats,
    Callback = function(State)
        LockStats = State
        AutoSave()
    end,
})

HomeTab:Section({ Title = "🛡️ Fitur Proteksi & Utilitas" })

HomeTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Mencegah terputus koneksi akibat AFK 20 menit",
    Value = AntiAfk,
    Callback = function(State)
        AntiAfk = State
        if AntiAfk and not idledConnection then
            idledConnection = LocalPlayer.Idled:Connect(function()
                if AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
            end)
        end
        AutoSave()
    end,
})

HomeTab:Toggle({
    Title = "Freeze Position",
    Desc = "Kunci lokasi karakter secara mutlak. Kebal knockback.",
    Value = FreezePosition,
    Callback = function(State)
        FreezePosition = State
        if State then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                LockedCFrame = char.HumanoidRootPart.CFrame
            end
        else
            LockedCFrame = nil
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.Anchored = false
            end
        end
        AutoSave()
    end,
})

---------------------------------------------------------
-- ULTRA-OPTIMIZED ESP ENGINE (STRICT FILTER)
---------------------------------------------------------
local function RemoveESP(obj)
    if ActiveESPs[obj] then
        pcall(function()
            if ActiveESPs[obj].Connections then
                for _, conn in ipairs(ActiveESPs[obj].Connections) do conn:Disconnect() end
            end
            if ActiveESPs[obj].Highlight then ActiveESPs[obj].Highlight:Destroy() end
            if ActiveESPs[obj].Billboard then ActiveESPs[obj].Billboard:Destroy() end
            if ActiveESPs[obj].Line then ActiveESPs[obj].Line:Destroy() end
        end)
        ActiveESPs[obj] = nil
    end
end

local function ClearAllESP()
    for obj, _ in pairs(ActiveESPs) do
        RemoveESP(obj)
    end
end

local function GetTargetPart(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("ProximityPrompt") then
        local p = obj.Parent
        if p:IsA("BasePart") then return p end
        if p:IsA("Model") then return p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true) end
    end
    return nil
end

-- Cari target ESP untuk Fragment (lebih longgar dari GetTargetPart)
local function ResolveFragmentTarget(prompt)
    local p = prompt.Parent
    if p and p:IsA("Attachment") then p = p.Parent end

    local target = nil
    local cur = p
    local depth = 0
    while cur and cur ~= workspace and depth < 5 do
        if cur:IsA("BasePart") or cur:IsA("Model") then
            target = cur
            break
        end
        cur = cur.Parent
        depth = depth + 1
    end

    if not target and p then
        target = p:FindFirstChildWhichIsA("BasePart", true)
    end

    -- Kalau part-nya transparan, sorot Model kecil di atasnya (mesh yang kelihatan)
    if target and target:IsA("BasePart") and target.Transparency >= 0.9 then
        local m = target.Parent
        if m and m:IsA("Model") and m ~= workspace and #m:GetDescendants() <= 40 then
            target = m
        end
    end

    return target
end

local function CreateESP(obj, espType, title, color, promptRef)
    if ActiveESPs[obj] then return end

    local part = GetTargetPart(obj)
    if not part then return end

    color = color or Color3.fromRGB(255, 80, 120)

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight_Hub"
    hl.Adornee = obj:IsA("ProximityPrompt") and obj.Parent or obj
    hl.FillColor = color
    hl.FillTransparency = 0.4
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Parent = hl.Adornee

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Billboard_Hub"
    bb.Adornee = part
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 2.5, 0)
    bb.Parent = part

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.Parent = bb

    local line = Instance.new("Frame")
    line.Name = "ESP_TracerLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = color
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 0.2
    line.Visible = false
    line.Parent = OverlayScreenGui

    local connections = {}
    
    table.insert(connections, obj.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveESP(obj) end
    end))

    local prompt = promptRef or (obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildWhichIsA("ProximityPrompt", true))
    if prompt then
        table.insert(connections, prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
            if not prompt.Enabled then RemoveESP(obj) end
        end))
        table.insert(connections, prompt.Triggered:Connect(function()
            task.delay(0.1, function() RemoveESP(obj) end)
        end))
    end

    ActiveESPs[obj] = {
        Highlight = hl,
        Billboard = bb,
        Text = txt,
        Line = line,
        Part = part,
        Prompt = prompt,
        Connections = connections,
        Type = espType,
        Title = title
    }
end

-- Detektor Diperketat: Wajib "crystal" DAN "seed"
task.spawn(function()
    while task.wait(9.9) do
        if EspChest or EspCrystalSeed or EspSlime or EspHogyoku or EspFragment or FragNotify then
            pcall(function()
                local fragSeen = {}
                local fragCount = 0

                for _, v in pairs(workspace:GetDescendants()) do
                    if v and v.Parent and v:IsDescendantOf(workspace) then
                        if EspCrystalSeed then
                            local isSeed = false
                            local targetObj = nil

                            if v:IsA("ProximityPrompt") and v.Enabled then
                                local objText = string.lower(v.ObjectText or "")
                                local actText = string.lower(v.ActionText or "")
                                -- Cek ketat: harus mengandung kata "crystal" DAN "seed"
                                if (string.find(objText, "crystal") and string.find(objText, "seed")) or 
                                   (string.find(actText, "crystal") and string.find(actText, "seed")) then
                                    isSeed = true
                                    targetObj = v.Parent
                                end
                            elseif v:IsA("BasePart") or v:IsA("Model") then
                                local nameLower = string.lower(v.Name)
                                if string.find(nameLower, "crystal seed") or string.find(nameLower, "crystalseed") or
                                   (string.find(nameLower, "crystal") and string.find(nameLower, "seed")) then
                                    isSeed = true
                                    targetObj = v
                                end
                            end

                            if isSeed and targetObj then
                                CreateESP(targetObj, "CrystalSeed", "💎 CRYSTAL SEED", Color3.fromRGB(255, 105, 180))
                            end
                        end

                        if (EspSlime or EspHogyoku) and v:IsA("ProximityPrompt") and v.Enabled then
                            local objText = string.lower(v.ObjectText or "")
                            local actText = string.lower(v.ActionText or "")
                            local allText = objText .. " " .. actText
                            local pObj = v.Parent
                            if pObj and pObj:IsA("Attachment") then pObj = pObj.Parent end
                            if pObj then
                                local label = (v.ObjectText and v.ObjectText ~= "") and v.ObjectText or nil
                                if EspSlime and string.find(allText, "slime") and string.find(allText, "piece") then
                                    CreateESP(pObj, "SlimePiece", "🟦 " .. (label or "SLIME PIECE"), Color3.fromRGB(80, 170, 255))
                                elseif EspHogyoku and string.find(allText, "hogyoku") and string.find(allText, "fragment") then
                                    CreateESP(pObj, "Hogyoku", "🔮 " .. (label or "HOGYOKU FRAGMENT"), Color3.fromRGB(170, 90, 255))
                                end
                            end
                        end

                        if (EspFragment or FragNotify) and v:IsA("ProximityPrompt") and v.Enabled then
                            local fObj = v.Parent
                            if fObj and fObj:IsA("Attachment") then fObj = fObj.Parent end
                            if fObj then
                                local fText = string.lower((v.ObjectText or "") .. " " .. (v.ActionText or ""))
                                if #(v.ObjectText or "") <= 40
                                    and string.find(fText, "ancient")
                                    and string.find(fText, "fragment")
                                    and not string.find(fText, "hogyoku")
                                    and not string.find(fText, "slime") then
                                    if not fragSeen[v] then
                                        fragSeen[v] = true
                                        fragCount = fragCount + 1
                                        if EspFragment then
                                            local fTarget = ResolveFragmentTarget(v)
                                            if fTarget then
                                                if not ActiveESPs[fTarget] then
                                                    local fLabel = (v.ObjectText and v.ObjectText ~= "") and v.ObjectText or nil
                                                    CreateESP(fTarget, "Fragment", "🧩 " .. (fLabel or "ANCIENT FRAGMENT"), Color3.fromRGB(255, 200, 60), v)
                                                    if ActiveESPs[fTarget] then
                                                        print("[AnimeHub] ESP Fragment dibuat:", fTarget:GetFullName())
                                                    else
                                                        warn("[AnimeHub] ESP Fragment gagal dibuat:", fTarget:GetFullName())
                                                    end
                                                end
                                            else
                                                warn("[AnimeHub] Target Fragment tidak ketemu untuk prompt:", v:GetFullName())
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if EspChest then
    local isChest = false
    local chestObj = nil

    if v:IsA("ProximityPrompt") and v.Enabled then
        local objText = string.lower(v.ObjectText or "")
        local actText = string.lower(v.ActionText or "")
        if string.find(objText, "chest") or string.find(objText, "treasure") or
           string.find(actText, "chest") or string.find(actText, "treasure") then
            isChest = true
            chestObj = v.Parent
        end
    elseif v:IsA("BasePart") or v:IsA("Model") then
        local nameLower = string.lower(v.Name)
        if string.find(nameLower, "chest") or string.find(nameLower, "treasure") then
            isChest = true
            chestObj = v
        end
    end

    if isChest and chestObj then
        local dup = false
        local anc = chestObj.Parent
        while anc do
            if ActiveESPs[anc] then dup = true break end
            anc = anc.Parent
        end
        if not dup then
            CreateESP(chestObj, "Chest", "📦 CHEST", Color3.fromRGB(255, 80, 120))
        end
    end
end
                    end
                end

                if FragNotify then
                    if fragCount > LastFragCount then
                        WindUI:Notify({
                            Title = "Ancient Fragments",
                            Content = "Ancient Fragments spawn (" .. fragCount .. ")",
                            Duration = 8
                        })
                    end
                    LastFragCount = fragCount
                end
            end)
        end
    end
end)

-- Render Loop ESP
RunService.RenderStepped:Connect(function()
    if not (EspChest or EspCrystalSeed or EspSlime or EspHogyoku or EspFragment) then 
        for _, data in pairs(ActiveESPs) do
            if data.Line then data.Line.Visible = false end
        end
        return 
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    local charScreenPos = nil
    if root then
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then charScreenPos = Vector2.new(pos.X, pos.Y) end
    end

    for obj, data in pairs(ActiveESPs) do
        local part = data.Part
        local prompt = (data.Type == "Fragment" and data.Prompt) or (obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildWhichIsA("ProximityPrompt", true))

        local isInvalid = not obj 
            or not obj.Parent 
            or not obj:IsDescendantOf(workspace) 
            or not part 
            or not part.Parent 
            or not part:IsDescendantOf(workspace)
            or (data.Type == "CrystalSeed" and part:IsA("BasePart") and part.Transparency >= 0.85)
or (data.Type == "Fragment" and data.Prompt and not data.Prompt:IsDescendantOf(workspace))
or (data.Type == "Chest" and not prompt)
or (data.Type == "Chest" and prompt and prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent.Transparency >= 0.85)
or (prompt and not prompt.Enabled)

        if isInvalid then
            RemoveESP(obj)
        else
            local dist = root and math.floor((root.Position - part.Position).Magnitude) or 0
            data.Text.Text = string.format("%s\n📏 [%d Studs]", data.Title or "OBJECT", dist)

            if EspTracer and data.Line then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and charScreenPos then
                    local p1 = charScreenPos
                    local p2 = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (p1 - p2).Magnitude
                    local center = (p1 + p2) / 2
                    local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))

                    data.Line.Size = UDim2.fromOffset(distance, 1.5)
                    data.Line.Position = UDim2.fromOffset(center.X, center.Y)
                    data.Line.Rotation = angle
                    data.Line.Visible = true
                else
                    data.Line.Visible = false
                end
            elseif data.Line then
                data.Line.Visible = false
            end
        end
    end
end)

---------------------------------------------------------
-- AUTO ATTACK / M1
---------------------------------------------------------
local function ClickScreen()
    if not VIM then return end
    local vp = Camera.ViewportSize
    local x, y = vp.X / 2, vp.Y / 2
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
    pcall(function()
        VIM:SendTouchEvent(1, 0, x, y)
        task.wait(0.03)
        VIM:SendTouchEvent(1, 2, x, y)
    end)
end

local function DoAttack()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            tool = bp:FindFirstChild("Combat") or bp:FindFirstChildOfClass("Tool")
            if tool then
                hum:EquipTool(tool)
                task.wait(0.15)
            end
        end
    end

    local useAll = (AttackMode == "Semua Metode")

    if (useAll or AttackMode == "Tool Activate") and tool and tool.Parent == char then
        tool:Activate()
    end

    if useAll or AttackMode == "Klik Layar (VIM)" then
        ClickScreen()
    end

    if useAll or AttackMode == "VirtualUser" then
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(0, 0), Camera.CFrame)
    end
end

task.spawn(function()
    while task.wait(0.25) do
        if AutoAttack then
            pcall(DoAttack)
        end
    end
end)

---------------------------------------------------------
-- MAGNET NPC / BOSS
---------------------------------------------------------
local MagnetMobs = {}
local MagnetPrepared = setmetatable({}, { __mode = "k" })
local MagnetConn = nil
local MagnetFront = 6

local function GetMagnetRange()
    return tonumber(string.match(MagnetRangeText, "%d+")) or 100
end

local function GetMobRoot(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChildWhichIsA("BasePart")
end

local function IsQuestOrSafeNPC(model)
    if not model then return true end
    local nameLower = string.lower(model.Name)
    local keywords = { "quest", "shop", "merchant", "seller", "trainer" }
    for _, kw in ipairs(keywords) do
        if string.find(nameLower, kw) then return true end
    end
    -- NPC interaksi biasanya punya ProximityPrompt
    if model:FindFirstChildWhichIsA("ProximityPrompt", true) then return true end
    return false
end

local function TryRegisterMob(h)
    if not h or not h:IsA("Humanoid") then return end
    local model = h.Parent
    if not model or not model:IsA("Model") then return end
    if Players:GetPlayerFromCharacter(model) then return end
    if IsQuestOrSafeNPC(model) then return end
    MagnetMobs[h] = true
end

local function UpdateMagnetHooks()
    if MagnetNPC or MagnetBoss then
        if not MagnetConn then
            table.clear(MagnetMobs)
            pcall(function()
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("Humanoid") then TryRegisterMob(d) end
                end
            end)
            MagnetConn = workspace.DescendantAdded:Connect(function(d)
                if d:IsA("Humanoid") then
                    task.defer(TryRegisterMob, d)
                end
            end)
        end
    else
        if MagnetConn then
            MagnetConn:Disconnect()
            MagnetConn = nil
        end
        table.clear(MagnetMobs)
    end
end

RunService.Heartbeat:Connect(function()
    if not (MagnetNPC or MagnetBoss) then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Minta kepemilikan fisika supaya posisi musuh ikut terbaca server
    if sethiddenproperty then
        pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
    end
    pcall(function()
        LocalPlayer.MaximumSimulationRadius = math.huge
    end)

    local range = GetMagnetRange()
    local targetPos = (root.CFrame * CFrame.new(0, 0, -MagnetFront)).Position
    local lookPos = Vector3.new(root.Position.X, targetPos.Y, root.Position.Z)

    for hum in pairs(MagnetMobs) do
        local model = hum.Parent
        if not model or not model.Parent or hum.Health <= 0 then
            MagnetMobs[hum] = nil
        else
            local mroot = GetMobRoot(model)
            if mroot then
                local isBoss = string.find(string.lower(model.Name), "boss") ~= nil
                local wanted = (isBoss and MagnetBoss) or ((not isBoss) and MagnetNPC)
                if wanted and (mroot.Position - root.Position).Magnitude <= range then
                    if not MagnetPrepared[model] then
                        MagnetPrepared[model] = true
                        for _, p in ipairs(model:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                    pcall(function()
                        model:PivotTo(CFrame.lookAt(targetPos, lookPos))
                    end)
                    mroot.AssemblyLinearVelocity = Vector3.zero
                    mroot.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end
end)

UpdateMagnetHooks()

local function MagnetDebug()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        WindUI:Notify({ Title = "Debug Magnet", Content = "Karakter belum siap.", Duration = 4 })
        return
    end

    local registered, inRange = 0, 0
    local range = GetMagnetRange()
    for hum in pairs(MagnetMobs) do
        registered = registered + 1
        local model = hum.Parent
        local mroot = model and GetMobRoot(model)
        if mroot and (mroot.Position - root.Position).Magnitude <= range then
            inRange = inRange + 1
        end
    end

    local near = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local model = d.Parent
            if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                local r = GetMobRoot(model)
                if r then
                    table.insert(near, {
                        name = model.Name,
                        dist = math.floor((r.Position - root.Position).Magnitude),
                        excluded = IsQuestOrSafeNPC(model),
                        anchored = r.Anchored
                    })
                end
            end
        end
    end
    table.sort(near, function(a, b) return a.dist < b.dist end)

    local lines = {
        "Terdaftar: " .. registered .. " | Dalam jarak: " .. inRange,
        "SimRadius: " .. (sethiddenproperty and "ada" or "tidak ada"),
        "Terdekat:"
    }
    for i = 1, math.min(4, #near) do
        local n = near[i]
        table.insert(lines, string.format(
            "- %s (%d studs)%s%s",
            n.name, n.dist,
            n.excluded and " [dikecualikan]" or "",
            n.anchored and " [anchored]" or ""
        ))
    end
    if #near == 0 then
        table.insert(lines, "- tidak ada Humanoid non-player yang ter-load")
    end

    local text = table.concat(lines, "\n")
    print("[AnimeHub] Debug Magnet:\n" .. text)
    WindUI:Notify({ Title = "Debug Magnet", Content = text, Duration = 12 })
end

---------------------------------------------------------
-- MOVEMENT: WALK SPEED / FLY / FREECAM / ZOOM
---------------------------------------------------------
local FlyOn = false
local FreecamOn = false
local VertInput = 0
local ActiveVertInput = nil

local FreecamPos = Vector3.zero
local FreecamYaw = 0
local FreecamPitch = 0

local WalkOverridden = false
local SavedWalkSpeed = 16
local ZoomOverridden = false
local SavedZoomMax = 128
local SavedZoomMin = 0.5

local ControlsObj = nil
pcall(function()
    local ps = LocalPlayer:WaitForChild("PlayerScripts", 3)
    local pm = ps and ps:WaitForChild("PlayerModule", 3)
    if pm then
        ControlsObj = require(pm):GetControls()
    end
end)

local function GetNum(text, default)
    return tonumber(string.match(text or "", "%d+")) or default
end

-- Arah joystick: x = kanan(+)/kiri(-), y = maju(+)/mundur(-)
local function GetJoy()
    if ControlsObj then
        local ok, mv = pcall(function()
            return ControlsObj:GetMoveVector()
        end)
        if ok and mv and (math.abs(mv.X) > 0.05 or math.abs(mv.Z) > 0.05) then
            return mv.X, -mv.Z
        end
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return 0, 0 end
    local md = hum.MoveDirection
    if md.Magnitude < 0.05 then return 0, 0 end

    local cam = workspace.CurrentCamera
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    local flatRight = Vector3.new(right.X, 0, right.Z)
    if flatLook.Magnitude < 0.01 or flatRight.Magnitude < 0.01 then return 0, 0 end
    return md:Dot(flatRight.Unit), md:Dot(flatLook.Unit)
end

local function ApplyWalkState(hum)
    local want = nil
    if FreecamOn then
        want = 0
    elseif WalkSpeedOn then
        want = GetNum(WalkSpeedText, 50)
    end

    if want ~= nil then
        if not WalkOverridden then
            SavedWalkSpeed = hum.WalkSpeed
            WalkOverridden = true
        end
        if hum.WalkSpeed ~= want then
            hum.WalkSpeed = want
        end
    elseif WalkOverridden then
        hum.WalkSpeed = SavedWalkSpeed
        WalkOverridden = false
    end
end

local function ZoomTick()
    pcall(function()
        if ZoomOn then
            if not ZoomOverridden then
                SavedZoomMax = LocalPlayer.CameraMaxZoomDistance
                SavedZoomMin = LocalPlayer.CameraMinZoomDistance
                ZoomOverridden = true
            end
            local z = GetNum(ZoomText, 1000)
            if LocalPlayer.CameraMinZoomDistance ~= 0.5 then
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
            if LocalPlayer.CameraMaxZoomDistance ~= z then
                LocalPlayer.CameraMaxZoomDistance = z
            end
        elseif ZoomOverridden then
            LocalPlayer.CameraMaxZoomDistance = SavedZoomMax
            LocalPlayer.CameraMinZoomDistance = SavedZoomMin
            ZoomOverridden = false
        end
    end)
end

-- Tombol naik / turun di layar (muncul saat Fly atau Freecam aktif)
local function MakeVertButton(text, yScale, dir)
    local b = Instance.new("TextButton")
    b.Name = "AH_Vert_" .. (dir > 0 and "Up" or "Down")
    b.Size = UDim2.fromOffset(56, 56)
    b.AnchorPoint = Vector2.new(0, 0.5)
    b.Position = UDim2.new(0, 150, yScale, 0)
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    b.BackgroundTransparency = 0.25
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 24
    b.AutoButtonColor = true
    b.Visible = false
    b.Parent = OverlayScreenGui

    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(255, 80, 120)
    stroke.Thickness = 1.2

    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            VertInput = dir
            ActiveVertInput = input
        end
    end)

    return b
end

local VertUpButton = MakeVertButton("▲", 0.64, 1)
local VertDownButton = MakeVertButton("▼", 0.80, -1)

UserInputService.InputEnded:Connect(function(input)
    if ActiveVertInput and input == ActiveVertInput then
        VertInput = 0
        ActiveVertInput = nil
    end
end)

local function UpdateVertButtons()
    local show = FlyOn or FreecamOn
    VertUpButton.Visible = show
    VertDownButton.Visible = show
    if not show then
        VertInput = 0
        ActiveVertInput = nil
    end
end

local function SetFreecam(state)
    FreecamOn = state
    local cam = workspace.CurrentCamera
    if state then
        local pitch, yaw = cam.CFrame:ToOrientation()
        FreecamPitch = pitch
        FreecamYaw = yaw
        FreecamPos = cam.CFrame.Position
        cam.CameraType = Enum.CameraType.Scriptable
    else
        cam.CameraType = Enum.CameraType.Custom
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
    end
    UpdateVertButtons()
end

-- Putar kamera freecam: geser jari di sisi kanan layar (atau klik kanan + geser di PC)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if not FreecamOn then return end

    local rotate = false
    if input.UserInputType == Enum.UserInputType.Touch then
        local cam = workspace.CurrentCamera
        if input.Position.X > cam.ViewportSize.X * 0.5 and not gameProcessed then
            rotate = true
        end
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            rotate = true
        end
    end

    if rotate then
        FreecamYaw = FreecamYaw - input.Delta.X * 0.005
        FreecamPitch = math.clamp(FreecamPitch - input.Delta.Y * 0.005, -1.5, 1.5)
    end
end)

-- Gerak kamera freecam
RunService.RenderStepped:Connect(function(dt)
    if not FreecamOn then return end

    local cam = workspace.CurrentCamera
    if cam.CameraType ~= Enum.CameraType.Scriptable then
        cam.CameraType = Enum.CameraType.Scriptable
    end

    local rot = CFrame.Angles(0, FreecamYaw, 0) * CFrame.Angles(FreecamPitch, 0, 0)
    local joyX, joyY = GetJoy()
    local speed = GetNum(FreecamSpeedText, 50)

    local move = rot.RightVector * joyX + rot.LookVector * joyY + Vector3.new(0, VertInput, 0)
    if move.Magnitude > 1 then move = move.Unit end

    FreecamPos = FreecamPos + move * speed * dt
    cam.CFrame = CFrame.new(FreecamPos) * rot
end)

-- Walk speed, zoom, dan fly
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        pcall(ApplyWalkState, hum)
    end

    ZoomTick()

    if root then
        local bv = root:FindFirstChild("AH_FlyBV")
        if FlyOn then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "AH_FlyBV"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.zero
                bv.Parent = root
            end

            if FreecamOn then
                -- Saat freecam, karakter melayang diam di tempat
                bv.Velocity = Vector3.zero
            else
                local cam = workspace.CurrentCamera
                local joyX, joyY = GetJoy()
                local move = cam.CFrame.RightVector * joyX + cam.CFrame.LookVector * joyY + Vector3.new(0, VertInput, 0)
                if move.Magnitude > 1 then move = move.Unit end
                bv.Velocity = move * GetNum(FlySpeedText, 100)
            end
        elseif bv then
            bv:Destroy()
        end
    end
end)

---------------------------------------------------------
-- TAB 2: COMBAT
---------------------------------------------------------
local CombatTab = Window:Tab({ Title = "Combat", Icon = "sword" })

CombatTab:Section({ Title = "Auto Attack / M1" })

CombatTab:Toggle({
    Title = "Auto Attack (M1)",
    Desc = "Serang otomatis memakai tool Combat",
    Value = AutoAttack,
    Callback = function(State)
        AutoAttack = State
        AutoSave()
    end,
})

CombatTab:Dropdown({
    Title = "Metode M1",
    Desc = "Kalau serangan tidak keluar, coba ganti metode",
    Values = AttackModes,
    Value = AttackMode,
    Callback = function(Value)
        AttackMode = Value
        AutoSave()
    end,
})

CombatTab:Section({ Title = "Magnet NPC / Boss" })

CombatTab:Toggle({
    Title = "Magnet NPC",
    Desc = "Tarik NPC musuh ke depan karaktermu tanpa perlu dipukul dulu",
    Value = MagnetNPC,
    Callback = function(State)
        MagnetNPC = State
        UpdateMagnetHooks()
        AutoSave()
    end,
})

CombatTab:Toggle({
    Title = "Magnet Boss",
    Desc = "Tarik boss (nama model mengandung kata boss) ke depan karaktermu",
    Value = MagnetBoss,
    Callback = function(State)
        MagnetBoss = State
        UpdateMagnetHooks()
        AutoSave()
    end,
})

CombatTab:Dropdown({
    Title = "Jarak Magnet",
    Desc = "Musuh dalam jarak ini yang akan ditarik",
    Values = MagnetRanges,
    Value = MagnetRangeText,
    Callback = function(Value)
        MagnetRangeText = Value
        AutoSave()
    end,
})

CombatTab:Button({
    Title = "Cek Magnet (Debug)",
    Desc = "Tampilkan jumlah musuh terdaftar dan 4 musuh terdekat",
    Callback = function()
        pcall(MagnetDebug)
    end,
})

---------------------------------------------------------
-- TAB 3: MOVEMENT
---------------------------------------------------------
local MoveTab = Window:Tab({ Title = "Movement", Icon = "move" })

MoveTab:Section({ Title = "Walk Speed" })

MoveTab:Toggle({
    Title = "Walk Speed",
    Desc = "Ubah kecepatan jalan karakter",
    Value = WalkSpeedOn,
    Callback = function(State)
        WalkSpeedOn = State
        AutoSave()
    end,
})

MoveTab:Dropdown({
    Title = "Kecepatan Walk",
    Desc = "Pilih kecepatan jalan",
    Values = WalkSpeeds,
    Value = WalkSpeedText,
    Callback = function(Value)
        WalkSpeedText = Value
        AutoSave()
    end,
})

MoveTab:Section({ Title = "Fly" })

MoveTab:Toggle({
    Title = "Fly",
    Desc = "Terbang. Joystick: maju, mundur, kiri, kanan. Tombol ▲ ▼ di layar untuk naik dan turun",
    Value = false,
    Callback = function(State)
        FlyOn = State
        UpdateVertButtons()
    end,
})

MoveTab:Dropdown({
    Title = "Kecepatan Fly",
    Desc = "Pilih kecepatan terbang",
    Values = FlySpeeds,
    Value = FlySpeedText,
    Callback = function(Value)
        FlySpeedText = Value
        AutoSave()
    end,
})

MoveTab:Section({ Title = "Freecam" })

MoveTab:Toggle({
    Title = "Freecam",
    Desc = "Kamera bebas, karakter diam. Joystick gerak kamera, geser sisi kanan layar untuk memutar",
    Value = false,
    Callback = function(State)
        SetFreecam(State)
    end,
})

MoveTab:Dropdown({
    Title = "Kecepatan Freecam",
    Desc = "Pilih kecepatan gerak kamera",
    Values = FreecamSpeeds,
    Value = FreecamSpeedText,
    Callback = function(Value)
        FreecamSpeedText = Value
        AutoSave()
    end,
})

MoveTab:Section({ Title = "Zoom" })

MoveTab:Toggle({
    Title = "Zoom Jauh",
    Desc = "Naikkan batas zoom out kamera (cubit layar untuk zoom)",
    Value = ZoomOn,
    Callback = function(State)
        ZoomOn = State
        AutoSave()
    end,
})

MoveTab:Dropdown({
    Title = "Zoom Maksimum",
    Desc = "Jarak zoom out maksimum dalam studs",
    Values = ZoomOptions,
    Value = ZoomText,
    Callback = function(Value)
        ZoomText = Value
        AutoSave()
    end,
})

---------------------------------------------------------
-- TAB 4: ESP VISUAL
---------------------------------------------------------
local EspTab = Window:Tab({ Title = "ESP Visual", Icon = "eye" })

EspTab:Section({ Title = "Visual ESP System" })

EspTab:Toggle({
    Title = "ESP Chest & Distance",
    Desc = "Menampilkan sorotan chest dan jarak dalam Studs",
    Value = EspChest,
    Callback = function(State)
        EspChest = State
        if not State then
            for obj, data in pairs(ActiveESPs) do
                if data.Type == "Chest" then RemoveESP(obj) end
            end
        end
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "ESP Crystal Seed",
    Desc = "Menampilkan posisi Crystal Seed di map",
    Value = EspCrystalSeed,
    Callback = function(State)
        EspCrystalSeed = State
        if not State then
            for obj, data in pairs(ActiveESPs) do
                if data.Type == "CrystalSeed" then RemoveESP(obj) end
            end
        end
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "ESP Slime Piece",
    Desc = "Menampilkan Slime Piece (quest Slime Collection)",
    Value = EspSlime,
    Callback = function(State)
        EspSlime = State
        if not State then
            for obj, data in pairs(ActiveESPs) do
                if data.Type == "SlimePiece" then RemoveESP(obj) end
            end
        end
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "ESP Hogyoku Fragment",
    Desc = "Menampilkan Hogyoku Fragment (quest Hogyoku Fragments)",
    Value = EspHogyoku,
    Callback = function(State)
        EspHogyoku = State
        if not State then
            for obj, data in pairs(ActiveESPs) do
                if data.Type == "Hogyoku" then RemoveESP(obj) end
            end
        end
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "ESP Ancient Fragment",
    Desc = "Menampilkan Ancient Fragment (quest Lost Fragments)",
    Value = EspFragment,
    Callback = function(State)
        EspFragment = State
        if not State then
            for obj, data in pairs(ActiveESPs) do
                if data.Type == "Fragment" then RemoveESP(obj) end
            end
        end
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "Notifikasi Fragment Spawn",
    Desc = "Muncul notifikasi saat Ancient Fragment spawn",
    Value = FragNotify,
    Callback = function(State)
        FragNotify = State
        LastFragCount = 0
        AutoSave()
    end,
})

EspTab:Toggle({
    Title = "ESP Line / Lane Tracer",
    Desc = "Menampilkan garis penunjuk arah ke item ESP",
    Value = EspTracer,
    Callback = function(State)
        EspTracer = State
        AutoSave()
    end,
})

EspTab:Button({
    Title = "Refresh Visual ESP",
    Desc = "Reset dan pindai ulang objek ESP",
    Callback = function()
        ClearAllESP()
        WindUI:Notify({ Title = "ESP Reset", Content = "Visual ESP berhasil di-refresh!", Duration = 2 })
    end,
})

---------------------------------------------------------
-- TAB 5: SETTINGS & CONFIG MANAGEMENT
---------------------------------------------------------
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Section({ Title = "📁 Config Status" })

SettingsTab:Paragraph({
    Title = "Auto Config Active",
    Desc = "Semua pengaturan (Toggle/Dropdown) akan tersimpan secara otomatis."
})

local confirmReset = false
SettingsTab:Toggle({
    Title = "⚠️ Konfirmasi Reset Config",
    Desc = "Aktifkan toggle ini terlebih dahulu sebelum menghapus file config",
    Value = false,
    Callback = function(State)
        confirmReset = State
    end,
})

SettingsTab:Button({
    Title = "🔄 Reset Config ke Default",
    Desc = "Hapus file config dan kembalikan seluruh pengaturan ke default",
    Callback = function()
        if confirmReset then
            if isfile(ConfigFileName) then
                delfile(ConfigFileName)
            end
            WindUI:Notify({ Title = "Config Reset", Content = "Pengaturan berhasil direset!", Duration = 3 })
            confirmReset = false
        else
            WindUI:Notify({ Title = "Aksi Dicegah", Content = "Nyalakan 'Konfirmasi Reset Config' dulu!", Duration = 3 })
        end
    end,
})

SettingsTab:Section({ Title = "🚪 Unload Hub" })

local confirmUnload = false
SettingsTab:Toggle({
    Title = "⚠️ Konfirmasi Unload UI",
    Desc = "Aktifkan toggle ini terlebih dahulu sebelum mematikan Script",
    Value = false,
    Callback = function(State)
        confirmUnload = State
    end,
})

SettingsTab:Button({
    Title = "❌ Unload UI",
    Desc = "Hentikan semua fitur dan tutup GUI secara aman",
    Callback = function()
        if not confirmUnload then
            WindUI:Notify({ Title = "Aksi Dicegah", Content = "Nyalakan 'Konfirmasi Unload UI' dulu!", Duration = 3 })
            return
        end

        AutoSave()

        AutoAttack = false
        MagnetNPC = false
        MagnetBoss = false
        UpdateMagnetHooks()
        FlyOn = false
        SetFreecam(false)
        WalkSpeedOn = false
        ZoomOn = false
        FreezePosition = false
        AntiAfk = false
        EspChest = false
        EspCrystalSeed = false
        EspTracer = false
        EspSlime = false
        EspHogyoku = false
        EspFragment = false
        FragNotify = false
        
        ClearAllESP()

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end

        if OverlayScreenGui then
            OverlayScreenGui:Destroy()
        end

        Window:Destroy()
    end,
})

---------------------------------------------------------
-- STATS UPDATER
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
    while task.wait(1) do
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

        local formattedStats = string.format(
            "⚡ FPS: %d | 📡 Ping: %dms | 👥 Players: %d\n💻 CPU: %d%% | 🎮 GPU: %d%% | ⏱️ Server Age: %s",
            fps, ping, playerOnline, cpuUsage, gpuUsage, uptimeStr
        )

        if StatsParagraph then StatsParagraph:SetDesc(formattedStats) end
        if OverlayText then OverlayText.Text = formattedStats end
    end
end)

WindUI:Notify({ Title = "Anime Hub", Content = "Filter ESP diperketat!", Duration = 3 })