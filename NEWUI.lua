local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Viewport = workspace.CurrentCamera.ViewportSize

--// CONFIG SYSTEM
local LibraryName = "ZuperMing"
local ConfigPath = "ZuperMing/Configs/"

if not isfolder("ZuperMing") then makefolder("ZuperMing") end
if not isfolder("ZuperMing/Configs") then makefolder("ZuperMing/Configs") end

local ConfigData = {}
local Elements = {} 
local CURRENT_VERSION = "1.0"

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
            if LoadConfigElements then LoadConfigElements() end
            return true
        end
    end
    return false
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        local targetValue = ConfigData[key]
        if element.Set and targetValue ~= nil then
            element:Set(targetValue)
        end
    end
end

--// ASSETS & ICONS
local Icons = {
    player = "rbxassetid://12120698352", web = "rbxassetid://137601480983962", bag = "rbxassetid://8601111810",
    shop = "rbxassetid://4985385964", settings = "rbxassetid://70386228443175", sword = "rbxassetid://82472368671405",
    discord = "rbxassetid://94434236999817", fish = "rbxassetid://97167558235554",
    search = "rbxassetid://11422151665", arrow_down = "rbxassetid://16851841101"
}

--// UTILITIES (Gradient, Drag, Ripple)
local function ApplyGradient(instance)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 140, 255)), -- Biru Zuper
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 60, 60))  -- Merah Ming
    }
    gradient.Rotation = 45
    gradient.Parent = instance
    return gradient
end

local function isMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end
local isMobile = isMobileDevice()

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15), { Position = pos }):Play()
    end
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPosition = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then UpdatePos(input) end end)
end

local function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Circle.ImageTransparency = 0.8
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Parent = Button
        local NewX, NewY = X - Circle.AbsolutePosition.X, Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", 0.5)
        for i=1,10 do Circle.ImageTransparency = Circle.ImageTransparency + 0.02; task.wait(0.04) end
        Circle:Destroy()
    end)
end

--// MAIN LIBRARY
local ZuperMing = {}

function ZuperMing:MakeNotify(NotifyConfig)
    NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "ZuperMing"
    NotifyConfig.Content = NotifyConfig.Content or "Notification"
    NotifyConfig.Time = NotifyConfig.Time or 3
    
    spawn(function()
        if not CoreGui:FindFirstChild("ZuperNotify") then
            local ng = Instance.new("ScreenGui"); ng.Name = "ZuperNotify"; ng.Parent = CoreGui; ng.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            local nl = Instance.new("Frame"); nl.Name = "Layout"; nl.Parent = ng
            nl.Position = UDim2.new(1, -20, 1, -20); nl.AnchorPoint = Vector2.new(1,1); nl.Size = UDim2.new(0, 300, 1, 0); nl.BackgroundTransparency = 1
            
            nl.ChildRemoved:Connect(function()
                local count = 0
                for _,v in nl:GetChildren() do
                    if v:IsA("Frame") then
                        TweenService:Create(v, TweenInfo.new(0.3), {Position = UDim2.new(0,0,1, -((v.Size.Y.Offset + 10)*count))}):Play()
                        count = count + 1
                    end
                end
            end)
        end
        
        local Layout = CoreGui.ZuperNotify.Layout
        local Count = #Layout:GetChildren()
        
        local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, 0, 0, 70); Frame.Parent = Layout
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
        Frame.Position = UDim2.new(0, 0, 1, -((80) * Count))
        Frame.BorderSizePixel = 0
        
        local Stroke = Instance.new("UIStroke"); Stroke.Parent = Frame; Stroke.Thickness = 1.5; ApplyGradient(Stroke)
        local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Frame
        
        local Title = Instance.new("TextLabel"); Title.Parent = Frame
        Title.Text = NotifyConfig.Title; Title.TextColor3 = Color3.fromRGB(0, 140, 255)
        Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 15, 0, 8); Title.Size = UDim2.new(1, -30, 0, 20); Title.TextXAlignment = Enum.TextXAlignment.Left
        
        local Desc = Instance.new("TextLabel"); Desc.Parent = Frame
        Desc.Text = NotifyConfig.Content; Desc.TextColor3 = Color3.fromRGB(220, 220, 220)
        Desc.Font = Enum.Font.Gotham; Desc.TextSize = 13; Desc.BackgroundTransparency = 1
        Desc.Position = UDim2.new(0, 15, 0, 30); Desc.Size = UDim2.new(1, -30, 0, 30); Desc.TextXAlignment = Enum.TextXAlignment.Left; Desc.TextWrapped = true

        -- Animation Slide In
        Frame.Position = Frame.Position + UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = Frame.Position - UDim2.new(1.5, 0, 0, 0)}):Play()
        
        task.wait(NotifyConfig.Time)
        -- Animation Slide Out
        TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = Frame.Position + UDim2.new(1.5, 0, 0, 0)}):Play()
        task.wait(0.5)
        Frame:Destroy()
    end)
end

function notif(msg, delay)
    ZuperMing:MakeNotify({Content = msg, Time = delay})
end

function ZuperMing:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Title = GuiConfig.Title or "ZuperMing"
    GuiConfig.Footer = GuiConfig.Footer or "ZuperMing V1"
    
    if CoreGui:FindFirstChild("ZuperMingUI") then CoreGui.ZuperMingUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZuperMingUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BackgroundTransparency = 0.05
    if isMobile then
        MainFrame.Size = UDim2.new(0, 500, 0, 280)
    else
        MainFrame.Size = UDim2.new(0, 650, 0, 400)
    end
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 10); MainCorner.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke"); MainStroke.Parent = MainFrame; MainStroke.Thickness = 2.5; ApplyGradient(MainStroke)

    MakeDraggable(MainFrame, MainFrame)

    -- GRADIENT LINE TOP
    local TopLine = Instance.new("Frame")
    TopLine.Parent = MainFrame
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 45)
    TopLine.BorderSizePixel = 0
    ApplyGradient(TopLine)

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    local SideCorner = Instance.new("UICorner"); SideCorner.CornerRadius = UDim.new(0, 10); SideCorner.Parent = Sidebar
    local SideCover = Instance.new("Frame"); SideCover.Parent = Sidebar; SideCover.BackgroundColor3 = Sidebar.BackgroundColor3; SideCover.BackgroundTransparency = 0.5; SideCover.BorderSizePixel = 0; SideCover.Size = UDim2.new(0, 10, 1, 0); SideCover.Position = UDim2.new(1, -5, 0, 0)

    -- TITLE HEADER
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Sidebar
    TitleLabel.Text = GuiConfig.Title
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 20
    TitleLabel.Size = UDim2.new(1, 0, 0, 45)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    local TitleGrad = ApplyGradient(TitleLabel) -- Gradient Text

    -- TAB CONTAINER
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.Position = UDim2.new(0, 0, 0, 55)
    TabContainer.Size = UDim2.new(1, 0, 1, -65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout"); TabList.Parent = TabContainer; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Padding = UDim.new(0, 5)

    -- PAGE CONTAINER
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Parent = MainFrame
    PageContainer.Position = UDim2.new(0, 160, 0, 55)
    PageContainer.Size = UDim2.new(1, -170, 1, -65)
    PageContainer.BackgroundTransparency = 1
    local PageFolder = Instance.new("Folder"); PageFolder.Parent = PageContainer

    -- TOGGLE UI KEYBIND (F3)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.F3 then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Tabs = {}
    local FirstTab = true

    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        local Name = TabConfig.Name or "Tab"
        local Icon = TabConfig.Icon or ""

        -- TAB BUTTON
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(1, -20, 0, 35)
        TabBtn.Position = UDim2.new(0, 10, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Parent = TabBtn
        TabTitle.Text = Name
        TabTitle.Font = Enum.Font.GothamBold
        TabTitle.TextSize = 14
        TabTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Size = UDim2.new(1, -30, 1, 0)
        TabTitle.Position = UDim2.new(0, 30, 0, 0)
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left

        local TabIco = Instance.new("ImageLabel")
        TabIco.Parent = TabBtn
        TabIco.BackgroundTransparency = 1
        TabIco.ImageColor3 = Color3.fromRGB(150, 150, 150)
        TabIco.Size = UDim2.new(0, 18, 0, 18)
        TabIco.Position = UDim2.new(0, 5, 0.5, -9)
        if Icons[Icon] then TabIco.Image = Icons[Icon] else TabIco.Image = Icon end

        local Glow = Instance.new("Frame"); Glow.Parent = TabBtn; Glow.Size = UDim2.new(0, 3, 0, 20); Glow.Position = UDim2.new(0, 0, 0.5, -10); Glow.BorderSizePixel = 0; Glow.Visible = false
        ApplyGradient(Glow)

        -- PAGE SCROLL
        local Page = Instance.new("ScrollingFrame")
        Page.Parent = PageFolder
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
        Page.Visible = false
        
        local PageList = Instance.new("UIListLayout"); PageList.Parent = Page; PageList.SortOrder = Enum.SortOrder.LayoutOrder; PageList.Padding = UDim.new(0, 8)
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 20) end)

        local function Activate()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v.TextLabel, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(v.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    v.Frame.Visible = false
                end
            end
            for _, p in pairs(PageFolder:GetChildren()) do p.Visible = false end
            
            Page.Visible = true
            Glow.Visible = true
            TweenService:Create(TabTitle, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(TabIco, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if FirstTab then Activate(); FirstTab = false end

        local Sections = {}
        function Sections:AddSection(Title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Parent = Page
            SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            SectionFrame.Size = UDim2.new(1, -5, 0, 30)
            local SecCorner = Instance.new("UICorner"); SecCorner.CornerRadius = UDim.new(0, 6); SecCorner.Parent = SectionFrame
            local SecStroke = Instance.new("UIStroke"); SecStroke.Parent = SectionFrame; SecStroke.Transparency = 0.8; ApplyGradient(SecStroke)

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Parent = SectionFrame
            SecTitle.Text = Title
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
            SecTitle.TextSize = 13
            SecTitle.BackgroundTransparency = 1
            SecTitle.Size = UDim2.new(1, -10, 0, 30)
            SecTitle.Position = UDim2.new(0, 10, 0, 0)
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left

            local Container = Instance.new("Frame")
            Container.Parent = SectionFrame
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Position = UDim2.new(0, 0, 0, 35)
            Container.BackgroundTransparency = 1
            local ContList = Instance.new("UIListLayout"); ContList.Parent = Container; ContList.SortOrder = Enum.SortOrder.LayoutOrder; ContList.Padding = UDim.new(0, 5)

            ContList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, ContList.AbsoluteContentSize.Y + 10)
                SectionFrame.Size = UDim2.new(1, -5, 0, Container.Size.Y.Offset + 35)
            end)

            local Items = {}

            -- PARAGRAPH
            function Items:AddParagraph(Config)
                local ParaFrame = Instance.new("Frame"); ParaFrame.Parent = Container; ParaFrame.BackgroundTransparency = 1; ParaFrame.Size = UDim2.new(1, 0, 0, 50)
                local PTitle = Instance.new("TextLabel"); PTitle.Parent = ParaFrame; PTitle.Text = Config.Title; PTitle.Font = Enum.Font.GothamBold; PTitle.TextColor3 = Color3.fromRGB(255,255,255); PTitle.TextSize = 13; PTitle.Position = UDim2.new(0, 10, 0, 5); PTitle.Size = UDim2.new(1, -20, 0, 15); PTitle.BackgroundTransparency = 1; PTitle.TextXAlignment = Enum.TextXAlignment.Left
                local PCont = Instance.new("TextLabel"); PCont.Parent = ParaFrame; PCont.Text = Config.Content; PCont.Font = Enum.Font.Gotham; PCont.TextColor3 = Color3.fromRGB(180,180,180); PCont.TextSize = 12; PCont.Position = UDim2.new(0, 10, 0, 22); PCont.Size = UDim2.new(1, -20, 0, 20); PCont.BackgroundTransparency = 1; PCont.TextXAlignment = Enum.TextXAlignment.Left; PCont.TextWrapped = true
                ParaFrame.Size = UDim2.new(1, 0, 0, PCont.TextBounds.Y + 30)
            end

            -- BUTTON
            function Items:AddButton(Config)
                local BtnFrame = Instance.new("Frame"); BtnFrame.Parent = Container; BtnFrame.BackgroundTransparency = 1; BtnFrame.Size = UDim2.new(1, 0, 0, 38)
                local Btn = Instance.new("TextButton")
                Btn.Parent = BtnFrame
                Btn.Size = UDim2.new(1, -20, 1, -4)
                Btn.Position = UDim2.new(0, 10, 0, 2)
                Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                Btn.Text = Config.Title or "Button"
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 13
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                local Stroke = Instance.new("UIStroke"); Stroke.Parent = Btn; Stroke.Color = Color3.fromRGB(60,60,60); Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                Btn.MouseButton1Click:Connect(function()
                    CircleClick(Btn, Mouse.X, Mouse.Y)
                    if Config.Callback then Config.Callback() end
                end)

                Btn.MouseEnter:Connect(function() Stroke.Thickness = 2; ApplyGradient(Stroke); Stroke.Transparency = 0 end)
                Btn.MouseLeave:Connect(function() Stroke.Thickness = 1; Stroke.Color = Color3.fromRGB(60,60,60); for _,v in pairs(Stroke:GetChildren()) do v:Destroy() end end)
            end

            -- TOGGLE
            function Items:AddToggle(Config)
                local configKey = "Toggle_" .. (Config.Title or "")
                local toggled = Config.Default or false
                if ConfigData[configKey] ~= nil then toggled = ConfigData[configKey] end

                local TglFrame = Instance.new("Frame"); TglFrame.Parent = Container; TglFrame.BackgroundTransparency = 1; TglFrame.Size = UDim2.new(1, 0, 0, 38)
                
                local Title = Instance.new("TextLabel"); Title.Parent = TglFrame; Title.Text = Config.Title; Title.Font = Enum.Font.GothamSemibold; Title.TextSize = 13; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.Position = UDim2.new(0, 10, 0, 0); Title.Size = UDim2.new(1, -60, 1, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

                local Switch = Instance.new("Frame"); Switch.Parent = TglFrame; Switch.Size = UDim2.new(0, 42, 0, 22); Switch.Position = UDim2.new(1, -15, 0.5, 0); Switch.AnchorPoint = Vector2.new(1, 0.5); Switch.BackgroundColor3 = Color3.fromRGB(50,50,55)
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame"); Dot.Parent = Switch; Dot.Size = UDim2.new(0, 18, 0, 18); Dot.Position = UDim2.new(0, 2, 0.5, -9); Dot.BackgroundColor3 = Color3.fromRGB(200,200,200)
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
                
                local Button = Instance.new("TextButton"); Button.Parent = TglFrame; Button.Size = UDim2.new(1, 0, 1, 0); Button.BackgroundTransparency = 1; Button.Text = ""

                local function Update()
                    if toggled then
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
                        Switch.BackgroundColor3 = Color3.fromRGB(255,255,255)
                        ApplyGradient(Switch)
                        TweenService:Create(Title, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    else
                        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
                        Switch.BackgroundColor3 = Color3.fromRGB(50,50,55)
                        for _,v in pairs(Switch:GetChildren()) do if v:IsA("UIGradient") then v:Destroy() end end
                        TweenService:Create(Title, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    end
                    ConfigData[configKey] = toggled
                    if Config.Callback then Config.Callback(toggled) end
                end

                Button.MouseButton1Click:Connect(function() toggled = not toggled; Update() end)
                if toggled then Update() end
                
                local Func = {}
                function Func:Set(val) toggled = val; Update() end
                Elements[configKey] = Func
                return Func
            end

            -- SLIDER
            function Items:AddSlider(Config)
                local configKey = "Slider_" .. (Config.Title or "")
                local min, max = Config.Min or 0, Config.Max or 100
                local default = Config.Default or min
                if ConfigData[configKey] ~= nil then default = ConfigData[configKey] end
                local value = default

                local SldFrame = Instance.new("Frame"); SldFrame.Parent = Container; SldFrame.BackgroundTransparency = 1; SldFrame.Size = UDim2.new(1, 0, 0, 55)
                
                local Title = Instance.new("TextLabel"); Title.Parent = SldFrame; Title.Text = Config.Title; Title.Font = Enum.Font.GothamSemibold; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.TextSize = 13; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(1, -50, 0, 20); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left
                local ValText = Instance.new("TextLabel"); ValText.Parent = SldFrame; ValText.Text = tostring(value); ValText.Font = Enum.Font.Gotham; ValText.TextColor3 = Color3.fromRGB(180,180,180); ValText.TextSize = 13; ValText.Position = UDim2.new(1, -15, 0, 5); ValText.AnchorPoint = Vector2.new(1,0); ValText.Size = UDim2.new(0, 40, 0, 20); ValText.BackgroundTransparency = 1; ValText.TextXAlignment = Enum.TextXAlignment.Right

                local BarBack = Instance.new("Frame"); BarBack.Parent = SldFrame; BarBack.BackgroundColor3 = Color3.fromRGB(40,40,45); BarBack.Size = UDim2.new(1, -20, 0, 6); BarBack.Position = UDim2.new(0, 10, 0, 35)
                Instance.new("UICorner", BarBack).CornerRadius = UDim.new(1, 0)

                local BarFill = Instance.new("Frame"); BarFill.Parent = BarBack; BarFill.BackgroundColor3 = Color3.fromRGB(255,255,255); BarFill.Size = UDim2.new(0, 0, 1, 0)
                Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
                ApplyGradient(BarFill)

                local Knob = Instance.new("Frame"); Knob.Parent = BarFill; Knob.BackgroundColor3 = Color3.fromRGB(255,255,255); Knob.Size = UDim2.new(0, 14, 0, 14); Knob.AnchorPoint = Vector2.new(0.5, 0.5); Knob.Position = UDim2.new(1, 0, 0.5, 0)
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                local Trigger = Instance.new("TextButton"); Trigger.Parent = BarBack; Trigger.BackgroundTransparency = 1; Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.Text = ""

                local function Update(input)
                    local scale = math.clamp((input.Position.X - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + ((max - min) * scale))
                    TweenService:Create(BarFill, TweenInfo.new(0.1), {Size = UDim2.new(scale, 0, 1, 0)}):Play()
                    ValText.Text = tostring(value)
                    ConfigData[configKey] = value
                    if Config.Callback then Config.Callback(value) end
                end
                
                local dragging = false
                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; Update(input)
                        TweenService:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 18, 0, 18)}):Play()
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        dragging = false
                        TweenService:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 14, 0, 14)}):Play()
                    end
                end)

                -- Init default
                local percent = (default - min) / (max - min)
                BarFill.Size = UDim2.new(percent, 0, 1, 0)
                
                local Func = {}
                function Func:Set(val) value = val; local p = (val - min) / (max - min); BarFill.Size = UDim2.new(p, 0, 1, 0); ValText.Text = tostring(val) end
                Elements[configKey] = Func
                return Func
            end

            -- INPUT
            function Items:AddInput(Config)
                local configKey = "Input_" .. (Config.Title or "")
                local default = Config.Default or ""
                if ConfigData[configKey] ~= nil then default = ConfigData[configKey] end

                local InpFrame = Instance.new("Frame"); InpFrame.Parent = Container; InpFrame.BackgroundTransparency = 1; InpFrame.Size = UDim2.new(1, 0, 0, 50)
                
                local Title = Instance.new("TextLabel"); Title.Parent = InpFrame; Title.Text = Config.Title; Title.Font = Enum.Font.GothamSemibold; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.TextSize = 13; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(1, -20, 0, 15); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

                local BoxFrame = Instance.new("Frame"); BoxFrame.Parent = InpFrame; BoxFrame.BackgroundColor3 = Color3.fromRGB(35,35,40); BoxFrame.Size = UDim2.new(1, -20, 0, 25); BoxFrame.Position = UDim2.new(0, 10, 0, 22)
                Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
                local Stroke = Instance.new("UIStroke"); Stroke.Parent = BoxFrame; Stroke.Color = Color3.fromRGB(60,60,60); Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                local Box = Instance.new("TextBox"); Box.Parent = BoxFrame; Box.BackgroundTransparency = 1; Box.Size = UDim2.new(1, -10, 1, 0); Box.Position = UDim2.new(0, 5, 0, 0); Box.Font = Enum.Font.Gotham; Box.TextColor3 = Color3.fromRGB(255,255,255); Box.TextSize = 13; Box.Text = default; Box.PlaceholderText = Config.Placeholder or "Type here..."
                Box.ClearTextOnFocus = false

                Box.Focused:Connect(function() Stroke.Thickness = 2; ApplyGradient(Stroke); Stroke.Transparency = 0 end)
                Box.FocusLost:Connect(function() 
                    Stroke.Thickness = 1; Stroke.Color = Color3.fromRGB(60,60,60); for _,v in pairs(Stroke:GetChildren()) do v:Destroy() end
                    ConfigData[configKey] = Box.Text
                    if Config.Callback then Config.Callback(Box.Text) end
                end)
                
                local Func = {}
                function Func:Set(val) Box.Text = val end
                Elements[configKey] = Func
                return Func
            end

            -- DROPDOWN (Enhanced with ZuperMing Style)
            function Items:AddDropdown(Config)
                local configKey = "Dropdown_" .. (Config.Title or "")
                local default = Config.Default
                if ConfigData[configKey] ~= nil then default = ConfigData[configKey] end
                
                local DropFrame = Instance.new("Frame"); DropFrame.Parent = Container; DropFrame.BackgroundTransparency = 1; DropFrame.Size = UDim2.new(1, 0, 0, 55); DropFrame.ZIndex = 2
                
                local Title = Instance.new("TextLabel"); Title.Parent = DropFrame; Title.Text = Config.Title; Title.Font = Enum.Font.GothamSemibold; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.TextSize = 13; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(1, -20, 0, 15); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

                local BoxFrame = Instance.new("Frame"); BoxFrame.Parent = DropFrame; BoxFrame.BackgroundColor3 = Color3.fromRGB(35,35,40); BoxFrame.Size = UDim2.new(1, -20, 0, 28); BoxFrame.Position = UDim2.new(0, 10, 0, 22)
                Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
                local Stroke = Instance.new("UIStroke"); Stroke.Parent = BoxFrame; Stroke.Color = Color3.fromRGB(60,60,60)

                local SelText = Instance.new("TextLabel"); SelText.Parent = BoxFrame; SelText.Text = (Config.Multi and "Select Options") or tostring(default or "Select Option"); SelText.Font = Enum.Font.Gotham; SelText.TextColor3 = Color3.fromRGB(200,200,200); SelText.TextSize = 13; SelText.Position = UDim2.new(0, 10, 0, 0); SelText.Size = UDim2.new(1, -30, 1, 0); SelText.BackgroundTransparency = 1; SelText.TextXAlignment = Enum.TextXAlignment.Left
                local Arrow = Instance.new("ImageLabel"); Arrow.Parent = BoxFrame; Arrow.Image = Icons.arrow_down; Arrow.Size = UDim2.new(0, 16, 0, 16); Arrow.Position = UDim2.new(1, -20, 0.5, -8); Arrow.BackgroundTransparency = 1; Arrow.ImageColor3 = Color3.fromRGB(150,150,150)

                local Button = Instance.new("TextButton"); Button.Parent = BoxFrame; Button.Size = UDim2.new(1, 0, 1, 0); Button.BackgroundTransparency = 1; Button.Text = ""

                -- DROPDOWN LIST
                local ListFrame = Instance.new("Frame"); ListFrame.Parent = BoxFrame; ListFrame.Size = UDim2.new(1, 0, 0, 0); ListFrame.Position = UDim2.new(0, 0, 1, 5); ListFrame.BackgroundColor3 = Color3.fromRGB(30,30,35); ListFrame.BorderSizePixel = 0; ListFrame.Visible = false; ListFrame.ClipsDescendants = true; ListFrame.ZIndex = 10
                Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)
                local ListStroke = Instance.new("UIStroke"); ListStroke.Parent = ListFrame; ListStroke.Thickness = 2; ApplyGradient(ListStroke)

                local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ListFrame; Scroll.Size = UDim2.new(1, -10, 1, -10); Scroll.Position = UDim2.new(0, 5, 0, 5); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Color3.fromRGB(0,140,255); Scroll.ZIndex = 11
                local Layout = Instance.new("UIListLayout"); Layout.Parent = Scroll; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 2)
                
                local opened = false
                local selected = (Config.Multi and (default or {})) or default

                local function RefreshList()
                    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    
                    for _, opt in pairs(Config.Options or {}) do
                        local Item = Instance.new("TextButton"); Item.Parent = Scroll; Item.Size = UDim2.new(1, 0, 0, 25); Item.BackgroundColor3 = Color3.fromRGB(40,40,45); Item.BackgroundTransparency = 0.5; Item.Text = "  " .. tostring(opt); Item.TextColor3 = Color3.fromRGB(200,200,200); Item.Font = Enum.Font.Gotham; Item.TextSize = 12; Item.TextXAlignment = Enum.TextXAlignment.Left; Item.ZIndex = 12
                        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)

                        local isSel = false
                        if Config.Multi then
                            if table.find(selected, opt) then isSel = true end
                        else
                            if selected == opt then isSel = true end
                        end

                        if isSel then
                            Item.TextColor3 = Color3.fromRGB(255,255,255)
                            local g = ApplyGradient(Item); g.Parent = Item -- Full Gradient Item
                            Item.BackgroundTransparency = 0
                        end

                        Item.MouseButton1Click:Connect(function()
                            if Config.Multi then
                                if table.find(selected, opt) then
                                    table.remove(selected, table.find(selected, opt))
                                else
                                    table.insert(selected, opt)
                                end
                                SelText.Text = table.concat(selected, ", ")
                            else
                                selected = opt
                                SelText.Text = tostring(opt)
                                opened = false
                                TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                                task.wait(0.2); ListFrame.Visible = false
                                TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                            end
                            ConfigData[configKey] = selected
                            if Config.Callback then Config.Callback(selected) end
                            RefreshList()
                        end)
                    end
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
                end

                Button.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        RefreshList()
                        ListFrame.Visible = true
                        TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 150)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    else
                        TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        task.wait(0.2); ListFrame.Visible = false
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end
                end)
            end
            
            -- PANEL (Input + Button combined)
            function Items:AddPanel(Config)
                local configKey = "Panel_" .. (Config.Title or "")
                local default = Config.Default or ""
                if ConfigData[configKey] ~= nil then default = ConfigData[configKey] end

                local PnlFrame = Instance.new("Frame"); PnlFrame.Parent = Container; PnlFrame.BackgroundTransparency = 1; PnlFrame.Size = UDim2.new(1, 0, 0, 75)
                
                local Title = Instance.new("TextLabel"); Title.Parent = PnlFrame; Title.Text = Config.Title; Title.Font = Enum.Font.GothamSemibold; Title.TextColor3 = Color3.fromRGB(255,255,255); Title.TextSize = 13; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(1, -20, 0, 15); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

                local InpBox = Instance.new("TextBox"); InpBox.Parent = PnlFrame; InpBox.BackgroundColor3 = Color3.fromRGB(35,35,40); InpBox.Size = UDim2.new(0.65, 0, 0, 30); InpBox.Position = UDim2.new(0, 10, 0, 25); InpBox.Font = Enum.Font.Gotham; InpBox.TextColor3 = Color3.fromRGB(255,255,255); InpBox.TextSize = 13; InpBox.Text = default; InpBox.PlaceholderText = Config.Placeholder or "Value..."
                Instance.new("UICorner", InpBox).CornerRadius = UDim.new(0, 6)
                
                local ActBtn = Instance.new("TextButton"); ActBtn.Parent = PnlFrame; ActBtn.BackgroundColor3 = Color3.fromRGB(40,40,45); ActBtn.Size = UDim2.new(0.3, -5, 0, 30); ActBtn.Position = UDim2.new(0.7, 0, 0, 25); ActBtn.Text = Config.ButtonText or "Set"; ActBtn.TextColor3 = Color3.fromRGB(255,255,255); ActBtn.Font = Enum.Font.GothamBold; ActBtn.TextSize = 13
                Instance.new("UICorner", ActBtn).CornerRadius = UDim.new(0, 6)
                local Stroke = Instance.new("UIStroke"); Stroke.Parent = ActBtn; Stroke.Color = Color3.fromRGB(60,60,60); Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                InpBox.FocusLost:Connect(function() ConfigData[configKey] = InpBox.Text end)
                
                ActBtn.MouseButton1Click:Connect(function()
                    CircleClick(ActBtn, Mouse.X, Mouse.Y)
                    if Config.Callback then Config.Callback(InpBox.Text) end
                end)
                
                ActBtn.MouseEnter:Connect(function() Stroke.Thickness = 2; ApplyGradient(Stroke); Stroke.Transparency = 0 end)
                ActBtn.MouseLeave:Connect(function() Stroke.Thickness = 1; Stroke.Color = Color3.fromRGB(60,60,60); for _,v in pairs(Stroke:GetChildren()) do v:Destroy() end end)
            end

            return Items
        end
        return Sections
    end
    return Tabs
end


return ZuperMing
