--[[
========================================================================
WELCOME TO NIGHTMARE OP SCRIPT
========================================================================

-- STREAMING_CHUNK:Initializing Roblox services and state variables...
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- Script State Variables
local SelectedPlayer = nil
local ActiveJumpscare = "Classic Screamer"
local IsJumpscaring = false
local SpinSpeed = 50
local ScareDuration = 3.5
local GuiVisible = true

-- Utility function to get safe GUI parent
local function GetGuiParent()
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
if success and coreGui then
return coreGui
end
return LocalPlayer:WaitForChild("PlayerGui")
end

-- STREAMING_CHUNK:Creating main GUI container and screen hierarchy...
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightmareOpScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GetGuiParent()

-- STREAMING_CHUNK:Building intro animated splash screen...
local IntroFrame = Instance.new("Frame")
IntroFrame.Name = "IntroFrame"
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.Position = UDim2.new(0, 0, 0, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
IntroFrame.BackgroundTransparency = 0
IntroFrame.ZIndex = 100
IntroFrame.Parent = ScreenGui

local IntroTitle = Instance.new("TextLabel")
IntroTitle.Name = "IntroTitle"
IntroTitle.Size = UDim2.new(0, 600, 0, 80)
IntroTitle.Position = UDim2.new(0.5, -300, 0.4, -40)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Text = "WELCOME TO NIGHTMARE"
IntroTitle.TextColor3 = Color3.fromRGB(255, 20, 50)
IntroTitle.TextSize = 42
IntroTitle.Font = Enum.Font.FredokaOne
IntroTitle.TextTransparency = 1
IntroTitle.ZIndex = 101
IntroTitle.Parent = IntroFrame

local IntroSub = Instance.new("TextLabel")
IntroSub.Name = "IntroSub"
IntroSub.Size = UDim2.new(0, 500, 0, 30)
IntroSub.Position = UDim2.new(0.5, -250, 0.4, 45)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "OP Jumpscare Matrix & Quantum Teleport Initialized..."
IntroSub.TextColor3 = Color3.fromRGB(180, 180, 200)
IntroSub.TextSize = 16
IntroSub.Font = Enum.Font.SourceSansItalic
IntroSub.TextTransparency = 1
IntroSub.ZIndex = 101
IntroSub.Parent = IntroFrame

local IntroGlow = Instance.new("ImageLabel")
IntroGlow.Size = UDim2.new(0, 550, 0, 550)
IntroGlow.Position = UDim2.new(0.5, -275, 0.5, -275)
IntroGlow.BackgroundTransparency = 1
IntroGlow.Image = "rbxassetid://5028857084" -- Red Radial Glow
IntroGlow.ImageColor3 = Color3.fromRGB(255, 0, 40)
IntroGlow.ImageTransparency = 1
IntroGlow.ZIndex = 100
IntroGlow.Parent = IntroFrame

-- Intro Sound Effect
local IntroSound = Instance.new("Sound")
IntroSound.SoundId = "rbxassetid://9114223171" -- Ambient horror riser
IntroSound.Volume = 1
IntroSound.Parent = SoundService

-- STREAMING_CHUNK:Constructing toast notification banner for keybind alert...
local KeyToast = Instance.new("Frame")
KeyToast.Name = "KeyToast"
KeyToast.Size = UDim2.new(0, 320, 0, 45)
KeyToast.Position = UDim2.new(0.5, -160, 1, 20) -- Starts hidden off bottom
KeyToast.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
KeyToast.BorderSizePixel = 0
KeyToast.ZIndex = 90
KeyToast.Parent = ScreenGui

local ToastCorner = Instance.new("UICorner")
ToastCorner.CornerRadius = UDim.new(0, 8)
ToastCorner.Parent = KeyToast

local ToastStroke = Instance.new("UIStroke")
ToastStroke.Color = Color3.fromRGB(255, 30, 60)
ToastStroke.Thickness = 1.5
ToastStroke.Parent = KeyToast

local ToastIcon = Instance.new("TextLabel")
ToastIcon.Size = UDim2.new(0, 35, 1, 0)
ToastIcon.Position = UDim2.new(0, 8, 0, 0)
ToastIcon.BackgroundTransparency = 1
ToastIcon.Text = "⚠️"
ToastIcon.TextSize = 20
ToastIcon.Parent = KeyToast

local ToastText = Instance.new("TextLabel")
ToastText.Size = UDim2.new(1, -50, 1, 0)
ToastText.Position = UDim2.new(0, 42, 0, 0)
ToastText.BackgroundTransparency = 1
ToastText.Text = "Press [K] or [V] to Open Nightmare GUI"
ToastText.TextColor3 = Color3.fromRGB(255, 255, 255)
ToastText.Font = Enum.Font.GothamBold
ToastText.TextSize = 13
ToastText.TextXAlignment = Enum.TextXAlignment.Left
ToastText.Parent = KeyToast

local function ShowToastNotification()
KeyToast.Position = UDim2.new(0.5, -160, 1, 20)
TweenService:Create(KeyToast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
Position = UDim2.new(0.5, -160, 1, -65)
}):Play()

task.delay(3.5, function()
    TweenService:Create(KeyToast, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -160, 1, 20)
    }):Play()
end)


end

-- STREAMING_CHUNK:Constructing main script frame and header UI...
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 640, 0, 440)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(255, 30, 60)
MainUIStroke.Thickness = 2
MainUIStroke.Transparency = 0.2
MainUIStroke.Parent = MainFrame

-- Top Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 400, 1, 0)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "NIGHTMARE OP SCRIPT v4.0 [10 MODES]"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 50, 75)
HeaderTitle.TextSize = 18
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = Header

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 6)
MinBtnCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

-- Dragging Mechanics
local Dragging, DragInput, DragStart, StartPos
local function UpdateDrag(input)
local delta = input.Position - DragStart
MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
Dragging = true
DragStart = input.Position
StartPos = MainFrame.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            Dragging = false
        end
    end)
end


end)

Header.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
DragInput = input
end
end)

UserInputService.InputChanged:Connect(function(input)
if input == DragInput and Dragging then
UpdateDrag(input)
end
end)

-- STREAMING_CHUNK:Building tab navigation bar...
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 35)
TabContainer.Position = UDim2.new(0, 10, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabPlayersBtn = Instance.new("TextButton")
TabPlayersBtn.Size = UDim2.new(0.32, 0, 1, 0)
TabPlayersBtn.Position = UDim2.new(0, 0, 0, 0)
TabPlayersBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
TabPlayersBtn.Text = "👥 Player Scanner"
TabPlayersBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabPlayersBtn.Font = Enum.Font.GothamBold
TabPlayersBtn.TextSize = 13
TabPlayersBtn.Parent = TabContainer

local TabPlayersCorner = Instance.new("UICorner")
TabPlayersCorner.CornerRadius = UDim.new(0, 6)
TabPlayersCorner.Parent = TabPlayersBtn

local TabModesBtn = Instance.new("TextButton")
TabModesBtn.Size = UDim2.new(0.32, 0, 1, 0)
TabModesBtn.Position = UDim2.new(0.34, 0, 0, 0)
TabModesBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TabModesBtn.Text = "⚡ Nightmare Modes (10)"
TabModesBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
TabModesBtn.Font = Enum.Font.GothamBold
TabModesBtn.TextSize = 13
TabModesBtn.Parent = TabContainer

local TabModesCorner = Instance.new("UICorner")
TabModesCorner.CornerRadius = UDim.new(0, 6)
TabModesCorner.Parent = TabModesBtn

local TabSettingsBtn = Instance.new("TextButton")
TabSettingsBtn.Size = UDim2.new(0.32, 0, 1, 0)
TabSettingsBtn.Position = UDim2.new(0.68, 0, 0, 0)
TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TabSettingsBtn.Text = "⚙️ Tuning & Settings"
TabSettingsBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
TabSettingsBtn.Font = Enum.Font.GothamBold
TabSettingsBtn.TextSize = 13
TabSettingsBtn.Parent = TabContainer

local TabSettingsCorner = Instance.new("UICorner")
TabSettingsCorner.CornerRadius = UDim.new(0, 6)
TabSettingsCorner.Parent = TabSettingsBtn

-- Content Body Panels
local BodyContainer = Instance.new("Frame")
BodyContainer.Size = UDim2.new(1, -20, 0, 335)
BodyContainer.Position = UDim2.new(0, 10, 0, 95)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

-- STREAMING_CHUNK:Building player scanner and target selection list...
local PlayersPanel = Instance.new("Frame")
PlayersPanel.Size = UDim2.new(1, 0, 1, 0)
PlayersPanel.BackgroundTransparency = 1
PlayersPanel.Visible = true
PlayersPanel.Parent = BodyContainer

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.65, 0, 0, 35)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SearchBox.PlaceholderText = "🔍 Search player in server..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.Parent = PlayersPanel

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBox

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.33, 0, 0, 35)
RefreshBtn.Position = UDim2.new(0.67, 0, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
RefreshBtn.Text = "🔄 Refresh Scanner"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 13
RefreshBtn.Parent = PlayersPanel

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 0, 235)
PlayerScroll.Position = UDim2.new(0, 0, 0, 45)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 6
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
PlayerScroll.Parent = PlayersPanel

local PlayerScrollCorner = Instance.new("UICorner")
PlayerScrollCorner.CornerRadius = UDim.new(0, 6)
PlayerScrollCorner.Parent = PlayerScroll

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 6)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Parent = PlayerScroll

local ActionExecuteBtn = Instance.new("TextButton")
ActionExecuteBtn.Size = UDim2.new(1, 0, 0, 45)
ActionExecuteBtn.Position = UDim2.new(0, 0, 1, -45)
ActionExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 50)
ActionExecuteBtn.Text = "💀 EXECUTE NIGHTMARE JUMPSCARE ON TARGET 💀"
ActionExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionExecuteBtn.Font = Enum.Font.GothamBlack
ActionExecuteBtn.TextSize = 14
ActionExecuteBtn.Parent = PlayersPanel

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 8)
ActionCorner.Parent = ActionExecuteBtn

-- STREAMING_CHUNK:Building jumpscare modes grid view...
local ModesPanel = Instance.new("Frame")
ModesPanel.Size = UDim2.new(1, 0, 1, 0)
ModesPanel.BackgroundTransparency = 1
ModesPanel.Visible = false
ModesPanel.Parent = BodyContainer

local ModesScroll = Instance.new("ScrollingFrame")
ModesScroll.Size = UDim2.new(1, 0, 1, 0)
ModesScroll.BackgroundTransparency = 1
ModesScroll.BorderSizePixel = 0
ModesScroll.ScrollBarThickness = 6
ModesScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
ModesScroll.Parent = ModesPanel

local ModesGrid = Instance.new("UIGridLayout")
ModesGrid.CellSize = UDim2.new(0.48, 0, 0, 80)
ModesGrid.CellPadding = UDim2.new(0.04, 0, 0, 10)
ModesGrid.Parent = ModesScroll

local ModeList = {
{Name = "Classic Screamer", Desc = "Scary visual face, red screech & intense camera shake", Icon = "😱"},
{Name = "Orbit Spin Tornado", Desc = "Teleports & violently spins around target at high speed", Icon = "🌪️"},
{Name = "Void Abyss Drop", Desc = "Drops target high into darkness with fog plunge FX", Icon = "🌌"},
{Name = "Strobe Glitch Stalker", Desc = "Rapidly teleports in 8 cardinal points with strobe flash", Icon = "⚡"},
{Name = "Shadow Phantom", Desc = "Invisibility stalker with sudden jumpscare face zoom", Icon = "👻"},
{Name = "Giant Face Swallow", Desc = "Massive dynamic monster image expanding in view", Icon = "👹"},
{Name = "Demonic Possession", Desc = "Float towards target with black smoke trail & spinning", Icon = "🔥"},
{Name = "Black Hole Singularity", Desc = "[OP] Gravitational spiral vortex locking target in void", Icon = "🕳️"},
{Name = "Blood Moon Ambush", Desc = "[OP] Quad-cardinal flash teleport with red moon lighting", Icon = "🩸"},
{Name = "Dimension Glitch Warp", Desc = "[OP] Hyper-velocity 3D matrix warp jumping around target", Icon = "🌀"}
}

local ModeButtons = {}

for idx, modeData in ipairs(ModeList) do
local ModeCard = Instance.new("TextButton")
ModeCard.Name = modeData.Name
ModeCard.BackgroundColor3 = (modeData.Name == ActiveJumpscare) and Color3.fromRGB(150, 20, 40) or Color3.fromRGB(25, 25, 35)
ModeCard.Text = ""
ModeCard.Parent = ModesScroll

local ModeCardCorner = Instance.new("UICorner")
ModeCardCorner.CornerRadius = UDim.new(0, 8)
ModeCardCorner.Parent = ModeCard

local ModeCardStroke = Instance.new("UIStroke")
ModeCardStroke.Color = (modeData.Name == ActiveJumpscare) and Color3.fromRGB(255, 50, 80) or Color3.fromRGB(50, 50, 65)
ModeCardStroke.Thickness = 1.5
ModeCardStroke.Parent = ModeCard

local ModeTitle = Instance.new("TextLabel")
ModeTitle.Size = UDim2.new(1, -10, 0, 25)
ModeTitle.Position = UDim2.new(0, 10, 0, 6)
ModeTitle.BackgroundTransparency = 1
ModeTitle.Text = modeData.Icon .. " " .. modeData.Name
ModeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeTitle.Font = Enum.Font.GothamBold
ModeTitle.TextSize = 13
ModeTitle.TextXAlignment = Enum.TextXAlignment.Left
ModeTitle.Parent = ModeCard

local ModeDesc = Instance.new("TextLabel")
ModeDesc.Size = UDim2.new(1, -15, 0, 40)
ModeDesc.Position = UDim2.new(0, 10, 0, 30)
ModeDesc.BackgroundTransparency = 1
ModeDesc.Text = modeData.Desc
ModeDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
ModeDesc.Font = Enum.Font.SourceSans
ModeDesc.TextSize = 11
ModeDesc.TextWrapped = true
ModeDesc.TextXAlignment = Enum.TextXAlignment.Left
ModeDesc.Parent = ModeCard

ModeButtons[modeData.Name] = {Card = ModeCard, Stroke = ModeCardStroke}

ModeCard.MouseButton1Click:Connect(function()
    ActiveJumpscare = modeData.Name
    for name, btns in pairs(ModeButtons) do
        if name == ActiveJumpscare then
            btns.Card.BackgroundColor3 = Color3.fromRGB(150, 20, 40)
            btns.Stroke.Color = Color3.fromRGB(255, 50, 80)
        else
            btns.Card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btns.Stroke.Color = Color3.fromRGB(50, 50, 65)
        end
    end
end)


end

-- STREAMING_CHUNK:Building tuning sliders and settings control panel...
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(1, 0, 1, 0)
SettingsPanel.BackgroundTransparency = 1
SettingsPanel.Visible = false
SettingsPanel.Parent = BodyContainer

-- Spin Speed Option
local SpinLabel = Instance.new("TextLabel")
SpinLabel.Size = UDim2.new(1, 0, 0, 25)
SpinLabel.Position = UDim2.new(0, 0, 0, 10)
SpinLabel.BackgroundTransparency = 1
SpinLabel.Text = "🌀 Spin Velocity: " .. tostring(SpinSpeed) .. " RPM"
SpinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinLabel.Font = Enum.Font.GothamBold
SpinLabel.TextSize = 14
SpinLabel.TextXAlignment = Enum.TextXAlignment.Left
SpinLabel.Parent = SettingsPanel

local SpinSliderBG = Instance.new("Frame")
SpinSliderBG.Size = UDim2.new(1, 0, 0, 15)
SpinSliderBG.Position = UDim2.new(0, 0, 0, 40)
SpinSliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpinSliderBG.Parent = SettingsPanel

local SpinSliderBGCorner = Instance.new("UICorner")
SpinSliderBGCorner.CornerRadius = UDim.new(0, 6)
SpinSliderBGCorner.Parent = SpinSliderBG

local SpinFill = Instance.new("Frame")
SpinFill.Size = UDim2.new(SpinSpeed / 150, 0, 1, 0)
SpinFill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
SpinFill.Parent = SpinSliderBG

local SpinFillCorner = Instance.new("UICorner")
SpinFillCorner.CornerRadius = UDim.new(0, 6)
SpinFillCorner.Parent = SpinFill

local SpinBtn = Instance.new("TextButton")
SpinBtn.Size = UDim2.new(1, 0, 1, 0)
SpinBtn.BackgroundTransparency = 1
SpinBtn.Text = ""
SpinBtn.Parent = SpinSliderBG

SpinBtn.MouseButton1Down:Connect(function()
local moveConn
moveConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
local relX = math.clamp((input.Position.X - SpinSliderBG.AbsolutePosition.X) / SpinSliderBG.AbsoluteSize.X, 0.05, 1)
SpinSpeed = math.floor(relX * 150)
SpinFill.Size = UDim2.new(relX, 0, 1, 0)
SpinLabel.Text = "🌀 Spin Velocity: " .. tostring(SpinSpeed) .. " RPM"
end
end)
local releaseConn
releaseConn = UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
moveConn:Disconnect()
releaseConn:Disconnect()
end
end)
end)

-- Duration Option
local DurationLabel = Instance.new("TextLabel")
DurationLabel.Size = UDim2.new(1, 0, 0, 25)
DurationLabel.Position = UDim2.new(0, 0, 0, 75)
DurationLabel.BackgroundTransparency = 1
DurationLabel.Text = "⏱️ Jumpscare Duration: " .. string.format("%.1f", ScareDuration) .. " seconds"
DurationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DurationLabel.Font = Enum.Font.GothamBold
DurationLabel.TextSize = 14
DurationLabel.TextXAlignment = Enum.TextXAlignment.Left
DurationLabel.Parent = SettingsPanel

local DurationSliderBG = Instance.new("Frame")
DurationSliderBG.Size = UDim2.new(1, 0, 0, 15)
DurationSliderBG.Position = UDim2.new(0, 0, 0, 105)
DurationSliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
DurationSliderBG.Parent = SettingsPanel

local DurationSliderBGCorner = Instance.new("UICorner")
DurationSliderBGCorner.CornerRadius = UDim.new(0, 6)
DurationSliderBGCorner.Parent = DurationSliderBG

local DurationFill = Instance.new("Frame")
DurationFill.Size = UDim2.new(ScareDuration / 10, 0, 1, 0)
DurationFill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
DurationFill.Parent = DurationSliderBG

local DurationFillCorner = Instance.new("UICorner")
DurationFillCorner.CornerRadius = UDim.new(0, 6)
DurationFillCorner.Parent = DurationFill

local DurationBtn = Instance.new("TextButton")
DurationBtn.Size = UDim2.new(1, 0, 1, 0)
DurationBtn.BackgroundTransparency = 1
DurationBtn.Text = ""
DurationBtn.Parent = DurationSliderBG

DurationBtn.MouseButton1Down:Connect(function()
local moveConn
moveConn = UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
local relX = math.clamp((input.Position.X - DurationSliderBG.AbsolutePosition.X) / DurationSliderBG.AbsoluteSize.X, 0.1, 1)
ScareDuration = math.floor(relX * 10 * 10) / 10
DurationFill.Size = UDim2.new(relX, 0, 1, 0)
DurationLabel.Text = "⏱️ Jumpscare Duration: " .. string.format("%.1f", ScareDuration) .. " seconds"
end
end)
local releaseConn
releaseConn = UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
moveConn:Disconnect()
releaseConn:Disconnect()
end
end)
end)

-- Keybind Info Box
local KeybindInfo = Instance.new("TextLabel")
KeybindInfo.Size = UDim2.new(1, 0, 0, 70)
KeybindInfo.Position = UDim2.new(0, 0, 0, 150)
KeybindInfo.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
KeybindInfo.Text = "📌 Keybind Shortcuts:\nPress 'K', 'V', or 'Right Control' on your keyboard at any time to hide/re-open this menu instantly."
KeybindInfo.TextColor3 = Color3.fromRGB(200, 200, 220)
KeybindInfo.Font = Enum.Font.Gotham
KeybindInfo.TextSize = 13
KeybindInfo.TextWrapped = true
KeybindInfo.Parent = SettingsPanel

local KeybindInfoCorner = Instance.new("UICorner")
KeybindInfoCorner.CornerRadius = UDim.new(0, 8)
KeybindInfoCorner.Parent = KeybindInfo

-- Tab Switching Logic
local function SwitchTab(activePanel, activeBtn)
PlayersPanel.Visible = (activePanel == PlayersPanel)
ModesPanel.Visible = (activePanel == ModesPanel)
SettingsPanel.Visible = (activePanel == SettingsPanel)

TabPlayersBtn.BackgroundColor3 = (activeBtn == TabPlayersBtn) and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(30, 30, 42)
TabModesBtn.BackgroundColor3 = (activeBtn == TabModesBtn) and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(30, 30, 42)
TabSettingsBtn.BackgroundColor3 = (activeBtn == TabSettingsBtn) and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(30, 30, 42)


end

TabPlayersBtn.MouseButton1Click:Connect(function() SwitchTab(PlayersPanel, TabPlayersBtn) end)
TabModesBtn.MouseButton1Click:Connect(function() SwitchTab(ModesPanel, TabModesBtn) end)
TabSettingsBtn.MouseButton1Click:Connect(function() SwitchTab(SettingsPanel, TabSettingsBtn) end)

-- STREAMING_CHUNK:Implementing player scanner engine and thumbnail loader...
local function RefreshPlayerList()
for _, child in ipairs(PlayerScroll:GetChildren()) do
if child:IsA("Frame") then
child:Destroy()
end
end

local filterText = string.lower(SearchBox.Text)

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    if targetPlayer ~= LocalPlayer then
        if filterText == "" or string.find(string.lower(targetPlayer.DisplayName), filterText) or string.find(string.lower(targetPlayer.Name), filterText) then
            
            local Card = Instance.new("Frame")
            Card.Name = targetPlayer.Name
            Card.Size = UDim2.new(1, -10, 0, 50)
            Card.BackgroundColor3 = (SelectedPlayer == targetPlayer) and Color3.fromRGB(120, 20, 40) or Color3.fromRGB(28, 28, 38)
            Card.Parent = PlayerScroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 6)
            CardCorner.Parent = Card

            -- Avatar Headshot Icon
            local AvatarImage = Instance.new("ImageLabel")
            AvatarImage.Size = UDim2.new(0, 40, 0, 40)
            AvatarImage.Position = UDim2.new(0, 5, 0, 5)
            AvatarImage.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            AvatarImage.Parent = Card

            local AvatarCorner = Instance.new("UICorner")
            AvatarCorner.CornerRadius = UDim.new(1, 0)
            AvatarCorner.Parent = AvatarImage

            -- Fetch Roblox User Thumbnail
            task.spawn(function()
                local content, isLoaded = Players:GetUserThumbnailAsync(
                    targetPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
                if isLoaded then
                    AvatarImage.Image = content
                end
            end)

            -- Display Name & Username
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(0.6, 0, 0, 22)
            NameLabel.Position = UDim2.new(0, 52, 0, 5)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = targetPlayer.DisplayName
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextSize = 14
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = Card

            local UserLabel = Instance.new("TextLabel")
            UserLabel.Size = UDim2.new(0.6, 0, 0, 18)
            UserLabel.Position = UDim2.new(0, 52, 0, 26)
            UserLabel.BackgroundTransparency = 1
            UserLabel.Text = "@" .. targetPlayer.Name
            UserLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            UserLabel.Font = Enum.Font.SourceSans
            UserLabel.TextSize = 12
            UserLabel.TextXAlignment = Enum.TextXAlignment.Left
            UserLabel.Parent = Card

            -- Selection Overlay Button
            local SelectBtn = Instance.new("TextButton")
            SelectBtn.Size = UDim2.new(1, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.Text = ""
            SelectBtn.Parent = Card

            SelectBtn.MouseButton1Click:Connect(function()
                SelectedPlayer = targetPlayer
                RefreshPlayerList()
            end)
        end
    end
end

PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)


end

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
if SelectedPlayer == player then
SelectedPlayer = nil
end
RefreshPlayerList()
end)

-- STREAMING_CHUNK:Implementing screen jumpscare effects and visual triggers...
local function TriggerScreenScare(duration, imageId, soundId, customColor)
task.spawn(function()
local ScareFrame = Instance.new("Frame")
ScareFrame.Size = UDim2.new(1, 0, 1, 0)
ScareFrame.BackgroundColor3 = customColor or Color3.fromRGB(255, 0, 0)
ScareFrame.BackgroundTransparency = 0.2
ScareFrame.ZIndex = 200
ScareFrame.Parent = ScreenGui

    local ImageOverlay = Instance.new("ImageLabel")
    ImageOverlay.Size = UDim2.new(1, 0, 1, 0)
    ImageOverlay.BackgroundTransparency = 1
    ImageOverlay.Image = imageId or "rbxassetid://6322923052"
    ImageOverlay.ZIndex = 201
    ImageOverlay.Parent = ScareFrame

    local Audio = Instance.new("Sound")
    Audio.SoundId = soundId or "rbxassetid://9069609268"
    Audio.Volume = 3
    Audio.Parent = SoundService
    Audio:Play()

    local startTime = tick()

    while tick() - startTime < duration do
        local shakeX = math.random(-10, 10) / 10
        local shakeY = math.random(-10, 10) / 10
        ScareFrame.Position = UDim2.new(0, shakeX * 12, 0, shakeY * 12)
        ImageOverlay.ImageColor3 = (math.random(1, 2) == 1) and Color3.fromRGB(255, 255, 255) or (customColor or Color3.fromRGB(255, 0, 0))
        RunService.RenderStepped:Wait()
    end

    ScareFrame:Destroy()
    Audio:Destroy()
end)


end

-- STREAMING_CHUNK:Implementing 10 OP jumpscare and teleportation algorithms...
local function PerformJumpscare()
if IsJumpscaring then return end
if not SelectedPlayer or not SelectedPlayer.Character or not SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
ActionExecuteBtn.Text = "⚠️ SELECT A VALID PLAYER FIRST!"
task.wait(1.5)
ActionExecuteBtn.Text = "💀 EXECUTE NIGHTMARE JUMPSCARE ON TARGET 💀"
return
end

local LocalChar = LocalPlayer.Character
if not LocalChar or not LocalChar:FindFirstChild("HumanoidRootPart") then return end

local MyHRP = LocalChar.HumanoidRootPart
local TargetHRP = SelectedPlayer.Character.HumanoidRootPart

IsJumpscaring = true
ActionExecuteBtn.Text = "⚡ NIGHTMARE JUMPSCARE IN PROGRESS..."
ActionExecuteBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local originalPosition = MyHRP.CFrame

if ActiveJumpscare == "Classic Screamer" then
    MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)
    TriggerScreenScare(ScareDuration, "rbxassetid://6322923052", "rbxassetid://9069609268")
    task.wait(ScareDuration)

elseif ActiveJumpscare == "Orbit Spin Tornado" then
    TriggerScreenScare(ScareDuration, "rbxassetid://7186088210", "rbxassetid://9114223171")
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local dt = RunService.RenderStepped:Wait()
        elapsed = elapsed + dt
        local angle = elapsed * (SpinSpeed / 5)
        local offset = Vector3.new(math.cos(angle) * 5, math.sin(angle * 2) * 2, math.sin(angle) * 5)
        MyHRP.CFrame = CFrame.new(TargetHRP.Position + offset, TargetHRP.Position)
        MyHRP.Velocity = Vector3.new(0, 0, 0)
    end

elseif ActiveJumpscare == "Void Abyss Drop" then
    MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 80, 0)
    TriggerScreenScare(ScareDuration, "rbxassetid://6322923052", "rbxassetid://9069609268")
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local dt = RunService.RenderStepped:Wait()
        elapsed = elapsed + dt
        MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, math.max(2, 80 - (elapsed * 40)), -2) * CFrame.Angles(0, math.rad(180), 0)
    end

elseif ActiveJumpscare == "Strobe Glitch Stalker" then
    TriggerScreenScare(ScareDuration, "rbxassetid://7186088210", "rbxassetid://9069609268")
    local angles = {0, 45, 90, 135, 180, 225, 270, 315}
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local rad = math.rad(angles[math.random(1, #angles)])
        local offset = Vector3.new(math.cos(rad) * 4, 0, math.sin(rad) * 4)
        MyHRP.CFrame = CFrame.new(TargetHRP.Position + offset, TargetHRP.Position)
        task.wait(0.1)
        elapsed = elapsed + 0.1
    end

elseif ActiveJumpscare == "Shadow Phantom" then
    MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, 6)
    task.wait(0.8)
    MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.rad(180), 0)
    TriggerScreenScare(ScareDuration - 0.8, "rbxassetid://6322923052", "rbxassetid://9069609268")
    task.wait(ScareDuration - 0.8)

elseif ActiveJumpscare == "Giant Face Swallow" then
    MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0)
    TriggerScreenScare(ScareDuration, "rbxassetid://7186088210", "rbxassetid://9069609268")
    task.wait(ScareDuration)

elseif ActiveJumpscare == "Demonic Possession" then
    TriggerScreenScare(ScareDuration, "rbxassetid://6322923052", "rbxassetid://9114223171")
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local dt = RunService.RenderStepped:Wait()
        elapsed = elapsed + dt
        local rot = elapsed * (SpinSpeed / 2)
        MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 3, -3) * CFrame.Angles(0, math.rad(rot), 0)
    end

elseif ActiveJumpscare == "Black Hole Singularity" then
    -- OP Nightmare Mode 1: Spiral Gravitational Vortex Pull
    TriggerScreenScare(ScareDuration, "rbxassetid://7186088210", "rbxassetid://9114223171", Color3.fromRGB(80, 0, 120))
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local dt = RunService.RenderStepped:Wait()
        elapsed = elapsed + dt
        local radius = math.max(1, 10 - (elapsed * 2))
        local angle = elapsed * (SpinSpeed / 3)
        local offset = Vector3.new(math.cos(angle) * radius, math.sin(angle) * 3, math.sin(angle) * radius)
        MyHRP.CFrame = CFrame.new(TargetHRP.Position + offset, TargetHRP.Position)
    end

elseif ActiveJumpscare == "Blood Moon Ambush" then
    -- OP Nightmare Mode 2: Quad-Cardinal Lightning Flash Ambush
    TriggerScreenScare(ScareDuration, "rbxassetid://6322923052", "rbxassetid://9069609268", Color3.fromRGB(200, 0, 0))
    local dists = {Vector3.new(0, 0, -3), Vector3.new(3, 0, 0), Vector3.new(0, 0, 3), Vector3.new(-3, 0, 0)}
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local posOffset = dists[math.random(1, #dists)]
        MyHRP.CFrame = CFrame.new(TargetHRP.Position + posOffset, TargetHRP.Position)
        task.wait(0.12)
        elapsed = elapsed + 0.12
    end

elseif ActiveJumpscare == "Dimension Glitch Warp" then
    -- OP Nightmare Mode 3: Matrix 3D Multi-Axis Quantum Glitch Teleport
    TriggerScreenScare(ScareDuration, "rbxassetid://7186088210", "rbxassetid://9069609268", Color3.fromRGB(0, 255, 200))
    local elapsed = 0
    while elapsed < ScareDuration and TargetHRP and TargetHRP.Parent do
        local rx = math.random(-6, 6)
        local ry = math.random(-3, 6)
        local rz = math.random(-6, 6)
        MyHRP.CFrame = TargetHRP.CFrame * CFrame.new(rx, ry, rz) * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)
        task.wait(0.06)
        elapsed = elapsed + 0.06
    end
end

-- Return to original position
MyHRP.CFrame = originalPosition
IsJumpscaring = false
ActionExecuteBtn.Text = "💀 EXECUTE NIGHTMARE JUMPSCARE ON TARGET 💀"
ActionExecuteBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 50)


end

ActionExecuteBtn.MouseButton1Click:Connect(PerformJumpscare)

-- STREAMING_CHUNK:Configuring keybind listeners and toast notification logic...
local function ToggleGui(state)
if state ~= nil then
GuiVisible = state
else
GuiVisible = not GuiVisible
end

MainFrame.Visible = GuiVisible
if not GuiVisible then
    ShowToastNotification()
end


end

CloseBtn.MouseButton1Click:Connect(function()
ToggleGui(false)
end)

MinimizeBtn.MouseButton1Click:Connect(function()
ToggleGui(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.V or input.KeyCode == Enum.KeyCode.RightControl then
ToggleGui()
end
end)

-- STREAMING_CHUNK:Executing cinematic intro transition and sequence startup...
local function RunIntroAnimation()
IntroSound:Play()

-- Title Fade In
TweenService:Create(IntroTitle, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
    TextTransparency = 0,
    Position = UDim2.new(0.5, -300, 0.35, -40)
}):Play()

TweenService:Create(IntroSub, TweenInfo.new(1.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
    TextTransparency = 0,
    Position = UDim2.new(0.5, -250, 0.35, 45)
}):Play()

TweenService:Create(IntroGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
    ImageTransparency = 0.4
}):Play()

task.wait(2.2)

-- Collapse Intro Frame
TweenService:Create(IntroTitle, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
    TextTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0)
}):Play()

TweenService:Create(IntroSub, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    TextTransparency = 1
}):Play()

TweenService:Create(IntroFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    BackgroundTransparency = 1
}):Play()

task.wait(0.6)
IntroFrame:Destroy()

-- Display Main GUI with Scale Pop Animation
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 640, 0, 440),
    Position = UDim2.new(0.5, -320, 0.5, -220)
}):Play()

RefreshPlayerList()


end

task.spawn(RunIntroAnimation)
