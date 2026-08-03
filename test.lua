-- STREAMING_CHUNK:Initializing services and player references...
-- Place this script inside StarterPlayer -> StarterPlayerScripts (or StarterGui) as a LocalScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- STREAMING_CHUNK:Logging message to developer console...
print("----------------------------------------")
print("You just wasted your time!")
print("----------------------------------------")

-- STREAMING_CHUNK:Creating GUI container and main screen layout...
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimeWasterGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main overlay backdrop
local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.Position = UDim2.new(0, 0, 0, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
backdrop.BackgroundTransparency = 1 -- Will tween in
backdrop.Parent = screenGui

-- Main card container
local card = Instance.new("Frame")
card.Name = "MainCard"
card.Size = UDim2.new(0, 450, 0, 280)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 50) -- Starts slightly down for slide-up effect
card.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = backdrop

-- Corner rounding for card
local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent = card

-- UI Stroke border gradient
local cardStroke = Instance.new("UIStroke")
cardStroke.Thickness = 2
cardStroke.Color = Color3.fromRGB(255, 70, 85)
cardStroke.Transparency = 1
cardStroke.Parent = card

-- STREAMING_CHUNK:Creating text labels and interactive UI elements...
-- Main Title Text Label
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(1, -40, 0, 80)
messageLabel.Position = UDim2.new(0, 20, 0, 30)
messageLabel.BackgroundTransparency = 1
messageLabel.Font = Enum.Font.FredokaOne
messageLabel.Text = "" -- Filled via typewriter effect
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextSize = 28
messageLabel.TextWrapped = true
messageLabel.Parent = card

-- Wasted Time Counter Label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, -40, 0, 40)
timerLabel.Position = UDim2.new(0, 20, 0, 120)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.Text = "Time wasted so far: 0 seconds"
timerLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
timerLabel.TextSize = 18
timerLabel.TextTransparency = 1
timerLabel.Parent = card

-- Dismiss Button
local dismissButton = Instance.new("TextButton")
dismissButton.Name = "DismissButton"
dismissButton.Size = UDim2.new(0, 180, 0, 45)
dismissButton.AnchorPoint = Vector2.new(0.5, 1)
dismissButton.Position = UDim2.new(0.5, 0, 1, -25)
dismissButton.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
dismissButton.Font = Enum.Font.SourceSansBold
dismissButton.Text = "Acknowledge"
dismissButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dismissButton.TextSize = 20
dismissButton.BackgroundTransparency = 1
dismissButton.TextTransparency = 1
dismissButton.Parent = card

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = dismissButton

-- STREAMING_CHUNK:Defining animation and tweening functions...
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Fade in backdrop and slide card up
TweenService:Create(backdrop, tweenInfo, { BackgroundTransparency = 0.3 }):Play()
TweenService:Create(card, tweenInfo, {
Position = UDim2.new(0.5, 0, 0.5, 0),
BackgroundTransparency = 0
}):Play()
TweenService:Create(cardStroke, tweenInfo, { Transparency = 0 }):Play()

task.wait(0.4)

-- Typewriter effect function for message
local targetText = "You just wasted your time!"
local function typeWriteText(label, text, speed)
for i = 1, #text do
label.Text = string.sub(text, 1, i)
task.wait(speed or 0.05)
end
end

-- STREAMING_CHUNK:Executing typewriter animation and timer loop...
typeWriteText(messageLabel, targetText, 0.06)

-- Fade in timer and dismiss button
TweenService:Create(timerLabel, tweenInfo, { TextTransparency = 0 }):Play()
TweenService:Create(dismissButton, tweenInfo, { BackgroundTransparency = 0, TextTransparency = 0 }):Play()

-- Start seconds timer count
local secondsWasted = 0
task.spawn(function()
while screenGui and screenGui.Parent do
task.wait(1)
secondsWasted = secondsWasted + 1
if timerLabel and timerLabel.Parent then
timerLabel.Text = string.format("Time wasted so far: %d second%s", secondsWasted, secondsWasted == 1 and "" or "s")
end
end
end)

-- STREAMING_CHUNK:Handling button interactions and cleanup...
-- Hover animation for button
dismissButton.MouseEnter:Connect(function()
TweenService:Create(dismissButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(230, 50, 65) }):Play()
end)

dismissButton.MouseLeave:Connect(function()
TweenService:Create(dismissButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 70, 85) }):Play()
end)

-- Close screen on button click
dismissButton.MouseButton1Click:Connect(function()
print(string.format("Player acknowledged wasting %d seconds of their life.", secondsWasted))

-- Fade out animations
TweenService:Create(backdrop, tweenInfo, { BackgroundTransparency = 1 }):Play()
TweenService:Create(cardStroke, tweenInfo, { Transparency = 1 }):Play()
TweenService:Create(messageLabel, tweenInfo, { TextTransparency = 1 }):Play()
TweenService:Create(timerLabel, tweenInfo, { TextTransparency = 1 }):Play()
TweenService:Create(dismissButton, tweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

local closeTween = TweenService:Create(card, tweenInfo, { 
    Position = UDim2.new(0.5, 0, 0.5, 50),
    BackgroundTransparency = 1 
})
closeTween:Play()

closeTween.Completed:Connect(function()
    screenGui:Destroy()
end)


end)
