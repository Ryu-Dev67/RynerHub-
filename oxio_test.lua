--[[ Oxio Hub - Auto Steal + Anti Guard (with PanduHub shim)
     - Cuma Farm tab, cuma Auto Steal section
     - Anti Guard panel bisa di-drag, outline putih
     - Logo: rbxassetid://118755181202304
]]

local r231, r179, r180, r183, r136, r137, r181, r138, r139, r232
local r182, r233, r234, r235, r238, r240, r241, r192, r243, r244
local r247, r263

-- ============= PANDUHUB SHIM (from original oxio_sae) =============
do
    r231 = function(s4)
        local s2 = typeof(getgenv) == "function" and getgenv() or _G
        if type(s2.ChilliDebugPrint) == "function" then pcall(s2.ChilliDebugPrint, s4) end
    end

    local _PanduLib = nil
    local _ok, _err = pcall(function()
        _PanduLib = loadstring(game:HttpGet("https://script.panduhub.com/PanduUiLibrary.lua"))()
    end)
    assert(_ok and type(_PanduLib) == "table", "PanduHub failed: " .. tostring(_err))

    local function _makePanduShim(PLib)
        local function _mkHandle(defaultVal)
            local v = defaultVal
            local subs = {}
            local h = {}
            h.Get = function() return v end
            h.Set = function(_, nv)
                v = nv
                for i = 1, #subs do pcall(subs[i], nv) end
            end
            h.Subscribe = function(_, fn)
                local alive = true
                subs[#subs + 1] = function(nv) if alive then pcall(fn, nv) end end
                return {
                    Connected = true,
                    Disconnect = function(s) s.Connected = false; alive = false end,
                }
            end
            h.JoinExclusiveGroup = function() end
            h.GetQuickPath = function() return nil end
            return h
        end

        local function _pick(obj, names)
            if type(obj) ~= "table" then return nil end
            for _, n in ipairs(names) do
                if type(obj[n]) == "function" then return n end
            end
            return nil
        end

        local function _setHandle(handle, val)
            if type(handle) ~= "table" then return end
            for _, m in ipairs({ "Set", "SetValue", "set" }) do
                if type(handle[m]) == "function" then
                    pcall(handle[m], handle, val)
                    return
                end
            end
        end

        local function _dbg(...)
            local ok, g = pcall(function() return (getgenv and getgenv()) or _G end)
            if ok and type(g) == "table" and g.OxioShimDebug == true then
                pcall(warn, "[OxioShim]", ...)
            end
        end

        local function _nparams(fn)
            if type(fn) ~= "function" then return nil end
            if debug and type(debug.info) == "function" then
                local ok, n, va = pcall(debug.info, fn, "a")
                if ok and type(n) == "number" then return n, va == true end
            end
            if debug and type(debug.getinfo) == "function" then
                local ok, i = pcall(debug.getinfo, fn)
                if ok and type(i) == "table" and type(i.nparams) == "number" then
                    return i.nparams, i.isvararg == true
                end
            end
            return nil
        end

        local function _usesCfgTable(fn)
            local getc = (debug and debug.getconstants) or getconstants
            if type(getc) ~= "function" then return false end
            local ok, cs = pcall(getc, fn)
            if not ok or type(cs) ~= "table" then return false end
            for _, c in pairs(cs) do
                if c == "Callback" or c == "callback" then return true end
            end
            return false
        end

        local function _chooseForm(fn, forms)
            local n, va = _nparams(fn)
            if n and not va then
                local want = n - 1
                for _, f in ipairs(forms) do
                    if f.argc == want then return f end
                end
                local best
                for _, f in ipairs(forms) do
                    if f.argc <= want and (not best or f.argc > best.argc) then best = f end
                end
                if best then return best end
            elseif _usesCfgTable(fn) then
                for _, f in ipairs(forms) do
                    if f.cfg then return f end
                end
            end
            return forms[1]
        end

        local function _invoke(pSec, M, forms, label)
            local fn = pSec[M]
            local f = _chooseForm(fn, forms)
            local n, va = _nparams(fn)
            _dbg(label, M, "nparams=" .. tostring(n), "vararg=" .. tostring(va), "form argc=" .. tostring(f.argc))
            local ok, res = pcall(function() return fn(pSec, f.build()) end)
            if ok then return res, f end
            _dbg(label, "form gagal:", tostring(res))
            for _, g in ipairs(forms) do
                if g ~= f then
                    local ok2, res2 = pcall(function() return fn(pSec, g.build()) end)
                    if ok2 then
                        _dbg(label, "fallback form argc=" .. tostring(g.argc), "berhasil")
                        return res2, g
                    end
                end
            end
            return nil, nil
        end

        local function _readState(handle)
            if type(handle) ~= "table" then return nil end
            for _, m in ipairs({ "Get", "GetValue", "GetState" }) do
                local okf, f = pcall(function() return handle[m] end)
                if okf and type(f) == "function" then
                    local ok, v = pcall(f, handle)
                    if ok and type(v) == "boolean" then return v end
                end
            end
            for _, k in ipairs({ "Value", "State", "CurrentValue", "Enabled", "Toggled" }) do
                local ok, v = pcall(function() return handle[k] end)
                if ok and type(v) == "boolean" then return v end
            end
            return nil
        end

        local _tracked = {}
        local _pollStarted = false
        local function _startPoll()
            if _pollStarted then return end
            _pollStarted = true
            task.spawn(function()
                while true do
                    task.wait(0.25)
                    for i = 1, #_tracked do
                        local t = _tracked[i]
                        local v = _readState(t.ui)
                        if v ~= nil and v ~= t.last then
                            t.last = v
                            if v ~= t.h:Get() then
                                t.rawSet(t.h, v)
                                if type(t.cb) == "function" then pcall(t.cb, v) end
                            end
                        end
                    end
                end
            end)
        end

        local function _wrapSection(pSec)
            if type(pSec) ~= "table" then pSec = {} end
            local sec = {}

            local M_TOGGLE   = _pick(pSec, { "AddToggle", "Toggle", "CreateToggle", "AddCheckbox", "Checkbox" })
            local M_CHECKBOX = _pick(pSec, { "AddCheckbox", "Checkbox", "AddToggle", "Toggle" })
            local M_SLIDER   = _pick(pSec, { "AddSlider", "Slider", "CreateSlider", "AddRange" })
            local M_DROPDOWN = _pick(pSec, { "AddDropdown", "Dropdown", "CreateDropdown", "AddCombo" })
            local M_BUTTON   = _pick(pSec, { "AddButton", "Button", "CreateButton" })
            local M_LABEL    = _pick(pSec, { "AddLabel", "Label", "AddHeader", "Header", "AddText" })
            local M_INPUT    = _pick(pSec, { "AddTextbox", "Textbox", "AddInput", "Input" })

            local function _mkToggle(M, name, def, cb)
                local forms = {
                    { argc = 3, passDef = true, build = function() return name, def, cb end },
                    { argc = 2, build = function() return name, cb end },
                    { argc = 1, cfg = true, passDef = true, build = function()
                        return { Name = name, Text = name, Title = name, Default = def, Value = def,
                                 State = def, CurrentValue = def, Callback = cb, callback = cb }
                    end },
                }
                local handle, form = _invoke(pSec, M, forms, "toggle")
                if def and form and not form.passDef then _setHandle(handle, true) end
                return handle
            end

            local function _bindToggle(M, name, def, h, userCb)
                local syncing = false
                local ui = nil
                local rawSet = h.Set
                local function libCb(v)
                    if syncing then return end
                    if type(v) ~= "boolean" then v = not h:Get() end
                    rawSet(h, v)
                    if type(userCb) == "function" then pcall(userCb, v) end
                end
                ui = _mkToggle(M, name, def, libCb)
                h.Set = function(_, nv)
                    rawSet(h, nv)
                    if type(ui) == "table" and not syncing then
                        syncing = true
                        pcall(_setHandle, ui, nv)
                        syncing = false
                    end
                end
                task.defer(function()
                    if type(ui) == "table" then
                        syncing = true
                        pcall(_setHandle, ui, def)
                        syncing = false
                        _tracked[#_tracked + 1] = { ui = ui, h = h, rawSet = rawSet, cb = userCb, last = _readState(ui) }
                        _startPoll()
                    end
                    if def and type(userCb) == "function" then pcall(userCb, true) end
                end)
                return ui
            end

            function sec:CreateToggle(cfg)
                local def = cfg.Default == true
                local h = _mkHandle(def)
                if not M_TOGGLE then return h end
                _bindToggle(M_TOGGLE, cfg.Name or "Toggle", def, h, function(v)
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
                end)
                return h
            end

            function sec:CreateSlider(cfg)
                local name = cfg.Name or "Slider"
                local mn, mx, def = cfg.Min or 0, cfg.Max or 100, cfg.Default or cfg.Min or 0
                local h = _mkHandle(def)
                if not M_SLIDER then return h end
                local function cb(v)
                    v = tonumber(v) or def
                    h:Set(v)
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
                end
                local forms = {
                    { argc = 5, passDef = true, build = function() return name, mn, mx, def, cb end },
                    { argc = 4, build = function() return name, mn, mx, cb end },
                    { argc = 1, cfg = true, passDef = true, build = function()
                        return { Name = name, Text = name, Title = name, Min = mn, Max = mx,
                                 Default = def, Value = def, CurrentValue = def,
                                 Increment = cfg.Increment or 1, Callback = cb, callback = cb }
                    end },
                }
                local handle, form = _invoke(pSec, M_SLIDER, forms, "slider")
                if form and not form.passDef and def ~= mn then _setHandle(handle, def) end
                return h
            end

            function sec:CreateDropdown(cfg)
                local name = cfg.Name or "Dropdown"
                local opts = cfg.Options or {}
                local def  = cfg.Default or opts[1] or ""
                local h    = _mkHandle(def)
                if not M_DROPDOWN then return h end
                local function cb(v)
                    if type(v) == "table" then v = v[1] or def end
                    h:Set(v)
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
                end
                local forms = {
                    { argc = 4, passDef = true, build = function() return name, opts, def, cb end },
                    { argc = 3, build = function() return name, opts, cb end },
                    { argc = 1, cfg = true, passDef = true, build = function()
                        return { Name = name, Text = name, Title = name, Options = opts, Values = opts,
                                 Default = def, Value = def, CurrentOption = { def },
                                 Callback = cb, callback = cb }
                    end },
                }
                local handle, form = _invoke(pSec, M_DROPDOWN, forms, "dropdown")
                if form and not form.passDef then _setHandle(handle, def) end
                return h
            end

            function sec:CreateMultiDropdown(cfg)
                local opts = cfg.Options or {}
                local selected = {}
                if type(cfg.Default) == "table" then
                    for _, o in ipairs(cfg.Default) do selected[o] = true end
                else
                    for _, o in ipairs(opts) do selected[o] = true end
                end
                local h = _mkHandle(selected)

                local function fire()
                    local snap = {}
                    for o, v in pairs(selected) do if v then snap[o] = true end end
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, snap) end
                end

                if M_LABEL and cfg.Name then
                    pcall(function() pSec[M_LABEL](pSec, cfg.Name) end)
                end

                local M = M_CHECKBOX or M_TOGGLE
                if M then
                    for _, o in ipairs(opts) do
                        local rowH = _mkHandle(selected[o] == true)
                        _bindToggle(M, "  · " .. o, selected[o] == true, rowH, function(v)
                            selected[o] = v
                            h:Set(selected)
                            fire()
                        end)
                    end
                end

                task.defer(fire)
                return h
            end

            function sec:CreateButton(cfg)
                if not M_BUTTON then return nil end
                local name = cfg.Name or "Button"
                local function cb()
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback) end
                end
                local forms = {
                    { argc = 2, build = function() return name, cb end },
                    { argc = 1, cfg = true, build = function()
                        return { Name = name, Text = name, Title = name, Callback = cb, callback = cb }
                    end },
                }
                _invoke(pSec, M_BUTTON, forms, "button")
                return nil
            end

            function sec:CreateLabel(cfg)
                local h = _mkHandle(cfg.Text or cfg.Name or "")
                if not M_LABEL then return h end
                pcall(function() pSec[M_LABEL](pSec, cfg.Text or cfg.Name or "") end)
                return h
            end

            function sec:CreateText(cfg)
                local h = _mkHandle(cfg.Text or "")
                if not M_LABEL then return h end
                pcall(function() pSec[M_LABEL](pSec, cfg.Text or "") end)
                local orig = h.Set
                h.Set = function(_, nv)
                    h._text = nv
                    orig(h, nv)
                end
                return h
            end

            function sec:CreateInput(cfg)
                local name = cfg.Name or "Input"
                local def = cfg.Default or ""
                local h = _mkHandle(def)
                if not M_INPUT then return h end
                local function cb(v)
                    v = tostring(v or "")
                    h:Set(v)
                    if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
                end
                local forms = {
                    { argc = 3, passDef = true, build = function() return name, def, cb end },
                    { argc = 2, build = function() return name, cb end },
                    { argc = 1, cfg = true, passDef = true, build = function()
                        return { Name = name, Text = name, Title = name, Default = def, Value = def,
                                 Placeholder = cfg.Placeholder or "", Callback = cb, callback = cb }
                    end },
                }
                local handle, form = _invoke(pSec, M_INPUT, forms, "input")
                if form and not form.passDef and def ~= "" then _setHandle(handle, def) end
                return h
            end

            sec.CreateParagraph = function(self, cfg)
                return self:CreateText({ Text = (cfg.Title or "") .. "\n" .. (cfg.Content or "") })
            end

            return sec
        end

        local function _wrapTab(pTab)
            if type(pTab) ~= "table" then pTab = {} end
            local tab = {}
            local _defaultPage = nil

            local M_PAGE = _pick(pTab, { "CreatePage", "Page", "AddPage", "NewPage" })
            local M_SEC_DIRECT = _pick(pTab, { "CreateSection", "AddSection", "Section" })

            local function _getPage()
                if _defaultPage then return _defaultPage end
                if M_PAGE then
                    local ok, p = pcall(function() return pTab[M_PAGE](pTab, "Main") end)
                    if ok and type(p) == "table" then
                        _defaultPage = p
                        return p
                    end
                end
                return nil
            end

            function tab:CreateSection(cfg)
                local page = _getPage()
                if page then
                    local M = _pick(page, { "CreateSection", "AddSection", "Section" })
                    if M then
                        local ok, s = pcall(function() return page[M](page, cfg.Name or "Section") end)
                        if ok and type(s) == "table" then return _wrapSection(s) end
                    end
                end
                if M_SEC_DIRECT then
                    local ok, s = pcall(function() return pTab[M_SEC_DIRECT](pTab, cfg.Name or "Section") end)
                    if ok and type(s) == "table" then return _wrapSection(s) end
                end
                return _wrapSection(pTab)
            end

            local _defaultSection = nil
            local function _fallbackSection()
                if not _defaultSection then _defaultSection = _wrapSection(pTab) end
                return _defaultSection
            end

            setmetatable(tab, {
                __index = function(_, k)
                    if k == "CreateSection" then return nil end
                    local s = _fallbackSection()
                    if type(s[k]) == "function" then
                        return function(self, ...) return s[k](s, ...) end
                    end
                end,
            })

            return tab
        end

        local _pWin = nil
        local _defaultTab = nil
        local _namedStates = {}

        local function _buildWindow(cfg)
            local win = {}
            local _wStates = {}

            local M_WIN = _pick(PLib, { "CreateWindow", "Window", "new", "Create", "Init" })
            local M_TAB = nil

            if M_WIN then
                pcall(function()
                    _pWin = PLib[M_WIN](PLib, { Title = cfg.Name or "Oxio Hub" })
                end)
            end
            if _pWin then
                M_TAB = _pick(_pWin, { "CreateTab", "Tab", "AddTab", "NewTab" })
            end

            function win:CreateTab(tcfg)
                local t = nil
                if _pWin and M_TAB then
                    local ok, r = pcall(function()
                        return _pWin[M_TAB](_pWin, tcfg.Name or "Tab")
                    end)
                    if ok and type(r) == "table" then t = r end
                end
                local wrapped = _wrapTab(t or _pWin or {})
                if not _defaultTab then _defaultTab = wrapped end
                return wrapped
            end

            function win:GetDefaultTab()
                if not _defaultTab then
                    _defaultTab = win:CreateTab({ Name = "Farm" })
                end
                return _defaultTab
            end

            function win:CreateState(cfg)
                local h = _mkHandle(cfg.Default)
                if cfg.Name then
                    _wStates[cfg.Name] = h
                    _namedStates[cfg.Name] = h
                end
                return h
            end

            function win:GetState(name)
                return _wStates[name] or _namedStates[name] or _mkHandle(nil)
            end

            function win:CreateExclusiveGroup(cfg)
                return {
                    _members = {},
                    Add = function(self, h) table.insert(self._members, h) end,
                }
            end

            return win
        end

        local lib = {}
        lib.ManualQuickDefaults = {}

        function lib:CreateWindow(cfg) return _buildWindow(cfg) end

        lib.Notify = function(...)
            local M = _pick(PLib, { "Notify", "Notification", "Notif", "AddNotification" })
            if not M then return end
            local args = { ... }
            if type(args[1]) == "table" then table.remove(args, 1) end
            pcall(function()
                PLib[M](PLib, tostring(args[1] or ""), tostring(args[2] or ""))
            end)
        end

        function lib:Finalize(cfg)
            if _pWin then
                local M = _pick(_pWin, { "Finalize", "Init", "Show", "Open", "LoadUi", "Build", "Run" })
                if M then pcall(function() _pWin[M](_pWin) end) end
            end
        end

        return lib
    end

    r179 = _makePanduShim(_PanduLib)
    assert(type(r179) == "table" and type(r179.CreateWindow) == "function" and type(r179.Finalize) == "function", "Shim invalid.")

    r179.ManualQuickDefaults = { PinnedFeatures = {}, Keybinds = {}, PinGroups = {}, LeftCenterHidden = true }

    r180 = r179:CreateWindow({ Name = "Oxio Hub", DefaultTab = "Farm" })
    r183 = r180:GetDefaultTab()

    r136 = game:GetService("Players")
    r137 = game:GetService("RunService")
    r181 = game:GetService("ReplicatedStorage")
    r138 = game:GetService("CoreGui")
    r139 = game:GetService("UserInputService")
    r232 = r136.LocalPlayer
    r182 = r181:WaitForChild("Packages"):WaitForChild("Networking")

    r233 = function(fn)
        local ok, res = pcall(function() return require(fn()) end)
        return ok and res or nil
    end

    r234 = {
        EggState = r233(function() return r181.Client.EggState end),
        Assets = r233(function() return r181.Data.Assets end),
        Guards = r233(function() return r181.Data.Guards end),
        EggRecords = r233(function() return r181.Shared.Util.EggRecords end),
        Mutations = r233(function() return r181.Shared.Modules.Mutations end),
        Save = r233(function() return r181.Shared.Save end),
        AreaEggCycle = r233(function() return r181.Shared.Util.AreaEggCycle end),
        AreaEggResetWall = r233(function() return r181.Client.AreaEggResetWall end),
        AreaEggResetCycle = r233(function() return r181.Data.AreaEggResetCycle end),
        Gears = r233(function() return r181.Data.Gears end),
        Areas = r233(function() return r181.Data.Areas end),
    }

    local r4 = r234.Save
    if type(r4) == "table" and (type(r4.Get) ~= "function" or type(r4.FieldSignal) ~= "function") then
        r234.Save = setmetatable({
            Get = type(r4.Get) == "function" and r4.Get or r4.Peek,
            FieldSignal = type(r4.FieldSignal) == "function" and r4.FieldSignal or r4.Watch,
        }, { __index = r4 })
    end

    r235 = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138

    do
        local rng = Random.new()
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        r238 = function()
            local n = rng:NextInteger(12, 20)
            local out = table.create(n)
            for i = 1, n do
                local k = rng:NextInteger(1, #chars)
                out[i] = string.sub(chars, k, k)
            end
            return table.concat(out)
        end
    end

    do
        local cleanups = {}
        r240 = function(fn) table.insert(cleanups, fn) end
        r241 = {}

        local genv = typeof(getgenv) == "function" and getgenv() or _G
        if type(genv.ChilliHubSaeCleanup) == "function" then pcall(genv.ChilliHubSaeCleanup) end
        genv.ChilliHubSaeCleanup = function()
            for i = #cleanups, 1, -1 do pcall(cleanups[i]) end
            table.clear(cleanups)
        end
    end

    r244 = { _list = {}, _wake = true }
    r244.Add = function(fn)
        local s = { Run = fn, Gap = 0.35, Idle = 5, Repeat = false, Hold = 0 }
        table.insert(r244._list, s)
        return s
    end
    r244.Wake = function() r244._wake = true end
    r244.Backoff = function(s, sec) if s then s.Hold = tonumber(sec) or 6 end end

    do
        local beat = r137.Heartbeat:Connect(function(dt)
            local woke = r244._wake
            r244._wake = false
            for _, s in ipairs(r244._list) do
                s.Gap = s.Gap + dt
                s.Idle = s.Idle + dt
                if s.Hold > 0 then
                    s.Hold = s.Hold - dt
                elseif s.Gap >= 0.35 and (woke or s.Repeat or s.Idle >= 5) then
                    s.Gap = 0; s.Idle = 0
                    local ok, res = pcall(s.Run, s)
                    s.Repeat = ok and res == true
                end
            end
        end)
        r240(function() beat:Disconnect() end)
    end
end

-- ============= CORE r247 =============
do
    r247 = {
        Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
        SafeCarry = {
            Enabled = true, Blocked = {}, StretchSeconds = 6, BeatGuard = false,
            SlowUntil = 0, SlowFactor = 0.3, CarryScale = 1, EasyRatio = 1.3,
            LastSkip = nil, Category = nil, PlanOk = true, LightMult = 0.96,
            Height = 70, ClimbShare = 0.5, Approach = "Run", RunSpeed = 1.15,
            RunWait = 0, RunAnimate = true, RunHeight = 50, StraightRun = true,
            RunStyle = "Velocity", CarryStyle = "Velocity", SpeedJitter = 0.08,
            Wobble = 0, LaneOffset = 0, JumpsPerMinute = 0, PausesPerMinute = 0,
            ReactMin = 0.2, ReactMax = 0.6, CarryReact = 0, SpeedRatio = 1.5,
            ExcessSeconds = 5.5, GuardMargin = 4, GuardRatio = 1.06, MinRatio = 1.1,
            BaseWait = 6.5, FreeJump = 1500, WaitRate = 0.9, RecoverTries = math.huge,
            GuessMult = 0.93, CarryRatio = 0.9, Mult = 1, Seen = {},
            JumpDistance = 0, JumpAt = 0, LastDelivered = 0, LastFailed = 0,
            Handle = nil, Dangers = {}, DangerAt = 0,
        },
        Movement = { Owner = nil, PlaceWanted = false, StealFirst = false, MutationWanted = false, FracturedWanted = false },
        AntiGuard = { Enabled = false, Busy = false, BusySince = 0, HitArms = 0, HitArmedAt = 0, Handle = nil, PanelHandle = nil, PanelShown = true, ShowPanel = nil, Render = nil },
        Treadmill = { Riding = false },
        Flying = false, Driving = 0, ShieldPaused = false, SpeedForced = false,
        UiQueue = {},
    }

    r247.UiDefer = function(fn) table.insert(r247.UiQueue, fn) end
    r247.Notify = function(title, msg)
        if type(r179.Notify) == "function" then pcall(r179.Notify, title, msg, 5) end
    end

    r247.Toggle = function(handle, def)
        if type(handle) ~= "table" then return def == true end
        local ok, v = pcall(function() local c = handle._controller; return c and type(c.GetValue) == "function" and c.GetValue() end)
        if ok and type(v) == "boolean" then return v end
        for _, m in ipairs({ "Get", "GetValue" }) do
            local ok2, fn = pcall(function() return handle[m] end)
            if ok2 and type(fn) == "function" then
                local ok3, val = pcall(fn, handle)
                if ok3 and type(val) == "boolean" then return val end
            end
        end
        return def == true
    end

    r247.Root = function()
        local c = r232.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        return r and r:IsDescendantOf(workspace) and r or nil
    end

    r247.DistanceTo = function(pos)
        local r = r247.Root()
        if not r or not pos then return math.huge end
        return (r.Position - pos).Magnitude
    end

    r247.Grounded = function(hm)
        hm = hm or (r232.Character and r232.Character:FindFirstChildOfClass("Humanoid"))
        if not hm or hm.Health <= 0 or hm.FloorMaterial == Enum.Material.Air then return false end
        local st = hm:GetState()
        return st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.RunningNoPhysics or st == Enum.HumanoidStateType.Landed
    end

    r247.WalkSpeed = function()
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        return h and h.WalkSpeed or 16
    end

    r247.IsNight = function()
        local cyc = r234.AreaEggCycle
        if type(cyc) ~= "table" or type(cyc.IsNightPhase) ~= "function" then return false end
        local ok, res = pcall(cyc.IsNightPhase, workspace:GetServerTimeNow())
        return ok and res == true
    end

    r247.WallSealed = function()
        local w = r234.AreaEggResetWall
        if type(w) ~= "table" or type(w.IsSealed) ~= "function" then return false end
        local ok, res = pcall(w.IsSealed)
        return ok and res == true
    end

    r247.WallOpenDelay = function()
        local cyc = r234.AreaEggResetCycle
        if type(cyc) ~= "table" then return 5 end
        return (tonumber(cyc.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(cyc.WallCountdownSeconds) or 3)
    end

    r247.ClaimMovement = function(owner)
        local m = r247.Movement
        local free = m.Owner == nil or m.Owner == owner or (m.Owner == "treadmill" and owner ~= "treadmill")
        local stealPreempt = m.Owner == "scramble" and owner == "steal"
        if free or stealPreempt then m.Owner = owner; return true end
        return false
    end
    r247.ReleaseMovement = function(owner)
        if r247.Movement.Owner == owner then r247.Movement.Owner = nil end
    end

    r247.StopWalking = function()
        local c = r232.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and r then pcall(function() h:MoveTo(r.Position); h:Move(Vector3.zero, false) end) end
    end

    r247.InsideBase = function(pos)
        if not pos then local r = r247.Root(); pos = r and r.Position end
        if pos == nil then return false end
        local w = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
        local areas = w and w:FindFirstChild("Areas")
        local sep = areas and areas:FindFirstChild("SeparationLine")
        return pos.X < (sep and sep:IsA("BasePart") and sep.Position.X or 552)
    end

    r247.PlacedPoints = function()
        local folder = workspace:FindFirstChild("PlacedEggRenders")
        local out = {}
        if not folder then return out end
        local uid = tostring(r232.UserId)
        for _, m in ipairs(folder:GetChildren()) do
            if string.find(m.Name, uid, 1, true) then
                local ok, pos = pcall(function() return m:IsA("Model") and m:GetPivot() or m.CFrame end)
                if ok then table.insert(out, pos.Position) end
            end
        end
        return out
    end

    r247.OwnPlot = function()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, p in ipairs(plots:GetChildren()) do
            local lbl = p:FindFirstChild("PlotSign")
            lbl = lbl and lbl:FindFirstChild("PlayerPlotSign")
            lbl = lbl and lbl:FindFirstChild("Frame")
            lbl = lbl and lbl:FindFirstChild("PlayerName")
            if lbl and lbl:IsA("TextLabel") then
                local t = string.lower(lbl.Text)
                if t == string.lower(r232.Name) or t == string.lower(r232.DisplayName) then return p end
            end
        end
        return nil
    end

    local function avgPlaced()
        local pts = r247.PlacedPoints()
        if #pts == 0 then return nil end
        local s = Vector3.zero
        for _, p in ipairs(pts) do s += p end
        return s / #pts
    end

    r247.PenAnchor = function()
        local c = avgPlaced()
        if c then return c end
        local plot = r247.OwnPlot()
        if not plot then return nil end
        local upd = plot:FindFirstChild("ToUpdate")
        local p = (upd and upd:FindFirstChild("StarterPen")) or plot:FindFirstChild("CenterPoint")
        if not p then return nil end
        local ok, cf = pcall(function() return p:IsA("Model") and p:GetPivot() or p.CFrame end)
        return ok and cf.Position or nil
    end

    r247.Plot = function()
        local own = r247.OwnPlot()
        if own then return own end
        local plots = workspace:FindFirstChild("Plots")
        local anchor = avgPlaced()
        if not plots or not anchor then return nil end
        local best, bdist = nil, math.huge
        for _, p in ipairs(plots:GetChildren()) do
            local ok, bbcf, bbsz = pcall(function() return p:GetBoundingBox() end)
            if ok and bbcf and bbsz then
                local local_ = bbcf:PointToObjectSpace(anchor)
                if math.abs(local_.X) <= bbsz.X/2 and math.abs(local_.Z) <= bbsz.Z/2 then return p end
                local d = (bbcf.Position - anchor).Magnitude
                if d < bdist then bdist = d; best = p end
            end
        end
        if best and bdist <= 60 then return best end
        return nil
    end

    r247.Belt = function()
        local plot = r247.Plot()
        if not plot then return nil end
        local b = plot:FindFirstChild("TreadmillBottom")
        if b and b:IsA("BasePart") then return b end
        return nil
    end

    r247.Treadmill = { Riding = false }
    r247.OnBelt = function() return false end
    r247.ExitBelt = function()
        r247.Treadmill.Riding = false
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.Jump = true; h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        task.wait(0.35)
    end
    r247.LeaveBelt = function()
        local rf = r182:FindFirstChild("RF/Treadmill/AskDoff")
        if rf and rf:IsA("RemoteFunction") then pcall(rf.InvokeServer, rf) end
    end
    r247.HoldBelt = function() end
    r247.ReleaseBelt = function() end
    r247.BeltHeld = function() return false end
    r247.ResetBelt = function() end
    r247.RefreshBeltHide = function() end

    r247.BeginFlight = function()
        r247.Flying = true
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = true; pcall(function() h:ChangeState(Enum.HumanoidStateType.Freefall) end) end
        return r247.Root() ~= nil
    end
    r247.EndFlight = function()
        r247.Flying = false
        local r = r247.Root()
        if r then pcall(function() r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero end) end
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end

    local godsaved = {}
    local godOn = false
    r247.GodMode = function(on)
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not c or not h then return end
        if on then
            godOn = true
            for _, st in ipairs({ Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding }) do
                pcall(function() h:SetStateEnabled(st, false) end)
            end
            pcall(function() h.BreakJointsOnDeath = false end)
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and godsaved[p] == nil then
                    godsaved[p] = p.CanCollide
                    pcall(function() p.CanCollide = false end)
                end
            end
        elseif godOn then
            godOn = false
            for _, st in ipairs({ Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding }) do
                pcall(function() h:SetStateEnabled(st, true) end)
            end
            for part, v in pairs(godsaved) do
                if part and part.Parent then pcall(function() part.CanCollide = v end) end
            end
            table.clear(godsaved)
        end
    end
    r247.GodTick = function()
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.Health < h.MaxHealth then pcall(function() h.Health = h.MaxHealth end) end
    end

    local BAT_NAMES = { "bat", "katana", "axe", "staff", "club", "hammer", "sword", "blade" }
    r247.IsBatTool = function(t)
        if typeof(t) ~= "Instance" or not t:IsA("Tool") then return false end
        if t:GetAttribute("IsBat") == true then return true end
        local gearName = t:GetAttribute("GearName")
        if type(gearName) == "string" then
            local gd = r234.Gears and r234.Gears.Directory
            local g = type(gd) == "table" and gd[gearName] or nil
            return type(g) == "table" and g.BatControllerData ~= nil
        end
        if t:GetAttribute("ItemType") ~= nil then return false end
        local n = string.lower(t.Name)
        for _, k in ipairs(BAT_NAMES) do if string.find(n, k, 1, true) then return true end end
        return false
    end

    -- ============= SHIELD (Humanoid Swap for Anti Guard disguise) =============
    do
        local swap = { Original = nil, Clone = nil, Links = {} }

        local function clear()
            for _, c in ipairs(swap.Links) do pcall(function() c:Disconnect() end) end
            table.clear(swap.Links)
        end

        r247.UndoSwap = function()
            clear()
            local c = r232.Character
            local orig, cl = swap.Original, swap.Clone
            swap.Original, swap.Clone = nil, nil
            if orig and cl and c and orig.Parent == nil and cl.Parent == c then
                orig.Parent = c
                workspace.CurrentCamera.CameraSubject = orig
                pcall(function() cl:Destroy() end)
            end
        end
        r247.Swapped = function()
            local c = r232.Character
            return swap.Clone ~= nil and c ~= nil and swap.Clone.Parent == c
        end

        local function doSwap()
            local c = r232.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then return end
            if swap.Clone and swap.Clone.Parent == c then return end
            if not r247.Grounded(h) then return end
            local clone = h:Clone()
            h.Parent = nil
            clone.Parent = c
            workspace.CurrentCamera.CameraSubject = clone
            swap.Original, swap.Clone = h, clone
            table.insert(swap.Links, h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if clone.Parent then clone.WalkSpeed = h.WalkSpeed end
            end))
            table.insert(swap.Links, clone.Died:Connect(function()
                clear()
                local orig = swap.Original
                swap.Original, swap.Clone = nil, nil
                local cc = r232.Character
                if cc and orig and h.Parent == nil then
                    orig.Parent = cc
                    workspace.CurrentCamera.CameraSubject = orig
                end
                pcall(function() clone:Destroy() end)
                h.Health = 0
            end))
        end

        local hb, car
        local function start()
            if hb then return end
            hb = r137.Heartbeat:Connect(function()
                if r247.ShieldPaused then return end
                if os.clock() - (hb._t or 0) < 0.25 then return end
                hb._t = os.clock()
                doSwap()
            end)
            car = r232.CharacterAdded:Connect(function()
                clear(); swap.Original, swap.Clone = nil, nil
                task.spawn(function() task.wait(1); doSwap() end)
            end)
        end
        local function stop()
            if hb then hb:Disconnect(); hb = nil end
            if car then car:Disconnect(); car = nil end
            clear()
        end
        r247.Shield = function(name, on) if on then start() else stop() end end
        r247.Shield("load", true)
        r240(stop)
    end

    -- ============= EXPAND RARITY =============
    r247.ExpandRarityOptions = function()
        local opts = { "Any" }
        local map = { Any = 0 }
        local seen = {}
        local dir = r234.Assets and r234.Assets.Directory
        if type(dir) == "table" then
            for _, v in pairs(dir) do
                local rar = type(v) == "table" and v.Rarity or nil
                if type(rar) == "table" then
                    local num = tonumber(rar.RarityNumber or rar.Rank)
                    if num and not seen[num] then seen[num] = tostring(rar.DisplayName or rar._id or num) end
                end
            end
        end
        if not next(seen) then
            seen = { [1]="Common",[2]="Uncommon",[3]="Rare",[4]="Epic",[5]="Legendary",[6]="Mythic",[7]="Cosmic",[8]="Secret",[9]="Eternal",[10]="Divine" }
        end
        local nums = {}
        for k in pairs(seen) do table.insert(nums, k) end
        table.sort(nums)
        for _, n in ipairs(nums) do
            table.insert(opts, seen[n])
            map[seen[n]] = n
        end
        return opts, map
    end
end

-- ============= AUTO STEAL SECTION =============
do
    local r7_4 = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
    local r191, r264 = r247.ExpandRarityOptions()

    local r150 = { "Forest", "Desert", "Snow", "Lake", "Jungle", "Volcano", "Prehistoric", "Cosmic", "Abyss Ocean", "Cherry Blossom", "Light Dark", "Temple of Trials" }
    local areaSeen = {}
    for _, v in ipairs(r150) do areaSeen[v] = true end

    task.spawn(function()
        local st = r234.EggState
        local ok, snap = pcall(function() return st.ReadFieldEggs() end)
        if ok and type(snap) == "table" and type(snap.Records) == "table" then
            for _, rec in pairs(snap.Records) do
                local aid = type(rec) == "table" and rec.AreaId or nil
                if type(aid) == "string" and not areaSeen[aid] then
                    areaSeen[aid] = true
                    table.insert(r150, aid)
                end
            end
        end
    end)

    local r26 = r183:CreateSection({ Name = "Auto Steal", Expanded = true })
    local r265 = {}
    for _, v in ipairs(r150) do r265[v] = true end

    local r266, r267 = 0, {}
    local r268, r269, r270 = {}, {}, {}
    local r271, r272, r273 = false, {}, 0
    local r274 = r7_4[4]
    local r275, r276, r277 = 400, 27.4, 400
    local r16_2
    local r291 = 0
    local r292 = {}
    local r293 = 20
    local r294 = nil

    local function r295(arg1)
        return arg1 ~= r291 or not r247.Toggle(r16_2, false)
    end

    local function r299()
        local cyc = r234.AreaEggCycle
        if type(cyc) ~= "table" then return nil end
        local ok, now, night, nextNight, nextReset = pcall(function()
            local t = workspace:GetServerTimeNow()
            return t, cyc.IsNightPhase(t), cyc.NextNightTime(t), cyc.NextResetTime(t)
        end)
        if not ok or type(nextReset) ~= "number" then return nil end
        if nextNight == true then return nextReset + r247.WallOpenDelay(), "night", night end
        if r247.WallSealed() then return math.max(0, night), "wall", night end
        return nil
    end

    -- main steal runner (simplified but functional)
    local r310 = function(forFuse, includeCarried)
        local recs
        local st = r234.EggState
        if type(st) == "table" and type(st.ReadFieldEggs) == "function" then
            task.spawn(function()
                local ok, snap = pcall(st.ReadFieldEggs)
                if ok and type(snap) == "table" and type(snap.Records) == "table" and next(snap.Records) ~= nil then
                    recs = snap.Records
                end
            end)
        end
        if not recs then
            local rf = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
            if not rf or not rf:IsA("RemoteFunction") then return {} end
            local ok, snap = pcall(rf.InvokeServer, rf)
            recs = ok and type(snap) == "table" and snap.Records or nil
        end
        if type(recs) ~= "table" then return {} end
        local out, live = {}, {}
        for _, rec in pairs(recs) do
            local uid = type(rec) == "table" and rec.Uid or nil
            if uid and rec.State ~= "Claimed" then live[uid] = true end
            local eligible = uid and (rec.State == "Slot" or rec.State == "Dropped" or (rec.State == "Carried" and includeCarried == true and forFuse ~= true and not (r247.Steal.Carrying and uid == r247.Steal.CarryUid)))
            local forced = uid and r268[uid] or nil
            local priority = uid and r269[uid] == true or false
            local areaOK = forFuse == true or forced or priority or r265[tostring(rec.AreaId)] == true
            local blocked = forFuse ~= true and forced == nil and r270[uid] == true
            local skip = r301 ~= nil and r301[uid] == true
            eligible = eligible and typeof(rec.BottomCFrame) == "CFrame"
            if eligible then eligible = (r292[uid] or 0) <= os.clock() end
            if eligible and areaOK and not blocked and not skip then
                local info = r307(rec.AssetCategory)
                local cat = tostring(rec.AssetCategory)
                local rarityOK = info.RarityNumber >= r266
                local specOK = next(r267) == nil or r267[cat] == true
                local scale = tonumber(rec.AssetScale) or 1
                local mult = r308(rec.Mutations)
                local factor = scale > 5 and (scale/5)^1.2 * 19.637875755794113 or scale^1.85
                local valueOK = r273 <= 0 or info.EarningRate * factor * mult >= r273
                valueOK = rarityOK and specOK and valueOK
                local unsafe = forFuse ~= true and r247.SafeCarry.Unsafe({ Uid = uid, Category = cat })
                if unsafe then
                    r268[uid] = nil; r269[uid] = nil
                    r247.SafeCarry.LastSkip = unsafe
                elseif forFuse == true or forced or priority or valueOK then
                    table.insert(out, {
                        Uid = uid, Category = cat, Scale = scale, State = rec.State,
                        Rarity = info.RarityNumber, Weight = r309(rec.AssetCategory, scale),
                        Mutation = mult, Value = info.EarningRate * factor * mult,
                        CFrame = rec.BottomCFrame, AreaId = tostring(rec.AreaId),
                        Forced = forFuse ~= true and forced and forced.At or nil,
                        Priority = forFuse ~= true and priority,
                    })
                end
            end
        end
        if next(live) ~= nil then
            for k in pairs(r268) do if not live[k] then r268[k] = nil end end
            for k in pairs(r269) do if not live[k] then r269[k] = nil end end
            for k in pairs(r270) do if not live[k] then r270[k] = nil end end
        end
        table.sort(out, function(a, b)
            if (a.Forced ~= nil) ~= (b.Forced ~= nil) then return a.Forced ~= nil end
            if a.Forced and b.Forced and a.Forced ~= b.Forced then return a.Forced < b.Forced end
            if a.Priority ~= b.Priority then return a.Priority == true end
            if r274 == r7_4[2] and a.Weight ~= b.Weight then return a.Weight > b.Weight end
            if r274 == r7_4[3] and a.Mutation ~= b.Mutation then return a.Mutation > b.Mutation end
            if r274 == r7_4[4] and a.Value ~= b.Value then return a.Value > b.Value end
            if r274 == r7_4[5] and a.Value ~= b.Value then return a.Value < b.Value end
            if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
            if a.Value ~= b.Value then return a.Value > b.Value end
            return tostring(a.Uid) < tostring(b.Uid)
        end)
        return out
    end

    function r307(cat)
        local dir = r234.Assets and r234.Assets.Directory
        local a = type(dir) == "table" and dir[tostring(cat)] or nil
        local rar = type(a) == "table" and type(a.Rarity) == "table" and a.Rarity or nil
        local out = {}
        if rar then rar = tonumber(rar.RarityNumber or rar.Rank) end
        out.RarityNumber = rar or 0
        out.EarningRate = type(a) == "table" and tonumber(a.EarningRate) or 0
        return out
    end
    function r308(muts)
        local m = r234.Mutations
        if type(m) == "table" and type(m.EarningsFor) == "function" then
            local ok, v = pcall(m.EarningsFor, type(muts) == "table" and muts or {})
            if ok and type(v) == "number" then return v end
        end
        return 1
    end
    function r309(cat, scale)
        local er = r234.EggRecords
        if type(er) == "table" and type(er.WeightKgForScale) == "function" then
            local ok, v = pcall(er.WeightKgForScale, cat, scale)
            if ok and type(v) == "number" then return v end
        end
        return 0
    end

    local r301, r302 = nil, 0
    local function r303(skipFirst)
        local out = {}
        local st = r234.EggState
        if type(st) ~= "table" or type(st.ReadFieldEggs) ~= "function" then return out end
        task.spawn(function()
            local ok, snap = pcall(st.ReadFieldEggs)
            if ok and type(snap) == "table" and type(snap.Records) == "table" then
                local prefix = "FirstAreaEgg_" .. tostring(r232.UserId)
                for _, rec in pairs(snap.Records) do
                    if type(rec) == "table" and type(rec.Uid) == "string" then
                        if not (skipFirst and string.sub(rec.Uid, 1, #prefix) == prefix) then
                            out[rec.Uid] = true
                        end
                    end
                end
            end
        end)
        return out
    end
    local function r305()
        if r301 and r302 == math.huge then return end
        r301 = r303(true)
        r302 = math.huge
        table.clear(r268); table.clear(r270); table.clear(r269); table.clear(r292)
        r294 = nil
    end
    local function r306()
        if not r301 then return false end
        if os.clock() >= r302 then r301 = nil; return false end
        local cur = r303()
        if next(cur) == nil then return true end
        local seen, unseen = false, false
        for k in pairs(cur) do
            if r301[k] then seen = true else unseen = true end
        end
        if not seen then r301 = nil; return false end
        return not unseen
    end

    -- fly to pos
    local r318, r319, r322, r314, r315
    do
        local r312, r313, r316, r317 = nil, nil, nil, {}
        r318 = function()
            r312 = nil
            if r313 then r313:Disconnect(); r313 = nil end
            if r316 then r316:Disconnect(); r316 = nil end
        end
        r319 = function()
            local t = tonumber(r232:GetAttribute("RagdollEndTime"))
            return t ~= nil and t > workspace:GetServerTimeNow()
        end
        r322 = function(target, walk)
            r312 = target
            if not target then return end
            r317 = {}
            r313 = r137.Heartbeat:Connect(function()
                if not r312 or r319() or r247.AntiGuard.Busy then return end
                local r = r247.Root()
                if not r then return end
                pcall(function()
                    local rot = r.CFrame.Rotation
                    r.CFrame = CFrame.new(r312) * rot
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                end)
            end)
        end
        r314 = function(part, target, speed, dt, mem)
            local delta = target - part.Position
            local dist = delta.Magnitude
            local step = math.max(dt, 1/240)
            local v = dist > 0.01 and delta.Unit * math.min(speed, dist / step) or Vector3.zero
            local v2 = v + Vector3.new(0, workspace.Gravity * step * 0.5, 0)
            pcall(function()
                part.AssemblyLinearVelocity = v2
                part.AssemblyAngularVelocity = Vector3.zero
            end)
            return dist <= 0.5
        end
        r315 = function()
            local r = r247.Root()
            if r then pcall(function() r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero end) end
        end
    end
    r240(r318)

    local r323 = function()
        r318()
        r247.EndFlight()
        r247.GodMode(false)
        local c = r232.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end

    local r347 = function(target, abortFn, needCarry, speedOverride)
        r318()
        local r = r247.Root()
        if not r then return false end
        local char = r232.Character
        local startPos = r.Position
        local mem = {}
        local done, elapsed = nil, 0
        local c1 = r137.Heartbeat:Connect(function(dt)
            if done ~= nil then return end
            elapsed = elapsed + dt
            if r295(abortFn) then done = false; return end
            if needCarry and not r247.Steal.Carrying then done = false; return end
            local cur = r247.Root()
            if not cur or elapsed >= 25 or r232.Character ~= char then done = false; return end
            local spd = speedOverride or r275
            local delta = target - startPos
            local step = spd * dt
            local arrived = delta.Magnitude <= math.max(step, 0.05)
            startPos = arrived and target or startPos + delta.Unit * step
            local flat = Vector3.new(delta.X, 0, delta.Z)
            local rot = flat.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, flat.Unit) or cur.CFrame.Rotation
            pcall(function()
                cur.CFrame = CFrame.new(startPos) * rot
                cur.AssemblyLinearVelocity = Vector3.zero
                cur.AssemblyAngularVelocity = Vector3.zero
            end)
            if arrived then done = true end
        end)
        local c2 = r137.PreSimulation:Connect(function(dt)
            if done ~= nil then return end
            if r295(abortFn) then done = false; return end
            if needCarry and not r247.Steal.Carrying then done = false; return end
            local cur = r247.Root()
            if not cur then done = false; return end
            local spd = speedOverride or r275
            if r314(cur, target, spd, dt, mem) then done = true end
        end)
        while done == nil do r137.Heartbeat:Wait() end
        c1:Disconnect(); c2:Disconnect()
        if done and r322 then r322(target, speedOverride ~= nil) end
        return done
    end

    -- quick grab via prompt
    local function smartPromptNear(uid, pos, radius)
        radius = radius or 14
        local best, bestDist = nil, radius
        for _, p in ipairs(workspace:GetChildren()) do
            if p.Name == "SmartPromptPart" and p:IsA("BasePart") then
                local cp = p:FindFirstChild("CarryAreaEgg")
                if cp and cp:IsA("ProximityPrompt") then
                    local d = (p.Position - pos).Magnitude
                    if d < bestDist then bestDist = d; best = cp end
                end
            end
        end
        return best
    end
    local function firePrompt(prompt)
        if not prompt then return false end
        pcall(function() prompt.HoldDuration = 0 end)
        if typeof(fireproximityprompt) == "function" then return pcall(fireproximityprompt, prompt) end
        return false
    end
    local function carryFallback(uid)
        local st = r234.EggState
        if type(uid) == "string" and type(st) == "table" and type(st.CarryFieldEgg) == "function" then
            pcall(st.CarryFieldEgg, uid)
        end
    end

    local function r337(egg, abortUid)
        local pos = typeof(egg.CFrame) == "CFrame" and egg.CFrame.Position or nil
        if not pos then return false end
        local elapsed, promptCooldown, misses = 0, math.huge, 0
        while elapsed < 1.5 do
            if r295(abortUid) then return false end
            if r247.Steal.Carrying and not r247.Steal.WrongEgg(egg.Uid) then return true end
            if promptCooldown >= 0.06 then
                local prompt = smartPromptNear(egg.Uid, pos)
                if prompt then
                    pcall(function() prompt.HoldDuration = 0 end)
                    misses = 0
                    firePrompt(prompt)
                else
                    misses += 1
                    if misses >= 4 then return false end
                    carryFallback(egg.Uid)
                end
                promptCooldown = 0
            end
            local dt = r137.Heartbeat:Wait()
            elapsed += dt
            promptCooldown += dt
        end
        return r247.Steal.Carrying == true
    end

    local function r340(uid, abortUid)
        if r247.Steal.Carrying then return true end
        local rf = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
        if not rf or not rf:IsA("RemoteFunction") then return false end
        local t = 0
        while t < 1 do
            if r295(abortUid) or r247.Steal.Carrying then return r247.Steal.Carrying == true end
            local ok, snap = pcall(rf.InvokeServer, rf)
            local recs = ok and type(snap) == "table" and snap.Records or nil
            if type(recs) == "table" then
                local alive = false
                for _, r in pairs(recs) do
                    if type(r) == "table" and r.Uid == uid and (r.State == "Slot" or r.State == "Dropped") then
                        alive = true; break
                    end
                end
                if not alive then return r247.Steal.Carrying == true end
            end
            t += task.wait(0.3)
        end
        return r247.Steal.Carrying == true
    end

    local r326 = 0.6
    local function currentCarryUid()
        local u = r247.Steal.CarryUid
        return type(u) == "string" and u or nil
    end
    local function matchesCarryUid(uid)
        local cur = currentCarryUid()
        if not cur or type(uid) ~= "string" then return true end
        return cur == uid
    end
    local function stillInList(uid)
        if type(uid) ~= "string" then return false end
        local list = r310(false, true)
        if #list == 0 then return true end
        for _, e in ipairs(list) do if e.Uid == uid then return true end end
        return false
    end
    local function dropHeld(abortUid)
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then
            pcall(st.DropFieldEgg, "PlayerRequest")
        end
        local g = 0
        while r247.Steal.Carrying and g < 1 and not r295(abortUid) do g += r137.Heartbeat:Wait() end
    end
    local function r336(expectedUid, abortUid)
        local g = 0
        while not r247.Steal.Carrying and g < r326 and not r295(abortUid) do
            g += r137.Heartbeat:Wait()
        end
        if not r247.Steal.Carrying then return false end
        if matchesCarryUid(expectedUid) then return true end
        if stillInList(currentCarryUid()) then return true end
        dropHeld(abortUid)
        return false
    end

    local r3_6 = function()
        local paths = {
            { Path = { "GearGiver_Slap", "Podium" }, Offset = Vector3.new(-16.415, 21.072, -6.106) },
            { Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Offset = Vector3.new(-26.776, 1.75, 18.665) },
            { Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Offset = Vector3.new(-26.776, 1.75, 18.665) },
        }
        for _, p in ipairs(paths) do
            local node = workspace
            for _, name in ipairs(p.Path) do node = node and node:FindFirstChild(name) or nil end
            if node and node:IsA("BasePart") then return node.CFrame:PointToWorldSpace(p.Offset) end
        end
        return Vector3.new(528.7, 70.57, -364.11)
    end
    r247.StealHome = r3_6

    local r366 = function(egg, abortUid)
        local pos = typeof(egg.CFrame) == "CFrame" and egg.CFrame.Position or nil
        if not pos then return false end
        if r247.InsideBase() and not r247.InsideBase(pos) then
            local h = r3_6()
            if h and not r347(h + Vector3.new(0, 3, 0), abortUid, nil, r277) then return false end
        end
        if not r347(pos + Vector3.new(0, 3, 0), abortUid, nil, r277) then return false end
        local grabbed = r337(egg, abortUid)
        if not grabbed and not r295(abortUid) then grabbed = r337(egg, abortUid) end
        if not grabbed and not r340(egg.Uid, abortUid) then
            r292[egg.Uid] = os.clock() + r293
            return false
        end
        r247.Steal.LastFinishedAt = os.clock()
        return true
    end

    local r371 = function(abortUid)
        local t = 0
        while not r247.Steal.Carrying and t < r326 and not r295(abortUid) do t += r137.Heartbeat:Wait() end
        if not r247.Steal.Carrying then return false end
        local home = r3_6()
        local r = r247.Root()
        if not home or not r then return false end
        local flyY = math.max(r.Position.Y, home.Y) + r276
        if not r347(Vector3.new(r.Position.X + (home.X - r.Position.X) * 0.25, r.Position.Y + (flyY - r.Position.Y) * 0.7, r.Position.Z + (home.Z - r.Position.Z) * 0.25), abortUid, true, nil) then return false end
        if not r347(Vector3.new(home.X, flyY, home.Z), abortUid, true, nil) then return false end
        if not r347(home, abortUid, true, nil) then return false end
        if not r247.Steal.Carrying then return false end
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then
            pcall(st.DropFieldEgg, "PlayerRequest")
        end
        return true
    end

    r247.Steal.WrongEgg = function(uid)
        local s = r247.Steal
        if type(uid) ~= "string" or not s.Carrying or s.CarryUid == uid then return false end
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then
            pcall(st.DropFieldEgg, "PlayerRequest")
        end
        local t = 0
        while s.Carrying and t < 1 do t += r137.Heartbeat:Wait() end
        s.Carrying = false
        s.CarryUid = uid
        return true
    end

    local r379 = function()
        local session = r291
        r247.Steal.Active = true
        r247.Steal.Carrying = r247.Steal.Carrying == true
        if not r247.Steal.Carrying then r247.Steal.CarryUid = nil end

        local list = r310(false, true)
        local target
        for _, e in ipairs(list) do
            if e.State ~= "Carried" then
                local reason = r247.SafeCarry.Unsafe(e)
                if not reason then target = e; break end
            end
        end
        r294 = target and target.Uid or nil
        r247.Steal.Wanted = target ~= nil
        if not target then r247.Steal.Active = false; return false end

        if not r247.ClaimMovement("steal") then
            r247.Steal.Active = false
            return false
        end

        if r247.Treadmill.Riding or r247.OnBelt() then r247.ExitBelt() end
        r247.HoldBelt()

        local function finish()
            r323()
            r247.Steal.Active = false
            r247.Steal.LastFinishedAt = os.clock()
            return true
        end

        if r366(target, session) then
            if r336(target.Uid, session) then r371(session) end
        end
        return finish()
    end

    r247.SafeCarry.Unsafe = function(entry)
        local sc = r247.SafeCarry
        if not sc.Enabled or type(entry) ~= "table" or not entry.Uid or not sc.Blocked[entry.Uid] then return nil end
        return string.format("the guard caught you with this %s before, skipping it", tostring(entry.Category))
    end

    local r378 = 0
    local worker = function()
        if not r247.Toggle(r16_2, false) then return false end
        local waitTime, kind = r299()
        if waitTime then
            if kind == "night" then r305() end
            r247.Movement.StealFirst = true
            r247.Steal.Wanted = false
            if r247._stealRunning then
                r291 += 1
                r247.Steal.Active = false
                r323()
                r247.StopWalking()
            end
            return false
        end
        if r301 and r302 == math.huge then r302 = os.clock() + 8 end
        if r247._stealRunning then return true end
        if r306() then r244.Wake(); return false end
        local mOwner = r247.Movement.Owner
        if mOwner and mOwner ~= "steal" and mOwner ~= "treadmill" then
            r247.Movement.StealFirst = true
            return true
        end
        if os.clock() < r378 then return true end
        r247.Movement.StealFirst = false
        r247._stealRunning = true
        task.spawn(function()
            local ok = pcall(r379)
            if not ok then r323(); r247.Steal.Active = false end
            r247._stealRunning = false
            r247.ReleaseMovement("steal")
            r378 = os.clock() + 0.6
            r244.Wake()
        end)
        return true
    end

    r16_2 = r26:CreateToggle({
        Name = "Auto Steal",
        Default = false,
        Callback = function()
            r291 += 1
            table.clear(r292)
            r247.Steal.Active = false
            r247.Steal.Wanted = false
            if not r247.Toggle(r16_2, false) then
                r247.Movement.StealFirst = false
                table.clear(r268); table.clear(r269); table.clear(r270)
            end
            r323()
            r247.StopWalking()
            r244.Wake()
        end,
    })

    r243(r26:CreateMultiDropdown({
        Name = "Target Areas",
        Options = r150,
        Default = r150,
        Callback = function(sel)
            local out = {}
            if type(sel) == "table" then
                for k, v in pairs(sel) do
                    if v == true and type(k) == "string" then out[k] = true
                    elseif type(v) == "string" then out[v] = true end
                end
            end
            if next(out) == nil then for _, v in ipairs(r150) do out[v] = true end end
            r265 = out
        end,
    }))

    r26:CreateDropdown({
        Name = "Min Rarity",
        Note = "Steal eggs of the chosen rarity and above",
        Options = r191,
        Default = r191[1],
        Callback = function(v) r266 = r264[v] or 0 end,
    })

    r26:CreateSlider({
        Name = "Tween Speed",
        Min = 100, Max = 1000, Default = 400, Increment = 10, Unit = "studs/s",
        Callback = function(v)
            local s = math.clamp(tonumber(v) or 400, 100, 1000)
            r275, r277 = s, s
        end,
    })

    r26:CreateDropdown({
        Name = "Steal Priority",
        Options = r7_4,
        Default = r7_4[4],
        Callback = function(v) if table.find(r7_4, v) then r274 = v end end,
    })

    r247.SafeCarry.Handle = r26:CreateToggle({
        Name = "Safe Delivery",
        Note = "Best with Anti Guard on",
        Default = true,
        Callback = function(v)
            if type(v) ~= "boolean" then v = r247.Toggle(r247.SafeCarry.Handle, true) end
            r247.SafeCarry.Enabled = v == true
            r244.Wake()
        end,
    })

    r26:CreateSlider({
        Name = "Carry Speed",
        Note = "Lower it if you get Delivery failed",
        Min = 80, Max = 120, Default = 100, Increment = 1, Unit = "%",
        SubOf = r247.SafeCarry.Handle,
        Callback = function(v) r247.SafeCarry.CarryScale = math.clamp(tonumber(v) or 100, 80, 120) / 100 end,
    })

    r26:CreateLabel({ Name = "Anti Guard Divider", Text = "───── Anti Guard ─────" })

    r247.AntiGuard.PanelHandle = r26:CreateToggle({
        Name = "Anti Guard Panel",
        Default = true,
        Callback = function(v)
            if type(v) ~= "boolean" then v = r247.Toggle(r247.AntiGuard.PanelHandle, true) end
            r247.AntiGuard.PanelShown = v
            if r247.AntiGuard.ShowPanel then pcall(r247.AntiGuard.ShowPanel, v) end
        end,
    })

    r247.AntiGuard.Handle = r180:CreateState({ Name = "Anti Guard Enabled", Default = false })
    pcall(function() r247.AntiGuard.Enabled = r247.AntiGuard.Handle:Get() == true end)
    pcall(function()
        r247.AntiGuard.Handle:Subscribe(function(v)
            if type(v) ~= "boolean" then v = r247.AntiGuard.Handle:Get() end
            r247.AntiGuard.Enabled = v == true
            if r247.AntiGuard.Render then
                r247.UiDefer(function() pcall(r247.AntiGuard.Render, false) end)
            end
        end)
    end)

    r244.Add(worker)
end

-- ============= ANTI GUARD PANEL =============
do
    local r164 = game:GetService("GuiService")
    local r165 = game:GetService("StarterGui")
    local r1550 = r247.AntiGuard
    local r163_4 = game:GetService("TweenService")

    -- White outline colors
    local r1554 = {
        Card = Color3.fromRGB(15, 15, 19),
        CardTop = Color3.fromRGB(24, 22, 28),
        Stroke = Color3.fromRGB(48, 46, 56),
        Text = Color3.fromRGB(240, 238, 244),
        AccentA = Color3.fromRGB(255, 255, 255),
        AccentB = Color3.fromRGB(225, 225, 235),
        Good = Color3.fromRGB(80, 220, 140),
        Work = Color3.fromRGB(255, 190, 70),
        Bad = Color3.fromRGB(240, 90, 90),
        Off = Color3.fromRGB(58, 56, 66),
    }

    local r5_65 = {
        { Path = { "GearGiver_Slap", "Podium" }, Offset = Vector3.new(-16.415, 21.072, -6.106) },
        { Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Offset = Vector3.new(-26.776, 1.75, 18.665) },
        { Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Offset = Vector3.new(-26.776, 1.75, 18.665) },
    }

    local r1556, r1557 = 52, true
    local r1558 = {}
    local r1559 = { AreaId = nil, SignalCarrying = false, WeldCarrying = false, Carrying = false, Active = false, Disguise = nil, FlashRequest = nil, FlashUntil = 0 }

    local function randName()
        local s = {}
        for i = 1, math.random(10, 16) do s[i] = string.char(math.random(97, 122)) end
        return table.concat(s)
    end
    local r1560 = randName

    local r1561 = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138

    local function newInst(class, parent, props)
        local i = Instance.new(class)
        i.Name = randName()
        for k, v in pairs(props or {}) do i[k] = v end
        i.Parent = parent
        return i
    end
    local r1_68 = newInst

    local r230 = function(obj, dur, props, style)
        local ok, t = pcall(function()
            return r163_4:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        end)
        if ok and t then t:Play() end
    end

    local r11_47
    local r1584 = function()
        local root = r247.Root()
        if not root then return nil end
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("Hitbox") then
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("JointInstance") or d:IsA("WeldConstraint") or d:IsA("RigidConstraint") then
                        local ok, p0, p1 = pcall(function() return d.Part0, d.Part1 end)
                        if ok and (p0 == root or p1 == root) then return m end
                    end
                end
            end
        end
        return nil
    end
    local r1585 = function(model, parent)
        local saved = {}
        for _, d in ipairs(model:GetDescendants()) do
            saved[d] = d.Archivable
            pcall(function() d.Archivable = true end)
        end
        local wasArch = model.Archivable
        model.Archivable = true
        local ok, clone = pcall(function() return model:Clone() end)
        model.Archivable = wasArch
        for k, v in pairs(saved) do pcall(function() k.Archivable = v end) end
        if not ok or not clone then return nil end
        clone.Name = randName()
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ForceField") or d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("WeldConstraint") or d:IsA("BodyMover") or d:IsA("ProximityPrompt") or d:IsA("BillboardGui") then
                pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                d.Anchored = true; d.CanCollide = false; d.CanQuery = false; d.CanTouch = false
            elseif d:IsA("Humanoid") then
                d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                d.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            end
        end
        clone.Parent = parent
        return clone
    end
    local r1586 = function(char, offset)
        local cam = workspace.CurrentCamera
        if not char or not cam or r1559.Disguise then return end
        offset = offset or Vector3.zero
        local st = { Camera = cam, CameraType = cam.CameraType, CameraCFrame = cam.CFrame, Copies = {}, Hidden = {} }
        r1559.Disguise = st
        local models = { char }
        local ok, m = pcall(r1584)
        if ok and m then models[#models+1] = m end
        for _, mm in ipairs(models) do
            for _, d in ipairs(mm:GetDescendants()) do
                if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
                    st.Hidden[#st.Hidden+1] = d
                end
            end
        end
        local function hide()
            for _, d in ipairs(st.Hidden) do pcall(function() d.LocalTransparencyModifier = 1 end) end
            pcall(function()
                if cam.CameraType ~= Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Scriptable end
                cam.CFrame = st.CameraCFrame
            end)
        end
        hide()
        st.BindName = randName()
        if not pcall(function() r137:BindToRenderStep(st.BindName, Enum.RenderPriority.Last.Value + 1, hide) end) then
            st.BindName = nil
            st.Link = r137.RenderStepped:Connect(hide)
        end
        st.Beat = r137.Heartbeat:Connect(hide)
        for _, mm in ipairs(models) do
            local ok2, clone = pcall(r1585, mm, cam)
            if ok2 and clone then
                if offset.Magnitude > 0.01 then
                    for _, d in ipairs(clone:GetDescendants()) do
                        if d:IsA("BasePart") then pcall(function() d.CFrame = d.CFrame + offset end) end
                    end
                end
                st.Copies[#st.Copies+1] = clone
            end
        end
    end
    local r1587 = function()
        local st = r1559.Disguise
        if not st then return end
        r1559.Disguise = nil
        if st.BindName then pcall(function() r137:UnbindFromRenderStep(st.BindName) end) end
        if st.Link then pcall(function() st.Link:Disconnect() end) end
        if st.Beat then pcall(function() st.Beat:Disconnect() end) end
        for _, d in ipairs(st.Hidden) do pcall(function() d.LocalTransparencyModifier = 0 end) end
        pcall(function() st.Camera.CameraType = st.CameraType end)
        for _, c in ipairs(st.Copies) do pcall(function() c:Destroy() end) end
    end
    local r1588 = function()
        for _, p in ipairs(r5_65) do
            local n = workspace
            for _, name in ipairs(p.Path) do n = n and n:FindFirstChild(name) or nil end
            if n and n:IsA("BasePart") then return n.CFrame:PointToWorldSpace(p.Offset) end
        end
        return Vector3.new(528.7, 70.57, -364.11)
    end
    local r1589 = function(char, root, pos, rot, freeze)
        local cf = CFrame.new(pos) * rot
        pcall(function() char:PivotTo(cf) end)
        if (root.Position - pos).Magnitude > 3 then pcall(function() root.CFrame = cf end) end
        if freeze == false then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.AssemblyLinearVelocity = Vector3.zero; p.AssemblyAngularVelocity = Vector3.zero end) end
        end
    end
    local function areaId()
        local id = r1559.AreaId
        if type(id) ~= "string" or id == "" then id = type(r247.Steal) == "table" and r247.Steal.CarryAreaId or nil end
        if type(id) ~= "string" or id == "" then
            local a = r232:GetAttribute("AreaId")
            id = type(a) == "string" and a or nil
        end
        return id
    end
    local function pickConfig()
        local ok, custom = pcall(function() return getgenv().OxioAntiGuard end)
        if ok and type(custom) == "table" then
            if type(custom.Steps) == "table" then return custom end
            if type(custom.Default) == "table" then return custom.Default end
        end
        return {
            Target = "line", LineOffset = 8, Height = 45, OffsetX = -90, OffsetZ = -35,
            Jitter = 0, Point = false, Disguise = true, Limp = true, Facing = "Zero",
            Freeze = false, StartAt = 0,
            Steps = { { At = 0.1, To = "home" }, { At = 0.33, To = "home" }, { At = 0.56, To = "home" }, { At = 0.75, To = "start" } },
            ReleaseAt = 0.8, WeldScanGap = 0.03, BusyLimit = 2.5,
        }
    end
    local function randJitter(amount)
        if amount <= 0 then return 0 end
        return (math.random() * 2 - 1) * amount
    end
    local function buildSteps(cfg)
        local steps = type(cfg.Steps) == "table" and cfg.Steps or {}
        local release = tonumber(cfg.ReleaseAt) or 0
        local startAt = math.max(tonumber(cfg.StartAt) or 0, 0)
        return steps, release, startAt
    end
    local function linePoint(cfg, base)
        local w = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
        local areas = w and w:FindFirstChild("Areas")
        local sep = areas and areas:FindFirstChild("SeparationLine")
        if sep and sep:IsA("BasePart") then
            local cf = sep.CFrame
            local perp = (Vector3.new(0, 1, 0)):Cross(sep.Size.X >= sep.Size.Z and cf.RightVector or cf.LookVector)
            local flat = Vector3.new(perp.X, 0, perp.Z)
            if flat.Magnitude > 0.001 then
                local u = flat.Unit
                local p = cf.Position + ((base - cf.Position):Dot(u) >= 0 and -u or u) * (tonumber(cfg.LineOffset) or 8)
                return Vector3.new(p.X, base.Y + 0.5, p.Z)
            end
        end
        return nil
    end
    local function targetPos(cfg, base)
        local kind = tostring(cfg.Target or "home")
        if kind == "sky" then return base end
        if kind == "point" and typeof(cfg.Point) == "Vector3" then return cfg.Point end
        if kind == "line" then local lp = linePoint(cfg, base); if lp then return lp end end
        return r1588()
    end
    local function finalPos(cfg, base)
        return targetPos(cfg, base) + Vector3.new(tonumber(cfg.OffsetX) or 0, tonumber(cfg.Height) or 0, tonumber(cfg.OffsetZ) or 0)
    end
    local function reset()
        r1559.Active = false
        r1550.Busy = false
    end
    local function runSteal(session)
        local char = r232.Character
        local root = r247.Root()
        local hm = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hm or hm.Health <= 0 then reset(); r11_47(r1554.Bad, 1.6); return end
        local alive = function() return r1557 and root.Parent and hm.Parent and hm.Health > 0 end
        local hadStand = hm.PlatformStand
        local startCF = root.CFrame
        local startPos = startCF.Position
        local cfg = pickConfig()
        local steps, releaseAt, startAt = buildSteps(cfg)
        local freeze = cfg.Freeze ~= false
        local facing = tostring(cfg.Facing or "Keep")
        local jitter = math.max(tonumber(cfg.Jitter) or 0, 0)
        local baseRot = facing == "Zero" and CFrame.new() or startCF.Rotation
        local function pickRot()
            if facing == "Spin" then return CFrame.Angles(0, math.rad(math.random(0, 359)), 0) end
            return baseRot
        end
        local function jittered(p)
            if jitter <= 0 then return p end
            return p + Vector3.new((math.random()*2-1)*jitter, 0, (math.random()*2-1)*jitter)
        end
        local jumpTarget = finalPos(cfg, startPos)
        local function sleep(untilTime)
            while alive() and os.clock() - session < untilTime do
                r137.Heartbeat:Wait()
                if freeze then pcall(function() root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end) end
            end
            return alive()
        end
        local function snapMove(pos, rot)
            r1589(char, root, pos, rot, freeze)
            r137.PreSimulation:Wait()
            if alive() and (root.Position - pos).Magnitude > 3 then r1589(char, root, pos, rot, freeze) end
        end
        pcall(function() hm.BreakJointsOnDeath = false end)
        if cfg.Disguise ~= false then pcall(r1586, char, Vector3.zero) end
        r11_47(r1554.Work)
        if sleep(startAt) and cfg.Limp ~= false then hm.PlatformStand = true end
        local prev = startPos
        for _, step in ipairs(steps) do
            if type(step) ~= "table" then break end
            if sleep(tonumber(step.At) or 0) then break end
            local dest = step.To == "start" and startPos or jittered(jumpTarget)
            local rot = pickRot()
            if type(step.Glide) == "table" and #step.Glide > 0 then
                for _, t in ipairs(step.Glide) do
                    if not alive() then break end
                    local f = math.clamp(tonumber(t) or 1, 0, 1)
                    r1589(char, root, prev:Lerp(dest, f), rot, freeze)
                    r137.Heartbeat:Wait()
                end
                prev = dest
            else
                snapMove(dest, rot)
                prev = dest
            end
        end
        sleep(releaseAt)
        pcall(function() hm.PlatformStand = hadStand end)
        r1587()
        reset()
        if alive() and r1559.Carrying then r11_47(r1554.Good, 1.6) else r11_47(r1554.Bad, 1.6) end
    end
    local function safeRun(session)
        if not pcall(runSteal, session) then
            pcall(function()
                local c = r232.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then h.PlatformStand = false end
            end)
            r1587(); reset(); r11_47(r1554.Bad, 1.6)
        end
    end
    local function hitArmExpired()
        if r1550.HitArms <= 0 then return false end
        if 25 < os.clock() - (r1550.HitArmedAt or 0) then r1550.HitArms = 0; return false end
        return true
    end
    local function updateCarry()
        local was = r1559.Carrying
        r1559.Carrying = r1559.SignalCarrying or r1559.WeldCarrying
        if r1559.Carrying and not was and r1557 and r1550.Enabled and not r1559.Active and not hitArmExpired() then
            r1559.Active = true
            r1550.Busy = true
            r1550.BusySince = os.clock()
            task.spawn(safeRun, os.clock())
        end
    end

    -- ===== UI =====
    local screen = newInst("ScreenGui", nil, {
        ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = -100,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local frame = newInst("Frame", screen, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 1, -120),
        Size = UDim2.fromOffset(226, 52),
        BackgroundTransparency = 1,
    })
    local frameScale = newInst("UIScale", frame, { Scale = 1 })
    local card = newInst("Frame", frame, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = r1554.Card,
        BorderSizePixel = 0, Active = true,
    })
    newInst("UICorner", card, { CornerRadius = UDim.new(0, 14) })
    local cardScale = newInst("UIScale", card, { Scale = 0.86 })
    newInst("UIGradient", card, { Color = ColorSequence.new(r1554.CardTop, r1554.Card), Rotation = 90 })
    local cardStroke = newInst("UIStroke", card, {
        Thickness = 1.5, Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    local strokeGrad = newInst("UIGradient", cardStroke, { Color = ColorSequence.new(r1554.Stroke, r1554.Stroke) })
    local iconBg = newInst("Frame", card, {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(36, 36), BackgroundColor3 = Color3.fromRGB(28, 26, 32),
        BorderSizePixel = 0, ZIndex = 2,
    })
    newInst("UICorner", iconBg, { CornerRadius = UDim.new(0, 11) })
    local iconStroke = newInst("UIStroke", iconBg, { Thickness = 1.5, Color = r1554.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local icon = newInst("ImageLabel", iconBg, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.86, 0.86), BackgroundTransparency = 1,
        Image = "rbxassetid://118755181202304",
        ImageTransparency = 0.35, ScaleType = Enum.ScaleType.Crop, ZIndex = 3,
    })
    newInst("UICorner", icon, { CornerRadius = UDim.new(0, 8) })
    local iconScale = newInst("UIScale", icon, { Scale = 1 })
    newInst("UIGradient", newInst("TextLabel", card, {
        BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 7),
        Size = UDim2.new(1, -112, 0, 15), Font = Enum.Font.BuilderSansExtraBold,
        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(255, 255, 255), Text = "Oxio Hub", ZIndex = 2,
    }), { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(210, 210, 220)) })
    newInst("TextLabel", card, {
        BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 22),
        Size = UDim2.new(1, -112, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = r1554.Text,
        Text = "Anti Guard", ZIndex = 2,
    })
    local toggle = newInst("TextButton", card, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false, BorderSizePixel = 0, Text = "", ZIndex = 2,
    })
    newInst("UICorner", toggle, { CornerRadius = UDim.new(1, 0) })
    local toggleGrad = newInst("UIGradient", toggle, { Color = ColorSequence.new(r1554.Off, r1554.Off) })
    local knob = newInst("Frame", toggle, {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(245, 245, 250),
        BorderSizePixel = 0, ZIndex = 3,
    })
    newInst("UICorner", knob, { CornerRadius = UDim.new(1, 0) })

    local function baseStroke()
        return r1550.Enabled and r1554.AccentA or r1554.Off
    end
    local function render(instant)
        local dur = instant and 0 or 0.28
        if r1550.Enabled then
            toggleGrad.Color = ColorSequence.new(r1554.AccentA, r1554.AccentB)
            strokeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, r1554.Stroke),
                ColorSequenceKeypoint.new(0.45, r1554.AccentA),
                ColorSequenceKeypoint.new(0.55, r1554.AccentB),
                ColorSequenceKeypoint.new(1, r1554.Stroke),
            })
            r230(knob, dur, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
            r230(icon, dur, { ImageTransparency = 0 })
            r230(cardStroke, 0.3, { Transparency = 0 })
        else
            toggleGrad.Color = ColorSequence.new(r1554.Off, r1554.Off)
            strokeGrad.Color = ColorSequence.new(r1554.Stroke, r1554.Stroke)
            r230(knob, dur, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
            r230(icon, dur, { ImageTransparency = 0.35 })
            r230(cardStroke, 0.3, { Transparency = 0.2 })
        end
        if r1559.FlashUntil <= os.clock() then r230(iconStroke, dur, { Color = baseStroke() }) end
    end
    r11_47 = function(color, hold) r1559.FlashRequest = { Color = color, Hold = hold } end
    local function processFlash()
        local req = r1559.FlashRequest
        if not req then return end
        r1559.FlashRequest = nil
        r1559.FlashUntil = os.clock() + (req.Hold or 0)
        r230(iconStroke, 0.2, { Color = req.Color })
        if req.Hold then
            task.delay(req.Hold, function()
                if r1557 and os.clock() >= r1559.FlashUntil then
                    r230(iconStroke, 0.3, { Color = baseStroke() })
                end
            end)
        end
    end
    local function setHandle(on)
        local h = r1550.Handle
        if type(h) ~= "table" then return end
        for _, m in ipairs({ "Set", "SetValue" }) do
            local ok, fn = pcall(function() return h[m] end)
            if ok and type(fn) == "function" and pcall(fn, h, on) then return end
        end
    end
    r1550.Render = render

    -- drag overlay
    local dragOverlay = newInst("TextButton", card, {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        AutoButtonColor = false, Text = "", ZIndex = 10, Active = false,
    })
    local dragging, dragged, dragStart, startPos, userPos, dragInput = false, false, Vector2.zero, nil, nil, nil
    local function onToggleClick()
        r1550.Enabled = not r1550.Enabled
        render(false)
        setHandle(r1550.Enabled)
        r230(iconScale, 0.12, { Scale = 1.15 })
        task.delay(0.12, function()
            if r1557 then r230(iconScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end
        end)
    end
    r1558[#r1558+1] = dragOverlay.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        dragging = true; dragged = false
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = frame.Position
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState ~= Enum.UserInputState.End then return end
            dragging = false; dragInput = nil
            if not dragged then onToggleClick() end
            dragged = false
        end)
    end)
    r1558[#r1558+1] = r139.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
        local cur = Vector2.new(input.Position.X, input.Position.Y)
        local d = cur - dragStart
        if not dragged and d.Magnitude > 4 then dragged = true end
        if dragged then
            local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            frame.Position = np
            userPos = np
        end
    end)
    local dragOrigSize = toggle.Size
    r1558[#r1558+1] = dragOverlay.MouseEnter:Connect(function()
        r230(toggle, 0.15, { Size = dragOrigSize + UDim2.fromOffset(2, 2) })
    end)
    r1558[#r1558+1] = dragOverlay.MouseLeave:Connect(function()
        r230(toggle, 0.15, { Size = dragOrigSize })
    end)

    -- auto-position
    local RAY_NAME = { Hotbar = true, HotBar = true, Toolbar = true, ToolBar = true, Backpack = true, Inventory = true }
    local monitored = {}
    local lastScan, lastPos = math.huge, math.huge
    local cachedBottom
    local function isVisible(node)
        while node do
            if node:IsA("GuiObject") and not node.Visible then return false end
            if node:IsA("LayerCollector") then return node.Enabled end
            node = node.Parent
        end
        return false
    end
    local function guiInsetY()
        local ok, v = pcall(function() return r164:GetGuiInset().Y end)
        return ok and v or 0
    end
    local function topOfContainer(inst)
        local top = nil
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("GuiButton") and d.Visible and d.AbsoluteSize.Y > 8 and d.AbsoluteSize.X > 8 then
                local y = d.AbsolutePosition.Y
                if not top or y < top then top = y end
            end
        end
        return top or inst.AbsolutePosition.Y
    end
    local function collect()
        table.clear(monitored)
        local pg = r232:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiObject") and RAY_NAME[d.Name] then monitored[#monitored+1] = d end
        end
    end
    local function allBars()
        local out = {}
        pcall(function()
            if not r165:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then return end
            for _, c in ipairs(r138.RobloxGui.Backpack:GetChildren()) do
                if c:IsA("GuiObject") then out[#out+1] = c end
            end
        end)
        for _, m in ipairs(monitored) do if m.Parent then out[#out+1] = m end end
        return out
    end
    local function reposition()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        if vp.X < 10 or vp.Y < 10 then return end
        local touch = r139.TouchEnabled and not r139.KeyboardEnabled
        local s = math.min(vp.X/1280, vp.Y/720)
        local scale = touch and math.clamp(s * 1.05, 0.6, 0.8) * 0.97 or math.clamp(s, 0.8, 1.1)
        frameScale.Scale = scale
        local bgT = touch and 0.3 or 0
        if card.BackgroundTransparency ~= bgT then
            card.BackgroundTransparency = bgT
            iconBg.BackgroundTransparency = bgT
        end
        if userPos then frame.Position = userPos; return end
        local y = vp.Y - 8 * scale
        local found = false
        for _, m in ipairs(allBars()) do
            local ok, vis = pcall(isVisible, m)
            if ok and vis then
                local sz = m.AbsoluteSize
                local mY = m.AbsolutePosition.Y
                if sz.X > 20 and sz.Y > 20 and sz.Y < vp.Y * 0.4 and mY + sz.Y/2 > vp.Y * 0.5 then
                    local ok2, top = pcall(topOfContainer, m)
                    mY = ok2 and top or mY
                    found = true
                    y = math.min(y, mY + guiInsetY())
                end
            end
        end
        if found then cachedBottom = vp.Y - y
        elseif cachedBottom then y = vp.Y - cachedBottom end
        local finalY = math.max(y - (touch and 4 or 6) * scale - r1556 * scale / 2, r1556 * scale / 2 + 8)
        frame.Position = UDim2.new(0.5, 0, 0, finalY)
    end

    -- carry signal
    do
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(info)
                local c = type(info) == "table" and info.IsCarrying == true
                if c and info.GuardDisabled == true then c = false end
                if c and type(info.AreaId) == "string" then r1559.AreaId = info.AreaId end
                if not c then r1559.AreaId = nil end
                r1559.SignalCarrying = c
                updateCarry()
            end)
            if ok and conn then r1558[#r1558+1] = conn end
        end
    end

    local scanT = 0
    r1558[#r1558+1] = r137.Heartbeat:Connect(function(dt)
        local busy = r1550.Busy or r1559.Active
        if busy and os.clock() - r1550.BusySince > 2.5 then
            r1587()
            local c = r232.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.PlatformStand then pcall(function() h.PlatformStand = false end) end
            reset()
        end
        hitArmExpired()
        scanT += dt
        if scanT < 0.03 then return end
        scanT = 0
        local weld = r1584() ~= nil
        if weld ~= r1559.WeldCarrying then
            r1559.WeldCarrying = weld
            updateCarry()
        end
    end)
    r1558[#r1558+1] = r137.RenderStepped:Connect(function(dt)
        processFlash()
        lastScan = lastScan + dt
        lastPos = lastPos + dt
        if lastScan >= 3 then lastScan = 0; pcall(collect) end
        if lastPos >= 0.2 then lastPos = 0; pcall(reposition) end
    end)

    render(true)
    r1550.ShowPanel = function(on) screen.Enabled = on == true end
    screen.Enabled = r1550.PanelShown == true
    screen.Parent = r1561
    r230(cardScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

    r240(function()
        r1557 = false
        for _, c in ipairs(r1558) do pcall(function() c:Disconnect() end) end
        table.clear(r1558)
        r1587(); reset()
        r1550.Render = nil
        r1550.ShowPanel = nil
        pcall(function() screen:Destroy() end)
    end)
end

-- ============= FINALIZE =============
r179:Finalize({ Window = r180, MainTab = r183, ShowMainTab = true })
print("[Oxio] Loaded: Auto Steal + Anti Guard")
