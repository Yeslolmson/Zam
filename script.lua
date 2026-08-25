```lua
-- Rivals Cheat Script (Mobile Optimized)
-- LocalScript placed in StarterPlayerScripts or StarterGui

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- === CONFIGURATION ===
local CONFIG = {
    MainToggleKey = Enum.KeyCode.G,  -- Keyboard toggle (still works on PC)
    SilentAimCircleSize = 100,       -- radius in pixels
    AimBoxTarget = "Hitbox",         -- "Head", "Body", "Hitbox"
}

-- === STATE ===
local Settings = {
    BacktrackEnabled = false,
    SilentAimEnabled = false,
    AimBoxEnabled = false,
    ESPEnabled = false,
    GuiOpen = true,
    SettingsOpen = false,
}

-- === GUI SETUP ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile toggle button (always visible)
local MobileToggle = Instance.new("TextButton")
MobileToggle.Name = "MobileToggle"
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0, 10, 0, 10)
MobileToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggle.Font = Enum.Font.SourceSansBold
MobileToggle.TextSize = 18
MobileToggle.Text = "☰"
MobileToggle.ZIndex = 10
MobileToggle.Parent = ScreenGui

-- Main GUI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Top drag bar for MainFrame
local MainDragBar = Instance.new("TextButton")
MainDragBar.Name = "DragBar"
MainDragBar.Size = UDim2.new(1, -40, 0, 40)  -- leave space for settings logo
MainDragBar.Position = UDim2.new(0, 0, 0, 0)
MainDragBar.BackgroundTransparency = 1
MainDragBar.Text = ""
MainDragBar.AutoButtonColor = false
MainDragBar.ZIndex = 2
MainDragBar.Parent = MainFrame

-- Settings Logo (top right of MainFrame)
local SettingsLogo = Instance.new("ImageButton")
SettingsLogo.Name = "SettingsLogo"
SettingsLogo.Size = UDim2.new(0, 30, 0, 30)
SettingsLogo.Position = UDim2.new(1, -35, 0, 5)
SettingsLogo.BackgroundTransparency = 1
SettingsLogo.Image = "rbxassetid://7072707420" -- gear icon
SettingsLogo.Parent = MainFrame
SettingsLogo.ZIndex = 5

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Rivals Cheats"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Toggle buttons container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(1, -20, 1, -50)
ToggleContainer.Position = UDim2.new(0, 10, 0, 40)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = MainFrame

-- Helper to create toggle buttons
local function CreateToggleButton(name, yPos, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Position = UDim2.new(0, 0, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Text = name .. ": OFF"
    Button.AutoButtonColor = false
    Button.Parent = ToggleContainer

    local State = false
    Button.MouseButton1Click:Connect(function()
        State = not State
        Button.Text = name .. ": " .. (State and "ON" or "OFF")
        Button.BackgroundColor3 = State and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        if callback then callback(State) end
    end)

    return {
        Button = Button,
        SetState = function(newState)
            State = newState
            Button.Text = name .. ": " .. (State and "ON" or "OFF")
            Button.BackgroundColor3 = State and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        end,
        GetState = function() return State end,
    }
end

-- Create toggle buttons
local BacktrackToggle = CreateToggleButton("Backtrack", 0, function(state)
    Settings.BacktrackEnabled = state
end)
local SilentAimToggle = CreateToggleButton("Silent Aim", 40, function(state)
    Settings.SilentAimEnabled = state
    CircleDrawing.Visible = state
end)
local AimBoxToggle = CreateToggleButton("AimBox", 80, function(state)
    Settings.AimBoxEnabled = state
end)
local ESPToggle = CreateToggleButton("ESP", 120, function(state)
    Settings.ESPEnabled = state
end)

-- === SETTINGS PANEL ===
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Size = UDim2.new(0, 300, 0, 400)
SettingsFrame.Position = MainFrame.Position
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = ScreenGui

-- Top drag bar for SettingsFrame
local SettingsDragBar = Instance.new("TextButton")
SettingsDragBar.Name = "DragBar"
SettingsDragBar.Size = UDim2.new(1, -40, 0, 40)
SettingsDragBar.Position = UDim2.new(0, 0, 0, 0)
SettingsDragBar.BackgroundTransparency = 1
SettingsDragBar.Text = ""
SettingsDragBar.AutoButtonColor = false
SettingsDragBar.ZIndex = 2
SettingsDragBar.Parent = SettingsFrame

-- Settings Title
local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -40, 0, 30)
SettingsTitle.Position = UDim2.new(0, 10, 0, 5)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextSize = 20
SettingsTitle.Parent = SettingsFrame

-- Silent Aim Circle Size Slider
local CircleSizeLabel = Instance.new("TextLabel")
CircleSizeLabel.Size = UDim2.new(0, 150, 0, 30)
CircleSizeLabel.Position = UDim2.new(0, 10, 0, 50)
CircleSizeLabel.BackgroundTransparency = 1
CircleSizeLabel.Text = "Circle Size: " .. CONFIG.SilentAimCircleSize
CircleSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleSizeLabel.Font = Enum.Font.SourceSans
CircleSizeLabel.TextSize = 16
CircleSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
CircleSizeLabel.Parent = SettingsFrame

local CircleSizeSlider = Instance.new("TextBox")
CircleSizeSlider.Size = UDim2.new(0, 60, 0, 30)
CircleSizeSlider.Position = UDim2.new(0, 160, 0, 50)
CircleSizeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CircleSizeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleSizeSlider.Font = Enum.Font.SourceSans
CircleSizeSlider.TextSize = 16
CircleSizeSlider.Text = tostring(CONFIG.SilentAimCircleSize)
CircleSizeSlider.Parent = SettingsFrame
CircleSizeSlider.FocusLost:Connect(function()
    local num = tonumber(CircleSizeSlider.Text)
    if num and num > 0 then
        CONFIG.SilentAimCircleSize = num
        CircleSizeLabel.Text = "Circle Size: " .. num
        UpdateCircle()
    else
        CircleSizeSlider.Text = tostring(CONFIG.SilentAimCircleSize)
    end
end)

-- AimBox Target Dropdown
local AimBoxTargetLabel = Instance.new("TextLabel")
AimBoxTargetLabel.Size = UDim2.new(0, 120, 0, 30)
AimBoxTargetLabel.Position = UDim2.new(0, 10, 0, 90)
AimBoxTargetLabel.BackgroundTransparency = 1
AimBoxTargetLabel.Text = "AimBox Target:"
AimBoxTargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBoxTargetLabel.Font = Enum.Font.SourceSans
AimBoxTargetLabel.TextSize = 16
AimBoxTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
AimBoxTargetLabel.Parent = SettingsFrame

local AimBoxTargetDropdown = Instance.new("TextButton")
AimBoxTargetDropdown.Size = UDim2.new(0, 120, 0, 30)
AimBoxTargetDropdown.Position = UDim2.new(0, 140, 0, 90)
AimBoxTargetDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimBoxTargetDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBoxTargetDropdown.Font = Enum.Font.SourceSans
AimBoxTargetDropdown.TextSize = 16
AimBoxTargetDropdown.Text = CONFIG.AimBoxTarget
AimBoxTargetDropdown.Parent = SettingsFrame

local AimBoxTargets = {"Head", "Body", "Hitbox"}
local AimBoxTargetIndex = table.find(AimBoxTargets, CONFIG.AimBoxTarget) or 3
AimBoxTargetDropdown.MouseButton1Click:Connect(function()
    AimBoxTargetIndex = AimBoxTargetIndex % #AimBoxTargets + 1
    CONFIG.AimBoxTarget = AimBoxTargets[AimBoxTargetIndex]
    AimBoxTargetDropdown.Text = CONFIG.AimBoxTarget
end)

-- Settings logo click handling (also move logo when switching panels)
SettingsLogo.MouseButton1Click:Connect(function()
    Settings.SettingsOpen = not Settings.SettingsOpen
    SettingsFrame.Visible = Settings.SettingsOpen
    MainFrame.Visible = not Settings.SettingsOpen
    SettingsLogo.Parent = Settings.SettingsOpen and SettingsFrame or MainFrame
    SettingsLogo.Position = UDim2.new(1, -35, 0, 5)
end)

-- === DRAG SYSTEM ===
local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local frameStart = nil

    dragHandle.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = Vector2.new(Mouse.X, Mouse.Y)
        frameStart = frame.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(Mouse.X, Mouse.Y) - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

makeDraggable(MainFrame, MainDragBar)
makeDraggable(SettingsFrame, SettingsDragBar)

-- === TOGGLE MAIN GUI FUNCTION ===
local function ToggleMainGUI()
    Settings.GuiOpen = not Settings.GuiOpen
    MainFrame.Visible = Settings.GuiOpen and not Settings.SettingsOpen
    SettingsFrame.Visible = Settings.GuiOpen and Settings.SettingsOpen
    if Settings.SettingsOpen then
        SettingsLogo.Parent = SettingsFrame
    else
        SettingsLogo.Parent = MainFrame
    end
end

-- Mobile toggle button click
MobileToggle.MouseButton1Click:Connect(function()
    ToggleMainGUI()
end)

-- Keyboard toggle (optional for PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == CONFIG.MainToggleKey then
        ToggleMainGUI()
    end
end)

-- === ESP SYSTEM ===
local ESPContainer = Instance.new("ScreenGui")
ESPContainer.Name = "ESPContainer"
ESPContainer.ResetOnSpawn = false
ESPContainer.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ESPFrames = {}

local function UpdateESP()
    for player, frameData in pairs(ESPFrames) do
        if player.Parent == nil or player.Character == nil or player.Character:FindFirstChild("HumanoidRootPart") == nil then
            if frameData.Frame then frameData.Frame:Destroy() end
            ESPFrames[player] = nil
        else
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
            if onScreen then
                local size = 50 / (Camera.CFrame.Position - rootPart.Position).Magnitude * 10
                frameData.Frame.Visible = true
                frameData.Frame.Position = UDim2.new(0, screenPos.X - size/2, 0, screenPos.Y - size/2)
                frameData.Frame.Size = UDim2.new(0, size, 0, size)
                frameData.NameLabel.Text = player.Name
            else
                frameData.Frame.Visible = false
            end
        end
    end
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer or ESPFrames[player] then return end

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    frame.Size = UDim2.new(0, 50, 0, 50)
    frame.Visible = false
    frame.Parent = ESPContainer

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = frame

    ESPFrames[player] = {Frame = frame, NameLabel = nameLabel}
end

Players.PlayerAdded:Connect(function(player)
    if Settings.ESPEnabled then
        wait(1)
        CreateESPForPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPFrames[player] then
        ESPFrames[player].Frame:Destroy()
        ESPFrames[player] = nil
    end
end)

-- Update ESP frames based on toggle
ESPToggle.Button.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = ESPToggle.GetState()
    if Settings.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESPForPlayer(player)
            end
        end
    else
        for player, data in pairs(ESPFrames) do
            data.Frame:Destroy()
            ESPFrames[player] = nil
        end
    end
end)

-- === BACKTRACK SYSTEM ===
local function GetClosestEnemyBehind(maxDistance)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local root = character.HumanoidRootPart
    local closest = nil
    local closestDist = maxDistance

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = player.Character.HumanoidRootPart
            local dist = (root.Position - enemyRoot.Position).Magnitude
            if dist < closestDist then
                local enemyLook = enemyRoot.CFrame.LookVector
                local toPlayer = (root.Position - enemyRoot.Position).Unit
                local dot = enemyLook:Dot(toPlayer)
                if dot < -0.5 then
                    closest = enemyRoot
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

local function BacktrackAttack()
    if not Settings.BacktrackEnabled then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or not tool:IsA("Tool") or tool.Name:lower():find("knife") == nil then return end

    local enemyRoot = GetClosestEnemyBehind(10)
    if enemyRoot then
        local character = LocalPlayer.Character
        local root = character.HumanoidRootPart
        local lookAt = CFrame.lookAt(root.Position, enemyRoot.Position)
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, lookAt.Y, 0)
        tool:Activate()
    end
end

Mouse.Button1Down:Connect(function()
    BacktrackAttack()
end)

-- === SILENT AIM SYSTEM ===
local CircleDrawing = Drawing.new("Circle")
CircleDrawing.Thickness = 2
CircleDrawing.Color = Color3.fromRGB(255, 0, 0)
CircleDrawing.Transparency = 0.8
CircleDrawing.Visible = false
CircleDrawing.Radius = CONFIG.SilentAimCircleSize
CircleDrawing.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local function UpdateCircle()
    CircleDrawing.Radius = CONFIG.SilentAimCircleSize
    CircleDrawing.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

local SilentAimOriginalCFrame = nil
local SilentAimFrameCount = 0

local function GetClosestEnemyInCircle()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest = nil
    local closestDist = CONFIG.SilentAimCircleSize

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < closestDist then
                    closest = head
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

local function SilentAimShot()
    if not Settings.SilentAimEnabled then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or not tool:IsA("Tool") then return end

    local targetHead = GetClosestEnemyInCircle()
    if targetHead then
        SilentAimOriginalCFrame = Camera.CFrame
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
        tool:Activate()
        SilentAimFrameCount = 2
    end
end

RunService.RenderStepped:Connect(function()
    if SilentAimFrameCount > 0 then
        SilentAimFrameCount = SilentAimFrameCount - 1
        if SilentAimFrameCount == 0 and SilentAimOriginalCFrame then
            Camera.CFrame = SilentAimOriginalCFrame
            SilentAimOriginalCFrame = nil
        end
    end
end)

Mouse.Button1Down:Connect(function()
    SilentAimShot()
end)

-- === AIMBOX SYSTEM ===
local function GetEnemyPartFromMouse()
    local mouseRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 500, raycastParams)
    if raycastResult and raycastResult.Instance then
        local part = raycastResult.Instance
        local character = part.Parent
        if character and character:IsA("Model") then
            local player = Players:GetPlayerFromCharacter(character)
            if player and player ~= LocalPlayer then
                return part, player
            end
        end
    end
    return nil, nil
end

local function IsPartValidTarget(part)
    if CONFIG.AimBoxTarget == "Hitbox" then
        return true
    elseif CONFIG.AimBoxTarget == "Head" then
        return part.Name == "Head"
    elseif CONFIG.AimBoxTarget == "Body" then
        return part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Parent:FindFirstChild("HumanoidRootPart") == part
    end
    return false
end

local function AimBoxCheck()
    if not Settings.AimBoxEnabled then return end
    local part, player = GetEnemyPartFromMouse()
    if part and player and IsPartValidTarget(part) then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:IsA("Tool") then
            tool:Activate()
        end
    end
end

Mouse.Move:Connect(function()
    AimBoxCheck()
end)

RunService.Heartbeat:Connect(function()
    if Settings.AimBoxEnabled then
        AimBoxCheck()
    end
end)

-- === INITIALIZATION ===
ESPToggle.SetState(false)
Settings.ESPEnabled = false

RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then
        UpdateESP()
    end
end)

MainFrame.Visible = true
SettingsFrame.Visible = false
SettingsLogo.Parent = MainFrame
CircleDrawing.Visible = false

print("Rivals Cheat Script Loaded (Mobile Version)")
```