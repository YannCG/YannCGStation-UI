-- YannCGStation UI v3.0 - Ultimate Beauty + Rayfield-Level Design + Full Freedom
-- Author: YannCG
-- Load: loadstring(game:HttpGet('https://raw.githubusercontent.com/YannCG/YannCGStation-UI/main/YannCGStation/source.lua'))()

local YannCG = {
    Version = "3.0.0",
    Flags = {},
    Themes = {
        RayfieldPro = {
            Background = Color3.fromRGB(22, 22, 28),
            Topbar = Color3.fromRGB(30, 30, 38),
            Accent = Color3.fromRGB(0, 170, 255),
            Text = Color3.fromRGB(245, 245, 247),
            ElementBg = Color3.fromRGB(38, 38, 48),
            ElementHover = Color3.fromRGB(48, 48, 60),
            ToggleOn = Color3.fromRGB(0, 170, 255),
            ToggleOff = Color3.fromRGB(85, 85, 95),
            SliderFill = Color3.fromRGB(0, 170, 255),
            Border = {Enabled = true, Color = Color3.fromRGB(55, 55, 65), Thickness = 1.2},
            CornerRadius = UDim.new(0, 12),
            Font = Enum.Font.GothamSemibold,
            Shadow = {Enabled = true, Transparency = 0.65, Blur = 12}
        }
    }
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function safeNew(class, props)
    local obj = Instance.new(class)
    if type(props) == "table" then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- 高级阴影
local function AddShadow(parent, theme)
    if not theme.Shadow or not theme.Shadow.Enabled then return end
    local shadow = safeNew("ImageLabel", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0, -12, 0, -12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = theme.Shadow.Transparency or 0.65,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50, 50, 450, 450),
        ZIndex = parent.ZIndex - 1,
        Parent = parent.Parent
    })
    parent:GetPropertyChangedSignal("Parent"):Connect(function()
        if not parent.Parent then pcall(shadow.Destroy, shadow) end
    end)
end

-- 主窗口
local function CreateWindow(options)
    options = options or {}
    local theme = YannCG.Themes[options.Theme] or YannCG.Themes.RayfieldPro
    if type(options.Theme) == "table" then theme = options.Theme end

    local ScreenGui = PlayerGui:FindFirstChild("YannCGStation") or safeNew("ScreenGui", {Name = "YannCGStation", ResetOnSpawn = false, Parent = PlayerGui})

    local MainFrame = safeNew("Frame", {
        Size = UDim2.new(0, 560, 0, 420),
        Position = UDim2.new(0.5, -280, 0.5, -210),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })

    AddShadow(MainFrame, theme)
    safeNew("UICorner", {CornerRadius = theme.CornerRadius, Parent = MainFrame})
    if theme.Border and theme.Border.Enabled then
        safeNew("UIStroke", {Color = theme.Border.Color, Thickness = theme.Border.Thickness, Parent = MainFrame})
    end

    -- 标题栏
    local Topbar = safeNew("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    safeNew("UICorner", {CornerRadius = theme.CornerRadius, Parent = Topbar})

    local Title = safeNew("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Name or "YannCG Station",
        TextColor3 = theme.Text,
        Font = theme.Font,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    local CloseBtn = safeNew("TextButton", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -46, 0, 6),
        BackgroundColor3 = Color3.fromRGB(255, 90, 90),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = Topbar
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 10), Parent = CloseBtn})

    -- 内容区
    local Content = safeNew("Frame", {
        Size = UDim2.new(1, -28, 1, -62),
        Position = UDim2.new(0, 14, 0, 56),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- 拖拽
    local dragging = false
    local dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() end) end)

    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local Tab = {}

        local TabBtn = safeNew("TextButton", {
            Size = UDim2.new(0, 120, 0, 40),
            Position = UDim2.new(0, (#Window.Tabs) * 125, 0, 0),
            BackgroundColor3 = theme.ElementBg,
            Text = name,
            TextColor3 = theme.Text,
            Font = theme.Font,
            TextSize = 15,
            Parent = Topbar
        })
        safeNew("UICorner", {CornerRadius = UDim.new(0, 10), Parent = TabBtn})

        local TabContent = safeNew("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Visible = false,
            Parent = Content,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        safeNew("UIListLayout", {Padding = UDim.new(0, 12), Parent = TabContent})

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

        -- Toggle（美观开关）
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local custom = cfg.Custom or {}
            local value = cfg.CurrentValue or false
            if cfg.Flag and YannCG.Flags[cfg.Flag] ~= nil then value = YannCG.Flags[cfg.Flag] end

            local frame = safeNew("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = theme.ElementBg,
                Parent = TabContent
            })
            safeNew("UICorner", {CornerRadius = UDim.new(0, 10), Parent = frame})

            local label = safeNew("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "开关",
                TextColor3 = custom.TextColor or theme.Text,
                Font = custom.Font or theme.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2.new(0, 16, 0, 0),
                Parent = frame
            })

            local switch = safeNew("TextButton", {
                Size = UDim2.new(0, 60, 0, 32),
                Position = UDim2.new(1, -76, 0.5, -16),
                BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff),
                Text = "",
                Parent = frame
            })
            safeNew("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

            local ball = safeNew("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = value and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = switch
            })
            safeNew("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ball})

            local function update()
                TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff)
                }):Play()
                TweenService:Create(ball, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                    Position = value and UDim2.new(1, -28, 0.5, -12) or UDim2.new(0, 4, 0.5, -12)
                }):Play()
                if cfg.Flag then YannCG.Flags[cfg.Flag] = value end
                if cfg.Callback then pcall(cfg.Callback, value) end
            end

            switch.MouseButton1Click:Connect(function()
                value = not value
                update()
            end)

            -- 悬停动画
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

-- 高级通知
function YannCG:Notify(info)
    local notif = safeNew("Frame", {
        Size = UDim2.new(0, 340, 0, 90),
        Position = UDim2.new(1, -360, 1, -110),
        BackgroundColor3 = Color3.fromRGB(32, 32, 40),
        Parent = PlayerGui:FindFirstChild("YannCGStation") or PlayerGui
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 14), Parent = notif})
    safeNew("UIStroke", {Color = Color3.fromRGB(70, 70, 80), Thickness = 1.5, Parent = notif})

    safeNew("TextLabel", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        Text = info.Title or "通知",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = notif
    })
    safeNew("TextLabel", {
        Size = UDim2.new(1, -24, 0, 34),
        Position = UDim2.new(0, 12, 0, 40),
        BackgroundTransparency = 1,
        Text = info.Content or "",
        TextColor3 = Color3.fromRGB(190, 190, 200),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = notif
    })

    notif.Position = UDim2.new(1, 20, 1, -110)
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -360, 1, -110)}):Play()
    task.wait(info.Duration or 3.5)
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 20, 1, -110)}):Play()
    task.wait(0.6)
    pcall(function() notif:Destroy() end)
end

YannCG.CreateWindow = CreateWindow
YannCG.LoadConfig = function() end

return YannCG
