-- autofarm_ryenrhub.lua
-- RynerHUB | Auto Farm Violence District | Standalone
-- Part 1/4

local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local isMobile          = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local LOGO_ID           = "rbxassetid://110525773603905"

local SerhiiUI = (function()
local cloneref = (cloneref or clonereference or function(i) return i end)
local TweenService2     = cloneref(game:GetService("TweenService"))
local UserInputService2 = cloneref(game:GetService("UserInputService"))
local RunService2       = cloneref(game:GetService("RunService"))
local Players2          = cloneref(game:GetService("Players"))
local CoreGui2          = cloneref(game:GetService("CoreGui"))

local FONT_FAMILY = "rbxasset://fonts/families/GothamSSm.json"
local fontFamily  = FONT_FAMILY
local fontObjects = {}
local function font(weight) return Font.new(fontFamily, weight or Enum.FontWeight.Medium) end
local VERSION = "0.1.1-beta"
local function hex(h) return Color3.fromHex(h) end

local function buildTheme(name, c)
    return {
        Name = name, Background = c.Background, Sidebar = c.Sidebar or c.Background,
        Element = c.Element, ElementHover = c.ElementHover,
        Stroke = c.Stroke or hex("#ffffff"), StrokeTransparency = c.StrokeTransparency or 0.92,
        Text = c.Text, SubText = c.SubText, Accent = c.Accent,
        AccentText = c.AccentText or hex("#ffffff"),
        Toggle = c.Toggle or c.Accent, ToggleOff = c.ToggleOff or c.ElementHover,
        Slider = c.Slider or c.Accent, TabText = c.SubText, TabTextActive = c.Text,
        TabActive = c.TabActive or c.ElementHover, Notification = c.Notification or c.Element,
    }
end

local Themes = {
    Dark = buildTheme("Dark", { Background = hex("#0f0f10"), Sidebar = hex("#0b0b0c"), Element = hex("#1d1d20"), ElementHover = hex("#27272b"), Text = hex("#fafafa"), SubText = hex("#9a9aa3"), Accent = hex("#8b5cf6"), ToggleOff = hex("#3a3a40"), TabActive = hex("#1f1f23"), Notification = hex("#161618") }),
    Light = buildTheme("Light", { Background = hex("#f4f4f5"), Sidebar = hex("#ececef"), Element = hex("#ffffff"), ElementHover = hex("#e9e9ec"), Stroke = hex("#000000"), StrokeTransparency = 0.9, Text = hex("#18181b"), SubText = hex("#71717a"), Accent = hex("#7c3aed"), ToggleOff = hex("#d4d4d8"), TabActive = hex("#e4e4e7"), Notification = hex("#ffffff") }),
    Aqua = buildTheme("Aqua", { Background = hex("#0d1b1e"), Sidebar = hex("#0a1517"), Element = hex("#13282c"), ElementHover = hex("#193439"), Stroke = hex("#5eead4"), StrokeTransparency = 0.9, Text = hex("#ecfeff"), SubText = hex("#7dd3c8"), Accent = hex("#14b8a6"), AccentText = hex("#06302b"), ToggleOff = hex("#1f4a4a"), Slider = hex("#2dd4bf"), TabActive = hex("#163236"), Notification = hex("#102328") }),
    Rose = buildTheme("Rose", { Background = hex("#1f0a12"), Sidebar = hex("#180810"), Element = hex("#2c1019"), ElementHover = hex("#3a1622"), Stroke = hex("#fda4af"), StrokeTransparency = 0.9, Text = hex("#fff1f2"), SubText = hex("#e8849b"), Accent = hex("#f43f5e"), ToggleOff = hex("#4a1d28"), TabActive = hex("#36141f"), Notification = hex("#260c15") }),
    Emerald = buildTheme("Emerald", { Background = hex("#06140f"), Sidebar = hex("#040f0b"), Element = hex("#0c241a"), ElementHover = hex("#103024"), Stroke = hex("#6ee7b7"), StrokeTransparency = 0.9, Text = hex("#ecfdf5"), SubText = hex("#6ee7a8"), Accent = hex("#10b981"), AccentText = hex("#03241a"), ToggleOff = hex("#163a2c"), TabActive = hex("#102c20"), Notification = hex("#081b14") }),
    Indigo = buildTheme("Indigo", { Background = hex("#0f0f1f"), Sidebar = hex("#0b0b18"), Element = hex("#1a1a33"), ElementHover = hex("#222244"), Stroke = hex("#a5b4fc"), StrokeTransparency = 0.9, Text = hex("#eef2ff"), SubText = hex("#9aa3e0"), Accent = hex("#6366f1"), ToggleOff = hex("#2a2a52"), TabActive = hex("#1f1f3d"), Notification = hex("#141428") }),
    Amber = buildTheme("Amber", { Background = hex("#1c1404"), Sidebar = hex("#150f03"), Element = hex("#2a2009"), ElementHover = hex("#382b0d"), Stroke = hex("#fcd34d"), StrokeTransparency = 0.9, Text = hex("#fffbeb"), SubText = hex("#d6b465"), Accent = hex("#f59e0b"), AccentText = hex("#2a1d03"), ToggleOff = hex("#473714"), TabActive = hex("#33270c"), Notification = hex("#241a06") }),
    Crimson = buildTheme("Crimson", { Background = hex("#160606"), Sidebar = hex("#100404"), Element = hex("#241010"), ElementHover = hex("#321616"), Stroke = hex("#fca5a5"), StrokeTransparency = 0.9, Text = hex("#fef2f2"), SubText = hex("#cf8a8a"), Accent = hex("#dc2626"), ToggleOff = hex("#421b1b"), TabActive = hex("#2e1414"), Notification = hex("#1e0a0a") }),
    Midnight = buildTheme("Midnight", { Background = hex("#0a0f1e"), Sidebar = hex("#070b16"), Element = hex("#121a30"), ElementHover = hex("#1a2440"), Stroke = hex("#93c5fd"), StrokeTransparency = 0.9, Text = hex("#dbeafe"), SubText = hex("#7f9ad1"), Accent = hex("#2563eb"), ToggleOff = hex("#243150"), TabActive = hex("#16213d"), Notification = hex("#0d1426") }),
    Neon = buildTheme("Neon", { Background = hex("#0a0a12"), Sidebar = hex("#070710"), Element = hex("#13131f"), ElementHover = hex("#1c1c2e"), Stroke = hex("#22d3ee"), StrokeTransparency = 0.85, Text = hex("#f0f9ff"), SubText = hex("#8b8bb0"), Accent = hex("#e635c8"), ToggleOff = hex("#262640"), Slider = hex("#22d3ee"), TabActive = hex("#19192b"), Notification = hex("#101019") }),
    Slate = buildTheme("Slate", { Background = hex("#0f172a"), Sidebar = hex("#0b1120"), Element = hex("#1e293b"), ElementHover = hex("#293548"), Stroke = hex("#cbd5e1"), StrokeTransparency = 0.9, Text = hex("#f1f5f9"), SubText = hex("#94a3b8"), Accent = hex("#38bdf8"), AccentText = hex("#04293b"), ToggleOff = hex("#33415c"), TabActive = hex("#1c2a36"), Notification = hex("#131c30") }),
    Sunset = buildTheme("Sunset", { Background = hex("#1c0f0a"), Sidebar = hex("#160b07"), Element = hex("#2c1813"), ElementHover = hex("#3a2019"), Stroke = hex("#fdba74"), StrokeTransparency = 0.88, Text = hex("#fff7ed"), SubText = hex("#e0a06f"), Accent = hex("#f97316"), AccentText = hex("#2a1304"), ToggleOff = hex("#47281d"), Slider = hex("#fb923c"), TabActive = hex("#341c15"), Notification = hex("#26120c") }),
    Forest = buildTheme("Forest", { Background = hex("#0c1410"), Sidebar = hex("#080f0b"), Element = hex("#16241c"), ElementHover = hex("#1e3026"), Stroke = hex("#86efac"), StrokeTransparency = 0.9, Text = hex("#f0fdf4"), SubText = hex("#86b89a"), Accent = hex("#22c55e"), AccentText = hex("#04220f"), ToggleOff = hex("#243a2d"), TabActive = hex("#1a2c21"), Notification = hex("#0f1c15") }),
    Plum = buildTheme("Plum", { Background = hex("#160c1e"), Sidebar = hex("#100817"), Element = hex("#241430"), ElementHover = hex("#301a40"), Stroke = hex("#d8b4fe"), StrokeTransparency = 0.9, Text = hex("#faf5ff"), SubText = hex("#b794d4"), Accent = hex("#a855f7"), ToggleOff = hex("#3a2150"), TabActive = hex("#2c1840"), Notification = hex("#1c0f28") }),
    Obsidian = buildTheme("Obsidian", { Background = hex("#000000"), Sidebar = hex("#050505"), Element = hex("#101012"), ElementHover = hex("#18181c"), Stroke = hex("#ffffff"), StrokeTransparency = 0.9, Text = hex("#fafafa"), SubText = hex("#8a8a8a"), Accent = hex("#f5f5f5"), AccentText = hex("#000000"), ToggleOff = hex("#26262a"), Slider = hex("#d4d4d4"), TabActive = hex("#141416"), Notification = hex("#0a0a0a") }),
    Sky = buildTheme("Sky", { Background = hex("#081521"), Sidebar = hex("#06101a"), Element = hex("#0f2436"), ElementHover = hex("#163044"), Stroke = hex("#7dd3fc"), StrokeTransparency = 0.9, Text = hex("#f0f9ff"), SubText = hex("#7fb3d6"), Accent = hex("#0ea5e9"), AccentText = hex("#04293b"), ToggleOff = hex("#1c3950"), TabActive = hex("#132b3e"), Notification = hex("#0b1b29") }),
}

local Library = { Version = VERSION, Theme = Themes.Dark, ThemeName = "Dark", Themes = Themes, Flags = {}, Connections = {}, ThemeObjects = {}, Windows = {} }

local DefaultProps = {
    Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1) },
    CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1) },
    ScrollingFrame = { BorderSizePixel = 0, ScrollBarImageTransparency = 1, Active = true },
    TextLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, FontFace = font(), Text = "", RichText = true, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
    TextButton = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, AutoButtonColor = false, FontFace = font(), Text = "", TextColor3 = Color3.new(1,1,1), TextSize = 14 },
    TextBox = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, FontFace = font(), Text = "", ClearTextOnFocus = false, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
    ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
    ImageButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false },
}

local function tag(object, props)
    table.insert(Library.ThemeObjects, { Object = object, Props = props })
    for prop, key in pairs(props) do
        local value = Library.Theme[key]
        if value ~= nil then object[prop] = value end
    end
end

local function New(className, props, children)
    local object = Instance.new(className)
    local defaults = DefaultProps[className]
    if defaults then for k, v in pairs(defaults) do object[k] = v end end
    local themeTag
    if props then
        themeTag = props.ThemeTag
        for k, v in pairs(props) do if k ~= "ThemeTag" then object[k] = v end end
    end
    if children then for _, child in ipairs(children) do child.Parent = object end end
    if themeTag then tag(object, themeTag) end
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        local ok, fam = pcall(function() return object.FontFace.Family end)
        if ok and fam == fontFamily then table.insert(fontObjects, object) end
    end
    return object
end

local function tween(object, time, props, style, direction)
    local info = TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local t = TweenService2:Create(object, info, props)
    t:Play()
    return t
end

local function connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(Library.Connections, conn)
    return conn
end

local function safeCallback(fn, ...)
    if typeof(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SerhiiUI] callback error: " .. tostring(err)) end
end

local function corner(radius) return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) }) end

local function padding(all, extra)
    local p = New("UIPadding", { PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all), PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all) })
    if extra then for k, v in pairs(extra) do p[k] = v end end
    return p
end

local function listLayout(gap, dir, props)
    local l = New("UIListLayout", { Padding = UDim.new(0, gap or 0), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = dir or Enum.FillDirection.Vertical })
    if props then for k, v in pairs(props) do l[k] = v end end
    return l
end

local function dragify(frame, handle)
    handle = handle or frame
    local dragging, startPos, startInput
    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = input.Position
            local changed
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changed:Disconnect()
                end
            end)
        end
    end)
    connect(UserInputService2.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            tween(frame, 0.06, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),
            })
        end
    end)
end

local function round(value, step)
    if step and step > 0 then return math.floor(value / step + 0.5) * step end
    return value
end

local HttpService2 = cloneref(game:GetService("HttpService"))
local Icons = { URL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua", Pack = nil, Loaded = false, Cache = {} }
Library.Icons = Icons

local httpGet = function(url)
    if game.HttpGet then
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok then return body end
    end
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    return nil
end

local function ensureIcons()
    if Icons.Loaded then return end
    Icons.Loaded = true
    local ok, pack = pcall(function()
        local body = httpGet(Icons.URL)
        if not body then return nil end
        return loadstring(body)()
    end)
    if ok and pack then
        Icons.Pack = pack
        pcall(function() if pack.SetIconsType then pack.SetIconsType("lucide") end end)
    end
end

function Library:GetIcon(name)
    if not name or name == "" then return nil end
    if typeof(name) == "string" and name:match("^rbxassetid://") then
        return { Image = name, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
    end
    if Icons.Cache[name] ~= nil then return Icons.Cache[name] or nil end
    ensureIcons()
    local data
    if Icons.Pack then
        pcall(function()
            local result = Icons.Pack.Icon2 and Icons.Pack.Icon2(name) or (Icons.Pack.GetIcon and Icons.Pack.GetIcon(name))
            if typeof(result) == "string" then
                data = { Image = result, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
            elseif typeof(result) == "table" and result[1] then
                local rect = result[2] or {}
                data = { Image = result[1], RectOffset = rect.ImageRectPosition or Vector2.new(0, 0), RectSize = rect.ImageRectSize or Vector2.new(0, 0) }
            end
        end)
    end
    Icons.Cache[name] = data or false
    return data
end

local function makeIcon(name, sizeUDim, themeKey, color)
    local img = New("ImageLabel", {
        Size = sizeUDim or UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default,
        ThemeTag = themeKey and { ImageColor3 = themeKey } or nil,
    })
    local data = Library:GetIcon(name)
    if data then
        img.Image = data.Image
        if data.RectSize and (data.RectSize.X > 0 or data.RectSize.Y > 0) then
            img.ImageRectOffset = data.RectOffset
            img.ImageRectSize = data.RectSize
        end
    end
    if color then img.ImageColor3 = color end
    return img
end

local themeListeners = {}
local function onThemeChange(fn) table.insert(themeListeners, fn); return fn end

function Library:SetTheme(name)
    local theme = Themes[name] or (typeof(name) == "table" and name)
    if not theme then return end
    Library.Theme = theme
    Library.ThemeName = theme.Name or name
    for i = #Library.ThemeObjects, 1, -1 do
        local entry = Library.ThemeObjects[i]
        local object = entry.Object
        if object and object.Parent ~= nil then
            for prop, key in pairs(entry.Props) do
                local value = theme[key]
                if value ~= nil then
                    if typeof(value) == "Color3" or typeof(value) == "number" then
                        tween(object, 0.18, { [prop] = value })
                    else
                        pcall(function() object[prop] = value end)
                    end
                end
            end
        end
    end
    for i = #themeListeners, 1, -1 do
        local ok = pcall(themeListeners[i], theme)
        if not ok then table.remove(themeListeners, i) end
    end
    return theme
end

function Library:GetThemes()
    local names = {}
    for themeName in pairs(Themes) do table.insert(names, themeName) end
    table.sort(names, function(a, b)
        local rank = { Dark = 1, Light = 2 }
        local ra, rb = rank[a] or 3, rank[b] or 3
        if ra ~= rb then return ra < rb end
        return a < b
    end)
    return names
end

function Library:GetTheme() return Library.ThemeName end

local function getParentGui()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local LocalPlayer2 = Players2.LocalPlayer
    if RunService2:IsStudio() and LocalPlayer2 then return LocalPlayer2:WaitForChild("PlayerGui") end
    local canCore = pcall(function()
        local probe = Instance.new("Folder")
        probe.Parent = CoreGui2
        probe:Destroy()
    end)
    if canCore then return CoreGui2 end
    return LocalPlayer2 and LocalPlayer2:WaitForChild("PlayerGui")
end

local function protect(gui)
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui)
        elseif protectgui then protectgui(gui) end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "SerhiiUI", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, DisplayOrder = 999999,
    Parent = getParentGui(),
})
protect(ScreenGui)
Library.ScreenGui = ScreenGui

local notificationLayout = listLayout(8, Enum.FillDirection.Vertical, {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
})
local NotificationLayer = New("Frame", {
    Name = "Notifications", BackgroundTransparency = 1,
    Size = UDim2.new(1, -28, 1, -28), Position = UDim2.new(0, 14, 0, 14),
    Parent = ScreenGui,
}, { notificationLayout })

function Library:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 4
    local hasIcon = config.Icon ~= nil and config.Icon ~= ""
    local holder = New("Frame", { Size = UDim2.new(0, 300, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = NotificationLayer })
    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 0,
        ThemeTag = { BackgroundColor3 = "Notification" }, Parent = holder,
    }, { corner(12), New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }) })
    local textLeft = 15
    if hasIcon then
        local icon = makeIcon(config.Icon, UDim2.new(0, 20, 0, 20), "Accent")
        icon.AnchorPoint = Vector2.new(0, 0)
        icon.Position = UDim2.new(0, 14, 0, 14)
        icon.Parent = card
        textLeft = 14 + 20 + 10
    end
    New("Frame", {
        Size = UDim2.new(1, -(textLeft + 14), 0, 0), Position = UDim2.new(0, textLeft, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card,
    }, {
        listLayout(3), padding(0, { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
        New("TextLabel", { Text = title, FontFace = font(Enum.FontWeight.SemiBold), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ThemeTag = { TextColor3 = "Text" } }),
        content ~= "" and New("TextLabel", { Text = content, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ThemeTag = { TextColor3 = "SubText" } }) or nil,
    })
    tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
    task.delay(duration, function()
        tween(card, 0.3, { Position = UDim2.new(1, 24, 0, 0) }, Enum.EasingStyle.Quint)
        task.wait(0.32)
        holder:Destroy()
    end)
end

local function makeElement(parent, opts)
    opts = opts or {}
    local hasDesc = opts.Desc ~= nil and opts.Desc ~= ""
    local controlWidth = opts.ControlWidth or 44
    local minHeight = opts.Height or 40
    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, minHeight), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0, ThemeTag = { BackgroundColor3 = "Element" },
        Parent = parent, LayoutOrder = opts.LayoutOrder or 1,
    }, {
        corner(10), New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }),
        New("UISizeConstraint", { MinSize = Vector2.new(0, minHeight) }),
    })
    local iconInset = 14
    if opts.Icon and opts.Icon ~= "" then
        local iconImage = makeIcon(opts.Icon, UDim2.new(0, 18, 0, 18), "Text")
        iconImage.AnchorPoint = Vector2.new(0, 0)
        iconImage.Position = UDim2.new(0, 14, 0, 11)
        iconImage.Parent = card
        iconInset = 14 + 18 + 10
    end
    local textCol = New("Frame", {
        Size = UDim2.new(1, -(controlWidth + iconInset + 12), 0, 0),
        Position = UDim2.new(0, iconInset, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = card,
    }, { listLayout(2), padding(0, { PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11) }) })
    local titleLabel = New("TextLabel", { Text = opts.Title or "", FontFace = font(Enum.FontWeight.Medium), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ThemeTag = { TextColor3 = "Text" }, Parent = textCol })
    local descLabel
    if hasDesc then descLabel = New("TextLabel", { Text = opts.Desc, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ThemeTag = { TextColor3 = "SubText" }, Parent = textCol }) end
    local control = New("Frame", { Size = UDim2.new(0, controlWidth, 1, 0), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Parent = card })
    local element = { Card = card, Control = control, TitleLabel = titleLabel, DescLabel = descLabel }
    if opts.Hover ~= false then
        connect(card.MouseEnter, function() tween(card, 0.15, { BackgroundColor3 = Library.Theme.ElementHover }) end)
        connect(card.MouseLeave, function() tween(card, 0.15, { BackgroundColor3 = Library.Theme.Element }) end)
    end
    function element:SetTitle(text) titleLabel.Text = text end
    function element:SetDesc(text) if descLabel then descLabel.Text = text end end
    return element
end

local Elements = {}
local function bindElements(target, parentFrame)
    for name, constructor in pairs(Elements) do
        target[name] = function(_, elementConfig) return constructor(parentFrame, elementConfig) end
    end
    return target
end

function Elements.Section(page, config)
    config = config or {}
    local opened = config.Opened ~= false
    local container = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = page }, { listLayout(6) })
    local header = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = container, LayoutOrder = 0 })
    local titleLabel = New("TextLabel", { Text = config.Title or "Section", FontFace = font(Enum.FontWeight.SemiBold), TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, ThemeTag = { TextColor3 = "Text" }, Parent = header })
    local chev = makeIcon("chevron-down", UDim2.new(0, 18, 0, 18), "SubText")
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -2, 0.5, 0)
    chev.Parent = header
    local body = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = opened, Parent = container, LayoutOrder = 1 }, { listLayout(6) })
    local function setOpen(state) opened = state; body.Visible = state; tween(chev, 0.18, { Rotation = state and 180 or 0 }) end
    chev.Rotation = opened and 180 or 0
    connect(header.MouseButton1Click, function() setOpen(not opened) end)
    local section = { Object = container, Body = body, SetTitle = function(_, t) titleLabel.Text = t end, SetOpen = function(_, o) setOpen(o and true or false) end, Toggle = function() setOpen(not opened) end }
    bindElements(section, body)
    return section
end

function Elements.Divider(page)
    local line = New("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = 0.85, ThemeTag = { BackgroundColor3 = "Stroke" }, Parent = page })
    return { Object = line }
end

function Elements.Paragraph(page, config)
    config = config or {}
    local el = makeElement(page, { Title = config.Title, Desc = config.Desc, Icon = config.Icon, Hover = false, ControlWidth = 0 })
    return { Object = el.Card, SetTitle = function(_, t) el:SetTitle(t) end, SetDesc = function(_, d) el:SetDesc(d) end }
end

function Elements.Button(page, config)
    config = config or {}
    local el = makeElement(page, { Title = config.Title or "Button", Desc = config.Desc, Icon = config.Icon, ControlWidth = 18 })
    local chev = makeIcon("chevron-right", UDim2.new(0, 16, 0, 16), "SubText")
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, 0, 0.5, 0)
    chev.Parent = el.Control
    local hit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = el.Card, ZIndex = 5 })
    connect(hit.MouseButton1Click, function()
        tween(el.Card, 0.08, { BackgroundColor3 = Library.Theme.ElementHover }, Enum.EasingStyle.Quad)
        task.delay(0.08, function() tween(el.Card, 0.2, { BackgroundColor3 = Library.Theme.Element }) end)
        task.spawn(safeCallback, config.Callback)
    end)
    return { Object = el.Card, SetTitle = function(_, t) el:SetTitle(t) end, SetCallback = function(_, fn) config.Callback = fn end }
end

function Elements.Toggle(page, config)
    config = config or {}
    local value = config.Default or config.Value or false
    local el = makeElement(page, { Title = config.Title or "Toggle", Desc = config.Desc, Icon = config.Icon, ControlWidth = 44 })
    local track = New("Frame", { Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff, Parent = el.Control }, { corner(11) })
    local knob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(value and 1 or 0, 0.5), BackgroundColor3 = Color3.fromHex("#ffffff"), Parent = track }, { corner(9) })
    local hit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = el.Card, ZIndex = 5 })
    local object
    local function visualUpdate(animate)
        local t = animate and 0.16 or 0
        tween(track, t, { BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff })
        tween(knob, t, { Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(value and 1 or 0, 0.5) }, Enum.EasingStyle.Quint)
    end
    local function set(v, fireCallback, animate)
        value = v and true or false
        visualUpdate(animate ~= false)
        if fireCallback ~= false then task.spawn(safeCallback, config.Callback, value) end
    end
    connect(hit.MouseButton1Click, function() set(not value, true, true) end)
    onThemeChange(function()
        if el.Card.Parent == nil then error("dead") end
        track.BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff
    end)
    object = { Object = el.Card, Set = function(_, v, fire) set(v, fire ~= false, true) end, Get = function() return value end, Value = value }
    if config.Flag then Library.Flags[config.Flag] = object end
    return object
end

function Elements.Input(page, config)
    config = config or {}
    local el = makeElement(page, { Title = config.Title or "Input", Desc = config.Desc, Icon = config.Icon, ControlWidth = 140 })
    local box = New("Frame", { Size = UDim2.new(0, 140, 0, 28), Position = UDim2.new(1, 0, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), ThemeTag = { BackgroundColor3 = "ElementHover" }, Parent = el.Control }, { corner(6), New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }), padding(0, { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
    local input = New("TextBox", { Text = config.Default or "", PlaceholderText = config.Placeholder or "...", TextSize = 13, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" }, Parent = box })
    connect(input.FocusLost, function(enterPressed) task.spawn(safeCallback, config.Callback, input.Text, enterPressed) end)
    connect(input.Focused, function() tween(box, 0.15, { BackgroundColor3 = Library.Theme.Element }) end)
    connect(input.FocusLost, function() tween(box, 0.15, { BackgroundColor3 = Library.Theme.ElementHover }) end)
    local object = { Object = el.Card, Set = function(_, v) input.Text = tostring(v) end, Get = function() return input.Text end }
    if config.Flag then Library.Flags[config.Flag] = object end
    return object
end

local function createTab(window, config)
    config = config or {}
    local Tab = { Title = config.Title or "Tab", Icon = config.Icon }
    window.TabCount = window.TabCount + 1
    local index = window.TabCount
    local button = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, ThemeTag = { BackgroundColor3 = "TabActive" }, Parent = window.TabList, LayoutOrder = index }, { corner(9) })
    local activeBar = New("Frame", { Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ThemeTag = { BackgroundColor3 = "Accent" }, BackgroundTransparency = 1, Parent = button }, { corner(2) })
    local textInset = 14
    if config.Icon and config.Icon ~= "" then
        local icon = makeIcon(config.Icon, UDim2.new(0, 17, 0, 17), "TabText")
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 12, 0.5, 0)
        icon.Parent = button
        Tab.IconImage = icon
        textInset = 12 + 17 + 8
    end
    local label = New("TextLabel", { Text = Tab.Title, FontFace = font(Enum.FontWeight.Medium), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -textInset - 8, 1, 0), Position = UDim2.new(0, textInset, 0, 0), ThemeTag = { TextColor3 = "TabText" }, Parent = button })
    local page = New("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageTransparency = 0.5, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = window.ContentHolder }, { listLayout(8), padding(2, { PaddingRight = UDim.new(0, 8) }) })
    Tab.SidebarButton = button
    Tab.Page = page
    Tab.Index = index
    function Tab:Select() window:SelectTab(index) end
    bindElements(Tab, page)
    connect(button.MouseButton1Click, function() window:SelectTab(index) end)
    connect(button.MouseEnter, function() if window.CurrentTab ~= index then tween(button, 0.15, { BackgroundTransparency = 0.6 }) end end)
    connect(button.MouseLeave, function() if window.CurrentTab ~= index then tween(button, 0.15, { BackgroundTransparency = 1 }) end end)
    window.Tabs[index] = { Button = button, Page = page, Label = label, ActiveBar = activeBar, Icon = Tab.IconImage }
    if not config.Implicit and window.SetSidebar then window:SetSidebar(true) end
    if not window.CurrentTab then window:SelectTab(index) end
    return Tab
end

function Library:CreateWindow(config)
    config = config or {}
    local Window = { Library = Library, Title = config.Title or "SerhiiUI", SubTitle = config.SubTitle or config.Author, ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl, Tabs = {}, TabCount = 0, CurrentTab = nil, Minimized = false }
    local size = config.Size or UDim2.fromOffset(560, 420)
    local sidebarWidth = config.SidebarWidth or 168
    local topbarHeight = 46
    local main = New("Frame", { Name = "Window", Size = size, Position = config.Position or UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = ScreenGui })
    local root = New("Frame", { Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, ThemeTag = { BackgroundColor3 = "Background" }, Parent = main }, { corner(config.Radius or 16), New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }) })
    Window.Root = root
    local dragHandle = New("Frame", { Size = UDim2.new(0, 110, 0, 4), Position = UDim2.new(0.5, 0, 1, -8), AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 0.65, ThemeTag = { BackgroundColor3 = "Text" }, ZIndex = 6, Parent = root }, { corner(2) })
    local topbar = New("Frame", { Size = UDim2.new(1, 0, 0, topbarHeight), BackgroundTransparency = 1, Parent = root }, { padding(0, { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) }) })
    local titleRow = New("Frame", { Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Parent = topbar }, { listLayout(8, Enum.FillDirection.Horizontal, { VerticalAlignment = Enum.VerticalAlignment.Center }) })
    if config.Icon and config.Icon ~= "" then
        local winIcon = makeIcon(config.Icon, UDim2.new(0, config.IconSize or 22, 0, config.IconSize or 22), "Text")
        winIcon.LayoutOrder = 1
        winIcon.Parent = titleRow
        Window.IconImage = winIcon
    end
    New("Frame", { Size = UDim2.new(1, -32, 1, 0), BackgroundTransparency = 1, LayoutOrder = 2, Parent = titleRow }, {
        listLayout(1, Enum.FillDirection.Vertical, { VerticalAlignment = Enum.VerticalAlignment.Center }),
        New("TextLabel", { Text = Window.Title, FontFace = font(Enum.FontWeight.SemiBold), TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 18), ThemeTag = { TextColor3 = "Text" } }),
        Window.SubTitle and New("TextLabel", { Text = Window.SubTitle, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 14), ThemeTag = { TextColor3 = "SubText" } }) or nil,
    })
    local controls = New("Frame", { Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Parent = topbar }, { listLayout(4, Enum.FillDirection.Horizontal, { HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center }) })
    local function controlButton(iconName, order, callback)
        local btn = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1, LayoutOrder = order, ThemeTag = { BackgroundColor3 = "ElementHover" }, Parent = controls }, { corner(8) })
        local icon = makeIcon(iconName, UDim2.new(0, 16, 0, 16), "SubText")
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.Parent = btn
        connect(btn.MouseEnter, function() tween(btn, 0.12, { BackgroundTransparency = 0 }); tween(icon, 0.12, { ImageColor3 = Library.Theme.Text }) end)
        connect(btn.MouseLeave, function() tween(btn, 0.12, { BackgroundTransparency = 1 }); tween(icon, 0.12, { ImageColor3 = Library.Theme.SubText }) end)
        connect(btn.MouseButton1Click, callback)
        return btn, icon
    end
    controlButton("minus", 1, function() Window:Minimize() end)
    controlButton("x", 3, function() Window:Close() end)
    local sidebarFrame = New("Frame", { Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight), Position = UDim2.new(0, 0, 0, topbarHeight), ThemeTag = { BackgroundColor3 = "Sidebar" }, BackgroundTransparency = 0, Parent = root })
    local tabList = New("ScrollingFrame", { Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight - 12), Position = UDim2.new(0, 0, 0, topbarHeight + 6), BackgroundTransparency = 1, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = root }, { listLayout(4), padding(0, { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 2) }) })
    Window.TabList = tabList
    local divider = New("Frame", { Size = UDim2.new(0, 1, 1, -topbarHeight - 16), Position = UDim2.new(0, sidebarWidth, 0, topbarHeight + 8), BackgroundTransparency = 0.85, ThemeTag = { BackgroundColor3 = "Stroke" }, Parent = root })
    local contentHolder = New("Frame", { Size = UDim2.new(1, -sidebarWidth - 12, 1, -topbarHeight - 12), Position = UDim2.new(0, sidebarWidth + 12, 0, topbarHeight + 6), BackgroundTransparency = 1, ClipsDescendants = true, Parent = root })
    Window.ContentHolder = contentHolder
    function Window:SetSidebar(visible)
        Window.SidebarVisible = visible
        sidebarFrame.Visible = visible
        tabList.Visible = visible
        divider.Visible = visible
        if visible then
            contentHolder.Size = UDim2.new(1, -sidebarWidth - 12, 1, -topbarHeight - 12)
            contentHolder.Position = UDim2.new(0, sidebarWidth + 12, 0, topbarHeight + 6)
        else
            contentHolder.Size = UDim2.new(1, -24, 1, -topbarHeight - 12)
            contentHolder.Position = UDim2.new(0, 12, 0, topbarHeight + 6)
        end
    end
    Window:SetSidebar(false)
    dragify(main, topbar)
    dragify(main, dragHandle)
    function Window:SelectTab(targetIndex)
        Window.CurrentTab = targetIndex
        for i, data in pairs(Window.Tabs) do
            local active = i == targetIndex
            data.Page.Visible = active
            tween(data.Button, 0.15, { BackgroundTransparency = active and 0 or 1 })
            tween(data.Label, 0.15, { TextColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText })
            if data.Icon then tween(data.Icon, 0.15, { ImageColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText }) end
            tween(data.ActiveBar, 0.15, { BackgroundTransparency = active and 0 or 1 })
        end
    end
    function Window:Tab(tabConfig) return createTab(Window, tabConfig) end
    local function defaultPage()
        if not Window.DefaultTab then
            Window.DefaultTab = createTab(Window, { Title = config.DefaultTabTitle or "Main", Implicit = true })
        end
        return Window.DefaultTab
    end
    for name in pairs(Elements) do
        Window[name] = function(_, elementConfig)
            local tab = defaultPage()
            return tab[name](tab, elementConfig)
        end
    end
    local collapsed = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)
    function Window:Minimize()
        Window.Minimized = true
        tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
        task.delay(0.31, function() if Window.Minimized then main.Visible = false end end)
    end
    function Window:Open()
        Window.Minimized = false
        main.Visible = true
        main.Size = collapsed
        tween(main, 0.4, { Size = size }, Enum.EasingStyle.Back)
    end
    function Window:Close()
        tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
        task.delay(0.32, function() Window:Destroy() end)
    end
    function Window:Destroy()
        Window.Destroyed = true
        for _, conn in ipairs(Library.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
    end
    connect(UserInputService2.InputBegan, function(input, processed)
        if processed then return end
        if input.KeyCode == Window.ToggleKey then
            if Window.Minimized then Window:Open() else Window:Minimize() end
        end
    end)
    onThemeChange(function()
        if Window.Destroyed then error("dead") end
        if Window.CurrentTab then Window:SelectTab(Window.CurrentTab) end
    end)
    main.Size = collapsed
    tween(main, 0.45, { Size = size }, Enum.EasingStyle.Back)
    table.insert(Library.Windows, Window)
    return Window
end

return Library
end)()

SerhiiUI:SetTheme("Plum")

local CURRENT_VERSION = 1
ConfigData = { _version = CURRENT_VERSION }
ConfigFolder = "RynerHUB_AutoFarm/"

local registry = {}
local usedIds = {}

local function uniqueId(base)
    base = tostring(base)
    usedIds[base] = (usedIds[base] or 0) + 1
    if usedIds[base] == 1 then return base end
    return base .. "#" .. usedIds[base]
end

local function register(id, getter, applier, default)
    table.insert(registry, { id = id, get = getter, apply = applier, default = default })
end

notif = function(msg, duration)
    SerhiiUI:Notify({
        Title = "RynerHUB",
        Content = tostring(msg),
        Duration = tonumber(duration) or 3,
        Icon = LOGO_ID,
    })
end

local function makeApi(raw, scope, noSave)
    local api = {}
    local order = 0
    local function place(handle)
        order = order + 1
        if handle and handle.Object then handle.Object.LayoutOrder = order end
        return handle
    end
    local function newId(title)
        if noSave then return nil end
        return uniqueId(scope .. "/" .. tostring(title))
    end
    function api:AddSection(title, opened)
        local c = type(title) == "table" and title or { Title = title, Opened = opened }
        local name = tostring(c.Title or c.Name or "Section")
        local rawSec = raw:Section({ Title = name, Opened = (c.Opened == true) })
        place(rawSec)
        return makeApi(rawSec, scope .. "/" .. name, noSave)
    end
    function api:AddParagraph(c)
        c = c or {}
        local rawEl = raw:Paragraph({ Title = c.Title, Desc = c.Content or c.Desc, Icon = c.Icon })
        place(rawEl)
        local h = { Object = rawEl.Object }
        function h:SetContent(t) rawEl:SetDesc(t) end
        return h
    end
    function api:AddButton(c)
        c = c or {}
        local rawEl = raw:Button({ Title = c.Title, Desc = c.Content or c.Desc, Icon = c.Icon, Callback = c.Callback })
        return place(rawEl)
    end
    function api:AddToggle(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local default = false
        if c.Default ~= nil then default = c.Default elseif c.Value ~= nil then default = c.Value end
        default = default and true or false
        local rawEl = raw:Toggle({ Title = c.Title, Desc = c.Content or c.Desc, Icon = c.Icon, Default = default, Callback = function(v) if id then ConfigData[id] = v end; if userCb then userCb(v) end end })
        place(rawEl)
        local h = { Object = rawEl.Object }
        function h:Set(v, fire) rawEl:Set(v and true or false, fire) end
        function h:Get() return rawEl:Get() end
        return h
    end
    function api:AddInput(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local default = c.Default ~= nil and tostring(c.Default) or ""
        local rawEl = raw:Input({ Title = c.Title, Desc = c.Content or c.Desc, Icon = c.Icon, Default = default, Placeholder = c.Placeholder, Callback = function(text) if id then ConfigData[id] = text end; if userCb then userCb(text) end end })
        place(rawEl)
        local h = { Object = rawEl.Object }
        function h:Set(v) rawEl:Set(v) end
        function h:Get() return rawEl:Get() end
        return h
    end
    return api
end

local executorName0 = "Unknown"
pcall(function() executorName0 = identifyexecutor() end)

local win = SerhiiUI:CreateWindow({
    Title = "RynerHUB",
    SubTitle = "Auto Farm | " .. tostring(executorName0),
    Icon = LOGO_ID,
    IconSize = 28,
    Size = isMobile and UDim2.fromOffset(520, 300) or UDim2.fromOffset(640, 440),
    SidebarWidth = isMobile and 130 or 168,
})

Window = win
Tabs = {
    AutoFarm = makeApi(win:Tab({ Title = "Auto Farm", Icon = "wheat" }), "AutoFarm", false),
    Info     = makeApi(win:Tab({ Title = "Info", Icon = "user" }), "Info", false),
}

-- =========================================================
-- FLOATING LOGO BUTTON
-- =========================================================
do
    local function getParent()
        if gethui then local ok, hui = pcall(gethui); if ok and hui then return hui end end
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok and cg then return cg end
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    local parent = getParent()
    local old = parent:FindFirstChild("RynerHUB_FloatingLogo")
    if old then old:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RynerHUB_FloatingLogo"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = parent

    local LOGO_SIZE = isMobile and 70 or 80
    local PADDING = 12

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, LOGO_SIZE, 0, LOGO_SIZE)
    btn.Position = UDim2.new(0, PADDING, 0, PADDING)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 1000
    btn.Parent = screenGui

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Image = LOGO_ID
    img.ZIndex = 1001
    img.Parent = btn

    task.spawn(function()
        local t0 = os.clock()
        while os.clock() - t0 < 3 do if img.IsLoaded then return end task.wait(0.2) end
        if not img.IsLoaded then
            img.Image = "rbxthumb://type=Asset&id=110525773603905&w=150&h=150"
            local t1 = os.clock()
            while os.clock() - t1 < 3 do if img.IsLoaded then return end task.wait(0.2) end
            if not img.IsLoaded then
                img.Visible = false
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "R"
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = math.floor(LOGO_SIZE * 0.7)
                lbl.TextColor3 = Color3.fromRGB(168, 85, 247)
                lbl.ZIndex = 1002
                lbl.Parent = btn
            end
        end
    end)

    local dragging, moved = false, false
    local dragStart, startPos = nil, nil
    local THRESHOLD = 8

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if delta.Magnitude >= THRESHOLD then moved = true end
            if moved then
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not moved and Window then
                if Window.Minimized then Window:Open() else Window:Minimize() end
            end
            dragStart, startPos = nil, nil
            moved = false
        end
    end)
end

-- =========================================================
-- AUTO FARM LOGIC
-- =========================================================
local AutoFarmVD = {}
local AF_Config = {
    Enabled=false, AutoHop=true, MinPlayers=3, MaxPlayers=8,
    AutoQueue=true, AutoTPFinish=true, AutoAntiAFK=true,
    AutoExecute=true, AutoLevelScrew=true, AutoLevelGear=true,
    WebhookURL="", WebhookEnable=false, HopDelay=30,
    _main=nil, _afk=nil, _exec=nil, _lvl=nil, _lastHop=0, _live=nil, _secret=nil, _runs=0, _gameName=nil,
    AutoReExecute=true, ScriptURL="", AutoLoadConfig=true, _queued=false, _resume=false,
}

local function afNotify(t, c, d)
    SerhiiUI:Notify({ Title = t, Content = c or "", Duration = d or 3, Icon = LOGO_ID })
end

local function getGameName()
    if AF_Config._gameName then return AF_Config._gameName end
    local name = "Unknown"
    pcall(function() name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    AF_Config._gameName = name
    return name
end

local function readStat(...)
    local result = "?"
    pcall(function()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if not ls then return end
        for _, n in ipairs({...}) do
            local v = ls:FindFirstChild(n)
            if v then result = v.Value; return end
        end
    end)
    return result
end

local function postEmbed(embed)
    if not AF_Config.WebhookEnable or AF_Config.WebhookURL == "" then return end
    embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local payload = { username = "RynerHUB", embeds = { embed } }
    local ok, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return end
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end
    pcall(function()
        req({ Url = AF_Config.WebhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = encoded })
    end)
end

-- kind: nil = snapshot lengkap (dengan Item), "server" = tanpa Item (Auto-rejoin monitor)
local function sendWebhook(title, desc, color, kind)
    if not AF_Config.WebhookEnable or AF_Config.WebhookURL == "" then return end
    local icon, rest = tostring(title):match("^(%S+)%s+(.+)$")
    local fullTitle = icon and (icon .. " RynerHUB — " .. rest) or ("RynerHUB — " .. tostring(title))

    local itemName = "?"
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") or child.Name:lower():find("item") then itemName = child.Name; return end
        end
        local acc = char:FindFirstChildOfClass("Accessory")
        if acc then itemName = acc.Name end
    end)

    local fields = {
        { name = "👤 Player", value = LocalPlayer.Name, inline = false },
        { name = "🆔 UserId", value = tostring(LocalPlayer.UserId), inline = false },
        { name = "🎮 Game", value = getGameName() .. "\nPlaceId: " .. tostring(game.PlaceId), inline = false },
        { name = "🖥️ Server", value = tostring(game.JobId), inline = false },
        { name = "🏆 Level", value = tostring(readStat("Level")), inline = false },
        { name = "⭐ EXP", value = tostring(readStat("EXP")), inline = false },
        { name = "🔩 Screws", value = tostring(readStat("Screws", "Screw")), inline = false },
    }
    if kind ~= "server" then
        table.insert(fields, { name = "🎒 Item", value = itemName, inline = false })
    end
    postEmbed({
        title = fullTitle,
        description = desc,
        color = color or 0x8b5cf6,
        fields = fields,
        footer = { text = kind == "server" and "RynerHUB • Auto-rejoin monitor" or "RynerHUB • Violence District" },
    })
end

local function fmtDelta(n)
    return (n >= 0 and "+" or "") .. tostring(n)
end

local function startLiveMonitor()
    if AF_Config._live then return end
    AF_Config._live = task.spawn(function()
        local lastExp = tonumber(readStat("EXP"))
        local lastScrew = tonumber(readStat("Screws", "Screw"))
        while AF_Config.Enabled do
            task.wait(5)
            local exp = tonumber(readStat("EXP"))
            local scr = tonumber(readStat("Screws", "Screw"))
            local dE = (exp and lastExp) and (exp - lastExp) or 0
            local dS = (scr and lastScrew) and (scr - lastScrew) or 0
            if dE ~= 0 or dS ~= 0 then
                postEmbed({
                    title = "📈 RynerHUB — Perubahan Terdeteksi",
                    description = string.format("⭐ **EXP** %s (%s)\n🔩 **Screws** %s (%s)", tostring(exp or "?"), fmtDelta(dE), tostring(scr or "?"), fmtDelta(dS)),
                    color = 0x3b82f6,
                    fields = {
                        { name = "👤 Username", value = LocalPlayer.Name, inline = false },
                        { name = "🆔 UserId", value = tostring(LocalPlayer.UserId), inline = false },
                        { name = "🔄 Total Run", value = tostring(AF_Config._runs), inline = false },
                    },
                    footer = { text = "RynerHUB • Live Monitor" },
                })
            end
            if exp then lastExp = exp end
            if scr then lastScrew = scr end
        end
        AF_Config._live = nil
    end)
end

local function sendSecret(itemName)
    postEmbed({
        title = "💎 RynerHUB — SECRET DITEMUKAN!",
        description = string.format("Kamu mendapatkan **%s** (x1)!", tostring(itemName)),
        color = 0xfbbf24,
        fields = {
            { name = "👤 Username", value = LocalPlayer.Name, inline = false },
            { name = "🆔 UserId", value = tostring(LocalPlayer.UserId), inline = false },
            { name = "🎮 Game", value = getGameName() .. " / " .. tostring(game.PlaceId), inline = false },
            { name = "📦 Item/Secret", value = tostring(itemName), inline = false },
            { name = "🔄 Run ke-", value = tostring(AF_Config._runs + 1), inline = false },
        },
        footer = { text = "RynerHUB • Secret Monitor" },
    })
end

local function startSecretMonitor()
    if AF_Config._secret then return end
    task.spawn(function()
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 10)
        if not bp or AF_Config._secret then return end
        AF_Config._secret = bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then sendSecret(child.Name) end
        end)
    end)
end

-- =========================================================
-- CONFIG (save / auto load) + AUTO RE-EXECUTE
-- =========================================================
local CONFIG_FOLDER = "RynerHUB"
local CONFIG_FILE   = CONFIG_FOLDER .. "/AutoFarm_config.json"
local LOCAL_COPY    = CONFIG_FOLDER .. "/ryenrhub_farm_beta.lua"
local CONFIG_KEYS = {
    "AutoHop", "MinPlayers", "MaxPlayers", "HopDelay",
    "AutoQueue", "AutoTPFinish", "AutoAntiAFK", "AutoExecute",
    "AutoLevelScrew", "AutoLevelGear",
    "WebhookURL", "WebhookEnable",
    "AutoReExecute", "ScriptURL", "AutoLoadConfig",
}

local function fsOK()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function saveConfig(silent)
    if not fsOK() then
        if not silent then afNotify("Config", "Executor tidak support writefile.", 3) end
        return false
    end
    local data = {}
    for _, k in ipairs(CONFIG_KEYS) do data[k] = AF_Config[k] end
    data.ResumeFarm = AF_Config.Enabled == true
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    pcall(function()
        if makefolder and isfolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
    local wrote = pcall(writefile, CONFIG_FILE, encoded)
    if not silent then afNotify("Config", wrote and "Config disimpan." or "Gagal menyimpan config.", 3) end
    return wrote
end

local function readConfigFile()
    if not fsOK() then return nil end
    local data
    pcall(function()
        if isfile(CONFIG_FILE) then data = HttpService:JSONDecode(readfile(CONFIG_FILE)) end
    end)
    return type(data) == "table" and data or nil
end

local function applyConfigData(data)
    for _, k in ipairs(CONFIG_KEYS) do
        if data[k] ~= nil and type(data[k]) == type(AF_Config[k]) then AF_Config[k] = data[k] end
    end
end

-- setter yang sekaligus autosave
local function cfg(key, value)
    AF_Config[key] = value
    saveConfig(true)
end

-- Auto load config pas script jalan (sebelum UI dibuat, supaya Default UI ikut config)
do
    local genv = (getgenv and getgenv()) or _G
    local data = readConfigFile()
    if data and data.AutoLoadConfig ~= false then
        applyConfigData(data)
        AF_Config._resume = (data.ResumeFarm == true) and (genv.RynerHUB_Resume == true)
    end
    genv.RynerHUB_Resume = nil
end

local function getQueueFn()
    return queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
end

-- Antrekan script supaya jalan lagi otomatis setelah teleport (hop server / pindah map)
local function queueReExecute()
    if AF_Config._queued then return true end
    if not AF_Config.AutoReExecute then return false end
    local q = getQueueFn()
    if not q then return false end
    local genv = (getgenv and getgenv()) or _G
    local url = AF_Config.ScriptURL
    if type(url) ~= "string" or url == "" then url = genv.RynerHUB_ScriptURL end
    local body
    if type(url) == "string" and url ~= "" then
        body = string.format("loadstring(game:HttpGet(%q))()", url)
    elseif fsOK() and isfile(LOCAL_COPY) then
        body = string.format("loadstring(readfile(%q))()", LOCAL_COPY)
    else
        return false
    end
    local src = "(getgenv and getgenv() or _G).RynerHUB_Resume = true; if not game:IsLoaded() then game.Loaded:Wait() end; task.wait(2); " .. body
    local ok = pcall(q, src)
    if ok then AF_Config._queued = true end
    return ok
end

local function startAntiAFK()
    if AF_Config._afk then return end
    AF_Config._afk = task.spawn(function()
        while AF_Config.AutoAntiAFK do
            pcall(function()
                if getconnections then
                    for _, c in pairs(getconnections(LocalPlayer.Idled)) do
                        if c.Disable then c:Disable() end
                    end
                end
            end)
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            task.wait(60)
        end
        AF_Config._afk = nil
    end)
end

local function stopAntiAFK()
    AF_Config.AutoAntiAFK = false
    if AF_Config._afk then task.cancel(AF_Config._afk); AF_Config._afk = nil end
end

local function findSmallServer()
    local ok, result = pcall(function()
        return game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
    end)
    if not ok or not result then return nil end
    local decoded
    local ok2 = pcall(function() decoded = HttpService:JSONDecode(result) end)
    if not ok2 or not decoded or not decoded.data then return nil end
    local candidates = {}
    for _, srv in ipairs(decoded.data) do
        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers
        and srv.playing >= (AF_Config.MinPlayers or 0)
        and srv.playing <= (AF_Config.MaxPlayers or 999) then
            table.insert(candidates, srv)
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    return candidates[1]
end

local function serverHop()
    if tick() - AF_Config._lastHop < AF_Config.HopDelay then
        afNotify("Server Hop", "Cooldown, tunggu sebentar.", 2); return false
    end
    AF_Config._lastHop = tick()
    afNotify("Server Hop", "Mencari server sepi...", 3)
    local srv = findSmallServer()
    if not srv then afNotify("Server Hop", "Tidak ada server kosong.", 4); return false end
    sendWebhook("🔀 Server Hop", string.format("Pindah ke server dengan %d/%d pemain.", srv.playing, srv.maxPlayers), 0x8b5cf6, "server")
    afNotify("Server Hop", string.format("Ketemu server %d player. Pindah...", srv.playing), 3)
    saveConfig(true)
    if AF_Config.AutoReExecute and not queueReExecute() then
        afNotify("Auto Execute", "Isi Script URL (tab Auto Farm > Config) supaya script jalan lagi setelah hop.", 5)
    end
    task.wait(1)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer) end)
    return true
end

local function tryAutoQueue()
    if not AF_Config.AutoQueue then return end
    local isLobby = LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator"
    if not isLobby then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local found = false
    for _, gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local name = tostring(gui.Name):lower()
            local text = ""
            pcall(function() text = tostring(gui.Text):lower() end)
            if name:find("play") or name:find("queue") or name:find("ready") or text == "play" or text == "ready" or text:find("mulai") then
                pcall(function()
                    if firesignal then firesignal(gui.MouseButton1Click)
                    elseif gui.MouseButton1Click then gui.MouseButton1Click:Fire() end
                end)
                found = true
                break
            end
        end
    end
    if found then afNotify("Auto Queue", "Masuk match...", 2) end
end

local function tryTPFinish()
    if not AF_Config.AutoTPFinish then return end
    local isSurvivor = LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
    if not isSurvivor then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    -- cari finish line
    local target, minDist = nil, math.huge
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = tostring(obj.Name):lower()
            if n == "fininshline" or n == "finishline" or n:find("finish") or n:find("exit") then
                local d = (obj.Position - hrp.Position).Magnitude
                if d < minDist then minDist = d; target = obj end
            end
        end
    end
    if not target then return end

    -- TP semua survivor di server ini
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Team and pl.Team.Name == "Survivors" and pl.Character then
            local tHrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                pcall(function() tHrp.CFrame = target.CFrame + Vector3.new(math.random(-3,3), 3, math.random(-3,3)) end)
            end
        end
    end

    -- TP diri sendiri
    pcall(function() hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0) end)
    task.wait(0.3)

    -- Fire event escape
    local EscapeEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game") and ReplicatedStorage.Remotes.Game:FindFirstChild("PlayerActionEvent")
    if EscapeEvent then
        for i = 1, 3 do pcall(function() EscapeEvent:FireServer("ESCAPED", 200) end); task.wait(0.1) end
    end

    AF_Config._runs = AF_Config._runs + 1
    sendWebhook("🏁 Escape Berhasil", "Semua survivor berhasil TP + escape.", 0xfbbf24)
    afNotify("Auto TP", "Semua survivor di-TP ke finish", 2)

    -- Habis TP, auto hop ke server baru
    task.wait(5)
    if AF_Config.AutoHop then
        afNotify("Auto Hop", "Escape selesai, pindah server...", 3)
        serverHop()
    end
end

local function startAutoExecute()
    if AF_Config._exec then return end
    AF_Config._exec = task.spawn(function()
        while AF_Config.Enabled and AF_Config.AutoExecute do
            task.wait(5)
            if not AF_Config.Enabled then break end
            local isLobby = LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator"
            if isLobby then tryAutoQueue()
            elseif LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" then tryTPFinish() end
        end
        AF_Config._exec = nil
    end)
end

local function startAutoLevel()
    if AF_Config._lvl then return end
    AF_Config._lvl = task.spawn(function()
        while AF_Config.Enabled and (AF_Config.AutoLevelScrew or AF_Config.AutoLevelGear) do
            task.wait(10)
            if not AF_Config.Enabled then break end
            if AF_Config.AutoLevelScrew then
                pcall(function()
                    local v = LocalPlayer:GetAttribute("Screw")
                    if v then LocalPlayer:SetAttribute("Screw", v + 50) end
                    local ls = LocalPlayer:FindFirstChild("leaderstats")
                    if ls and ls:FindFirstChild("Screw") then ls.Screw.Value = ls.Screw.Value + 50 end
                end)
            end
            if AF_Config.AutoLevelGear then
                pcall(function()
                    local v = LocalPlayer:GetAttribute("Gear")
                    if v then LocalPlayer:SetAttribute("Gear", v + 50) end
                    local ls = LocalPlayer:FindFirstChild("leaderstats")
                    if ls and ls:FindFirstChild("Gear") then ls.Gear.Value = ls.Gear.Value + 50 end
                end)
            end
            pcall(function()
                local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if Remotes then
                    local ev = Remotes:FindFirstChild("UnlockEvent") or Remotes:FindFirstChild("LevelUp")
                    if ev and ev.FireServer then ev:FireServer("Screw", 50); ev:FireServer("Gear", 50) end
                end
            end)
        end
        AF_Config._lvl = nil
    end)
end

local function startMainLoop()
    if AF_Config._main then return end
    AF_Config._main = task.spawn(function()
        while AF_Config.Enabled do
            task.wait(3)
            if not AF_Config.Enabled then break end
            if AF_Config.AutoHop and LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator" then
                if #Players:GetPlayers() > AF_Config.MaxPlayers then serverHop(); break end
            end
        end
        AF_Config._main = nil
    end)
end

function AutoFarmVD:Start()
    if AF_Config.Enabled then return end
    AF_Config.Enabled = true
    saveConfig(true)
    if AF_Config.AutoAntiAFK then startAntiAFK() end
    if AF_Config.AutoExecute then startAutoExecute() end
    if AF_Config.AutoLevelScrew or AF_Config.AutoLevelGear then startAutoLevel() end
    startMainLoop()
    startLiveMonitor()
    startSecretMonitor()
    afNotify("Auto Farm", "Aktif", 2)
    sendWebhook("✅ Auto Farm ON", "Auto farm dimulai.", 0x22c55e)
end

function AutoFarmVD:Stop()
    AF_Config.Enabled = false
    saveConfig(true)
    if AF_Config._main then task.cancel(AF_Config._main); AF_Config._main = nil end
    if AF_Config._afk then task.cancel(AF_Config._afk); AF_Config._afk = nil end
    if AF_Config._exec then task.cancel(AF_Config._exec); AF_Config._exec = nil end
    if AF_Config._lvl then task.cancel(AF_Config._lvl); AF_Config._lvl = nil end
    if AF_Config._live then task.cancel(AF_Config._live); AF_Config._live = nil end
    if AF_Config._secret then AF_Config._secret:Disconnect(); AF_Config._secret = nil end
    afNotify("Auto Farm", "Nonaktif", 2)
    sendWebhook("🛑 Auto Farm OFF", "Auto farm dihentikan.", 0xef4444)
end

-- =========================================================
-- BUILD AUTO FARM TAB UI
-- =========================================================
local TAF = Tabs.AutoFarm

local UI = {}

local srv = TAF:AddSection("Server Management", true)
UI.AutoHop = srv:AddToggle({ Title = "Auto Server Hop", Content = "Pindah otomatis kalau server penuh", Default = AF_Config.AutoHop, Callback = function(v) cfg("AutoHop", v) end })
UI.MinPlayers = srv:AddInput({ Title = "Min Players", Default = tostring(AF_Config.MinPlayers), Placeholder = "3", Callback = function(t) local n = tonumber(t); if n then cfg("MinPlayers", n) end end })
UI.MaxPlayers = srv:AddInput({ Title = "Max Players", Default = tostring(AF_Config.MaxPlayers), Placeholder = "8", Callback = function(t) local n = tonumber(t); if n then cfg("MaxPlayers", n) end end })
UI.HopDelay = srv:AddInput({ Title = "Hop Cooldown (detik)", Default = tostring(AF_Config.HopDelay), Placeholder = "30", Callback = function(t) local n = tonumber(t); if n then cfg("HopDelay", n) end end })
srv:AddButton({ Title = "Manual Server Hop", Content = "Cari server sepi sekarang", Callback = function() serverHop() end })

local match = TAF:AddSection("Match Automation", true)
UI.AutoQueue = match:AddToggle({ Title = "Auto Queue", Content = "Otomatis masuk match di lobby", Default = AF_Config.AutoQueue, Callback = function(v) cfg("AutoQueue", v) end })
UI.AutoTPFinish = match:AddToggle({ Title = "Auto TP Finish", Content = "TP survivor ke finish line", Default = AF_Config.AutoTPFinish, Callback = function(v) cfg("AutoTPFinish", v) end })
match:AddButton({ Title = "Manual TP Finish", Callback = function() tryTPFinish() end })

local util = TAF:AddSection("Utility", true)
UI.AutoAntiAFK = util:AddToggle({ Title = "Anti AFK", Content = "Cegah kick karena idle", Default = AF_Config.AutoAntiAFK, Callback = function(v) cfg("AutoAntiAFK", v); if v then startAntiAFK() else stopAntiAFK() end end })
UI.AutoExecute = util:AddToggle({ Title = "Auto Execute", Content = "Loop queue, tunggu, TP, escape", Default = AF_Config.AutoExecute, Callback = function(v) cfg("AutoExecute", v); if v then startAutoExecute() end end })
UI.AutoLevelScrew = util:AddToggle({ Title = "Auto Level Screw", Default = AF_Config.AutoLevelScrew, Callback = function(v) cfg("AutoLevelScrew", v) end })
UI.AutoLevelGear = util:AddToggle({ Title = "Auto Level Gear", Default = AF_Config.AutoLevelGear, Callback = function(v) cfg("AutoLevelGear", v) end })

local wh = TAF:AddSection("Webhook", false)
UI.WebhookURL = wh:AddInput({ Title = "Webhook URL", Default = AF_Config.WebhookURL, Placeholder = "https://discord.com/api/webhooks/...", Callback = function(t) cfg("WebhookURL", t) end })
UI.WebhookEnable = wh:AddToggle({ Title = "Enable Webhook", Default = AF_Config.WebhookEnable, Callback = function(v) cfg("WebhookEnable", v) end })
wh:AddButton({ Title = "Test Webhook", Callback = function()
    sendWebhook("🔗 Tes Berhasil", "Snapshot akun dikirim saat tombol Test Webhook ditekan.", 0x22c55e)
    afNotify("Webhook", "Test dikirim.", 3)
end })

local cf = TAF:AddSection("Config", false)
UI.AutoLoadConfig = cf:AddToggle({ Title = "Auto Load Config", Content = "Muat config otomatis saat script jalan", Default = AF_Config.AutoLoadConfig, Callback = function(v) cfg("AutoLoadConfig", v) end })
UI.AutoReExecute = cf:AddToggle({ Title = "Auto Re-Execute", Content = "Jalankan script lagi otomatis setelah hop/pindah map", Default = AF_Config.AutoReExecute, Callback = function(v) cfg("AutoReExecute", v) end })
UI.ScriptURL = cf:AddInput({ Title = "Script URL", Content = "Link raw script untuk re-execute (opsional)", Default = AF_Config.ScriptURL, Placeholder = "https://.../script.lua", Callback = function(t) cfg("ScriptURL", t) end })
cf:AddButton({ Title = "Save Config", Content = "Simpan pengaturan sekarang", Callback = function() saveConfig(false) end })
cf:AddButton({ Title = "Load Config", Content = "Muat ulang pengaturan dari file", Callback = function()
    local data = readConfigFile()
    if not data then afNotify("Config", "Belum ada config tersimpan.", 3); return end
    applyConfigData(data)
    for _, k in ipairs(CONFIG_KEYS) do
        local h = UI[k]
        if h then
            if type(AF_Config[k]) == "boolean" then h:Set(AF_Config[k], false) else h:Set(tostring(AF_Config[k])) end
        end
    end
    if AF_Config.Enabled then
        if AF_Config.AutoAntiAFK then startAntiAFK() else stopAntiAFK() end
    end
    afNotify("Config", "Config dimuat.", 3)
end })
cf:AddButton({ Title = "Delete Config", Content = "Hapus file config tersimpan", Callback = function()
    local removed = false
    pcall(function() if delfile and isfile and isfile(CONFIG_FILE) then delfile(CONFIG_FILE); removed = true end end)
    afNotify("Config", removed and "Config dihapus." or "Tidak ada config untuk dihapus.", 3)
end })

local master = TAF:AddSection("Master Control", true)
master:AddButton({ Title = "▶️ START AUTO FARM", Callback = function() AutoFarmVD:Start() end })
master:AddButton({ Title = "🛑 STOP AUTO FARM", Callback = function() AutoFarmVD:Stop() end })

local info = Tabs.Info:AddSection("Tentang", true)
info:AddParagraph({ Title = "RynerHUB AutoFarm", Content = "Standalone build. Klik logo (kiri atas) untuk buka/tutup UI. Drag logo buat pindah posisi. Tekan RightCtrl juga bisa minimize." })

print("[RynerHUB] Auto Farm loaded.")

-- Auto-execute monitor: kirim notif pas masuk server baru
task.spawn(function()
    task.wait(3)
    if AF_Config.WebhookEnable and AF_Config.WebhookURL ~= "" then
        sendWebhook("🔄 Server Baru", "Auto-execute aktif kembali setelah masuk server/map baru.", 0x3b82f6, "server")
    end
end)

-- Antrekan script untuk teleport berikutnya
task.spawn(function()
    task.wait(2)
    queueReExecute()
end)

-- Lanjut auto farm otomatis kalau script jalan lagi setelah hop/pindah map
if AF_Config._resume then
    task.delay(4, function()
        if not AF_Config.Enabled then
            afNotify("Auto Resume", "Lanjut auto farm di server baru.", 3)
            AutoFarmVD:Start()
        end
    end)
end
