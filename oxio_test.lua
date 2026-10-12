--[[ Oxio Hub - Steal Eggs + Anti Guard
     Layout mirip screenshot
     Panel draggable, outline putih
     Logo: rbxassetid://118755181202304
]]

local r179, r180, r183, r136, r137, r181, r138, r139, r232, r182
local r233, r234, r235, r238, r240, r243, r244, r247

-- ===== BOOTSTRAP =====
do
    local function loadLib()
        local cached
        local function fetch()
            if type(cached) == "string" and #cached > 0 then return cached end
            cached = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli%20Library")
            return cached
        end
        local function cleanup()
            local genv = typeof(getgenv) == "function" and getgenv() or _G
            if type(genv.ChilliHubSaeCleanup) == "function" then pcall(genv.ChilliHubSaeCleanup) end
            local roots = { game:GetService("CoreGui") }
            if typeof(gethui) == "function" then
                local ok, h = pcall(gethui)
                if ok and typeof(h) == "Instance" then table.insert(roots, h) end
            end
            local names = { Settings = true, ChilliLeftCenter = true, ChilliLibrarySettings = true, ChilliLibraryLauncher = true }
            for _, r in ipairs(roots) do
                for _, g in ipairs(r:GetChildren()) do
                    if g:IsA("ScreenGui") and (g:GetAttribute("ChilliLibraryOwned") == true or names[g.Name]) then
                        pcall(function() g:Destroy() end)
                    end
                end
            end
        end
        local function boot()
            local src = fetch()
            local fn, err = loadstring(src)
            assert(fn, err)
            local bootFn = fn()
            assert(type(bootFn) == "function", "Chilli bootstrap invalid")
            local key = table.create(45)
            local idx = 1
            for i = 1, 90, 2 do
                key[idx] = string.char(bit32.bxor(tonumber(string.sub("306908100841206d474f00185f26635b2101387507010810127d7d477a473b6f435a0916573165562900226c00", i, i+1), 16), string.byte("s9K!2vQ#", (idx-1)%8+1)))
                idx += 1
            end
            return bootFn(table.concat(key))
        end
        local lastErr = "unknown"
        for attempt = 1, 6 do
            task.wait(); pcall(cleanup)
            local ok, lib = pcall(boot)
            if ok and type(lib) == "table" then return lib end
            lastErr = tostring(lib)
            if type(lastErr) == "string" and string.find(lastErr, "HttpGet", 1, true) then cached = nil end
            task.wait(1 + attempt * 0.5)
        end
        error("Chilli Library failed: " .. lastErr, 0)
    end

    r179 = loadLib()
    assert(type(r179) == "table" and type(r179.CreateWindow) == "function" and type(r179.Finalize) == "function", "Invalid Chilli API")

    r180 = r179:CreateWindow({ Name = "Oxio Hub", DefaultTab = "Farm" })
    r183 = r180:GetDefaultTab()

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
    local sv = r234.Save
    if type(sv) == "table" and (type(sv.Get) ~= "function" or type(sv.FieldSignal) ~= "function") then
        r234.Save = setmetatable({
            Get = type(sv.Get) == "function" and sv.Get or sv.Peek,
            FieldSignal = type(sv.FieldSignal) == "function" and sv.FieldSignal or sv.Watch,
        }, { __index = sv })
    end
    r235 = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138

    do
        local rng = Random.new()
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        r238 = function()
            local n = rng:NextInteger(12, 20)
            local out = table.create(n)
            for i = 1, n do out[i] = string.sub(chars, rng:NextInteger(1,#chars), rng:NextInteger(1,#chars)) end
            return table.concat(out)
        end
    end
    do
        local cleanups = {}
        r240 = function(fn) table.insert(cleanups, fn) end
        local genv = typeof(getgenv) == "function" and getgenv() or _G
        if type(genv.ChilliHubSaeCleanup) == "function" then pcall(genv.ChilliHubSaeCleanup) end
        genv.ChilliHubSaeCleanup = function()
            for i = #cleanups, 1, -1 do pcall(cleanups[i]) end
            table.clear(cleanups)
        end
    end
    do
        local busy = false
        r243 = function(handle)
            if type(handle) ~= "table" then return handle end
            local inst = rawget(handle, "Instance")
            if typeof(inst) ~= "Instance" then return handle end
            local function fix(node)
                if busy then return end
                if node:IsA("TextLabel") and node.Name == "Value" and node.Text == "None" then
                    busy = true; node.Text = "All"; busy = false
                end
            end
            for _, d in ipairs(inst:GetDescendants()) do fix(d) end
            local conn = inst.DescendantAdded:Connect(fix)
            r240(function() pcall(function() conn:Disconnect() end) end)
            return handle
        end
    end
    r244 = { _list = {}, _wake = true }
    r244.Add = function(fn)
        local s = { Run = fn, Gap = 0.35, Idle = 5, Repeat = false, Hold = 0 }
        table.insert(r244._list, s); return s
    end
    r244.Wake = function() r244._wake = true end
    r244.Backoff = function(s, sec) if s then s.Hold = tonumber(sec) or 6 end end
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
end

-- ===== CORE =====
do
    r247 = {
        Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
        SafeCarry = {
            Enabled = true, Blocked = {}, CarryScale = 1, Approach = "Run", RunSpeed = 1.15,
            Height = 70, Mult = 1, Seen = {}, LastDelivered = 0, LastFailed = 0,
            SlowUntil = 0, SlowFactor = 0.3, LastSkip = nil, Category = nil, PlanOk = true,
            StretchSeconds = 6, BeatGuard = false, EasyRatio = 1.3, LightMult = 0.96,
            ClimbShare = 0.5, RunWait = 0, RunAnimate = true, RunHeight = 50, StraightRun = true,
            RunStyle = "Velocity", CarryStyle = "Velocity", SpeedJitter = 0.08, Wobble = 0,
            LaneOffset = 0, JumpsPerMinute = 0, PausesPerMinute = 0, ReactMin = 0.2, ReactMax = 0.6,
            CarryReact = 0, SpeedRatio = 1.5, ExcessSeconds = 5.5, GuardMargin = 4, GuardRatio = 1.06,
            MinRatio = 1.1, BaseWait = 6.5, FreeJump = 1500, WaitRate = 0.9, RecoverTries = math.huge,
            GuessMult = 0.93, CarryRatio = 0.9, Dangers = {}, DangerAt = 0, Handle = nil,
        },
        Movement = { Owner = nil, StealFirst = false, PlaceWanted = false, ScrambleWanted = false, MutationWanted = false, FracturedWanted = false },
        AntiGuard = { Enabled = false, Busy = false, BusySince = 0, HitArms = 0, HitArmedAt = 0, Handle = nil, PanelHandle = nil, PanelShown = true, ShowPanel = nil, Render = nil },
        Treadmill = { Riding = false },
        Flying = false, Driving = 0, ShieldPaused = false,
        UiQueue = {},
    }
    r247.UiDefer = function(fn) table.insert(r247.UiQueue, fn) end
    r247.Notify = function(t, m) if type(r179.Notify) == "function" then pcall(r179.Notify, t, m, 5) end end
    r247.Toggle = function(h, d)
        if type(h) ~= "table" then return d == true end
        local ok, v = pcall(function() local c = h._controller; return c and type(c.GetValue) == "function" and c.GetValue() end)
        if ok and type(v) == "boolean" then return v end
        for _, m in ipairs({ "Get", "GetValue" }) do
            local ok2, fn = pcall(function() return h[m] end)
            if ok2 and type(fn) == "function" then
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
    r247.Pace = function() return math.max(r247.WalkSpeed() * (tonumber(r247.SafeCarry.RunSpeed) or 1), 16) end
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
    r247.ClaimMovement = function(o)
        local m = r247.Movement
        local free = m.Owner == nil or m.Owner == o or (m.Owner == "treadmill" and o ~= "treadmill")
        local preempt = m.Owner == "scramble" and o == "steal"
        if free or preempt then m.Owner = o; return true end
        return false
    end
    r247.ReleaseMovement = function(o) if r247.Movement.Owner == o then r247.Movement.Owner = nil end end
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
        local a = w and w:FindFirstChild("Areas")
        local s = a and a:FindFirstChild("SeparationLine")
        return pos.X < (s and s:IsA("BasePart") and s.Position.X or 552)
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
    -- Shield
    do
        local swap = { Original = nil, Clone = nil, Links = {} }
        local function clear()
            for _, c in ipairs(swap.Links) do pcall(function() c:Disconnect() end) end
            table.clear(swap.Links)
        end
        r247.UndoSwap = function()
            clear()
            local c = r232.Character
            local o, cl = swap.Original, swap.Clone
            swap.Original, swap.Clone = nil, nil
            if o and cl and c and o.Parent == nil and cl.Parent == c then
                o.Parent = c; workspace.CurrentCamera.CameraSubject = o
                pcall(function() cl:Destroy() end)
            end
        end
        local function doSwap()
            local c = r232.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then return end
            if swap.Clone and swap.Clone.Parent == c then return end
            if not r247.Grounded(h) then return end
            local cl = h:Clone(); h.Parent = nil; cl.Parent = c
            workspace.CurrentCamera.CameraSubject = cl
            swap.Original, swap.Clone = h, cl
            table.insert(swap.Links, h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if cl.Parent then cl.WalkSpeed = h.WalkSpeed end
            end))
            table.insert(swap.Links, cl.Died:Connect(function()
                clear()
                local o = swap.Original
                swap.Original, swap.Clone = nil, nil
                local cc = r232.Character
                if cc and o and h.Parent == nil then
                    o.Parent = cc; workspace.CurrentCamera.CameraSubject = o
                end
                pcall(function() cl:Destroy() end)
                h.Health = 0
            end))
        end
        local hb, car
        local function start()
            if hb then return end
            hb = r137.Heartbeat:Connect(function()
                if r247.ShieldPaused then return end
                if os.clock() - (hb._t or 0) < 0.25 then return end
                hb._t = os.clock(); doSwap()
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
        r247.Shield = function(_, on) if on then start() else stop() end end
        r247.Shield("load", true)
        r240(stop)
    end
end

-- ===== RARITY / AREA OPTIONS =====
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

-- ===== STEAL LOGIC =====
do
    local AREAS = { "Forest", "Desert", "Snow", "Lake", "Jungle", "Volcano", "Prehistoric", "Cosmic", "Abyss Ocean", "Cherry Blossom", "Light Dark", "Temple of Trials" }
    local areaSeen = {}
    for _, v in ipairs(AREAS) do areaSeen[v] = true end
    task.spawn(function()
        local st = r234.EggState
        if type(st) ~= "table" then return end
        local ok, snap = pcall(function() return st.ReadFieldEggs() end)
        if ok and type(snap) == "table" and type(snap.Records) == "table" then
            for _, rec in pairs(snap.Records) do
                local a = type(rec) == "table" and rec.AreaId or nil
                if type(a) == "string" and not areaSeen[a] then
                    areaSeen[a] = true; table.insert(AREAS, a)
                end
            end
        end
    end)

    local targetAreas, targetRarities, specificEggs, minValue = {}, {}, {}, 0
    for _, v in ipairs(AREAS) do targetAreas[v] = true end
    for _, v in ipairs(RARITY_OPTIONS) do
        local num = RARITY_MAP[v]
        if num and num > 0 then targetRarities[v] = true end
    end
    local force, priority, blocklist = {}, {}, {}
    local priorityMode, tweenSpeed, minRarity = PRIORITY[4], 400, 0
    local cooldownEggs, sessionId, carryUid = {}, 0, nil
    local stealToggle, running = nil, false
    local eggOptions, eggCategory = {}, {}

    -- build egg options
    do
        local list, seen = {}, {}
        local dir = r234.Assets and r234.Assets.Directory
        if type(dir) == "table" then
            for k, v in pairs(dir) do
                local rar = type(v) == "table" and v.Rarity or nil
                if type(rar) == "table" then
                    local rn = tonumber(rar.RarityNumber or rar.Rank)
                    if rn then
                        table.insert(list, {
                            Cat = tostring(k),
                            Name = tostring(v.DisplayName or k),
                            Rar = rn,
                            RarName = tostring(rar.DisplayName or rar._id or rn),
                        })
                    end
                end
            end
        end
        table.sort(list, function(a, b) if a.Rar ~= b.Rar then return a.Rar > b.Rar end return a.Name < b.Name end)
        for _, e in ipairs(list) do
            local label = string.format("%s [%s]", e.Name, e.RarName)
            if seen[label] then label = string.format("%s [%s] (%s)", e.Name, e.RarName, e.Cat) end
            seen[label] = true
            table.insert(eggOptions, label)
            eggCategory[label] = e.Cat
        end
    end

    local function stillOurs(sid) return sid ~= sessionId or not r247.Toggle(stealToggle, false) end

    local function readFieldSnap()
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

    local function eggInfo(cat)
        local dir = r234.Assets and r234.Assets.Directory
        local a = type(dir) == "table" and dir[tostring(cat)] or nil
        local rar = type(a) == "table" and type(a.Rarity) == "table" and a.Rarity or nil
        local out = {}
        if rar then rar = tonumber(rar.RarityNumber or rar.Rank) end
        out.RarityNumber = rar or 0
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

    local function listEggs(includeCarried)
        local recs = readFieldSnap()
        if type(recs) ~= "table" then return {} end
        local out, live = {}, {}
        for _, rec in pairs(recs) do
            local uid = type(rec) == "table" and rec.Uid or nil
            if uid and rec.State ~= "Claimed" then live[uid] = true end
            local eligible = uid and (rec.State == "Slot" or rec.State == "Dropped" or (rec.State == "Carried" and includeCarried and not (r247.Steal.Carrying and uid == carryUid)))
            local forced = uid and force[uid] or nil
            local prio = uid and priority[uid] == true or false
            local areaOK = forced or prio or targetAreas[tostring(rec.AreaId)] == true
            local blocked = forced == nil and blocklist[uid] == true
            eligible = eligible and typeof(rec.BottomCFrame) == "CFrame"
            if eligible then eligible = (cooldownEggs[uid] or 0) <= os.clock() end
            if eligible and areaOK and not blocked then
                local info = eggInfo(rec.AssetCategory)
                local cat = tostring(rec.AssetCategory)
                local rarityOK = info.RarityNumber >= minRarity
                local specOK = next(specificEggs) == nil or specificEggs[cat] == true
                local scale = tonumber(rec.AssetScale) or 1
                local mult = mutMult(rec.Mutations)
                local factor = scale > 5 and (scale/5)^1.2 * 19.637875755794113 or scale^1.85
                local valueOK = minValue <= 0 or info.EarningRate * factor * mult >= minValue
                valueOK = rarityOK and specOK and valueOK
                if forced or prio or valueOK then
                    table.insert(out, {
                        Uid = uid, Category = cat, Scale = scale, State = rec.State,
                        Rarity = info.RarityNumber, Weight = 0, Mutation = mult,
                        Value = info.EarningRate * factor * mult,
                        CFrame = rec.BottomCFrame, AreaId = tostring(rec.AreaId),
                        Forced = forced and forced.At or nil,
                        Priority = prio,
                    })
                end
            end
        end
        if next(live) ~= nil then
            for k in pairs(force) do if not live[k] then force[k] = nil end end
            for k in pairs(priority) do if not live[k] then priority[k] = nil end end
            for k in pairs(blocklist) do if not live[k] then blocklist[k] = nil end end
        end
        table.sort(out, function(a, b)
            if (a.Forced ~= nil) ~= (b.Forced ~= nil) then return a.Forced ~= nil end
            if a.Forced and b.Forced and a.Forced ~= b.Forced then return a.Forced < b.Forced end
            if a.Priority ~= b.Priority then return a.Priority == true end
            if priorityMode == PRIORITY[4] and a.Value ~= b.Value then return a.Value > b.Value end
            if priorityMode == PRIORITY[5] and a.Value ~= b.Value then return a.Value < b.Value end
            if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
            if a.Value ~= b.Value then return a.Value > b.Value end
            return tostring(a.Uid) < tostring(b.Uid)
        end)
        return out
    end

    local function flyTo(target, abortUid, needCarry, speedOverride)
        local function abort() return stillOurs(abortUid) end
        local r = r247.Root()
        if not r then return false end
        local char = r232.Character
        local startPos = r.Position
        local done, elapsed = nil, 0
        local c1 = r137.Heartbeat:Connect(function(dt)
            if done ~= nil or r247.AntiGuard.Busy then return end
            elapsed = elapsed + dt
            if abort() then done = false; return end
            if needCarry and not r247.Steal.Carrying then done = false; return end
            local cur = r247.Root()
            if not cur or elapsed >= 20 or r232.Character ~= char then done = false; return end
            local spd = speedOverride or tweenSpeed
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
            if done ~= nil or r247.AntiGuard.Busy then return end
            if abort() then done = false; return end
            if needCarry and not r247.Steal.Carrying then done = false; return end
            local cur = r247.Root()
            if not cur then done = false; return end
            local spd = speedOverride or tweenSpeed
            local delta = target - cur.Position
            if delta.Magnitude <= 0.5 then done = true; return end
            local v = delta.Unit * math.min(spd, delta.Magnitude / math.max(dt, 1/240))
            local vy = workspace.Gravity * math.max(dt, 1/240) * 0.5
            pcall(function()
                cur.AssemblyLinearVelocity = v + Vector3.new(0, vy, 0)
                cur.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        while done == nil do r137.Heartbeat:Wait() end
        c1:Disconnect(); c2:Disconnect()
        return done
    end

    local function smartPromptNear(uid, pos, radius)
        radius = radius or 14
        local best, bd = nil, radius
        for _, p in ipairs(workspace:GetChildren()) do
            if p.Name == "SmartPromptPart" and p:IsA("BasePart") then
                local cp = p:FindFirstChild("CarryAreaEgg")
                if cp and cp:IsA("ProximityPrompt") then
                    local d = (p.Position - pos).Magnitude
                    if d < bd then bd = d; best = cp end
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

    r247.Steal.WrongEgg = function(uid)
        local s = r247.Steal
        if type(uid) ~= "string" or not s.Carrying or s.CarryUid == uid then return false end
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then pcall(st.DropFieldEgg, "PlayerRequest") end
        local t = 0
        while s.Carrying and t < 1 do t += r137.Heartbeat:Wait() end
        s.Carrying = false; s.CarryUid = uid
        return true
    end

    local function grabEgg(egg, abortUid)
        local pos = typeof(egg.CFrame) == "CFrame" and egg.CFrame.Position or nil
        if not pos then return false end
        local elapsed, cd, misses = 0, math.huge, 0
        while elapsed < 1.5 do
            if stillOurs(abortUid) then return false end
            if r247.Steal.Carrying and not r247.Steal.WrongEgg(egg.Uid) then return true end
            if cd >= 0.06 then
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
                cd = 0
            end
            local dt = r137.Heartbeat:Wait()
            elapsed += dt; cd += dt
        end
        return r247.Steal.Carrying == true
    end

    local function verifyCarry(expectedUid, abortUid)
        local t = 0
        while not r247.Steal.Carrying and t < 0.6 and not stillOurs(abortUid) do t += r137.Heartbeat:Wait() end
        if not r247.Steal.Carrying then return false end
        if not carryUid or carryUid == expectedUid then return true end
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then pcall(st.DropFieldEgg, "PlayerRequest") end
        local g = 0
        while r247.Steal.Carrying and g < 1 and not stillOurs(abortUid) do g += r137.Heartbeat:Wait() end
        return false
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

    local function fetchAndGrab(egg, abortUid)
        local pos = typeof(egg.CFrame) == "CFrame" and egg.CFrame.Position or nil
        if not pos then return false end
        if r247.InsideBase() and not r247.InsideBase(pos) then
            local h = homePos()
            if h and not flyTo(h + Vector3.new(0, 3, 0), abortUid, nil, tweenSpeed) then return false end
        end
        if not flyTo(pos + Vector3.new(0, 3, 0), abortUid, nil, tweenSpeed) then return false end
        local got = grabEgg(egg, abortUid)
        if not got and not stillOurs(abortUid) then got = grabEgg(egg, abortUid) end
        if not got then cooldownEggs[egg.Uid] = os.clock() + 20; return false end
        r247.Steal.LastFinishedAt = os.clock()
        return true
    end

    local function deliverHome(abortUid)
        local ag = r247.AntiGuard
        if ag.Enabled then
            local t = 0
            while not ag.Busy and t < 1 and not stillOurs(abortUid) do t += r137.Heartbeat:Wait() end
            local had = ag.Busy
            local t2 = 0
            while ag.Busy and t2 < 30 and not stillOurs(abortUid) do t2 += r137.Heartbeat:Wait() end
            if had then r247.SafeCarry.SlowUntil = os.clock() + 2 end
        end
        local t = 0
        while not r247.Steal.Carrying and t < 0.6 and not stillOurs(abortUid) do t += r137.Heartbeat:Wait() end
        if not r247.Steal.Carrying then return false end
        local home = homePos()
        local r = r247.Root()
        if not home or not r then return false end
        local startT = os.clock()
        local flyY = math.max(r.Position.Y, home.Y) + 27.4
        if not flyTo(Vector3.new(r.Position.X, flyY, r.Position.Z), abortUid, true, tweenSpeed) then return false end
        if not flyTo(Vector3.new(home.X, flyY, home.Z), abortUid, true, tweenSpeed) then return false end
        if not flyTo(home, abortUid, true, tweenSpeed) then return false end
        if not r247.Steal.Carrying then return false end
        local st = r234.EggState
        if type(st) == "table" and type(st.DropFieldEgg) == "function" then pcall(st.DropFieldEgg, "PlayerRequest") end
        return r247.Steal.LastDelivered >= startT or true
    end

    local function stealRun(sid)
        r247.Steal.Active = true
        local list = listEggs(true)
        local target
        for _, e in ipairs(list) do
            if e.State ~= "Carried" then target = e; break end
        end
        if not target then r247.Steal.Active = false; return end
        if not r247.ClaimMovement("steal") then r247.Steal.Active = false; return end
        if r247.Treadmill.Riding then r247.ExitBelt() end
        local ok = pcall(function()
            if fetchAndGrab(target, sid) then
                if verifyCarry(target.Uid, sid) then deliverHome(sid) end
            end
        end)
        r247.Steal.Active = false
        r247.Steal.LastFinishedAt = os.clock()
        r247.ReleaseMovement("steal")
        return ok
    end

    local lastStealAt = 0
    r244.Add(function()
        if not r247.Toggle(stealToggle, false) then return false end
        local cyc = r234.AreaEggCycle
        if type(cyc) == "table" then
            local ok, night = pcall(function() return cyc.IsNightPhase(workspace:GetServerTimeNow()) end)
            if ok and night == true then return false end
            if r247.WallSealed() then return false end
        end
        if running then return true end
        if os.clock() < lastStealAt + 0.6 then return true end
        running = true
        local sid = sessionId
        task.spawn(function()
            pcall(stealRun, sid)
            running = false
            lastStealAt = os.clock()
            r244.Wake()
        end)
        return true
    end)

    -- ===== STEAL EGGS SECTION =====
    local section = r183:CreateSection({ Name = "Steal Eggs", Expanded = true })

    stealToggle = section:CreateToggle({
        Name = "Auto Steal",
        Default = false,
        Callback = function()
            sessionId += 1
            cooldownEggs = {}
            r247.Steal.Active = false
            if not r247.Toggle(stealToggle, false) then
                r247.Movement.StealFirst = false
                table.clear(force); table.clear(priority); table.clear(blocklist)
            end
            r247.StopWalking()
            r244.Wake()
        end,
    })

    section:CreateToggle({
        Name = "Steal Selected Only",
        Note = "Only steal eggs from the target eggs list below",
        Default = false,
        Callback = function(v)
            if type(v) ~= "boolean" then v = false end
            r247._stealSelectedOnly = v
        end,
    })

    section:CreateToggle({
        Name = "Steal Big Eggs Only",
        Note = "Skip eggs smaller than x2.0",
        Default = false,
        Callback = function(v)
            r247._bigEggsOnly = v == true
        end,
    })

    r243(section:CreateMultiDropdown({
        Name = "Areas",
        Note = "Which areas to steal from",
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
    }))

    r243(section:CreateMultiDropdown({
        Name = "Rarities",
        Note = "Which rarities to steal",
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
            targetRarities = out
            minRarity = lowest
        end,
    }))

    r243(section:CreateMultiDropdown({
        Name = "Specific Eggs",
        Note = "Only steal these egg species (empty = all)",
        Options = eggOptions,
        Default = {},
        Callback = function(sel)
            local out = {}
            if type(sel) == "table" then
                for k, v in pairs(sel) do
                    local name = (v == true and type(k) == "string" and k) or (type(v) == "string" and v)
                    if name and eggCategory[name] then out[eggCategory[name]] = true end
                end
            end
            specificEggs = out
        end,
    }))

    section:CreateSlider({
        Name = "Tween Speed",
        Min = 100, Max = 1000, Default = 400, Increment = 10, Unit = "studs/s",
        Callback = function(v) tweenSpeed = math.clamp(tonumber(v) or 400, 100, 1000) end,
    })

    section:CreateDropdown({
        Name = "Steal Priority",
        Options = PRIORITY,
        Default = PRIORITY[4],
        Callback = function(v) if table.find(PRIORITY, v) then priorityMode = v end end,
    })

    local safeHandle = section:CreateToggle({
        Name = "Safe Delivery",
        Note = "Best with Anti Guard on",
        Default = true,
        Callback = function(v)
            if type(v) ~= "boolean" then v = r247.Toggle(safeHandle, true) end
            r247.SafeCarry.Enabled = v == true
        end,
    })

    section:CreateSlider({
        Name = "Carry Speed",
        Min = 80, Max = 120, Default = 100, Increment = 1, Unit = "%",
        SubOf = safeHandle,
        Callback = function(v) r247.SafeCarry.CarryScale = math.clamp(tonumber(v) or 100, 80, 120) / 100 end,
    })

    -- ===== ANTI GUARD SECTION =====
    local agSection = r183:CreateSection({ Name = "Anti Guard", Expanded = true })

    agSection:CreateToggle({
        Name = "Anti Guard",
        Note = "Slip past guard when caught carrying an egg",
        Default = false,
        Callback = function(v)
            local on = v == true
            r247.AntiGuard.Enabled = on
            local h = r247.AntiGuard.Handle
            if h and type(h.Set) == "function" then pcall(h.Set, h, on) end
            if r247.AntiGuard.Render then
                r247.UiDefer(function() pcall(r247.AntiGuard.Render, false) end)
            end
        end,
    })

    r247.AntiGuard.PanelHandle = agSection:CreateToggle({
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

    agSection:CreateLabel({ Text = "Tip: click the floating panel below" })
    agSection:CreateLabel({ Text = "to toggle. Hold & drag to move it." })

    -- carry state
    do
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(info)
                local c = type(info) == "table" and info.IsCarrying == true
                if c and type(info.Uid) == "string" then carryUid = info.Uid end
                r247.Steal.Carrying = c
                if not c then carryUid = nil end
                r244.Wake()
            end)
            if ok and conn then r240(function() pcall(function() conn:Disconnect() end) end) end
        end
    end
    do
        local ok, verdict = pcall(function() return r182:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict") end)
        if ok and verdict and verdict:IsA("RemoteEvent") then
            local conn = verdict.OnClientEvent:Connect(function() r247.SafeCarry.LastDelivered = os.clock() end)
            r240(function() conn:Disconnect() end)
        end
        local ok2, alerts = pcall(function() return r182:FindFirstChild("RE/Alerts/Raise") end)
        if ok2 and alerts and alerts:IsA("RemoteEvent") then
            local conn = alerts.OnClientEvent:Connect(function(msg)
                if type(msg) == "table" and type(msg.Text) == "string" and string.find(msg.Text, "Delivery failed", 1, true) then
                    r247.SafeCarry.LastFailed = os.clock()
                end
            end)
            r240(function() conn:Disconnect() end)
        end
    end
end

-- ===== ANTI GUARD PANEL =====
do
    local TweenService = game:GetService("TweenService")
    local GuiService = game:GetService("GuiService")
    local StarterGui = game:GetService("StarterGui")
    local AG = r247.AntiGuard

    local COLORS = {
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

    local PANEL_H, ALIVE = 52, true
    local conns = {}
    local state = { AreaId = nil, SignalCarrying = false, WeldCarrying = false, Carrying = false, Active = false, Disguise = nil, FlashRequest = nil, FlashUntil = 0 }

    local function randName()
        local s = {}
        for i = 1, math.random(10, 16) do s[i] = string.char(math.random(97, 122)) end
        return table.concat(s)
    end
    local HUIPARENT = (typeof(gethui) == "function" and select(2, pcall(gethui))) or r138
    local function newInst(class, parent, props)
        local i = Instance.new(class)
        i.Name = randName()
        for k, v in pairs(props or {}) do i[k] = v end
        i.Parent = parent
        return i
    end
    local function tween(obj, dur, props, style)
        local ok, t = pcall(function()
            return TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        end)
        if ok and t then t:Play() end
    end
    local flash
    local function findWeldModel()
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
    local function cloneClean(model, parent)
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
    local function disguise(char)
        local cam = workspace.CurrentCamera
        if not char or not cam or state.Disguise then return end
        local st = { Camera = cam, CameraType = cam.CameraType, CameraCFrame = cam.CFrame, Copies = {}, Hidden = {} }
        state.Disguise = st
        local models = { char }
        local ok, m = pcall(findWeldModel)
        if ok and m then models[#models+1] = m end
        for _, mm in ipairs(models) do
            for _, d in ipairs(mm:GetDescendants()) do
                if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then st.Hidden[#st.Hidden+1] = d end
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
            local ok2, c = pcall(cloneClean, mm, cam)
            if ok2 and c then st.Copies[#st.Copies+1] = c end
        end
    end
    local function undisguise()
        local st = state.Disguise
        if not st then return end
        state.Disguise = nil
        if st.BindName then pcall(function() r137:UnbindFromRenderStep(st.BindName) end) end
        if st.Link then pcall(function() st.Link:Disconnect() end) end
        if st.Beat then pcall(function() st.Beat:Disconnect() end) end
        for _, d in ipairs(st.Hidden) do pcall(function() d.LocalTransparencyModifier = 0 end) end
        pcall(function() st.Camera.CameraType = st.CameraType end)
        for _, c in ipairs(st.Copies) do pcall(function() c:Destroy() end) end
    end

    local function runAntiGuard(session)
        local char = r232.Character
        local root = r247.Root()
        local hm = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hm or hm.Health <= 0 then
            AG.Busy = false; flash(COLORS.Bad, 1.6); return
        end
        local function alive() return ALIVE and root.Parent and hm.Parent and hm.Health > 0 end
        local startCF = root.CFrame
        local startPos = startCF.Position
        local hadStand = hm.PlatformStand
        pcall(function() hm.BreakJointsOnDeath = false end)
        pcall(disguise, char)
        flash(COLORS.Work)
        local function sleep(sec)
            local t = os.clock() + sec
            while alive() and os.clock() - session < 3 and os.clock() < t do
                r137.Heartbeat:Wait()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end)
            end
        end
        sleep(0.15)
        if alive() then hm.PlatformStand = true end
        local function snap(pos, rot)
            local cf = CFrame.new(pos) * rot
            pcall(function() char:PivotTo(cf) end)
            if (root.Position - pos).Magnitude > 3 then pcall(function() root.CFrame = cf end) end
        end
        local baseRot = CFrame.new()
        for i = 1, 3 do
            if not alive() then break end
            local dest = startPos + Vector3.new((math.random()*2-1)*6, 0, (math.random()*2-1)*6)
            snap(dest, baseRot); sleep(0.35)
        end
        if alive() then snap(startPos, baseRot); sleep(0.3) end
        pcall(function() hm.PlatformStand = hadStand end)
        undisguise()
        AG.Busy = false
        if alive() and state.Carrying then flash(COLORS.Good, 1.6) else flash(COLORS.Bad, 1.6) end
    end

    local function hitArmExpired()
        if AG.HitArms <= 0 then return false end
        if 25 < os.clock() - (AG.HitArmedAt or 0) then AG.HitArms = 0; return false end
        return true
    end
    local function updateCarry()
        local was = state.Carrying
        state.Carrying = state.SignalCarrying or state.WeldCarrying
        if state.Carrying and not was and ALIVE and AG.Enabled and not state.Active and not hitArmExpired() then
            state.Active = true
            AG.Busy = true
            AG.BusySince = os.clock()
            task.spawn(function()
                if not pcall(runAntiGuard, os.clock()) then
                    pcall(function()
                        local c = r232.Character
                        local h = c and c:FindFirstChildOfClass("Humanoid")
                        if h then h.PlatformStand = false end
                    end)
                    undisguise()
                    AG.Busy = false
                    flash(COLORS.Bad, 1.6)
                end
            end)
        end
    end

    -- Panel UI
    local screen = newInst("ScreenGui", nil, { ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = -100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    local frame = newInst("Frame", screen, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, -120), Size = UDim2.fromOffset(226, PANEL_H), BackgroundTransparency = 1 })
    local frameScale = newInst("UIScale", frame, { Scale = 1 })
    local card = newInst("Frame", frame, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = COLORS.Card, BorderSizePixel = 0, Active = true })
    newInst("UICorner", card, { CornerRadius = UDim.new(0, 14) })
    local cardScale = newInst("UIScale", card, { Scale = 0.86 })
    newInst("UIGradient", card, { Color = ColorSequence.new(COLORS.CardTop, COLORS.Card), Rotation = 90 })
    local cardStroke = newInst("UIStroke", card, { Thickness = 1.5, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local strokeGrad = newInst("UIGradient", cardStroke, { Color = ColorSequence.new(COLORS.Stroke, COLORS.Stroke) })
    local iconBg = newInst("Frame", card, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = Color3.fromRGB(28, 26, 32), BorderSizePixel = 0, ZIndex = 2 })
    newInst("UICorner", iconBg, { CornerRadius = UDim.new(0, 11) })
    local iconStroke = newInst("UIStroke", iconBg, { Thickness = 1.5, Color = COLORS.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local icon = newInst("ImageLabel", iconBg, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.86, 0.86), BackgroundTransparency = 1, Image = "rbxassetid://118755181202304", ImageTransparency = 0.35, ScaleType = Enum.ScaleType.Crop, ZIndex = 3 })
    newInst("UICorner", icon, { CornerRadius = UDim.new(0, 8) })
    local iconScale = newInst("UIScale", icon, { Scale = 1 })
    newInst("UIGradient", newInst("TextLabel", card, { BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 7), Size = UDim2.new(1, -112, 0, 15), Font = Enum.Font.BuilderSansExtraBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 255, 255), Text = "Oxio Hub", ZIndex = 2 }), { Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,220)) })
    newInst("TextLabel", card, { BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 22), Size = UDim2.new(1, -112, 0, 20), Font = Enum.Font.GothamBlack, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = COLORS.Text, Text = "Anti Guard", ZIndex = 2 })
    local toggle = newInst("TextButton", card, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, BorderSizePixel = 0, Text = "", ZIndex = 2 })
    newInst("UICorner", toggle, { CornerRadius = UDim.new(1, 0) })
    local toggleGrad = newInst("UIGradient", toggle, { Color = ColorSequence.new(COLORS.Off, COLORS.Off) })
    local knob = newInst("Frame", toggle, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(245, 245, 250), BorderSizePixel = 0, ZIndex = 3 })
    newInst("UICorner", knob, { CornerRadius = UDim.new(1, 0) })

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
            tween(knob, dur, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
            tween(icon, dur, { ImageTransparency = 0 })
            tween(cardStroke, 0.3, { Transparency = 0 })
        else
            toggleGrad.Color = ColorSequence.new(COLORS.Off, COLORS.Off)
            strokeGrad.Color = ColorSequence.new(COLORS.Stroke, COLORS.Stroke)
            tween(knob, dur, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
            tween(icon, dur, { ImageTransparency = 0.35 })
            tween(cardStroke, 0.3, { Transparency = 0.2 })
        end
        if state.FlashUntil <= os.clock() then tween(iconStroke, dur, { Color = baseStroke() }) end
    end
    flash = function(color, hold) state.FlashRequest = { Color = color, Hold = hold } end
    local function processFlash()
        local req = state.FlashRequest
        if not req then return end
        state.FlashRequest = nil
        state.FlashUntil = os.clock() + (req.Hold or 0)
        tween(iconStroke, 0.2, { Color = req.Color })
        if req.Hold then
            task.delay(req.Hold, function()
                if ALIVE and os.clock() >= state.FlashUntil then tween(iconStroke, 0.3, { Color = baseStroke() }) end
            end)
        end
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

    local dragOverlay = newInst("TextButton", card, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 10, Active = false })
    local dragging, dragged, dragStart, startPos, userPos, dragInput = false, false, Vector2.zero, nil, nil, nil
    local function onToggleClick()
        AG.Enabled = not AG.Enabled
        render(false); setHandle(AG.Enabled)
        tween(iconScale, 0.12, { Scale = 1.15 })
        task.delay(0.12, function() if ALIVE then tween(iconScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end end)
    end
    conns[#conns+1] = dragOverlay.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
        dragging, dragged = true, false
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = frame.Position
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState ~= Enum.UserInputState.End then return end
            dragging, dragInput = false, nil
            if not dragged then onToggleClick() end
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
    local dragOrigSize = toggle.Size
    conns[#conns+1] = dragOverlay.MouseEnter:Connect(function() tween(toggle, 0.15, { Size = dragOrigSize + UDim2.fromOffset(2, 2) }) end)
    conns[#conns+1] = dragOverlay.MouseLeave:Connect(function() tween(toggle, 0.15, { Size = dragOrigSize }) end)

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
        local ok, v = pcall(function() return GuiService:GetGuiInset().Y end)
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
            if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then return end
            for _, c in ipairs(r138.RobloxGui.Backpack:GetChildren()) do if c:IsA("GuiObject") then out[#out+1] = c end end
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
        local scale = touch and math.clamp(s*1.05, 0.6, 0.8)*0.97 or math.clamp(s, 0.8, 1.1)
        frameScale.Scale = scale
        local bgT = touch and 0.3 or 0
        if card.BackgroundTransparency ~= bgT then
            card.BackgroundTransparency = bgT; iconBg.BackgroundTransparency = bgT
        end
        if userPos then frame.Position = userPos; return end
        local y = vp.Y - 8 * scale
        local found = false
        for _, m in ipairs(allBars()) do
            local ok, vis = pcall(isVisible, m)
            if ok and vis then
                local sz = m.AbsoluteSize
                local mY = m.AbsolutePosition.Y
                if sz.X > 20 and sz.Y > 20 and sz.Y < vp.Y*0.4 and mY + sz.Y/2 > vp.Y*0.5 then
                    local ok2, top = pcall(topOfContainer, m)
                    mY = ok2 and top or mY
                    found = true
                    y = math.min(y, mY + guiInsetY())
                end
            end
        end
        if found then cachedBottom = vp.Y - y
        elseif cachedBottom then y = vp.Y - cachedBottom end
        local finalY = math.max(y - (touch and 4 or 6)*scale - PANEL_H*scale/2, PANEL_H*scale/2 + 8)
        frame.Position = UDim2.new(0.5, 0, 0, finalY)
    end

    do
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(info)
                local c = type(info) == "table" and info.IsCarrying == true
                if c and info.GuardDisabled == true then c = false end
                if c and type(info.AreaId) == "string" then state.AreaId = info.AreaId end
                if not c then state.AreaId = nil end
                state.SignalCarrying = c
                updateCarry()
            end)
            if ok and conn then conns[#conns+1] = conn end
        end
    end
    local scanT = 0
    conns[#conns+1] = r137.Heartbeat:Connect(function(dt)
        local busy = AG.Busy or state.Active
        if busy and os.clock() - AG.BusySince > 2.5 then
            undisguise()
            local c = r232.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.PlatformStand then pcall(function() h.PlatformStand = false end) end
            state.Active = false; AG.Busy = false
        end
        hitArmExpired()
        scanT += dt
        if scanT < 0.03 then return end
        scanT = 0
        local weld = findWeldModel() ~= nil
        if weld ~= state.WeldCarrying then
            state.WeldCarrying = weld
            updateCarry()
        end
    end)
    conns[#conns+1] = r137.RenderStepped:Connect(function(dt)
        processFlash()
        lastScan, lastPos = lastScan + dt, lastPos + dt
        if lastScan >= 3 then lastScan = 0; pcall(collect) end
        if lastPos >= 0.2 then lastPos = 0; pcall(reposition) end
    end)
    render(true)
    AG.ShowPanel = function(on) screen.Enabled = on == true end
    screen.Enabled = AG.PanelShown == true
    screen.Parent = HUIPARENT
    tween(cardScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

    r240(function()
        ALIVE = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        table.clear(conns)
        undisguise()
        state.Active = false; AG.Busy = false
        AG.Render = nil; AG.ShowPanel = nil
        pcall(function() screen:Destroy() end)
    end)
end

r179:Finalize({ Window = r180, MainTab = r183, ShowMainTab = true })
print("[Oxio] Loaded: Steal Eggs + Anti Guard")
