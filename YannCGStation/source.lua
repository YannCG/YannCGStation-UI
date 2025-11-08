-- YannCGStation UI 1.0 - High Freedom + Smart Error Handling + Modular Effects
-- Author: YannCG
-- Load: loadstring(game:HttpGet('https://raw.githubusercontent.com/YannCG/YannCGStation-UI/main/YannCGStation/source.lua'))()

local YannCG = {
    Version = "1.0.0",
    Flags = {},
    Themes = {
        Default = {
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Accent = Color3.fromRGB(0, 170, 255),
            Text = Color3.fromRGB(255, 255, 255),
            ElementBg = Color3.fromRGB(35, 35, 35),
            ElementHover = Color3.fromRGB(45, 45, 45),
            ToggleOn = Color3.fromRGB(0, 170, 255),
            ToggleOff = Color3.fromRGB(100, 100, 100),
            SliderFill = Color3.fromRGB(0, 170, 255),
            Border = {Enabled = true, Color = Color3.fromRGB(50, 50, 50), Thickness = 1},
            CornerRadius = UDim.new(0, 6),
            Font = Enum.Font.Gotham
        }
    },
    Effects = {
        Breathing = {Enabled = false, Speed = 1.5, Intensity = 0.15},
        Particles = {Enabled = false, Rate = 10, Color = Color3.fromRGB(0, 170, 255)},
        Gradient = {Enabled = false, Colors = {Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 100, 255)}}
    }
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Safe service getter
local function safeGetService(name)
    local success, service = pcall(game.GetService, game, name)
    return success and service or nil
end

-- Safe instance creator with error-proof property setting
local function safeNew(class, props)
    local obj = Instance.new(class)
    if type(props) == "table" then
        for k, v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Apply modular effects
local function ApplyEffects(frame, theme, effects)
    if not frame or not effects then return end

    -- Breathing Light
    if effects.Breathing and effects.Breathing.Enabled then
        spawn(function()
            while frame and frame.Parent do
                local targetColor = Color3.new(
                    math.clamp(theme.Background.R + effects.Breathing.Intensity, 0, 1),
                    math.clamp(theme.Background.G + effects.Breathing.Intensity, 0, 1),
                    math.clamp(theme.Background.B + effects.Breathing.Intensity, 0, 1)
                )
                local tween = TweenService:Create(frame, TweenInfo.new(effects.Breathing.Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    BackgroundColor3 = targetColor
                })
                pcall(tween.Play, tween)
                task.wait(3)
            end
        end)
    end

    -- Particle System
    if effects.Particles and effects.Particles.Enabled then
        local attachment = safeNew("Attachment", {Parent = frame})
        local emitter = safeNew("ParticleEmitter", {
            Parent = attachment,
            Rate = effects.Particles.Rate or 10,
            Lifetime = NumberRange.new(1, 2),
            Speed = NumberRange.new(5, 10),
            Color = ColorSequence.new(effects.Particles.Color or theme.Accent),
            Transparency = NumberSequence.new(0.5, 1),
            Size = NumberSequence.new(0.2, 0),
            Texture = "rbxasset://textures/particles/sparkles.png",
            Enabled = true
        })
    end

    -- Gradient Background
    if effects.Gradient and effects.Gradient.Enabled then
        safeNew("UIGradient", {
            Parent = frame,
            Color = ColorSequence.new(effects.Gradient.Colors or {theme.Accent, theme.Accent})
        })
    end
end

-- Create Main Window
local function CreateWindow(options)
    options = options or {}
    local theme = YannCG.Themes[options.Theme] or YannCG.Themes.Default
    if type(options.Theme) == "table" then theme = options.Theme end
    local effects = options.Effects or YannCG.Effects

    -- Main Frame
    local MainFrame = safeNew("Frame", {
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.new(0.5, -260, 0.5, -190),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = PlayerGui:FindFirstChild("YannCGStation") or safeNew("ScreenGui", {Name = "YannCGStation", ResetOnSpawn = false, Parent = PlayerGui})
    })

    -- Corner Radius
    if theme.CornerRadius then
        safeNew("UICorner", {CornerRadius = theme.CornerRadius, Parent = MainFrame})
    end

    -- Border Stroke
    if theme.Border and theme.Border.Enabled then
        safeNew("UIStroke", {
            Color = theme.Border.Color,
            Thickness = theme.Border.Thickness or 1,
            Parent = MainFrame
        })
    end

    -- Apply Effects
    ApplyEffects(MainFrame, theme, effects)

    -- Title Bar
    local TitleBar = safeNew("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.Topbar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    safeNew("UICorner", {CornerRadius = theme.CornerRadius or UDim.new(0, 6), Parent = TitleBar})

    local Title = safeNew("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Name or "YannCG Hub",
        TextColor3 = theme.Text,
        Font = theme.Font or Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Close Button
    local CloseBtn = safeNew("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = TitleBar
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})
    CloseBtn.MouseButton1Click:Connect(function() pcall(function() MainFrame.Parent:Destroy() end) end)

    -- Content Area
    local Content = safeNew("Frame", {
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Dragging Support (PC + Mobile)
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
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

    -- Window Object
    local Window = {Tabs = {}, Theme = theme}

    function Window:CreateTab(name)
        local Tab = {Elements = {}}
        table.insert(Window.Tabs, Tab)

        -- Tab Button
        local TabBtn = safeNew("TextButton", {
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(0, (#Window.Tabs - 1) * 105, 0, 0),
            BackgroundColor3 = theme.ElementBg,
            Text = name,
            TextColor3 = theme.Text,
            Font = theme.Font or Enum.Font.Gotham,
            TextSize = 13,
            Parent = TitleBar
        })
        safeNew("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        -- Tab Content
        local TabContent = safeNew("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Visible = false,
            Parent = Content,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        local List = safeNew("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })

        -- Tab Switching
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

        if #Window.Tabs == 1 then
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = theme.Accent
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        Tab.Button = TabBtn
        Tab.Content = TabContent

        -- Toggle with Custom Support
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local custom = cfg.Custom or {}
            local value = cfg.CurrentValue or false
            if cfg.Flag and YannCG.Flags[cfg.Flag] ~= nil then value = YannCG.Flags[cfg.Flag] end

            local frame = safeNew("Frame", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Parent = TabContent
            })

            local label = safeNew("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Toggle",
                TextColor3 = custom.TextColor or theme.Text,
                Font = custom.Font or theme.Font or Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })

            local switch = safeNew("TextButton", {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -55, 0.5, -12.5),
                BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff),
                Text = "",
                Parent = frame
            })
            safeNew("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

            local function update()
                switch.BackgroundColor3 = value and (custom.OnColor or theme.ToggleOn) or (custom.OffColor or theme.ToggleOff)
                if cfg.Flag then YannCG.Flags[cfg.Flag] = value end
                if cfg.Callback then pcall(cfg.Callback, value) end
            end

            switch.MouseButton1Click:Connect(function()
                value = not value
                update()
            end)

            update()

            return {
                Set = function(v)
                    value = v
                    update()
                end,
                Get = function() return value end
            }
        end

        return Tab
    end

    return Window
end

-- Notification System
function YannCG:Notify(info)
    info = info or {}
    local notif = safeNew("Frame", {
        Size = UDim2.new(0, 300, 0, 70),
        Position = UDim2.new(1, -320, 1, -90),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Parent = PlayerGui:FindFirstChild("YannCGStation") or PlayerGui
    })
    safeNew("UICorner", {CornerRadius = UDim.new(0, 6), Parent = notif})

    safeNew("TextLabel", {
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Text = info.Title or "Notice",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        Parent = notif
    })
    safeNew("TextLabel", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 30),
        BackgroundTransparency = 1,
        Text = info.Content or "",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        Parent = notif
    })

    -- Slide in/out animation
    notif.Position = UDim2.new(1, 10, 1, -90)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -320, 1, -90)}):Play()
    task.wait(info.Duration or 3)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 1, -90)}):Play()
    task.wait(0.5)
    pcall(function() notif:Destroy() end)
end

-- Load Configuration (Placeholder - ready for file system)
function YannCG:LoadConfig()
    print("[YannCG] Configuration system ready (v2.0 Freedom Mode)")
end

-- Export API
YannCG.CreateWindow = CreateWindow
YannCG.LoadConfig = YannCG.LoadConfig

return YannCG
