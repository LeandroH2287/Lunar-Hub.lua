--==============================================================
-- SCRIPT: Vortexs Position
-- Save Position x2 + TP x2 + Noclip
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--==================== CONFIG ====================
local CONFIG = {
    TPOffset   = Vector3.new(0, 3, 0),
    ToggleKey  = Enum.KeyCode.RightShift
}

--==================== VARIABLES ====================
local SavedPosition1 = nil
local SavedPosition2 = nil
local NoclipEnabled = false
local MenuOpen = false

--==================== COLORS ====================
local COLORS = {
    Background = Color3.fromRGB(18, 16, 28),
    TopBar     = Color3.fromRGB(28, 24, 45),
    Blue       = Color3.fromRGB(80, 120, 240),
    Cyan       = Color3.fromRGB(60, 190, 220),
    Green      = Color3.fromRGB(60, 190, 110),
    Lime       = Color3.fromRGB(140, 210, 60),
    Purple     = Color3.fromRGB(160, 80, 240),
    Pink       = Color3.fromRGB(240, 80, 180),
    Red        = Color3.fromRGB(230, 70, 90),
    Gray       = Color3.fromRGB(85, 85, 105),
    Text       = Color3.fromRGB(245, 240, 255),
    SubText    = Color3.fromRGB(170, 160, 200)
}

--==================== FUNCTIONS ====================

-- Save Position 1
local function SetPosition1()
    local char = LocalPlayer.Character
    if not char then return warn("[X] No character") end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return warn("[X] No HRP") end

    SavedPosition1 = hrp.CFrame
    local pos = SavedPosition1.Position
    print("[OK] Position 1 saved: " .. tostring(pos))

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Vortexs Position";
            Text = string.format("Potion 1 saved: X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z);
            Duration = 3;
        })
    end)
end

-- Save Position 2
local function SetPosition2()
    local char = LocalPlayer.Character
    if not char then return warn("[X] No character") end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return warn("[X] No HRP") end

    SavedPosition2 = hrp.CFrame
    local pos = SavedPosition2.Position
    print("[OK] Position 2 saved: " .. tostring(pos))

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Vortexs Position";
            Text = string.format("Potion 2 saved: X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z);
            Duration = 3;
        })
    end)
end

-- Teleport to Position 1
local function TeleportToPosition1()
    if not SavedPosition1 then
        warn("[X] No saved Position 1")
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = SavedPosition1 + CONFIG.TPOffset
    print("[OK] Teleported to Position 1")

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Vortexs Position";
            Text = "Teleported to Potion 1!";
            Duration = 2;
        })
    end)
end

-- Teleport to Position 2
local function TeleportToPosition2()
    if not SavedPosition2 then
        warn("[X] No saved Position 2")
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = SavedPosition2 + CONFIG.TPOffset
    print("[OK] Teleported to Position 2")

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Vortexs Position";
            Text = "Teleported to Potion 2!";
            Duration = 2;
        })
    end)
end

--==================== NOCLIP ====================
local function NoclipLoop()
    while NoclipEnabled do
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end

local function RestoreCollisions()
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

--==================== UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VortexsPosition"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Floating toggle
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 58, 0, 58)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -29)
ToggleBtn.BackgroundColor3 = COLORS.TopBar
ToggleBtn.Text = "🌀"
ToggleBtn.TextSize = 28
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = COLORS.Text
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 14)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.Purple),
    ColorSequenceKeypoint.new(1, COLORS.Pink)
})
ToggleGradient.Rotation = 45
ToggleGradient.Parent = ToggleStroke

-- Main frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 420)
Frame.Position = UDim2.new(0, 88, 0.5, -210)
Frame.BackgroundColor3 = COLORS.Background
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Visible = false
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Transparency = 0.3
FrameStroke.Parent = Frame

local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.Purple),
    ColorSequenceKeypoint.new(1, COLORS.Pink)
})
FrameGradient.Rotation = 45
FrameGradient.Parent = FrameStroke

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = COLORS.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 14)
TopFix.Position = UDim2.new(0, 0, 1, -14)
TopFix.BackgroundColor3 = COLORS.TopBar
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌀  Vortexs Position"
Title.TextColor3 = COLORS.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 8)
CloseBtn.BackgroundColor3 = COLORS.Red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = COLORS.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Section label helper
local function CreateSectionLabel(text, yPos, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Frame
    return lbl
end

-- Button helper
local function CreateButton(text, yPos, height, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, height)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                math.min(color.R + 0.12, 1),
                math.min(color.G + 0.12, 1),
                math.min(color.B + 0.12, 1)
            )
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = color
        }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {
            Size = UDim2.new(1, -28, 0, height - 4)
        }):Play()
        task.wait(0.08)
        TweenService:Create(btn, TweenInfo.new(0.08), {
            Size = UDim2.new(1, -24, 0, height)
        }):Play()
        callback(btn)
    end)

    return btn
end

-- ============ POTION 1 SECTION ============
CreateSectionLabel("🧪  POTION 1", 55, COLORS.Cyan)

CreateButton("📌  Save Potion 1  [G]", 80, 45, COLORS.Blue, function()
    SetPosition1()
end)

CreateButton("🚀  TP to Potion 1  [T]", 130, 45, COLORS.Cyan, function()
    TeleportToPosition1()
end)

-- ============ POTION 2 SECTION ============
CreateSectionLabel("🧪  POTION 2", 185, COLORS.Lime)

CreateButton("📌  Save Potion 2  [Y]", 210, 45, COLORS.Green, function()
    SetPosition2()
end)

CreateButton("🚀  TP to Potion 2  [U]", 260, 45, COLORS.Lime, function()
    TeleportToPosition2()
end)

-- ============ NOCLIP SECTION ============
CreateSectionLabel("⚙️  UTILITIES", 320, COLORS.Pink)

local BtnNoclip = CreateButton("👻  Noclip: OFF  [N]", 345, 45, COLORS.Gray, function(btn)
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        btn.Text = "👻  Noclip: ON  [N]"
        btn.BackgroundColor3 = COLORS.Purple
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Purple}):Play()
        task.spawn(NoclipLoop)
    else
        btn.Text = "👻  Noclip: OFF  [N]"
        btn.BackgroundColor3 = COLORS.Gray
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Gray}):Play()
        RestoreCollisions()
    end
end)

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -24, 0, 20)
Footer.Position = UDim2.new(0, 12, 1, -26)
Footer.BackgroundTransparency = 1
Footer.Text = "G • T • Y • U • N • RightShift"
Footer.TextColor3 = COLORS.SubText
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 11
Footer.Parent = Frame

--==================== MENU OPEN/CLOSE ====================
local function ToggleMenu()
    MenuOpen = not MenuOpen
    if MenuOpen then
        Frame.Visible = true
        Frame.Size = UDim2.new(0, 280, 0, 400)
        TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 420)
        }):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.Purple
        }):Play()
    else
        TweenService:Create(Frame, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 260, 0, 380)
        }):Play()
        task.wait(0.15)
        Frame.Visible = false
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.TopBar
        }):Play()
    end
end

CloseBtn.MouseButton1Click:Connect(function()
    if MenuOpen then ToggleMenu() end
end)

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)

--==================== KEYBOARD INPUT ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.G then
        SetPosition1()
    elseif input.KeyCode == Enum.KeyCode.T then
        TeleportToPosition1()
    elseif input.KeyCode == Enum.KeyCode.Y then
        SetPosition2()
    elseif input.KeyCode == Enum.KeyCode.U then
        TeleportToPosition2()
    elseif input.KeyCode == Enum.KeyCode.N then
        NoclipEnabled = not NoclipEnabled
        if NoclipEnabled then
            BtnNoclip.Text = "👻  Noclip: ON  [N]"
            BtnNoclip.BackgroundColor3 = COLORS.Purple
            TweenService:Create(BtnNoclip, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Purple}):Play()
            task.spawn(NoclipLoop)
        else
            BtnNoclip.Text = "👻  Noclip: OFF  [N]"
            BtnNoclip.BackgroundColor3 = COLORS.Gray
            TweenService:Create(BtnNoclip, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Gray}):Play()
            RestoreCollisions()
        end
    elseif input.KeyCode == CONFIG.ToggleKey then
        ToggleMenu()
    end
end)

-- Re-apply noclip on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if NoclipEnabled then
        task.spawn(NoclipLoop)
    end
end)

--==================== LOADED ====================
print("[OK] Vortexs Position loaded successfully")
print("G = Save Potion 1 | T = TP Potion 1")
print("Y = Save Potion 2 | U = TP Potion 2")
print("N = Noclip | RightShift = Menu")
