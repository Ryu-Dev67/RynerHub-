--[[

    SerhiiUI
    A modern UI library for Roblox script hubs.

    Inspired by the look & feel of WindUI, but built from scratch with its own
    identity (violet accent, native UICorner/UIStroke styling, no external assets).

    Usage:
        local SerhiiUI = loadstring(game:HttpGet("<raw url>/src/SerhiiUI.lua"))()

        local Window = SerhiiUI:CreateWindow({
            Title = "My Hub",
            SubTitle = "v1.0",
        })

        local Tab = Window:Tab({ Title = "Main", Icon = "" })

        Tab:Button({ Title = "Click me", Callback = function() print("hi") end })

    See examples/demo.lua for a full showcase, and CLAUDE.md for architecture.

]]

--//============================================================\\--
--||                       SERVICES                            ||--
--\\============================================================//--

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))

--//============================================================\\--
--||                       CONSTANTS                           ||--
--\\============================================================//--

local FONT_FAMILY = "rbxasset://fonts/families/GothamSSm.json"

-- The main font family is mutable via Library:SetFont. `fontObjects` tracks
-- every text object built with the main font so SetFont can re-apply it.
local fontFamily = FONT_FAMILY
local fontObjects = {}

local function font(weight)
	return Font.new(fontFamily, weight or Enum.FontWeight.Medium)
end

local VERSION = "0.1.1-beta"

--//============================================================\\--
--||                         THEMES                            ||--
--\\============================================================//--
-- A theme is a flat map of semantic keys -> Color3 / number.
-- Elements register a "ThemeTag" mapping a Roblox property to one of
-- these keys; SetTheme re-applies them across every registered object.

local function hex(h)
	return Color3.fromHex(h)
end

-- buildTheme fills in the full key set from a short colour spec, so a new
-- theme only needs to specify what makes it distinct.
local function buildTheme(name, c)
	return {
		Name = name,
		Background = c.Background,
		Sidebar = c.Sidebar or c.Background,
		Element = c.Element,
		ElementHover = c.ElementHover,
		Stroke = c.Stroke or hex("#ffffff"),
		StrokeTransparency = c.StrokeTransparency or 0.92,
		Text = c.Text,
		SubText = c.SubText,
		Accent = c.Accent,
		AccentText = c.AccentText or hex("#ffffff"),
		Toggle = c.Toggle or c.Accent,
		ToggleOff = c.ToggleOff or c.ElementHover,
		Slider = c.Slider or c.Accent,
		TabText = c.SubText,
		TabTextActive = c.Text,
		TabActive = c.TabActive or c.ElementHover,
		Notification = c.Notification or c.Element,
	}
end

local Themes = {
	Dark = buildTheme("Dark", {
		Background = hex("#0f0f10"), Sidebar = hex("#0b0b0c"),
		Element = hex("#1d1d20"), ElementHover = hex("#27272b"),
		Text = hex("#fafafa"), SubText = hex("#9a9aa3"),
		Accent = hex("#8b5cf6"), ToggleOff = hex("#3a3a40"),
		TabActive = hex("#1f1f23"), Notification = hex("#161618"),
	}),
	Light = buildTheme("Light", {
		Background = hex("#f4f4f5"), Sidebar = hex("#ececef"),
		Element = hex("#ffffff"), ElementHover = hex("#e9e9ec"),
		Stroke = hex("#000000"), StrokeTransparency = 0.9,
		Text = hex("#18181b"), SubText = hex("#71717a"),
		Accent = hex("#7c3aed"), ToggleOff = hex("#d4d4d8"),
		TabActive = hex("#e4e4e7"), Notification = hex("#ffffff"),
	}),
	Aqua = buildTheme("Aqua", {
		Background = hex("#0d1b1e"), Sidebar = hex("#0a1517"),
		Element = hex("#13282c"), ElementHover = hex("#193439"),
		Stroke = hex("#5eead4"), StrokeTransparency = 0.9,
		Text = hex("#ecfeff"), SubText = hex("#7dd3c8"),
		Accent = hex("#14b8a6"), AccentText = hex("#06302b"),
		ToggleOff = hex("#1f4a4a"), Slider = hex("#2dd4bf"),
		TabActive = hex("#163236"), Notification = hex("#102328"),
	}),
	Rose = buildTheme("Rose", {
		Background = hex("#1f0a12"), Sidebar = hex("#180810"),
		Element = hex("#2c1019"), ElementHover = hex("#3a1622"),
		Stroke = hex("#fda4af"), StrokeTransparency = 0.9,
		Text = hex("#fff1f2"), SubText = hex("#e8849b"),
		Accent = hex("#f43f5e"), ToggleOff = hex("#4a1d28"),
		TabActive = hex("#36141f"), Notification = hex("#260c15"),
	}),
	Emerald = buildTheme("Emerald", {
		Background = hex("#06140f"), Sidebar = hex("#040f0b"),
		Element = hex("#0c241a"), ElementHover = hex("#103024"),
		Stroke = hex("#6ee7b7"), StrokeTransparency = 0.9,
		Text = hex("#ecfdf5"), SubText = hex("#6ee7a8"),
		Accent = hex("#10b981"), AccentText = hex("#03241a"),
		ToggleOff = hex("#163a2c"), TabActive = hex("#102c20"),
		Notification = hex("#081b14"),
	}),
	Indigo = buildTheme("Indigo", {
		Background = hex("#0f0f1f"), Sidebar = hex("#0b0b18"),
		Element = hex("#1a1a33"), ElementHover = hex("#222244"),
		Stroke = hex("#a5b4fc"), StrokeTransparency = 0.9,
		Text = hex("#eef2ff"), SubText = hex("#9aa3e0"),
		Accent = hex("#6366f1"), ToggleOff = hex("#2a2a52"),
		TabActive = hex("#1f1f3d"), Notification = hex("#141428"),
	}),
	Amber = buildTheme("Amber", {
		Background = hex("#1c1404"), Sidebar = hex("#150f03"),
		Element = hex("#2a2009"), ElementHover = hex("#382b0d"),
		Stroke = hex("#fcd34d"), StrokeTransparency = 0.9,
		Text = hex("#fffbeb"), SubText = hex("#d6b465"),
		Accent = hex("#f59e0b"), AccentText = hex("#2a1d03"),
		ToggleOff = hex("#473714"), TabActive = hex("#33270c"),
		Notification = hex("#241a06"),
	}),
	Crimson = buildTheme("Crimson", {
		Background = hex("#160606"), Sidebar = hex("#100404"),
		Element = hex("#241010"), ElementHover = hex("#321616"),
		Stroke = hex("#fca5a5"), StrokeTransparency = 0.9,
		Text = hex("#fef2f2"), SubText = hex("#cf8a8a"),
		Accent = hex("#dc2626"), ToggleOff = hex("#421b1b"),
		TabActive = hex("#2e1414"), Notification = hex("#1e0a0a"),
	}),
	Midnight = buildTheme("Midnight", {
		Background = hex("#0a0f1e"), Sidebar = hex("#070b16"),
		Element = hex("#121a30"), ElementHover = hex("#1a2440"),
		Stroke = hex("#93c5fd"), StrokeTransparency = 0.9,
		Text = hex("#dbeafe"), SubText = hex("#7f9ad1"),
		Accent = hex("#2563eb"), ToggleOff = hex("#243150"),
		TabActive = hex("#16213d"), Notification = hex("#0d1426"),
	}),
	Mocha = buildTheme("Mocha", {
		Background = hex("#1a1410"), Sidebar = hex("#130e0b"),
		Element = hex("#271e18"), ElementHover = hex("#332820"),
		Stroke = hex("#d6bfa8"), StrokeTransparency = 0.9,
		Text = hex("#f5ece2"), SubText = hex("#b59c83"),
		Accent = hex("#c08457"), AccentText = hex("#241813"),
		ToggleOff = hex("#42342a"), TabActive = hex("#2e241c"),
		Notification = hex("#221a14"),
	}),
	Neon = buildTheme("Neon", {
		Background = hex("#0a0a12"), Sidebar = hex("#070710"),
		Element = hex("#13131f"), ElementHover = hex("#1c1c2e"),
		Stroke = hex("#22d3ee"), StrokeTransparency = 0.85,
		Text = hex("#f0f9ff"), SubText = hex("#8b8bb0"),
		Accent = hex("#e635c8"), ToggleOff = hex("#262640"),
		Slider = hex("#22d3ee"), TabActive = hex("#19192b"),
		Notification = hex("#101019"),
	}),
	["Cotton Candy"] = buildTheme("Cotton Candy", {
		Background = hex("#1a0b2e"), Sidebar = hex("#150823"),
		Element = hex("#312643"), ElementHover = hex("#3c2f52"),
		Stroke = hex("#f9a8d4"), StrokeTransparency = 0.88,
		Text = hex("#fdf2f8"), SubText = hex("#b79ad8"),
		Accent = hex("#ec4899"), ToggleOff = hex("#3f2d57"),
		Slider = hex("#d946ef"), TabActive = hex("#2a1d40"),
		Notification = hex("#22102f"),
	}),
	Slate = buildTheme("Slate", {
		Background = hex("#0f172a"), Sidebar = hex("#0b1120"),
		Element = hex("#1e293b"), ElementHover = hex("#293548"),
		Stroke = hex("#cbd5e1"), StrokeTransparency = 0.9,
		Text = hex("#f1f5f9"), SubText = hex("#94a3b8"),
		Accent = hex("#38bdf8"), AccentText = hex("#04293b"),
		ToggleOff = hex("#33415c"), TabActive = hex("#1c2a36"),
		Notification = hex("#131c30"),
	}),
	Sunset = buildTheme("Sunset", {
		Background = hex("#1c0f0a"), Sidebar = hex("#160b07"),
		Element = hex("#2c1813"), ElementHover = hex("#3a2019"),
		Stroke = hex("#fdba74"), StrokeTransparency = 0.88,
		Text = hex("#fff7ed"), SubText = hex("#e0a06f"),
		Accent = hex("#f97316"), AccentText = hex("#2a1304"),
		ToggleOff = hex("#47281d"), Slider = hex("#fb923c"),
		TabActive = hex("#341c15"), Notification = hex("#26120c"),
	}),
	Forest = buildTheme("Forest", {
		Background = hex("#0c1410"), Sidebar = hex("#080f0b"),
		Element = hex("#16241c"), ElementHover = hex("#1e3026"),
		Stroke = hex("#86efac"), StrokeTransparency = 0.9,
		Text = hex("#f0fdf4"), SubText = hex("#86b89a"),
		Accent = hex("#22c55e"), AccentText = hex("#04220f"),
		ToggleOff = hex("#243a2d"), TabActive = hex("#1a2c21"),
		Notification = hex("#0f1c15"),
	}),
	Plum = buildTheme("Plum", {
		Background = hex("#160c1e"), Sidebar = hex("#100817"),
		Element = hex("#241430"), ElementHover = hex("#301a40"),
		Stroke = hex("#d8b4fe"), StrokeTransparency = 0.9,
		Text = hex("#faf5ff"), SubText = hex("#b794d4"),
		Accent = hex("#a855f7"), ToggleOff = hex("#3a2150"),
		TabActive = hex("#2c1840"), Notification = hex("#1c0f28"),
	}),
	Steel = buildTheme("Steel", {
		Background = hex("#16181c"), Sidebar = hex("#101216"),
		Element = hex("#22262c"), ElementHover = hex("#2d323a"),
		Stroke = hex("#94a3b8"), StrokeTransparency = 0.9,
		Text = hex("#f1f5f9"), SubText = hex("#8b95a3"),
		Accent = hex("#64748b"), ToggleOff = hex("#363c46"),
		TabActive = hex("#282d34"), Notification = hex("#1a1d22"),
	}),
	Coral = buildTheme("Coral", {
		Background = hex("#1d0d0f"), Sidebar = hex("#16090b"),
		Element = hex("#2c1518"), ElementHover = hex("#3a1d21"),
		Stroke = hex("#fca5a5"), StrokeTransparency = 0.88,
		Text = hex("#fff1f2"), SubText = hex("#dd9090"),
		Accent = hex("#fb7185"), AccentText = hex("#2a0c0f"),
		ToggleOff = hex("#47242a"), Slider = hex("#f87171"),
		TabActive = hex("#34191d"), Notification = hex("#260f12"),
	}),
	Lime = buildTheme("Lime", {
		Background = hex("#11160a"), Sidebar = hex("#0c1007"),
		Element = hex("#1c2511"), ElementHover = hex("#263117"),
		Stroke = hex("#bef264"), StrokeTransparency = 0.88,
		Text = hex("#f7fee7"), SubText = hex("#a3bd6f"),
		Accent = hex("#84cc16"), AccentText = hex("#1c2a04"),
		ToggleOff = hex("#2f3b1c"), Slider = hex("#a3e635"),
		TabActive = hex("#232e15"), Notification = hex("#161c0d"),
	}),
	Obsidian = buildTheme("Obsidian", {
		Background = hex("#000000"), Sidebar = hex("#050505"),
		Element = hex("#101012"), ElementHover = hex("#18181c"),
		Stroke = hex("#ffffff"), StrokeTransparency = 0.9,
		Text = hex("#fafafa"), SubText = hex("#8a8a8a"),
		Accent = hex("#f5f5f5"), AccentText = hex("#000000"),
		ToggleOff = hex("#26262a"), Slider = hex("#d4d4d4"),
		TabActive = hex("#141416"), Notification = hex("#0a0a0a"),
	}),
	Sky = buildTheme("Sky", {
		Background = hex("#081521"), Sidebar = hex("#06101a"),
		Element = hex("#0f2436"), ElementHover = hex("#163044"),
		Stroke = hex("#7dd3fc"), StrokeTransparency = 0.9,
		Text = hex("#f0f9ff"), SubText = hex("#7fb3d6"),
		Accent = hex("#0ea5e9"), AccentText = hex("#04293b"),
		ToggleOff = hex("#1c3950"), TabActive = hex("#132b3e"),
		Notification = hex("#0b1b29"),
	}),
}

--//============================================================\\--
--||                       LIBRARY ROOT                        ||--
--\\============================================================//--

local Library = {
	Version = VERSION,
	Theme = Themes.Dark,
	ThemeName = "Dark",
	Themes = Themes,
	Flags = {}, -- Flag -> element, for config / value lookups
	Connections = {}, -- tracked signal connections for :Destroy cleanup
	ThemeObjects = {}, -- { Object, Props } entries for theme re-application
	Windows = {},
}

--//============================================================\\--
--||                    INSTANCE CREATION                      ||--
--\\============================================================//--

local DefaultProps = {
	Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	ScrollingFrame = { BorderSizePixel = 0, ScrollBarImageTransparency = 1, Active = true },
	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = font(),
		Text = "",
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		FontFace = font(),
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		FontFace = font(),
		Text = "",
		ClearTextOnFocus = false,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	},
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	ImageButton = { BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false },
}

-- Register a theme tag so the object's properties track theme changes.
local function tag(object, props)
	table.insert(Library.ThemeObjects, { Object = object, Props = props })
	for prop, key in pairs(props) do
		local value = Library.Theme[key]
		if value ~= nil then
			object[prop] = value
		end
	end
end

-- New(className, properties, children) - the workhorse builder.
-- `ThemeTag` is a special property: { RobloxProperty = "ThemeKey", ... }
local function New(className, props, children)
	local object = Instance.new(className)

	local defaults = DefaultProps[className]
	if defaults then
		for k, v in pairs(defaults) do
			object[k] = v
		end
	end

	local themeTag
	if props then
		themeTag = props.ThemeTag
		for k, v in pairs(props) do
			if k ~= "ThemeTag" then
				object[k] = v
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = object
		end
	end

	if themeTag then
		tag(object, themeTag)
	end

	-- Track text objects using the main font so SetFont can re-apply it.
	-- Objects with a deliberately different family (e.g. the monospace Code
	-- block) keep their own font and are skipped.
	if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
		local ok, fam = pcall(function()
			return object.FontFace.Family
		end)
		if ok and fam == fontFamily then
			table.insert(fontObjects, object)
		end
	end

	return object
end

--//============================================================\\--
--||                        UTILITIES                          ||--
--\\============================================================//--

local function tween(object, time, props, style, direction)
	local info = TweenInfo.new(
		time or 0.18,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local t = TweenService:Create(object, info, props)
	t:Play()
	return t
end

local function connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Library.Connections, conn)
	return conn
end

local function safeCallback(fn, ...)
	if typeof(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[SerhiiUI] callback error: " .. tostring(err))
	end
end

local function corner(radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function padding(all, extra)
	local p = New("UIPadding", {
		PaddingTop = UDim.new(0, all),
		PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all),
		PaddingRight = UDim.new(0, all),
	})
	if extra then
		for k, v in pairs(extra) do
			p[k] = v
		end
	end
	return p
end

local function listLayout(gap, dir, props)
	local l = New("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical,
	})
	if props then
		for k, v in pairs(props) do
			l[k] = v
		end
	end
	return l
end

-- Make a frame draggable by a handle.
local function dragify(frame, handle)
	handle = handle or frame
	local dragging, startPos, startInput

	connect(handle.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
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

	connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local delta = input.Position - startInput
			tween(frame, 0.06, {
				Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				),
			})
		end
	end)
end

local function round(value, step)
	if step and step > 0 then
		return math.floor(value / step + 0.5) * step
	end
	return value
end

--//============================================================\\--
--||                      LUCIDE ICONS                         ||--
--\\============================================================//--
-- Icons are referenced by name (e.g. "house", "settings", "bird") and
-- resolved from a remote Lucide spritesheet pack at runtime, then cached.
--
-- Avoiding blurry icons:
--   * The window root is a plain Frame, NOT a CanvasGroup. CanvasGroups
--     flatten children to a texture and soften every icon/text inside them.
--   * Icon images use ScaleType = Fit so the square glyph keeps its aspect.
--   * Icons are only ever downscaled (sheet glyph -> small label), never
--     upscaled past their source rect, which keeps the lines clean.

local HttpService = cloneref(game:GetService("HttpService"))

local Icons = {
	URL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua",
	Pack = nil,
	Loaded = false,
	Cache = {},
}
Library.Icons = Icons

local httpGet = function(url)
	if game.HttpGet then
		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)
		if ok then
			return body
		end
	end
	local request = (syn and syn.request) or (http and http.request) or http_request or request
	if request then
		local ok, res = pcall(request, { Url = url, Method = "GET" })
		if ok and res and res.Body then
			return res.Body
		end
	end
	return nil
end

local function ensureIcons()
	if Icons.Loaded then
		return
	end
	Icons.Loaded = true
	local ok, pack = pcall(function()
		local body = httpGet(Icons.URL)
		if not body then
			return nil
		end
		return loadstring(body)()
	end)
	if ok and pack then
		Icons.Pack = pack
		pcall(function()
			if pack.SetIconsType then
				pack.SetIconsType("lucide")
			end
		end)
	else
		print("[SerhiiUI] failed to load the Lucide icon pack; icons will be skipped")
	end
end

-- Resolve an icon name to { Image, RectOffset, RectSize } (or nil).
function Library:GetIcon(name)
	if not name or name == "" then
		return nil
	end
	-- Direct asset ids pass straight through.
	if typeof(name) == "string" and name:match("^rbxassetid://") then
		return { Image = name, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
	end
	if Icons.Cache[name] ~= nil then
		return Icons.Cache[name] or nil
	end

	ensureIcons()
	local data
	if Icons.Pack then
		pcall(function()
			local result = Icons.Pack.Icon2 and Icons.Pack.Icon2(name)
				or (Icons.Pack.GetIcon and Icons.Pack.GetIcon(name))
			if typeof(result) == "string" then
				data = { Image = result, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
			elseif typeof(result) == "table" and result[1] then
				local rect = result[2] or {}
				data = {
					Image = result[1],
					RectOffset = rect.ImageRectP