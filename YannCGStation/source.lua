-- YannCGStation UI v2.5 - Professional Beauty + High Freedom + Smart Safety
-- Author: YannCG
-- Load: loadstring(game:HttpGet('https://raw.githubusercontent.com/YannCG/YannCGStation-UI/main/YannCGStation/source.lua'))()

local YannCG = {
    Version = "2.5.0",
    Flags = {},
    Themes = {
        Professional = {
            Background = Color3.fromRGB(22, 22, 28),
            Topbar = Color3.fromRGB(30, 30, 38),
            Accent = Color3.fromRGB(0, 170, 255),
            Text = Color3.fromRGB(245, 245, 247),
            ElementBg = Color3.fromRGB(35, 35, 44),
            ElementHover = Color3.fromRGB(45, 45, 55),
            ToggleOn = Color3.fromRGB(0, 170, 255),
            ToggleOff = Color3.fromRGB(80, 80, 90),
            SliderFill = Color3.fromRGB(0, 170, 255),
            Border = {Enabled = true, Color = Color3.fromRGB(50, 50, 60), Thickness = 1},
            CornerRadius = UDim.new(0, 10),
            Font = Enum.Font.GothamSemibold,
            Shadow = {Enabled = true, Transparency = 0.7, Offset = UDim2.new(0, 0, 0, 4)}
        }
    }
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Safe create
local function safeNew(class, props)
    local obj = Instance.new(class)
    if type(props) == "table" then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Apply shadow
local function ApplyShadow(frame, theme)
    if theme.Shadow and theme.Shadow.Enabled then
        local shadow = safeNew("ImageLabel", {
            Size = UDim2.new(1, 12, 1, 12),
            Position = UDim2.new(0, -6, 0, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = theme.Shadow.Transparency or 0.7,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(50, 50, 450, 450),
            ZIndex = frame.ZIndex - 1,
            Parent = frame.Parent
        })
        frame:GetPropertyChangedSignal("Parent"):Connect(function()
            if not frame.Parent then pcall(function() shadow:Destroy() end) end
        end)
    end
end

-- Create Window
local function CreateWindow(options)
    options = options or {}
    local theme = YannCG.Themes[options.Theme] or YannCG.Themes.Professional
    if type(options.Theme) == "table" then theme = options.Theme end

    local ScreenGui = PlayerGui:FindFirstChild("YannCGStation") or safeNew("ScreenGui", {Name = "YannCGStation", ResetOnSpawn = false, Parent = PlayerGui})

    -- Main Frame
    local MainFrame = safeNew("Frame", {
        Size = UDim2.new(0, 540, 0, 400),
        Position = UDim2.new(0.5, -270, 0.5, -200),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })

    -- Shadow
    ApplyShadow(MainFrame, theme)

    -- Corner
    safeNew("UICorner", {CornerRadius = theme.CornerRadius, Parent = MainFrame})

    -- Stroke
    if theme.Border and theme.Border.Enabled then
        safeNew("UIStroke", {Color = theme.Border.Color, Thickness = theme.Border.Thickness, Parent = MainFrame})
    end

    -- Topbar
    local Topbar = safeNew("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    safeNew("UICorner", {CornerRadius = theme.CornerRadius, Parent = Topbar})

    -- Title
    local Title = safeNew("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Name or "YannCG Station",
        TextColor3 = theme.Text,
        Font = theme.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    -- Close Button
    local Close = safeNew("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0, 6),
        BackgroundColor3 = Color3.fromRGB(255, 85, 85),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = Topbar
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Close})

    -- Content
    local Content = safeNew("Frame", {
        Size = UDim2.new(1, -24, 1, -56),
        Position = UDim2.new(0, 12, 0, 50),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Dragging
    local dragging, startPos, dragInput
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = MainFrame.Position
            dragInput = input.Position
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragInput
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Close.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() end) end)

    -- Window API
    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local Tab = {Elements = {}}

        local TabBtn = safeNew("TextButton", {
            Size = UDim2.new(0, 110, 0, 36),
            Position = UDim2.new(0, (#Window.Tabs) * 115, 0, 0),
            BackgroundColor3 = theme.ElementBg,
            Text = name,
            TextColor3 = theme.Text,
            Font = theme.Font,
            TextSize = 14,
            Parent = Topbar
        })
        safeNew("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})

        local TabContent = safeNew("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            Visible = false,
            Parent = Content,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        safeNew("UIListLayout", {Padding = UDim.new(0, 10), Parent = TabContent})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = theme.ElementBg
                t.Button.TextColor3 = theme.Text
            end
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = theme.Accent
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if #Window.Tabs == 0 then
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = theme.Accent
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        Tab.Button = TabBtn
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)

        -- Toggle
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local custom = cfg.Custom or {}
            local value = cfg.CurrentValue or false
            if cfg.Flag and YannCG.Flags[cfg.Flag] ~= nil then value = YannCG.Flags[cfg.Flag] end

            local frame = safeNew("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = theme.ElementBg,
                Parent = TabContent
            })
            safeNew("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})

            local label = safeNew("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Toggle",
                TextColor3 = custom.TextColor or theme.Text,
                Font = custom.Font or theme.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 12, 0, 0),
                Parent = frame
            })

            local switch = safeNew("TextButton", {
                Size = UDim2.new(0, 54, 0, 28),
                Position = UDim2.new(1, -66, 0.5, -14),
                BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff),
                Text = "",
                Parent = frame
            })
            safeNew("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

            local indicator = safeNew("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = value and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = switch
            })
            safeNew("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})

            local function update()
                TweenService:Create(switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff)
                }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.2), {
                    Position = value and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
                }):Play()
                if cfg.Flag then YannCG.Flags[cfg.Flag] = value end
                if cfg.Callback then pcall(cfg.Callback, value) end
            end

            switch.MouseButton1Click:Connect(function()
                value = not value
                update()
            end)

            frame.MouseEnter:Connect(function()
                TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementHover}):Play()
            end)
            frame.MouseLeave:Connect(function()
                TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = theme.ElementBg}):Play()
            end)

            update()

            return {Set = function(v) value = v; update() end}
        end

        return Tab
    end

    return Window
end

-- Notification
function YannCG:Notify(info)
    local notif = safeNew("Frame", {
        Size = UDim2.new(0, 320, 0, 80),
        Position = UDim2.new(1, -340, 1, -100),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Parent = PlayerGui:FindFirstChild("YannCGStation") or PlayerGui
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 12), Parent = notif})
    safeNew("UIStroke", {Color = Color3.fromRGB(60, 60, 70), Thickness = 1, Parent = notif})

    safeNew("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = info.Title or "Notice",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Parent = notif
    })
    safeNew("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 36),
        BackgroundTransparency = 1,
        Text = info.Content or "",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = notif
    })

    notif.Position = UDim2.new(1, 10, 1, -100)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -340, 1, -100)}):Play()
    task.wait(info.Duration or 3)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 1, -100)}):Play()
    task.wait(0.5)
    pcall(function() notif:Destroy() end)
end

YannCG.CreateWindow = CreateWindow
YannCG.LoadConfig = function() end

return YannCG
