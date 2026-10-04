local RYNERHub = (function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Player = Players.LocalPlayer

local function SafeGetExecutor()
	if identifyexecutor then
		local ok, v = pcall(identifyexecutor) if ok and v then return tostring(v) end
	end
	if getexecutorname then
		local ok, v = pcall(getexecutorname) if ok and v then return tostring(v) end
	end
	return "Unknown"
end

local function GetISO8601()
	local ok, t = pcall(function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end)
	return ok and t or "1970-01-01T00:00:00Z"
end

local function ColorInt(c)
	return type(c) == "number" and c or 0xB464FF
end

local WebhookConfig = {}
WebhookConfig.__index = WebhookConfig

function WebhookConfig.new(name, cfg)
	cfg = cfg or {}
	local self = setmetatable({}, WebhookConfig)
	self.Name = name or "Config"
	self.Enabled = cfg.Enabled ~= false
	self.URL = cfg.URL or ""
	self.Username = cfg.Username or "RYNER HUB"
	self.AvatarURL = cfg.AvatarURL or ""
	self.SendPlayer = cfg.SendPlayer ~= false
	self.SendGame = cfg.SendGame ~= false
	self.Timestamp = cfg.Timestamp ~= false
	self.RateDelay = cfg.RateDelay or 2
	self.QueueMax = cfg.QueueMax or 50
	self.Color = cfg.Color or 0xB464FF
	self._queue = {}
	self._events = {}
	self._listeners = {}
	self._stats = { sent = 0, failed = 0, dropped = 0 }
	self._lastSent = 0
	self._processing = false
	self._playerCache = nil
	self._gameCache = nil
	self:_StartWorker()
	return self
end

function WebhookConfig:_CanSend()
	if not self.Enabled then return false end
	if self.URL == "" then return false end
	local f = syn and syn.request or (http and http.request) or request or http_request
	return f ~= nil
end

function WebhookConfig:_GetPlayer()
	if self._playerCache then return self._playerCache end
	local ok, r = pcall(function()
		return { Username = Player.Name, DisplayName = Player.DisplayName, UserId = Player.UserId }
	end)
	self._playerCache = ok and r or { Username = "?", DisplayName = "?", UserId = 0 }
	return self._playerCache
end

function WebhookConfig:_GetGame()
	if self._gameCache then return self._gameCache end
	local ok, r = pcall(function()
		return { PlaceId = game.PlaceId, JobId = game.JobId, Executor = SafeGetExecutor() }
	end)
	self._gameCache = ok and r or { PlaceId = 0, JobId = "?", Executor = "?" }
	return self._gameCache
end

function WebhookConfig:_BuildFields(data)
	local fields = {}
	if data then
		for k, v in pairs(data) do
			if type(k) == "string" and type(v) ~= "table" and type(v) ~= "function" then
				table.insert(fields, { name = tostring(k), value = "```" .. tostring(v) .. "```", inline = true })
			end
		end
	end
	if self.SendPlayer then
		local p = self:_GetPlayer()
		table.insert(fields, { name = "Username", value = p.Username .. " (" .. p.DisplayName .. ")", inline = true })
		table.insert(fields, { name = "User ID", value = "```" .. tostring(p.UserId) .. "```", inline = true })
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and url then
			table.insert(fields, { name = "Avatar", value = "[View](" .. url .. ")", inline = true })
		end
	end
	if self.SendGame then
		local g = self:_GetGame()
		table.insert(fields, { name = "Place ID", value = "```" .. tostring(g.PlaceId) .. "```", inline = true })
		table.insert(fields, { name = "Job ID", value = "```" .. tostring(g.JobId):sub(1, 18) .. "...```", inline = true })
		if g.Executor ~= "Unknown" then
			table.insert(fields, { name = "Executor", value = "```" .. g.Executor .. "```", inline = true })
		end
	end
	return fields
end

function WebhookConfig:_DoPost(payload)
	local f = syn and syn.request or (http and http.request) or request or http_request
	if not f then self._stats.failed = self._stats.failed + 1 return false end
	local ok, body = pcall(HttpService.JSONEncode, HttpService, payload)
	if not ok then self._stats.failed = self._stats.failed + 1 return false end
	local s, r = pcall(function()
		return f({ Url = self.URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
	end)
	if not s then self._stats.failed = self._stats.failed + 1 return false end
	local code = r and (r.StatusCode or r.status_code)
	if code and code >= 400 then self._stats.failed = self._stats.failed + 1 return false end
	self._stats.sent = self._stats.sent + 1
	return true
end

function WebhookConfig:_Enqueue(payload)
	if #self._queue >= self.QueueMax then self._stats.dropped = self._stats.dropped + 1 return false end
	table.insert(self._queue, payload)
	return true
end

function WebhookConfig:_StartWorker()
	task.spawn(function()
		while true do
			task.wait(0.5)
			if #self._queue > 0 and not self._processing then
				if (tick() - self._lastSent) >= self.RateDelay then
					self._processing = true
					local item = table.remove(self._queue, 1)
					if item then self:_DoPost(item) end
					self._lastSent = tick()
					self._processing = false
				end
			end
		end
	end)
end

function WebhookConfig:_FireListeners(event, data)
	local list = self._listeners[event]
	if list then for _, cb in ipairs(list) do pcall(cb, data) end end
	local any = self._listeners["*"]
	if any then for _, cb in ipairs(any) do pcall(cb, event, data) end end
end

function WebhookConfig:_MakePayload(embed)
	local p = { username = self.Username, embeds = { embed } }
	if self.AvatarURL ~= "" then p.avatar_url = self.AvatarURL end
	return p
end

function WebhookConfig:RegisterEvent(name, tpl)
	tpl = tpl or {}
	self._events[name] = { title = tpl.title or tpl.Title or name, color = tpl.color or tpl.Color or self.Color }
end

function WebhookConfig:On(event, cb)
	if not self._listeners[event] then self._listeners[event] = {} end
	table.insert(self._listeners[event], cb)
end

function WebhookConfig:Send(event, data)
	if not self:_CanSend() then return false end
	self:_FireListeners(event, data)
	local tpl = self._events[event] or { title = tostring(event), color = self.Color }
	local embed = { title = tpl.title, color = ColorInt(tpl.color), fields = self:_BuildFields(data) }
	if self.Timestamp then embed.timestamp = GetISO8601() end
	return self:_Enqueue(self:_MakePayload(embed))
end

function WebhookConfig:SendEmbed(tbl)
	if not self:_CanSend() then return false end
	local embed = {
		title = tbl.Title or tbl.title or "Embed",
		description = tbl.Description or tbl.description or "",
		color = ColorInt(tbl.Color or tbl.color or self.Color),
		fields = tbl.Fields or tbl.fields or {},
	}
	if tbl.Footer or tbl.footer then embed.footer = { text = tbl.Footer or tbl.footer } end
	if tbl.Author or tbl.author then embed.author = { name = tbl.Author or tbl.author } end
	if tbl.Thumbnail or tbl.thumbnail then embed.thumbnail = { url = tbl.Thumbnail or tbl.thumbnail } end
	if tbl.Image or tbl.image then embed.image = { url = tbl.Image or tbl.image } end
	if self.Timestamp then embed.timestamp = GetISO8601() end
	return self:_Enqueue(self:_MakePayload(embed))
end

function WebhookConfig:SendEmbeds(list)
	if not self:_CanSend() then return false end
	local embeds = {}
	for i, tbl in ipairs(list) do
		if i > 10 then break end
		local e = {
			title = tbl.Title or tbl.title or ("Embed " .. i),
			description = tbl.Description or tbl.description or "",
			color = ColorInt(tbl.Color or tbl.color or self.Color),
			fields = tbl.Fields or tbl.fields or {},
		}
		if self.Timestamp then e.timestamp = GetISO8601() end
		table.insert(embeds, e)
	end
	local p = { username = self.Username, embeds = embeds }
	if self.AvatarURL ~= "" then p.avatar_url = self.AvatarURL end
	return self:_Enqueue(p)
end

function WebhookConfig:SendRaw(payload)
	if not self:_CanSend() then return false end
	return self:_Enqueue(payload)
end

function WebhookConfig:SendContent(text)
	if not self:_CanSend() then return false end
	return self:_Enqueue({ username = self.Username, content = tostring(text) })
end

function WebhookConfig:Flush()
	task.spawn(function()
		while #self._queue > 0 do
			local item = table.remove(self._queue, 1)
			if item then self:_DoPost(item) end
			task.wait(0.5)
		end
	end)
end

function WebhookConfig:ClearQueue()
	self._stats.dropped = self._stats.dropped + #self._queue
	self._queue = {}
end

function WebhookConfig:GetStats()
	return { sent = self._stats.sent, failed = self._stats.failed, queued = #self._queue, dropped = self._stats.dropped }
end

function WebhookConfig:GetPlayerInfo() return self:_GetPlayer() end
function WebhookConfig:GetGameInfo() return self:_GetGame() end

function WebhookConfig:Configure(cfg)
	for k, v in pairs(cfg) do self[k] = v end
end

function WebhookConfig:SetEnabled(b) self.Enabled = b == true end
function WebhookConfig:SetURL(u) self.URL = u or "" end

local RYNERWebhook = {}
RYNERWebhook._configs = {}

function RYNERWebhook:NewConfig(name, cfg)
	local c = WebhookConfig.new(name, cfg)
	self._configs[name] = c
	return c
end

function RYNERWebhook:Get(name)
	return self._configs[name]
end

function RYNERWebhook:AttachToLibrary(lib, configNameOrObj)
	local cfg = type(configNameOrObj) == "string" and self._configs[configNameOrObj] or configNameOrObj
	if not cfg or not lib then return end
	if lib.SetNotification then
		local orig = lib.SetNotification
		lib.SetNotification = function(libSelf, c)
			local text = c.Content or c[1] or ""
			if text ~= "" then cfg:Send("Notification", { message = text }) end
			return orig(libSelf, c)
		end
	end
end

-- Anti-AFK (dipertahankan dari script lama)
Player.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- ============================================================
--  SerhiiUI (library UI baru, di-embed supaya script tetap 1 file)
-- ============================================================

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
		BackgroundTransparency = 1, -- transparan: kotak gelap di belakangnya yang terlihat
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
		local icon = makeIcon(config.Icon, UDim2.new(0, 20, 0, 20), "Accent")
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

	for _, value in ipairs(values) do
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

	if config.Icon and config.Icon ~= "" then
		local winIcon = makeIcon(config.Icon, UDim2.new(0, config.IconSize or 22, 0, config.IconSize or 22), "Text")
		winIcon.LayoutOrder = 1
		winIcon.Parent = titleRow
		Window.IconImage = winIcon
	end

	New("Frame", {
		Size = UDim2.new(1, -32, 1, 0),
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
		Size = UDim2.new(0, 100, 1, 0),
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

	-- Floating reopen button (shown while minimized; also reopened via key).
	local OPEN_BTN_SIZE = 58 -- ukuran logo (px), ubah di sini kalau mau lebih besar/kecil
	local openButton = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(0, OPEN_BTN_SIZE, 0, OPEN_BTN_SIZE),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Parent = ScreenGui,
	})
	local obIconName = (config.Icon and config.Icon ~= "" and config.Icon) or "layout-grid"
	-- Logo asset (rbxassetid) dipakai apa adanya tanpa tint; icon Lucide tetap diwarnai Accent
	local obIsAsset = typeof(obIconName) == "string" and obIconName:match("^rbxassetid://") ~= nil
	local obIcon = makeIcon(obIconName, UDim2.new(1, 0, 1, 0), (not obIsAsset) and "Accent" or nil)
	obIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	obIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	obIcon.Parent = openButton
	dragify(openButton)

	-- Animations use Size only (no GroupTransparency) to keep icons crisp.
	local collapsed = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)

	function Window:Minimize()
		Window.Minimized = true
		tween(main, 0.3, { Size = collapsed }, Enum.EasingStyle.Quint)
		task.delay(0.31, function()
			if Window.Minimized then
				main.Visible = false
				openButton.Visible = true
			end
		end)
	end

	function Window:Open()
		Window.Minimized = false
		openButton.Visible = false
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

	connect(openButton.MouseButton1Click, function()
		Window:Open()
	end)

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

-- =====================================================================
--  RYNER HUB UI  (tampilan SerhiiUI, tema Plum #a855f7)
--  API lama (AddTab / AddSection / AddToggle / ...) tetap sama, jadi semua
--  kode fitur di bawah tidak perlu diubah. Yang berubah hanya tampilannya.
-- =====================================================================
local RYNERHub_Library = {}
RYNERHub_Library.Unloaded = false
RYNERHub_Library.ControlList = {}   -- urutan pembuatan: { key=, kind=, get=, set= }
RYNERHub_Library.ControlMap  = {}   -- key -> entry
RYNERHub_Library.Loading     = false -- true saat Load Config (notif di-mute)
RYNERHub_Library.SerhiiUI = SerhiiUI

local PLUM = Color3.fromHex("#a855f7")

SerhiiUI:CreateTheme("Plum", {
	Background = Color3.fromHex("#130c1c"),
	Sidebar = Color3.fromHex("#0e0915"),
	Element = Color3.fromHex("#1d1229"),
	ElementHover = Color3.fromHex("#2a1a3b"),
	Stroke = Color3.fromHex("#c084fc"),
	StrokeTransparency = 0.88,
	Text = Color3.fromHex("#faf5ff"),
	SubText = Color3.fromHex("#b69bd4"),
	Accent = PLUM,
	AccentText = Color3.fromHex("#ffffff"),
	ToggleOff = Color3.fromHex("#3d2a55"),
	TabActive = Color3.fromHex("#261739"),
	Notification = Color3.fromHex("#180f23"),
})
SerhiiUI:SetTheme("Plum")

-- ---------------------------------------------------------------------
-- Notifikasi
-- ---------------------------------------------------------------------
function RYNERHub_Library:SetNotification(Config)
	if type(Config) == "string" then Config = { Content = Config } end
	Config = Config or {}
	local text = tostring(Config.Content or Config[1] or "")
	local delay = tonumber(Config.Delay or Config[6]) or 3
	pcall(function()
		SerhiiUI:Notify({ Title = "RYNER HUB", Content = text, Duration = delay })
	end)
	return { Close = function() end }
end

-- ---------------------------------------------------------------------
-- Elemen di dalam Section (API lama -> elemen SerhiiUI)
-- ---------------------------------------------------------------------
local function MakeSectionFuncs(section, path, noSave)
	local SecFuncs = {}
	local order = 0

	-- Daftarkan kontrol ke registry supaya ikut tersimpan / ter-load di Config
	local function register(kind, name, getter, setter)
		if noSave then return end
		local base = tostring(path or "") .. "/" .. tostring(name)
		local key, n = base, 1
		while RYNERHub_Library.ControlMap[key] do
			n = n + 1
			key = base .. "#" .. n
		end
		local entry = { key = key, kind = kind, get = getter, set = setter }
		RYNERHub_Library.ControlMap[key] = entry
		table.insert(RYNERHub_Library.ControlList, entry)
	end

	-- beri LayoutOrder unik supaya urutan elemen tetap sesuai urutan dibuat
	-- (dibutuhkan juga saat dropdown dibangun ulang lewat SetValues)
	local function place(obj)
		order = order + 1
		if obj and obj.Object then obj.Object.LayoutOrder = order end
		return order
	end

	function SecFuncs:AddButton(c)
		local name = c[1] or c.Name or "Button"
		local desc = c[2] or c.Description or c.Content
		local cb = c[3] or c.Callback or function() end
		local obj = section:Button({ Title = name, Desc = desc, Callback = cb })
		place(obj)
		return { Button = obj.Object, SetText = function(t) obj:SetTitle(t) end }
	end

	function SecFuncs:AddToggle(c)
		local name = c[1] or c.Name or "Toggle"
		local default = c[2] or c.Default or false
		local cb = c[3] or c.Callback or function() end
		local desc = c.Content or c.Description or c[4]
		local obj = section:Toggle({ Title = name, Desc = desc, Default = default, Callback = cb })
		place(obj)
		register("toggle", name, function() return obj:Get() and true or false end, function(v) obj:Set(v and true or false) end)
		return {
			Toggle = obj.Object,
			Set = function(v) obj:Set(v) end,
			Get = function() return obj:Get() end,
		}
	end

	function SecFuncs:AddSlider(c)
		local name = c[1] or c.Name or "Slider"
		local min = c[2] or c.Min or 0
		local max = c[3] or c.Max or 100
		local default = c[4] or c.Default or min
		local cb = c[5] or c.Callback or function() end
		local obj = section:Slider({
			Title = name,
			Value = { Min = min, Max = max, Default = default },
			Step = c.Increment or 1,
			Callback = cb,
		})
		place(obj)
		register("slider", name, function() return obj:Get() end, function(v) obj:Set(tonumber(v) or default) end)
		return {
			Slider = obj.Object,
			Set = function(v) obj:Set(v) end,
			Get = function() return obj:Get() end,
		}
	end

	function SecFuncs:AddInput(c)
		local name = c[1] or c.Name or "Input"
		local placeholder = c[2] or c.Placeholder or "Enter text..."
		local default = c[3] or c.Default or ""
		local cb = c[4] or c.Callback or function() end
		local obj = section:Input({ Title = name, Placeholder = placeholder, Default = default, Callback = cb })
		place(obj)
		register("input", name, function() return tostring(obj:Get()) end, function(v)
			obj:Set(tostring(v))
			task.spawn(cb, tostring(v))
		end)
		return {
			Input = obj.Object,
			Set = function(t) obj:Set(t) end,
			Get = function() return obj:Get() end,
		}
	end

	function SecFuncs:AddDropdown(c)
		local name = c[1] or c.Name or "Dropdown"
		local values = c[2] or c.Options or {}
		local default = c[3] or c.Default
		local cb = c[4] or c.Callback or function() end
		if type(default) == "table" then default = default[1] end

		local current = default
		local slot, obj

		local function build(list, selected)
			local d = section:Dropdown({
				Title = name,
				Values = list,
				Default = selected,
				Callback = function(v)
					current = v
					cb(v)
				end,
			})
			if slot then d.Object.LayoutOrder = slot else slot = place(d) end
			return d
		end
		obj = build(values, default)

		local Ret = { Dropdown = obj.Object }

		-- Ganti daftar opsi (dipakai Config -> Refresh List). Dropdown dibangun
		-- ulang di posisi yang sama; pilihan lama dipertahankan kalau masih ada.
		Ret.SetValues = function(a, b)
			local list = (a == Ret) and b or a
			values = list or {}
			local keep = nil
			for _, v in ipairs(values) do
				if v == current then keep = v break end
			end
			pcall(function() obj.Object:Destroy() end)
			obj = build(values, keep)
			Ret.Dropdown = obj.Object
			current = keep
		end

		Ret.Set = function(v)
			if type(v) == "table" then v = v[1] end
			if v == nil then return end
			current = v
			obj:Set(v)
			task.spawn(cb, v)
		end
		Ret.Get = function() return { current } end
		register("dropdown", name, function() return current end, function(v) Ret.Set(v) end)
		return Ret
	end

	function SecFuncs:AddParagraph(c)
		if type(c) == "string" then c = { c } end
		local title = c[1] or c.Title or "Paragraph"
		local text = c[2] or c.Text or c.Desc or ""
		local obj = section:Paragraph({ Title = title, Desc = text })
		place(obj)
		return { Paragraph = obj.Object, Set = function(t) obj:SetDesc(t) end }
	end

	function SecFuncs:AddSeparator()
		local obj = section:Divider()
		place(obj)
		return { Separator = obj.Object }
	end
	SecFuncs.AddLine = SecFuncs.AddSeparator

	return SecFuncs
end

-- ---------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------
-- Ukuran menyesuaikan layar (HP landscape ~640x360 tetap muat).
local function ComputeSize()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local w = math.clamp(vp.X - 40, 420, 560)
	local h = math.clamp(vp.Y - 70, 270, 380)
	return UDim2.fromOffset(w, h), (w < 500 and 124 or 150)
end

function RYNERHub_Library:CreateWindow(Config)
	Config = Config or {}
	local Title = Config[1] or Config.Title or "RYNER HUB"
	local Desc = Config[2] or Config.Description or Config.Desc or ""
	local Keybind = Config.Keybind or Enum.KeyCode.RightControl
	local Icon = Config.Icon or ""
	local Tags = Config.Tags or {}

	-- subjudul = deskripsi + tag, dipisah titik
	local sub = Desc
	for _, t in ipairs(Tags) do
		sub = (sub ~= "" and (sub .. "  •  ") or "") .. tostring(t)
	end

	local autoSize, autoSide = ComputeSize()
	local SizeUi = Config.SizeUi or autoSize

	-- Kalau Config.KeySystem diisi, SerhiiUI menampilkan kartu key LEBIH DULU
	-- dan baru membuat window fitur setelah key valid. Return nil kalau dibatalkan.
	local raw = SerhiiUI:CreateWindow({
		Title = Title,
		SubTitle = sub ~= "" and sub or nil,
		Icon = Icon,
		Size = SizeUi,
		SidebarWidth = Config.SidebarWidth or autoSide,
		ToggleKey = Keybind,
		KeySystem = Config.KeySystem,
	})
	if not raw then return nil end

	-- Tombol maximize bawaan SerhiiUI memanggil Window:ToggleFullscreen() yang
	-- belum ada di library -> definisikan di sini supaya tidak error.
	if not raw.ToggleFullscreen then
		local main = raw.Root and raw.Root.Parent
		raw.ToggleFullscreen = function()
			if not main or not main.Parent then return end
			local goFull = (main.Size == SizeUi)
			TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Size = goFull and UDim2.new(1, -40, 1, -40) or SizeUi,
				Position = UDim2.new(0.5, 0, 0.5, 0),
			}):Play()
		end
	end

	local Funcs = { Raw = raw }

	function Funcs:AddTab(c)
		if type(c) == "string" then c = { c } end
		local name = c[1] or c.Name or c.Title or "Tab"
		local icon = c[2] or c.Icon or ""
		local tab = raw:Tab({ Title = name, Icon = icon })
		local TabFuncs = { Tab = tab, Select = function() tab:Select() end }

		function TabFuncs:AddSection(sc)
			if type(sc) == "string" then sc = { sc } end
			sc = sc or {}
			local secName = sc[1] or sc.Name or sc.Title or "Section"
			local section = tab:Section({ Title = secName, Opened = sc.Opened ~= false })
			return MakeSectionFuncs(section, tostring(name) .. "/" .. tostring(secName), tostring(name) == "Config")
		end

		return TabFuncs
	end

	Funcs.SetOpen = function(open)
		if open then raw:Open() else raw:Minimize() end
	end
	Funcs.Toggle = function()
		if raw.Minimized then raw:Open() else raw:Minimize() end
	end
	Funcs.IsOpen = function() return (not raw.Minimized) and (not raw.Destroyed) end
	Funcs.IsAlive = function() return not raw.Destroyed end
	Funcs.Destroy = function() pcall(function() raw:Destroy() end) end

	return Funcs
end


return {
	Library = RYNERHub_Library,
	Webhook = RYNERWebhook,
}
end)()

local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local Workspace         = game:GetService("Workspace")
local GuiService        = game:GetService("GuiService")
local Lighting          = game:GetService("Lighting")
local Camera            = Workspace.CurrentCamera
local LP                = Players.LocalPlayer
local PlayerGui         = LP:WaitForChild("PlayerGui")

local VIM = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local LOGO_ICON = "rbxassetid://70543929280917"
local Lib = RYNERHub.Library

-- ================= RYNER HUB KEY SYSTEM =================
-- Urutan: cek key (getgenv().Key / file tersimpan) -> kalau belum valid,
-- tampil kartu Key System (SerhiiUI, tema Plum) -> baru window fitur dibuat.
local KeyCfg = nil
do
    local API = "https://qnvoipytnavzgmwfqkms.supabase.co/functions/v1/gateway/check"
    local GET_KEY_URL = "https://rynerweb.vercel.app"
    local KEY_FILE = "RynerHub_Key.txt"

    local okId, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if not okId or type(hwid) ~= "string" or #hwid < 4 then
        warn("[RYNER HUB] Gagal membaca ID perangkat.")
        return
    end

    local function clean(k)
        return (tostring(k or ""):gsub("%s+", ""))
    end

    local function check(k)
        k = clean(k)
        if not k:match("^RYNER%-HUB%-%w+$") then return false end
        local ok, res = pcall(function()
            return game:HttpGet(API .. "?key=" .. HttpService:UrlEncode(k) .. "&hwid=" .. HttpService:UrlEncode(hwid))
        end)
        return ok and res == "valid"
    end

    local function saveKey(k)
        if writefile then pcall(writefile, KEY_FILE, k) end
    end

    -- Key dari getgenv().Key atau dari file yang tersimpan
    local candidate = getgenv and getgenv().Key or nil
    if not candidate and readfile and isfile then
        local okf, exists = pcall(isfile, KEY_FILE)
        if okf and exists then
            local okr, c = pcall(readfile, KEY_FILE)
            if okr then candidate = c end
        end
    end

    local verified = candidate and check(candidate) or false
    if verified then saveKey(clean(candidate)) end

    -- Belum valid -> siapkan konfigurasi kartu Key System
    if not verified then
        KeyCfg = {
            Title = "RYNER HUB  •  Key System",
            Note = "Tekan Get Key, selesaikan checkpoint di website, lalu tempel key kamu di kolom bawah.",
            GetKey = GET_KEY_URL,
            SaveKey = false, -- penyimpanan key ditangani sendiri lewat saveKey()
            Validator = function(k)
                k = clean(k)
                if k == "" then return false end
                if check(k) then
                    saveKey(k)
                    return true
                end
                return false
            end,
        }
    end
end
-- ================= AKHIR KEY SYSTEM =================

local ExecutorName = "Unknown"
pcall(function()
    if identifyexecutor then ExecutorName = identifyexecutor()
    elseif getexecutorname then ExecutorName = getexecutorname() end
end)

-- Kalau KeyCfg ada, kartu key tampil dulu di dalam CreateWindow dan baru
-- setelah key valid window fitur muncul. Key dibatalkan -> Window = nil.
local createOk, Window = pcall(function()
    return Lib:CreateWindow({
        Title = "RYNER HUB",
        Desc = "Still High",
        Icon = LOGO_ICON,
        Keybind = Enum.KeyCode.RightControl,
        Tags = { "v1.0", "VD", "Executor: " .. ExecutorName },
        KeySystem = KeyCfg,
    })
end)
if not createOk then return warn("[Ryner] CreateWindow error: " .. tostring(Window)) end
if not Window then return end


task.wait(1)

local function notif(txt, dur)
    if Lib.Loading then return end
    pcall(function()
        Lib:SetNotification({ Content = tostring(txt), Delay = dur or 3 })
    end)
end

local function GetRoot()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function IsKiller(p)
    return p and p.Team and p.Team.Name == "Killer"
end

local function IsDowned(char)
    return char and (char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true)
end

pcall(function()
    if getconnections then
        for _, c in pairs(getconnections(LP.Idled)) do
            if c.Disable then c:Disable() end
        end
    end
end)

local TabInfo = Window:AddTab({"Info", "info"})
local SecServer = TabInfo:AddSection({"Server"})

SecServer:AddButton({"Return to Lobby", "Balik ke lobby", function()
    pcall(function()
        ReplicatedStorage.Remotes.Game.loadcharevent:FireServer()
    end)
    notif("Returning to lobby...")
end})

SecServer:AddButton({"Rejoin Server", "Rejoin server yang sama", function()
    notif("Rejoining server...", 2)
    task.delay(1, function()
        TeleportService:Teleport(game.PlaceId)
    end)
end})

SecServer:AddButton({"Server Hop", "Cari server random", function()
    notif("Finding new server...", 2)
    local success, result = pcall(function()
        return game:HttpGet(string.format(
            "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
            game.PlaceId
        ))
    end)
    if not success then notif("Error API!"); return end
    local ok2, serverList = pcall(function() return HttpService:JSONDecode(result) end)
    if not ok2 or not serverList or not serverList.data then
        notif("Gagal parse server list!"); return
    end
    local servers = {}
    for _, server in ipairs(serverList.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            table.insert(servers, server)
        end
    end
    if #servers > 0 then
        local pick = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LP)
    else
        notif("Gak ada server tersedia!")
    end
end})

SecServer:AddButton({"Server Hop (Small)", "Cari server isi ≤ 5", function()
    notif("Searching small server...", 2)
    local success, result = pcall(function()
        return game:HttpGet(string.format(
            "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
            game.PlaceId
        ))
    end)
    if not success then notif("API Error!"); return end
    local ok2, serverList = pcall(function() return HttpService:JSONDecode(result) end)
    if not ok2 or not serverList or not serverList.data then
        notif("Gagal parse server list!"); return
    end
    local target = nil
    for _, server in ipairs(serverList.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            if server.playing <= 5 then target = server; break end
        end
    end
    if target then
        notif("Found server with " .. target.playing .. " players!", 2)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LP)
    else
        notif("Gak ada small server!")
    end
end})

local TabSurvivor = Window:AddTab({"Survivor", "shield"})

local ParryCfg = {
    AutoParry = false, ParrySafety = true, ParryAggressive = true,    
    ParryCircle = true, ParryRadius = 6, ParryFace = 1, IgnoredSkills = {},
}
local ParryState = { Cooldown = false, CooldownThread = nil, Adornment = nil, ResetTimer = nil }
local ParryAttached = {}
local DynamicRadius = { Current = 6, LastParryAttempt = 0, LastSuccessfulParry = 0 }

local VALID_PARRY_IDS = {
    ["122812055447896"]="Veil lunge",["133963973694098"]="Mayers Basic",
    ["117042998468241"]="Mayers lunge",["135002183282873"]="cure lunge",
    ["121216847022485"]="cure Basic",["132817836308238"]="Jeff Basic",
    ["129784271201071"]="Jeff lunge",["82666958311998"]="Jeff Frenzy",
    ["78432063483146"]="Abyssal Basic",["118907603246885"]="Abyssal lunge",
    ["139369275981139"]="Jason Basic",["110355011987939"]="Jason lunge",
    ["111920872708571"]="Masked Basic",["105374834496520"]="Masked lunge",
    ["138720291317243"]="Masked Tony",["106871536134254"]="Masked Alex",
    ["130593238885843"]="Masked Cobra",["115244153053858"]="Masked Cobra lunge",
    ["74968262036854"]="Hidden Basic",["113255068724446"]="Hidden lunge",
    ["98163597193511"]="Hidden S1",["80411309607666"]="Abyssal S1",
}

local function SwitchRadius()
    local n = (DynamicRadius.Current == 6) and 7 or 6
    DynamicRadius.Current = n
    ParryCfg.ParryRadius = n
end

local function IsSafeToParry(char)
    if not ParryCfg.ParrySafety then return true end
    if not char then return false end
    local obj = char:FindFirstChild("CheckInterractable")
    if obj then
        if obj:GetAttribute("isVaulting")==true then return false end
        if obj:GetAttribute("isRepairing")==true then return false end
        if obj:GetAttribute("isUnhooking")==true then return false end
        if obj:GetAttribute("isHealing")==true then return false end
        if obj:GetAttribute("isSliding")==true then return false end
    end
    return true
end

local function tapMobileParryButton()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    local survivorMob = pg:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")
    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    elseif VIM then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

local function AutoStopRepair()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local interact = char:FindFirstChild("CheckInterractable")
        if not interact then return end
        if interact:GetAttribute("isRepairing") ~= true then return end
        local repairEvent = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Generator")
            and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
        if repairEvent then
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in pairs(map:GetDescendants()) do
                    if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                        if obj:GetAttribute("IsRepairing") == true then
                            repairEvent:FireServer(obj, false)
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function ExecuteParry()
    if ParryState.Cooldown then return end
    AutoStopRepair()
    task.wait(0.01)
    DynamicRadius.LastParryAttempt = tick()
    pcall(function()
        local parryRemote = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Items")
            and ReplicatedStorage.Remotes.Items:FindFirstChild("Parrying Dagger")
            and ReplicatedStorage.Remotes.Items["Parrying Dagger"]:FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

local function ListenToParryResult()
    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5)
            and remotes.Items:WaitForChild("Parrying Dagger", 5)
        local result = dagger and dagger:FindFirstChild("parryResult", 5)
        if result then
            result.OnClientEvent:Connect(function(arg1, arg2)
                DynamicRadius.LastSuccessfulParry = tick()
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                ParryState.Cooldown = true
                if ParryState.CooldownThread then task.cancel(ParryState.CooldownThread) end
                ParryState.CooldownThread = task.delay(cdDur, function()
                    ParryState.Cooldown = false
                end)
                if ParryState.ResetTimer then task.cancel(ParryState.ResetTimer) end
                ParryState.ResetTimer = task.delay(10, function()
                    if ParryCfg.AutoParry then
                        ParryCfg.AutoParry = false
                        task.wait(0.1)
                        ParryCfg.AutoParry = true
                    end
                    ParryState.ResetTimer = nil
                end)
            end)
        end
    end)
end
ListenToParryResult()

local function AttachParrySensor(kChar)
    if not kChar or ParryAttached[kChar] then return end
    ParryAttached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid") or kChar:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            ParryAttached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then ParryAttached[kChar] = nil end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        if not ParryCfg.AutoParry or ParryState.Cooldown then return end
        if ParryCfg.IgnoredSkills and ParryCfg.IgnoredSkills[attackName] then return end
        local myChar = LP.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        local startDistance = (myHRP.Position - kHRP.Position).Magnitude

        if ParryCfg.ParryAggressive then
            local aggroR, detectR = 12, ParryCfg.ParryRadius + 5
            if startDistance > detectR then return end
            if startDistance <= aggroR then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or ParryState.Cooldown
                    or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    if (myHRP.Position - kHRP.Position).Magnitude <= aggroR then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > ParryCfg.ParryRadius then return end
            local myFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myFlat - kFlat
            if flatDelta.Magnitude > 0 then
                local dir = flatDelta.Unit
                local kLook = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                if kLook:Dot(dir) < ParryCfg.ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

local function TryAttach(p)
    if p ~= LP and IsKiller(p) and p.Character then
        AttachParrySensor(p.Character)
    end
end
local function SetupPlayer(p)
    if p == LP then return end
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

task.spawn(function()
    while true do
        task.wait(8)
        if not ParryCfg.AutoParry then continue end
        local now = tick()
        if DynamicRadius.LastParryAttempt > 0
        and (now - DynamicRadius.LastParryAttempt) > 10
        and (now - DynamicRadius.LastSuccessfulParry) > 10
        and not ParryState.Cooldown then
            SwitchRadius()
            DynamicRadius.LastParryAttempt = now
            DynamicRadius.LastSuccessfulParry = now
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if ParryCfg.ParryCircle and ParryCfg.AutoParry and hrp then
        if not ParryState.Adornment or ParryState.Adornment.Parent ~= hrp then
            if ParryState.Adornment then ParryState.Adornment:Destroy() end
            ParryState.Adornment = Instance.new("CylinderHandleAdornment")
            ParryState.Adornment.Name = "AutoParryCircleESP"
            ParryState.Adornment.Height = 0.05
            ParryState.Adornment.Transparency = 0.3
            ParryState.Adornment.Adornee = hrp
            ParryState.Adornment.Parent = hrp
            ParryState.Adornment.ZIndex = 0
            ParryState.Adornment.AlwaysOnTop = false
        end
        local cR = ParryCfg.ParryRadius
        ParryState.Adornment.Radius = cR
        ParryState.Adornment.InnerRadius = math.max(0.1, cR - 0.15)
        ParryState.Adornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
        if ParryState.Cooldown then
            ParryState.Adornment.Color3 = Color3.fromRGB(255, 128, 0)
        elseif ParryCfg.ParryAggressive then
            ParryState.Adornment.Color3 = Color3.fromRGB(255, 0, 0)
        else
            ParryState.Adornment.Color3 = Color3.fromRGB(0, 255, 255)
        end
    elseif ParryState.Adornment then
        ParryState.Adornment:Destroy()
        ParryState.Adornment = nil
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local char = LP.Character
        if not char then
            if ParryCfg.AutoParry then
                ParryCfg.ParrySafety = false
                ParryCfg.ParryAggressive = false
            end
            continue
        end
        local interact = char:FindFirstChild("CheckInterractable")
        local isRepairing = interact and interact:GetAttribute("isRepairing") == true
        if ParryCfg.AutoParry then
            ParryCfg.ParrySafety = not isRepairing
            ParryCfg.ParryAggressive = true
        else
            ParryCfg.ParrySafety = false
            ParryCfg.ParryAggressive = false
        end
    end
end)

-- UI Auto Parry
local SecParry = TabSurvivor:AddSection({"Auto Parry"})

SecParry:AddToggle({"Auto Parry", false, function(v)
    ParryCfg.AutoParry = v
    if not v then
        ParryCfg.ParrySafety = false
        ParryCfg.ParryAggressive = false
    end
    notif("Auto Parry: " .. (v and "ON" or "OFF"))
end, "Parry otomatis saat killer menyerang"})

SecParry:AddToggle({"Radius Parry (Visual)", true, function(v)
    ParryCfg.ParryCircle = v
end, "Tampilkan lingkaran radius parry"})

SecParry:AddSlider({"Radius Parry (studs)", 1, 20, 6, function(v)
    ParryCfg.ParryRadius = v
    if DynamicRadius then DynamicRadius.Current = v end
end})

SecParry:AddSlider({"Sensitivitas Arah (Aim)", 1, 20, 10, function(v)
    ParryCfg.ParryFace = v / 10
end})


-- HIDE NAME --
Config = Config or {}
Config.Misc_FakeName = false
State = State or {}
State.SpooferConns = State.SpooferConns or {}

function enableSpoofer()
    if not Config.Misc_FakeName then return end
    local PlayerGui2 = LP:FindFirstChild("PlayerGui")
    if not PlayerGui2 then return end

    local function applySpooferToObj(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local function updateText()
                if not Config.Misc_FakeName then return end
                local ct = obj.Text
                local ch = false

                if not obj:GetAttribute("OriginalText") then
                    obj:SetAttribute("OriginalText", ct)
                end
                if not obj:GetAttribute("OriginalFontFace") then
                    obj:SetAttribute("OriginalFontFace", obj.FontFace)
                end
                if not obj:GetAttribute("OriginalStrokeTransparency") then
                    obj:SetAttribute("OriginalStrokeTransparency", obj.TextStrokeTransparency)
                end
                if not obj:GetAttribute("OriginalStrokeColor") then
                    obj:SetAttribute("OriginalStrokeColor", obj.TextStrokeColor3)
                end

                for _, pl in ipairs(Players:GetPlayers()) do
                    if string.find(ct, pl.Name) or string.find(ct, pl.DisplayName) then
                        ct = string.gsub(ct, pl.Name, "REYNER HUB")
                        ct = string.gsub(ct, pl.DisplayName, "REYNER HUB")
                        ch = true
                    end
                end

                if ch then
                    if obj.Text ~= ct then obj.Text = ct end
                    local orig = obj:GetAttribute("OriginalFontFace")
                    if orig then
                        obj.FontFace = Font.new(orig.Family, Enum.FontWeight.Bold, orig.Style)
                    end
                    obj.TextStrokeTransparency = 0.5
                    obj.TextStrokeColor3 = obj.TextColor3
                else
                    local orig = obj:GetAttribute("OriginalFontFace")
                    if orig and obj.FontFace ~= orig then obj.FontFace = orig end
                    local ost = obj:GetAttribute("OriginalStrokeTransparency")
                    if ost then obj.TextStrokeTransparency = ost end
                    local osc = obj:GetAttribute("OriginalStrokeColor")
                    if osc then obj.TextStrokeColor3 = osc end
                end
            end

            updateText()
            local conn = obj:GetPropertyChangedSignal("Text"):Connect(updateText)
            table.insert(State.SpooferConns, conn)

        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local function updateImage()
                if not Config.Misc_FakeName then return end
                local ci = obj.Image
                local ch = false
                for _, pl in ipairs(Players:GetPlayers()) do
                    if string.find(ci, tostring(pl.UserId)) then
                        if not obj:GetAttribute("OriginalImage") then
                            obj:SetAttribute("OriginalImage", ci)
                        end
                        ch = true
                        break
                    end
                end
                if ch and obj.Image ~= "rbxassetid://70543929280917" then
                    obj.Image = "rbxassetid://70543929280917"
                end
            end

            updateImage()
            local conn = obj:GetPropertyChangedSignal("Image"):Connect(updateImage)
            table.insert(State.SpooferConns, conn)
        end
    end

    for _, obj in ipairs(PlayerGui2:GetDescendants()) do
        applySpooferToObj(obj)
    end

    local conn = PlayerGui2.DescendantAdded:Connect(function(obj)
        task.defer(function() applySpooferToObj(obj) end)
    end)
    table.insert(State.SpooferConns, conn)
end

function disableSpoofer()
    for _, conn in ipairs(State.SpooferConns) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(State.SpooferConns)

    local PlayerGui2 = LP:FindFirstChild("PlayerGui")
    if PlayerGui2 then
        for _, obj in ipairs(PlayerGui2:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local ot = obj:GetAttribute("OriginalText")
                if ot then
                    obj.Text = ot
                    obj:SetAttribute("OriginalText", nil)
                end
                local of = obj:GetAttribute("OriginalFontFace")
                if of then
                    obj.FontFace = of
                    obj:SetAttribute("OriginalFontFace", nil)
                end
                local ost = obj:GetAttribute("OriginalStrokeTransparency")
                if ost then
                    obj.TextStrokeTransparency = ost
                    obj:SetAttribute("OriginalStrokeTransparency", nil)
                end
                local osc = obj:GetAttribute("OriginalStrokeColor")
                if osc then
                    obj.TextStrokeColor3 = osc
                    obj:SetAttribute("OriginalStrokeColor", nil)
                end

            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                local oi = obj:GetAttribute("OriginalImage")
                if oi then
                    obj.Image = oi
                    obj:SetAttribute("OriginalImage", nil)
                end
            end
        end
    end
end

-- ===== HIDE NAME (Screamer Mode) =====
local SecHideName = TabSurvivor:AddSection({"Hide Name (Screamer Mode)"})

SecHideName:AddToggle({"Hide Name", false, function(v)
    Config.Misc_FakeName = v
    if v then
        enableSpoofer()
        notif("Hide Name: ON")
    else
        disableSpoofer()
        notif("Hide Name: OFF")
    end
end, "Ganti nama player jadi 'AscenD' di client"})

local SecCrouch = TabSurvivor:AddSection({"Auto Crouch"})

local CrouchCfg = { AutoCrouch = false, CrouchV = false }

function TriggerCrouch()
    pcall(function()
        local b = LP:FindFirstChild("PlayerGui")
        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then b = b:FindFirstChild(segment) end
        end
        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent
            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click) task.wait(1.4) firesignal(btn.MouseButton1Click)
            else
                VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(1.4)
                VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(1.4)
            VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

-- Dodge Veil module
local DodgeVeil = { Attached = {}, lastTime = 0, Cooldown = 0.1, Distance = 6 }

DodgeVeil.Trigger = function()
    if tick() - DodgeVeil.lastTime < DodgeVeil.Cooldown then return end
    DodgeVeil.lastTime = tick()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local side = (math.random() > 0.5) and 1 or -1
    local offset = hrp.CFrame.RightVector * side * DodgeVeil.Distance
    hrp.CFrame = CFrame.new(hrp.Position + offset) * (hrp.CFrame - hrp.CFrame.Position)
end

DodgeVeil.Attach = function(kChar)
    if not kChar or DodgeVeil.Attached[kChar] then return end
    DodgeVeil.Attached[kChar] = true
    local humanoid = kChar:WaitForChild("Humanoid", 5) if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 5)
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not CrouchCfg.CrouchV then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        if id ~= "86266790353635" and id ~= "93136435416899" then return end
        local myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not (myHRP and kHRP) then return end
        if (myHRP.Position - kHRP.Position).Magnitude > 100 then return end
        local flatDelta = Vector3.new(myHRP.Position.X - kHRP.Position.X, 0, myHRP.Position.Z - kHRP.Position.Z)
        if flatDelta.Magnitude <= 0 then return end
        local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z)
        if kLookFlat.Magnitude <= 0.001 then return end
        if kLookFlat.Unit:Dot(flatDelta.Unit) >= 0.7 then DodgeVeil.Trigger() end
    end)
end

DodgeVeil.TryAttach = function(p)
    if p ~= LP and p.Team and p.Team.Name == "Killer" and p.Character then
        DodgeVeil.Attach(p.Character)
    end
end

DodgeVeil.Setup = function(p)
    if p == LP then return end
    p.CharacterAdded:Connect(function() DodgeVeil.TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() DodgeVeil.TryAttach(p) end)
    if p.Character then DodgeVeil.TryAttach(p) end
end

for _, p in ipairs(Players:GetPlayers()) do DodgeVeil.Setup(p) end
Players.PlayerAdded:Connect(DodgeVeil.Setup)

SecCrouch:AddToggle({"Auto Crouch", false, function(v)
    ParryCfg.AutoCrouch = v
    CrouchCfg.AutoCrouch = v
    notif("Auto Crouch: " .. (v and "ON" or "OFF"))
end, "Otomatis jongkok saat killer pakai Abyssal S1"})

-- ===== FAKE PERKS =====
local FakePerks = {
    QuickRecoveryEnabled = false, PerfectLandingEnabled = false, FlowstateEnabled = false,
    PerkCooldown = 10, boostActive = false, perfectLandingBoostActive = false, fsOnCooldown = false,
    lastQRTime = 0, lastPLTime = 0, lastFSTime = 0,
    qrConnection = nil, plConnection = nil, fsConnection = nil, fsAnimConnection = nil,
}

local function IsSurvivorFake()
    return LP.Team and LP.Team.Name == "Survivors"
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
    if not FakePerks.QuickRecoveryEnabled or not IsSurvivorFake() then return end
    if FakePerks.boostActive or (tick() - FakePerks.lastQRTime) < FakePerks.PerkCooldown then return end
    FakePerks.boostActive = true
    FakePerks.lastQRTime = tick()
    local startTime = tick()
    task.spawn(function()
        while FakePerks.QuickRecoveryEnabled and (tick() - startTime) < 3 do
            if char and char.Parent then char:SetAttribute("speedboost", 1.4) end
            task.wait()
        end
        if char and char.Parent then char:SetAttribute("speedboost", 1) end
        FakePerks.boostActive = false
    end)
end

local function setupQuickRecovery(char)
    if FakePerks.qrConnection then FakePerks.qrConnection:Disconnect() end
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
    if not FakePerks.PerfectLandingEnabled or not IsSurvivorFake() then return end
    if FakePerks.perfectLandingBoostActive or (tick() - FakePerks.lastPLTime) < FakePerks.PerkCooldown then return end
    FakePerks.perfectLandingBoostActive = true
    FakePerks.lastPLTime = tick()
    local startTime = tick()
    task.spawn(function()
        while FakePerks.perfectLandingBoostActive and (tick() - startTime) < 3 do
            if char and char.Parent then char:SetAttribute("speedboost", 1.4) end
            task.wait()
        end
        if char and char.Parent then char:SetAttribute("speedboost", 1) end
        FakePerks.perfectLandingBoostActive = false
    end)
end

local function setupPerfectLanding(char)
    if FakePerks.plConnection then FakePerks.plConnection:Disconnect() end
    if not char then return end
    FakePerks.plConnection = char:GetAttributeChangedSignal("speedboost"):Connect(function()
        if not IsSurvivorFake() then return end
        if char:GetAttribute("speedboost") == 0.625 then
            applyPerfectLanding(char)
        end
    end)
end

local function setupFlowstate(char)
    if FakePerks.fsConnection then FakePerks.fsConnection:Disconnect() end
    if FakePerks.fsAnimConnection then FakePerks.fsAnimConnection:Disconnect() end
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
            if char and char.Parent then char:SetAttribute("Flowstate", false) end
            task.delay(FakePerks.PerkCooldown, function()
                FakePerks.fsOnCooldown = false
                if FakePerks.FlowstateEnabled and char and char.Parent then
                    char:SetAttribute("Flowstate", true)
                end
            end)
        end)
    end)

    FakePerks.fsConnection = char:GetAttributeChangedSignal("Flowstate"):Connect(function()
        if not FakePerks.FlowstateEnabled or not IsSurvivorFake() then return end
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

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if FakePerks.QuickRecoveryEnabled then setupQuickRecovery(char) end
    if FakePerks.PerfectLandingEnabled then setupPerfectLanding(char) end
    if FakePerks.FlowstateEnabled then setupFlowstate(char) end
end)


-- ====================== AUTO SKILL CHECK (GENE) ======================
local GeneConfig = {
    Enabled = false,
    Mode = "SUCCESS",
    SUCCESS_MIN = 102,
    SUCCESS_MAX = 116,
    NEUTRAL_MIN = 116,
    NEUTRAL_MAX = 159,
    TriggerDelay = 0.035,
    LastTrigger = 0,
    Busy = false,
    ScourgeActive = false,
    ScourgeRound = 0,
}

local KingScourgeStart, KingScourgeEnd
pcall(function()
    local KillerPerks = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("KillerPerks")
    local KingScourge = KillerPerks:WaitForChild("kingscourge")
    KingScourgeStart = KingScourge:WaitForChild("KingScourgeStart")
    KingScourgeEnd = KingScourge:WaitForChild("KingScourgeEnd")
end)

local Check, Line, Goal, Action

local function GeneRefreshReferences()
    pcall(function()
        local SkillGui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if SkillGui then
            Check = SkillGui:FindFirstChild("Check")
            if Check then
                Line = Check:FindFirstChild("Line")
                Goal = Check:FindFirstChild("Goal")
            end
        end
        local Survivor = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("Survivor-mob")
        if Survivor then
            local Controls = Survivor:FindFirstChild("Controls")
            if Controls then
                Action = Controls:FindFirstChild("action")
            end
        end
    end)
end

GeneRefreshReferences()
task.spawn(function()
    while true do
        GeneRefreshReferences()
        task.wait(0.5)
    end
end)

local function GeneTriggerAction()
    if not Action then GeneRefreshReferences() end
    if not Action then return false end
    local Now = os.clock()
    if Now - GeneConfig.LastTrigger < GeneConfig.TriggerDelay then return false end
    GeneConfig.LastTrigger = Now
    pcall(function()
        if Action:IsA("GuiButton") then Action:Activate() end
    end)
    if typeof(firesignal) == "function" then
        pcall(function() firesignal(Action.MouseButton1Down) end)
    end
    return true
end

local function GeneGetAngle()
    if not Line or not Goal then return nil end
    return tonumber(Line.Rotation) or 0, tonumber(Goal.Rotation) or 0
end

local function GeneIsSuccess()
    local LineRotation, GoalRotation = GeneGetAngle()
    if not LineRotation then return false end
    local Min = GoalRotation + GeneConfig.SUCCESS_MIN
    local Max = GoalRotation + GeneConfig.SUCCESS_MAX
    return LineRotation >= Min and LineRotation <= Max
end

local function GeneIsNeutral()
    local LineRotation, GoalRotation = GeneGetAngle()
    if not LineRotation then return false end
    local Min = GoalRotation + GeneConfig.NEUTRAL_MIN
    local Max = GoalRotation + GeneConfig.NEUTRAL_MAX
    return LineRotation > Min and LineRotation <= Max
end

local function GeneInstantNormal()
    if not Check or not Line or not Goal then GeneRefreshReferences() end
    if not Check or not Line or not Goal then return end
    if not Check.Visible then return end
    local GoalRotation = tonumber(Goal.Rotation) or 0
    Line.Rotation = GoalRotation + 109
    GeneTriggerAction()
end

local function GeneInstantScourge()
    if not GeneConfig.Enabled or not GeneConfig.ScourgeActive then return end
    if not Line or not Goal then GeneRefreshReferences() end
    if not Line or not Goal then return end
    local GoalRotation = tonumber(Goal.Rotation) or 0
    Line.Rotation = GoalRotation + 109
    GeneTriggerAction()
    GeneConfig.ScourgeRound = GeneConfig.ScourgeRound + 1
end

if KingScourgeStart then
    KingScourgeStart.OnClientEvent:Connect(function()
        if not GeneConfig.Enabled then return end
        GeneConfig.ScourgeActive = true
        GeneConfig.ScourgeRound = 0
        GeneConfig.Busy = false
        task.defer(function()
            if GeneConfig.Enabled and GeneConfig.Mode == "INSTANT" then
                GeneInstantScourge()
            end
        end)
    end)
end

if KingScourgeEnd then
    KingScourgeEnd.OnClientEvent:Connect(function()
        GeneConfig.ScourgeActive = false
        GeneConfig.Busy = false
    end)
end

local GenePreviousVisible = false
RunService.RenderStepped:Connect(function()
    if not GeneConfig.Enabled then
        GenePreviousVisible = false
        return
    end
    if not Check then GeneRefreshReferences() end
    if not Check then return end

    local Visible = Check.Visible
    if Visible and not GenePreviousVisible then
        GeneConfig.Busy = false
        if not GeneConfig.ScourgeActive and GeneConfig.Mode == "INSTANT" then
            GeneInstantNormal()
        end
    end
    GenePreviousVisible = Visible

    if Visible and not GeneConfig.ScourgeActive then
        if not GeneConfig.Busy then
            local ShouldTrigger = false
            if GeneConfig.Mode == "SUCCESS" then
                ShouldTrigger = GeneIsSuccess()
            elseif GeneConfig.Mode == "NEUTRAL" then
                ShouldTrigger = GeneIsNeutral()
            end
            if ShouldTrigger then
                GeneConfig.Busy = true
                GeneTriggerAction()
                task.delay(0.07, function() GeneConfig.Busy = false end)
            end
        end
    end

    if GeneConfig.ScourgeActive and Visible then
        if GeneConfig.Mode == "SUCCESS" then
            if not GeneConfig.Busy and GeneIsSuccess() then
                GeneConfig.Busy = true
                GeneTriggerAction()
                task.delay(0.06, function() GeneConfig.Busy = false end)
            end
        elseif GeneConfig.Mode == "NEUTRAL" then
            if not GeneConfig.Busy and GeneIsNeutral() then
                GeneConfig.Busy = true
                GeneTriggerAction()
                task.delay(0.06, function() GeneConfig.Busy = false end)
            end
        elseif GeneConfig.Mode == "INSTANT" then
            local CurrentGoal = tonumber(Goal and Goal.Rotation) or 0
            local CurrentLine = tonumber(Line and Line.Rotation) or 0
            if math.abs(CurrentLine - CurrentGoal) > 130 then
                GeneConfig.Busy = false
            end
        end
    end
end)

task.spawn(function()
    local LastGoalRotation = nil
    while true do
        if GeneConfig.Enabled and GeneConfig.ScourgeActive and GeneConfig.Mode == "INSTANT" then
            GeneRefreshReferences()
            if Check and Check.Visible and Goal and Line then
                local CurrentGoal = tonumber(Goal.Rotation) or 0
                if LastGoalRotation == nil then
                    LastGoalRotation = CurrentGoal
                    GeneInstantScourge()
                elseif math.abs(CurrentGoal - LastGoalRotation) > 1 then
                    LastGoalRotation = CurrentGoal
                    GeneInstantScourge()
                end
            end
        else
            LastGoalRotation = nil
        end
        task.wait(0.005)
    end
end)

getgenv().GeneConfig = GeneConfig
getgenv().SetGeneEnabled = function(v)
    GeneConfig.Enabled = v and true or false
    GeneConfig.Busy = false
end
getgenv().SetGeneMode = function(mode)
    if mode == "SUCCESS" or mode == "NEUTRAL" or mode == "INSTANT" then
        GeneConfig.Mode = mode
        GeneConfig.Busy = false
    end
end

local SecGene = TabSurvivor:AddSection({"Auto Skill Check"})

SecGene:AddToggle({"Auto Skill Check", false, function(v)
    getgenv().SetGeneEnabled(v)
    if v then
        notif("Auto Skill Check: ON (" .. GeneConfig.Mode .. ")")
    else
        notif("Auto Skill Check: OFF")
    end
end, "Auto success / neutral / instant skill check"})

SecGene:AddDropdown({
    "Skill Check Mode",
    Options = {"SUCCESS", "NEUTRAL", "INSTANT"},
    Default = "SUCCESS",
    Callback = function(mode)
        getgenv().SetGeneMode(mode)
        notif("Mode: " .. mode)
    end
})


local SecPerks = TabSurvivor:AddSection({"Fake Perks"})

SecPerks:AddToggle({"Fake Quick Recovery", false, function(v)
    FakePerks.QuickRecoveryEnabled = v
    if v and LP.Character then
        setupQuickRecovery(LP.Character)
    elseif not v and FakePerks.qrConnection then
        FakePerks.qrConnection:Disconnect()
        FakePerks.qrConnection = nil
    end
    notif("Fake QR: " .. (v and "ON" or "OFF"))
end, "Speed boost 1.4x selama 3 detik setelah vault cepat"})

SecPerks:AddToggle({"Fake Perfect Landing", false, function(v)
    FakePerks.PerfectLandingEnabled = v
    if v then
        if LP.Character then setupPerfectLanding(LP.Character) end
    else
        if FakePerks.plConnection then FakePerks.plConnection:Disconnect() end
        if FakePerks.perfectLandingBoostActive and LP.Character then
            LP.Character:SetAttribute("speedboost", 1)
            FakePerks.perfectLandingBoostActive = false
        end
    end
    notif("Fake PL: " .. (v and "ON" or "OFF"))
end, "Speed boost 1.4x selama 3 detik setelah landing"})

SecPerks:AddToggle({"Fake Flowstate", false, function(v)
    FakePerks.FlowstateEnabled = v
    if v then
        if LP.Character then setupFlowstate(LP.Character) end
    else
        if FakePerks.fsConnection then FakePerks.fsConnection:Disconnect() end
        if FakePerks.fsAnimConnection then FakePerks.fsAnimConnection:Disconnect() end
        if LP.Character then LP.Character:SetAttribute("Flowstate", false) end
    end
    notif("Fake Flowstate: " .. (v and "ON" or "OFF"))
end, "Flowstate unlimited dengan cooldown realistis"})

SecPerks:AddSlider({"Perks Cooldown (detik)", 0, 180, 10, function(v)
    FakePerks.PerkCooldown = v
    if FakePerks.FlowstateEnabled and LP.Character then
        local char = LP.Character
        char:SetAttribute("Flowstate", true)
        FakePerks.fsOnCooldown = false
        FakePerks.lastFSTime = tick()
    end
end})

-- ===== DBD CAMERA (New) =====
local VD_CameraDBD = {
    Enabled    = false,
    Resolution = 0.65,
    Priority   = 200,
    _Bound     = false,
}

local function ApplyDBDCamera()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if not VD_CameraDBD.Enabled then return end

    local res = VD_CameraDBD.Resolution or 0.65
    local pos = cam.CFrame.Position
    local rot = cam.CFrame - pos
    local squeeze = CFrame.new(0, 0, 0, 1, 0, 0, 0, res, 0, 0, 0, 1)
    cam.CFrame = CFrame.new(pos) * rot * squeeze
end

local function BindDBDCamera()
    if VD_CameraDBD._bound then return end
    VD_CameraDBD._bound = true
    RunService:BindToRenderStep("VD_DBDCamera", VD_CameraDBD.Priority, function()
        ApplyDBDCamera()
    end)
end

local function UnbindDBDCamera()
    if not VD_CameraDBD._bound then return end
    VD_CameraDBD._bound = false
    pcall(function() RunService:UnbindFromRenderStep("VD_DBDCamera") end)
end

function VD_CameraDBD.SetEnabled(state)
    VD_CameraDBD.Enabled = state and true or false
    if VD_CameraDBD.Enabled then
        BindDBDCamera()
    else
        UnbindDBDCamera()
    end
end

function VD_CameraDBD.SetResolution(value)
    VD_CameraDBD.Resolution = math.clamp(tonumber(value) or 0.65, 0.05, 1)
end

function VD_CameraDBD.GetEnabled()
    return VD_CameraDBD.Enabled
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() end)

getgenv().VD_CameraDBD = VD_CameraDBD

local SecDBD = TabSurvivor:AddSection({"DBD Camera"})

SecDBD:AddToggle({"DBD Camera", false, function(v)
    VD_CameraDBD.SetEnabled(v)
    if v then
        notif("DBD Camera: ON")
    else
        notif("DBD Camera: OFF")
    end
end, "Efek kamera seperti Dead by Daylight"})

SecDBD:AddSlider({"Resolution", 5, 100, 65, function(v)
    VD_CameraDBD.SetResolution(v / 100)
end})

-- ============================================================
-- SILENT AIM (Survivor) — FOV circle + smooth aim
-- ============================================================
local SilentAim = {
    Enabled   = false,
    ShowCircle = false,
    Holding   = true,          -- true = harus nahan tombol
    AimKey    = Enum.UserInputType.MouseButton2,
    Fov       = 120,
    Smooth    = 0.25,          -- 0 = instant, semakin besar semakin lambat
    AimPart   = "Head",        -- "Head" / "HumanoidRootPart"
    TeamFilter = "Killer",     -- Survivor → target Killer
}

local SilentAiming = false
local FOVCircle = nil

-- FOV Circle (Drawing API — aman kalau executor gak support)
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1
        FOVCircle.NumSides = 64
        FOVCircle.Radius = SilentAim.Fov
        FOVCircle.Filled = false
        FOVCircle.Visible = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
        FOVCircle.Transparency = 0.7
    end
end)

local function SA_GetAimPart(character)
    if not character then return nil end
    local part = character:FindFirstChild(SilentAim.AimPart)
    if not part then
        part = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end
    return part
end

local function SA_IsValidTeam(player)
    if SilentAim.TeamFilter == "All" then return true end
    if not player.Team then return false end
    local teamName = string.lower(player.Team.Name)
    if SilentAim.TeamFilter == "Killer" then
        return string.find(teamName, "kill") ~= nil
    elseif SilentAim.TeamFilter == "Survivor" then
        return string.find(teamName, "surv") ~= nil
    end
    return true
end

local function SA_GetClosestTarget()
    local closest = nil
    local shortest = SilentAim.Fov
    local mousePos = UserInputService:GetMouseLocation()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and SA_IsValidTeam(player) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local aimPart = SA_GetAimPart(player.Character)
            if humanoid and humanoid.Health > 0 and aimPart then
                local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = aimPart
                    end
                end
            end
        end
    end
    return closest
end

-- Input hold
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not SilentAim.Enabled then return end
    if input.UserInputType == SilentAim.AimKey then
        SilentAiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == SilentAim.AimKey then
        SilentAiming = false
    end
end)

-- Render loop
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    -- Update FOV circle
    if FOVCircle then
        if SilentAim.ShowCircle and SilentAim.Enabled then
            FOVCircle.Visible = true
            FOVCircle.Radius = SilentAim.Fov
            FOVCircle.Position = cam.ViewportSize / 2
        else
            FOVCircle.Visible = false
        end
    end

    if not SilentAim.Enabled then return end

    local shouldAim = true
    if SilentAim.Holding then
        shouldAim = SilentAiming or UserInputService:IsMouseButtonPressed(SilentAim.AimKey)
    end

    if shouldAim then
        local target = SA_GetClosestTarget()
        if target then
            local targetCFrame = CFrame.new(cam.CFrame.Position, target.Position)
            if SilentAim.Smooth > 0 then
                cam.CFrame = cam.CFrame:Lerp(targetCFrame, 1 - SilentAim.Smooth)
            else
                cam.CFrame = targetCFrame
            end
        end
    end
end)

-- UI Section
local SecSilentAim = TabSurvivor:AddSection({"Silent Aim"})

SecSilentAim:AddToggle({"Enable Silent Aim", false, function(v)
    SilentAim.Enabled = v
    if not v and FOVCircle then FOVCircle.Visible = false end
    notif("Silent Aim: " .. (v and "ON" or "OFF"))
end, "Aim assist FOV-based ke target terdekat"})

SecSilentAim:AddToggle({"Show FOV Circle", false, function(v)
    SilentAim.ShowCircle = v
    if FOVCircle then FOVCircle.Visible = v and SilentAim.Enabled end
end, "Tampilkan lingkaran FOV di tengah layar"})

SecSilentAim:AddSlider({"FOV Radius (POV)", 20, 500, 120, function(v)
    SilentAim.Fov = v
    if FOVCircle then FOVCircle.Radius = v end
end})

SecSilentAim:AddSlider({"Smoothness", 0, 90, 25, function(v)
    -- UI 0–90 → internal 0–0.9 (0 = instant)
    SilentAim.Smooth = v / 100
end})

SecSilentAim:AddToggle({"Hold to Aim (M2)", true, function(v)
    SilentAim.Holding = v
end, "Harus nahan klik kanan biar aim aktif"})

SecSilentAim:AddDropdown({
    "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(v)
        SilentAim.AimPart = tostring(v)
        notif("Aim Part: " .. tostring(v))
    end,
})

SecSilentAim:AddDropdown({
    "Target Team",
    Options = {"Killer", "Survivor", "All"},
    Default = "Killer",
    Callback = function(v)
        SilentAim.TeamFilter = tostring(v)
        notif("Target: " .. tostring(v))
    end,
})

_G.SilentAim = SilentAim

local TabKiller = Window:AddTab({"Killer", "skull"})

-- ===== HIDDEN NO CD =====
local KillerCfg = { BypassLeap = false }
local KillerConns = {}

local function StartLeapBypass()
    KillerConns.LeapBypass = task.spawn(function()
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
            warn("[Hidden No CD] Function tryActivate / playM2Animation tidak ditemukan.")
            return
        end
        while task.wait(0.1) do
            if not KillerCfg.BypassLeap then break end
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

local SecHidden = TabKiller:AddSection({"Bypass All Killer"})

SecHidden:AddToggle({"Bypass Cooldown (Hidden)", false, function(v)
    KillerCfg.BypassLeap = v
    if v then
        StartLeapBypass()
        notif("Bypass Hidden: ON")
    else
        notif("Bypass Hidden: OFF")
    end
end, "Hapus cooldown leap / M2 Hidden"})

-- ===== AIM LOCK HIDDEN =====
local AimbotEnabled = false
local AimbotThread = nil
local Aiming = false
local HoldKey = Enum.KeyCode.E
local mobileHooks = {}

local function GetClosestTarget()
    local hrp = GetRoot()
    if not hrp then return nil end
    local myTeam = LP.Team and LP.Team.Name or ""
    local closestTarget, shortestDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local playerTeam = player.Team and player.Team.Name or ""
            if targetHrp and hum and hum.Health > 0 then
                local isEnemy = (myTeam == "Killer" and playerTeam ~= "Killer")
                    or (myTeam ~= "Killer" and playerTeam == "Killer")
                if isEnemy then
                    local d = (targetHrp.Position - hrp.Position).Magnitude
                    if d < shortestDist then
                        shortestDist, closestTarget = d, targetHrp
                    end
                end
            end
        end
    end
    return closestTarget
end

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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not AimbotEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = true end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == HoldKey then Aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Aiming = false end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == HoldKey then Aiming = false end
end)

local function disconnectMobileHooks()
    for _, c in pairs(mobileHooks) do pcall(function() c:Disconnect() end) end
    mobileHooks = {}
end

local function setupMobileAimButtons()
    if not UserInputService.TouchEnabled then return end
    disconnectMobileHooks()
    task.spawn(function()
        local pGui = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
        if not pGui then return end
        local NAMES = {"attack","shoot","fire","basicattack","tembak","hidden","skill","ability","power","skill1","ability1","gui-mob"}
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
            if not btn or btn:GetAttribute("RYNER_HoldAim") then return end
            btn:SetAttribute("RYNER_HoldAim", true)
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
LP.CharacterAdded:Connect(function()
    Aiming = false
    if UserInputService.TouchEnabled then
        task.wait(2)
        setupMobileAimButtons()
    end
end)

SecHidden:AddToggle({"Aim Lock Hidden (Hold)", false, function(state)
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
end, "Tahan M2 / tombol attack → lock kamera"})

SecHidden:AddInput({"Hold Keybind (Custom)", "E", "E", function(input)
    input = tostring(input or ""):gsub("%s+", "")
    if input == "" then return end
    local map = {
        ["leftshift"]=Enum.KeyCode.LeftShift, ["rightshift"]=Enum.KeyCode.RightShift,
        ["leftalt"]=Enum.KeyCode.LeftAlt, ["rightalt"]=Enum.KeyCode.RightAlt,
        ["leftctrl"]=Enum.KeyCode.LeftControl, ["rightctrl"]=Enum.KeyCode.RightControl,
        ["leftcontrol"]=Enum.KeyCode.LeftControl, ["rightcontrol"]=Enum.KeyCode.RightControl,
        ["space"]=Enum.KeyCode.Space, ["tab"]=Enum.KeyCode.Tab,
        ["capslock"]=Enum.KeyCode.CapsLock, ["shift"]=Enum.KeyCode.LeftShift,
        ["ctrl"]=Enum.KeyCode.LeftControl, ["alt"]=Enum.KeyCode.LeftAlt,
    }
    local newKey = map[input:lower()]
    if not newKey then
        local ok, kc = pcall(function()
            return Enum.KeyCode[input:upper():sub(1,1) .. input:lower():sub(2)]
        end)
        if ok and kc then newKey = kc end
    end
    if newKey then
        HoldKey = newKey
        notif("Hold key: " .. newKey.Name)
    else
        notif("Keybind tidak valid: " .. input)
    end
end})

--==================== TAB 4: ESP ===================
local TabESP = Window:AddTab({"Esp", "eye"})

--==================== HELPERS ====================
local function notif(txt, dur)
    if Lib.Loading then return end
    pcall(function()
        Lib:SetNotification({ Content = tostring(txt), Delay = dur or 3 })
    end)
end
Notify = notif

local function GetRoot()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function IsKiller(p)
    return p and p.Team and p.Team.Name == "Killer"
end

local function IsSurvivor(p)
    return p and p.Team and p.Team.Name == "Survivors"
end

local function IsDowned(char)
    return char and (char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true)
end

local function GetRole()
    if not LP.Team then return "Unknown" end
    local n = LP.Team.Name
    if n == "Killer" then return "Killer"
    elseif n == "Survivors" then return "Survivor"
    else return "Spectator" end
end

pcall(function()
    if getconnections then
        for _, c in pairs(getconnections(LP.Idled)) do
            if c.Disable then c:Disable() end
        end
    end
end)

-- Anti AFK
pcall(function()
    if getconnections then
        for _, c in pairs(getconnections(LP.Idled)) do
            if c.Disable then c:Disable() end
        end
    end
end)


-- =========== ESP SYSTEM =======================

local Tuning = {
    Colors = {
        SCP           = Color3.fromRGB(255, 255, 0),
        Player        = Color3.fromRGB( 160, 90, 255),
        Killer        = Color3.fromRGB(255, 40, 40),
        Generator     = Color3.fromRGB(255, 255, 255),
        GeneratorDone = Color3.fromRGB(0, 180, 60),
        Pallet        = Color3.fromRGB(0, 180, 60),
        Hook          = Color3.fromRGB(0, 180, 60),
        Gate          = Color3.fromRGB(255, 255, 255),
        Window        = Color3.fromRGB(255, 255, 255),
    }
}

local Cache = { Generators = {}, Pallets = {}, Hooks = {}, Gates = {}, Windows = {}, SCPs = {} }
local HookData = {}
HookESPEnabled = false
local lastScanTime = 0

local ESPCfg = {
    Master     = false,
    Player     = false,
    Killer     = false,
    SCP        = false,
    Outline    = false,
    Name       = false,
    Distance   = false,
    ItemIcon   = false,
    KillerWarn = false,
    Generator  = false,
    GenName    = true,
    Pallet     = false,
    Window     = false,
    Hook       = false,
    Gate       = false,
    HookCount  = false,
}

local FullBright, NoFog, NoShadow = false, false, false
local TimeOfDayValue = 14

-- ===== Map Scanner (HYBRID — Robust + Pallet Strict) =====
local function ScanMap()
    if tick() - lastScanTime < 2 then return end
    lastScanTime = tick()
    table.clear(Cache.Generators) table.clear(Cache.Windows) table.clear(Cache.Pallets)
    table.clear(Cache.Hooks) table.clear(Cache.Gates) table.clear(Cache.SCPs)

    local mapFolder = workspace:FindFirstChild("Map") or workspace

    for i, v in ipairs(mapFolder:GetDescendants()) do
        if i % 200 == 0 then task.wait() end

        if v:IsA("Model") then
            local name = string.lower(v.Name)

            -- ============ GENERATOR (robust) ============
            local isGenerator = false
            if name:find("generator") or (name:find("gen") and #name <= 12) then
                local hasProgress = v:GetAttribute("RepairProgress") ~= nil
                    or v:GetAttribute("ProgressRepair") ~= nil
                    or v:GetAttribute("kickcount") ~= nil
                    or v:GetAttribute("Completed") ~= nil
                local hasGenPoint = false
                for _, child in ipairs(v:GetChildren()) do
                    if child.Name:find("GeneratorPoint") or child.Name:find("RepairPoint") then
                        hasGenPoint = true
                        break
                    end
                end
                if hasProgress or hasGenPoint then
                    isGenerator = true
                end
            end
            if isGenerator then
                local p = v:FindFirstChildWhichIsA("BasePart") or v.PrimaryPart
                if p then table.insert(Cache.Generators, {model=v, part=p}) end
                continue
            end

            -- ============ HOOK (robust) ============
            local isHook = false
            if name:find("hook") or name:find("meat") then
                local hookPoint = v:FindFirstChild("HookPoint")
                    or v:FindFirstChild("HookPointSlide")
                    or v:FindFirstChild("HookingPoint")
                    or v:FindFirstChild("Attach")
                if hookPoint and hookPoint:IsA("BasePart") then
                    isHook = true
                end
                if not isHook then
                    for _, child in ipairs(v:GetChildren()) do
                        if child:IsA("BasePart") and child.Name:lower():find("hook") then
                            isHook = true
                            break
                        end
                    end
                end
            end
            if isHook then
                if not table.find(Cache.Hooks, v) then
                    table.insert(Cache.Hooks, v)
                end
                continue
            end

            -- ============ GATE (robust) ============
            local isGate = false
            if name:find("gate") or name:find("exit") then
                local hasLever = v:FindFirstChild("ExitLever")
                    or v:FindFirstChild("ExitLeverPart")
                    or v:FindFirstChild("Lever")
                local hasLeftRight = v:FindFirstChild("LeftGate") and v:FindFirstChild("RightGate")
                if hasLever or hasLeftRight then
                    isGate = true
                end
            end
            if isGate then
                if not table.find(Cache.Gates, v) then
                    table.insert(Cache.Gates, v)
                end
                continue
            end

            -- ============ WINDOW / VAULT (robust) ============
            local isWindow = false
            if name:find("window") or name:find("vault") then
                local hasBottom = v:FindFirstChild("Bottom") or v:FindFirstChildWhichIsA("BasePart")
                if hasBottom then
                    isWindow = true
                end
            end
            if isWindow then
                if not table.find(Cache.Windows, v) then
                    table.insert(Cache.Windows, v)
                end
                continue
            end
        end

        -- ============ PALLET (STRICT — cuma PrimaryPartPallet) ============
        if v:IsA("BasePart") and v.Name == "PrimaryPartPallet" then
            local m = v.Parent
            if m and m:IsA("Model") and not table.find(Cache.Pallets, m) then
                table.insert(Cache.Pallets, m)
            end
        end
    end

    -- ============ SCP / ZOMBIE ============
    for i, v in ipairs(workspace:GetDescendants()) do
        if i % 200 == 0 then task.wait() end
        if v:IsA("Model") and string.match(string.lower(v.Name), "^scp") then
            if not table.find(Cache.SCPs, v) then table.insert(Cache.SCPs, v) end
        end
    end

    print(string.format(
        "[RYNER] Map scanned → Gen: %d | Hook: %d | Gate: %d | Pallet: %d | Window: %d | SCP: %d",
        #Cache.Generators, #Cache.Hooks, #Cache.Gates, #Cache.Pallets, #Cache.Windows, #Cache.SCPs
    ))
end

-- ===== Item Icon =====
local ItemsFolder = ReplicatedStorage:WaitForChild("Items", 5)
local function extractAssetId(str) return tostring(str):match("%d+") end
local function getItemIcon(itemName)
    if not ItemsFolder then return nil end
    local item = ItemsFolder:FindFirstChild(itemName)
    if not item then return nil end
    local tex
    pcall(function() tex = item.Texture or item.Image end)
    if tex and tex ~= "" then
        local id = extractAssetId(tex)
        if id then return ("rbxthumb://type=Asset&id=%s&w=420&h=420"):format(id) end
    end
    return nil
end

-- ===== Create Modern ESP =====
local function CreateModernESP(parent, idName, cfg)
    local billboard = parent:FindFirstChild(idName)
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = idName
        billboard.Parent = parent
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 25)
        billboard.StudsOffset = Vector3.new(0, cfg.offsetY or 3.5, 0)

        local box = Instance.new("Frame")
        box.Name = "Box" box.AutomaticSize = Enum.AutomaticSize.X
        box.Size = UDim2.new(0, 0, 0, 15) box.Position = UDim2.new(0.5, 0, 0, 0)
        box.AnchorPoint = Vector2.new(0.5, 0)
        box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        box.BorderSizePixel = 0 box.ZIndex = 2 box.Parent = billboard
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)

        local bg = Instance.new("UIGradient", box)
        bg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.15, 0.35),
            NumberSequenceKeypoint.new(0.85, 0.35),
            NumberSequenceKeypoint.new(1, 1)
        })

        local pad = Instance.new("UIPadding", box)
        pad.PaddingLeft = UDim.new(0, 8) pad.PaddingRight = UDim.new(0, 8)

        local layout = Instance.new("UIListLayout", box)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 3) layout.SortOrder = Enum.SortOrder.LayoutOrder

        local icon = Instance.new("ImageLabel", box)
        icon.Name = "Icon" icon.Size = UDim2.new(0, 12, 0, 12)
        icon.BackgroundTransparency = 1 icon.ZIndex = 3 icon.LayoutOrder = 1 icon.Visible = false

        local txt = Instance.new("TextLabel", box)
        txt.Name = "Text" txt.AutomaticSize = Enum.AutomaticSize.X
        txt.Size = UDim2.new(0, 0, 1, 0) txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamMedium txt.TextSize = 10 txt.ZIndex = 3
        txt.LayoutOrder = 2 txt.RichText = true
        txt.TextXAlignment = Enum.TextXAlignment.Center
        txt.TextYAlignment = Enum.TextYAlignment.Center

        local line = Instance.new("Frame")
        line.Name = "Line" line.Size = UDim2.new(0, 1, 0, 10)
        line.Position = UDim2.new(0.5, 0, 0, 15) line.AnchorPoint = Vector2.new(0.5, 0)
        line.BorderSizePixel = 0 line.ZIndex = 1 line.Parent = billboard

        local lg = Instance.new("UIGradient", line)
        lg.Rotation = 90
        lg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    end

    billboard.Line.BackgroundColor3 = cfg.color
    local iconLabel = billboard.Box:FindFirstChild("Icon")
    if cfg.icon and cfg.icon ~= "" then
        if iconLabel then iconLabel.Image = cfg.icon iconLabel.Visible = true end
    else
        if iconLabel then iconLabel.Visible = false end
    end

    local hex = string.format("#%02X%02X%02X", cfg.color.R*255, cfg.color.G*255, cfg.color.B*255)
    if cfg.distance then
        billboard.Box.Text.Text = string.format("<font color='#FFFFFF'>%s</font> <font color='%s'>[%dm]</font>", cfg.name, hex, cfg.distance)
    elseif cfg.subtext then
        billboard.Box.Text.Text = string.format("<font color='#FFFFFF'>%s</font> <font color='%s'>%s</font>", cfg.name, hex, cfg.subtext)
    else
        billboard.Box.Text.Text = string.format("<font color='#FFFFFF'>%s</font>", cfg.name)
    end
end

-- ===== Clear ESP =====
local function ClearESP(tipe)
    if tipe == "Player" then
        for _, p in pairs(Players:GetPlayers()) do if p.Character then
            if p.Character:FindFirstChild("PEH") then p.Character.PEH:Destroy() end
            if p.Character:FindFirstChild("PE_Text") then p.Character.PE_Text:Destroy() end
        end end
    elseif tipe == "Killer" then
        for _, p in pairs(Players:GetPlayers()) do if p.Character then
            if p.Character:FindFirstChild("KEH") then p.Character.KEH:Destroy() end
            if p.Character:FindFirstChild("KE_Text") then p.Character.KE_Text:Destroy() end
        end end
    elseif tipe == "Generator" then
        for _, v in pairs(Cache.Generators) do if v.model and v.model.Parent then
            if v.model:FindFirstChild("GEH") then v.model.GEH:Destroy() end
            if v.model:FindFirstChild("GE_Text") then v.model.GE_Text:Destroy() end
        end end
    elseif tipe == "Pallet" then for _, v in pairs(Cache.Pallets) do
        if v and v.Parent and v:FindFirstChild("PalletEH") then v.PalletEH:Destroy() end end
    elseif tipe == "Hook" then for _, v in pairs(Cache.Hooks) do
        if v and v.Parent and v:FindFirstChild("HookEH") then v.HookEH:Destroy() end end
    elseif tipe == "Window" then for _, v in pairs(Cache.Windows) do
        if v and v.Parent and v:FindFirstChild("WindowEH") then v.WindowEH:Destroy() end end
    elseif tipe == "Gate" then for _, v in pairs(Cache.Gates) do
        if v and v.Parent and v:FindFirstChild("GateEH") then v.GateEH:Destroy() end end
    elseif tipe == "SCP" then for _, v in pairs(Cache.SCPs) do
        if v and v.Parent and v:FindFirstChild("SCPEH") then v.SCPEH:Destroy() end end
    end
end

local function ClearHookESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            for _, child in pairs(p.Character:GetChildren()) do
                if string.match(child.Name, "^HookESP_") then child:Destroy() end
            end
        end
    end
end

local function ClearAllESP()
    ClearESP("Player") ClearESP("Killer") ClearESP("Generator") ClearESP("Pallet")
    ClearESP("Hook") ClearESP("Gate") ClearESP("SCP") ClearESP("Window")
    ClearHookESP()
end

-- ===== Update Player ESP =====
local function UpdatePlayerESP()
    if not ESPCfg.Master then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if ESPCfg.KillerWarn and myHRP and GetRole() == "Survivor" then
        local warn = myHRP:FindFirstChild("KillerWarn")
        local closestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and IsKiller(p) and p.Character then
                local kHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if kHrp then
                    local d = (kHrp.Position - myHRP.Position).Magnitude
                    if d < closestDist then closestDist = d end
                end
            end
        end
        if closestDist <= 80 then
            if not warn then
                warn = Instance.new("BillboardGui")
                warn.Name = "KillerWarn"
                warn.Size = UDim2.new(0, 30, 0, 30)
                warn.AlwaysOnTop = true
                warn.StudsOffset = Vector3.new(0, 4, 0)
                warn.Parent = myHRP
                local txt = Instance.new("TextLabel")
                txt.Name = "WarnText" txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1 txt.TextScaled = true
                txt.TextStrokeTransparency = 0 txt.Font = Enum.Font.GothamBlack
                txt.Parent = warn
            end
            local txt = warn:FindFirstChild("WarnText")
            if txt then
                if closestDist <= 40 then txt.Text = "!!" txt.TextColor3 = Color3.fromRGB(255,0,0)
                else txt.Text = "!" txt.TextColor3 = Color3.fromRGB(255,255,0) end
            end
        else if warn then warn:Destroy() end end
    else
        local warn = myHRP and myHRP:FindFirstChild("KillerWarn")
        if warn then warn:Destroy() end
    end

    if ESPCfg.Player or ESPCfg.Killer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local isK = IsKiller(p)
                local root = p.Character:FindFirstChild("Head")
                if root and ((not isK and ESPCfg.Player) or (isK and ESPCfg.Killer)) then
                    local dist = myHRP and math.floor((root.Position - myHRP.Position).Magnitude) or 0
                    local col = isK and Tuning.Colors.Killer or Tuning.Colors.Player
                    local hName = isK and "KEH" or "PEH"
                    local tName = isK and "KE_Text" or "PE_Text"

                    local hl = p.Character:FindFirstChild(hName)
                    if not hl then hl = Instance.new("Highlight") hl.Name = hName hl.Parent = p.Character end
                    hl.FillColor = col hl.OutlineColor = col
                    hl.FillTransparency = ESPCfg.Outline and 1 or 0.5
                    hl.OutlineTransparency = 0

                    if ESPCfg.Name then
                        local icon = nil
                        if ESPCfg.ItemIcon and not isK then
                            local eq = p:GetAttribute("EquippedItem")
                            if eq and eq ~= "" then icon = getItemIcon(eq) end
                        end
                        CreateModernESP(p.Character, tName, {
                            name = p.Name,
                            distance = ESPCfg.Distance and dist or nil,
                            color = col, icon = icon
                        })
                    else
                        local old = p.Character:FindFirstChild(tName)
                        if old then old:Destroy() end
                    end
                end
            end
        end
    end
end

-- ===== Update SCP ESP =====
local function UpdateSCPESP()
    if not ESPCfg.Master then return end
    if ESPCfg.SCP then
        for _, obj in ipairs(Cache.SCPs) do
            if obj and obj.Parent then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChild("Torso")
                if hum and root and hum.Health > 0 and math.floor(hum.WalkSpeed) == 9 then
                    local col = Tuning.Colors.SCP
                    local hl = obj:FindFirstChild("SCPEH")
                    if not hl then hl = Instance.new("Highlight") hl.Name = "SCPEH" hl.Parent = obj end
                    hl.FillColor = col hl.OutlineColor = col
                    hl.FillTransparency = ESPCfg.Outline and 1 or 0.5
                    hl.OutlineTransparency = 0
                else
                    local h = obj:FindFirstChild("SCPEH") if h then h:Destroy() end
                end
            end
        end
    else ClearESP("SCP") end
end

-- ===== Update Static ESP =====
local function UpdateStaticESP()
    if not ESPCfg.Master then return end
    if ESPCfg.Generator then
        for _, d in pairs(Cache.Generators) do
            local v = d.model
            if v and v.Parent then
                local prog = math.floor(v:GetAttribute("RepairProgress") or 0)
                local col = (prog >= 100) and Tuning.Colors.GeneratorDone or Tuning.Colors.Generator
                local h = v:FindFirstChild("GEH")
                if not h then h = Instance.new("Highlight") h.Name = "GEH" h.Parent = v end
                h.FillColor = col h.OutlineColor = col
                h.FillTransparency = ESPCfg.Outline and 1 or 0.5
                h.OutlineTransparency = 0
                if ESPCfg.GenName then
                    local sub = (prog >= 100) and "DONE 100%" or string.format("%d%%", prog)
                    CreateModernESP(v, "GE_Text", { name = "GEN", subtext = sub, color = col, icon = nil })
                else
                    local old = v:FindFirstChild("GE_Text")
                    if old then old:Destroy() end
                end
            end
        end
    end
    if ESPCfg.Pallet then
        for _, v in pairs(Cache.Pallets) do
            if v and v.Parent then
                local h = v:FindFirstChild("PalletEH")
                if not h then h = Instance.new("Highlight") h.Name = "PalletEH" h.Parent = v end
                h.Adornee = v h.FillColor = Tuning.Colors.Pallet h.OutlineColor = Tuning.Colors.Pallet
                h.FillTransparency = ESPCfg.Outline and 1 or 0.5 h.OutlineTransparency = 0
            end
        end
    end
    if ESPCfg.Window then
        for _, v in ipairs(Cache.Windows) do
            if v and v.Parent then
                local tp = v:FindFirstChild("Bottom") or v:FindFirstChildWhichIsA("BasePart")
                if tp then
                    local h = v:FindFirstChild("WindowEH")
                    if not h then h = Instance.new("BoxHandleAdornment") h.Name = "WindowEH" h.Parent = v
                        h.AlwaysOnTop = true h.ZIndex = 5 end
                    h.Adornee = tp h.Size = tp.Size h.Color3 = Tuning.Colors.Window
                    h.Transparency = ESPCfg.Outline and 0.8 or 0.4
                end
            end
        end
    end
    if ESPCfg.Hook then
        for _, v in ipairs(Cache.Hooks) do
            if v and v.Parent then
                local h = v:FindFirstChild("HookEH")
                if not h then h = Instance.new("Highlight") h.Name = "HookEH" h.Parent = v end
                h.FillColor = Tuning.Colors.Hook h.OutlineColor = Tuning.Colors.Hook
                h.FillTransparency = ESPCfg.Outline and 1 or 0.5 h.OutlineTransparency = 0
            end
        end
    end
    if ESPCfg.Gate then
        for _, v in ipairs(Cache.Gates) do
            if v and v.Parent then
                local h = v:FindFirstChild("GateEH")
                if not h then h = Instance.new("Highlight") h.Name = "GateEH" h.Parent = v end
                h.Adornee = v h.FillColor = Tuning.Colors.Gate h.OutlineColor = Tuning.Colors.Gate
                h.FillTransparency = ESPCfg.Outline and 1 or 0.5 h.OutlineTransparency = 0
            end
        end
    end
end

local function ForceRefreshMap()
    ScanMap()
    if ESPCfg.Master then
        ClearAllESP() task.wait(0.1)
        UpdatePlayerESP() UpdateSCPESP() UpdateStaticESP()
    end
end

-- ===== Hook ESP =====
local function UpdateHookData()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Team and plr.Team.Name == "Survivors" then
            HookData[plr.Name] = plr:GetAttribute("HookCount") or 0
        end
    end
end

local function CreateHookESP(parent, hookCount)
    if not HookESPEnabled then return end
    local espName = "HookESP_" .. parent.Name
    local existing = parent:FindFirstChild(espName)
    if existing then existing:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = espName billboard.Parent = parent
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 60, 0, 18)
    billboard.StudsOffset = Vector3.new(0, 5.5, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold label.TextSize = 11 label.TextScaled = true
    label.Text = string.format("Hooked %d", hookCount)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = billboard
    if hookCount >= 3 then label.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif hookCount >= 2 then label.TextColor3 = Color3.fromRGB(255, 200, 50)
    else label.TextColor3 = Color3.fromRGB(200, 200, 200) end
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0) stroke.Thickness = 2 stroke.Transparency = 0.5
    stroke.Parent = label
end

local function UpdateHookESP()
    if not HookESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not IsKiller(p) then
            local hc = HookData[p.Name] or p:GetAttribute("HookCount") or 0
            CreateHookESP(p.Character, hc)
        end
    end
end

-- ===== World Effects =====
local function ApplyFullBright()
    if FullBright then
        Lighting.Brightness = 5
        Lighting.ClockTime = TimeOfDayValue
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
end

local function ApplyNoFog()
    if NoFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Density = 0 atm.Offset = 0 atm.Glare = 0 atm.Haze = 0 end
    end
end

local function ApplyNoShadow() Lighting.GlobalShadows = not NoShadow end

-- ===== Player ESP =====
local SecESPPlayer = TabESP:AddSection({"Player ESP"})

SecESPPlayer:AddToggle({"Enable ESP (Master)", false, function(v)
    ESPCfg.Master = v
    if v then
        ForceRefreshMap()
        notif("ESP Master: ON")
    else
        ClearAllESP()
        notif("ESP Master: OFF")
    end
end, "Master switch untuk semua ESP"})

SecESPPlayer:AddToggle({"Player ESP", false, function(v)
    ESPCfg.Player = v
    if ESPCfg.Master then
        if not v then ClearESP("Player") else ScanMap() end
    end
end, "ESP untuk Survivor"})

SecESPPlayer:AddToggle({"Killer ESP", false, function(v)
    ESPCfg.Killer = v
    if ESPCfg.Master then
        if not v then ClearESP("Killer") else ScanMap() end
    end
end, "ESP untuk Killer"})

SecESPPlayer:AddToggle({"SCP / Zombie ESP", false, function(v)
    ESPCfg.SCP = v
    if ESPCfg.Master then
        if not v then ClearESP("SCP") else ScanMap() end
    end
end, "ESP untuk SCP / Zombie"})

SecESPPlayer:AddToggle({"ESP Name", false, function(v)
    ESPCfg.Name = v
    if v then ScanMap() else ClearAllESP() end
end, "Tampilkan nama player"})

SecESPPlayer:AddToggle({"ESP Distance", false, function(v)
    ESPCfg.Distance = v
    if ESPCfg.Master then UpdatePlayerESP() end
end, "Tampilkan jarak"})

SecESPPlayer:AddToggle({"ESP Item Icon", false, function(v)
    ESPCfg.ItemIcon = v
    if ESPCfg.Master then UpdatePlayerESP() end
end, "Tampilkan icon item yang dipegang"})

SecESPPlayer:AddToggle({"Killer Warn (!/!!)", false, function(v)
    ESPCfg.KillerWarn = v
end, "Peringatan kalau killer dekat"})

SecESPPlayer:AddToggle({"Hook Count ESP", false, function(v)
    ESPCfg.HookCount = v
    HookESPEnabled = v
    if v then UpdateHookData() else ClearHookESP() end
end, "Tampilkan hitungan hook di atas survivor"})

-- ===== Map ESP =====
local SecESPMap = TabESP:AddSection({"Map ESP"})

SecESPMap:AddToggle({"Generator ESP", false, function(v)
    ESPCfg.Generator = v
    if ESPCfg.Master then
        if not v then ClearESP("Generator") else ScanMap() end
    end
end, "ESP untuk generator"})

SecESPMap:AddToggle({"Gen Name & Progress", true, function(v)
    ESPCfg.GenName = v
    if ESPCfg.Master then ScanMap() end
end, "Tampilkan progress generator"})

SecESPMap:AddToggle({"Pallet ESP", false, function(v)
    ESPCfg.Pallet = v
    if ESPCfg.Master then
        if not v then ClearESP("Pallet") else ScanMap() end
    end
end, "ESP untuk pallet"})

SecESPMap:AddToggle({"Window / Vault ESP", false, function(v)
    ESPCfg.Window = v
    if ESPCfg.Master then
        if not v then ClearESP("Window") else ScanMap() end
    end
end, "ESP untuk vault/window"})

SecESPMap:AddToggle({"Hook ESP", false, function(v)
    ESPCfg.Hook = v
    if ESPCfg.Master then
        if not v then ClearESP("Hook") else ScanMap() end
    end
end, "ESP untuk hook"})

SecESPMap:AddToggle({"Exit Gate ESP", false, function(v)
    ESPCfg.Gate = v
    if ESPCfg.Master then
        if not v then ClearESP("Gate") else ScanMap() end
    end
end, "ESP untuk exit gate"})

SecESPMap:AddButton({"Refresh Map Cache", "Force scan map ulang", function()
    ForceRefreshMap()
    notif("Map cache refreshed")
end})

-- ===== World Effects =====
local SecESPWorld = TabESP:AddSection({"World Effects"})

SecESPWorld:AddToggle({"Full Bright", false, function(v)
    FullBright = v
    if v then
        ApplyFullBright()
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end
end})

SecESPWorld:AddSlider({"Time Of Day", 0, 24, 14, function(v)
    TimeOfDayValue = v
    if FullBright then Lighting.ClockTime = v end
end})

SecESPWorld:AddToggle({"No Fog", false, function(v)
    NoFog = v
    if v then
        ApplyNoFog()
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Density = 0.35 end
    end
end})

SecESPWorld:AddToggle({"No Shadow", false, function(v)
    NoShadow = v
    ApplyNoShadow()
end})

-- ============================================================
-- LOOPS (ESP Update + World Effects)
-- ============================================================
local lastEspUpdate = 0

-- ESP Player/SCP/Static update loop
RunService.Heartbeat:Connect(function()
    if not ESPCfg.Master then return end
    local currentTime = tick()
    if currentTime - lastEspUpdate < 2 then return end
    lastEspUpdate = currentTime

    if ESPCfg.Player or ESPCfg.Killer or ESPCfg.Name or ESPCfg.ItemIcon or ESPCfg.KillerWarn then
        pcall(UpdatePlayerESP)
    end
    if ESPCfg.SCP then pcall(UpdateSCPESP) end
    if ESPCfg.Generator or ESPCfg.Pallet or ESPCfg.Hook or ESPCfg.Gate or ESPCfg.Window then
        pcall(UpdateStaticESP)
    end
end)

-- Hook ESP update loop
task.spawn(function()
    while true do
        task.wait(1)
        if HookESPEnabled then
            UpdateHookData()
            UpdateHookESP()
        else
            ClearHookESP()
        end
    end
end)

-- Map scan loop
task.spawn(function()
    while true do
        task.wait(10)
        if ESPCfg.Master then pcall(ScanMap) end
    end
end)

-- Initial scan
task.spawn(function()
    task.wait(2)
    ScanMap()
end)

workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then
        task.wait(1)
        ScanMap()
    end
end)

-- Character respawn: reset ESP + refresh
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    ScanMap()
    if ESPCfg.Master then
        task.spawn(function()
            task.wait(0.5)
            ClearAllESP()
            task.wait(0.2)
            UpdatePlayerESP()
            UpdateSCPESP()
            UpdateStaticESP()
        end)
    end
end)

-- ============================================================
-- EXPOSE STATE KE GLOBAL
-- ============================================================
_G.ParryCfg       = ParryCfg
_G.CrouchCfg      = CrouchCfg
_G.FakePerks      = FakePerks
_G.VD_CameraDBD   = VD_CameraDBD
_G.Config         = Config
_G.KillerCfg      = KillerCfg
_G.AimbotEnabled  = AimbotEnabled
_G.HoldKey        = HoldKey
_G.ESPCfg         = ESPCfg
_G.HookESPEnabled = HookESPEnabled

-- Skill Check pakai GeneConfig (setmetatable biar Luau-compatible)
_G.SkillCfg = setmetatable({}, {
    __index = function(_, k)
        if k == "Enabled" then return GeneConfig.Enabled end
        if k == "Mode" then return GeneConfig.Mode end
    end,
    __newindex = function(_, k, v)
        if k == "Enabled" then
            if getgenv().SetGeneEnabled then getgenv().SetGeneEnabled(v) else GeneConfig.Enabled = v and true or false end
        elseif k == "Mode" then
            if getgenv().SetGeneMode then getgenv().SetGeneMode(v) else GeneConfig.Mode = v end
        end
    end,
})

-- TAB: CONFIG
local TabConfig   = Window:AddTab({"Config", "settings"})
local SecConfigIO = TabConfig:AddSection({"Save & Load"})

local CONFIG_FOLDER = "RYNER_HUB"

local function ensureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder(CONFIG_FOLDER)) then
            makefolder(CONFIG_FOLDER)
        end
    end)
end
ensureFolder()

-- ===== Helper: daftar file config =====
local function listConfigs()
    local out = {}
    pcall(function()
        if listfiles and isfolder and isfolder(CONFIG_FOLDER) then
            for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = f:match("([^/\\]+)%.json$")
                if name and name ~= "autosave" then
                    table.insert(out, name)
                end
            end
        end
    end)
    table.sort(out)
    if #out == 0 then out = {"default"} end
    return out
end

-- ===== Helper: nama aman =====
local function safeName(v)
    local n = v
    if type(n) == "table" then
        for k, val in pairs(n) do
            if type(k) == "string" and k ~= "" then n = k break end
            if type(val) == "string" then n = val break end
        end
    end
    n = tostring(n or "default"):gsub("[^%w_%-]", "")
    if n == "" then n = "default" end
    return n
end

-- ===== Capture Config =====
local function CaptureConfig()
    return {
        __version = 3,
        __time = os.time(),

        -- Semua toggle / slider / dropdown / input di UI (setting yang kamu atur)
        Controls = (function()
            local out = {}
            for _, e in ipairs(Lib.ControlList) do
                local ok, v = pcall(e.get)
                if ok and v ~= nil then out[e.key] = v end
            end
            return out
        end)(),

        ParryCfg = {
            AutoParry = ParryCfg.AutoParry,
            ParrySafety = ParryCfg.ParrySafety,
            ParryAggressive = ParryCfg.ParryAggressive,
            ParryCircle = ParryCfg.ParryCircle,
            ParryRadius = ParryCfg.ParryRadius,
            ParryFace = ParryCfg.ParryFace,
        },

        KillerCfg = {
            BypassLeap = KillerCfg.BypassLeap,
        },

        CrouchCfg = {
            AutoCrouch = CrouchCfg.AutoCrouch,
            CrouchV = CrouchCfg.CrouchV,
        },

        FakePerks = {
            QuickRecoveryEnabled = FakePerks.QuickRecoveryEnabled,
            PerfectLandingEnabled = FakePerks.PerfectLandingEnabled,
            FlowstateEnabled = FakePerks.FlowstateEnabled,
            PerkCooldown = FakePerks.PerkCooldown,
        },

        DBD_Config = {
            Enabled = VD_CameraDBD and VD_CameraDBD.Enabled or false,
            Resolution = VD_CameraDBD and VD_CameraDBD.Resolution or 0.65,
        },

        ESPCfg = {
            Master = ESPCfg.Master,
            Player = ESPCfg.Player,
            Killer = ESPCfg.Killer,
            SCP = ESPCfg.SCP,
            Outline = ESPCfg.Outline,
            Name = ESPCfg.Name,
            Distance = ESPCfg.Distance,
            ItemIcon = ESPCfg.ItemIcon,
            KillerWarn = ESPCfg.KillerWarn,
            Generator = ESPCfg.Generator,
            GenName = ESPCfg.GenName,
            Pallet = ESPCfg.Pallet,
            Window = ESPCfg.Window,
            Hook = ESPCfg.Hook,
            Gate = ESPCfg.Gate,
            HookCount = ESPCfg.HookCount,
        },

        -- Skill Check pakai GeneConfig
        SkillCheckCfg = {
            Enabled = GeneConfig.Enabled,
            Mode    = GeneConfig.Mode,
        },

        -- Standalone
        FullBright     = FullBright,
        NoFog          = NoFog,
        NoShadow       = NoShadow,
        HookESPEnabled = HookESPEnabled,
        TimeOfDayValue = TimeOfDayValue,
    }
end

-- ===== Encode aman (buang NaN/inf/function/userdata, nilai non-JSON) =====
local function sanitize(v, depth)
    depth = depth or 0
    if depth > 8 then return nil end
    local t = type(v)
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return 0 end
        return v
    elseif t == "string" or t == "boolean" then
        return v
    elseif t == "table" then
        local out = {}
        for k, val in pairs(v) do
            if type(k) == "string" then
                local sv = sanitize(val, depth + 1)
                if sv ~= nil then out[k] = sv end
            end
        end
        return out
    elseif typeof(v) == "EnumItem" then
        return v.Name
    end
    return nil -- function / userdata / thread / nil
end

local function EncodeConfig()
    local okCap, cfg = pcall(CaptureConfig)
    if not okCap then return nil, "capture: " .. tostring(cfg) end
    local okEnc, json = pcall(function()
        return HttpService:JSONEncode(sanitize(cfg))
    end)
    if not okEnc then return nil, "encode: " .. tostring(json) end
    return json
end

-- ===== Apply Config =====
local function ApplyConfig(data)
    if type(data) ~= "table" then return false end

    -- Config versi baru: pasang ulang setiap kontrol UI (switch ikut bergeser
    -- + callback fitur jalan lagi, jadi fiturnya benar-benar aktif).
    if type(data.Controls) == "table" then
        Lib.Loading = true
        -- Master ESP dipasang paling akhir supaya sub-toggle sudah siap
        local deferred = {}
        for _, e in ipairs(Lib.ControlList) do
            local v = data.Controls[e.key]
            if v ~= nil then
                if e.key:find("Enable ESP %(Master%)") then
                    table.insert(deferred, { e, v })
                else
                    pcall(e.set, v)
                end
            end
        end
        for _, d in ipairs(deferred) do pcall(d[1].set, d[2]) end
        task.wait()
        Lib.Loading = false
        return true
    end

    local function merge(dst, src)
        if type(src) ~= "table" or type(dst) ~= "table" then return end
        for k, v in pairs(src) do
            if dst[k] ~= nil then dst[k] = v end
        end
    end

    merge(ParryCfg,   data.ParryCfg)
    merge(KillerCfg,  data.KillerCfg)
    merge(CrouchCfg,  data.CrouchCfg)
    merge(FakePerks,  data.FakePerks)
    if type(data.DBD_Config) == "table" and VD_CameraDBD then
        if data.DBD_Config.Enabled ~= nil then VD_CameraDBD.SetEnabled(data.DBD_Config.Enabled) end
        if data.DBD_Config.Resolution ~= nil then VD_CameraDBD.SetResolution(data.DBD_Config.Resolution) end
    end
    merge(ESPCfg,     data.ESPCfg)

    if type(data.SkillCheckCfg) == "table" then
        if data.SkillCheckCfg.Mode ~= nil then _G.SkillCfg.Mode = data.SkillCheckCfg.Mode end
        if data.SkillCheckCfg.Enabled ~= nil then _G.SkillCfg.Enabled = data.SkillCheckCfg.Enabled end
    end

    if data.FullBright     ~= nil then FullBright     = data.FullBright end
    if data.NoFog          ~= nil then NoFog          = data.NoFog end
    if data.NoShadow       ~= nil then NoShadow       = data.NoShadow end
    if data.HookESPEnabled ~= nil then HookESPEnabled = data.HookESPEnabled end
    if data.TimeOfDayValue ~= nil then TimeOfDayValue = data.TimeOfDayValue end

    -- Terapkan efek samping
    if ESPCfg.Master then
        pcall(ForceRefreshMap)
    else
        pcall(ClearAllESP)
    end

    if LP.Character then
        if FakePerks.QuickRecoveryEnabled  then pcall(setupQuickRecovery,  LP.Character) end
        if FakePerks.PerfectLandingEnabled then pcall(setupPerfectLanding, LP.Character) end
        if FakePerks.FlowstateEnabled      then pcall(setupFlowstate,      LP.Character) end
    end

    -- DBD Camera handled via VD_CameraDBD

    if FullBright then pcall(ApplyFullBright) end
    if NoFog      then pcall(ApplyNoFog)      end
    pcall(ApplyNoShadow)

    if HookESPEnabled then
        pcall(UpdateHookData)
        pcall(UpdateHookESP)
    else
        pcall(ClearHookESP)
    end

    return true
end

-- UI CONFIG
local SelectedConfig = "default"

-- Dropdown pilih config (auto-refresh)
local ConfigDropdown = SecConfigIO:AddDropdown({
    "Select Config",
    Options = listConfigs(),
    Default = "default",
    Callback = function(v)
        SelectedConfig = safeName(v)
    end,
})

-- Helper refresh dropdown (kalau library support SetValues)
local function refreshDropdown()
    pcall(function()
        if ConfigDropdown and ConfigDropdown.SetValues then
            ConfigDropdown:SetValues(listConfigs())
        elseif ConfigDropdown and ConfigDropdown.Set then
            ConfigDropdown:Set(listConfigs())
        end
    end)
end

-- Input nama manual (kalau dropdown gak muat banyak)
SecConfigIO:AddInput({
    "Config Name",
    "Tulis nama config baru...",
    "default",
    function(v)
        SelectedConfig = safeName(v)
    end,
})

SecConfigIO:AddButton({
    "Save Config",
    "Simpan setting ke file",
    function()
        ensureFolder()
        if not writefile then notif("Executor gak support writefile!") return end
        local json, err = EncodeConfig()
        if not json then
            warn("[RYNER] Save config gagal -> " .. tostring(err))
            notif("Gagal encode! " .. tostring(err):sub(1, 60))
            return
        end
        local path = CONFIG_FOLDER .. "/" .. SelectedConfig .. ".json"
        local w, werr = pcall(function() writefile(path, json) end)
        if w then
            notif("Saved: " .. SelectedConfig)
            refreshDropdown()
        else
            warn("[RYNER] writefile gagal -> " .. tostring(werr))
            notif("Gagal save!")
        end
    end,
})

SecConfigIO:AddButton({
    "Load Config",
    "Ambil setting dari file",
    function()
        if not readfile then notif("Executor gak support readfile!") return end
        local path = CONFIG_FOLDER .. "/" .. SelectedConfig .. ".json"
        if isfile and not isfile(path) then
            notif("File gak ada: " .. SelectedConfig)
            return
        end
        local ok, content = pcall(function() return readfile(path) end)
        if not ok or not content then notif("Gagal baca!") return end
        local dOk, data = pcall(function() return HttpService:JSONDecode(content) end)
        if not dOk or type(data) ~= "table" then notif("JSON rusak!") return end
        if ApplyConfig(data) then
            notif("Loaded: " .. SelectedConfig)
        else
            notif("Load gagal!")
        end
    end,
})

SecConfigIO:AddButton({
    "Delete Config",
    "Hapus file config",
    function()
        if not delfile then notif("Executor gak support delfile!") return end
        local path = CONFIG_FOLDER .. "/" .. SelectedConfig .. ".json"
        if isfile and isfile(path) then
            pcall(function() delfile(path) end)
            notif("Deleted: " .. SelectedConfig)
            refreshDropdown()
        else
            notif("File gak ada!")
        end
    end,
})

SecConfigIO:AddButton({
    "Refresh List",
    "Scan ulang folder config",
    function()
        refreshDropdown()
        notif("List refreshed")
    end,
})

-- ===== Auto-save =====
local AutoSaveEnabled = false
SecConfigIO:AddToggle({
    "Auto Save (15s)",
    false,
    function(v)
        AutoSaveEnabled = v
        notif("Auto Save: " .. (v and "ON" or "OFF"))
    end,
    "Auto save ke autosave.json tiap 15 detik",
})

task.spawn(function()
    while true do
        task.wait(15)
        if AutoSaveEnabled and writefile then
            ensureFolder()
            pcall(function()
                local json = EncodeConfig()
                if json then writefile(CONFIG_FOLDER .. "/autosave.json", json) end
            end)
        end
    end
end)

-- NOTIF
task.wait(1)
pcall(function()
    Lib:SetNotification({ Content = "RYNER HUB berhasil dimuat!", Delay = 3 })
end)

print("RYNER HUB Ready. Tap logo di kiri atas buat buka UI.")