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
RYNERHub_Library.Fluent = nil

-- ==================== RYNER HUB UI → Fluent Renewed Plus ====================
-- Adapter: API lama (AddTab/AddSection/AddToggle/...) diteruskan ke Fluent Renewed Plus
local FLUENT_URL = "https://github.com/lamduck2005/Fluent-Renewed-Plus/releases/latest/download/Fluent.luau"
local UI_THEME = "Amethyst Dark"

local TabIcons = {
	Info = "info", Survivor = "user", Killer = "skull",
	Esp = "eye", ESP = "eye", Config = "settings", Key = "key",
}

local ElemCounter = 0
local function NextId(Name)
	ElemCounter = ElemCounter + 1
	return tostring(Name or "El"):gsub("%s+", "_") .. "_" .. ElemCounter
end

local function GetFluent()
	if RYNERHub_Library.Fluent then return RYNERHub_Library.Fluent end
	local okGet, src = pcall(function() return game:HttpGet(FLUENT_URL) end)
	if not okGet or type(src) ~= "string" or #src < 1000 then
		warn("[RYNER HUB] Gagal mengunduh Fluent UI: " .. tostring(src))
		return nil
	end
	local fn, err = loadstring(src)
	if not fn then
		warn("[RYNER HUB] Gagal compile Fluent UI: " .. tostring(err))
		return nil
	end
	local okRun, lib = pcall(fn)
	if not okRun or type(lib) ~= "table" then
		warn("[RYNER HUB] Gagal menjalankan Fluent UI: " .. tostring(lib))
		return nil
	end
	RYNERHub_Library.Fluent = lib
	return lib
end

function RYNERHub_Library:SetNotification(Config)
	local Fl = GetFluent()
	if not Fl then return end
	local Text = Config.Content or Config[1] or ""
	local Delay = tonumber(Config.Delay or Config[6]) or 3
	pcall(function()
		Fl:Notify({ Title = "RYNER HUB", Content = tostring(Text), Duration = Delay })
	end)
end

function RYNERHub_Library:CreateWindow(Config)
	local Fl = GetFluent()
	if not Fl then error("Fluent UI tidak bisa dimuat") end

	local Title = Config[1] or Config.Title or "RYNER HUB"
	local Desc = Config[2] or Config.Description or ""
	local Keybind = Config[5] or Config.Keybind or Enum.KeyCode.RightControl
	local Icon = Config[6] or Config.Icon or "rbxassetid://70543929280917"
	local Tags = Config[7] or Config.Tags or {}

	local SubTitle = Desc
	if type(Tags) == "table" and #Tags > 0 then
		SubTitle = (Desc ~= "" and (Desc .. "  •  ") or "") .. table.concat(Tags, "  •  ")
	end

	local WindowCfg = {
		Title = Title,
		SubTitle = SubTitle,
		TabWidth = 130,
		Size = UDim2.fromOffset(540, 340),
		Acrylic = false,
		Theme = UI_THEME,
		MinimizeKey = Keybind,
		HideButton = true,
		Mobile = {
			Size = UDim2.fromOffset(55, 55),
			GetIcon = function()
				return { Image = Icon, ImageRectOffset = Vector2.new(0, 0), ImageRectSize = Vector2.new(0, 0) }
			end,
		},
	}
	if Config.KeySystem then WindowCfg.KeySystem = Config.KeySystem end

	local WindowObj = Fl:CreateWindow(WindowCfg)

	-- ===== Logo button: tanpa background, tanpa outline =====
	pcall(function()
		local HB = WindowObj.HideButton
		if not HB then return end
		HB.Visible = true
		HB.BackgroundTransparency = 1
		for _, ch in ipairs(HB:GetChildren()) do
			if ch:IsA("UICorner") or ch:IsA("UIStroke") then ch:Destroy() end
		end
		local IconLbl = HB:FindFirstChild("Icon")
		if IconLbl then
			IconLbl.Size = UDim2.fromScale(1, 1)
			IconLbl.Position = UDim2.fromScale(0, 0)
			IconLbl.ImageColor3 = Color3.fromRGB(255, 255, 255)
			pcall(function()
				Fl.ThemeChanged:Connect(function()
					IconLbl.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end)
			end)
			pcall(function()
				WindowObj.PostMinimized:Connect(function(_, visible)
					IconLbl.ImageTransparency = visible and 0 or 0.35
				end)
			end)
		end
	end)

	local Funcs = {}

	-- Tags (Fluent tidak punya tag; info dimasukkan ke SubTitle)
	local DummyTag = { Set = function() end, Remove = function() end }
	Funcs.Tags = {
		Add = function() return DummyTag end,
		AddDynamic = function() return DummyTag end,
		AddExecutorTag = function() return DummyTag end,
	}

	function Funcs.SetOpen(State)
		State = State and true or false
		local IsOpen = not WindowObj.Minimized
		if State ~= IsOpen then WindowObj:Minimize() end
	end
	function Funcs.Toggle() WindowObj:Minimize() end
	function Funcs.IsOpen() return not WindowObj.Minimized end
	function Funcs.IsAlive()
		return WindowObj.Root ~= nil and WindowObj.Root.Parent ~= nil
	end
	function Funcs.Destroy()
		pcall(function() Fl:Destroy() end)
	end
	function Funcs:SetTitle() end
	function Funcs:SetDescription() end

	function Funcs:AddTab(TabConfig)
		local TabName = TabConfig[1] or TabConfig.Name or TabConfig.Title or "Tab"
		local TabIcon = TabConfig.Icon or TabIcons[TabName] or ""
		local TabObj = WindowObj:AddTab({ Title = TabName, Icon = TabIcon })
		local TabFuncs = {}

		function TabFuncs:AddSection(SectionConfig)
			if type(SectionConfig) == "string" then SectionConfig = { SectionConfig } end
			local SectionName = SectionConfig[1] or SectionConfig.Name or SectionConfig.Title or "Section"
			local Sec = TabObj:AddSection(SectionName)
			local SecFuncs = {}

			function SecFuncs:AddButton(C)
				local Name = C[1] or C.Name or "Button"
				local Desc2 = C[2] or C.Description or C.Content or ""
				local Callback = C[3] or C.Callback or function() end
				Sec:AddButton({
					Title = Name,
					Description = Desc2 ~= "" and Desc2 or nil,
					Callback = function() Callback() end,
				})
			end

			function SecFuncs:AddToggle(C)
				local Name = C[1] or C.Name or "Toggle"
				local Default = (C[2] or C.Default or false) and true or false
				local Callback = C[3] or C.Callback or function() end
				local Desc2 = C[4] or C.Description or ""
				local Ready = false
				local Toggle = Sec:AddToggle(NextId(Name), {
					Title = Name,
					Description = Desc2 ~= "" and Desc2 or nil,
					Default = Default,
					Callback = function(v)
						if not Ready then return end
						Callback(v)
					end,
				})
				Ready = true
				if Default then task.spawn(Callback, true) end
				return {
					Toggle = Toggle,
					Set = function(a, b)
						local v = b
						if b == nil then v = a end
						Toggle:SetValue(v and true or false)
					end,
					Get = function() return Toggle.Value end,
				}
			end

			function SecFuncs:AddSlider(C)
				local Name = C[1] or C.Name or "Slider"
				local MinVal = C[2] or C.Min or 0
				local MaxVal = C[3] or C.Max or 100
				local Default = C[4] or C.Default or MinVal
				local Callback = C[5] or C.Callback or function() end
				local Inc = C.Increment or 1
				local Rounding = 0
				if Inc < 1 then Rounding = math.ceil(-math.log10(Inc)) end
				local Ready = false
				local Slider = Sec:AddSlider(NextId(Name), {
					Title = Name, Min = MinVal, Max = MaxVal, Default = Default, Rounding = Rounding,
					Callback = function(v)
						if not Ready then return end
						Callback(v)
					end,
				})
				Ready = true
				task.spawn(Callback, Default)
				return {
					Slider = Slider,
					Set = function(a, b)
						local v = b
						if b == nil then v = a end
						Slider:SetValue(v)
					end,
					Get = function() return Slider.Value end,
				}
			end

			function SecFuncs:AddInput(C)
				local Name = C[1] or C.Name or "Input"
				local Placeholder = C[2] or C.Placeholder or "Enter text..."
				local Default = C[3] or C.Default or ""
				local Callback = C[4] or C.Callback or function() end
				local Ready = false
				local Input = Sec:AddInput(NextId(Name), {
					Title = Name, Default = Default, Placeholder = Placeholder, Finished = true,
					Callback = function(v)
						if not Ready then return end
						Callback(v)
					end,
				})
				Ready = true
				return {
					Input = Input,
					Get = function() return Input.Value end,
					Set = function(a, b)
						local v = b
						if b == nil then v = a end
						Input:SetValue(tostring(v))
					end,
				}
			end

			function SecFuncs:AddDropdown(C)
				local Name = C[1] or C.Name or "Dropdown"
				local Options = C[2] or C.Options or {}
				local Default = C[3] or C.Default or nil
				local Callback = C[4] or C.Callback or function() end
				if type(Default) == "table" then Default = Default[1] end
				local Ready = false
				local Dropdown = Sec:AddDropdown(NextId(Name), {
					Title = Name, Values = Options, Default = Default, Multi = false,
					Callback = function(v)
						if not Ready then return end
						Callback(v)
					end,
				})
				Ready = true
				if Default ~= nil then task.spawn(Callback, Default) end
				return {
					Dropdown = Dropdown,
					Get = function() return { Dropdown.Value } end,
					Set = function(a, b)
						local v = b
						if b == nil then v = a end
						if type(v) == "table" then v = v[1] end
						if v ~= nil then Dropdown:SetValue(v) end
					end,
					SetValues = function(a, b)
						local vals = b
						if b == nil then vals = a end
						if type(vals) == "table" then Dropdown:SetValues(vals) end
					end,
				}
			end

			function SecFuncs:AddColorpicker(C)
				local Name = C[1] or C.Name or "Warna"
				local Default = C[2] or C.Default or Color3.fromRGB(255, 255, 255)
				local Callback = C[3] or C.Callback or function() end
				local Ready = false
				local Picker = Sec:AddColorPicker(NextId(Name), {
					Title = Name, Default = Default,
					Callback = function(c)
						if not Ready then return end
						Callback(c)
					end,
				})
				Ready = true
				return {
					Picker = Picker,
					Get = function() return Picker.Value end,
					Set = function(a, b)
						local c = b
						if b == nil then c = a end
						Picker:SetValueRGB(c)
					end,
				}
			end

			function SecFuncs:AddKeybind(C)
				local Name = C[1] or C.Name or "Keybind"
				local DefaultKey = C[2] or C.Default or Enum.KeyCode.E
				local Callback = C[3] or C.Callback or function() end
				if typeof(DefaultKey) == "EnumItem" then DefaultKey = DefaultKey.Name end
				Sec:AddKeybind(NextId(Name), {
					Title = Name, Mode = "Toggle", Default = tostring(DefaultKey),
					Callback = function() Callback() end,
				})
			end

			function SecFuncs:AddParagraph(C)
				if type(C) == "string" then C = { C } end
				local T = C[1] or C.Title or "Info"
				local X = C[2] or C.Text or C.Content or ""
				Sec:AddParagraph({ Title = T, Content = X })
			end
			SecFuncs.AddReadMe = SecFuncs.AddParagraph

			function SecFuncs:AddSeparator(C)
				pcall(function() Sec:AddDivider() end)
			end
			function SecFuncs:AddLine()
				pcall(function() Sec:AddDivider() end)
			end

			function SecFuncs:AddSocial(C)
				local Name = C[1] or C.Name or "Link"
				local Url = C[2] or C.Url or ""
				Sec:AddButton({
					Title = Name, Description = Url ~= "" and Url or nil,
					Callback = function()
						if setclipboard then
							pcall(setclipboard, Url)
							RYNERHub_Library:SetNotification({ Content = "Link disalin: " .. Url })
						end
					end,
				})
			end

			function SecFuncs:AddCopyGroup(C)
				local Name = C[1] or C.Name or "Copy"
				local Text = C[2] or C.Text or ""
				Sec:AddButton({
					Title = Name, Description = Text ~= "" and Text or nil,
					Callback = function()
						if setclipboard then
							pcall(setclipboard, Text)
							RYNERHub_Library:SetNotification({ Content = "Disalin: " .. Text })
						end
					end,
				})
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

-- ================= RYNER HUB KEY SYSTEM =================
local KeySystemCfg = nil
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

    -- Belum valid: pakai Key System bawaan Fluent (muncul saat window dibuat)
    if not verified then
        KeySystemCfg = {
            Title = "RYNER HUB - Key System",
            Note = "Tekan Get Key untuk menyalin link, selesaikan checkpoint di website, lalu tempel key kamu di sini dan tekan Enter.",
            URL = GET_KEY_URL,
            SaveKey = false,
            KeyValidator = function(k)
                if check(k) then
                    saveKey(clean(k))
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

local createOk, Window = pcall(function()
    return Lib:CreateWindow({
        "RYNER HUB", "Still High", 105,
        UDim2.fromOffset(480, 275),
        Enum.KeyCode.RightControl,
        LOGO_ICON,
        {"v1.0", "VD", "Executor: " .. ExecutorName},
        KeySystem = KeySystemCfg,
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


-- ====================== SILENT AIM TOF v2 (GanKunZ) ======================
do
-- Silent Aim ToF — GanKunZ (Pure)
-- Hold system + target modes + Bypass Carry
-- NO Oxio hub
-- Toggle: getgenv().GANKZ_SetToFSilentAim(true/false)
-- Keys: K=Killer | J=Survivors | L=Zombie
-- UI colors: Aim Veil V12 palette

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

getgenv().VD = getgenv().VD or {}
local VD = getgenv().VD

VD.TOF_SilentAim     = VD.TOF_SilentAim ~= nil and VD.TOF_SilentAim or true
VD.TOF_Laser         = VD.TOF_Laser ~= nil and VD.TOF_Laser or true
VD.TOF_WallCheck     = VD.TOF_WallCheck ~= nil and VD.TOF_WallCheck or false
VD.TOF_BlockKnocked  = VD.TOF_BlockKnocked ~= nil and VD.TOF_BlockKnocked or true
VD.TOF_BypassCarry   = VD.TOF_BypassCarry ~= nil and VD.TOF_BypassCarry or true
VD.TOF_TargetMode    = VD.TOF_TargetMode or "Killer"
VD.TOF_Key           = VD.TOF_Key or "None"

local function GetSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and core then
        return core
    end

    return LocalPlayer:FindFirstChild("PlayerGui")
        or LocalPlayer:WaitForChild("PlayerGui", 5)
end

local function VD_Notify(title, content, dur)
    print("[" .. tostring(title) .. "]", tostring(content))
end

local GANKZ_ToFState = {
    Connection = nil,
    LaserBeam = nil,
    TargetGui = nil,
    InputBegan = nil,
    InputEnded = nil,
    TouchInput = nil,
    IsAiming = false,
    SavedUIPos = UDim2.new(0.5, -120, 0, 110),
    SCPCache = {},
    SCPCacheTimer = 0,
}

local GANKZ_ToFKeyCodes = {
    None = nil,
    Q = Enum.KeyCode.Q,
    E = Enum.KeyCode.E,
    R = Enum.KeyCode.R,
    T = Enum.KeyCode.T,
    F = Enum.KeyCode.F,
    G = Enum.KeyCode.G,
    H = Enum.KeyCode.H,
    J = Enum.KeyCode.J,
    K = Enum.KeyCode.K,
    L = Enum.KeyCode.L,
    X = Enum.KeyCode.X,
    Z = Enum.KeyCode.Z,
}

local function GANKZ_ToFGetEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local tof = items and items:FindFirstChild("Twist of Fate")
    local fire = tof and tof:FindFirstChild("Fire")

    if fire and fire:IsA("RemoteEvent") then
        return fire
    end

    return nil
end

local function GANKZ_ToFGetGunObject()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end

    local baseToF = char:FindFirstChild("Twist of Fate", true)
    if not baseToF then
        return nil
    end

    local rightArm = baseToF:FindFirstChild("Right Arm")

    if rightArm then
        local gunPart = rightArm:FindFirstChild("gun")
        if gunPart then
            return gunPart
        end

        local emperorGun = rightArm:FindFirstChild("EmperorGun")
        if emperorGun then
            return emperorGun
        end
    end

    return baseToF
end

local function GANKZ_ToFIsTargetVisible(originPos, targetPos, targetCharacter)
    local direction = targetPos - originPos
    local distance = direction.Magnitude

    if distance < 0.1 then
        return true
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local excludeList = {}

    local localChar = LocalPlayer.Character
    if localChar then
        table.insert(excludeList, localChar)
    end

    if targetCharacter and targetCharacter ~= localChar then
        table.insert(excludeList, targetCharacter)
    end

    if GANKZ_ToFState.LaserBeam then
        table.insert(excludeList, GANKZ_ToFState.LaserBeam)
    end

    rayParams.FilterDescendantsInstances = excludeList

    local result = workspace:Raycast(
        originPos,
        direction.Unit * distance,
        rayParams
    )

    return result == nil
end

local function GANKZ_ToFGetSCPs()
    if tick() - GANKZ_ToFState.SCPCacheTimer < 0.5 then
        return GANKZ_ToFState.SCPCache
    end

    local newTargets = {}

    local mapFolder = workspace:FindFirstChild("Map")

    if mapFolder then
        for _, container in pairs(mapFolder:GetDescendants()) do
            if container:IsA("Model") then
                local attributes = container:GetAttributes()

                if container:GetAttribute("CorpseCreated0492")
                    or next(attributes) ~= nil then

                    local root = container:FindFirstChild("HumanoidRootPart")

                    if root then
                        table.insert(newTargets, root)
                    end
                end
            end
        end
    end

    GANKZ_ToFState.SCPCache = newTargets
    GANKZ_ToFState.SCPCacheTimer = tick()

    return GANKZ_ToFState.SCPCache
end

local function GANKZ_ToFGetTargetPosition()
    local gunObj = GANKZ_ToFGetGunObject()
    local char = LocalPlayer.Character

    if not (gunObj and char) then
        return nil, nil, nil, nil
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return nil, nil, nil, nil
    end

    local myPos = hrp.Position
    local originPos

    if char:GetAttribute("IsCarried") then
        originPos = hrp.Position + (hrp.CFrame.LookVector * 2)
    else
        pcall(function()
            originPos =
                gunObj:IsA("BasePart")
                and gunObj.Position
                or (
                    gunObj:FindFirstChildOfClass("BasePart")
                    and gunObj:FindFirstChildOfClass("BasePart").Position
                )
        end)

        originPos =
            originPos
            or Vector3.new(
                myPos.X,
                myPos.Y + 1.5,
                myPos.Z
            )
    end

    local function predictTarget(torso, targetCharacter)
        local targetPos = torso.Position

        if VD.TOF_WallCheck
            and not GANKZ_ToFIsTargetVisible(
                originPos,
                targetPos,
                targetCharacter
            ) then

            return nil, nil, nil, nil
        end

        local targetVel = Vector3.new(0, 0, 0)

        local rootPart =
            targetCharacter
            and (
                targetCharacter:FindFirstChild("HumanoidRootPart")
                or torso
            )

        if rootPart then
            targetVel = rootPart.Velocity
        end

        local directionRaw = targetPos - originPos
        local distance = directionRaw.Magnitude

        if distance < 0.1 then
            return nil, nil, nil, nil
        end

        if distance < 5 then
            return directionRaw.Unit, gunObj, originPos, targetPos
        end

        local travelTime = distance / 400
        local predictedPos = targetPos + (targetVel * travelTime)

        for _ = 1, 2 do
            local newDist = (predictedPos - originPos).Magnitude
            travelTime = newDist / 400
            predictedPos = targetPos + (targetVel * travelTime)
        end

        local finalDirection = predictedPos - originPos

        if finalDirection.Magnitude < 0.1 then
            return nil, nil, nil, nil
        end

        return finalDirection.Unit, gunObj, originPos, predictedPos
    end

    local targetMode = VD.TOF_TargetMode or "Killer"

    if targetMode == "Killer" then
        local closestTorso
        local closestChar
        local shortestDist = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer
                and player.Team
                and player.Team.Name == "Killer"
                and player.Character then

                local torso =
                    player.Character:FindFirstChild("Torso")
                    or player.Character:FindFirstChild("UpperTorso")
                    or player.Character:FindFirstChild("HumanoidRootPart")

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

        if not closestTorso then
            return nil, nil, nil, nil
        end

        return predictTarget(closestTorso, closestChar)

    elseif targetMode == "Survivors" then
        local bestTorso
        local bestChar
        local bestDot = -math.huge

        local cam = workspace.CurrentCamera

        if not cam then
            return nil, nil, nil, nil
        end

        local camLook = cam.CFrame.LookVector

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer
                and player.Team
                and player.Team.Name == "Survivors"
                and player.Character then

                local torso =
                    player.Character:FindFirstChild("Torso")
                    or player.Character:FindFirstChild("UpperTorso")
                    or player.Character:FindFirstChild("HumanoidRootPart")

                if torso then
                    local dirToTarget =
                        torso.Position - cam.CFrame.Position

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

        if not bestTorso then
            return nil, nil, nil, nil
        end

        return predictTarget(bestTorso, bestChar)

    elseif targetMode == "Zombie" then
        local bestPart
        local bestDot = -math.huge

        local cam = workspace.CurrentCamera

        if not cam then
            return nil, nil, nil, nil
        end

        local camLook = cam.CFrame.LookVector

        for _, root in ipairs(GANKZ_ToFGetSCPs()) do
            if root and root.Parent then
                local dirToTarget =
                    root.Position - cam.CFrame.Position

                if dirToTarget.Magnitude > 0.1 then
                    local dot = camLook:Dot(dirToTarget.Unit)

                    if dot > 0.5 and dot > bestDot then
                        bestDot = dot
                        bestPart = root
                    end
                end
            end
        end

        if not bestPart then
            return nil, nil, nil, nil
        end

        return predictTarget(bestPart, bestPart.Parent)
    end

    return nil, nil, nil, nil
end

local function GANKZ_ToFUpdateLaser(originPos, targetPos)
    if not GANKZ_ToFState.LaserBeam then
        local laser = Instance.new("Part")

        laser.Name = "ToFLaser"
        laser.Anchored = true
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CastShadow = false
        laser.Material = Enum.Material.Neon
        laser.Color = Color3.fromRGB(255, 50, 50)
        laser.Parent = workspace

        GANKZ_ToFState.LaserBeam = laser
    end

    local dist = (targetPos - originPos).Magnitude

    GANKZ_ToFState.LaserBeam.Size =
        Vector3.new(0.05, 0.05, dist)

    GANKZ_ToFState.LaserBeam.CFrame =
        CFrame.new(
            (originPos + targetPos) / 2,
            targetPos
        )

    GANKZ_ToFState.LaserBeam.Transparency = 0
end

local function GANKZ_ToFClearLaser()
    if GANKZ_ToFState.LaserBeam then
        pcall(function()
            GANKZ_ToFState.LaserBeam:Destroy()
        end)

        GANKZ_ToFState.LaserBeam = nil
    end
end

local function IsDowned(char)
    if not char then
        return true
    end

    if VD.TOF_BypassCarry
        and char == LocalPlayer.Character
        and char:GetAttribute("IsCarried") then

        return char:GetAttribute("Knocked") == true
            or char:GetAttribute("IsHooked") == true
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return true
    end

    local state = char:GetAttribute("State")

    return state == "Downed"
        or state == "Dead"
        or char:GetAttribute("Knocked") == true
        or char:GetAttribute("IsHooked") == true
end

local function GANKZ_ToFGetMobileShootButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

    local survivorMob =
        playerGui
        and playerGui:FindFirstChild("Survivor-mob")

    local controls =
        survivorMob
        and survivorMob:FindFirstChild("Controls")

    local guiMob =
        controls
        and controls:FindFirstChild("Gui-mob")

    if not guiMob then
        return nil
    end

    local directNames = {
        "attack",
        "Attack",
        "shoot",
        "Shoot",
        "fire",
        "Fire"
    }

    for _, name in ipairs(directNames) do
        local btn = guiMob:FindFirstChild(name, true)

        if btn and btn:IsA("GuiObject") then
            return btn
        end
    end

    for _, obj in ipairs(guiMob:GetDescendants()) do
        if obj:IsA("GuiButton") and obj.Visible then
            return obj
        end
    end

    return guiMob:IsA("GuiObject") and guiMob or nil
end

local function GANKZ_ToFIsTouchOnShootButton(input)
    local shootButton = GANKZ_ToFGetMobileShootButton()

    if not (shootButton and shootButton.Visible) then
        return false
    end

    local pos = input.Position
    local absPos = shootButton.AbsolutePosition
    local absSize = shootButton.AbsoluteSize

    return pos.X >= absPos.X
        and pos.X <= absPos.X + absSize.X
        and pos.Y >= absPos.Y
        and pos.Y <= absPos.Y + absSize.Y
end

local function GANKZ_ToFDoShoot()
    if not VD.TOF_SilentAim then
        return
    end

    local char = LocalPlayer.Character

    if char then
        if VD.TOF_BlockKnocked and IsDowned(char) then
            return
        end
    end

    local targetDirection
    local gunObject
    local originPos
    local targetPos

    targetDirection,
    gunObject,
    originPos,
    targetPos = GANKZ_ToFGetTargetPosition()

    if not (
        targetDirection
        and gunObject
        and targetPos
        and originPos
    ) then
        return
    end

    local tofEvent = GANKZ_ToFGetEvent()

    if not tofEvent then
        return
    end

    local freshDirection = targetPos - originPos

    if freshDirection.Magnitude < 0.1 then
        return
    end

    pcall(function()
        tofEvent:FireServer(
            gunObject,
            freshDirection.Unit
        )
    end)
end

local GANKZ_ToFModeButtons = {}

local function GANKZ_ToFRefreshTargetButtons()
    local modes = {
        Killer = {
            Color3.fromRGB(180, 30, 30),
            Color3.fromRGB(255, 255, 255)
        },

        Survivors = {
            Color3.fromRGB(180, 30, 30),
            Color3.fromRGB(255, 255, 255)
        },

        Zombie = {
            Color3.fromRGB(180, 30, 30),
            Color3.fromRGB(255, 255, 255)
        },
    }

    for modeName, btn in pairs(GANKZ_ToFModeButtons) do
        if btn and btn.Parent then
            local active =
                modeName == (VD.TOF_TargetMode or "Killer")

            local colors = modes[modeName]

            btn.BackgroundColor3 =
                active
                and colors[1]
                or Color3.fromRGB(24, 24, 28)

            btn.TextColor3 =
                active
                and colors[2]
                or Color3.fromRGB(230, 230, 235)
        end
    end
end

local function GANKZ_ToFSetTargetMode(modeName, notify)
    if modeName ~= "Killer"
        and modeName ~= "Survivors"
        and modeName ~= "Zombie" then
        return
    end

    VD.TOF_TargetMode = modeName

    GANKZ_ToFRefreshTargetButtons()

    if notify then
        VD_Notify("Target Mode", modeName, 1)
    end
end

local function GANKZ_ToFCreateTargetSelectorUI()
    local parent = GetSafeGuiParent()

    if not parent then
        return
    end

    if GANKZ_ToFState.TargetGui
        and GANKZ_ToFState.TargetGui.Parent then
        return
    end

    local old = parent:FindFirstChild("ToFTargetSelector")

    if old then
        pcall(function()
            old:Destroy()
        end)
    end

    local gui = Instance.new("ScreenGui")

    gui.Name = "ToFTargetSelector"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent

    local frame = Instance.new("Frame")

    frame.Name = "Main"
    frame.Size = UDim2.new(0, 180, 0, 230)
    frame.Position = GANKZ_ToFState.SavedUIPos
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = false
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius =
        UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)

    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5

    local header = Instance.new("Frame")

    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    header.BorderSizePixel = 0
    header.Parent = frame

    Instance.new("UICorner", header).CornerRadius =
        UDim.new(0, 8)

    local headerFix = Instance.new("Frame")

    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerDiv = Instance.new("Frame")

    headerDiv.Size = UDim2.new(1, 0, 0, 1)
    headerDiv.Position = UDim2.new(0, 0, 1, -1)
    headerDiv.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    headerDiv.BorderSizePixel = 0
    headerDiv.Parent = header

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

    btnContainer.Size = UDim2.new(1, -16, 0, 190)
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

        minimizeBtn.Text =
            isMinimized and "+" or "-"

        btnContainer.Visible = not isMinimized

        frame.Size =
            isMinimized
            and UDim2.new(0, 180, 0, 28)
            or UDim2.new(0, 180, 0, 230)
    end)

    local enableBtn = Instance.new("TextButton")

    enableBtn.Size = UDim2.new(1, 0, 0, 25)
    enableBtn.BorderSizePixel = 0
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 11
    enableBtn.LayoutOrder = 0
    enableBtn.Parent = btnContainer

    Instance.new("UICorner", enableBtn).CornerRadius =
        UDim.new(0, 6)

    local enableStroke = Instance.new("UIStroke", enableBtn)

    enableStroke.Thickness = 1

    local function paintEnable()
        if VD.TOF_SilentAim then
            enableBtn.BackgroundColor3 =
                Color3.fromRGB(180, 30, 30)

            enableBtn.TextColor3 =
                Color3.fromRGB(255, 255, 255)

            enableBtn.Text = "SILENT AIM  ON"

            enableStroke.Color =
                Color3.fromRGB(220, 70, 70)
        else
            enableBtn.BackgroundColor3 =
                Color3.fromRGB(24, 24, 28)

            enableBtn.TextColor3 =
                Color3.fromRGB(230, 230, 235)

            enableBtn.Text = "SILENT AIM  OFF"

            enableStroke.Color =
                Color3.fromRGB(50, 50, 55)
        end
    end

    paintEnable()

    local bypassCarryBtn = Instance.new("TextButton")

    bypassCarryBtn.Size = UDim2.new(1, 0, 0, 25)
    bypassCarryBtn.BorderSizePixel = 0
    bypassCarryBtn.Font = Enum.Font.GothamBold
    bypassCarryBtn.TextSize = 11
    bypassCarryBtn.LayoutOrder = 1
    bypassCarryBtn.Parent = btnContainer

    Instance.new("UICorner", bypassCarryBtn).CornerRadius =
        UDim.new(0, 6)

    local bypassStroke = Instance.new("UIStroke", bypassCarryBtn)

    bypassStroke.Thickness = 1

    local function paintBypassCarry()
        if VD.TOF_BypassCarry then
            bypassCarryBtn.BackgroundColor3 =
                Color3.fromRGB(180, 30, 30)

            bypassCarryBtn.TextColor3 =
                Color3.fromRGB(255, 255, 255)

            bypassCarryBtn.Text = "BYPASS CARRY  ON"

            bypassStroke.Color =
                Color3.fromRGB(220, 70, 70)
        else
            bypassCarryBtn.BackgroundColor3 =
                Color3.fromRGB(24, 24, 28)

            bypassCarryBtn.TextColor3 =
                Color3.fromRGB(230, 230, 235)

            bypassCarryBtn.Text = "BYPASS CARRY  OFF"

            bypassStroke.Color =
                Color3.fromRGB(50, 50, 55)
        end
    end

    paintBypassCarry()

    bypassCarryBtn.MouseButton1Click:Connect(function()
        VD.TOF_BypassCarry =
            not VD.TOF_BypassCarry

        paintBypassCarry()

        print(
            "[GANKZ] ToF Bypass Carry:",
            VD.TOF_BypassCarry and "ON" or "OFF"
        )
    end)

    local blockKnockBtn = Instance.new("TextButton")

    blockKnockBtn.Size = UDim2.new(1, 0, 0, 25)
    blockKnockBtn.BorderSizePixel = 0
    blockKnockBtn.Font = Enum.Font.GothamBold
    blockKnockBtn.TextSize = 11
    blockKnockBtn.LayoutOrder = 2
    blockKnockBtn.Parent = btnContainer

    Instance.new("UICorner", blockKnockBtn).CornerRadius =
        UDim.new(0, 6)

    local blockKnockStroke =
        Instance.new("UIStroke", blockKnockBtn)

    blockKnockStroke.Thickness = 1

    local function paintBlockKnock()
        if VD.TOF_BlockKnocked then
            blockKnockBtn.BackgroundColor3 =
                Color3.fromRGB(180, 30, 30)

            blockKnockBtn.TextColor3 =
                Color3.fromRGB(255, 255, 255)

            blockKnockBtn.Text = "BLOCK KNOCK  ON"

            blockKnockStroke.Color =
                Color3.fromRGB(220, 70, 70)
        else
            blockKnockBtn.BackgroundColor3 =
                Color3.fromRGB(24, 24, 28)

            blockKnockBtn.TextColor3 =
                Color3.fromRGB(230, 230, 235)

            blockKnockBtn.Text = "BLOCK KNOCK  OFF"

            blockKnockStroke.Color =
                Color3.fromRGB(50, 50, 55)
        end
    end

    paintBlockKnock()

    blockKnockBtn.MouseButton1Click:Connect(function()
        VD.TOF_BlockKnocked =
            not VD.TOF_BlockKnocked

        paintBlockKnock()
    end)

    local modes = {
        {
            Internal = "Killer",
            Display = "KILLER        K"
        },
        {
            Internal = "Survivors",
            Display = "SURVIVOR      J"
        },
        {
            Internal = "Zombie",
            Display = "ZOMBIE        L"
        },
    }

    GANKZ_ToFModeButtons = {}

    for i, mode in ipairs(modes) do
        local btn = Instance.new("TextButton")

        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Text = mode.Display
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.LayoutOrder = i + 2
        btn.Parent = btnContainer

        Instance.new("UICorner", btn).CornerRadius =
            UDim.new(0, 6)

        local btnStroke = Instance.new("UIStroke", btn)

        btnStroke.Color =
            Color3.fromRGB(50, 50, 55)

        btnStroke.Thickness = 1

        btn.MouseButton1Click:Connect(function()
            GANKZ_ToFSetTargetMode(
                mode.Internal,
                false
            )
        end)

        btn.InputEnded:Connect(function(input)
            if input.UserInputType ==
                Enum.UserInputType.Touch then

                GANKZ_ToFSetTargetMode(
                    mode.Internal,
                    false
                )
            end
        end)

        GANKZ_ToFModeButtons[mode.Internal] = btn
    end

    GANKZ_ToFRefreshTargetButtons()

    local GANKZ_SetToFSilentAim_Local

    enableBtn.MouseButton1Click:Connect(function()
        GANKZ_SetToFSilentAim_Local(
            not VD.TOF_SilentAim
        )
    end)

    local dragging = false
    local dragStart
    local startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragStart = input.Position
            startPos = frame.Position
            dragging = true
        end
    end)

    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            local delta =
                input.Position - dragStart

            local newPos =
                UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )

            frame.Position = newPos
            GANKZ_ToFState.SavedUIPos = newPos
        end
    end)

    GANKZ_ToFState.TargetGui = gui

    GANKZ_SetToFSilentAim_Local = function(enabled)
        VD.TOF_SilentAim =
            enabled and true or false

        if not VD.TOF_SilentAim then
            GANKZ_ToFState.IsAiming = false

            if GANKZ_ToFState.LaserBeam then
                GANKZ_ToFState.LaserBeam.Transparency = 1
            end
        end

        paintEnable()
    end
end

local function GANKZ_ToFDestroyTargetSelectorUI()
    if GANKZ_ToFState.TargetGui then
        pcall(function()
            GANKZ_ToFState.TargetGui:Destroy()
        end)

        GANKZ_ToFState.TargetGui = nil
    end

    GANKZ_ToFModeButtons = {}
end

local function GANKZ_ToFStartConnection()
    if GANKZ_ToFState.Connection then
        return
    end

    GANKZ_ToFState.Connection =
        RunService.Heartbeat:Connect(function()

        if not VD.TOF_SilentAim
            or not GANKZ_ToFState.IsAiming then

            if GANKZ_ToFState.LaserBeam then
                GANKZ_ToFState.LaserBeam.Transparency = 1
            end

            return
        end

        local _
        local __
        local originPos
        local targetPos

        _, __, originPos, targetPos =
            GANKZ_ToFGetTargetPosition()

        if originPos and targetPos then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp =
                    char
                    and char:FindFirstChild(
                        "HumanoidRootPart"
                    )

                if hrp
                    and not char:GetAttribute(
                        "IsCarried"
                    ) then

                    hrp.CFrame =
                        CFrame.new(
                            hrp.Position,
                            Vector3.new(
                                targetPos.X,
                                hrp.Position.Y,
                                targetPos.Z
                            )
                        )
                end
            end)

            if VD.TOF_Laser then
                GANKZ_ToFUpdateLaser(
                    originPos,
                    targetPos
                )
            elseif GANKZ_ToFState.LaserBeam then
                GANKZ_ToFState.LaserBeam.Transparency = 1
            end

        elseif GANKZ_ToFState.LaserBeam then
            GANKZ_ToFState.LaserBeam.Transparency = 1
        end
    end)
end

local function GANKZ_ToFStopConnection()
    if GANKZ_ToFState.Connection then
        pcall(function()
            GANKZ_ToFState.Connection:Disconnect()
        end)

        GANKZ_ToFState.Connection = nil
    end

    GANKZ_ToFState.IsAiming = false

    GANKZ_ToFClearLaser()
end

local GANKZ_SetToFSilentAim

local function GANKZ_ToFEnsureInputs()
    if not GANKZ_ToFState.InputBegan then
        GANKZ_ToFState.InputBegan =
            UserInputService.InputBegan:Connect(
            function(input, gameProcessed)

            if gameProcessed then
                return
            end

            local keyCode =
                GANKZ_ToFKeyCodes[
                    VD.TOF_Key or "None"
                ]

            if keyCode
                and input.UserInputType ==
                    Enum.UserInputType.Keyboard
                and input.KeyCode == keyCode then

                GANKZ_SetToFSilentAim(
                    not VD.TOF_SilentAim
                )

                return
            end

            if not VD.TOF_SilentAim then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or (
                    input.UserInputType ==
                        Enum.UserInputType.Touch
                    and GANKZ_ToFIsTouchOnShootButton(
                        input
                    )
                ) then

                GANKZ_ToFState.IsAiming = true

                if input.UserInputType ==
                    Enum.UserInputType.Touch then

                    GANKZ_ToFState.TouchInput = input
                end

                GANKZ_ToFDoShoot()

                return
            end

            if input.UserInputType ==
                Enum.UserInputType.Keyboard then

                if input.KeyCode == Enum.KeyCode.K then
                    GANKZ_ToFSetTargetMode(
                        "Killer",
                        true
                    )

                elseif input.KeyCode == Enum.KeyCode.J then
                    GANKZ_ToFSetTargetMode(
                        "Survivors",
                        true
                    )

                elseif input.KeyCode == Enum.KeyCode.L then
                    GANKZ_ToFSetTargetMode(
                        "Zombie",
                        true
                    )
                end
            end
        end)
    end

    if not GANKZ_ToFState.InputEnded then
        GANKZ_ToFState.InputEnded =
            UserInputService.InputEnded:Connect(
            function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or (
                    input.UserInputType ==
                        Enum.UserInputType.Touch
                    and input ==
                        GANKZ_ToFState.TouchInput
                ) then

                GANKZ_ToFState.IsAiming = false

                if input ==
                    GANKZ_ToFState.TouchInput then

                    GANKZ_ToFState.TouchInput = nil
                end

                if GANKZ_ToFState.LaserBeam then
                    GANKZ_ToFState.LaserBeam.Transparency = 1
                end
            end
        end)
    end
end

GANKZ_SetToFSilentAim = function(enabled)
    VD.TOF_SilentAim =
        enabled and true or false

    GANKZ_ToFEnsureInputs()

    if VD.TOF_SilentAim then
        GANKZ_ToFCreateTargetSelectorUI()
        GANKZ_ToFStartConnection()
    else
        GANKZ_ToFDestroyTargetSelectorUI()
        GANKZ_ToFStopConnection()
    end
end

GANKZ_ToFEnsureInputs()

getgenv().GANKZ_SetToFSilentAim =
    GANKZ_SetToFSilentAim

getgenv().GANKZ_ToFClearLaser =
    GANKZ_ToFClearLaser

getgenv().GANKZ_ToFSetTargetMode =
    GANKZ_ToFSetTargetMode

if getgenv().GANKZ_SetToFSilentAim then
    getgenv().GANKZ_SetToFSilentAim(true)
end

print(
    "[GANKZ] Silent Aim ToF loaded | pure | BypassCarry:",
    tostring(VD.TOF_BypassCarry)
)

print(
    "[GANKZ] Toggle: getgenv().GANKZ_SetToFSilentAim(true/false)"
)

print(
    "[GANKZ] Keys: K=Killer | J=Survivors | L=Zombie"
)
end

local SecSilentAim = TabSurvivor:AddSection({"Silent Aim ToF"})

SecSilentAim:AddToggle({"Silent Aim ToF", true, function(v)
    if getgenv().GANKZ_SetToFSilentAim then
        getgenv().GANKZ_SetToFSilentAim(v)
    end
    notif("Silent Aim ToF: " .. (v and "ON" or "OFF"))
end, "Silent Aim v2 (panel target muncul di layar, key K/J/L)"})


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

-- ===== Warna ESP =====
local SecESPColor = TabESP:AddSection({"Warna ESP"})

local function AddESPColorPicker(label, key)
    SecESPColor:AddColorpicker({
        label,
        Tuning.Colors[key],
        function(c)
            Tuning.Colors[key] = c
            if ESPCfg.Master then ForceRefreshMap() end
        end
    })
end

AddESPColorPicker("Warna Survivor",       "Player")
AddESPColorPicker("Warna Killer",         "Killer")
AddESPColorPicker("Warna SCP / Zombie",   "SCP")
AddESPColorPicker("Warna Generator",      "Generator")
AddESPColorPicker("Warna Generator Done", "GeneratorDone")
AddESPColorPicker("Warna Pallet",         "Pallet")
AddESPColorPicker("Warna Hook",           "Hook")
AddESPColorPicker("Warna Exit Gate",      "Gate")
AddESPColorPicker("Warna Window / Vault", "Window")

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

-- ===== Warna ESP =====
local SecESPColor = TabESP:AddSection({"Warna ESP"})

local ESPColorPresets = {
    ["Ungu"]   = Color3.fromRGB(160, 90, 255),
    ["Merah"]  = Color3.fromRGB(255, 40, 40),
    ["Hijau"]  = Color3.fromRGB(0, 200, 70),
    ["Biru"]   = Color3.fromRGB(50, 130, 255),
    ["Cyan"]   = Color3.fromRGB(0, 230, 230),
    ["Kuning"] = Color3.fromRGB(255, 235, 0),
    ["Oranye"] = Color3.fromRGB(255, 140, 0),
    ["Pink"]   = Color3.fromRGB(255, 105, 180),
    ["Putih"]  = Color3.fromRGB(255, 255, 255),
}
local ESPColorOrder = {"Ungu","Merah","Hijau","Biru","Cyan","Kuning","Oranye","Pink","Putih"}

local function NameOfColor(c)
    for n, v in pairs(ESPColorPresets) do
        if v == c then return n end
    end
    return nil
end

local function AddESPColorPicker(label, key)
    SecESPColor:AddDropdown({
        label,
        Options = ESPColorOrder,
        Default = NameOfColor(Tuning.Colors[key]) or "Putih",
        Callback = function(name)
            local c = ESPColorPresets[name]
            if not c then return end
            Tuning.Colors[key] = c
            if ESPCfg.Master then ForceRefreshMap() end
        end
    })
end

AddESPColorPicker("Warna Survivor",       "Player")
AddESPColorPicker("Warna Killer",         "Killer")
AddESPColorPicker("Warna SCP / Zombie",   "SCP")
AddESPColorPicker("Warna Generator",      "Generator")
AddESPColorPicker("Warna Generator Done", "GeneratorDone")
AddESPColorPicker("Warna Pallet",         "Pallet")
AddESPColorPicker("Warna Hook",           "Hook")
AddESPColorPicker("Warna Exit Gate",      "Gate")
AddESPColorPicker("Warna Window / Vault", "Window")

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

local SecUITheme = TabConfig:AddSection({"Tampilan UI"})
SecUITheme:AddDropdown({
    "Tema UI",
    Options = (Lib.Fluent and Lib.Fluent.Themes) or {"Amethyst Dark"},
    Default = "Amethyst Dark",
    Callback = function(t)
        pcall(function() Lib.Fluent:SetTheme(t) end)
    end,
})

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
    if type(data.DBD_Config) == "table" and VD_CameraDBD then
        if data.DBD_Config.Enabled ~= nil then VD_CameraDBD.SetEnabled(data.DBD_Config.Enabled) end
        if data.DBD_Config.Resolution ~= nil then VD_CameraDBD.SetResolution(data.DBD_Config.Resolution) end
    end
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