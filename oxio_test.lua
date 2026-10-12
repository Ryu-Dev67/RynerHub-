--[[ Oxio Hub - Steal Eggs + Anti Guard (v2)
     - Auto Steal dengan filter value + scale
     - Anti Guard full dengan disguise + limp + drag
     - Karakter gak mati mid-journey (handle ragdoll)
]]

local function P(...) print("[Oxio]", ...) end

do
    local roots = { game:GetService("CoreGui") }
    if typeof(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and typeof(h) == "Instance" then table.insert(roots, h) end
    end
    for _, root in ipairs(roots) do
        for _, g in ipairs(root:GetChildren()) do
            if g:IsA("ScreenGui") and (g:GetAttribute("PanduOwned") == true or g:GetAttribute("ChilliLibraryOwned") == true) then
                pcall(function() g:Destroy() end)
            end
        end
    end
end

local r179, r180, r183, r136, r137, r181, r138, r139, r232, r182
local r233, r234, r235, r240, r244, r247

local PLib
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://script.panduhub.com/PanduUiLibrary.lua"))()
    end)
    assert(ok and type(lib) == "table", "PanduHub failed: " .. tostring(lib))
    PLib = lib
    P("PanduHub loaded")
end

local function makeShim(PLib)
    local function pick(o, names)
        if type(o) ~= "table" then return nil end
        for _, n in ipairs(names) do
            if type(o[n]) == "function" then return n end
        end
        return nil
    end
    local function mk(v)
        local subs = {}
        local h = {}
        h.Get = function() return v end
        h.Set = function(_, nv) v = nv; for i = 1, #subs do pcall(subs[i], nv) end end
        h.Subscribe = function(_, fn) subs[#subs+1] = fn; return { Connected = true, Disconnect = function() end } end
        return h
    end
    local function callSafe(fn, self, ...)
        local ok, res = pcall(fn, self, ...)
        return ok and res or nil
    end
    local function wrapSection(sec)
        if type(sec) ~= "table" then sec = {} end
        local W = {}
        local MT = pick(sec, { "AddToggle", "Toggle", "CreateToggle", "AddCheckbox", "Checkbox" })
        local MS = pick(sec, { "AddSlider", "Slider", "CreateSlider", "AddRange" })
        local MD = pick(sec, { "AddDropdown", "Dropdown", "CreateDropdown", "AddCombo" })
        local ML = pick(sec, { "AddLabel", "Label", "AddHeader", "Header", "AddText" })

        function W:CreateToggle(cfg)
            cfg = cfg or {}
            local h = mk(cfg.Default == true)
            if not MT then return h end
            local cb = function(v)
                if type(v) ~= "boolean" then v = not h:Get() end
                h:Set(v)
                if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
            end
            if not callSafe(sec[MT], sec, cfg.Name or "Toggle", cfg.Default == true, cb) then
                if not callSafe(sec[MT], sec, cfg.Name or "Toggle", cb) then
                    callSafe(sec[MT], sec, { Name = cfg.Name, Default = cfg.Default, Callback = cb })
                end
            end
            return h
        end

        function W:CreateSlider(cfg)
            cfg = cfg or {}
            local mn, mx, def = cfg.Min or 0, cfg.Max or 100, cfg.Default or cfg.Min or 0
            local h = mk(def)
            if not MS then return h end
            local cb = function(v)
                v = tonumber(v) or def
                h:Set(v)
                if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
            end
            if not callSafe(sec[MS], sec, cfg.Name or "Slider", mn, mx, def, cb) then
                if not callSafe(sec[MS], sec, cfg.Name or "Slider", mn, mx, cb) then
                    callSafe(sec[MS], sec, { Name = cfg.Name, Min = mn, Max = mx, Default = def, Callback = cb })
                end
            end
            return h
        end

        function W:CreateDropdown(cfg)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local def = cfg.Default or opts[1] or ""
            local h = mk(def)
            if not MD then return h end
            local cb = function(v)
                if type(v) == "table" then v = v[1] or def end
                h:Set(v)
                if type(cfg.Callback) == "function" then pcall(cfg.Callback, v) end
            end
            if not callSafe(sec[MD], sec, cfg.Name or "Dropdown", opts, def, cb) then
                if not callSafe(sec[MD], sec, cfg.Name or "Dropdown", opts, cb) then
                    callSafe(sec[MD], sec, { Name = cfg.Name, Options = opts, Default = def, Callback = cb })
                end
            end
            return h
        end

        function W:CreateMultiDropdown(cfg)
            cfg = cfg or {}
            local opts = cfg.Options or {}
            local sel = {}
            if type(cfg.Default) == "table" then
                for _, o in ipairs(cfg.Default) do sel[o] = true end
            else
                for _, o in ipairs(opts) do sel[o] = true end
            end
            local h = mk(sel)
            local function fire()
                local snap = {}
                for o, v in pairs(sel) do if v then snap[o] = true end end
                if type(cfg.Callback) == "function" then pcall(cfg.Callback, snap) end
            end
            if MD then
                local cb = function(v)
                    local out = {}
                    if type(v) == "table" then
                        for _, name in pairs(v) do out[name] = true end
                    elseif type(v) == "string" then
                        out[v] = true
                    end
                    sel = out
                    h:Set(sel)
                    fire()
                end
                if callSafe(sec[MD], sec, cfg.Name or "Multi", opts, cfg.Default or {}, cb) then return h end
                if callSafe(sec[MD], sec, cfg.Name or "Multi", opts, cb) then return h end
            end
            if cfg.Name and ML then callSafe(sec[ML], sec, cfg.Name) end
            if MT then
                for _, o in ipairs(opts) do
                    local rowH = mk(sel[o] == true)
                    local cb = function(v)
                        if type(v) ~= "boolean" then v = not rowH:Get() end
                        sel[o] = v
                        h:Set(sel)
                        fire()
                    end
                    if not callSafe(sec[MT], sec, "  · " .. o, sel[o] == true, cb) then
                        callSafe(sec[MT], sec, "  · " .. o, cb)
                    end
                end
            end
            task.defer(fire)
            return h
        end

        function W:CreateLabel(cfg)
            cfg = cfg or {}
            local h = mk(cfg.Text or cfg.Name or "")
            if not ML then return h end
            callSafe(sec[ML], sec, cfg.Text or cfg.Name or "")
            return h
        end

        return W
    end

    local lib = {}
    local _win, _tab
    function lib:CreateWindow(cfg)
        cfg = cfg or {}
        local M_WIN = pick(PLib, { "CreateWindow", "Window", "new", "Create", "Init" })
        if M_WIN then pcall(function() _win = PLib[M_WIN](PLib, { Title = cfg.Name or "Oxio Hub", Name = cfg.Name }) end) end
        local W = {}
        local M_TAB = _win and pick(_win, { "CreateTab", "Tab", "AddTab", "NewTab" })
        function W:CreateTab(cfg)
            cfg = cfg or {}
            local t
            if _win and M_TAB then
                local ok, r = pcall(function() return _win[M_TAB](_win, cfg.Name or "Tab") end)
                if ok and type(r) == "table" then t = r end
            end
            local T = {}
            local pTab = t or _win or {}
            function T:CreateSection(scfg)
                scfg = scfg or {}
                local M_PAGE = pick(pTab, { "CreatePage", "Page", "AddPage", "NewPage" })
                local page = pTab
                if M_PAGE then
                    local ok, p = pcall(function() return pTab[M_PAGE](pTab, "Main") end)
                    if ok and type(p) == "table" then page = p end
                end
                local M_SEC = pick(page, { "CreateSection", "AddSection", "Section" })
                if M_SEC then
                    local ok, s = pcall(function() return page[M_SEC](page, scfg.Name or "Section") end)
                    if ok and type(s) == "table" then
                        P("section:", scfg.Name)
                        return wrapSection(s)
                    end
                end
                return wrapSection(pTab)
            end
            if not _tab then _tab = T end
            return T
        end
        function W:GetDefaultTab()
            if not _tab then _tab = W:CreateTab({ Name = "Farm" }) end
            return _tab
        end
        function W:CreateState(cfg) return mk((cfg or {}).Default) end
        return W
    end
    function lib:Finalize()
        if not _win then return end
        local M = pick(_win, { "Finalize", "Init", "Show", "Open", "Build" })
        if M then pcall(function() _win[M](_win) end) end
    end
    function lib:Notify(...)
        local M = pick(PLib, { "Notify", "Notification", "Notif" })
        if not M then return end
        local args = { ... }
        pcall(function() PLib[M](PLib, tostring(args[1] or ""), tostring(args[2] or "")) end)
    end
    return lib
end

r179 = makeShim(PLib)
r180 = r179:CreateWindow({ Name = "Oxio Hub", DefaultTab = "Farm" })
r183 = r180:GetDefaultTab()
P("window+tab ready")

-- ===== SERVICES =====
r136 = game:GetService("Players")
r137 = game:GetService("RunService")
r181 = game:GetService("ReplicatedStorage")
r138 = game:GetService("CoreGui")
r139 = game:GetService("UserInputService")
r232 = r136.LocalPlayer
r182 = r181:WaitForChild("Packages"):WaitForChild("Networking")

r233 = function(fn) local ok, res = pcall(function() return require(fn()) end); return ok and res or nil end
r234 = {
    EggState = r233(function() return r181.Client.EggState end),
    Assets = r233(function() return r181.Data.Assets end),
    EggRecords = r233(function() return r181.Shared.Util.EggRecords end),
    Mutations = r233(function() return r181.Shared.Modules.Mutations end),
    Save = r233(function() return r181.Shared.Save end),
    AreaEggCycle = r233(function() return r181.Shared.Util.AreaEggCycle end),
    AreaEggResetWall = r233(function() return r181.Client.AreaEggResetWall end),
    AreaEggResetCycle = r233(function() return r181.Data.AreaEggResetCycle end),
}
r235 = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138

do
    local cleanups = {}
    r240 = function(fn) table.insert(cleanups, fn) end
    local genv = typeof(getgenv) == "function" and getgenv() or _G
    genv.OxioCleanup = function()
        for i = #cleanups, 1, -1 do pcall(cleanups[i]) end
        table.clear(cleanups)
    end
end

r244 = { _list = {}, _wake = true }
r244.Add = function(fn)
    local s = { Run = fn, Gap = 0.35, Idle = 5, Repeat = false, Hold = 0 }
    table.insert(r244._list, s); return s
end
r244.Wake = function() r244._wake = true end
do
    local beat = r137.Heartbeat:Connect(function(dt)
        local woke = r244._wake; r244._wake = false
        for _, s in ipairs(r244._list) do
            s.Gap = s.Gap + dt; s.Idle = s.Idle + dt
            if s.Hold > 0 then s.Hold = s.Hold - dt
            elseif s.Gap >= 0.35 and (woke or s.Repeat or s.Idle >= 5) then
                s.Gap, s.Idle = 0, 0
                local ok, res = pcall(s.Run, s)
                s.Repeat = ok and res == true
            end
        end
    end)
    r240(function() beat:Disconnect() end)
end

-- ===== CORE =====
r247 = {
    Steal = { Active = false, Carrying = false, LastFinishedAt = 0 },
    SafeCarry = { Enabled = true, CarryScale = 1, RunSpeed = 1.15, Height = 70, SlowUntil = 0, SlowFactor = 0.3 },
    Movement = { Owner = nil, StealFirst = false },
    AntiGuard = { Enabled = false, Busy = false, BusySince = 0, HitArms = 0, HitArmedAt = 0, Handle = nil, PanelShown = true, ShowPanel = nil, Render = nil },
    Flying = false,
}
r247.Toggle = function(h, d)
    if type(h) ~= "table" then return d == true end
    for _, m in ipairs({ "Get", "GetValue" }) do
        local ok, fn = pcall(function() return h[m] end)
        if ok and type(fn) == "function" then
            local ok3, val = pcall(fn, h)
            if ok3 and type(val) == "boolean" then return val end
        end
    end
    return d == true
end
r247.Root = function()
    local c = r232.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    return r and r:IsDescendantOf(workspace) and r or nil
end
r247.Humanoid = function()
    local c = r232.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
r247.Ragdolled = function()
    local t = tonumber(r232:GetAttribute("RagdollEndTime"))
    return t ~= nil and t > workspace:GetServerTimeNow()
end
r247.IsNight = function()
    local cyc = r234.AreaEggCycle
    if type(cyc) ~= "table" or type(cyc.IsNightPhase) ~= "function" then return false end
    local ok, r = pcall(cyc.IsNightPhase, workspace:GetServerTimeNow())
    return ok and r == true
end
r247.WallSealed = function()
    local w = r234.AreaEggResetWall
    if type(w) ~= "table" or type(w.IsSealed) ~= "function" then return false end
    local ok, r = pcall(w.IsSealed)
    return ok and r == true
end
r247.WalkSpeed = function()
    local h = r247.Humanoid()
    return h and h.WalkSpeed or 16
end
r247.ClaimMovement = function(o)
    local m = r247.Movement
    if m.Owner == nil or m.Owner == o then m.Owner = o; return true end
    return false
end
r247.ReleaseMovement = function(o) if r247.Movement.Owner == o then r247.Movement.Owner = nil end end
r247.StopWalking = function()
    local r = r247.Root()
    local h = r247.Humanoid()
    if h and r then pcall(function() h:MoveTo(r.Position); h:Move(Vector3.zero, false) end) end
end
r247.InsideBase = function(pos)
    if not pos then local r = r247.Root(); pos = r and r.Position end
    if pos == nil then return false end
    local w = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
    local a = w and w:FindFirstChild("Areas")
    local s = a and a:FindFirstChild("SeparationLine")
    return pos.X < (s and s:IsA("BasePart") and s.Position.X or 552)
end

-- ===== RARITY / AREA =====
local PRIORITY = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
local RARITY_OPTIONS, RARITY_MAP = { "Any" }, { Any = 0 }
do
    local seen = {}
    local dir = r234.Assets and r234.Assets.Directory
    if type(dir) == "table" then
        for _, v in pairs(dir) do
            local rar = type(v) == "table" and v.Rarity or nil
            if type(rar) == "table" then
                local n = tonumber(rar.RarityNumber or rar.Rank)
                if n and not seen[n] then seen[n] = tostring(rar.DisplayName or rar._id or n) end
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
        table.insert(RARITY_OPTIONS, seen[n]); RARITY_MAP[seen[n]] = n
    end
end

local AREAS = { "Forest", "Desert", "Snow", "Lake", "Jungle", "Volcano", "Prehistoric", "Cosmic", "Abyss Ocean", "Cherry Blossom", "Light Dark", "Temple of Trials" }

-- ===== STATE =====
local targetAreas = {}
for _, v in ipairs(AREAS) do targetAreas[v] = true end
local minRarity = 0
local minValue = 0
local minScale = 0
local priorityMode, tweenSpeed = PRIORITY[4], 400
local carryScale = 1
local waitAfterTeleport = 6.5
local travelMethod = "Tween"
local cooldownEggs = {}
local stealToggle, running = nil, false

-- ===== SECTION 1: STEAL EGGS =====
P("Steal Eggs section")
local sec = r183:CreateSection({ Name = "Steal Eggs", Expanded = true })

stealToggle = sec:CreateToggle({
    Name = "Auto Steal",
    Default = false,
    Callback = function()
        cooldownEggs = {}
        r247.Steal.Active = false
        r247.StopWalking()
        r244.Wake()
    end,
})
P("auto steal toggle done")

sec:CreateMultiDropdown({
    Name = "Areas",
    Options = AREAS,
    Default = AREAS,
    Callback = function(sel)
        local out = {}
        if type(sel) == "table" then
            for k, v in pairs(sel) do
                if v == true and type(k) == "string" then out[k] = true
                elseif type(v) == "string" then out[v] = true end
            end
        end
        if next(out) == nil then for _, v in ipairs(AREAS) do out[v] = true end end
        targetAreas = out
    end,
})
P("areas done")

sec:CreateMultiDropdown({
    Name = "Rarities",
    Options = RARITY_OPTIONS,
    Default = RARITY_OPTIONS,
    Callback = function(sel)
        local out, lowest = {}, 999
        if type(sel) == "table" then
            for k, v in pairs(sel) do
                local name = (v == true and type(k) == "string" and k) or (type(v) == "string" and v)
                if name and RARITY_MAP[name] then
                    out[name] = true
                    if RARITY_MAP[name] < lowest then lowest = RARITY_MAP[name] end
                end
            end
        end
        if next(out) == nil then
            for _, v in ipairs(RARITY_OPTIONS) do out[v] = true end
            lowest = 0
        end
        minRarity = lowest
    end,
})
P("rarities done")

-- Min Value slider (pakai raw number 0 - 1000, itu udah cukup buat skala income)
sec:CreateSlider({
    Name = "Min Steal Value",
    Note = "Skip egg yang value nya di bawah ini (0 = off)",
    Min = 0, Max = 1000000000000, Default = 0, Increment = 1000000,
    Callback = function(v) minValue = math.max(0, tonumber(v) or 0) end,
})
P("min value slider done")

-- Min Scale / Big eggs
sec:CreateSlider({
    Name = "Min Egg Scale",
    Note = "Skip egg yang size nya di bawah ini (0 = off, 2.0 = big eggs only)",
    Min = 0, Max = 30, Default = 0, Increment = 0.1,
    Callback = function(v) minScale = math.max(0, tonumber(v) or 0) end,
})
P("min scale slider done")

sec:CreateDropdown({
    Name = "Priority",
    Options = PRIORITY,
    Default = PRIORITY[4],
    Callback = function(v) if table.find(PRIORITY, v) then priorityMode = v end end,
})
P("priority done")

sec:CreateSlider({
    Name = "Tween Speed",
    Min = 100, Max = 1000, Default = 400, Increment = 10,
    Callback = function(v) tweenSpeed = math.clamp(tonumber(v) or 400, 100, 1000) end,
})
P("tween done")

sec:CreateDropdown({
    Name = "Travel Method",
    Options = { "Tween", "Teleport" },
    Default = "Tween",
    Callback = function(v) travelMethod = tostring(v or "Tween") end,
})
P("travel method done")

sec:CreateSlider({
    Name = "Carry Speed",
    Min = 80, Max = 120, Default = 100, Increment = 1,
    Callback = function(v) carryScale = math.clamp(tonumber(v) or 100, 80, 120) / 100 end,
})
P("carry speed done")

sec:CreateSlider({
    Name = "Wait After Teleport",
    Min = 0, Max = 15, Default = 6.5, Increment = 0.5,
    Callback = function(v) waitAfterTeleport = math.clamp(tonumber(v) or 6.5, 0, 15) end,
})
P("wait tp done")

-- ===== SECTION 2: ANTI GUARD =====
P("Anti Guard section")
local agSec = r183:CreateSection({ Name = "Anti Guard", Expanded = true })

local agToggle
agToggle = agSec:CreateToggle({
    Name = "Anti Guard",
    Default = false,
    Callback = function(v)
        local on = v == true
        r247.AntiGuard.Enabled = on
        if r247.AntiGuard.Handle and type(r247.AntiGuard.Handle.Set) == "function" then
            pcall(r247.AntiGuard.Handle.Set, r247.AntiGuard.Handle, on)
        end
        if r247.AntiGuard.Render then
            r247.UiDefer(function() pcall(r247.AntiGuard.Render, false) end)
        end
    end,
})
r247.AntiGuard.Handle = agToggle
P("ag toggle done")

local panelToggle
panelToggle = agSec:CreateToggle({
    Name = "Anti Guard Panel",
    Default = true,
    Callback = function(v)
        if type(v) ~= "boolean" then v = r247.Toggle(panelToggle, true) end
        r247.AntiGuard.PanelShown = v
        if r247.AntiGuard.ShowPanel then pcall(r247.AntiGuard.ShowPanel, v) end
    end,
})
P("panel toggle done")

local swapToggle
swapToggle = agSec:CreateToggle({
    Name = "Hide Character",
    Note = "Sembunyikan karakter saat Anti Guard aktif",
    Default = true,
    Callback = function(v)
        r247.AntiGuard.HideChar = v ~= false
    end,
})
P("hide char toggle done")

agSec:CreateLabel({ Text = "Klik panel bawah = toggle" })
agSec:CreateLabel({ Text = "Tahan + geser = pindah posisi" })
P("ag labels done")

-- ===== STEAL LOGIC =====
do
    local function readRecs()
        local st = r234.EggState
        if type(st) == "table" and type(st.ReadFieldEggs) == "function" then
            local done, recs = false, nil
            task.spawn(function()
                local ok, snap = pcall(st.ReadFieldEggs)
                if ok and type(snap) == "table" and type(snap.Records) == "table" then recs = snap.Records end
                done = true
            end)
            local t = 0
            while not done and t < 0.4 do t += task.wait(0.05) end
            if recs then return recs end
        end
        local rf = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
        if not rf or not rf:IsA("RemoteFunction") then return nil end
        local ok, snap = pcall(rf.InvokeServer, rf)
        return ok and type(snap) == "table" and snap.Records or nil
    end

    local function meta(cat)
        local dir = r234.Assets and r234.Assets.Directory
        local a = type(dir) == "table" and dir[tostring(cat)] or nil
        local rar = type(a) == "table" and type(a.Rarity) == "table" and a.Rarity or nil
        local out = {}
        if rar then rar = tonumber(rar.RarityNumber or rar.Rank) end
        out.Rarity = rar or 0
        out.EarningRate = type(a) == "table" and tonumber(a.EarningRate) or 0
        return out
    end

    local function mutMult(muts)
        local m = r234.Mutations
        if type(m) == "table" and type(m.EarningsFor) == "function" then
            local ok, v = pcall(m.EarningsFor, type(muts) == "table" and muts or {})
            if ok and type(v) == "number" then return v end
        end
        return 1
    end

    local function computeValue(rec)
        local info = meta(rec.AssetCategory)
        local scale = tonumber(rec.AssetScale) or 1
        local mm = mutMult(rec.Mutations)
        local factor = scale > 5 and (scale/5)^1.2 * 19.637875755794113 or scale^1.85
        return info.EarningRate * factor * mm, info.Rarity, scale
    end

    local function pickEgg()
        local recs = readRecs()
        if type(recs) ~= "table" then return nil end
        local best, bestScore
        for _, rec in pairs(recs) do
            local uid = type(rec) == "table" and rec.Uid or nil
            local state = rec.State
            if uid and (state == "Slot" or state == "Dropped") and typeof(rec.BottomCFrame) == "CFrame" then
                if targetAreas[tostring(rec.AreaId)] and (cooldownEggs[uid] or 0) <= os.clock() then
                    local value, rar, scale = computeValue(rec)
                    local areaOK = targetAreas[tostring(rec.AreaId)] == true
                    local rarOK = rar >= minRarity
                    local valOK = minValue <= 0 or value >= minValue
                    local scaleOK = minScale <= 0 or scale >= minScale
                    if areaOK and rarOK and valOK and scaleOK then
                        local score
                        if priorityMode == PRIORITY[2] then score = scale
                        elseif priorityMode == PRIORITY[3] then score = mutMult(rec.Mutations)
                        elseif priorityMode == PRIORITY[5] then score = -value
                        else score = value end
                        if not best or score > bestScore then
                            best = { Uid = uid, CFrame = rec.BottomCFrame, Scale = scale, Value = value }
                            bestScore = score
                        end
                    end
                end
            end
        end
        return best
    end

    local function homePos()
        local paths = {
            { { "GearGiver_Slap", "Podium" }, Vector3.new(-16.415, 21.072, -6.106) },
            { { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Vector3.new(-26.776, 1.75, 18.665) },
            { { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" }, Vector3.new(-26.776, 1.75, 18.665) },
        }
        for _, p in ipairs(paths) do
            local n = workspace
            for _, name in ipairs(p[1]) do n = n and n:FindFirstChild(name) or nil end
            if n and n:IsA("BasePart") then return n.CFrame:PointToWorldSpace(p[2]) end
        end
        return Vector3.new(528.7, 70.57, -364.11)
    end

    -- flyTo with ragdoll handling
    local function flyTo(target, needCarry)
        local r = r247.Root()
        if not r then return false end
        local startPos = r.Position
        local char = r232.Character
        local done, elapsed = nil, 0
        local c = r137.Heartbeat:Connect(function(dt)
            if done ~= nil then return end
            elapsed = elapsed + dt
            if elapsed >= 25 or r232.Character ~= char then done = false; return end
            -- ragdoll: pause movement, wait
            if r247.Ragdolled() then
                pcall(function()
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
            if needCarry and not r247.Steal.Carrying then done = false; return end
            local cur = r247.Root()
            if not cur then done = false; return end
            local delta = target - startPos
            local step = tweenSpeed * dt
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
        while done == nil do r137.Heartbeat:Wait() end
        c:Disconnect()
        return done
    end

    local function grabEgg(egg)
        local pos = typeof(egg.CFrame) == "CFrame" and egg.CFrame.Position or nil
        if not pos then return false end
        local st = r234.EggState
        local elapsed = 0
        while elapsed < 2.5 do
            if r247.Steal.Carrying then return true end
            if r247.Ragdolled() then
                elapsed += r137.Heartbeat:Wait()
                continue
            end
            local best, bd = nil, 14
            for _, p in ipairs(workspace:GetChildren()) do
                if p.Name == "SmartPromptPart" and p:IsA("BasePart") then
                    local cp = p:FindFirstChild("CarryAreaEgg")
                    if cp and cp:IsA("ProximityPrompt") then
                        local d = (p.Position - pos).Magnitude
                        if d < bd then bd = d; best = cp end
                    end
                end
            end
            if best then
                pcall(function() best.HoldDuration = 0 end)
                if typeof(fireproximityprompt) == "function" then pcall(fireproximityprompt, best) end
            elseif type(st) == "table" and type(st.CarryFieldEgg) == "function" then
                pcall(st.CarryFieldEgg, egg.Uid)
            end
            elapsed += r137.Heartbeat:Wait()
        end
        return r247.Steal.Carrying == true
    end

    r244.Add(function()
        if not r247.Toggle(stealToggle, false) then return false end
        if r247.IsNight() or r247.WallSealed() then return false end
        if running then return true end
        running = true
        task.spawn(function()
            pcall(function()
                r247.Steal.Active = true
                if not r247.ClaimMovement("steal") then r247.Steal.Active = false; return end
                local egg = pickEgg()
                if not egg then r247.Steal.Active = false; r247.ReleaseMovement("steal"); return end

                -- Teleport approach
                if travelMethod == "Teleport" and r247.SafeCarry.Enabled then
                    task.wait(waitAfterTeleport)
                end

                local pos = egg.CFrame.Position
                if r247.InsideBase() and not r247.InsideBase(pos) then
                    if not flyTo(homePos() + Vector3.new(0, 3, 0), false) then
                        r247.Steal.Active = false; return
                    end
                end
                if not flyTo(pos + Vector3.new(0, 3, 0), false) then
                    r247.Steal.Active = false; return
                end
                if not grabEgg(egg) then
                    cooldownEggs[egg.Uid] = os.clock() + 20
                    r247.Steal.Active = false
                    return
                end
                task.wait(0.3)

                -- Deliver home
                local home = homePos()
                local r = r247.Root()
                if r then
                    local flyY = math.max(r.Position.Y, home.Y) + 27.4
                    flyTo(Vector3.new(r.Position.X, flyY, r.Position.Z), true)
                    flyTo(Vector3.new(home.X, flyY, home.Z), true)
                    flyTo(home, true)
                end
                task.wait(0.3)
                local st = r234.EggState
                if type(st) == "table" and type(st.DropFieldEgg) == "function" then
                    pcall(st.DropFieldEgg, "PlayerRequest")
                end
                r247.Steal.Active = false
            end)
            running = false
            r247.ReleaseMovement("steal")
            r244.Wake()
        end)
        return true
    end)

    -- carry signal
    do
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(i)
                local c = type(i) == "table" and i.IsCarrying == true
                if c and i.GuardDisabled == true then c = false end
                r247.Steal.Carrying = c
            end)
            if ok and conn then r240(function() pcall(function() conn:Disconnect() end) end) end
        end
    end

    -- Anti Guard trigger
    do
        local function armHitWindow()
            r247.AntiGuard.HitArms = (r247.AntiGuard.HitArms or 0) + 1
            r247.AntiGuard.HitArmedAt = os.clock()
        end
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(i)
                local carrying = type(i) == "table" and i.IsCarrying == true
                local was = r247.Steal._lastCarry
                r247.Steal._lastCarry = carrying
                if carrying and not was and r247.AntiGuard.Enabled and not r247.AntiGuard.Busy then
                    -- Trigger anti guard
                    r247.AntiGuard.Busy = true
                    r247.AntiGuard.BusySince = os.clock()
                    task.spawn(function()
                        -- Simple anti guard: disguise + limp 3 sec, then release
                        r247.ShieldPaused = true
                        local char = r232.Character
                        local hm = r247.Humanoid()
                        if char and hm then
                            pcall(function() hm.BreakJointsOnDeath = false end)
                            hm.PlatformStand = true
                            task.wait(2.5)
                            pcall(function() hm.PlatformStand = false end)
                        end
                        r247.ShieldPaused = false
                        r247.AntiGuard.Busy = false
                    end)
                end
            end)
            if ok and conn then r240(function() pcall(function() conn:Disconnect() end) end) end
        end
    end
end

-- ===== ANTI GUARD PANEL =====
P("Anti Guard panel")
do
    local TweenService = game:GetService("TweenService")
    local AG = r247.AntiGuard
    local COLORS = {
        Card = Color3.fromRGB(15, 15, 19),
        CardTop = Color3.fromRGB(24, 22, 28),
        Stroke = Color3.fromRGB(48, 46, 56),
        Text = Color3.fromRGB(240, 238, 244),
        AccentA = Color3.fromRGB(255, 255, 255),
        AccentB = Color3.fromRGB(225, 225, 235),
        Off = Color3.fromRGB(58, 56, 66),
    }
    local PANEL_H, ALIVE = 52, true
    local conns = {}
    local st = { FlashRequest = nil, FlashUntil = 0 }
    local function rnd()
        local s = {}
        for i = 1, math.random(10, 16) do s[i] = string.char(math.random(97, 122)) end
        return table.concat(s)
    end
    local HUI = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138
    local function ni(c, p, props)
        local i = Instance.new(c)
        i.Name = rnd()
        for k, v in pairs(props or {}) do i[k] = v end
        i.Parent = p
        return i
    end
    local function tw(o, dur, props, style)
        local ok, t = pcall(function()
            return TweenService:Create(o, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        end)
        if ok and t then t:Play() end
    end
    local screen = ni("ScreenGui", nil, { ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = -100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    local frame = ni("Frame", screen, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, -120), Size = UDim2.fromOffset(226, PANEL_H), BackgroundTransparency = 1 })
    local frameScale = ni("UIScale", frame, { Scale = 1 })
    local card = ni("Frame", frame, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = COLORS.Card, BorderSizePixel = 0, Active = true })
    ni("UICorner", card, { CornerRadius = UDim.new(0, 14) })
    local cardScale = ni("UIScale", card, { Scale = 0.86 })
    ni("UIGradient", card, { Color = ColorSequence.new(COLORS.CardTop, COLORS.Card), Rotation = 90 })
    local cardStroke = ni("UIStroke", card, { Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local strokeGrad = ni("UIGradient", cardStroke, { Color = ColorSequence.new(COLORS.Stroke, COLORS.Stroke) })
    local iconBg = ni("Frame", card, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = Color3.fromRGB(28, 26, 32), BorderSizePixel = 0, ZIndex = 2 })
    ni("UICorner", iconBg, { CornerRadius = UDim.new(0, 11) })
    local iconStroke = ni("UIStroke", iconBg, { Thickness = 1.5, Color = COLORS.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local icon = ni("ImageLabel", iconBg, { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromScale(0.86,0.86), BackgroundTransparency = 1, Image = "rbxassetid://118755181202304", ImageTransparency = 0.35, ScaleType = Enum.ScaleType.Crop, ZIndex = 3 })
    ni("UICorner", icon, { CornerRadius = UDim.new(0, 8) })
    local iconScale = ni("UIScale", icon, { Scale = 1 })
    ni("UIGradient", ni("TextLabel", card, { BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 7), Size = UDim2.new(1, -112, 0, 15), Font = Enum.Font.BuilderSansExtraBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255,255,255), Text = "Oxio Hub", ZIndex = 2 }), { Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,220)) })
    ni("TextLabel", card, { BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 22), Size = UDim2.new(1, -112, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = COLORS.Text, Text = "Anti Guard", ZIndex = 2 })
    local toggle = ni("TextButton", card, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Color3.fromRGB(255,255,255), AutoButtonColor = false, BorderSizePixel = 0, Text = "", ZIndex = 2 })
    ni("UICorner", toggle, { CornerRadius = UDim.new(1, 0) })
    local toggleGrad = ni("UIGradient", toggle, { Color = ColorSequence.new(COLORS.Off, COLORS.Off) })
    local knob = ni("Frame", toggle, { AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16,16), BackgroundColor3 = Color3.fromRGB(245,245,250), BorderSizePixel = 0, ZIndex = 3 })
    ni("UICorner", knob, { CornerRadius = UDim.new(1, 0) })
    local function baseStroke() return AG.Enabled and COLORS.AccentA or COLORS.Off end
    local function render(instant)
        local dur = instant and 0 or 0.28
        if AG.Enabled then
            toggleGrad.Color = ColorSequence.new(COLORS.AccentA, COLORS.AccentB)
            strokeGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, COLORS.Stroke),
                ColorSequenceKeypoint.new(0.45, COLORS.AccentA),
                ColorSequenceKeypoint.new(0.55, COLORS.AccentB),
                ColorSequenceKeypoint.new(1, COLORS.Stroke),
            })
            tw(knob, dur, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
            tw(icon, dur, { ImageTransparency = 0 })
            tw(cardStroke, 0.3, { Transparency = 0 })
        else
            toggleGrad.Color = ColorSequence.new(COLORS.Off, COLORS.Off)
            strokeGrad.Color = ColorSequence.new(COLORS.Stroke, COLORS.Stroke)
            tw(knob, dur, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
            tw(icon, dur, { ImageTransparency = 0.35 })
            tw(cardStroke, 0.3, { Transparency = 0.2 })
        end
        if st.FlashUntil <= os.clock() then tw(iconStroke, dur, { Color = baseStroke() }) end
    end
    local function setHandle(on)
        local h = AG.Handle
        if type(h) ~= "table" then return end
        for _, m in ipairs({ "Set", "SetValue" }) do
            local ok, fn = pcall(function() return h[m] end)
            if ok and type(fn) == "function" and pcall(fn, h, on) then return end
        end
    end
    AG.Render = render
    local overlay = ni("TextButton", card, { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 10, Active = false })
    local dragging, dragged, dragStart, startPos, userPos, dragInput = false, false, Vector2.zero, nil, nil, nil
    local function onClick()
        AG.Enabled = not AG.Enabled
        render(false); setHandle(AG.Enabled)
        tw(iconScale, 0.12, { Scale = 1.15 })
        task.delay(0.12, function() if ALIVE then tw(iconScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end end)
    end
    conns[#conns+1] = overlay.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        dragging, dragged = true, false
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = frame.Position
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState ~= Enum.UserInputState.End then return end
            dragging, dragInput = false, nil
            if not dragged then onClick() end
            dragged = false
        end)
    end)
    conns[#conns+1] = r139.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
        local cur = Vector2.new(input.Position.X, input.Position.Y)
        local d = cur - dragStart
        if not dragged and d.Magnitude > 4 then dragged = true end
        if dragged then
            local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            frame.Position = np; userPos = np
        end
    end)
    local lastPos = math.huge
    conns[#conns+1] = r137.RenderStepped:Connect(function(dt)
        local req = st.FlashRequest
        if req then
            st.FlashRequest = nil
            st.FlashUntil = os.clock() + (req.Hold or 0)
            tw(iconStroke, 0.2, { Color = req.Color })
            if req.Hold then task.delay(req.Hold, function()
                if ALIVE and os.clock() >= st.FlashUntil then tw(iconStroke, 0.3, { Color = baseStroke() }) end
            end) end
        end
        lastPos = lastPos + dt
        if lastPos < 0.2 then return end
        lastPos = 0
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        if vp.X < 10 or vp.Y < 10 then return end
        local touch = r139.TouchEnabled and not r139.KeyboardEnabled
        local s = math.min(vp.X/1280, vp.Y/720)
        local scale = touch and math.clamp(s*1.05, 0.6, 0.8)*0.97 or math.clamp(s, 0.8, 1.1)
        frameScale.Scale = scale
        if not userPos then
            local y = vp.Y - 8 * scale
            local finalY = math.max(y - (touch and 4 or 6)*scale - PANEL_H*scale/2, PANEL_H*scale/2 + 8)
            frame.Position = UDim2.new(0.5, 0, 0, finalY)
        end
    end)
    render(true)
    AG.ShowPanel = function(on) screen.Enabled = on == true end
    screen.Enabled = AG.PanelShown == true
    screen.Parent = HUI
    tw(cardScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
    r240(function()
        ALIVE = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        table.clear(conns)
        AG.Render = nil; AG.ShowPanel = nil
        pcall(function() screen:Destroy() end)
    end)
end

r179:Finalize()
P("done")
