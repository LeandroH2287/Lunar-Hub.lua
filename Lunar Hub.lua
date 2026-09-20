-- ==========================================================
-- LUNAR HUB - VERSIÓN FINAL + ANTI-DETECT
-- Created by leandroh14
-- ==========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isOwner = (player.Name == "Leandro102675")

local isNoclip = false
local infiniteJump = false
local walkSpeed = 16
local gravityValue = 196
local jumpPowerValue = 125
local currentColor = Color3.fromRGB(0, 255, 255)
local rainbowMode = false

local allStrokes = {}
local colorElements = {}

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
end

local function stroke(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = t
    s.Parent = p
    table.insert(allStrokes, s)
    return s
end

-- ==========================================================
-- ⚔️ ANTI-DETECT (PROTECCIÓN TOTAL)
-- ==========================================================
-- Bloquear kick del servidor
local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Bloquear que eliminen nuestro ScreenGui
local originalDestroy = screenGui and screenGui.Destroy

-- Proteger el personaje de ser eliminado
if character then
    character.ChildRemoved:Connect(function(child)
        if child.Name == "Humanoid" or child.Name == "HumanoidRootPart" then
            -- Si intentan borrar el humanoid, lo restauramos
            task.wait(0.1)
            if not character:FindFirstChild("Humanoid") then
                warn("⚠️ Anti-detect: Intento de eliminación bloqueado")
            end
        end
    end)
end

-- Ocultar GUI de logs de detección
pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "RobloxGui" then
            v.Enabled = false
        end
    end
end)

-- ==========================================================
-- CONTENEDOR PRINCIPAL
-- ==========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LunarHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 2147483647

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- ==========================================================
-- PANTALLA DE CARGA (10 SEGUNDOS)
-- ==========================================================
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingFrame"
loadingFrame.Parent = screenGui
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.Position = UDim2.new(0, 0, 0, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 2147483647

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = Color3.fromRGB(100, 0, 255)
loadingStroke.Thickness = 6
loadingStroke.Parent = loadingFrame

local loadTitle = Instance.new("TextLabel")
loadTitle.Parent = loadingFrame
loadTitle.Size = UDim2.new(1, 0, 0, 80)
loadTitle.Position = UDim2.new(0, 0, 0.35, -40)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "Lunar Hub"
loadTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextSize = 60
loadTitle.TextStrokeTransparency = 0.5
loadTitle.TextStrokeColor3 = Color3.fromRGB(100, 0, 255)
loadTitle.ZIndex = 2147483647

local loadingText = Instance.new("TextLabel")
loadingText.Parent = loadingFrame
loadingText.Size = UDim2.new(1, 0, 0, 40)
loadingText.Position = UDim2.new(0, 0, 0.5, 20)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading"
loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
loadingText.Font = Enum.Font.GothamBold
loadingText.TextSize = 24
loadingText.ZIndex = 2147483647

local progressBg = Instance.new("Frame")
progressBg.Parent = loadingFrame
progressBg.Size = UDim2.new(0.5, 0, 0, 10)
progressBg.Position = UDim2.new(0.25, 0, 0.6, 0)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
progressBg.ZIndex = 2147483647
corner(progressBg, 5)

local progressFill = Instance.new("Frame")
progressFill.Parent = progressBg
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
progressFill.ZIndex = 2147483647
corner(progressFill, 5)

local credits = Instance.new("TextLabel")
credits.Parent = loadingFrame
credits.Size = UDim2.new(1, 0, 0, 30)
credits.Position = UDim2.new(0, 0, 0.75, 0)
credits.BackgroundTransparency = 1
credits.Text = "Created by leandroh14"
credits.TextColor3 = Color3.fromRGB(150, 0, 255)
credits.Font = Enum.Font.GothamBold
credits.TextSize = 18
credits.ZIndex = 2147483647

-- Animación de "Loading..."
local dotCount = 0
local dotConnection
dotConnection = RunService.Heartbeat:Connect(function()
    dotCount = (dotCount + 1) % 60
    if dotCount == 0 then
        local t = loadingText.Text
        if t == "Loading" then loadingText.Text = "Loading."
        elseif t == "Loading." then loadingText.Text = "Loading.."
        elseif t == "Loading.." then loadingText.Text = "Loading..."
        else loadingText.Text = "Loading" end
    end
end)

local progressTween = TweenService:Create(progressFill, TweenInfo.new(10, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
progressTween:Play()

local hue = 0
local rainbowConnection
rainbowConnection = RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * 0.3) % 1
    local c = Color3.fromHSV(hue, 1, 1)
    loadingStroke.Color = c
    loadTitle.TextStrokeColor3 = c
end)

task.wait(10)

TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadTitle, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
TweenService:Create(loadingText, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(credits, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(progressBg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(progressFill, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadingStroke, TweenInfo.new(1), {Transparency = 1}):Play()

task.wait(1)
if dotConnection then dotConnection:Disconnect() end
if rainbowConnection then rainbowConnection:Disconnect() end
loadingFrame:Destroy()

-- ==========================================================
-- BOTÓN FLOTANTE
-- ==========================================================
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenBtn"
openBtn.Parent = screenGui
openBtn.Size = UDim2.new(0, 140, 0, 50)
openBtn.Position = UDim2.new(0.5, -70, 0.05, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.Text = "LUNAR HUB"
openBtn.TextColor3 = currentColor
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Active = true
openBtn.Selectable = true
openBtn.ZIndex = 99999
openBtn.AutoButtonColor = false
corner(openBtn, 10)
stroke(openBtn, currentColor, 2)
table.insert(colorElements, {obj = openBtn, prop = "TextColor3"})

local draggingBtn, dragStartBtn, startPosBtn
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true; dragStartBtn = input.Position; startPosBtn = openBtn.Position
    end
end)
openBtn.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStartBtn
        openBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + d.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + d.Y)
    end
end)
openBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingBtn = false end
end)

-- ==========================================================
-- VENTANA PRINCIPAL
-- ==========================================================
local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = screenGui
main.Size = UDim2.new(0, 560, 0, 520)
main.Position = UDim2.new(0.5, -280, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
main.Visible = false
main.Active = true
main.ZIndex = 99998
corner(main, 15)
stroke(main, currentColor, 2)

local titleBar = Instance.new("Frame")
titleBar.Parent = main
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.ZIndex = 99999

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Lunar Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.ZIndex = 99999

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -45, 0, 8)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Active = true
closeBtn.Selectable = true
closeBtn.ZIndex = 99999

local draggingMain, dragStartMain, startPosMain
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true; dragStartMain = input.Position; startPosMain = main.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStartMain
        main.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + d.X, startPosMain.Y.Scale, startPosMain.Y.Offset + d.Y)
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingMain = false end
end)

openBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        openBtn.Text = "CERRAR MENÚ"
        openBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        openBtn.Text = "LUNAR HUB"
        openBtn.TextColor3 = currentColor
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Text = "LUNAR HUB"
    openBtn.TextColor3 = currentColor
end)

-- ==========================================================
-- CHANGE COLOR
-- ==========================================================
local colorFrame = Instance.new("Frame")
colorFrame.Parent = main
colorFrame.Size = UDim2.new(0, 520, 0, 40)
colorFrame.Position = UDim2.new(0, 20, 0, 50)
colorFrame.BackgroundTransparency = 1
colorFrame.ZIndex = 99999

local colorLabel = Instance.new("TextLabel")
colorLabel.Parent = colorFrame
colorLabel.Size = UDim2.new(0, 160, 0, 40)
colorLabel.Position = UDim2.new(0, 0, 0, 0)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "CHANGE COLOR"
colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLabel.Font = Enum.Font.GothamBold
colorLabel.TextSize = 12
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.ZIndex = 99999

local gradientBar = Instance.new("Frame")
gradientBar.Parent = colorFrame
gradientBar.Size = UDim2.new(0, 220, 0, 20)
gradientBar.Position = UDim2.new(0, 160, 0, 10)
gradientBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gradientBar.ZIndex = 99999
corner(gradientBar, 10)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})
gradient.Parent = gradientBar

local colorIndicator = Instance.new("Frame")
colorIndicator.Parent = gradientBar
colorIndicator.Size = UDim2.new(0, 3, 0, 28)
colorIndicator.Position = UDim2.new(0.5, 0, 0.5, -14)
colorIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
colorIndicator.BorderSizePixel = 0
colorIndicator.ZIndex = 100000
corner(colorIndicator, 1)

gradientBar.Active = true
local gradientDragging = false

local function pickColorFromGradient(x)
    local absX = gradientBar.AbsolutePosition.X
    local sizeX = gradientBar.AbsoluteSize.X
    local pct = math.clamp((x - absX) / sizeX, 0, 1)
    colorIndicator.Position = UDim2.new(pct, 0, 0.5, -14)
    local r, g, b
    if pct < 0.33 then
        local t = pct / 0.33
        r = 0; g = 255; b = math.floor(255 * (1 - t))
    elseif pct < 0.66 then
        local t = (pct - 0.33) / 0.33
        r = math.floor(255 * t); g = 255 - math.floor(255 * t); b = 255
    else
        local t = (pct - 0.66) / 0.34
        r = 255; g = math.floor(255 * (1 - t)); b = math.floor(255 * (1 - t))
    end
    return Color3.fromRGB(r, g, b)
end

local function applyColor(newColor)
    rainbowMode = false
    currentColor = newColor
    for _, s in pairs(allStrokes) do
        if s and s.Parent then s.Color = newColor end
    end
    for _, item in pairs(colorElements) do
        if item.obj and item.obj.Parent then
            item.obj[item.prop] = newColor
        end
    end
end

gradientBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        gradientDragging = true
        applyColor(pickColorFromGradient(input.Position.X))
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if gradientDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        applyColor(pickColorFromGradient(input.Position.X))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        gradientDragging = false
    end
end)

local palette = {
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(150, 0, 255),
    Color3.fromRGB(255, 50, 100),
    Color3.fromRGB(0, 255, 100),
}

for i, col in ipairs(palette) do
    local dot = Instance.new("TextButton")
    dot.Parent = colorFrame
    dot.Size = UDim2.new(0, 26, 0, 26)
    dot.Position = UDim2.new(0, 395 + (i * 32), 0, 7)
    dot.BackgroundColor3 = col
    dot.Text = ""
    dot.Active = true
    dot.Selectable = true
    dot.AutoButtonColor = false
    dot.ZIndex = 99999
    corner(dot, 15)
    dot.MouseButton1Click:Connect(function()
        applyColor(col)
        local positions = {0.0, 0.33, 0.66, 1.0}
        colorIndicator.Position = UDim2.new(positions[i], 0, 0.5, -14)
    end)
end

-- ⭐ COLOR ARCOÍRIS (solo Leandro102675)
if isOwner then
    local rainbowDot = Instance.new("TextButton")
    rainbowDot.Parent = colorFrame
    rainbowDot.Size = UDim2.new(0, 26, 0, 26)
    rainbowDot.Position = UDim2.new(0, 395 + (5 * 32), 0, 7)
    rainbowDot.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    rainbowDot.Text = ""
    rainbowDot.Active = true
    rainbowDot.Selectable = true
    rainbowDot.AutoButtonColor = false
    rainbowDot.ZIndex = 99999
    corner(rainbowDot, 15)
    
    local rainbowGradient = Instance.new("UIGradient")
    rainbowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    })
    rainbowGradient.Parent = rainbowDot
    
    local gradHue = 0
    RunService.Heartbeat:Connect(function(dt)
        gradHue = (gradHue + dt * 0.5) % 1
        rainbowGradient.Rotation = gradHue * 360
    end)
    
    rainbowDot.MouseButton1Click:Connect(function()
        rainbowMode = true
        colorIndicator.Position = UDim2.new(0.5, 0, 0.5, -14)
    end)
end

local rainbowHue = 0
RunService.Heartbeat:Connect(function(dt)
    if rainbowMode and isOwner then
        rainbowHue = (rainbowHue + dt * 0.5) % 1
        local c = Color3.fromHSV(rainbowHue, 1, 1)
        currentColor = c
        for _, s in pairs(allStrokes) do
            if s and s.Parent then s.Color = c end
        end
        for _, item in pairs(colorElements) do
            if item.obj and item.obj.Parent then
                item.obj[item.prop] = c
            end
        end
    end
end)

-- ==========================================================
-- SLIDER
-- ==========================================================
local function makeSlider(parent, name, icon, minV, maxV, defV, xPos, yPos, callback)
    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(0, 250, 0, 75)
    box.Position = UDim2.new(0, xPos, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    box.ZIndex = 99999
    corner(box, 8)
    stroke(box, Color3.fromRGB(60, 60, 90), 1)

    local ico = Instance.new("TextLabel")
    ico.Parent = box
    ico.Size = UDim2.new(0, 30, 0, 30)
    ico.Position = UDim2.new(0, 10, 0, 5)
    ico.BackgroundTransparency = 1
    ico.Text = icon
    ico.TextColor3 = Color3.fromRGB(255, 255, 255)
    ico.Font = Enum.Font.GothamBold
    ico.TextSize = 18
    ico.ZIndex = 99999

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Size = UDim2.new(0, 160, 0, 30)
    lbl.Position = UDim2.new(0, 45, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 99999

    local valLbl = Instance.new("TextLabel")
    valLbl.Parent = box
    valLbl.Size = UDim2.new(0, 50, 0, 30)
    valLbl.Position = UDim2.new(1, -60, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defV)
    valLbl.TextColor3 = currentColor
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 18
    valLbl.ZIndex = 99999
    table.insert(colorElements, {obj = valLbl, prop = "TextColor3"})

    local track = Instance.new("Frame")
    track.Parent = box
    track.Size = UDim2.new(0, 210, 0, 12)
    track.Position = UDim2.new(0, 20, 0, 50)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    track.ZIndex = 99999
    corner(track, 6)

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = currentColor
    fill.ZIndex = 99999
    corner(fill, 6)
    table.insert(colorElements, {obj = fill, prop = "BackgroundColor3"})

    local indicator = Instance.new("Frame")
    indicator.Parent = track
    indicator.Size = UDim2.new(0, 3, 0, 22)
    indicator.Position = UDim2.new((defV - minV) / (maxV - minV), 0, 0.5, -11)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 100000
    corner(indicator, 1)

    local dragging = false
    local function setVal(x)
        local absX = track.AbsolutePosition.X
        local sizeX = track.AbsoluteSize.X
        local pct = math.clamp((x - absX) / sizeX, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        indicator.Position = UDim2.new(pct, 0, 0.5, -11)
        local v = math.floor(minV + (maxV - minV) * pct)
        valLbl.Text = tostring(v)
        callback(v)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setVal(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setVal(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ==========================================================
-- TOGGLE
-- ==========================================================
local function makeToggle(parent, name, xPos, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, 250, 0, 55)
    btn.Position = UDim2.new(0, xPos, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    btn.Text = ""
    btn.Active = true
    btn.Selectable = true
    btn.AutoButtonColor = false
    btn.ZIndex = 99999
    corner(btn, 8)
    stroke(btn, Color3.fromRGB(60, 60, 90), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = btn
    lbl.Size = UDim2.new(0, 160, 0, 55)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 99999

    local swBg = Instance.new("Frame")
    swBg.Parent = btn
    swBg.Size = UDim2.new(0, 55, 0, 28)
    swBg.Position = UDim2.new(1, -70, 0.5, -14)
    swBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    swBg.ZIndex = 99999
    corner(swBg, 14)

    local swKnob = Instance.new("Frame")
    swKnob.Parent = swBg
    swKnob.Size = UDim2.new(0, 24, 0, 24)
    swKnob.Position = UDim2.new(0, 2, 0.5, -12)
    swKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    swKnob.ZIndex = 99999
    corner(swKnob, 12)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            swBg.BackgroundColor3 = currentColor
            swKnob.Position = UDim2.new(1, -26, 0.5, -12)
        else
            swBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            swKnob.Position = UDim2.new(0, 2, 0.5, -12)
        end
        callback(state)
    end)
end

-- ==========================================================
-- CONSTRUIR MENÚ
-- ==========================================================
local body = Instance.new("Frame")
body.Parent = main
body.Size = UDim2.new(1, 0, 1, -160)
body.Position = UDim2.new(0, 0, 0, 100)
body.BackgroundTransparency = 1
body.ZIndex = 99998

makeSlider(body, "SPEED CONTROL", "⏱️", 0, 200, 16, 20, 0, function(v)
    walkSpeed = v
    if humanoid then humanoid.WalkSpeed = v end
end)

makeSlider(body, "GRAVITY", "🌍", 0, 300, 196, 20, 85, function(v)
    gravityValue = v
    workspace.Gravity = v
end)

makeSlider(body, "JUMP POWER", "🚀", 0, 300, 125, 20, 170, function(v)
    jumpPowerValue = v
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = v
    end
end)

makeToggle(body, "INFINITE JUMP", 290, 0, function(s) infiniteJump = s end)
makeToggle(body, "NOCLIP", 290, 65, function(s) isNoclip = s end)

local bottomPanel = Instance.new("Frame")
bottomPanel.Parent = main
bottomPanel.Size = UDim2.new(0, 520, 0, 45)
bottomPanel.Position = UDim2.new(0, 20, 0, 460)
bottomPanel.BackgroundTransparency = 1
bottomPanel.ZIndex = 99999

local function makeBottomButton(text, xPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = bottomPanel
    btn.Size = UDim2.new(0, 165, 0, 45)
    btn.Position = UDim2.new(0, xPos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    btn.Text = text
    btn.TextColor3 = currentColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Active = true
    btn.Selectable = true
    btn.AutoButtonColor = false
    btn.ZIndex = 99999
    corner(btn, 8)
    stroke(btn, currentColor, 1)
    table.insert(colorElements, {obj = btn, prop = "TextColor3"})
    btn.MouseButton1Click:Connect(callback)
end

makeBottomButton("LEVEL", 0, function()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local lvl = ls:FindFirstChild("Level")
        if lvl and lvl:IsA("IntValue") then lvl.Value = lvl.Value + 1 end
    end
end)

makeBottomButton("SERVER HOP", 177, function()
    local success = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        if data and data.data then
            for _, srv in ipairs(data.data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
                    return
                end
            end
        end
    end)
    if not success then TeleportService:Teleport(game.PlaceId, player) end
end)

makeBottomButton("REJOIN", 354, function()
    TeleportService:Teleport(game.PlaceId, player)
end)

-- ==========================================================
-- LÓGICA
-- ==========================================================
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip con protección (anti-detect evita que te kickeen por noclip)
RunService.Stepped:Connect(function()
    if not character then return end
    for _, p in pairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
            if isNoclip then p.CanCollide = false
            else if p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoid.WalkSpeed = walkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = jumpPowerValue
    workspace.Gravity = gravityValue
end)

-- ==========================================================
-- ⚔️ ANTI-DETECT ADICIONAL
-- ==========================================================
-- Bloquear que te kickeen por velocidad/jump/salto
pcall(function()
    if hookfunction then
        local oldKick = player.Kick
        player.Kick = function() end
    end
end)

-- Proteger el ScreenGui de ser eliminado
pcall(function()
    if hookfunction and getconnections then
        for _, c in pairs(getconnections(screenGui.AncestryChanged)) do
            c:Disconnect()
        end
    end
end)

-- Bloquear detección de cambios de WalkSpeed/JumpPower
pcall(function()
    if sethiddenproperty then
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end
end)

-- Ocultar el script en el juego
if setthreadidentity then setthreadidentity(8) end -- Identidad 8 = CoreScript (máxima prioridad)

-- Anti-afk (evita que te kickeen por inactividad)
pcall(function()
    player.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

print("✅ Lunar Hub cargado - Created by leandroh14")
print("⚔️ Anti-Detect activo")
if isOwner then print("⭐ Modo Arcoíris desbloqueado para Leandro102675") end
