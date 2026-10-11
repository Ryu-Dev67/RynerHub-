local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")  -- tambahkan ini
local Camera = Workspace.CurrentCamera
local Saved = {}
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- =================================
-- UI: SERHIIUI (TEMA PLUM) + KEY SYSTEM
-- Dibuat paling awal supaya fitur di bawah baru jalan setelah key valid.
-- =================================
local Window, Tabs
do
local HttpService = game:GetService("HttpService")

-- Key system dipindah ke loader. Script ini hanya dikirim server setelah key valid + HWID cocok.
local KeyCfg = nil -- nil -> kartu Key System di SerhiiUI dilewati


-- ===================== SERHIIUI (library, sudah dipatch) =====================
local SerhiiUI = (function()
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
		BackgroundTransparency = 1,
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
		return tonumber(string.format("%.10g", math.floor(value / step + 0.5) * step))
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
					RectOffset = rect.ImageRectPosition or Vector2.new(0, 0),
					RectSize = rect.ImageRectSize or Vector2.new(0, 0),
				}
			end
		end)
	end

	Icons.Cache[name] = data or false
	return data
end

-- Register custom icons by name. Use this in a real game (where the remote
-- Lucide pack can't load, since game clients have no HttpGet/loadstring) to map
-- names to your own image assets:
--   SerhiiUI:AddIcons({ shield = "rbxassetid://123", boot = 456 })
-- A value may be a "rbxassetid://" string, an asset id number, or a spritesheet
-- table { Image, RectOffset, RectSize }. Registered names win over the pack and
-- never hit the network.
function Library:AddIcons(map)
	if typeof(map) ~= "table" then
		return
	end
	for name, value in pairs(map) do
		if typeof(value) == "number" then
			Icons.Cache[name] = {
				Image = "rbxassetid://" .. value,
				RectOffset = Vector2.new(0, 0),
				RectSize = Vector2.new(0, 0),
			}
		elseif typeof(value) == "string" then
			Icons.Cache[name] = {
				Image = value,
				RectOffset = Vector2.new(0, 0),
				RectSize = Vector2.new(0, 0),
			}
		elseif typeof(value) == "table" and value.Image then
			Icons.Cache[name] = {
				Image = value.Image,
				RectOffset = value.RectOffset or value.ImageRectOffset or Vector2.new(0, 0),
				RectSize = value.RectSize or value.ImageRectSize or Vector2.new(0, 0),
			}
		end
	end
end

-- Build an ImageLabel for an icon name. `sizeUDim` defaults to 18x18.
local function makeIcon(name, sizeUDim, themeKey, color)
	local img = New("ImageLabel", {
		Size = sizeUDim or UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		ResampleMode = Enum.ResamplerMode.Default,
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
	if color then
		img.ImageColor3 = color
	end
	return img
end

-- Swap an existing icon ImageLabel to a different Lucide icon (used to flip
-- the maximize/minimize control when toggling fullscreen).
local function setIconImage(img, name)
	local data = Library:GetIcon(name)
	if not data then
		return
	end
	img.Image = data.Image
	if data.RectSize and (data.RectSize.X > 0 or data.RectSize.Y > 0) then
		img.ImageRectOffset = data.RectOffset
		img.ImageRectSize = data.RectSize
	else
		img.ImageRectOffset = Vector2.new(0, 0)
		img.ImageRectSize = Vector2.new(0, 0)
	end
end

--//============================================================\\--
--||                     THEME SWITCHING                       ||--
--\\============================================================//--

-- Elements that paint themselves with direct (non-ThemeTag) colours — e.g. the
-- selected dropdown option (Accent) or a toggle track — register a listener so
-- they can re-apply their dynamic colours when the theme changes. Without this,
-- those surfaces lag a theme behind ("half the window is the old theme").
local themeListeners = {}
local function onThemeChange(fn)
	table.insert(themeListeners, fn)
	return fn
end

function Library:SetTheme(name)
	local theme = Themes[name] or (typeof(name) == "table" and name)
	if not theme then
		warn("[SerhiiUI] unknown theme: " .. tostring(name))
		return
	end

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
						pcall(function()
							object[prop] = value
						end)
					end
				end
			end
		end
	end

	for i = #themeListeners, 1, -1 do
		local ok = pcall(themeListeners[i], theme)
		if not ok then
			-- drop dead listeners (their element was destroyed)
			table.remove(themeListeners, i)
		end
	end

	return theme
end

-- AddTheme registers a fully-specified theme table (must contain every key).
function Library:AddTheme(theme)
	Themes[theme.Name] = theme
	return theme
end

-- CreateTheme builds a complete theme from a short colour spec (see buildTheme).
-- e.g. SerhiiUI:CreateTheme("Sunset", { Background=..., Element=..., Accent=... })
function Library:CreateTheme(name, colours)
	local theme = buildTheme(name, colours)
	Themes[name] = theme
	return theme
end

function Library:RemoveTheme(name)
	if name == "Dark" then
		warn("[SerhiiUI] the Dark theme cannot be removed")
		return false
	end
	if not Themes[name] then
		return false
	end
	Themes[name] = nil
	if Library.ThemeName == name then
		Library:SetTheme("Dark")
	end
	return true
end

-- Returns a sorted list of theme names (Dark and Light first).
function Library:GetThemes()
	local names = {}
	for themeName in pairs(Themes) do
		table.insert(names, themeName)
	end
	table.sort(names, function(a, b)
		local rank = { Dark = 1, Light = 2 }
		local ra, rb = rank[a] or 3, rank[b] or 3
		if ra ~= rb then
			return ra < rb
		end
		return a < b
	end)
	return names
end

function Library:GetTheme()
	return Library.ThemeName
end

-- Swap the main font family at runtime (a "rbxasset://fonts/families/*.json"
-- string, or any valid Font family). Re-applies it to every tracked text
-- object while preserving each one's weight/style. Monospace Code blocks keep
-- their own font (they were never tracked).
function Library:SetFont(fontId)
	if typeof(fontId) ~= "string" or fontId == "" then
		return
	end
	fontFamily = fontId
	for i = #fontObjects, 1, -1 do
		local obj = fontObjects[i]
		if obj and obj.Parent ~= nil then
			pcall(function()
				local face = obj.FontFace
				obj.FontFace = Font.new(fontId, face.Weight, face.Style)
			end)
		else
			table.remove(fontObjects, i)
		end
	end
end

--//============================================================\\--
--||                       SCREEN GUI                          ||--
--\\============================================================//--

local function getParentGui()
	-- Executor: gethui() gives a protected, persistent parent.
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then
		return hui
	end

	local LocalPlayer = Players.LocalPlayer

	-- Studio (and normal in-game LocalScripts) cannot write to CoreGui, so
	-- parent to PlayerGui. This is the path that makes the module work when
	-- required as a ModuleScript from a LocalScript in Studio.
	if RunService:IsStudio() and LocalPlayer then
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Executor without gethui (or Studio command bar): use CoreGui only if we
	-- can actually parent into it; otherwise fall back to PlayerGui.
	local canCore = pcall(function()
		local probe = Instance.new("Folder")
		probe.Parent = CoreGui
		probe:Destroy()
	end)
	if canCore then
		return CoreGui
	end

	return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
end

local function protect(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif protectgui then
			protectgui(gui)
		end
	end)
end

local ScreenGui = New("ScreenGui", {
	Name = "SerhiiUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	DisplayOrder = 999999,
	Parent = getParentGui(),
})
protect(ScreenGui)
Library.ScreenGui = ScreenGui

-- Separate layer for notifications so they always render above windows.
-- Default: bottom-right (matches the WindUI look). SetNotificationLower
-- toggles between the lower (bottom) and upper (top) stack.
local notificationLayout = listLayout(8, Enum.FillDirection.Vertical, {
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
})
local NotificationLayer = New("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -28, 1, -28),
	Position = UDim2.new(0, 14, 0, 14),
	Parent = ScreenGui,
}, {
	notificationLayout,
})

-- true (default) = notifications stack at the bottom; false = at the top.
function Library:SetNotificationLower(lower)
	notificationLayout.VerticalAlignment = (lower ~= false) and Enum.VerticalAlignment.Bottom
		or Enum.VerticalAlignment.Top
end

--//============================================================\\--
--||                      NOTIFICATIONS                        ||--
--\\============================================================//--

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 4
	local hasIcon = config.Icon ~= nil and config.Icon ~= ""

	-- The holder is the layout slot; AutomaticSize Y is driven by the text
	-- column (offset-sized). Nothing here uses a scale-based Y size — a
	-- scale-Y child inside an AutomaticSize parent feeds back and makes the
	-- card grow to fill the whole screen.
	local holder = New("Frame", {
		Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = NotificationLayer,
	})

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(1, 24, 0, 0),
		BackgroundTransparency = 0,
		ThemeTag = { BackgroundColor3 = "Notification" },
		Parent = holder,
	}, {
		corner(12),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	local textLeft = 15
	if hasIcon then
		local isAssetIcon = typeof(config.Icon) == "string" and config.Icon:match("^rbxassetid://") ~= nil
		local icon = makeIcon(config.Icon, UDim2.new(0, 20, 0, 20), (not isAssetIcon) and "Accent" or nil, isAssetIcon and Color3.new(1, 1, 1) or nil)
		icon.AnchorPoint = Vector2.new(0, 0)
		icon.Position = UDim2.new(0, 14, 0, 14)
		icon.Parent = card
		textLeft = 14 + 20 + 10
	end

	New("Frame", {
		Size = UDim2.new(1, -(textLeft + 14), 0, 0),
		Position = UDim2.new(0, textLeft, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		listLayout(3),
		padding(0, { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
		New("TextLabel", {
			Text = title,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "Text" },
		}),
		content ~= "" and New("TextLabel", {
			Text = content,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "SubText" },
		}) or nil,
	})

	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)

	task.delay(duration, function()
		tween(card, 0.3, { Position = UDim2.new(1, 24, 0, 0) }, Enum.EasingStyle.Quint)
		task.wait(0.32)
		holder:Destroy()
	end)
end

--//============================================================\\--
--||                    ELEMENT FACTORY                        ||--
--\\============================================================//--
-- Shared card used by Button/Toggle/Slider/Dropdown/Input/Paragraph.

local function makeElement(parent, opts)
	opts = opts or {}
	local hasDesc = opts.Desc ~= nil and opts.Desc ~= ""
	local controlWidth = opts.ControlWidth or 44
	local minHeight = opts.Height or 40

	-- The card never gets top/bottom UIPadding (that would squash the
	-- full-height control). Instead the text column carries its own
	-- vertical padding, which is what drives the card's automatic height.
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, minHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		ThemeTag = { BackgroundColor3 = "Element" },
		Parent = parent,
		LayoutOrder = opts.LayoutOrder or 1,
	}, {
		corner(10),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		New("UISizeConstraint", { MinSize = Vector2.new(0, minHeight) }),
	})

	-- Optional left icon (by Lucide name). Shifts the text column right.
	-- IMPORTANT: the icon is positioned with a fixed OFFSET (top-aligned with
	-- the title row), never a scale-Y position. A scale-Y child of an
	-- AutomaticSize=Y card breaks the card's height (it grows unbounded) and
	-- re-centres itself when the card resizes (e.g. a dropdown opening).
	local iconInset = 14
	local iconImage
	if opts.Icon and opts.Icon ~= "" then
		iconImage = makeIcon(opts.Icon, UDim2.new(0, 18, 0, 18), "Text")
		iconImage.AnchorPoint = Vector2.new(0, 0)
		iconImage.Position = UDim2.new(0, 14, 0, 11)
		iconImage.Parent = card
		iconInset = 14 + 18 + 10
	end

	-- Left text column (drives card height via its own vertical padding)
	local textCol = New("Frame", {
		Size = UDim2.new(1, -(controlWidth + iconInset + 12), 0, 0),
		Position = UDim2.new(0, iconInset, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		listLayout(2),
		padding(0, { PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11) }),
	})

	local titleLabel = New("TextLabel", {
		Text = opts.Title or "",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		ThemeTag = { TextColor3 = "Text" },
		Parent = textCol,
	})

	local descLabel
	if hasDesc then
		descLabel = New("TextLabel", {
			Text = opts.Desc,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			ThemeTag = { TextColor3 = "SubText" },
			Parent = textCol,
		})
	end

	-- Right control slot. Scale height (1,0) makes it fill the final card
	-- height and centre its widget; AutomaticSize ignores scale-sized
	-- children, so it never feeds back into the card's height.
	local control = New("Frame", {
		Size = UDim2.new(0, controlWidth, 1, 0),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = card,
	})

	local element = {
		Card = card,
		Control = control,
		TitleLabel = titleLabel,
		DescLabel = descLabel,
		Icon = iconImage,
	}

	if opts.Hover ~= false then
		connect(card.MouseEnter, function()
			tween(card, 0.15, { BackgroundColor3 = Library.Theme.ElementHover })
		end)
		connect(card.MouseLeave, function()
			tween(card, 0.15, { BackgroundColor3 = Library.Theme.Element })
		end)
	end

	function element:SetTitle(text)
		titleLabel.Text = text
	end
	function element:SetDesc(text)
		if descLabel then
			descLabel.Text = text
		end
	end

	return element
end

--//============================================================\\--
--||                  ELEMENT CONSTRUCTORS                     ||--
--\\============================================================//--
-- Each is attached to a "page" (a tab's content ScrollingFrame).
-- They return an element table with :Set / :Get / control methods.

local Elements = {}

-- Bind every element constructor onto `target` so it appends to `parentFrame`
-- (e.g. target:Button({...}) builds into parentFrame). Used by Tab, the
-- window's default page, and collapsible Sections — so sections can hold any
-- element, including nested sections.
local function bindElements(target, parentFrame)
	for name, constructor in pairs(Elements) do
		target[name] = function(_, elementConfig)
			return constructor(parentFrame, elementConfig)
		end
	end
	return target
end

-- Section is a collapsible GROUP, not a title. It has a bold header with a
-- chevron; clicking it expands/collapses its body, which holds elements.
-- (For a plain heading, use Tab:Text({ Title = "..." }) instead.)
function Elements.Section(page, config)
	config = config or {}
	local opened = config.Opened ~= false

	local container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = page,
	}, {
		listLayout(6),
	})

	local header = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = container,
		LayoutOrder = 0,
	})
	local titleLabel = New("TextLabel", {
		Text = config.Title or "Section",
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 2, 0, 0),
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "Text" },
		Parent = header,
	})
	local chev = makeIcon("chevron-down", UDim2.new(0, 18, 0, 18), "SubText")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -2, 0.5, 0)
	chev.Parent = header

	-- Body holds the section's elements. Hidden bodies don't count toward the
	-- container's automatic height, so collapsing pulls following elements up.
	local body = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = opened,
		Parent = container,
		LayoutOrder = 1,
	}, {
		listLayout(6),
	})

	local function setOpen(state)
		opened = state
		body.Visible = state
		tween(chev, 0.18, { Rotation = state and 180 or 0 })
	end
	chev.Rotation = opened and 180 or 0

	connect(header.MouseButton1Click, function()
		setOpen(not opened)
	end)

	local section = {
		Object = container,
		Body = body,
		SetTitle = function(_, t) titleLabel.Text = t end,
		SetOpen = function(_, o) setOpen(o and true or false) end,
		Toggle = function() setOpen(not opened) end,
	}
	bindElements(section, body)
	return section
end

function Elements.Divider(page)
	local line = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "Stroke" },
		Parent = page,
	})
	return { Object = line }
end

function Elements.Paragraph(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title,
		Desc = config.Desc,
		Icon = config.Icon,
		Hover = false,
		ControlWidth = 0,
	})
	return {
		Object = el.Card,
		SetTitle = function(_, t) el:SetTitle(t) end,
		SetDesc = function(_, d) el:SetDesc(d) end,
	}
end

function Elements.Button(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title or "Button",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 18,
	})

	-- chevron (Lucide icon, not a text glyph — glyphs render as tofu boxes)
	local chev = makeIcon("chevron-right", UDim2.new(0, 16, 0, 16), "SubText")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, 0, 0.5, 0)
	chev.Parent = el.Control

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = el.Card,
		ZIndex = 5,
	})

	connect(hit.MouseButton1Click, function()
		tween(el.Card, 0.08, { BackgroundColor3 = Library.Theme.ElementHover }, Enum.EasingStyle.Quad)
		task.delay(0.08, function()
			tween(el.Card, 0.2, { BackgroundColor3 = Library.Theme.Element })
		end)
		task.spawn(safeCallback, config.Callback)
	end)

	return {
		Object = el.Card,
		SetTitle = function(_, t) el:SetTitle(t) end,
		SetCallback = function(_, fn) config.Callback = fn end,
	}
end

function Elements.Toggle(page, config)
	config = config or {}
	local value = config.Default or config.Value or false

	local el = makeElement(page, {
		Title = config.Title or "Toggle",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 44,
	})

	local track = New("Frame", {
		Size = UDim2.new(0, 42, 0, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff,
		Parent = el.Control,
	}, {
		corner(11),
	})

	local knob = New("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = track,
	}, {
		corner(9),
	})

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = el.Card,
		ZIndex = 5,
	})

	local object

	local function visualUpdate(animate)
		local t = animate and 0.16 or 0
		tween(track, t, { BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff })
		tween(knob, t, {
			Position = value and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
		}, Enum.EasingStyle.Quint)
	end

	local function set(v, fireCallback, animate)
		value = v and true or false
		visualUpdate(animate ~= false)
		if fireCallback ~= false then
			task.spawn(safeCallback, config.Callback, value)
		end
	end

	connect(hit.MouseButton1Click, function()
		set(not value, true, true)
	end)

	-- track colour is set directly (not via ThemeTag), so refresh it on theme change
	onThemeChange(function()
		if el.Card.Parent == nil then
			error("dead")
		end
		track.BackgroundColor3 = value and Library.Theme.Toggle or Library.Theme.ToggleOff
	end)

	object = {
		Object = el.Card,
		Set = function(_, v, fire) set(v, fire ~= false, true) end,
		Get = function() return value end,
		Value = value,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Slider(page, config)
	config = config or {}
	local valueCfg = config.Value or {}
	local min = valueCfg.Min or 0
	local max = valueCfg.Max or 1
	local default = valueCfg.Default or min
	local step = config.Step or 1
	local current = math.clamp(default, min, max)

	local sliderHeight = config.Desc and 64 or 54
	local el = makeElement(page, {
		Title = config.Title or "Slider",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 56,
		Height = sliderHeight,
	})
	-- Slider has a fixed height (title row + track row), so disable autosize.
	el.Card.AutomaticSize = Enum.AutomaticSize.None
	el.Card.Size = UDim2.new(1, 0, 0, sliderHeight)

	-- value readout, top-right, aligned with the title row
	local valueLabel = New("TextLabel", {
		Text = tostring(current),
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = 13,
		Size = UDim2.new(0, 56, 0, 16),
		Position = UDim2.new(1, -12, 0, 11),
		AnchorPoint = Vector2.new(1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ThemeTag = { TextColor3 = "Accent" },
		Parent = el.Card,
	})

	-- the track lives full-width along the bottom of the card
	local trackHolder = New("Frame", {
		Size = UDim2.new(1, -26, 0, 14),
		Position = UDim2.new(0, 14, 1, -12),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Parent = el.Card,
	})

	local track = New("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = { BackgroundColor3 = "ToggleOff" },
		Parent = trackHolder,
	}, { corner(3) })

	local fill = New("Frame", {
		Size = UDim2.new((current - min) / (max - min), 0, 1, 0),
		ThemeTag = { BackgroundColor3 = "Slider" },
		Parent = track,
	}, { corner(3) })

	local knob = New("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new((current - min) / (max - min), 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = track,
		ZIndex = 3,
	}, { corner(7) })

	local object

	local function set(v, fireCallback)
		current = math.clamp(round(v, step), min, max)
		local scale = (max - min) ~= 0 and (current - min) / (max - min) or 0
		valueLabel.Text = tostring(current)
		tween(fill, 0.06, { Size = UDim2.new(scale, 0, 1, 0) })
		tween(knob, 0.06, { Position = UDim2.new(scale, 0, 0.5, 0) })
		if fireCallback ~= false then
			task.spawn(safeCallback, config.Callback, current)
		end
	end

	local dragging = false
	local function updateFromInput(input)
		local relative = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		set(min + (max - min) * math.clamp(relative, 0, 1))
	end

	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 2, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = trackHolder,
		ZIndex = 4,
	})

	connect(hit.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			tween(knob, 0.12, { Size = UDim2.new(0, 18, 0, 18) })
			updateFromInput(input)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if dragging then
				dragging = false
				tween(knob, 0.12, { Size = UDim2.new(0, 14, 0, 14) })
			end
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
			updateFromInput(input)
		end
	end)

	object = {
		Object = el.Card,
		Set = function(_, v, fire) set(v, fire ~= false) end,
		Get = function() return current end,
		Value = current,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Input(page, config)
	config = config or {}
	local el = makeElement(page, {
		Title = config.Title or "Input",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 140,
	})

	local box = New("Frame", {
		Size = UDim2.new(0, 140, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover" },
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		padding(0, { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
	})

	local input = New("TextBox", {
		Text = config.Default or "",
		PlaceholderText = config.Placeholder or "...",
		TextSize = 13,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
		Parent = box,
	})

	connect(input.FocusLost, function(enterPressed)
		task.spawn(safeCallback, config.Callback, input.Text, enterPressed)
	end)

	connect(input.Focused, function()
		tween(box, 0.15, { BackgroundColor3 = Library.Theme.Element })
	end)
	connect(input.FocusLost, function()
		tween(box, 0.15, { BackgroundColor3 = Library.Theme.ElementHover })
	end)

	local object = {
		Object = el.Card,
		Set = function(_, v) input.Text = tostring(v) end,
		Get = function() return input.Text end,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Dropdown(page, config)
	config = config or {}
	local values = config.Values or {}
	local multi = config.Multi or false

	-- Normalize selection state
	local selected = {}
	if multi then
		if typeof(config.Default) == "table" then
			for _, v in ipairs(config.Default) do
				selected[v] = true
			end
		end
	end
	local single = (not multi) and config.Default or nil

	local el = makeElement(page, {
		Title = config.Title or "Dropdown",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 150,
	})

	local function displayText()
		if multi then
			local list = {}
			for v in pairs(selected) do
				table.insert(list, tostring(v))
			end
			return #list > 0 and table.concat(list, ", ") or "None"
		else
			return single ~= nil and tostring(single) or "None"
		end
	end

	-- Header is anchored to the card's top-right so it stays put when the
	-- card grows to reveal the option list.
	local header = New("Frame", {
		Size = UDim2.new(0, 150, 0, 30),
		Position = UDim2.new(1, -12, 0, 8),
		AnchorPoint = Vector2.new(1, 0),
		ThemeTag = { BackgroundColor3 = "ElementHover" },
		Parent = el.Card,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	local headerText = New("TextLabel", {
		Text = displayText(),
		TextSize = 13,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = { TextColor3 = "Text" },
		Parent = header,
	})

	local arrow = makeIcon("chevron-down", UDim2.new(0, 16, 0, 16), "SubText")
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.Position = UDim2.new(1, -14, 0.5, 0)
	arrow.Parent = header

	-- The expandable list lives inside the card, below the header row,
	-- so it pushes following elements down (clip-safe, no popup layer).
	-- While hidden it does not count toward the card's automatic height.
	local listContainer = New("Frame", {
		Size = UDim2.new(1, -26, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 14, 0, 46),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = el.Card,
	}, {
		listLayout(4),
		padding(0, { PaddingBottom = UDim.new(0, 12) }),
	})

	local open = false
	local function setOpen(state)
		open = state
		listContainer.Visible = state
		tween(arrow, 0.15, { Rotation = state and 180 or 0 })
	end

	local headerHit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = header,
		ZIndex = 5,
	})

	local optionButtons = {}
	local function refresh()
		headerText.Text = displayText()
		for value, btn in pairs(optionButtons) do
			local isSel = multi and selected[value] or (not multi and single == value)
			tween(btn, 0.12, { BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Element })
			btn.TextColor3 = isSel and Library.Theme.AccentText or Library.Theme.Text
		end
	end

	local object

	local function choose(value)
		if multi then
			selected[value] = (not selected[value]) or nil
		else
			single = value
			setOpen(false)
		end
		refresh()
		if config.Callback then
			task.spawn(safeCallback, config.Callback, multi and selected or single)
		end
	end

	local function buildOptions(list)
		for _, old in pairs(optionButtons) do
			old:Destroy()
		end
		optionButtons = {}
		for _, value in ipairs(list) do
			local label = typeof(value) == "table" and (value.Title or "Option") or tostring(value)
			local key = typeof(value) == "table" and (value.Title or label) or value

			local btn = New("TextButton", {
				Text = label,
				TextSize = 13,
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Library.Theme.Element,
				ThemeTag = { TextColor3 = "Text" },
				Parent = listContainer,
			}, {
				corner(6),
				padding(0, { PaddingLeft = UDim.new(0, 10) }),
			})
			optionButtons[key] = btn

			connect(btn.MouseButton1Click, function()
				if typeof(value) == "table" and value.Callback then
					task.spawn(safeCallback, value.Callback)
				end
				choose(key)
			end)
		end
		refresh()
	end
	buildOptions(values)

	connect(headerHit.MouseButton1Click, function()
		setOpen(not open)
	end)

	refresh()
	-- Re-apply option colours when the theme changes (selected = Accent,
	-- others = Element) so an open dropdown doesn't lag a theme behind.
	onThemeChange(function()
		if el.Card.Parent == nil then
			error("dead") -- pruned by SetTheme
		end
		refresh()
	end)

	object = {
		Object = el.Card,
		Set = function(_, v)
			if multi then
				selected = {}
				if typeof(v) == "table" then
					for _, item in ipairs(v) do
						selected[item] = true
					end
				end
			else
				single = v
			end
			refresh()
		end,
		Get = function()
			return multi and selected or single
		end,
		SetValues = function(_, list)
			values = list or {}
			buildOptions(values)
		end,
	}

	if config.Flag then
		Library.Flags[config.Flag] = object
	end

	return object
end

function Elements.Text(page, config)
	config = config or {}
	local align = config.Align == "Center" and Enum.TextXAlignment.Center
		or config.Align == "Right" and Enum.TextXAlignment.Right
		or Enum.TextXAlignment.Left

	local label = New("TextLabel", {
		Text = config.Title or config.Text or "",
		FontFace = font(config.FontWeight or Enum.FontWeight.Medium),
		TextSize = config.TextSize or 14,
		TextXAlignment = align,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = true,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = config.Muted and "SubText" or "Text" },
		Parent = page,
	}, {
		padding(0, { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2) }),
	})
	if config.Color then
		label.TextColor3 = config.Color
	end

	return {
		Object = label,
		Set = function(_, t) label.Text = t end,
		SetText = function(_, t) label.Text = t end,
	}
end

function Elements.Space(page, config)
	config = config or {}
	local space = New("Frame", {
		Size = UDim2.new(1, 0, 0, config.Height or config.Size or 6),
		BackgroundTransparency = 1,
		Parent = page,
	})
	return { Object = space }
end

function Elements.Keybind(page, config)
	config = config or {}
	local current = config.Default
	if typeof(current) == "string" then
		current = (current ~= "None" and current ~= "") and Enum.KeyCode[current] or nil
	end

	local el = makeElement(page, {
		Title = config.Title or "Keybind",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 92,
	})

	local btn = New("TextButton", {
		Text = current and current.Name or "None",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 13,
		AutoButtonColor = false,
		Size = UDim2.new(0, 90, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover", TextColor3 = "Text" },
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	local binding = false

	local function setKey(key, fireCallback)
		current = key
		btn.Text = key and key.Name or "None"
		if fireCallback then
			task.spawn(safeCallback, config.Callback, key)
		end
	end

	connect(btn.MouseButton1Click, function()
		binding = true
		btn.Text = "..."
		tween(btn, 0.12, { BackgroundColor3 = Library.Theme.Accent })
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				binding = false
				tween(btn, 0.12, { BackgroundColor3 = Library.Theme.ElementHover })
				-- fire the callback when the user rebinds (sets) a key
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
					setKey(nil, true)
				else
					setKey(input.KeyCode, true)
				end
			end
			return
		end
		if processed then
			return
		end
		if current and input.KeyCode == current then
			task.spawn(safeCallback, config.Callback, current)
		end
	end)

	local object = {
		Object = el.Card,
		Set = function(_, k, fire)
			if typeof(k) == "string" then
				k = (k ~= "None" and k ~= "") and Enum.KeyCode[k] or nil
			end
			setKey(k, fire == true)
		end,
		Get = function() return current end,
	}
	if config.Flag then
		Library.Flags[config.Flag] = object
	end
	return object
end

function Elements.Colorpicker(page, config)
	config = config or {}

	local h, s, v = 0, 1, 1
	if typeof(config.Default) == "Color3" then
		local ok, hh, ss, vv = pcall(function()
			return config.Default:ToHSV()
		end)
		if ok and hh then
			h, s, v = hh, ss, vv
		end
	end

	local el = makeElement(page, {
		Title = config.Title or "Colorpicker",
		Desc = config.Desc,
		Icon = config.Icon,
		ControlWidth = 44,
	})

	local swatch = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, 40, 0, 24),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromHSV(h, s, v),
		Parent = el.Control,
	}, {
		corner(6),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})

	-- inline panel (revealed below the row; grows the card)
	local panel = New("Frame", {
		Size = UDim2.new(1, -26, 0, 124),
		Position = UDim2.new(0, 14, 0, 46),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = el.Card,
	})

	-- saturation/value square
	local svSquare = New("Frame", {
		Size = UDim2.new(1, -26, 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Parent = panel,
	}, {
		corner(6),
		New("Frame", { -- white -> transparent (saturation)
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("#ffffff"),
		}, {
			corner(6),
			New("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
		New("Frame", { -- transparent -> black (value)
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromHex("#000000"),
		}, {
			corner(6),
			New("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				}),
			}),
		}),
	})

	local svCursor = New("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		ZIndex = 5,
		Parent = svSquare,
	}, {
		corner(5),
		New("UIStroke", { Thickness = 1.5, Color = Color3.fromHex("#000000"), Transparency = 0.4 }),
	})

	-- hue bar (vertical, right side)
	local hueBar = New("Frame", {
		Size = UDim2.new(0, 16, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		Parent = panel,
	}, {
		corner(6),
		New("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
				ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
				ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
				ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
				ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
				ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
				ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
			}),
		}),
	})

	local hueCursor = New("Frame", {
		Size = UDim2.new(1, 4, 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, h, 0),
		BackgroundColor3 = Color3.fromHex("#ffffff"),
		ZIndex = 5,
		Parent = hueBar,
	}, {
		corner(2),
		New("UIStroke", { Thickness = 1, Color = Color3.fromHex("#000000"), Transparency = 0.4 }),
	})

	local object

	local function fire()
		if config.Callback then
			task.spawn(safeCallback, config.Callback, Color3.fromHSV(h, s, v))
		end
	end

	local function updateVisual(doFire)
		local colour = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = colour
		svSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		if doFire ~= false then
			fire()
		end
	end

	-- drag helpers
	local function bindDrag(frame, onMove)
		local dragging = false
		connect(frame.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				onMove(input)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				onMove(input)
			end
		end)
	end

	bindDrag(svSquare, function(input)
		local rx = math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
		local ry = math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
		s, v = rx, 1 - ry
		updateVisual()
	end)
	bindDrag(hueBar, function(input)
		h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
		updateVisual()
	end)

	local open = false
	connect(swatch.MouseButton1Click, function()
		open = not open
		panel.Visible = open
	end)

	object = {
		Object = el.Card,
		Set = function(_, colour)
			if typeof(colour) == "Color3" then
				local ok, hh, ss, vv = pcall(function()
					return colour:ToHSV()
				end)
				if ok and hh then
					h, s, v = hh, ss, vv
					updateVisual(false)
				end
			end
		end,
		Get = function() return Color3.fromHSV(h, s, v) end,
	}
	if config.Flag then
		Library.Flags[config.Flag] = object
	end
	return object
end

function Elements.Code(page, config)
	config = config or {}
	local codeText = config.Code or config.Text or ""

	-- clipboard shim (executor-dependent; falls back to a no-op)
	local setClip = setclipboard
		or toclipboard
		or writeclipboard
		or (syn and syn.write_clipboard)
		or function() end

	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeTag = { BackgroundColor3 = "Element" },
		Parent = page,
	}, {
		corner(8),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
		listLayout(8),
		padding(12),
	})

	local header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = card,
	})
	New("TextLabel", {
		Text = config.Title or "Code",
		FontFace = font(Enum.FontWeight.SemiBold),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -60, 1, 0),
		ThemeTag = { TextColor3 = "SubText" },
		Parent = header,
	})
	local copyBtn = New("TextButton", {
		Text = "Copy",
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 12,
		AutoButtonColor = false,
		Size = UDim2.new(0, 56, 0, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "ElementHover", TextColor3 = "Text" },
		Parent = header,
	}, { corner(5) })

	local codeLabel = New("TextLabel", {
		Text = codeText,
		FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		RichText = false,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "Text" },
		Parent = card,
	})

	connect(copyBtn.MouseButton1Click, function()
		pcall(setClip, codeLabel.Text)
		copyBtn.Text = "Copied!"
		task.delay(1, function()
			copyBtn.Text = "Copy"
		end)
	end)

	return {
		Object = card,
		Set = function(_, t) codeLabel.Text = t end,
		Get = function() return codeLabel.Text end,
	}
end

--//============================================================\\--
--||                          TAB                              ||--
--\\============================================================//--

local function createTab(window, config)
	config = config or {}
	local Tab = {
		Title = config.Title or "Tab",
		Icon = config.Icon,
	}

	window.TabCount = window.TabCount + 1
	local index = window.TabCount

	-- Sidebar button. BackgroundColor3 is theme-tagged so the active tab's
	-- fill tracks theme changes; SelectTab only toggles its transparency.
	local button = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		ThemeTag = { BackgroundColor3 = "TabActive" },
		Parent = window.TabList,
		LayoutOrder = index,
	}, {
		corner(9),
	})

	local activeBar = New("Frame", {
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = { BackgroundColor3 = "Accent" },
		BackgroundTransparency = 1,
		Parent = button,
	}, { corner(2) })

	-- Optional tab icon
	local textInset = 14
	if config.Icon and config.Icon ~= "" then
		local icon = makeIcon(config.Icon, UDim2.new(0, 17, 0, 17), "TabText")
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Position = UDim2.new(0, 12, 0.5, 0)
		icon.Parent = button
		Tab.IconImage = icon
		textInset = 12 + 17 + 8
	end

	local label = New("TextLabel", {
		Text = Tab.Title,
		FontFace = font(Enum.FontWeight.Medium),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -textInset - 8, 1, 0),
		Position = UDim2.new(0, textInset, 0, 0),
		ThemeTag = { TextColor3 = "TabText" },
		Parent = button,
	})

	-- Content page
	local page = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = window.ContentHolder,
	}, {
		listLayout(8),
		padding(2, { PaddingRight = UDim.new(0, 8) }),
	})

	Tab.SidebarButton = button
	Tab.Page = page
	Tab.Index = index

	function Tab:Select()
		window:SelectTab(index)
	end

	-- Wire element constructors onto the tab (Tab:Button, Tab:Toggle, ...).
	bindElements(Tab, page)

	connect(button.MouseButton1Click, function()
		window:SelectTab(index)
	end)
	connect(button.MouseEnter, function()
		if window.CurrentTab ~= index then
			tween(button, 0.15, { BackgroundTransparency = 0.6 })
		end
	end)
	connect(button.MouseLeave, function()
		if window.CurrentTab ~= index then
			tween(button, 0.15, { BackgroundTransparency = 1 })
		end
	end)

	window.Tabs[index] = {
		Button = button,
		Page = page,
		Label = label,
		ActiveBar = activeBar,
		Icon = Tab.IconImage,
	}

	-- An explicit tab (not the implicit window-level page) reveals the sidebar.
	if not config.Implicit and window.SetSidebar then
		window:SetSidebar(true)
	end

	if not window.CurrentTab then
		window:SelectTab(index)
	end

	return Tab
end

--//============================================================\\--
--||                       KEY SYSTEM                          ||--
--\\============================================================//--
-- Optional gate shown before a window loads. Blocks (yields) until a valid
-- key is entered, or returns false if the user closes it.

local function runKeySystem(cfg)
	cfg = cfg or {}
	local keys = cfg.Key
	if typeof(keys) == "string" then
		keys = { keys }
	end

	local function isValid(input)
		input = tostring(input)
		if cfg.Validator then
			local ok, res = pcall(cfg.Validator, input)
			return ok and res and true or false
		end
		if keys then
			for _, k in ipairs(keys) do
				if tostring(k) == input then
					return true
				end
			end
		end
		return false
	end

	-- Saved key shortcut
	local savePath = cfg.SaveKey and ((cfg.Folder or "SerhiiUI") .. "/key.txt") or nil
	if savePath and isfile then
		local ok, saved = pcall(function()
			return isfile(savePath) and readfile(savePath) or nil
		end)
		if ok and saved and isValid(saved) then
			return true
		end
	end

	local done, result = false, false

	local overlay = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromHex("#000000"),
		BackgroundTransparency = 0.4,
		ZIndex = 50,
		Parent = ScreenGui,
	})

	local card = New("Frame", {
		Size = UDim2.new(0, 320, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ThemeTag = { BackgroundColor3 = "Background" },
		ZIndex = 51,
		Parent = overlay,
	}, {
		corner(12),
		New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }),
		listLayout(10),
		padding(18),
	})

	New("TextLabel", {
		Text = cfg.Title or "Key System",
		FontFace = font(Enum.FontWeight.Bold),
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 51,
		ThemeTag = { TextColor3 = "Text" },
		Parent = card,
	})

	New("TextLabel", {
		Text = cfg.Note or cfg.Subtitle or "Enter your key to continue.",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		ZIndex = 51,
		ThemeTag = { TextColor3 = "SubText" },
		Parent = card,
	})

	local box = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		ThemeTag = { BackgroundColor3 = "Element" },
		ZIndex = 51,
		Parent = card,
	}, {
		corner(8),
		New("UIStroke", { Thickness = 1, ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" } }),
		padding(0, { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
	})
	local input = New("TextBox", {
		Text = "",
		PlaceholderText = "Key...",
		TextSize = 14,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 52,
		ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
		Parent = box,
	})

	local status = New("TextLabel", {
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 51,
		TextColor3 = Color3.fromHex("#f87171"),
		Parent = card,
	})

	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		ZIndex = 51,
		Parent = card,
	}, {
		listLayout(8, Enum.FillDirection.Horizontal, { HorizontalAlignment = Enum.HorizontalAlignment.Right }),
	})

	local function makeKeyBtn(text, accent)
		return New("TextButton", {
			Text = text,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 13,
			AutoButtonColor = false,
			Size = UDim2.new(0, accent and 90 or 80, 1, 0),
			ZIndex = 51,
			ThemeTag = accent and { BackgroundColor3 = "Accent", TextColor3 = "AccentText" }
				or { BackgroundColor3 = "Element", TextColor3 = "Text" },
			Parent = row,
		}, {
			corner(8),
			accent and nil or New("UIStroke", {
				Thickness = 1,
				ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
			}),
		})
	end

	local closeBtn = makeKeyBtn("Cancel", false)
	if cfg.GetKey then
		local getBtn = makeKeyBtn("Get Key", false)
		connect(getBtn.MouseButton1Click, function()
			local copy = setclipboard or toclipboard or writeclipboard or function() end
			pcall(copy, tostring(cfg.GetKey))
			status.TextColor3 = Library.Theme.SubText
			status.Text = "Link copied to clipboard."
		end)
	end
	local submitBtn = makeKeyBtn("Submit", true)

	local function submit()
		if isValid(input.Text) then
			if savePath and writefile then
				pcall(function()
					if makefolder and not (isfolder and isfolder(cfg.Folder or "SerhiiUI")) then
						makefolder(cfg.Folder or "SerhiiUI")
					end
					writefile(savePath, input.Text)
				end)
			end
			result = true
			done = true
			overlay:Destroy()
		else
			status.TextColor3 = Color3.fromHex("#f87171")
			status.Text = "Invalid key, try again."
			tween(card, 0.08, { Position = UDim2.new(0.5, 6, 0.5, 0) })
			task.delay(0.08, function()
				tween(card, 0.12, { Position = UDim2.new(0.5, 0, 0.5, 0) })
			end)
		end
	end

	connect(submitBtn.MouseButton1Click, submit)
	connect(input.FocusLost, function(enter)
		if enter then
			submit()
		end
	end)
	connect(closeBtn.MouseButton1Click, function()
		result = false
		done = true
		overlay:Destroy()
	end)

	repeat
		task.wait()
	until done

	return result
end

--//============================================================\\--
--||                         WINDOW                            ||--
--\\============================================================//--

function Library:CreateWindow(config)
	config = config or {}

	if config.KeySystem then
		local ok = runKeySystem(config.KeySystem)
		if not ok then
			return nil
		end
	end

	local Window = {
		Library = Library,
		Title = config.Title or "SerhiiUI",
		SubTitle = config.SubTitle or config.Author,
		ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
		Tabs = {},
		TabCount = 0,
		CurrentTab = nil,
		Minimized = false,
	}

	local size = config.Size or UDim2.fromOffset(560, 420)
	local sidebarWidth = config.SidebarWidth or 168
	local topbarHeight = 46

	-- Root -------------------------------------------------------------
	local main = New("Frame", {
		Name = "Window",
		Size = size,
		Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})

	-- soft drop shadow (built-in sliced shadow asset)
	New("ImageLabel", {
		Image = "rbxassetid://8992230677",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Size = UDim2.new(1, 120, 1, 120),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = main,
	})

	-- NOTE: a plain Frame, deliberately NOT a CanvasGroup. CanvasGroups
	-- flatten their descendants into a single texture, which makes icons and
	-- text render soft/blurry. The open/close animation uses size, not group
	-- transparency, so everything stays crisp.
	local root = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,
		ThemeTag = { BackgroundColor3 = "Background" },
		Parent = main,
	}, {
		corner(config.Radius or 16),
		New("UIStroke", {
			Thickness = 1,
			ThemeTag = { Color = "Stroke", Transparency = "StrokeTransparency" },
		}),
	})
	Window.Root = root

	-- Bottom drag handle (WindUI signature). Purely visual + an extra drag grip.
	local dragHandle = New("Frame", {
		Size = UDim2.new(0, 110, 0, 4),
		Position = UDim2.new(0.5, 0, 1, -8),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 0.65,
		ThemeTag = { BackgroundColor3 = "Text" },
		ZIndex = 6,
		Parent = root,
	}, { corner(2) })

	-- Topbar -----------------------------------------------------------
	local topbar = New("Frame", {
		Size = UDim2.new(1, 0, 0, topbarHeight),
		BackgroundTransparency = 1,
		Parent = root,
	}, {
		padding(0, { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) }),
	})

	-- title block (left): optional icon + (title / subtitle)
	local titleRow = New("Frame", {
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	}, {
		listLayout(8, Enum.FillDirection.Horizontal, {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	local titleIconInset = 0
	if config.Icon and config.Icon ~= "" then
		local isAsset = typeof(config.Icon) == "string" and config.Icon:match("^rbxassetid://") ~= nil
		local iconPx = config.IconSize or 22
		titleIconInset = iconPx + 8 -- lebar ikon + jarak list layout
		local winIcon = makeIcon(
			config.Icon,
			UDim2.new(0, iconPx, 0, iconPx),
			(not isAsset) and "Text" or nil,
			isAsset and Color3.new(1, 1, 1) or nil
		)
		winIcon.LayoutOrder = 1
		winIcon.Parent = titleRow
		Window.IconImage = winIcon

		-- Fallback logo judul (sama seperti tombol buka): kalau asset gagal
		-- dimuat lewat rbxassetid, coba thumbnail, lalu huruf "R".
		if isAsset then
			task.spawn(function()
				local function waitLoaded(t)
					local t0 = os.clock()
					while os.clock() - t0 < t do
						if winIcon.IsLoaded then return true end
						task.wait(0.2)
					end
					return winIcon.IsLoaded
				end
				if waitLoaded(2.5) then return end
				local id = tostring(config.Icon):match("%d+")
				if id then
					winIcon.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
					if waitLoaded(4) then return end
				end
				winIcon.ImageTransparency = 1
				New("TextLabel", {
					Text = "R",
					FontFace = font(Enum.FontWeight.Bold),
					TextSize = math.floor(iconPx * 0.8),
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ThemeTag = { TextColor3 = "Accent" },
					Parent = winIcon,
				})
			end)
		end
	end

	New("Frame", {
		Size = UDim2.new(1, -titleIconInset, 1, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = titleRow,
	}, {
		listLayout(1, Enum.FillDirection.Vertical, {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		New("TextLabel", {
			Text = Window.Title,
			FontFace = font(Enum.FontWeight.SemiBold),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 18),
			ThemeTag = { TextColor3 = "Text" },
		}),
		Window.SubTitle and New("TextLabel", {
			Text = Window.SubTitle,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			ThemeTag = { TextColor3 = "SubText" },
		}) or nil,
	})

	-- window controls (right)
	local controls = New("Frame", {
		Size = UDim2.new(0, 132, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	}, {
		listLayout(4, Enum.FillDirection.Horizontal, {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	local function controlButton(iconName, order, callback)
		local btn = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundTransparency = 1,
			LayoutOrder = order,
			ThemeTag = { BackgroundColor3 = "ElementHover" },
			Parent = controls,
		}, { corner(8) })

		local icon = makeIcon(iconName, UDim2.new(0, 16, 0, 16), "SubText")
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Parent = btn

		connect(btn.MouseEnter, function()
			tween(btn, 0.12, { BackgroundTransparency = 0 })
			tween(icon, 0.12, { ImageColor3 = Library.Theme.Text })
		end)
		connect(btn.MouseLeave, function()
			tween(btn, 0.12, { BackgroundTransparency = 1 })
			tween(icon, 0.12, { ImageColor3 = Library.Theme.SubText })
		end)
		connect(btn.MouseButton1Click, callback)
		return btn, icon
	end

	-- Tombol Discord (paling kiri, di samping minimize & X): salin link invite
	local DISCORD_LINK = "https://discord.gg/wBMUk86q"
	local dcBtn, dcIcon = controlButton("message-circle", 0, function()
		local copied = false
		if setclipboard then
			copied = pcall(setclipboard, DISCORD_LINK)
		elseif toclipboard then
			copied = pcall(toclipboard, DISCORD_LINK)
		end
		Library:Notify({
			Title = "Discord",
			Content = copied and ("Link disalin: " .. DISCORD_LINK) or DISCORD_LINK,
			Duration = 4,
			Icon = "rbxassetid://110525773603905",
		})
	end)
	-- Kalau ikon gagal dimuat, tampilkan teks "DC" sebagai gantinya
	if dcIcon.Image == "" then
		dcIcon.Visible = false
		New("TextLabel", {
			Text = "DC",
			FontFace = font(Enum.FontWeight.Bold),
			TextSize = 11,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "SubText" },
			Parent = dcBtn,
		})
	end

	controlButton("minus", 1, function()
		Window:Minimize()
	end)
	local maxBtn, maxIcon = controlButton("maximize", 2, function()
		Window:ToggleFullscreen()
	end)
	controlButton("x", 3, function()
		Window:Close()
	end)

	-- Sidebar ----------------------------------------------------------
	local sidebarFrame = New("Frame", {
		Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight),
		Position = UDim2.new(0, 0, 0, topbarHeight),
		ThemeTag = { BackgroundColor3 = "Sidebar" },
		BackgroundTransparency = 0,
		Parent = root,
	})

	local tabList = New("ScrollingFrame", {
		Size = UDim2.new(0, sidebarWidth, 1, -topbarHeight - 12),
		Position = UDim2.new(0, 0, 0, topbarHeight + 6),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = root,
	}, {
		listLayout(4),
		padding(0, {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 2),
		}),
	})
	Window.TabList = tabList

	-- vertical divider
	local divider = New("Frame", {
		Size = UDim2.new(0, 1, 1, -topbarHeight - 16),
		Position = UDim2.new(0, sidebarWidth, 0, topbarHeight + 8),
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "Stroke" },
		Parent = root,
	})

	-- Content ----------------------------------------------------------
	local contentHolder = New("Frame", {
		Size = UDim2.new(1, -sidebarWidth - 12, 1, -topbarHeight - 12),
		Position = UDim2.new(0, sidebarWidth + 12, 0, topbarHeight + 6),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = root,
	})
	Window.ContentHolder = contentHolder

	-- Sidebar can be hidden so elements added straight to the window (no
	-- explicit tabs) use the full width. Hidden until the first real Tab.
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

	-- Behaviour --------------------------------------------------------
	dragify(main, topbar)
	dragify(main, dragHandle)

	function Window:SelectTab(targetIndex)
		Window.CurrentTab = targetIndex
		for i, data in pairs(Window.Tabs) do
			local active = i == targetIndex
			data.Page.Visible = active
			tween(data.Button, 0.15, { BackgroundTransparency = active and 0 or 1 })
			tween(data.Label, 0.15, {
				TextColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText,
			})
			if data.Icon then
				tween(data.Icon, 0.15, {
					ImageColor3 = active and Library.Theme.TabTextActive or Library.Theme.TabText,
				})
			end
			tween(data.ActiveBar, 0.15, { BackgroundTransparency = active and 0 or 1 })
		end
	end

	function Window:Tab(tabConfig)
		return createTab(Window, tabConfig)
	end

	-- Window-level elements (optional tabs). Calling Window:Button(...) etc.
	-- appends to an implicit "Main" page; if no explicit tabs exist the
	-- sidebar stays hidden and the page fills the window.
	local function defaultPage()
		if not Window.DefaultTab then
			Window.DefaultTab = createTab(Window, {
				Title = config.DefaultTabTitle or "Main",
				Implicit = true,
			})
		end
		return Window.DefaultTab
	end
	for name in pairs(Elements) do
		Window[name] = function(_, elementConfig)
			local tab = defaultPage()
			return tab[name](tab, elementConfig)
		end
	end

	-- Config save system ----------------------------------------------
	-- Opt-in: pass `ConfigFolder` (or `Folder`). Only elements created with
	-- a `Flag` are saved. Values round-trip through JSON on disk; Color3 and
	-- KeyCode are tagged so they deserialize back to the right type.
	local configFolder = config.ConfigFolder or config.Folder
	local hasFS = (writefile and readfile and isfile) and true or false

	local function color3ToHex(c)
		return string.format(
			"#%02X%02X%02X",
			math.floor(c.R * 255 + 0.5),
			math.floor(c.G * 255 + 0.5),
			math.floor(c.B * 255 + 0.5)
		)
	end

	local function serializeValue(v)
		local t = typeof(v)
		if t == "Color3" then
			return { __type = "Color3", value = color3ToHex(v) }
		elseif t == "EnumItem" then
			return { __type = "KeyCode", value = v.Name }
		elseif t == "table" then
			local arr = {}
			for key, on in pairs(v) do
				if on then
					table.insert(arr, key)
				end
			end
			return { __type = "Set", value = arr }
		end
		return v
	end

	local function deserializeValue(v)
		if typeof(v) == "table" and v.__type then
			if v.__type == "Color3" then
				return Color3.fromHex(v.value)
			elseif v.__type == "KeyCode" then
				return Enum.KeyCode[v.value]
			elseif v.__type == "Set" then
				return v.value
			end
		end
		return v
	end

	local Config = { Folder = configFolder }
	Window.Config = Config

	local function ensureFolder()
		if configFolder and makefolder and isfolder and not isfolder(configFolder) then
			pcall(makefolder, configFolder)
		end
	end

	function Config:Save(name)
		if not hasFS or not configFolder then
			warn("[SerhiiUI] config saving unavailable (need an executor + ConfigFolder)")
			return false
		end
		ensureFolder()
		local data = {}
		for flag, element in pairs(Library.Flags) do
			if element.Get then
				local ok, value = pcall(function()
					return element:Get()
				end)
				if ok and value ~= nil then
					data[flag] = serializeValue(value)
				end
			end
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if ok then
			pcall(writefile, configFolder .. "/" .. (name or "default") .. ".json", encoded)
			return true
		end
		return false
	end

	function Config:Load(name)
		if not hasFS or not configFolder then
			return false
		end
		local path = configFolder .. "/" .. (name or "default") .. ".json"
		if not isfile(path) then
			return false
		end
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if not ok or typeof(decoded) ~= "table" then
			return false
		end
		for flag, raw in pairs(decoded) do
			local element = Library.Flags[flag]
			if element and element.Set then
				pcall(function()
					element:Set(deserializeValue(raw))
				end)
			end
		end
		return true
	end

	function Config:List()
		local out = {}
		if not hasFS or not configFolder or not listfiles or not isfolder or not isfolder(configFolder) then
			return out
		end
		for _, file in ipairs(listfiles(configFolder)) do
			local name = tostring(file):match("([^/\\]+)%.json$")
			if name then
				table.insert(out, name)
			end
		end
		return out
	end

	function Config:Delete(name)
		if hasFS and configFolder and delfile then
			local path = configFolder .. "/" .. (name or "default") .. ".json"
			if isfile(path) then
				pcall(delfile, path)
				return true
			end
		end
		return false
	end

	-- Floating logo button (selalu tampil): klik = buka/tutup window, tahan & geser = pindah.
	-- Hanya logo: tanpa kotak, tanpa stroke, background transparan.
	local logoImage = config.OpenLogo
	if not logoImage and typeof(config.Icon) == "string" and config.Icon:match("^rbxassetid://") then
		logoImage = config.Icon
	end
	local logoSize = config.OpenLogoSize or 56
	local openButton = New("TextButton", {
		Name = "OpenButton",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, logoSize, 0, logoSize),
		Position = UDim2.new(0, 20, 0, 80),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 100,
		Visible = true,
		Parent = ScreenGui,
	})
	if logoImage then
		local logo = New("ImageLabel", {
			Name = "Logo",
			Image = logoImage,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = Color3.new(1, 1, 1),
			ZIndex = 101,
			Parent = openButton,
		})
		-- Kalau asset gagal dimuat: coba lewat thumbnail, lalu huruf "R" sebagai cadangan.
		task.spawn(function()
			local function waitLoaded(t)
				local t0 = os.clock()
				while os.clock() - t0 < t do
					if logo.IsLoaded then return true end
					task.wait(0.2)
				end
				return logo.IsLoaded
			end
			if waitLoaded(4) then return end
			local id = tostring(logoImage):match("%d+")
			if id then
				logo.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420"
				if waitLoaded(4) then return end
			end
			logo.Visible = false
			New("TextLabel", {
				Text = "R",
				FontFace = font(Enum.FontWeight.Bold),
				TextSize = math.floor(logoSize * 0.7),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ZIndex = 101,
				ThemeTag = { TextColor3 = "Accent" },
				Parent = openButton,
			})
		end)
	else
		local obIcon = makeIcon((config.Icon and config.Icon ~= "" and config.Icon) or "layout-grid", UDim2.new(0, 28, 0, 28), "Accent")
		obIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		obIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		obIcon.Parent = openButton
	end

	-- drag manual: bedakan klik dan geser
	local obDragging, obMoved, obStart, obStartPos = false, false, nil, nil
	connect(openButton.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			obDragging, obMoved = true, false
			obStart, obStartPos = input.Position, openButton.Position
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if obDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - obStart
			if d.Magnitude > 6 then
				obMoved = true
			end
			if obMoved then
				openButton.Position = UDim2.new(
					obStartPos.X.Scale, obStartPos.X.Offset + d.X,
					obStartPos.Y.Scale, obStartPos.Y.Offset + d.Y
				)
			end
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if obDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			obDragging = false
			if not obMoved then
				if Window.Minimized then
					Window:Open()
				else
					Window:Minimize()
				end
			end
		end
	end)

	-- Animations use Size only (no GroupTransparency) to keep icons crisp.
	local collapsed = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)

	function Window:Minimize()
		Window.Minimized = true
		tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
		task.delay(0.31, function()
			if Window.Minimized then
				main.Visible = false
			end
		end)
	end

	function Window:Open()
		Window.Minimized = false
		main.Visible = true
		main.Size = collapsed
		tween(main, 0.4, { Size = size }, Enum.EasingStyle.Back)
	end

	function Window:Close()
		tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
		task.delay(0.32, function()
			Window:Destroy()
		end)
	end

	function Window:Destroy()
		Window.Destroyed = true
		for _, conn in ipairs(Library.Connections) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		ScreenGui:Destroy()
	end

	function Window:SetToggleKey(key)
		if typeof(key) == "string" then
			key = Enum.KeyCode[key]
		end
		if key then
			Window.ToggleKey = key
		end
	end

	connect(UserInputService.InputBegan, function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Window.ToggleKey then
			if Window.Minimized then
				Window:Open()
			else
				Window:Minimize()
			end
		end
	end)

	-- Re-apply the active tab's label/icon colours on theme change (SelectTab
	-- sets them directly, so they would otherwise lag a theme behind).
	onThemeChange(function()
		if Window.Destroyed then
			error("dead")
		end
		if Window.CurrentTab then
			Window:SelectTab(Window.CurrentTab)
		end
	end)

	-- Intro animation --------------------------------------------------
	main.Size = collapsed
	tween(main, 0.45, { Size = size }, Enum.EasingStyle.Back)

	table.insert(Library.Windows, Window)
	return Window
end

return Library

end)()

-- ===================== RYNER HUB • SERHIIUI (TEMA PLUM) =====================
SerhiiUI:SetTheme("Plum")

local UIS = game:GetService("UserInputService")
local LOGO_ID = "rbxassetid://110525773603905" -- logo RynerHUB

-- ---------- Registry config (dipakai Save / Load / Reset Config) ----------
CURRENT_VERSION = 1
ConfigData = { _version = CURRENT_VERSION }

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

LoadConfigElements = function()
    for _, e in ipairs(registry) do
        local v = ConfigData[e.id]
        if v == nil then v = e.default end
        if v ~= nil then pcall(e.apply, v) end
    end
end

SaveConfig = function(name)
    if not name or name == "" then return false end
    local data = { _version = CURRENT_VERSION }
    for _, e in ipairs(registry) do
        local ok, v = pcall(e.get)
        if ok and v ~= nil then data[e.id] = v end
    end
    ConfigData = data
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then
        pcall(writefile, ConfigFolder .. name .. ".json", encoded)
        return true
    end
    return false
end

LoadConfigFromFile = function(name)
    if not name or name == "" then return false end
    local path = ConfigFolder .. name .. ".json"
    if not (isfile and isfile(path)) then return false end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(decoded) ~= "table" then return false end
    ConfigData = decoded
    LoadConfigElements()
    return true
end

-- ---------- Notifikasi ----------
notif = function(msg, duration)
    SerhiiUI:Notify({
        Title = "RynerHUB",
        Content = tostring(msg),
        Duration = tonumber(duration) or 3,
        Icon = LOGO_ID,
    })
end
SendNotif = notif

Library = {
    Notify = function(_, cfg)
        cfg = cfg or {}
        SerhiiUI:Notify({
            Title = cfg.Title or "RynerHUB",
            Content = cfg.Description or cfg.Content or "",
            Duration = cfg.Time or cfg.Duration or 3,
            Icon = LOGO_ID,
        })
    end,
}

-- ---------- Chip keybind kecil di dalam kartu toggle ----------
local KEY_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

local function shortKey(name)
    if not name or name == "None" then return "None" end
    name = name:gsub("Left", "L"):gsub("Right", "R"):gsub("Control", "Ctrl"):gsub("Shift", "Shift")
    return name
end

local function attachKeybind(card, handle, id)
    local theme = SerhiiUI.Theme
    local current = nil

    local textCol = card:FindFirstChildWhichIsA("Frame")
    if textCol then
        textCol.Size = textCol.Size - UDim2.fromOffset(62, 0)
    end

    local chip = Instance.new("TextButton")
    chip.Name = "KeybindChip"
    chip.AutoButtonColor = false
    chip.BorderSizePixel = 0
    chip.Text = "None"
    chip.FontFace = KEY_FONT
    chip.TextSize = 11
    chip.TextTruncate = Enum.TextTruncate.AtEnd
    chip.TextColor3 = theme.SubText
    chip.BackgroundColor3 = theme.ElementHover
    chip.Size = UDim2.new(0, 54, 0, 22)
    chip.AnchorPoint = Vector2.new(1, 0.5)
    chip.Position = UDim2.new(1, -(12 + 44 + 8), 0.5, 0)
    chip.ZIndex = 10
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = chip
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = theme.Stroke
    stroke.Transparency = theme.StrokeTransparency
    stroke.Parent = chip
    chip.Parent = card

    local binding = false

    local function refreshChip()
        chip.Text = binding and "..." or shortKey(current and current.Name or "None")
        chip.TextColor3 = (binding or current) and theme.Text or theme.SubText
    end

    local function setKey(keyName)
        if keyName and keyName ~= "None" and Enum.KeyCode[keyName] then
            current = Enum.KeyCode[keyName]
        else
            current = nil
        end
        refreshChip()
        if id then ConfigData[id .. "#key"] = current and current.Name or "None" end
    end

    chip.MouseButton1Click:Connect(function()
        binding = true
        refreshChip()
    end)

    local keyConn = UIS.InputBegan:Connect(function(input, processed)
        if binding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                binding = false
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                    setKey(nil)
                else
                    setKey(input.KeyCode.Name)
                end
            end
            return
        end
        if processed then return end
        if current and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current then
            handle:Set(not handle:Get(), true)
        end
    end)
    table.insert(SerhiiUI.Connections, keyConn) -- ikut terputus saat window di-destroy

    if id then
        register(id .. "#key", function() return current and current.Name or "None" end, setKey, "None")
    end
end

-- ---------- Adapter: API lama (AddSection/AddToggle/...) -> SerhiiUI ----------
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

    function api:AddSubSection(title)
        return place(raw:Text({
            Title = tostring(title),
            FontWeight = Enum.FontWeight.SemiBold,
            TextSize = 13,
            Muted = true,
        }))
    end

    function api:AddDivider()
        return place(raw:Divider())
    end

    function api:AddParagraph(c)
        c = c or {}
        local rawEl = raw:Paragraph({ Title = c.Title, Desc = c.Content or c.Desc, Icon = c.Icon })
        place(rawEl)
        local handle = { Object = rawEl.Object }
        function handle:SetContent(t) rawEl:SetDesc(t) end
        function handle:SetTitle(t) rawEl:SetTitle(t) end
        return handle
    end

    function api:AddButton(c)
        c = c or {}
        if c.SubTitle then
            -- dua tombol sebaris (Title + SubTitle)
            local b1 = raw:Button({ Title = c.Title, Callback = c.Callback })
            local b2 = raw:Button({ Title = c.SubTitle, Callback = c.SubCallback })
            local row = Instance.new("Frame")
            row.Name = "ButtonRow"
            row.BackgroundTransparency = 1
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 0)
            row.AutomaticSize = Enum.AutomaticSize.Y
            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Horizontal
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 6)
            layout.Parent = row
            row.Parent = raw.Body or raw.Page
            for i, b in ipairs({ b1, b2 }) do
                b.Object.Size = UDim2.new(0.5, -3, 0, 40)
                b.Object.LayoutOrder = i
                b.Object.Parent = row
            end
            return place({ Object = row })
        end
        local rawEl = raw:Button({
            Title = c.Title,
            Desc = c.Content or c.Desc,
            Icon = c.Icon,
            Callback = c.Callback,
        })
        return place(rawEl)
    end

    function api:AddToggle(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local default = false
        if c.Default ~= nil then default = c.Default elseif c.Value ~= nil then default = c.Value end
        default = default and true or false

        local rawEl = raw:Toggle({
            Title = c.Title,
            Desc = c.Content or c.Desc,
            Icon = c.Icon,
            Default = default,
            Callback = function(v)
                if id then ConfigData[id] = v end
                if userCb then userCb(v) end
            end,
        })
        place(rawEl)

        local handle = { Object = rawEl.Object }
        function handle:Set(v, fire) rawEl:Set(v and true or false, fire) end
        handle.SetValue = handle.Set
        function handle:Get() return rawEl:Get() end
        setmetatable(handle, {
            __index = function(_, k)
                if k == "Value" then return rawEl:Get() end
            end,
        })

        if id then
            register(id, function() return rawEl:Get() end, function(v)
                v = v and true or false
                if rawEl:Get() ~= v then rawEl:Set(v, true) end
            end, default)
        end
        if c.Keybind and not isMobile then
            attachKeybind(rawEl.Object, handle, id)
        end
        return handle
    end

    function api:AddSlider(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local min, max = c.Min or 0, c.Max or 100
        local def = c.Default or min
        local step = c.Step or c.Increment or c.Rounding
        if not step then
            if (min % 1 ~= 0) or (max % 1 ~= 0) or (def % 1 ~= 0) then step = 0.1 else step = 1 end
        end

        local rawEl = raw:Slider({
            Title = c.Title,
            Desc = c.Content or c.Desc,
            Icon = c.Icon,
            Value = { Min = min, Max = max, Default = def },
            Step = step,
            Callback = function(v)
                if id then ConfigData[id] = v end
                if userCb then userCb(v) end
            end,
        })
        place(rawEl)

        local handle = { Object = rawEl.Object }
        function handle:Set(v, fire) rawEl:Set(v, fire) end
        handle.SetValue = handle.Set
        function handle:Get() return rawEl:Get() end
        setmetatable(handle, {
            __index = function(_, k)
                if k == "Value" then return rawEl:Get() end
            end,
        })

        if id then
            register(id, function() return rawEl:Get() end, function(v)
                v = tonumber(v)
                if v and rawEl:Get() ~= v then rawEl:Set(v, true) end
            end, math.clamp(def, min, max))
        end
        return handle
    end

    function api:AddInput(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local default = c.Default ~= nil and tostring(c.Default) or ""

        local rawEl = raw:Input({
            Title = c.Title,
            Desc = c.Content or c.Desc,
            Icon = c.Icon,
            Default = default,
            Placeholder = c.Placeholder,
            Callback = function(text)
                if id then ConfigData[id] = text end
                if userCb then userCb(text) end
            end,
        })
        place(rawEl)

        local handle = { Object = rawEl.Object }
        function handle:Set(v) rawEl:Set(v) end
        handle.SetValue = handle.Set
        function handle:Get() return rawEl:Get() end

        if id then
            register(id, function() return rawEl:Get() end, function(v)
                v = tostring(v)
                if rawEl:Get() ~= v then
                    rawEl:Set(v)
                    if id then ConfigData[id] = v end
                    if userCb then task.spawn(userCb, v) end
                end
            end, default)
        end
        return handle
    end

    function api:AddDropdown(c)
        c = c or {}
        local id = newId(c.Title)
        local userCb = c.Callback
        local multi = c.Multi and true or false
        local options = c.Options or c.Values or {}

        local default = c.Default
        if multi then
            if type(default) == "string" then
                default = (default ~= "") and { default } or {}
            elseif type(default) ~= "table" then
                default = {}
            end
        elseif default == "" then
            default = nil
        end

        local function toList(selected)
            local arr = {}
            for _, opt in ipairs(options) do
                if selected[opt] then table.insert(arr, opt) end
            end
            return arr
        end

        local rawEl = raw:Dropdown({
            Title = c.Title,
            Desc = c.Content or c.Desc,
            Icon = c.Icon,
            Values = options,
            Multi = multi,
            Default = default,
            Callback = function(sel)
                local v = multi and toList(sel) or sel
                if id then ConfigData[id] = v end
                if userCb then userCb(v) end
            end,
        })
        place(rawEl)

        local handle = { Object = rawEl.Object }
        function handle:Set(v) rawEl:Set(v) end
        handle.SetValue = handle.Set
        function handle:SetValues(list)
            options = list or {}
            rawEl:SetValues(options)
        end
        function handle:Get()
            local v = rawEl:Get()
            return multi and toList(v) or v
        end

        if id then
            register(id, function() return handle:Get() end, function(v)
                rawEl:Set(v)
                if id then ConfigData[id] = v end
                if userCb then task.spawn(userCb, v) end
            end, default)
        end
        return handle
    end

    return api
end

-- ---------- Window ----------
local executorName0 = "Unknown"
pcall(function() executorName0 = identifyexecutor() end)

local win = SerhiiUI:CreateWindow({
    Title = "RynerHUB",
    SubTitle = "Executor: " .. tostring(executorName0),
    Icon = LOGO_ID,
    IconSize = 28,
    OpenLogo = LOGO_ID,
    OpenLogoSize = 56,
    Size = isMobile and UDim2.fromOffset(520, 300) or UDim2.fromOffset(640, 440),
    SidebarWidth = isMobile and 130 or 168,
    KeySystem = KeyCfg, -- nil kalau key sudah valid -> kartu Key System dilewati
})

if win then
    Window = win
    Tabs = {
        Survivor  = makeApi(win:Tab({ Title = "Survivor", Icon = "sword" }), "Survivor", false),
        Killer    = makeApi(win:Tab({ Title = "Killer", Icon = "skull" }), "Killer", false),
        Exclusive = makeApi(win:Tab({ Title = "Exclusive", Icon = "star" }), "Exclusive", false),
        ESP       = makeApi(win:Tab({ Title = "Visual", Icon = "eye" }), "ESP", false), -- ESP diganti nama jadi Visual (scope config tetap "ESP")
        Utility   = makeApi(win:Tab({ Title = "Utility", Icon = "wrench" }), "Utility", false),
        Settings  = makeApi(win:Tab({ Title = "Settings", Icon = "settings" }), "Settings", false),
        Info      = makeApi(win:Tab({ Title = "Info", Icon = "user" }), "Info", false),
        Config    = makeApi(win:Tab({ Title = "Configuration", Icon = "save" }), "Configuration", true), -- paling akhir
    }
end

end -- UI block
if not Window then return end -- key tidak valid / kartu ditutup

-- =================================
-- VIRTUAL INPUT MANAGER (DENGAN FALLBACK)
-- =================================
local VIM = nil
local VirtualUser = nil

-- Coba dapatkan VirtualInputManager
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

-- Coba dapatkan VirtualUser sebagai fallback
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- Jika keduanya nil, beri peringatan
if not VIM and not VirtualUser then
    warn("[WARNING] Tidak ada VirtualInputManager atau VirtualUser! Fungsi input mungkin tidak berjalan.")
end

function GetRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function IsPlayerInLobby()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator"
end

-- =================================
-- ANTI AFK (AUTOMATION)
-- =================================
pcall(function()
    if getconnections then
        for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
            if connection.Disable then
                connection:Disable()
            end
        end
    end
    warn("Anti AFK Automatically Active...")
end)

-- =================================
-- VARIABLE AND FUNCS
-- =================================

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"]  = "Jeff Frenzy",
    ["78432063483146"]  = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"]  = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"]  = "Hidden S1",
    ["80411309607666"]  = "Abyssal S1"
}

local Config = {
    Surv_AutoParry = false,
    Surv_ParrySafety = false,
    Surv_ParryAggressive = false,
    Surv_ParryCircle = false,
    Surv_ParryRadius = 6,
    Surv_ParryFace = 1,
    Ignored_Skills_List = {},
}
local State = {
    ParryCooldown = false,
    ParryCooldownThread = nil,
    AutoParryAdornment = nil,
    lastParry = 0,
    ParryActive = false,
    ResetTimerThread = nil
}
local Attached = {}
local PARRY_DEBOUNCE = 0.2

local DynamicRadius = {
    Current = 6,
    Options = {6, 7},
    LastParryAttempt = 0,
    LastSuccessfulParry = 0
}

local lastRepairPoint = nil

local function AutoStopRepair()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local interact = char:FindFirstChild("CheckInterractable")
        if not interact then return end
        if interact:GetAttribute("isRepairing") ~= true then 
            lastRepairPoint = nil
            return 
        end
        
        local repairEvent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Generator"):FindFirstChild("RepairEvent")
        if repairEvent then
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in pairs(map:GetDescendants()) do
                    if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                        if obj:GetAttribute("IsRepairing") == true then
                            repairEvent:FireServer(obj, false)
                            lastRepairPoint = obj
                            print("[Auto] Stop repair")
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function SwitchRadius()
    local newRadius = (DynamicRadius.Current == 6) and 7 or 6
    DynamicRadius.Current = newRadius
    Config.Surv_ParryRadius = newRadius
    print("[Parry] Radius changed to:", newRadius)
end

function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end
function IsDowned(char) return char and (char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true) end
function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    local interactObj = char:FindFirstChild("CheckInterractable")
    if interactObj then
        if interactObj:GetAttribute("isVaulting") == true then return false end
        if interactObj:GetAttribute("isRepairing") == true then return false end
        if interactObj:GetAttribute("isUnhooking") == true then return false end
        if interactObj:GetAttribute("isHealing") == true then return false end
        if interactObj:GetAttribute("isSliding") == true then return false end
    end
    return true
end

local function GetParryButton()
    local current = PlayerGui
    for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function pressRightClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
end

local function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob and survivorMob:FindFirstChild("Controls") and survivorMob.Controls:FindFirstChild("Gui-mob")
    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        pressRightClick()
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end

    AutoStopRepair()
    task.wait(0.01)

    DynamicRadius.LastParryAttempt = tick()
    pcall(function()
        local parryRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

function ListenToParryResult()
    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:FindFirstChild("parryResult", 5)
        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                DynamicRadius.LastSuccessfulParry = tick()
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)

                -- ========== RESET TOGGLE PADA DETIK KE-10 ==========
                if State.ResetTimerThread then 
                    task.cancel(State.ResetTimerThread) 
                    State.ResetTimerThread = nil
                end
                State.ResetTimerThread = task.delay(10, function()
                    if Config.Surv_AutoParry then
                        Config.Surv_AutoParry = false
                        task.wait(0.1)
                        Config.Surv_AutoParry = true
                        print("[Parry] Reset toggle (OFF→ON) pada detik ke-10")
                    end
                    State.ResetTimerThread = nil
                end)
                -- ===================================================
            end)
        end
    end)
end
ListenToParryResult()

local function TriggerCrouch()
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")
        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then b = b:FindFirstChild(segment) end
        end
        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent
            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click)
                task.wait(2)
                firesignal(btn.MouseButton1Click)
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end
    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then Attached[kChar] = nil end
    end)
    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then
                    TriggerCrouch()
                end
            end
            return
        end
        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end
        if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end
        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude
        if Config.Surv_ParryAggressive then
            local aggressiveRadius = 12
            local detectionRadius = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > Config.Surv_ParryRadius then return end
            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                if kLookFlat:Dot(flatDirection) < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then
        AttachParrySensor(p.Character)
    end
end

function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)
task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end
    end
end)

-- Loop radius dinamis & safety otomatis
task.spawn(function()
    while true do
        task.wait(8)
        if not Config.Surv_AutoParry then continue end
        local now = tick()
        local attempt = DynamicRadius.LastParryAttempt
        local success = DynamicRadius.LastSuccessfulParry
        if attempt > 0 and (now - attempt) > 10 and (now - success) > 10 and not State.ParryCooldown then
            SwitchRadius()
            DynamicRadius.LastParryAttempt = now
            DynamicRadius.LastSuccessfulParry = now
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local char = LocalPlayer.Character
        if not char then
            if Config.Surv_AutoParry then
                Config.Surv_ParrySafety = false
                Config.Surv_ParryAggressive = false
            end
            continue
        end
        local interact = char:FindFirstChild("CheckInterractable")
        local isRepairing = interact and interact:GetAttribute("isRepairing") == true
        if Config.Surv_AutoParry then
            if isRepairing then
                Config.Surv_ParrySafety = false
                Config.Surv_ParryAggressive = true
            else
                Config.Surv_ParrySafety = true
                Config.Surv_ParryAggressive = true
            end
        else
            Config.Surv_ParrySafety = false
            Config.Surv_ParryAggressive = false
        end
    end
end)

local AutoGenEnabled = false
local KillerEscapeDist = 30
local AutoGenThread = nil 
local CurrentGen = nil
local CurrentPoint = nil
local LastFireTime = 0
local RepairEvent = ReplicatedStorage.Remotes.Generator.RepairEvent
 
local REPAIR_ANIM_ID = "rbxassetid://92960319113695"
local RepairAnimTrack = nil
 
local LastTPTime = 0
local StuckCheckCounter = 0
 
local KillerCache = {}
local KillerCacheTimer = 0
local function GetKillers()
    local now = tick()
    if now - KillerCacheTimer < 1 then return KillerCache end
    KillerCache = {}
    KillerCacheTimer = now
    for _, pl in pairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        if pl.Team and pl.Team.Name == "Killer" then
            table.insert(KillerCache, pl)
        end
    end
    return KillerCache
end
 
local GenCache = {}
local GenCacheTimer = 0
local function GetAllGenerators()
    local now = tick()
    if now - GenCacheTimer < 5 then return GenCache end
    GenCache = {}
    GenCacheTimer = now
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return GenCache end
    pcall(function()
        for _, v in pairs(mapFolder:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local isRealGen = v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil
                or v:GetAttribute("ProgressRepair") ~= nil
            if not isRealGen then continue end
            table.insert(GenCache, v)
        end
    end)
    return GenCache
end
 
local function PlayRepairAnim()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    if RepairAnimTrack and RepairAnimTrack.IsPlaying then return end
    pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = REPAIR_ANIM_ID
        RepairAnimTrack = animator:LoadAnimation(anim)
        RepairAnimTrack.Priority = Enum.AnimationPriority.Action
        RepairAnimTrack:Play()
    end)
end
 
local function StopRepairAnim()
    if RepairAnimTrack and RepairAnimTrack.IsPlaying then
        pcall(function() RepairAnimTrack:Stop() end)
    end
    RepairAnimTrack = nil
end
 
local function GetGeneratorPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                table.insert(points, obj)
            end
        end
    end)
    return points
end
 
local function IsGenDone(gen)
    local done = false
    pcall(function()
        local progress = gen:GetAttribute("RepairProgress") or gen:GetAttribute("ProgressRepair") or 0
        done = progress >= 100
    end)
    return done
end
 
local SCPCache = {}
local SCPCacheTimer = 0
 
local function GetSCPs()
    if tick() - SCPCacheTimer < 0.5 then return SCPCache end
        
        local newTargets = {}
        local mapFolder = workspace:FindFirstChild("Map")
        
        if mapFolder then
            for _, container in pairs(mapFolder:GetDescendants()) do
                if container:IsA("Model") then
                    local attributes = container:GetAttributes()
                    
                    if container:GetAttribute("CorpseCreated0492") or next(attributes) ~= nil then
                        local root = container:FindFirstChild("HumanoidRootPart")
                        if root then 
                            table.insert(newTargets, root) 
                        end
                    end
                end
            end
        end
        
        SCPCache = newTargets
        SCPCacheTimer = tick()
        return SCPCache
end
 
local function IsKillerNearby(position, radius)
    for _, pl in pairs(GetKillers()) do
        local char = pl.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - position).Magnitude <= radius then
            return true
        end
    end
    
    for _, model in pairs(GetSCPs()) do
        if model and model.Parent then
            local pos
            pcall(function() pos = model:GetPivot().Position end)
            if pos and (pos - position).Magnitude <= radius then
                return true
            end
        end
    end
    
    return false
end
 
local function IsPointOccupied(point)
    if not point or not point.Parent then return true end
    
    -- Check jika ada survivor lain yg repair di point ini
    local checkRadius = 5
    for _, pl in pairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        local char = pl.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - point.Position).Magnitude <= checkRadius then
            return true
        end
    end
    return false
end
 
local function GetBestGeneratorPoint(gen)
    local hrp = GetRoot()
    if not hrp then return nil end
    
    local points = GetGeneratorPoints(gen)
    if #points == 0 then return nil end
    
    -- Priority 1: Cari point kosong yang terdekat
    local bestEmptyPoint = nil
    local bestEmptyDist = math.huge
    
    for _, point in pairs(points) do
        if not IsPointOccupied(point) then
            local d = (hrp.Position - point.Position).Magnitude
            if d < bestEmptyDist then
                bestEmptyDist = d
                bestEmptyPoint = point
            end
        end
    end
    
    -- Kalo ada empty point, pake itu
    if bestEmptyPoint then return bestEmptyPoint end
    
    -- Priority 2: Fallback ke point terdekat (even if occupied)
    local bestPoint = nil
    local bestDist = math.huge
    for _, point in pairs(points) do
        local d = (hrp.Position - point.Position).Magnitude
        if d < bestDist then
            bestDist = d
            bestPoint = point
        end
    end
    
    return bestPoint
end
 
local function GetBestGenerator()
    local hrp = GetRoot()
    if not hrp then return nil end
    local gens = GetAllGenerators()
    local bestGen = nil
    local bestDist = math.huge
    for _, gen in pairs(gens) do
        if IsGenDone(gen) then continue end
        local pos
        pcall(function() pos = gen:GetPivot().Position end)
        if not pos then continue end
        if IsKillerNearby(pos, KillerEscapeDist) then continue end
        local dist = (hrp.Position - pos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestGen = gen
        end
    end
    return bestGen
end
 
local function TeleportToGen(gen)
    local hrp = GetRoot()
    if not hrp then return end
    
    local bestPoint = GetBestGeneratorPoint(gen)
    if bestPoint then
        CurrentPoint = bestPoint
        local offsetDir = (hrp.Position - bestPoint.Position).Unit
        local safePos = bestPoint.Position + offsetDir * 3 + Vector3.new(0, 1.5, 0)
        hrp.CFrame = CFrame.new(safePos)
        LastTPTime = tick()
        return
    end
    
    -- Fallback ke gen pivot kalo gak ada valid point
    local pos
    pcall(function() pos = gen:GetPivot().Position end)
    if pos then 
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        LastTPTime = tick()
    end
end
 
local function IsNearPoint(gen)
    local hrp = GetRoot()
    if not hrp then return false end
    
    -- Check apakah current point masih valid dan dekat
    if CurrentPoint and CurrentPoint.Parent == gen then
        local dist = (hrp.Position - CurrentPoint.Position).Magnitude
        
        -- Check apakah point sekarang occupied, jika iya don't proceed
        if IsPointOccupied(CurrentPoint) then
            StuckCheckCounter = StuckCheckCounter + 1
            -- Force TP ulang jika stuck (>3 loop tanpa gerakan)
            if StuckCheckCounter > 3 then
                CurrentPoint = nil
                return false
            end
            return false
        end
        
        if dist <= 5 then
            StuckCheckCounter = 0
            return true
        end
    end
    
    -- Scan semua point di generator dan cek mana yg bisa dipake
    local points = GetGeneratorPoints(gen)
    for _, point in pairs(points) do
        if not IsPointOccupied(point) then
            if (hrp.Position - point.Position).Magnitude <= 5 then
                CurrentPoint = point
                StuckCheckCounter = 0
                return true
            end
        end
    end
    
    -- Increment stuck counter
    StuckCheckCounter = StuckCheckCounter + 1
    return false
end
 
local function StopRepair()
    StopRepairAnim()
    if CurrentPoint then
        pcall(function() RepairEvent:FireServer(CurrentPoint, false) end)
    elseif CurrentGen then
        local points = GetGeneratorPoints(CurrentGen)
        for _, point in pairs(points) do
            pcall(function() RepairEvent:FireServer(point, false) end)
        end
    end
    CurrentGen = nil
    CurrentPoint = nil
    StuckCheckCounter = 0
    _G.ActualRepairPoint = nil
end
 
local function StartAutoGen()
    if AutoGenThread then task.cancel(AutoGenThread) end
    AutoGenThread = task.spawn(function()
        while AutoGenEnabled do
            if IsPlayerInLobby() then task.wait(0.5) continue end
            local hrp = GetRoot()
            if not hrp then task.wait(0.1) continue end
 
            if IsKillerNearby(hrp.Position, KillerEscapeDist) then
                if CurrentGen then
                    StopRepair()
                    CurrentGen = nil
                    CurrentPoint = nil
                end
                local safeGen = GetBestGenerator()
                if safeGen then TeleportToGen(safeGen) end
                task.wait(0.1)
                continue
            end
 
            local bestGen = GetBestGenerator()
            if not bestGen then task.wait(0.1) continue end
 
            if CurrentGen and CurrentGen ~= bestGen then
                StopRepair()
                CurrentGen = nil
                CurrentPoint = nil
            end
 
            if not IsNearPoint(bestGen) then
                -- Aggressive re-TP jika stuck lama
                if StuckCheckCounter > 5 then
                    CurrentPoint = nil
                    StuckCheckCounter = 0
                end
                TeleportToGen(bestGen)
                task.wait(0.15)
                continue
            end
 
            CurrentGen = bestGen
            local now = tick()
            if now - LastFireTime >= 0.5 then
                if CurrentPoint then
                    pcall(function()
                        RepairEvent:FireServer(CurrentPoint, true)
                        _G.ActualRepairPoint = CurrentPoint
                    end)
                    PlayRepairAnim()
                else
                    local bestPoint = GetBestGeneratorPoint(bestGen)
                    if bestPoint then 
                        CurrentPoint = bestPoint
                    end
                end
                LastFireTime = now
            end
            task.wait(0.1)
        end
    end)
end

-- [[ Survival Utility ]]
local NoFallEnabled = false
local FleeEnabled = false
local GodModeEnabled = false
local FleeDist = 40
local FleeThread = nil
local GodModeThread = nil

local function StartFlee()
    if FleeThread then task.cancel(FleeThread) end

    FleeThread = task.spawn(function()
        while FleeEnabled do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                local nearestKiller = nil
                local nearestDist = math.huge

                for _, player in pairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    local c = player.Character
                    if not c then continue end
                    local krp = c:FindFirstChild("HumanoidRootPart")
                    if not krp then continue end
                    local isKiller = player.Team and player.Team.Name == "Killer"
                    if not isKiller then continue end

                    local dist = (krp.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestKiller = krp
                    end
                end

                if nearestKiller and nearestDist <= FleeDist then
                    local fleeDir = (hrp.Position - nearestKiller.Position).Unit
                    local targetPos = hrp.Position + fleeDir * FleeDist

                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    
                    task.wait(0.5) 
                    continue
                end
            end

            task.wait(0.1)
        end
    end)
end

local function StartGodMode()
    if GodModeThread then task.cancel(GodModeThread) end

    GodModeThread = task.spawn(function()
        while GodModeEnabled do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            
            if hum then
                pcall(function()
                    if hum.Health < hum.MaxHealth and hum.Health > 0 then
                        hum.Health = hum.MaxHealth
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end

local SpeedBoostEnabled = false
local SpeedMoveConnection = nil
local SPEED = 30

local function StartSpeedBoost()
    if SpeedMoveConnection then SpeedMoveConnection:Disconnect() end

    local function UpdateVelocity()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or not SpeedBoostEnabled then return end

        local bv = hrp:FindFirstChild("SpeedBV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "SpeedBV"
            bv.MaxForce = Vector3.new(1e9, 0, 1e9)
            bv.P = 1e6
            bv.Parent = hrp
        end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir * SPEED
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
    end

    UpdateVelocity()

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        SpeedMoveConnection = hum:GetPropertyChangedSignal("MoveDirection"):Connect(UpdateVelocity)
    end
end
-- =================================
-- CONFIGURATION AND WINDOW UI
-- =================================
local executorName = (identifyexecutor and identifyexecutor() or "Unknown")
local isRonix = executorName:find("RonixExploit") ~= nil

_G.ConfigFolder = "RynerHUB_Violence/Config/"
local AutoloadFile = _G.ConfigFolder .. "Autoload.txt"
local ScriptLoaded = false
local IsLoadingConfig = false
-- (Window & Tabs sudah dibuat di bagian atas file dengan SerhiiUI)

----------------------------------------------------------------
-- INFO TAB
----------------------------------------------------------------
InfoSection = Tabs.Info:AddSection("Server", true)
InfoSection:AddButton({
    Title = "Return to Lobby",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Return To Lobby",
            Text = "Back...",
            Icon = "rbxassetid://110525773603905",
            Duration = 3
        })

        ReplicatedStorage.Remotes.Game.loadcharevent:FireServer()
    end
})
InfoSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rejoin Server",
            Text = "Rejoining server...",
            Icon = "rbxassetid://110525773603905",
            Duration = 3
        })

        task.delay(1, function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
})
InfoSection:AddButton({
    Title = "Server Hop",
    Callback = function()
        notif("Finding new server...", 1)
        
        local success, result = pcall(function()
            return game:HttpGet(string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", 
                game.PlaceId
            ))
        end)
        
        if success then
            local serverList = game:GetService("HttpService"):JSONDecode(result)
            
            if serverList and serverList.data then
                local servers = {}
                for _, server in ipairs(serverList.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server)
                    end
                end
                
                if #servers > 0 then
                    local randomServer = servers[math.random(1, #servers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, Players.LocalPlayer)
                else
                    notif("No available servers found!")
                end
            else
                notif("Failed to get server list!")
            end
        else
            notif("Error connecting to Roblox API!")
        end
    end
})
InfoSection:AddButton({
    Title = "Server Hop (Small Server)",
    Callback = function()
        notif("Searching for a small server...", 2)
        
        local success, result = pcall(function()
            return game:HttpGet(string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", 
                game.PlaceId
            ))
        end)
        
        if success then
            local serverList = game:GetService("HttpService"):JSONDecode(result)
            
            if serverList and serverList.data then
                local targetServer = nil
                
                for _, server in ipairs(serverList.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        if server.playing <= 5 then 
                            targetServer = server
                            break
                        end
                    end
                end
                
                if targetServer then
                    notif("Found server with " .. targetServer.playing .. " players!", 2)
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, targetServer.id, game.Players.LocalPlayer)
                else
                    notif("No small servers ( < 5 players) found!")
                end
            else
                notif("Failed to parse server list!")
            end
        else
            notif("API Error!")
        end
    end
})

-- RynerHUB: section Auto Parry AI di paling atas tab Exclusive (isinya diisi di blok Parry AI di bawah)
ParryAIExclusiveSection = Tabs.Exclusive:AddSection("Auto Parry AI", true)

-- RynerHUB: section Silent Aim ToF tepat di bawah Auto Parry AI (isinya diisi di blok Silent Aim ToF di bawah)
ToFExclusiveSection = Tabs.Exclusive:AddSection("Silent Aim Features")

InvisibleSection = Tabs.Exclusive:AddSection("Invisible")

    local Invisible = nil
    local invis_on = false
    local invisGui = nil
    local invisToggleRef = nil

    -- Urutan percobaan: API dari user dulu, GitHub lama sebagai cadangan
    local INVIS_URLS = {
        "https://leekguy.vercel.app/roblox/menghub/crack_obf_invisible_93978595733734.lua",
        "https://raw.githubusercontent.com/GrexXMeng/menghub-api/refs/heads/main/Invisibility",
    }
    local invisLoadReason = "belum dimuat"
    local invisLoading = false
    local invisWanted = false

    -- Muat script Invisible: coba sampai 3x, dan catat alasan kalau gagal.
    local function loadInvisible()
        if Invisible then return true end
        if invisLoading then
            local t0 = os.clock()
            while invisLoading and os.clock() - t0 < 15 do task.wait(0.2) end
            return Invisible ~= nil
        end
        invisLoading = true

        for attempt = 1, 3 do
            if _G.MengHub and _G.MengHub.Invisible then
                Invisible = _G.MengHub.Invisible
                break
            end

            local invisUrl = INVIS_URLS[((attempt - 1) % #INVIS_URLS) + 1]
            local okGet, body = pcall(function() return game:HttpGet(invisUrl) end)
            if not okGet or type(body) ~= "string" or #body < 20 then
                invisLoadReason = "gagal download: " .. tostring(body)
            elseif body:match("^%s*404") then
                invisLoadReason = "file 404 (link GitHub sudah tidak ada)"
            else
                local fn, cerr = loadstring(body)
                if not fn then
                    invisLoadReason = "gagal compile: " .. tostring(cerr)
                else
                    local okRun, rerr = pcall(fn)
                    if not okRun then
                        invisLoadReason = "error saat dijalankan: " .. tostring(rerr)
                    else
                        -- script remote bisa mengisi _G.MengHub.Invisible agak telat
                        local t0 = os.clock()
                        while os.clock() - t0 < 3 do
                            if _G.MengHub and _G.MengHub.Invisible then break end
                            task.wait(0.1)
                        end
                        if _G.MengHub and _G.MengHub.Invisible then
                            Invisible = _G.MengHub.Invisible
                            break
                        end
                        invisLoadReason = "script jalan tapi _G.MengHub.Invisible tidak dibuat"
                    end
                end
            end

            warn("[Invisible] percobaan " .. attempt .. "/3 gagal (" .. invisUrl .. "): " .. invisLoadReason)
            if attempt < 3 then task.wait(1.5) end
        end

        invisLoading = false
        if Invisible then
            print("[Invisible] script berhasil dimuat")
        end
        return Invisible ~= nil
    end

    task.spawn(loadInvisible)

    -- ===================== FALLBACK CLEANUP =====================
    local function forceCleanupInvisible()
        pcall(function()
            local chair = Workspace:FindFirstChild("invischair")
            if chair then chair:Destroy() end

            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        if part.Name ~= "Hurtbox"
                        and part.Name ~= "HumanoidRootPart"
                        and part.Name ~= "HRP_Clone" then
                            part.Transparency = 0
                        end
                    end
                end
            end
        end)
    end

    -- ===================== BUTTON UPDATER =====================
    local function updateInvisButton()
    if not invisGui then return end
    local btn = invisGui:FindFirstChild("InvisButton")
    if not btn then return end
    local stroke = btn:FindFirstChildOfClass("UIStroke")

    if invis_on then
        btn.Text = "INVISIBLE"
        btn.TextColor3 = Color3.fromRGB(192, 132, 252)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if stroke then
            stroke.Color = Color3.fromRGB(168, 85, 247)
            stroke.Thickness = 1.8
        end
    else
        btn.Text = "INVISIBLE"
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if stroke then
            stroke.Color = Color3.fromRGB(130, 130, 130)
            stroke.Thickness = 1.5
        end
    end
end

    -- ===================== STATE HANDLER =====================
    local function setInvisibleState(state, fromButton)
        if not Invisible then
            -- Mematikan saat belum dimuat = tidak ada yang perlu dilakukan (jangan spam notif)
            if state then
                notif("Invisible belum siap: " .. tostring(invisLoadReason), 4)
            end
            return
        end

        if invis_on == state then
            if not state then
                pcall(function() Invisible.disable() end)
                forceCleanupInvisible()
            end
            updateInvisButton()
            return
        end

        invis_on = state
        print("[Invisible] Setting state:", state, "| fromButton:", fromButton)

        if state then
            local ok, err = pcall(function() Invisible.enable() end)
            if not ok then
                warn("[Invisible] enable error: " .. tostring(err))
                forceCleanupInvisible()
            end
            if not fromButton then notif("Invisible Aktif!") end
        else
            pcall(function() Invisible.disable() end)
            forceCleanupInvisible()
            if not fromButton then notif("Invisible Nonaktif!") end
        end

        updateInvisButton()

        if invisToggleRef and fromButton then
            pcall(function() invisToggleRef:Set(state, false) end)
        end
    end

    -- ===================== CREATE MOBILE BUTTON =====================
    local function createInvisButton()
    local old = CoreGui:FindFirstChild("InvisButtonGui")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "InvisButtonGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local SIZE = 40
    local btn = Instance.new("TextButton")
    btn.Name = "InvisButton"
    btn.Size = UDim2.fromOffset(SIZE * 3, SIZE)
    btn.Position = UDim2.new(0.65, 0, 0.87, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.Text = "INVISIBLE"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = gui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(130, 130, 130)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local touchId, dragStart, startPos, hasMoved = nil, nil, nil, false
    local THRESHOLD = 8

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if touchId then return end
        touchId = input
        dragStart = input.Position
        startPos = btn.Position
        hasMoved = false
    end)

    btn.InputChanged:Connect(function(input)
        if input ~= touchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - dragStart
        if delta.Magnitude >= THRESHOLD then hasMoved = true end
        if hasMoved then
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input ~= touchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not hasMoved then
            setInvisibleState(not invis_on, true)
        end
        touchId = nil; dragStart = nil; startPos = nil; hasMoved = false
    end)

    invisGui = gui
    updateInvisButton()
end

    local function destroyInvisButton()
        if invisGui then
            invisGui:Destroy()
            invisGui = nil
        end
    end

    -- ===================== UI TOGGLE =====================
    InvisibleSection:AddParagraph({
    Title = "❗️BUKAN VISUAL❗️",
    Content = "Fitur ini benar-benar membuat karakter Anda tidak terlihat, bukan hanya visual."
    })
        
    invisToggleRef = InvisibleSection:AddToggle({
        Title = "Invisible",
        Default = false,
        Keybind = true,
        Callback = function(state)
            invisWanted = state

            -- Script belum termuat: muat dulu, baru aktifkan (bukan langsung "Not Ready")
            if state and not Invisible then
                notif("Invisible sedang dimuat...", 2)
                task.spawn(function()
                    if loadInvisible() then
                        if invisWanted then
                            setInvisibleState(true, false)
                            if isMobile then createInvisButton() end
                        end
                    else
                        notif("Invisible gagal dimuat: " .. tostring(invisLoadReason), 6)
                        invisWanted = false
                        if invisToggleRef then
                            pcall(function() invisToggleRef:Set(false, false) end)
                        end
                    end
                end)
                return
            end

            setInvisibleState(state, false)
            -- FIX: Sinkron tombol mobile dengan toggle UI
            if isMobile then
                if state and Invisible then
                    createInvisButton()
                elseif not state then
                    destroyInvisButton()
                end
            end
        end
    })

    if isMobile and invis_on then
        task.wait(0.5)
        createInvisButton()
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        if isMobile and invis_on and invisGui == nil then
            createInvisButton()
        end
    end)

;(function() -- RynerHUB: closure terpisah (batas 200 local)
MovementSection = Tabs.Exclusive:AddSection("Movement", true) -- section Movement: Moonwalk, Auto Dodge Crouch, Auto Run, Speed Boost   
local moonwalkEnabled = false
local moonwalkConn = nil
local moonwalkGui = nil

local MOONWALK_SIDE_SPEED = 0.9    -- kecepatan menyamping
local MOONWALK_BACK_SPEED = 1.2    -- kecepatan mundur
local MOONWALK_INTERVAL  = 0.07    -- interval pergantian arah

local function stopMoonwalk()
    if moonwalkConn then
        moonwalkConn:Disconnect()
        moonwalkConn = nil
    end
end

local function startMoonwalk()
    stopMoonwalk()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local lastSwitch = 0
    local direction = 1

    moonwalkConn = RunService.RenderStepped:Connect(function()
        if not moonwalkEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local cHrp = c:FindFirstChild("HumanoidRootPart")
        local cHum = c:FindFirstChildOfClass("Humanoid")
        if not cHrp or not cHum or cHum.Health <= 0 then return end

        local now = tick()
        if now - lastSwitch >= MOONWALK_INTERVAL then
            direction = direction * -1
            lastSwitch = now
        end

        local back = cHrp.CFrame.LookVector * -MOONWALK_BACK_SPEED
        local side = cHrp.CFrame.RightVector * (direction * MOONWALK_SIDE_SPEED)
        cHum:Move(back + side, false)
    end)
end

local function updateMobileGui()
    if not moonwalkGui then return end
    local btn = moonwalkGui:FindFirstChild("MoonButton")
    if not btn then return end
    local stroke = btn:FindFirstChildOfClass("UIStroke")

    if moonwalkEnabled then
        btn.Text = "MOONWALK"
        btn.TextColor3 = Color3.fromRGB(192, 132, 252)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if stroke then
            stroke.Color = Color3.fromRGB(168, 85, 247)
            stroke.Thickness = 1.8
        end
    else
        btn.Text = "MOONWALK"
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if stroke then
            stroke.Color = Color3.fromRGB(130, 130, 130)
            stroke.Thickness = 1.5
        end
    end
end

local function setMoonwalk(state)
    moonwalkEnabled = state
    if state then
        startMoonwalk()
    else
        stopMoonwalk()
    end
    pcall(updateMobileGui)
end

function toggleMoonwalk()
    setMoonwalk(not moonwalkEnabled)
end

-- ===== CREATE MOBILE GUI =====
local function createMobileGui()
    local old = CoreGui:FindFirstChild("MoonwalkCircleGui")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoonwalkCircleGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local SIZE = 40
    local btn = Instance.new("TextButton")
    btn.Name = "MoonButton"
    btn.Size = UDim2.fromOffset(SIZE * 3, SIZE)
    btn.Position = UDim2.new(0.65, 0, 0.80, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.Text = "MOONWALK"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = gui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(130, 130, 130)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local touchId, dragStart, startPos, hasMoved = nil, nil, nil, false
    local THRESHOLD = 8
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if touchId then return end
        touchId = input
        dragStart = input.Position
        startPos = btn.Position
        hasMoved = false
    end)
    btn.InputChanged:Connect(function(input)
        if input ~= touchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - dragStart
        if delta.Magnitude >= THRESHOLD then hasMoved = true end
        if hasMoved then
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input ~= touchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and
           input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not hasMoved then
            toggleMoonwalk()
        end
        touchId = nil; dragStart = nil; startPos = nil; hasMoved = false
    end)

    moonwalkGui = gui
    updateMobileGui()
end

local function destroyMobileGui()
    if moonwalkGui then
        moonwalkGui:Destroy()
        moonwalkGui = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if moonwalkEnabled then
        startMoonwalk()
    end
    if isMobile and moonwalkEnabled then
        createMobileGui()
    end
end)

-- ===== PC KEYBIND (F8) =====
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        toggleMoonwalk()
    end
end)

-- Inisialisasi GUI mobile saat awal (hanya kalau moonwalk ON)
if isMobile and moonwalkEnabled then
    task.wait(0.5)
    createMobileGui()
end

MovementSection:AddToggle({
    Title = "Moonwalk",
    Default = false,
    Keybind = true,
    Callback = function(v)
        if v then
            if isMobile then createMobileGui() end
            setMoonwalk(true)
        else
            setMoonwalk(false)
            if isMobile then destroyMobileGui() end
        end
    end
})

local AutoDodgeCrouch = false
local DodgeThread = nil
local currentAbyssalAnimationTrack = nil

local function isAbyssalwalkerSkillActive()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Team and player.Team.Name == "Killer" and player.Character then
            local killerHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if not killerHRP then continue end

            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            if distance > 25 then
                continue
            end

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and track.Animation.AnimationId == "rbxassetid://80411309607666" then
                            local timeLeft = track.Length - track.TimePosition
                            if timeLeft <= 1.5 then
                                currentAbyssalAnimationTrack = nil
                                return false
                            end
                            currentAbyssalAnimationTrack = track
                            return true
                        end
                    end
                end
            end
        end
    end

    currentAbyssalAnimationTrack = nil
    return false
end

local function getCrouchBtn()
    local b = LocalPlayer:FindFirstChild("PlayerGui")
    for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
        if b then b = b:FindFirstChild(segment) end
    end
    if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
        return b.Parent
    end
    return nil
end

local function fireCrouch(state)
    if isMobile then
        local btn = getCrouchBtn()
        if btn then
            pcall(function() firesignal(btn.MouseButton1Click) end)
        end
    else
        if state then
            VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        else
            VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end
end

local function StartAutoDodgeCrouch()
    if DodgeThread then return end

    DodgeThread = task.spawn(function()
        local isCrouching = false

        while AutoDodgeCrouch do
            local skillActive = isAbyssalwalkerSkillActive()

            if skillActive and not isCrouching then
                isCrouching = true
                fireCrouch(true)
            elseif not skillActive and isCrouching then
                isCrouching = false
                fireCrouch(false)
            end

            task.wait(0.05)
        end

        if isCrouching then
            fireCrouch(false)
        end
    end)
end

local function StopAutoDodgeCrouch()
    if DodgeThread then
        task.cancel(DodgeThread)
        DodgeThread = nil
    end
end

MovementSection:AddToggle({
    Title = "Auto Dodge Crouch",
    Default = false,
    Callback = function(v)
        AutoDodgeCrouch = v
        if v then
            StartAutoDodgeCrouch()
        else
            StopAutoDodgeCrouch()
        end
    end
})

-- ==================== AUTO RUN MOBILE (FIX CROUCH BUG) ====================
getgenv().AutoRunMobileEnabled = false
local AutoRunMobileThread = nil

local function GetMobileSprintButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local mob = pg:FindFirstChild("Survivor-mob")
    if not mob then return nil end
    local controls = mob:FindFirstChild("Controls")
    if not controls then return nil end
    local sprint = controls:FindFirstChild("sprint")
    if not sprint then return nil end

    if sprint:IsA("GuiButton") then return sprint end
    local icon = sprint:FindFirstChild("icon")
    if icon and icon:IsA("GuiButton") then return icon end
    if icon and icon.Parent and icon.Parent:IsA("GuiButton") then return icon.Parent end
    if sprint.Parent and sprint.Parent:IsA("GuiButton") then return sprint.Parent end
    return sprint
end

local function PressSprint()
    local btn = GetMobileSprintButton()
    if not btn then return false end
    pcall(function()
        if type(firesignal) == "function" then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            task.wait(0.04)
            firesignal(btn.MouseButton1Up)
        else
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local x = pos.X + size.X / 2 + inset.X
            local y = pos.Y + size.Y / 2 + inset.Y
            local id = 9901
            VIM:SendTouchEvent(id, 0, x, y)
            task.wait(0.04)
            VIM:SendTouchEvent(id, 2, x, y)
        end
    end)
    return true
end

local function IsMoving()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.MoveDirection.Magnitude > 0.12 then return true end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local v = hrp.AssemblyLinearVelocity
        local horizontal = Vector3.new(v.X, 0, v.Z).Magnitude
        if horizontal > 1.5 then return true end
    end
    return false
end

local function IsCrouching()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:GetAttribute("Crouching") == true
        or char:GetAttribute("Crouchingserver") == true
end

local function IsActuallySprinting()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:GetAttribute("Sprinting") == true
        or char:GetAttribute("IsRunning") == true
end

local function StartAutoRunMobile()
    if AutoRunMobileThread then return end

    AutoRunMobileThread = task.spawn(function()
        while getgenv().AutoRunMobileEnabled do
            local moving = IsMoving()
            local crouching = IsCrouching()
            local sprinting = IsActuallySprinting()

            if crouching then
                if sprinting then PressSprint() end
            else
                if moving and not sprinting then
                    PressSprint()
                elseif not moving and sprinting then
                    PressSprint()
                end
            end

            task.wait(0.12)
        end

        if IsActuallySprinting() then PressSprint() end
        AutoRunMobileThread = nil
    end)
end

local function StopAutoRunMobile()
    getgenv().AutoRunMobileEnabled = false
end

-- ===== UI TOGGLE =====
MovementSection:AddToggle({
    Title = "Auto Run [Mobile]",
    Content = "Otomatis sprint saat gerak (fix bug crouch)",
    Default = false,
    Keybind = true,
    Callback = function(v)
        getgenv().AutoRunMobileEnabled = v
        if v then
            StartAutoRunMobile()
            notif("Auto Run Mobile: ON")
        else
            StopAutoRunMobile()
            notif("Auto Run Mobile: OFF")
        end
    end
})

-- Auto restart saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if getgenv().AutoRunMobileEnabled then
        AutoRunMobileThread = nil
        StartAutoRunMobile()
    end
end)

MovementSection:AddToggle({
    Title = "Auto Run [PC]",
    Default = false,
    Callback = function(v)
        getgenv().AutoRunEnabled = v
        if v then
            task.spawn(function()
                while getgenv().AutoRunEnabled do
                    VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, LocalPlayer:GetMouse())
                    task.wait(0.1)
                end
            end)
        else
            VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, LocalPlayer:GetMouse())
        end
    end
})
MovementSection:AddToggle({
    Title = "Speed Boost",
    Default = false,
    Keybind = true,
    Callback = function(state)
        SpeedBoostEnabled = state
        notif("Speedboost ".. (state and "Aktif" or "Nonaktif"))

        if state then
            StartSpeedBoost()
        else
            if SpeedMoveConnection then 
                SpeedMoveConnection:Disconnect() 
                SpeedMoveConnection = nil
            end
            
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum then hum.WalkSpeed = 16 end
                if hrp then
                    local bv = hrp:FindFirstChild("SpeedBV")
                    if bv then bv:Destroy() end
                end
            end
        end
    end
})

    local mapPredictEnabled = false
    local mapPredictGui = nil
    local mapPredictThread = nil

    local function cleanMapGui()
        if mapPredictGui then
            mapPredictGui:Destroy()
            mapPredictGui = nil
        end
    end

    local function buildMapGui()
        cleanMapGui()
        local gui = Instance.new("ScreenGui")
        gui.Name = "MapPredictUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = CoreGui

        local frame = Instance.new("Frame", gui)
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 165, 0, 40)
        frame.Position = UDim2.new(0.5, 0, 0, 110)
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        frame.BackgroundTransparency = 0.35
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(168, 85, 247)
        stroke.Thickness = 1.8
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local mapLabel = Instance.new("TextLabel", frame)
        mapLabel.Name = "MapName"
        mapLabel.Size = UDim2.new(1, 0, 0, 16)
        mapLabel.Position = UDim2.new(0, 0, 0, 4)
        mapLabel.Text = "Map: Scanning..."
        mapLabel.Font = Enum.Font.GothamBold
        mapLabel.TextSize = 11
        mapLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
        mapLabel.BackgroundTransparency = 1
        mapLabel.TextXAlignment = Enum.TextXAlignment.Center
        mapLabel.RichText = true

        local statusLabel = Instance.new("TextLabel", frame)
        statusLabel.Name = "MapStatus"
        statusLabel.Size = UDim2.new(1, 0, 0, 14)
        statusLabel.Position = UDim2.new(0, 0, 0, 21)
        statusLabel.Text = "Status: —"
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 9.5
        statusLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center

        mapPredictGui = gui
        return gui
    end
    

    local function detectMap()
        local map = workspace:FindFirstChild("Map")
        if not map then return nil end

        if map:FindFirstChild("random shakes") or map:FindFirstChild("SCP-173 Room") or map:FindFirstChild("SCP-205 Room") then
            return "Site 68"
        elseif map:FindFirstChild("HooksMeat") then
            return "BLOODBATH! Club"
        elseif map:FindFirstChild("Gate") and map.Gate:FindFirstChild("vfx") then
            return "Firelink Shrine"
        elseif map:FindFirstChild("Bldg_Addon_RooftopUnit_A") or map:FindFirstChild("Rooftop") then
            return "Mercy Hospital Rooftop"
        elseif map:FindFirstChild("White Armored Car") then
            return "Mount Massive Asylum"
        elseif map:FindFirstChild("Dumbster") then
            return "The Bay Harbor"
        elseif map:FindFirstChild("water pump") then
            return "Valdelobos Village"
        elseif map:FindFirstChild("LargeBoulder01") then
            return "Woodview Cabin"
        end
        return nil
    end

    PredictPerkSection = Tabs.ESP:AddSection("Predict And Info", true)

    PredictPerkSection:AddToggle({
        Title = "Next Map Prediction",
        Default = false,
        Callback = function(state)
            mapPredictEnabled = state
            if mapPredictThread then
                task.cancel(mapPredictThread)
                mapPredictThread = nil
            end
            if not state then
                cleanMapGui()
                return
            end
            mapPredictThread = task.spawn(function()
                local lastMap = nil
                local lastMapExists = false
                while mapPredictEnabled do
                    local gui = buildMapGui()
                    local mainFrame = gui and gui:FindFirstChild("MainFrame")
                    local isSpectator = (LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator") or false
                    if gui then gui.Enabled = isSpectator end

                    if isSpectator and mainFrame then
                        local map = workspace:FindFirstChild("Map")
                        local mapExists = map ~= nil
                        local detectedMap = detectMap()

                        if lastMapExists and not mapExists then
                            mainFrame.MapName.Text = "Map: " .. (lastMap or "Unknown")
                            mainFrame.MapStatus.Text = "Status: Setting up..."
                            mainFrame.MapStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
                        elseif mapExists and detectedMap then
                            lastMap = detectedMap
                            mainFrame.MapName.Text = "Map: " .. detectedMap
                            mainFrame.MapStatus.Text = "Status: Lobby"
                            mainFrame.MapStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                        elseif mapExists and not detectedMap then
                            mainFrame.MapName.Text = "Map: Unknown"
                            mainFrame.MapStatus.Text = "Status: Lobby"
                            mainFrame.MapStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                        else
                            mainFrame.MapName.Text = "Map: —"
                            mainFrame.MapStatus.Text = "Status: Lobby"
                            mainFrame.MapStatus.TextColor3 = Color3.fromRGB(160, 160, 160)
                        end
                        lastMapExists = mapExists
                    end
                    task.wait(0.5)
                end
                cleanMapGui()
            end)
        end
    })

    local killerPerksEnabled = false
    local killerPerksGui = nil
    local killerPerksMinimized = false

    local function buildKillerPerksGUI()
    if killerPerksGui then
        killerPerksGui:Destroy()
        killerPerksGui = nil
    end
    if not killerPerksEnabled then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "KillerPerksUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui

    -- ===== Main Frame (LEBIH KECIL) =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainBox"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.Position = UDim2.new(0.18, 0, 0.30, 0)
    mainFrame.Size = UDim2.new(0, 160, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = sg
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 5)

    -- ===== Top Bar Ungu =====
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 90, 180)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 5)
    local topBarFix = Instance.new("Frame", topBar)
    topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    topBarFix.BackgroundColor3 = Color3.fromRGB(30, 90, 180)
    topBarFix.BorderSizePixel = 0

    -- ===== Header =====
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 14)
    header.Position = UDim2.new(0, 0, 0, 3)
    header.BackgroundTransparency = 1
    header.Active = true

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -18, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Killer Perks"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.TextSize = 9
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = header

    local minimizeBtn = Instance.new("TextButton", header)
    minimizeBtn.Size = UDim2.new(0, 14, 0, 14)
    minimizeBtn.Position = UDim2.new(1, -15, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 11
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header

    -- ===== Divider =====
    local divider = Instance.new("Frame", mainFrame)
    divider.Size = UDim2.new(1, -10, 0, 1)
    divider.Position = UDim2.new(0, 5, 0, 18)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    divider.BorderSizePixel = 0

    -- ===== TAB BAR =====
    local tabBar = Instance.new("Frame", mainFrame)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -10, 0, 16)
    tabBar.Position = UDim2.new(0, 5, 0, 21)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabBar.BorderSizePixel = 0
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 3)

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- ===== Page Container =====
    local pageContainer = Instance.new("Frame", mainFrame)
    pageContainer.Name = "PageContainer"
    pageContainer.Size = UDim2.new(1, -10, 1, -60)
    pageContainer.Position = UDim2.new(0, 5, 0, 40)
    pageContainer.BackgroundTransparency = 1
    pageContainer.ClipsDescendants = true

    -- ===== Tab: Perks =====
    local pagePerks = Instance.new("Frame", pageContainer)
    pagePerks.Name = "PagePerks"
    pagePerks.Size = UDim2.new(1, 0, 1, 0)
    pagePerks.BackgroundTransparency = 1

    local perksLayout = Instance.new("UIListLayout", pagePerks)
    perksLayout.Padding = UDim.new(0, 2)
    perksLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- ===== Tab: Info =====
    local pageInfo = Instance.new("Frame", pageContainer)
    pageInfo.Name = "PageInfo"
    pageInfo.Size = UDim2.new(1, 0, 1, 0)
    pageInfo.BackgroundTransparency = 1
    pageInfo.Visible = false

    local infoLayout = Instance.new("UIListLayout", pageInfo)
    infoLayout.Padding = UDim.new(0, 2)
    infoLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local killerNameLabel = Instance.new("TextLabel", pageInfo)
    killerNameLabel.Size = UDim2.new(1, 0, 0, 12)
    killerNameLabel.BackgroundTransparency = 1
    killerNameLabel.Font = Enum.Font.GothamBold
    killerNameLabel.Text = "Killer: ???"
    killerNameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    killerNameLabel.TextSize = 9
    killerNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    killerNameLabel.LayoutOrder = 1

    local perkCountLabel = Instance.new("TextLabel", pageInfo)
    perkCountLabel.Size = UDim2.new(1, 0, 0, 11)
    perkCountLabel.BackgroundTransparency = 1
    perkCountLabel.Font = Enum.Font.Gotham
    perkCountLabel.Text = "Perks: 0"
    perkCountLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    perkCountLabel.TextSize = 9
    perkCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    perkCountLabel.LayoutOrder = 2

    local statusLabel = Instance.new("TextLabel", pageInfo)
    statusLabel.Size = UDim2.new(1, 0, 0, 11)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: Scanning..."
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.LayoutOrder = 3

    -- ===== Helper funcs =====
    local function getKillerPlayer()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Team and pl.Team.Name == "Killer" then 
                return pl 
            end
        end
        return nil
    end

    local function readPerksFromWorkspace(char)
        if not char then return {} end
        local result, seen = {}, {}
        for _, child in ipairs(char:GetDescendants()) do
            local name = tostring(child.Name)
            local perkName, level = name:match("^(.+)%s+(%d+)$")
            if perkName then
                perkName = perkName:gsub("^%s+", ""):gsub("%s+$", "")
                if perkName ~= "" and not seen[perkName] then
                    seen[perkName] = true
                    table.insert(result, {Name = perkName, Level = level})
                end
            end
        end
        table.sort(result, function(a, b) return a.Name < b.Name end)
        return result
    end

    -- ===== Tab Setup =====
    local tabPages = {
        ["Perks"] = pagePerks,
        ["Info"]  = pageInfo,
    }
    local tabBtns = {}

    for i, tabName in ipairs({"Perks", "Info"}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -2, 1, -3)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BorderSizePixel = 0
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)
        tabBtns[tabName] = btn
    end

    local function switchTab(active)
        for name, btn in pairs(tabBtns) do
            if name == active then
                btn.BackgroundColor3 = Color3.fromRGB(30, 90, 180)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            tabPages[name].Visible = (name == active)
        end
    end

    for name, btn in pairs(tabBtns) do
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    switchTab("Perks")

    -- ===== Expand / Minimize =====
    local isExpanded = true
    local FULL_H = 100
    local MIN_H = 20

    local function setExpanded(state)
        isExpanded = state
        if state then
            mainFrame.Size = UDim2.new(0, 160, 0, FULL_H)
            divider.Visible = true
            tabBar.Visible = true
            pageContainer.Visible = true
            minimizeBtn.Text = "−"
        else
            mainFrame.Size = UDim2.new(0, 160, 0, MIN_H)
            divider.Visible = false
            tabBar.Visible = false
            pageContainer.Visible = false
            minimizeBtn.Text = "+"
        end
    end

    minimizeBtn.MouseButton1Click:Connect(function()
        setExpanded(not isExpanded)
    end)

    -- ===== Drag handler =====
    local dragging, dragStart, startPos = false, nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)

    setExpanded(true)
    killerPerksGui = sg

    -- ===== Update loop =====
    local perkLabels = {}
    task.spawn(function()
        while killerPerksEnabled and killerPerksGui do
            local killer = getKillerPlayer()
            local killerName = killer and (killer.DisplayName or killer.Name) or "Unknown"
            killerNameLabel.Text = "Killer: " .. killerName

            local perks = {}
            if killer and killer.Character then
                perks = readPerksFromWorkspace(killer.Character)
            end

            perkCountLabel.Text = "Perks: " .. #perks

            if #perks > 0 then
                statusLabel.Text = "Status: Active"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                statusLabel.Text = "Status: Scanning..."
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            end

            local displayPerks = {}
            for i = 1, math.min(#perks, 4) do
                table.insert(displayPerks, perks[i])
            end

            for i = 1, #displayPerks do
                if not perkLabels[i] then
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 0, 11)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
                    lbl.TextSize = 9
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.LayoutOrder = i
                    lbl.Parent = pagePerks
                    perkLabels[i] = lbl
                end
                local p = displayPerks[i]
                local lvlText = p.Level and (" lvl " .. p.Level) or ""
                perkLabels[i].Text = "• " .. p.Name .. lvlText
                perkLabels[i].Visible = true
            end
            for i = #displayPerks + 1, #perkLabels do
                perkLabels[i].Visible = false
            end

            if #displayPerks == 0 then
                if not perkLabels[1] then
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 0, 11)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.TextColor3 = Color3.fromRGB(140, 140, 150)
                    lbl.TextSize = 9
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = pagePerks
                    perkLabels[1] = lbl
                end
                perkLabels[1].Text = "Waiting for perks..."
                perkLabels[1].Visible = true
            end

            task.wait(1)
        end
    end)
end

    PredictPerkSection:AddToggle({
        Title = "Killer Perks Display",
        Default = false,
        Callback = function(state)
            killerPerksEnabled = state
            if state then
                buildKillerPerksGUI()
            else
                if killerPerksGui then
                    killerPerksGui:Destroy()
                    killerPerksGui = nil
                end
            end
        end
    })
    
    local spectatorEnabled = false
    local spectatorGui = nil
    local spectatorLabel = nil
    local spectatorThread = nil
    local spectatorExpanded = true
    local spectatorMainFrame = nil

    local function createSpectatorUI()
        if spectatorGui then
            spectatorGui:Destroy()
            spectatorGui = nil
        end

        spectatorGui = Instance.new("ScreenGui")
        spectatorGui.Name = "SpectatorCounter"
        spectatorGui.ResetOnSpawn = false
        spectatorGui.IgnoreGuiInset = true
        spectatorGui.Parent = CoreGui

        -- ===== Main Frame =====
        local mainFrame = Instance.new("Frame", spectatorGui)
        mainFrame.Name = "MainBox"
        mainFrame.AnchorPoint = Vector2.new(0.5, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.42, 0)
        mainFrame.Size = UDim2.new(0, 145, 0, 52)
        mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        spectatorMainFrame = mainFrame

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

        -- ===== Top Bar Biru Tua =====
        local topBar = Instance.new("Frame", mainFrame)
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 4)
        topBar.Position = UDim2.new(0, 0, 0, 0)
        topBar.BackgroundColor3 = Color3.fromRGB(30, 90, 180)
        topBar.BorderSizePixel = 0
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)

        local topBarFix = Instance.new("Frame", topBar)
        topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
        topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
        topBarFix.BackgroundColor3 = Color3.fromRGB(30, 90, 180)
        topBarFix.BorderSizePixel = 0

        -- ===== Header =====
        local header = Instance.new("Frame", mainFrame)
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 18)
        header.Position = UDim2.new(0, 0, 0, 4)
        header.BackgroundTransparency = 1
        header.Active = true

        local title = Instance.new("TextLabel", header)
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = "Spectators"
        title.TextColor3 = Color3.fromRGB(230, 230, 230)
        title.TextSize = 10
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = header

        local minimizeBtn = Instance.new("TextButton", header)
        minimizeBtn.Name = "MinimizeBtn"
        minimizeBtn.Size = UDim2.new(0, 18, 0, 18)
        minimizeBtn.Position = UDim2.new(1, -19, 0, 0)
        minimizeBtn.BackgroundTransparency = 1
        minimizeBtn.Text = "−"
        minimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.TextSize = 13
        minimizeBtn.AutoButtonColor = false
        minimizeBtn.Parent = header

        -- ===== Separator =====
        local divider = Instance.new("Frame", mainFrame)
        divider.Name = "Divider"
        divider.Size = UDim2.new(1, -12, 0, 1)
        divider.Position = UDim2.new(0, 6, 0, 23)
        divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        divider.BorderSizePixel = 0

        -- ===== Body =====
        local body = Instance.new("Frame", mainFrame)
        body.Name = "Body"
        body.Size = UDim2.new(1, 0, 1, -25)
        body.Position = UDim2.new(0, 0, 0, 25)
        body.BackgroundTransparency = 1
        body.ClipsDescendants = true

        local bodyLayout = Instance.new("UIListLayout", body)
        bodyLayout.FillDirection = Enum.FillDirection.Horizontal
        bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        bodyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        bodyLayout.Padding = UDim.new(0, 5)

        -- 👁 Eye Icon — PUTIH, di depan
        local eye = Instance.new("ImageLabel", body)
        eye.Name = "EyeIcon"
        eye.Size = UDim2.new(0, 13, 0, 13)
        eye.BackgroundTransparency = 1
        eye.Image = "rbxassetid://13321848320"
        eye.ImageColor3 = Color3.fromRGB(255, 255, 255)
        eye.LayoutOrder = 1

        spectatorLabel = Instance.new("TextLabel", body)
        spectatorLabel.Name = "CountLabel"
        spectatorLabel.BackgroundTransparency = 1
        spectatorLabel.Font = Enum.Font.GothamMedium
        spectatorLabel.Text = "No spectators"
        spectatorLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        spectatorLabel.TextSize = 10
        spectatorLabel.AutomaticSize = Enum.AutomaticSize.X
        spectatorLabel.LayoutOrder = 2

        -- ===== Toggle minimize =====
        local function setExpanded(state)
            spectatorExpanded = state
            if state then
                mainFrame.Size = UDim2.new(0, 145, 0, 52)
                divider.Visible = true
                body.Visible = true
                minimizeBtn.Text = "−"
            else
                mainFrame.Size = UDim2.new(0, 145, 0, 22)
                divider.Visible = false
                body.Visible = false
                minimizeBtn.Text = "+"
            end
        end

        minimizeBtn.MouseButton1Click:Connect(function()
            setExpanded(not spectatorExpanded)
        end)

        spectatorExpanded = true
        setExpanded(true)

        -- ===== DRAG HANDLER =====
        local dragging, dragStart, startPos = false, nil, nil

        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                dragStart = nil
                startPos = nil
            end
        end)
    end

    local function updateSpectatorCount()
        if not spectatorEnabled or not spectatorLabel then return end
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Team and p.Team.Name == "Spectator" then
                count = count + 1
            end
        end

        if count == 0 then
            spectatorLabel.Text = "No spectators"
            spectatorLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        else
            spectatorLabel.Text = count .. " spectators"
            spectatorLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        end
    end

    PredictPerkSection:AddToggle({
        Title = "Spectator Counter",
        Default = false,
        Callback = function(state)
            spectatorEnabled = state
            if spectatorThread then
                task.cancel(spectatorThread)
                spectatorThread = nil
            end
            if state then
                createSpectatorUI()
                updateSpectatorCount()
                spectatorThread = task.spawn(function()
                    while spectatorEnabled do
                        updateSpectatorCount()
                        task.wait(1.2)
                    end
                end)
            else
                if spectatorGui then
                    spectatorGui:Destroy()
                    spectatorGui = nil
                    spectatorLabel = nil
                    spectatorMainFrame = nil
                end
            end
        end
    })
end)()

do
local AutoParrySection = Tabs.Survivor:AddSection("Auto Parry")

Config = Config or {}
Config.Surv_AutoParry       = false      -- master toggle
Config.Surv_ParrySafety     = false      -- cegah parry saat sibuk (vault, repair, dll)
Config.Surv_ParryAggressive = false      -- parry tanpa peduli arah hadap killer
Config.Surv_ParryCircle     = false      -- tampilkan lingkaran ESP radius (default mati, ikut toggle Radius Parry)
Config.Surv_ParryRadius     = 6          -- jarak maksimum parry (sama dengan default input Radius Parry)
Config.Surv_ParryFace       = 0.7        -- sensitivitas arah hadap (0–1)
Config.Ignored_Skills_List  = {}         -- daftar skill yang diabaikan (contoh: "Hidden S1")


State = State or {}
State.ParryCooldown   = false
State.ParryCooldownThread = nil
State.AutoParryAdornment = nil  -- untuk circle ESP


local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"]  = "Jeff Frenzy",
    ["78432063483146"]  = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"]  = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"]  = "Hidden S1",
    ["80411309607666"]  = "Abyssal S1"
}

-- 4. PENGECEKAN KEAMANAN (tidak parry saat sedang melakukan aksi lain)
function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end

    -- Cek attribute di karakter (hook, pallet, vault, dll)
    if char:GetAttribute("IsHooked") == true then return false end
    if char:GetAttribute("IsCarried") == true then return false end
    if char:GetAttribute("IsStunned") == true then return false end
    if char:GetAttribute("Immobile") == true then return false end
    if char:GetAttribute("MovementLocked") == true then return false end
    if char:GetAttribute("Knocked") == true then return false end
    if char:GetAttribute("Crouching") == true then return false end
    if char:GetAttribute("IsVaulting") == true then return false end
    if char:GetAttribute("IsPalletStunned") == true then return false end

    -- Cek attribute di CheckInterractable
    local interactObj = char:FindFirstChild("CheckInterractable")
    if interactObj then
        if interactObj:GetAttribute("isVaulting")    == true then return false end
        if interactObj:GetAttribute("isRepairing")   == true then return false end
        if interactObj:GetAttribute("isUnhooking")   == true then return false end
        if interactObj:GetAttribute("isHealing")     == true then return false end
        if interactObj:GetAttribute("isSliding")     == true then return false end
        if interactObj:GetAttribute("isPalletVault") == true then return false end
        if interactObj:GetAttribute("isPalletDrop")  == true then return false end
    end

    -- Cek Humanoid state
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Climbing
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.PlatformStanding then
            return false
        end
    end

    return true
end

-- 5. EKSEKUSI PARRY (menekan tombol parry)
function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob
        and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")

    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        -- fallback untuk PC / executor lain
        pcall(function()
            if mouse2click then
                mouse2click()
                return
            end
            if mouse2press and mouse2release then
                mouse2press()
                task.wait(0.01)
                mouse2release()
                return
            end
            if MouseButton2Click then
                MouseButton2Click()
                return
            end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = game:GetService("ReplicatedStorage")
            :FindFirstChild("Remotes")
            :FindFirstChild("Items")
            :FindFirstChild("Parrying Dagger")
            :FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

-- 6. COOLDOWN (mendengarkan hasil parry dari server)
function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)

        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end)
        end
    end)
end
ListenToParryResult()

-- 7. SENSOR PARRY – dipasang ke setiap karakter killer
local Attached = {}  -- agar tidak double attach

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true

    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end

    -- Re-attach jika Animator diganti
    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)

    -- Bersihkan jika karakter dihapus
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end)

    -- Deteksi animasi serangan
    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end

        -- Fitur khusus: Auto Crouch untuk Abyssal S1 (bukan parry)
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then
                    TriggerCrouch() -- fungsi crouch (ada di script utama)
                end
            end
            return
        end

        -- Jika Auto Parry mati / cooldown / skill diabaikan
        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end
        if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end

        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end

        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if Config.Surv_ParryAggressive then
            -- Mode agresif: parry langsung jika dalam radius kecil, atau lacak sampai masuk radius
            local aggressiveRadius = 12
            local detectionRadius = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end

            if startDistance <= aggressiveRadius then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            -- Mode normal: cek jarak dan arah hadap
            if startDistance > Config.Surv_ParryRadius then return end

            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

-- 8. FUNGSI UNTUK MENEMPELKAN SENSOR KE KILLER
function TryAttach(p)
    if p ~= player and IsKiller(p) and p.Character then
        AttachParrySensor(p.Character)
    end
end

function SetupPlayer(p)
    if p == player then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

-- Pasang ke semua pemain yang sudah ada
for _, p in pairs(Players:GetPlayers()) do
    SetupPlayer(p)
end
Players.PlayerAdded:Connect(SetupPlayer)

-- Loop periodik untuk memastikan sensor tetap terpasang
task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do
            TryAttach(p)
        end
    end
end)

-- 9. ESP CIRCLE (visual radius parry)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Buat/update lingkaran
    if Config.Surv_ParryCircle and Config.Surv_AutoParry and hrp then
        if not State.AutoParryAdornment or State.AutoParryAdornment.Parent ~= hrp then
            if State.AutoParryAdornment then State.AutoParryAdornment:Destroy() end
            State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
            State.AutoParryAdornment.Name = "AutoParryCircleESP"
            State.AutoParryAdornment.Height = 0.05
            State.AutoParryAdornment.Transparency = 0.3
            State.AutoParryAdornment.Adornee = hrp
            State.AutoParryAdornment.Parent = hrp
            State.AutoParryAdornment.ZIndex = 0
            State.AutoParryAdornment.AlwaysOnTop = false
        end
        local cR = Config.Surv_ParryRadius
        State.AutoParryAdornment.Radius = cR
        State.AutoParryAdornment.InnerRadius = math.max(0.1, cR - 0.15)
        -- PENTING: ubah offset Y jika lingkaran tidak terlihat (misal -1)
        State.AutoParryAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
        if State.ParryCooldown then
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 128, 0)   -- oranye
        elseif Config.Surv_ParryAggressive then
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0)     -- merah
        else
            State.AutoParryAdornment.Color3 = Color3.fromRGB(0, 255, 255)   -- cyan
        end
    elseif State.AutoParryAdornment then
        State.AutoParryAdornment:Destroy()
        State.AutoParryAdornment = nil
    end
end)

-- 10. CUSTOM GUI UNTUK AUTO PARRY (opsional)
local AutoParryCustom = {
    Gui = nil,
    IsActive = false,
    GuiVisible = false,
}

function UpdateCustomParryGUI(isOn)
    if not AutoParryCustom.Gui then return end
    local frame = AutoParryCustom.Gui:FindFirstChild("Frame")
    if not frame then return end
    local btn = frame:FindFirstChild("ActionButton")
    local stroke = frame:FindFirstChild("UIStroke")
    if isOn then
        if btn then
            btn.Text = "PARRY [ON]"
            btn.TextColor3 = Color3.fromRGB(180, 255, 180)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        if stroke then stroke.Color = Color3.fromRGB(100, 200, 100) end
    else
        if btn then
            btn.Text = "PARRY [OFF]"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
        if stroke then stroke.Color = Color3.fromRGB(90, 90, 95) end
    end
end

function ToggleParryStatus()
    Config.Surv_AutoParry = not Config.Surv_AutoParry
    AutoParryCustom.IsActive = Config.Surv_AutoParry
    UpdateCustomParryGUI(Config.Surv_AutoParry)
    -- sync dengan UI Library jika ada
    pcall(function()
        if Toggles and Toggles.AutoParryKey then Toggles.AutoParryKey:SetValue(Config.Surv_AutoParry) end
    end)
    pcall(function()
        if Toggles and Toggles.AutoParry then Toggles.AutoParry:SetValue(Config.Surv_AutoParry) end
    end)
    Library:Notify({ Title = "Auto Parry", Description = Config.Surv_AutoParry and "Aktif" or "Nonaktif", Time = 2 })
end

function CreateCustomParryGUI()
    if AutoParryCustom.Gui then
        AutoParryCustom.Gui:Destroy()
        AutoParryCustom.Gui = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoParryCustomGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    gui.Enabled = false
    AutoParryCustom.Gui = gui
    AutoParryCustom.GuiVisible = false

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = gui
    frame.Size = UDim2.fromOffset(110, 36)
    frame.Position = UDim2.fromScale(0.85, 0.35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Name = "UIStroke"
    stroke.Parent = frame
    stroke.Color = Color3.fromRGB(90, 90, 95)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2

    local button = Instance.new("TextButton")
    button.Name = "ActionButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Text = "PARRY [OFF]"
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    -- drag & drop (sama seperti di script asli)
    local dragging, dragMoved, canDrag = false, false, false
    local dragStart, startPos, holdThread = nil, nil, nil
    local DRAG_THRESHOLD, HOLD_TIME = 18, 0.18

    local function update(input)
        if not dragging or not canDrag or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        if not dragMoved and (math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD) then
            dragMoved = true
        end
        if dragMoved then
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragMoved = false
            canDrag = false
            dragStart = input.Position
            startPos = frame.Position
            if holdThread then task.cancel(holdThread) holdThread = nil end
            holdThread = task.delay(HOLD_TIME, function()
                if dragging then canDrag = true end
            end)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if holdThread then task.cancel(holdThread) holdThread = nil end
            if dragging and not dragMoved then
                ToggleParryStatus()
            end
            dragging = false
            dragMoved = false
            canDrag = false
            dragStart = nil
            startPos = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and canDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    if AutoParryCustom._statusConn then AutoParryCustom._statusConn:Disconnect() end
    AutoParryCustom._statusConn = RunService.Heartbeat:Connect(function()
        if not AutoParryCustom.Gui or not AutoParryCustom.Gui.Parent then
            if AutoParryCustom._statusConn then
                AutoParryCustom._statusConn:Disconnect()
                AutoParryCustom._statusConn = nil
            end
            return
        end
        if AutoParryCustom.IsActive ~= Config.Surv_AutoParry then
            AutoParryCustom.IsActive = Config.Surv_AutoParry
            UpdateCustomParryGUI(Config.Surv_AutoParry)
        end
    end)
end

-- Buat GUI saat pertama kali (bisa diaktifkan via toggle di UI)
task.spawn(function()
    task.wait(1.5)
    AutoParryCustom.IsActive = false
    AutoParryCustom.GuiVisible = false
    CreateCustomParryGUI()
end)
    
    AutoParrySection:AddParagraph({
        Title = "⚠️ PENTING",
        Content = "Wajib dimatikan saat di lobby dan dinyalakan lagi saat ingame, Jika tidak mengalami crash WAJIB MENYALAKAB SKIP ENDSCREEN."
    })
    
    AutoParrySection:AddToggle({
        Title = "Auto Parry",
        Content = "Parry saat killer menyerang",
        Default = false,
        Keybind = true,
        Callback = function(v)
            Config.Surv_AutoParry = v
            if not v then
                Config.Surv_ParrySafety = false
                Config.Surv_ParryAggressive = false
            end
        end
    })
    
    AutoParrySection:AddToggle({
        Title = "Radius Parry",
        Content = "Visual radius parry",
        Default = false,
        Callback = function(v)
            Config.Surv_ParryCircle = v
        end
    })

    AutoParrySection:AddToggle({
        Title = "Mode Agresif",
        Content = "Parry tanpa peduli arah",
        Default = false,
        Callback = function(v)
            Config.Surv_ParryAggressive = v
        end
    })

    AutoParrySection:AddToggle({
        Title = "Safety Parry",
        Content = "Cegah parry saat sedang sibuk (vault, repair, dll)",
        Default = false,
        Callback = function(v)
            Config.Surv_ParrySafety = v
        end
    })

    AutoParrySection:AddInput({
        Title = "Radius Parry (studs)",
        Default = "6",
        Placeholder = "Write ur input here...",
        Callback = function(v)
            -- input UI berupa teks -> ubah ke angka (kalau tidak valid, abaikan)
            local n = tonumber(v)
            if not n then return end
            n = math.clamp(n, 1, 60)
            Config.Surv_ParryRadius = n
            DynamicRadius.Current = n
        end
    })

    AutoParrySection:AddInput({
        Title = "Sensivitas Arah Hadap Killer (studs)",
        Default = "10",
        Placeholder = "Write ur input here...",
        Callback = function(v)
            Config.Surv_ParryFace = v / 10
        end
    })

    AutoParrySection:AddDropdown({
        Title = "Abaikan Skill",
        Options = {"Hidden S1", "Abyssal S1"},
        Default = "",
        Multi = true,
        Callback = function(selected)
            local parsed = {}
            for _, v in pairs(selected) do
                parsed[v] = true
            end
            Config.Ignored_Skills_List = parsed
        end
    })
    
    local UserInputService = game:GetService("UserInputService")
    local CoreGui          = game:GetService("CoreGui")
    local TweenService     = game:GetService("TweenService")

    -- ============ CONFIG ============
    local FakeParry = {
        Enabled   = false,
        Animation = "Enten",
        Keybind   = Enum.KeyCode.G
    }

    local FakeParryAnimations = {
        Enten       = "rbxassetid://127096285501517",
        Stopwatch   = "rbxassetid://81793464499285",
        Fih         = "rbxassetid://123307242865945",
        BloodShield = "rbxassetid://75939529748815"
    }

    local State = {
        FakeParryTrack       = nil,
        FakeParryButton      = nil,
        FakeParryBtnRef      = nil,
        UpdateFakeParryStyle = nil,
        FakeParryAnimGui     = nil
    }

    -- ============ PLAY FAKE PARRY ============
    local function PlayFakeParry()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then animator = Instance.new("Animator", hum) end

        if State.FakeParryTrack then
            State.FakeParryTrack:Stop()
            State.FakeParryTrack = nil
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = FakeParryAnimations[FakeParry.Animation]
                          or FakeParryAnimations.Enten

        State.FakeParryTrack = animator:LoadAnimation(anim)
        State.FakeParryTrack.Priority = Enum.AnimationPriority.Action
        State.FakeParryTrack:Play()
    end

    -- ============ INPUT KEYBIND ============
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == FakeParry.Keybind and FakeParry.Enabled then
            PlayFakeParry()
        end
    end)

    -- ==========================================================
    --  BUTTON FLOATING (TIDAK DIUBAH)
    -- ==========================================================
    local function CreateFakeParryButton()
        if State.FakeParryButton then State.FakeParryButton:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "FakeParryGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = CoreGui

        local SIZE = 40
        local btn = Instance.new("TextButton")
        btn.Name = "FakeParryButton"
        btn.Size = UDim2.fromOffset(SIZE * 3, SIZE)
        btn.Position = UDim2.new(0.65, 0, 0.70, 0)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.BorderSizePixel = 0
        btn.Text = "FAKE PARRY"
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = gui

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(130, 130, 130)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local function updateStyle()
            local strokeRef = btn:FindFirstChildOfClass("UIStroke")
            if FakeParry.Enabled then
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                btn.TextColor3 = Color3.fromRGB(192, 132, 252)
                if strokeRef then
                    strokeRef.Color = Color3.fromRGB(168, 85, 247)
                    strokeRef.Thickness = 1.8
                end
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                btn.TextColor3 = Color3.fromRGB(230, 230, 230)
                if strokeRef then
                    strokeRef.Color = Color3.fromRGB(130, 130, 130)
                    strokeRef.Thickness = 1.5
                end
            end
        end
        updateStyle()

        State.FakeParryBtnRef      = btn
        State.UpdateFakeParryStyle = updateStyle

        local touchId, dragStart, startPos, hasMoved = nil, nil, nil, false
        local THRESHOLD = 8

        btn.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and
               input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if touchId then return end
            touchId   = input
            dragStart = input.Position
            startPos  = btn.Position
            hasMoved  = false
        end)

        btn.InputChanged:Connect(function(input)
            if input ~= touchId then return end
            if input.UserInputType ~= Enum.UserInputType.Touch and
               input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

            local delta = input.Position - dragStart
            if delta.Magnitude >= THRESHOLD then hasMoved = true end

            if hasMoved then
                btn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        btn.InputEnded:Connect(function(input)
            if input ~= touchId then return end
            if input.UserInputType ~= Enum.UserInputType.Touch and
               input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            if not hasMoved then
                FakeParry.Enabled = true
                updateStyle()
                PlayFakeParry()

                task.delay(0.4, function()
                    FakeParry.Enabled = false
                    updateStyle()
                end)
            end

            touchId = nil; dragStart = nil; startPos = nil; hasMoved = false
        end)

        State.FakeParryButton = gui
    end

    local function RemoveFakeParryButton()
        if State.FakeParryButton then
            State.FakeParryButton:Destroy()
            State.FakeParryButton      = nil
            State.FakeParryBtnRef      = nil
            State.UpdateFakeParryStyle = nil
        end
    end

    -- ==========================================================
    --  DROPDOWN ANIMASI (UI LUAR COMPACT)
    -- ==========================================================
    local function CreateFakeParryAnimDropdown()
    if State.FakeParryAnimGui then State.FakeParryAnimGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FakeParryAnimGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    -- ===== Main Frame (compact) =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainBox"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.28, 0)
    mainFrame.Size = UDim2.new(0, 145, 0, 128)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 5)

    -- ===== Top Bar Ungu =====
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 5)
    local topBarFix = Instance.new("Frame", topBar)
    topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    topBarFix.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    topBarFix.BorderSizePixel = 0

    -- ===== Header =====
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 14)
    header.Position = UDim2.new(0, 0, 0, 3)
    header.BackgroundTransparency = 1
    header.Active = true

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -18, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Fake Parry"
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.TextSize = 9
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = header

    local minimizeBtn = Instance.new("TextButton", header)
    minimizeBtn.Size = UDim2.new(0, 14, 0, 14)
    minimizeBtn.Position = UDim2.new(1, -15, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 11
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header

    -- ===== Divider =====
    local divider = Instance.new("Frame", mainFrame)
    divider.Size = UDim2.new(1, -10, 0, 1)
    divider.Position = UDim2.new(0, 5, 0, 18)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    divider.BorderSizePixel = 0

    -- ===== TAB BAR =====
    local tabBar = Instance.new("Frame", mainFrame)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -10, 0, 16)
    tabBar.Position = UDim2.new(0, 5, 0, 21)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabBar.BorderSizePixel = 0
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 3)

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- ===== Page Container =====
    local pageContainer = Instance.new("Frame", mainFrame)
    pageContainer.Name = "PageContainer"
    pageContainer.Size = UDim2.new(1, -10, 1, -60)
    pageContainer.Position = UDim2.new(0, 5, 0, 40)
    pageContainer.BackgroundTransparency = 1
    pageContainer.ClipsDescendants = true

    -- ===== Tab: Anim =====
    local pageAnim = Instance.new("Frame", pageContainer)
    pageAnim.Name = "PageAnim"
    pageAnim.Size = UDim2.new(1, 0, 1, 0)
    pageAnim.BackgroundTransparency = 1

    local animLayout = Instance.new("UIListLayout", pageAnim)
    animLayout.Padding = UDim.new(0, 2)
    animLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local animations = { "Enten", "Stopwatch", "Fih", "BloodShield" }
    local itemButtons = {}
    local ITEM_H = 16

    local currentLabel

    local function refreshAnimStyles()
        for _, btn in ipairs(itemButtons) do
            local name = btn:GetAttribute("AnimName")
            if name == FakeParry.Animation then
                btn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                btn.Font = Enum.Font.Gotham
            end
        end
    end

    for i, animName in ipairs(animations) do
        local item = Instance.new("TextButton")
        item.Name = "Item_" .. animName
        item:SetAttribute("AnimName", animName)
        item.Size = UDim2.new(1, 0, 0, ITEM_H)
        item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        item.BorderSizePixel = 0
        item.Text = animName
        item.TextColor3 = Color3.fromRGB(200, 200, 200)
        item.Font = Enum.Font.Gotham
        item.TextSize = 9
        item.AutoButtonColor = false
        item.LayoutOrder = i
        item.Parent = pageAnim
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 3)

        item.MouseEnter:Connect(function()
            if animName ~= FakeParry.Animation then
                item.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            end
        end)
        item.MouseLeave:Connect(function()
            if animName ~= FakeParry.Animation then
                item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            end
        end)
        item.MouseButton1Click:Connect(function()
            FakeParry.Animation = animName
            refreshAnimStyles()
            if currentLabel then
                currentLabel.Text = "Selected: " .. animName
            end
        end)
        table.insert(itemButtons, item)
    end
    refreshAnimStyles()

    -- ===== Tab: Info =====
    local pageInfo = Instance.new("Frame", pageContainer)
    pageInfo.Name = "PageInfo"
    pageInfo.Size = UDim2.new(1, 0, 1, 0)
    pageInfo.BackgroundTransparency = 1
    pageInfo.Visible = false

    local infoLayout = Instance.new("UIListLayout", pageInfo)
    infoLayout.Padding = UDim.new(0, 3)
    infoLayout.SortOrder = Enum.SortOrder.LayoutOrder

    currentLabel = Instance.new("TextLabel", pageInfo)
    currentLabel.Size = UDim2.new(1, 0, 0, 12)
    currentLabel.BackgroundTransparency = 1
    currentLabel.Font = Enum.Font.GothamBold
    currentLabel.Text = "Selected: " .. FakeParry.Animation
    currentLabel.TextColor3 = Color3.fromRGB(192, 132, 252)
    currentLabel.TextSize = 9
    currentLabel.TextXAlignment = Enum.TextXAlignment.Center
    currentLabel.LayoutOrder = 1

    local keybindLabel = Instance.new("TextLabel", pageInfo)
    keybindLabel.Size = UDim2.new(1, 0, 0, 11)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.Text = "Keybind: " .. tostring(FakeParry.Keybind.Name or "G")
    keybindLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    keybindLabel.TextSize = 9
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Center
    keybindLabel.LayoutOrder = 2

    local statusLabel = Instance.new("TextLabel", pageInfo)
    statusLabel.Size = UDim2.new(1, 0, 0, 11)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.LayoutOrder = 3

    task.spawn(function()
        while State.FakeParryAnimGui and State.FakeParryAnimGui.Parent do
            keybindLabel.Text = "Keybind: " .. tostring(FakeParry.Keybind.Name or "G")
            statusLabel.Text = "Status: " .. (FakeParry.Enabled and "ON" or "OFF")
            statusLabel.TextColor3 = FakeParry.Enabled 
                and Color3.fromRGB(100, 255, 100) 
                or Color3.fromRGB(150, 150, 160)
            task.wait(1)
        end
    end)

    -- ===== Tab Setup =====
    local tabPages = {
        ["Anim"] = pageAnim,
        ["Info"] = pageInfo,
    }
    local tabBtns = {}

    for i, tabName in ipairs({"Anim", "Info"}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5, -2, 1, -3)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BorderSizePixel = 0
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)
        tabBtns[tabName] = btn
    end

    local function switchTab(active)
        for name, btn in pairs(tabBtns) do
            if name == active then
                btn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            tabPages[name].Visible = (name == active)
        end
    end

    for name, btn in pairs(tabBtns) do
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end
    switchTab("Anim")

    -- ===== Expand / Minimize =====
    local isExpanded = true
    local FULL_H = 128
    local MIN_H = 20

    local function setExpanded(state)
        isExpanded = state
        if state then
            mainFrame.Size = UDim2.new(0, 145, 0, FULL_H)
            divider.Visible = true
            tabBar.Visible = true
            pageContainer.Visible = true
            minimizeBtn.Text = "−"
        else
            mainFrame.Size = UDim2.new(0, 145, 0, MIN_H)
            divider.Visible = false
            tabBar.Visible = false
            pageContainer.Visible = false
            minimizeBtn.Text = "+"
        end
    end

    minimizeBtn.MouseButton1Click:Connect(function()
        setExpanded(not isExpanded)
    end)

    -- ===== Drag handler =====
    local dragging, dragStart, startPos = false, nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)

    setExpanded(true)
    State.FakeParryAnimGui = gui
end

    -- ==========================================================
    --  UI TOGGLE
    -- ==========================================================
    AutoParrySection:AddToggle({
        Title = "Enable Fake Parry",
        Content = "Pura-pura parry (animasi saja)",
        Default = false,
        Keybind = true,
        Callback = function(v)
            FakeParry.Enabled = v
            if UserInputService.TouchEnabled then
                if v then
                    CreateFakeParryButton()
                    CreateFakeParryAnimDropdown()
                else
                    RemoveFakeParryButton()
                    if State.FakeParryAnimGui then
                        State.FakeParryAnimGui:Destroy()
                        State.FakeParryAnimGui = nil
                    end
                end
            end
        end
    })
    
    AutoParrySection:AddInput({
        Title = "Fake Parry Keybind",
        Content = "Ketik tombol: G, F, X, Q, dll",
        Default = "G",
        Placeholder = "Contoh: G / F / X",
        Callback = function(input)
            input = tostring(input or ""):gsub("%s+", "")
            if input == "" then return end
            local ok, kc = pcall(function()
                return Enum.KeyCode[input:upper():sub(1,1) .. input:lower():sub(2)]
            end)
            if ok and kc then
                FakeParry.Keybind = kc
            end
        end
    })
end

-- =====================================================
-- AUTO PARRY AI (section terpisah, di bawah Auto Parry biasa)
-- Semua variabel/fungsi yang namanya sama dengan Auto Parry biasa
-- dibuat local di dalam blok ini, jadi tidak saling menimpa.
-- =====================================================
do

local VD = {
    SURV_AutoParry        = false,
    SURV_AIParryRadius    = 20,
    SURV_ParryDistance    = 8,
    SURV_ShowParryCircle  = false,
    SURV_ParryFacingAngle = 60,
    SURV_ParryAntiFake    = true,
    SURV_ParryShowHitDir  = false,
    SURV_AICCTV           = false,
    SURV_AICCTVShowHUD    = false,
    SURV_ParryCamera      = false,
    SURV_ParryCamView     = false,
    SURV_ParryCamFOV      = 70,
    SURV_ParryCamRadius   = 16,
    SURV_ParryCamSpeed    = 0.18,
    SURV_ParryCamShowFocus= false,
    Ignored_Skills_List   = {},
}

local okAI, errAI = pcall(function()

-- nama yang sama dengan Auto Parry biasa -> dibuat local supaya tidak menimpa global
local IsKiller, IsDowned, IsSafeToParry, TriggerCrouch
local tapMobileParryButton, ExecuteParry, ListenToParryResult
local AttachParrySensor, TryAttach, SetupPlayer
local Root, Humanoid

local VirtualInputManager
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local function GetSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local VD_Parry = {
    PreciseDistanceEnabled = true,
    MaxDistance = 14,
    CanParry = true,
    IsParrying = false,
    CooldownEndTime = 0,
    KillerAnimator = nil,
    KillerChar = nil,
    KillerPlayer = nil,
    Connections = {},
    FiredTracks = {},
    RenderConnection = nil,
    LastStatus = "Off",
}

local VD_ParryAnimation = Instance.new("Animation")
VD_ParryAnimation.AnimationId = "rbxassetid://109133187196613"

-- Gaya Zian: CylinderHandleAdornment abu-abu tipis (Height 0.01) nempel di Terrain.
local VD_ParryRange = Instance.new("CylinderHandleAdornment")
VD_ParryRange.Name = "KYS_ParryRange"
VD_ParryRange.Radius = VD.SURV_ParryDistance or 8
VD_ParryRange.InnerRadius = math.max(0.1, (VD.SURV_ParryDistance or 8) - 0.15)
VD_ParryRange.Height = 0.01
VD_ParryRange.Color3 = Color3.fromRGB(80, 80, 80)
VD_ParryRange.AlwaysOnTop = false
VD_ParryRange.Adornee = Workspace:FindFirstChildOfClass("Terrain")
VD_ParryRange.Transparency = 1
VD_ParryRange.Parent = GetSafeGuiParent()

local VD_ATTACK_ANIMS = {
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://74968262036854"] = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://78432063483146"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://138720291317243"] = true,
    ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
}

-- ==================== V21: AI BACA ANIMATION ATTACK KILLER ====================
-- AI "masuk server" dan lihat model 3D killer. Tiap killer yang beneran main
-- animation attack dicatat di sini (waktu + animasi). AI parry CUMA boleh
-- trigger kalau ada animation attack BENERAN (bukan cuma gerak/hadap).
VD_KillerAttackState = {}   -- [killerChar] = { t = os.clock(), animId = "..." }
VD_ATTACK_ANIM_WINDOW = 1.25 -- V22: animation attack dianggap "aktif" selama 1.25 detik
                             -- (dulu 0.9s -> AI kehabisan waktu baca pas killer attack dari luar jangkauan)

-- FIX BUG "parry dari jauh": killer di dalam lingkaran besar (mis. 19) TAPI masih jauh
-- dari player -> JANGAN parry. Parry cuma kalau killer BENERAN dalam jangkauan hit.
-- Attack yang bisa DITAHAN (lari sambil jalan / charging) boleh agak lebih jauh.
VD_HIT_RANGE      = 9    -- jangkauan hit melee normal (studs)
VD_HIT_RANGE_HOLD = 18   -- jangkauan buat attack yang bisa ditahan (lari sambil attack / charging)
VD_SMALL_CIRCLE   = 14   -- V22: lingkaran <= ini dianggap "kecil" -> parry harus GESIT

function VD_MarkKillerAttack(kChar, animId)
    if not kChar then return end
    VD_KillerAttackState[kChar] = { t = os.clock(), animId = animId }
end

function VD_IsKillerAttacking(kChar)
    if not kChar then return false end
    local st = VD_KillerAttackState[kChar]
    if not st then return false end
    if os.clock() - st.t > VD_ATTACK_ANIM_WINDOW then
        VD_KillerAttackState[kChar] = nil
        return false
    end
    return true
end

function VD_UpdateParryRange()
    if not VD.SURV_ShowParryCircle or not VD.SURV_AutoParry then
        VD_ParryRange.Transparency = 1
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        VD_ParryRange.Transparency = 1
        return
    end

    -- V19: lingkaran parry = radius AI (killer WAJIB masuk sini baru boleh parry)
    local currentMaxDist = VD_GetAIParryRadius()
    VD_ParryRange.Transparency = 0.4
    VD_ParryRange.Radius = currentMaxDist
    VD_ParryRange.InnerRadius = math.max(0.1, currentMaxDist - 0.15)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ray = Workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)
    local groundPos = ray and ray.Position or (root.Position - Vector3.new(0, 3, 0))
    VD_ParryRange.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.05, 0)) * CFrame.Angles(math.pi / 2, 0, 0)
end

function VD_GetParryRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local dagger = items and items:FindFirstChild("Parrying Dagger")
    return dagger and dagger:FindFirstChild("parry")
end

function VD_RefreshLocalCombatCache()
    local char = LocalPlayer.Character
    Root = char and char:FindFirstChild("HumanoidRootPart") or Root
    Humanoid = char and char:FindFirstChildOfClass("Humanoid") or Humanoid
end

local State = { ParryCooldown = false, ParryCooldownThread = nil }
local Attached = {}
function IsKiller(p) return p.Team and p.Team.Name == "Killer" end
function IsDowned(char) local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return true end; local state = char:GetAttribute("State"); return state == "Downed" or state == "Dead" end
function TriggerCrouch()
    local startT = tick()
    task.spawn(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        -- Toggle crouch ON: replicate mobile SurvivorAnimationsController logic
        pcall(function() char:SetAttribute("Crouching", true) end)
        pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
        pcall(function() ReplicatedStorage.Remotes.Chase.Runevent:FireServer(char, false) end)
        if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Landed) end) end
        
        -- Also fire the mobile crouch button signal for visual sync
        pcall(function()
            local survMob = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
            if survMob then
                local controls = survMob:FindFirstChild("Controls")
                if controls then
                    local crouchBtn = controls:FindFirstChild("crouch")
                    if crouchBtn then
                        firesignal(crouchBtn.MouseButton1Click)
                    end
                end
            end
        end)
        
        while tick() - startT < 1.2 do
            pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
            task.wait(0.1)
        end
        
        -- Toggle crouch OFF
        pcall(function() char:SetAttribute("Crouching", false) end)
        pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", false) end)
        if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Landed) end) end
        
        -- Fire crouch button again to toggle OFF visually
        pcall(function()
            local survMob = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
            if survMob then
                local controls = survMob:FindFirstChild("Controls")
                if controls then
                    local crouchBtn = controls:FindFirstChild("crouch")
                    if crouchBtn then
                        firesignal(crouchBtn.MouseButton1Click)
                    end
                end
            end
        end)
    end)
end
function IsSafeToParry(char)
    if not char then return false end
    if IsDowned(char) then return false end

    -- Cek attribute di karakter (hook, pallet, vault, dll)
    if char:GetAttribute("IsHooked") == true then return false end
    if char:GetAttribute("IsCarried") == true then return false end
    if char:GetAttribute("IsStunned") == true then return false end
    if char:GetAttribute("Immobile") == true then return false end
    if char:GetAttribute("MovementLocked") == true then return false end
    if char:GetAttribute("Knocked") == true then return false end
    if char:GetAttribute("Crouching") == true then return false end
    if char:GetAttribute("IsVaulting") == true then return false end
    if char:GetAttribute("IsPalletStunned") == true then return false end

    -- Cek attribute di CheckInterractable
    local interactObj = char:FindFirstChild("CheckInterractable")
    if interactObj then
        if interactObj:GetAttribute("isVaulting")    == true then return false end
        if interactObj:GetAttribute("isRepairing")   == true then return false end
        if interactObj:GetAttribute("isUnhooking")   == true then return false end
        if interactObj:GetAttribute("isHealing")     == true then return false end
        if interactObj:GetAttribute("isSliding")     == true then return false end
        if interactObj:GetAttribute("isPalletVault") == true then return false end
        if interactObj:GetAttribute("isPalletDrop")  == true then return false end
    end

    -- Cek Humanoid state
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Climbing
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.PlatformStanding then
            return false
        end
    end

    return true
end

-- ==================== V16 ANTI FAKE HIT ====================
-- Ambil arah hadap/aim killer yang paling akurat.
-- Prioritas: Head (mata) -> UpperTorso -> HumanoidRootPart.
-- Ini yang dipakai buat nentuin hit-nya beneran ke arah kita atau fake.
function VD_GetKillerAimDirection(kChar)
    if not kChar then return nil end
    local head = kChar:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        local lv = head.CFrame.LookVector
        if Vector3.new(lv.X, 0, lv.Z).Magnitude > 0.05 then
            return Vector3.new(lv.X, 0, lv.Z).Unit
        end
    end
    local upper = kChar:FindFirstChild("UpperTorso") or kChar:FindFirstChild("Torso")
    if upper and upper:IsA("BasePart") then
        local lv = upper.CFrame.LookVector
        if Vector3.new(lv.X, 0, lv.Z).Magnitude > 0.05 then
            return Vector3.new(lv.X, 0, lv.Z).Unit
        end
    end
    local hrp = kChar:FindFirstChild("HumanoidRootPart")
    if hrp then
        local lv = hrp.CFrame.LookVector
        if Vector3.new(lv.X, 0, lv.Z).Magnitude > 0.05 then
            return Vector3.new(lv.X, 0, lv.Z).Unit
        end
    end
    return nil
end

-- Cek apakah killer BENAR-BENAR menghadap ke arah kita.
-- Kalau killer menghadap belakang / samping (mata & badan ga ke kita),
-- berarti itu fake hit / bait -> JANGAN parry.
-- angleDeg = lebar cone (derajat). Makin kecil = makin ketat.
function VD_IsKillerFacingMe(kHRP, myHRP, angleDeg, kChar)
    if not kHRP or not myHRP then return false end
    local toMe = myHRP.Position - kHRP.Position
    local flatToMe = Vector3.new(toMe.X, 0, toMe.Z)
    if flatToMe.Magnitude < 0.05 then return true end
    flatToMe = flatToMe.Unit

    -- Arah hadap killer (pakai Head/mata kalau ada, fallback ke root)
    local aimDir = kChar and VD_GetKillerAimDirection(kChar) or nil
    if not aimDir then
        local look = kHRP.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 0.05 then return true end
        aimDir = flatLook.Unit
    end

    local dot = aimDir:Dot(flatToMe)
    local cosLimit = math.cos(math.rad(tonumber(angleDeg) or 60))
    return dot >= cosLimit
end

-- Cek apakah killer sedang bergerak/charge ke arah kita (indikasi hit nyata).
function VD_IsKillerChargingMe(kChar, myHRP)
    if not kChar or not myHRP then return false end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return false end
    local vel = kHRP.AssemblyLinearVelocity
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    if flatVel.Magnitude < 6 then return false end
    local toMe = myHRP.Position - kHRP.Position
    local flatToMe = Vector3.new(toMe.X, 0, toMe.Z)
    if flatToMe.Magnitude < 0.05 then return true end
    return flatVel.Unit:Dot(flatToMe.Unit) >= 0.5
end

-- Cek apakah killer sedang dalam animasi attack yang benar-benar mengarah ke kita.
-- Dipakai untuk memastikan hit-nya nyata (bukan fake/bait).
function VD_IsRealHit(kChar, myHRP, angleDeg)
    if not kChar or not myHRP then return false end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return false end
    return VD_IsKillerFacingMe(kHRP, myHRP, angleDeg, kChar)
end

-- FIX BUG "parry dari jauh": killer di dalam lingkaran besar (mis. 19) tapi masih
-- jauh dari player -> JANGAN parry. Parry cuma kalau killer BENERAN dalam jangkauan hit.
-- Attack yang bisa DITAHAN (lari sambil jalan / charging) boleh agak lebih jauh.
-- V22 FIX "parry LAMA di outline kecil (8/9/11/12)": kalau lingkaran kecil, jangkauan
-- hit = radius lingkaran itu sendiri. Jadi begitu killer MASUK lingkaran + attack,
-- parry langsung trigger (ga nunggu killer nyampe 9 studs dulu).
function VD_IsKillerInHitRange(kChar, myHRP, dist)
    if not kChar or not myHRP then return false end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return false end
    if not dist then dist = (kHRP.Position - myHRP.Position).Magnitude end
    local charging = VD_IsKillerChargingMe(kChar, myHRP)
    local limit = charging and VD_HIT_RANGE_HOLD or VD_HIT_RANGE
    -- V22: lingkaran kecil -> jangkauan hit ikut radius lingkaran (biar gesit)
    local radius = VD_GetAIParryRadius()
    if radius <= VD_SMALL_CIRCLE then
        limit = math.max(limit, radius)
    end
    return dist <= limit
end

-- ==================== V16 HIT DIRECTION DEBUG VISUAL ====================
-- Nampilin garis arah hit killer: MERAH = hit beneran ke kita, ABU = fake/bukan ke kita.
getgenv().VD_HitDirPart = nil
getgenv().VD_HitDirPart2 = nil
function VD_UpdateHitDirVisual(kChar, myHRP, isReal)
    if not VD.SURV_ParryShowHitDir then
        if getgenv().VD_HitDirPart then getgenv().VD_HitDirPart.Transparency = 1 end
        if getgenv().VD_HitDirPart2 then getgenv().VD_HitDirPart2.Transparency = 1 end
        return
    end
    if not kChar or not myHRP then return end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return end

    local aimDir = VD_GetKillerAimDirection(kChar)
    if not aimDir then return end

    local origin = kHRP.Position + Vector3.new(0, 2.5, 0)
    local length = 12
    local endPos = origin + aimDir * length

    local function ensure(part)
        if part and part.Parent then return part end
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Material = Enum.Material.Neon
        p.Size = Vector3.new(0.15, 0.15, 1)
        p.Parent = workspace
        return p
    end

    local beam = ensure(getgenv().VD_HitDirPart)
    getgenv().VD_HitDirPart = beam
    local mid = (origin + endPos) / 2
    beam.CFrame = CFrame.new(mid, endPos)
    beam.Size = Vector3.new(0.15, 0.15, (endPos - origin).Magnitude)
    beam.Color = isReal and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(150, 150, 150)
    beam.Transparency = 0.25

    -- Titik di ujung (nunjukin arah)
    local tip = ensure(getgenv().VD_HitDirPart2)
    getgenv().VD_HitDirPart2 = tip
    tip.Shape = Enum.PartType.Ball
    tip.Size = Vector3.new(0.5, 0.5, 0.5)
    tip.CFrame = CFrame.new(endPos)
    tip.Color = isReal and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(150, 150, 150)
    tip.Transparency = 0.2
end

-- ==================== V17 PARRY CAMERA (VISION LOCK) ====================
-- "Kamera" virtual yang merekam gerakan player di lingkaran/outline.
-- Begitu ada killer masuk radius, kamera langsung fokus ke killer dan
-- baca arah animasi attack-nya. Kalau attack beneran ngarah ke kita,
-- kamera kirim sinyal parry secepat mungkin.
VD_ParryCam = {
    Active         = false,
    Camera         = nil,
    Heartbeat      = nil,
    FocusKiller    = nil,
    MoveHistory    = {},
    LastMoveRec    = 0,
    LastFire       = 0,
    AttackActive   = 0,
    AttackKiller   = nil,
    AttackDir      = nil,
    AttackToward   = false,
    FocusHighlight = nil,
    FocusGui       = nil,
    TrailParts     = {},
}

function VD_ParryCam_EnsureCamera()
    if VD_ParryCam.Camera and VD_ParryCam.Camera.Parent then
        return VD_ParryCam.Camera
    end
    local cam = Instance.new("Camera")
    cam.Name = "VD_ParryCam"
    cam.FieldOfView = tonumber(VD.SURV_ParryCamFOV) or 70
    cam.Parent = workspace
    VD_ParryCam.Camera = cam
    return cam
end

-- Rekam gerakan player di lingkaran/outline (posisi tiap ~0.05s)
function VD_ParryCam_RecordMovement(myHRP)
    if not myHRP then return end
    local now = os.clock()
    if now - VD_ParryCam.LastMoveRec < 0.05 then return end
    VD_ParryCam.LastMoveRec = now
    local hist = VD_ParryCam.MoveHistory
    table.insert(hist, { pos = myHRP.Position, t = now })
    while #hist > 40 do table.remove(hist, 1) end
end

-- Cari killer terdekat dalam radius kamera
function VD_ParryCam_GetNearestKiller(myHRP, radius)
    if not myHRP then return nil, math.huge end
    local nearest, nearestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if r and hum and hum.Health > 0 then
                local d = (r.Position - myHRP.Position).Magnitude
                if d < nearestDist and d <= radius then
                    nearestDist = d
                    nearest = p.Character
                end
            end
        end
    end
    return nearest, nearestDist
end

-- Baca arah attack killer (gabungan aim Head + velocity charge + animasi)
function VD_ParryCam_ReadAttackDir(kChar, myHRP)
    if not kChar or not myHRP then return nil, 0 end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return nil, 0 end

    local aimDir = VD_GetKillerAimDirection(kChar)
    if not aimDir then return nil, 0 end

    local confidence = 0.6

    -- velocity charge ke arah kita
    local vel = kHRP.AssemblyLinearVelocity
    local flatVel = Vector3.new(vel.X, 0, vel.Z)
    if flatVel.Magnitude > 6 then
        local toMe = myHRP.Position - kHRP.Position
        local flatToMe = Vector3.new(toMe.X, 0, toMe.Z)
        if flatToMe.Magnitude > 0.05 and flatVel.Unit:Dot(flatToMe.Unit) > 0.5 then
            confidence = math.min(1, confidence + 0.25)
        end
    end

    -- lagi main attack animation
    if VD_ParryCam.AttackActive > 0 and (os.clock() - VD_ParryCam.AttackActive) < 0.6 then
        confidence = math.min(1, confidence + 0.3)
    end

    return aimDir, confidence
end

-- Cek apakah arah attack beneran ngarah ke kita (pakai cone FOV kamera)
function VD_ParryCam_IsAttackTowardMe(kChar, myHRP, fovDeg)
    if not kChar or not myHRP then return false end
    local kHRP = kChar:FindFirstChild("HumanoidRootPart")
    if not kHRP then return false end
    local aimDir = VD_ParryCam_ReadAttackDir(kChar, myHRP)
    if not aimDir then return false end
    local toMe = myHRP.Position - kHRP.Position
    local flatToMe = Vector3.new(toMe.X, 0, toMe.Z)
    if flatToMe.Magnitude < 0.05 then
        VD_ParryCam.AttackDir = aimDir
        VD_ParryCam.AttackToward = true
        return true
    end
    flatToMe = flatToMe.Unit
    local dot = aimDir:Dot(flatToMe)
    local cosLimit = math.cos(math.rad(tonumber(fovDeg) or 70))
    VD_ParryCam.AttackDir = aimDir
    VD_ParryCam.AttackToward = dot >= cosLimit
    return VD_ParryCam.AttackToward
end

-- Indikator visual fokus kamera (highlight killer + label + trail gerakan)
function VD_ParryCam_ShowFocus(kChar, myHRP, toward)
    if not VD.SURV_ParryCamShowFocus then
        if VD_ParryCam.FocusHighlight then VD_ParryCam.FocusHighlight.Enabled = false end
        if VD_ParryCam.FocusGui then VD_ParryCam.FocusGui.Enabled = false end
        for _, tp in ipairs(VD_ParryCam.TrailParts) do tp.Transparency = 1 end
        return
    end
    if not kChar then
        if VD_ParryCam.FocusHighlight then VD_ParryCam.FocusHighlight.Enabled = false end
        if VD_ParryCam.FocusGui then VD_ParryCam.FocusGui.Enabled = false end
        return
    end

    -- Highlight killer
    local hl = VD_ParryCam.FocusHighlight
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "VD_ParryCamFocus"
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = kChar
        VD_ParryCam.FocusHighlight = hl
    end
    hl.Adornee = kChar
    hl.Enabled = true
    hl.FillColor = toward and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 200, 40)
    hl.OutlineColor = toward and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 170, 0)

    -- Label di atas killer
    local gui = VD_ParryCam.FocusGui
    local head = kChar:FindFirstChild("Head")
    if not gui or not gui.Parent then
        gui = Instance.new("BillboardGui")
        gui.Name = "VD_ParryCamLabel"
        gui.Size = UDim2.new(0, 170, 0, 40)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.Parent = head or kChar:FindFirstChild("HumanoidRootPart") or kChar
        local txt = Instance.new("TextLabel")
        txt.Name = "Txt"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextScaled = true
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeTransparency = 0.3
        txt.Parent = gui
        VD_ParryCam.FocusGui = gui
    end
    gui.Adornee = head or kChar:FindFirstChild("HumanoidRootPart") or kChar
    gui.Enabled = true
    local txt = gui:FindFirstChild("Txt")
    if txt then
        txt.Text = toward and "CAM LOCK: HIT KE KITA" or "CAM LOCK: FAKE / BUKAN KE KITA"
        txt.TextColor3 = toward and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 210, 90)
    end

    -- Trail gerakan player di lingkaran
    local hist = VD_ParryCam.MoveHistory
    while #VD_ParryCam.TrailParts < math.min(#hist, 40) do
        local tp = Instance.new("Part")
        tp.Anchored = true
        tp.CanCollide = false
        tp.CanQuery = false
        tp.CanTouch = false
        tp.Material = Enum.Material.Neon
        tp.Shape = Enum.PartType.Ball
        tp.Size = Vector3.new(0.35, 0.35, 0.35)
        tp.Color = Color3.fromRGB(80, 200, 255)
        tp.Transparency = 0.5
        tp.Parent = workspace
        table.insert(VD_ParryCam.TrailParts, tp)
    end
    for i, tp in ipairs(VD_ParryCam.TrailParts) do
        local sample = hist[i]
        if sample then
            tp.Position = sample.pos + Vector3.new(0, 0.2, 0)
            tp.Transparency = 0.5
        else
            tp.Transparency = 1
        end
    end
end

-- Update utama (dipanggil tiap Heartbeat)
function VD_ParryCam_Update()
    if not VD.SURV_ParryCamera then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    -- 1) rekam gerakan player
    VD_ParryCam_RecordMovement(myHRP)

    -- 2) cari killer dalam radius
    local radius = tonumber(VD.SURV_ParryCamRadius) or 16
    local killer = VD_ParryCam_GetNearestKiller(myHRP, radius)

    local cam = VD_ParryCam_EnsureCamera()
    cam.FieldOfView = tonumber(VD.SURV_ParryCamFOV) or 70

    -- V17: kalau Camera View aktif, pakai kamera parry sebagai kamera utama
    if VD.SURV_ParryCamView then
        local cc = workspace.CurrentCamera
        if cc and cc ~= cam then
            cc.CameraType = Enum.CameraType.Scriptable
            cc.CFrame = cam.CFrame
            cc.FieldOfView = cam.FieldOfView
        end
    end

    if not killer then
        VD_ParryCam.FocusKiller = nil
        VD_ParryCam.AttackToward = false
        local look = myHRP.CFrame.LookVector
        local target = CFrame.new(myHRP.Position + Vector3.new(0, 2.5, 0), myHRP.Position + Vector3.new(0, 2.5, 0) + look)
        cam.CFrame = cam.CFrame:Lerp(target, 0.15)
        VD_ParryCam_ShowFocus(nil, myHRP, false)
        return
    end

    -- 3) fokus kamera ke killer
    VD_ParryCam.FocusKiller = killer
    local kHRP = killer:FindFirstChild("HumanoidRootPart")
    if kHRP then
        local camPos = myHRP.Position + Vector3.new(0, 2.5, 0)
        local lookAt = kHRP.Position + Vector3.new(0, 1.5, 0)
        local target = CFrame.new(camPos, lookAt)
        local speed = math.clamp(tonumber(VD.SURV_ParryCamSpeed) or 0.18, 0.05, 1)
        cam.CFrame = cam.CFrame:Lerp(target, speed)
    end

    -- 4) baca arah attack killer
    local fov = tonumber(VD.SURV_ParryCamFOV) or 70
    local toward = VD_ParryCam_IsAttackTowardMe(killer, myHRP, fov)
    VD_ParryCam_ShowFocus(killer, myHRP, toward)

    -- 5) V19 FIX: parry HANYA kalau killer MASUK lingkaran/outline AI.
    -- Kalau killer di luar lingkaran (walau menghadap kita & attack) -> NO PARRY.
    local aiRadius = VD_GetAIParryRadius()
    local killerDist = (kHRP and (kHRP.Position - myHRP.Position).Magnitude) or math.huge
    if killerDist > aiRadius then
        -- killer di luar lingkaran -> jangan parry
        return
    end
    if toward and VD.SURV_AutoParry and not State.ParryCooldown and not IsDowned(myChar) then
        local now = os.clock()
        if now - VD_ParryCam.LastFire >= 0.12 then
            -- V21: WAJIB ada animation attack BENERAN (bukan cuma gerak/hadap/charge)
            local attacking = VD_IsKillerAttacking(killer)
                or (VD_ParryCam.AttackActive > 0 and (now - VD_ParryCam.AttackActive) < 0.6)
            if attacking then
                ExecuteParry()
                VD_ParryCam.LastFire = now
            end
        end
    end
end

function VD_ParryCam_Start()
    if VD_ParryCam.Heartbeat then return end
    VD_ParryCam.Active = true
    VD_ParryCam_EnsureCamera()
    VD_ParryCam.Heartbeat = RunService.Heartbeat:Connect(function()
        pcall(VD_ParryCam_Update)
    end)
end

function VD_ParryCam_Stop()
    VD_ParryCam.Active = false
    if VD_ParryCam.Heartbeat then
        VD_ParryCam.Heartbeat:Disconnect()
        VD_ParryCam.Heartbeat = nil
    end
    -- restore kamera player
    pcall(function()
        local cc = workspace.CurrentCamera
        if cc then cc.CameraType = Enum.CameraType.Custom end
    end)
    if VD_ParryCam.Camera then
        VD_ParryCam.Camera:Destroy()
        VD_ParryCam.Camera = nil
    end
    if VD_ParryCam.FocusHighlight then
        VD_ParryCam.FocusHighlight:Destroy()
        VD_ParryCam.FocusHighlight = nil
    end
    if VD_ParryCam.FocusGui then
        VD_ParryCam.FocusGui:Destroy()
        VD_ParryCam.FocusGui = nil
    end
    for _, tp in ipairs(VD_ParryCam.TrailParts) do
        if tp and tp.Parent then tp:Destroy() end
    end
    VD_ParryCam.TrailParts = {}
    VD_ParryCam.MoveHistory = {}
    VD_ParryCam.FocusKiller = nil
end

function VD_SetParryCamera(state)
    VD.SURV_ParryCamera = state == true
    if VD.SURV_ParryCamera then
        VD_ParryCam_Start()
    else
        VD_ParryCam_Stop()
    end
end

-- ==================== V19 AI HARD (AUTO PARRY 100% AI) ====================
-- Auto Parry sekarang cuma ON/OFF. Ga ada lagi metode "Agresif".
-- ATURAN UTAMA (fix bug): killer WAJIB berada DI DALAM lingkaran/outline
-- (radius AI) dulu. Kalau killer di LUAR lingkaran walau dia menghadap kita
-- dan attack, parry TIDAK akan trigger. Baru setelah killer masuk lingkaran,
-- AI baca arah attack-nya: kalau beneran ngarah ke kita -> parry secepatnya.
function VD_GetParryMethod()
    -- V19: metode tunggal "AI HARD" (auto). Dipertahankan biar kompatibel.
    return "AI HARD"
end

function VD_ApplyParryMethod(method)
    -- V19: Auto Parry cuma ON/OFF, AI yang ngatur. Anti fake hit selalu aktif.
    VD.SURV_ParryMethod   = "AI HARD"
    VD.SURV_ParryAggressive = false
end

-- Radius lingkaran/outline AI (killer WAJIB masuk sini baru boleh parry).
function VD_GetAIParryRadius()
    return tonumber(VD.SURV_AIParryRadius) or 20
end

-- FIX: makin kecil lingkaran -> parry makin gesit (cooldown makin pendek).
-- V22: cooldown dipangkas lagi biar outline kecil (8/9/11/12) kerasa INSTAN.
-- Radius 4 -> ~0.02s, radius 14 -> ~0.035s, radius 60 -> ~0.07s.
function VD_GetAIParryCooldown()
    local r = VD_GetAIParryRadius()
    local t = 0.02 + (math.clamp(r, 4, 60) - 4) / (60 - 4) * 0.05
    return t
end

-- Cek killer terdekat yang masih hidup di dalam radius AI.
-- Return: char, dist, hrp  (atau nil kalau ga ada)
function VD_GetKillerInsideCircle(myHRP, radius)
    if not myHRP then return nil end
    radius = radius or VD_GetAIParryRadius()
    local nearest, nearestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if r and hum and hum.Health > 0 then
                local d = (r.Position - myHRP.Position).Magnitude
                if d <= radius and d < nearestDist then
                    nearestDist = d
                    nearest = p.Character
                end
            end
        end
    end
    if nearest then
        return nearest, nearestDist, nearest:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- V20: killer terdekat (di mana pun, ga peduli radius) -> buat nampilin
-- "Killer Distance" di HUD REAPER X walau killer masih di luar lingkaran.
function VD_GetNearestKiller(myHRP)
    if not myHRP then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if r and hum and hum.Health > 0 then
                local d = (r.Position - myHRP.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = p.Character
                end
            end
        end
    end
    if nearest then
        return nearest, nearestDist, nearest:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- ==================== V19 AI CCTV (HARD) ====================
-- AI yang "lihat" player + lingkaran/outline. Begitu ada killer MASUK lingkaran,
-- AI langsung mode SIAP (HARD). Kalau killer di luar lingkaran -> STANDBY,
-- parry ga akan pernah trigger walau killer menghadap kita.
VD_AICCTV = {
    Active      = false,
    Heartbeat   = nil,
    Ready       = false,
    Threat      = nil,
    ThreatDist  = math.huge,
    ThreatFacing= false,
    ThreatCharge= false,
    ThreatAttacking = false,
    ThreatInRange   = false,
    Method      = "AI HARD",
    LastUpdate  = 0,
    Gui         = nil,
    Circle      = nil,
}

-- Gaya Zian: lingkaran/outline pakai CylinderHandleAdornment (abu-abu tipis, Height 0.01,
-- nempel di Terrain) — jauh lebih rapi dari Part neon. Warna tetap berubah buat nunjukin state.
function VD_AICCTV_EnsureCircle()
    if VD_AICCTV.Circle and VD_AICCTV.Circle.Parent then return VD_AICCTV.Circle end
    local c = Instance.new("CylinderHandleAdornment")
    c.Name = "VD_AICCTV_Circle"
    c.Radius = VD_GetAIParryRadius()
    c.InnerRadius = math.max(0.1, VD_GetAIParryRadius() - 0.15)
    c.Height = 0.01
    c.Color3 = Color3.fromRGB(80, 80, 80)
    c.AlwaysOnTop = false
    c.Adornee = Workspace:FindFirstChildOfClass("Terrain")
    c.Transparency = 0.35
    c.Parent = GetSafeGuiParent()
    VD_AICCTV.Circle = c
    return c
end

-- Posisikan lingkaran/outline di tanah ngikutin player (gaya Zian).
function VD_AICCTV_PositionCircle(circle, myHRP, radius)
    if not circle or not myHRP then return end
    radius = radius or VD_GetAIParryRadius()
    circle.Radius = radius
    circle.InnerRadius = math.max(0.1, radius - 0.15)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local myChar = LocalPlayer.Character
    if myChar then params.FilterDescendantsInstances = { myChar } end
    local ray = Workspace:Raycast(myHRP.Position, Vector3.new(0, -15, 0), params)
    local groundPos = ray and ray.Position or (myHRP.Position - Vector3.new(0, 3, 0))
    circle.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.05, 0)) * CFrame.Angles(math.pi / 2, 0, 0)
end

function VD_AICCTV_EnsureHUD()
    -- HUD "REAPER X SYSTEM" (pojok kiri atas) DIHAPUS. Fungsi dibiarkan ada
    -- (kosong) supaya semua pemanggil lama tetap aman. Logika parry tidak berubah.
    if VD_AICCTV.Gui then
        pcall(function() VD_AICCTV.Gui:Destroy() end)
        VD_AICCTV.Gui = nil
    end
    return nil
end

function VD_AICCTV_UpdateHUD()
    -- HUD dihapus: tidak ada UI yang digambar lagi.
    if VD_AICCTV.Gui then
        pcall(function() VD_AICCTV.Gui:Destroy() end)
        VD_AICCTV.Gui = nil
    end
end

function VD_AICCTV_Update()
    if not VD.SURV_AICCTV then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local radius = VD_GetAIParryRadius()

    -- lingkaran/outline (gaya Zian: CylinderHandleAdornment di tanah)
    local circle = VD_AICCTV_EnsureCircle()
    if type(VD_AICCTV_PositionCircle) == "function" then
        VD_AICCTV_PositionCircle(circle, myHRP, radius)
    end
    circle.Transparency = 0.35

    -- scan killer terdekat YANG MASUK LINGKARAN
    local nearest, nearestDist, kHRP = VD_GetKillerInsideCircle(myHRP, radius)

    if nearest and kHRP then
        VD_AICCTV.Ready = true
        VD_AICCTV.Threat = nearest
        VD_AICCTV.ThreatDist = nearestDist
        local facingAngle = tonumber(VD.SURV_ParryFacingAngle) or 60
        local facingMe = VD_IsKillerFacingMe(kHRP, myHRP, facingAngle, nearest)
        -- V21: LOCK cuma kalau ada animation attack BENERAN + ngarah ke kita + dalam jangkauan hit
        local attacking = VD_IsKillerAttacking(nearest)
        local inHitRange = VD_IsKillerInHitRange(nearest, myHRP, nearestDist)
        VD_AICCTV.ThreatFacing = attacking and facingMe and inHitRange
        VD_AICCTV.ThreatAttacking = attacking
        VD_AICCTV.ThreatInRange = inHitRange
        VD_AICCTV.ThreatCharge = VD_IsKillerChargingMe(nearest, myHRP)
        VD_AICCTV.Method = "AI HARD"

        -- warna lingkaran: merah kalau LOCK (attack beneran ke kita), kuning kalau belum attack
        circle.Color3 = VD_AICCTV.ThreatFacing and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 80, 80)
    else
        VD_AICCTV.Ready = false
        VD_AICCTV.Threat = nil
        VD_AICCTV.ThreatDist = math.huge
        VD_AICCTV.ThreatFacing = false
        VD_AICCTV.ThreatCharge = false
        circle.Color3 = Color3.fromRGB(80, 80, 80)
    end

    VD_AICCTV_UpdateHUD()
end

function VD_AICCTV_Start()
    if VD_AICCTV.Heartbeat then return end
    VD_AICCTV.Active = true
    VD_AICCTV.Heartbeat = RunService.Heartbeat:Connect(function()
        pcall(VD_AICCTV_Update)
    end)
end

function VD_AICCTV_Stop()
    VD_AICCTV.Active = false
    if VD_AICCTV.Heartbeat then
        VD_AICCTV.Heartbeat:Disconnect()
        VD_AICCTV.Heartbeat = nil
    end
    if VD_AICCTV.Circle then VD_AICCTV.Circle:Destroy(); VD_AICCTV.Circle = nil end
    if VD_AICCTV.Gui then VD_AICCTV.Gui:Destroy(); VD_AICCTV.Gui = nil end
    VD_AICCTV.Ready = false
    VD_AICCTV.Threat = nil
end

function VD_SetAICCTV(state)
    VD.SURV_AICCTV = state == true
    if VD.SURV_AICCTV then
        VD_AICCTV_Start()
    else
        VD_AICCTV_Stop()
    end
end

-- ==================== V19 AI HARD PARRY ENGINE ====================
-- Ini otak Auto Parry. Dipanggil tiap Heartbeat selama Auto Parry ON.
-- Logika:
--   1) Cari killer yang MASUK lingkaran/outline (radius AI).
--   2) Kalau ga ada killer di dalam lingkaran -> JANGAN parry (fix bug).
--   3) Kalau ada, baca arah attack (hadap/mata + charge).
--   4) Kalau beneran ngarah ke kita -> parry secepatnya (dengan cooldown).
VD_AIParry = {
    Heartbeat = nil,
    LastFire  = 0,
    LastThreat = nil,
}

function VD_AIParry_Update()
    if not VD.SURV_AutoParry then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
    if State.ParryCooldown then return end

    local radius = VD_GetAIParryRadius()

    -- V20: lingkaran/outline REAPER X selalu ngikutin player selama Auto Parry ON (gaya Zian)
    if type(VD_AICCTV_EnsureCircle) == "function" then
        local circle = VD_AICCTV_EnsureCircle()
        if circle then
            if type(VD_AICCTV_PositionCircle) == "function" then
                VD_AICCTV_PositionCircle(circle, myHRP, radius)
            end
            circle.Transparency = 0.35
        end
    end

    -- (1) killer WAJIB di dalam lingkaran/outline
    local killer, dist, kHRP = VD_GetKillerInsideCircle(myHRP, radius)
    if not killer or not kHRP then
        VD_AIParry.LastThreat = nil
        -- V20: HUD REAPER X -> STANDBY (ga ada killer di dalam lingkaran)
        VD_AICCTV.Ready = false
        VD_AICCTV.Threat = nil
        VD_AICCTV.ThreatDist = math.huge
        VD_AICCTV.ThreatFacing = false
        if type(VD_AICCTV_EnsureCircle) == "function" and VD_AICCTV.Circle then
            VD_AICCTV.Circle.Color3 = Color3.fromRGB(80, 80, 80)
        end
        pcall(VD_AICCTV_UpdateHUD)
        return
    end
    VD_AIParry.LastThreat = killer

    -- (2) V21: AI baca ANIMATION ATTACK BENERAN dari killer (model 3D di server).
    -- Killer cuma gerak/hadap TANPA main animation attack -> JANGAN parry.
    local attacking = VD_IsKillerAttacking(killer)

    -- (3) baca arah attack killer (hadap/mata + charge) — cuma dipakai kalau lagi attack
    local facingAngle = tonumber(VD.SURV_ParryFacingAngle) or 60
    local facingMe = VD_IsKillerFacingMe(kHRP, myHRP, facingAngle, killer)
    local charging = VD_IsKillerChargingMe(killer, myHRP)
    pcall(VD_UpdateHitDirVisual, killer, myHRP, facingMe)

    -- FIX BUG "parry dari jauh": killer di dalam lingkaran besar (mis. 19) tapi masih
    -- jauh dari player -> JANGAN parry. Parry cuma kalau killer BENERAN dalam jangkauan hit.
    -- Attack yang bisa DITAHAN (lari sambil jalan / charging) boleh agak lebih jauh.
    local inHitRange = VD_IsKillerInHitRange(killer, myHRP, dist)

    -- V22 FIX "parry LAMA di outline kecil (8/9/11/12)": kalau lingkaran kecil, killer
    -- udah masuk lingkaran = udah cukup deket. Jangan nunggu dia "hadap" sempurna
    -- (facing gate bikin parry kerasa lama). Cukup animation attack BENERAN + di lingkaran.
    local smallCircle = radius <= VD_SMALL_CIRCLE
    local facingOk = facingMe or charging or smallCircle
    -- Anti Fake Parry OFF -> cek arah hadap dilewati (parry cukup animasi attack + di lingkaran)
    if VD.SURV_ParryAntiFake == false then facingOk = true end

    -- V20/V21: HUD REAPER X -> READY / LOCK
    -- LOCK (merah) = killer di dalam lingkaran DAN lagi main animation attack DAN ngarah ke kita
    local locked = attacking and facingOk and inHitRange
    VD_AICCTV.Ready = true
    VD_AICCTV.Threat = killer
    VD_AICCTV.ThreatDist = dist
    VD_AICCTV.ThreatFacing = locked
    VD_AICCTV.ThreatAttacking = attacking
    VD_AICCTV.ThreatInRange = inHitRange
    if VD_AICCTV.Circle then
        VD_AICCTV.Circle.Color3 = locked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(80, 80, 80)
    end
    pcall(VD_AICCTV_UpdateHUD)

    -- (4) PARRY cuma kalau: killer di dalam lingkaran + animation attack BENERAN +
    --     ngarah ke kita + BENERAN dalam jangkauan hit (bukan cuma di dalam lingkaran besar).
    if attacking and facingOk and inHitRange then
        local now = os.clock()
        -- FIX: cooldown dinamis — lingkaran kecil = parry lebih gesit
        if now - VD_AIParry.LastFire >= VD_GetAIParryCooldown() then
            ExecuteParry()
            VD_AIParry.LastFire = now
        end
    end
end

function VD_AIParry_Start()
    if VD_AIParry.Heartbeat then return end
    VD_AIParry.Heartbeat = RunService.Heartbeat:Connect(function()
        pcall(VD_AIParry_Update)
    end)
end

function VD_AIParry_Stop()
    if VD_AIParry.Heartbeat then
        VD_AIParry.Heartbeat:Disconnect()
        VD_AIParry.Heartbeat = nil
    end
    VD_AIParry.LastThreat = nil
    -- V20: bersihin lingkaran + HUD REAPER X kalau AI CCTV juga mati
    if not VD.SURV_AICCTV then
        if VD_AICCTV.Circle then VD_AICCTV.Circle:Destroy(); VD_AICCTV.Circle = nil end
        if VD_AICCTV.Gui then VD_AICCTV.Gui.Enabled = false end
    end
end


local player = LocalPlayer
-- ==================== AUTO PARRY SENSOR ====================
function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob
        and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")

    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        pcall(function()
            if mouse2click then
                mouse2click()
                return
            end
            if mouse2press and mouse2release then
                mouse2press()
                task.wait(0.01)
                mouse2release()
                return
            end
            if MouseButton2Click then
                MouseButton2Click()
                return
            end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
        
        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end)
        end
    end)
end
ListenToParryResult()

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)

    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        
        -- Auto Crouch untuk Abyssal S1
        if id == "80411309607666" and VD.AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then
                    TriggerCrouch()
                end
            end
            return 
        end
        
        local attackName = VD_ATTACK_ANIMS[animId]
        if not attackName then return end

        -- V21: AI catat animation attack BENERAN dari killer (model 3D di server).
        -- Ini yang bikin AI tau killer lagi attack (bukan cuma gerak/hadap).
        VD_MarkKillerAttack(kChar, animId)

        -- V17: rekam event attack buat Parry Camera (biar kamera tau killer lagi attack)
        VD_ParryCam.AttackActive = os.clock()
        VD_ParryCam.AttackKiller = kChar
        if VD.SURV_ParryCamera then
            local myCharCam = LocalPlayer.Character
            local myHRPCam = myCharCam and myCharCam:FindFirstChild("HumanoidRootPart")
            local kHRPCam = kChar:FindFirstChild("HumanoidRootPart")
            if myHRPCam and kHRPCam then
                -- V19 FIX: killer WAJIB di dalam lingkaran/outline AI dulu.
                -- Kalau di luar lingkaran (walau menghadap kita) -> NO PARRY.
                local aiRadius = VD_GetAIParryRadius()
                local killerDist = (kHRPCam.Position - myHRPCam.Position).Magnitude
                -- FIX BUG "parry dari jauh": WAJIB di dalam lingkaran DAN dalam jangkauan hit.
                if killerDist <= aiRadius and VD_IsKillerInHitRange(kChar, myHRPCam, killerDist) then
                    local fov = tonumber(VD.SURV_ParryCamFOV) or 70
                    local toward = VD_ParryCam_IsAttackTowardMe(kChar, myHRPCam, fov)
                    if toward and VD.SURV_AutoParry and not State.ParryCooldown and not IsDowned(myCharCam) then
                        local nowCam = os.clock()
                        if nowCam - VD_ParryCam.LastFire >= 0.12 then
                            ExecuteParry()
                            VD_ParryCam.LastFire = nowCam
                        end
                    end
                end
            end
        end

        if not VD.SURV_AutoParry then return end
        if State.ParryCooldown then return end 
        if VD.Ignored_Skills_List and VD.Ignored_Skills_List[attackName] then return end

        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        
        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        -- ===== V19 AI HARD: killer WAJIB di dalam lingkaran/outline dulu =====
        -- FIX BUG: dulu killer di luar lingkaran tapi menghadap kita langsung parry
        -- walau jarak jauh. Sekarang kalau killer di LUAR lingkaran -> NO PARRY.
        local aiRadius = VD_GetAIParryRadius()
        if startDistance > aiRadius then
            return
        end

        -- FIX BUG "parry dari jauh": WAJIB beneran dalam jangkauan hit (bukan cuma di
        -- dalam lingkaran besar). Attack yang bisa ditahan (lari sambil jalan) boleh lebih jauh.
        if not VD_IsKillerInHitRange(kChar, myHRP, startDistance) then
            return
        end

        -- V16: Anti Fake Hit — killer harus benar-benar menghadap kita.
        -- V22 FIX: kalau lingkaran kecil (8/9/11/12), killer udah masuk lingkaran =
        -- udah cukup deket -> parry langsung (ga nunggu hadap sempurna, biar ga LAMA).
        local antiFake = VD.SURV_ParryAntiFake ~= false
        local facingAngle = tonumber(VD.SURV_ParryFacingAngle) or 60
        local facingMe = VD_IsKillerFacingMe(kHRP, myHRP, facingAngle, kChar)
        local charging = VD_IsKillerChargingMe(kChar, myHRP)
        pcall(VD_UpdateHitDirVisual, kChar, myHRP, facingMe)
        local smallCircle = aiRadius <= VD_SMALL_CIRCLE
        if antiFake and not facingMe and not charging and not smallCircle then
            return
        end

        -- Killer udah di dalam lingkaran + menghadap kita -> parry.
        ExecuteParry()
    end)
end

function TryAttach(p)
    if p ~= player and IsKiller(p) and p.Character then 
        AttachParrySensor(p.Character) 
    end
end

function SetupPlayer(p)
    if p == player then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

-- Setup Parry Sensor
for _, p in pairs(Players:GetPlayers()) do 
    SetupPlayer(p) 
end
Players.PlayerAdded:Connect(SetupPlayer)

task.spawn(function()
    while true do 
        task.wait(5) 
        for _, p in pairs(Players:GetPlayers()) do 
            TryAttach(p) 
        end 
    end
end)

-- V16: Update garis arah hit killer terus-menerus (biar keliatan walau belum attack)
task.spawn(function()
    while true do
        task.wait(0.1)
        if VD.SURV_ParryShowHitDir then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                -- cari killer terdekat
                local nearest, nearestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and IsKiller(p) and p.Character then
                        local r = p.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local d = (r.Position - myHRP.Position).Magnitude
                            if d < nearestDist then nearestDist = d; nearest = p.Character end
                        end
                    end
                end
                if nearest then
                    local kHRP = nearest:FindFirstChild("HumanoidRootPart")
                    local facingAngle = tonumber(VD.SURV_ParryFacingAngle) or 60
                    local isReal = VD_IsKillerFacingMe(kHRP, myHRP, facingAngle, nearest)
                    pcall(VD_UpdateHitDirVisual, nearest, myHRP, isReal)
                end
            end
        else
            if getgenv().VD_HitDirPart then getgenv().VD_HitDirPart.Transparency = 1 end
            if getgenv().VD_HitDirPart2 then getgenv().VD_HitDirPart2.Transparency = 1 end
        end
    end
end)


function VD_SetAutoParry(state)
    VD.SURV_AutoParry = state == true
    if VD.SURV_AutoParry then
        -- ===== V20: AUTO PARRY AI — user cuma ON/OFF + radius =====
        -- Semua setting lain dipaksa ON otomatis (AI yang atur di server):
        VD.SURV_ParryFacingAngle = 60     -- cone hadap default (AI baca arah attack)
        VD.SURV_ParryCamPredict = true    -- prediksi arah attack dari animasi
        VD.SURV_AICCTVShowHUD   = false   -- HUD dihapus
        -- Radius CCTV = radius lingkaran (biar sinkron)
        VD.SURV_AICCTVRadius    = tonumber(VD.SURV_AIParryRadius) or 20

        if not _G.VD_ParryRenderConnection then
            _G.VD_ParryRenderConnection = game:GetService('RunService').RenderStepped:Connect(function()
                if type(VD_UpdateParryRange) == 'function' then VD_UpdateParryRange() end
            end)
        end
        -- V19: nyalain AI HARD engine (otak Auto Parry)
        if type(VD_AIParry_Start) == "function" then pcall(VD_AIParry_Start) end
        -- V20: tampilkan HUD REAPER X + lingkaran selama Auto Parry ON
        if type(VD_AICCTV_EnsureHUD) == "function" then pcall(VD_AICCTV_EnsureHUD) end
        if type(VD_AICCTV_UpdateHUD) == "function" then pcall(VD_AICCTV_UpdateHUD) end
    else
        if typeof(VD_ParryRange) == 'Instance' then VD_ParryRange.Transparency = 1 end
        if _G.VD_ParryRenderConnection then
            _G.VD_ParryRenderConnection:Disconnect()
            _G.VD_ParryRenderConnection = nil
        end
        -- V19: matiin AI HARD engine
        if type(VD_AIParry_Stop) == "function" then pcall(VD_AIParry_Stop) end
        -- V20: matiin AI CCTV (kalau nyala) + sembunyikan HUD REAPER X
        if VD.SURV_AICCTV and type(VD_AICCTV_Stop) == "function" then pcall(VD_AICCTV_Stop) end
        if VD_AICCTV.Gui then VD_AICCTV.Gui.Enabled = false end
    end
end


end) -- akhir pcall load Auto Parry AI

if not okAI then
    warn("[Auto Parry AI] gagal load: " .. tostring(errAI))
end

local AutoParryAISection = ParryAIExclusiveSection -- section dibuat di paling atas tab Exclusive

AutoParryAISection:AddParagraph({
    Title = "⚠️ PENTING",
    Content = "Jangan dinyalakan bersamaan dengan Auto Parry biasa (parry jadi dobel). Pilih salah satu."
})

AutoParryAISection:AddToggle({
    Title = "Auto Parry AI",
    Content = "AI baca animasi serangan killer, parry hanya kalau killer masuk radius & benar-benar mengarah ke kamu",
    Default = false,
    Keybind = true,
    Callback = function(v)
        if type(VD_SetAutoParry) == "function" then
            pcall(VD_SetAutoParry, v)
        end
    end
})

AutoParryAISection:AddToggle({
    Title = "Anti Fake Parry",
    Content = "Abaikan fake hit: parry hanya kalau killer benar-benar menghadap / charging ke kamu",
    Default = true,
    Callback = function(v)
        VD.SURV_ParryAntiFake = v
    end
})

AutoParryAISection:AddInput({
    Title = "Radius AI (studs)",
    Default = "20",
    Placeholder = "Write ur input here...",
    Callback = function(v)
        local n = tonumber(v)
        if not n then return end
        n = math.clamp(n, 4, 60)
        VD.SURV_AIParryRadius = n
        VD.SURV_AICCTVRadius  = n
    end
})

AutoParryAISection:AddToggle({
    Title = "Lingkaran Radius AI",
    Content = "Visual lingkaran radius parry AI",
    Default = false,
    Callback = function(v)
        VD.SURV_ShowParryCircle = v
    end
})

AutoParryAISection:AddToggle({
    Title = "AI CCTV",
    Content = "Pantau killer di dalam lingkaran",
    Default = false,
    Callback = function(v)
        if type(VD_SetAICCTV) == "function" then
            pcall(VD_SetAICCTV, v)
        end
    end
})

AutoParryAISection:AddToggle({
    Title = "Garis Arah Hit",
    Content = "Garis arah serang killer (merah = ke kamu, abu = fake)",
    Default = false,
    Callback = function(v)
        VD.SURV_ParryShowHitDir = v
    end
})

AutoParryAISection:AddToggle({
    Title = "Parry Camera",
    Content = "Kamera virtual yang mengunci killer dan membaca arah serangan",
    Default = false,
    Callback = function(v)
        if type(VD_SetParryCamera) == "function" then
            pcall(VD_SetParryCamera, v)
        end
    end
})


end


;(function() -- RynerHUB: pecah blok besar jadi closure supaya tidak kena batas 200 local per fungsi

SurvUtilitySection = Tabs.Utility:AddSection("Survivor Utility")
    local FakePerks = {
    QuickRecoveryEnabled = false,
    PerfectLandingEnabled = false,
    FlowstateEnabled = false,

    PerkCooldown = 10,

    boostActive = false,
    perfectLandingBoostActive = false,
    fsOnCooldown = false,

    lastQRTime = 0,
    lastPLTime = 0,
    lastFSTime = 0,

    qrConnection = nil,
    plConnection = nil,
    fsConnection = nil,
    fsAnimConnection = nil,
}

local function IsSurvivorFake()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
end

local function isSlowVaulting(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Animation and string.find(tostring(track.Animation.AnimationId), "126081405469607") then
            return true
        end
    end
    return false
end

local function applyQuickRecovery(char)
    if not FakePerks.QuickRecoveryEnabled then return end
    if not IsSurvivorFake() then return end
    if FakePerks.boostActive then return end
    if (tick() - FakePerks.lastQRTime) < FakePerks.PerkCooldown then return end

    FakePerks.boostActive = true
    FakePerks.lastQRTime = tick()
    local startTime = tick()

    task.spawn(function()
        while FakePerks.QuickRecoveryEnabled and (tick() - startTime) < 3 do
            if char and char.Parent then
                char:SetAttribute("speedboost", 1.4)
            end
            task.wait()
        end
        if char and char.Parent then
            char:SetAttribute("speedboost", 1)
        end
        FakePerks.boostActive = false
    end)
end

local function setupQuickRecovery(char)
    if FakePerks.qrConnection then
        FakePerks.qrConnection:Disconnect()
        FakePerks.qrConnection = nil
    end
    if not char then return end

    FakePerks.qrConnection = char:GetAttributeChangedSignal("isvaulting"):Connect(function()
        if char:GetAttribute("isvaulting") == true then
            task.spawn(function()
                task.wait(0.05)
                local isSlow = isSlowVaulting(char)
                if not isSlow then
                    task.wait(0.05)
                    isSlow = isSlowVaulting(char)
                end
                if not isSlow and char:GetAttribute("isvaulting") == true then
                    applyQuickRecovery(char)
                end
            end)
        end
    end)
end

local function applyPerfectLanding(char)
    if not FakePerks.PerfectLandingEnabled then return end
    if not IsSurvivorFake() then return end
    if FakePerks.perfectLandingBoostActive then return end
    if (tick() - FakePerks.lastPLTime) < FakePerks.PerkCooldown then return end

    FakePerks.perfectLandingBoostActive = true
    FakePerks.lastPLTime = tick()
    local startTime = tick()

    task.spawn(function()
        while FakePerks.perfectLandingBoostActive and (tick() - startTime) < 3 do
            if char and char.Parent then
                char:SetAttribute("speedboost", 1.4)
            end
            task.wait()
        end
        if char and char.Parent then
            char:SetAttribute("speedboost", 1)
        end
        FakePerks.perfectLandingBoostActive = false
    end)
end

local function setupPerfectLanding(char)
    if FakePerks.plConnection then
        FakePerks.plConnection:Disconnect()
        FakePerks.plConnection = nil
    end
    if not char then return end

    FakePerks.plConnection = char:GetAttributeChangedSignal("speedboost"):Connect(function()
        if not IsSurvivorFake() then return end
        local currentBoost = char:GetAttribute("speedboost")
        if currentBoost == 0.625 then
            applyPerfectLanding(char)
        end
    end)
end

local function tryApplyFlowstate(char)
    if not FakePerks.FlowstateEnabled then return end
    if not char or not char.Parent then return end
    if not IsSurvivorFake() then return end
    if FakePerks.fsOnCooldown then return end
    if (tick() - FakePerks.lastFSTime) < FakePerks.PerkCooldown then return end

    char:SetAttribute("Flowstate", true)
end

local function setupFlowstate(char)
    if FakePerks.fsConnection then
        FakePerks.fsConnection:Disconnect()
        FakePerks.fsConnection = nil
    end
    if FakePerks.fsAnimConnection then
        FakePerks.fsAnimConnection:Disconnect()
        FakePerks.fsAnimConnection = nil
    end
    if not char then return end

    local humanoid = char:WaitForChild("Humanoid", 3)
    if not humanoid then return end
    local animator = humanoid:WaitForChild("Animator", 3)
    if not animator then return end

    FakePerks.fsAnimConnection = animator.AnimationPlayed:Connect(function(track)
        if not track.Animation then return end
        if track.Animation.AnimationId ~= "rbxassetid://136962284480779" then return end

        local stoppedConn
        stoppedConn = track.Stopped:Connect(function()
            if stoppedConn then stoppedConn:Disconnect() end
            FakePerks.lastFSTime = tick()
            FakePerks.fsOnCooldown = true
            if char and char.Parent then
                char:SetAttribute("Flowstate", false)
            end
            task.delay(FakePerks.PerkCooldown, function()
                FakePerks.fsOnCooldown = false
                if FakePerks.FlowstateEnabled and char and char.Parent then
                    char:SetAttribute("Flowstate", true)
                end
            end)
        end)
    end)

    FakePerks.fsConnection = char:GetAttributeChangedSignal("Flowstate"):Connect(function()
        if not FakePerks.FlowstateEnabled then return end
        if not IsSurvivorFake() then return end
        local current = char:GetAttribute("Flowstate")
        if current == true then
            if FakePerks.fsOnCooldown or (tick() - FakePerks.lastFSTime) < FakePerks.PerkCooldown then
                char:SetAttribute("Flowstate", false)
            end
        elseif current == false then
            if not FakePerks.fsOnCooldown and (tick() - FakePerks.lastFSTime) >= FakePerks.PerkCooldown then
                char:SetAttribute("Flowstate", true)
            end
        end
    end)

    task.wait(0.5)
    if FakePerks.FlowstateEnabled and char and char.Parent then
        char:SetAttribute("Flowstate", true)
    end
end

local function onCharacterAddedFake(char)
    task.wait(0.5)
    if FakePerks.QuickRecoveryEnabled then setupQuickRecovery(char) end
    if FakePerks.PerfectLandingEnabled then setupPerfectLanding(char) end
    if FakePerks.FlowstateEnabled then setupFlowstate(char) end
end

-- Init
if LocalPlayer.Character then
    onCharacterAddedFake(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAddedFake)

SurvUtilitySection:AddToggle({
    Title = "Fake Quick Recovery",
    Content = "Speed boost 1.4x selama 3 detik setelah vault cepat",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        FakePerks.QuickRecoveryEnabled = Value
        if Value and LocalPlayer.Character then
            setupQuickRecovery(LocalPlayer.Character)
        elseif not Value and FakePerks.qrConnection then
            FakePerks.qrConnection:Disconnect()
            FakePerks.qrConnection = nil
        end
    end
})

SurvUtilitySection:AddToggle({
    Title = "Fake Perfect Landing",
    Content = "Speed boost 1.4x selama 3 detik setelah landing",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        FakePerks.PerfectLandingEnabled = Value
        if Value then
            if LocalPlayer.Character then setupPerfectLanding(LocalPlayer.Character) end
        else
            if FakePerks.plConnection then
                FakePerks.plConnection:Disconnect()
                FakePerks.plConnection = nil
            end
            if FakePerks.perfectLandingBoostActive and LocalPlayer.Character then
                LocalPlayer.Character:SetAttribute("speedboost", 1)
                FakePerks.perfectLandingBoostActive = false
            end
        end
    end
})

SurvUtilitySection:AddToggle({
    Title = "Fake Flowstate",
    Content = "Flowstate unlimited dengan cooldown realistis",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        FakePerks.FlowstateEnabled = Value
        if Value then
            if LocalPlayer.Character then setupFlowstate(LocalPlayer.Character) end
        else
            if FakePerks.fsConnection then
                FakePerks.fsConnection:Disconnect()
                FakePerks.fsConnection = nil
            end
            if FakePerks.fsAnimConnection then
                FakePerks.fsAnimConnection:Disconnect()
                FakePerks.fsAnimConnection = nil
            end
            if LocalPlayer.Character then
                LocalPlayer.Character:SetAttribute("Flowstate", false)
            end
        end
    end
})

SurvUtilitySection:AddSlider({
    Title = "Perks Cooldown (detik)",
    Min = 0,
    Max = 180,
    Default = 10,
    Callback = function(Value)
        FakePerks.PerkCooldown = Value
        if FakePerks.FlowstateEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
            char:SetAttribute("Flowstate", true)
            FakePerks.fsOnCooldown = false
            FakePerks.lastFSTime = tick()
        end
    end
})

-- === Fake Perk Tambahan: Snake Step / Adrenalin / Great Collapse (AUTO) ===
do
    local FP_New = {
        SnakeStep        = false,
        Adrenalin        = false,
        GreatCollapse    = false,
        AdrenCooldown    = 0,
        CollapseCooldown = 0,
        Running          = false,
    }

    local function FP_ResetChar(char)
        if not char then return end
        pcall(function() char:SetAttribute("speedboost", 1) end)
    end

    local function FP_ApplyLoop()
        if FP_New.Running then return end
        FP_New.Running = true

        local acc = 0
        RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < 0.05 then return end
            acc = 0

            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end

            local now = tick()
            local mult = 1.0

            if FP_New.SnakeStep then
                local isCrouch = char:GetAttribute("Crouching") == true
                    or char:GetAttribute("Crouchingserver") == true
                    or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                if isCrouch then
                    mult = mult * 1.7
                end
            end

            if FP_New.Adrenalin and now < FP_New.AdrenCooldown then
                local elapsed = 10 - (FP_New.AdrenCooldown - now)
                if elapsed <= 10 then
                    mult = mult * 1.07
                else
                    mult = mult * 0.9345
                end
            end

            if FP_New.GreatCollapse and now < FP_New.CollapseCooldown then
                mult = mult * 1.3
            end

            mult = math.clamp(mult, 0.5, 2.5)

            local current = char:GetAttribute("speedboost")
            if current == nil or math.abs(current - mult) > 0.01 then
                pcall(function() char:SetAttribute("speedboost", mult) end)
            end
        end)
    end

    SurvUtilitySection:AddToggle({
        Title = "Snake Step",
        Content = "Crouch (Ctrl) -> speed +70%",
        Default = false,
        Keybind = true,
        Callback = function(v)
            FP_New.SnakeStep = v
            if v then
                FP_ApplyLoop()
                notif("Snake Step: ON")
            else
                notif("Snake Step: OFF")
            end
        end
    })

    SurvUtilitySection:AddToggle({
        Title = "Adrenalin Rush",
        Content = "+7% (10s) lalu -6.5% (3s)",
        Default = false,
        Keybind = true,
        Callback = function(v)
            FP_New.Adrenalin = v
            if v then
                FP_New.AdrenCooldown = tick() + 13
                FP_ApplyLoop()
                notif("Adrenalin Rush: ON")
            else
                notif("Adrenalin Rush: OFF")
            end
        end
    })

    SurvUtilitySection:AddToggle({
        Title = "Great Collapse",
        Content = "Auto: pas berhasil stun killer pakai pallet -> +30% (3s)",
        Default = false,
        Keybind = false,
        Callback = function(v)
            FP_New.GreatCollapse = v
            if v then
                FP_ApplyLoop()
                notif("Great Collapse: ON (auto-trigger pas stun)")
            else
                notif("Great Collapse: OFF")
            end
        end
    })

    local STUN_ANIMS = {
        ["rbxassetid://123809268724645"] = true,
        ["rbxassetid://102055678391920"] = true,
        ["rbxassetid://88848807662765"] = true,
    }

    local function FP_AttachStunSensor(kChar)
        if not kChar or kChar:GetAttribute("Nyx_FP_Attached") then return end
        kChar:SetAttribute("Nyx_FP_Attached", true)

        local hum = kChar:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = kChar:WaitForChild("Humanoid", 5)
            if not hum then return end
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = hum:WaitForChild("Animator", 5)
            if not animator then return end
        end

        -- Auto-trigger Great Collapse (TANPA notif, biar ga spam)
        animator.AnimationPlayed:Connect(function(track)
            if not FP_New.GreatCollapse then return end
            local animId = track.Animation and track.Animation.AnimationId or ""
            if STUN_ANIMS[animId] then
                FP_New.CollapseCooldown = tick() + 3
            end
        end)

        kChar:GetAttributeChangedSignal("IsStunned"):Connect(function()
            if not FP_New.GreatCollapse then return end
            if kChar:GetAttribute("IsStunned") == true then
                FP_New.CollapseCooldown = tick() + 3
            end
        end)

        kChar:GetAttributeChangedSignal("IsPalletStunned"):Connect(function()
            if not FP_New.GreatCollapse then return end
            if kChar:GetAttribute("IsPalletStunned") == true then
                FP_New.CollapseCooldown = tick() + 3
            end
        end)
    end

    local function FP_ScanKillers()
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Team and pl.Team.Name == "Killer" and pl.Character then
                FP_AttachStunSensor(pl.Character)
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(3)
            if FP_New.GreatCollapse then
                FP_ScanKillers()
            end
        end
    end)

    Players.PlayerAdded:Connect(function(pl)
        pl.CharacterAdded:Connect(function()
            task.wait(1)
            if FP_New.GreatCollapse then FP_ScanKillers() end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        FP_ResetChar(char)
    end)
end

    
    local NoFallEnabled = false
    local FallEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")

    local rawMT = getrawmetatable(game)
    local oldNamecall = rawMT.__namecall
    setreadonly(rawMT, false)

    rawMT.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if NoFallEnabled and self == FallEvent and (method == "FireServer" or method == "fireServer") then
            args[1] = 0 
            return oldNamecall(self, unpack(args))
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(rawMT, true)
    local fovValue = 70
    local fovLocked = false
    local fovConnection = nil

    setFOV = function(value)
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = value
        end
    end

    lockFOV = function()
        if fovConnection then fovConnection:Disconnect() end
        
        fovConnection = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if fovLocked then
                setFOV(fovValue)
            end
        end)
    end

    SurvUtilitySection:AddSlider({
        Title = "FOV",
        Min = 40,
        Max = 140,
        Default = 70,
        Callback = function(value)
            fovValue = value
            setFOV(value)
        end
    })
    SurvUtilitySection:AddToggle({
        Title = "Lock FOV",
        Default = false,
        Callback = function(v)
            fovLocked = v
            if v then
                setFOV(fovValue)
                lockFOV()
            else
                if fovConnection then
                    fovConnection:Disconnect()
                    fovConnection = nil
                end
                setFOV(70)
            end
        end
    })
    SurvUtilitySection:AddDivider()
    SurvUtilitySection:AddToggle({
        Title = "No Fall Damage",
        Default = false,
        Callback = function(state)
            NoFallEnabled = state
        end
    })
    
    SurvUtilitySection:AddToggle({
        Title = "Force Kick Killer",
        Default = false,
        Callback = function(v)
            if forceKickConn then
                forceKickConn:Disconnect()
                forceKickConn = nil
            end
            if not v then return end

            forceKickConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                if not char:GetAttribute("IsCarried") then return end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end

                hum.Health = 0
            end)
        end
    })
    SurvUtilitySection:AddToggle({
        Title = "Flee Killer (Auto Menjauh)",
        Default = false,
        Callback = function(state)
            FleeEnabled = state
            if state then
                StartFlee()
            else
                if FleeThread then task.cancel(FleeThread) end
            end
        end
    })
    SurvUtilitySection:AddInput({
        Title = "Flee Distance (studs)",
        Default = "40",
        Placeholder = "Write ur input here...",
        Callback = function(input)
            local num = tonumber(input)
            if num then FleeDist = num end
        end
    })
    SurvUtilitySection:AddToggle({
        Title = "God Mode",
        Default = false,
        Keybind = true,
        Callback = function(state)
            GodModeEnabled = state
            notif("Godmode ".. (state and "Aktif" or "Nonaktif"))
    
            if state then
                StartGodMode()
            else
                if GodModeThread then task.cancel(GodModeThread) end
            end
        end
    })

local isAutoHealActive = false
local healAnimListener = nil

local function suppressHealingAnimation()
    if healAnimListener then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    healAnimListener = animator.AnimationPlayed:Connect(function(activeTrack)
        if activeTrack.Animation and activeTrack.Animation.AnimationId:find("95836365038528") then
            activeTrack:Stop(0)
        end
    end)
end

local function restoreHealingAnimation()
    if healAnimListener then
        pcall(function() healAnimListener:Disconnect() end)
        healAnimListener = nil
    end
end

-- Looping langsung tanpa fungsi terpisah
task.spawn(function()
    while true do
        task.wait(3)
        if isAutoHealActive then
            if LocalPlayer.Team.Name ~= "Killer" then
                local character = LocalPlayer.Character
                if character then
                    local interactState = character:FindFirstChild("CheckInterractable")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    local isBusy = false
                    if interactState then
                        if interactState:GetAttribute("isVaulting") 
                        or interactState:GetAttribute("isRepairing") 
                        or interactState:GetAttribute("isUnhooking") 
                        or interactState:GetAttribute("isHealing") 
                        or interactState:GetAttribute("isSliding") then
                            isBusy = true
                        end
                    end

                    if not isBusy and rootPart and humanoid and humanoid.Health < humanoid.MaxHealth then
                        pcall(function()
                            local remoteService = ReplicatedStorage:FindFirstChild("Remotes")
                            if remoteService and remoteService:FindFirstChild("Healing") then
                                remoteService.Healing.HealEvent:FireServer(rootPart, true)
                            end
                        end)
                    end
                end
            end
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    restoreHealingAnimation()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(5)
    if isAutoHealActive then
        suppressHealingAnimation()
    end
end)

_G.toggleHealthSystem = function(state)
    SelfHealToggle:Set(not SelfHealToggle.Value)
end

SelfHealToggle = SurvUtilitySection:AddToggle({
    Title = "Self Heal",
    Default = false,
    Keybind = true,
    Callback = function(state)
        if IsKiller() then
            SendNotif("you must be a survivors!")
            return
        end
        
        isAutoHealActive = state
        if state then
            suppressHealingAnimation()
        else
            restoreHealingAnimation()
        end
        SendNotif("self heal: " .. (state and "enabled" or "disabled"))
    end
})

local autoVaultEnabled = false
    local lastActionTime = 0
    local COOLDOWN = 1.5

    SurvUtilitySection:AddToggle({
        Title = "Auto Vault",
        Default = false,
        Callback = function(v)
            autoVaultEnabled = v
        end
    })

task.spawn(function()
    while true do
        if autoVaultEnabled and not UserInputService.TouchEnabled then
            if (tick() - lastActionTime) >= COOLDOWN then
                local pcPrompts = PlayerGui:FindFirstChild("pcprompts")
                if pcPrompts and pcPrompts.Frame then
                    local frame = pcPrompts.Frame
                    if (frame:FindFirstChild("VaultPromptGui") and frame.VaultPromptGui.Visible) or
                    (frame:FindFirstChild("PalletSlidePromptGui") and frame.PalletSlidePromptGui.Visible) then
                        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        lastActionTime = tick()
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

local function setupMobileVault()
    if not UserInputService.TouchEnabled then return end

    local mobileGui = PlayerGui:WaitForChild("Survivor-mob", 10)
    local controls = mobileGui and mobileGui:WaitForChild("Controls", 5)
    local action = controls and controls:WaitForChild("action", 5)
    if not action then return end

    local allowedNames = {["vault"] = true, ["palletvault"] = true}

    local function connectLabel(child)
        if not child:IsA("ImageLabel") then return end
        if not allowedNames[child.Name:lower()] then return end

        child:GetPropertyChangedSignal("Visible"):Connect(function()
            if not child.Visible then return end
            if not autoVaultEnabled or not UserInputService.TouchEnabled then return end
            if (tick() - lastActionTime) < COOLDOWN then return end

            pcall(function()
                firesignal(action.MouseButton1Down)
                task.wait(0.01)
                firesignal(action.MouseButton1Up)
            end)
            lastActionTime = tick()
        end)
    end

    for _, child in pairs(action:GetChildren()) do
        connectLabel(child)
    end

    action.ChildAdded:Connect(function(child)
        task.wait()
        connectLabel(child)
    end)
end

task.spawn(setupMobileVault)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    setupMobileVault()
end)

PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "Survivor-mob" then
        task.wait(1)
        setupMobileVault()
    end
end)

local FastVaultEnabled = false
local FastVaultSpeed = 1.3

local function ApplyFastVault(state)
    FastVaultEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    if state then
        char:SetAttribute("vaultspeed", FastVaultSpeed)
    else
        char:SetAttribute("vaultspeed", 1)
    end
end

-- Reapply Fast Vault saat respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if FastVaultEnabled then
        char:SetAttribute("vaultspeed", FastVaultSpeed)
    end
end)

SurvUtilitySection:AddSlider({
    Title = "Fast Vault Speed Multiplier",
    Min = 10,
    Max = 20,
    Default = 13,
    Callback = function(value)
        FastVaultSpeed = value / 10
        if FastVaultEnabled then
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("vaultspeed", FastVaultSpeed)
            end
        end
    end
})

SurvUtilitySection:AddToggle({
    Title = "Fast Vault",
    Default = false,
    Keybind = true,
    Callback = function(state)
        ApplyFastVault(state)
    end
})

local AntiSlowVaultEnabled = false
local AntiSlowVaultConn = nil

function EnableAntiSlowVault()
    if AntiSlowVaultEnabled then return end
    AntiSlowVaultEnabled = true
    Config.Surv_PerfectVault = true  -- jika pakai Config

    for _, v in ipairs(CollectionService:GetTagged("SlowVault")) do
        CollectionService:RemoveTag(v, "SlowVault")
    end

    if AntiSlowVaultConn then AntiSlowVaultConn:Disconnect() end
    AntiSlowVaultConn = CollectionService:GetInstanceAddedSignal("SlowVault"):Connect(function(instance)
        CollectionService:RemoveTag(instance, "SlowVault")
    end)
end

function DisableAntiSlowVault()
    AntiSlowVaultEnabled = false
    Config.Surv_PerfectVault = false

    if AntiSlowVaultConn then
        AntiSlowVaultConn:Disconnect()
        AntiSlowVaultConn = nil
    end
end

SurvUtilitySection:AddToggle({
    Title = "Anti Slow Vault",
    Default = false,
    Keybind = true,
    Callback = function(state)
        if state then EnableAntiSlowVault() else DisableAntiSlowVault() end
    end
})

local UnlimitedVaultEnabled = false

function EnableUnlimitedVault()
    if UnlimitedVaultEnabled then return end
    UnlimitedVaultEnabled = true
    
    if _G.UnlimitedVaultConn then
        _G.UnlimitedVaultConn:Disconnect()
    end
    
    for _, v in ipairs(CollectionService:GetTagged("Blocked")) do
        CollectionService:RemoveTag(v, "Blocked")
    end
    
    _G.UnlimitedVaultConn = CollectionService:GetInstanceAddedSignal("Blocked"):Connect(function(instance)
        CollectionService:RemoveTag(instance, "Blocked")
    end)
end

function DisableUnlimitedVault()
    UnlimitedVaultEnabled = false
    if _G.UnlimitedVaultConn then
        _G.UnlimitedVaultConn:Disconnect()
        _G.UnlimitedVaultConn = nil
    end
end

SurvUtilitySection:AddToggle({
    Title = "Unlimited Vault",
    Default = false,
    Keybind = true,
    Callback = function(state)
        if state then EnableUnlimitedVault() else DisableUnlimitedVault() end
    end
})

-- ============ CAMERA DBD (dari Promers Hub) ============
-- Dibungkus do...end supaya local-nya tidak numpuk di closure Survivor Utility.
do
    local CamDBD = {
        SmoothEnabled = false,
        SmoothSpeed   = 5,
        POVEnabled    = false,
        TargetPOV     = 85,
        POVSmooth     = 9,
    }
    local CamDBD_PrevPos, CamDBD_PrevRot, CamDBD_OrigPOV = nil, nil, 70

    local bind = "RynerHUB_CameraDBD_Smooth"
    pcall(function() RunService:UnbindFromRenderStep(bind) end)

    RunService:BindToRenderStep(bind, Enum.RenderPriority.Camera.Value + 1, function(dt)
        local cam = Workspace.CurrentCamera
        if not cam then return end

        if cam.CameraType ~= Enum.CameraType.Custom
        and cam.CameraType ~= Enum.CameraType.Follow then
            CamDBD_PrevPos, CamDBD_PrevRot = nil, nil
            return
        end

        if CamDBD.SmoothEnabled then
            local cCF = cam.CFrame
            local cPos = cCF.Position
            local cRot = cCF.Rotation

            if not CamDBD_PrevPos or not CamDBD_PrevRot then
                CamDBD_PrevPos, CamDBD_PrevRot = cPos, cRot
            else
                local speed = tonumber(CamDBD.SmoothSpeed) or 5
                local pa = 1 - math.exp(-speed * dt)
                CamDBD_PrevPos = CamDBD_PrevPos:Lerp(cPos, pa)

                local ra = 1 - math.exp(-(speed * 1.90) * dt)
                CamDBD_PrevRot = CamDBD_PrevRot:Lerp(cRot, ra)

                cam.CFrame = CFrame.new(CamDBD_PrevPos) * CamDBD_PrevRot
            end
        else
            CamDBD_PrevPos, CamDBD_PrevRot = nil, nil
        end

        if CamDBD.POVEnabled then
            local ps = tonumber(CamDBD.POVSmooth) or 9
            local a = 1 - math.exp(-ps * dt)
            local target = tonumber(CamDBD.TargetPOV) or 85
            cam.FieldOfView = cam.FieldOfView + (target - cam.FieldOfView) * a
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        CamDBD_PrevPos, CamDBD_PrevRot = nil, nil
    end)

    local function CamDBD_SetSmooth(v)
        CamDBD.SmoothEnabled = v and true or false
        if not v then
            CamDBD_PrevPos, CamDBD_PrevRot = nil, nil
        else
            local cam = Workspace.CurrentCamera
            if cam then
                CamDBD_PrevPos = cam.CFrame.Position
                CamDBD_PrevRot = cam.CFrame.Rotation
            end
        end
    end

    local function CamDBD_SetPOVLock(v)
        CamDBD.POVEnabled = v and true or false
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if not v then
            cam.FieldOfView = CamDBD_OrigPOV
        else
            CamDBD_OrigPOV = cam.FieldOfView
        end
    end

    -- ===== UI Camera DBD =====
    SurvUtilitySection:AddDivider()

    SurvUtilitySection:AddToggle({
        Title = "Camera DBD Smooth",
        Content = "Kamera smoothing ala DBD",
        Default = false,
        Callback = function(v)
            CamDBD_SetSmooth(v)
            notif("Camera DBD Smooth: " .. (v and "ON" or "OFF"))
        end
    })

    SurvUtilitySection:AddSlider({
        Title = "DBD Smoothness",
        Min = 1, Max = 30, Default = 5, Step = 1,
        Callback = function(v) CamDBD.SmoothSpeed = tonumber(v) or 5 end
    })

    SurvUtilitySection:AddToggle({
        Title = "DBD POV Lock",
        Content = "Kunci Field of View",
        Default = false,
        Callback = function(v)
            CamDBD_SetPOVLock(v)
            notif("DBD POV Lock: " .. (v and "ON" or "OFF"))
        end
    })

    SurvUtilitySection:AddSlider({
        Title = "POV Value",
        Min = 60, Max = 120, Default = 85, Step = 1,
        Callback = function(v) CamDBD.TargetPOV = tonumber(v) or 85 end
    })

    SurvUtilitySection:AddSlider({
        Title = "POV Smoothness",
        Min = 3, Max = 20, Default = 9, Step = 1,
        Callback = function(v) CamDBD.POVSmooth = tonumber(v) or 9 end
    })

    SurvUtilitySection:AddDivider()
end

-- ============ STRETCH RESOLUTION (layar gepeng) ============
do
    -- Kalau script dijalankan ulang, bersihkan instance lama dulu
    local old = getgenv().VD_StretchCamera
    if old and old.Unload then pcall(old.Unload) end

    local RS = game:GetService("RunService")
    local Stretch = {
        Enabled    = false,
        Resolution = 0.65,
        -- Prioritas paling akhir: jalan setelah semua script kamera game
        Priority   = Enum.RenderPriority.Last.Value,
    }

    local function ApplyStretch()
        local cam = workspace.CurrentCamera
        if not cam or not Stretch.Enabled then return end
        local pos = cam.CFrame.Position
        local rot = cam.CFrame - pos
        local squeeze = CFrame.new(0, 0, 0, 1, 0, 0, 0, Stretch.Resolution, 0, 0, 0, 1)
        cam.CFrame = CFrame.new(pos) * rot * squeeze
    end

    local function SetStretch(state)
        Stretch.Enabled = state and true or false
        pcall(function() RS:UnbindFromRenderStep("VD_StretchCamera") end)
        if Stretch.Enabled then
            RS:BindToRenderStep("VD_StretchCamera", Stretch.Priority, ApplyStretch)
        end
    end

    getgenv().VD_StretchCamera = {
        SetEnabled = SetStretch,
        Unload = function() SetStretch(false) end,
    }

    SurvUtilitySection:AddDivider()

    SurvUtilitySection:AddSlider({
        Title = "Stretch Resolution",
        Min = 5, Max = 100, Default = 65, Step = 1,
        Callback = function(v)
            Stretch.Resolution = math.clamp(v / 100, 0.05, 1)
        end
    })

    SurvUtilitySection:AddToggle({
        Title = "Stretch Screen",
        Default = false,
        Keybind = true,
        Callback = function(state)
            SetStretch(state)
        end
    })

    SurvUtilitySection:AddDivider()
end

local ManualGenEnabled = false
local ManualGenThread = nil
local ManualCurrentPoint = nil
local ManualCurrentGen = nil

local function StopAllRepair()
    StopRepairAnim()
    local pointToStop = ManualCurrentPoint
    ManualCurrentPoint = nil
    ManualCurrentGen = nil
    if pointToStop then
        pcall(function() RepairEvent:FireServer(pointToStop, false) end)
    end
end

AutoGeneratorSection = Tabs.Survivor:AddSection("Auto Generator")
AutoGeneratorSection:AddToggle({
    Title = "Manual Generator (No TP)",
    Content = "Jika killer mendekat akan melepas Repair",
    Default = false,
    Keybind = true,
    Callback = function(state)
        ManualGenEnabled = state
        notif("Manual Generator ".. (state and "Aktif" or "Nonaktif"))
        if ManualGenThread then task.cancel(ManualGenThread) ManualGenThread = nil end
        StopAllRepair()
        if not state then return end

        ManualGenThread = task.spawn(function()
            local notifiedKiller = false
            while ManualGenEnabled do
                local hrp = GetRoot()
                if not hrp then task.wait(0.1) continue end

                local isKillerNear = IsKillerNearby(hrp.Position, KillerEscapeDist)
                if isKillerNear then
                    if not notifiedKiller then
                        notif("Killer Mendekat! Proses Repair Dilepas.")
                        notifiedKiller = true
                    end
                    StopAllRepair()
                    task.wait(0.5)
                    continue
                else
                    notifiedKiller = false
                end

                local gens = GetAllGenerators()
                local foundPoint = nil
                
                for _, gen in pairs(gens) do
                    if IsGenDone(gen) then continue end
                    local points = GetGeneratorPoints(gen)
                    
                    for _, point in pairs(points) do
                        if (hrp.Position - point.Position).Magnitude <= 5 then
                            foundPoint = point
                            if ManualCurrentGen ~= gen then
                                ManualCurrentGen = gen
                            end
                            break
                        end
                    end
                    if foundPoint then break end
                end

                if foundPoint then
                    ManualCurrentPoint = foundPoint
                    local now = tick()
                    if now - LastFireTime >= 0.5 then
                        if not ManualGenEnabled then break end
                        pcall(function() RepairEvent:FireServer(foundPoint, true) end)
                        PlayRepairAnim()
                        LastFireTime = now
                    end
                else
                    if ManualCurrentPoint then
                        StopAllRepair()
                    end
                end
                
                task.wait(0.1)
            end
            StopAllRepair()
        end)
    end
})
AutoGeneratorSection:AddToggle({
    Title = "Auto Generator (With TP)",
    Content = "Jika killer mendekat akan TP ke Gen lain",
    Default = false,
    Keybind = true,
    Callback = function(state)
        AutoGenEnabled = state
        notif("Auto Generator ".. (state and "Aktif" or "Nonaktif"))
        if state then
            StartAutoGen()
        else
            StopRepair()
            if AutoGenThread then task.cancel(AutoGenThread) end
        end
    end
})
AutoGeneratorSection:AddInput({
    Title = "Killer Escape Distance",
    Default = "30",
    Placeholder = "Write ur input here...",
    Callback = function(input)
        local num = tonumber(input)
        if num then KillerEscapeDist = num end
    end
})

do
    local BypassGenEnabled = false
    local BypassGenMode = "Manual Repair"
    local ProcessedGens = {}

    local AutoRepairEnabled = false
    local AutoRepairThread = nil
    local AutoCurrentPoint = nil
    local AutoCurrentGenModel = nil
    local LastFireTime = 0
    local AutoFireInterval = 0.5

    local function StopAutoRepair()
        StopRepairAnim()
        local pointToStop = AutoCurrentPoint
        AutoCurrentPoint = nil
        if pointToStop then
            pcall(function() RepairEvent:FireServer(pointToStop, false) end)
        end
    end

    local function StartAutoRepairLoop(genModel)
        AutoCurrentGenModel = genModel

        if AutoRepairThread then
            task.cancel(AutoRepairThread)
            AutoRepairThread = nil
        end
        StopAutoRepair()

        AutoRepairThread = task.spawn(function()
            while AutoRepairEnabled and BypassGenEnabled do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(0.1) continue end

                local foundPoint = nil
                for _, gen in pairs(GetAllGenerators()) do
                    for _, point in pairs(GetGeneratorPoints(gen)) do
                        if (hrp.Position - point.Position).Magnitude <= 5 then
                            foundPoint = point
                            break
                        end
                    end
                    if foundPoint then break end
                end

                if foundPoint then
                    AutoCurrentPoint = foundPoint
                    local now = tick()
                    if now - LastFireTime >= AutoFireInterval then
                        PlayRepairAnim()
                        pcall(function() RepairEvent:FireServer(foundPoint, true) end)
                        LastFireTime = now
                    end
                else
                    if AutoCurrentPoint then
                        StopAutoRepair()
                        AutoRepairEnabled = false

                        if AutoCurrentGenModel then
                            ProcessedGens[AutoCurrentGenModel] = nil
                            AutoCurrentGenModel = nil
                        end
                        break
                    end
                end

                task.wait(0.1)
            end
            StopAutoRepair()
        end)
    end

    local function waitForRepairing(point, timeout)
        local start = tick()
        while tick() - start < (timeout or 1) do
            if point:GetAttribute("IsRepairing") == true then
                return true
            end
            task.wait(0.05)
        end
        return false
    end

    local function clearProcessedOnLeave(genModel, targetPoint)
        local conn
        conn = targetPoint:GetAttributeChangedSignal("IsRepairing"):Connect(function()
            if targetPoint:GetAttribute("IsRepairing") == false then
                ProcessedGens[genModel] = nil
                conn:Disconnect()
            end
        end)
    end

    local BypassUI = Instance.new("ScreenGui")
    BypassUI.Name = "BypassGenUI"
    BypassUI.ResetOnSpawn = false
    BypassUI.IgnoreGuiInset = true
    BypassUI.Parent = CoreGui

    local BypassButton = Instance.new("ImageButton")
    BypassButton.Name = "BypassGenButton"
    BypassButton.Size = UDim2.new(0, 55, 0, 55)
    BypassButton.Position = UDim2.new(0.88, 0, 0.55, 0)
    BypassButton.AnchorPoint = Vector2.new(0.5, 0.5)
    BypassButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    BypassButton.BackgroundTransparency = 0.15
    BypassButton.AutoButtonColor = true
    BypassButton.Visible = false
    BypassButton.ZIndex = 10
    BypassButton.Parent = BypassUI

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = BypassButton

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.4
    UIStroke.Parent = BypassButton

    local BypassLabel = Instance.new("TextLabel")
    BypassLabel.Size = UDim2.new(1, 0, 1, 0)
    BypassLabel.BackgroundTransparency = 1
    BypassLabel.Text = "GEN"
    BypassLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BypassLabel.TextScaled = true
    BypassLabel.Font = Enum.Font.GothamBold
    BypassLabel.ZIndex = 11
    BypassLabel.Parent = BypassButton

    local function DoMultiRepairPlain(targetPoint)
        local genModel = targetPoint.Parent
        if ProcessedGens[genModel] then return end

        ProcessedGens[genModel] = true
        clearProcessedOnLeave(genModel, targetPoint)

        local allPoints = GetGeneratorPoints(genModel)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then ProcessedGens[genModel] = nil return end

        local originalCFrame = hrp.CFrame

        for _, point in pairs(allPoints) do
            if point ~= targetPoint and point.Parent then
                local wasAnchored = hrp.Anchored
                hrp.Anchored = false
                hrp.CFrame = point.CFrame
                task.wait(0.05)
                hrp.Anchored = wasAnchored

                pcall(function() RepairEvent:FireServer(point, true) end)

                if not waitForRepairing(point, 0.8) then
                    pcall(function() RepairEvent:FireServer(point, false) end)
                    task.wait(0.05)
                    hrp.Anchored = false
                    hrp.CFrame = point.CFrame
                    task.wait(0.05)
                    hrp.Anchored = wasAnchored
                    pcall(function() RepairEvent:FireServer(point, true) end)
                    waitForRepairing(point, 0.5)
                end
            end
        end

        hrp.Anchored = false
        hrp.CFrame = originalCFrame
        if BypassGenMode == "Manual Repair" then
            pcall(function() RepairEvent:FireServer(targetPoint, false) end)
        elseif BypassGenMode == "Auto Repair" then
            AutoRepairEnabled = true
            StartAutoRepairLoop(genModel)
        end
    end

    BypassButton.MouseButton1Click:Connect(function()
        if not BypassGenEnabled then return end

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bestPoint, bestDist = nil, math.huge
        for _, gen in pairs(GetAllGenerators()) do
            for _, point in pairs(GetGeneratorPoints(gen)) do
                local d = (hrp.Position - point.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestPoint = point
                end
            end
        end

        if bestPoint and bestDist <= 8 then
            DoMultiRepairPlain(bestPoint)
        end
    end)

    local __namecall
    __namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if method == "FireServer" and self == RepairEvent and BypassGenEnabled then
            local targetPoint = args[1]
            local isStarting = args[2]

            if isStarting and targetPoint and targetPoint.Parent then
                local genModel = targetPoint.Parent

                if ProcessedGens[genModel] then
                    return __namecall(self, ...)
                end

                ProcessedGens[genModel] = true
                clearProcessedOnLeave(genModel, targetPoint)

                local allPoints = GetGeneratorPoints(genModel)
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local originalCFrame = hrp.CFrame

                for _, point in pairs(allPoints) do
                    if point ~= targetPoint and point.Parent then
                        local wasAnchored = hrp.Anchored
                        hrp.Anchored = false
                        hrp.CFrame = point.CFrame
                        task.wait(0.05)
                        hrp.Anchored = wasAnchored

                        self.FireServer(self, point, true)

                        if not waitForRepairing(point, 0.8) then
                            self.FireServer(self, point, false)
                            task.wait(0.05)
                            hrp.Anchored = false
                            hrp.CFrame = point.CFrame
                            task.wait(0.05)
                            hrp.Anchored = wasAnchored
                            self.FireServer(self, point, true)
                            waitForRepairing(point, 0.5)
                        end
                    end
                end

                hrp.CFrame = originalCFrame
                task.wait(0.05)
                if BypassGenMode == "Manual Repair" then
                    self.FireServer(self, targetPoint, false)
                elseif BypassGenMode == "Auto Repair" then
                    AutoRepairEnabled = true
                    StartAutoRepairLoop(genModel)
                end
                return
            end
        end

        return __namecall(self, ...)
    end)
    
    BypassGenSection = Tabs.Survivor:AddSection("Bypass Generator")
    BypassGenSection:AddParagraph({
        Title = "README!",
        Content = "Fitur ini akan menumpuk skillcheck jika anda tidak menggunakan mode yang Auto Repair.\n" ..
                "Jika jaringan anda tidak bagus, sudah pasti akan meledak saat skillcheck jika menggunakan mode Manual Repair.\n" ..
                "Jika menggunakan fitur ini dan mode manual repair, sangat disarankan untuk menggunakan Auto Skillcheck mode Instant!"
    })
    BypassGenSection:AddDropdown({
        Title = "Bypass Mode",
        Options = {"Manual Repair", "Auto Repair"},
        Default = "Manual Repair",
        Callback = function(opts)
            BypassGenMode = opts
        end
    })
    BypassGenSection:AddToggle({
        Title = "Bypass Generator",
        Content = "Jika mobile, tekan tombol GEN terlebih dahulu",
        Default = false,
        Keybind = true,
        Callback = function(state)
            BypassGenEnabled = state
            BypassButton.Visible = state and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
            if not state then
                ProcessedGens = {}
                AutoRepairEnabled = false
                AutoCurrentGenModel = nil
                if AutoRepairThread then
                    task.cancel(AutoRepairThread)
                    AutoRepairThread = nil
                end
                StopAutoRepair()
            end
            notif("Gen Booster: " .. (state and "Aktif" or "Nonaktif"))
        end
    })
end

-- =====================================================
-- AUTO SKILLCHECK (Normal / Perfect / Instant) + AUTO PALLET DROP — dari A2
-- Menggantikan Auto Skillcheck Perfect (King Scourge) yang lama sepenuhnya.
-- Semua variabel dibuat local di dalam blok ini (pcall), jadi tidak menambah
-- jumlah local di level atas script.
-- Role Survivor = Team "Survivors", Killer = Team "Killer" (sama seperti fitur lain).
-- =====================================================
do
    local okA2, errA2 = pcall(function()
        local GuiService = game:GetService("GuiService")
        local VirtualInputManager
        pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        local VD = getgenv().VD or {}
        getgenv().VD = VD
        if VD.AutoSkillcheck == nil then VD.AutoSkillcheck = false end
        if VD.AutoSkillcheckMode == nil then VD.AutoSkillcheckMode = "Perfect" end
        if VD.SURV_AutoPallet == nil then VD.SURV_AutoPallet = false end
        if VD.SURV_AutoPalletDist == nil then VD.SURV_AutoPalletDist = 20 end

        -- =================================================
        -- AUTO SKILLCHECK (Normal / Perfect / Instant) — dari A2
        -- Config:
        --   VD.AutoSkillcheck     = true/false
        --   VD.AutoSkillcheckMode = "Perfect" | "Normal" | "Instant"
        -- Perfect zone: (goalRotation+104) .. (goalRotation+108)
        -- Tekan Space (PC) / tombol mobile "check"
        -- =================================================
        local AutoSkill = {
            LastGoalRotation = nil,
            HasClickedThisGoal = false,
            LastLineRotation = nil,
            LastTick = nil,
            WasActive = false,
            PerfectLastGoalRotation = nil,
            PerfectHasClickedThisGoal = false,
            PerfectLastLineRotation = nil,
            PerfectLastTick = nil,
            PerfectWasActive = false,
            InstantLastTriggerTick = 0,
            InstantLastGoalRotation = 0,
            InstantLastGoalInstance = nil,
            InstantCurrentGoalID = 0,
            InstantHasClicked = false,
            InstantForcingRotation = false,
            InstantRotationConnection = nil,
        }

        local function VD_PressSkill()
            if isMobile then
                local btn = PlayerGui:FindFirstChild("check", true)
                if btn and btn:IsA("GuiObject") then
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    local inset = GuiService:GetGuiInset()
                    local x = pos.X + (size.X / 2) + inset.X
                    local y = pos.Y + (size.Y / 2) + inset.Y
                    pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.Begin.Value, x, y) end)
                    task.wait(0.01)
                    pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.End.Value, x, y) end)
                    pcall(function()
                        if firesignal and btn.MouseButton1Click then
                            firesignal(btn.MouseButton1Click)
                        end
                    end)
                end
            else
                pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
                task.wait(0.01)
                pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
            end
        end

        local function VD_GetSkillCheck()
            for _, guiName in ipairs({ "SkillCheckPromptGui", "SkillCheckPromptGui-con" }) do
                local gui = PlayerGui:FindFirstChild(guiName, true)
                if gui then
                    local check = gui:FindFirstChild("Check", true)
                    if check and check.Visible then
                        local line = check:FindFirstChild("Line", true)
                        local goal = check:FindFirstChild("Goal", true)
                        if line and goal then return line, goal end
                    end
                end
            end
        end

        local function VD_AngularDelta(from, to)
            local d = to - from
            if d > 180 then d = d - 360 end
            if d < -180 then d = d + 360 end
            return d
        end

        local function VD_CrossedZone(prevLr, lr, startPos, endPos)
            local function inZone(r)
                if startPos > endPos then
                    return r >= startPos or r <= endPos
                end
                return r >= startPos and r <= endPos
            end
            if inZone(lr) then return true end
            if prevLr == nil then return false end
            local delta = VD_AngularDelta(prevLr, lr)
            local steps = math.abs(math.floor(delta))
            if steps < 2 then return false end
            local stepSize = delta / steps
            for i = 1, steps do
                if inZone((prevLr + stepSize * i) % 360) then return true end
            end
            return false
        end

        local function VD_NormalSkillcheckUpdate()
            local line, goal = VD_GetSkillCheck()
            if not (line and goal) then
                AutoSkill.LastGoalRotation = nil
                AutoSkill.HasClickedThisGoal = false
                AutoSkill.LastLineRotation = nil
                AutoSkill.LastTick = nil
                AutoSkill.WasActive = false
                return
            end

            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            local now = os.clock()
            if not AutoSkill.WasActive then
                AutoSkill.WasActive = true
                AutoSkill.HasClickedThisGoal = false
                AutoSkill.LastGoalRotation = gr
                AutoSkill.LastLineRotation = lr
                AutoSkill.LastTick = now
                return
            end
            if AutoSkill.LastGoalRotation and math.abs(VD_AngularDelta(AutoSkill.LastGoalRotation, gr)) > 5 then
                AutoSkill.HasClickedThisGoal = false
                AutoSkill.LastLineRotation = nil
                AutoSkill.LastTick = nil
            end
            AutoSkill.LastGoalRotation = gr
            if AutoSkill.HasClickedThisGoal then
                AutoSkill.LastLineRotation = lr
                AutoSkill.LastTick = now
                return
            end
            if AutoSkill.LastLineRotation and AutoSkill.LastTick then
                local dt = now - AutoSkill.LastTick
                if dt > 0 then
                    local lineSpeed = VD_AngularDelta(AutoSkill.LastLineRotation, lr) / dt
                    local predicted = (lr + lineSpeed * dt * 0) % 360
                    if VD_CrossedZone(AutoSkill.LastLineRotation, predicted, (gr + 104) % 360, (gr + 109) % 360) then
                        AutoSkill.HasClickedThisGoal = true
                        task.spawn(function()
                            task.wait(0.03)
                            VD_PressSkill()
                        end)
                    end
                end
            end
            AutoSkill.LastLineRotation = lr
            AutoSkill.LastTick = now
        end

        local function VD_PerfectSkillcheckUpdate()
            local line, goal = VD_GetSkillCheck()
            if not (line and goal) then
                AutoSkill.PerfectLastGoalRotation = nil
                AutoSkill.PerfectHasClickedThisGoal = false
                AutoSkill.PerfectLastLineRotation = nil
                AutoSkill.PerfectLastTick = nil
                AutoSkill.PerfectWasActive = false
                return
            end

            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            local now = os.clock()
            if not AutoSkill.PerfectWasActive then
                AutoSkill.PerfectWasActive = true
                AutoSkill.PerfectHasClickedThisGoal = false
                AutoSkill.PerfectLastGoalRotation = gr
                AutoSkill.PerfectLastLineRotation = lr
                AutoSkill.PerfectLastTick = now
                return
            end
            if AutoSkill.PerfectLastGoalRotation and math.abs(VD_AngularDelta(AutoSkill.PerfectLastGoalRotation, gr)) > 5 then
                AutoSkill.PerfectHasClickedThisGoal = false
                AutoSkill.PerfectLastLineRotation = nil
                AutoSkill.PerfectLastTick = nil
            end
            AutoSkill.PerfectLastGoalRotation = gr
            if AutoSkill.PerfectHasClickedThisGoal then
                AutoSkill.PerfectLastLineRotation = lr
                AutoSkill.PerfectLastTick = now
                return
            end
            if AutoSkill.PerfectLastLineRotation and AutoSkill.PerfectLastTick then
                local dt = now - AutoSkill.PerfectLastTick
                if dt > 0 then
                    local lineSpeed = VD_AngularDelta(AutoSkill.PerfectLastLineRotation, lr) / dt
                    local predicted = (lr + lineSpeed * dt * 0) % 360
                    if VD_CrossedZone(AutoSkill.PerfectLastLineRotation, predicted, (gr + 104) % 360, (gr + 108) % 360) then
                        AutoSkill.PerfectHasClickedThisGoal = true
                        VD_PressSkill()
                    end
                end
            end
            AutoSkill.PerfectLastLineRotation = lr
            AutoSkill.PerfectLastTick = now
        end

        local function VD_InstantSkillcheckUpdate()
            if AutoSkill.InstantHasClicked then return end

            -- Exact Fallens.lua logic: non-recursive FindFirstChild
            local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
            if not prompt then
                prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui-con")
            end
            if not prompt then return end

            local check = prompt:FindFirstChild("Check")
            if not check or not check.Visible then return end

            local line = check:FindFirstChild("Line")
            local goal = check:FindFirstChild("Goal")
            if not line or not goal then return end

            -- Exact Fallens.lua logic: raw rotation WITHOUT modulo
            line.Rotation = goal.Rotation + 109

            AutoSkill.InstantHasClicked = true
            task.spawn(function()
                VD_PressSkill()
                task.wait(0.2)
                AutoSkill.InstantHasClicked = false
            end)
        end

        RunService.RenderStepped:Connect(function()
            if not VD.AutoSkillcheck then return end
            if VD.AutoSkillcheckMode == "Perfect" then
                VD_PerfectSkillcheckUpdate()
            elseif VD.AutoSkillcheckMode == "Instant" then
                VD_InstantSkillcheckUpdate()
            else
                VD_NormalSkillcheckUpdate()
            end
        end)

        local function VD_SetAutoSkillcheck(state)
            state = state == true
            -- callback awal toggle (false) tidak perlu memunculkan notifikasi
            if state == (VD.AutoSkillcheck == true) then return end
            VD.AutoSkillcheck = state
            if not VD.AutoSkillcheck then
                if AutoSkill.InstantRotationConnection then
                    AutoSkill.InstantRotationConnection:Disconnect()
                    AutoSkill.InstantRotationConnection = nil
                end
                AutoSkill.InstantHasClicked = false
                AutoSkill.WasActive = false
                AutoSkill.PerfectWasActive = false
                notif("Auto Skillcheck Nonaktif")
            else
                notif("Auto Skillcheck Aktif (" .. tostring(VD.AutoSkillcheckMode or "Normal") .. " Mode)")
            end
        end
        getgenv().VD_SetAutoSkillcheck = VD_SetAutoSkillcheck

        -- =================================================
        -- AUTO PALLET DROP
        -- Spy: PalletDropEvent:FireServer(Palletwrong.PalletPointSlide)
        -- =================================================
        local palletCache   = {}
        local usedPallets   = setmetatable({}, { __mode = "k" })
        local lastPalletTick, lastPalletDrop, lastMapScan = 0, 0, 0

        local function findPalletPointSlide(model)
            local slide = model:FindFirstChild("PalletPointSlide")
            if slide then return slide end
            for _, child in ipairs(model:GetDescendants()) do
                if child.Name == "PalletPointSlide" then return child end
            end
            return model:FindFirstChild("PalletPoint")
        end

        local function partPosition(part, model)
            if part and part:IsA("BasePart") then return part.Position end
            if part and part:IsA("Attachment") then return part.WorldPosition end
            local ok, pivot = pcall(function() return model:GetPivot().Position end)
            if ok then return pivot end
            return nil
        end

        local function refreshPallets()
            local list = {}
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if (obj.Name == "Palletwrong" or obj.Name == "Pallet") and obj:IsA("Model") then
                        local slide = findPalletPointSlide(obj)
                        if slide then
                            local ref = obj:FindFirstChild("PalletPoint", true) or slide
                            list[#list + 1] = { model = obj, point = slide, ref = ref }
                        end
                    end
                end
            end
            palletCache = list
        end

        -- Killer terdekat (Team "Killer") beserta jaraknya
        local function nearestKillerDist(myPos)
            local bestD = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" then
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (root.Position - myPos).Magnitude
                        if not bestD or d < bestD then bestD = d end
                    end
                end
            end
            return bestD
        end

        local function palletStep()
            if not VD.SURV_AutoPallet then return end
            if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors") then return end
            local now = tick()
            if now - lastPalletTick < 0.2 then return end
            lastPalletTick = now
            if now - lastPalletDrop < 2.5 then return end

            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not myRoot or not hum or hum.Health <= 0 then return end

            local kd = nearestKillerDist(myRoot.Position)
            if not kd or kd > (VD.SURV_AutoPalletDist or 20) then return end

            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local palletFold = remotes and remotes:FindFirstChild("Pallet")
            local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
            if not dropEvent then return end

            if now - lastMapScan > 2 then
                lastMapScan = now
                refreshPallets()
            end

            local best, bestDist = nil, 8 -- maksimal 8 studs dari pemain
            for _, pal in ipairs(palletCache) do
                local model = pal.model
                if model.Parent and not usedPallets[model] then
                    local pos = partPosition(pal.ref, model)
                    if pos then
                        local d = (myRoot.Position - pos).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = pal
                        end
                    end
                end
            end

            if best then
                pcall(function() dropEvent:FireServer(best.point) end)
                usedPallets[best.model] = true
                lastPalletDrop = tick()
            end
        end

        LocalPlayer.CharacterAdded:Connect(function()
            table.clear(usedPallets)
            palletCache = {}
            lastMapScan = 0
        end)

        local palletConn = nil
        local function setAutoPallet(state)
            state = state == true
            if state == (VD.SURV_AutoPallet == true) then return end
            VD.SURV_AutoPallet = state
            if palletConn then
                palletConn:Disconnect()
                palletConn = nil
            end
            if state then
                table.clear(usedPallets)
                lastMapScan = 0
                palletConn = RunService.Heartbeat:Connect(function()
                    pcall(palletStep)
                end)
            end
            notif("Auto Pallet Drop " .. (state and "Aktif" or "Nonaktif"))
        end

        -- =================================================
        -- UI (tab Survivor)
        -- =================================================
        local AutoSkillSection = Tabs.Survivor:AddSection("Auto Skillcheck")
        AutoSkillSection:AddDropdown({
            Title = "Mode Auto Skillcheck",
            Content = "Perfect: klik di zona sempit (goal+104 sampai goal+108)",
            Options = { "Normal", "Perfect", "Instant" },
            Default = "Perfect",
            Callback = function(v)
                if type(v) == "table" then v = v[1] end
                if v ~= "Normal" and v ~= "Perfect" and v ~= "Instant" then return end
                VD.AutoSkillcheckMode = v
            end
        })
        AutoSkillSection:AddToggle({
            Title = "Enable Auto Skillcheck",
            Content = "Tekan Space (PC) / tombol check (mobile)",
            Default = false,
            Keybind = true,
            Callback = function(state)
                VD_SetAutoSkillcheck(state)
            end
        })

        local AutoPalletSection = Tabs.Survivor:AddSection("Auto Pallet Drop")
        AutoPalletSection:AddToggle({
            Title = "Auto Pallet Drop",
            Content = "Otomatis menjatuhkan pallet terdekat saat killer mendekat",
            Default = false,
            Keybind = true,
            Callback = function(state)
                setAutoPallet(state)
            end
        })
        AutoPalletSection:AddSlider({
            Title = "Jarak Killer (studs)",
            Min = 5,
            Max = 50,
            Default = 20,
            Callback = function(v)
                VD.SURV_AutoPalletDist = v
            end
        })
    end)
    if not okA2 then
        warn("[RynerHUB] Auto Skillcheck / Auto Pallet Drop gagal dimuat: " .. tostring(errA2))
    end
end

BypassGateSection = Tabs.Exclusive:AddSection("Bypass Gate")
BypassGateSection:AddButton({
    Title = "Beat Game (Auto Escape)",
    Callback = function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local rootPart = character.HumanoidRootPart
        local map = workspace:FindFirstChild("Map")
        
        local closestGate = nil
        local minGateDist = math.huge
        
        for _, obj in pairs(map:GetDescendants()) do
            if obj.Name == "Gate" or (obj:FindFirstChild("LeftGate") and obj:FindFirstChild("RightGate")) then
                local gatePos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local dist = (rootPart.Position - gatePos).Magnitude
                if dist < minGateDist then
                    minGateDist = dist
                    closestGate = obj
                end
            end
        end

        if not closestGate then return end

        local gateModel = closestGate:IsA("Model") and closestGate or closestGate.Parent
        if gateModel:FindFirstChild("LeftGate") then gateModel.LeftGate.Transparency = 1; gateModel.LeftGate.CanCollide = false end
        if gateModel:FindFirstChild("RightGate") then gateModel.RightGate.Transparency = 1; gateModel.RightGate.CanCollide = false end
        if gateModel:FindFirstChild("Box") then gateModel.Box.CanCollide = false end

        local targetPos = (gateModel:IsA("Model") and gateModel:GetPivot() or gateModel.CFrame) + Vector3.new(0, 3, 0)
        rootPart.CFrame = targetPos
        
        task.wait(0.3) 
        
        if (rootPart.Position - targetPos.Position).Magnitude > 5 then
            rootPart.CFrame = targetPos
        end

        local closestFinish = nil
        local minFinishDist = math.huge
        
        for _, name in pairs({"Fininshline", "Finishline"}) do
            for _, obj in pairs(map:GetDescendants()) do
                if obj.Name == name and obj:IsA("BasePart") then
                    local dist = (rootPart.Position - obj.Position).Magnitude
                    if dist < minFinishDist then
                        minFinishDist = dist
                        closestFinish = obj
                    end
                end
            end
        end

        if closestFinish then
            local speed = 180 
            local dist = (rootPart.Position - closestFinish.Position).Magnitude
            local duration = dist / speed
            
            local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                CFrame = closestFinish.CFrame + Vector3.new(0, 2, 0)
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                local EscapeEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game") and ReplicatedStorage.Remotes.Game:FindFirstChild("PlayerActionEvent")
                if EscapeEvent then
                    for i = 1, 5 do
                        EscapeEvent:FireServer("ESCAPED", 200)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
})

-- [[ Killer ]]
do

-- Buat Section dan Toggle
local bypassallkillerSection = Tabs.Killer:AddSection("Bypass All Killer")
bypassallkillerSection:AddParagraph({
        Title = "‼️ PENJELASAN ‼️",
        Content = "Penjelasan tentang aim lock hidden, untuk atas itu di gunakan untuk lock target jadi ga bisa di geser layar nya, untuk mengatasi itu wajib menyalakan unlock juga."
    })
-- ==================== BYPASS LEAP COOLDOWN (HIDDEN) ====================

-- Pastikan tabel Killer sudah ada
    local Killer = Killer or {}
    Killer.BypassLeap = false

local function StartLeapBypass()
    Connections.LeapBypass = task.spawn(function()
        local leapFunction, m2Function
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local info = debug.getinfo(v)
                if info.name == "tryActivate" then leapFunction = v end
                if info.name == "playM2Animation" then m2Function = v end
                if leapFunction and m2Function then break end
            end
        end
        if not leapFunction and not m2Function then
            warn("Function tryActivate/playM2Animation tidak ditemukan.")
            return
        end
        while task.wait(0.1) do
            if not Killer.BypassLeap then break end
            for _, fn in pairs({leapFunction, m2Function}) do
                if fn then
                    for i, val in pairs(debug.getupvalues(fn)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(fn, i, false)
                        end
                    end
                end
            end
        end
    end)
end

-- Toggle UI
bypassallkillerSection:AddToggle({
    Title = "Bypass Cooldown (Hidden)",
    Default = false,
    Callback = function(v)
        Killer.BypassLeap = v
        if v then
            StartLeapBypass()
            Library:Notify({Title = "Bypass Leap", Description = "Diaktifkan", Duration = 3})
        else
            Library:Notify({Title = "Bypass Leap", Description = "Dinonaktifkan", Duration = 3})
            -- Loop akan berhenti otomatis karena Killer.BypassLeap = false
         end
      end
   })
do
    local AimbotEnabled = false
    local AimbotThread  = nil
    local Aiming        = false
    local HoldKey       = Enum.KeyCode.E  -- default, bisa diganti lewat UI
    local mobileHooks   = {}

    -- ============ CARI TARGET ============
    local function GetClosestTarget()
        local hrp = GetRoot()
        if not hrp then return nil end
        local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name or ""
        local closestTarget, shortestDist = nil, math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local playerTeam = player.Team and player.Team.Name or ""
                if targetHrp and hum and hum.Health > 0 then
                    local isEnemy = (myTeam == "Killer" and playerTeam ~= "Killer")
                                 or (myTeam ~= "Killer" and playerTeam == "Killer")
                    if isEnemy then
                        local dist = (targetHrp.Position - hrp.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist, closestTarget = dist, targetHrp
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    -- ============ AIMBOT LOOP ============
    local function StartAimbot()
        if AimbotThread then task.cancel(AimbotThread) end
        AimbotThread = task.spawn(function()
            while AimbotEnabled do
                if Aiming then
                    local target = GetClosestTarget()
                    if target then
                        pcall(function()
                            Camera.CFrame = CFrame.new(
                                Camera.CFrame.Position,
                                target.Position + Vector3.new(0, 2.5, 0)
                            )
                        end)
                    end
                end
                task.wait()
            end
        end)
    end

    -- ============ INPUT PC ============
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not AimbotEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = true
        end
        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == HoldKey then
            Aiming = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = false
        end
        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == HoldKey then
            Aiming = false
        end
    end)

    -- ============ INPUT MOBILE ============
    local function disconnectMobileHooks()
        for _, c in pairs(mobileHooks) do pcall(function() c:Disconnect() end) end
        mobileHooks = {}
    end

    local function setupMobileAimButtons()
        if not UserInputService.TouchEnabled then return end
        disconnectMobileHooks()
        task.spawn(function()
            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                       or LocalPlayer:WaitForChild("PlayerGui", 10)
            if not pGui then return end
            local NAMES = {"attack","shoot","fire","basicattack","tembak",
                           "hidden","skill","ability","power","skill1","ability1","gui-mob"}
            local function isBtn(obj)
                if not obj then return false end
                if not (obj:IsA("GuiButton") or obj:IsA("ImageButton") or obj:IsA("TextButton")) then return false end
                local l = obj.Name:lower()
                for _, n in ipairs(NAMES) do
                    if l == n or l:find(n, 1, true) then return true end
                end
                return false
            end
            local function hook(btn)
                if not btn or btn:GetAttribute("RynerHUB_HoldAim") then return end
                btn:SetAttribute("RynerHUB_HoldAim", true)
                table.insert(mobileHooks, btn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.Touch
                    or i.UserInputType == Enum.UserInputType.MouseButton1 then
                        if AimbotEnabled then Aiming = true end
                    end
                end))
                table.insert(mobileHooks, btn.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.Touch
                    or i.UserInputType == Enum.UserInputType.MouseButton1 then
                        Aiming = false
                    end
                end))
                table.insert(mobileHooks, btn:GetPropertyChangedSignal("Visible"):Connect(function()
                    if not btn.Visible then Aiming = false end
                end))
            end
            local function scan()
                for _, ch in ipairs(pGui:GetChildren()) do
                    local ctrl = ch:FindFirstChild("Controls")
                    if ctrl then
                        for _, obj in ipairs(ctrl:GetDescendants()) do
                            if isBtn(obj) then hook(obj) end
                        end
                    end
                end
            end
            scan()
            table.insert(mobileHooks, pGui.ChildAdded:Connect(function() task.wait(0.3) scan() end))
        end)
    end

    if UserInputService.TouchEnabled then setupMobileAimButtons() end

    LocalPlayer.CharacterAdded:Connect(function()
        Aiming = false
        if UserInputService.TouchEnabled then
            task.wait(2)
            setupMobileAimButtons()
        end
    end)

    -- ============ TOGGLE UI ============
    bypassallkillerSection:AddToggle({
        Title = "Aim Lock Hidden (Hold)",
        Content = "Tahan M2 / tombol attack → lock kamera. Lepas → bebas.",
        Default = false,
        Keybind = true,
        Callback = function(state)
            AimbotEnabled = state
            if state then
                StartAimbot()
                notif("Aim Lock Hidden: ON")
            else
                Aiming = false
                if AimbotThread then
                    task.cancel(AimbotThread)
                    AimbotThread = nil
                end
                notif("Aim Lock Hidden: OFF")
            end
        end
    })

    -- ============ INPUT KEYBIND BEBAS ============
    bypassallkillerSection:AddInput({
        Title = "Hold Keybind (Custom)",
        Content = "Ketik nama tombol: E, Q, F, X, LeftShift, LeftAlt, LeftCtrl, dll",
        Default = "E",
        Placeholder = "Contoh: Q / F / LeftShift",
        Callback = function(input)
            input = tostring(input or ""):gsub("%s+", "")
            if input == "" then return end

            -- Map nama umum ke KeyCode
            local map = {
                ["leftshift"]   = Enum.KeyCode.LeftShift,
                ["rightshift"]  = Enum.KeyCode.RightShift,
                ["leftalt"]     = Enum.KeyCode.LeftAlt,
                ["rightalt"]    = Enum.KeyCode.RightAlt,
                ["leftctrl"]    = Enum.KeyCode.LeftControl,
                ["rightctrl"]   = Enum.KeyCode.RightControl,
                ["leftcontrol"] = Enum.KeyCode.LeftControl,
                ["rightcontrol"]= Enum.KeyCode.RightControl,
                ["space"]       = Enum.KeyCode.Space,
                ["tab"]         = Enum.KeyCode.Tab,
                ["capslock"]    = Enum.KeyCode.CapsLock,
                ["shift"]       = Enum.KeyCode.LeftShift,
                ["ctrl"]        = Enum.KeyCode.LeftControl,
                ["alt"]         = Enum.KeyCode.LeftAlt,
            }

            local newKey = map[input:lower()]
            if not newKey then
                -- Coba langsung dari Enum.KeyCode
                local ok, kc = pcall(function()
                    return Enum.KeyCode[input:upper():sub(1,1) .. input:lower():sub(2)]
                end)
                if ok and kc then newKey = kc end
            end

            if newKey then
                HoldKey = newKey
                notif("Hold key diubah ke: " .. newKey.Name)
            else
                notif("Keybind tidak valid: " .. input)
            end
        end
    })
end
    
    -- Pastikan tabel Killer sudah ada
    local Killer = Killer or {}
    Killer.BypassCooldown = false

local function StartCooldownBypass()
    -- Cari fungsi corruptHandler di memori (hanya sekali)
    if not State.CorruptHandlerFunc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local constants = debug.getconstants(v)
                if table.find(constants, "corrupt") and table.find(constants, "Immobile") then
                    State.CorruptHandlerFunc = v
                    break
                end
            end
        end
    end

    if not State.CorruptHandlerFunc then
        warn("Fungsi corruptHandler tidak ditemukan di memori.")
        return
    end
    
    if Connections.CooldownBypass then 
        Connections.CooldownBypass:Disconnect() 
    end
    
    Connections.CooldownBypass = RunService.Heartbeat:Connect(function()
        if not Killer.BypassCooldown then return end
        if State.CorruptHandlerFunc then
            local upvalues = debug.getupvalues(State.CorruptHandlerFunc)
            for idx, val in pairs(upvalues) do
                if type(val) == "boolean" then
                    if val == false then
                        debug.setupvalue(State.CorruptHandlerFunc, idx, true)
                    end
                end
            end
        end
    end)
end

local function StopCooldownBypass()
    if Connections.CooldownBypass then
        Connections.CooldownBypass:Disconnect()
        Connections.CooldownBypass = nil
    end
end

-- Toggle UI
bypassallkillerSection:AddToggle({
    Title = "Bypass Cooldown (Abyss)",
    Default = false,
    Callback = function(state)
        Killer.BypassCooldown = state
        if state then
            StartCooldownBypass()
            Library:Notify({Title = "Bypass Cooldown", Description = "Diaktifkan", Duration = 3})
        else
            StopCooldownBypass()
            Library:Notify({Title = "Bypass Cooldown", Description = "Dinonaktifkan", Duration = 3})
        end
    end
})

    -- Definisikan tabel AutoStalk
    local AutoStalk = {
    Enabled    = false,
    StalkRange = 150,
    Target     = nil
}

-- Pastikan fungsi getClosestSurvivorForStalk sudah didefinisikan sebelumnya (dari kode asli)
-- Jika belum, salin dari skrip utama.

-- Fungsi untuk mengaktifkan Auto Stalk
local function startAutoStalk()
    if Connections.Stalk then return end
    Connections.Stalk = RunService.Heartbeat:Connect(function()
        if not AutoStalk.Enabled then return end
        local target = getClosestSurvivorForStalk()
        if not target or not target.Character then return end
        local stalkEvent = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
            and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if stalkEvent then
            pcall(function() stalkEvent:FireServer(target) end)
        end
    end)
end

-- Fungsi untuk menonaktifkan Auto Stalk
local function stopAutoStalk()
    if Connections.Stalk then
        Connections.Stalk:Disconnect()
        Connections.Stalk = nil
    end
end

bypassallkillerSection:AddToggle({
    Title = "Auto Stalk (myers)",
    Default = false,
    Callback = function(v)
        AutoStalk.Enabled = v
        if v then
            startAutoStalk()
        else
            stopAutoStalk()
        end
    end
})

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- HANYA BYPASS CARRY
    if Config.Killer_BypassCarry and method == "GetAttribute" and not checkcaller() then
        if args[1] == "IsCarrying" then
            return false   -- Selalu false agar game menganggap tidak menggendong
        end
    end
    
    -- (Jika ada hook lain, tambahkan di sini)
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

bypassallkillerSection:AddToggle({
    Title = "Unlock Skills While Carrying",
    Default = false,
    Callback = function(v)
        Config.Killer_BypassCarry = v
        if v then
            Library:Notify({Title = "Bypass Carry", Description = "Diaktifkan", Duration = 3})
        else
            Library:Notify({Title = "Bypass Carry", Description = "Dinonaktifkan", Duration = 3})
            -- Hook akan berhenti otomatis karena Config.Killer_BypassCarry = false
           end
       end
    })
    
    -- ==================== [ADDED] COUNTER AUTO PARRY ====================
AntiAutoParryEnabled = false
local ParryAnimList = {}
for id, _ in pairs(VALID_PARRY_IDS) do
    table.insert(ParryAnimList, id)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if not AntiAutoParryEnabled then continue end
        
        local char = LocalPlayer.Character
        if not char then continue end
        
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end
        
        local near = false
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" then
                local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r and (myRoot.Position - r.Position).Magnitude <= 15 then
                    near = true
                    break
                end
            end
        end
        
        if near then
            local randomId = ParryAnimList[math.random(1, #ParryAnimList)]
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. randomId
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            
            if animator then
                local track = animator:LoadAnimation(anim)
                track:Play()
                track:AdjustWeight(0)
                task.wait(0.05)
                track:Stop()
                anim:Destroy()
            end
        end
    end
end)

-- ==================== [ADDED] INFINITE LUNGE ====================
InfiniteLungeEnabled = false

function EnableInfiniteLunge()
    InfiniteLungeEnabled = true
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("lungeboost", 999)
    end
end

function DisableInfiniteLunge()
    InfiniteLungeEnabled = false
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("lungeboost", 1)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.8)
    if InfiniteLungeEnabled and newChar then
        newChar:SetAttribute("lungeboost", 999)
    end
end)

-- ==================== [ADDED] INFINITE FRENZY (JEFF) ====================
local VD = getgenv().VD or {}
getgenv().VD = VD
VD.KILLER_InfFrenzy = false

function NEX_StartJeffCooldownBypass()
    if getgenv().NEX_JeffCooldownBypassThread then return end
    getgenv().NEX_JeffCooldownBypassThread = task.spawn(function()
        while VD.KILLER_InfFrenzy do
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:GetAttribute("Frenzy") ~= true then
                    char:SetAttribute("Frenzy", true)
                end
            end)
            task.wait(0.1)
        end
        getgenv().NEX_JeffCooldownBypassThread = nil
    end)
end

function NEX_StopJeffCooldownBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:GetAttribute("Frenzy") == true then
            char:SetAttribute("Frenzy", false)
            local killer = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Killer")
            if killer then
                local deact = killer:FindFirstChild("Deactivatefromclient")
                if deact then deact:FireServer() end
            end
        end
    end)
end

-- ==================== [ADDED] INFINITE PURSUIT (JASON) ====================
VD.KILLER_InfPursuit = false
local InfPursuitThread = nil

function NEX_StartJasonPursuitBypass()
    if InfPursuitThread then return end
    InfPursuitThread = task.spawn(function()
        while VD.KILLER_InfPursuit do
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:GetAttribute("Pursuit") ~= true then
                    char:SetAttribute("Pursuit", true)
                end
            end)
            task.wait(0.1)
        end
        InfPursuitThread = nil
    end)
end

function NEX_StopJasonPursuitBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:GetAttribute("Pursuit") == true then
            char:SetAttribute("Pursuit", false)
            local jason = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Jason")
            if jason then
                local deact = jason:FindFirstChild("Deactivatefromclient")
                if deact then deact:FireServer() end
            end
        end
    end)
end

-- ==================== [ADDED] HOOK __NAMECALL UNTUK BLOKIR REMOTE ====================
local rawMT = getrawmetatable(game)
local oldNamecall = rawMT.__namecall
setreadonly(rawMT, false)

rawMT.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" then
        local ok, name = pcall(function() return self.Name end)
        if ok then
            -- Infinite Frenzy: blokir Deactivatefromclient & PowerDoneDeactivating
            if VD.KILLER_InfFrenzy and (name == "Deactivatefromclient" or name == "PowerDoneDeactivating") then
                return nil
            end
            -- Infinite Pursuit: blokir Pursuit dengan arg false
            if VD.KILLER_InfPursuit and name == "Pursuit" then
                if #args > 0 and args[1] == false then
                    return nil
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(rawMT, true)

bypassallkillerSection:AddToggle({
    Title = "Counter Auto Parry",
    Default = false,
    Keybind = true,
    Callback = function(v)
        AntiAutoParryEnabled = v
    end
})

bypassallkillerSection:AddToggle({
    Title = "Infinite Lunge",
    Default = false,
    Keybind = true,
    Callback = function(v)
        if v then EnableInfiniteLunge() else DisableInfiniteLunge() end
    end
})

bypassallkillerSection:AddToggle({
    Title = "Infinite Frenzy (Jeff)",
    Default = false,
    Keybind = true,
    Callback = function(v)
        VD.KILLER_InfFrenzy = v
        if v then
            NEX_StartJeffCooldownBypass()
        else
            NEX_StopJeffCooldownBypass()
        end
    end
})

bypassallkillerSection:AddToggle({
    Title = "Infinite Pursuit (Jason)",
    Default = false,
    Keybind = true,
    Callback = function(v)
        VD.KILLER_InfPursuit = v
        if v then
            NEX_StartJasonPursuitBypass()
        else
            NEX_StopJasonPursuitBypass()
         end
      end
    })
end

do

    local AimConfig = AimConfig or {}
    AimConfig.Aim_SilentVeil = false
    AimConfig.Aim_SilentVeilV2 = false
    AimConfig.Veil_ShowFOV = true
    AimConfig.SpearSmart_enable = false
    AimConfig.Veil_FOV = 150
    AimConfig.SPEAR_Speed = 165
    AimConfig.SPEAR_Gravity = workspace.Gravity * 0.5
    AimConfig.SPEAR_MaxDist = 200
    AimConfig.Veil_LeadMultiplier = 1.4
    AimConfig.AIM_Auto = false
    AimConfig.AIM_TargetPart = "Torso"

    local isChargingSpear = false
    local isAttackCooldown = false
    local isFiringSpear = false

    local function IsVeilSilentOn()
        return AimConfig.Aim_SilentVeil or AimConfig.Aim_SilentVeilV2
    end

    function getTargetPartObject(char)
        if AimConfig.AIM_TargetPart == "Head" then 
            return char:FindFirstChild("Head")
        elseif AimConfig.AIM_TargetPart == "Root" or AimConfig.AIM_TargetPart == "HumanoidRootPart" then 
            return char:FindFirstChild("HumanoidRootPart")
        else 
            return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") 
        end
    end

    function getClosestSurvivor()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local closestFovDist = AimConfig.Veil_FOV
        local closestTarget = nil
        local cam = workspace.CurrentCamera
        local centerScreen = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local targetPart = getTargetPartObject(char)
                if hum and hum.Health > 0 and targetPart then
                    local dist3D = (targetPart.Position - myRoot.Position).Magnitude
                    if dist3D <= AimConfig.SPEAR_MaxDist then
                        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
                            local dist2D = (targetPos2D - centerScreen).Magnitude
                            if dist2D <= closestFovDist then
                                closestFovDist = dist2D
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    local veilTargetHighlight = Instance.new("Highlight")
    veilTargetHighlight.Name = "VD_VeilTarget"
    veilTargetHighlight.FillColor = Color3.fromRGB(255, 0, 0)
    veilTargetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    veilTargetHighlight.FillTransparency = 0.5
    veilTargetHighlight.OutlineTransparency = 0

    local VeilTrackerEnabled = false
    local VeilTrackerLine = nil
    local currentVeilBillboard = nil

    local function setupVeilTrackerGui()
        if CoreGui:FindFirstChild("VeilTrackerGui") then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "VeilTrackerGui"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.Parent = CoreGui

        VeilTrackerLine = Instance.new("Frame")
        VeilTrackerLine.Name = "Line"
        VeilTrackerLine.AnchorPoint = Vector2.new(0.5, 0.5)
        VeilTrackerLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        VeilTrackerLine.BackgroundTransparency = 0.2
        VeilTrackerLine.BorderSizePixel = 0
        VeilTrackerLine.Visible = false
        VeilTrackerLine.Parent = sg

        -- fungsi makeVeilBillboard tidak perlu karena kita buat langsung di RenderStepped
        currentVeilBillboard = nil
    end
    setupVeilTrackerGui()

    local VeilFOVFrame = nil
    if not CoreGui:FindFirstChild("FOVCircleGui_Standalone") then
        local FOVGui = Instance.new("ScreenGui")
        FOVGui.Name = "FOVCircleGui_Standalone"
        FOVGui.Parent = CoreGui
        FOVGui.ResetOnSpawn = false
        FOVGui.IgnoreGuiInset = true

        VeilFOVFrame = Instance.new("Frame")
        VeilFOVFrame.BackgroundTransparency = 1
        VeilFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        VeilFOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        VeilFOVFrame.Visible = false
        VeilFOVFrame.Parent = FOVGui
        Instance.new("UICorner", VeilFOVFrame).CornerRadius = UDim.new(1, 0)
        local VeilFOVStroke = Instance.new("UIStroke", VeilFOVFrame)
        VeilFOVStroke.Color = Color3.fromRGB(0, 255, 100)
        VeilFOVStroke.Thickness = 1.5
    end

    local SpearInterceptorHooked = false
    function setupSpearInterceptor()
        if SpearInterceptorHooked then return end
        if not getrawmetatable or not setreadonly then
            warn("[SpearInterceptor]: Executor tidak support.")
            return
        end

        local Spearthrow = nil
        pcall(function()
            Spearthrow = ReplicatedStorage.Remotes.Killers.Veil.Spearthrow
        end)

        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and not checkcaller() and typeof(self) == "Instance" and self.ClassName == "RemoteEvent" and self.Name == "Spearthrow" then
                if AimConfig.Aim_SilentVeil and not AimConfig.Aim_SilentVeilV2 then
                    return nil
                end
                if AimConfig.Aim_SilentVeilV2 and not isFiringSpear then
                    local lookVec, speed, originPos = ...
                    speed = speed or AimConfig.SPEAR_Speed or 165
                    local myChar = LocalPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local startPart = myChar and (myChar:FindFirstChild("Head") or myHRP)
                    local isSpecial = myChar and myChar:GetAttribute("special") == true
                    if Config.SpearSmart_enable then
                        speed = isSpecial and 165 or 142.5
                    else
                        speed = AimConfig.SPEAR_Speed or 165
                    end
                    originPos = originPos or (Config.SpearSmart_enable and myHRP and myHRP.Position) or (startPart and startPart.Position)

                    local bestDir = lookVec
                    local targetPart = getClosestSurvivor()
                    if targetPart and originPos then
                        local targetHRP = targetPart:IsA("Model") and targetPart:FindFirstChild("HumanoidRootPart") or targetPart
                        local targetPos = targetHRP.Position
                        local targetVel = Vector3.new(0,0,0)
                        local targetHum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.MoveDirection.Magnitude > 0 then
                            targetVel = targetHum.MoveDirection * targetHum.WalkSpeed
                        elseif targetHRP:IsA("BasePart") then
                            targetVel = targetHRP.AssemblyLinearVelocity
                        end
                        targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                        local distance = (targetPos - originPos).Magnitude
                        local timeToHit = distance / math.max(speed, 1)
                        if Config.SpearSmart_enable then
                            local leadMultiplier = AimConfig.Veil_LeadMultiplier or 1.4
                            local predictedPos = targetPos + (targetVel * (timeToHit * leadMultiplier))
                            local spearGravity = workspace.Gravity * 0.5
                            local drop = 0.5 * spearGravity * (timeToHit * timeToHit)
                            local finalAimPos = predictedPos + Vector3.new(0, drop - 1.5, 0)
                            bestDir = (finalAimPos - originPos).Unit
                        else
                            local dynamicPrediction = math.clamp(distance / 50, 0.1, 4.0)
                            local predictedPos = targetPos + (targetVel * (timeToHit * dynamicPrediction))
                            local distanceMultiplier = math.clamp(distance / 100, 1, 2.5)
                            local autoGravity = math.max(0, distance - 8)
                            local gravity = AimConfig.AIM_Auto and autoGravity or (AimConfig.SPEAR_Gravity or workspace.Gravity * 0.5)
                            local drop = 0.5 * gravity * (timeToHit * timeToHit) * distanceMultiplier
                            local finalAimPos = predictedPos + Vector3.new(0, drop, 0)
                            bestDir = (finalAimPos - originPos).Unit
                        end
                    end
                    isFiringSpear = true
                    pcall(function()
                        if Spearthrow then Spearthrow:FireServer(bestDir, speed, originPos)
                        else self:FireServer(bestDir, speed, originPos) end
                    end)
                    isFiringSpear = false
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        SpearInterceptorHooked = true
    end
    setupSpearInterceptor()

    -- Input handlers
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        local isTouch = (input.UserInputType == Enum.UserInputType.Touch)
        if gameProcessed and not isTouch then return end

        local char = LocalPlayer.Character
        local isSpearMode = char and char:GetAttribute("spearmode") == true

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if IsVeilSilentOn() and isSpearMode then
                isChargingSpear = true
            end
        end

        if isTouch then
            if IsVeilSilentOn() and isSpearMode then
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local slasherMob = playerGui:FindFirstChild("Slasher-mob")
                    if slasherMob then
                        local controls = slasherMob:FindFirstChild("Controls")
                        if controls then
                            local attackBtn = controls:FindFirstChild("attack")
                            if attackBtn and attackBtn.Visible then
                                local pos = input.Position
                                local absPos = attackBtn.AbsolutePosition
                                local absSize = attackBtn.AbsoluteSize
                                if pos.X >= absPos.X and pos.X <= (absPos.X + absSize.X) and pos.Y >= absPos.Y and pos.Y <= (absPos.Y + absSize.Y) then
                                    isChargingSpear = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        local isTouchEnd = (input.UserInputType == Enum.UserInputType.Touch)

        if isChargingSpear and (input == currentTouchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
            isChargingSpear = false
            if isAttackCooldown then return end
            isAttackCooldown = true
            task.delay(2, function() isAttackCooldown = false end)

            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local startPart = myChar and (myChar:FindFirstChild("Head") or myHRP)
            if startPart and myHRP then
                local isSpecial = myChar:GetAttribute("special") == true
                local startPos = Config.SpearSmart_enable and myHRP.Position or startPart.Position
                local currentSpearSpeed = Config.SpearSmart_enable and (isSpecial and 165 or 142.5) or AimConfig.SPEAR_Speed
                local targetPart = getClosestSurvivor()
                local aimDirection
                if targetPart then
                    local targetHRP = targetPart:IsA("Model") and targetPart:FindFirstChild("HumanoidRootPart") or targetPart
                    local targetPos = targetHRP.Position
                    local targetVel = Vector3.new(0,0,0)
                    local targetHum = targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("Humanoid")
                    if targetHum and targetHum.MoveDirection.Magnitude > 0 then
                        targetVel = targetHum.MoveDirection * targetHum.WalkSpeed
                    elseif targetHRP:IsA("BasePart") then
                        targetVel = targetHRP.AssemblyLinearVelocity
                    end
                    targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                    local distance = (targetPos - startPos).Magnitude
                    local timeToHit = distance / currentSpearSpeed
                    if Config.SpearSmart_enable then
                        local leadMultiplier = AimConfig.Veil_LeadMultiplier or 1.4
                        local predictedPos = targetPos + (targetVel * (timeToHit * leadMultiplier))
                        local spearGravity = workspace.Gravity * 0.5
                        local dropCompensation = 0.5 * spearGravity * (timeToHit ^ 2)
                        local finalAimPos = predictedPos + Vector3.new(0, dropCompensation - 1.5, 0)
                        aimDirection = (finalAimPos - startPos).Unit
                    else
                        local dynamicPrediction = math.clamp(distance / 50, 0.1, 4.0)
                        local predictedPos = targetPos + (targetVel * (timeToHit * dynamicPrediction))
                        local distanceMultiplier = math.clamp(distance / 100, 1, 2.5)
                        local autoGravity = math.max(0, distance - 8)
                        local gravity = AimConfig.AIM_Auto and autoGravity or AimConfig.SPEAR_Gravity
                        local dropCompensation = 0.5 * gravity * (timeToHit ^ 2) * distanceMultiplier
                        local finalAimPos = predictedPos + Vector3.new(0, dropCompensation, 0)
                        aimDirection = (finalAimPos - startPos).Unit
                    end
                else
                    aimDirection = Camera.CFrame.LookVector
                end
                if AimConfig.Aim_SilentVeil then
                    pcall(function()
                        ReplicatedStorage.Remotes.Killers.Veil.Spearthrow:FireServer(aimDirection, currentSpearSpeed, startPos)
                    end)
                end
            end
        end
    end)

-- 8. UI TOGGLE UNTUK VEIL (DI TAB KILLER) - VERSI W424_UI
local VeilGroup = Tabs.Exclusive:AddSection("Silent Aim (Veil Spear)")

VeilGroup:AddToggle({
    Title = "Silent Veil V1",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        AimConfig.Aim_SilentVeil = Value
    end
})

VeilGroup:AddToggle({
    Title = "Silent Veil V2",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        AimConfig.Aim_SilentVeilV2 = Value
        notif("Silent Veil V2: " .. (Value and "ON" or "OFF"))
    end
})

VeilGroup:AddToggle({
    Title = "Auto Predict",
    Default = false,
    Callback = function(Value)
        Config.SpearSmart_enable = Value
    end
})

VeilGroup:AddSlider({
    Title = "Lead Multiplier",
    Min = 0.5,
    Max = 5,
    Default = 1.4,
    Callback = function(Value)
        AimConfig.Veil_LeadMultiplier = Value
    end
})

VeilGroup:AddSlider({
    Title = "Spear Speed",
    Min = 50,
    Max = 200,
    Default = 165,
    Callback = function(Value)
        AimConfig.SPEAR_Speed = Value
    end
})

VeilGroup:AddSlider({
    Title = "Spear Gravity",
    Min = 0,
    Max = 200,
    Default = 103,
    Callback = function(Value)
        AimConfig.SPEAR_Gravity = Value
    end
})

VeilGroup:AddToggle({
    Title = "ESP Tracker Target",
    Default = false,
    Callback = function(Value)
        VeilTrackerEnabled = Value
        if not Value then
            if VeilTrackerLine then VeilTrackerLine.Visible = false end
            if currentVeilBillboard then
                currentVeilBillboard:Destroy()
                currentVeilBillboard = nil
            end
        end
    end
})

VeilGroup:AddToggle({
    Title = "Show Veil FOV",
    Default = true,
    Callback = function(Value)
        AimConfig.Veil_ShowFOV = Value
    end
})

VeilGroup:AddSlider({
    Title = "Veil FOV Radius",
    Min = 50,
    Max = 500,
    Default = 150,
    Callback = function(Value)
        AimConfig.Veil_FOV = Value
    end
})

    -- RenderStepped untuk update visual
    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local isSpearMode = char and char:GetAttribute("spearmode") == true
        local cam = workspace.CurrentCamera

        -- FOV Circle
        if VeilFOVFrame then
            if IsVeilSilentOn() and AimConfig.Veil_ShowFOV and isSpearMode then
                VeilFOVFrame.Visible = true
                VeilFOVFrame.Size = UDim2.new(0, AimConfig.Veil_FOV * 2, 0, AimConfig.Veil_FOV * 2)
            else
                VeilFOVFrame.Visible = false
            end
        end

        -- Target Highlight & Tracker
        if IsVeilSilentOn() and isSpearMode and cam then
            local targetPart = getClosestSurvivor()
            if targetPart and targetPart.Parent then
                veilTargetHighlight.Parent = targetPart.Parent

                if VeilTrackerEnabled then
                    if not currentVeilBillboard or currentVeilBillboard.Parent ~= targetPart then
                        if currentVeilBillboard then currentVeilBillboard:Destroy() end
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "VeilTrackerBillboard"
                        bb.Size = UDim2.fromOffset(14, 14)
                        bb.AlwaysOnTop = true
                        bb.LightInfluence = 0
                        bb.MaxDistance = 500
                        local ring = Instance.new("Frame")
                        ring.AnchorPoint = Vector2.new(0.5, 0.5)
                        ring.Position = UDim2.fromScale(0.5, 0.5)
                        ring.Size = UDim2.fromScale(1, 1)
                        ring.BackgroundTransparency = 1
                        ring.Parent = bb
                        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Color3.fromRGB(0, 255, 100)
                        stroke.Thickness = 1
                        stroke.Transparency = 0.1
                        stroke.Parent = ring
                        bb.Adornee = targetPart
                        bb.Parent = targetPart
                        currentVeilBillboard = bb
                    end

                    local sp, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                    if onScreen and sp.Z > 0 and VeilTrackerLine then
                        local vp = cam.ViewportSize
                        local fromX = vp.X * 0.5
                        local fromY = vp.Y
                        local toX, toY = sp.X, sp.Y
                        local dx, dy = toX - fromX, toY - fromY
                        local length = math.sqrt(dx * dx + dy * dy)
                        VeilTrackerLine.Size = UDim2.fromOffset(math.max(length, 1), 1)
                        VeilTrackerLine.Position = UDim2.fromOffset((fromX + toX) * 0.5, (fromY + toY) * 0.5)
                        VeilTrackerLine.Rotation = math.deg(math.atan2(dy, dx))
                        VeilTrackerLine.Visible = true
                    else
                        if VeilTrackerLine then VeilTrackerLine.Visible = false end
                    end
                else
                    if currentVeilBillboard then
                        currentVeilBillboard:Destroy()
                        currentVeilBillboard = nil
                    end
                    if VeilTrackerLine then VeilTrackerLine.Visible = false end
                end
            else
                veilTargetHighlight.Parent = nil
                if currentVeilBillboard then
                    currentVeilBillboard:Destroy()
                    currentVeilBillboard = nil
                end
                if VeilTrackerLine then VeilTrackerLine.Visible = false end
            end
        else
            veilTargetHighlight.Parent = nil
            if currentVeilBillboard then
                currentVeilBillboard:Destroy()
                currentVeilBillboard = nil
            end
            if VeilTrackerLine then VeilTrackerLine.Visible = false end
        end
    end)

end

do

    function NEX_UpdateCureFlaskLaser()
    local char = LocalPlayer.Character
    if not char then return end

    local targetPos  = nil
    local originPos  = nil
    local closest    = nil
    local minDst     = math.huge
    local hrp        = char:FindFirstChild("HumanoidRootPart")

    if hrp then
        local hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
        originPos  = hand and hand.Position or hrp.Position

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and not v.Character:GetAttribute("IsKiller") then
                local dst = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dst < minDst then
                    minDst  = dst
                    closest = v
                end
            end
        end
    end

    if closest then
        targetPos = closest.Character.HumanoidRootPart.Position
    end

    -- Cek apakah sedang charge/hold flask
    local actionActive = false
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("LocalScript") and child:GetAttribute("action") == true then
            actionActive = true
            break
        end
    end

    if originPos and targetPos and actionActive then
        if not getgenv().NEX_CureFlaskLaserPart then
            local laser = Instance.new("Part")
            laser.Name = "FlaskSilentAimLaser"
            laser.Anchored = true
            laser.CanCollide = false
            laser.CanTouch = false
            laser.CastShadow = false
            laser.Material = Enum.Material.Neon
            laser.Color = Color3.fromRGB(255, 50, 50)
            laser.Transparency = 0
            laser.Parent = workspace
            getgenv().NEX_CureFlaskLaserPart = laser
        end

        local dist = (targetPos - originPos).Magnitude
        if dist > 0.1 then
            local laser = getgenv().NEX_CureFlaskLaserPart
            laser.Size = Vector3.new(0.16, 0.16, dist)
            laser.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
            laser.Transparency = 0
        end
    else
        if getgenv().NEX_CureFlaskLaserPart then
            getgenv().NEX_CureFlaskLaserPart.Transparency = 1
        end
    end
end

function NEX_StartCureFlaskLaser()
    if getgenv().NEX_CureFlaskLaserThread then return end
    getgenv().NEX_CureFlaskLaserThread = RunService.RenderStepped:Connect(function()
        if not VD.KILLER_FlaskLaser then
            if getgenv().NEX_CureFlaskLaserPart then
                pcall(function() getgenv().NEX_CureFlaskLaserPart:Destroy() end)
                getgenv().NEX_CureFlaskLaserPart = nil
            end
            if getgenv().NEX_CureFlaskLaserThread then
                getgenv().NEX_CureFlaskLaserThread:Disconnect()
                getgenv().NEX_CureFlaskLaserThread = nil
            end
            return
        end
        pcall(NEX_UpdateCureFlaskLaser)
    end)
end

local FlaskGroup = Tabs.Killer:AddSection("Silent Aim Flask (Cure)")

-- Toggle Silent Aim Flask
FlaskGroup:AddToggle({
    Title = "Silent Aim Flask (Cure)",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        VD.KILLER_SilentAimFlask = Value
        notif("Silent Aim Flask: " .. (Value and "AKTIF" or "NONAKTIF"))
    end
})

-- Toggle Laser
FlaskGroup:AddToggle({
    Title = "Enable Laser",
    Default = false,
    Keybind = true,
    Callback = function(Value)
        VD.KILLER_FlaskLaser = Value
        if Value then
            pcall(NEX_StartCureFlaskLaser)
            notif("Flask Laser: AKTIF - Laser merah")
        else
            if getgenv().NEX_CureFlaskLaserThread then
                getgenv().NEX_CureFlaskLaserThread:Disconnect()
                getgenv().NEX_CureFlaskLaserThread = nil
            end
            if getgenv().NEX_CureFlaskLaserPart then
                pcall(function() getgenv().NEX_CureFlaskLaserPart:Destroy() end)
                getgenv().NEX_CureFlaskLaserPart = nil
            end
            notif("Flask Laser: NONAKTIF")
        end
     end
   })
end

do 
    local autoHookEnabled = false
    local autoHookThread  = nil
    local charConn        = nil
    AutoHookSection = Tabs.Killer:AddSection("Auto Hook")
    AutoHookSection:AddToggle({
        Title = "Enable Auto Hook",
        Default = false,
        Keybind = true,
        Callback = function(state)
            autoHookEnabled = state
            if autoHookThread then
                pcall(task.cancel, autoHookThread)
                autoHookThread = nil
            end
            if charConn then
                charConn:Disconnect()
                charConn = nil
            end
            if not state then return end
            local Carry      = ReplicatedStorage.Remotes.Carry
            local CarryEvent = Carry.CarrySurvivorEvent
            local HookEvent  = Carry.HookEvent
            local isAutoHooking = false
            local function IsKiller()
                return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
            end
            local function GetAllHooks()
                local hooks = {}
                local searchIn = workspace:FindFirstChild("Map") or workspace
                for _, obj in ipairs(searchIn:GetDescendants()) do
                    if obj.Name == "Hook" and obj:IsA("Model") then
                        local hookPoint = obj:FindFirstChild("HookPoint")
                        if hookPoint then
                            table.insert(hooks, { model = obj, part = hookPoint })
                        end
                    end
                end
                return hooks
            end
            local function IsPlayerOnHook(character, hooks)
                local tr = character:FindFirstChild("HumanoidRootPart")
                if not tr then return false end
                for _, h in ipairs(hooks) do
                    if (h.part.Position - tr.Position).Magnitude < 6 then
                        return true
                    end
                end
                return false
            end
            local function IsPlayerCarried(character)
                return character:GetAttribute("IsCarried") == true
            end
            local function FindDownedSurvivor(hooks)
                local closest, closestDist, closestChar = nil, math.huge, nil
                local r = GetRoot()
                if not r then return nil, nil end
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer or not pl.Character then continue end
                    if not (pl.Team and pl.Team.Name == "Survivors") then continue end
                    local tr = pl.Character:FindFirstChild("HumanoidRootPart")
                    local h  = pl.Character:FindFirstChildOfClass("Humanoid")
                    if not tr or not h then continue end
                    local pct = h.MaxHealth > 0 and (h.Health / h.MaxHealth) or 0
                    if pct > 0.25 or pct <= 0 then continue end
                    if IsPlayerOnHook(pl.Character, hooks) then continue end
                    if IsPlayerCarried(pl.Character) then continue end
                    local d = (tr.Position - r.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest     = tr
                        closestChar = pl.Character
                    end
                end
                return closest, closestChar
            end
            local function FindNearestHook(targetPos, hooks)
                local closest, closestDist = nil, math.huge
                for _, h in ipairs(hooks) do
                    local d = (h.part.Position - targetPos).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest     = h
                    end
                end
                return closest
            end
            local function DoAutoHook()
                if not autoHookEnabled or isAutoHooking then return end
                if not IsKiller() then return end
                local r = GetRoot()
                if not r then return end
                local hooks = GetAllHooks()
                if #hooks == 0 then return end
                local targetRoot, targetChar = FindDownedSurvivor(hooks)
                if not targetRoot then return end
                local nearestHook = FindNearestHook(targetRoot.Position, hooks)
                if not nearestHook then return end
                isAutoHooking = true
                task.spawn(function()
                    pcall(function()
                        r.CFrame = CFrame.new(
                            targetRoot.Position + Vector3.new(0, 3, 0),
                            targetRoot.Position
                        )
                    end)
                    task.wait(0.2)
                    pcall(function() CarryEvent:FireServer(targetChar) end)
                    task.wait(0.5)
                    local r2 = GetRoot()
                    if not r2 then isAutoHooking = false return end
                    pcall(function()
                        r2.CFrame = CFrame.new(
                            nearestHook.part.Position + Vector3.new(0, 3, 0)
                        )
                    end)
                    task.wait(0.3)
                    pcall(function()
                        local hookPoint = nearestHook.model:FindFirstChild("HookPoint")
                            or nearestHook.model:FindFirstChild("HookHitbox")
                            or nearestHook.part
                        HookEvent:FireServer(hookPoint)
                    end)
                    task.wait(1)
                    isAutoHooking = false
                end)
            end
            charConn = LocalPlayer.CharacterAdded:Connect(function()
                isAutoHooking = false
            end)
            autoHookThread = task.spawn(function()
                while autoHookEnabled do
                    if not isAutoHooking and IsKiller() then
                        DoAutoHook()
                    end
                    task.wait(1)
                end
            end)
        end
    })
end

do
    local killAll = false
    KillAllSection = Tabs.Killer:AddSection("Kill All Instant (Riskan)")
    KillAllSection:AddToggle({
        Title = "Enable Kill All",
        Default = false,
        Keybind = true,
        Callback = function(state)
            killAll = state
            if state then
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                    while killAll do
                        if IsPlayerInLobby() then
                            task.wait(0.5)
                            continue
                        end
                        
                        local root = GetRoot()
                        if root then
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LocalPlayer and plr.Character then
                                    if plr.Team and plr.Team.Name == "Spectator" then continue end
                                    
                                    local plrChar = plr.Character
                                    local tr = plrChar:FindFirstChild("HumanoidRootPart")
                                    
                                    local isKnocked = plrChar:GetAttribute("Knocked") 
                                        or plrChar:GetAttribute("IsKnocked")
                                    if isKnocked then continue end
                                    
                                    if tr then
                                        root.CFrame = tr.CFrame * CFrame.new(0, 0, 2)
                                        pcall(function() remote:FireServer() end)
                                        task.wait(0.15)
                                    end
                                end
                            end
                        end
                        task.wait(0.2)
                    end
                end)
            end
        end
    })
end

do
    function Masked(MaskedSelected)
        local ActivatedMaskEvent = game:GetService("ReplicatedStorage").Remotes.Killers.Masked.Activatepower
        ActivatedMaskEvent:FireServer(MaskedSelected)
    end

    local SpearSection = Tabs.Killer:AddSection("Masked [BETA]")
    SpearSection:AddDropdown({Title = "Select Mask", Options =  {"Alex", "Brandon", "Cobra", "Rabbit", "Richter", "Tony"}, Default = "Alex", Callback = function(opts) MaskedSelected = opts end })
    SpearSection:AddButton({Title = "Activated Mask", Callback = function() Masked(MaskedSelected) end})
    SpearSection:AddButton({Title = "Deactivated Mask", Callback = function() local DeactivatedMaskEvent = game:GetService("ReplicatedStorage").Remotes.Killers.Masked.Deactivatepower; DeactivatedMaskEvent:FireServer() end})
end

do
    local autoAttack = false
    local attackRange = 12
    AutoAttackSection = Tabs.Killer:AddSection("Auto Attack")
    AutoAttackSection:AddToggle({
        Title = "Enable Auto Attack (No Animation)",
        Default = false,
        Keybind = true,
        Callback = function(state)
            autoAttack = state
            if state then
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                    while autoAttack do
                        local root = GetRoot()
                        if root then
                            for _, pl in ipairs(Players:GetPlayers()) do
                                if pl ~= LocalPlayer and pl.Character then
                                    local tr = pl.Character:FindFirstChild("HumanoidRootPart")
                                    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                                    if tr and hum and hum.Health > 0 then
                                        if (tr.Position - root.Position).Magnitude <= attackRange then
                                            pcall(function() remote:FireServer(false) end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })
    AutoAttackSection:AddInput({
        Title = "Attack Range (studs)",
        Default = "12",
        Placeholder = "Write ur input here...",
        Callback = function(input)
            local num = tonumber(input)
            if num then attackRange = num end
        end
    })
end

;(function() -- Killer Utility (Utility tab) - closure terpisah
    local noFlashlight = false
    local fixCameraEnabled = false
    KillerUtilitySection = Tabs.Utility:AddSection("Killer Utility")
    KillerUtilitySection:AddButton({
        Title = "Block All Vault",
        Callback = function()
            local VaultEvent = game:GetService("ReplicatedStorage").Remotes.Window.VaultEvent
            local count = 0

            local map = workspace:FindFirstChild("Map")
            if not map then
                game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Map tidak ditemukan", Duration = 3})
                return
            end

            for _, trigger in ipairs(map:GetDescendants()) do
                if trigger.Name == "VaultTrigger" then
                    pcall(function()
                        VaultEvent:FireServer(trigger, true)
                        count = count + 1
                    end)
                end
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "Anti Looping",
                Text = "Successfully Block " .. count .. " Vault!",
                Duration = 5
            })
        end
    })
    KillerUtilitySection:AddButton({
        Title = "Unblock All Vault",
        Callback = function()
            local VaultCompleteEvent = game:GetService("ReplicatedStorage").Remotes.Window.VaultCompleteEvent
            local count = 0

            local map = workspace:FindFirstChild("Map")
            if not map then
                game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Map tidak ditemukan", Duration = 3})
                return
            end

            for _, trigger in ipairs(map:GetDescendants()) do
                if trigger.Name == "VaultPointInUse" then
                    local vaultParent = trigger.Parent
                    
                    if vaultParent then
                        pcall(function()
                            VaultCompleteEvent:FireServer(vaultParent, false)
                            count = count + 1
                        end)
                    end
                end
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "Anti Looping",
                Text = "Successfully Unblock " .. count .. " Vaults!",
                Duration = 5
            })
        end
    })
    KillerUtilitySection:AddToggle({
        Title = "No Flashlight (Anti Blind)",
        Default = false,
        Callback = function(state)
            noFlashlight = state
            if state then
                task.spawn(function()
                    while noFlashlight do
                        local pg = LocalPlayer:FindFirstChild("PlayerGui")
                        if pg then
                            for _, d in pairs(pg:GetDescendants()) do
                                if d:IsA("GuiObject") and d.Name == "Blind" then d:Destroy() end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
    KillerUtilitySection:AddToggle({
        Title = "Anti Break Pallet",
        Default = false,
        Callback = function(v)
            local antiPalletConn = nil
            
            if v then
                local stunOver = ReplicatedStorage.Remotes.Pallet.Jason:WaitForChild("Stunover")
                local stunEvent = ReplicatedStorage.Remotes.Pallet.Jason:FindFirstChild("Stun")
                
                local STUN_ANIMS = {
                    ["rbxassetid://123809268724645"] = true,
                    ["rbxassetid://102055678391920"] = true,
                    ["rbxassetid://88848807662765"] = true,
                }

                if stunEvent then
                    stunEvent.OnClientEvent:Connect(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local animator = hum and hum:FindFirstChildOfClass("Animator")
                        if not animator then return end
                        
                        task.wait(0.1)
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            local id = track.Animation and track.Animation.AnimationId or ""
                            if STUN_ANIMS[id] then
                                track:AdjustSpeed(99)
                            end
                        end
                    end)
                end
                
                antiPalletConn = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not (char and hum) then return end
                    
                    if char:GetAttribute("IsStunned") or hum.WalkSpeed < 3 then
                        pcall(function() stunOver:FireServer() end)
                        char:SetAttribute("Immobile", false)
                        char:SetAttribute("IsStunned", false)
                        hum.WalkSpeed = char:GetAttribute("Speed") or 16
                    end
                end)
            else
                if antiPalletConn then
                    antiPalletConn:Disconnect()
                    antiPalletConn = nil
                end
            end
        end
    })
end)() -- akhir Killer Utility
    
do
    local espEnabled   = false
    local espSurvivor  = true
    local espMurder    = true
    local espGenerator = true
    local espGate      = false
    local espHook      = false
    local espPallet    = false
    local espWindow    = true
    local espZombie    = true
    local ShowName      = false
    local ShowDistance  = false
    local ShowHP        = false
    local ShowHL        = true
    local ShowItemImage = false
    local ShowItemName  = false

    local ITEM_ASSETS = {
        ["Adrenaline Shot"] = "rbxassetid://135388781922226",
        ["Bandage"]         = "rbxassetid://97791520639443",
        ["Flashlight"]      = "rbxassetid://103299939715311",
        ["Gate"]            = "rbxassetid://131249244284700",
        ["Holy Water"]      = "rbxassetid://86130208614143",
        ["Motion Tracker"]  = "rbxassetid://92303584765773",
        ["Riot Shield"]     = "rbxassetid://95718705901699",
        ["Shadow Clone"]    = "rbxassetid://134088840518889",
        ["Twist of Fate"]   = "rbxassetid://98397448432071",
        ["WaxBound Candle"] = "rbxassetid://110413686590821",
    }

    local itemScreenGui = nil
    local itemFrames    = {}
    local itemESPThread = nil
    local IMG_SIZE      = 40
    local NAME_H        = 14

    local playerESP            = {}
    local mapESP               = {}
    local labelCache           = {}
    local scannedObjects       = {}
    local windowObjects        = {}
    local mapScanConnections   = {}
    local perPlayerConnections = {}
    local globalConnections    = {}
    local mapScanned           = false

    local C_SUR    = Color3.fromRGB(64, 224, 255)
    local C_KIL    = Color3.fromRGB(255, 93, 108)
    local C_GEN    = Color3.fromRGB(255, 255, 255)
    local C_GATE   = Color3.fromRGB(255, 255, 255)
    local C_HOOK   = Color3.fromRGB(132, 255, 169)
    local C_PAL    = Color3.fromRGB(74, 255, 181)
    local C_WINDOW = Color3.fromRGB(255, 255, 255)
    local C_ZOMBIE = Color3.fromRGB(255, 200, 0)

    local zombieESP         = {}
    local zombieConnections = {}

    local genConnections = _G.GenConnections or {}
    _G.GenConnections = genConnections

    -- ========================================================
    -- REMOVE WINDOW ESP
    -- ========================================================
    local function removeWindowESP(obj)
        if not obj then return end

        local d = mapESP[obj]
        if d then
            if d.highlight then d.highlight:Destroy() end
            if d.bill then d.bill:Destroy() end
            mapESP[obj] = nil
        end

        local wData = windowObjects[obj]
        if wData then
            if wData.box then pcall(function() wData.box:Destroy() end) end
            if wData.bottomPart and wData.bottomPart.Parent then
                pcall(function()
                    local orig = wData.bottomPart:GetAttribute("ESP_OrigTrans")
                    if orig ~= nil then
                        wData.bottomPart.Transparency = orig
                        wData.bottomPart:SetAttribute("ESP_OrigTrans", nil)
                    end
                end)
            end
            windowObjects[obj] = nil
        end

        scannedObjects[obj] = nil
    end

    -- ========================================================
    -- REMOVE MAP ESP
    -- ========================================================
    local function removeMapESP(obj)
        local d = mapESP[obj]
        if d then
            if d.highlight then d.highlight:Destroy() end
            if d.bill then d.bill:Destroy() end
            if d.genBill then d.genBill:Destroy() end
            mapESP[obj] = nil
        end

        local isGen = obj.Name:lower():match("generator")
        local isCompleted = isGen and (obj:GetAttribute("Completed") == true or (obj:GetAttribute("RepairProgress") or 0) >= 100)

        if not isCompleted then
            scannedObjects[obj] = nil
        end

        if genConnections[obj] then
            for _, conn in pairs(genConnections[obj]) do
                pcall(function() conn:Disconnect() end)
            end
            genConnections[obj] = nil
        end

        if windowObjects[obj] then
            removeWindowESP(obj)
        end
    end

    -- ========================================================
    -- REMOVE PLAYER ESP
    -- ========================================================
    local function removePlayerESP(char)
        local d = playerESP[char]
        if d then
            if d.highlight then d.highlight:Destroy() end
            if d.bill then d.bill:Destroy() end
            playerESP[char] = nil
            labelCache[char] = nil
        end
    end

    -- ========================================================
    -- REMOVE ZOMBIE ESP
    -- ========================================================
    local function removeZombieESP(obj)
        local d = zombieESP[obj]
        if d then
            if d.highlight then d.highlight:Destroy() end
            if d.bill then d.bill:Destroy() end
            zombieESP[obj] = nil
        end
    end

    -- ========================================================
    -- PLAYER ITEM DETECTION
    -- ========================================================
    local function getPlayerItem(pl)
        local char = pl and pl.Character
        if not char then return nil, nil end
        for _, child in pairs(char:GetChildren()) do
            if ITEM_ASSETS[child.Name] then return child.Name, ITEM_ASSETS[child.Name] end
            for _, gc in pairs(child:GetChildren()) do
                if ITEM_ASSETS[gc.Name] then return gc.Name, ITEM_ASSETS[gc.Name] end
            end
        end
        return nil, nil
    end

    local function removeItemFrame(pl)
        local f = itemFrames[pl]
        if f and f.frame and f.frame.Parent then f.frame:Destroy() end
        itemFrames[pl] = nil
    end

    local function clearAllItemFrames()
        for pl in pairs(itemFrames) do removeItemFrame(pl) end
        if itemScreenGui and itemScreenGui.Parent then
            itemScreenGui:Destroy()
            itemScreenGui = nil
        end
    end

    local function stopItemESPThread()
        if itemESPThread then
            pcall(task.cancel, itemESPThread)
            itemESPThread = nil
        end
        clearAllItemFrames()
    end

    local function getOrCreateItemGui()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
        local gui = pg:FindFirstChild("ItemESPGui")
        if not gui then
            gui = Instance.new("ScreenGui")
            gui.Name = "ItemESPGui"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.DisplayOrder = 999
            gui.Parent = pg
        end
        itemScreenGui = gui
        return gui
    end

    local function getOrCreateItemFrame(pl, gui)
        if itemFrames[pl] and itemFrames[pl].frame and itemFrames[pl].frame.Parent then
            return itemFrames[pl]
        end

        local frame = Instance.new("Frame")
        frame.Name = "IF_" .. pl.Name
        frame.Size = UDim2.new(0, IMG_SIZE * 3, 0, IMG_SIZE + NAME_H + 2)
        frame.BackgroundTransparency = 1
        frame.Parent = gui

        local imgLbl = Instance.new("ImageLabel", frame)
        imgLbl.Size = UDim2.new(0, IMG_SIZE, 0, IMG_SIZE)
        imgLbl.Position = UDim2.new(0, 0, 0, 0)
        imgLbl.BackgroundTransparency = 1
        imgLbl.ScaleType = Enum.ScaleType.Fit
        imgLbl.Visible = false

        local nameLbl = Instance.new("TextLabel", frame)
        nameLbl.Size = UDim2.new(1, 0, 0, NAME_H)
        nameLbl.Position = UDim2.new(0, 0, 0, IMG_SIZE + 2)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 11
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.Visible = false

        local t = { frame = frame, imgLbl = imgLbl, nameLbl = nameLbl }
        itemFrames[pl] = t
        return t
    end

    local function startItemESPThread()
        stopItemESPThread()
        if not espEnabled or (not ShowItemImage and not ShowItemName) then return end

        local gui = getOrCreateItemGui()

        itemESPThread = task.spawn(function()
            while espEnabled and (ShowItemImage or ShowItemName) do
                local cam = workspace.CurrentCamera
                for char, data in pairs(playerESP) do
                    if not data.isKiller then
                        local pl = Players:GetPlayerFromCharacter(char)
                        if pl then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if not hrp then
                                removeItemFrame(pl)
                            else
                                local iName, iAsset = getPlayerItem(pl)
                                if not iName then
                                    removeItemFrame(pl)
                                else
                                    local footPos = hrp.CFrame * CFrame.new(0, -4, 0)
                                    local sp, inView = cam:WorldToViewportPoint(footPos.Position)
                                    if not inView or sp.Z < 0 then
                                        removeItemFrame(pl)
                                    else
                                        local f = getOrCreateItemFrame(pl, gui)
                                        local dist = (hrp.Position - cam.CFrame.Position).Magnitude
                                        local scaledSize = math.clamp(1400 / dist, 18, 40)
                                        local totalScaledH = (ShowItemImage and scaledSize or 0) + (ShowItemName and (NAME_H + 2) or 0)
                                        f.frame.Position = UDim2.new(0, sp.X - (scaledSize / 2), 0, sp.Y)
                                        f.frame.Size = UDim2.new(0, scaledSize, 0, totalScaledH)
                                        f.imgLbl.Size = UDim2.new(1, 0, 0, scaledSize)
                                        f.imgLbl.Image = iAsset
                                        f.imgLbl.Visible = ShowItemImage
                                        if ShowItemImage and ShowItemName then
                                            f.imgLbl.Position = UDim2.new(0, 0, 0, 0)
                                            f.nameLbl.Position = UDim2.new(0, 0, 0, scaledSize + 2)
                                        elseif ShowItemName then
                                            f.nameLbl.Position = UDim2.new(0, 0, 0, 0)
                                        end
                                        f.nameLbl.Text = iName
                                        f.nameLbl.Visible = ShowItemName
                                    end
                                end
                            end
                        end
                    end
                end
                for pl in pairs(itemFrames) do
                    local char = pl.Character
                    if not char or not playerESP[char] then removeItemFrame(pl) end
                end
                task.wait()
            end
            clearAllItemFrames()
        end)
    end

    -- ========================================================
    -- BUILD ESP
    -- ========================================================
    local function buildESP(obj, color, title)
        local hl = Instance.new("Highlight")
        hl.Adornee = obj
        hl.FillColor = color
        hl.FillTransparency = 0.8
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = ShowHL
        hl.Parent = obj

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 400, 0, 30)
        bill.Adornee = obj
        bill.AlwaysOnTop = true
        bill.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
        bill.Parent = obj

        local mainLbl = Instance.new("TextLabel", bill)
        mainLbl.Size = UDim2.new(1, 0, 1, 0)
        mainLbl.BackgroundTransparency = 1
        mainLbl.Font = Enum.Font.GothamBold
        mainLbl.TextSize = 13
        mainLbl.TextColor3 = color
        mainLbl.TextStrokeTransparency = 0
        mainLbl.TextXAlignment = Enum.TextXAlignment.Center

        local isKiller = (color == C_KIL)
        local isGen = title == "Generator"
        local finalTitle = title or obj.Name
        if _G.HiddenNameEnabled and not isKiller then
            finalTitle = "RynerHUB"
        end

        mainLbl.Text = finalTitle
        mainLbl.Visible = false

        local genBill = nil
        if isGen then
            genBill = Instance.new("BillboardGui")
            genBill.Size = UDim2.new(0, 120, 0, 26)
            genBill.MaxDistance = 90
            genBill.Adornee = obj
            genBill.AlwaysOnTop = true
            genBill.StudsOffsetWorldSpace = Vector3.new(0, 0.5, 0)
            genBill.LightInfluence = 0
            genBill.Parent = obj

            local bg = Instance.new("Frame", genBill)
            bg.Size = UDim2.new(1, 0, 0, 10)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            bg.BorderSizePixel = 0
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

            local fill = Instance.new("Frame", bg)
            fill.Name = "Fill"
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            fill.BorderSizePixel = 0
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

            local pctLbl = Instance.new("TextLabel", genBill)
            pctLbl.Name = "PctLabel"
            pctLbl.Size = UDim2.new(1, 0, 0, 12)
            pctLbl.Position = UDim2.new(0, 0, 0, 10)
            pctLbl.BackgroundTransparency = 1
            pctLbl.Font = Enum.Font.GothamBold
            pctLbl.TextSize = 12
            pctLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            pctLbl.TextStrokeTransparency = 0
            pctLbl.Text = "0%"
            pctLbl.TextXAlignment = Enum.TextXAlignment.Center

            local function updateBar()
                if not obj or not obj.Parent then return end
                local progress = math.clamp(obj:GetAttribute("RepairProgress") or 0, 0, 100)
                local t = progress / 100
                local barColor
                if t < 0.5 then
                    barColor = Color3.new(1, t * 2, 0)
                else
                    barColor = Color3.new(1 - (t - 0.5) * 2, 1, 0)
                end
                fill.Size = UDim2.new(t, 0, 1, 0)
                fill.BackgroundColor3 = barColor
                pctLbl.Text = math.floor(progress) .. "%"
                pctLbl.TextColor3 = barColor
            end

            updateBar()
            obj:GetAttributeChangedSignal("RepairProgress"):Connect(updateBar)
        end

        return { highlight = hl, bill = bill, mainLbl = mainLbl, baseName = title or obj.Name, genBill = genBill }
    end

    -- ========================================================
    -- MAP FOLDERS
    -- ========================================================
    local function getMapFolders()
        local folders = {}
        local map = workspace:FindFirstChild("Map")
        if map then
            table.insert(folders, map)
            for _, c in pairs(map:GetChildren()) do
                if c:IsA("Folder") or c:IsA("Model") then
                    table.insert(folders, c)
                end
            end
        else
            table.insert(folders, workspace)
        end
        return folders
    end

    local function getGameValue(obj, name)
        if not obj then return nil end
        local a = obj:GetAttribute(name)
        if a ~= nil then return a end
        local c = obj:FindFirstChild(name)
        if c then
            local ok, v = pcall(function() return c.Value end)
            if ok then return v end
        end
        return nil
    end

    local function isKnockedDown(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return true end
        if char:FindFirstChild("Knocked") then return true end
        if char:GetAttribute("Knocked") == true then return true end
        return false
    end

    -- ========================================================
    -- ZOMBIE SCAN
    -- ========================================================
    local function scanZombies()
        for _, conn in pairs(zombieConnections) do
            pcall(function() conn:Disconnect() end)
        end
        zombieConnections = {}
        for obj in pairs(zombieESP) do removeZombieESP(obj) end

        if not espZombie or not espEnabled then return end

        local function checkAndAddZombie(obj)
            if not obj or not obj:IsA("Model") then return end
            if not obj.Name:lower():find("^scp") then return end

            local hasHumanoid = obj:FindFirstChildOfClass("Humanoid")
            local hasBody = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")

            if hasHumanoid or hasBody then
                if not zombieESP[obj] then
                    zombieESP[obj] = buildESP(obj, C_ZOMBIE, obj.Name)
                end
            end
        end

        for _, child in pairs(workspace:GetChildren()) do
            checkAndAddZombie(child)
        end

        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            for _, desc in pairs(mapFolder:GetDescendants()) do
                checkAndAddZombie(desc)
            end
        end

        table.insert(zombieConnections, workspace.ChildAdded:Connect(function(child)
            task.wait(0.1)
            checkAndAddZombie(child)
        end))

        if mapFolder then
            table.insert(zombieConnections, mapFolder.DescendantAdded:Connect(function(desc)
                task.wait(0.2)
                checkAndAddZombie(desc)
            end))
        end

        table.insert(zombieConnections, workspace.DescendantRemoving:Connect(function(desc)
            if zombieESP[desc] then
                removeZombieESP(desc)
            end
        end))
    end

    -- ========================================================
    -- PLAYER ESP
    -- ========================================================
    local function applyPlayerESP(pl)
        local char = pl.Character
        if not char or char.Name == "Lobby" then return end

        local isMurder = false
        for _ = 1, 10 do
            if pl.Team and pl.Team.Name ~= "Neutral" and pl.Team.Name ~= "" then
                isMurder = pl.Team.Name == "Killer"
                break
            end
            task.wait(0.5)
        end

        local existing = playerESP[char]
        if existing and existing.isMurder ~= isMurder then
            removePlayerESP(char)
            existing = nil
        end

        if isMurder then
            if not espMurder then removePlayerESP(char) return end
            if not existing then
                local selKiller = getGameValue(pl, "SelectedKiller")
                local kName = (selKiller and tostring(selKiller) ~= "") and tostring(selKiller) or pl.Name
                local d = buildESP(char, C_KIL, kName)
                d.isMurder = true
                d.isKiller = true
                playerESP[char] = d
            end
        else
            if not espSurvivor then removePlayerESP(char) return end
            if not existing then
                local d = buildESP(char, C_SUR, pl.Name)
                d.isMurder = false
                d.isKiller = false
                d.wasKnocked = false
                playerESP[char] = d
            end
        end
    end

    -- ========================================================
    -- CLEANUP
    -- ========================================================
    local function clearMapConnections()
        for _, conn in pairs(mapScanConnections) do
            pcall(function() conn:Disconnect() end)
        end
        mapScanConnections = {}
    end

    local function clearAllMapESP()
        for obj in pairs(mapESP) do removeMapESP(obj) end
        for obj in pairs(windowObjects) do removeWindowESP(obj) end
        scannedObjects = {}
    end

    -- ========================================================
    -- HANDLE WINDOW OBJECT
    -- ========================================================
    local function handleWindowObject(child)
        if not espWindow then return end
        if child.Name ~= "VaultTrigger" then return end

        local winModel = child.Parent
        if not winModel then return end
        if not winModel:IsA("Model") then return end

        if scannedObjects[winModel] or mapESP[winModel] then return end
        scannedObjects[winModel] = true

        local bottomPart = winModel:FindFirstChild("Bottom")
    if not bottomPart or not bottomPart:IsA("BasePart") then
        local bestSize = 0
        for _, p in ipairs(winModel:GetChildren()) do
            if p:IsA("BasePart")
               and p.Name ~= "VaultTrigger"
               and p.Name ~= "inviswall"
               and p.Size.Magnitude > bestSize then
                bestSize = p.Size.Magnitude
                bottomPart = p
            end
        end
    end

        if not bottomPart then return end

        if bottomPart:GetAttribute("ESP_OrigTrans") == nil then
            bottomPart:SetAttribute("ESP_OrigTrans", bottomPart.Transparency)
        end
        if bottomPart.Transparency > 0.5 then
            bottomPart.Transparency = 0.5
        end

        local box = Instance.new("BoxHandleAdornment")
        box.Name = "WindowBox"
        box.Adornee = bottomPart
        box.Size = bottomPart.Size
        box.Color3 = C_WINDOW
        box.Transparency = 0.3
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Parent = bottomPart

        local hl = Instance.new("Highlight")
        hl.Adornee = winModel
        hl.FillColor = C_WINDOW
        hl.FillTransparency = 0.9
        hl.OutlineColor = C_WINDOW
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = ShowHL
        hl.Parent = winModel

        mapESP[winModel] = {
            highlight = hl,
            baseName = "Window",
        }
        windowObjects[winModel] = {
            box = box,
            bottomPart = bottomPart,
        }
    end

    -- ========================================================
    -- HANDLE MAP OBJECT
    -- ========================================================
    local function handleMapObject(child)
        if not espEnabled then return end

        local rootModel = child
        if not child:IsA("Model") and not child:IsA("Folder") and child.Parent then
            if child.Parent:IsA("Model") or child.Parent:IsA("Folder") then
                rootModel = child.Parent
            end
        end

        if scannedObjects[rootModel] then return end
        local nameLower = rootModel.Name:lower()

        if nameLower:match("generator") then
            if espGenerator then
                local function isGenDone(obj)
                    return obj:GetAttribute("Completed") == true
                        or (obj:GetAttribute("RepairProgress") or 0) >= 100
                end

                if isGenDone(rootModel) then
                    if mapESP[rootModel] then removeMapESP(rootModel) end
                    scannedObjects[rootModel] = true
                    return
                end

                scannedObjects[rootModel] = true
                mapESP[rootModel] = buildESP(rootModel, C_GEN, "Generator")

                local function checkGenStatus()
                    if not rootModel or not rootModel.Parent then
                        if mapESP[rootModel] then removeMapESP(rootModel) end
                        return
                    end
                    if isGenDone(rootModel) then
                        local d = mapESP[rootModel]
                        if d then
                            if d.highlight then d.highlight:Destroy() end
                            if d.bill then d.bill:Destroy() end
                            if d.genBill then d.genBill:Destroy() end
                            mapESP[rootModel] = nil
                        end
                        if genConnections[rootModel] then
                            for _, conn in pairs(genConnections[rootModel]) do
                                pcall(function() conn:Disconnect() end)
                            end
                            genConnections[rootModel] = nil
                        end
                    end
                end

                if genConnections[rootModel] then
                    for _, conn in pairs(genConnections[rootModel]) do
                        pcall(function() conn:Disconnect() end)
                    end
                end

                genConnections[rootModel] = {
                    rootModel:GetAttributeChangedSignal("Completed"):Connect(checkGenStatus),
                    rootModel:GetAttributeChangedSignal("RepairProgress"):Connect(checkGenStatus),
                }

                task.spawn(function()
                    while rootModel and rootModel.Parent and mapESP[rootModel] do
                        task.wait(2)
                        checkGenStatus()
                    end
                end)
            end
            return
        end

        if nameLower == "pallet" or nameLower == "palletwrong" then
            if rootModel:IsA("Model") then
                if espPallet and not mapESP[rootModel] then
                    scannedObjects[rootModel] = true
                    mapESP[rootModel] = buildESP(rootModel, C_PAL, nameLower:match("wrong") and "Fake Pallet" or "Pallet")
                end
            end
            return
        end

        if child.Name == "VaultTrigger" or child.Name == "Bottom" then
            handleWindowObject(child)
            return
        end

        if child.Name == "ExitLever" or child.Name == "RightGate" or child.Name == "LeftGate" then
            if espGate and not mapESP[child] and not scannedObjects[child] then
                scannedObjects[child] = true
                local displayTitle = child.Name == "ExitLever" and "Gate Lever" or "Gate Door"
                mapESP[child] = buildESP(child, C_GATE, displayTitle)
            end
            return
        elseif (child:IsA("Folder") or child:IsA("Model")) and (nameLower:match("gate") or child.Name:match("^%d+$")) then
            if espGate then
                for _, subChild in pairs(child:GetChildren()) do
                    if subChild.Name == "ExitLever" or subChild.Name == "RightGate" or subChild.Name == "LeftGate" then
                        if not mapESP[subChild] and not scannedObjects[subChild] then
                            scannedObjects[subChild] = true
                            local displayTitle = subChild.Name == "ExitLever" and "Gate Lever" or "Gate Door"
                            mapESP[subChild] = buildESP(subChild, C_GATE, displayTitle)
                        end
                    end
                end
            end
            return
        end

        if nameLower:match("hook") then
            if nameLower:match("meat") then return end

            if espHook then
                local targetObj = rootModel:FindFirstChild("Model") or rootModel
                if not mapESP[targetObj] and not scannedObjects[targetObj] then
                    scannedObjects[targetObj] = true
                    mapESP[targetObj] = buildESP(targetObj, C_HOOK, "Hook")
                end
            end
        end
    end

    -- ========================================================
    -- SCAN MAP
    -- ========================================================
    local function scanMapOnce()
        if not espEnabled then return end
        if mapScanned then return end
        mapScanned = true
        clearMapConnections()
        clearAllMapESP()

        for _, folder in pairs(getMapFolders()) do
            local function scanLevel(parent, depth)
                if depth > 4 then return end
                for _, child in pairs(parent:GetChildren()) do
                    local cNameLower = child.Name:lower()

                    handleMapObject(child)

                    if child:IsA("Folder") or child:IsA("Model") then
                        if cNameLower:match("generator") or child.Name == "Pallet" or child.Name == "Palletwrong" then
                            -- skip
                        else
                            scanLevel(child, depth + 1)
                        end
                    end
                end
            end

            scanLevel(folder, 1)

            table.insert(mapScanConnections, folder.DescendantAdded:Connect(function(desc)
                task.wait()
                handleMapObject(desc)
            end))
            table.insert(mapScanConnections, folder.DescendantRemoving:Connect(function(desc)
                removeMapESP(desc)
                if desc.Parent and mapESP[desc.Parent] then removeMapESP(desc.Parent) end
            end))
        end
        scanZombies()
    end

    -- ========================================================
    -- LABEL & ESP LOOP
    -- ========================================================
    local function buildLabelText(char, data, hrp)
        local tp = char:FindFirstChild("HumanoidRootPart")
        if not tp then return nil end
        local parts = {}
        if ShowName then
            if _G.HiddenNameEnabled and not data.isKiller then
                parts[#parts + 1] = "RynerHUB"
            else
                parts[#parts + 1] = data.baseName
            end
        end
        if ShowHP then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                parts[#parts + 1] = "[ " .. math.floor(hum.Health) .. " HP ]"
            end
        end
        if ShowDistance and hrp then
            local dist = math.floor((hrp.Position - tp.Position).Magnitude / 2) * 2
            parts[#parts + 1] = "[ " .. dist .. " M ]"
        end
        return #parts > 0 and table.concat(parts, " ") or nil
    end

    local function startEspLoop()
        if _G.MengHubThread then
            pcall(task.cancel, _G.MengHubThread)
            _G.MengHubThread = nil
        end

        local needLabel = ShowName or ShowDistance or ShowHP
        if not needLabel then
            for char, data in pairs(playerESP) do
                if data.highlight then data.highlight.Enabled = ShowHL end
                if data.mainLbl then data.mainLbl.Visible = false end
            end
            for obj, data in pairs(zombieESP) do
                if data.highlight then data.highlight.Enabled = ShowHL end
            end
            return
        end

        _G.MengHubThread = task.spawn(function()
            while espEnabled do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                for char, data in pairs(playerESP) do
                    if char and char.Parent then
                        if data.highlight then data.highlight.Enabled = ShowHL end

                        if data.isKiller then
                            local newText = buildLabelText(char, data, hrp)
                            if newText then
                                if labelCache[char] ~= newText then
                                    labelCache[char] = newText
                                    data.mainLbl.Text = newText
                                    data.mainLbl.Visible = true
                                end
                            else
                                labelCache[char] = nil
                                removePlayerESP(char)
                            end
                        else
                            local knocked = isKnockedDown(char)
                            if data.wasKnocked ~= knocked then
                                data.wasKnocked = knocked
                                local targetColor = knocked and Color3.fromRGB(255, 165, 0) or C_SUR
                                if data.highlight then
                                    data.highlight.FillColor = targetColor
                                    data.highlight.OutlineColor = targetColor
                                end
                                if data.mainLbl then
                                    data.mainLbl.TextColor3 = targetColor
                                end
                            end

                            local newText = buildLabelText(char, data, hrp)
                            if newText then
                                if labelCache[char] ~= newText then
                                    labelCache[char] = newText
                                    data.mainLbl.Text = newText
                                    data.mainLbl.Visible = true
                                end
                            else
                                labelCache[char] = nil
                                removePlayerESP(char)
                            end
                        end
                    else
                        labelCache[char] = nil
                        removePlayerESP(char)
                    end
                end

                for obj, data in pairs(zombieESP) do
                    if obj and obj.Parent then
                        if data.highlight then data.highlight.Enabled = ShowHL end
                    else
                        removeZombieESP(obj)
                    end
                end

                task.wait(1.5)
            end
        end)
    end

    -- ========================================================
    -- PLAYER WATCHER
    -- ========================================================
    local function cleanupPlayer(pl)
        if perPlayerConnections[pl] then
            for _, c in pairs(perPlayerConnections[pl]) do
                pcall(function() c:Disconnect() end)
            end
            perPlayerConnections[pl] = nil
        end
        if pl.Character then removePlayerESP(pl.Character) end
    end

    local function watchPlayer(pl)
        if pl == LocalPlayer then return end

        if perPlayerConnections[pl] then
            for _, c in pairs(perPlayerConnections[pl]) do
                pcall(function() c:Disconnect() end)
            end
        end

        perPlayerConnections[pl] = {
            pl.CharacterAdded:Connect(function()
                task.wait(2)
                if espEnabled then applyPlayerESP(pl) end
            end),
            pl.CharacterRemoving:Connect(function(char)
                removePlayerESP(char)
            end),
            pl:GetPropertyChangedSignal("Team"):Connect(function()
                task.wait(0.5)
                if not espEnabled then return end
                if not pl.Character or pl.Character.Name == "Lobby" then return end
                local char = pl.Character
                local existing = playerESP[char]
                if existing then
                    removePlayerESP(char)
                end
                applyPlayerESP(pl)
            end),
        }

        if pl.Character and espEnabled then
            applyPlayerESP(pl)
        end
    end

    local function setupPlayerEvents()
        for pl in pairs(perPlayerConnections) do
            cleanupPlayer(pl)
        end
        perPlayerConnections = {}

        for _, conn in pairs(globalConnections) do
            pcall(function() conn:Disconnect() end)
        end
        globalConnections = {}

        for _, pl in pairs(Players:GetPlayers()) do
            watchPlayer(pl)
        end

        table.insert(globalConnections, Players.PlayerAdded:Connect(function(pl)
            watchPlayer(pl)
        end))

        table.insert(globalConnections, Players.PlayerRemoving:Connect(function(pl)
            cleanupPlayer(pl)
        end))
    end

    LocalPlayer.CharacterAdded:Connect(function()
        mapScanned = false
        labelCache = {}
        clearAllMapESP()
        clearMapConnections()
        stopItemESPThread()
        for obj in pairs(zombieESP) do removeZombieESP(obj) end
        for _, conn in pairs(zombieConnections) do
            pcall(function() conn:Disconnect() end)
        end
        zombieConnections = {}
        for c in pairs(playerESP) do removePlayerESP(c) end
        task.wait(2)
        if espEnabled then
            setupPlayerEvents()
            scanMapOnce()
            startEspLoop()
            startItemESPThread()
        end
    end)

    -- ========================================================
    -- UI ESP
    -- ========================================================
    local s1 = Tabs.ESP:AddSection("Enable ESP")
    s1:AddToggle({ Title = "Enable ESP", Default = false, Callback = function(v)
        espEnabled = v
        if not v then
            if _G.MengHubThread then
                pcall(task.cancel, _G.MengHubThread)
                _G.MengHubThread = nil
            end
            stopItemESPThread()
            for char in pairs(playerESP) do removePlayerESP(char) end
            clearAllMapESP()
            clearMapConnections()
            for obj in pairs(zombieESP) do removeZombieESP(obj) end
            for _, conn in pairs(zombieConnections) do
                pcall(function() conn:Disconnect() end)
            end
            zombieConnections = {}
            for pl in pairs(perPlayerConnections) do cleanupPlayer(pl) end
            for _, conn in pairs(globalConnections) do
                pcall(function() conn:Disconnect() end)
            end
            globalConnections = {}
            labelCache = {}
            mapScanned = false
            return
        end
        setupPlayerEvents()
        scanMapOnce()
        startEspLoop()
        startItemESPThread()
    end })

    s1:AddToggle({
        Title = "Enable Killer Prediction",
        Default = false,
        Callback = function(v)
            local function getFreshPlayerGui()
                return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
            end

            local currentPg = getFreshPlayerGui()
            local oldGui = currentPg:FindFirstChild("KillerPredictUI")
            if oldGui then oldGui:Destroy() end

            getgenv().KillerPredictEnabled = v
            if not v then return end

            local function buildGui()
                local targetPg = getFreshPlayerGui()
                local old = targetPg:FindFirstChild("KillerPredictUI")
                if old then old:Destroy() end

                local gui = Instance.new("ScreenGui")
                gui.Name = "KillerPredictUI"
                gui.ResetOnSpawn = false
                gui.IgnoreGuiInset = true
                gui.Parent = targetPg

                local frame = Instance.new("Frame")
                frame.Name = "MainFrame"
                frame.Size = UDim2.new(0, 160, 0, 45)
                frame.Position = UDim2.new(0.5, -80, 0, 55)
                frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
                frame.BackgroundTransparency = 0.35
                frame.BorderSizePixel = 0
                frame.Visible = false
                frame.Parent = gui

                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

                local stroke = Instance.new("UIStroke", frame)
                stroke.Color = Color3.fromRGB(168, 85, 247)
                stroke.Thickness = 1.8
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0.45, 0)
                title.Position = UDim2.new(0, 0, 0, 0)
                title.BackgroundTransparency = 1
                title.Text = "Predict Next Killer"
                title.TextColor3 = Color3.fromRGB(255, 100, 100)
                title.Font = Enum.Font.GothamBold
                title.TextSize = 11
                title.TextXAlignment = Enum.TextXAlignment.Center
                title.Parent = frame

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "PredictName"
                nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
                nameLabel.Position = UDim2.new(0, 0, 0.45, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = "Scanning..."
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 13
                nameLabel.TextXAlignment = Enum.TextXAlignment.Center
                nameLabel.Parent = frame

                return gui
            end

            buildGui()

            local function getPredictUIComponents()
                local activePg = getFreshPlayerGui()
                local gui = activePg:FindFirstChild("KillerPredictUI")
                if not gui then
                    gui = buildGui()
                end
                local frame = gui:FindFirstChild("MainFrame")
                local nameLabel = frame and frame:FindFirstChild("PredictName")
                return frame, nameLabel
            end

            task.spawn(function()
                while getgenv().KillerPredictEnabled do
                    pcall(function()
                        local team = LocalPlayer.Team
                        local isSpectator = team and team.Name == "Spectator"

                        local frame, nameLabel = getPredictUIComponents()

                        if frame then
                            if frame.Visible ~= isSpectator then
                                frame.Visible = isSpectator
                            end
                        end

                        if not isSpectator then return end

                        local activePg = getFreshPlayerGui()
                        local spectatorGui = activePg:FindFirstChild("Spectator")
                        local info = spectatorGui and spectatorGui:FindFirstChild("Info")
                        local leaderboardParent = info and info:FindFirstChild("Leaderboard")
                        local leaderboard = leaderboardParent and leaderboardParent:FindFirstChild("Leaderboard")

                        if not leaderboard then
                            if nameLabel and nameLabel.Text ~= "Waiting..." then
                                nameLabel.Text = "Waiting..."
                            end
                            return
                        end

                        local highestKC = -1
                        local predictedName = "Unknown"

                        for _, playerFrame in ipairs(leaderboard:GetChildren()) do
                            if playerFrame:IsA("GuiObject") then
                                local kcFolder = playerFrame:FindFirstChild("kc")
                                local kcLabel = kcFolder and kcFolder:FindFirstChild("kc")
                                if kcLabel then
                                    local val = tonumber(kcLabel.Text) or 0
                                    if val > highestKC then
                                        highestKC = val
                                        predictedName = playerFrame.Name
                                    end
                                end
                            end
                        end

                        local yourFrame = info:FindFirstChild("Your")
                        local myKC = yourFrame and yourFrame:FindFirstChild("KillerChance")
                        local myKCVal = myKC and tonumber(myKC.Text) or 0

                        if myKCVal > highestKC then
                            predictedName = LocalPlayer.Name .. " (You)"
                        end

                        if nameLabel and nameLabel.Text ~= predictedName then
                            nameLabel.Text = predictedName
                        end
                    end)

                    task.wait(1)
                end
            end)
        end
    })

    local s2 = Tabs.ESP:AddSection("ESP Role")
    s2:AddToggle({ Title = "ESP Survivor",     Default = true, Callback = function(v) espSurvivor = v end })
    s2:AddToggle({ Title = "ESP Killer",       Default = true, Callback = function(v) espMurder = v end })
    s2:AddToggle({ Title = "ESP Zombie Dummy", Default = true, Callback = function(v)
        espZombie = v
        if not v then
            for obj in pairs(zombieESP) do removeZombieESP(obj) end
        else
            if espEnabled then scanZombies() end
        end
    end })

    local s3 = Tabs.ESP:AddSection("ESP Object")
    s3:AddToggle({ Title = "ESP Generator", Default = true, Callback = function(v) espGenerator = v; if v and espEnabled then mapScanned = false; scanMapOnce() end end })
    s3:AddToggle({ Title = "ESP Gate",      Default = false, Callback = function(v) espGate = v; if v and espEnabled then mapScanned = false; scanMapOnce() end end })
    s3:AddToggle({ Title = "ESP Hook",      Default = false, Callback = function(v) espHook = v; if v and espEnabled then mapScanned = false; scanMapOnce() end end })
    s3:AddToggle({ Title = "ESP Pallet",    Default = false, Callback = function(v) espPallet = v; if v and espEnabled then mapScanned = false; scanMapOnce() end end })

    s3:AddToggle({
        Title = "ESP Vault",
        Default = true,
        Callback = function(v)
            espWindow = v
            if v then
                if espEnabled then
                    mapScanned = false
                    scanMapOnce()
                end
            else
                for obj in pairs(windowObjects) do
                    removeWindowESP(obj)
                end
                for obj, data in pairs(mapESP) do
                    if data.baseName == "Window" then
                        removeMapESP(obj)
                    end
                end
            end
        end
    })

    local function onLabelToggle()
        if espEnabled then startEspLoop() end
    end

    local s4 = Tabs.ESP:AddSection("ESP Settings")
    s4:AddToggle({ Title = "Show Name",       Default = false, Callback = function(v) ShowName = v;      onLabelToggle() end })
    s4:AddToggle({ Title = "Show Distance",   Default = false, Callback = function(v) ShowDistance = v;  onLabelToggle() end })
    s4:AddToggle({ Title = "Show Health",     Default = false, Callback = function(v) ShowHP = v;        onLabelToggle() end })
    s4:AddToggle({ Title = "Show Item Image", Default = false, Callback = function(v) ShowItemImage = v; startItemESPThread() end })
    s4:AddToggle({ Title = "Show Item Name",  Default = false, Callback = function(v) ShowItemName = v;  startItemESPThread() end })

    local colorTemplates = {
        ["Default Survivor"]     = Color3.fromRGB(64, 224, 255),
        ["Default Killer"]       = Color3.fromRGB(255, 93, 108),
        ["Default Generator"]    = Color3.fromRGB(255, 255, 255),
        ["Default Gate"]         = Color3.fromRGB(255, 255, 255),
        ["Default Hook"]         = Color3.fromRGB(132, 255, 169),
        ["Default Pallet"]       = Color3.fromRGB(74, 255, 181),
        ["Default Zombie Dummy"] = Color3.fromRGB(255, 200, 0),
        ["Merah (Red)"]          = Color3.fromRGB(255, 0, 0),
        ["Hijau (Green)"]        = Color3.fromRGB(0, 255, 0),
        ["Biru (Blue)"]          = Color3.fromRGB(0, 0, 255),
        ["Kuning (Yellow)"]      = Color3.fromRGB(255, 255, 0),
        ["Ungu (Purple)"]        = Color3.fromRGB(128, 0, 128),
        ["Cyan"]                 = Color3.fromRGB(0, 255, 255),
        ["Putih (White)"]        = Color3.fromRGB(255, 255, 255),
        ["Hitam (Black)"]        = Color3.fromRGB(0, 0, 0),
        ["Pink"]                 = Color3.fromRGB(255, 192, 203),
        ["Orange"]               = Color3.fromRGB(255, 165, 0),
    }

    local colorOptions = {}
    for k in pairs(colorTemplates) do
        table.insert(colorOptions, k)
    end

    local s5 = Tabs.ESP:AddSection("Custom ESP Colors")
    pcall(function()
        s5:AddDropdown({ Title = "Survivor Color",     Options = colorOptions, Default = "Default Survivor", Callback = function(v) if colorTemplates[v] then C_SUR    = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Killer Color",       Options = colorOptions, Default = "Default Killer", Callback = function(v) if colorTemplates[v] then C_KIL    = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Zombie Dummy Color", Options = colorOptions, Default = "Default Zombie Dummy", Callback = function(v) if colorTemplates[v] then C_ZOMBIE = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Generator Color",    Options = colorOptions, Default = "Default Generator", Callback = function(v) if colorTemplates[v] then C_GEN    = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Gate Color",         Options = colorOptions, Default = "Default Gate", Callback = function(v) if colorTemplates[v] then C_GATE   = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Hook Color",         Options = colorOptions, Default = "Default Hook", Callback = function(v) if colorTemplates[v] then C_HOOK   = colorTemplates[v] end end })
        s5:AddDropdown({ Title = "Pallet Color",       Options = colorOptions, Default = "Default Pallet", Callback = function(v) if colorTemplates[v] then C_PAL    = colorTemplates[v] end end })
    end)
end

do 
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local currentTrack = nil
    local currentSound = nil
    local currentEmoteItems = {}

    local emoteList = {}
    for _, name in pairs(ReplicatedStorage.Emotes:GetChildren()) do
        if name:IsA("Folder") then
            table.insert(emoteList, name.Name)
        end
        table.sort(emoteList)
    end

    local selectedEmoteName = emoteList[1]
    local isPlaying = false

    local function attachEmoteItem(emoteFolder, character)
        for _, item in pairs(currentEmoteItems) do
            if item and item.Parent then item:Destroy() end
        end
        currentEmoteItems = {}

        for _, child in pairs(emoteFolder:GetChildren()) do
            if child.Name == "emoteitem" and child:IsA("Model") then
                local clone = child:Clone()
                clone.Parent = character

                local primaryPart = clone.PrimaryPart
                if primaryPart then
                    local targetPartName = clone:GetAttribute("Part0") or "Left Arm"
                    local posAttr = clone:GetAttribute("position")
                    local oriAttr = clone:GetAttribute("orientation")
                    local targetPart = character:FindFirstChild(targetPartName)

                    if targetPart then
                        local rotCF = CFrame.new()
                        if oriAttr then
                            rotCF = CFrame.Angles(
                                math.rad(oriAttr.X),
                                math.rad(oriAttr.Y),
                                math.rad(oriAttr.Z)
                            )
                        end
                        local offsetCF = CFrame.new(posAttr or Vector3.new()) * rotCF

                        local motor = Instance.new("Motor6D")
                        motor.Name = "EmoteItemMotor_" .. targetPartName 
                        motor.Part0 = targetPart
                        motor.Part1 = primaryPart
                        motor.C0 = offsetCF
                        motor.C1 = CFrame.new()
                        motor.Parent = targetPart
                    end

                    for _, part in pairs(clone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Massless = true
                        end
                    end
                end

                table.insert(currentEmoteItems, clone)
            end
        end
    end

    local function cleanupEmoteItems()
        for _, item in pairs(currentEmoteItems) do
            if item and item.Parent then item:Destroy() end
        end
        currentEmoteItems = {}
    end

    local function getCharacter()
        return LocalPlayer.Character
    end

    local function getHumanoid()
        local char = getCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function playSelectedEmote()
        local character = getCharacter()
        local humanoid = getHumanoid()
        
        if not character or not humanoid then return end
        
        if currentTrack then currentTrack:Stop() end
        if currentSound then currentSound:Stop() currentSound:Destroy() end
        cleanupEmoteItems()

        if not isPlaying or not selectedEmoteName then return end

        local emoteFolder = game.ReplicatedStorage.Emotes:FindFirstChild(selectedEmoteName)
        if emoteFolder then
            local animId = emoteFolder:GetAttribute("animationid")
            local songId = emoteFolder:GetAttribute("Song")

            if animId then
                local anim = Instance.new("Animation")
                anim.AnimationId = tostring(animId):find("rbxassetid://") and animId or "rbxassetid://" .. tostring(animId)
                currentTrack = humanoid:LoadAnimation(anim)
                currentTrack.Looped = true
                currentTrack:Play()
            end

            if songId then
                local sId = tostring(songId):find("rbxassetid://") and songId or "rbxassetid://" .. tostring(songId)
                currentSound = Instance.new("Sound")
                currentSound.SoundId = sId
                currentSound.Volume = 0.05
                currentSound.Parent = character:FindFirstChild("HumanoidRootPart") or character
                currentSound.Looped = true
                currentSound:Play()
            end

            attachEmoteItem(emoteFolder, character)
        end
    end

    EmoteSection = Tabs.Exclusive:AddSection("Emote Features")
    EmoteSection:AddDropdown({
        Title = "Select Emote",
        Options = emoteList,
        Default = emoteList[1],
        Callback = function(opts)
            selectedEmoteName = opts

            if isPlaying then
                playSelectedEmote()
            end
        end
    })
    EmoteSection:AddToggle({
        Title = "Play Emote",
        Default = false,
        Keybind = true,
        Callback = function(v)
            isPlaying = v
            if isPlaying then
                playSelectedEmote()
            else
                if currentTrack then currentTrack:Stop() end
                if currentSound then currentSound:Stop() currentSound:Destroy() end
                cleanupEmoteItems()
            end
        end
    })
    LocalPlayer.CharacterAdded:Connect(function()
        currentTrack = nil
        currentSound = nil
        cleanupEmoteItems()
        
        if isPlaying then
            task.wait(1)
            playSelectedEmote()
        end
    end)

    FakeAvatarSection = Tabs.Exclusive:AddSection("Fake Avatar")
    local FakeAvatarEnabled = false
    local SelectedFakeAva = nil
    local function LoadAsetKeKarakter(appearance, character, head)
        local items = appearance:GetChildren()
        
        local function ApplyMesh(obj)
            if obj:IsA("CharacterMesh") or obj:IsA("BodyColors") or obj:IsA("Shirt") or obj:IsA("Pants") then
                local existing = character:FindFirstChild(obj.Name)
                if existing and existing.ClassName == obj.ClassName then existing:Destroy() end
                obj:Clone().Parent = character
            end
        end

        for _, item in pairs(items) do
            if item:IsA("Folder") or item:IsA("Model") then
                for _, subItem in pairs(item:GetChildren()) do
                    ApplyMesh(subItem)
                end
            else
                ApplyMesh(item)
            end
        end

        for _, item in pairs(items) do
            if item:IsA("SpecialMesh") and head then
                local targetMesh = head:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", head)
                targetMesh.MeshType = Enum.MeshType.FileMesh
                targetMesh.MeshId = item.MeshId
                targetMesh.TextureId = item.TextureId
            elseif item:IsA("Decal") and item.Name == "face" and head then
                if head:FindFirstChild("face") then head.face:Destroy() end
                item:Clone().Parent = head
            end
        end

        for _, item in pairs(items) do
            if item:IsA("Accessory") then
                local clone = item:Clone()
                local handle = clone:FindFirstChild("Handle")
                if handle then
                    local att = handle:FindFirstChildOfClass("Attachment")
                    if att then
                        local targetAtt = character:FindFirstChild(att.Name, true)
                        if targetAtt then
                            local weld = Instance.new("Weld")
                            weld.Part0 = handle 
                            weld.Part1 = targetAtt.Parent
                            weld.C0 = att.CFrame 
                            weld.C1 = targetAtt.CFrame
                            weld.Parent = handle
                        end
                    end
                    handle.CanCollide = false
                    handle.Massless = true
                    clone.Parent = character
                end
            end
        end
    end

    function ApplyFakeAvaAppearance()
        local character = LocalPlayer.Character
        if not character or not SelectedFakeAva then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        task.spawn(function()
            local success, appearance = pcall(function()
                return game:GetService("Players"):GetCharacterAppearanceAsync(SelectedFakeAva)
            end)
            
            if not success or not appearance then 
                warn("Gagal load data avatar!")
                return 
            end

            for _, obj in pairs(character:GetChildren()) do
                if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") 
                or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") or obj:IsA("ShirtGraphic") then
                    obj:Destroy()
                end
            end

            local head = character:FindFirstChild("Head")
            if head then
                for _, hObj in pairs(head:GetChildren()) do
                    if hObj:IsA("SpecialMesh") or hObj:IsA("Decal") then hObj:Destroy() end
                end
                local m = Instance.new("SpecialMesh", head)
                m.MeshType = Enum.MeshType.Head
                m.Scale = Vector3.new(1, 1, 1)
            end

            local scaleDefaults = {
                BodyDepthScale = 1, BodyHeightScale = 1, BodyWidthScale = 1,
                HeadScale = 1, BodyTypeScale = 0, BodyProportionScale = 0,
            }
            for scaleName, val in pairs(scaleDefaults) do
                local s = humanoid:FindFirstChild(scaleName)
                if s then s.Value = val end
            end

            task.wait(0.1)

            LoadAsetKeKarakter(appearance, character, head)

            pcall(function()
                local info = game:GetService("Players"):GetCharacterAppearanceInfoAsync(SelectedFakeAva)
                if head and info.assets then
                    for _, asset in pairs(info.assets) do
                        if asset.assetType.name == "Face" then
                            if head:FindFirstChild("face") then head.face:Destroy() end
                            local f = Instance.new("Decal", head)
                            f.Name = "face"
                            f.Texture = "rbxassetid://"..asset.id
                            break
                        end
                    end
                end
            end)
        end)
    end

    FakeAvatarSection:AddDropdown({
        Title = "Fake Avatar",
        Options = {
            "Self Avatar", "Random 1", "Random 2", "Random 3", "Random 4", "Random 5", 
            "Random 6", "Random 7", "WoozyNate", "Nicholas", "yvlyf", "traevp", "J0LLY", 
            "LucashDev", "CEOofIsaac", "Stealthy", "Wildes", "Talon", "Relukt", 
            "Sammy", "Diesel", "S4ans03", "Aura", "iJava", "White Guy", 
            "Purple King", "Kachaaaa Gay", "Mpruyyy"
        },
        Default = "Self Avatar",
        Callback = function(option)
            local ids = {
                ["Self Avatar"] = LocalPlayer.UserId, 
                ["Random 1"] = 2888298851, 
                ["Random 2"] = 10074747755,
                ["Random 3"] = 5209567453, 
                ["Random 4"] = 8991982843, 
                ["Random 5"] = 5796319029, 
                ["Random 6"] = 9744452117,
                ["Random 7"] = 8476755006, 
                ["WoozyNate"] = 146089324, 
                ["Nicholas"] = 909635, 
                ["yvlyf"] = 181751703,
                ["traevp"] = 471607078, 
                ["J0LLY"] = 1073847038, 
                ["LucashDev"] = 2525651744,
                ["CEOofIsaac"] = 63238912, 
                ["Stealthy"] = 56602747, 
                ["Wildes"] = 40397833,
                ["Talon"] = 75974130, 
                ["Relukt"] = 65042011, 
                ["Sammy"] = 2678001507,
                ["Diesel"] = 9123921576, 
                ["S4ans03"] = 35439794, 
                ["Aura"] = 2275806428,
                ["iJava"] = 276557820, 
                ["White Guy"] = 8843268357, 
                ["Purple King"] = 9070758608,
                ["Kachaaaa Gay"] = 8956318334, 
                ["Mpruyyy"] = 8340163775
            }
            SelectedFakeAva = ids[option]
            if FakeAvatarEnabled then ApplyFakeAvaAppearance() end
        end
    })

    FakeAvatarSection:AddToggle({
        Title = "Fake Avatar",
        Default = false,
        Keybind = true,
        Callback = function(state)
            FakeAvatarEnabled = state
            if state then ApplyFakeAvaAppearance() end
        end
    })
    local UsernameInput = ""
    FakeAvatarSection:AddSubSection("Fake Avatar Via Username")
    FakeAvatarSection:AddInput({
        Title = "Input Username (@username)",
        Placeholder = "Write ur input here",
        Callback = function(input)
            UsernameInput = input:gsub("^@", "")
        end
    })
    FakeAvatarSection:AddButton({
        Title = "Apply Fake Avatar",
        Callback = function()
            if UsernameInput == "" then
                notif("Masukkan username dulu!")
                return
            end

            local ok, userId = pcall(function()
                return game:GetService("Players"):GetUserIdFromNameAsync(UsernameInput)
            end)

            if not ok or not userId then
                notif("Username tidak ditemukan: " .. UsernameInput)
                return
            end

            SelectedFakeAva = userId
            ApplyFakeAvaAppearance()
            notif("Fake avatar diterapkan: @" .. UsernameInput)
        end
    })
    LocalPlayer.CharacterAdded:Connect(function(char)
        if FakeAvatarEnabled then 
            task.wait(1)
            ApplyFakeAvaAppearance() 
        end
    end)
    
    FakeKarlossSection = Tabs.Exclusive:AddSection("Fake Karloss")

    local KorlessMorph = {
    Enabled = false,
    Connection = nil  -- Untuk menyimpan koneksi CharacterAdded
}


local function ApplyKorless()
    local plr = game.Players.LocalPlayer

    local function Morph()
        repeat task.wait()
        until plr.Character
            and plr.Character:FindFirstChild("HumanoidRootPart")
            and plr.Character:FindFirstChild("Right Leg")

        task.wait(0.1)
        local char = plr.Character

        pcall(function()
            char.Head.Transparency = 1

            local face = char.Head:FindFirstChild("face")
            if face then
                face:Destroy()
            end

            char["Right Leg"].Transparency = 1

            local mesh = Instance.new("MeshPart")
            mesh.Name = "KorlessHead"
            mesh.Size = Vector3.new(1.5, 1.5, 1.5)
            mesh.CanCollide = false
            mesh.MeshId = "rbxassetid://902942096"
            mesh.TextureID = "rbxassetid://902843398"
            mesh.CFrame = char["Right Leg"].CFrame * CFrame.new(0, 0.5, 0)
            mesh.Parent = char

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char["Right Leg"]
            weld.Part1 = mesh
            weld.Parent = mesh
        end)
    end

    Morph()

    if KorlessMorph.Connection then
        KorlessMorph.Connection:Disconnect()
    end

    KorlessMorph.Connection = plr.CharacterAdded:Connect(function()
        task.wait(1)
        Morph()
    end)
end

local function RemoveKorless()
    local char = LocalPlayer.Character
    if char then
        -- Hapus mesh
        local mesh = char:FindFirstChild("KorlessHead")
        if mesh then mesh:Destroy() end

        -- Kembalikan transparansi
        if char:FindFirstChild("Head") then
            char.Head.Transparency = 0
        end
        if char:FindFirstChild("Right Leg") then
            char["Right Leg"].Transparency = 0
        end
    end

    -- Putuskan koneksi CharacterAdded
    if KorlessMorph.Connection then
        KorlessMorph.Connection:Disconnect()
        KorlessMorph.Connection = nil
    end
end


FakeKarlossSection:AddToggle({
    Title = "Korless Morph",
    Default = false,
    Callback = function(v)
        KorlessMorph.Enabled = v
        if v then
            ApplyKorless()
            Library:Notify({Title = "Korless Morph", Description = "Diaktifkan", Duration = 3})
        else
            RemoveKorless()
            Library:Notify({Title = "Korless Morph", Description = "Dinonaktifkan", Duration = 3})
          end
      end
    })
end


-- [[ Settings ]]
_G.FirstCursor = true
CursorSection = Tabs.Settings:AddSection("Cursor Features")
CursorSection:AddToggle({
    Title = "Enable/Disable Cursor",
    Value = false,
    Keybind = true,
    Callback = function(v)
        if LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator" then
            CursorToggle:Set(false)
            return notif("Anda sedang dilobby, tidak perlu menggunakan ini!")
        end

        UserInputService.MouseIconEnabled = v
        if v then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
})

;(function() -- Aim Flashlight (Survivor tab) - closure terpisah
    local SAFlashSection = Tabs.Exclusive:AddSection("Aim Flashlight Features")

    -- Config
    local SAFlash = {
        Enabled       = false,
        YOffset       = 8,
        LerpSpeed     = 0.5,
        ShowLaser     = true,
        LaserColor    = Color3.fromRGB(255, 255, 0),
        LaserFromHead = true,
    }

    -- State
    local isAimingFlash = false
    local currentTouchFlashInput = nil
    local flashLaser = nil
    local flashLoopConn = nil

    -- ============ HELPERS ============
    local function IsDownedSAF(char)
        if not char then return false end
        return char:GetAttribute("Knocked") == true
            or char:GetAttribute("IsHooked") == true
            or char:GetAttribute("Downed") == true
            or char:GetAttribute("IsDown") == true
    end

    local function IsKillerSAF(p)
        if not p then return false end
        if p.Team then
            local tName = tostring(p.Team.Name):lower()
            if tName:find("kill") or tName:find("assassin") or tName:find("hunter") then
                return true
            end
        end
        if p.Character then
            if p.Character:GetAttribute("IsKiller") == true
            or p.Character:GetAttribute("Killer") == true then
                return true
            end
            if p.Character:FindFirstChild("Weapon")
            or p.Character:FindFirstChild("Machete")
            or p.Character:FindFirstChild("Knife") then
                return true
            end
        end
        return false
    end

    local function GetFlashTarget()
        local bestTarget, closestDist = nil, math.huge
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsKillerSAF(p) and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp and not IsDownedSAF(p.Character) then
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        bestTarget = hrp
                    end
                end
            end
        end
        return bestTarget
    end

    -- ============ LASER ============
    local function CreateFlashLaser()
        if flashLaser then return end
        flashLaser = Instance.new("Part")
        flashLaser.Name = "VD_FlashLaser"
        flashLaser.Material = Enum.Material.Neon
        flashLaser.Color = SAFlash.LaserColor
        flashLaser.CanCollide = false
        flashLaser.Anchored = true
        flashLaser.CastShadow = false
        flashLaser.Size = Vector3.new(0.05, 0.05, 1)
        flashLaser.Transparency = 0.2
    end

    local function UpdateFlashLaser(startPos, endPos)
        if not SAFlash.ShowLaser then
            if flashLaser and flashLaser.Parent then flashLaser.Parent = nil end
            return
        end
        if not flashLaser then CreateFlashLaser() end
        if not startPos or not endPos then
            if flashLaser and flashLaser.Parent then flashLaser.Parent = nil end
            return
        end
        local dist = (endPos - startPos).Magnitude
        if dist > 0.5 then
            flashLaser.Color = SAFlash.LaserColor
            flashLaser.Size = Vector3.new(0.05, 0.05, dist)
            flashLaser.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
            flashLaser.Parent = workspace
        else
            if flashLaser.Parent then flashLaser.Parent = nil end
        end
    end

    local function RemoveFlashLaser()
        if flashLaser and flashLaser.Parent then
            flashLaser.Parent = nil
        end
    end

    -- ============ MAIN LOOP ============
    local function StartFlashLoop()
        if flashLoopConn then flashLoopConn:Disconnect() end
        flashLoopConn = RunService.RenderStepped:Connect(function()
            if not SAFlash.Enabled then
                RemoveFlashLaser()
                return
            end

            local cam = workspace.CurrentCamera
            local myChar = LocalPlayer.Character
            if not cam or not myChar then RemoveFlashLaser() return end

            local targetPart = GetFlashTarget()
            if not targetPart then RemoveFlashLaser() return end

            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            local targetPos = targetPart.Position + Vector3.new(0, SAFlash.YOffset, 0)

            -- Rotate Camera
            cam.CFrame = cam.CFrame:Lerp(
                CFrame.lookAt(cam.CFrame.Position, targetPos),
                SAFlash.LerpSpeed
            )

            -- Rotate Character
            if myHRP then
                local goalHrp = CFrame.lookAt(
                    myHRP.Position,
                    Vector3.new(targetPos.X, myHRP.Position.Y, targetPos.Z)
                )
                myHRP.CFrame = myHRP.CFrame:Lerp(goalHrp, SAFlash.LerpSpeed)
            end

            -- Update Laser
            local startPos
            if SAFlash.LaserFromHead and myChar:FindFirstChild("Head") then
                startPos = myChar.Head.Position
            else
                startPos = myHRP and myHRP.Position or myChar:GetPivot().Position
            end
            UpdateFlashLaser(startPos, targetPos)
        end)
    end

    local function StopFlashLoop()
        if flashLoopConn then
            flashLoopConn:Disconnect()
            flashLoopConn = nil
        end
        RemoveFlashLaser()
    end

    -- ============ UI TOGGLES (FORMAT W424) ============
    SAFlashSection:AddToggle({
        Title = "Aim Flashlight",
        Content = "Lock camera & character ke killer",
        Default = false,
        Keybind = true,
        Callback = function(v)
            SAFlash.Enabled = v
            if v then
                StartFlashLoop()
                notif("Silent Aim Flashlight: ON")
            else
                StopFlashLoop()
                notif("Silent Aim Flashlight: OFF")
            end
        end
    })

    SAFlashSection:AddToggle({
        Title = "Show Laser",
        Default = true,
        Callback = function(v)
            SAFlash.ShowLaser = v
            if not v then RemoveFlashLaser() end
        end
    })

    SAFlashSection:AddToggle({
        Title = "Laser From Head",
        Default = true,
        Callback = function(v)
            SAFlash.LaserFromHead = v
        end
    })

    SAFlashSection:AddInput({
        Title = "Y-Offset (Tinggi Sorot)",
        Min = 1,
        Max = 15,
        Default = 8,
        Callback = function(v)
            SAFlash.YOffset = v
        end
    })

    SAFlashSection:AddSlider({
        Title = "Lerp Speed",
        Min = 10,
        Max = 100,
        Default = 50,
        Callback = function(v)
            SAFlash.LerpSpeed = v / 100
        end
    })
end)() -- akhir Aim Flashlight

;(function()
    -- ============ SILENT AIM: TWIST OF FATE (versi KYS) ============
    -- Inti bidik/tembak = kode kiriman Ryuga. Bagian toggle, input, laser, panel & UI hub dilengkapi
    -- karena versi kiriman hanya berupa kerangka (toggle-nya kosong).
    -- Dibungkus fungsi sendiri supaya tidak menambah variabel lokal di chunk utama.
    for _, k in ipairs({ "KYS_ToFUnload", "GANKZ_ToFUnload" }) do
        local prev = getgenv()[k]
        if prev then pcall(prev) end
    end

    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer       = Players.LocalPlayer

    getgenv().VD = getgenv().VD or {}
    local VD = getgenv().VD
    VD.TOF_SilentAim       = false
    VD.TOF_Laser           = true
    VD.TOF_WallCheck       = false
    VD.TOF_BlockKnocked    = true
    VD.TOF_TargetMode      = "Killer"
    VD.TOF_Key             = "None"

-- ===== ANTI KNOCK =====
    VD.TOF_AntiKnock       = true    -- master toggle anti knock
    VD.TOF_KnockReduction  = 65      -- 0..100 : makin tinggi, makin kecil chance knock
    VD.TOF_KnockPart       = "Legs"  -- Head | Torso | Legs  (legs = knock paling kecil)

    local ACCENT   = Color3.fromRGB(168, 85, 247)
    local ACCENT_L = Color3.fromRGB(192, 132, 252)
    local OFF_BG   = Color3.fromRGB(24, 24, 28)
    local OFF_TXT  = Color3.fromRGB(230, 230, 235)
    local OFF_LINE = Color3.fromRGB(50, 50, 55)

    local function GetSafeGuiParent()
        if gethui then
            local ok, hui = pcall(gethui)
            if ok and hui then return hui end
        end
        local ok, core = pcall(function() return game:GetService("CoreGui") end)
        if ok and core then return core end
        return LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end

    -- ====================== KODE KIRIMAN (inti) ======================
    local KYS_ToFState = {
    Connection = nil,
    LaserBeam = nil,
    TargetGui = nil,
    InputBegan = nil,
    InputEnded = nil,
    InputChanged = nil,    -- <<< tambahin ini
    TouchInput = nil,
    DragConn = nil,
    IsAiming = false,
    IsCancelled = false,
    SavedUIPos = UDim2.new(0.5, -120, 0, 110),
    SCPCache = {},
    SCPCacheTimer = 0,
}

    local KYS_ToFKeyCodes = {
        None = nil,
        Q = Enum.KeyCode.Q, E = Enum.KeyCode.E, R = Enum.KeyCode.R,
        T = Enum.KeyCode.T, F = Enum.KeyCode.F, G = Enum.KeyCode.G,
        H = Enum.KeyCode.H, J = Enum.KeyCode.J, K = Enum.KeyCode.K,
        L = Enum.KeyCode.L, X = Enum.KeyCode.X, Z = Enum.KeyCode.Z,
    }

    local function KYS_ToFGetEvent()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local items = remotes and remotes:FindFirstChild("Items")
        local tof = items and items:FindFirstChild("Twist of Fate")
        local fire = tof and tof:FindFirstChild("Fire")
        if fire and fire:IsA("RemoteEvent") then
            return fire
        end
        return nil
    end

    local function KYS_ToFGetGunObject()
        local char = LocalPlayer.Character
        if not char then return nil end

        local baseToF = char:FindFirstChild("Twist of Fate", true)
        if not baseToF then return nil end

        local rightArm = baseToF:FindFirstChild("Right Arm")
        if rightArm then
            local gunPart = rightArm:FindFirstChild("gun")
            if gunPart then return gunPart end
            local emperorGun = rightArm:FindFirstChild("EmperorGun")
            if emperorGun then return emperorGun end
        end
        return baseToF
    end

    local function KYS_ToFIsTargetVisible(originPos, targetPos, targetCharacter)
        local direction = targetPos - originPos
        local distance = direction.Magnitude
        if distance < 0.1 then return true end

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local excludeList = {}
        local localChar = LocalPlayer.Character
        if localChar then table.insert(excludeList, localChar) end
        if targetCharacter and targetCharacter ~= localChar then table.insert(excludeList, targetCharacter) end
        if KYS_ToFState.LaserBeam then table.insert(excludeList, KYS_ToFState.LaserBeam) end
        rayParams.FilterDescendantsInstances = excludeList

        local result = workspace:Raycast(originPos, direction.Unit * distance, rayParams)
        return result == nil
    end

    local function KYS_ToFGetSCPs()
        if tick() - KYS_ToFState.SCPCacheTimer < 0.5 then
            return KYS_ToFState.SCPCache
        end
        local newTargets = {}
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            for _, container in pairs(mapFolder:GetDescendants()) do
                if container:IsA("Model") then
                    if container:GetAttribute("CorpseCreated0492") or next(container:GetAttributes()) ~= nil then
                        local root = container:FindFirstChild("HumanoidRootPart")
                        if root then table.insert(newTargets, root) end
                    end
                end
            end
        end
        KYS_ToFState.SCPCache = newTargets
        KYS_ToFState.SCPCacheTimer = tick()
        return KYS_ToFState.SCPCache
    end

    -- RynerHUB: cari bagian badan target, ada fallback buat target jauh
    -- RynerHUB: kalau AntiKnock ON, target bagian badan yang knock-nya rendah
local function KYS_ToFGetTorso(char)
    if not char then return nil end

    if VD.TOF_AntiKnock then
        local mode = VD.TOF_KnockPart or "Legs"
        if mode == "Legs" then
            local p = char:FindFirstChild("Left Leg")
                or char:FindFirstChild("Right Leg")
                or char:FindFirstChild("LeftFoot")
                or char:FindFirstChild("RightFoot")
                or char:FindFirstChild("LowerTorso")
                or char:FindFirstChild("LeftLowerLeg")
                or char:FindFirstChild("RightLowerLeg")
            if p then return p end
        elseif mode == "Head" then
            local p = char:FindFirstChild("Head")
            if p then return p end
        else
            local p = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            if p then return p end
        end
    end

    return char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("HumanoidRootPart")
        or char.PrimaryPart
        or char:FindFirstChildWhichIsA("BasePart", true)
end

-- RynerHUB: helper spread acak buat nurunin presisi -> nurunin chance knock
local function KYS_ToFApplyKnockSpread(dirUnit)
    if not VD.TOF_AntiKnock or not dirUnit then return dirUnit end
    local pct = math.clamp(tonumber(VD.TOF_KnockReduction) or 0, 0, 100) / 100
    if pct <= 0 then return dirUnit end
    -- makin tinggi pct, makin lebar cone spread (max ~4.5 derajat)
    local maxAngle = math.rad(4.5 * pct)
    local theta    = math.random() * math.pi * 2
    local phi      = math.random() * maxAngle
    local up       = Vector3.new(0, 1, 0)
    local right    = dirUnit:Cross(up)
    if right.Magnitude < 0.01 then right = Vector3.new(1, 0, 0) end
    right = right.Unit
    local realUp = right:Cross(dirUnit).Unit
    local offset = (right * math.cos(theta) + realUp * math.sin(theta)) * math.tan(phi)
    return (dirUnit + offset).Unit
end

    local function KYS_ToFGetTargetPosition()
        local gunObj = KYS_ToFGetGunObject()
        local char = LocalPlayer.Character
        if not (gunObj and char) then return nil, nil, nil, nil end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, nil, nil, nil end

        local myPos = hrp.Position
        local originPos
        if char:GetAttribute("IsCarried") then
            originPos = hrp.Position + (hrp.CFrame.LookVector * 2)
        else
            pcall(function()
                originPos = gunObj:IsA("BasePart") and gunObj.Position
                    or (gunObj:FindFirstChildOfClass("BasePart") and gunObj:FindFirstChildOfClass("BasePart").Position)
            end)
            originPos = originPos or Vector3.new(myPos.X, myPos.Y + 1.5, myPos.Z)
        end

        local function predictTarget(torso, targetCharacter)
    local targetPos = torso.Position
    if VD.TOF_WallCheck and not KYS_ToFIsTargetVisible(originPos, targetPos, targetCharacter) then
        return nil, nil, nil, nil
    end

    local targetVel = Vector3.new(0, 0, 0)
    local rootPart = targetCharacter and (targetCharacter:FindFirstChild("HumanoidRootPart") or torso)
    if rootPart then targetVel = rootPart.Velocity end

    local directionRaw = targetPos - originPos
    local distance = directionRaw.Magnitude
    if distance < 0.1 then return nil, nil, nil, nil end
    if distance < 5 then
        local d = KYS_ToFApplyKnockSpread(directionRaw.Unit)
        return d, gunObj, originPos, targetPos
    end

    local travelTime = distance / 400
    local predictedPos = targetPos + (targetVel * travelTime)
    for _ = 1, 2 do
        local newDist = (predictedPos - originPos).Magnitude
        travelTime = newDist / 400
        predictedPos = targetPos + (targetVel * travelTime)
    end

    local finalDirection = predictedPos - originPos
    if finalDirection.Magnitude < 0.1 then return nil, nil, nil, nil end
    return KYS_ToFApplyKnockSpread(finalDirection.Unit), gunObj, originPos, predictedPos
end

        local targetMode = VD.TOF_TargetMode or "Killer"
        if targetMode == "Killer" then
            local closestTorso, closestChar, shortestDist = nil, nil, math.huge
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team and player.Team.Name == "Killer" and player.Character then
                    local torso = KYS_ToFGetTorso(player.Character)
                    if torso then
                        local dist = (myPos - torso.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestTorso = torso
                            closestChar = player.Character
                        end
                    end
                end
            end
            if not closestTorso then return nil, nil, nil, nil end
            return predictTarget(closestTorso, closestChar)

        elseif targetMode == "Survivors" then
            local bestTorso, bestChar, bestDot = nil, nil, -math.huge
            local cam = workspace.CurrentCamera
            if not cam then return nil, nil, nil, nil end
            local camLook = cam.CFrame.LookVector
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" and player.Character then
                    local torso = KYS_ToFGetTorso(player.Character)
                    if torso then
                        local dirToTarget = torso.Position - cam.CFrame.Position
                        if dirToTarget.Magnitude > 0.1 then
                            local dot = camLook:Dot(dirToTarget.Unit)
                            if dot > 0.5 and dot > bestDot then
                                bestDot = dot
                                bestTorso = torso
                                bestChar = player.Character
                            end
                        end
                    end
                end
            end
            if not bestTorso then return nil, nil, nil, nil end
            return predictTarget(bestTorso, bestChar)

        elseif targetMode == "Zombie" then
            local bestPart, bestDot = nil, -math.huge
            local cam = workspace.CurrentCamera
            if not cam then return nil, nil, nil, nil end
            local camLook = cam.CFrame.LookVector
            for _, root in ipairs(KYS_ToFGetSCPs()) do
                if root and root.Parent then
                    local dirToTarget = root.Position - cam.CFrame.Position
                    if dirToTarget.Magnitude > 0.1 then
                        local dot = camLook:Dot(dirToTarget.Unit)
                        if dot > 0.5 and dot > bestDot then
                            bestDot = dot
                            bestPart = root
                        end
                    end
                end
            end
            if not bestPart then return nil, nil, nil, nil end
            return predictTarget(bestPart, bestPart.Parent)
        end
        return nil, nil, nil, nil
    end

    local function KYS_ToFDoShoot()
        if not VD.TOF_SilentAim then return end

        local char = LocalPlayer.Character
        if char and VD.TOF_BlockKnocked ~= false then
            local state   = char:GetAttribute("State")
            local knocked = char:GetAttribute("Knocked")   == true
                         or char:GetAttribute("IsKnocked") == true
                         or char:GetAttribute("IsHooked")  == true
                         or char:GetAttribute("IsCarried") == true
                         or char:GetAttribute("Downed")    == true
                         or char:GetAttribute("IsDown")    == true

            local hum = char:FindFirstChildOfClass("Humanoid")
            local humDead = hum and hum.Health <= 0

            if state == "Downed" or state == "Dead" or knocked or humDead then
                return
            end
        end

        local targetDirection, gunObject, originPos, targetPos = KYS_ToFGetTargetPosition()
        if not (targetDirection and gunObject and targetPos and originPos) then return end

        local tofEvent = KYS_ToFGetEvent()
        if not tofEvent then return end

        local freshDirection = targetPos - originPos
        if freshDirection.Magnitude < 0.1 then return end

        local fireDir = KYS_ToFApplyKnockSpread(freshDirection.Unit)

        pcall(function()
            tofEvent:FireServer(gunObject, fireDir)
        end)
     end

    -- ====================== PELENGKAP (laser, input, panel, toggle) ======================
    local function KYS_ToFUpdateLaser(originPos, targetPos)
        if not KYS_ToFState.LaserBeam then
            local laser = Instance.new("Part")
            laser.Name = "ToFLaser"
            laser.Anchored = true
            laser.CanCollide = false
            laser.CanTouch = false
            laser.CastShadow = false
            laser.Material = Enum.Material.Neon
            laser.Color = Color3.fromRGB(255, 50, 50)
            laser.Parent = workspace
            KYS_ToFState.LaserBeam = laser
        end
        local laser = KYS_ToFState.LaserBeam
        if laser.Parent ~= workspace then laser.Parent = workspace end
        local dist = (targetPos - originPos).Magnitude
        if dist < 0.1 then laser.Transparency = 1 return end
        -- RynerHUB: laser makin tebal kalau target makin jauh (0.05 stud itu ga kelihatan di jarak jauh)
        local len = math.min(dist, 2000)
        local thick = math.clamp(dist * 0.004, 0.05, 0.8)
        local dirUnit = (targetPos - originPos).Unit
        laser.Size = Vector3.new(thick, thick, len)
        laser.CFrame = CFrame.lookAt(originPos + dirUnit * (len / 2), originPos + dirUnit * len)
        laser.Transparency = 0.1
    end

    local function KYS_ToFClearLaser()
        if KYS_ToFState.LaserBeam then
            pcall(function() KYS_ToFState.LaserBeam:Destroy() end)
            KYS_ToFState.LaserBeam = nil
        end
    end

    local function KYS_ToFGetMobileShootButton()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
        local controls = survivorMob and survivorMob:FindFirstChild("Controls")
        local guiMob = controls and controls:FindFirstChild("Gui-mob")
        if not guiMob then return nil end
        for _, name in ipairs({ "attack", "Attack", "shoot", "Shoot", "fire", "Fire" }) do
            local btn = guiMob:FindFirstChild(name, true)
            if btn and btn:IsA("GuiObject") then return btn end
        end
        for _, obj in ipairs(guiMob:GetDescendants()) do
            if obj:IsA("GuiButton") and obj.Visible then return obj end
        end
        return guiMob:IsA("GuiObject") and guiMob or nil
    end

    local function KYS_ToFIsTouchOnShootButton(input)
        local shootButton = KYS_ToFGetMobileShootButton()
        if not (shootButton and shootButton.Visible) then return false end
        local pos = input.Position
        local absPos = shootButton.AbsolutePosition
        local absSize = shootButton.AbsoluteSize
        return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
            and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
    end

    -- Cari tombol cancel native game Violence District
    -- VD structure: PlayerGui > Survivor-mob > Controls > <button>
    local function KYS_ToFGetMobileCancelButton()
        local playerGui   = LocalPlayer:FindFirstChild("PlayerGui")
        local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
        local controls    = survivorMob and survivorMob:FindFirstChild("Controls")
        if not controls then return nil end

        -- coba nama umum yang biasa dipakai VD
        for _, name in ipairs({
            "cancel", "Cancel", "CANCEL",
            "stop", "Stop", "STOP",
            "x", "X",
            "back", "Back",
            "cancelshoot", "CancelShoot", "cancel_shoot",
            "abort", "Abort",
            "retreat", "Retreat",
        }) do
            local btn = controls:FindFirstChild(name, true)
            if btn and btn:IsA("GuiObject") and btn.Visible then return btn end
        end

        -- fallback: ambil semua GuiButton visible di Controls,
        -- buang yang sudah dikenal sebagai shoot/parry/crouch
        local shootBtn = KYS_ToFGetMobileShootButton()
        for _, obj in ipairs(controls:GetDescendants()) do
            if obj:IsA("GuiButton") and obj.Visible and obj ~= shootBtn then
                local lname = obj.Name:lower()
                -- skip crouch, parry, dan icon
                if not (lname:find("crouch") or lname:find("parry") or lname:find("icon")
                    or lname:find("jump") or lname:find("sprint")) then
                    return obj
                end
            end
        end
        return nil
    end

    local function KYS_ToFIsTouchOnCancelButton(input)
        local cancelBtn = KYS_ToFGetMobileCancelButton()
        if not (cancelBtn and cancelBtn.Visible) then return false end
        local pos     = input.Position
        local absPos  = cancelBtn.AbsolutePosition
        local absSize = cancelBtn.AbsoluteSize
        return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
           and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
    end

    local ModeButtons = {}

    local function KYS_ToFRefreshTargetButtons()
        for modeName, btn in pairs(ModeButtons) do
            if btn and btn.Parent then
                local active = modeName == (VD.TOF_TargetMode or "Killer")
                btn.BackgroundColor3 = active and ACCENT or OFF_BG
                btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or OFF_TXT
            end
        end
    end

    local function KYS_ToFSetTargetMode(modeName, doNotify)
        if modeName ~= "Killer" and modeName ~= "Survivors" and modeName ~= "Zombie" then return end
        VD.TOF_TargetMode = modeName
        KYS_ToFRefreshTargetButtons()
        if doNotify then notif("Target Mode: " .. modeName) end
    end

    local function KYS_ToFCreateTargetSelectorUI()
        local parent = GetSafeGuiParent()
        if not parent then return end
        if KYS_ToFState.TargetGui and KYS_ToFState.TargetGui.Parent then return end

        local oldGui = parent:FindFirstChild("ToFTargetSelector")
        if oldGui then pcall(function() oldGui:Destroy() end) end

        local gui = Instance.new("ScreenGui")
        gui.Name = "ToFTargetSelector"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = parent

        local frame = Instance.new("Frame")
        frame.Name = "Main"
        frame.Size = UDim2.new(0, 180, 0, 205)
        frame.Position = KYS_ToFState.SavedUIPos
        frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Parent = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = ACCENT
        stroke.Thickness = 1.5

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        header.BorderSizePixel = 0
        header.Parent = frame
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

        local headerFix = Instance.new("Frame")
        headerFix.Size = UDim2.new(1, 0, 0, 10)
        headerFix.Position = UDim2.new(0, 0, 1, -10)
        headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        headerFix.BorderSizePixel = 0
        headerFix.Parent = header

        local dragArea = Instance.new("Frame")
        dragArea.Size = UDim2.new(1, -34, 1, 0)
        dragArea.BackgroundTransparency = 1
        dragArea.Parent = header

        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Size = UDim2.new(0, 28, 1, 0)
        minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
        minimizeBtn.BackgroundTransparency = 1
        minimizeBtn.Text = "-"
        minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minimizeBtn.Font = Enum.Font.GothamBold
        minimizeBtn.TextSize = 14
        minimizeBtn.Parent = header

        local headerLbl = Instance.new("TextLabel")
        headerLbl.Size = UDim2.new(1, -44, 1, 0)
        headerLbl.Position = UDim2.new(0, 10, 0, 0)
        headerLbl.BackgroundTransparency = 1
        headerLbl.Text = "PISTOL TARGET MODE"
        headerLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        headerLbl.Font = Enum.Font.GothamBold
        headerLbl.TextSize = 10
        headerLbl.TextXAlignment = Enum.TextXAlignment.Left
        headerLbl.Parent = header

        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -16, 0, 160)
        btnContainer.Position = UDim2.new(0, 8, 0, 34)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = frame

        local layout = Instance.new("UIListLayout", btnContainer)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)

        local isMinimized = false
        minimizeBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            minimizeBtn.Text = isMinimized and "+" or "-"
            btnContainer.Visible = not isMinimized
            frame.Size = isMinimized and UDim2.new(0, 180, 0, 28) or UDim2.new(0, 180, 0, 205)
        end)

        local function makeToggleButton(order, label, getter, onClick)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.LayoutOrder = order
            btn.Parent = btnContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local st = Instance.new("UIStroke", btn)
            st.Thickness = 1
            local function paint()
                if getter() then
                    btn.BackgroundColor3 = ACCENT
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = label .. "  ON"
                    st.Color = ACCENT_L
                else
                    btn.BackgroundColor3 = OFF_BG
                    btn.TextColor3 = OFF_TXT
                    btn.Text = label .. "  OFF"
                    st.Color = OFF_LINE
                end
            end
            paint()
            btn.MouseButton1Click:Connect(function()
                onClick()
                paint()
            end)
        end

        makeToggleButton(0, "SILENT AIM",
            function() return VD.TOF_SilentAim end,
            function()
                VD.TOF_SilentAim = not VD.TOF_SilentAim
                if not VD.TOF_SilentAim then
                    KYS_ToFState.IsAiming    = false
                    KYS_ToFState.IsCancelled = false
                    KYS_ToFState.TouchInput  = nil
                    if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
                end
            end)

        makeToggleButton(1, "BLOCK KNOCK",
            function() return VD.TOF_BlockKnocked ~= false end,
            function() VD.TOF_BlockKnocked = not (VD.TOF_BlockKnocked ~= false) end)

        local modes = {
            { Internal = "Killer",    Display = "KILLER        K" },
            { Internal = "Survivors", Display = "SURVIVOR      J" },
            { Internal = "Zombie",    Display = "ZOMBIE        L" },
        }

        ModeButtons = {}
        for i, mode in ipairs(modes) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.Text = mode.Display
            btn.LayoutOrder = i + 1
            btn.Parent = btnContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = OFF_LINE
            btnStroke.Thickness = 1

            btn.MouseButton1Click:Connect(function() KYS_ToFSetTargetMode(mode.Internal, false) end)
            btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    KYS_ToFSetTargetMode(mode.Internal, false)
                end
            end)
            ModeButtons[mode.Internal] = btn
        end
        KYS_ToFRefreshTargetButtons()

        local dragging = false
        local dragStart, startPos

        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position
                startPos = frame.Position
                dragging = true
            end
        end)

        dragArea.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        KYS_ToFState.DragConn = UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                frame.Position = newPos
                KYS_ToFState.SavedUIPos = newPos
            end
        end)

        KYS_ToFState.TargetGui = gui
    end

    local function KYS_ToFDestroyTargetSelectorUI()
        if KYS_ToFState.DragConn then
            pcall(function() KYS_ToFState.DragConn:Disconnect() end)
            KYS_ToFState.DragConn = nil
        end
        if KYS_ToFState.TargetGui then
            pcall(function() KYS_ToFState.TargetGui:Destroy() end)
            KYS_ToFState.TargetGui = nil
        end
        KYS_ToFState.IsCancelled = false
        KYS_ToFState.IsAiming    = false
        KYS_ToFState.TouchInput  = nil
        ModeButtons = {}
    end

    local function KYS_ToFStartConnection()
        if KYS_ToFState.Connection then return end
        KYS_ToFState.Connection = RunService.Heartbeat:Connect(function()
            if not VD.TOF_SilentAim or not KYS_ToFState.IsAiming then
                if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
                return
            end

            local _, __, originPos, targetPos = KYS_ToFGetTargetPosition()

            if originPos and targetPos then
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and not char:GetAttribute("IsCarried") then
                        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
                    end
                end)

                if VD.TOF_Laser then
                    KYS_ToFUpdateLaser(originPos, targetPos)
                elseif KYS_ToFState.LaserBeam then
                    KYS_ToFState.LaserBeam.Transparency = 1
                end
            elseif KYS_ToFState.LaserBeam then
                KYS_ToFState.LaserBeam.Transparency = 1
            end
        end)
    end

    local function KYS_ToFStopConnection()
        if KYS_ToFState.Connection then
            pcall(function() KYS_ToFState.Connection:Disconnect() end)
            KYS_ToFState.Connection = nil
        end
        KYS_ToFState.IsAiming = false
        KYS_ToFClearLaser()
    end

    local KYS_SetToFSilentAim

    local function KYS_ToFEnsureInputs()
        if not KYS_ToFState.InputBegan then
            KYS_ToFState.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                -- NOTE: touch di tombol GUI native (shoot/cancel) selalu gameProcessed=true,
                -- jadi cancel & shoot touch TIDAK boleh diblok oleh gameProcessed.

                -- keybind toggle SA
                local keyCode = KYS_ToFKeyCodes[VD.TOF_Key or "None"]
                if not gameProcessed and keyCode and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keyCode then
                    KYS_SetToFSilentAim(not VD.TOF_SilentAim)
                    return
                end

                if not VD.TOF_SilentAim then return end

                -- ===== CANCEL: klik kanan (PC) atau tombol cancel native (mobile) =====
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    KYS_ToFState.IsCancelled = true
                    KYS_ToFState.IsAiming    = false
                    KYS_ToFState.TouchInput  = nil
                    if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
                    return
                end
                if input.UserInputType == Enum.UserInputType.Touch and KYS_ToFIsTouchOnCancelButton(input) then
                    KYS_ToFState.IsCancelled = true
                    KYS_ToFState.IsAiming    = false
                    KYS_ToFState.TouchInput  = nil
                    if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
                    return
                end

                -- ===== SHOOT INPUT: mulai aim, laser nyala, tembak nanti saat dilepas =====
                local isShootInput = (input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed)
                    or (input.UserInputType == Enum.UserInputType.Touch and KYS_ToFIsTouchOnShootButton(input))

                if isShootInput then
                    KYS_ToFState.IsCancelled = false
                    KYS_ToFState.IsAiming    = true
                    if input.UserInputType == Enum.UserInputType.Touch then
                        KYS_ToFState.TouchInput = input
                    end
                    return
                end

                -- shortcut ganti target mode keyboard
                if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.K then
                        KYS_ToFSetTargetMode("Killer", true)
                    elseif input.KeyCode == Enum.KeyCode.J then
                        KYS_ToFSetTargetMode("Survivors", true)
                    elseif input.KeyCode == Enum.KeyCode.L then
                        KYS_ToFSetTargetMode("Zombie", true)
                    end
                end
            end)
        end

        -- ===== INPUT ENDED: fire tembakan saat lepas =====
        if not KYS_ToFState.InputEnded then
            KYS_ToFState.InputEnded = UserInputService.InputEnded:Connect(function(input)
                local isRelease = (input.UserInputType == Enum.UserInputType.MouseButton1)
                    or (input.UserInputType == Enum.UserInputType.Touch and input == KYS_ToFState.TouchInput)
                if not isRelease then return end

                if input.UserInputType == Enum.UserInputType.Touch
                    and KYS_ToFState.IsAiming and KYS_ToFIsTouchOnCancelButton(input) then
                    KYS_ToFState.IsCancelled = true
                end

                if KYS_ToFState.IsCancelled then
                    KYS_ToFState.IsCancelled = false
                    KYS_ToFState.IsAiming    = false
                    if input == KYS_ToFState.TouchInput then KYS_ToFState.TouchInput = nil end
                    if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
                    return
                end

                if VD.TOF_SilentAim and KYS_ToFState.IsAiming then
                    KYS_ToFDoShoot()
                end
                KYS_ToFState.IsAiming = false
                if input == KYS_ToFState.TouchInput then KYS_ToFState.TouchInput = nil end
                if KYS_ToFState.LaserBeam then KYS_ToFState.LaserBeam.Transparency = 1 end
            end)
        end

        -- ===== DRAG-TO-CANCEL (mobile): geser jari dari shoot ke tombol X =====
        -- saat IsAiming aktif, track posisi touch secara realtime.
        -- kalau jari masuk area cancel button → IsCancelled = true → pas release tidak tembak
        if not KYS_ToFState.InputChanged then
            KYS_ToFState.InputChanged = UserInputService.InputChanged:Connect(function(input)
                if not VD.TOF_SilentAim then return end
                if input.UserInputType ~= Enum.UserInputType.Touch then return end
                if input ~= KYS_ToFState.TouchInput then return end
                if not KYS_ToFState.IsAiming then return end

                local cancelBtn = KYS_ToFGetMobileCancelButton()
                if not (cancelBtn and cancelBtn.Visible) then return end

                local pos      = input.Position
                local absPos   = cancelBtn.AbsolutePosition
                local absSize  = cancelBtn.AbsoluteSize
                local onCancel = pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                             and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y

                if onCancel then
                    -- jari masuk area X → tandai cancel, laser mati
                    KYS_ToFState.IsCancelled = true
                    if KYS_ToFState.LaserBeam then
                        KYS_ToFState.LaserBeam.Transparency = 1
                    end
                else
                    -- jari keluar lagi dari X → batalkan flag cancel
                    KYS_ToFState.IsCancelled = false
                end
            end)
        end

    end -- nutup KYS_ToFEnsureInputs

    -- Toggle utama
    KYS_SetToFSilentAim = function(enabled)
        VD.TOF_SilentAim = enabled and true or false
        KYS_ToFEnsureInputs()
        if VD.TOF_SilentAim then
            KYS_ToFCreateTargetSelectorUI()
            KYS_ToFStartConnection()
        else
            KYS_ToFDestroyTargetSelectorUI()
            KYS_ToFStopConnection()
        end
    end

    KYS_ToFEnsureInputs()

    -- Expose ke global
    getgenv().KYS_ToFDoShoot = KYS_ToFDoShoot
    getgenv().KYS_ToFGetEvent = KYS_ToFGetEvent
    getgenv().KYS_ToFGetGunObject = KYS_ToFGetGunObject
    getgenv().KYS_ToFGetTargetPosition = KYS_ToFGetTargetPosition
    getgenv().KYS_SetToFSilentAim = KYS_SetToFSilentAim
    getgenv().KYS_ToFClearLaser = KYS_ToFClearLaser
    getgenv().KYS_ToFUnload = function()
    KYS_SetToFSilentAim(false)
    for _, k in ipairs({ "InputBegan", "InputEnded", "InputChanged" }) do
        if KYS_ToFState[k] then
            pcall(function() KYS_ToFState[k]:Disconnect() end)
            KYS_ToFState[k] = nil
        end
    end
end

    -- ===== TOGGLE UI DI TAB EXCLUSIVE (sama seperti script lama) =====
    local ToFSection = ToFExclusiveSection -- section dibuat tepat di bawah Auto Parry AI (tab Exclusive)

    ToFSection:AddToggle({
        Title = "Silent Aim",
        Default = false,
        Keybind = true,
        Callback = function(state)
            KYS_SetToFSilentAim(state)
            notif("Silent Aim ToF : " .. (state and "ON" or "OFF"))
        end
    })

    ToFSection:AddDropdown({
        Title = "Target Mode",
        Options = { "Killer", "Survivors", "Zombie" },
        Default = "Killer",
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            KYS_ToFSetTargetMode(v, false)
        end
    })

    ToFSection:AddToggle({
        Title = "Block Knocked",
        Content = "Jangan tembak saat Downed / Dead",
        Default = true,
        Callback = function(state)
            VD.TOF_BlockKnocked = state and true or false
        end
    })

    ToFSection:AddToggle({
        Title = "Wallcheck",
        Default = false,
        Callback = function(state)
            VD.TOF_WallCheck = state and true or false
            notif("Wallcheck: " .. (state and "ON" or "OFF"))
        end
    })

    ToFSection:AddToggle({
        Title = "Laser Effect",
        Default = true,
        Callback = function(state)
            VD.TOF_Laser = state and true or false
            if not state then KYS_ToFClearLaser() end
            notif("Laser Effect: " .. (state and "ON" or "OFF"))
        end
    })

    ToFSection:AddParagraph({
        Title = "Cara Pakai",
        Content = "Tap cepat = tembak langsung. Tahan = laser muncul, lepas = tembak. Klik kanan (PC) atau tombol cancel game (mobile) = batalkan tembakan.",
    })
end)()

-- =====================================================
-- KILLER STUN NOTIFY (dari RynerHUB — Auto Parry style panel)
-- Panel sound + STUN tag. Ditaruh di bawah Silent Aim ToF.
-- =====================================================
;(function()
    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local SoundService      = game:GetService("SoundService")
    local LocalPlayer       = Players.LocalPlayer

    local SOUND_PRESETS = {
        { name = "Mambo",           id = 119974879573475 },
        { name = "Hidup Jokowi",    id = 134840941464861 },
        { name = "Uh Kaget",        id = 116892434344527 },
        { name = "Saya Akan Lawan", id = 106628244357280 },
        { name = "Plankton Aughhh", id = 105065352580494 },
        { name = "Screaming chicken", id = 117909139728666 },
        { name = "Yepiiii",         id = 71173310238334 },
        { name = "Jangan di coba",  id = 122039713538884 },
        { name = "Anime Wow",       id = 115676011304423 },
        { name = "Windows Error",   id = 99118140108649 },
        { name = "Taco Bell Bong",  id = 88440511098572 },
        { name = "Among Us",        id = 113698031466483 },
        { name = "Tuturu",          id = 88260420289752 },
        { name = "Off",             id = 0 },
    }
    local PANEL_BG_ID       = 98761835530869
    local SOUND_VOLUME      = 3
    local SOUND_PLAYBACK    = 1
    local STUN_COOLDOWN     = 2.8
    local MIN_TAG_DISPLAY   = 1.2

    local Enabled         = true
    local Tracked         = {}
    local CurrentSoundIdx = 1
    local PanelGui        = nil
    local DragLocked      = false

    local function isKiller(p)
        local t = p.Team and p.Team.Name or ""
        return t:lower():find("killer") ~= nil
    end

    local function getParent()
        if gethui then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end
        local ok, core = pcall(function() return game:GetService("CoreGui") end)
        if ok and core then return core end
        return LocalPlayer:WaitForChild("PlayerGui", 10)
    end

    -- ===== SOUND =====
    local StunSound, StunSoundGroup

    local function loadSoundByIndex(idx)
        local preset = SOUND_PRESETS[idx]
        if not preset then return end
        if StunSound      then pcall(function() StunSound:Destroy() end) StunSound = nil end
        if StunSoundGroup then pcall(function() StunSoundGroup:Destroy() end) StunSoundGroup = nil end
        if preset.id == 0 then return end

        StunSoundGroup = Instance.new("SoundGroup")
        StunSoundGroup.Name = "STUN_BoostGroup"
        StunSoundGroup.Volume = 1
        StunSoundGroup.Parent = SoundService

        StunSound = Instance.new("Sound")
        StunSound.Name = "STUN_NotifySound"
        StunSound.SoundId = "rbxassetid://" .. tostring(preset.id)
        StunSound.Volume = math.clamp(tonumber(SOUND_VOLUME) or 3, 0, 10)
        StunSound.PlaybackSpeed = tonumber(SOUND_PLAYBACK) or 1
        StunSound.Looped = false
        StunSound.SoundGroup = StunSoundGroup
        StunSound.Parent = SoundService

        task.spawn(function()
            pcall(function()
                if not StunSound.IsLoaded then StunSound.Loaded:Wait() end
            end)
        end)
    end

    local function playStunSound()
        if not StunSound then return end
        pcall(function()
            StunSound:Stop()
            StunSound.TimePosition = 0
            StunSound:Play()
        end)
    end

    loadSoundByIndex(CurrentSoundIdx)

    -- ===== STUN TAG =====
    local function clearTag(p)
        local data = Tracked[p]
        if data and data.tag then
            pcall(function() data.tag:Destroy() end)
            data.tag = nil
            data.tagLabel = nil
            data.cdBar = nil
            data.tagStroke = nil
            data.stunnedAt = nil
            data.tagShownAt = nil
        end
    end

    local function showTag(p, char)
        clearTag(p)
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "STUN_Tag"
        bb.Size = UDim2.fromOffset(130, 42)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 400
        bb.Adornee = head
        bb.Parent = head

        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(18, 8, 10)
        bg.BackgroundTransparency = 0.12
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

        local outer = Instance.new("UIStroke", bg)
        outer.Color = Color3.fromRGB(255, 70, 70)
        outer.Thickness = 2
        outer.Transparency = 0.1

        local accent = Instance.new("Frame", bg)
        accent.Size = UDim2.new(0, 4, 1, -8)
        accent.Position = UDim2.fromOffset(4, 4)
        accent.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        accent.BorderSizePixel = 0
        Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1, -14, 0, 22)
        lbl.Position = UDim2.fromOffset(12, 4)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(255, 230, 230)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = "STUNNED"
        lbl.ZIndex = 2

        local nameLbl = Instance.new("TextLabel", bg)
        nameLbl.Size = UDim2.new(1, -14, 0, 12)
        nameLbl.Position = UDim2.fromOffset(12, 22)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 10
        nameLbl.TextColor3 = Color3.fromRGB(255, 170, 170)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Text = tostring(p.DisplayName or p.Name)
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex = 2

        local barBg = Instance.new("Frame", bg)
        barBg.Size = UDim2.new(1, -16, 0, 5)
        barBg.Position = UDim2.new(0, 8, 1, -10)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 12, 14)
        barBg.BorderSizePixel = 0
        barBg.ZIndex = 2
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local bar = Instance.new("Frame", barBg)
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        bar.BorderSizePixel = 0
        bar.ZIndex = 3
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        if not Tracked[p] then Tracked[p] = {} end
        Tracked[p].tag        = bb
        Tracked[p].tagLabel   = lbl
        Tracked[p].tagStroke  = outer
        Tracked[p].cdBar      = bar
        Tracked[p].nameLbl    = nameLbl
        Tracked[p].stunnedAt  = os.clock()
        Tracked[p].tagShownAt = os.clock()
    end

    RunService.RenderStepped:Connect(function()
        if not Enabled then return end
        local now = os.clock()
        for p, data in pairs(Tracked) do
            if data.tag and data.tag.Parent and data.stunnedAt then
                local elapsed   = now - data.stunnedAt
                local remaining = math.max(0, STUN_COOLDOWN - elapsed)
                local pct       = math.clamp(remaining / STUN_COOLDOWN, 0, 1)
                local shownFor  = now - (data.tagShownAt or now)

                if remaining <= 0 and shownFor < MIN_TAG_DISPLAY then
                    remaining = 0.01
                    pct = 0.01
                end

                if data.tagStroke then
                    if remaining <= 0.8 then
                        data.tagStroke.Color = Color3.fromRGB(255, 210, 80)
                    elseif remaining <= 1.6 then
                        data.tagStroke.Color = Color3.fromRGB(255, 140, 70)
                    else
                        data.tagStroke.Color = Color3.fromRGB(255, 70, 70)
                    end
                end

                if data.cdBar then
                    data.cdBar.Size = UDim2.new(pct, 0, 1, 0)
                    if remaining <= 0.8 then
                        data.cdBar.BackgroundColor3 = Color3.fromRGB(255, 220, 70)
                    elseif remaining <= 1.6 then
                        data.cdBar.BackgroundColor3 = Color3.fromRGB(255, 140, 60)
                    else
                        data.cdBar.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
                    end
                end

                if remaining <= 0 and shownFor >= MIN_TAG_DISPLAY then
                    clearTag(p)
                end
            end
        end
    end)

    local function isStunned(char)
        if not char then return false end
        if char:GetAttribute("IsStunned")  == true then return true end
        if char:GetAttribute("isStunned")  == true then return true end
        if char:GetAttribute("Stunned")    == true then return true end
        return false
    end

    local function checkPlayer(p)
        if not Enabled then return end
        if p == LocalPlayer then return end
        local char = p.Character
        local data = Tracked[p]
        if not data then data = { stunned = false } Tracked[p] = data end

        if not isKiller(p) then
            if data.tagShownAt and (os.clock() - data.tagShownAt) < MIN_TAG_DISPLAY then return end
            clearTag(p)
            data.stunned = false
            return
        end

        local stunned = isStunned(char)
        if stunned and not data.stunned then
            data.stunned = true
            playStunSound()
            if char then showTag(p, char) end
        elseif not stunned and data.stunned then
            data.stunned = false
        elseif stunned and char and (not data.tag or not data.tag.Parent) then
            if not data.tagShownAt or (os.clock() - data.tagShownAt) >= MIN_TAG_DISPLAY then
                showTag(p, char)
            else
                local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if head and data.tag then
                    data.tag.Adornee = head
                    data.tag.Parent  = head
                end
            end
        end
    end

    local function hookChar(p, char)
        if not char then return end
        for _, attr in ipairs({ "IsStunned", "isStunned", "Stunned" }) do
            pcall(function()
                char:GetAttributeChangedSignal(attr):Connect(function() checkPlayer(p) end)
            end)
        end
        checkPlayer(p)
    end

    local function hookPlayer(p)
        if p.Character then hookChar(p, p.Character) end
        p.CharacterAdded:Connect(function(c)
            task.wait(0.3)
            if Tracked[p] then Tracked[p].stunned = false end
            clearTag(p)
            hookChar(p, c)
        end)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then hookPlayer(p) end
    end
    Players.PlayerAdded:Connect(hookPlayer)
    Players.PlayerRemoving:Connect(function(p) clearTag(p) Tracked[p] = nil end)

    task.spawn(function()
        while true do
            if Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer then pcall(checkPlayer, p) end
                end
            end
            task.wait(0.2)
        end
    end)

    -- ===== PANEL UI =====
    local function CreateUI()
        local parent = getParent()
        if not parent then return end

        local old = parent:FindFirstChild("STUN_NotifyUI")
        if old then pcall(function() old:Destroy() end) end

        local gui = Instance.new("ScreenGui")
        gui.Name = "STUN_NotifyUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999999
        gui.Parent = parent
        PanelGui = gui

        local floatBtn = Instance.new("TextButton")
        floatBtn.Name = "OpenCloseBtn"
        floatBtn.Size = UDim2.fromOffset(44, 44)
        floatBtn.Position = UDim2.new(0.5, -22, 0.12, 0)
        floatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        floatBtn.AutoButtonColor = false
        floatBtn.Text = "🔊"
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextSize = 20
        floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        floatBtn.ZIndex = 20
        floatBtn.Parent = gui
        Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
        local floatStroke = Instance.new("UIStroke", floatBtn)
        floatStroke.Color = Color3.fromRGB(255, 80, 80)
        floatStroke.Thickness = 2

        local Main = Instance.new("Frame")
        Main.Name = "Main"
        Main.Size = UDim2.fromOffset(240, 360)
        Main.Position = UDim2.new(0.5, -120, 0.22, 0)
        Main.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
        Main.BorderSizePixel = 0
        Main.Active = true
        Main.ClipsDescendants = true
        Main.Visible = false
        Main.Parent = gui
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
        local mainStroke = Instance.new("UIStroke", Main)
        mainStroke.Color = Color3.fromRGB(255, 255, 255)
        mainStroke.Thickness = 1.5

        local TitleBar = Instance.new("Frame", Main)
        TitleBar.Size = UDim2.new(1, 0, 0, 36)
        TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TitleBar.BorderSizePixel = 0
        Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

        local TitleFix = Instance.new("Frame", TitleBar)
        TitleFix.Size = UDim2.new(1, 0, 0, 14)
        TitleFix.Position = UDim2.new(0, 0, 1, -14)
        TitleFix.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TitleFix.BorderSizePixel = 0

        local Title = Instance.new("TextLabel", TitleBar)
        Title.Size = UDim2.new(1, -70, 1, 0)
        Title.Position = UDim2.fromOffset(12, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Stun Notify"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local lockBtn = Instance.new("ImageButton", TitleBar)
        lockBtn.Size = UDim2.fromOffset(22, 22)
        lockBtn.Position = UDim2.new(1, -56, 0.5, 0)
        lockBtn.AnchorPoint = Vector2.new(0, 0.5)
        lockBtn.BackgroundTransparency = 1
        lockBtn.Image = "rbxassetid://3926305904"
        lockBtn.ImageRectOffset = Vector2.new(4, 684)
        lockBtn.ImageRectSize = Vector2.new(36, 36)
        lockBtn.ImageColor3 = Color3.fromRGB(255, 70, 70)
        lockBtn.ScaleType = Enum.ScaleType.Fit
        lockBtn.ZIndex = 11

        local closeBtn = Instance.new("ImageButton", TitleBar)
        closeBtn.Size = UDim2.fromOffset(22, 22)
        closeBtn.Position = UDim2.new(1, -28, 0.5, 0)
        closeBtn.AnchorPoint = Vector2.new(0, 0.5)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Image = "rbxassetid://3926305904"
        closeBtn.ImageRectOffset = Vector2.new(284, 4)
        closeBtn.ImageRectSize = Vector2.new(36, 36)
        closeBtn.ImageColor3 = Color3.fromRGB(255, 90, 90)
        closeBtn.ScaleType = Enum.ScaleType.Fit
        closeBtn.ZIndex = 11

        local Content = Instance.new("Frame", Main)
        Content.Size = UDim2.new(1, 0, 1, -36)
        Content.Position = UDim2.fromOffset(0, 36)
        Content.BackgroundTransparency = 1
        Content.ClipsDescendants = true

        local BgImage = Instance.new("ImageLabel", Content)
        BgImage.Name = "PanelBackground"
        BgImage.Size = UDim2.new(1, 0, 1, 0)
        BgImage.BackgroundTransparency = 1
        BgImage.Image = "rbxassetid://" .. tostring(PANEL_BG_ID)
        BgImage.ScaleType = Enum.ScaleType.Crop
        BgImage.ZIndex = 0
        BgImage.ImageTransparency = 0.15

        local BgDim = Instance.new("Frame", Content)
        BgDim.Size = UDim2.new(1, 0, 1, 0)
        BgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BgDim.BackgroundTransparency = 0.55
        BgDim.BorderSizePixel = 0
        BgDim.ZIndex = 1

        local Scroll = Instance.new("ScrollingFrame", Content)
        Scroll.Size = UDim2.new(1, -14, 1, -8)
        Scroll.Position = UDim2.fromOffset(7, 4)
        Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 3
        Scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 210)
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll.ZIndex = 2

        local ListLayout = Instance.new("UIListLayout", Scroll)
        ListLayout.Padding = UDim.new(0, 5)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)

        local function CreateSection(text)
            local lbl = Instance.new("TextLabel", Scroll)
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 3
        end

        local function CreateToggle(name, get, set)
            local Frame = Instance.new("Frame", Scroll)
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            Frame.BackgroundTransparency = 0.45
            Frame.BorderSizePixel = 0
            Frame.ZIndex = 3
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", Frame)
            lbl.Size = UDim2.new(1, -55, 1, 0)
            lbl.Position = UDim2.fromOffset(10, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 4

            local ToggleBtn = Instance.new("TextButton", Frame)
            ToggleBtn.Size = UDim2.fromOffset(38, 18)
            ToggleBtn.Position = UDim2.new(1, -46, 0.5, -9)
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.ZIndex = 4
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame", ToggleBtn)
            Circle.Size = UDim2.fromOffset(14, 14)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BorderSizePixel = 0
            Circle.ZIndex = 5
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local function paint()
                local on = get()
                ToggleBtn.BackgroundColor3 = on and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(50, 50, 55)
                Circle.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.fromOffset(2, 2)
            end
            paint()
            ToggleBtn.MouseButton1Click:Connect(function() set(not get()) paint() end)
        end

        CreateSection("MAIN")
        CreateToggle("Enabled", function() return Enabled end, function(v)
            Enabled = v
            if not v then for p in pairs(Tracked) do clearTag(p) end end
        end)

        CreateSection("SOUND")
        local soundButtons = {}
        for i, preset in ipairs(SOUND_PRESETS) do
            local btn = Instance.new("TextButton", Scroll)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
            btn.BackgroundTransparency = 0.45
            btn.Text = preset.name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextColor3 = Color3.fromRGB(240, 240, 245)
            btn.AutoButtonColor = false
            btn.ZIndex = 3
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local st = Instance.new("UIStroke", btn)
            st.Thickness = 1
            st.Color = Color3.fromRGB(80, 80, 90)

            btn.MouseButton1Click:Connect(function()
                CurrentSoundIdx = i
                loadSoundByIndex(i)
                for j, b in ipairs(soundButtons) do
                    if j == i then
                        b.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
                        b.BackgroundTransparency = 0.15
                        b.TextColor3 = Color3.fromRGB(255, 255, 255)
                        b.UIStroke.Color = Color3.fromRGB(255, 90, 90)
                    else
                        b.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
                        b.BackgroundTransparency = 0.45
                        b.TextColor3 = Color3.fromRGB(240, 240, 245)
                        b.UIStroke.Color = Color3.fromRGB(80, 80, 90)
                    end
                end
                if preset.id ~= 0 then playStunSound() end
            end)
            soundButtons[i] = btn
        end
        soundButtons[CurrentSoundIdx].BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        soundButtons[CurrentSoundIdx].BackgroundTransparency = 0.15
        soundButtons[CurrentSoundIdx].TextColor3 = Color3.fromRGB(255, 255, 255)
        soundButtons[CurrentSoundIdx].UIStroke.Color = Color3.fromRGB(255, 90, 90)

        local panelOpen = false
        local function setPanelOpen(v)
            panelOpen = v and true or false
            Main.Visible = panelOpen
            floatStroke.Color = panelOpen and Color3.fromRGB(255, 180, 60) or Color3.fromRGB(255, 80, 80)
            floatBtn.BackgroundColor3 = panelOpen and Color3.fromRGB(40, 30, 20) or Color3.fromRGB(20, 20, 24)
        end

        local fDragging, fStart, fPos, fMoved = false, nil, nil, false
        floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDragging, fMoved = true, false
                fStart, fPos = input.Position, floatBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not fDragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - fStart
                if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then fMoved = true end
                floatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
            end
        end)
        floatBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDragging = false
            end
        end)
        floatBtn.MouseButton1Click:Connect(function()
            if fMoved then return end
            setPanelOpen(not panelOpen)
        end)

        lockBtn.MouseButton1Click:Connect(function()
            DragLocked = not DragLocked
            lockBtn.ImageColor3 = DragLocked and Color3.fromRGB(255, 180, 60) or Color3.fromRGB(255, 70, 70)
        end)
        closeBtn.MouseButton1Click:Connect(function() setPanelOpen(false) end)

        local dragging, dragStart, startPos = false, nil, nil
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if DragLocked then return end
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or DragLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    task.defer(CreateUI)
    print("[STUN NOTIFY] loaded | STUNNED tag | cooldown 2.8s")
end)()

do
    BoosterSection = Tabs.Settings:AddSection("Booster FPS")
    local Terrain      = workspace:FindFirstChildOfClass("Terrain")
    local Lighting     = game:GetService("Lighting")
    local StarterGui   = game:GetService("StarterGui")
    local SoundService = game:GetService("SoundService")
    local E_SMOOTH    = Enum.SurfaceType.SmoothNoOutlines
    local E_PLASTIC   = Enum.Material.SmoothPlastic
    local E_LEGACY    = Enum.Technology.Legacy
    local E_LVL1      = Enum.QualityLevel.Level01
    local E_MESH1     = Enum.MeshPartDetailLevel.Level01
    local E_AUTO      = Enum.QualityLevel.Automatic
    local E_DISTBASE  = Enum.MeshPartDetailLevel.DistanceBased
    local E_SAVEDAUTO = Enum.SavedQualitySetting.Automatic
    local E_SAVEDQ1   = Enum.SavedQualitySetting.QualityLevel1
    local E_NOREVRB   = Enum.ReverbType.NoReverb
    local E_LISTCAM   = Enum.ListenerType.Camera
    local WHITE       = Color3.new(1, 1, 1)
    local SURFACES    = { "TopSurface","BottomSurface","LeftSurface","RightSurface","FrontSurface","BackSurface" }
    local DESTROY_SET = {
        ParticleEmitter=true, Trail=true, Beam=true, Fire=true,
        Smoke=true, Sparkles=true, ForceField=true, Explosion=true,
        BloomEffect=true, BlurEffect=true, ColorCorrectionEffect=true,
        SunRaysEffect=true, DepthOfFieldEffect=true, Atmosphere=true,
        Decal=true, Texture=true, SurfaceAppearance=true,
        SpecialMesh=true, BlockMesh=true, CylinderMesh=true,
        PointLight=true, SpotLight=true, SurfaceLight=true,
        Accessory=true, Hat=true, Shirt=true, Pants=true,
        ShirtGraphic=true, CharacterMesh=true, BodyColors=true,
        Clothing=true, HumanoidDescription=true,
    }
    local _potato = {
        enabled          = false,
        connections      = {},
        processedObjects = setmetatable({}, { __mode = "k" }),
        origStates       = { lighting = {}, water = {}, camera = {} },
    }
    local function _optimizeObj(obj)
        if _potato.processedObjects[obj] then return end
        _potato.processedObjects[obj] = true
        if DESTROY_SET[obj.ClassName] then
            obj:Destroy()
            return
        end
        if obj:IsA("BasePart") then
            obj.Material    = E_PLASTIC
            obj.CastShadow  = false
            obj.Reflectance = 0
            for i = 1, 6 do obj[SURFACES[i]] = E_SMOOTH end
        end
    end
    local function _optimizeChar(char)
        if not char or _potato.processedObjects[char] then return end
        _potato.processedObjects[char] = true
        pcall(function()
            local desc = char:GetDescendants()
            for i = 1, #desc do
                local obj = desc[i]
                if DESTROY_SET[obj.ClassName] then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    if obj.Name == "Head" then obj.Transparency = 1 end
                    obj.Material    = E_PLASTIC
                    obj.CastShadow  = false
                    obj.Reflectance = 0
                    obj.CanCollide  = (obj.Name == "HumanoidRootPart" or obj.Name == "Head")
                    for s = 1, 6 do obj[SURFACES[s]] = E_SMOOTH end
                elseif obj:IsA("Humanoid") then
                    local tracks = obj:GetPlayingAnimationTracks()
                    for t = 1, #tracks do tracks[t]:Stop(0) end
                    obj.HealthDisplayDistance = 0
                    obj.NameDisplayDistance   = 0
                end
            end
        end)
    end
    local function _potatoCleanup()
        local conns = _potato.connections
        for i = 1, #conns do pcall(conns[i].Disconnect, conns[i]) end
        _potato.connections      = {}
        _potato.processedObjects = setmetatable({}, { __mode = "k" })
    end
    local function _applyWorldSettings()
        if Terrain then
            pcall(function()
                _potato.origStates.water = {
                    WaterReflectance  = Terrain.WaterReflectance,
                    WaterWaveSize     = Terrain.WaterWaveSize,
                    WaterWaveSpeed    = Terrain.WaterWaveSpeed,
                    WaterTransparency = Terrain.WaterTransparency,
                }
                Terrain.WaterWaveSize     = 0
                Terrain.WaterWaveSpeed    = 0
                Terrain.WaterReflectance  = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration        = false
            end)
            local clouds = Terrain:FindFirstChildOfClass("Clouds")
            if clouds then clouds:Destroy() end
        end
        pcall(function()
            _potato.origStates.lighting = {
                GlobalShadows = Lighting.GlobalShadows,
                Brightness    = Lighting.Brightness,
                Technology    = Lighting.Technology,
            }
            Lighting.GlobalShadows            = false
            Lighting.FogEnd                   = 9e9
            Lighting.Brightness               = 0
            Lighting.OutdoorAmbient           = WHITE
            Lighting.Ambient                  = WHITE
            Lighting.Technology               = E_LEGACY
            Lighting.EnvironmentDiffuseScale  = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ShadowSoftness           = 0
        end)
        local lchildren = Lighting:GetChildren()
        for i = 1, #lchildren do
            local c = lchildren[i]
            if c:IsA("PostEffect") or c:IsA("Atmosphere") then
                pcall(c.Destroy, c)
            elseif c:IsA("Sky") then
                pcall(function()
                    c.StarCount            = 0
                    c.SunAngularSize       = 0
                    c.MoonAngularSize      = 0
                    c.CelestialBodiesShown = false
                    c.SkyboxBk = ""; c.SkyboxDn = ""; c.SkyboxFt = ""
                    c.SkyboxLf = ""; c.SkyboxRt = ""; c.SkyboxUp = ""
                end)
            end
        end
        pcall(function()
            SoundService.AmbientReverb = E_NOREVRB
            SoundService:SetListener(E_LISTCAM)
        end)
        pcall(function()
            local rs = settings().Rendering
            rs.QualityLevel        = E_LVL1
            rs.MeshPartDetailLevel = E_MESH1
            rs.EditQualityLevel    = E_LVL1
        end)
        pcall(function()
            local ugs = UserSettings():GetService("UserGameSettings")
            ugs.SavedQualityLevel    = E_SAVEDQ1
        end)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                _potato.origStates.camera = { FieldOfView = cam.FieldOfView }
                cam.FieldOfView = 70
            end
        end)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
        end)
    end
    local function _restoreWorldSettings()
        if Terrain and _potato.origStates.water.WaterReflectance ~= nil then
            pcall(function()
                local w = _potato.origStates.water
                Terrain.WaterReflectance  = w.WaterReflectance
                Terrain.WaterWaveSize     = w.WaterWaveSize
                Terrain.WaterWaveSpeed    = w.WaterWaveSpeed
                Terrain.WaterTransparency = w.WaterTransparency
                Terrain.Decoration        = true
            end)
        end
        pcall(function()
            local l = _potato.origStates.lighting
            if l.GlobalShadows ~= nil then
                Lighting.GlobalShadows = l.GlobalShadows
                Lighting.Brightness    = l.Brightness
                Lighting.Technology    = l.Technology
            end
        end)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam and _potato.origStates.camera.FieldOfView then
                cam.FieldOfView = _potato.origStates.camera.FieldOfView
            end
        end)
        pcall(function()
            local rs = settings().Rendering
            rs.QualityLevel        = E_AUTO
            rs.MeshPartDetailLevel = E_DISTBASE
        end)
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = E_SAVEDAUTO
        end)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        end)
        _potato.origStates = { lighting = {}, water = {}, camera = {} }
    end
    BoosterSection:AddToggle({
        Title    = "Reduce Map (Potato Mode)",
        Default  = false,
        Callback = function(on)
            _potato.enabled = on
            _potatoCleanup()
            if not on then
                _restoreWorldSettings()
                return
            end
            _applyWorldSettings()
            task.spawn(function()
                while _potato.enabled do
                    _potato.processedObjects = setmetatable({}, { __mode = "k" })
                    local all   = workspace:GetDescendants()
                    local n     = #all
                    local BATCH = 50
                    for i = 1, n, BATCH do
                        if not _potato.enabled then break end
                        for j = i, math.min(i + BATCH - 1, n) do
                            _optimizeObj(all[j])
                        end
                        task.wait()
                    end
                    if not _potato.enabled then break end
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr.Character then task.defer(_optimizeChar, plr.Character) end
                    end
                    local waitTime = 600
                    while waitTime > 0 and _potato.enabled do
                        task.wait(1)
                        waitTime = waitTime - 1
                    end
                    if _potato.enabled then
                        pcall(_applyWorldSettings)
                    end
                end
            end)
            _potato.connections[#_potato.connections+1] = Players.PlayerAdded:Connect(function(plr)
                _potato.connections[#_potato.connections+1] = plr.CharacterAdded:Connect(function(char)
                    if not _potato.enabled then return end
                    task.delay(0.2, function()
                        if _potato.enabled then _optimizeChar(char) end
                    end)
                end)
                if plr.Character then task.defer(_optimizeChar, plr.Character) end
            end)
            _potato.connections[#_potato.connections+1] = LocalPlayer.CharacterAdded:Connect(function(char)
                if not _potato.enabled then return end
                task.delay(0.2, function()
                    if _potato.enabled then _optimizeChar(char) end
                end)
            end)
            _potato.connections[#_potato.connections+1] = workspace.DescendantAdded:Connect(function(obj)
                if not _potato.enabled then return end
                _optimizeObj(obj)
            end)
        end,
    })
    BoosterSection:AddToggle({
        Title = "Low Graphics Mode",
        Content = "Activate this before match",
        Default = false,
        Callback = function(v)
            LocalPlayer:SetAttribute("lowGraphics", v)
        end
    })
    BoosterSection:AddToggle({
        Title = "Remove Dynamic Shadow",
        Default = false,
        Callback = function(v)
            Lighting.GlobalShadows = not v
        end
    })
    BoosterSection:AddToggle({
        Title = "Max FPS",
        Default = true,
        Callback = function(v)
            if v then
                setfpscap(9999)
            end
        end
    })
    BoosterSection:AddDivider()
    local originalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        AtmosphereDensity = Lighting:FindFirstChildOfClass("Atmosphere") and Lighting:FindFirstChildOfClass("Atmosphere").Density or 0.3
    }

    local fullBrightConnection = nil
    local noFogConnection = nil

    local function enforceBright()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    end

    local function enforceNoFog()
        Lighting.FogStart = 999999
        Lighting.FogEnd = 999999
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere.Density = 0
        end
    end

    BoosterSection:AddToggle({
        Title = "Full Bright",
        Default = false,
        Callback = function(state)
            if fullBrightConnection then fullBrightConnection:Disconnect(); fullBrightConnection = nil end
            
            if state then
                enforceBright()
                fullBrightConnection = Lighting.Changed:Connect(function(property)
                    if property == "Ambient" or property == "OutdoorAmbient" or property == "Brightness" or property == "ClockTime" then
                        enforceBright()
                    end
                end)
            else
                Lighting.Ambient = originalLighting.Ambient
                Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
                Lighting.Brightness = originalLighting.Brightness
                Lighting.ClockTime = originalLighting.ClockTime
            end
        end
    })

    BoosterSection:AddToggle({
        Title = "No Fog",
        Default = false,
        Callback = function(state)
            if noFogConnection then noFogConnection:Disconnect(); noFogConnection = nil end
            
            if state then
                enforceNoFog()
                noFogConnection = Lighting.Changed:Connect(function(property)
                    if property == "FogStart" or property == "FogEnd" then
                        enforceNoFog()
                    end
                end)
                
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = 0
                    atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
                        if noFogConnection then atmosphere.Density = 0 end
                    end)
                end
            else
                Lighting.FogStart = originalLighting.FogStart
                Lighting.FogEnd = originalLighting.FogEnd
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere.Density = originalLighting.AtmosphereDensity
                end
            end
        end
    })

    Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Atmosphere") and noFogConnection then
            task.wait() 
            child.Density = 0
            child:GetPropertyChangedSignal("Density"):Connect(function()
                if noFogConnection then child.Density = 0 end
            end)
        end
    end)
end

PlayerUtilitySection = Tabs.Utility:AddSection("Player Utility")
local defaultZoom = 128
local zoomConn
local cameraFollowThread = nil
local cameraFollowEnabled = false
local originalName = LocalPlayer.Name
if _G.HiddenNameConnections then
    for _, conn in pairs(_G.HiddenNameConnections) do
        if conn then conn:Disconnect() end
    end
end
_G.HiddenNameConnections = {}

local runSpeedEnabled = false
local speedValue = 20
local _speedHookConn = nil
local _attributeLoopConn = nil
local _charAddedConn = nil
local originalWalkSpeed = nil

local function _hookSpeed(character)
    if _speedHookConn then _speedHookConn:Disconnect(); _speedHookConn = nil end
    if _attributeLoopConn then _attributeLoopConn:Disconnect(); _attributeLoopConn = nil end
    if not runSpeedEnabled then return end
    if not character then return end

    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then hum = character:WaitForChild("Humanoid", 10) end
    if not hum then return end

    if not originalWalkSpeed and hum.WalkSpeed ~= speedValue and hum.WalkSpeed > 0 then
        originalWalkSpeed = hum.WalkSpeed
    end

    task.wait(0.5)
    if not runSpeedEnabled then return end

    _speedHookConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not runSpeedEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end

        if c:GetAttribute("IsCarried") or c:GetAttribute("IsHooked") or
           c:GetAttribute("IsStunned") or c:GetAttribute("Immobile") or
           c:GetAttribute("MovementLocked") or c:GetAttribute("Crouching") or
           c:GetAttribute("Knocked") or c:GetAttribute("isHealing") then
            return
        end

        if hum.WalkSpeed == 0 then return end
        if hum.WalkSpeed ~= speedValue then
            pcall(function() hum.WalkSpeed = speedValue end)
        end
    end)

    _attributeLoopConn = RunService.Stepped:Connect(function()
        if not runSpeedEnabled or not LocalPlayer.Character then return end
        local c = LocalPlayer.Character

        if not c:GetAttribute("Crouching") and not c:GetAttribute("Knocked") and
           not c:GetAttribute("isHealing") and not c:GetAttribute("IsCarried") then

            if c:GetAttribute("Sprinting") ~= true then
                c:SetAttribute("Sprinting", true)
            end
            if c:GetAttribute("IsRunning") ~= true then
                c:SetAttribute("IsRunning", true)
            end

            if hum and hum.WalkSpeed ~= speedValue and hum.WalkSpeed > 0 then
                pcall(function() hum.WalkSpeed = speedValue end)
            end
        end
    end)

    pcall(function() hum.WalkSpeed = speedValue end)
end

PlayerUtilitySection:AddSlider({
    Title = "Speed Value",
    Default = 20,
    Min = 16,
    Max = 50,
    Callback = function(val)
        speedValue = val
        if runSpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = val end) end
        end
    end
})

PlayerUtilitySection:AddToggle({
    Title = "Enable Run Speed",
    Default = false,
    Callback = function(v)
        runSpeedEnabled = v

        if _speedHookConn then _speedHookConn:Disconnect(); _speedHookConn = nil end
        if _attributeLoopConn then _attributeLoopConn:Disconnect(); _attributeLoopConn = nil end

        if v then
            _hookSpeed(LocalPlayer.Character)

            _charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if runSpeedEnabled then
                    _hookSpeed(newChar)
                end
            end)
        else
            if _charAddedConn then _charAddedConn:Disconnect(); _charAddedConn = nil end

            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("Sprinting", false)
                char:SetAttribute("IsRunning", false)

                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum.WalkSpeed = originalWalkSpeed or 10 end)
                end
            end
            originalWalkSpeed = nil
        end
    end,
})
PlayerUtilitySection:AddDivider()
PlayerUtilitySection:AddToggle({
    Title = "Anti Staff",
    Content = "Automatically kick if any staff/dev join",
    Default = true,
    Callback = function(state)
        _G.AntiStaffVD = state
        
        local GroupID = 8818124
        local StaffRanks = {
            [3]  = "contributors",
            [254]  = "rick",
            [255]  = "dev",
        }

        function Action(StaffName, StaffRole)
            Players.LocalPlayer:Kick("\n[ANTI-STAFF DETECTION]\n\nStaff: " .. StaffName .. "\nRole: " .. StaffRole .. "\n\nAkun diamankan karena ada staff masuk!")
        end

        function CheckForStaff(Player)
            if not _G.AntiStaffVD then return end
            if Player == Players.LocalPlayer then return end
            
            local Success, PlayerRank = pcall(function()
                return Player:GetRankInGroup(GroupID)
            end)
            
            if Success and StaffRanks[PlayerRank] then
                Action(Player.Name, StaffRanks[PlayerRank])
            end
        end

        if _G.StaffConnectionVD then
            _G.StaffConnectionVD:Disconnect()
            _G.StaffConnectionVD = nil
        end

        if state then
            for _, v in ipairs(Players:GetPlayers()) do
                task.spawn(CheckForStaff, v)
            end

            _G.StaffConnectionVD = Players.PlayerAdded:Connect(function(NewPlayer)
                task.wait(1)
                CheckForStaff(NewPlayer)
            end)
        end
    end
})
local skipEndscreen = false
PlayerUtilitySection:AddToggle({
    Title = "Skip Endscreen",
    Content = "Mobile disarankan mengaktifkan ini untuk menghindari crash after match",
    Default = false,
    Callback = function(v)
        skipEndscreen = v
    end
})
task.spawn(function()
        while true do
            if skipEndscreen then
                pcall(function()
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        local endscreenFolder = map:FindFirstChild("endscreen", true)
                        if endscreenFolder then
                            for _, obj in ipairs(endscreenFolder:GetDescendants()) do
                                if obj:IsA("LocalScript") then
                                    obj.Disabled = true
                                end
                            end
                            endscreenFolder:Destroy()
                        end
                    end

                    local resultGui = PlayerGui.Results
                    local frameResult = resultGui.Frame
                    local continueBtn = frameResult.Close

                    if resultGui then
                        if frameResult.Visible and continueBtn.Visible then
                            pcall(function() firesignal(continueBtn.MouseButton1Click) end)
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)
PlayerUtilitySection:AddToggle({
    Title = "Ping & FPS Counter",
    Default = false,
    Callback = function(v)
        _G.ShowPingFPS = v
        
        local CoreGui = game:GetService("CoreGui")
        local RunService = game:GetService("RunService")
        local StatsService = game:GetService("Stats")
        
        if CoreGui:FindFirstChild("SimpleStatsUI") then
            CoreGui.SimpleStatsUI:Destroy()
        end
        
        if not v then return end
        
        local SimpleStatsUI = Instance.new("ScreenGui")
        local Container = Instance.new("Frame")
        local StatLabel = Instance.new("TextLabel")
        
        SimpleStatsUI.Name = "SimpleStatsUI"
        SimpleStatsUI.Parent = CoreGui
        SimpleStatsUI.ResetOnSpawn = false
        
        Container.Name = "Container"
        Container.Parent = SimpleStatsUI
        Container.AnchorPoint = Vector2.new(0.5, 0)
        Container.Position = UDim2.new(0.5, 0, 0.015, 0)
        Container.Size = UDim2.new(0, 400, 0, 25)
        Container.BackgroundTransparency = 1
        
        StatLabel.Name = "StatLabel"
        StatLabel.Parent = Container
        StatLabel.Size = UDim2.new(1, 0, 1, 0)
        StatLabel.BackgroundTransparency = 1
        StatLabel.Font = Enum.Font.GothamBold
        StatLabel.TextSize = 13
        StatLabel.RichText = true
        StatLabel.TextYAlignment = Enum.TextYAlignment.Center
        StatLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local TextStroke = Instance.new("UIStroke")
        TextStroke.Thickness = 1
        TextStroke.Color = Color3.fromRGB(0, 0, 0)
        TextStroke.Parent = StatLabel
        
        StatLabel.Text = "<font color='#00FF78'>-- FPS</font>  <font color='#FFFFFF'>|</font>  <font color='#FF4B4B'>-- ms</font>"
        
        local fpsCount = 0
        local lastUpdate = os.clock()
        local currentFps = 60
        
        local fpsConnection
        fpsConnection = RunService.RenderStepped:Connect(function(dt)
            if not _G.ShowPingFPS then
                if fpsConnection then fpsConnection:Disconnect() end
                if SimpleStatsUI then SimpleStatsUI:Destroy() end
                return
            end
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastUpdate >= 1 then
                currentFps = math.floor(fpsCount / (now - lastUpdate))
                fpsCount = 0
                lastUpdate = now
            end
        end)
        
        task.spawn(function()
            while _G.ShowPingFPS and Container and StatLabel do
                local realPing = 0
                
                pcall(function()
                    local serverStats = StatsService:FindFirstChild("Network") and StatsService.Network:FindFirstChild("ServerStatsItem")
                    local dataPingItem = serverStats and serverStats:FindFirstChild("Data Ping")
                    if dataPingItem then
                        realPing = math.floor(dataPingItem:GetValue())
                    end
                end)
                
                if realPing <= 0 then
                    pcall(function()
                        realPing = math.floor(StatsService.Network:GetPing())
                    end)
                end
                
                StatLabel.Text = string.format(
                    "<font color='#00FF78'>%d FPS</font>   <font color='#555555'>|</font>   <font color='#FF4B4B'>%d ms</font>", 
                    currentFps, realPing
                )
                
                task.wait(0.5)
            end
        end)
    end
})
local originalGuiData = {
    Names = {},
    Icons = {}
}

if not _G.HiddenNameConnections then _G.HiddenNameConnections = {} end
if not _G.HideIconConnections then _G.HideIconConnections = {} end

local function getSurvivorFrames()
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
    local selectedKillerName = LocalPlayer:GetAttribute("SelectedKiller")

    local survivorGui = pGui:FindFirstChild("Survivor") or pGui:FindFirstChild("Survivor-mob")
    local sFrame = survivorGui and survivorGui:FindFirstChild("Frame")
    
    local killerGui = pGui:FindFirstChild(selectedKillerName) or pGui:FindFirstChild(selectedKillerName .. "-mob")
    local slFrame = killerGui and killerGui:FindFirstChild("Frame")
    
    local activeFrame = nil
    if sFrame and survivorGui.Enabled then
        activeFrame = sFrame
    elseif slFrame and killerGui and killerGui.Enabled then
        activeFrame = slFrame
    else
        activeFrame = sFrame or slFrame
    end

    if activeFrame then
        local frames = {}
        for i = 1, 5 do
            local sSlot = activeFrame:FindFirstChild("Survivor" .. i)
            if sSlot then table.insert(frames, sSlot) end
        end
        return frames
    end
    return nil
end

PlayerUtilitySection:AddToggle({
    Title = "Protect Name",
    Default = false,
    Callback = function(v)
        _G.HiddenNameEnabled = v

        for _, conn in pairs(_G.HiddenNameConnections) do
            if conn then conn:Disconnect() end
        end
        _G.HiddenNameConnections = {}

        if espEnabled then startEspLoop() end

        local function applyNameProtection()
            local frames = getSurvivorFrames()
            if frames then
                for _, sFrame in ipairs(frames) do
                    local txtLabel = sFrame:FindFirstChildOfClass("TextLabel")
                    if txtLabel then
                        if _G.HiddenNameEnabled then
                            if sFrame.Visible and txtLabel.Visible and #txtLabel.Text > 0 and txtLabel.Text ~= "RynerHUB" then
                                if not originalGuiData.Names[txtLabel] then
                                    originalGuiData.Names[txtLabel] = txtLabel.Text
                                end
                                txtLabel.Text = "RynerHUB"
                                table.insert(_G.HiddenNameConnections, txtLabel:GetPropertyChangedSignal("Text"):Connect(function()
                                    if txtLabel.Text ~= "RynerHUB" then txtLabel.Text = "RynerHUB" end
                                end))
                            elseif (not sFrame.Visible or not txtLabel.Visible or #txtLabel.Text == 0) then
                                txtLabel.Text = ""
                            end
                        else
                            if originalGuiData.Names[txtLabel] then
                                txtLabel.Text = originalGuiData.Names[txtLabel]
                            end
                        end
                    end
                end
            end

            task.spawn(function()
                local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
                local myName = LocalPlayer.Name

                local function scanAndProtect(root)
                    for _, v in ipairs(root:GetDescendants()) do
                        if v:IsA("TextLabel") and (v.Text == myName or v.Text == "RynerHUB") then
                            if v.Parent and v.Parent.Name:match("^Survivor%d") then continue end

                            if _G.HiddenNameEnabled then
                                if v.Text ~= "RynerHUB" then
                                    if not originalGuiData.Names[v] then
                                        originalGuiData.Names[v] = v.Text
                                    end
                                    v.Text = "RynerHUB"
                                end

                                table.insert(_G.HiddenNameConnections, v:GetPropertyChangedSignal("Text"):Connect(function()
                                    if v.Text ~= "RynerHUB" then
                                        if v.Text ~= "" and v.Text ~= "RynerHUB" then
                                            originalGuiData.Names[v] = v.Text
                                        end
                                        v.Text = "RynerHUB"
                                    end
                                end))
                            else
                                if originalGuiData.Names[v] then
                                    v.Text = originalGuiData.Names[v]
                                end
                            end
                        end
                    end
                end

                scanAndProtect(pGui)
                table.insert(_G.HiddenNameConnections, pGui.DescendantAdded:Connect(function(descendant)
                    if _G.HiddenNameEnabled and descendant:IsA("TextLabel") then
                        task.wait(0.1)
                        if descendant.Text == myName then
                            if descendant.Parent and descendant.Parent.Name:match("^Survivor%d") then return end

                            if not originalGuiData.Names[descendant] then
                                originalGuiData.Names[descendant] = descendant.Text
                            end
                            descendant.Text = "RynerHUB"
                            table.insert(_G.HiddenNameConnections, descendant:GetPropertyChangedSignal("Text"):Connect(function()
                                if descendant.Text ~= "RynerHUB" then descendant.Text = "RynerHUB" end
                            end))
                        end
                    end
                end))
            end)
        end

        applyNameProtection()

        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
        local selectedKillerName = LocalPlayer:GetAttribute("SelectedKiller")

        -- Watch GUI yang udah exist tapi baru di-enable pas match mulai
        local function watchNameGuiEnabled(guiName)
            local existing = pGui:FindFirstChild(guiName)
            if existing then
                table.insert(_G.HiddenNameConnections, existing:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if existing.Enabled and _G.HiddenNameEnabled then
                        task.wait(0.2)
                        applyNameProtection()
                    end
                end))
            end
        end

        watchNameGuiEnabled("Survivor")
        watchNameGuiEnabled("Survivor-mob")
        watchNameGuiEnabled(selectedKillerName)
        watchNameGuiEnabled(selectedKillerName .. "-mob")

        -- Watch GUI yang baru di-add
        table.insert(_G.HiddenNameConnections, pGui.ChildAdded:Connect(function(child)
            if child.Name == "Survivor" or child.Name == selectedKillerName or child.Name == "Spectator"
            or child.Name == "Survivor-mob" or child.Name == selectedKillerName .. "-mob" then
                task.wait(0.2)
                if _G.HiddenNameEnabled then applyNameProtection() end
                -- Watch juga kalau GUI ini di-enable ulang nanti
                table.insert(_G.HiddenNameConnections, child:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if child.Enabled and _G.HiddenNameEnabled then
                        task.wait(0.1)
                        applyNameProtection()
                    end
                end))
            end
        end))
    end
})

PlayerUtilitySection:AddToggle({
    Title = "Hide Player Icon",
    Default = false,
    Callback = function(v)
        _G.HideIconEnabled = v

        for _, conn in pairs(_G.HideIconConnections) do
            if conn then conn:Disconnect() end
        end
        _G.HideIconConnections = {}

        local targetLogo = "rbxassetid://110525773603905" -- logo RynerHUB

        local function applyIconProtection()
            local frames = getSurvivorFrames()
            if not frames then return end

            for _, sFrame in ipairs(frames) do
                local imgLabel = sFrame:FindFirstChildOfClass("ImageLabel")

                if imgLabel then
                    if _G.HideIconEnabled then
                        if sFrame.Visible and imgLabel.Visible and imgLabel.Image ~= "" and imgLabel.Image ~= targetLogo then
                            if not originalGuiData.Icons[imgLabel] then
                                originalGuiData.Icons[imgLabel] = imgLabel.Image
                            end

                            imgLabel.Image = targetLogo

                            table.insert(_G.HideIconConnections, imgLabel:GetPropertyChangedSignal("Image"):Connect(function()
                                if imgLabel.Image ~= targetLogo then imgLabel.Image = targetLogo end
                            end))
                        elseif (not sFrame.Visible or not imgLabel.Visible or imgLabel.Image == "") then
                            imgLabel.Image = ""
                        end
                    else
                        if originalGuiData.Icons[imgLabel] then
                            imgLabel.Image = originalGuiData.Icons[imgLabel]
                        end
                    end
                end
            end
        end

        applyIconProtection()

        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
        local selectedKillerName = LocalPlayer:GetAttribute("SelectedKiller")

        -- Watch GUI yang udah exist tapi baru di-enable pas match mulai
        local function watchIconGuiEnabled(guiName)
            local existing = pGui:FindFirstChild(guiName)
            if existing then
                table.insert(_G.HideIconConnections, existing:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if existing.Enabled and _G.HideIconEnabled then
                        task.wait(0.2)
                        applyIconProtection()
                    end
                end))
            end
        end

        watchIconGuiEnabled("Survivor")
        watchIconGuiEnabled("Survivor-mob")
        watchIconGuiEnabled(selectedKillerName)
        watchIconGuiEnabled(selectedKillerName .. "-mob")

        -- Watch GUI yang baru di-add
        table.insert(_G.HideIconConnections, pGui.ChildAdded:Connect(function(child)
            if child.Name == "Survivor" or child.Name == selectedKillerName
            or child.Name == "Survivor-mob" or child.Name == selectedKillerName .. "-mob" then
                task.wait(0.2)
                if _G.HideIconEnabled then applyIconProtection() end
                -- Watch juga kalau GUI ini di-enable ulang nanti
                table.insert(_G.HideIconConnections, child:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if child.Enabled and _G.HideIconEnabled then
                        task.wait(0.1)
                        applyIconProtection()
                    end
                end))
            end
        end))
    end
})
PlayerUtilitySection:AddToggle({
    Title = "Camera Follow Body Movement",
    Default = false,
    Callback = function(state)
        cameraFollowEnabled = state
        
        if state then
            if cameraFollowThread then task.cancel(cameraFollowThread) end
            
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.AutoRotate = false end

            cameraFollowThread = task.spawn(function()
                while cameraFollowEnabled do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum then
                        local cameraLookVector = Camera.CFrame.LookVector
                        local targetAngle = math.atan2(-cameraLookVector.X, -cameraLookVector.Z)
                        
                        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, targetAngle, 0)
                    end
                    task.wait() 
                end
            end)
        else
            if cameraFollowThread then 
                task.cancel(cameraFollowThread) 
                cameraFollowThread = nil
            end
            
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
    end
})
PlayerUtilitySection:AddToggle({
    Title = "Max Zoom 1000",
    Content = "Increase max camera distance",
    Default = false,
    Callback = function(state)
        if zoomConn then
            zoomConn:Disconnect()
            zoomConn = nil
        end

        if state then
            LocalPlayer.CameraMaxZoomDistance = 1000
            LocalPlayer.CameraMinZoomDistance = 0.5

            zoomConn = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.3)
                LocalPlayer.CameraMaxZoomDistance = 1000
                LocalPlayer.CameraMinZoomDistance = 0.5
            end)
        else
            LocalPlayer.CameraMaxZoomDistance = defaultZoom
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end
})

local billboard = nil
local textLabel = nil
local shineLabel = nil
local shineGradient = nil
local sizeConnection = nil

local BASE_WIDTH = isMobile and 90 or 140
local BASE_HEIGHT = isMobile and 20 or 32
local BASE_DISTANCE = 12
local MIN_SCALE = 0.6
local MAX_SCALE = isMobile and 1.1 or 1.4 -- mobile dibatasi lebih ketat biar ga bengkak

local function createBillboard()
    if billboard then billboard:Destroy() end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character:FindFirstChild("Head") then return end

    billboard = Instance.new("BillboardGui")
    billboard.Name = "CustomHeaderBillboard"
    billboard.Adornee = character.Head
    billboard.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = character

    textLabel = Instance.new("TextLabel")
    textLabel.Name = "BaseText"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(40, 130, 220)
    textLabel.ZIndex = 1
    textLabel.Parent = billboard

    shineLabel = Instance.new("TextLabel")
    shineLabel.Name = "ShineText"
    shineLabel.Size = UDim2.new(1, 0, 1, 0)
    shineLabel.BackgroundTransparency = 1
    shineLabel.TextScaled = true
    shineLabel.Font = Enum.Font.GothamBold
    shineLabel.TextStrokeTransparency = 1
    shineLabel.Text = textLabel.Text
    shineLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    shineLabel.ZIndex = 2
    shineLabel.Parent = billboard

    shineGradient = Instance.new("UIGradient")
    shineGradient.Name = "ShineGradient"
    shineGradient.Rotation = 20
    shineGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1),
        NumberSequenceKeypoint.new(0.30, 1),
        NumberSequenceKeypoint.new(0.42, 0),
        NumberSequenceKeypoint.new(0.58, 0),
        NumberSequenceKeypoint.new(0.70, 1),
        NumberSequenceKeypoint.new(1.00, 1),
    })
    shineGradient.Offset = Vector2.new(-1, 0)
    shineGradient.Parent = shineLabel

    if sizeConnection then sizeConnection:Disconnect() end
    sizeConnection = RunService.RenderStepped:Connect(function()
        if not billboard or not billboard.Parent then
            sizeConnection:Disconnect()
            return
        end
        local head = character:FindFirstChild("Head")
        if not head then return end

        local distance = (Camera.CFrame.Position - head.Position).Magnitude
        local scaleFactor = math.clamp(BASE_DISTANCE / distance, MIN_SCALE, MAX_SCALE)

        billboard.Size = UDim2.new(0, BASE_WIDTH * scaleFactor, 0, BASE_HEIGHT * scaleFactor)
    end)
end

local function startSweepAnimation()
    if not shineLabel or not shineGradient then return end

    task.spawn(function()
        while shineLabel and shineLabel.Parent and shineGradient and shineGradient.Parent do
            shineGradient.Offset = Vector2.new(-1, 0)

            local tween = TweenService:Create(
                shineGradient,
                TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Offset = Vector2.new(1, 0)}
            )
            tween:Play()
            tween.Completed:Wait()

            task.wait(2)
        end
    end)
end

local function updateHeader(text)
    if textLabel then textLabel.Text = text or "" end
    if shineLabel then shineLabel.Text = text or "" end
end

local function toggleHeader(enabled)
    if enabled then
        createBillboard()
        startSweepAnimation()
        local inputText = _G.InputHeader or "RynerHUB"
        updateHeader(inputText)
    else
        if sizeConnection then
            sizeConnection:Disconnect()
            sizeConnection = nil
        end
        if billboard then
            billboard:Destroy()
            billboard = nil
            textLabel = nil
            shineLabel = nil
            shineGradient = nil
        end
    end
end

TitleHeaderSection = Tabs.Settings:AddSection("Header Title")
TitleHeaderSection:AddInput({
    Title = "Input Header Name",
    Default = "RynerHUB",
    Placeholder = "Write ur input here...",
    Callback = function(input)
        _G.InputHeader = input
        if textLabel then updateHeader(input) end
    end
})
TitleHeaderSection:AddToggle({
    Title = "Enable Header Name",
    Default = false,
    Callback = function(v)
        toggleHeader(v)
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if getgenv()._G.F_HeaderName == true then
        toggleHeader(true)
    end
end)

-- [[ Configuration ]]
SelectedConfig = ""
CurrentLoaded = "None"
ConfigFolder = _G.ConfigFolder
AutoloadFile = ConfigFolder .. "Autoload.txt"

mainFolderName = ConfigFolder:split("/")[1]
if not isfolder(mainFolderName) then makefolder(mainFolderName) end
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

AutoloadConfig = isfile(AutoloadFile) and readfile(AutoloadFile) or "None"

GetConfigList = function()
    local list = {}
    if isfolder(ConfigFolder) then
        for _, v in pairs(listfiles(ConfigFolder)) do
            if v:sub(-5) == ".json" then
                local name = v:match("([^/\\]+)$"):gsub(".json", "")
                table.insert(list, name)
            end
        end
    end
    return list
end
ConfigSection = Tabs.Config:AddSection("Configuration", true)
ConfigParagraph = ConfigSection:AddParagraph({
    Title = "Config Manager",
    Icon = "settings",
    Content = "Current: " .. CurrentLoaded .. " | Autoload: " .. AutoloadConfig
})
UpdateStatus = function()
    if ConfigParagraph then
        local cleanCurrent = CurrentLoaded:match("([^/\\]+)$") or CurrentLoaded
        local cleanAutoload = AutoloadConfig:match("([^/\\]+)$") or AutoloadConfig
        
        ConfigParagraph:SetContent("Current: " .. cleanCurrent .. " | Autoload: " .. cleanAutoload)
    end
end
task.spawn(function()
    task.wait(1.5)
    if AutoloadConfig ~= "None" then
        IsLoadingConfig = true
        if LoadConfigFromFile(AutoloadConfig) then
            CurrentLoaded = AutoloadConfig
            UpdateStatus()
        end
        task.wait(1) 
        IsLoadingConfig = false 
    end
    ScriptLoaded = true
end)
ConfigSection:AddInput({
    Title = "Config Name",
    Content = "Enter the name for u config",
    Placeholder = "Write ur input here",
    Callback = function(input)
        SelectedConfig = input
    end
})
ConfigDropdown = ConfigSection:AddDropdown({
    Title = "Select Config",
    Content = "Choose from exists configs",
    Options = GetConfigList(),
    Callback = function(option)
        SelectedConfig = option
    end
})
ConfigSection:AddButton({
    Title = "Save Config",
    Callback = function()
        if SelectedConfig and SelectedConfig ~= "" then
            notif("Config ".. SelectedConfig .. " saved")
            SaveConfig(SelectedConfig)
            ConfigDropdown:SetValues(GetConfigList())
        end
    end,
    SubTitle = "Load Config",
    SubCallback = function()
        IsLoadingConfig = true
        if LoadConfigFromFile(SelectedConfig) then
            CurrentLoaded = SelectedConfig
            UpdateStatus()
            notif("Config ".. SelectedConfig .. " loaded")
            ConfigDropdown:SetValues(GetConfigList())
        end
        task.wait(0.5)
        IsLoadingConfig = false
    end 
})
ConfigSection:AddButton({
    Title = "Delete Config",
    Callback = function()
        local path = ConfigFolder .. SelectedConfig .. ".json"
        if isfile(path) then 
            delfile(path) 
            ConfigDropdown:SetValues(GetConfigList())
        end
    end,
    SubTitle = "Set Autoload",
    SubCallback = function()
        if SelectedConfig ~= "" then
            AutoloadConfig = SelectedConfig
            writefile(AutoloadFile, AutoloadConfig)
            UpdateStatus()
            notif("Berhasil set config menjadi autoload")
        else 
            notif("Pilih config terlebih dahulu")
        end
    end
})
ConfigSection:AddButton({
    Title = "Refresh List",
    Callback = function()
        ConfigDropdown:SetValues(GetConfigList())
    end,
    SubTitle = "Clear Autoload",
    SubCallback = function()
        AutoloadConfig = "None"
        if isfile(AutoloadFile) then delfile(AutoloadFile) end
        UpdateStatus()
        notif("Berhasil menghapus autoload config")
    end
})
ConfigSection:AddButton({
    Title = "Reset All Elements to Default",
    Callback = function()
        ScriptLoaded = false
        ConfigData = { _version = CURRENT_VERSION }
        
        if LoadConfigElements then
            LoadConfigElements()
        end
        
        CurrentLoaded = "None"
        UpdateStatus()
        
        task.wait(0.5)
        ScriptLoaded = true
    end
})
ExternalJSONInput = ""
ConfigSection:AddSubSection("Load From External")
ConfigSection:AddInput({
    Title = "External Config JSON",
    Content = "Paste ur raw JSON config here",
    Callback = function(input)
        ExternalJSONInput = input
    end
})
ConfigSection:AddButton({
    Title = "Load External JSON",
    Callback = function()
        if ExternalJSONInput == "" or ExternalJSONInput == nil then
            notif("JSON input kosong!")
            return
        end
        
        local success, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(ExternalJSONInput)
        end)
        
        if success and decoded then
            IsLoadingConfig = true
            ConfigData = decoded
            
            if LoadConfigElements then
                LoadConfigElements()
            end
            
            CurrentLoaded = "External JSON"
            UpdateStatus()
            notif("Berhasil load config dari external JSON")
            
            task.wait(0.5)
            IsLoadingConfig = false
        else
            notif("JSON tidak valid! Cek formatnya")
        end
    end,
    SubTitle = "Export Config",
    SubCallback = function()
        if SelectedConfig == "" or SelectedConfig == nil then
            notif("Pilih dan load dulu, dan select kembali config yang ingin di import!")
            return
        end
        
        local jsonData = game:GetService("HttpService"):JSONEncode(ConfigData)
        setclipboard(jsonData)
        notif("Config " .. SelectedConfig .. " berhasil di-copy ke clipboard!")
      end
    })
end)()
