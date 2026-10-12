--[[ Oxio Hub - Auto Steal + Anti Guard
     Panel bisa di-drag
     Outline: putih
     Logo: rbxassetid://118755181202304
]]

local r231, r179, r180, r183, r136, r137, r181, r138, r139, r232
local r182, r233, r234, r235, r238, r240, r241, r192, r243, r244
local r247, r263

-- ============= BOOTSTRAP =============
do
    r231 = function(s4)
        local s2 = typeof(getgenv) == "function" and getgenv() or _G
        if type(s2.ChilliDebugPrint) == "function" then pcall(s2.ChilliDebugPrint, s4) end
    end

    local _PLib = nil
    local _ok, _err = pcall(function()
        _PLib = loadstring(game:HttpGet("https://script.panduhub.com/PanduUiLibrary.lua"))()
    end)
    assert(_ok and type(_PLib) == "table", "PanduHub failed: " .. tostring(_err))

    r179 = _PLib
    assert(type(r179.CreateWindow) == "function" and type(r179.Finalize) == "function", "Chilli Lib invalid.")

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
            for i = 1, n do out[i] = string.sub(chars, rng:NextInteger(1, #chars), rng:NextInteger(1, #chars)) end
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

    do
        r244 = { _list = {}, _wake = true }
        r244.Add = function(fn)
            local s = { Run = fn, Gap = 0.35, Idle = 5, Repeat = false, Hold = 0 }
            table.insert(r244._list, s)
            return s
        end
        r244.Wake = function() r244._wake = true end
        r244.Backoff = function(s, sec) if s then s.Hold = tonumber(sec) or 6 end end

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

-- ============= r247 BASE =============
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
        Flying = false, Driving = 0,
        ShieldPaused = false, SpeedForced = false,
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
    r247.FindBat = function()
        local c = r232.Character
        local equip = c and c:FindFirstChildWhichIsA("Tool")
        if r247.IsBatTool(equip) then return equip end
        local bp = r232:FindFirstChildOfClass("Backpack")
        if bp then for _, t in ipairs(bp:GetChildren()) do if r247.IsBatTool(t) then return t end end end
        if c then for _, t in ipairs(c:GetChildren()) do if r247.IsBatTool(t) then return t end end end
        return nil
    end

    -- ============= SHIELD (Humanoid Swap) =============
    do
        local r14 = { Original = nil, Clone = nil, Links = {} }
        local links = r14.Links

        local function clearLinks()
            for _, c in ipairs(links) do pcall(function() c:Disconnect() end) end
            table.clear(links)
        end

        r247.UndoSwap = function()
            clearLinks()
            local c = r232.Character
            local orig, cl = r14.Original, r14.Clone
            r14.Original, r14.Clone = nil, nil
            if orig and cl and c and orig.Parent == nil and cl.Parent == c then
                orig.Parent = c
                workspace.CurrentCamera.CameraSubject = orig
                pcall(function() cl:Destroy() end)
            end
        end

        r247.Swapped = function()
            local c = r232.Character
            return r14.Clone ~= nil and c ~= nil and r14.Clone.Parent == c
        end

        local function doSwap()
            local c = r232.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then return end
            if r14.Clone and r14.Clone.Parent == c then return end
            if not r247.Grounded(h) then return end
            local clone = h:Clone()
            h.Parent = nil
            clone.Parent = c
            workspace.CurrentCamera.CameraSubject = clone
            r14.Original, r14.Clone = h, clone

            table.insert(links, h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if clone.Parent then clone.WalkSpeed = h.WalkSpeed end
            end))
            table.insert(links, clone.Died:Connect(function()
                clearLinks()
                local orig = r14.Original
                r14.Original, r14.Clone = nil, nil
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
                clearLinks()
                r14.Original, r14.Clone = nil, nil
                task.spawn(function() task.wait(1); doSwap() end)
            end)
        end

        local function stop()
            if hb then hb:Disconnect(); hb = nil end
            if car then car:Disconnect(); car = nil end
            clearLinks()
        end

        r247.Shield = function(name, on)
            if on then start() else stop() end
        end
        r247.Shield("load", true)
        r240(stop)
    end

    -- ============= ON HUMANOID CHANGED =============
    do
        local subs = {}
        r247.OnHumanoidChanged = function(fn)
            table.insert(subs, fn)
            local s = { Connected = true, Disconnect = function()
                s.Connected = false
                local i = table.find(subs, fn)
                if i then table.remove(subs, i) end
            end }
            return s
        end
    end

    r247.MutationName = function(id)
        local map = { Boss = "Fractured", GreatBloom = "Spirit Bloom", Sakura = "Bloom", Monstrous = "Parasite" }
        task.spawn(function()
            local m = r234.Mutations
            local ok, all = pcall(function() return m.All() end)
            if ok and type(all) == "table" then
                for k, v in pairs(all) do
                    local mid = type(v) == "table" and (v.Id or k) or nil
                    local lbl = type(v) == "table" and v.Label or nil
                    if mid ~= nil and type(lbl) == "string" and lbl ~= "" then map[tostring(mid)] = lbl end
                end
            end
        end)
        return map[tostring(id)] or tostring(id)
    end
    r263 = r247.MutationName

    -- ============= WALKTO =============
    do
        local function walkToPos(pos, threshold, timeout, abort)
            threshold = tonumber(threshold) or 6
            timeout = tonumber(timeout) or 10
            local elapsed = 0
            local last, stuck = nil, 0
            local cooldown = 0
            while elapsed < timeout do
                if type(abort) == "function" and abort() then r247.StopWalking(); return false end
                local c = r232.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if not r or not h or h.Health <= 0 then return false end
                if (r.Position - pos).Magnitude <= threshold then r247.StopWalking(); return true end
                local moved = last and (r.Position - last).Magnitude < 1
                stuck = moved and stuck + 0.2 or 0
                last = r.Position
                cooldown = math.max(0, cooldown - 0.2)
                if stuck >= 0.8 and cooldown <= 0 then
                    r247.LeaveBelt()
                    pcall(function() h.Jump = true end)
                    stuck = 0; cooldown = 1.5
                end
                h:MoveTo(pos)
                elapsed += task.wait(0.2)
            end
            r247.StopWalking()
            return r247.DistanceTo(pos) <= threshold
        end
        r247.WalkTo = function(pos, threshold, timeout, abort)
            r247.Driving = r247.Driving + 1
            local ok, res = pcall(walkToPos, pos, threshold, timeout, abort)
            r247.Driving = math.max(0, r247.Driving - 1)
            return ok and res == true
        end
    end

    -- ============= STEAL HOME / r3_6 =============
    r247.ExpandRarityOptions = function()
        local opts = { "Any" }
        local rarityMap = { Any = 0 }
        local seen = {}
        local dir = r234.Assets and r234.Assets.Directory
        if type(dir) == "table" then
            for _, v in pairs(dir) do
                local rar = type(v) == "table" and v.Rarity or nil
                if type(rar) == "table" then
                    local num = tonumber(rar.RarityNumber or rar.Rank)
                    if num and not seen[num] then
                        seen[num] = tostring(rar.DisplayName or rar._id or num)
                    end
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
            rarityMap[seen[n]] = n
        end
        return opts, rarityMap
    end
end

-- ============= STEAL LOGIC =============
do
    local r7_4 = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
    local r191, r264 = r247.ExpandRarityOptions()

    local r150 = {
        "Forest", "Desert", "Snow", "Lake", "Jungle", "Volcano",
        "Prehistoric", "Cosmic", "Abyss Ocean", "Cherry Blossom", "Light Dark", "Temple of Trials",
    }
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

    local r266 = 0
    local r267 = {}
    local r268, r269, r270 = {}, {}, {}
    local r271, r272, r273 = false, {}, 0
    local r274 = r7_4[4]
    local r275, r276, r277 = 400, 27.4, 400
    local r278 = nil
    local r16_2

    local r291 = 0
    local r292 = {}
    local r293 = 20
    local r294 = nil

    local function r295(arg1)
        return arg1 ~= r291 or not r247.Toggle(r16_2, false)
    end

    -- r299: night/wall timer
    local r296, r298 = {}, 0
    local function r297(t)
        if type(t) ~= "number" or r296[t] then return end
        r296[t] = true
        task.delay(math.max(0, t - workspace:GetServerTimeNow()) + 0.05, function()
            r296[t] = nil
            r244.Wake()
        end)
    end
    local function r299()
        local cyc = r234.AreaEggCycle
        if type(cyc) ~= "table" then return nil end
        local ok, now, night, nextNight, nextReset = pcall(function()
            local t = workspace:GetServerTimeNow()
            return t, cyc.IsNightPhase(t), cyc.NextNightTime(t), cyc.NextResetTime(t)
        end)
        if not ok or type(nextReset) ~= "number" then return nil end
        if nextNight == true then
            r298 = nextReset + r247.WallOpenDelay()
            r297(r298)
            return r298, "night", night
        end
        if r247.WallSealed() then
            r297(night + 0.3)
            return math.max(r298, night), "wall", night
        end
        if type(nextNight) == "number" and nextNight > night then r297(nextNight) end
        return nil
    end

    -- field tracking
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
    local function r304()
        if r301 == nil then return false end
        if r247.IsNight() then return true end
        if r302 == math.huge then r302 = os.clock() + 8 end
        return false
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
        local seen = false; local unseen = false
        for k in pairs(cur) do
            if r301[k] then seen = true else unseen = true end
        end
        if not seen then r301 = nil; return false end
        return not unseen
    end

    -- r310: get list of eggs
    local function r307(cat)
        local dir = r234.Assets and r234.Assets.Directory
        local a = type(dir) == "table" and dir[tostring(cat)] or nil
        local rar = type(a) == "table" and type(a.Rarity) == "table" and a.Rarity or nil
        local out = {}
        if rar then rar = tonumber(rar.RarityNumber or rar.Rank) end
        out.RarityNumber = rar or 0
        out.EarningRate = type(a) == "table" and tonumber(a.EarningRate) or 0
        return out
    end
    local function r308(muts)
        local m = r234.Mutations
        if type(m) == "table" and type(m.EarningsFor) == "function" then
            local ok, v = pcall(m.EarningsFor, type(muts) == "table" and muts or {})
            if ok and type(v) == "number" then return v end
        end
        return 1
    end
    local function r309(cat, scale)
        local er = r234.EggRecords
        if type(er) == "table" and type(er.WeightKgForScale) == "function" then
            local ok, v = pcall(er.WeightKgForScale, cat, scale)
            if ok and type(v) == "number" then return v end
        end
        return 0
    end

    local r310 = function(forFuse, includeCarried)
        local recs = nil
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
            local index = forFuse ~= true and r271 and uid and r272[tostring(rec.AssetCategory)] or nil
            local rift = forFuse ~= true and r247.Steal.RiftPriority == true and uid and r247.Steal.RiftNeeds[tostring(rec.AssetCategory)] == true
            local areaOK = forFuse == true or forced or priority or rift or index ~= nil or r265[tostring(rec.AreaId)] == true
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
                local riftOnly = rift and not valueOK and not priority and forced == nil and index == nil
                local unsafe = forFuse ~= true and r247.SafeCarry.Unsafe({ Uid = uid, Category = cat })
                if unsafe then
                    r268[uid] = nil; r269[uid] = nil
                    r247.SafeCarry.LastSkip = unsafe
                elseif forFuse == true or forced or priority or rift or index ~= nil or valueOK then
                    table.insert(out, {
                        Uid = uid, Category = cat, Scale = scale, State = rec.State,
                        Rarity = info.RarityNumber, Weight = r309(rec.AssetCategory, scale),
                        Mutation = mult, Value = info.EarningRate * factor * mult,
                        CFrame = rec.BottomCFrame, AreaId = tostring(rec.AreaId),
                        Rift = forFuse ~= true and rift,
                        RiftOnly = forFuse ~= true and riftOnly,
                        Index = index, Forced = forFuse ~= true and forced and forced.At or nil,
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
            if a.RiftOnly ~= b.RiftOnly then return b.RiftOnly == true end
            if (a.Index ~= nil) ~= (b.Index ~= nil) then return a.Index ~= nil end
            if a.Index and b.Index and a.Index ~= b.Index then return a.Index > b.Index end
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

    -- movement/pathfinder helpers
    local r311 = 6
    local r314, r315, r318, r319, r322
    do
        local r312, r313 = nil, nil
        r314 = function(part, target, speed, dt, mem)
            local delta = target - part.Position
            local dist = delta.Magnitude
            local step = math.max(dt, 1/240)
            local v = Vector3.zero
            if dist > 0.01 then v = delta.Unit * math.min(speed, dist / step) end
            local v2 = v + Vector3.new(0, workspace.Gravity * step * 0.5, 0)
            if dist > 2 then
                if not mem.mark then mem.mark = dist; mem.clock = 0 end
                mem.clock = mem.clock + dt
                if mem.clock >= 0.4 then
                    if mem.mark - dist < speed * 0.1 then
                        pcall(function() part.CFrame = part.CFrame + delta.Unit * math.min(dist, speed * step) end)
                    end
                    mem.mark = dist; mem.clock = 0
                end
            else
                mem.mark = nil
            end
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
        local r316, r317 = nil, {}
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
            r316 = r137.PreSimulation:Connect(function(dt)
                if not r312 or r319() or r247.AntiGuard.Busy then return end
                local r = r247.Root()
                if r then r314(r, r312, r277, dt, r317) end
            end)
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

    -- r347: fly to position
    local r347 = function(target, abortFn, needCarry, speedOverride, watchDisplace, customCancel)
        r318()
        local r = r247.Root()
        if not r then return false end
        local char = r232.Character
        local startPos = r.Position
        local mem = {}
        local done, reason = nil, nil
        local elapsed = 0

        local function step(dt)
            elapsed = elapsed + dt
            if r295(abortFn) then done = false; return nil end
            if needCarry and not r247.Steal.Carrying then done = false; reason = "dropped"; return nil end
            if customCancel then
                local r_ = customCancel()
                if r_ then done = false; reason = r_; return nil end
            end
            local cur = r247.Root()
            if not cur or elapsed >= 25 or r232.Character ~= char then done = false; reason = "respawned"; return nil end
            return cur
        end

        local c1 = r137.Heartbeat:Connect(function(dt)
            if done ~= nil or r247.AntiGuard.Busy then return end
            local cur = step(dt)
            if not cur then return end
            if (cur.Position - startPos).Magnitude > r311 then
                if watchDisplace then done = false; reason = "displaced"; return end
                startPos = cur.Position
            end
            local baseSpeed = (speedOverride or r275) * (os.clock() < (r247.SafeCarry.SlowUntil or 0) and r247.SafeCarry.SlowFactor or 1)
            local spd = baseSpeed
            if r247.SafeCarry.Enabled and r247.SafeCarry.Pace then
                spd = math.min(baseSpeed, r247.SafeCarry.Pace())
            end
            local delta = target - startPos
            local steplen = spd * dt
            local arrived = delta.Magnitude <= math.max(steplen, 0.05)
            startPos = arrived and target or startPos + delta.Unit * steplen
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
            local cur = step(dt)
            if not cur then return end
            local baseSpeed = (speedOverride or r275) * (os.clock() < (r247.SafeCarry.SlowUntil or 0) and r247.SafeCarry.SlowFactor or 1)
            local spd = baseSpeed
            if r247.SafeCarry.Enabled and r247.SafeCarry.Pace then
                spd = math.min(baseSpeed, r247.SafeCarry.Pace())
            end
            if r314(cur, target, spd, dt, mem) then done = true end
        end)

        while done == nil do r137.Heartbeat:Wait() end
        c1:Disconnect(); c2:Disconnect()
        if done and r322 then r322(target, speedOverride ~= nil) end
        return done, reason
    end

    -- r336: verify carry
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
        local guard = 0
        while r247.Steal.Carrying and guard < 1 and not r295(abortUid) do
            guard += r137.Heartbeat:Wait()
        end
    end
    local r336 = function(expectedUid, abortUid)
        local g = 0
        while not r247.Steal.Carrying and g < r326 and not r295(abortUid) do
            g += r137.Heartbeat:Wait()
        end
        if not r247.Steal.Carrying then return false end
        if matchesCarryUid(expectedUid) then return true end
        local cur = currentCarryUid()
        if stillInList(cur) then return true end
        dropHeld(abortUid)
        return false
    end

    -- r330: find SmartPromptPart near pos
    local function smartPromptNear(uid, pos, radius)
        radius = radius or 14
        local best, bestPos, bestDist = nil, nil, radius
        for _, p in ipairs(workspace:GetChildren()) do
            if p.Name == "SmartPromptPart" and p:IsA("BasePart") then
                local cp = p:FindFirstChild("CarryAreaEgg")
                if cp and cp:IsA("ProximityPrompt") then
                    local d = (p.Position - pos).Magnitude
                    if d < bestDist then bestDist = d; best = cp; bestPos = p end
                end
            end
        end
        return best, bestPos
    end

    local function firePrompt(prompt)
        if not prompt then return false end
        pcall(function() prompt.HoldDuration = 0 end)
        if typeof(fireproximityprompt) == "function" then
            return pcall(fireproximityprompt, prompt)
        end
        return false
    end

    local function carryFallback(uid)
        local st = r234.EggState
        if type(uid) == "string" and type(st) == "table" and type(st.CarryFieldEgg) == "function" then
            pcall(st.CarryFieldEgg, uid)
        end
    end

    -- r337: grab egg
    local r337 = function(egg, abortUid)
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

    -- r340: confirm carry at server
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

    local r342 = function(list)
        local best, bd = nil, math.huge
        for _, e in ipairs(list) do
            local r = r247.Root()
            local p = typeof(e.CFrame) == "CFrame" and e.CFrame.Position or nil
            if r and p then
                local d = (r.Position - p).Magnitude
                if d < bd then bd = d; best = e end
            end
        end
        return best, bd
    end

    local r344 = 90
    local r354 = 20

    -- r363: other player holds?
    local function otherHolds(uid)
        local m = workspace:FindFirstChild(uid)
        if not m then return false end
        for _, c in ipairs(m:GetDescendants()) do
            if c:IsA("JointInstance") or c:IsA("WeldConstraint") or c:IsA("RigidConstraint") then
                local ok, p0, p1 = pcall(function() return c.Part0, c.Part1 end)
                if ok then
                    for _, part in ipairs({ p0, p1 }) do
                        if typeof(part) == "Instance" and not part:IsDescendantOf(m) then
                            local anc = part:FindFirstAncestorOfClass("Model")
                            if anc and anc ~= r232.Character and r136:GetPlayerFromCharacter(anc) then return true end
                        end
                    end
                end
            end
        end
        return false
    end

    -- r365: follow falling egg
    local function r365(abortUid, overrideUid)
        local uid = overrideUid or r247.Steal.CarryUid
        if type(uid) ~= "string" then return false end
        r318()
        local followPos, velocity = nil, Vector3.zero
        local conn = r137.PreSimulation:Connect(function(dt)
            local r = r247.Root()
            if not r or not followPos or r247.Steal.Carrying or r295(abortUid) then return end
            if r319() then return end
            local step = math.max(dt, 1/240)
            local desired = velocity + (followPos - r.Position) / math.max(0.08, step)
            local cap = r247.SafeCarry.Enabled and r247.SafeCarry.Pace() or (r277 + velocity.Magnitude)
            if cap < desired.Magnitude then desired = desired.Unit * cap end
            local v = desired + Vector3.new(0, workspace.Gravity * step * 0.5, 0)
            pcall(function()
                r.AssemblyLinearVelocity = v
                r.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
        local t, lastPos, lastAt = 0, nil, nil
        local promptCooldown = math.huge
        local seenGone = 0
        while t < 30 do
            if r295(abortUid) then conn:Disconnect(); return false end
            if r247.Steal.Carrying then
                if not r247.Steal.WrongEgg(uid) then conn:Disconnect(); return true end
            end
            local r = r247.Root()
            if not r then conn:Disconnect(); return false end
            local pos = nil
            local m = workspace:FindFirstChild("AreaEggSlotsClient")
            m = m and m:FindFirstChild(uid)
            if m then local ok, pv = pcall(function() return m:GetPivot().Position end); if ok then pos = pv end end
            if not pos then
                local rf = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
                if rf and rf:IsA("RemoteFunction") and promptCooldown >= 0.5 then
                    promptCooldown = 0
                    local ok, snap = pcall(rf.InvokeServer, rf)
                    if ok and type(snap) == "table" and type(snap.Records) == "table" then
                        for _, rec in pairs(snap.Records) do
                            if type(rec) == "table" and rec.Uid == uid and typeof(rec.BottomCFrame) == "CFrame" then
                                pos = rec.BottomCFrame.Position
                                break
                            end
                        end
                        local found = false
                        for _, rec in pairs(snap.Records) do if type(rec) == "table" and rec.Uid == uid then found = true end end
                        if not found then seenGone += 1 else seenGone = 0 end
                        if seenGone >= 4 then conn:Disconnect(); return false end
                    end
                end
            else promptCooldown = 0.5 end
            if pos then
                local now = os.clock()
                if lastPos and lastAt then
                    local d = (pos - lastPos) / math.max(now - lastAt, 1/240)
                    if d.Magnitude < 3000 then velocity = velocity:Lerp(d, 0.3) end
                end
                followPos = pos + Vector3.new(0, 3, 0)
                lastPos = pos; lastAt = now
                if (r.Position - followPos).Magnitude <= r354 and promptCooldown >= 0.1 then
                    local prompt = smartPromptNear(uid, pos - Vector3.new(0, 3, 0), 6)
                    if prompt then
                        pcall(function() prompt.HoldDuration = 0 end)
                        firePrompt(prompt)
                    else
                        task.spawn(carryFallback, uid)
                    end
                    promptCooldown = 0
                end
            end
            if otherHolds(uid) then
                -- keep chasing
            end
            r137.Heartbeat:Wait()
            t += 1/60
            promptCooldown += 1/60
        end
        conn:Disconnect()
        r315()
        return r247.Steal.Carrying == true
    end

    -- r366: fetch egg (fly + grab)
    local function insideBaseOr(pos) return r247.InsideBase(pos) end
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

    -- r371: deliver home
    local r371 = function(abortUid)
        -- anti guard
        local ag = r247.AntiGuard
        if ag.Enabled then
            local t = 0
            while not ag.Busy and t < 1 and not r295(abortUid) do t += r137.Heartbeat:Wait() end
            local had = ag.Busy
            local t2 = 0
            while ag.Busy and t2 < 30 and not r295(abortUid) do t2 += r137.Heartbeat:Wait() end
            if had then
                local t3, t4 = 0, 0
                while t3 < 10 and not r295(abortUid) do
                    local ragdolled = r319()
                    local held = (function() local ok, v = pcall(r247.Steal.HeldByMe); return ok and v == true end)()
                    local okToMove = not ragdolled
                    if okToMove and not held then break end
                    if okToMove and held and not ag.Busy then
                        t4 += r137.Heartbeat:Wait()
                        if t4 >= 0.3 then break end
                    else
                        t3 += r137.Heartbeat:Wait()
                        t4 = 0
                    end
                end
                local ok, v = pcall(r247.Steal.HeldByMe)
                if ok and not v then r247.Steal.Carrying = false end
                local home = r3_6()
                local heightTarget = home and r247.SafeCarry.Enabled and r247.SafeCarry.CarryStyle ~= "Walk" and r247.SafeCarry.Height > 0.5 and home.Y + r247.SafeCarry.Height or nil
                local t5 = 0
                while t5 < 0.8 and r247.Steal.Carrying and not r295(abortUid) do
                    local r = r247.Root()
                    if r and heightTarget then
                        local dy = heightTarget - r.Position.Y
                        local vy = t5 < 0.6 and math.clamp(dy / math.max(0.6 - t5, 0.1), -120, 120) or math.clamp(dy / 0.2, -30, 30)
                        pcall(function() r.AssemblyLinearVelocity = Vector3.new(0, vy, 0) end)
                    end
                    t5 += r137.Heartbeat:Wait()
                end
                local ok2, v2 = pcall(r247.Steal.HeldByMe)
                if ok2 and not v2 then r247.Steal.Carrying = false else r247.SafeCarry.SlowUntil = os.clock() + 2 end
            end
        end

        local t = 0
        while not r247.Steal.Carrying and t < r326 and not r295(abortUid) do t += r137.Heartbeat:Wait() end
        if not r247.Steal.Carrying then
            if not r365(abortUid) then return false end
        end

        if r247.SafeCarry.Enabled then
            -- full safe carry home
            local sc = r247.SafeCarry
            local home = r3_6()
            local r = r247.Root()
            if not home or not r then return false end
            r318()
            local sep = (workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS"))
            sep = sep and sep:FindFirstChild("Areas")
            sep = sep and sep:FindFirstChild("SeparationLine")
            local edgeX = (sep and sep:IsA("BasePart") and sep.Position.X or 552) - 7
            local ch = r232.Character
            local hm = ch and ch:FindFirstChildOfClass("Humanoid")
            if hm then hm.PlatformStand = false end
            local startT = os.clock()
            local speedNow = 0

            local function refreshPlan()
                local rr = r247.Root()
                if not rr then return end
                local plan, ok, base, max, guard = sc.Plan and sc.Plan(r247.Steal.CarryAreaId, (Vector3.new(rr.Position.X, 0, rr.Position.Z) - Vector3.new(home.X, 0, home.Z)).Magnitude + math.max(0, sc.Height) * 2, sc.Mult) or (r275 * sc.CarryScale), true, r275 * sc.CarryScale, r275 * sc.CarryScale * sc.SpeedRatio, 0
                speedNow = plan * sc.CarryScale
                sc.PlanOk = ok
                sc.FloorSpeed = sc.BeatGuard and math.min(guard + math.max(sc.GuardMargin, 1), max) or 0
            end
            refreshPlan()

            local lastSampleT = startT
            local stride = { Clock = 0, Factor = 1, Target = 1, NextShift = 0, Phase = math.random()*math.pi*2, Period = 2 + math.random()*2.5, PauseUntil = 0, Lane = 0 }
            local laneZ = (r.Position.Z) + stride.Lane

            while r247.Steal.Carrying and not r295(abortUid) do
                local rr = r247.Root()
                if not rr then return false end
                local now = os.clock()
                local dt = math.max(now - lastSampleT, 1/240)
                -- walking
                if hm and rr.Position.X > edgeX + 2 then
                    local target = Vector3.new(edgeX, rr.Position.Y, math.clamp(laneZ, -425, -300))
                    local delta = Vector3.new(target.X - rr.Position.X, 0, target.Z - rr.Position.Z)
                    if delta.Magnitude > 0.5 then
                        local sp = speedNow
                        local unit = delta.Unit
                        pcall(function()
                            rr.AssemblyLinearVelocity = Vector3.new(unit.X * sp, rr.AssemblyLinearVelocity.Y, unit.Z * sp)
                            if sc.RunAnimate then hm:Move(unit, false) end
                        end)
                    else
                        pcall(function() rr.AssemblyLinearVelocity = Vector3.new(0, rr.AssemblyLinearVelocity.Y, 0) end)
                    end
                else
                    local target = home
                    local delta = target - rr.Position
                    if delta.Magnitude < 2 then break end
                    local unit = delta.Unit
                    pcall(function()
                        rr.AssemblyLinearVelocity = Vector3.new(unit.X * speedNow, rr.AssemblyLinearVelocity.Y, unit.Z * speedNow)
                        if sc.RunAnimate and hm then hm:Move(Vector3.new(unit.X, 0, unit.Z), false) end
                    end)
                end
                lastSampleT = now
                r137.Heartbeat:Wait()
                if r247.Steal.LastDelivered >= startT then return true end
                if r247.Steal.LastFailed >= startT then return false end
                if not r247.Steal.Carrying then
                    -- dropped, re-grab once
                    if not r365(abortUid) then return false end
                    startT = os.clock()
                end
            end

            if r247.Steal.Carrying then
                task.wait(0.2)
                local st = r234.EggState
                if type(st) == "table" and type(st.DropFieldEgg) == "function" then
                    pcall(st.DropFieldEgg, "PlayerRequest")
                end
            end
            return r247.Steal.LastDelivered >= startT
        end

        -- non-safe path (fly home)
        local home = r3_6()
        local r = r247.Root()
        if not home or not r then return false end
        local flyY = math.max(r.Position.Y, home.Y) + r276
        local target1 = Vector3.new(r.Position.X + (home.X - r.Position.X) * 0.25, r.Position.Y + (flyY - r.Position.Y) * 0.7, r.Position.Z + (home.Z - r.Position.Z) * 0.25)
        if not r347(target1, abortUid, true, nil) then return false end
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

    -- r379: main steal runner
    local r374 = false
    local r375, r376, r378 = 0.5, 0.6, 0
    local r373 = function(egg)
        if not egg then return "None" end
        local scaled = string.format("%s  %.2fx  |  value %.2f  |  %s", tostring(egg.Category), tonumber(egg.Scale) or 0, egg.Value, tostring(egg.AreaId))
        if egg.State == "Dropped" then scaled = scaled .. "  |  dropped" end
        if egg.State == "Carried" then scaled = scaled .. "  |  carried" end
        return scaled
    end

    local r379 = function()
        local session = r291
        r247.Steal.Active = true
        r247.Steal.Carrying = r247.Steal.Carrying == true
        if not r247.Steal.Carrying then r247.Steal.CarryUid = nil end

        local list = r310(false, true)
        local target, carried, skipped = nil, nil, nil
        for _, e in ipairs(list) do
            if e.State == "Carried" then
                carried = carried or e
            else
                local reason = r247.SafeCarry.Unsafe(e)
                if reason then skipped = skipped or reason else target = e; break end
            end
        end
        r294 = target and target.Uid or nil
        r247.Steal.Wanted = target ~= nil

        if not target then
            r247.Steal.Active = false
            return false
        end

        if not r247.ClaimMovement("steal") then
            r247.Steal.Active = false
            return false
        end

        if r247.Treadmill.Riding or r247.OnBelt() then r247.ExitBelt() end
        r374 = true
        r247.HoldBelt()

        local function finish()
            r323()
            r247.Steal.Active = false
            r247.Steal.LastFinishedAt = os.clock()
            return true
        end

        local r = r247.Root()
        local pos = typeof(target.CFrame) == "CFrame" and target.CFrame.Position or nil
        if r and pos then
            local close = (pos - r.Position).Magnitude <= r354
            local sameArea = r232:GetAttribute("AreaId") == target.AreaId
            if close or sameArea then
                r366(target, session)
                if r336(target.Uid, session) then
                    r371(session)
                end
                return finish()
            end
        end

        -- approach
        local saved = r247.SafeCarry.Approach
        local approachRun = saved == "Run"
        if approachRun then
            -- Safecarry RunTo
            local ok = pcall(function()
                -- run to egg
                if not r347(pos + Vector3.new(0, 3, 0), session, nil, r277) then error("fail") end
                if not r337(target, session) and not r295(session) then r337(target, session) end
                if r247.Steal.Carrying then r371(session) end
            end)
            r323()
            r247.Steal.Active = false
            r247.Steal.LastFinishedAt = os.clock()
            return true
        end

        -- fallback: default approach (fetch + deliver)
        local session2 = session
        if r366(target, session2) then
            if r336(target.Uid, session2) then r371(session2) end
        end
        return finish()
    end

    local function worker()
        if not r247.Toggle(r16_2, false) then return false end
        local waitTime, kind, refTime = r299()
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
            if r374 then r374 = false; r247.ReleaseBelt() end
            if not ok then r323(); r247.Steal.Active = false end
            r247._stealRunning = false
            r247.ReleaseMovement("steal")
            r378 = os.clock() + r376
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

    -- target areas
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

    r26:CreateDropdown({
        Name = "Travel Method",
        Options = { "Tween", "Teleport" },
        Default = "Tween",
        SubOf = r247.SafeCarry.Handle,
        Callback = function(v)
            if v == "Tween" then r247.SafeCarry.Approach = "Run"
            elseif v == "Teleport" then r247.SafeCarry.Approach = "Ragdoll Jump" end
        end,
    })

    r26:CreateSlider({
        Name = "Carry Speed",
        Note = "Lower it if you get Delivery failed",
        Min = 80, Max = 120, Default = 100, Increment = 1, Unit = "%",
        SubOf = r247.SafeCarry.Handle,
        Callback = function(v) r247.SafeCarry.CarryScale = math.clamp(tonumber(v) or 100, 80, 120) / 100 end,
    })

    r26:CreateSlider({
        Name = "Egg Tween Speed",
        Min = 50, Max = 300, Default = 115, Increment = 5, Unit = "%",
        SubOf = r247.SafeCarry.Handle,
        Callback = function(v) r247.SafeCarry.RunSpeed = math.clamp(tonumber(v) or 115, 50, 300) / 100 end,
    })

    r244.Add(worker)

    r247.Steal.HeldByMe = function()
        local uid = r247.Steal.CarryUid
        local c = r232.Character
        if type(uid) ~= "string" or not c then return false end
        local m = workspace:FindFirstChild(uid)
        if not m then return false end
        for _, j in ipairs(m:GetDescendants()) do
            if j:IsA("WeldConstraint") or j:IsA("JointInstance") then
                local ok, p0, p1 = pcall(function() return j.Part0, j.Part1 end)
                if ok and ((p0 and p0:IsDescendantOf(c)) or (p1 and p1:IsDescendantOf(c))) then return true end
            end
        end
        return false
    end

    -- carry state tracking
    do
        local t = 0
        local hb = r137.Heartbeat:Connect(function(dt)
            t += dt
            if t < 0.2 then return end
            t = 0
            local s = r247.Steal
            if not s.Carrying then
                if s.GuessedDrop then
                    local ok, v = pcall(s.HeldByMe)
                    if ok and v then s.GuessedDrop = false; s.Carrying = true; s.HeldSeenAt = os.clock() end
                end
                return
            end
            local ok, v = pcall(s.HeldByMe)
            if not ok or v then s.HeldSeenAt = os.clock(); return end
            if os.clock() - (s.HeldSeenAt or 0) > 0.8 then
                s.Carrying = false
                s.GuessedDrop = true
                s.LastFinishedAt = os.clock()
                r244.Wake()
            end
        end)
        r240(function() hb:Disconnect() end)
    end

    do
        local st = r234.EggState
        local ev = type(st) == "table" and st.CarryChanged or nil
        if type(ev) == "table" and type(ev.Connect) == "function" then
            local ok, conn = pcall(ev.Connect, ev, function(info)
                local carrying = type(info) == "table" and info.IsCarrying == true
                if r247.Steal.Carrying and not carrying then r247.Steal.LastFinishedAt = os.clock() end
                r247.Steal.GuessedDrop = false
                if carrying then r247.Steal.HeldSeenAt = os.clock() end
                if carrying and type(info.Uid) == "string" then
                    r247.Steal.CarryUid = info.Uid
                    r247.Steal.CarryAreaId = info.AreaId
                    local mult = tonumber(info.SpeedMultiplier)
                    if mult and mult > 0 then
                        r247.SafeCarry.Mult = mult
                        r247.SafeCarry.Category = info.AssetCategory
                        if info.AssetCategory ~= nil then
                            local k = tostring(info.AssetCategory)
                            r247.SafeCarry.Seen[k] = math.min(r247.SafeCarry.Seen[k] or mult, mult)
                        end
                    end
                end
                r247.Steal.Carrying = carrying
                r244.Wake()
            end)
            if ok and conn then r240(function() pcall(function() conn:Disconnect() end) end) end
        end
    end

    do
        local ok1, verdict = pcall(function() return r182:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict") end)
        local ok2, alerts = pcall(function() return r182:FindFirstChild("RE/Alerts/Raise") end)
        if ok1 and verdict and verdict:IsA("RemoteEvent") then
            local conn = verdict.OnClientEvent:Connect(function() r247.SafeCarry.LastDelivered = os.clock() end)
            r240(function() conn:Disconnect() end)
        end
        if ok2 and alerts and alerts:IsA("RemoteEvent") then
            local conn = alerts.OnClientEvent:Connect(function(msg)
                if type(msg) == "table" and type(msg.Text) == "string" and string.find(msg.Text, "Delivery failed", 1, true) then
                    r247.SafeCarry.LastFailed = os.clock()
                end
            end)
            r240(function() conn:Disconnect() end)
        end
    end

    r26:CreateLabel({ Name = "Anti Guard Title", Text = "Anti Guard" })

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
            if r247.AntiGuard.Render then r247.UiDefer(function() pcall(r247.AntiGuard.Render, false) end) end
        end)
    end)

    r247._stealSection = r26
end

-- ============= ANTI GUARD PANEL =============
do
    local r164 = game:GetService("GuiService")
    local r165 = game:GetService("StarterGui")
    local r1550 = r247.AntiGuard
    local r163_4 = game:GetService("TweenService")

    local r1551 = {
        Target = "line", LineOffset = 8, Height = 45, OffsetX = -90, OffsetZ = -35,
        Jitter = 0, Point = false, Disguise = true, Limp = true, Facing = "Zero",
        Freeze = false, StartAt = 0,
        Steps = { { At = 0.1, To = "home" }, { At = 0.33, To = "home" }, { At = 0.56, To = "home" }, { At = 0.75, To = "start" } },
        ReleaseAt = 0.8, WeldScanGap = 0.03, BusyLimit = 2.5,
    }

    local function presetSteps(count, start, step, endAt, releaseAt, busyLimit)
        local steps = {}
        for i = 1, count do steps[#steps+1] = { At = start + step * (i-1), To = "home" } end
        steps[#steps+1] = { At = endAt, To = "start" }
        return {
            Target = "home", LineOffset = 8, Height = 0, OffsetX = 0, OffsetZ = 0,
            Jitter = 0, Point = false, Disguise = true, Limp = false, Facing = "Zero",
            Freeze = true, StartAt = 0, StartRandom = 0, HopRandom = 0.085, HoldRandom = 0.395,
            Steps = steps, ReleaseAt = releaseAt, WeldScanGap = 0.03, BusyLimit = busyLimit,
        }
    end

    local r1552 = { LightDark = r1551, Default = presetSteps(25, 0, 0.05, 1.27, 1.52, 2.5) }
    pcall(function() getgenv().OxioAntiGuard = r1552 end)

    -- panel colors: hitam + putih
    local r1554 = {
        Card = Color3.fromRGB(15, 15, 19),
        CardTop = Color3.fromRGB(24, 22, 28),
        Stroke = Color3.fromRGB(48, 46, 56),
        Text = Color3.fromRGB(240, 238, 244),
        AccentA = Color3.fromRGB(255, 255, 255),
        AccentB = Color3.fromRGB(220, 220, 230),
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

    local r1556, r1557, r1558 = 52, true, {}
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

    -- ============== ANTI GUARD CORE ==============
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
            local s = custom.Default
            if type(s) == "table" then return s end
        end
        return r1552.Default
    end

    local function randJitter(amount)
        if amount <= 0 then return 0 end
        return (math.random() * 2 - 1) * amount
    end

    local function buildSteps(cfg)
        local steps = type(cfg.Steps) == "table" and cfg.Steps or {}
        local release = tonumber(cfg.ReleaseAt) or 0
        local startAt = math.max(tonumber(cfg.StartAt) or 0, 0)
        local startR = math.max(tonumber(cfg.StartRandom) or 0, 0)
        local hopR = math.max(tonumber(cfg.HopRandom) or 0, 0)
        local holdR = math.max(tonumber(cfg.HoldRandom) or 0, 0)
        if startR <= 0 and hopR <= 0 and holdR <= 0 then return steps, release, startAt end
        local t0 = math.max(startAt + randJitter(startR), 0)
        local out = {}
        local cursor = 0
        local acc = 0
        for i, s in ipairs(steps) do
            if type(s) ~= "table" then break end
            local at = math.max(tonumber(s.At) or 0, 0)
            acc = math.max(acc + math.max(at - cursor, 0) + randJitter(s.To == "start" and holdR or hopR), t0)
            out[i] = { At = acc, To = s.To, Glide = s.Glide }
            cursor = at
        end
        return out, acc + math.max(release - cursor, 0), t0
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
            r1587(); reset()
            r11_47(r1554.Bad, 1.6)
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

    -- ============== PANEL UI ==============
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
        BorderSizePixel = 0,
        Active = true,
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

    local function flash(color, hold)
        r1559.FlashRequest = { Color = color, Hold = hold }
    end
    local r11_47 = flash

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

    -- Drag overlay
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
        dragging = true
        dragged = false
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPos = frame.Position
        dragInput = input

        input.Changed:Connect(function()
            if input.UserInputState ~= Enum.UserInputState.End then return end
            dragging = false
            dragInput = nil
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

    -- bottom auto-position watcher
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

    local function reposition(force)
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
        if userPos and not force then frame.Position = userPos; return end

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

    -- Carry signal from game
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
        if busy and os.clock() - r1550.BusySince > math.max(tonumber(r1551.BusyLimit) or 2.5, (tonumber(r1551.ReleaseAt) or 0) + 1) then
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

task.defer(function()
    for _ = 1, 3 do r137:Heartbeat:Wait() end
end)

print("[Oxio] Loaded: Auto Steal + Anti Guard")