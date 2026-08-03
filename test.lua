-- STREAMING_CHUNK:Initializing services and local player references...
-- Place this script inside StarterPlayer -> StarterPlayerScripts (or StarterGui) as a LocalScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Variables for state management
local selectedTargetPlayer = nil
local activeJumpscareType = "Classic Screamer"
local isSpinning = false
local spinConnection = nil

-- STREAMING_CHUNK:Logging startup message to developer console...
print("--------------------------------------------------")
print("🔥 WELCOME TO NIGHTMARE OP SCRIPT LOADED SUCCESSFULLY 🔥")
print("--------------------------------------------------")

-- STREAMING_CHUNK:Creating main ScreenGui overlay...
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NightmareOpGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Jumpscare Visual Overlay (Screen Flash / Screamer Effect)
local jumpscareOverlay = Instance.new("Frame")
jumpscareOverlay.Name = "JumpscareOverlay"
jumpscareOverlay.Size = UDim2.new(1, 0, 1, 0)
jumpscareOverlay.Position = UDim2.new(0, 0, 0, 0)
jumpscareOverlay.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
jumpscareOverlay.BackgroundTransparency = 1
jumpscareOverlay.ZIndex = 100
jumpscareOverlay.Parent = screenGui

local jumpscareImage = Instance.new("ImageLabel")
jumpscareImage.Name = "JumpscareImage"
jumpscareImage.Size = UDim2.new(0.8, 0, 0.8, 0)
jumpscareImage.AnchorPoint = Vector2.new(0.5, 0.5)
jumpscareImage.Position = UDim2.new(0.5, 0, 0.5, 0)
jumpscareImage.BackgroundTransparency = 1
jumpscareImage.Image = "rbxassetid://6894541539" -- Dark ominous entity graphic
jumpscareImage.ImageTransparency = 1
jumpscareImage.ZIndex = 101
jumpscareImage.Parent = jumpscareOverlay

-- Main GUI Window Container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(220, 38, 38)
mainStroke.Parent = mainFrame

-- STREAMING_CHUNK:Constructing title header and status bar...
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Text = "WELCOME TO NIGHTMARE OP SCRIPT"
titleLabel.TextColor3 = Color3.fromRGB(255, 65, 65)
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- STREAMING_CHUNK:Building left panel for dynamic player list...
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 230, 1, -65)
leftPanel.Position = UDim2.new(0, 10, 0, 55)
leftPanel.BackgroundColor3 = Color3.fromRGB(24, 25, 35)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 10)
leftCorner.Parent = leftPanel

local playerListHeader = Instance.new("TextLabel")
playerListHeader.Size = UDim2.new(1, 0, 0, 30)
playerListHeader.BackgroundTransparency = 1
playerListHeader.Font = Enum.Font.SourceSansBold
playerListHeader.Text = "SERVER PLAYERS"
playerListHeader.TextColor3 = Color3.fromRGB(160, 165, 185)
playerListHeader.TextSize = 14
playerListHeader.Parent = leftPanel

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Name = "PlayerScroll"
playerScroll.Size = UDim2.new(1, -10, 1, -35)
playerScroll.Position = UDim2.new(0, 5, 0, 30)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = Color3.fromRGB(220, 38, 38)
playerScroll.Parent = leftPanel

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 6)
playerListLayout.Parent = playerScroll

-- STREAMING_CHUNK:Building right panel for controls and jumpscare options...
local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -260, 1, -65)
rightPanel.Position = UDim2.new(0, 250, 0, 55)
rightPanel.BackgroundColor3 = Color3.fromRGB(24, 25, 35)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 10)
rightCorner.Parent = rightPanel

local targetStatusLabel = Instance.new("TextLabel")
targetStatusLabel.Name = "TargetStatusLabel"
targetStatusLabel.Size = UDim2.new(1, -20, 0, 30)
targetStatusLabel.Position = UDim2.new(0, 10, 0, 10)
targetStatusLabel.BackgroundTransparency = 1
targetStatusLabel.Font = Enum.Font.SourceSansBold
targetStatusLabel.Text = "Target: None Selected"
targetStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
targetStatusLabel.TextSize = 16
targetStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
targetStatusLabel.Parent = rightPanel

-- Jumpscare Type Selection Label
local typeHeader = Instance.new("TextLabel")
typeHeader.Size = UDim2.new(1, -20, 0, 25)
typeHeader.Position = UDim2.new(0, 10, 0, 45)
typeHeader.BackgroundTransparency = 1
typeHeader.Font = Enum.Font.SourceSansBold
typeHeader.Text = "SELECT JUMPSCARE TYPE:"
typeHeader.TextColor3 = Color3.fromRGB(160, 165, 185)
typeHeader.TextSize = 14
typeHeader.TextXAlignment = Enum.TextXAlignment.Left
typeHeader.Parent = rightPanel

-- Jumpscare Mode Container Grid
local modesFrame = Instance.new("Frame")
modesFrame.Name = "ModesFrame"
modesFrame.Size = UDim2.new(1, -20, 0, 110)
modesFrame.Position = UDim2.new(0, 10, 0, 75)
modesFrame.BackgroundTransparency = 1
modesFrame.Parent = rightPanel

local modesGrid = Instance.new("UIGridLayout")
modesGrid.CellSize = UDim2.new(0.48, 0, 0, 45)
modesGrid.CellPadding = UDim2.new(0.04, 0, 0.08, 0)
modesGrid.Parent = modesFrame

local jumpscareTypes = {
{ Name = "Classic Screamer", Desc = "Full flash image + loud demonic screech" },
{ Name = "Spinning TP Ambush", Desc = "Teleports to target and spins rapidly" },
{ Name = "Void Screamer", Desc = "Black red vignette with screen shake" },
{ Name = "Dimension Distortion", Desc = "Strobe light sequence + teleports" }
}

local typeButtons = {}

-- STREAMING_CHUNK:Populating jumpscare mode selection buttons...
for _, jType in ipairs(jumpscareTypes) do
local btn = Instance.new("TextButton")
btn.Name = jType.Name
btn.BackgroundColor3 = jType.Name == activeJumpscareType and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(35, 38, 55)
btn.Font = Enum.Font.SourceSansBold
btn.Text = jType.Name
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 14
btn.Parent = modesFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn

typeButtons[jType.Name] = btn

btn.MouseButton1Click:Connect(function()
    activeJumpscareType = jType.Name
    for name, button in pairs(typeButtons) do
        if name == activeJumpscareType then
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(220, 38, 38) }):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(35, 38, 55) }):Play()
        end
    end
end)


end

-- STREAMING_CHUNK:Creating action buttons (Execute, TP, Spin)...
local executeButton = Instance.new("TextButton")
executeButton.Name = "ExecuteButton"
executeButton.Size = UDim2.new(1, -20, 0, 45)
executeButton.Position = UDim2.new(0, 10, 0, 200)
executeButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
executeButton.Font = Enum.Font.FredokaOne
executeButton.Text = "☠️ EXECUTE JUMPSCARE"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.TextSize = 18
executeButton.Parent = rightPanel

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 8)
execCorner.Parent = executeButton

-- Teleport Only Button
local tpButton = Instance.new("TextButton")
tpButton.Name = "TpButton"
tpButton.Size = UDim2.new(0.48, 0, 0, 40)
tpButton.Position = UDim2.new(0, 10, 0, 255)
tpButton.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
tpButton.Font = Enum.Font.SourceSansBold
tpButton.Text = "🌀 TP To Target"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextSize = 15
tpButton.Parent = rightPanel

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpButton

-- Spin Self Button
local spinButton = Instance.new("TextButton")
spinButton.Name = "SpinButton"
spinButton.Size = UDim2.new(0.48, 0, 0, 40)
spinButton.Position = UDim2.new(0.52, 0, 0, 255)
spinButton.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
spinButton.Font = Enum.Font.SourceSansBold
spinButton.Text = "🔄 Spin Character"
spinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spinButton.TextSize = 15
spinButton.Parent = rightPanel

local spinCorner = Instance.new("UICorner")
spinCorner.CornerRadius = UDim.new(0, 8)
spinCorner.Parent = spinButton

-- STREAMING_CHUNK:Defining player list updating function...
local function updatePlayerList()
-- Clear current list
for _, child in ipairs(playerScroll:GetChildren()) do
if child:IsA("TextButton") then
child:Destroy()
end
end

-- Populate active players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        local pBtn = Instance.new("TextButton")
        pBtn.Name = player.Name
        pBtn.Size = UDim2.new(1, -10, 0, 36)
        pBtn.BackgroundColor3 = (selectedTargetPlayer == player) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(35, 38, 52)
        pBtn.Font = Enum.Font.SourceSansBold
        pBtn.Text = " 👤 " .. player.DisplayName .. " (@" .. player.Name .. ")"
        pBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
        pBtn.TextSize = 14
        pBtn.TextXAlignment = Enum.TextXAlignment.Left
        pBtn.Parent = playerScroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = pBtn
        
        pBtn.MouseButton1Click:Connect(function()
            selectedTargetPlayer = player
            targetStatusLabel.Text = "Target: " .. player.DisplayName
            updatePlayerList() -- Refresh highlights
        end)
    end
end

playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)


end

-- Connect auto-update events on player join/leave
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
if selectedTargetPlayer == player then
selectedTargetPlayer = nil
targetStatusLabel.Text = "Target: None Selected"
end
updatePlayerList()
end)

updatePlayerList()

-- STREAMING_CHUNK:Implementing teleport and character spin helper functions...
local function teleportToTarget(target)
if not target or not target.Character then return end
local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

if targetHrp and myHrp then
    -- Teleport right in front of target facing them
    myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.pi, 0)
end


end

local function toggleSpinCharacter(speed)
speed = speed or 30
if isSpinning then
isSpinning = false
spinButton.Text = "🔄 Spin Character"
if spinConnection then
spinConnection:Disconnect()
spinConnection = nil
end
else
isSpinning = true
spinButton.Text = "🛑 Stop Spinning"
spinConnection = RunService.RenderStepped:Connect(function(dt)
local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
if myHrp then
myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
end
end)
end
end

-- STREAMING_CHUNK:Executing jumpscare visual & audio effects...
local function triggerJumpscareEffect(mode)
-- Sound FX creation
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9069609268" -- Screamer screech audio ID
sound.Volume = 3
sound.Parent = SoundService
sound:Play()

if mode == "Classic Screamer" then
    -- Flash jumpscare image
    jumpscareOverlay.BackgroundTransparency = 0.2
    jumpscareImage.ImageTransparency = 0
    jumpscareImage.Size = UDim2.new(0.5, 0, 0.5, 0)
    
    -- Shake image
    local tweenZoom = TweenService:Create(jumpscareImage, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), { Size = UDim2.new(1.1, 0, 1.1, 0) })
    tweenZoom:Play()
    
    task.wait(1.2)
    
    TweenService:Create(jumpscareOverlay, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(jumpscareImage, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()

elseif mode == "Spinning TP Ambush" then
    if selectedTargetPlayer then
        teleportToTarget(selectedTargetPlayer)
    end
    
    -- Enable temporary fast spin
    local tempSpin = RunService.RenderStepped:Connect(function()
        local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, math.rad(45), 0)
        end
    end)
    
    jumpscareOverlay.BackgroundTransparency = 0.4
    jumpscareImage.ImageTransparency = 0.2
    
    task.wait(1.5)
    tempSpin:Disconnect()
    jumpscareOverlay.BackgroundTransparency = 1
    jumpscareImage.ImageTransparency = 1

elseif mode == "Void Screamer" then
    -- Strobe Vignette dark red screen distortion
    for i = 1, 6 do
        jumpscareOverlay.BackgroundTransparency = (i % 2 == 0) and 0.1 or 0.8
        jumpscareOverlay.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.wait(0.1)
    end
    jumpscareOverlay.BackgroundTransparency = 1

elseif mode == "Dimension Distortion" then
    if selectedTargetPlayer then
        for i = 1, 4 do
            teleportToTarget(selectedTargetPlayer)
            local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                myHrp.CFrame = myHrp.CFrame * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
            jumpscareOverlay.BackgroundTransparency = 0.3
            task.wait(0.15)
            jumpscareOverlay.BackgroundTransparency = 1
            task.wait(0.15)
        end
    end
end

task.delay(3, function()
    sound:Destroy()
end)


end

-- STREAMING_CHUNK:Connecting button listeners and event handlers...
executeButton.MouseButton1Click:Connect(function()
if not selectedTargetPlayer then
targetStatusLabel.Text = "⚠️ Select a target first!"
task.wait(1.5)
targetStatusLabel.Text = "Target: None Selected"
return
end
triggerJumpscareEffect(activeJumpscareType)
end)

tpButton.MouseButton1Click:Connect(function()
if selectedTargetPlayer then
teleportToTarget(selectedTargetPlayer)
else
targetStatusLabel.Text = "⚠️ Select a target first!"
task.wait(1.5)
targetStatusLabel.Text = "Target: None Selected"
end
end)

spinButton.MouseButton1Click:Connect(function()
toggleSpinCharacter(35)
end)

closeButton.MouseButton1Click:Connect(function()
if spinConnection then
spinConnection:Disconnect()
end
screenGui:Destroy()
end)

-- UI Entry Animation
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 40)
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
Position = UDim2.new(0.5, 0, 0.5, 0),
BackgroundTransparency = 0
}):Play()
