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

local Custom = {}
do
	Custom.ColorRGB = Color3.fromRGB(180, 100, 255)
	Custom.GradientPinkWhite = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	Custom.DefaultIcon = "rbxassetid://106067976276511"

	function Custom:Create(Name, Props, Parent)
		local inst = Instance.new(Name)
		for k, v in pairs(Props) do inst[k] = v end
		if Parent then inst.Parent = Parent end
		return inst
	end

	function Custom:EnabledAFK()
		Player.Idled:Connect(function()
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
	end

	function Custom:AddGradient(inst, Rotation)
		return Custom:Create("UIGradient", { Color = Custom.GradientPinkWhite, Rotation = Rotation or 0 }, inst)
	end

	function Custom:Highlight(Frame)
		local Ring = Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 2, Transparency = 0, Parent = Frame })
		Custom:AddGradient(Ring)
		task.spawn(function()
			task.wait(1)
			local ft = TweenService:Create(Ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 })
			ft:Play() ft.Completed:Wait() Ring:Destroy()
		end)
	end

	function Custom:GetGuiParent()
		if RunService:IsStudio() then return Player.PlayerGui end
		if gethui then local ok, r = pcall(gethui) if ok and r then return r end end
		if cloneref then local ok, r = pcall(function() return cloneref(game:GetService("CoreGui")) end) if ok and r then return r end end
		return game:GetService("CoreGui")
	end
end

Custom:EnabledAFK()

local function CircleClick(Button, X, Y)
	task.spawn(function()
		Button.ClipsDescendants = true
		local Circle = Instance.new("ImageLabel")
		Circle.Image = "rbxassetid://106471194043211" Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
		Circle.ImageTransparency = 0.9 Circle.BackgroundTransparency = 1
		Circle.ZIndex = 10 Circle.Name = "Circle" Circle.Parent = Button
		local NX = X - Button.AbsolutePosition.X
		local NY = Y - Button.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NX, 0, NY)
		local Sz = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
		local Tw = TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, Sz, 0, Sz), Position = UDim2.new(0.5, -Sz / 2, 0.5, -Sz / 2)
		})
		Tw:Play()
		Tw.Completed:Connect(function()
			for i = 1, 10 do Circle.ImageTransparency = Circle.ImageTransparency + 0.01 task.wait(0.05) end
			Circle:Destroy()
		end)
	end)
end

local RYNERHub_Library = {}
RYNERHub_Library.Unloaded = false

local NotifGui, NotifContainer, NotifCounter = nil, nil, 0
local NOTIF_WIDTH = 260

local function EnsureNotifGui()
	if NotifGui and NotifGui.Parent then return end
	NotifGui = Custom:Create("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, DisplayOrder = 1000,
	}, Custom:GetGuiParent())
	NotifContainer = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0, 14), Size = UDim2.new(0, NOTIF_WIDTH, 1, -28), Name = "NotifContainer",
	}, NotifGui)
	Custom:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8),
	}, NotifContainer)
end

function RYNERHub_Library:SetNotification(Config)
	EnsureNotifGui()
	local Text = Config.Content or Config[1] or ""
	local Delay = tonumber(Config.Delay or Config[6]) or 3
	local AnimT = tonumber(Config.Time or Config[5]) or 0.25
	NotifCounter = NotifCounter + 1
	local Closed, BarTween = false, nil
	local NF = {}

	local TSz = TextService:GetTextSize(Text, 13, Enum.Font.GothamBold, Vector2.new(NOTIF_WIDTH - 24, 1000))
	local CardH = math.max(TSz.Y + 22, 34)

	local Slot = Custom:Create("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
		LayoutOrder = NotifCounter, Size = UDim2.new(1, 0, 0, CardH), Name = "NotifSlot",
	}, NotifContainer)

	local Card = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(42, 42, 46), BackgroundTransparency = 0.06, BorderSizePixel = 0,
		Position = UDim2.new(1, NOTIF_WIDTH + 20, 0, 0), Size = UDim2.new(1, 0, 1, 0), Name = "Card",
	}, Slot)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Card)
	Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = Text, TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center, BackgroundTransparency = 1,
		BorderSizePixel = 0, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -20, 1, -8), Name = "Label",
	}, Card)

	local BarTrack = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9, BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -4), Size = UDim2.new(1, -16, 0, 2), Name = "BarTrack",
	}, Card)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, BarTrack)
	local Bar = Custom:Create("Frame", {
		BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), Name = "Bar",
	}, BarTrack)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Bar)

	TweenService:Create(Card, TweenInfo.new(AnimT, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.spawn(function()
		BarTween = TweenService:Create(Bar, TweenInfo.new(Delay, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
		BarTween:Play()
		BarTween.Completed:Connect(function(State)
			if State == Enum.PlaybackState.Completed and not Closed then NF:Close() end
		end)
	end)

	local function DoClose()
		if Closed then return end Closed = true
		if BarTween then pcall(function() BarTween:Cancel() end) end
		local Out = TweenService:Create(Card, TweenInfo.new(AnimT, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, NOTIF_WIDTH + 20, 0, 0)
		})
		Out:Play() Out.Completed:Wait()
		if Slot and Slot.Parent then Slot:Destroy() end
	end

	function NF:Close() task.spawn(DoClose) end
	return NF
end

function RYNERHub_Library:CreateWindow(Config)
	local Title = Config[1] or Config.Title or ""
	local Desc = Config[2] or Config.Description or ""
	local TabWidth = Config[3] or Config["Tab Width"] or 105
	local SizeUi = Config[4] or Config.SizeUi or UDim2.fromOffset(480, 275)
	local Keybind = Config[5] or Config.Keybind or Enum.KeyCode.RightControl
	local Icon = Config[6] or Config.Icon or "rbxassetid://106067976276511"
	local Funcs = {}
	local SearchRegistry = {}

	local RYNERHubGui = Custom:Create("ScreenGui", { ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, Custom:GetGuiParent())

	local DropShadowHolder = Custom:Create("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(0, 400, 0, 310), ZIndex = 0,
		Name = "DropShadowHolder",
		Position = UDim2.new(0, (RYNERHubGui.AbsoluteSize.X // 2 - 400 // 2), 0, (RYNERHubGui.AbsoluteSize.Y // 2 - 310 // 2)),
	}, RYNERHubGui)

	local DropShadow = Custom:Create("ImageLabel", {
		Image = "", ImageColor3 = Color3.fromRGB(15, 15, 15), ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = SizeUi, ZIndex = 0, Name = "DropShadow",
	}, DropShadowHolder)

	local Main = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		BackgroundTransparency = 0.1, BorderSizePixel = 0, ClipsDescendants = true,
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = SizeUi, Name = "Main",
	}, DropShadow)
	Custom:Create("UICorner", {}, Main)
	Custom:Create("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1.6 }, Main)

	do
		local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
		Main.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true mousePos = i.Position framePos = DropShadowHolder.Position
				i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		Main.InputChanged:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
				dragInput = i
			end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging and dragInput then
				local d = dragInput.Position - mousePos
				DropShadowHolder.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + d.X, framePos.Y.Scale, framePos.Y.Offset + d.Y)
			end
		end)
	end

	local Top = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.999,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 38), Name = "Top",
	}, Main)
	Custom:Create("UICorner", {}, Top)

	local TextLabel = Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = Title, TextColor3 = Custom.ColorRGB, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 0.999,
		BorderSizePixel = 0, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0),
	}, Top)

	local IconWidth = 0
	if Icon ~= "" then
		IconWidth = 34
		Custom:Create("ImageLabel", {
			Image = Icon, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
			BorderSizePixel = 0, Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(0, 28, 0, 28), Name = "Icon",
		}, Top)
		TextLabel.Position = UDim2.new(0, 10 + IconWidth, 0, 0)
	end

	local Separator = Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = "|", TextColor3 = Color3.fromRGB(90, 90, 90), TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(0, 12, 1, 0),
		Position = UDim2.new(0, 10 + IconWidth + TextLabel.TextBounds.X + 8, 0, 0), Name = "Separator",
	}, Top)

	local TextLabel1 = Custom:Create("TextLabel", {
		Font = Enum.Font.Gotham, Text = Desc, TextColor3 = Color3.fromRGB(120, 120, 120), TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0, Separator.Position.X.Offset + 14, 0, 0),
	}, Top)

	local Close, Min
	local TagsFuncs = {}
	local TagList = {}
	local MAX_TAGS = 3

	local function RelayoutTags()
		local TotalWidth = 0
		for i, d in ipairs(TagList) do
			TotalWidth = TotalWidth + d.Frame.Size.X.Offset
			if i < #TagList then TotalWidth = TotalWidth + 6 end
		end
		local DescEndX = TextLabel1.Position.X.Offset + TextLabel1.TextBounds.X + 12
		local MinLeftX = Min and ((Min.AbsolutePosition.X - Top.AbsolutePosition.X) - 10) or (DescEndX + TotalWidth)
		local StartX = math.max(DescEndX, MinLeftX - TotalWidth)
		local OffsetX = StartX
		for _, d in ipairs(TagList) do
			d.Frame.Position = UDim2.new(0, OffsetX, 0.5, 0)
			OffsetX = OffsetX + d.Frame.Size.X.Offset + 6
		end
	end

	function TagsFuncs:Add(Text)
		if #TagList >= MAX_TAGS then return { Frame = nil, Set = function() end, Remove = function() end } end
		Text = Text or "Tag"
		local TagFrame = Custom:Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9, BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 10, 0, 20), Name = "Tag",
		}, Top)
		Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, TagFrame)
		Custom:Create("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 1, Transparency = 0.4 }, TagFrame)
		local TagLabel = Custom:Create("TextLabel", {
			Font = Enum.Font.GothamBold, Text = Text, TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Name = "TagLabel",
		}, TagFrame)

		local TagEntry = { Frame = TagFrame, Label = TagLabel }
		local TIF = { Frame = TagFrame }
		table.insert(TagList, TagEntry)

		function TIF:Set(NewText)
			TagLabel.Text = NewText
			local function R()
				TagFrame.Size = UDim2.new(0, TagLabel.TextBounds.X + 16, 0, 20)
				RelayoutTags()
			end
			R() task.defer(R)
		end
		function TIF:Remove()
			for i, v in ipairs(TagList) do if v == TagEntry then table.remove(TagList, i) break end end
			TagFrame:Destroy() RelayoutTags()
		end
		TIF:Set(Text)
		return TIF
	end

	function TagsFuncs:AddDynamic(Label, ValueFn, RefreshInterval)
		Label = Label or "" ValueFn = ValueFn or function() return "" end
		local function CT()
			local Ok, Value = pcall(ValueFn)
			Value = (Ok and Value ~= nil and tostring(Value)) or "Unknown"
			return (Label ~= "" and (Label .. ": " .. Value)) or Value
		end
		local TIF = TagsFuncs:Add("* " .. CT())
		if RefreshInterval then
			task.spawn(function()
				while TIF.Frame and TIF.Frame.Parent do
					task.wait(RefreshInterval)
					if not (TIF.Frame and TIF.Frame.Parent) then break end
					TIF:Set("* " .. CT())
				end
			end)
		end
		return TIF
	end

	function TagsFuncs:AddExecutorTag(RefreshInterval)
		return TagsFuncs:AddDynamic("Executor", function() return SafeGetExecutor() end, RefreshInterval)
	end

	Funcs.Tags = TagsFuncs

	function Funcs:SetTitle(NewTitle)
		TextLabel.Text = NewTitle
		Separator.Position = UDim2.new(0, 10 + IconWidth + TextLabel.TextBounds.X + 8, 0, 0)
		TextLabel1.Position = UDim2.new(0, Separator.Position.X.Offset + 14, 0, 0)
		RelayoutTags()
	end
	function Funcs:SetDescription(NewDescription)
		TextLabel1.Text = NewDescription RelayoutTags()
	end

	Close = Custom:Create("TextButton", {
		Font = Enum.Font.GothamBold, Text = "✕", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15,
		AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 30, 0, 26), Name = "Close",
	}, Top)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Close)

	Min = Custom:Create("TextButton", {
		Font = Enum.Font.GothamBold, Text = "─", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
		AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Position = UDim2.new(1, -42, 0.5, 0), Size = UDim2.new(0, 22, 0, 22), Name = "Min",
	}, Top)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Min)

	if Config.Tags or Config[7] then
		for _, TagText in ipairs(Config.Tags or Config[7]) do TagsFuncs:Add(TagText) end
	end

	-- ============================================================
	-- FLOATING TOGGLE BUTTON (dipindah masuk ke library)
	-- Posisi: kiri tengah layar, offset -27
	-- Ukuran: 55x55
	-- ============================================================
	local FloatingBtn = Custom:Create("ImageButton", {
		Name = "FloatingToggle",
		Size = UDim2.new(0, 55, 0, 55),
		Position = UDim2.new(0, 20, 0.5, -27),
		BackgroundColor3 = Color3.fromRGB(30, 30, 38),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Active = true,
		Image = Icon,
		ImageColor3 = Custom.ColorRGB,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 9999,
	}, RYNERHubGui)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, FloatingBtn)

	Custom:Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, FloatingBtn)

	local FloatingStroke = Custom:Create("UIStroke", {
		Color = Custom.ColorRGB, Thickness = 2, Transparency = 0.1,
	}, FloatingBtn)

	-- Drag handler untuk FloatingBtn
	do
		local dragging, dragStart, startPos, moved = false, nil, nil, false
		local DRAG_THRESHOLD = 8

		FloatingBtn.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1
			   or i.UserInputType == Enum.UserInputType.Touch then
				dragging, moved = true, false
				dragStart = i.Position
				startPos = FloatingBtn.Position
			end
		end)
		FloatingBtn.InputChanged:Connect(function(i)
			if not dragging then return end
			if i.UserInputType == Enum.UserInputType.MouseMovement
			   or i.UserInputType == Enum.UserInputType.Touch then
				local d = i.Position - dragStart
				if d.Magnitude > DRAG_THRESHOLD then moved = true end
				if moved then
					FloatingBtn.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + d.X,
						startPos.Y.Scale, startPos.Y.Offset + d.Y
					)
				end
			end
		end)
		FloatingBtn.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1
			   or i.UserInputType == Enum.UserInputType.Touch then
				task.wait(0.05)
				if dragging and not moved then
					Funcs:Toggle()
				end
				dragging, moved = false, false
			end
		end)
	end

	local function UpdateFloatingColor()
		local open = DropShadowHolder.Visible
		FloatingBtn.ImageColor3 = open and Custom.ColorRGB or Color3.fromRGB(70, 40, 110)
		FloatingStroke.Color = FloatingBtn.ImageColor3
	end

	-- API utama: SetOpen / Toggle / IsOpen
	local function SetOpen(State)
		State = State and true or false
		DropShadowHolder.Visible = State
		UpdateFloatingColor()
	end

	Funcs.SetOpen = SetOpen
	Funcs.Toggle = function() SetOpen(not DropShadowHolder.Visible) end
	Funcs.IsOpen = function() return DropShadowHolder.Visible end

	UpdateFloatingColor()

	-- Min: sembunyikan window (tombol floating tetap ada)
	Min.Activated:Connect(function()
		CircleClick(Min, Player:GetMouse().X, Player:GetMouse().Y)
		SetOpen(false)
	end)

	-- Keybind RC: toggle buka/tutup
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Keybind then
			SetOpen(not DropShadowHolder.Visible)
		end
	end)

	-- ============================================================
	-- Lanjut seperti biasa (tab, section, dll.)
	-- ============================================================

	local LayersTab = Custom:Create("Frame", {
		BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Position = UDim2.new(0, 9, 0, 50), Size = UDim2.new(0, TabWidth, 1, -59), Name = "LayersTab",
	}, Main)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, LayersTab)

	local SearchBoxContainer = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
		BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 0, 24), Name = "SBC",
	}, LayersTab)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SearchBoxContainer)

	local SearchIcon = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 7, 0.5, 0), Size = UDim2.new(0, 11, 0, 11), ZIndex = 2, Name = "SI",
	}, SearchBoxContainer)
	local SearchIconLens = Custom:Create("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 8, 0, 8), Name = "Lens",
	}, SearchIcon)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SearchIconLens)
	local LensStroke = Custom:Create("UIStroke", { Color = Color3.fromRGB(150, 150, 150), Thickness = 1.4 }, SearchIconLens)
	local SearchHandle = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(150, 150, 150),
		BorderSizePixel = 0, Rotation = 45, Position = UDim2.new(0, 9, 0, 9), Size = UDim2.new(0, 1.6, 0, 5), Name = "Handle",
	}, SearchIcon)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SearchHandle)

	local SearchBox = Custom:Create("TextBox", {
		Font = Enum.Font.GothamBold, PlaceholderText = "Search...", PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		Text = "", TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, BackgroundTransparency = 1, BorderSizePixel = 0,
		ZIndex = 2, Position = UDim2.new(0, 24, 0, 0), Size = UDim2.new(1, -30, 1, 0), Name = "SearchBox",
	}, SearchBoxContainer)

	SearchBox.Focused:Connect(function()
		TweenService:Create(LensStroke, TweenInfo.new(0.15), { Color = Custom.ColorRGB }):Play()
		TweenService:Create(SearchHandle, TweenInfo.new(0.15), { BackgroundColor3 = Custom.ColorRGB }):Play()
	end)
	SearchBox.FocusLost:Connect(function()
		TweenService:Create(LensStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(150, 150, 150) }):Play()
		TweenService:Create(SearchHandle, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(150, 150, 150) }):Play()
	end)

	Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 38),
		Size = UDim2.new(1, 0, 0, 1), Name = "DecideFrame",
	}, Main)

	local Layers = Custom:Create("Frame", {
		BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Position = UDim2.new(0, TabWidth + 18, 0, 50), Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59), Name = "Layers",
	}, Main)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, Layers)

	local NameTab = Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = "", TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 24, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 0.999, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Name = "NameTab",
	}, Layers)

	local LayersReal = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 0.999, BorderSizePixel = 0,
		ClipsDescendants = true, Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 1, -33), Name = "LayersReal",
	}, Layers)

	local LayersFolder = Custom:Create("Folder", { Name = "LayersFolder" }, LayersReal)

	local ScrollTab = Custom:Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 2.1, 0), ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
		ScrollBarThickness = 0, Active = true, BackgroundTransparency = 0.999, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 1, -80), Name = "ScrollTab",
	}, LayersTab)
	Custom:Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, ScrollTab)

	local AvatarFooter = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.94, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 40), Name = "AvatarFooter",
	}, LayersTab)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, AvatarFooter)

	local AvatarImage = Custom:Create("ImageLabel", {
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0,
		Position = UDim2.new(0, 5, 0.5, 0), Size = UDim2.new(0, 28, 0, 28), Name = "AvatarImage",
	}, AvatarFooter)
	Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, AvatarImage)
	Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.3 }, AvatarImage)

	local function CensorName(Name)
		if #Name <= 3 then return Name end
		return Name:sub(1, 3) .. "***"
	end
	Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = "Welcome, " .. CensorName(Player.Name),
		TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 11, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(1, -45, 1, 0), Name = "WelcomeLabel",
	}, AvatarFooter)

	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and url then AvatarImage.Image = url end
	end)

	local SearchPopup = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 22, 22), BackgroundTransparency = 0.02,
		BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 0), Visible = false, ZIndex = 20, Name = "SearchPopup",
	}, LayersTab)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SearchPopup)
	Custom:Create("UIStroke", { Color = Color3.fromRGB(60, 60, 60), Thickness = 1, Transparency = 0.3 }, SearchPopup)
	Custom:Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, SearchPopup)

	local function UpdateScrollSize()
		local total = 0
		for _, v in pairs(ScrollTab:GetChildren()) do
			if v.Name ~= "UIListLayout" then total = total + 3 + v.Size.Y.Offset end
		end
		ScrollTab.CanvasSize = UDim2.new(0, 0, 0, total)
	end
	ScrollTab.ChildAdded:Connect(UpdateScrollSize)
	ScrollTab.ChildRemoved:Connect(UpdateScrollSize)

	local function RegisterSearch(Title, TargetFrame, Subtitle, SelectTabFn, EnsureOpenFn, ScrollFrameRef)
		if Title == "" then return end
		table.insert(SearchRegistry, { Title = Title, Subtitle = Subtitle or "", TargetFrame = TargetFrame, SelectTab = SelectTabFn, EnsureOpen = EnsureOpenFn, ScrollFrame = ScrollFrameRef })
	end

	local function ClearSearchPopup()
		for _, v in pairs(SearchPopup:GetChildren()) do if v.Name == "ResultRow" then v:Destroy() end end
	end

	local function HideSearchPopup()
		SearchPopup.Visible = false SearchPopup.Size = UDim2.new(1, 0, 0, 0)
		ScrollTab.Visible = true ClearSearchPopup()
	end

	local function ScrollIntoView(SF, TF)
		task.wait(0.15)
		local ry = (TF.AbsolutePosition.Y - SF.AbsolutePosition.Y) + SF.CanvasPosition.Y
		TweenService:Create(SF, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, math.max(ry - 20, 0))
		}):Play()
	end

	local function RunSearch(Query)
		Query = string.lower(Query) HideSearchPopup()
		if Query == "" then return end
		local Matches = {}
		for _, e in ipairs(SearchRegistry) do
			if string.find(string.lower(e.Title), Query, 1, true) then
				table.insert(Matches, e) if #Matches >= 8 then break end
			end
		end
		if #Matches == 0 then return end
		ScrollTab.Visible = false
		for i, Entry in ipairs(Matches) do
			local Row = Custom:Create("TextButton", {
				Font = Enum.Font.SourceSans, Text = "", AutoButtonColor = false,
				BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = i,
				Size = UDim2.new(1, 0, 0, 38), Name = "ResultRow",
			}, SearchPopup)
			if i < #Matches then
				Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					BorderSizePixel = 0, Position = UDim2.new(0, 8, 1, 0), Size = UDim2.new(1, -16, 0, 1), Name = "Divider",
				}, Row)
			end
			local Accent = Custom:Create("Frame", {
				BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0, 13), Size = UDim2.new(0, 1, 0, 12), Name = "RA",
			}, Row)
			Custom:AddGradient(Accent, 90)
			Custom:AddGradient(Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.6 }, Accent), 90)
			Custom:Create("TextLabel", {
				Font = Enum.Font.GothamBold, Text = Entry.Title, TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -14, 0, 15), Name = "RT",
			}, Row)
			Custom:Create("TextLabel", {
				Font = Enum.Font.Gotham, Text = Entry.Subtitle, TextColor3 = Color3.fromRGB(150, 150, 150),
				TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 20), Size = UDim2.new(1, -14, 0, 12), Name = "RS",
			}, Row)
			local HL = Custom:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Row.ZIndex - 1, Name = "RH",
			}, Row)
			Row.MouseEnter:Connect(function() TweenService:Create(HL, TweenInfo.new(0.12), { BackgroundTransparency = 0.94 }):Play() end)
			Row.MouseLeave:Connect(function() TweenService:Create(HL, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play() end)
			Row.Activated:Connect(function()
				SearchBox.Text = "" HideSearchPopup()
				if Entry.SelectTab then Entry.SelectTab() end
				task.spawn(function()
					task.wait(0.1) if Entry.EnsureOpen then Entry.EnsureOpen() end
					if Entry.ScrollFrame and Entry.TargetFrame then ScrollIntoView(Entry.ScrollFrame, Entry.TargetFrame) end
					task.wait(0.3) if Entry.TargetFrame then Custom:Highlight(Entry.TargetFrame) end
				end)
			end)
		end
		SearchPopup.Size = UDim2.new(1, 0, 0, math.min(#Matches * 38, 220))
		SearchPopup.Visible = true
	end
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function() RunSearch(SearchBox.Text) end)

	local ExitBackdrop = Custom:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 49, Name = "ExitBackdrop",
	}, Main)
	local ExitConfirm = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 260, 0, 118),
		Visible = false, ZIndex = 50, Name = "ExitConfirm",
	}, Main)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, ExitConfirm)
	Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = "Close Window", TextColor3 = Color3.fromRGB(235, 235, 235),
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34), ZIndex = 51, Name = "ExitTitle",
	}, ExitConfirm)
	Custom:Create("TextLabel", {
		Font = Enum.Font.GothamBold, Text = "WANT TO CLOSE THIS SCRIPT?",
		TextColor3 = Color3.fromRGB(160, 160, 160), TextSize = 12, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 40), Size = UDim2.new(1, -24, 0, 30), ZIndex = 51, Name = "ExitDesc",
	}, ExitConfirm)
	local CancelButton = Custom:Create("TextButton", {
		Font = Enum.Font.GothamBold, Text = "Cancel", TextColor3 = Color3.fromRGB(225, 225, 225), TextSize = 13,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45), BorderSizePixel = 0, ZIndex = 51,
		Position = UDim2.new(0, 12, 1, -42), Size = UDim2.new(0.5, -18, 0, 30), Name = "CancelButton",
	}, ExitConfirm)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, CancelButton)
	local ExitButton = Custom:Create("TextButton", {
		Font = Enum.Font.GothamBold, Text = "Close", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13,
		BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0, ZIndex = 51,
		Position = UDim2.new(0.5, 6, 1, -42), Size = UDim2.new(0.5, -18, 0, 30), Name = "ExitButton",
	}, ExitConfirm)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, ExitButton)

	local function ShowExitConfirm()
		ExitBackdrop.Visible = true ExitConfirm.Visible = true
		ExitBackdrop.BackgroundTransparency = 1 ExitConfirm.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(ExitBackdrop, TweenInfo.new(0.2), { BackgroundTransparency = 0.45 }):Play()
		TweenService:Create(ExitConfirm, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 260, 0, 118) }):Play()
	end
	local function HideExitConfirm()
		TweenService:Create(ExitBackdrop, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		local Shrink = TweenService:Create(ExitConfirm, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
		Shrink:Play() Shrink.Completed:Wait()
		ExitConfirm.Visible = false ExitBackdrop.Visible = false
	end
	CancelButton.Activated:Connect(function()
		CircleClick(CancelButton, Player:GetMouse().X, Player:GetMouse().Y)
		task.spawn(HideExitConfirm)
	end)
	ExitButton.Activated:Connect(function()
		CircleClick(ExitButton, Player:GetMouse().X, Player:GetMouse().Y)
		task.spawn(function() HideExitConfirm() if RYNERHubGui then RYNERHubGui:Destroy() end end)
	end)
	Close.Activated:Connect(function()
		CircleClick(Close, Player:GetMouse().X, Player:GetMouse().Y)
		ShowExitConfirm()
	end)

	local Tabs = {}
	local ActiveTab = nil

	function Funcs:AddTab(Config)
		local TabName = Config[1] or Config.Name or Config.Title or "Tab"
		local TabIcon = Config[2] or Config.Icon or ""

		local TabBtn = Custom:Create("TextButton", {
			Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
			BackgroundTransparency = 0.999, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30), Name = TabName .. "TabBtn",
		}, ScrollTab)
		local TabIndicator = Custom:Create("Frame", {
			Name = "Indicator", BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0,
			Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, 0, 0, 12), Visible = false,
		}, TabBtn)
		Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, TabIndicator)
		Custom:AddGradient(Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.5 }, TabIndicator))
		if TabIcon ~= "" then
			Custom:Create("ImageLabel", {
				Image = TabIcon, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
				BorderSizePixel = 0, Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), Name = "TabIcon",
			}, TabBtn)
		end
		local TabLabel = Custom:Create("TextLabel", {
			Font = Enum.Font.GothamBold, Text = TabName, TextColor3 = Color3.fromRGB(180, 180, 180),
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
			Position = UDim2.new(0, TabIcon ~= "" and 38 or 16, 0, 0), Size = UDim2.new(1, -50, 1, 0), Name = "TabLabel",
		}, TabBtn)

		local TabFrame = Custom:Create("ScrollingFrame", {
			BackgroundTransparency = 0.999, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, ScrollBarImageColor3 = Custom.ColorRGB,
			Name = TabName .. "Frame", Visible = false,
		}, LayersFolder)
		local TabLayout = Custom:Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, TabFrame)
		Custom:Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, TabFrame)
		TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 24)
		end)

		local TabFuncs = { Frame = TabFrame, Button = TabBtn }

		local function SelectTab()
			if ActiveTab then
				local OI = ActiveTab.Button:FindFirstChild("Indicator")
				local OL = ActiveTab.Button:FindFirstChild("TabLabel")
				if OI then
					TweenService:Create(OI, TweenInfo.new(0.15), { Size = UDim2.new(0, 0, 0, 12) }):Play()
					task.delay(0.15, function() OI.Visible = false end)
				end
				if OL then TweenService:Create(OL, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(180, 180, 180) }):Play() end
			end

			for _, tab in ipairs(Tabs) do
				tab.Frame.Visible = false
			end

			ActiveTab = TabFuncs
			TabFrame.Visible = true
			NameTab.Text = TabName

			task.defer(function()
				task.wait(0.05)
				TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 24)
				TabFrame.CanvasPosition = Vector2.new(0, 0)
			end)

			TabIndicator.Visible = true
			TweenService:Create(TabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 3, 0, 16) }):Play()
			TweenService:Create(TabLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
		TabBtn.Activated:Connect(function() CircleClick(TabBtn, Player:GetMouse().X, Player:GetMouse().Y) SelectTab() end)
		TabFuncs.Select = SelectTab
		table.insert(Tabs, TabFuncs)
		if #Tabs == 1 then SelectTab() end

		function TabFuncs:AddSection(SectionConfig)
			if type(SectionConfig) == "string" then SectionConfig = { SectionConfig } end
			local SectionName = SectionConfig[1] or SectionConfig.Name or SectionConfig.Title or "Section"

			local SectionFrame = Custom:Create("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.95,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Name = SectionName .. "Section",
			}, TabFrame)
			Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, SectionFrame)
			Custom:Create("TextLabel", {
				Font = Enum.Font.GothamBold, Text = SectionName, TextColor3 = Custom.ColorRGB,
				TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -20, 0, 30), Name = "SectionTitle",
			}, SectionFrame)

			local SectionContent = Custom:Create("Frame", {
				BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 30),
				Size = UDim2.new(1, 0, 0, 0), Name = "SectionContent",
			}, SectionFrame)
			local ContentLayout = Custom:Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, SectionContent)
			Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, SectionContent)
			ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionContent.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 8)
				SectionFrame.Size = UDim2.new(1, 0, 0, 30 + SectionContent.Size.Y.Offset)
			end)

			local SecFuncs = {}

			function SecFuncs:AddButton(ButtonConfig)
				local ButtonName = ButtonConfig[1] or ButtonConfig.Name or "Button"
				local ButtonDesc = ButtonConfig[2] or ButtonConfig.Description or ButtonConfig.Content or ""
				local Callback = ButtonConfig[3] or ButtonConfig.Callback or function() end
				local Btn = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Name = ButtonName .. "Btn",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Btn)
				local BtnLabel = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = ButtonName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, ButtonDesc ~= "" and 0.6 or 1, 0), Name = "BtnLabel",
				}, Btn)
				if ButtonDesc ~= "" then
					Custom:Create("TextLabel", {
						Font = Enum.Font.Gotham, Text = ButtonDesc, TextColor3 = Color3.fromRGB(140, 140, 140),
						TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0.6, 0), Size = UDim2.new(1, -20, 0.4, 0), Name = "BtnDesc",
					}, Btn)
				end
				Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play() end)
				Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.92 }):Play() end)
				Btn.Activated:Connect(function() CircleClick(Btn, Player:GetMouse().X, Player:GetMouse().Y) task.spawn(Callback) end)
				RegisterSearch(ButtonName, Btn, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return { Button = Btn, SetText = function(t) BtnLabel.Text = t end }
			end

			function SecFuncs:AddToggle(ToggleConfig)
				local ToggleName = ToggleConfig[1] or ToggleConfig.Name or "Toggle"
				local Default = ToggleConfig[2] or ToggleConfig.Default or false
				local Callback = ToggleConfig[3] or ToggleConfig.Callback or function() end
				local ToggleFrame = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Name = ToggleName .. "Toggle",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, ToggleFrame)
				local ToggleLabel = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = ToggleName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -60, 1, 0), Name = "ToggleLabel",
				}, ToggleFrame)
				local ToggleDesc = ToggleConfig.Content or ToggleConfig.Description or ToggleConfig[4]
				if ToggleDesc and ToggleDesc ~= "" then
					ToggleLabel.Size = UDim2.new(1, -60, 0.6, 0)
					Custom:Create("TextLabel", {
						Font = Enum.Font.Gotham, Text = ToggleDesc, TextColor3 = Color3.fromRGB(140, 140, 140),
						TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0.6, 0), Size = UDim2.new(1, -60, 0.4, 0), Name = "ToggleDesc",
					}, ToggleFrame)
				end
				local SwitchBg = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					BorderSizePixel = 0, Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 36, 0, 18), Name = "SwitchBg",
				}, ToggleFrame)
				Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SwitchBg)
				local SwitchDot = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					BorderSizePixel = 0, Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.new(0, 14, 0, 14), Name = "SwitchDot",
				}, SwitchBg)
				Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SwitchDot)
				local ToggleState = Default
				local function UpdateToggle(State, Animate)
					ToggleState = State
					if Animate then
						TweenService:Create(SwitchBg, TweenInfo.new(0.2), { BackgroundColor3 = State and Custom.ColorRGB or Color3.fromRGB(50, 50, 50) }):Play()
						TweenService:Create(SwitchDot, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Position = State and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
							BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
						}):Play()
					else
						SwitchBg.BackgroundColor3 = State and Custom.ColorRGB or Color3.fromRGB(50, 50, 50)
						SwitchDot.Position = State and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
						SwitchDot.BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
					end
				end
				UpdateToggle(Default, false)
				ToggleFrame.Activated:Connect(function()
					CircleClick(ToggleFrame, Player:GetMouse().X, Player:GetMouse().Y)
					UpdateToggle(not ToggleState, true) task.spawn(Callback, ToggleState)
				end)
				RegisterSearch(ToggleName, ToggleFrame, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return {
					Toggle = ToggleFrame,
					Set = function(State) UpdateToggle(State, true) task.spawn(Callback, State) end,
					Get = function() return ToggleState end,
				}
			end

			function SecFuncs:AddSlider(SliderConfig)
				local SliderName = SliderConfig[1] or SliderConfig.Name or "Slider"
				local MinVal = SliderConfig[2] or SliderConfig.Min or 0
				local MaxVal = SliderConfig[3] or SliderConfig.Max or 100
				local Default = SliderConfig[4] or SliderConfig.Default or MinVal
				local Callback = SliderConfig[5] or SliderConfig.Callback or function() end
				local Increment = SliderConfig.Increment or 1
				local SliderFrame = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46), Name = SliderName .. "Slider",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, SliderFrame)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = SliderName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 4), Size = UDim2.new(1, -60, 0, 16), Name = "SliderLabel",
				}, SliderFrame)
				local ValueLabel = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = tostring(Default), TextColor3 = Custom.ColorRGB,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1,
					Position = UDim2.new(1, -60, 0, 4), Size = UDim2.new(0, 50, 0, 16), Name = "ValueLabel",
				}, SliderFrame)
				local BarBg = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(50, 50, 50),
					BorderSizePixel = 0, Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 6), Name = "BarBg",
				}, SliderFrame)
				Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, BarBg)
				local BarFill = Custom:Create("Frame", {
					BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0,
					Size = UDim2.new((Default - MinVal) / (MaxVal - MinVal), 0, 1, 0), Name = "BarFill",
				}, BarBg)
				Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, BarFill)
				Custom:AddGradient(BarFill)
				local SliderDot = Custom:Create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0, Position = UDim2.new((Default - MinVal) / (MaxVal - MinVal), 0, 0.5, 0),
					Size = UDim2.new(0, 12, 0, 12), ZIndex = 2, Name = "SliderDot",
				}, BarBg)
				Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SliderDot)
				Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.5 }, SliderDot)
				local Dragging = false local CurrentValue = Default
				local function UpdateSlider(Input)
					local BarX = BarBg.AbsolutePosition.X local BarW = BarBg.AbsoluteSize.X
					local Percent = math.clamp((Input.Position.X - BarX) / BarW, 0, 1)
					local raw = MinVal + (MaxVal - MinVal) * Percent
					CurrentValue = math.floor(raw / Increment + 0.5) * Increment
					if Increment >= 1 then CurrentValue = math.floor(CurrentValue) end
					ValueLabel.Text = tostring(CurrentValue)
					BarFill.Size = UDim2.new(Percent, 0, 1, 0) SliderDot.Position = UDim2.new(Percent, 0, 0.5, 0)
					task.spawn(Callback, CurrentValue)
				end
				BarBg.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
						Dragging = true UpdateSlider(i)
					end
				end)
				BarBg.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(i) end
				end)
				RegisterSearch(SliderName, SliderFrame, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return {
					Slider = SliderFrame,
					Set = function(Value)
						CurrentValue = math.clamp(Value, MinVal, MaxVal)
						local Percent = (CurrentValue - MinVal) / (MaxVal - MinVal)
						ValueLabel.Text = tostring(CurrentValue)
						BarFill.Size = UDim2.new(Percent, 0, 1, 0) SliderDot.Position = UDim2.new(Percent, 0, 0.5, 0)
						task.spawn(Callback, CurrentValue)
					end,
					Get = function() return CurrentValue end,
				}
			end

			function SecFuncs:AddInput(InputConfig)
				local InputName = InputConfig[1] or InputConfig.Name or "Input"
				local Placeholder = InputConfig[2] or InputConfig.Placeholder or "Enter text..."
				local Default = InputConfig[3] or InputConfig.Default or ""
				local Callback = InputConfig[4] or InputConfig.Callback or function() end
				local InputFrame = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46), Name = InputName .. "Input",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, InputFrame)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = InputName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 4), Size = UDim2.new(1, -20, 0, 16), Name = "InputLabel",
				}, InputFrame)
				local InputBox = Custom:Create("TextBox", {
					Font = Enum.Font.Gotham, Text = Default, PlaceholderText = Placeholder,
					PlaceholderColor3 = Color3.fromRGB(120, 120, 120), TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0,
					Position = UDim2.new(0, 10, 1, -26), Size = UDim2.new(1, -20, 0, 20), Name = "InputBox",
				}, InputFrame)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, InputBox)
				Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, InputBox)
				InputBox.FocusLost:Connect(function() task.spawn(Callback, InputBox.Text) end)
				RegisterSearch(InputName, InputFrame, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return {
					Input = InputBox,
					Set = function(Text) InputBox.Text = Text end,
					Get = function() return InputBox.Text end,
				}
			end

			function SecFuncs:AddDropdown(DropdownConfig)
				local DropdownName = DropdownConfig[1] or DropdownConfig.Name or "Dropdown"
				local Options = DropdownConfig[2] or DropdownConfig.Options or {}
				local Default = DropdownConfig[3] or DropdownConfig.Default or nil
				local Callback = DropdownConfig[4] or DropdownConfig.Callback or function() end
				if type(Default) == "table" then Default = Default[1] end
				local DropdownFrame = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true, Name = DropdownName .. "Dropdown",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, DropdownFrame)
				local DropdownBtn = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
					BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Name = "DropdownBtn",
				}, DropdownFrame)
				local DdLabel = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = DropdownName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -40, 1, 0), Name = "DdLabel",
				}, DropdownBtn)
				local Arrow = Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = "▼", TextColor3 = Color3.fromRGB(150, 150, 150),
					TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1,
					Position = UDim2.new(0, -20, 0, 0), Size = UDim2.new(1, -10, 1, 0), Name = "Arrow",
				}, DropdownBtn)
				local OptionHolder = Custom:Create("Frame", {
					BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(1, 0, 0, 0), Name = "OptionHolder",
				}, DropdownFrame)
				local OptionLayout = Custom:Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, OptionHolder)
				Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, OptionHolder)
				local IsOpen = false local SelectedOption = nil local OptionFrames = {}
				local function UpdateDropdownSize()
					local TH = 30 if IsOpen then TH = TH + OptionLayout.AbsoluteContentSize.Y + 6 end
					TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, TH) }):Play()
				end
				local function SelectOption(OptionText)
					if SelectedOption then
						local OF = OptionFrames[SelectedOption]
						if OF then
							local OI = OF:FindFirstChild("Indicator")
							if OI then
								TweenService:Create(OI, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 12) }):Play()
								task.delay(0.15, function() if OI then OI.Visible = false end end)
							end
						end
					end
					SelectedOption = OptionText
					local NF = OptionFrames[OptionText]
					if NF then
						local NI = NF:FindFirstChild("Indicator")
						if NI then
							NI.Visible = true
							TweenService:Create(NI, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 3, 0, 16) }):Play()
						end
					end
					DdLabel.Text = DropdownName .. ": " .. OptionText DdLabel.TextColor3 = Custom.ColorRGB
					task.spawn(Callback, { OptionText })
				end
				for i, OptionText in ipairs(Options) do
					local OF = Custom:Create("TextButton", {
						Font = Enum.Font.Gotham, Text = "", AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.95,
						BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = i, Name = "Option_" .. OptionText,
					}, OptionHolder)
					Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, OF)
					local Ind = Custom:Create("Frame", {
						Name = "Indicator", BackgroundColor3 = Custom.ColorRGB, BorderSizePixel = 0,
						Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.new(0, 0, 0, 12), Visible = false,
					}, OF)
					Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Ind)
					Custom:AddGradient(Custom:Create("UIStroke", { Color = Custom.ColorRGB, Thickness = 1.5 }, Ind))
					Custom:Create("TextLabel", {
						Font = Enum.Font.Gotham, Text = OptionText, TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
						Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -20, 1, 0), Name = "OptionLabel",
					}, OF)
					OF.MouseEnter:Connect(function() TweenService:Create(OF, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play() end)
					OF.MouseLeave:Connect(function() TweenService:Create(OF, TweenInfo.new(0.15), { BackgroundTransparency = 0.95 }):Play() end)
					OF.Activated:Connect(function() SelectOption(OptionText) IsOpen = false Arrow.Text = "▼" UpdateDropdownSize() end)
					OptionFrames[OptionText] = OF
				end
				if Default and OptionFrames[Default] then SelectOption(Default) end
				DropdownBtn.Activated:Connect(function()
					CircleClick(DropdownBtn, Player:GetMouse().X, Player:GetMouse().Y)
					IsOpen = not IsOpen Arrow.Text = IsOpen and "▲" or "▼" UpdateDropdownSize()
				end)
				RegisterSearch(DropdownName, DropdownFrame, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return {
					Dropdown = DropdownFrame,
					Set = function(Value) if type(Value) == "table" then Value = Value[1] end if OptionFrames[Value] then SelectOption(Value) end end,
					Get = function() return { SelectedOption } end,
				}
			end

			function SecFuncs:AddKeybind(KeybindConfig)
				local KeybindName = KeybindConfig[1] or KeybindConfig.Name or "Keybind"
				local DefaultKey = KeybindConfig[2] or KeybindConfig.Default or Enum.KeyCode.E
				local Callback = KeybindConfig[3] or KeybindConfig.Callback or function() end
				if type(DefaultKey) == "string" then DefaultKey = Enum.KeyCode[DefaultKey] or Enum.KeyCode.E end
				local KeybindFrame = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Name = KeybindName .. "Keybind",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, KeybindFrame)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = KeybindName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -80, 1, 0), Name = "KeybindLabel",
				}, KeybindFrame)
				local KeyBtn = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = DefaultKey.Name, TextColor3 = Custom.ColorRGB,
					TextSize = 11, BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 50, 0, 20), Name = "KeyBtn",
				}, KeybindFrame)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, KeyBtn)
				local CurrentKey = DefaultKey local Listening = false
				local function UpdateKey(Key)
					CurrentKey = Key KeyBtn.Text = Key.Name KeyBtn.TextColor3 = Custom.ColorRGB task.spawn(Callback, Key)
				end
				KeyBtn.Activated:Connect(function()
					if Listening then return end
					Listening = true KeyBtn.Text = "..." KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					local Conn
					Conn = UserInputService.InputBegan:Connect(function(i, gp)
						if gp then return end
						if i.UserInputType == Enum.UserInputType.Keyboard then
							UpdateKey(i.KeyCode) Listening = false Conn:Disconnect()
						end
					end)
				end)
				RegisterSearch(KeybindName, KeybindFrame, SectionName .. " > " .. TabName, SelectTab, nil, TabFrame)
				return {
					Keybind = KeybindFrame,
					Set = function(Key) if type(Key) == "string" then Key = Enum.KeyCode[Key] end if Key then UpdateKey(Key) end end,
					Get = function() return CurrentKey end,
				}
			end

			function SecFuncs:AddParagraph(ParagraphConfig)
				if type(ParagraphConfig) == "table" and ParagraphConfig[1] and ParagraphConfig[2] then
					ParagraphConfig = { Title = ParagraphConfig[1], Text = ParagraphConfig[2] }
				end
				local ParagraphName = ParagraphConfig[1] or ParagraphConfig.Title or "Paragraph"
				local ParagraphText = ParagraphConfig[2] or ParagraphConfig.Text or ""
				local PF = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.95,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Name = ParagraphName .. "Paragraph",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, PF)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = ParagraphName, TextColor3 = Custom.ColorRGB,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 4), Size = UDim2.new(1, -20, 0, 16), Name = "ParaTitle",
				}, PF)
				local ParaLabel = Custom:Create("TextLabel", {
					Font = Enum.Font.Gotham, Text = ParagraphText, TextColor3 = Color3.fromRGB(180, 180, 180),
					TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 22), Size = UDim2.new(1, -20, 0, 20), Name = "ParaLabel",
				}, PF)
				local Sz = TextService:GetTextSize(ParagraphText, 11, Enum.Font.Gotham, Vector2.new(PF.AbsoluteSize.X - 20, 1000))
				ParaLabel.Size = UDim2.new(1, -20, 0, Sz.Y + 4) PF.Size = UDim2.new(1, 0, 0, Sz.Y + 32)
				return {
					Paragraph = PF,
					Set = function(Text)
						ParaLabel.Text = Text
						local NS = TextService:GetTextSize(Text, 11, Enum.Font.Gotham, Vector2.new(PF.AbsoluteSize.X - 20, 1000))
						ParaLabel.Size = UDim2.new(1, -20, 0, NS.Y + 4) PF.Size = UDim2.new(1, 0, 0, NS.Y + 32)
					end,
				}
			end

			function SecFuncs:AddSeparator(SeparatorConfig)
				if type(SeparatorConfig) == "string" then SeparatorConfig = { SeparatorConfig } end
				local SeparatorName = SeparatorConfig and (SeparatorConfig[1] or SeparatorConfig.Name) or ""
				local SF = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.8,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Name = "Separator",
				}, SectionContent)
				if SeparatorName ~= "" then
					local Lbl = Custom:Create("TextLabel", {
						Font = Enum.Font.GothamBold, Text = SeparatorName, TextColor3 = Color3.fromRGB(150, 150, 150),
						TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center,
						BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.new(0, 80, 0, 14), Name = "SepLabel",
					}, SF)
					Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Lbl)
				end
				return { Separator = SF }
			end

			function SecFuncs:AddLine()
				local LF = Custom:Create("Frame", {
					BackgroundColor3 = Custom.ColorRGB, BackgroundTransparency = 0.6,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Name = "Line",
				}, SectionContent)
				return { Line = LF }
			end

			function SecFuncs:AddSocial(SocialConfig)
				local SocialName = SocialConfig[1] or SocialConfig.Name or "Social"
				local SocialUrl = SocialConfig[2] or SocialConfig.Url or ""
				local SocialIcon = SocialConfig[3] or SocialConfig.Icon or ""
				local SF = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Name = SocialName .. "Social",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, SF)
				if SocialIcon ~= "" then
					Custom:Create("ImageLabel", {
						Image = SocialIcon, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
						BorderSizePixel = 0, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), Name = "SocialIcon",
					}, SF)
				end
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = SocialName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, SocialIcon ~= "" and 32 or 10, 0, 0), Size = UDim2.new(1, -40, 1, 0), Name = "SocialLabel",
				}, SF)
				SF.MouseEnter:Connect(function() TweenService:Create(SF, TweenInfo.new(0.15), { BackgroundTransparency = 0.85 }):Play() end)
				SF.MouseLeave:Connect(function() TweenService:Create(SF, TweenInfo.new(0.15), { BackgroundTransparency = 0.92 }):Play() end)
				SF.Activated:Connect(function()
					CircleClick(SF, Player:GetMouse().X, Player:GetMouse().Y)
					if SocialUrl ~= "" then pcall(function() game:GetService("GuiService"):OpenBrowserWindow(SocialUrl) end) end
				end)
				return { Social = SF }
			end

			function SecFuncs:AddCopyGroup(CopyConfig)
				local CopyName = CopyConfig[1] or CopyConfig.Name or "Copy Group"
				local CopyText = CopyConfig[2] or CopyConfig.Text or ""
				local CF = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "", AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), Name = CopyName .. "Copy",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, CF)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = CopyName, TextColor3 = Color3.fromRGB(230, 230, 230),
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -80, 1, 0), Name = "CopyLabel",
				}, CF)
				local CopyBtn = Custom:Create("TextButton", {
					Font = Enum.Font.GothamBold, Text = "Copy", TextColor3 = Custom.ColorRGB,
					TextSize = 11, BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 50, 0, 20), Name = "CopyBtn",
				}, CF)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, CopyBtn)
				CopyBtn.Activated:Connect(function()
					CircleClick(CopyBtn, Player:GetMouse().X, Player:GetMouse().Y)
					if setclipboard then setclipboard(CopyText) RYNERHub_Library:SetNotification({ Content = "Copied: " .. CopyText }) end
				end)
				return { CopyGroup = CF, Set = function(Text) CopyText = Text end }
			end

			function SecFuncs:AddReadMe(ReadMeConfig)
				if type(ReadMeConfig) == "table" and ReadMeConfig[1] and ReadMeConfig[2] then
					ReadMeConfig = { Title = ReadMeConfig[1], Text = ReadMeConfig[2] }
				end
				local ReadMeName = ReadMeConfig[1] or ReadMeConfig.Title or "Read Me"
				local ReadMeText = ReadMeConfig[2] or ReadMeConfig.Text or ""
				local RF = Custom:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.95,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), Name = ReadMeName .. "ReadMe",
				}, SectionContent)
				Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, RF)
				Custom:Create("TextLabel", {
					Font = Enum.Font.GothamBold, Text = ReadMeName, TextColor3 = Custom.ColorRGB,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 4), Size = UDim2.new(1, -20, 0, 16), Name = "ReadMeTitle",
				}, RF)
				local RL = Custom:Create("TextLabel", {
					Font = Enum.Font.Gotham, Text = ReadMeText, TextColor3 = Color3.fromRGB(180, 180, 180),
					TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 22), Size = UDim2.new(1, -20, 0, 20), Name = "ReadMeLabel",
				}, RF)
				local Sz = TextService:GetTextSize(ReadMeText, 11, Enum.Font.Gotham, Vector2.new(RF.AbsoluteSize.X - 20, 1000))
				RL.Size = UDim2.new(1, -20, 0, Sz.Y + 4) RF.Size = UDim2.new(1, 0, 0, Sz.Y + 32)
				return { ReadMe = RF }
			end

			return SecFuncs
		end

		return TabFuncs
	end

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

local ExecutorName = "Unknown"
pcall(function()
    if identifyexecutor then ExecutorName = identifyexecutor()
    elseif getexecutorname then ExecutorName = getexecutorname() end
end)

local createOk, Window = pcall(function()
    return Lib:CreateWindow({
        "RYNER HUB", "Still High", 105,
        UDim2.fromOffset(480, 275),
        Enum.KeyCode.RightControl,
        LOGO_ICON,
        {"v1.0", "VD", "Executor: " .. ExecutorName}
    })
end)
if not createOk then return warn("[Ryner] CreateWindow error") end

pcall(function()
    Window.Tags:AddExecutorTag(ExecutorName)
end)

task.wait(1)

local function notif(txt, dur)
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

local TabInfo = Window:AddTab({"Info"})
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

local TabSurvivor = Window:AddTab({"Survivor", ""})

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

-- ===== DBD CAMERA =====
local DBD_Config = {
    Enabled = false, Distance = 25, FOV = 120, Height = 0,
    CharScale = 0.05, UseCharScale = true,
}
local DBD_DefaultFOV = 70
local DBD_DefaultMinZoom = 0.5
local DBD_DefaultMaxZoom = 128
local DBD_Conn = nil

task.spawn(function()
    while not Workspace.CurrentCamera do task.wait(0.1) end
    DBD_DefaultFOV = Workspace.CurrentCamera.FieldOfView
    DBD_DefaultMinZoom = LP.CameraMinZoomDistance
    DBD_DefaultMaxZoom = LP.CameraMaxZoomDistance
end)

local function ApplyCharScale()
    if not DBD_Config.UseCharScale then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local s = DBD_Config.CharScale
    pcall(function()
        hum.BodyHeightScale = s
        hum.BodyWidthScale = s
        hum.BodyDepthScale = s
        hum.HeadScale = s
    end)
end

local function ResetAll()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.BodyHeightScale = 1
                hum.BodyWidthScale = 1
                hum.BodyDepthScale = 1
                hum.HeadScale = 1
                hum.CameraOffset = Vector3.new(0, 0, 0)
            end)
        end
    end
    local cam = Workspace.CurrentCamera
    if cam then cam.FieldOfView = DBD_DefaultFOV end
    LP.CameraMaxZoomDistance = DBD_DefaultMaxZoom
    LP.CameraMinZoomDistance = DBD_DefaultMinZoom
end

local function StartLoop()
    if DBD_Conn then return end
    DBD_Conn = RunService.RenderStepped:Connect(function()
        if not DBD_Config.Enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        cam.FieldOfView = DBD_Config.FOV
        local d = DBD_Config.Distance
        LP.CameraMaxZoomDistance = d + 0.5
        LP.CameraMinZoomDistance = math.max(0.1, d - 0.5)
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.CameraOffset.Y ~= DBD_Config.Height then
                hum.CameraOffset = Vector3.new(0, DBD_Config.Height, 0)
            end
        end
    end)
end

local function StopLoop()
    if DBD_Conn then
        DBD_Conn:Disconnect()
        DBD_Conn = nil
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.3)
    if DBD_Config.Enabled then ApplyCharScale() end
end)

local SecDBD = TabSurvivor:AddSection({"DBD Camera"})

SecDBD:AddToggle({"DBD Camera", false, function(v)
    DBD_Config.Enabled = v
    if v then
        ApplyCharScale()
        StartLoop()
        notif("DBD Camera: ON")
    else
        StopLoop()
        ResetAll()
        notif("DBD Camera: OFF")
    end
end})

SecDBD:AddSlider({"DBD Camera Distance", 0, 6, 3, function(v)
    DBD_Config.Distance = v
end})

local TabKiller = Window:AddTab({"Killer", ""})

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
local TabESP = Window:AddTab({"Esp", ""})

--==================== HELPERS ====================
local function notif(txt, dur)
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
_G.DBD_Config     = DBD_Config
_G.Config         = Config
_G.KillerCfg      = KillerCfg
_G.AimbotEnabled  = AimbotEnabled
_G.HoldKey        = HoldKey
_G.ESPCfg         = ESPCfg
_G.HookESPEnabled = HookESPEnabled

-- Skill Check pakai variable `Auto` (setmetatable biar Luau-compatible)
_G.SkillCfg = setmetatable({}, {
    __index = function(_, k)
        if k == "Enabled" then return Auto and Auto.SkillCheck or false end
        if k == "Mode" then return Auto and Auto.SkillCheckMode or "Legit" end
    end,
    __newindex = function(_, k, v)
        if Auto then
            if k == "Enabled" then Auto.SkillCheck = v end
            if k == "Mode" then Auto.SkillCheckMode = v end
        end
    end,
})

-- TAB: CONFIG
local TabConfig   = Window:AddTab({"Config", ""})
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
        __version = 2,
        __time = os.time(),

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
            Enabled = DBD_Config.Enabled,
            Distance = DBD_Config.Distance,
            FOV = DBD_Config.FOV,
            Height = DBD_Config.Height,
            CharScale = DBD_Config.CharScale,
            UseCharScale = DBD_Config.UseCharScale,
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

        -- Skill Check pakai variable `Auto`
        SkillCheckCfg = {
            Enabled = Auto.SkillCheck,
            Mode    = Auto.SkillCheckMode,
        },

        -- Standalone
        FullBright     = FullBright,
        NoFog          = NoFog,
        NoShadow       = NoShadow,
        HookESPEnabled = HookESPEnabled,
        TimeOfDayValue = TimeOfDayValue,
    }
end

-- ===== Apply Config =====
local function ApplyConfig(data)
    if type(data) ~= "table" then return false end

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
    merge(DBD_Config, data.DBD_Config)
    merge(ESPCfg,     data.ESPCfg)

    if type(data.SkillCheckCfg) == "table" then
        if data.SkillCheckCfg.Enabled ~= nil then Auto.SkillCheck = data.SkillCheckCfg.Enabled end
        if data.SkillCheckCfg.Mode    ~= nil then Auto.SkillCheckMode = data.SkillCheckCfg.Mode end
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

    if DBD_Config.Enabled then
        pcall(ApplyCharScale)
        pcall(StartLoop)
    else
        pcall(StopLoop)
        pcall(ResetAll)
    end

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
    "default",
    "Tulis nama config baru...",
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
        local ok, json = pcall(function() return HttpService:JSONEncode(CaptureConfig()) end)
        if not ok or not json then notif("Gagal encode!") return end
        local path = CONFIG_FOLDER .. "/" .. SelectedConfig .. ".json"
        local w = pcall(function() writefile(path, json) end)
        if w then
            notif("Saved: " .. SelectedConfig)
            refreshDropdown()
        else
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
                local path = CONFIG_FOLDER .. "/autosave.json"
                writefile(path, HttpService:JSONEncode(CaptureConfig()))
            end)
        end
    end
end)

-- NOTIF
task.wait(1)
pcall(function()
    Lib:SetNotification({ Content = "RYNER HUB berhasil dimuat!", Delay = 3 })
end)

print("RYNER HUB Ready. Tap logo ungu di kiri buat buka/tutup UI.")