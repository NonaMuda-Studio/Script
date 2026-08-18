local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Bersihkan UI / Sound lama jika skrip dijalankan ulang
if playerGui:FindFirstChild("NeonLoadingScreen") then playerGui.NeonLoadingScreen:Destroy() end
if playerGui:FindFirstChild("MainHubGui") then playerGui.MainHubGui:Destroy() end
if SoundService:FindFirstChild("CustomLoadingSound") then SoundService.CustomLoadingSound:Destroy() end

-- 1. PEMBUATAN SOUND
local loadingSound = Instance.new("Sound")
loadingSound.Name = "CustomLoadingSound"
loadingSound.SoundId = "rbxassetid://112510022853483"
loadingSound.Volume = 0.8
loadingSound.Parent = SoundService

-- Fungsi Helper agar UI bisa Di-drag secara halus
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    guiObject.InputBegan:Connect(function(input)
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
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- 2. FUNGSI LOADING SCREEN
local function StartLoadingScreen(hubName, creatorName, onComplete)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeonLoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    screenGui.Parent = playerGui

    -- Card Utama Loading (Tinggi ditingkatkan jadi 0.60)
    local mainCard = Instance.new("Frame")
    mainCard.Size = UDim2.new(0.65, 0, 0.60, 0)
    mainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCard.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainCard.BackgroundTransparency = 0.1
    mainCard.BorderSizePixel = 0
    mainCard.Parent = screenGui

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 14)
    cardCorner.Parent = mainCard

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(0, 240, 255)
    cardStroke.Thickness = 2.5
    cardStroke.Parent = mainCard

    -- Nama Hub
    local hubTitle = Instance.new("TextLabel")
    hubTitle.Size = UDim2.new(1, -40, 0, 50)
    hubTitle.Position = UDim2.new(0, 20, 0.08, 0)
    hubTitle.BackgroundTransparency = 1
    hubTitle.Text = hubName or "ShiroNeko Hub"
    hubTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    hubTitle.TextSize = 30
    hubTitle.Font = Enum.Font.Arcade
    hubTitle.TextXAlignment = Enum.TextXAlignment.Center
    hubTitle.Parent = mainCard

    -- Teks Loading......... (Efek Kedip)
    local loadingTitle = Instance.new("TextLabel")
    loadingTitle.Size = UDim2.new(1, -40, 0, 30)
    loadingTitle.Position = UDim2.new(0, 20, 0.24, 0)
    loadingTitle.BackgroundTransparency = 1
    loadingTitle.Text = "Loading........."
    loadingTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    loadingTitle.TextSize = 22
    loadingTitle.Font = Enum.Font.Arcade
    loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
    loadingTitle.Parent = mainCard

    local blinkInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local blinkTween = TweenService:Create(loadingTitle, blinkInfo, {TextTransparency = 0.7})
    blinkTween:Play()

    -- Bar Loading
    local outerBar = Instance.new("Frame")
    outerBar.Size = UDim2.new(0.9, 0, 0, 38)
    outerBar.Position = UDim2.new(0.05, 0, 0.48, 0)
    outerBar.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    outerBar.BorderSizePixel = 0
    outerBar.Parent = mainCard

    local barStroke = Instance.new("UIStroke")
    barStroke.Color = Color3.fromRGB(0, 240, 255)
    barStroke.Thickness = 1.5
    barStroke.Parent = outerBar

    local innerBar = Instance.new("Frame")
    innerBar.Size = UDim2.new(0, 0, 1, 0)
    innerBar.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    innerBar.BorderSizePixel = 0
    innerBar.Parent = outerBar

    -- Teks Persentase
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

    -- Teks By Pembuat
    local creatorTitle = Instance.new("TextLabel")
    creatorTitle.Size = UDim2.new(0.9, 0, 0, 30)
    creatorTitle.Position = UDim2.new(0.05, 0, 0.82, 0)
    creatorTitle.BackgroundTransparency = 1
    creatorTitle.Text = "By : " .. (creatorName or "Kurumi X Nahida")
    creatorTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    creatorTitle.TextSize = 18
    creatorTitle.Font = Enum.Font.SourceSansItalic
    creatorTitle.TextXAlignment = Enum.TextXAlignment.Left
    creatorTitle.Parent = mainCard

    pcall(function()
        loadingSound:Play()
    end)

    -- =======================================================
    -- SISTEM LOADING REALISTIS TOTAL ~7 DETIK
    -- =======================================================
    for i = 0, 100 do
        percentText.Text = i .. "%"
        innerBar.Size = UDim2.new(i / 100, 0, 1, 0)

        if i <= 60 then
            -- 1 - 60%: Cepat (~0.02s x 60 = 1.2 detik)
            task.wait(0.02)
        elseif i > 60 and i < 89 then
            -- 61 - 88%: Agak lama (~0.08s x 28 = 2.24 detik)
            task.wait(0.08)
        elseif i == 89 then
            -- 89%: Stuck / Pause lama (2.5 detik)
            task.wait(2.5)
        else
            -- 90 - 100%: Cepat kembali (~0.03s x 11 = 0.33 detik)
            task.wait(0.03)
        end
    end

    blinkTween:Cancel()
    task.wait(0.3)

    -- Fade Out
    local fadeInfo = TweenInfo.new(0.5)
    TweenService:Create(mainCard, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(cardStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(hubTitle, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(loadingTitle, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(outerBar, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(barStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(innerBar, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(creatorTitle, fadeInfo, {TextTransparency = 1}):Play()
    
    local lastTween = TweenService:Create(percentText, fadeInfo, {TextTransparency = 1})
    lastTween:Play()
    
    lastTween.Completed:Connect(function()
        screenGui:Destroy()
        if loadingSound then loadingSound:Destroy() end
        if onComplete then
            onComplete()
        end
    end)
end

-- 3. FUNGSI PEMBUATAN MENU UTAMA
local function ShowMainUI()
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "MainHubGui"
    mainGui.ResetOnSpawn = false
    mainGui.DisplayOrder = 999999
    mainGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 28)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = mainGui

    MakeDraggable(mainFrame)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(0, 240, 255)
    frameStroke.Thickness = 1.5
    frameStroke.Parent = mainFrame

    -- Title Bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 35)
    title.Position = UDim2.new(0, 12, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "ShiroNeko Hub | Version 1.0"
    title.TextColor3 = Color3.fromRGB(0, 240, 255)
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame

    -- Tombol Close (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        mainGui:Destroy()
    end)

    -- Tombol Minimize (-)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    minimizeBtn.Position = UDim2.new(1, -68, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 75)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.Parent = mainFrame

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn

    -- Tombol Melayang Emoji (🐈)
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "OpenToggleButton"
    openBtn.Size = UDim2.new(0, 55, 0, 55)
    openBtn.Position = UDim2.new(0, 20, 0.15, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    openBtn.Text = "🐈"
    openBtn.TextSize = 28
    openBtn.ZIndex = 999
    openBtn.Active = true
    openBtn.Visible = false
    openBtn.Parent = mainGui

    MakeDraggable(openBtn)

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(1, 0)
    openCorner.Parent = openBtn

    local openStroke = Instance.new("UIStroke")
    openStroke.Color = Color3.fromRGB(0, 240, 255)
    openStroke.Thickness = 2.5
    openStroke.Parent = openBtn

    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        openBtn.Visible = false
        mainFrame.Visible = true
    end)

    -- =======================================================
    -- SIDEBAR UNTUK LIST MENU (Home -> Settings UI)
    -- =======================================================
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Size = UDim2.new(0, 140, 1, -45)
    sidebar.Position = UDim2.new(0, 8, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
    sidebar.Parent = mainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 6)
    sidebarCorner.Parent = sidebar

    local sidebarList = Instance.new("UIListLayout")
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 4)
    sidebarList.Parent = sidebar

    -- Panel Konten Kanan
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -160, 1, -45)
    contentArea.Position = UDim2.new(0, 152, 0, 40)
    contentArea.BackgroundColor3 = Color3.fromRGB(28, 22, 38)
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentArea

    -- Daftar List Menu Sesuai Urutan
    local tabNames = {
        "Home",
        "Main",
        "Automatically",
        "Webhook",
        "Misc",
        "Settings",
        "Settings UI"
    }

    local tabs = {}
    local tabButtons = {}

    local function SwitchTab(selectedName)
        for name, frame in pairs(tabs) do
            frame.Visible = (name == selectedName)
        end
        for name, btn in pairs(tabButtons) do
            if name == selectedName then
                btn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
                btn.TextColor3 = Color3.fromRGB(10, 10, 15)
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 25, 42)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end

    -- Loop Membuat Tombol List Menu & Frame Kosongnya
    for i, tabName in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(30, 25, 42)
        btn.Text = "  " .. tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        tabButtons[tabName] = btn

        -- Container Panel Kosong Tiap Tab
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "Page"
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
        page.Visible = false
        page.Parent = contentArea

        -- Label Judul Menu
        local pageTitle = Instance.new("TextLabel")
        pageTitle.Size = UDim2.new(1, 0, 0, 25)
        pageTitle.BackgroundTransparency = 1
        pageTitle.Text = "-- " .. tabName .. " --"
        pageTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
        pageTitle.Font = Enum.Font.GothamBold
        pageTitle.TextSize = 14
        pageTitle.TextXAlignment = Enum.TextXAlignment.Left
        pageTitle.Parent = page

        tabs[tabName] = page

        btn.MouseButton1Click:Connect(function()
            SwitchTab(tabName)
        end)
    end

    sidebar.CanvasSize = UDim2.new(0, 0, 0, #tabNames * 36)

    -- Pilih Tab 'Home' secara default
    SwitchTab("Home")
end

-- ==========================================
-- JALANKAN LOADING SCREEN
-- ==========================================
StartLoadingScreen("ShiroNeko Hub", "Kurumi X Nahida", function()
    ShowMainUI()
end)
