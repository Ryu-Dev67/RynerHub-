--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           BloxHub GUI Framework v3.4                      ║
    ║           Universal Roblox GUI System                     ║
    ║           Author: ArtChiveGroup (BloxHub Script)          ║
    ║           Pure Roblox Engine UI Components                ║
    ║           Cross-Device Compatible (PC/Mobile/Console)     ║
    ║                                                           ║
    ║           Copyright (C) 2026 ArtChiveGroup                ║
    ║           License: GNU GPL v3 — see the LICENSE file      ║
    ║           https://github.com/ArtChivegroup/BloxHubUILibs  ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- Hallmark · design pass v3.4 "Obsidian Glass" · scale: component tokens
-- tone: quiet luxury · accent: champagne gold (used sparingly) · material: dark glass
-- Added: glass surfaces, hairline strokes, tonal layering, refined motion.
-- Nothing public removed or renamed; downstream scripts keep working.

local BloxHub = {
    Version = "3.4.0",

    Core = {
        Initialized = false,
        ScreenGui = nil,
        MainContainer = nil,
        UIScale = nil
    },

    Elements = {},

    Settings = {
        Theme = {
            -- "Obsidian Glass" default palette: warm near-black glass with a
            -- champagne gold accent. Large surfaces stay near-opaque so text
            -- contrast holds over any game scene.
            Background = Color3.fromRGB(10, 10, 12),
            BackgroundGradient = Color3.fromRGB(17, 17, 20),
            Primary = Color3.fromRGB(19, 19, 22),
            PrimaryGradient = Color3.fromRGB(25, 25, 29),
            Secondary = Color3.fromRGB(28, 28, 32),
            SecondaryGradient = Color3.fromRGB(36, 36, 41),
            Accent = Color3.fromRGB(201, 169, 110),
            AccentGradient = Color3.fromRGB(224, 196, 140),
            AccentHover = Color3.fromRGB(235, 210, 160),
            Text = Color3.fromRGB(245, 243, 238),
            TextDim = Color3.fromRGB(158, 154, 146),
            Success = Color3.fromRGB(125, 195, 145),
            Warning = Color3.fromRGB(218, 182, 95),
            Error = Color3.fromRGB(205, 112, 98),
            Border = Color3.fromRGB(235, 232, 225),
            Shadow = Color3.fromRGB(0, 0, 0),
            -- Additive (v3.4.0): scrim color behind popups / modal surfaces
            Overlay = Color3.fromRGB(0, 0, 0)
        },
        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold,
        FontSemibold = Enum.Font.GothamSemibold,
        CornerRadius = {
            Large = 14,
            Medium = 10,
            Small = 8,
            XSmall = 6
        },
        Animation = {
            Speed = 0.2,
            FastSpeed = 0.1,
            Style = Enum.EasingStyle.Quint,
            Direction = Enum.EasingDirection.Out,
            -- Additive (v3.4.0): named duration stops used across components
            Micro = 0.12,
            Quick = 0.18,
            Smooth = 0.25
        },
        -- Additive design tokens used across components. Nothing here removes or
        -- renames an existing option, so downstream scripts keep working.
        Spacing = {
            XS = 4,
            SM = 6,
            MD = 8,
            LG = 12,
            XL = 16,
            XXL = 24
        },
        Type = {
            Caption = 12,
            Body = 13,
            BodyStrong = 14,
            -- Additive (v3.4.0): Title wires the window title, Section the
            -- notification title. Existing keys keep their values.
            Section = 15,
            Title = 16,
            Header = 17,
            Control = 22
        },
        UI = {
            StrokeEnabled = true,
            GradientEnabled = true,
            -- v3.4.0: shadow mati secara default (keputusan pemilik — dianggap
            -- mengganggu). Set true bila ingin bayangan window/popup opt-in.
            ShadowEnabled = false,
            ResponsiveScale = true
        }
    },

    State = {
        Windows = {},
        ActiveHotkeyListener = nil,
        DraggingElement = nil,
        SavedConfigs = {},
        Notifications = {},
        ThemeCallbacks = {},
        -- Additive (v3.3.0): dropdown z-order management
        DropdownOpenCount = 0,
        OrigDisplayOrder = nil,
        TopMost = false
    },

    Input = {
        Connections = {}
    },

    Device = {
        IsMobile = false,
        IsTablet = false,
        IsConsole = false,
        IsDesktop = true,
        TouchEnabled = false
    },

    Screen = {
        ViewportSize = Vector2.new(1920, 1080),
        Breakpoint = "desktop",
        Orientation = "landscape",
        Scale = 1,
        Hooks = {}
    }
}

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local ViewportSize = Vector2.new(1920, 1080)

local function GetViewportSize()
    local cam = workspace and workspace.CurrentCamera
    if cam and cam.ViewportSize and cam.ViewportSize.X > 0 then
        return cam.ViewportSize
    end
    return Vector2.new(1920, 1080)
end

-- ═══════════════════════════════════════════════════════════
-- DEVICE DETECTION
-- ═══════════════════════════════════════════════════════════
local function DetectDevice()
    local touchEnabled = UserInputService.TouchEnabled
    local keyboardEnabled = UserInputService.KeyboardEnabled
    local gamepadEnabled = UserInputService.GamepadEnabled
    local mouseEnabled = UserInputService.MouseEnabled

    BloxHub.Device.TouchEnabled = touchEnabled
    BloxHub.Device.IsMobile = touchEnabled and not keyboardEnabled and not mouseEnabled
    BloxHub.Device.IsTablet = touchEnabled and (keyboardEnabled or mouseEnabled)
    BloxHub.Device.IsConsole = gamepadEnabled and not keyboardEnabled and not mouseEnabled
    BloxHub.Device.IsDesktop = keyboardEnabled and mouseEnabled and not touchEnabled
end
DetectDevice()

-- ═══════════════════════════════════════════════════════════
-- CORE UTILITIES
-- ═══════════════════════════════════════════════════════════

local function Tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then return nil end
    duration = duration or BloxHub.Settings.Animation.Speed
    style = style or BloxHub.Settings.Animation.Style
    direction = direction or BloxHub.Settings.Animation.Direction

    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    pcall(function() tween:Play() end)
    return tween
end

-- Adds a connection to the global cleanup pool and returns it.
local function AddConnection(connection)
    if connection then
        table.insert(BloxHub.Input.Connections, connection)
    end
    return connection
end

-- Registers a theme refresh callback (called whenever the theme changes).
local function RegisterThemeCallback(cb)
    table.insert(BloxHub.State.ThemeCallbacks, cb)
    return cb
end

-- ═══════════════════════════════════════════════════════════
-- CLEAN-THREAD DISPATCHER (additive, v3.3.0)
-- ═══════════════════════════════════════════════════════════
-- Dibuat SATU KALI saat loadstring dieksekusi — sebelum script pemakai sempat
-- memanggil require modul game. Thread coroutine mewarisi capability saat
-- DIBUAT, bukan saat di-resume, jadi Instance.new di dalamnya tetap bersih
-- meskipun thread pemanggil sudah kehilangan capability ("lacking capability
-- Plugin" saat require dijalankan di tengah pembangunan UI).
-- Pola resume/yield ini SINKRON: tidak ada perubahan timing, urutan baris,
-- maupun return value dibanding eksekusi langsung. Bila dispatcher pernah
-- mati (seharusnya tidak terjadi), RunClean jatuh ke jalur lama: eksekusi
-- langsung di thread pemanggil = persis perilaku sebelum v3.3.0.
local __cleanThread = coroutine.create(function(fn, ...)
    local args = table.pack(fn, ...)
    while true do
        if type(args[1]) ~= "function" then
            args = table.pack(function()
                error("RunClean: job bukan fungsi", 0)
            end)
        end
        local results = table.pack(pcall(table.unpack(args, 1, args.n)))
        args = table.pack(coroutine.yield(table.unpack(results, 1, results.n)))
    end
end)

local function RunClean(fn, ...)
    local results = table.pack(coroutine.resume(__cleanThread, fn, ...))
    if not results[1] then
        -- dispatcher mati → jalur lama (perilaku legacy)
        return fn(...)
    end
    if not results[2] then
        -- fn error di dalam: re-raise PESAN ASLI tanpa menambah prefix posisi
        -- baru (level 0) supaya pesan yang ditangkap pcall pemanggil identik
        -- dengan perilaku legacy saat error langsung dari thread pemanggil.
        error(results[3], 0)
    end
    return table.unpack(results, 3, results.n)
end

-- ═══════════════════════════════════════════════════════════
-- DROPDOWN OPTIONS Z-ORDER (additive, v3.3.0)
-- ═══════════════════════════════════════════════════════════
-- Daftar opsi dropdown hidup di ScreenGui root milik framework. Selama ada
-- dropdown yang terbuka, DisplayOrder dinaikkan supaya daftar pasti berada
-- di atas ScreenGui lain milik script pemakai (overlay/pill buatan sendiri),
-- lalu dikembalikan saat dropdown terakhir ditutup — layering permanen tidak
-- berubah. Override eksplisit: BloxHub:SetTopMost(true).
local function RaiseOptionsLayer()
    local sg = BloxHub.Core.ScreenGui
    if not sg or BloxHub.State.TopMost then return end
    BloxHub.State.DropdownOpenCount = (BloxHub.State.DropdownOpenCount or 0) + 1
    if BloxHub.State.OrigDisplayOrder == nil then
        BloxHub.State.OrigDisplayOrder = sg.DisplayOrder
    end
    sg.DisplayOrder = math.max(sg.DisplayOrder, 10000)
end

local function RestoreOptionsLayer()
    local sg = BloxHub.Core.ScreenGui
    if not sg or BloxHub.State.TopMost then return end
    BloxHub.State.DropdownOpenCount = math.max((BloxHub.State.DropdownOpenCount or 1) - 1, 0)
    if (BloxHub.State.DropdownOpenCount or 0) == 0 and BloxHub.State.OrigDisplayOrder ~= nil then
        sg.DisplayOrder = BloxHub.State.OrigDisplayOrder
        BloxHub.State.OrigDisplayOrder = nil
    end
end

local function SafeSet(inst, prop, value)
    if not inst or not inst.Parent then return end
    pcall(function() inst[prop] = value end)
end

-- Recolor an interactive button for the current theme.
local function ThemeButton(btn, accent)
    if not btn or not btn.Parent then return end
    local T = BloxHub.Settings.Theme
    pcall(function()
        if accent then
            btn.BackgroundColor3 = T.Accent
            btn.TextColor3 = T.Text
        else
            btn.BackgroundColor3 = T.Secondary
            btn.TextColor3 = T.TextDim
        end
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = T.Border end
    end)
end

local function MakeDraggable(frame, dragHandle, owner)
    local dragging = false
    local dragInput, mousePos, framePos

    dragHandle = dragHandle or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local conn = AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end))

    if conn and owner then
        owner.Connections = owner.Connections or {}
        table.insert(owner.Connections, conn)
    end

    return conn
end

local function CreateUICorner(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or BloxHub.Settings.CornerRadius.Medium)
    corner.Parent = parent
    return corner
end

local function CreateUIPadding(left, right, top, bottom, parent)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
end

-- ═══════════════════════════════════════════════════════════
-- MODERN UI COMPONENTS (Roblox Engine Native)
-- ═══════════════════════════════════════════════════════════

local function CreateUIStroke(parent, color, thickness, transparency)
    if not BloxHub.Settings.UI.StrokeEnabled then return nil end
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or BloxHub.Settings.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = parent
    return stroke
end

local function CreateUIGradient(parent, color1, color2, rotation)
    if not BloxHub.Settings.UI.GradientEnabled then return nil end
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(220, 220, 220))
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

local function CreateShadow(parent, offset, transparency)
    if not BloxHub.Settings.UI.ShadowEnabled then return nil end
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, (offset or 4) - 2)
    shadow.BackgroundColor3 = BloxHub.Settings.Theme.Shadow
    shadow.BackgroundTransparency = transparency or 0.55
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    CreateUICorner(BloxHub.Settings.CornerRadius.Large + 6, shadow)
    shadow.Parent = parent.Parent
    return shadow
end

-- v3.4.0 "Obsidian Glass" material helpers (additive).
-- A glass surface = near-opaque dark fill + 1px hairline stroke + a faint
-- light catch along the top edge. Accents stay thin; fills stay quiet.

-- Hairline stroke: the only border language in v3.4.0.
local function Hairline(parent, transparency)
    return CreateUIStroke(parent, BloxHub.Settings.Theme.Border, 1, transparency or 0.86)
end

-- Faint top-edge light catch that sells the glass read.
local function GlassHighlight(parent, inset)
    local hl = Instance.new("Frame")
    hl.Name = "GlassHighlight"
    hl.Size = UDim2.new(1, inset and -(inset * 2) or -2, 0, 1)
    hl.Position = UDim2.new(0, inset or 1, 0, 0)
    hl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hl.BackgroundTransparency = 0.9
    hl.BorderSizePixel = 0
    hl.ZIndex = 2
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.3, 0.62),
        NumberSequenceKeypoint.new(1, 0.92)
    })
    g.Rotation = 0
    g.Parent = hl
    hl.Parent = parent
    return hl
end

-- Accent segment: a short rounded gold dash (quiet, not a full-width bar).
local function CreateAccentLine(parent, position)
    local line = Instance.new("Frame")
    line.Name = "AccentLine"
    line.Size = UDim2.new(0, 26, 0, 2)
    line.Position = position or UDim2.new(0, 0, 0, 0)
    line.BackgroundColor3 = BloxHub.Settings.Theme.Accent
    line.BorderSizePixel = 0
    CreateUICorner(BloxHub.Settings.CornerRadius.XSmall, line)
    line.Parent = parent
    return line
end

-- ═══════════════════════════════════════════════════════════
-- RESPONSIVE ENGINE (web-style media-query + density scaling)
-- ═══════════════════════════════════════════════════════════

-- Converts a "logical" pixel size into one scaled for the current screen.
function BloxHub:RP(px)
    local s = self.Screen.Scale
    if s == 1 then return px end
    return math.max(1, math.round(px * s))
end

-- Rebuild the screen telemetry each time the viewport changes.
function BloxHub:MeasureScreen()
    local vs = GetViewportSize()
    local w = vs.X

    local bp
    if self.Device.IsConsole then
        bp = "console"
    elseif self.Device.IsTablet then
        bp = "tablet"
    elseif self.Device.IsMobile then
        bp = "phone"
    else
        bp = "desktop"
    end

    self.Screen.ViewportSize = vs
    self.Screen.Breakpoint = bp
    self.Screen.Orientation = (w >= vs.Y) and "landscape" or "portrait"
    self.Screen.Ratio = w / math.max(vs.Y, 1)

    -- Density factor per breakpoint. Desktop stays 1:1 (pixels already read well);
    -- phones/tablets scale up so controls and text stay a usable size.
    local scale
    if bp == "phone" then
        scale = math.clamp(w / 360, 0.82, 1.35)
    elseif bp == "tablet" then
        scale = math.clamp(w / 768, 0.9, 1.4)
    else
        scale = 1
    end
    self.Screen.Scale = scale

    return self.Screen
end

-- Returns a fitted size for a window, clamped to the viewport.
function BloxHub:Fit(baseWidth, baseHeight)
    local vs = GetViewportSize()
    local S = (self.Screen.Scale == nil or self.Screen.Scale == 0) and 1 or self.Screen.Scale
    local w = math.min(baseWidth * S, vs.X * 0.92)
    local h = math.min(baseHeight * S, vs.Y * 0.85)
    return {
        Width = math.round(math.max(w, 220)),
        Height = math.round(math.max(h, 140)),
        ViewportW = vs.X,
        ViewportH = vs.Y
    }
end

local function GetAdaptiveSize(baseWidth, baseHeight)
    BloxHub:MeasureScreen()
    local fit = BloxHub:Fit(baseWidth, baseHeight)
    return UDim2.new(0, fit.Width, 0, fit.Height)
end

-- Re-flow every open window and notify external resize hooks.
function BloxHub:ResizeWindows()
    self:MeasureScreen()
    for _, window in pairs(self.State.Windows) do
        if window and window.Relayout then
            pcall(window.Relayout)
        end
    end
    for _, hook in ipairs(self.Screen.Hooks) do
        pcall(hook, self.Screen)
    end
end

-- Subscribe to viewport resize / orientation change. Returns a handle to disconnect.
function BloxHub:OnScreenChange(callback)
    table.insert(self.Screen.Hooks, callback)
    return {
        Disconnect = function()
            local i = table.find(self.Screen.Hooks, callback)
            if i then table.remove(self.Screen.Hooks, i) end
        end
    }
end

-- Pin framework ScreenGui di atas SEMUA ScreenGui milik script pemakai
-- (overlay, pill, dsb). Additive (v3.3.0). Panggil SetTopMost(false) untuk
-- mengembalikan DisplayOrder default (999). Tanpa ini, dropdown tetap
-- otomatis terangkat selama daftar terbuka (lihat RaiseOptionsLayer).
function BloxHub:SetTopMost(enabled)
    local sg = self.Core.ScreenGui
    if not sg then return end
    if enabled then
        if self.State.OrigDisplayOrder == nil then
            self.State.OrigDisplayOrder = sg.DisplayOrder
        end
        self.State.TopMost = true
        sg.DisplayOrder = math.max(sg.DisplayOrder, 10000)
    else
        self.State.TopMost = false
        if (self.State.DropdownOpenCount or 0) == 0 and self.State.OrigDisplayOrder ~= nil then
            sg.DisplayOrder = self.State.OrigDisplayOrder
            self.State.OrigDisplayOrder = nil
        end
    end
end

local function GetMousePosition()
    return UserInputService:GetMouseLocation()
end

local function GetKeyName(keyCode, inputType)
    if inputType == Enum.UserInputType.MouseButton1 then return "Mouse1"
    elseif inputType == Enum.UserInputType.MouseButton2 then return "Mouse2"
    elseif inputType == Enum.UserInputType.MouseButton3 then return "Mouse3"
    elseif keyCode then return keyCode.Name:gsub("Enum.KeyCode.", "")
    end
    return "None"
end

-- ═══════════════════════════════════════════════════════════
-- CORE INITIALIZATION
-- ═══════════════════════════════════════════════════════════

function BloxHub:Init()
    if self.Core.Initialized then
        return self
    end

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BloxHubFramework_" .. HttpService:GenerateGUID(false)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999

    -- Parent to appropriate location (exploit-environment safe)
    local targetParent = game:GetService("CoreGui")
    local ok, customParent = pcall(function()
        local env = getgenv and getgenv() or _G
        if type(env) == "table" then
            if env.gethui then
                return env.gethui()
            end
            if env.syn and env.syn.protect_gui then
                env.syn.protect_gui(screenGui)
            end
        end
        return nil
    end)
    if ok and customParent then
        targetParent = customParent
    end
    screenGui.Parent = targetParent

    self.Core.ScreenGui = screenGui
    self.Core.Initialized = true

    -- First pass of screen telemetry used by the responsive layout
    self:MeasureScreen()

    -- Watch the viewport and re-flow on resize / orientation change.
    self.Screen.Watch = RunService.RenderStepped:Connect(function()
        local vs = GetViewportSize()
        if vs ~= self.Screen.ViewportSize then
            self:ResizeWindows()
        end
    end)
    AddConnection(self.Screen.Watch)

    -- Setup input handling
    self:SetupInputHandling()

    -- Load saved config
    self:LoadConfig()

    return self
end

function BloxHub:SetupInputHandling()
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- Handle hotkey listening mode
        if self.State.ActiveHotkeyListener then
            local keyName = GetKeyName(input.KeyCode, input.UserInputType)
            local callback = self.State.ActiveHotkeyListener.Callback
            local button = self.State.ActiveHotkeyListener.Button

            if button and button.Parent then
                button.Text = keyName
            end

            if callback then
                pcall(callback, input.KeyCode, input.UserInputType, keyName)
            end

            self.State.ActiveHotkeyListener = nil
            return
        end

        -- Handle registered hotkeys
        for _, window in pairs(self.State.Windows) do
            if window.Hotkeys then
                for _, hotkey in pairs(window.Hotkeys) do
                    if hotkey.Enabled and
                       ((hotkey.KeyCode and input.KeyCode == hotkey.KeyCode) or
                        (hotkey.InputType and input.UserInputType == hotkey.InputType)) then
                        if hotkey.Callback then
                            pcall(hotkey.Callback)
                        end
                    end
                end
            end
        end
    end)

    AddConnection(connection)
end

function BloxHub:Destroy()
    for _, conn in ipairs(self.Input.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Input.Connections = {}

    for _, window in pairs(self.State.Windows) do
        if window.Connections then
            for _, conn in ipairs(window.Connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
    end

    if self.Core.ScreenGui then
        pcall(function() self.Core.ScreenGui:Destroy() end)
        self.Core.ScreenGui = nil
    end

    self.Core.Initialized = false
    self.State.Windows = {}
    self.State.Notifications = {}
    self.State.ThemeCallbacks = {}
    self.Screen.Hooks = {}
    if self.Screen.Watch then
        pcall(function() self.Screen.Watch:Disconnect() end)
        self.Screen.Watch = nil
    end
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW API
-- ═══════════════════════════════════════════════════════════

-- Implementasi CreateWindow dijalankan lewat RunClean (thread bersih) agar
-- pembuatan Instance tetap aman bila thread pemanggil kehilangan capability
-- (lihat catatan CLEAN-THREAD DISPATCHER di atas). Signature & perilaku tidak
-- berubah dari versi sebelumnya.
local function CreateWindowImpl(self, title, config)
    config = config or {}

    local baseWidth = config.Size and config.Size.X.Offset or 550
    local baseHeight = config.Size and config.Size.Y.Offset or 450
    local adaptiveSize = GetAdaptiveSize(baseWidth, baseHeight)

    local window = {
        Title = title or "BloxHub Window",
        BaseWidth = baseWidth,
        BaseHeight = baseHeight,
        Size = adaptiveSize,
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        Resizable = config.Resizable or false,
        MinSize = config.MinSize or UDim2.new(0, 320, 0, 200),
        Visible = config.Visible ~= false,
        Minimized = false,
        Tabs = {},
        CurrentTab = nil,
        Elements = {},
        MiniWidgets = {},
        Hotkeys = {},
        Connections = {},
        ID = HttpService:GenerateGUID(false)
    }

    -- Main container with AnchorPoint centering
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window_" .. window.ID
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = window.Size
    mainFrame.Position = window.Position
    mainFrame.BackgroundColor3 = self.Settings.Theme.Background
    mainFrame.BackgroundTransparency = 0.12 -- glass: a hint of the scene behind
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Visible = window.Visible
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = self.Core.ScreenGui

    CreateUICorner(self.Settings.CornerRadius.Large, mainFrame)
    Hairline(mainFrame, 0.86)

    if self.Settings.UI.GradientEnabled then
        local bgGradient = Instance.new("UIGradient")
        bgGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.Settings.Theme.Background),
            ColorSequenceKeypoint.new(1, self.Settings.Theme.BackgroundGradient)
        })
        bgGradient.Rotation = 135
        bgGradient.Parent = mainFrame
    end
    GlassHighlight(mainFrame, 1)

    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "Shadow"
    shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowFrame.BackgroundColor3 = self.Settings.Theme.Shadow
    shadowFrame.BackgroundTransparency = self.Settings.UI.ShadowEnabled and 0.55 or 1
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = -1
    CreateUICorner(self.Settings.CornerRadius.Large + 6, shadowFrame)
    shadowFrame.Parent = self.Core.ScreenGui

    -- FIX v3.4.0: bayangan window harus berukuran window + 20px (piksel),
    -- BUKAN skala relatif ke ScreenGui — ukuran (1,20) relatif ke root
    -- berarti seluas layar penuh (tirai hitam menutupi seluruh scene).
    -- Bayangan juga mengikuti posisi window saat didrag/dipindah/diresize.
    local function SyncShadow()
        shadowFrame.AnchorPoint = mainFrame.AnchorPoint
        shadowFrame.Size = UDim2.new(
            mainFrame.Size.X.Scale, mainFrame.Size.X.Offset + 20,
            mainFrame.Size.Y.Scale, mainFrame.Size.Y.Offset + 20
        )
        shadowFrame.Position = UDim2.new(
            mainFrame.Position.X.Scale, mainFrame.Position.X.Offset,
            mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 8
        )
    end
    SyncShadow()
    table.insert(window.Connections, mainFrame:GetPropertyChangedSignal("Position"):Connect(SyncShadow))
    table.insert(window.Connections, mainFrame:GetPropertyChangedSignal("Size"):Connect(SyncShadow))
    table.insert(window.Connections, mainFrame:GetPropertyChangedSignal("AnchorPoint"):Connect(SyncShadow))

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = self.Settings.Theme.Background
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "Logo"
    logoContainer.Size = UDim2.new(0, 24, 0, 24)
    logoContainer.Position = UDim2.new(0, 14, 0.5, -12)
    logoContainer.BackgroundColor3 = self.Settings.Theme.Secondary
    logoContainer.BackgroundTransparency = 0.55
    logoContainer.BorderSizePixel = 0
    logoContainer.Parent = header
    CreateUICorner(self.Settings.CornerRadius.XSmall, logoContainer)
    CreateUIStroke(logoContainer, self.Settings.Theme.Accent, 1, 0.55)

    -- Rotated square = diamond mark. One accent, kept small and quiet.
    local logoDot = Instance.new("Frame")
    logoDot.Size = UDim2.new(0, 7, 0, 7)
    logoDot.Position = UDim2.new(0.5, -3.5, 0.5, -3.5)
    logoDot.Rotation = 45
    logoDot.BackgroundColor3 = self.Settings.Theme.Accent
    logoDot.BorderSizePixel = 0
    logoDot.Parent = logoContainer

    -- Quiet rule across the header with a short gold dash at the left.
    local headerRule = Instance.new("Frame")
    headerRule.Name = "HeaderRule"
    headerRule.Size = UDim2.new(1, 0, 0, 1)
    headerRule.Position = UDim2.new(0, 0, 1, -1)
    headerRule.BackgroundColor3 = self.Settings.Theme.Border
    headerRule.BackgroundTransparency = 0.9
    headerRule.BorderSizePixel = 0
    headerRule.Parent = header

    CreateAccentLine(header, UDim2.new(0, 14, 1, -2))

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, 48, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = window.Title
    titleLabel.TextColor3 = self.Settings.Theme.Text
    titleLabel.TextSize = self.Settings.Type.Title
    titleLabel.Font = self.Settings.FontSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local btnSize = BloxHub.Device.IsMobile and 32 or 28
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    minimizeBtn.Position = UDim2.new(1, -btnSize - 12, 0.5, -btnSize/2)
    minimizeBtn.BackgroundColor3 = self.Settings.Theme.Secondary
    minimizeBtn.BackgroundTransparency = 1 -- ghost: the surface appears on hover
    minimizeBtn.Text = ""
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header

    CreateUICorner(self.Settings.CornerRadius.Small, minimizeBtn)
    local minStroke = CreateUIStroke(minimizeBtn, self.Settings.Theme.Border, 1, 1)

    local minIcon = Instance.new("Frame")
    minIcon.Size = UDim2.new(0, 12, 0, 2)
    minIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    minIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    minIcon.BackgroundColor3 = self.Settings.Theme.TextDim
    minIcon.BorderSizePixel = 0
    minIcon.Parent = minimizeBtn
    CreateUICorner(2, minIcon)

    -- Opsi MinimizeButton (additive v3.3.0): tombol header memakai jalur
    -- Minimize/Restore resmi (ikon melayang sebagai restore). Default tetap
    -- Toggle seperti sebelumnya — script lama tidak berubah perilaku.
    minimizeBtn.MouseButton1Click:Connect(function()
        if config.MinimizeButton then
            window:Minimize()
        else
            window:Toggle()
        end
    end)

    minimizeBtn.MouseEnter:Connect(function()
        Tween(minimizeBtn, {BackgroundColor3 = self.Settings.Theme.Secondary, BackgroundTransparency = 0.25}, BloxHub.Settings.Animation.Quick)
        Tween(minIcon, {BackgroundColor3 = self.Settings.Theme.Text}, BloxHub.Settings.Animation.Quick)
        if minStroke then minStroke.Transparency = 0.88 end
    end)

    minimizeBtn.MouseLeave:Connect(function()
        Tween(minimizeBtn, {BackgroundTransparency = 1}, BloxHub.Settings.Animation.Quick)
        Tween(minIcon, {BackgroundColor3 = self.Settings.Theme.TextDim}, BloxHub.Settings.Animation.Quick)
        if minStroke then minStroke.Transparency = 1 end
    end)

    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -24, 0, 40)
    tabContainer.Position = UDim2.new(0, 12, 0, 58)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Parent = tabContainer

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -24, 1, -115)
    contentContainer.Position = UDim2.new(0, 12, 0, 105)
    contentContainer.BackgroundColor3 = self.Settings.Theme.Primary
    contentContainer.BackgroundTransparency = 0.35 -- glass layer: scene shows through
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame

    CreateUICorner(self.Settings.CornerRadius.Medium, contentContainer)
    Hairline(contentContainer, 0.88)

    MakeDraggable(mainFrame, header, window)

    window.Frame = mainFrame
    window.Header = header
    window.Shadow = shadowFrame
    window.TabContainer = tabContainer
    window.ContentContainer = contentContainer

    -- Window resize (bottom-right handle)
    if window.Resizable then
        local handle = Instance.new("TextButton")
        handle.Name = "ResizeHandle"
        handle.Size = UDim2.new(0, 26, 0, 26)
        handle.Position = UDim2.new(1, -13, 1, -13)
        handle.BackgroundColor3 = self.Settings.Theme.Secondary
        handle.BackgroundTransparency = 0.55
        handle.Text = ""
        handle.AutoButtonColor = false
        handle.Active = true
        handle.Parent = mainFrame

        CreateUICorner(self.Settings.CornerRadius.Small, handle)
        Hairline(handle, 0.9)

        -- Diagonal grip (three dots rising to the corner) signals "resizable"
        local gripPositions = { {6, 6}, {11, 11}, {16, 16} }
        for _, p in ipairs(gripPositions) do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 3, 0, 3)
            dot.Position = UDim2.new(0, p[1], 0, p[2])
            dot.BackgroundColor3 = self.Settings.Theme.TextDim
            dot.BorderSizePixel = 0
            dot.ZIndex = handle.ZIndex + 1
            dot.Parent = handle
            CreateUICorner(2, dot)
        end

        -- Hover hint so desktop users know the corner is a resize grip
        local hint = Instance.new("TextLabel")
        hint.Name = "ResizeHint"
        hint.BackgroundColor3 = self.Settings.Theme.Secondary
        hint.BackgroundTransparency = 0.08
        hint.Text = "Drag to resize"
        hint.Font = self.Settings.Font
        hint.TextSize = BloxHub.Settings.Type.Caption
        hint.TextColor3 = self.Settings.Theme.Text
        hint.AnchorPoint = Vector2.new(1, 0)
        hint.Position = UDim2.new(1, -30, 1, 4)
        hint.ZIndex = handle.ZIndex + 2
        hint.Visible = false
        hint.Parent = handle
        CreateUICorner(BloxHub.Settings.CornerRadius.Small, hint)
        Hairline(hint, 0.9)

        handle.MouseEnter:Connect(function()
            Tween(handle, {BackgroundTransparency = 0.15}, BloxHub.Settings.Animation.Micro)
            if not BloxHub.Device.IsMobile then hint.Visible = true end
        end)
        handle.MouseLeave:Connect(function()
            Tween(handle, {BackgroundTransparency = 0.55}, BloxHub.Settings.Animation.Micro)
            hint.Visible = false
        end)

        local resizing = false
        local startSize, startMouse

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                startSize = window.Frame.AbsoluteSize
                startMouse = input.Position
            end
        end)

        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)

        local resizeConn = AddConnection(UserInputService.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and
               input.UserInputType ~= Enum.UserInputType.Touch then return end

            local delta = input.Position - startMouse
            local newX = math.max(startSize.X + delta.X, window.MinSize.X.Offset)
            local newY = math.max(startSize.Y + delta.Y, window.MinSize.Y.Offset)

            window.Size = UDim2.new(0, newX, 0, newY)
            window.Frame.Size = window.Size

            -- Re-sync child layouts relative to the resized window
            contentContainer.Size = UDim2.new(1, -24, 1, -115)
        end))
        table.insert(window.Connections, resizeConn)
    end

    -- Window methods
    function window:Relayout()
        if not self.Frame or not self.Frame.Parent then return end
        local fit = BloxHub:Fit(self.BaseWidth, self.BaseHeight)

        -- Keep a manual resize if it still fits; otherwise drop to the fitted size.
        local cur = self.Frame.AbsoluteSize
        local w = (cur.X > 0) and math.min(cur.X, fit.Width) or fit.Width
        local h = (cur.Y > 0) and math.min(cur.Y, fit.Height) or fit.Height
        w = math.max(w, 220)
        h = math.max(h, 140)

        self.Size = UDim2.new(0, w, 0, h)
        self.Frame.Size = self.Size
        if contentContainer then contentContainer.Size = UDim2.new(1, -24, 1, -115) end

        -- Pull the window back on-screen if the viewport shrank.
        local vsW, vsH = fit.ViewportW, fit.ViewportH
        local p = self.Frame.AbsolutePosition
        local shiftX, shiftY = 0, 0
        if p.X < 0 then shiftX = -p.X end
        if p.Y < 0 then shiftY = -p.Y end
        if p.X + w > vsW then shiftX = vsW - (p.X + w) end
        if p.Y + h > vsH then shiftY = vsH - (p.Y + h) end
        if shiftX ~= 0 or shiftY ~= 0 then
            local pos = self.Frame.Position
            self.Frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + shiftX, pos.Y.Scale, pos.Y.Offset + shiftY)
        end
    end

    window:Relayout()

    function window:Toggle()
        self.Visible = not self.Visible
        -- Window yang kembali tampil otomatis dianggap tidak minimized;
        -- hanya menulis field baru (v3.3.0), script lama tidak membacanya.
        if self.Visible then
            self.Minimized = false
            self:Show() -- Show menegaskan state yang sama + animasi masuk
        else
            self:Hide()
        end
    end

    function window:Show()
        self.Visible = true
        self.Minimized = false
        self.Frame.Visible = true
        if self.Shadow then self.Shadow.Visible = true end
        if self.FloatingIcon then self.FloatingIcon.Visible = false end
        -- v3.4.0 entrance (visual only; end state identical to before)
        pcall(function()
            local s = self.Frame:FindFirstChild("WindowScale")
            if not s then
                s = Instance.new("UIScale")
                s.Name = "WindowScale"
                s.Parent = self.Frame
            end
            s.Scale = 0.965
            Tween(s, {Scale = 1}, BloxHub.Settings.Animation.Quick)
        end)
    end

    -- Hide tetap instan: script lama mengandalkan flip visibility langsung
    -- (re-run cleanup, hotkey toggle), jadi hanya Show yang dianimasikan.
    function window:Hide()
        self.Visible = false
        self.Frame.Visible = false
        if self.Shadow then self.Shadow.Visible = false end
        if self.FloatingIcon then self.FloatingIcon.Visible = true end
    end

    -- Minimize/restore bawaan (additive v3.3.0). Minimize menyembunyikan
    -- window dan memunculkan ikon melayang (BloxHub:CreateFloatingIcon)
    -- sebagai jalur restore resmi; Restore mengembalikannya. Script tidak
    -- perlu lagi membuat pill minimize sendiri.
    function window:Minimize()
        -- Selalu terapkan state (idempoten) agar aman walau dipanggil
        -- setelah Toggle/Hide dari hotkey script.
        self.Minimized = true
        if not self.FloatingIcon then
            BloxHub:CreateFloatingIcon(self, { ShowOnMinimize = true })
        end
        self:Hide()
    end

    function window:Restore()
        if not self.Minimized then return end
        self.Minimized = false
        self:Show()
    end

    function window:IsMinimized()
        return self.Minimized
    end

    function window:SetTitle(newTitle)
        self.Title = newTitle
        titleLabel.Text = newTitle
    end

    function window:SetSize(width, height)
        self.Size = UDim2.new(0, width, 0, height)
        self.Frame.Size = self.Size
    end

    function window:SetPosition(pos)
        self.Position = pos
        self.Frame.Position = pos
    end

    function window:Destroy()
        for _, conn in ipairs(self.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        if self.MiniWidgets then
            for _, mw in ipairs(self.MiniWidgets) do
                pcall(function() mw:Destroy() end)
            end
        end
        if self.Frame then pcall(function() self.Frame:Destroy() end) end
        if self.Shadow then pcall(function() self.Shadow:Destroy() end) end
        if self.FloatingIcon then pcall(function() self.FloatingIcon:Destroy() end) end
        BloxHub.State.Windows[self.ID] = nil
    end

    function window:CreateTab(tabName)
        return RunClean(BloxHub.Elements.CreateTab, BloxHub.Elements, self, tabName)
    end

    function window:CreatePopup(title, options)
        return RunClean(BloxHub.Elements.CreatePopup, BloxHub.Elements, self, title, options)
    end

    -- Widget mini / compact mode (additive v3.3.0): kontrol cepat tanpa
    -- membuka window penuh. Lihat BloxHub:CreateMiniWidget untuk format Rows.
    -- FIX v3.4.0: wrapper lama mengirim window ke slot implicit-self, jadi
    -- self.Settings.Theme selalu error — jalur ini belum pernah berhasil.
    function window:CreateMiniWidget(config)
        local widget = RunClean(BloxHub.CreateMiniWidget, BloxHub, self, config)
        table.insert(self.MiniWidgets, widget)
        return widget
    end

    function window:RegisterHotkey(name, keyCode, callback)
        self.Hotkeys[name] = {
            KeyCode = keyCode,
            Callback = callback,
            Enabled = true
        }
        return {
            Enabled = true,
            Disable = function() self.Hotkeys[name].Enabled = false end,
            Enable = function() self.Hotkeys[name].Enabled = true end
        }
    end

    -- Theme refresh for the window shell
    RegisterThemeCallback(function()
        if not window.Frame or not window.Frame.Parent then return end
        local T = BloxHub.Settings.Theme
        pcall(function()
            window.Frame.BackgroundColor3 = T.Background
            contentContainer.BackgroundColor3 = T.Primary
            -- keep the glass gradient in sync (it used to stay stale on theme change)
            local bgGrad = mainFrame:FindFirstChildOfClass("UIGradient")
            if bgGrad then
                bgGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.Background),
                    ColorSequenceKeypoint.new(1, T.BackgroundGradient)
                })
            end
            local stroke = window.Frame:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = T.Border end
            local contentStroke = contentContainer:FindFirstChildOfClass("UIStroke")
            if contentStroke then contentStroke.Color = T.Border end
            -- logo: gold ring + diamond
            local logoStroke = logoContainer:FindFirstChildOfClass("UIStroke")
            if logoStroke then logoStroke.Color = T.Accent end
            SafeSet(logoDot, "BackgroundColor3", T.Accent)
            SafeSet(titleLabel, "TextColor3", T.Text)
            -- recolor tabs: quiet surfaces, accent lives in the underline/text
            if window.Tabs then
                for _, tb in ipairs(window.Tabs) do
                    if tb and tb.Button then
                        SafeSet(tb.Button, "BackgroundColor3", T.Background)
                        SafeSet(tb.Button, "TextColor3", tb.Active and T.Text or T.TextDim)
                    end
                    if tb and tb.Indicator then SafeSet(tb.Indicator, "BackgroundColor3", T.Accent) end
                end
            end
            -- accent segment + header rule
            local accentLine = header:FindFirstChild("AccentLine")
            if accentLine then SafeSet(accentLine, "BackgroundColor3", T.Accent) end
            SafeSet(headerRule, "BackgroundColor3", T.Border)
        end)
    end)

    self.State.Windows[window.ID] = window

    return window
end

function BloxHub:CreateWindow(title, config)
    return RunClean(CreateWindowImpl, self, title, config)
end

-- ═══════════════════════════════════════════════════════════
-- ELEMENTS API
-- ═══════════════════════════════════════════════════════════

function BloxHub.Elements:CreateTab(window, tabName)
    local tab = {
        Name = tabName,
        Window = window,
        Active = false,
        Elements = {},
        Container = nil
    }

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. tabName
    tabBtn.Size = UDim2.new(0, BloxHub.Device.IsMobile and 90 or 110, 0, 32)
    tabBtn.BackgroundTransparency = 1 -- quiet tab: no pill, the accent lives in the underline
    tabBtn.BackgroundColor3 = BloxHub.Settings.Theme.Background -- base for the hover tint
    tabBtn.Text = tabName
    tabBtn.TextColor3 = BloxHub.Settings.Theme.TextDim
    tabBtn.TextSize = BloxHub.Device.IsMobile and BloxHub.Settings.Type.Caption or BloxHub.Settings.Type.Body
    tabBtn.Font = BloxHub.Settings.FontSemibold
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = window.TabContainer

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.AnchorPoint = Vector2.new(0.5, 1)
    indicator.Size = UDim2.new(0.4, 0, 0, 2)
    indicator.Position = UDim2.new(0.5, 0, 1, -3)
    indicator.BackgroundColor3 = BloxHub.Settings.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    CreateUICorner(2, indicator)
    indicator.Parent = tabBtn

    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "TabContent_" .. tabName
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 3
    contentFrame.ScrollBarImageColor3 = BloxHub.Settings.Theme.TextDim
    contentFrame.ScrollBarImageTransparency = 0.55
    contentFrame.ScrollBarImageTransparency = 0.3
    contentFrame.BorderSizePixel = 0
    contentFrame.Visible = false
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = window.ContentContainer

    CreateUIPadding(BloxHub.Settings.Spacing.MD, BloxHub.Settings.Spacing.MD, BloxHub.Settings.Spacing.MD, BloxHub.Settings.Spacing.MD, contentFrame)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame

    tab.Button = tabBtn
    tab.Indicator = indicator
    tab.Container = contentFrame

    tabBtn.MouseButton1Click:Connect(function() tab:Activate() end)

    tabBtn.MouseEnter:Connect(function()
        if not tab.Active then
            Tween(tabBtn, {BackgroundColor3 = BloxHub.Settings.Theme.Background, BackgroundTransparency = 0.55}, BloxHub.Settings.Animation.Micro)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if not tab.Active then
            Tween(tabBtn, {BackgroundTransparency = 1}, BloxHub.Settings.Animation.Micro)
        end
    end)

    function tab:Activate()
        for _, otherTab in pairs(self.Window.Tabs) do
            otherTab.Active = false
            otherTab.Container.Visible = false
            otherTab.Indicator.Visible = false
            Tween(otherTab.Button, {
                BackgroundColor3 = BloxHub.Settings.Theme.Background,
                BackgroundTransparency = 1,
                TextColor3 = BloxHub.Settings.Theme.TextDim
            }, BloxHub.Settings.Animation.Micro)
        end

        self.Active = true
        self.Container.Visible = true
        self.Indicator.Visible = true
        self.Window.CurrentTab = self
        Tween(self.Button, {
            BackgroundColor3 = BloxHub.Settings.Theme.Background,
            BackgroundTransparency = 1,
            TextColor3 = BloxHub.Settings.Theme.Text
        }, BloxHub.Settings.Animation.Micro)
        -- the underline grows in under the active tab
        self.Indicator.Size = UDim2.new(0, 0, 0, 2)
        Tween(self.Indicator, {Size = UDim2.new(0.4, 0, 0, 2)}, BloxHub.Settings.Animation.Quick)
    end

    -- Semua Add* dijalankan lewat RunClean (thread bersih) — lihat catatan
    -- CLEAN-THREAD DISPATCHER. Signature & return value tidak berubah.
    function tab:AddButton(text, callback) return RunClean(BloxHub.Elements.CreateButton, BloxHub.Elements, self, text, callback) end
    function tab:AddToggle(text, default, callback) return RunClean(BloxHub.Elements.CreateToggle, BloxHub.Elements, self, text, default, callback) end
    function tab:AddSlider(text, min, max, default, callback) return RunClean(BloxHub.Elements.CreateSlider, BloxHub.Elements, self, text, min, max, default, callback) end
    function tab:AddKeybind(text, defaultKey, callback) return RunClean(BloxHub.Elements.CreateKeybind, BloxHub.Elements, self, text, defaultKey, callback) end
    function tab:AddDropdown(text, options, callback) return RunClean(BloxHub.Elements.CreateDropdown, BloxHub.Elements, self, text, options, callback) end
    function tab:AddTextBox(text, placeholder, callback) return RunClean(BloxHub.Elements.CreateTextBox, BloxHub.Elements, self, text, placeholder, callback) end
    function tab:AddLabel(text, config) return RunClean(BloxHub.Elements.CreateLabel, BloxHub.Elements, self, text, config) end
    function tab:AddDivider() return RunClean(BloxHub.Elements.CreateDivider, BloxHub.Elements, self) end

    table.insert(window.Tabs, tab)

    if #window.Tabs == 1 then
        tab:Activate()
    end

    return tab
end

--- Generic row container helper (shared by most components)
local function RowContainer(tab, name, height)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, height)
    container.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    container.BackgroundTransparency = 0.4 -- glass layer
    container.BorderSizePixel = 0
    container.Parent = tab.Container

    CreateUICorner(BloxHub.Settings.CornerRadius.Small, container)
    Hairline(container, 0.88)

    return container
end

function BloxHub.Elements:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(1, 0, 0, BloxHub:RP(BloxHub.Device.IsMobile and 42 or 38))
    button.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    button.BackgroundTransparency = 0.4 -- glass layer
    button.Text = text
    button.TextColor3 = BloxHub.Settings.Theme.Text
    button.TextSize = BloxHub.Device.IsMobile and BloxHub.Settings.Type.Body or BloxHub.Settings.Type.BodyStrong
    button.Font = BloxHub.Settings.FontSemibold
    button.AutoButtonColor = false
    button.Parent = tab.Container

    CreateUICorner(BloxHub.Settings.CornerRadius.Small, button)
    local btnStroke = Hairline(button, 0.88)

    button.MouseButton1Click:Connect(function()
        Tween(button, {Size = UDim2.new(1, -4, 0, BloxHub.Device.IsMobile and 40 or 36)}, 0.05)
        task.delay(0.05, function()
            Tween(button, {Size = UDim2.new(1, 0, 0, BloxHub:RP(BloxHub.Device.IsMobile and 42 or 38))}, BloxHub.Settings.Animation.FastSpeed)
        end)
        if callback then pcall(callback) end
    end)

    -- Quiet hover: the surface lifts one tonal step and the hairline turns
    -- gold — never a full accent fill.
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro)
        if btnStroke then
            btnStroke.Color = BloxHub.Settings.Theme.Accent
            btnStroke.Transparency = 0.55
        end
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = BloxHub.Settings.Theme.Secondary}, BloxHub.Settings.Animation.Micro)
        if btnStroke then
            btnStroke.Color = BloxHub.Settings.Theme.Border
            btnStroke.Transparency = 0.88
        end
    end)

    RegisterThemeCallback(function()
        if not button.Parent then return end
        local T = BloxHub.Settings.Theme
        pcall(function()
            button.BackgroundColor3 = T.Secondary
            button.TextColor3 = T.Text
            if btnStroke then
                btnStroke.Color = T.Border
                btnStroke.Transparency = 0.88
            end
        end)
    end)

    return button
end

function BloxHub.Elements:CreateToggle(tab, text, default, callback)
    local toggleState = default or false

    local container = RowContainer(tab, "Toggle_" .. text, BloxHub:RP(BloxHub.Device.IsMobile and 42 or 38))

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -65, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = BloxHub.Settings.Theme.Text
    label.TextSize = BloxHub.Device.IsMobile and 13 or 14
    label.Font = BloxHub.Settings.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = toggleState and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.Primary
    switch.BackgroundTransparency = toggleState and 0.1 or 0.35
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = container

    CreateUICorner(11, switch) -- pill: radius = half the track height
    local switchStroke = CreateUIStroke(switch, toggleState and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.Border, 1, toggleState and 0.4 or 0.88)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = toggleState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(250, 248, 244)
    knob.BorderSizePixel = 0
    knob.Parent = switch

    CreateUICorner(9, knob)

    local knobShadow = Instance.new("Frame")
    knobShadow.Size = UDim2.new(1, 2, 1, 2)
    knobShadow.Position = UDim2.new(0, -1, 0, 1)
    knobShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.75
    knobShadow.ZIndex = knob.ZIndex - 1
    CreateUICorner(9, knobShadow)
    knobShadow.Parent = switch

    local function setToggleState(state)
        toggleState = state
        local T = BloxHub.Settings.Theme

        Tween(switch, {
            BackgroundColor3 = toggleState and T.Accent or T.Primary,
            BackgroundTransparency = toggleState and 0.1 or 0.35
        }, BloxHub.Settings.Animation.Micro)

        if switchStroke then
            Tween(switchStroke, {
                Color = toggleState and T.Accent or T.Border,
                Transparency = toggleState and 0.4 or 0.88
            }, BloxHub.Settings.Animation.Micro)
        end

        Tween(knob, {
            Position = toggleState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }, BloxHub.Settings.Animation.Micro, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        if callback then pcall(callback, toggleState) end
    end

    switch.MouseButton1Click:Connect(function() setToggleState(not toggleState) end)

    local containerBtn = Instance.new("TextButton")
    containerBtn.Size = UDim2.new(1, -60, 1, 0)
    containerBtn.BackgroundTransparency = 1
    containerBtn.Text = ""
    containerBtn.ZIndex = 1
    containerBtn.Parent = container

    label.ZIndex = 2

    containerBtn.MouseButton1Click:Connect(function() setToggleState(not toggleState) end)

    container.MouseEnter:Connect(function()
        Tween(container, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro)
    end)
    container.MouseLeave:Connect(function()
        Tween(container, {BackgroundColor3 = BloxHub.Settings.Theme.Secondary}, BloxHub.Settings.Animation.Micro)
    end)

    RegisterThemeCallback(function()
        if not container.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(container, "BackgroundColor3", T.Secondary)
        SafeSet(label, "TextColor3", T.Text)
        SafeSet(knob, "BackgroundColor3", Color3.fromRGB(250, 248, 244))
        SafeSet(switch, "BackgroundColor3", toggleState and T.Accent or T.Primary)
        SafeSet(switch, "BackgroundTransparency", toggleState and 0.1 or 0.35)
        if switchStroke then
            SafeSet(switchStroke, "Color", toggleState and T.Accent or T.Border)
            SafeSet(switchStroke, "Transparency", toggleState and 0.4 or 0.88)
        end
    end)

    return {
        Container = container,
        GetValue = function() return toggleState end,
        SetValue = function(_, value) setToggleState(value) end,
        Destroy = function()
            if container then pcall(function() container:Destroy() end) end
        end
    }
end

function BloxHub.Elements:CreateSlider(tab, text, min, max, default, callback)
    local sliderValue = default or min

    local container = Instance.new("Frame")
    container.Name = "Slider_" .. text
    container.Size = UDim2.new(1, 0, 0, BloxHub:RP(BloxHub.Device.IsMobile and 56 or 52))
    container.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    container.BorderSizePixel = 0
    container.Parent = tab.Container

    CreateUICorner(BloxHub.Settings.CornerRadius.Small, container)
    Hairline(container, 0.88)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 22)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = BloxHub.Settings.Theme.Text
    label.TextSize = BloxHub.Device.IsMobile and BloxHub.Settings.Type.Body or BloxHub.Settings.Type.BodyStrong
    label.Font = BloxHub.Settings.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    -- v3.4.0: the filled value chip became a quiet right-aligned gold figure.
    local valueFrame = Instance.new("Frame")
    valueFrame.Name = "ValueFrame"
    valueFrame.Size = UDim2.new(0, 50, 0, 22)
    valueFrame.Position = UDim2.new(1, -60, 0, 6)
    valueFrame.BackgroundTransparency = 1
    valueFrame.BorderSizePixel = 0
    valueFrame.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(sliderValue)
    valueLabel.TextColor3 = BloxHub.Settings.Theme.Accent
    valueLabel.TextSize = BloxHub.Settings.Type.Caption
    valueLabel.Font = BloxHub.Settings.FontBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = valueFrame

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, -28, 0, 4)
    sliderBack.Position = UDim2.new(0, 14, 1, -17)
    sliderBack.BackgroundColor3 = BloxHub.Settings.Theme.Primary
    sliderBack.BackgroundTransparency = 0.3
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = container
    CreateUICorner(2, sliderBack)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = BloxHub.Settings.Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    CreateUICorner(2, sliderFill)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((sliderValue - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(250, 248, 244)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = sliderBack
    CreateUICorner(7, knob)
    local knobStroke = CreateUIStroke(knob, BloxHub.Settings.Theme.Accent, 1.5, 0.15)

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 20, 1, 16)
    sliderButton.Position = UDim2.new(0, -10, 0, -8)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.Parent = sliderBack

    local dragging = false

    local function updateSlider(x)
        local relativeX = math.clamp((x - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        sliderValue = min + (max - min) * relativeX
        sliderValue = math.floor(sliderValue + 0.5)

        valueLabel.Text = tostring(sliderValue)
        Tween(sliderFill, {Size = UDim2.new(relativeX, 0, 1, 0)}, 0.03)
        Tween(knob, {Position = UDim2.new(relativeX, 0, 0.5, 0)}, 0.03)

        if callback then pcall(callback, sliderValue) end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local sliderInputChanged = UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                updateSlider(input.Position.X)
            end
        end
    end)

    local sliderInputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    RegisterThemeCallback(function()
        if not container.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(container, "BackgroundColor3", T.Secondary)
        SafeSet(label, "TextColor3", T.Text)
        SafeSet(valueLabel, "TextColor3", T.Accent)
        SafeSet(sliderBack, "BackgroundColor3", T.Primary)
        SafeSet(sliderFill, "BackgroundColor3", T.Accent)
        SafeSet(knob, "BackgroundColor3", Color3.fromRGB(250, 248, 244))
        if knobStroke then SafeSet(knobStroke, "Color", T.Accent) end
    end)

    return {
        Container = container,
        GetValue = function() return sliderValue end,
        SetValue = function(_, value)
            sliderValue = math.clamp(value, min, max)
            valueLabel.Text = tostring(sliderValue)
            local relativeX = (sliderValue - min) / (max - min)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
        end,
        Destroy = function()
            pcall(function() sliderInputChanged:Disconnect() end)
            pcall(function() sliderInputEnded:Disconnect() end)
            if container then pcall(function() container:Destroy() end) end
        end
    }
end

function BloxHub.Elements:CreateKeybind(tab, text, defaultKey, callback)
    local currentKey = defaultKey
    local currentInputType = nil
    local listening = false

    local container = RowContainer(tab, "Keybind_" .. text, BloxHub:RP(BloxHub.Device.IsMobile and 42 or 38))

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = BloxHub.Settings.Theme.Text
    label.TextSize = BloxHub.Device.IsMobile and BloxHub.Settings.Type.Body or BloxHub.Settings.Type.BodyStrong
    label.Font = BloxHub.Settings.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.45, -18, 0, 28)
    keyButton.Position = UDim2.new(0.55, 4, 0.5, -14)
    keyButton.BackgroundColor3 = BloxHub.Settings.Theme.Primary
    keyButton.BackgroundTransparency = 0.35
    keyButton.Text = GetKeyName(currentKey, currentInputType)
    keyButton.TextColor3 = BloxHub.Settings.Theme.TextDim
    keyButton.TextSize = BloxHub.Settings.Type.Caption
    keyButton.Font = BloxHub.Settings.FontBold
    keyButton.AutoButtonColor = false
    keyButton.Parent = container

    CreateUICorner(BloxHub.Settings.CornerRadius.XSmall, keyButton)
    local keyStroke = Hairline(keyButton, 0.85)

    keyButton.MouseButton1Click:Connect(function()
        if BloxHub.State.ActiveHotkeyListener then return end
        listening = true
        keyButton.Text = "..."
        keyButton.TextColor3 = BloxHub.Settings.Theme.Accent
        if keyStroke then keyStroke.Color = BloxHub.Settings.Theme.Accent end

        BloxHub.State.ActiveHotkeyListener = {
            Button = keyButton,
            Callback = function(keyCode, inputType, keyName)
                currentKey = keyCode
                currentInputType = inputType
                listening = false
                keyButton.TextColor3 = BloxHub.Settings.Theme.TextDim
                if keyStroke then keyStroke.Color = BloxHub.Settings.Theme.Border end
                if callback then pcall(callback, keyCode, inputType, keyName) end
            end
        }
    end)

    keyButton.MouseEnter:Connect(function()
        if not listening then
            Tween(keyButton, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro)
            keyButton.TextColor3 = BloxHub.Settings.Theme.Text
        end
    end)

    keyButton.MouseLeave:Connect(function()
        if not listening then
            Tween(keyButton, {BackgroundColor3 = BloxHub.Settings.Theme.Primary}, BloxHub.Settings.Animation.Micro)
            keyButton.TextColor3 = BloxHub.Settings.Theme.TextDim
        end
    end)

    RegisterThemeCallback(function()
        if not container.Parent then return end
        SafeSet(container, "BackgroundColor3", BloxHub.Settings.Theme.Secondary)
        SafeSet(label, "TextColor3", BloxHub.Settings.Theme.Text)
        if not listening then
            SafeSet(keyButton, "BackgroundColor3", BloxHub.Settings.Theme.Primary)
            SafeSet(keyButton, "TextColor3", BloxHub.Settings.Theme.TextDim)
        end
        if keyStroke then SafeSet(keyStroke, "Color", BloxHub.Settings.Theme.Border) end
    end)

    return {
        Container = container,
        GetKey = function() return currentKey, currentInputType end,
        SetKey = function(_, keyCode, inputType)
            currentKey = keyCode
            currentInputType = inputType
            keyButton.Text = GetKeyName(keyCode, inputType)
        end,
        Destroy = function()
            if container then pcall(function() container:Destroy() end) end
        end
    }
end

function BloxHub.Elements:CreateDropdown(tab, text, options, callback)
    local selectedOption = options[1] or "None"
    local expanded = false

    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. text
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    container.BackgroundTransparency = 0.4 -- glass layer
    container.BorderSizePixel = 0
    container.Parent = tab.Container
    CreateUICorner(BloxHub.Settings.CornerRadius.Small, container)
    Hairline(container, 0.88)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = BloxHub.Settings.Theme.Text
    label.TextSize = BloxHub.Settings.Type.BodyStrong
    label.Font = BloxHub.Settings.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownButton"
    dropdownBtn.Size = UDim2.new(0.5, -12, 0, 28)
    dropdownBtn.Position = UDim2.new(0.5, 0, 0.5, -14)
    dropdownBtn.BackgroundColor3 = BloxHub.Settings.Theme.Primary
    dropdownBtn.BackgroundTransparency = 0.3
    dropdownBtn.Text = selectedOption .. "  ▼"
    dropdownBtn.TextColor3 = BloxHub.Settings.Theme.Text
    dropdownBtn.TextSize = BloxHub.Settings.Type.Caption
    dropdownBtn.Font = BloxHub.Settings.FontSemibold
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.Parent = container
    CreateUICorner(BloxHub.Settings.CornerRadius.XSmall, dropdownBtn)
    Hairline(dropdownBtn, 0.9)

    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "DropdownOptions"
    optionsContainer.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    optionsContainer.BackgroundTransparency = 0.15
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ClipsDescendants = true
    optionsContainer.ZIndex = 5000
    optionsContainer.Parent = BloxHub.Core.ScreenGui
    CreateUICorner(BloxHub.Settings.CornerRadius.Medium, optionsContainer)
    Hairline(optionsContainer, 0.78)

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer
    CreateUIPadding(4, 4, 4, 4, optionsContainer)

    local optionObjects = {}

    local function createOptions()
        for _, obj in pairs(optionObjects) do pcall(function() obj:Destroy() end) end
        table.clear(optionObjects)

        local totalHeight = 8

        for i, option in ipairs(options) do
            local optionBg = Instance.new("TextButton")
            optionBg.Name = "Option_" .. i
            optionBg.Size = UDim2.new(1, 0, 0, 26)
            optionBg.BackgroundTransparency = 1
            optionBg.BackgroundColor3 = BloxHub.Settings.Theme.Primary -- base for the hover tint
            optionBg.Text = ""
            optionBg.AutoButtonColor = false
            optionBg.LayoutOrder = i
            optionBg.ZIndex = 5001
            optionBg.Parent = optionsContainer

            local optionText = Instance.new("TextLabel")
            optionText.Name = "OptionText"
            optionText.Size = UDim2.new(1, -18, 1, 0)
            optionText.Position = UDim2.new(0, 12, 0, 0)
            optionText.BackgroundTransparency = 1
            optionText.Text = option
            optionText.TextColor3 = (option == selectedOption) and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.Text
            optionText.TextSize = BloxHub.Settings.Type.Caption
            optionText.Font = BloxHub.Settings.Font
            optionText.TextXAlignment = Enum.TextXAlignment.Left
            optionText.ZIndex = 5002
            optionText.Parent = optionBg

            local selectedIndicator = Instance.new("Frame")
            selectedIndicator.Name = "SelectedIndicator"
            selectedIndicator.Size = UDim2.new(0, 2, 1, -8)
            selectedIndicator.Position = UDim2.new(0, 0, 0, 4)
            selectedIndicator.BackgroundColor3 = BloxHub.Settings.Theme.Accent
            selectedIndicator.BorderSizePixel = 0
            selectedIndicator.Visible = (option == selectedOption)
            selectedIndicator.ZIndex = 5003
            selectedIndicator.Parent = optionBg

            optionBg.MouseButton1Click:Connect(function()
                selectedOption = option
                dropdownBtn.Text = option .. "  ▼"
                expanded = false
                optionsContainer.Visible = false
                RestoreOptionsLayer()

                for _, el in pairs(optionObjects) do
                    local indicatorFil = el:FindFirstChild("SelectedIndicator")
                    local ot = el:FindFirstChild("OptionText")
                    if indicatorFil and ot then
                        local isSel = (ot.Text == option)
                        indicatorFil.Visible = isSel
                        ot.TextColor3 = isSel and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.Text
                    end
                end

                if callback then pcall(callback, option) end
            end)

            optionBg.MouseEnter:Connect(function()
                Tween(optionBg, {BackgroundColor3 = BloxHub.Settings.Theme.Primary, BackgroundTransparency = 0.25}, BloxHub.Settings.Animation.Micro)
            end)
            optionBg.MouseLeave:Connect(function()
                Tween(optionBg, {BackgroundTransparency = 1}, BloxHub.Settings.Animation.Micro)
            end)

            table.insert(optionObjects, optionBg)
            totalHeight = totalHeight + 26 + 2
        end

        optionsContainer.Size = UDim2.fromOffset(dropdownBtn.AbsoluteSize.X, totalHeight)
    end

    createOptions()

    dropdownBtn.MouseButton1Click:Connect(function()
        expanded = not expanded

        if expanded then
            local btnPos = dropdownBtn.AbsolutePosition
            local btnSize = dropdownBtn.AbsoluteSize
            local vp = GetViewportSize()

            -- Tinggi daftar dibatasi tinggi viewport (ClipsDescendants aktif)
            local listH = optionsContainer.AbsoluteSize.Y
            local maxH = math.max(vp.Y - 16, 40)
            if listH > maxH then listH = maxH end
            optionsContainer.Size = UDim2.fromOffset(btnSize.X, listH)

            -- Default buka ke bawah; bila tidak muat, buka ke atas. Posisi
            -- selalu di-clamp agar daftar tidak keluar viewport.
            local x = math.clamp(btnPos.X, 8, math.max(8, vp.X - btnSize.X - 8))
            local y = btnPos.Y + btnSize.Y + 5
            if y + listH > vp.Y - 8 then
                y = btnPos.Y - 5 - listH
                if y < 8 then y = math.max(8, vp.Y - 8 - listH) end
            end
            optionsContainer.Position = UDim2.fromOffset(x, y)

            dropdownBtn.Text = selectedOption .. "  ▲"
            optionsContainer.Visible = true
            RaiseOptionsLayer()
        else
            dropdownBtn.Text = selectedOption .. "  ▼"
            optionsContainer.Visible = false
            RestoreOptionsLayer()
        end
    end)

    dropdownBtn.MouseEnter:Connect(function() Tween(dropdownBtn, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro) end)
    dropdownBtn.MouseLeave:Connect(function() Tween(dropdownBtn, {BackgroundColor3 = BloxHub.Settings.Theme.Primary}, BloxHub.Settings.Animation.Micro) end)

    local function closeDropdown()
        if expanded then
            expanded = false
            optionsContainer.Visible = false
            dropdownBtn.Text = selectedOption .. "  ▼"
            RestoreOptionsLayer()
        end
    end

    tab.Window.Frame.Changed:Connect(function(prop)
        if prop == "Visible" and not tab.Window.Frame.Visible then
            closeDropdown()
        end
    end)

    RegisterThemeCallback(function()
        if not container.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(container, "BackgroundColor3", T.Secondary)
        SafeSet(label, "TextColor3", T.Text)
        SafeSet(optionsContainer, "BackgroundColor3", T.Secondary)
        for _, el in pairs(optionObjects) do
            if el and el.Parent then
                SafeSet(el, "BackgroundColor3", T.Primary)
                local ot = el:FindFirstChild("OptionText")
                local ind = el:FindFirstChild("SelectedIndicator")
                if ot then
                    SafeSet(ot, "TextColor3", (ind and ind.Visible) and T.Accent or T.Text)
                end
                if ind then SafeSet(ind, "BackgroundColor3", T.Accent) end
            end
        end
    end)

    return {
        Container = container,
        GetValue = function() return selectedOption end,
        SetValue = function(_, value)
            if table.find(options, value) then
                selectedOption = value
                dropdownBtn.Text = value .. "  ▼"
                for _, el in pairs(optionObjects) do
                    local indicatorFil = el:FindFirstChild("SelectedIndicator")
                    local ot = el:FindFirstChild("OptionText")
                    if indicatorFil and ot then
                        local isSel = (ot.Text == value)
                        indicatorFil.Visible = isSel
                        ot.TextColor3 = isSel and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.Text
                    end
                end
            end
        end,
        -- Menerima dua gaya panggilan: row.Refresh(list) DAN row:Refresh(list).
        -- Gaya titik dua mengirim row itu sendiri sebagai argumen pertama; row
        -- selalu punya kunci .Container sedangkan daftar opsi selalu array
        -- string, jadi keduanya tidak mungkin tertukar. Perilaku gaya titik
        -- (dipakai script lama) tidak berubah sama sekali.
        Refresh = function(a, b)
            local newOptions = a
            if type(a) == "table" and a.Container ~= nil then
                newOptions = b
            end
            options = newOptions or options
            -- createOptions membuat Instance: jalankan di thread bersih agar
            -- aman dipanggil dari thread yang kehilangan capability (require).
            RunClean(createOptions)
        end,
        Destroy = function()
            if expanded then
                expanded = false
                RestoreOptionsLayer()
            end
            pcall(function() optionsContainer:Destroy() end)
            if container then pcall(function() container:Destroy() end) end
        end
    }
end

function BloxHub.Elements:CreateTextBox(tab, text, placeholder, callback)
    local container = RowContainer(tab, "TextBox_" .. text, BloxHub:RP(BloxHub.Device.IsMobile and 42 or 38))

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = BloxHub.Settings.Theme.Text
    label.TextSize = BloxHub.Device.IsMobile and BloxHub.Settings.Type.Body or BloxHub.Settings.Type.BodyStrong
    label.Font = BloxHub.Settings.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.65, -18, 0, 28)
    textBox.Position = UDim2.new(0.35, 4, 0.5, -14)
    textBox.BackgroundColor3 = BloxHub.Settings.Theme.Primary
    textBox.BackgroundTransparency = 0.35
    textBox.PlaceholderText = placeholder or "Enter text..."
    textBox.Text = ""
    textBox.TextColor3 = BloxHub.Settings.Theme.Text
    textBox.PlaceholderColor3 = BloxHub.Settings.Theme.TextDim
    textBox.TextSize = BloxHub.Settings.Type.Caption
    textBox.Font = BloxHub.Settings.Font
    textBox.ClearTextOnFocus = false
    textBox.Parent = container

    CreateUICorner(BloxHub.Settings.CornerRadius.XSmall, textBox)
    local tbStroke = Hairline(textBox, 0.85)
    CreateUIPadding(10, 10, 0, 0, textBox)

    textBox.Focused:Connect(function()
        if tbStroke then Tween(tbStroke, {Color = BloxHub.Settings.Theme.Accent, Transparency = 0.45}, BloxHub.Settings.Animation.Micro) end
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        if tbStroke then Tween(tbStroke, {Color = BloxHub.Settings.Theme.Border, Transparency = 0.85}, BloxHub.Settings.Animation.Micro) end
        if callback then pcall(callback, textBox.Text, enterPressed) end
    end)

    RegisterThemeCallback(function()
        if not container.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(container, "BackgroundColor3", T.Secondary)
        SafeSet(label, "TextColor3", T.Text)
        SafeSet(textBox, "BackgroundColor3", T.Primary)
        SafeSet(textBox, "PlaceholderColor3", T.TextDim)
        if tbStroke and not textBox:IsFocused() then SafeSet(tbStroke, "Color", T.Border) end
    end)

    return {
        Container = container,
        GetValue = function() return textBox.Text end,
        SetValue = function(_, value) textBox.Text = value end,
        Destroy = function()
            if container then pcall(function() container:Destroy() end) end
        end
    }
end

function BloxHub.Elements:CreateLabel(tab, text, config)
    config = config or {}

    local container = Instance.new("Frame")
    container.Name = "Label_" .. text
    container.Size = UDim2.new(1, 0, 0, config.Height or (BloxHub.Device.IsMobile and 28 or 26))
    container.BackgroundTransparency = 1
    container.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, config.Bold and 10 or 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = config.TextColor or (config.Bold and BloxHub.Settings.Theme.Text or BloxHub.Settings.Theme.TextDim)
    label.TextSize = config.TextSize or (config.Bold and BloxHub.Settings.Type.BodyStrong or BloxHub.Settings.Type.Body)
    label.Font = config.Bold and BloxHub.Settings.FontBold or BloxHub.Settings.Font
    label.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = container

    if config.Bold then
        local accentBar = Instance.new("Frame")
        accentBar.Name = "AccentBar"
        accentBar.Size = UDim2.new(0, 2, 0, 14)
        accentBar.Position = UDim2.new(0, 0, 0.5, -7)
        accentBar.BackgroundColor3 = BloxHub.Settings.Theme.Accent
        accentBar.BorderSizePixel = 0
        accentBar.Parent = container
        CreateUICorner(2, accentBar)

        RegisterThemeCallback(function()
            if accentBar and accentBar.Parent then
                SafeSet(accentBar, "BackgroundColor3", BloxHub.Settings.Theme.Accent)
            end
        end)
    end

    -- v3.4.0: label text follows theme swaps too (it used to stay at the
    -- creation-time color). An explicit config.TextColor keeps winning.
    if not config.TextColor then
        RegisterThemeCallback(function()
            if label and label.Parent then
                SafeSet(label, "TextColor3", config.Bold and BloxHub.Settings.Theme.Text or BloxHub.Settings.Theme.TextDim)
            end
        end)
    end

    return container
end

function BloxHub.Elements:CreateDivider(tab)
    local container = Instance.new("Frame")
    container.Name = "Divider"
    container.Size = UDim2.new(1, 0, 0, 12)
    container.BackgroundTransparency = 1
    container.Parent = tab.Container

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0.5, 0)
    divider.BackgroundColor3 = BloxHub.Settings.Theme.Border
    divider.BackgroundTransparency = 0.85
    divider.BorderSizePixel = 0
    divider.Parent = container

    RegisterThemeCallback(function()
        if divider and divider.Parent then
            SafeSet(divider, "BackgroundColor3", BloxHub.Settings.Theme.Border)
        end
    end)

    return container
end

function BloxHub.Elements:CreatePopup(window, title, options)
    local popup = {
        Title = title,
        Options = options or {},
        Visible = false
    }

    -- v3.4.0: scrim MATI secara default (scene tetap terlihat penuh, perilaku
    -- v3.3.0). Aktifkan per-popup lewat options: { Scrim = true } untuk gelap
    -- standar, atau { Scrim = 0.6 } untuk kekuatan kustom (0 = solid, 1 = off).
    local scrimTransparency = 1
    if options and options.Scrim == true then
        scrimTransparency = 0.55
    elseif options and type(options.Scrim) == "number" then
        scrimTransparency = math.clamp(options.Scrim, 0, 1)
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "PopupOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = BloxHub.Settings.Theme.Overlay
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Visible = false
    overlay.ZIndex = 100
    overlay.Parent = BloxHub.Core.ScreenGui

    local popupFrame = Instance.new("Frame")
    popupFrame.Name = "Popup_" .. title
    popupFrame.Size = UDim2.new(0, 300, 0, 200)
    popupFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    popupFrame.BackgroundColor3 = BloxHub.Settings.Theme.Background
    popupFrame.BackgroundTransparency = 0.2 -- glass, consistent with the window
    popupFrame.BorderSizePixel = 0
    popupFrame.ZIndex = 101
    popupFrame.Parent = overlay
    CreateUICorner(BloxHub.Settings.CornerRadius.Large, popupFrame)
    Hairline(popupFrame, 0.86)

    -- FIX v3.4.0: bayangan popup berukuran popup + 12px (piksel eksplisit),
    -- bukan helper CreateShadow yang berukuran relatif ke overlay full-screen
    -- (sebelumnya menghasilkan tirai hitam seluas layar saat popup terbuka).
    if BloxHub.Settings.UI.ShadowEnabled then
        local popupShadow = Instance.new("Frame")
        popupShadow.Name = "Shadow"
        popupShadow.Size = UDim2.new(0, 312, 0, 212)
        popupShadow.Position = UDim2.new(0.5, -156, 0.5, -102)
        popupShadow.BackgroundColor3 = BloxHub.Settings.Theme.Shadow
        popupShadow.BackgroundTransparency = 0.6
        popupShadow.BorderSizePixel = 0
        popupShadow.ZIndex = 100
        CreateUICorner(BloxHub.Settings.CornerRadius.Large + 6, popupShadow)
        popupShadow.Parent = overlay
    end

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1 -- title floats on the glass, no nested box
    header.BorderSizePixel = 0
    header.ZIndex = 102
    header.Parent = popupFrame

    -- hairline separator under the title (replaces the old filled header,
    -- whose all-corner UICorner left small notches at the content boundary)
    local headerRule = Instance.new("Frame")
    headerRule.Name = "HeaderRule"
    headerRule.Size = UDim2.new(1, 0, 0, 1)
    headerRule.Position = UDim2.new(0, 0, 1, -1)
    headerRule.BackgroundColor3 = BloxHub.Settings.Theme.Border
    headerRule.BackgroundTransparency = 0.88
    headerRule.BorderSizePixel = 0
    headerRule.ZIndex = 102
    headerRule.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = BloxHub.Settings.Theme.Text
    titleLabel.TextSize = BloxHub.Settings.Type.Title
    titleLabel.Font = BloxHub.Settings.FontSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 102
    titleLabel.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = BloxHub.Settings.Theme.Secondary
    closeBtn.BackgroundTransparency = 1 -- ghost until hovered
    closeBtn.Text = "×"
    closeBtn.TextColor3 = BloxHub.Settings.Theme.TextDim
    closeBtn.TextSize = 20
    closeBtn.Font = BloxHub.Settings.FontBold
    closeBtn.ZIndex = 102
    closeBtn.Parent = header
    CreateUICorner(BloxHub.Settings.CornerRadius.Small, closeBtn)

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = BloxHub.Settings.Theme.Secondary, BackgroundTransparency = 0.25, TextColor3 = BloxHub.Settings.Theme.Text}, BloxHub.Settings.Animation.Micro)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 1, TextColor3 = BloxHub.Settings.Theme.TextDim}, BloxHub.Settings.Animation.Micro)
    end)

    closeBtn.MouseButton1Click:Connect(function() popup:Hide() end)

    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 3
    contentFrame.ScrollBarImageColor3 = BloxHub.Settings.Theme.TextDim
    contentFrame.ScrollBarImageTransparency = 0.55
    contentFrame.BorderSizePixel = 0
    -- FIX v3.4.0: tanpa ini, CanvasSize memakai default engine {0,0},{2,0}
    -- sehingga muncul scrollbar hantu + konten bisa "ter-scroll" 2px (bug
    -- popup terlihat terpotong). Kanvas mengikuti isi konten.
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.ZIndex = 102
    contentFrame.Parent = popupFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame

    -- Close popup when overlay clicked (backdrop dismiss)
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            popup:Hide()
        end
    end)

    popup.Overlay = overlay
    popup.Frame = popupFrame
    popup.Content = contentFrame

    function popup:Show()
        self.Visible = true
        self.Overlay.Visible = true
        -- v3.4.0: scale entrance (visual only; end state unchanged). The
        -- scrim only animates in when the popup opted into one.
        Tween(overlay, {BackgroundTransparency = scrimTransparency}, BloxHub.Settings.Animation.Quick)
        pcall(function()
            local s = popupFrame:FindFirstChild("PopupScale")
            if not s then
                s = Instance.new("UIScale")
                s.Name = "PopupScale"
                s.Parent = popupFrame
            end
            s.Scale = 0.96
            Tween(s, {Scale = 1}, BloxHub.Settings.Animation.Quick)
        end)
    end

    -- Hide tetap instan (script lama mengandalkan flip visibility langsung).
    function popup:Hide()
        self.Visible = false
        overlay.BackgroundTransparency = 1
        self.Overlay.Visible = false
    end

    function popup:AddButton(text, callback)
        return RunClean(function()
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundColor3 = BloxHub.Settings.Theme.Primary
            btn.BackgroundTransparency = 0.4 -- glass layer
            btn.Text = text
            btn.TextColor3 = BloxHub.Settings.Theme.Text
            btn.TextSize = BloxHub.Settings.Type.BodyStrong
            btn.Font = BloxHub.Settings.FontSemibold
            btn.AutoButtonColor = false
            btn.ZIndex = 102
            btn.Parent = self.Content
            CreateUICorner(BloxHub.Settings.CornerRadius.Small, btn)
            local pStroke = Hairline(btn, 0.9)

            btn.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
            end)

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro)
                if pStroke then
                    pStroke.Color = BloxHub.Settings.Theme.Accent
                    pStroke.Transparency = 0.6
                end
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = BloxHub.Settings.Theme.Primary}, BloxHub.Settings.Animation.Micro)
                if pStroke then
                    pStroke.Color = BloxHub.Settings.Theme.Border
                    pStroke.Transparency = 0.9
                end
            end)

            return btn
        end)
    end

    function popup:AddLabel(text)
        return RunClean(function()
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = BloxHub.Settings.Theme.Text
            lbl.TextSize = BloxHub.Settings.Type.Body
            lbl.Font = BloxHub.Settings.Font
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.ZIndex = 102
            lbl.Parent = contentFrame
            return lbl
        end)
    end

    function popup:Destroy()
        if overlay then pcall(function() overlay:Destroy() end) end
    end

    return popup
end

-- ═══════════════════════════════════════════════════════════
-- LAYOUT UTILITIES
-- ═══════════════════════════════════════════════════════════

function BloxHub:CreateGrid(parent, columns, cellSize, padding)
    return RunClean(function()
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellSize = cellSize or UDim2.new(0, 140, 0, 100)
        gridLayout.CellPadding = padding or UDim2.new(0, 10, 0, 10)
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.StartCorner = Enum.StartCorner.TopLeft
        gridLayout.FillDirection = Enum.FillDirection.Horizontal
        gridLayout.Parent = parent
        return gridLayout
    end)
end

function BloxHub:CreateVerticalStack(parent, padding)
    return RunClean(function()
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, padding or 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.Parent = parent
        return listLayout
    end)
end

function BloxHub:CreateHorizontalStack(parent, padding)
    return RunClean(function()
        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.Padding = UDim.new(0, padding or 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = parent
        return listLayout
    end)
end

-- ═══════════════════════════════════════════════════════════
-- THEME & CUSTOMIZATION
-- ═══════════════════════════════════════════════════════════

-- v3.4.0: every palette speaks the same design language — tonal layering,
-- hairline borders (Border doubles as the hairline color), one restrained
-- accent. Legacy names keep their hue identity; Obsidian/Frost are new.
local BUILTIN_THEMES = {
    Dark = {
        Background = Color3.fromRGB(10, 11, 14),
        BackgroundGradient = Color3.fromRGB(17, 19, 24),
        Primary = Color3.fromRGB(18, 20, 25),
        PrimaryGradient = Color3.fromRGB(25, 27, 34),
        Secondary = Color3.fromRGB(27, 30, 37),
        SecondaryGradient = Color3.fromRGB(36, 39, 48),
        Accent = Color3.fromRGB(96, 140, 215),
        AccentGradient = Color3.fromRGB(118, 160, 228),
        AccentHover = Color3.fromRGB(138, 176, 238),
        Text = Color3.fromRGB(242, 244, 247),
        TextDim = Color3.fromRGB(152, 157, 166),
        Success = Color3.fromRGB(122, 195, 145),
        Warning = Color3.fromRGB(218, 182, 95),
        Error = Color3.fromRGB(208, 112, 98),
        Border = Color3.fromRGB(238, 240, 244),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Background = Color3.fromRGB(241, 239, 235),
        BackgroundGradient = Color3.fromRGB(250, 248, 244),
        Primary = Color3.fromRGB(248, 246, 242),
        PrimaryGradient = Color3.fromRGB(253, 251, 247),
        Secondary = Color3.fromRGB(236, 233, 227),
        SecondaryGradient = Color3.fromRGB(245, 242, 236),
        Accent = Color3.fromRGB(166, 134, 78),
        AccentGradient = Color3.fromRGB(184, 152, 92),
        AccentHover = Color3.fromRGB(148, 118, 66),
        Text = Color3.fromRGB(30, 28, 25),
        TextDim = Color3.fromRGB(112, 108, 100),
        Success = Color3.fromRGB(63, 138, 90),
        Warning = Color3.fromRGB(168, 128, 38),
        Error = Color3.fromRGB(180, 76, 60),
        Border = Color3.fromRGB(30, 28, 25),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    },
    Purple = {
        Background = Color3.fromRGB(12, 10, 16),
        BackgroundGradient = Color3.fromRGB(19, 16, 24),
        Primary = Color3.fromRGB(21, 18, 27),
        PrimaryGradient = Color3.fromRGB(28, 24, 35),
        Secondary = Color3.fromRGB(30, 26, 39),
        SecondaryGradient = Color3.fromRGB(39, 34, 50),
        Accent = Color3.fromRGB(158, 122, 222),
        AccentGradient = Color3.fromRGB(178, 146, 234),
        AccentHover = Color3.fromRGB(196, 168, 242),
        Text = Color3.fromRGB(244, 242, 247),
        TextDim = Color3.fromRGB(154, 148, 164),
        Success = Color3.fromRGB(122, 195, 145),
        Warning = Color3.fromRGB(218, 182, 95),
        Error = Color3.fromRGB(208, 112, 98),
        Border = Color3.fromRGB(240, 238, 246),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    },
    Green = {
        Background = Color3.fromRGB(9, 13, 11),
        BackgroundGradient = Color3.fromRGB(15, 20, 17),
        Primary = Color3.fromRGB(17, 22, 19),
        PrimaryGradient = Color3.fromRGB(23, 29, 25),
        Secondary = Color3.fromRGB(26, 33, 29),
        SecondaryGradient = Color3.fromRGB(34, 43, 38),
        Accent = Color3.fromRGB(110, 188, 142),
        AccentGradient = Color3.fromRGB(134, 204, 160),
        AccentHover = Color3.fromRGB(154, 217, 176),
        Text = Color3.fromRGB(240, 245, 241),
        TextDim = Color3.fromRGB(148, 158, 152),
        Success = Color3.fromRGB(122, 195, 145),
        Warning = Color3.fromRGB(218, 182, 95),
        Error = Color3.fromRGB(208, 112, 98),
        Border = Color3.fromRGB(238, 244, 240),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    },
    -- v3.4.0 additive themes
    Obsidian = {
        Background = Color3.fromRGB(10, 10, 12),
        BackgroundGradient = Color3.fromRGB(17, 17, 20),
        Primary = Color3.fromRGB(19, 19, 22),
        PrimaryGradient = Color3.fromRGB(25, 25, 29),
        Secondary = Color3.fromRGB(28, 28, 32),
        SecondaryGradient = Color3.fromRGB(36, 36, 41),
        Accent = Color3.fromRGB(201, 169, 110),
        AccentGradient = Color3.fromRGB(224, 196, 140),
        AccentHover = Color3.fromRGB(235, 210, 160),
        Text = Color3.fromRGB(245, 243, 238),
        TextDim = Color3.fromRGB(158, 154, 146),
        Success = Color3.fromRGB(125, 195, 145),
        Warning = Color3.fromRGB(218, 182, 95),
        Error = Color3.fromRGB(205, 112, 98),
        Border = Color3.fromRGB(235, 232, 225),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    },
    Frost = {
        Background = Color3.fromRGB(11, 12, 14),
        BackgroundGradient = Color3.fromRGB(18, 19, 22),
        Primary = Color3.fromRGB(20, 21, 24),
        PrimaryGradient = Color3.fromRGB(27, 28, 32),
        Secondary = Color3.fromRGB(30, 31, 35),
        SecondaryGradient = Color3.fromRGB(39, 40, 45),
        Accent = Color3.fromRGB(202, 208, 216),
        AccentGradient = Color3.fromRGB(224, 229, 235),
        AccentHover = Color3.fromRGB(240, 243, 247),
        Text = Color3.fromRGB(245, 246, 248),
        TextDim = Color3.fromRGB(152, 155, 161),
        Success = Color3.fromRGB(120, 190, 140),
        Warning = Color3.fromRGB(216, 180, 95),
        Error = Color3.fromRGB(205, 110, 98),
        Border = Color3.fromRGB(240, 242, 245),
        Shadow = Color3.fromRGB(0, 0, 0),
        Overlay = Color3.fromRGB(0, 0, 0)
    }
}

function BloxHub:GetThemes()
    local names = {}
    for name in pairs(BUILTIN_THEMES) do table.insert(names, name) end
    table.sort(names)
    return names
end

function BloxHub:SetTheme(themeName)
    local selectedTheme = BUILTIN_THEMES[themeName] or BUILTIN_THEMES.Dark
    for key, value in pairs(selectedTheme) do
        self.Settings.Theme[key] = value
    end

    -- Notify all components to recolor
    for _, cb in ipairs(self.State.ThemeCallbacks) do
        pcall(cb)
    end

    return self
end

function BloxHub:CustomizeTheme(customColors)
    for key, value in pairs(customColors) do
        if self.Settings.Theme[key] then
            self.Settings.Theme[key] = value
        end
    end

    for _, cb in ipairs(self.State.ThemeCallbacks) do
        pcall(cb)
    end

    return self
end

-- ═══════════════════════════════════════════════════════════
-- CONFIG PERSISTENCE
-- ═══════════════════════════════════════════════════════════

function BloxHub:SaveConfig(configName)
    configName = configName or "default"

    local config = {
        Version = self.Version,
        Theme = self.Settings.Theme,
        Windows = {}
    }

    for id, window in pairs(self.State.Windows) do
        config.Windows[id] = {
            Title = window.Title,
            Position = window.Frame.Position,
            Size = window.Frame.Size,
            Visible = window.Visible
        }
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)

    if success then
        if writefile then
            pcall(writefile, "BloxHub_" .. configName .. ".json", encoded)
        end
        self.State.SavedConfigs[configName] = config
    end

    return success
end

function BloxHub:LoadConfig(configName)
    configName = configName or "default"

    local config = nil

    if readfile and isfile and isfile("BloxHub_" .. configName .. ".json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("BloxHub_" .. configName .. ".json"))
        end)
        if success then config = result end
    end

    if not config and self.State.SavedConfigs[configName] then
        config = self.State.SavedConfigs[configName]
    end

    if config and config.Theme then
        for key, value in pairs(config.Theme) do
            pcall(function()
                if type(value) == "table" then
                    self.Settings.Theme[key] = Color3.new(value.r, value.g, value.b)
                else
                    self.Settings.Theme[key] = value
                end
            end)
        end
        for _, cb in ipairs(self.State.ThemeCallbacks) do pcall(cb) end
    end

    return config
end

-- ═══════════════════════════════════════════════════════════
-- FLOATING ICON TOGGLE
-- ═══════════════════════════════════════════════════════════

-- Dijalankan lewat RunClean (thread bersih) — lihat CLEAN-THREAD DISPATCHER.
local function CreateFloatingIconImpl(self, window, config)
    config = config or {}

    local icon = Instance.new("TextButton")
    icon.Name = "FloatingIcon"
    icon.Size = config.Size or UDim2.new(0, 100, 0, 40)
    icon.Position = config.Position or UDim2.new(0.5, -50, 0.05, 0)
    icon.BackgroundColor3 = self.Settings.Theme.Background
    icon.BackgroundTransparency = 0.2
    icon.Text = config.Text or ("◆ " .. window.Title)
    icon.TextColor3 = self.Settings.Theme.Text
    icon.TextSize = BloxHub.Settings.Type.BodyStrong
    icon.Font = self.Settings.FontSemibold
    icon.Visible = not window.Visible and config.ShowOnMinimize
    icon.ZIndex = 200
    icon.Parent = self.Core.ScreenGui

    CreateUICorner(self.Settings.CornerRadius.Medium, icon)
    local iconStroke = CreateUIStroke(icon, self.Settings.Theme.Accent, 1, 0.55)

    icon.MouseButton1Click:Connect(function()
        -- Jalur restore resmi untuk window:Minimize() (additive v3.3.0);
        -- window lama tanpa state Minimized tetap memakai Toggle seperti biasa.
        if window.Minimized then
            window:Restore()
        else
            window:Toggle()
        end
    end)

    icon.MouseEnter:Connect(function()
        -- soft gold bloom on hover (the one loud moment, and it is small)
        Tween(icon, {BackgroundColor3 = self.Settings.Theme.AccentHover, BackgroundTransparency = 0.55}, BloxHub.Settings.Animation.Quick)
        if iconStroke then iconStroke.Transparency = 0.35 end
    end)
    icon.MouseLeave:Connect(function()
        Tween(icon, {BackgroundColor3 = self.Settings.Theme.Background, BackgroundTransparency = 0.2}, BloxHub.Settings.Animation.Quick)
        if iconStroke then iconStroke.Transparency = 0.55 end
    end)

    MakeDraggable(icon, icon, window)

    window.FloatingIcon = icon

    if config.ShowOnMinimize then
        window.OriginalState = window.Visible
    end

    RegisterThemeCallback(function()
        if not icon or not icon.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(icon, "BackgroundColor3", T.Background)
        SafeSet(icon, "TextColor3", T.Text)
        local stroke = icon:FindFirstChildOfClass("UIStroke")
        if stroke then SafeSet(stroke, "Color", T.Accent) end
    end)

    return icon
end

function BloxHub:CreateFloatingIcon(window, config)
    return RunClean(CreateFloatingIconImpl, self, window, config)
end

-- ═══════════════════════════════════════════════════════════
-- MINI WIDGET (compact overlay control) — additive, v3.3.0
-- ═══════════════════════════════════════════════════════════
--[[
    window:CreateMiniWidget({
        Title    = "FARM",                       -- opsional
        Position = UDim2.new(0, 12, 0, 200),     -- opsional (default kanan-bawah)
        Rows = {
            { Type = "Toggle", Text = "Farm", Default = false, Callback = function(on) end },
            { Type = "Label",  Text = "Kills: 0" },
        },
    })
    → {
        Frame  = frame,
        Show(), Hide(), Destroy(),
        SetText(rowIndex, newText),              -- untuk baris Label
        Rows = { [i] = { Type = "Toggle", GetValue(), SetValue(bool) }
                       | { Type = "Label",  SetText(s) } },
    }
    Draggable; otomatis di-clamp ke viewport dan bisa "dock" ke tepi terdekat.
]]
function BloxHub:CreateMiniWidget(window, config)
    config = config or {}
    local T = self.Settings.Theme

    local widget = { Rows = {} }

    local frame = Instance.new("Frame")
    frame.Name = "MiniWidget_" .. (config.Title or window.ID)
    frame.BackgroundColor3 = T.Background
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ZIndex = 220
    frame.Position = config.Position or UDim2.new(1, -160, 1, -60)
    frame.Parent = self.Core.ScreenGui
    CreateUICorner(self.Settings.CornerRadius.Medium, frame)
    Hairline(frame, 0.86)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, self.Settings.Spacing.XS)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    CreateUIPadding(self.Settings.Spacing.SM, self.Settings.Spacing.SM, self.Settings.Spacing.SM, self.Settings.Spacing.SM, frame)

    local rowHeight = self.Device.IsMobile and 32 or 26
    local layoutOrder = 0
    local builtRows = 0

    if config.Title then
        layoutOrder = layoutOrder + 1
        local titleRow = Instance.new("TextLabel")
        titleRow.Name = "Title"
        titleRow.Size = UDim2.new(1, 0, 0, rowHeight)
        titleRow.BackgroundTransparency = 1
        titleRow.Text = config.Title
        titleRow.TextColor3 = T.Text
        titleRow.TextSize = BloxHub.Settings.Type.Body
        titleRow.Font = self.Settings.FontBold
        titleRow.TextXAlignment = Enum.TextXAlignment.Left
        titleRow.ZIndex = 221
        titleRow.LayoutOrder = layoutOrder
        titleRow.Parent = frame
        CreateAccentLine(titleRow, UDim2.new(0, 0, 1, 0))
        RegisterThemeCallback(function()
            if titleRow and titleRow.Parent then
                SafeSet(titleRow, "TextColor3", BloxHub.Settings.Theme.Text)
            end
        end)
    end

    -- widget.Rows diindeks sama dengan config.Rows (Title tidak menggeser)
    for rowIdx, rowConfig in ipairs(config.Rows or {}) do
        layoutOrder = layoutOrder + 1
        builtRows = builtRows + 1
        rowConfig.Type = rowConfig.Type or "Label"

        if rowConfig.Type == "Toggle" then
            local state = rowConfig.Default or false
            local rowBtn = Instance.new("TextButton")
            rowBtn.Name = "MiniToggle_" .. (rowConfig.Text or rowIdx)
            rowBtn.Size = UDim2.new(1, 0, 0, rowHeight)
            rowBtn.BackgroundColor3 = T.Secondary
            rowBtn.BackgroundTransparency = 0.4
            rowBtn.Text = ""
            rowBtn.AutoButtonColor = false
            rowBtn.ZIndex = 221
            rowBtn.LayoutOrder = layoutOrder
            rowBtn.Parent = frame
            CreateUICorner(self.Settings.CornerRadius.Small, rowBtn)
            Hairline(rowBtn, 0.92)

            local rowLabel = Instance.new("TextLabel")
            rowLabel.Size = UDim2.new(1, -46, 1, 0)
            rowLabel.Position = UDim2.new(0, 10, 0, 0)
            rowLabel.BackgroundTransparency = 1
            rowLabel.Text = rowConfig.Text or ""
            rowLabel.TextColor3 = T.Text
            rowLabel.TextSize = BloxHub.Settings.Type.Caption
            rowLabel.Font = self.Settings.Font
            rowLabel.TextXAlignment = Enum.TextXAlignment.Left
            rowLabel.ZIndex = 222
            rowLabel.Parent = rowBtn

            local stateLabel = Instance.new("TextLabel")
            stateLabel.Size = UDim2.new(0, 40, 1, 0)
            stateLabel.Position = UDim2.new(1, -46, 0, 0)
            stateLabel.BackgroundTransparency = 1
            stateLabel.Text = state and "ON" or "OFF"
            stateLabel.TextColor3 = state and T.Accent or T.TextDim
            stateLabel.TextSize = BloxHub.Settings.Type.Caption
            stateLabel.Font = self.Settings.FontBold
            stateLabel.TextXAlignment = Enum.TextXAlignment.Right
            stateLabel.ZIndex = 222
            stateLabel.Parent = rowBtn

            rowBtn.MouseEnter:Connect(function()
                Tween(rowBtn, {BackgroundColor3 = BloxHub.Settings.Theme.SecondaryGradient}, BloxHub.Settings.Animation.Micro)
            end)
            rowBtn.MouseLeave:Connect(function()
                Tween(rowBtn, {BackgroundColor3 = BloxHub.Settings.Theme.Secondary}, BloxHub.Settings.Animation.Micro)
            end)

            rowBtn.MouseButton1Click:Connect(function()
                state = not state
                stateLabel.Text = state and "ON" or "OFF"
                stateLabel.TextColor3 = state and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.TextDim
                if rowConfig.Callback then pcall(rowConfig.Callback, state) end
            end)

            widget.Rows[rowIdx] = {
                Type = "Toggle",
                GetValue = function() return state end,
                SetValue = function(_, value)
                    state = value and true or false
                    stateLabel.Text = state and "ON" or "OFF"
                    stateLabel.TextColor3 = state and BloxHub.Settings.Theme.Accent or BloxHub.Settings.Theme.TextDim
                end
            }

            RegisterThemeCallback(function()
                if not rowBtn.Parent then return end
                local TH = BloxHub.Settings.Theme
                SafeSet(rowBtn, "BackgroundColor3", TH.Secondary)
                SafeSet(rowLabel, "TextColor3", TH.Text)
                SafeSet(stateLabel, "TextColor3", state and TH.Accent or TH.TextDim)
            end)
        else
            local rowLabel = Instance.new("TextLabel")
            rowLabel.Name = "MiniLabel_" .. (rowConfig.Text or rowIdx)
            rowLabel.Size = UDim2.new(1, 0, 0, rowHeight)
            rowLabel.BackgroundColor3 = T.Secondary
            rowLabel.BackgroundTransparency = 0.55
            rowLabel.Text = rowConfig.Text or ""
            rowLabel.TextColor3 = T.TextDim
            rowLabel.TextSize = BloxHub.Settings.Type.Caption
            rowLabel.Font = self.Settings.Font
            rowLabel.TextXAlignment = Enum.TextXAlignment.Left
            rowLabel.TextTruncate = Enum.TextTruncate.AtEnd
            rowLabel.ZIndex = 221
            rowLabel.LayoutOrder = layoutOrder
            rowLabel.Parent = frame
            CreateUIPadding(10, 10, 0, 0, rowLabel)
            CreateUICorner(self.Settings.CornerRadius.Small, rowLabel)

            widget.Rows[rowIdx] = {
                Type = "Label",
                SetText = function(_, newText)
                    rowLabel.Text = tostring(newText)
                end
            }

            RegisterThemeCallback(function()
                if not rowLabel.Parent then return end
                local TH = BloxHub.Settings.Theme
                SafeSet(rowLabel, "TextColor3", TH.Text)
                SafeSet(rowLabel, "BackgroundColor3", TH.Secondary)
            end)
        end
    end

    if builtRows == 0 and not config.Title then
        local emptyRow = Instance.new("TextLabel")
        emptyRow.Size = UDim2.new(1, 0, 0, rowHeight)
        emptyRow.BackgroundTransparency = 1
        emptyRow.Text = "—"
        emptyRow.TextColor3 = T.TextDim
        emptyRow.TextSize = self.Settings.Type.Caption
        emptyRow.Font = self.Settings.Font
        emptyRow.ZIndex = 221
        emptyRow.LayoutOrder = 1
        emptyRow.Parent = frame
    end

    -- Lebar tetap, tinggi otomatis mengikuti jumlah baris (UIListLayout)
    frame.Size = UDim2.new(0, 210, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y

    MakeDraggable(frame, frame, window)

    -- Setelah selesai drag: clamp ke viewport + dock ke tepi bila dekat
    AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not frame or not frame.Parent then return end
        local abs = frame.AbsolutePosition
        local size = frame.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then return end
        local vp = GetViewportSize()
        local margin = 10
        local snapZone = 40

        local x = math.clamp(abs.X, 0, math.max(0, vp.X - size.X))
        local y = math.clamp(abs.Y, 0, math.max(0, vp.Y - size.Y))

        local distLeft, distRight = math.abs(x), math.abs((x + size.X) - vp.X)
        if distLeft < snapZone or distRight < snapZone then
            x = (distLeft <= distRight) and margin or (vp.X - size.X - margin)
        end
        local distTop, distBottom = math.abs(y), math.abs((y + size.Y) - vp.Y)
        if distTop < snapZone or distBottom < snapZone then
            y = (distTop <= distBottom) and margin or (vp.Y - size.Y - margin)
        end

        frame.Position = UDim2.fromOffset(x, y)
    end))

    function widget:Show()
        frame.Visible = true
    end

    function widget:Hide()
        frame.Visible = false
    end

    function widget:SetText(rowIndex, newText)
        local row = self.Rows[rowIndex]
        if row and row.SetText then row:SetText(newText) end
    end

    function widget:Destroy()
        for i, mw in ipairs(window.MiniWidgets or {}) do
            if mw == widget then table.remove(window.MiniWidgets, i) break end
        end
        pcall(function() frame:Destroy() end)
    end

    return widget
end

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

local NOTIF_START_Y = 0.05
local NOTIF_STAGGER = 0.11
local NOTIF_WIDTH = 300
-- With AnchorPoint (1, 0) the X offset anchors from the right edge,
-- so a small NEGATIVE offset keeps it on-screen; a large POSITIVE offset
-- hides it toward the right (for the slide-in/out).
local NOTIF_MARGIN_X = 12
local NOTIF_OFFSCREEN_X = 330

local function ReflowNotifications()
    for index, notif in ipairs(BloxHub.State.Notifications) do
        if notif.Frame and notif.Frame.Parent then
            local y = NOTIF_START_Y + (index - 1) * NOTIF_STAGGER
            Tween(notif.Frame, {Position = UDim2.new(1, -NOTIF_MARGIN_X, y, 0)}, BloxHub.Settings.Animation.Smooth)
        end
    end
end

-- Dijalankan lewat RunClean (thread bersih) — lihat CLEAN-THREAD DISPATCHER.
local function NotifyImpl(self, title, message, duration, notifType)
    duration = duration or 3
    notifType = notifType or "Info"

    local notifColors = {
        Info = self.Settings.Theme.Accent,
        Success = self.Settings.Theme.Success,
        Warning = self.Settings.Theme.Warning,
        Error = self.Settings.Theme.Error
    }

    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, NOTIF_WIDTH, 0, 80)
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.Position = UDim2.new(1, NOTIF_OFFSCREEN_X, NOTIF_START_Y, 0)
    notification.BackgroundColor3 = self.Settings.Theme.Background
    notification.BackgroundTransparency = 0.2 -- glass layer
    notification.BorderSizePixel = 0
    notification.ZIndex = 300
    notification.Parent = self.Core.ScreenGui

    CreateUICorner(self.Settings.CornerRadius.Medium, notification)
    Hairline(notification, 0.86)

    -- Slim rounded accent hairline, floating inside the toast.
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 2, 1, -20)
    accent.Position = UDim2.new(0, 0, 0, 10)
    accent.BackgroundColor3 = notifColors[notifType] or notifColors.Info
    accent.BorderSizePixel = 0
    accent.Parent = notification
    CreateUICorner(1, accent)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -26, 0, 24)
    titleLabel.Position = UDim2.new(0, 14, 0, 9)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Settings.Theme.Text
    titleLabel.TextSize = BloxHub.Settings.Type.Section
    titleLabel.Font = self.Settings.FontSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -26, 1, -42)
    messageLabel.Position = UDim2.new(0, 14, 0, 33)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.Settings.Theme.TextDim
    messageLabel.TextSize = BloxHub.Settings.Type.Body
    messageLabel.Font = self.Settings.Font
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification

    RegisterThemeCallback(function()
        if not notification.Parent then return end
        local T = BloxHub.Settings.Theme
        SafeSet(notification, "BackgroundColor3", T.Background)
        SafeSet(accent, "BackgroundColor3",
            notifType == "Success" and T.Success or
            notifType == "Warning" and T.Warning or
            notifType == "Error" and T.Error or T.Accent)
        SafeSet(titleLabel, "TextColor3", T.Text)
        SafeSet(messageLabel, "TextColor3", T.TextDim)
    end)

    local record = { Frame = notification }
    table.insert(self.State.Notifications, record)
    ReflowNotifications()

    -- Slide in (Quint, no bounce)
    Tween(notification, {Position = UDim2.new(1, -NOTIF_MARGIN_X, NOTIF_START_Y, 0)}, BloxHub.Settings.Animation.Smooth)

    task.delay(duration, function()
        if not notification or not notification.Parent then return end
        Tween(notification, {Position = UDim2.new(1, NOTIF_OFFSCREEN_X, NOTIF_START_Y, 0)}, BloxHub.Settings.Animation.Quick, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(BloxHub.Settings.Animation.Quick)
        if notification and notification.Parent then
            notification:Destroy()
        end
        local idx = table.find(self.State.Notifications, record)
        if idx then table.remove(self.State.Notifications, idx) end
        ReflowNotifications()
    end)

    return record
end

function BloxHub:Notify(title, message, duration, notifType)
    return RunClean(NotifyImpl, self, title, message, duration, notifType)
end

-- ═══════════════════════════════════════════════════════════
-- INITIALIZATION & RETURN
-- ═══════════════════════════════════════════════════════════

BloxHub:Init()

BloxHub:Notify(
    "BloxHub Framework Loaded",
    "Version " .. BloxHub.Version .. " | Ready to use",
    4,
    "Success"
)

return BloxHub