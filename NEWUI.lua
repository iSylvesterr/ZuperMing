local HttpService = game:GetService("HttpService")

local ConfigPath = "ZuperMing/Config/" 

if not isfolder("ZuperMing") then makefolder("ZuperMing") end
if not isfolder("ZuperMing/Config") then makefolder("ZuperMing/Config") end

ConfigData = {}
Elements = {} 
CURRENT_VERSION = nil

function SaveConfig(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(fileName, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    
    if isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        
        if success and type(result) == "table" then
            ConfigData = result
            
            if LoadConfigElements then
                LoadConfigElements()
            end
            return true
        end
    end
    return false
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        local targetValue = ConfigData[key]
        
        if element.Set then
            if targetValue ~= nil then
                element:Set(targetValue)
            else
                if element.Type == "Toggle" then
                    element:Set(false)
                elseif element.Type == "Slider" then
                    element:Set(element.Default or 0)
                elseif element.Type == "Dropdown" then
                    element:Set(element.Default or "")
                elseif element.Type == "Input" then
                    element:Set("")
                end
            end
        end
    end
end

local Icons = {
    player    = "rbxassetid://12120698352",
    web       = "rbxassetid://137601480983962",
    bag       = "rbxassetid://8601111810",
    shop      = "rbxassetid://4985385964",
    cart      = "rbxassetid://128874923961846",
    plug      = "rbxassetid://137601480983962",
    settings  = "rbxassetid://70386228443175",
    loop      = "rbxassetid://122032243989747",
    gps       = "rbxassetid://17824309485",
    compas    = "rbxassetid://125300760963399",
    gamepad   = "rbxassetid://84173963561612",
    boss      = "rbxassetid://13132186360",
    scroll    = "rbxassetid://114127804740858",
    menu      = "rbxassetid://6340513838",
    crosshair = "rbxassetid://12614416478",
    user      = "rbxassetid://108483430622128",
    stat      = "rbxassetid://12094445329",
    eyes      = "rbxassetid://14321059114",
    sword     = "rbxassetid://82472368671405",
    discord   = "rbxassetid://94434236999817",
    star      = "rbxassetid://107005941750079",
    skeleton  = "rbxassetid://17313330026",
    payment   = "rbxassetid://18747025078",
    scan      = "rbxassetid://109869955247116",
    alert     = "rbxassetid://73186275216515",
    question  = "rbxassetid://17510196486",
    idea      = "rbxassetid://16833255748",
    strom     = "rbxassetid://13321880293",
    water     = "rbxassetid://100076212630732",
    dcs       = "rbxassetid://15310731934",
    start     = "rbxassetid://108886429866687",
    next      = "rbxassetid://12662718374",
    rod       = "rbxassetid://103247953194129",
    fish      = "rbxassetid://97167558235554",
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y

    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end

    return UDim2.new(scaleX, 0, scaleY, 0)
end

local function MakeDraggable(topbarobject, object)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Position = pos })
            Tween:Play()
        end

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end)
    end

    local function CustomSize(object)
        local Dragging, DragInput, DragStart, StartSize

        local minSizeX, minSizeY
        local defSizeX, defSizeY

        if isMobile then
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 470, 270
        else
            minSizeX, minSizeY = 100, 100
            defSizeX, defSizeY = 640, 400
        end

        object.Size = UDim2.new(0, defSizeX, 0, defSizeY)

        local changesizeobject = Instance.new("Frame")
        changesizeobject.AnchorPoint = Vector2.new(1, 1)
        changesizeobject.BackgroundTransparency = 1
        changesizeobject.Size = UDim2.new(0, 40, 0, 40)
        changesizeobject.Position = UDim2.new(1, 20, 1, 20)
        changesizeobject.Name = "changesizeobject"
        changesizeobject.Parent = object

        local function UpdateSize(input)
            local Delta = input.Position - DragStart
            local newWidth = StartSize.X.Offset + Delta.X
            local newHeight = StartSize.Y.Offset + Delta.Y

            if newWidth < minSizeX then newWidth = minSizeX end
            if newHeight < minSizeY then newHeight = minSizeY end

            local siz = UDim2.new(0, newWidth, 0, newHeight)
            local Tween = TweenService:Create(object, TweenInfo.new(0.2), { Size = siz })
            Tween:Play()
        end

        changesizeobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartSize = object.Size
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        changesizeobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdateSize(input)
            end
        end)
    end

    CustomPos(topbarobject, object)
    CustomSize(object)
end

local ZuperMing = {}

function ZuperMing:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Name = GuiConfig.Name or "ZuperMing"
    GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(120, 160, 255)
    GuiConfig.Logo = GuiConfig.Logo or "rbxassetid://18838620006"
    GuiConfig.Version = GuiConfig.Version or "1.0"
    CURRENT_VERSION = GuiConfig.Version

    local ZuperMingZuperMing = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local TopBar = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel")
    local UIGradient = Instance.new("UIGradient")
    local LeftMenu = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local UIPadding = Instance.new("UIPadding")
    local RightDisplay = Instance.new("Frame")
    local UICorner_3 = Instance.new("UICorner")
    local UIStroke_2 = Instance.new("UIStroke")
    local BackgroundImageLabel = Instance.new("ImageLabel")
    local DimOverlay = Instance.new("Frame")
    
    -- MINIMIZE ICON (Initially hidden)
    local MinimizeIcon = Instance.new("ImageButton")
    local MinimizeIconCorner = Instance.new("UICorner")
    local MinimizeIconStroke = Instance.new("UIStroke")

    ZuperMingZuperMing.Name = "ZuperMing"
    ZuperMingZuperMing.Parent = CoreGui
    ZuperMingZuperMing.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ZuperMingZuperMing.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ZuperMingZuperMing
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.ClipsDescendants = true

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    UIStroke.Color = Color3.fromRGB(60, 60, 70)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.5
    UIStroke.Parent = Main

    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.ZIndex = 10

    UICorner_2.CornerRadius = UDim.new(0, 12)
    UICorner_2.Parent = TopBar

    -- IMPROVED: Title position moved to center to avoid Mac buttons overlap
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.5, 0, 0.5, -5)
    Title.Size = UDim2.new(0, 300, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = GuiConfig.Name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.ZIndex = 11

    Subtitle.Name = "Subtitle"
    Subtitle.Parent = TopBar
    Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.5, 0, 0.5, 10)
    Subtitle.Size = UDim2.new(0, 300, 0, 15)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "v" .. GuiConfig.Version
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    Subtitle.TextSize = 11
    Subtitle.ZIndex = 11

    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    UIGradient.Rotation = 90
    UIGradient.Parent = TopBar

    -- Mac OS Style Buttons (kept in position but won't overlap title now)
    local MacButtons = Instance.new("Frame")
    MacButtons.Name = "MacButtons"
    MacButtons.Parent = TopBar
    MacButtons.BackgroundTransparency = 1
    MacButtons.Position = UDim2.new(0, 12, 0.5, -6)
    MacButtons.Size = UDim2.new(0, 60, 0, 12)
    MacButtons.ZIndex = 12

    local function createMacButton(color, position, callback)
        local button = Instance.new("TextButton")
        button.Parent = MacButtons
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Position = UDim2.new(0, position, 0, 0)
        button.Size = UDim2.new(0, 12, 0, 12)
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 13
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 0.5
        stroke.Transparency = 0.3
        stroke.Parent = button
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 20, 255),
                math.min(color.G * 255 + 20, 255),
                math.min(color.B * 255 + 20, 255)
            )}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        if callback then
            button.Activated:Connect(callback)
        end
        
        return button
    end

    -- Close Button (Red)
    createMacButton(Color3.fromRGB(255, 95, 86), 0, function()
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        wait(0.3)
        ZuperMingZuperMing:Destroy()
    end)

    -- IMPROVED: Minimize Button with Icon Toggle
    local isMinimized = false
    createMacButton(Color3.fromRGB(255, 189, 46), 24, function()
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Minimize: Hide window, show icon
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 1.2, 0)
            }):Play()
            
            wait(0.3)
            Main.Visible = false
            MinimizeIcon.Visible = true
            
            TweenService:Create(MinimizeIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 60, 0, 60),
                Position = UDim2.new(0, 20, 1, -80)
            }):Play()
        else
            -- Maximize: Show window, hide icon
            TweenService:Create(MinimizeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            wait(0.2)
            MinimizeIcon.Visible = false
            Main.Visible = true
            
            local targetSize = UDim2.new(0, 640, 0, 400)
            if isMobile then
                targetSize = UDim2.new(0, 470, 0, 270)
            end
            
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize,
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end
    end)

    -- Maximize Button (Green)
    createMacButton(Color3.fromRGB(40, 201, 64), 48, function()
        -- Toggle fullscreen or reset size
    end)

    -- MINIMIZE ICON SETUP
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ZuperMingZuperMing
    MinimizeIcon.AnchorPoint = Vector2.new(0, 1)
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0, 20, 1, -80)
    MinimizeIcon.Size = UDim2.new(0, 0, 0, 0)
    MinimizeIcon.Image = GuiConfig.Logo
    MinimizeIcon.ImageTransparency = 0
    MinimizeIcon.ScaleType = Enum.ScaleType.Fit
    MinimizeIcon.Visible = false
    MinimizeIcon.ZIndex = 100

    MinimizeIconCorner.CornerRadius = UDim.new(0, 12)
    MinimizeIconCorner.Parent = MinimizeIcon

    MinimizeIconStroke.Color = GuiConfig.Color
    MinimizeIconStroke.Thickness = 2
    MinimizeIconStroke.Transparency = 0
    MinimizeIconStroke.Parent = MinimizeIcon

    -- Click minimize icon to restore window
    MinimizeIcon.Activated:Connect(function()
        isMinimized = false
        
        TweenService:Create(MinimizeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        wait(0.2)
        MinimizeIcon.Visible = false
        Main.Visible = true
        
        local targetSize = UDim2.new(0, 640, 0, 400)
        if isMobile then
            targetSize = UDim2.new(0, 470, 0, 270)
        end
        
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = targetSize,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    end)

    -- Hover effect for minimize icon
    MinimizeIcon.MouseEnter:Connect(function()
        TweenService:Create(MinimizeIcon, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 70, 0, 70)
        }):Play()
        TweenService:Create(MinimizeIconStroke, TweenInfo.new(0.2), {
            Thickness = 3
        }):Play()
    end)

    MinimizeIcon.MouseLeave:Connect(function()
        TweenService:Create(MinimizeIcon, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
        TweenService:Create(MinimizeIconStroke, TweenInfo.new(0.2), {
            Thickness = 2
        }):Play()
    end)

    LeftMenu.Name = "LeftMenu"
    LeftMenu.Parent = Main
    LeftMenu.Active = true
    LeftMenu.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    LeftMenu.BorderSizePixel = 0
    LeftMenu.Position = UDim2.new(0, 0, 0, 45)
    LeftMenu.Size = UDim2.new(0, 160, 1, -45)
    LeftMenu.CanvasSize = UDim2.new(0, 0, 0, 0)
    LeftMenu.ScrollBarThickness = 4
    LeftMenu.ScrollBarImageColor3 = GuiConfig.Color
    LeftMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIListLayout.Parent = LeftMenu
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    UIPadding.Parent = LeftMenu
    UIPadding.PaddingTop = UDim.new(0, 8)
    UIPadding.PaddingBottom = UDim.new(0, 8)
    UIPadding.PaddingLeft = UDim.new(0, 8)
    UIPadding.PaddingRight = UDim.new(0, 8)

    RightDisplay.Name = "RightDisplay"
    RightDisplay.Parent = Main
    RightDisplay.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    RightDisplay.BorderSizePixel = 0
    RightDisplay.Position = UDim2.new(0, 160, 0, 45)
    RightDisplay.Size = UDim2.new(1, -160, 1, -45)
    RightDisplay.ClipsDescendants = true

    UICorner_3.CornerRadius = UDim.new(0, 8)
    UICorner_3.Parent = RightDisplay

    UIStroke_2.Color = Color3.fromRGB(40, 40, 50)
    UIStroke_2.Thickness = 1
    UIStroke_2.Transparency = 0.7
    UIStroke_2.Parent = RightDisplay

    -- IMPROVED: Background Image with better dimming
    BackgroundImageLabel.Name = "BackgroundImage"
    BackgroundImageLabel.Parent = RightDisplay
    BackgroundImageLabel.BackgroundTransparency = 1
    BackgroundImageLabel.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImageLabel.Image = GuiConfig.Logo
    BackgroundImageLabel.ImageTransparency = 0.15  -- More transparent
    BackgroundImageLabel.ScaleType = Enum.ScaleType.Fit
    BackgroundImageLabel.ZIndex = 1

    -- IMPROVED: Dim overlay to make features visible
    DimOverlay.Name = "DimOverlay"
    DimOverlay.Parent = RightDisplay
    DimOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    DimOverlay.BackgroundTransparency = 0.3  -- 70% dark overlay
    DimOverlay.BorderSizePixel = 0
    DimOverlay.Size = UDim2.new(1, 0, 1, 0)
    DimOverlay.ZIndex = 2

    -- Blur effect for better readability
    local BlurEffect = Instance.new("ImageLabel")
    BlurEffect.Name = "BlurEffect"
    BlurEffect.Parent = RightDisplay
    BlurEffect.BackgroundTransparency = 1
    BlurEffect.Size = UDim2.new(1, 0, 1, 0)
    BlurEffect.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    BlurEffect.ImageTransparency = 0.85
    BlurEffect.ZIndex = 2

    MakeDraggable(TopBar, Main)

    local Tabs = {}
    local CountTab = 0

    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or Icons.menu

        local Tab = Instance.new("TextButton")
        local TabIcon = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabCorner = Instance.new("UICorner")
        local TabStroke = Instance.new("UIStroke")
        local SelectedIndicator = Instance.new("Frame")
        local IndicatorCorner = Instance.new("UICorner")

        Tab.Name = "Tab_" .. TabConfig.Name
        Tab.Parent = LeftMenu
        Tab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        Tab.BackgroundTransparency = 0.95
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, 0, 0, 40)
        Tab.AutoButtonColor = false
        Tab.Text = ""
        Tab.LayoutOrder = CountTab

        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = Tab

        TabStroke.Color = Color3.fromRGB(60, 60, 70)
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.8
        TabStroke.Parent = Tab

        TabIcon.Name = "TabIcon"
        TabIcon.Parent = Tab
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 10, 0.5, 0)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Image = TabConfig.Icon
        TabIcon.ImageColor3 = Color3.fromRGB(180, 180, 190)

        TabText.Name = "TabText"
        TabText.Parent = Tab
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0, 38, 0, 0)
        TabText.Size = UDim2.new(1, -38, 1, 0)
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = TabConfig.Name
        TabText.TextColor3 = Color3.fromRGB(180, 180, 190)
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left

        SelectedIndicator.Name = "SelectedIndicator"
        SelectedIndicator.Parent = Tab
        SelectedIndicator.AnchorPoint = Vector2.new(0, 0.5)
        SelectedIndicator.BackgroundColor3 = GuiConfig.Color
        SelectedIndicator.BorderSizePixel = 0
        SelectedIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        SelectedIndicator.Size = UDim2.new(0, 0, 0, 20)

        IndicatorCorner.CornerRadius = UDim.new(0, 4)
        IndicatorCorner.Parent = SelectedIndicator

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent_" .. TabConfig.Name
        TabContent.Parent = RightDisplay
        TabContent.Active = true
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = GuiConfig.Color
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Visible = false
        TabContent.ZIndex = 3

        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Parent = TabContent
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Padding = UDim.new(0, 8)

        local TabContentPadding = Instance.new("UIPadding")
        TabContentPadding.Parent = TabContent
        TabContentPadding.PaddingTop = UDim.new(0, 12)
        TabContentPadding.PaddingBottom = UDim.new(0, 12)
        TabContentPadding.PaddingLeft = UDim.new(0, 12)
        TabContentPadding.PaddingRight = UDim.new(0, 12)

        local function SelectTab()
            for _, v in pairs(LeftMenu:GetChildren()) do
                if v:IsA("TextButton") and v.Name:match("^Tab_") then
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
                    TweenService:Create(v.TabIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(180, 180, 190)}):Play()
                    TweenService:Create(v.TabText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
                    TweenService:Create(v.UIStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
                    TweenService:Create(v.SelectedIndicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 20)}):Play()
                end
            end

            for _, v in pairs(RightDisplay:GetChildren()) do
                if v:IsA("ScrollingFrame") and v.Name:match("^TabContent_") then
                    v.Visible = false
                end
            end

            TweenService:Create(Tab, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = GuiConfig.Color}):Play()
            TweenService:Create(TabText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(TabStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
            TweenService:Create(SelectedIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 3, 0, 20)}):Play()
            
            TabContent.Visible = true
        end

        Tab.Activated:Connect(SelectTab)

        if CountTab == 0 then
            SelectTab()
        end

        Tab.MouseEnter:Connect(function()
            if TabContent.Visible == false then
                TweenService:Create(Tab, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
            end
        end)

        Tab.MouseLeave:Connect(function()
            if TabContent.Visible == false then
                TweenService:Create(Tab, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
            end
        end)

        local Sections = {}
        local CountSection = 0

        function Sections:AddSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            SectionConfig.Name = SectionConfig.Name or "Section"

            local Section = Instance.new("Frame")
            local SectionCorner = Instance.new("UICorner")
            local SectionStroke = Instance.new("UIStroke")
            local SectionHeader = Instance.new("Frame")
            local SectionHeaderCorner = Instance.new("UICorner")
            local SectionTitle = Instance.new("TextLabel")
            local SectionAdd = Instance.new("Frame")
            local SectionLayout = Instance.new("UIListLayout")
            local SectionPadding = Instance.new("UIPadding")

            Section.Name = "Section_" .. SectionConfig.Name
            Section.Parent = TabContent
            Section.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
            Section.BackgroundTransparency = 0.3
            Section.BorderSizePixel = 0
            Section.Size = UDim2.new(1, 0, 0, 0)
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.LayoutOrder = CountSection

            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = Section

            SectionStroke.Color = Color3.fromRGB(50, 50, 60)
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.6
            SectionStroke.Parent = Section

            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            SectionHeader.BackgroundTransparency = 0.5
            SectionHeader.BorderSizePixel = 0
            SectionHeader.Size = UDim2.new(1, 0, 0, 35)

            SectionHeaderCorner.CornerRadius = UDim.new(0, 8)
            SectionHeaderCorner.Parent = SectionHeader

            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 12, 0, 0)
            SectionTitle.Size = UDim2.new(1, -24, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = SectionConfig.Name
            SectionTitle.TextColor3 = GuiConfig.Color
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.Position = UDim2.new(0, 0, 0, 35)
            SectionAdd.Size = UDim2.new(1, 0, 0, 0)
            SectionAdd.AutomaticSize = Enum.AutomaticSize.Y

            SectionLayout.Parent = SectionAdd
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 6)

            SectionPadding.Parent = SectionAdd
            SectionPadding.PaddingTop = UDim.new(0, 8)
            SectionPadding.PaddingBottom = UDim.new(0, 8)
            SectionPadding.PaddingLeft = UDim.new(0, 12)
            SectionPadding.PaddingRight = UDim.new(0, 12)

            local Items = {}
            local CountItem = 0

            function Items:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Text = LabelConfig.Text or "Label"

                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Parent = SectionAdd
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Font = Enum.Font.Gotham
                Label.Text = LabelConfig.Text
                Label.TextColor3 = Color3.fromRGB(200, 200, 210)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.AutomaticSize = Enum.AutomaticSize.Y
                Label.LayoutOrder = CountItem

                CountItem = CountItem + 1
                return Label
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end

                local ButtonFrame = Instance.new("Frame")
                local ButtonCorner = Instance.new("UICorner")
                local Button = Instance.new("TextButton")
                local ButtonText = Instance.new("TextLabel")

                ButtonFrame.Name = "ButtonFrame"
                ButtonFrame.Parent = SectionAdd
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                ButtonFrame.BackgroundTransparency = 0.5
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
                ButtonFrame.LayoutOrder = CountItem

                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = ButtonFrame

                Button.Name = "Button"
                Button.Parent = ButtonFrame
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Font = Enum.Font.GothamBold
                Button.Text = ""
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 14
                Button.AutoButtonColor = false

                ButtonText.Name = "ButtonText"
                ButtonText.Parent = Button
                ButtonText.AnchorPoint = Vector2.new(0.5, 0.5)
                ButtonText.BackgroundTransparency = 1
                ButtonText.Position = UDim2.new(0.5, 0, 0.5, 0)
                ButtonText.Size = UDim2.new(1, -20, 1, 0)
                ButtonText.Font = Enum.Font.GothamBold
                ButtonText.Text = ButtonConfig.Name
                ButtonText.TextColor3 = Color3.fromRGB(230, 230, 240)
                ButtonText.TextSize = 14

                Button.Activated:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = GuiConfig.Color}):Play()
                    TweenService:Create(ButtonText, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    
                    wait(0.15)
                    
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
                    TweenService:Create(ButtonText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 240)}):Play()
                    
                    ButtonConfig.Callback()
                end)

                Button.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
                end)

                Button.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end)

                CountItem = CountItem + 1
                return Button
            end

            function Items:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local configKey = (TabConfig.Name or "Tab") .. "_" .. (SectionConfig.Name or "Section") .. "_Toggle_" .. ToggleConfig.Name

                local ToggleFrame = Instance.new("Frame")
                local ToggleCorner = Instance.new("UICorner")
                local ToggleButton = Instance.new("TextButton")
                local ToggleText = Instance.new("TextLabel")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchCorner = Instance.new("UICorner")
                local ToggleCircle = Instance.new("Frame")
                local ToggleCircleCorner = Instance.new("UICorner")

                ToggleFrame.Name = "ToggleFrame"
                ToggleFrame.Parent = SectionAdd
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                ToggleFrame.BackgroundTransparency = 0.7
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
                ToggleFrame.LayoutOrder = CountItem

                ToggleCorner.CornerRadius = UDim.new(0, 6)
                ToggleCorner.Parent = ToggleFrame

                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleFrame
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Text = ""
                ToggleButton.AutoButtonColor = false

                ToggleText.Name = "ToggleText"
                ToggleText.Parent = ToggleButton
                ToggleText.BackgroundTransparency = 1
                ToggleText.Position = UDim2.new(0, 12, 0, 0)
                ToggleText.Size = UDim2.new(1, -80, 1, 0)
                ToggleText.Font = Enum.Font.GothamMedium
                ToggleText.Text = ToggleConfig.Name
                ToggleText.TextColor3 = Color3.fromRGB(220, 220, 230)
                ToggleText.TextSize = 13
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left

                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleButton
                ToggleSwitch.AnchorPoint = Vector2.new(1, 0.5)
                ToggleSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                ToggleSwitch.BorderSizePixel = 0
                ToggleSwitch.Position = UDim2.new(1, -10, 0.5, 0)
                ToggleSwitch.Size = UDim2.new(0, 45, 0, 22)

                ToggleSwitchCorner.CornerRadius = UDim.new(1, 0)
                ToggleSwitchCorner.Parent = ToggleSwitch

                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = ToggleSwitch
                ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Position = UDim2.new(0, 3, 0.5, 0)
                ToggleCircle.Size = UDim2.new(0, 16, 0, 16)

                ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCircleCorner.Parent = ToggleCircle

                local ToggleFunc = {
                    Value = ToggleConfig.Default,
                    Type = "Toggle"
                }

                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value

                    if Value then
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = GuiConfig.Color}):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Position = UDim2.new(1, -19, 0.5, 0),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        }):Play()
                    else
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Position = UDim2.new(0, 3, 0.5, 0),
                            BackgroundColor3 = Color3.fromRGB(200, 200, 210)
                        }):Play()
                    end

                    ToggleConfig.Callback(Value)
                end

                ToggleButton.Activated:Connect(function()
                    ToggleFunc:Set(not ToggleFunc.Value)
                end)

                ToggleButton.MouseEnter:Connect(function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end)

                ToggleButton.MouseLeave:Connect(function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                end)

                ToggleFunc:Set(ToggleFunc.Value)

                CountItem = CountItem + 1
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local configKey = (TabConfig.Name or "Tab") .. "_" .. (SectionConfig.Name or "Section") .. "_Slider_" .. SliderConfig.Name

                local SliderFrame = Instance.new("Frame")
                local SliderCorner = Instance.new("UICorner")
                local SliderTitle = Instance.new("TextLabel")
                local SliderValue = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local SliderBarCorner = Instance.new("UICorner")
                local SliderFill = Instance.new("Frame")
                local SliderFillCorner = Instance.new("UICorner")
                local SliderButton = Instance.new("TextButton")

                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = SectionAdd
                SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                SliderFrame.BackgroundTransparency = 0.7
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.LayoutOrder = CountItem

                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = SliderFrame

                SliderTitle.Name = "SliderTitle"
                SliderTitle.Parent = SliderFrame
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Position = UDim2.new(0, 12, 0, 8)
                SliderTitle.Size = UDim2.new(1, -100, 0, 16)
                SliderTitle.Font = Enum.Font.GothamMedium
                SliderTitle.Text = SliderConfig.Name
                SliderTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
                SliderTitle.TextSize = 13
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderFrame
                SliderValue.AnchorPoint = Vector2.new(1, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(1, -12, 0, 8)
                SliderValue.Size = UDim2.new(0, 60, 0, 16)
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(SliderConfig.Default)
                SliderValue.TextColor3 = GuiConfig.Color
                SliderValue.TextSize = 13
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right

                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderFrame
                SliderBar.AnchorPoint = Vector2.new(0, 1)
                SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0, 12, 1, -10)
                SliderBar.Size = UDim2.new(1, -24, 0, 6)

                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Parent = SliderBar

                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar
                SliderFill.BackgroundColor3 = GuiConfig.Color
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new(0, 0, 1, 0)

                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill

                SliderButton.Name = "SliderButton"
                SliderButton.Parent = SliderBar
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 1, 10)
                SliderButton.Text = ""
                SliderButton.AutoButtonColor = false

                local SliderFunc = {
                    Value = SliderConfig.Default,
                    Default = SliderConfig.Default,
                    Type = "Slider"
                }

                local function UpdateSlider(value)
                    value = math.clamp(value, SliderConfig.Min, SliderConfig.Max)
                    value = math.floor(value / SliderConfig.Increment + 0.5) * SliderConfig.Increment
                    
                    SliderFunc.Value = value
                    ConfigData[configKey] = value

                    local percent = (value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    TweenService:Create(SliderFill, TweenInfo.new(0.15), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    
                    SliderValue.Text = tostring(value)
                    SliderConfig.Callback(value)
                end

                function SliderFunc:Set(value)
                    UpdateSlider(value)
                end

                function SliderFunc:GetValue()
                    return SliderFunc.Value
                end

                local dragging = false

                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)

                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mousePos = input.Position.X
                        local barPos = SliderBar.AbsolutePosition.X
                        local barSize = SliderBar.AbsoluteSize.X
                        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                        local value = SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * percent
                        UpdateSlider(value)
                    end
                end)

                SliderFrame.MouseEnter:Connect(function()
                    TweenService:Create(SliderFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end)

                SliderFrame.MouseLeave:Connect(function()
                    TweenService:Create(SliderFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                end)

                UpdateSlider(SliderFunc.Value)

                CountItem = CountItem + 1
                Elements[configKey] = SliderFunc
                return SliderFunc
            end

            function Items:AddInput(InputConfig)
                InputConfig = InputConfig or {}
                InputConfig.Name = InputConfig.Name or "Input"
                InputConfig.Placeholder = InputConfig.Placeholder or "Enter text..."
                InputConfig.Default = InputConfig.Default or ""
                InputConfig.Callback = InputConfig.Callback or function() end

                local configKey = (TabConfig.Name or "Tab") .. "_" .. (SectionConfig.Name or "Section") .. "_Input_" .. InputConfig.Name

                local InputFrame = Instance.new("Frame")
                local InputCorner = Instance.new("UICorner")
                local InputTitle = Instance.new("TextLabel")
                local InputBox = Instance.new("TextBox")
                local InputBoxCorner = Instance.new("UICorner")
                local InputBoxStroke = Instance.new("UIStroke")

                InputFrame.Name = "InputFrame"
                InputFrame.Parent = SectionAdd
                InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                InputFrame.BackgroundTransparency = 0.7
                InputFrame.BorderSizePixel = 0
                InputFrame.Size = UDim2.new(1, 0, 0, 60)
                InputFrame.LayoutOrder = CountItem

                InputCorner.CornerRadius = UDim.new(0, 6)
                InputCorner.Parent = InputFrame

                InputTitle.Name = "InputTitle"
                InputTitle.Parent = InputFrame
                InputTitle.BackgroundTransparency = 1
                InputTitle.Position = UDim2.new(0, 12, 0, 8)
                InputTitle.Size = UDim2.new(1, -24, 0, 16)
                InputTitle.Font = Enum.Font.GothamMedium
                InputTitle.Text = InputConfig.Name
                InputTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
                InputTitle.TextSize = 13
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left

                InputBox.Name = "InputBox"
                InputBox.Parent = InputFrame
                InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                InputBox.BorderSizePixel = 0
                InputBox.Position = UDim2.new(0, 12, 0, 30)
                InputBox.Size = UDim2.new(1, -24, 0, 22)
                InputBox.Font = Enum.Font.Gotham
                InputBox.PlaceholderText = InputConfig.Placeholder
                InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
                InputBox.Text = InputConfig.Default
                InputBox.TextColor3 = Color3.fromRGB(230, 230, 240)
                InputBox.TextSize = 12
                InputBox.TextXAlignment = Enum.TextXAlignment.Left
                InputBox.ClearTextOnFocus = false

                InputBoxCorner.CornerRadius = UDim.new(0, 4)
                InputBoxCorner.Parent = InputBox

                InputBoxStroke.Color = Color3.fromRGB(50, 50, 60)
                InputBoxStroke.Thickness = 1
                InputBoxStroke.Transparency = 0.7
                InputBoxStroke.Parent = InputBox

                local InputPadding = Instance.new("UIPadding")
                InputPadding.Parent = InputBox
                InputPadding.PaddingLeft = UDim.new(0, 8)
                InputPadding.PaddingRight = UDim.new(0, 8)

                local InputFunc = {
                    Value = InputConfig.Default,
                    Type = "Input"
                }

                function InputFunc:Set(text)
                    InputFunc.Value = text
                    InputBox.Text = text
                    ConfigData[configKey] = text
                    InputConfig.Callback(text)
                end

                function InputFunc:GetValue()
                    return InputFunc.Value
                end

                InputBox.FocusLost:Connect(function(enterPressed)
                    InputFunc:Set(InputBox.Text)
                end)

                InputBox.Focused:Connect(function()
                    TweenService:Create(InputBoxStroke, TweenInfo.new(0.2), {Color = GuiConfig.Color, Transparency = 0}):Play()
                end)

                InputBox.FocusLost:Connect(function()
                    TweenService:Create(InputBoxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 60), Transparency = 0.7}):Play()
                end)

                InputFrame.MouseEnter:Connect(function()
                    TweenService:Create(InputFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end)

                InputFrame.MouseLeave:Connect(function()
                    TweenService:Create(InputFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                end)

                CountItem = CountItem + 1
                Elements[configKey] = InputFunc
                return InputFunc
            end

            function Items:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or (DropdownConfig.Multi and {} or nil)
                DropdownConfig.Multi = DropdownConfig.Multi or false
                DropdownConfig.Callback = DropdownConfig.Callback or function() end

                local configKey = (TabConfig.Name or "Tab") .. "_" .. (SectionConfig.Name or "Section") .. "_Dropdown_" .. DropdownConfig.Name

                local DropdownFrame = Instance.new("Frame")
                local DropdownCorner = Instance.new("UICorner")
                local DropdownTitle = Instance.new("TextLabel")
                local DropdownButton = Instance.new("TextButton")
                local DropdownButtonCorner = Instance.new("UICorner")
                local DropdownButtonStroke = Instance.new("UIStroke")
                local OptionSelecting = Instance.new("TextLabel")
                local DropdownArrow = Instance.new("TextLabel")
                local DropdownContent = Instance.new("Frame")
                local DropdownContentCorner = Instance.new("UICorner")
                local DropdownContentStroke = Instance.new("UIStroke")
                local SearchBox = Instance.new("TextBox")
                local SearchBoxCorner = Instance.new("UICorner")
                local ScrollSelect = Instance.new("ScrollingFrame")
                local ScrollSelectLayout = Instance.new("UIListLayout")

                DropdownFrame.Name = "DropdownFrame"
                DropdownFrame.Parent = SectionAdd
                DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                DropdownFrame.BackgroundTransparency = 0.7
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.LayoutOrder = CountItem
                DropdownFrame.ZIndex = 100

                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownFrame

                DropdownTitle.Name = "DropdownTitle"
                DropdownTitle.Parent = DropdownFrame
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Position = UDim2.new(0, 12, 0, 8)
                DropdownTitle.Size = UDim2.new(1, -24, 0, 16)
                DropdownTitle.Font = Enum.Font.GothamMedium
                DropdownTitle.Text = DropdownConfig.Name
                DropdownTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
                DropdownTitle.TextSize = 13
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.ZIndex = 101

                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = DropdownFrame
                DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(0, 12, 0, 30)
                DropdownButton.Size = UDim2.new(1, -24, 0, 22)
                DropdownButton.AutoButtonColor = false
                DropdownButton.Text = ""
                DropdownButton.ZIndex = 101

                DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                DropdownButtonCorner.Parent = DropdownButton

                DropdownButtonStroke.Color = Color3.fromRGB(50, 50, 60)
                DropdownButtonStroke.Thickness = 1
                DropdownButtonStroke.Transparency = 0.7
                DropdownButtonStroke.Parent = DropdownButton

                OptionSelecting.Name = "OptionSelecting"
                OptionSelecting.Parent = DropdownButton
                OptionSelecting.BackgroundTransparency = 1
                OptionSelecting.Position = UDim2.new(0, 8, 0, 0)
                OptionSelecting.Size = UDim2.new(1, -30, 1, 0)
                OptionSelecting.Font = Enum.Font.Gotham
                OptionSelecting.Text = DropdownConfig.Multi and "Select Options" or "Select Option"
                OptionSelecting.TextColor3 = Color3.fromRGB(150, 150, 160)
                OptionSelecting.TextSize = 12
                OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
                OptionSelecting.TextTruncate = Enum.TextTruncate.AtEnd
                OptionSelecting.ZIndex = 102

                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = DropdownButton
                DropdownArrow.AnchorPoint = Vector2.new(1, 0.5)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(1, -8, 0.5, 0)
                DropdownArrow.Size = UDim2.new(0, 12, 0, 12)
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = Color3.fromRGB(150, 150, 160)
                DropdownArrow.TextSize = 10
                DropdownArrow.ZIndex = 102

                DropdownContent.Name = "DropdownContent"
                DropdownContent.Parent = DropdownFrame
                DropdownContent.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                DropdownContent.BorderSizePixel = 0
                DropdownContent.Position = UDim2.new(0, 12, 0, 56)
                DropdownContent.Size = UDim2.new(1, -24, 0, 0)
                DropdownContent.ClipsDescendants = true
                DropdownContent.Visible = false
                DropdownContent.ZIndex = 103

                DropdownContentCorner.CornerRadius = UDim.new(0, 4)
                DropdownContentCorner.Parent = DropdownContent

                DropdownContentStroke.Color = GuiConfig.Color
                DropdownContentStroke.Thickness = 1
                DropdownContentStroke.Transparency = 0.5
                DropdownContentStroke.Parent = DropdownContent

                SearchBox.Name = "SearchBox"
                SearchBox.Parent = DropdownContent
                SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                SearchBox.BorderSizePixel = 0
                SearchBox.Position = UDim2.new(0, 6, 0, 6)
                SearchBox.Size = UDim2.new(1, -12, 0, 22)
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.PlaceholderText = "Search..."
                SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
                SearchBox.Text = ""
                SearchBox.TextColor3 = Color3.fromRGB(220, 220, 230)
                SearchBox.TextSize = 11
                SearchBox.TextXAlignment = Enum.TextXAlignment.Left
                SearchBox.ClearTextOnFocus = false
                SearchBox.ZIndex = 104

                SearchBoxCorner.CornerRadius = UDim.new(0, 3)
                SearchBoxCorner.Parent = SearchBox

                local SearchPadding = Instance.new("UIPadding")
                SearchPadding.Parent = SearchBox
                SearchPadding.PaddingLeft = UDim.new(0, 6)
                SearchPadding.PaddingRight = UDim.new(0, 6)

                ScrollSelect.Name = "ScrollSelect"
                ScrollSelect.Parent = DropdownContent
                ScrollSelect.Active = true
                ScrollSelect.BackgroundTransparency = 1
                ScrollSelect.BorderSizePixel = 0
                ScrollSelect.Position = UDim2.new(0, 6, 0, 34)
                ScrollSelect.Size = UDim2.new(1, -12, 1, -40)
                ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollSelect.ScrollBarThickness = 3
                ScrollSelect.ScrollBarImageColor3 = GuiConfig.Color
                ScrollSelect.AutomaticCanvasSize = Enum.AutomaticSize.Y
                ScrollSelect.ZIndex = 104

                ScrollSelectLayout.Parent = ScrollSelect
                ScrollSelectLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ScrollSelectLayout.Padding = UDim.new(0, 3)

                local CountDropdown = 0
                local isOpen = false

                local DropdownFunc = {
                    Value = DropdownConfig.Default,
                    Options = DropdownConfig.Options,
                    Type = "Dropdown"
                }

                function DropdownFunc:Clear()
                    for _, v in pairs(ScrollSelect:GetChildren()) do
                        if v.Name == "Option" then
                            v:Destroy()
                        end
                    end
                    CountDropdown = 0
                end

                DropdownButton.Activated:Connect(function()
                    isOpen = not isOpen
                    
                    if isOpen then
                        DropdownContent.Visible = true
                        local targetHeight = math.min(#DropdownFunc.Options * 28 + 45, 150)
                        TweenService:Create(DropdownContent, TweenInfo.new(0.2), {Size = UDim2.new(1, -24, 0, targetHeight)}):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 60 + targetHeight + 5)}):Play()
                        TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                        TweenService:Create(DropdownButtonStroke, TweenInfo.new(0.2), {Color = GuiConfig.Color, Transparency = 0}):Play()
                    else
                        TweenService:Create(DropdownContent, TweenInfo.new(0.2), {Size = UDim2.new(1, -24, 0, 0)}):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 60)}):Play()
                        TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        TweenService:Create(DropdownButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 60), Transparency = 0.7}):Play()
                        wait(0.2)
                        DropdownContent.Visible = false
                    end
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local searchText = SearchBox.Text:lower()
                    for _, option in pairs(ScrollSelect:GetChildren()) do
                        if option:IsA("TextButton") and option.Name == "Option" then
                            local optionText = option.OptionText.Text:lower()
                            option.Visible = searchText == "" or optionText:find(searchText) ~= nil
                        end
                    end
                end)

                function DropdownFunc:AddOption(value)
                    local label = tostring(value)
                    
                    local Option = Instance.new("TextButton")
                    local UICorner38 = Instance.new("UICorner")
                    local OptionButton = Instance.new("TextButton")
                    local OptionText = Instance.new("TextLabel")
                    local ChooseFrame = Instance.new("Frame")
                    local UIStroke15 = Instance.new("UIStroke")

                    Option.Name = "Option"
                    Option.Parent = ScrollSelect
                    Option.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    Option.BackgroundTransparency = 0.999
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, 0, 0, 25)
                    Option.AutoButtonColor = false
                    Option.Text = ""
                    Option.LayoutOrder = CountDropdown
                    Option.ZIndex = 105

                    UICorner38.CornerRadius = UDim.new(0, 4)
                    UICorner38.Parent = Option

                    OptionButton.Name = "OptionButton"
                    OptionButton.Parent = Option
                    OptionButton.BackgroundTransparency = 1
                    OptionButton.Size = UDim2.new(1, 0, 1, 0)
                    OptionButton.Text = ""
                    OptionButton.AutoButtonColor = false
                    OptionButton.ZIndex = 106

                    OptionText.Name = "OptionText"
                    OptionText.Parent = Option
                    OptionText.Font = Enum.Font.Gotham
                    OptionText.Text = label
                    OptionText.TextSize = 12
                    OptionText.TextColor3 = Color3.fromRGB(220, 220, 230)
                    OptionText.Position = UDim2.new(0, 8, 0, 0)
                    OptionText.Size = UDim2.new(1, -25, 1, 0)
                    OptionText.BackgroundTransparency = 1
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.ZIndex = 106

                    Option:SetAttribute("RealValue", value)

                    ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
                    ChooseFrame.BackgroundColor3 = GuiConfig.Color
                    ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
                    ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
                    ChooseFrame.Name = "ChooseFrame"
                    ChooseFrame.Parent = Option
                    ChooseFrame.ZIndex = 106

                    UIStroke15.Color = GuiConfig.Color
                    UIStroke15.Thickness = 1.6
                    UIStroke15.Transparency = 0.999
                    UIStroke15.Parent = ChooseFrame

                    Instance.new("UICorner", ChooseFrame).CornerRadius = UDim.new(0, 2)

                    OptionButton.Activated:Connect(function()
                        if DropdownConfig.Multi then
                            if not table.find(DropdownFunc.Value, value) then
                                table.insert(DropdownFunc.Value, value)
                            else
                                for i, v in pairs(DropdownFunc.Value) do
                                    if v == value then
                                        table.remove(DropdownFunc.Value, i)
                                        break
                                    end
                                end
                            end
                        else
                            DropdownFunc.Value = value
                        end
                        DropdownFunc:Set(DropdownFunc.Value)
                    end)

                    OptionButton.MouseEnter:Connect(function()
                        TweenService:Create(Option, TweenInfo.new(0.1), {BackgroundTransparency = 0.9}):Play()
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, value) or DropdownFunc.Value == value
                        if not selected then
                            TweenService:Create(Option, TweenInfo.new(0.1), {BackgroundTransparency = 0.999}):Play()
                        end
                    end)

                    CountDropdown = CountDropdown + 1
                end

                function DropdownFunc:Set(Value)
                    if DropdownConfig.Multi then
                        DropdownFunc.Value = type(Value) == "table" and Value or {}
                    else
                        DropdownFunc.Value = (type(Value) == "table" and Value[1]) or Value
                    end

                    ConfigData[configKey] = DropdownFunc.Value

                    local texts = {}
                    for _, Drop in pairs(ScrollSelect:GetChildren()) do
                        if Drop.Name == "Option" and Drop:FindFirstChild("OptionText") then
                            local v = Drop:GetAttribute("RealValue")
                            local selected = DropdownConfig.Multi and table.find(DropdownFunc.Value, v) or DropdownFunc.Value == v

                            if selected then
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 2, 0, 12)}):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
                                table.insert(texts, Drop.OptionText.Text)
                            else
                                TweenService:Create(Drop.ChooseFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                                TweenService:Create(Drop.ChooseFrame.UIStroke, TweenInfo.new(0.1), {Transparency = 0.999}):Play()
                                TweenService:Create(Drop, TweenInfo.new(0.1), {BackgroundTransparency = 0.999}):Play()
                            end
                        end
                    end

                    OptionSelecting.Text = (#texts == 0)
                        and (DropdownConfig.Multi and "Select Options" or "Select Option")
                        or table.concat(texts, ", ")
                    
                    if #texts > 0 then
                        OptionSelecting.TextColor3 = Color3.fromRGB(230, 230, 240)
                    else
                        OptionSelecting.TextColor3 = Color3.fromRGB(150, 150, 160)
                    end

                    if DropdownConfig.Callback then
                        if DropdownConfig.Multi then
                            DropdownConfig.Callback(DropdownFunc.Value)
                        else
                            local str = (DropdownFunc.Value ~= nil) and tostring(DropdownFunc.Value) or ""
                            DropdownConfig.Callback(str)
                        end
                    end
                end

                function DropdownFunc:SetValue(val)
                    self:Set(val)
                end

                function DropdownFunc:GetValue()
                    return self.Value
                end

                function DropdownFunc:SetValues(newList, selecting)
                    newList = newList or {}
                    selecting = selecting or (DropdownConfig.Multi and {} or nil)
                    DropdownFunc:Clear()
                    for _, v in ipairs(newList) do
                        DropdownFunc:AddOption(v)
                    end
                    DropdownFunc.Options = newList
                    DropdownFunc:Set(selecting)
                end

                DropdownFunc:SetValues(DropdownFunc.Options, DropdownFunc.Value)

                DropdownFrame.MouseEnter:Connect(function()
                    if not isOpen then
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                    end
                end)

                DropdownFrame.MouseLeave:Connect(function()
                    if not isOpen then
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                    end
                end)

                CountItem = CountItem + 1
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end

            function Items:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Parent = SectionAdd
                Divider.AnchorPoint = Vector2.new(0.5, 0)
                Divider.Position = UDim2.new(0.5, 0, 0, 0)
                Divider.Size = UDim2.new(1, 0, 0, 2)
                Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Divider.BackgroundTransparency = 0
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = CountItem

                local UIGradient = Instance.new("UIGradient")
                UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 80)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
                }
                UIGradient.Parent = Divider

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 2)
                UICorner.Parent = Divider

                CountItem = CountItem + 1
                return Divider
            end

            function Items:AddSubSection(title)
                title = title or "Sub Section"

                local SubSection = Instance.new("Frame")
                SubSection.Name = "SubSection"
                SubSection.Parent = SectionAdd
                SubSection.BackgroundTransparency = 1
                SubSection.Size = UDim2.new(1, 0, 0, 22)
                SubSection.LayoutOrder = CountItem

                local Background = Instance.new("Frame")
                Background.Parent = SubSection
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 0.935
                Background.BorderSizePixel = 0
                Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)

                local Label = Instance.new("TextLabel")
                Label.Parent = SubSection
                Label.AnchorPoint = Vector2.new(0, 0.5)
                Label.Position = UDim2.new(0, 10, 0.5, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.GothamBold
                Label.Text = "── " .. title .. " ──"
                Label.TextColor3 = Color3.fromRGB(230, 230, 230)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                CountItem = CountItem + 1
                return SubSection
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        _G[safeName] = Sections
        return Sections
    end

    return Tabs
end

return ZuperMing
