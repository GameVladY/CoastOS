-- STREAMING_CHUNK:Initializing services and dynamic GUI parent detection...
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

-- Safe GUI container resolution (Works in Roblox Studio & Executors)
local function getGuiParent()
local success, result = pcall(function()
if gethui then
return gethui()
elseif CoreGui then
return CoreGui
end
end)
if success and result then
return result
end
return localPlayer:WaitForChild("PlayerGui")
end

local targetParent = getGuiParent()

-- Destroy existing GUI instance if script is re-executed
if targetParent:FindFirstChild("NightmareOpGui") then
targetParent:FindFirstChild("NightmareOpGui"):Destroy()
end

-- State variables
local selectedTargetPlayer = nil
local activeJumpscareType = "Classic Screamer"
local isSpinning = false
local spinConnection = nil
local dragging = false
local dragInput, dragStart, startPos

print("--------------------------------------------------")
print("🔥 WELCOME TO NIGHTMARE OP SCRIPT LOADED SUCCESSFULLY 🔥")
print("--------------------------------------------------")

-- STREAMING_CHUNK:Creating main ScreenGui and visual overlay elements...
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NightmareOpGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 99999
screenGui.Parent = targetParent

-- Fullscreen Jumpscare Overlay
local jumpscareOverlay = Instance.new("Frame")
jumpscareOverlay.Name = "JumpscareOverlay"
jumpscareOverlay.Size = UDim2.new(1, 0, 1, 0)
jumpscareOverlay.Position = UDim2.new(0, 0, 0, 0)
jumpscareOverlay.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
jumpscareOverlay.BackgroundTransparency = 1
jumpscareOverlay.ZIndex = 1000
jumpscareOverlay.Parent = screenGui

local jumpscareImage = Instance.new("ImageLabel")
jumpscareImage.Name = "JumpscareImage"
jumpscareImage.Size = UDim2.new(0.7, 0, 0.7, 0)
jumpscareImage.AnchorPoint = Vector2.new(0.5, 0.5)
jumpscareImage.Position = UDim2.new(0.5, 0, 0.5, 0)
jumpscareImage.BackgroundTransparency = 1
jumpscareImage.Image = "rbxassetid://6894541539" -- Dark entity horror asset
jumpscareImage.ImageTransparency = 1
jumpscareImage.ZIndex = 1001
jumpscareImage.Parent = jumpscareOverlay

-- STREAMING_CHUNK:Constructing window frame and layout structure...
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(230, 35, 35)
mainStroke.Parent = mainFrame

-- STREAMING_CHUNK:Building header bar with dragging capabilities...
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
header.BorderSizePixel = 0
header.ZIndex = 11
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
titleLabel.Text = "☠️ WELCOME TO NIGHTMARE OP SCRIPT"
titleLabel.TextColor3 = Color3.fromRGB(255, 65, 65)
titleLabel.TextSize = 19
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12
titleLabel.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -12, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.ZIndex = 12
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Window Drag Logic
header.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = mainFrame.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end


end)

header.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)

UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
mainFrame.Position = UDim2.new(
startPos.Scale.X, startPos.Offset.X + delta.X,
startPos.Scale.Y, startPos.Offset.Y + delta.Y
)
end
end)

-- STREAMING_CHUNK:Creating left panel for dynamic player selection...
local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 220, 1, -65)
leftPanel.Position = UDim2.new(0, 12, 0, 58)
leftPanel.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
leftPanel.BorderSizePixel = 0
leftPanel.ZIndex = 11
leftPanel.Parent = mainFrame

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 10)
leftCorner.Parent = leftPanel

local playerListHeader = Instance.new("TextLabel")
playerListHeader.Size = UDim2.new(1, 0, 0, 30)
playerListHeader.BackgroundTransparency = 1
playerListHeader.Font = Enum.Font.SourceSansBold
playerListHeader.Text = "SERVER PLAYERS"
playerListHeader.TextColor3 = Color3.fromRGB(150, 155, 175)
playerListHeader.TextSize = 13
playerListHeader.ZIndex = 12
playerListHeader.Parent = leftPanel

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Name = "PlayerScroll"
playerScroll.Size = UDim2.new(1, -10, 1, -35)
playerScroll.Position = UDim2.new(0, 5, 0, 30)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = Color3.fromRGB(220, 38, 38)
playerScroll.ZIndex = 12
playerScroll.Parent = leftPanel

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.Parent = playerScroll

-- STREAMING_CHUNK:Creating right panel for jumpscare settings and controls...
local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -256, 1, -65)
rightPanel.Position = UDim2.new(0, 244, 0, 58)
rightPanel.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
rightPanel.BorderSizePixel = 0
rightPanel.ZIndex = 11
rightPanel.Parent = mainFrame

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 10)
rightCorner.Parent = rightPanel

local targetStatusLabel = Instance.new("TextLabel")
targetStatusLabel.Name = "TargetStatusLabel"
targetStatusLabel.Size = UDim2.new(1, -20, 0, 30)
targetStatusLabel.Position = UDim2.new(0, 10, 0, 8)
targetStatusLabel.BackgroundTransparency = 1
targetStatusLabel.Font = Enum.Font.SourceSansBold
targetStatusLabel.Text = "Target: None Selected"
targetStatusLabel.TextColor3 = Color3.fromRGB(255, 190, 70)
targetStatusLabel.TextSize = 15
targetStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
targetStatusLabel.ZIndex = 12
targetStatusLabel.Parent = rightPanel

local typeHeader = Instance.new("TextLabel")
typeHeader.Size = UDim2.new(1, -20, 0, 22)
typeHeader.Position = UDim2.new(0, 10, 0, 38)
typeHeader.BackgroundTransparency = 1
typeHeader.Font = Enum.Font.SourceSansBold
typeHeader.Text = "SELECT JUMPSCARE MODE:"
typeHeader.TextColor3 = Color3.fromRGB(150, 155, 175)
typeHeader.TextSize = 13
typeHeader.TextXAlignment = Enum.TextXAlignment.Left
typeHeader.ZIndex = 12
typeHeader.Parent = rightPanel

-- Jumpscare Type Buttons Grid
local modesFrame = Instance.new("Frame")
modesFrame.Name = "ModesFrame"
modesFrame.Size = UDim2.new(1, -20, 0, 120)
modesFrame.Position = UDim2.new(0, 10, 0, 64)
modesFrame.BackgroundTransparency = 1
modesFrame.ZIndex = 12
modesFrame.Parent = rightPanel

local modesGrid = Instance.new("UIGridLayout")
modesGrid.CellSize = UDim2.new(0.48, 0, 0, 52)
modesGrid.CellPadding = UDim2.new(0.04, 0, 0.08, 0)
modesGrid.Parent = modesFrame

local jumpscareTypes = {
{ Name = "Classic Screamer", Icon = "😱" },
{ Name = "Spinning TP Ambush", Icon = "🌀" },
{ Name = "Void Screamer", Icon = "👁️" },
{ Name = "Dimension Strobe", Icon = "⚡" }
}

local typeButtons = {}

for _, jType in ipairs(jumpscareTypes) do
local btn = Instance.new("TextButton")
btn.Name = jType.Name
btn.BackgroundColor3 = (jType.Name == activeJumpscareType) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(32, 34, 48)
btn.Font = Enum.Font.SourceSansBold
btn.Text = jType.Icon .. " " .. jType.Name
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 13
btn.TextWrapped = true
btn.ZIndex = 13
btn.Parent = modesFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btn

typeButtons[jType.Name] = btn

btn.MouseButton1Click:Connect(function()
    activeJumpscareType = jType.Name
    for name, button in pairs(typeButtons) do
        if name == activeJumpscareType then
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(220, 38, 38) }):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(32, 34, 48) }):Play()
        end
    end
end)


end

-- STREAMING_CHUNK:Creating primary action buttons...
local executeButton = Instance.new("TextButton")
executeButton.Name = "ExecuteButton"
executeButton.Size = UDim2.new(1, -20, 0, 48)
executeButton.Position = UDim2.new(0, 10, 0, 196)
executeButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
executeButton.Font = Enum.Font.FredokaOne
executeButton.Text = "☠️ EXECUTE JUMPSCARE"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.TextSize = 17
executeButton.ZIndex = 12
executeButton.Parent = rightPanel

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 8)
execCorner.Parent = executeButton

local tpButton = Instance.new("TextButton")
tpButton.Name = "TpButton"
tpButton.Size = UDim2.new(0.48, 0, 0, 42)
tpButton.Position = UDim2.new(0, 10, 0, 252)
tpButton.BackgroundColor3 = Color3.fromRGB(35, 40, 58)
tpButton.Font = Enum.Font.SourceSansBold
tpButton.Text = "🌀 Teleport to Target"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextSize = 14
tpButton.ZIndex = 12
tpButton.Parent = rightPanel

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpButton

local spinButton = Instance.new("TextButton")
spinButton.Name = "SpinButton"
spinButton.Size = UDim2.new(0.48, 0, 0, 42)
spinButton.Position = UDim2.new(0.52, 0, 0, 252)
spinButton.BackgroundColor3 = Color3.fromRGB(35, 40, 58)
spinButton.Font = Enum.Font.SourceSansBold
spinButton.Text = "🔄 Spin Character"
spinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spinButton.TextSize = 14
spinButton.ZIndex = 12
spinButton.Parent = rightPanel

local spinCorner = Instance.new("UICorner")
spinCorner.CornerRadius = UDim.new(0, 8)
spinCorner.Parent = spinButton

-- STREAMING_CHUNK:Defining player list builder function...
local function updatePlayerList()
for _, child in ipairs(playerScroll:GetChildren()) do
if child:IsA("TextButton") then
child:Destroy()
end
end

local activePlayers = Players:GetPlayers()

-- If playing alone in Studio / test environment, add self for testing
if #activePlayers <= 1 then
    local pBtn = Instance.new("TextButton")
    pBtn.Name = "SelfTest"
    pBtn.Size = UDim2.new(1, -6, 0, 36)
    pBtn.BackgroundColor3 = (selectedTargetPlayer == localPlayer) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(32, 35, 50)
    pBtn.Font = Enum.Font.SourceSansBold
    pBtn.Text = " 👤 Test on Self (" .. localPlayer.DisplayName .. ")"
    pBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    pBtn.TextSize = 13
    pBtn.TextXAlignment = Enum.TextXAlignment.Left
    pBtn.ZIndex = 13
    pBtn.Parent = playerScroll

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = pBtn

    pBtn.MouseButton1Click:Connect(function()
        selectedTargetPlayer = localPlayer
        targetStatusLabel.Text = "Target: " .. localPlayer.DisplayName .. " (Self)"
        updatePlayerList()
    end)
else
    for _, player in ipairs(activePlayers) do
        if player ~= localPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Name = player.Name
            pBtn.Size = UDim2.new(1, -6, 0, 36)
            pBtn.BackgroundColor3 = (selectedTargetPlayer == player) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(32, 35, 50)
            pBtn.Font = Enum.Font.SourceSansBold
            pBtn.Text = " 👤 " .. player.DisplayName
            pBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
            pBtn.TextSize = 13
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.ZIndex = 13
            pBtn.Parent = playerScroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = pBtn

            pBtn.MouseButton1Click:Connect(function()
                selectedTargetPlayer = player
                targetStatusLabel.Text = "Target: " .. player.DisplayName
                updatePlayerList()
            end)
        end
    end
end

playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)


end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
if selectedTargetPlayer == player then
selectedTargetPlayer = nil
targetStatusLabel.Text = "Target: None Selected"
end
updatePlayerList()
end)

updatePlayerList()

-- STREAMING_CHUNK:Implementing character mechanics (Teleport & Spin)...
local function teleportToTarget(target)
if not target or not target.Character then return end
local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

if targetHrp and myHrp then
    if target == localPlayer then
        myHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -5)
    else
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.pi, 0)
    end
end


end

local function toggleSpinCharacter(speed)
speed = speed or 35
if isSpinning then
isSpinning = false
spinButton.Text = "🔄 Spin Character"
spinButton.BackgroundColor3 = Color3.fromRGB(35, 40, 58)
if spinConnection then
spinConnection:Disconnect()
spinConnection = nil
end
else
isSpinning = true
spinButton.Text = "🛑 Stop Spinning"
spinButton.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
spinConnection = RunService.RenderStepped:Connect(function()
local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
if myHrp then
myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
end
end)
end
end

-- STREAMING_CHUNK:Implementing jumpscare execution modes...
local function triggerJumpscareEffect(mode)
pcall(function()
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9069609268"
sound.Volume = 4
sound.Parent = SoundService
sound:Play()
task.delay(3, function() sound:Destroy() end)
end)

if mode == "Classic Screamer" then
    jumpscareOverlay.BackgroundTransparency = 0.1
    jumpscareImage.ImageTransparency = 0
    jumpscareImage.Size = UDim2.new(0.4, 0, 0.4, 0)
    
    local tweenZoom = TweenService:Create(jumpscareImage, TweenInfo.new(0.25, Enum.EasingStyle.Bounce), { Size = UDim2.new(1.1, 0, 1.1, 0) })
    tweenZoom:Play()
    
    task.wait(1.2)
    
    TweenService:Create(jumpscareOverlay, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(jumpscareImage, TweenInfo.new(0.4), { ImageTransparency = 1 }):Play()

elseif mode == "Spinning TP Ambush" then
    if selectedTargetPlayer then
        teleportToTarget(selectedTargetPlayer)
    end
    
    local tempSpin = RunService.RenderStepped:Connect(function()
        local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, math.rad(50), 0)
        end
    end)
    
    jumpscareOverlay.BackgroundTransparency = 0.3
    jumpscareImage.ImageTransparency = 0.2
    
    task.wait(1.5)
    tempSpin:Disconnect()
    jumpscareOverlay.BackgroundTransparency = 1
    jumpscareImage.ImageTransparency = 1

elseif mode == "Void Screamer" then
    for i = 1, 8 do
        jumpscareOverlay.BackgroundTransparency = (i % 2 == 0) and 0.1 or 0.8
        jumpscareOverlay.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(0, 0, 0)
        task.wait(0.08)
    end
    jumpscareOverlay.BackgroundTransparency = 1

elseif mode == "Dimension Strobe" then
    if selectedTargetPlayer then
        for i = 1, 5 do
            teleportToTarget(selectedTargetPlayer)
            local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                myHrp.CFrame = myHrp.CFrame * CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
            end
            jumpscareOverlay.BackgroundTransparency = 0.2
            task.wait(0.12)
            jumpscareOverlay.BackgroundTransparency = 1
            task.wait(0.12)
        end
    end
end


end

-- STREAMING_CHUNK:Connecting user events and completion logic...
executeButton.MouseButton1Click:Connect(function()
if not selectedTargetPlayer then
targetStatusLabel.Text = "⚠️ Select a target first!"
task.wait(1.2)
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
task.wait(1.2)
targetStatusLabel.Text = "Target: None Selected"
end
end)

spinButton.MouseButton1Click:Connect(function()
toggleSpinCharacter(40)
end)

closeButton.MouseButton1Click:Connect(function()
if spinConnection then
spinConnection:Disconnect()
end
screenGui:Destroy()
end)

print("✅ Nightmare OP GUI successfully displayed on screen!")
