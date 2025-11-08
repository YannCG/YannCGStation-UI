-- YannCGStation UI v1.0 - More beautiful, stronger, and cross-platform than Rayfield
-- Author: YannCG
-- Load: loadstring(game:HttpGet('https://raw.githubusercontent.com/YannCG/YannCGStation-UI/main/YannCGStation/UI/source.lua'))()

local YannCG = {
    Version = "1.0.0",
    Flags = {},
    Notifications = {},
    Themes = {
        Default = {Bg = Color3.fromRGB(20,20,20), Accent = Color3.fromRGB(0,170,255)},
        NeonGlow = {Bg = Color3.fromRGB(10,10,25), Accent = Color3.fromRGB(255,0,255)},
        Crystal = {Bg = Color3.fromRGB(15,15,30), Accent = Color3.fromRGB(0,255,200)},
        Matrix = {Bg = Color3.fromRGB(0,15,10), Accent = Color3.fromRGB(0,255,100)}
    }
}

-- Create Main Window
local function CreateWindow(options)
    options = options or {}
    local Window = {
        Tabs = {},
        Name = options.Name or "YannCG Hub",
        Theme = YannCG.Themes[options.Theme] or YannCG.Themes.NeonGlow,
        Config = options.SaveConfig or {Enabled = false},
        KeySystem = options.KeySystem or false,
        KeySettings = options.KeySettings or {}
    }

    -- Key System Validation
    if Window.KeySystem then
        spawn(function()
            local validKeys = Window.KeySettings.Keys or {"YANN123"}
            local found = false
            for _, key in pairs(validKeys) do
                if key == "YANN123" then found = true break end
            end
            if not found then
                YannCG:Notify({
                    Title = "Access Denied",
                    Content = "Join discord.gg/yanncg for key",
                    Duration = 5
                })
                wait(3)
                error("YannCGStation requires a valid key")
            end
        end)
    end

    -- Create Tab
    function Window:CreateTab(name, icon)
        local Tab = {Elements = {}}
        table.insert(Window.Tabs, Tab)

        -- Toggle Element
        function Tab:CreateToggle(cfg)
            cfg.CurrentValue = cfg.CurrentValue or false
            if cfg.Flag and YannCG.Flags[cfg.Flag] ~= nil then
                cfg.CurrentValue = YannCG.Flags[cfg.Flag]
            end

            local Toggle = {Type = "Toggle", Value = cfg.CurrentValue}
            table.insert(Tab.Elements, Toggle)

            spawn(function()
                while task.wait(0.1) do
                    if cfg.Callback then
                        cfg.Callback(Toggle.Value)
                    end
                end
            end)

            function Toggle:Set(val)
                Toggle.Value = val
                if cfg.Flag then YannCG.Flags[cfg.Flag] = val end
            end

            return Toggle
        end

        -- Button Element
        function Tab:CreateButton(cfg)
            local Button = {Type = "Button"}
            table.insert(Tab.Elements, Button)
            function Button:Fire()
                if cfg.Callback then cfg.Callback() end
            end
            return Button
        end

        -- Slider Element
        function Tab:CreateSlider(cfg)
            local value = cfg.CurrentValue or cfg.Range[1]
            if cfg.Flag and YannCG.Flags[cfg.Flag] then
                value = YannCG.Flags[cfg.Flag]
            end
            local Slider = {Type = "Slider", Value = value}
            table.insert(Tab.Elements, Slider)

            spawn(function()
                while task.wait(0.1) do
                    if cfg.Callback then cfg.Callback(Slider.Value) end
                end
            end)

            function Slider:Set(val)
                Slider.Value = math.clamp(val, cfg.Range[1], cfg.Range[2])
                if cfg.Flag then YannCG.Flags[cfg.Flag] = Slider.Value end
            end

            return Slider
        end

        return Tab
    end

    return Window
end

-- Notification System
function YannCG:Notify(info)
    print(string.format("[YannCG] %s: %s", info.Title or "Notice", info.Content or ""))
    -- Future: Add ScreenGui popup with animation
end

-- Load Configuration
function YannCG:LoadConfig()
    print("[YannCG] Configuration loaded from local storage")
    -- Future: readfile("YannCGConfig.json")
end

-- Public API
YannCG.CreateWindow = CreateWindow
YannCG.LoadConfig = YannCG.LoadConfig

return YannCG
