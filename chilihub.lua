
local r231, r179, r180, r183, r136, r137, r181, r138, r139, r232
local r182, r233, r234, r235, r238, r240, r241, r192, r243, r244
local r247, r263, r7_4, r274, r4_5, r22_2, r951, r1_43, r14_12, r16_7
local r961

do
	local r145, r146, r184, r190, r245, r191, r264

	do
		r231 = function(s4)
			local s2 = typeof(getgenv) == "function" and getgenv() or _G

			if type(s2.ChilliDebugPrint) == "function" then
				pcall(s2.ChilliDebugPrint, s4)
			end
		end

		task.spawn(pcall, function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/DiscordLink"))()
		end)

		local function r1()
			local s14 = nil

			local function s16()
				if type(s14) == "string" and #s14 > 0 then
					return s14
				end
				s14 = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli%20Library")
				return s14
			end

			local function s17()
				local t2_1 = (typeof(getgenv) == "function" and getgenv() or _G).ChilliHubSaeCleanup

				if type(t2_1) == "function" then
					pcall(t2_1)
				end

				local t7 = { game:GetService("CoreGui") }

				if typeof(gethui) == "function" then
					local t11, t12_1 = pcall(gethui)

					if t11 and typeof(t12_1) == "Instance" then
						table.insert(t7, t12_1)
					end
				end

				local t16 = {
					Settings = true,
					ChilliLeftCenter = true,
					ChilliLibrarySettings = true,
					ChilliLibraryLauncher = true,
				}

				local t18 = 0

				for _, t4 in ipairs(t7) do
					for _, t7_1 in ipairs(t4:GetChildren()) do
						if t7_1:IsA("ScreenGui") and (t7_1:GetAttribute("ChilliLibraryOwned") == true or t16[t7_1.Name]) then
							pcall(function()
								t7_1:Destroy()
							end)

							t18 += 1
						end
					end
				end

				if t18 > 0 then
					r231("cleared " .. t18 .. " leftover Chilli UI screens")
				end
			end

			local function s6()
				local t6 = s16()
				local t5, t6_1 = loadstring(t6)
				assert(t5, t6_1)
				local t9 = t5()
				assert(type(t9) == "function", "Chilli Library bootstrap is invalid.")
				local t11 = table.create(45)
				local t14 = 1

				for t6_2 = 1, 90, 2 do
					t11[t14] = string.char(bit32.bxor(tonumber(string.sub("306908100841206d474f00185f26635b2101387507010810127d7d477a473b6f435a0916573165562900226c00", t6_2, t6_2 + 1), 16), string.byte("s9K!2vQ#", (t14 - 1) % 8 + 1)))
					t14 += 1
				end

				return t9(table.concat(t11))
			end

			local s9 = "unknown"

			for s4 = 1, 6 do
				task.wait()
				pcall(s17)
				local s2, s3 = pcall(s6)
				if s2 and type(s3) == "table" then
					return s3
				end
				s9 = tostring(s3)

				if type(s9) == "string" and string.find(s9, "HttpGet", 1, true) then
					s14 = nil
				end

				r231("library load attempt " .. s4 .. " failed: " .. s9)
				task.wait(1 + s4 * 0.5)
			end

			error("Chilli Library failed to load: " .. s9, 0)
		end

		r179 = r1()
		assert(type(r179) == "table" and type(r179.CreateWindow) == "function" and type(r179.Finalize) == "function", "Chilli Library returned an invalid API.")

		r179.ManualQuickDefaults = {
			PinnedFeatures = { "Player > Movement > Speed Boost", "Player > Movement > Boost Speed" },
			Keybinds = { ["Player > Movement > Speed Boost"] = "Q" },
			PinGroups = {},
			LeftCenterHidden = true,
		}

		r180 = r179:CreateWindow({ Name = "Chilli Hub - Steal An Egg", DefaultTab = "Farm" })
		r183 = r180:GetDefaultTab()
		r136 = game:GetService("Players")
		r137 = game:GetService("RunService")
		r181 = game:GetService("ReplicatedStorage")
		r138 = game:GetService("CoreGui")
		r139 = game:GetService("UserInputService")
		r145 = game:GetService("CollectionService")
		game:GetService("LocalizationService")
		r146 = game:GetService("ProximityPromptService")
		r232 = r136.LocalPlayer
		r182 = r181:WaitForChild("Packages"):WaitForChild("Networking")

		r233 = function(s35)
			local s33, s34 = pcall(function()
				return require(s35())
			end)

			return s33 and s34 or nil
		end

		r234 = {
			EggState = r233(function()
				return r181.Client.EggState
			end),
			AreaEggs = r233(function()
				return r181.Shared.Types.AreaEggs
			end),
			ToolGameplayGuard = r233(function()
				return r181.Client.ToolGameplayGuard
			end),
			Assets = r233(function()
				return r181.Data.Assets
			end),
			Guards = r233(function()
				return r181.Data.Guards
			end),
			EggRecords = r233(function()
				return r181.Shared.Util.EggRecords
			end),
			Mutations = r233(function()
				return r181.Shared.Modules.Mutations
			end),
			Save = r233(function()
				return r181.Shared.Save
			end),
			FuseKernel = r233(function()
				return r181.Shared.Util.FuseKernel
			end),
			AreaEggCycle = r233(function()
				return r181.Shared.Util.AreaEggCycle
			end),
			AreaEggResetWall = r233(function()
				return r181.Client.AreaEggResetWall
			end),
			AreaEggResetCycle = r233(function()
				return r181.Data.AreaEggResetCycle
			end),
			Gears = r233(function()
				return r181.Data.Gears
			end),
			Areas = r233(function()
				return r181.Data.Areas
			end),
			LimitedEgg = r233(function()
				return r181.Data.LimitedEgg
			end),
			BrainrotEgg = r233(function()
				return r181.Data.BrainrotEgg
			end),
			MonsterEgg = r233(function()
				return r181.Data.MonsterEgg
			end),
		}

		local r4 = r234.Save

		if type(r4) == "table" and (type(r4.Get) ~= "function" or type(r4.FieldSignal) ~= "function") then
			r234.Save = setmetatable({
				Get = type(r4.Get) == "function" and r4.Get or r4.Peek,
				FieldSignal = type(r4.FieldSignal) == "function" and r4.FieldSignal or r4.Watch,
			}, { __index = r4 })
		end

		local function r1_4()
			if typeof(gethui) == "function" then
				local s4, s5 = pcall(gethui)
				if s4 and typeof(s5) == "Instance" then
					return s5
				end
			end

			return r138
		end

		r235 = r1_4()

		do
			local r236 = Random.new()
			local r237 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

			r238 = function()
				local s3 = r236:NextInteger(12, 20)
				local s9 = table.create(s3)

				for s13 = 1, s3 do
					local s4 = r236:NextInteger(1, #r237)
					s9[s13] = string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", s4, s4)
				end

				return table.concat(s9)
			end
		end

		do
			local r239 = {}

			r240 = function(s23)
				table.insert(r239, s23)
			end

			r241 = {}

			r192 = function(arg1, s32)
				local s7 = 1000
				local s8 = 3
				local s9 = 12

				local function s11(t13)
					if t13 <= 0 then
						return 0
					end
					local t4 = 10 ^ (math.floor(math.log10(t13)) - 2)
					return math.floor(t13 / t4 + 0.5) * t4
				end

				local function s12(t12)
					local t7_1 = math.clamp(tonumber(t12) or 0, 0, 1000)
					if t7_1 <= 0 then
						return 0
					end
					return s11(10 ^ (s8 + (s9 - s8) * t7_1 / s7))
				end

				local function s13(t28)
					local t3 = tonumber(t28) or 0
					if t3 <= 0 then
						return 0
					end
					return math.clamp(math.floor((math.log10(t3) - s8) / (s9 - s8) * s7 * 100 + 0.5) / 100, 0, 1000)
				end

				local function s14(t36)
					local t34_1 = string.format(t36 >= 100 and "%.0f" or t36 >= 10 and "%.1f" or "%.2f", t36)

					if string.find(t34_1, ".", 1, true) then
						t34_1 = string.gsub(string.gsub(t34_1, "0+$", ""), "%.$", "")
					end

					return t34_1
				end

				local function s3(t36)
					local t1 = s12(t36)
					if t1 <= 0 then
						return "Off"
					end

					if t1 < 1000000 then
						return s14(t1 / 1000) .. " K/s"
					end

					if t1 < 1e9 then
						return s14(t1 / 1000000) .. " M/s"
					end
					return s14(t1 / 1e9) .. " B/s"
				end

				local function s15(t20)
					local t1 = s12(t20)
					if t1 <= 0 then
						return "0"
					end

					if t1 < 1000000 then
						return s14(t1 / 1000) .. "k"
					end
					return (string.gsub(string.gsub(string.format("%.3f", t1 / 1000000), "0+$", ""), "%.$", ""))
				end

				local s17 = { k = 1000, m = 1000000, b = 1e9, t = 1e12 }

				local function s4(arg1)
					local t1_1 = string.gsub(string.lower(string.gsub(tostring(arg1 or ""), "[%s,/]", "")), "s$", "")
					if t1_1 == "" or t1_1 == "off" then
						return 0
					end
					local t30_1, t31 = string.match(t1_1, "^([%d%.]+)([kmbt]?)$")
					local t1_2 = tonumber(t30_1)
					if not t1_2 then
						return nil
					end
					return s13(t1_2 * (s17[t31] or 1000000))
				end

				local s29 = arg1:CreateSlider({
					Name = s32.Name,
					Note = s32.Note,
					SubOf = s32.SubOf,
					Min = 0,
					Max = s7,
					Default = s13(s32.Default or 0),
					AllowDecimals = true,
					Increment = 0.01,
					ValueFormat = s3,
					ValueParse = s4,
					Callback = function(t16)
						if type(s32.OnRaw) == "function" then
							s32.OnRaw(s12(t16))
						end
					end,
				})

				local s34 = type(s29) == "table" and rawget(s29, "Instance") or nil

				if typeof(s34) == "Instance" then
					for _, s4_1 in ipairs(s34:GetDescendants()) do
						if s4_1:IsA("TextBox") then
							local s33 = s4_1.Focused:Connect(function()
								task.defer(function()
									if s4_1:IsFocused() then
										local u2, u3 = pcall(s29.Get, s29)
										s4_1.Text = s15(u2 and u3 or 0)
										s4_1.CursorPosition = #s4_1.Text + 1
										s4_1.SelectionStart = 1
									end
								end)
							end)

							r240(function()
								pcall(function()
									s33:Disconnect()
								end)
							end)
						end
					end
				end

				if type(s32.Legacy) == "string" and type(s32.SectionName) == "string" then
					table.insert(r241, { Handle = s29, Name = s32.Name, Legacy = s32.Legacy, Section = s32.SectionName, StepOf = s13 })
				end

				return s29
			end

			local r242 = "All"

			r243 = function(s9)
				if type(s9) ~= "table" then
					return s9
				end
				local s5 = rawget(s9, "Instance")
				if typeof(s5) ~= "Instance" then
					return s9
				end
				local s16 = false

				local function s18(t25)
					if s16 then
						return
					end

					if t25.Text == "None" then
						s16 = true
						t25.Text = r242
						s16 = false
					end
				end

				local function s12(t35)
					if not t35:IsA("TextLabel") or t35.Name ~= "Value" then
						return
					end
					s18(t35)

					local t31 = t35:GetPropertyChangedSignal("Text"):Connect(function()
						s18(t35)
					end)

					r240(function()
						pcall(function()
							t31:Disconnect()
						end)
					end)
				end

				for _, s3 in ipairs(s5:GetDescendants()) do
					s12(s3)
				end

				local s10 = s5.DescendantAdded:Connect(s12)

				r240(function()
					pcall(function()
						s10:Disconnect()
					end)
				end)

				return s9
			end

			local r1_5 = typeof(getgenv) == "function" and getgenv() or _G
			local r2_2 = r1_5.ChilliHubSaeCleanup

			if type(r2_2) == "function" then
				pcall(r2_2)
			end

			r1_5.ChilliHubSaeCleanup = function()
				for s6 = #r239, 1, -1 do
					pcall(r239[s6])
				end

				table.clear(r239)
			end
		end

		do
			local r1_6 = 0
			local r2_3 = nil

			r2_3 = function(s13, arg2)
				local s14 = arg2 or 0

				if type(s13) == "table" then
					if s14 > 3 then
						return
					end
					local s6 = 0

					for s3, s4 in pairs(s13) do
						s6 += 1

						if not (s6 > 20) then
							r2_3(s3, s14 + 1)
							r2_3(s4, s14 + 1)
							continue
						end

						break
					end
				elseif typeof(s13) == "Instance" then
					pcall(s13.GetFullName, s13)
				else
					r1_6 += #tostring(s13)
				end
			end

			local r3 = {}

			local function r4_1(arg1)
				r3[#r3 + 1] = arg1
			end

			local function r5()
				for _, s6 in ipairs(r3) do
					pcall(function()
						s6:Disconnect()
					end)
				end

				table.clear(r3)
			end

			local function r6_3()
				r5()

				for _, s8 in ipairs({
					"RE/GearSatchel/Lost",
					"RE/GearSatchel/Gained",
					"RE/RigSync/ProbeSatchel",
					"RE/RigSync/SeedSatchel",
					"RE/RigSync/CorrectionBegan",
					"RE/RigSync/Refresh",
					"RE/ToolTrigger/Trigger",
					"RE/BatSwing/Trigger",
				}) do
					local s9 = r182:FindFirstChild(s8)

					if s9 and s9:IsA("RemoteEvent") then
						r4_1(s9.OnClientEvent:Connect(function(...)
							r2_3({ ... })
						end))
					end
				end

				local function s7_1(t17)
					if not t17 then
						return
					end

					r4_1(t17.ChildRemoved:Connect(function(u7)
						if u7:IsA("Tool") then
							r2_3({ u7.Name, u7.Parent })
						end
					end))

					r4_1(t17.ChildAdded:Connect(function(u17)
						if u17:IsA("Tool") then
							r2_3({ u17.Name })
						end
					end))
				end

				s7_1(r232:FindFirstChildOfClass("Backpack"))

				r4_1(r232.ChildAdded:Connect(function(t14)
					if t14:IsA("Backpack") then
						s7_1(t14)
					end
				end))

				task.spawn(function()
					pcall(function()
						local u4 = r234.Save.Get()
						r2_3({ u4.GearInventory, u4.Inventory }, 2)
					end)

					if type(getgc) == "function" then
						pcall(function()
							for _, u4 in ipairs(getgc(false)) do
								if type(u4) == "function" and islclosure(u4) then
									pcall(debug.info, u4, "n")
								end
							end
						end)
					end
				end)
			end
			;(typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper = r6_3
			task.defer(r6_3)
			r240(r5)
		end

		do
			local r2_4 = 0.35
			local r3_1 = 5
			local r5_1 = {}
			local r6_4 = true

			r244 = {
				Add = function(arg1)
					local s2 = { Run = arg1, Gap = r2_4, Idle = r3_1, Repeat = false, Hold = 0 }
					table.insert(r5_1, s2)
					return s2
				end,
				Wake = function()
					r6_4 = true
				end,
				Backoff = function(s2, s3)
					if s2 then
						s2.Hold = tonumber(s3) or 6
					end
				end,
			}

			local r147 = r137.Heartbeat:Connect(function(s25)
				local s5 = r6_4
				r6_4 = false

				for _, s3 in ipairs(r5_1) do
					s3.Gap = s3.Gap + s25
					s3.Idle = s3.Idle + s25

					if s3.Hold > 0 then
						s3.Hold = s3.Hold - s25
					elseif s3.Gap >= r2_4 and (s5 or s3.Repeat or s3.Idle >= r3_1) then
						s3.Gap = 0
						s3.Idle = 0
						local s22, s23 = pcall(s3.Run, s3)
						s3.Repeat = s22 and s23 == true
					end
				end
			end)

			r240(function()
				r147:Disconnect()
			end)
		end

		r184 = r183:CreateSection({ Name = "Dr Scramble Mech (New)", Expanded = false })
		local r26
		r26 = r183:CreateSection({ Name = "Auto Steal", Expanded = true })
		local r185
		r185 = r183:CreateSection({ Name = "Auto Place Egg", Expanded = false })
		local r186
		r186 = r183:CreateSection({ Name = "Auto Treadmill", Expanded = false })
		local r187
		r187 = r183:CreateSection({ Name = "Auto Hatch & Equip", Expanded = false })
		local r188
		r188 = r183:CreateSection({ Name = "Auto Sell", Expanded = false })
		local r189
		r189 = r183:CreateSection({ Name = "Auto Fuse Machine", Expanded = false })
		r190 = r183:CreateSection({ Name = "Auto Favorite", Expanded = false })
		r245 = { Paused = false }

		do
			local r2_5 = 0.5
			local r3_2 = nil
			local r4_2 = nil
			local r5_2 = {}
			local r6_5 = false
			local r7_3 = 0

			local function r8()
				for s7 = #r5_2, 1, -1 do
					local s6 = r5_2[s7]

					if s6 and s6.Connected then
						s6:Disconnect()
					end

					r5_2[s7] = nil
				end
			end

			local function r9()
				r8()
				local s3 = r3_2
				local s5 = r4_2
				r3_2 = nil
				r4_2 = nil
				if not s3 or not s3.Parent or not s5 then
					return
				end

				pcall(function()
					s3.BreakJointsOnDeath = s5.BreakJointsOnDeath
					s3.RequiresNeck = s5.RequiresNeck
					s3:SetStateEnabled(Enum.HumanoidStateType.Dead, s5.DeadEnabled)
				end)
			end

			local function r10(s27)
				if not s27 or not s27.Parent then
					return false
				end

				return pcall(function()
					s27.BreakJointsOnDeath = false
					s27.RequiresNeck = false
					s27:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				end) and s27.BreakJointsOnDeath == false and s27.RequiresNeck == false and s27:GetStateEnabled(Enum.HumanoidStateType.Dead) == false
			end

			local function r11(s20)
				if r245.Paused or s20 ~= r3_2 or not s20 or not s20.Parent or r6_5 then
					return false
				end
				local s2_2 = s20.MaxHealth
				if s2_2 <= 0 then
					return false
				end

				if s2_2 == math.huge or s20.Health >= s2_2 then
					return true
				end
				r6_5 = true

				local s4 = pcall(function()
					s20.Health = s2_2
				end)

				r6_5 = false
				return s4 and s20.Health >= s2_2
			end

			local function r12(s27)
				if s27 == r3_2 and s27 and s27.Parent then
					return true
				end
				r9()
				if not s27 or not s27:IsA("Humanoid") or not s27.Parent then
					return false
				end
				r3_2 = s27

				r4_2 = {
					BreakJointsOnDeath = s27.BreakJointsOnDeath,
					RequiresNeck = s27.RequiresNeck,
					DeadEnabled = s27:GetStateEnabled(Enum.HumanoidStateType.Dead),
				}

				if not r10(s27) then
					r9()
					return false
				end
				r11(s27)

				r5_2[#r5_2 + 1] = s27.HealthChanged:Connect(function()
					r11(s27)
				end)

				r5_2[#r5_2 + 1] = s27:GetPropertyChangedSignal("MaxHealth"):Connect(function()
					r11(s27)
				end)

				r5_2[#r5_2 + 1] = s27.StateChanged:Connect(function(arg1, arg2)
					if arg2 == Enum.HumanoidStateType.Dead and not r245.Paused then
						r10(s27)
						r11(s27)
					end
				end)

				r7_3 = os.clock()
				return true
			end

			local function r246()
				local s11 = r232.Character
				return s11 and s11:FindFirstChildOfClass("Humanoid") or nil
			end

			local r147_1 = r232.CharacterAdded:Connect(function()
				task.defer(function()
					r12(r246())
				end)
			end)

			local r148 = r137.Heartbeat:Connect(function()
				local s3 = os.clock()
				if r245.Paused or s3 - r7_3 < r2_5 then
					return
				end
				r7_3 = s3
				local s3_1 = r246()
				if s3_1 ~= r3_2 then
					r12(s3_1)
					return
				end

				if s3_1 then
					r10(s3_1)
					r11(s3_1)
				end
			end)

			task.defer(function()
				r12(r246())
			end)

			r240(function()
				if r147_1 then
					r147_1:Disconnect()
				end

				if r148 then
					r148:Disconnect()
				end

				r9()
			end)
		end

		local r1_7 = { "bat", "katana", "axe", "staff", "club", "hammer", "sword", "blade" }

		r247 = {
			Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
			SafeCarry = {
				Enabled = true,
				SkipUnsafe = false,
				WaitGuard = false,
				SameSpeedBigEggs = false,
				Blocked = {},
				StretchSeconds = 6,
				BeatGuard = false,
				SlowUntil = 0,
				SlowFactor = 0.3,
				CarryScale = 1,
				EasyRatio = 1.3,
				LastSkip = nil,
				Category = nil,
				PlanOk = true,
				LightMult = 0.96,
				Height = 70,
				ClimbShare = 0.5,
				Approach = "Run",
				RunSpeed = 1.15,
				RunWait = 0,
				RunAnimate = true,
				RunHeight = 50,
				StraightRun = true,
				RunStyle = "Velocity",
				CarryStyle = "Velocity",
				SpeedJitter = 0.08,
				Wobble = 0,
				LaneOffset = 0,
				JumpsPerMinute = 0,
				PausesPerMinute = 0,
				ReactMin = 0.2,
				ReactMax = 0.6,
				CarryReact = 0,
				SpeedRatio = 1.5,
				ExcessSeconds = 5.5,
				GuardMargin = 4,
				GuardRatio = 1.06,
				MinRatio = 1.1,
				BaseWait = 6.5,
				FreeJump = 1500,
				WaitRate = 0.9,
				RecoverTries = math.huge,
				GuessMult = 0.93,
				CarryRatio = 0.9,
				Mult = 1,
				Seen = {},
				JumpDistance = 0,
				JumpAt = 0,
				LastDelivered = 0,
				LastFailed = 0,
				Handle = nil,
			},
			Movement = {
				Owner = nil,
				PlaceWanted = false,
				StealFirst = false,
				MutationWanted = false,
				FracturedWanted = false,
			},
			AntiGuard = {
				Enabled = false,
				Busy = false,
				BusySince = 0,
				HitArms = 0,
				Handle = nil,
				Render = nil,
			},
			IsBatTool = function(s10)
				if typeof(s10) ~= "Instance" or not s10:IsA("Tool") then
					return false
				end

				if s10:GetAttribute("IsBat") == true then
					return true
				end
				local s11 = s10:GetAttribute("GearName")

				if type(s11) == "string" then
					local s2 = r234.Gears
					local s3_1 = type(s2) == "table" and s2.Directory or nil
					local s2_2 = type(s3_1) == "table" and s3_1[s11] or nil
					return type(s2_2) == "table" and s2_2.BatControllerData ~= nil
				end

				if s10:GetAttribute("ItemType") ~= nil then
					return false
				end
				local s10_1 = string.lower(s10.Name)

				for _, s4_1 in ipairs(r1_7) do
					if string.find(s10_1, s4_1, 1, true) then
						return true
					end
				end

				return false
			end,
			FindBat = function()
				local s12 = r232.Character
				local s8 = s12 and s12:FindFirstChildWhichIsA("Tool")
				if r247.IsBatTool(s8) then
					return s8
				end
				local s8_1 = r232:FindFirstChildOfClass("Backpack")

				if s8_1 then
					for _, s7 in ipairs(s8_1:GetChildren()) do
						if r247.IsBatTool(s7) then
							return s7
						end
					end
				end

				if s12 then
					for _, s10 in ipairs(s12:GetChildren()) do
						if r247.IsBatTool(s10) then
							return s10
						end
					end
				end

				return nil
			end,
			IsNight = function()
				local s4 = r234.AreaEggCycle
				if type(s4) ~= "table" or type(s4.IsNightPhase) ~= "function" then
					return false
				end
				local s4_1, s5_1 = pcall(s4.IsNightPhase, workspace:GetServerTimeNow())
				return s4_1 and s5_1 == true
			end,
			WallSealed = function()
				local s3 = r234.AreaEggResetWall
				if type(s3) ~= "table" or type(s3.IsSealed) ~= "function" then
					return false
				end
				local s2_1, s3_1 = pcall(s3.IsSealed)
				return s2_1 and s3_1 == true
			end,
			WallOpenDelay = function()
				local s2 = r234.AreaEggResetCycle
				if type(s2) ~= "table" then
					return 5
				end
				return (tonumber(s2.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(s2.WallCountdownSeconds) or 3)
			end,
			ClaimMovement = function(s2)
				local s4 = r247.Movement
				local s6 = s4.Owner == nil or s4.Owner == s2 or s4.Owner == "treadmill" and s2 ~= "treadmill"
				local s8

				if s6 then
					s8 = s6
				else
					s8 = s4.Owner == "scramble" and s2 == "steal"
				end

				if s8 then
					s4.Owner = s2
					return true
				end
				return false
			end,
			ReleaseMovement = function(arg1)
				if r247.Movement.Owner == arg1 then
					r247.Movement.Owner = nil
				end
			end,
		}

		do
			local r2_6 = { "Humanoid Swap", "Disable Monitor" }
			r247.ShieldMethods = r2_6
			local r9_1 = r2_6[1]
			local r10_1 = {}
			local r11_1 = {}
			local r12_1 = nil
			local r13 = 0
			local r14 = { Original = nil, Clone = nil, Links = {} }
			local r15 = nil
			local r16 = {}

			local function r17()
				for _, s6 in ipairs(r16) do
					task.defer(function()
						pcall(s6)
					end)
				end
			end

			r247.OnHumanoidChanged = function(s2)
				table.insert(r16, s2)
				local s5

				s5 = {
					Connected = true,
					Disconnect = function()
						s5.Connected = false
						local t6 = table.find(r16, s2)

						if t6 then
							table.remove(r16, t6)
						end
					end,
				}

				return s5
			end

			local function r18(s11)
				pcall(function()
					local t9 = r232:FindFirstChild("PlayerScripts")
					local t11 = t9 and t9:FindFirstChild("PlayerModule")

					if t11 then
						local t2 = require(t11):GetControls()

						if type(t2) == "table" then
							t2.humanoid = s11
						end
					end
				end)
			end

			local function r248(s12)
				local s4 = s12 and s12:FindFirstChild("Animate")

				if s4 and s4:IsA("LocalScript") then
					task.spawn(function()
						s4.Enabled = false
						task.wait()
						s4.Enabled = true
					end)
				end
			end

			local function r249()
				for _, s6 in ipairs(r14.Links) do
					pcall(function()
						s6:Disconnect()
					end)
				end

				table.clear(r14.Links)
			end

			r247.UndoSwap = function()
				r249()
				local s2 = r232.Character
				local s4 = r14.Original
				local s5 = r14.Clone
				local s10 = r14
				r14.Original = nil
				s10.Clone = nil

				if s4 and s5 and s2 and s4.Parent == nil and s5.Parent == s2 then
					s4.Parent = s2
					workspace.CurrentCamera.CameraSubject = s4
					r18(s4)

					pcall(function()
						s5:Destroy()
					end)

					r248(s2)
					r17()
				end
			end

			local r250 = {
				[Enum.HumanoidStateType.Running] = true,
				[Enum.HumanoidStateType.RunningNoPhysics] = true,
				[Enum.HumanoidStateType.Landed] = true,
			}

			r247.Grounded = function(s18)
				if not s18 then
					s18 = r232.Character
					s18 = s18 and s18:FindFirstChildOfClass("Humanoid")
				end

				if not s18 or s18.Health <= 0 or s18.FloorMaterial == Enum.Material.Air then
					return false
				end
				return r250[s18:GetState()] == true
			end

			r247.ShieldPaused = false

			r247.WalkSpeed = function()
				local s7 = r232.Character
				s7 = s7 and s7:FindFirstChildOfClass("Humanoid")
				s7 = s7 and s7.WalkSpeed or 16
				local s2 = r14.Original
				local s10

				if s2 and s2.Health > 0 then
					s10 = math.min(s7, s2.WalkSpeed)
				else
					s10 = s7
				end

				local s3, s4 = pcall(function()
					local t7 = r232:FindFirstChild("leaderstats")
					t7 = t7 and t7:FindFirstChild("Speed")
					local t2 = require(r181.Shared.Util.TreadmillUtil)
					return t7 and t2.SpeedPowerToWalkSpeed(t7.Value) or nil
				end)

				local s2_1

				if s3 and tonumber(s4) and s4 > 0 then
					s2_1 = math.min(s10, s4)
				else
					s2_1 = s10
				end

				return s2_1
			end

			local function r251()
				local s6 = r232.Character
				local s2 = s6 and s6:FindFirstChildOfClass("Humanoid")
				if not s2 or s2.Health <= 0 then
					return
				end

				if r14.Clone and r14.Clone.Parent == s6 then
					return
				end

				if not r247.Grounded(s2) then
					return
				end
				local s9 = s2:Clone()
				s2.Parent = nil
				s9.Parent = s6
				workspace.CurrentCamera.CameraSubject = s9
				r18(s9)
				r248(s6)
				local s5 = r14
				r14.Original = s2
				s5.Clone = s9
				r17()

				table.insert(r14.Links, s2:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
					if s9.Parent ~= nil then
						s9.WalkSpeed = s2.WalkSpeed
					end
				end))

				local s4_1 = s2:FindFirstChildOfClass("Animator")
				local s5_1 = s9:FindFirstChildOfClass("Animator")

				if s4_1 and s5_1 then
					table.insert(r14.Links, s4_1.AnimationPlayed:Connect(function(t8)
						local t13 = t8.Animation
						if not t13 or s9.Parent == nil then
							return
						end

						local t10, t6 = pcall(function()
							return s5_1:LoadAnimation(t13)
						end)

						if not t10 or not t6 then
							return
						end

						pcall(function()
							t6.Priority = t8.Priority
							t6.Looped = t8.Looped
							local u10 = t8.Speed
							t6:Play(0.05, math.max(t8.WeightTarget, 0.01), u10)
						end)

						local t4 = nil

						t4 = t8.Stopped:Connect(function()
							t4:Disconnect()

							pcall(function()
								t6:Stop(0.1)
							end)
						end)
					end))
				end

				table.insert(r14.Links, s9.Died:Connect(function()
					r249()
					local t5 = r14
					r14.Original = nil
					t5.Clone = nil
					local t2 = r232.Character

					if t2 and s2.Parent == nil then
						s2.Parent = t2
						workspace.CurrentCamera.CameraSubject = s2
						r18(s2)
						r17()
					end

					pcall(function()
						s9:Destroy()
					end)

					s2.Health = 0
				end))
			end

			local function r252()
				if type(getconnections) ~= "function" then
					return
				end

				for _, s6 in ipairs({ r137.Heartbeat, r137.PreSimulation, r137.PostSimulation }) do
					local s7, s11 = pcall(getconnections, s6)

					if s7 and type(s11) == "table" then
						for _, s9 in ipairs(s11) do
							local s12, s13 = pcall(function()
								return s9.Function
							end)

							local s14 = s12 and type(s13) == "function"
							local s11_1 = false
							local s12_1 = nil

							if s14 then
								s11_1, s12_1 = pcall(debug.info, s13, "s")
							end

							if s11_1 and string.find(tostring(s12_1), "UGI", 1, true) then
								local s14_1, s15 = pcall(function()
									return s9.Enabled
								end)

								if not s14_1 or s15 ~= false then
									if pcall(function()
										s9:Disable()
									end) then
										table.insert(r11_1, s9)
									end
								end
							end
						end
					end
				end
			end

			local function r253()
				if r12_1 then
					r12_1:Disconnect()
					r12_1 = nil
				end

				if r15 then
					r15:Disconnect()
					r15 = nil
				end

				for _, s6 in ipairs(r11_1) do
					pcall(function()
						s6:Enable()
					end)
				end

				table.clear(r11_1)
			end

			local function r254()
				if r247.ShieldPaused then
					return
				end

				if r9_1 == r2_6[1] then
					r251()
				else
					r252()
				end
			end

			local function r255()
				r254()
				r13 = 0

				r12_1 = r137.Heartbeat:Connect(function(arg1)
					r13 += arg1
					local t1 = r232.Character
					local t2 = r9_1 == r2_6[1]

					if t2 then
						t2 = not (r14.Clone and t1 and r14.Clone.Parent == t1)
					end

					if (t2 and 0.25 or 3) <= r13 then
						r13 = 0
						r254()
					end
				end)

				r15 = r232.CharacterAdded:Connect(function(t29)
					r249()
					local t4 = r14
					r14.Original = nil
					t4.Clone = nil
					if r9_1 ~= r2_6[1] then
						return
					end

					task.spawn(function()
						t29:WaitForChild("Humanoid", 10)
						task.wait(1)

						if r12_1 and r232.Character == t29 then
							r254()
						end
					end)
				end)
			end

			r247.Swapped = function()
				if r9_1 ~= r2_6[1] then
					return true
				end
				local s2 = r232.Character
				return r14.Clone ~= nil and s2 ~= nil and r14.Clone.Parent == s2
			end

			r247.Shield = function(arg1, arg2)
				r10_1[arg1] = arg2 == true or nil
				if next(r10_1) == nil then
					r253()
					return
				end

				if r12_1 then
					return
				end
				r255()
			end

			r247.SetShieldMethod = function(s34)
				if not table.find(r2_6, s34) or s34 == r9_1 then
					return
				end
				local s1_1 = r12_1 ~= nil
				r253()
				r9_1 = s34

				if s1_1 and next(r10_1) ~= nil then
					r255()
				end
			end

			r240(r253)
		end

		r247.Shield("load", true)

		r247.Toggle = function(s17, s18)
			if type(s17) ~= "table" then
				return s18 == true
			end

			local s2, s3 = pcall(function()
				local t2 = s17._controller
				return type(t2) == "table" and type(t2.GetValue) == "function" and t2.GetValue()
			end)

			if s2 and type(s3) == "boolean" then
				return s3
			end

			for _, s4 in ipairs({ "Get", "GetValue" }) do
				local s15, s5 = pcall(function()
					return s17[s4]
				end)

				if s15 and type(s5) == "function" then
					local s15_1, s16_1 = pcall(s5, s17)
					if s15_1 and type(s16_1) == "boolean" then
						return s16_1
					end
				end
			end

			return s18 == true
		end

		r247.Root = function()
			local s11 = r232.Character
			s11 = s11 and s11:FindFirstChild("HumanoidRootPart")
			return s11 and s11:IsDescendantOf(workspace) and s11 or nil
		end

		r247.PlacedPoints = function()
			local s9 = workspace:FindFirstChild("PlacedEggRenders")
			local s14 = {}
			if not s9 then
				return s14
			end
			local s10 = tostring(r232.UserId)

			for _, s7 in ipairs(s9:GetChildren()) do
				if string.find(s7.Name, s10, 1, true) then
					local s11, s12 = pcall(function()
						return s7:IsA("Model") and s7:GetPivot() or s7.CFrame
					end)

					if s11 then
						table.insert(s14, s12.Position)
					end
				end
			end

			return s14
		end

		r247.OwnPlot = function()
			local s8 = workspace:FindFirstChild("Plots")
			if not s8 then
				return nil
			end

			for _, s6 in ipairs(s8:GetChildren()) do
				local s12 = s6:FindFirstChild("PlotSign")
				s12 = s12 and s12:FindFirstChild("PlayerPlotSign")
				s12 = s12 and s12:FindFirstChild("Frame")
				s12 = s12 and s12:FindFirstChild("PlayerName")

				if s12 and s12:IsA("TextLabel") then
					local s7 = string.lower(s12.Text)
					if s7 == string.lower(r232.Name) or s7 == string.lower(r232.DisplayName) then
						return s6
					end
				end
			end

			return nil
		end

		local function r256()
			local s6 = r247.PlacedPoints()
			if #s6 == 0 then
				return nil
			end
			local s10 = Vector3.zero

			for _, s4 in ipairs(s6) do
				s10 += s4
			end

			return s10 / #s6
		end

		r247.PenAnchor = function()
			local s4 = r256()
			if s4 then
				return s4
			end
			local s9 = r247.OwnPlot()
			if not s9 then
				return nil
			end
			local s10 = s9:FindFirstChild("ToUpdate")
			local s4_1 = s10 and s10:FindFirstChild("StarterPen") or s9:FindFirstChild("CenterPoint")
			if not s4_1 then
				return nil
			end

			local s9_1, s10_1 = pcall(function()
				return s4_1:IsA("Model") and s4_1:GetPivot() or s4_1.CFrame
			end)

			return s9_1 and s10_1.Position or nil
		end

		r247.Plot = function()
			local s1 = r247.OwnPlot()
			if s1 then
				return s1
			end
			local s5 = workspace:FindFirstChild("Plots")
			local s12 = r256()
			if not s5 or not s12 then
				return nil
			end
			local s16 = math.huge
			local s18 = nil

			for _, s3 in ipairs(s5:GetChildren()) do
				local s4, s8, s10 = pcall(function()
					return s3:GetBoundingBox()
				end)

				if s4 and s8 and s10 then
					local s4_1 = s8:PointToObjectSpace(s12)
					local s6_1 = s10.X / 2
					local s5_2 = math.abs(s4_1.X) <= s6_1
					local s6_2

					if s5_2 then
						local s5_3 = s10.Z / 2
						s6_2 = math.abs(s4_1.Z) <= s5_3
					else
						s6_2 = s5_2
					end

					if s6_2 then
						return s3
					end
					local s4_2 = (s8.Position - s12).Magnitude

					if s4_2 < s16 then
						s18 = s3
						s16 = s4_2
					end
				end
			end

			if s18 and s16 <= 60 then
				return s18
			end
			return nil
		end

		r247.Belt = function()
			local s7 = r247.Plot()
			if not s7 then
				return nil
			end
			local s9 = s7:FindFirstChild("TreadmillBottom")
			if s9 and s9:IsA("BasePart") then
				return s9
			end
			local s2 = workspace:FindFirstChild("__ClientTreadmillRenders")
			local s3 = s2 and s2:FindFirstChild("TreadmillRender_" .. s7.Name)
			local s5

			if s3 then
				s5 = s3:FindFirstChild("BoundingBoxPart") or s3:IsA("Model") and s3.PrimaryPart or s3:FindFirstChildWhichIsA("BasePart")
			else
				s5 = s3
			end

			if s5 then
				return s5
			end
			local s7_1 = s7:FindFirstChild("TreadmillUpgrade")
			return s7_1 and s7_1:FindFirstChildWhichIsA("BasePart") or nil
		end

		r247.DistanceTo = function(s14)
			local s2 = r247.Root()
			if not s2 or not s14 then
				return math.huge
			end
			return (s2.Position - s14).Magnitude
		end

		do
			local r257 = {}
			local r258 = 0

			local function r259()
				local s12 = r247.Plot()
				if not s12 then
					return {}
				end
				local s20 = {}

				for _, s4 in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
					local s5 = s12:FindFirstChild(s4)

					if s5 then
						if s5:IsA("BasePart") then
							table.insert(s20, s5)
						else
							for _, s7 in ipairs(s5:GetDescendants()) do
								if s7:IsA("BasePart") then
									table.insert(s20, s7)
								end
							end
						end
					end
				end

				local s2 = workspace:FindFirstChild("__ClientTreadmillRenders")
				s2 = s2 and s2:FindFirstChild("TreadmillRender_" .. s12.Name)

				if s2 then
					for _, s10 in ipairs(s2:GetDescendants()) do
						if s10:IsA("BasePart") then
							table.insert(s20, s10)
						end
					end
				end

				return s20
			end

			local function r260()
				for _, s3 in ipairs(r259()) do
					if not r257[s3] then
						r257[s3] = {
							CFrame = s3.CFrame,
							CanTouch = s3.CanTouch,
							CanCollide = s3.CanCollide,
							Transparency = s3.Transparency,
						}

						pcall(function()
							s3.CanTouch = false
							s3.CanCollide = false
							s3.Transparency = 1
							s3.CFrame = s3.CFrame - Vector3.new(0, 120, 0)
						end)
					end
				end
			end

			local function r261()
				for s5, s6 in pairs(r257) do
					if s5 and s5.Parent then
						pcall(function()
							s5.CFrame = s6.CFrame
							s5.CanTouch = s6.CanTouch
							s5.CanCollide = s6.CanCollide
							s5.Transparency = s6.Transparency
						end)
					end
				end

				table.clear(r257)
			end

			r247.HoldBelt = function()
				r258 += 1
				r260()
			end

			r247.ReleaseBelt = function()
				r258 = math.max(0, r258 - 1)

				if r258 == 0 then
					r261()
				end
			end

			r247.BeltHeld = function()
				return r258 > 0
			end

			r247.RefreshBeltHide = function()
				if r258 > 0 then
					r260()
				end
			end

			r240(function()
				r258 = 0
				r261()
			end)

			r247.LeaveBelt = function()
				local s10 = r182:FindFirstChild("RF/Treadmill/AskDoff")

				if s10 and s10:IsA("RemoteFunction") then
					pcall(s10.InvokeServer, s10)
				end
			end

			r247.Treadmill = { Riding = false }

			r247.ResetBelt = function()
				r258 = 0
				r261()
			end

			r247.OnBelt = function()
				local s9 = r247.Belt()
				if not s9 or r257[s9] then
					return false
				end
				local s4 = r247.Root()
				if not s4 then
					return false
				end
				local s2_1 = s9.CFrame:PointToObjectSpace(s4.Position)
				local s4_1 = s9.Size.X / 2 + 2
				local s3 = math.abs(s2_1.X) <= s4_1

				if s3 then
					local s6 = s9.Size.Z / 2 + 2
					s3 = math.abs(s2_1.Z) <= s6
				end

				return s3 and s2_1.Y >= -2 and s2_1.Y <= s9.Size.Y / 2 + 8
			end
		end

		r247.ExitBelt = function()
			r247.Treadmill.Riding = false
			r247.LeaveBelt()
			local s3 = r232.Character
			local s10 = s3 and s3:FindFirstChildOfClass("Humanoid")

			if s10 then
				pcall(function()
					s10.Jump = true
					s10:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			task.wait(0.35)
		end

		r247.Flying = false
		r247.Driving = 0

		r247.BeginFlight = function()
			r247.Flying = true
			local s10 = r232.Character
			local s2 = s10 and s10:FindFirstChildOfClass("Humanoid")

			if s2 then
				s2.PlatformStand = true

				pcall(function()
					s2:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end

			return r247.Root() ~= nil
		end

		r247.SetFlightVelocity = function(s36)
			local s1 = r247.Root()

			if s1 then
				s1.AssemblyLinearVelocity = s36
				s1.AssemblyAngularVelocity = Vector3.zero
			end
		end

		r247.EndFlight = function()
			r247.Flying = false
			local s12 = r247.Root()

			if s12 then
				pcall(function()
					s12.AssemblyLinearVelocity = Vector3.zero
					s12.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			local s10 = r232.Character
			s10 = s10 and s10:FindFirstChildOfClass("Humanoid")

			if s10 then
				s10.PlatformStand = false
			end
		end

		do
			local r3_3 = {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.Physics,
				Enum.HumanoidStateType.Seated,
				Enum.HumanoidStateType.PlatformStanding,
			}

			local r4_3 = {}
			local r5_3 = false

			r247.GodMode = function(s28)
				local s4 = r232.Character
				local s15 = s4 and s4:FindFirstChildOfClass("Humanoid")
				if not s4 or not s15 then
					return
				end

				if s28 then
					r5_3 = true

					for _, s3 in ipairs(r3_3) do
						pcall(function()
							s15:SetStateEnabled(s3, false)
						end)
					end

					pcall(function()
						s15.BreakJointsOnDeath = false
					end)

					for _, s6 in ipairs(s4:GetDescendants()) do
						if s6:IsA("BasePart") and r4_3[s6] == nil then
							r4_3[s6] = s6.CanCollide

							pcall(function()
								s6.CanCollide = false
							end)
						end
					end
				elseif r5_3 then
					r5_3 = false

					for _, s10 in ipairs(r3_3) do
						pcall(function()
							s15:SetStateEnabled(s10, true)
						end)
					end

					for s13, s14 in pairs(r4_3) do
						if s13 and s13.Parent then
							pcall(function()
								s13.CanCollide = s14
							end)
						end
					end

					table.clear(r4_3)
				end
			end
		end

		r247.GodTick = function()
			local s3 = r232.Character
			local s2 = s3 and s3:FindFirstChildOfClass("Humanoid")

			if s2 and s2.Health < s2.MaxHealth then
				pcall(function()
					s2.Health = s2.MaxHealth
				end)
			end
		end

		r247.StopWalking = function()
			local s9 = r232.Character
			local s11 = s9 and s9:FindFirstChild("HumanoidRootPart")
			local s2 = s9 and s9:FindFirstChildOfClass("Humanoid")

			if s2 and s11 then
				pcall(function()
					s2:MoveTo(s11.Position)
					s2:Move(Vector3.zero, false)
				end)
			end
		end

		local function r6_6(s19, s20, s21, s22)
			local s9 = tonumber(s20) or 6
			local s10 = tonumber(s21) or 10
			local s11 = 0
			local s12 = nil
			local s14 = 0
			local s6 = 0

			while s11 < s10 do
				if type(s22) == "function" and s22() then
					r247.StopWalking()
					return false
				end
				local s3 = r232.Character
				local s4 = s3 and s3:FindFirstChild("HumanoidRootPart")
				local s8 = s3 and s3:FindFirstChildOfClass("Humanoid")
				if not s4 or not s8 or s8.Health <= 0 then
					return false
				end

				if (s4.Position - s19).Magnitude <= s9 then
					r247.StopWalking()
					return true
				end
				s12 = s12 and (s4.Position - s12).Magnitude < 1

				if s12 then
					s14 += 0.2
				else
					s14 = 0
				end

				s12 = s4.Position
				s6 = math.max(0, s6 - 0.2)

				if s14 >= 0.8 and s6 <= 0 then
					r247.LeaveBelt()

					pcall(function()
						s8.Jump = true
					end)

					s14 = 0
					s6 = 1.5
				end

				s8:MoveTo(s19)
				s11 += task.wait(0.2)
			end

			r247.StopWalking()
			return r247.DistanceTo(s19) <= s9
		end

		r247.WalkTo = function(s29, s30, s31, s32)
			r247.Driving = r247.Driving + 1
			local s27, s28 = pcall(r6_6, s29, s30, s31, s32)
			r247.Driving = math.max(0, r247.Driving - 1)
			return s27 and s28 == true
		end

		local r262 = {
			Boss = "Fractured",
			GreatBloom = "Spirit Bloom",
			Sakura = "Bloom",
			Monstrous = "Parasite",
		}

		task.spawn(function()
			local s8 = r234.Mutations

			local s2, s6 = pcall(function()
				return s8.All()
			end)

			if s2 and type(s6) == "table" then
				for s3_1, s4 in pairs(s6) do
					local s6_1 = type(s4) == "table" and (s4.Id or s3_1) or nil
					local s10 = type(s4) == "table" and s4.Label or nil

					if s6_1 ~= nil and type(s10) == "string" and s10 ~= "" then
						r262[tostring(s6_1)] = s10
					end
				end
			end
		end)

		r263 = function(s26)
			return r262[tostring(s26)] or tostring(s26)
		end

		local r265, r266, r267, r268, r269, r270, r271, r272, r273, r275
		local r276, r277, r278

		do
			local r150 = {
				"Forest",
				"Desert",
				"Snow",
				"Lake",
				"Jungle",
				"Volcano",
				"Prehistoric",
				"Cosmic",
				"Abyss Ocean",
				"Cherry Blossom",
				"Light Dark",
				"Titan Temple",
			}

			local r4_4 = {}

			for _, r3_4 in ipairs(r150) do
				r4_4[r3_4] = true
			end

			task.spawn(function()
				local s6 = r234.EggState

				local s2, s3 = pcall(function()
					return s6.ReadFieldEggs()
				end)

				if s2 and type(s3) == "table" and type(s3.Records) == "table" then
					for _, s4 in pairs(s3.Records) do
						local s8 = type(s4) == "table" and s4.AreaId or nil

						if type(s8) == "string" and not r4_4[s8] then
							r4_4[s8] = true
							table.insert(r150, s8)
						end
					end
				end
			end)

			r191 = { "Any" }
			r264 = { Any = 0 }
			local r1_8 = {}
			local r5_4 = r234.Assets and r234.Assets.Directory

			if type(r5_4) == "table" then
				for _, r6_72 in pairs(r5_4) do
					local r3_27 = type(r6_72) == "table" and r6_72.Rarity or nil
					local r2_70 = type(r3_27) == "table"

					if r2_70 then
						r2_70 = tonumber(r3_27.RarityNumber or r3_27.Rank)
					end

					r2_70 = r2_70 or nil

					if r2_70 then
						local r7_6 = r1_8[r2_70]

						if not r7_6 then
							r7_6 = tostring(r3_27.DisplayName or r3_27._id or r2_70)
						end

						r1_8[r2_70] = r7_6
					end
				end
			end

			if next(r1_8) == nil then
				r1_8 = {
					"Common",
					"Uncommon",
					"Rare",
					"Epic",
					"Legendary",
					"Mythic",
					"Cosmic",
					"Secret",
					"Eternal",
					"Divine",
				}
			end

			local r11_2 = {}

			for r8_1 in pairs(r1_8) do
				table.insert(r11_2, r8_1)
			end

			table.sort(r11_2)

			for _, r12_2 in ipairs(r11_2) do
				table.insert(r191, r1_8[r12_2])
				r264[r1_8[r12_2]] = r12_2
			end

			r7_4 = { "Best Rarity", "Biggest Weight", "Best Mutation", "Highest Value", "Lowest Value" }
			r265 = {}
			r266 = 0
			r267 = {}
			r268 = {}
			r269 = {}
			r270 = {}
			r247.Steal.RiftPriority = false
			r247.Steal.RiftNeeds = {}
			r271 = false
			r272 = {}
			r273 = 0
			r274 = r7_4[4]
			r275 = 400
			r276 = 27.4
			r277 = 400
			r278 = nil

			r4_5 = r26:CreateToggle({
				Name = "Auto Steal",
				Default = false,
				Callback = function()
					if r278 then
						r278()
					end
				end,
			})

			for _, r15_1 in ipairs(r150) do
				r265[r15_1] = true
			end

			r243(r26:CreateMultiDropdown({
				Name = "Target Areas",
				Options = r150,
				Default = r150,
				Callback = function(s24)
					local s7 = {}

					if type(s24) == "table" then
						for s2, s3 in pairs(s24) do
							if s3 == true and type(s2) == "string" then
								s7[s2] = true
							elseif type(s3) == "string" then
								s7[s3] = true
							end
						end
					end

					if next(s7) == nil then
						for _, s6 in ipairs(r150) do
							s7[s6] = true
						end
					end

					r265 = s7
				end,
			}))
		end

		r26:CreateDropdown({
			Name = "Min Rarity",
			Note = "Steal eggs of the chosen rarity and every rarity above it",
			Options = r191,
			Default = r191[1],
			Callback = function(arg1)
				r266 = r264[arg1] or 0
			end,
		})

		r192(r26, {
			Name = "Min Steal Value",
			Note = "Skip eggs worth less than this. Drag or type 250k, 50m, 1.5b",
			Legacy = "Min Value To Steal",
			SectionName = "Auto Steal",
			OnRaw = function(arg1)
				r273 = arg1
			end,
		})

		do
			local r5_5 = {}
			local r6_7 = {}
			local r17_1 = r234.Assets and r234.Assets.Directory
			local r20 = {}

			if type(r17_1) == "table" then
				for r17_9, r18_5 in pairs(r17_1) do
					local r1_83 = type(r18_5) == "table" and r18_5.Rarity or nil
					local r2_68 = type(r1_83) == "table"

					if r2_68 then
						r2_68 = tonumber(r1_83.RarityNumber or r1_83.Rank)
					end

					r2_68 = r2_68 or nil

					if r2_68 then
						table.insert(r20, {
							Category = tostring(r17_9),
							Name = tostring(r18_5.DisplayName or r17_9),
							Rarity = r2_68,
							RarityName = tostring(r1_83.DisplayName or r1_83._id or r2_68),
						})
					end
				end
			end

			table.sort(r20, function(s37, s38)
				if s37.Rarity ~= s38.Rarity then
					return s37.Rarity > s38.Rarity
				end
				return s37.Name < s38.Name
			end)

			for _, r21 in ipairs(r20) do
				local r151 = string.format("%s [%s]", r21.Name, r21.RarityName)

				if r6_7[r151] then
					r151 = string.format("%s [%s] (%s)", r21.Name, r21.RarityName, r21.Category)
				end

				table.insert(r5_5, r151)
				r6_7[r151] = r21.Category
			end

			r243(r26:CreateMultiDropdown({
				Name = "Target Specific Eggs",
				Note = "Only steal these eggs (empty = all)",
				Options = r5_5,
				Default = {},
				Callback = function(s35)
					local s4 = {}

					if type(s35) == "table" then
						for s2, s3 in pairs(s35) do
							s2 = s3 == true and type(s2) == "string" and s2 or type(s3) == "string" and s3 or nil

							if s2 and r6_7[s2] then
								s4[r6_7[s2]] = true
							end
						end
					end

					r267 = s4
				end,
			}))
		end

		do
			local r13_1 = 30
			local r14_2 = false
			local r15_2 = 0

			local function r16_1()
				local s11 = {}
				local s2 = r234.Save

				if type(s2) == "table" and type(s2.Get) == "function" then
					local s6, s7 = pcall(s2.Get)

					if s6 and type(s7) == "table" then
						local s2_2 = pairs
						local s6_1 = s7.Inventory or {}

						for _, s4 in s2_2(s6_1) do
							if type(s4) == "table" and s4.Category ~= nil then
								s11[tostring(s4.Category)] = true
							end
						end

						local s6_3 = pairs
						local s2_3 = s7.EggInventory or {}

						for _, s8_1 in s6_3(s2_3) do
							if type(s8_1) == "table" and s8_1.AssetCategory ~= nil then
								s11[tostring(s8_1.AssetCategory)] = true
							end
						end
					end
				end

				return s11
			end

			local function r17_2()
				local s8 = r182:FindFirstChild("RF/Rift/AskState")
				if not s8 or not s8:IsA("RemoteFunction") then
					return
				end
				local s2, s3 = pcall(s8.InvokeServer, s8)
				if not s2 or type(s3) ~= "table" or type(s3.Requirements) ~= "table" then
					return
				end
				local s5 = r16_1()
				local s6_1 = {}

				for _, s4 in pairs(s3.Requirements) do
					if not s5[tostring(s4)] then
						s6_1[tostring(s4)] = true
					end
				end

				r247.Steal.RiftNeeds = s6_1
			end

			r244.Add(function()
				if not r247.Steal.RiftPriority or r14_2 or os.clock() < r15_2 then
					return false
				end
				r14_2 = true
				r15_2 = os.clock() + r13_1

				task.spawn(function()
					pcall(r17_2)
					r14_2 = false
				end)

				return false
			end)

			local function r18_1()
				local s6 = r247.Steal.RiftNeeds
				if not r247.Steal.RiftPriority or next(s6) == nil then
					return
				end
				local s8 = r16_1()
				local s10 = false

				for s3 in pairs(s6) do
					if s8[s3] then
						s6[s3] = nil
						s10 = true
					end
				end

				if s10 then
					r244.Wake()
				end
			end

			local r2_8 = r234.Save

			if type(r2_8) == "table" and type(r2_8.FieldSignal) == "function" then
				for _, r24 in ipairs({ "EggInventory", "Inventory" }) do
					local r153, r154 = pcall(r2_8.FieldSignal, r24)

					if r153 and type(r154) == "table" and type(r154.Connect) == "function" then
						local r152, r153_1 = pcall(r154.Connect, r154, function()
							task.defer(r18_1)
						end)

						if r152 and r153_1 then
							r240(function()
								pcall(function()
									r153_1:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		do
			local r19 = 5
			local r279 = 5
			local r280 = 60
			local r5_6 = nil
			local r281 = 0
			local r282 = 0
			local r283 = false
			local r284 = {}

			local function r285()
				local s3 = r234.Save

				if type(s3) == "table" and type(s3.Get) == "function" then
					local s2_1, s3_1 = pcall(s3.Get)
					if s2_1 and type(s3_1) == "table" then
						return s3_1
					end
				end

				return nil
			end

			local function r286()
				local s6 = r285()
				local s10 = r234.Areas and r234.Areas.Directory
				local s17 = r234.Assets and r234.Assets.Directory
				if not s6 or type(s10) ~= "table" or type(s17) ~= "table" then
					return
				end
				local s19 = type(s6.Index) == "table" and s6.Index or {}
				local s20 = {}
				local s1_2 = pairs
				local s5 = s6.Inventory or {}

				for _, s3 in s1_2(s5) do
					if type(s3) == "table" and s3.Category ~= nil then
						s20[tostring(s3.Category)] = true
					end
				end

				local s5_2 = pairs
				local s1_3 = s6.EggInventory or {}

				for _, s7 in s5_2(s1_3) do
					if type(s7) == "table" and s7.AssetCategory ~= nil then
						s20[tostring(s7.AssetCategory)] = true
					end
				end

				local s2_3 = {}

				for _, s11 in pairs(s10) do
					local s3_1 = type(s11) == "table" and type(s11.Rarity) == "table"

					if s3_1 then
						s3_1 = tonumber(s11.Rarity.RarityNumber or s11.Rarity.Rank)
					end

					s3_1 = s3_1 or 0
					local s13 = pairs
					local s1_6 = type(s11) == "table" and s11.DropTable or {}

					for _, s15 in s13(s1_6) do
						local s1_7 = type(s15) == "table" and s15[1] or nil
						local s5_4 = type(s15) == "table" and tonumber(s15[2]) or 0
						local s7_1 = s1_7 ~= nil and s17[s1_7] or nil

						if type(s7_1) == "table" and s5_4 > 0 and s7_1.DontRoll ~= true then
							local s5_5 = tostring(s1_7)

							if s19[s1_7] ~= true and not s20[s5_5] and (s2_3[s5_5] == nil or s3_1 > s2_3[s5_5]) then
								s2_3[s5_5] = s3_1
							end
						end
					end
				end

				r272 = s2_3
			end

			local function r287(s13, ...)
				local s2 = r182:FindFirstChild(s13)
				if not s2 or not s2:IsA("RemoteFunction") then
					return false
				end
				local s9, s10 = pcall(s2.InvokeServer, s2, ...)
				return s9 and s10 ~= false
			end

			local function r288(s19, s20)
				local s13 = {}
				if type(s19) ~= "table" then
					return s13
				end

				for _, s4 in ipairs(s20) do
					local s11 = s19

					for _, s7 in ipairs(s4) do
						s11 = type(s11) == "table" and s11[s7] or nil
					end

					local s8_1 = ipairs
					s11 = type(s11) == "table" and s11 or {}

					for _, s10 in s8_1(s11) do
						if type(s10) == "table" and s10.AssetId ~= nil then
							table.insert(s13, s10.AssetId)
						end
					end
				end

				return s13
			end

			local r8_2 = {
				{
					Id = "LimitedEgg",
					Gear = "GravityDisruptor",
					Module = "LimitedEgg",
					Lists = { { "Entries" }, { "MechaReroll", "Entries" } },
				},
				{
					Id = "BrainrotEgg",
					Gear = "BeeLauncher",
					Module = "BrainrotEgg",
					Lists = { { "Entries" } },
				},
				{
					Id = "MonsterEgg",
					Gear = "BeeLauncher",
					Module = "MonsterEgg",
					Lists = { { "Entries" }, { "MechaEntries" } },
				},
			}

			local function r289()
				local s7 = r285()
				if not s7 then
					return
				end
				local s16 = type(s7.Index) == "table" and s7.Index or {}
				local s8 = type(s7.IndexClaimedCategories) == "table" and s7.IndexClaimedCategories or {}

				for s3, s4 in pairs(s16) do
					if s4 == true and s8[s3] ~= true then
						r287("RF/Codex/AskRedeemAll")
						break
					end
				end

				local s3_1 = type(s7.GearInventory) == "table" and s7.GearInventory or {}

				for _, s9_1 in ipairs(r8_2) do
					local s2_1 = (tonumber(s3_1[s9_1.Gear]) or 0) <= 0

					if s2_1 then
						s2_1 = os.clock() >= (r284[s9_1.Id] or 0)
					end

					if s2_1 then
						local s12_1 = r288(r234[s9_1.Module], s9_1.Lists)
						local s4_2 = #s12_1 > 0

						for _, s13 in ipairs(s12_1) do
							if s16[s13] ~= true then
								s4_2 = false
								break
							end
						end

						if s4_2 then
							r284[s9_1.Id] = os.clock() + r280
							r287("RF/Codex/AskRedeemLimitedEgg", s9_1.Id)
						end
					end
				end
			end

			r244.Add(function()
				local s10 = os.clock()

				if r271 and s10 >= r281 then
					r281 = s10 + r19
					pcall(r286)
				end

				if not r283 and s10 >= r282 and r247.Toggle(r247.IndexClaimHandle, false) then
					r283 = true
					r282 = s10 + r279

					task.spawn(function()
						pcall(r289)
						r283 = false
					end)
				end

				return false
			end)

			r5_6 = r26:CreateToggle({
				Name = "Steal Missing Index Eggs",
				Note = "Also steal eggs missing from your index, highest area first",
				Default = false,
				Callback = function()
					r271 = r247.Toggle(r5_6, false) == true
					r281 = 0

					if not r271 then
						r272 = {}
					end

					r244.Wake()
				end,
			})

			r247.IndexClaimRestart = function()
				r282 = 0
				r244.Wake()
			end
		end

		r247.Steal.PriorityHandle = r26:CreateDropdown({
			Name = "Steal Priority",
			Options = r7_4,
			Default = r7_4[4],
			Callback = function(s26)
				if table.find(r7_4, s26) then
					r274 = s26

					if type(r247.ResortSteal) == "function" then
						r247.ResortSteal()
					end
				end
			end,
		})

		r26:CreateSlider({
			Name = "Tween Speed",
			Min = 100,
			Max = 1000,
			Default = 400,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(s18)
				local s14_1 = math.clamp(tonumber(s18) or 400, 100, 1000)
				r275 = s14_1
				r277 = s14_1
			end,
		})

		r247.AntiGuard.Handle = r180:CreateState({ Name = "Anti Guard Enabled", Default = false })

		pcall(function()
			r247.AntiGuard.Enabled = r247.AntiGuard.Handle:Get() == true
		end)

		pcall(function()
			r247.AntiGuard.Handle:Subscribe(function(t14)
				if type(t14) ~= "boolean" then
					t14 = r247.AntiGuard.Handle:Get()
				end

				r247.AntiGuard.Enabled = t14 == true

				if r247.StealPanelSync then
					pcall(r247.StealPanelSync)
				end

				if r247.AntiGuard.Render and r247.UiDefer then
					r247.UiDefer(function()
						pcall(r247.AntiGuard.Render, false)
					end)
				end
			end)
		end)

		r247.AntiGuard.PanelHandle = r26:CreateToggle({
			Name = "Anti Guard Panel",
			Default = true,
			Callback = function(s16)
				if type(s16) ~= "boolean" then
					s16 = r247.Toggle(r247.AntiGuard.PanelHandle, true)
				end

				r247.AntiGuard.PanelShown = s16

				if r247.AntiGuard.ShowPanel then
					pcall(r247.AntiGuard.ShowPanel, s16)
				end
			end,
		})

		r247.SafeCarry.Handle = r26:CreateToggle({
			Name = "Safe Delivery",
			Note = "Best with Anti Guard on",
			Default = true,
			Callback = function(s25)
				if type(s25) ~= "boolean" then
					s25 = r247.Toggle(r247.SafeCarry.Handle, true)
				end

				r247.SafeCarry.Enabled = s25 == true
				r244.Wake()
			end,
		})

		r26:CreateDropdown({
			Name = "Travel Method",
			Options = { "Tween", "Teleport" },
			Default = "Tween",
			SubOf = r247.SafeCarry.Handle,
			Callback = function(s33)
				if s33 == "Tween" then
					r247.SafeCarry.Approach = "Run"
				elseif s33 == "Teleport" then
					r247.SafeCarry.Approach = "Ragdoll Jump"
				end
			end,
		})

		r26:CreateSlider({
			Name = "Carry Speed",
			Note = "Lower it if you get Delivery failed",
			Min = 80,
			Max = 120,
			Default = 100,
			Increment = 1,
			Unit = "%",
			SubOf = r247.SafeCarry.Handle,
			Callback = function(s19)
				r247.SafeCarry.CarryScale = math.clamp(tonumber(s19) or 100, 80, 120) / 100
			end,
		})

		r247.SafeCarry.RunHandle = r26:CreateSlider({
			Name = "Egg Tween Speed",
			Note = "Tween only: how fast you fly to the egg, 100 = your walk speed",
			Min = 50,
			Max = 300,
			Default = 115,
			Increment = 5,
			Unit = "%",
			SubOf = r247.SafeCarry.Handle,
			Callback = function(s12)
				r247.SafeCarry.RunSpeed = math.clamp(tonumber(s12) or 115, 50, 300) / 100
			end,
		})

		r26:CreateSlider({
			Name = "Wait After Teleport",
			Note = "Teleport only: wait time before taking the egg. Too short and the delivery fails",
			Min = 0,
			Max = 15,
			Default = 6.5,
			Increment = 0.5,
			Unit = "s",
			SubOf = r247.SafeCarry.Handle,
			Callback = function(s21)
				r247.SafeCarry.BaseWait = math.clamp(tonumber(s21) or 6.5, 0, 15)
			end,
		})

		local r16_2
		r16_2 = nil
		local r17_3
		r17_3 = nil
		local r18_2
		r18_2 = nil
		local r19_1
		r19_1 = "None"
		local r20_2
		r20_2 = "Idle"
		local r21_1
		r21_1 = false
		local r291
		r291 = 0
		local r292
		r292 = {}
		local r293
		r293 = 20
		local r294
		r294 = nil
		local r295

		r295 = function(arg1)
			return arg1 ~= r291 or not r247.Toggle(r16_2, false)
		end

		local r299

		do
			local r296 = {}

			local function r297(s16)
				if type(s16) ~= "number" or r296[s16] then
					return
				end
				r296[s16] = true

				task.delay(math.max(0, s16 - workspace:GetServerTimeNow()) + 0.05, function()
					r296[s16] = nil
					r244.Wake()
				end)
			end

			local r298 = 0

			r299 = function()
				local s11 = r234.AreaEggCycle
				if type(s11) ~= "table" then
					return nil
				end

				local s5, s6, s7, s8, s9 = pcall(function()
					local t2 = workspace:GetServerTimeNow()
					local t5 = s11.NextResetTime
					return t2, s11.IsNightPhase(t2), s11.NextNightTime(t2), t5(t2)
				end)

				if not s5 or type(s9) ~= "number" then
					return nil
				end

				if s7 == true then
					r298 = s9 + r247.WallOpenDelay()
					r297(r298)
					return r298, "night", s6
				end

				if r247.WallSealed() then
					r297(s6 + 0.3)
					return math.max(r298, s6), "wall", s6
				end

				if type(s8) == "number" and s8 > s6 then
					r297(s8)
				end

				return nil
			end
		end

		do
			local r1_10 = r234.AreaEggResetWall
			local r3_5 = type(r1_10) == "table" and r1_10.Changed or nil

			if r3_5 and type(r3_5.Connect) == "function" then
				local r1_11, r2_10 = pcall(function()
					return r3_5:Connect(function()
						r244.Wake()
					end)
				end)

				if r1_11 and r2_10 then
					r240(function()
						pcall(function()
							r2_10:Disconnect()
						end)
					end)
				end
			end
		end

		local r300
		r300 = 8
		local r301
		r301 = nil
		local r302
		r302 = 0
		local r304, r305, r306

		local function r303(s15)
			local s1 = {}
			local s3 = "FirstAreaEgg_" .. tostring(r232.UserId)
			local s4 = r234.EggState

			if type(s4) == "table" and type(s4.ReadFieldEggs) == "function" then
				task.spawn(function()
					local t2, t3 = pcall(s4.ReadFieldEggs)

					if t2 and type(t3) == "table" and type(t3.Records) == "table" then
						for _, t4 in pairs(t3.Records) do
							local t12 = type(t4) == "table" and type(t4.Uid) == "string"

							if t12 then
								t12 = not (s15 and string.sub(t4.Uid, 1, #s3) == s3)
							end

							if t12 then
								s1[t4.Uid] = true
							end
						end
					end
				end)
			end

			return s1
		end

		r304 = function()
			if r301 == nil then
				return false
			end

			if r247.IsNight() then
				return true
			end

			if r302 == math.huge then
				r302 = os.clock() + r300
			end

			return false
		end

		r305 = function()
			if r301 and r302 == math.huge then
				return
			end
			r301 = r303(true)
			r302 = math.huge
			table.clear(r268)
			table.clear(r270)
			table.clear(r269)
			table.clear(r292)
			r294 = nil
		end

		r306 = function()
			if not r301 then
				return false
			end

			if os.clock() >= r302 then
				r301 = nil
				return false
			end
			local s3 = r303()
			if next(s3) == nil then
				return true
			end
			local s8 = false
			local s10 = false

			for s3_1 in pairs(s3) do
				if r301[s3_1] then
					s8 = true
				else
					s10 = true
				end
			end

			if not s8 then
				r301 = nil
				return false
			end
			return not s10
		end

		local r310

		do
			local function r307(s23)
				local s1 = r234.Assets and r234.Assets.Directory
				local s2 = type(s1) == "table" and s1[tostring(s23)] or nil
				local s3 = type(s2) == "table" and type(s2.Rarity) == "table" and s2.Rarity or nil
				local s1_2 = {}

				if s3 then
					s3 = tonumber(s3.RarityNumber or s3.Rank)
				end

				s1_2.RarityNumber = s3 or 0
				s1_2.EarningRate = type(s2) == "table" and tonumber(s2.EarningRate) or 0
				return s1_2
			end

			local function r308(s16)
				local s2 = r234.Mutations

				if type(s2) == "table" and type(s2.EarningsFor) == "function" then
					local s14_1, s15_1 = pcall(s2.EarningsFor, type(s16) == "table" and s16 or {})
					if s14_1 and type(s15_1) == "number" then
						return s15_1
					end
				end

				return 1
			end

			local function r309(s21, s22)
				local s2 = r234.EggRecords

				if type(s2) == "table" and type(s2.WeightKgForScale) == "function" then
					local s19, s20 = pcall(s2.WeightKgForScale, s21, s22)
					if s19 and type(s20) == "number" then
						return s20
					end
				end

				return 0
			end

			r310 = function(s4, s5)
				local s13 = nil
				local s14 = r234.EggState

				if type(s14) == "table" and type(s14.ReadFieldEggs) == "function" then
					task.spawn(function()
						local t2, t3 = pcall(s14.ReadFieldEggs)

						if t2 and type(t3) == "table" and type(t3.Records) == "table" and next(t3.Records) ~= nil then
							s13 = t3.Records
						end
					end)
				end

				if not s13 then
					local s1_1 = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
					if not s1_1 or not s1_1:IsA("RemoteFunction") then
						return {}
					end
					local s8, s9 = pcall(s1_1.InvokeServer, s1_1)
					s13 = s8 and type(s9) == "table" and s9.Records or nil
				end

				if type(s13) ~= "table" then
					return {}
				end
				local s15 = {}
				local s16 = {}

				for _, s3_1 in pairs(s13) do
					local s6 = type(s3_1) == "table" and s3_1.Uid or nil

					if s6 and s3_1.State ~= "Claimed" then
						s16[s6] = true
					end

					local s7_2 = s6 and (s3_1.State == "Slot" or s3_1.State == "Dropped" or s3_1.State == "Carried" and s5 == true and s4 ~= true and not (r247.Steal.Carrying and s6 == r247.Steal.CarryUid))
					local s8_2 = s6 and r268[s6] or nil
					local s9_1 = s6 and r269[s6] == true or false
					local s17 = s4 ~= true and r271 and s6 and r272[tostring(s3_1.AssetCategory)] or nil
					local s18 = s4 ~= true and r247.Steal.RiftPriority == true and s6 ~= nil and r247.Steal.RiftNeeds[tostring(s3_1.AssetCategory)] == true
					local s10_1 = s4 == true or s8_2 ~= nil or s9_1 or s18 or s17 ~= nil or r265[tostring(s3_1.AreaId)] == true
					local s11_1 = s4 ~= true and s8_2 == nil and r270[s6] == true
					local s12 = r301 ~= nil and r301[s6] == true
					s7_2 = s7_2 and typeof(s3_1.BottomCFrame) == "CFrame"

					if s7_2 then
						s7_2 = (r292[s6] or 0) <= os.clock()
					end

					if s7_2 and s10_1 and not s11_1 and not s12 then
						local s7_3 = r307(s3_1.AssetCategory)
						local s10_2 = tostring(s3_1.AssetCategory)
						local s11_2 = s7_3.RarityNumber >= r266
						local s26_1 = next(r267) == nil or r267[s10_2] == true
						local s12_1 = tonumber(s3_1.AssetScale) or 1
						local s28 = r308(s3_1.Mutations)
						local s29 = s12_1 > 5 and (s12_1 / 5) ^ 1.2 * 19.637875755794113 or s12_1 ^ 1.85
						local s34 = r273 <= 0 or s7_3.EarningRate * s29 * s28 >= r273
						s34 = s11_2 and s26_1 and s34
						local s37_1 = s18 and not s34 and not s9_1 and s8_2 == nil and s17 == nil
						local s11_3 = s4 ~= true and r247.SafeCarry.Unsafe({ Uid = s6, Category = s10_2 })

						if s11_3 then
							r268[s6] = nil
							r269[s6] = nil
							r247.SafeCarry.LastSkip = s11_3
						elseif s4 == true or s8_2 or s9_1 or s18 or s17 ~= nil or s34 then
							table.insert(s15, {
								Uid = s6,
								Category = s10_2,
								Scale = s12_1,
								State = s3_1.State,
								Rarity = s7_3.RarityNumber,
								Weight = r309(s3_1.AssetCategory, s12_1),
								Mutation = s28,
								Value = s7_3.EarningRate * s29 * s28,
								CFrame = s3_1.BottomCFrame,
								AreaId = tostring(s3_1.AreaId),
								Rift = s4 ~= true and s18,
								RiftOnly = s4 ~= true and s37_1,
								Index = s17,
								Forced = s4 ~= true and s8_2 and s8_2.At or nil,
								Priority = s4 ~= true and s9_1,
							})
						end
					end
				end

				if next(s16) ~= nil then
					for s5_1 in pairs(r268) do
						if not s16[s5_1] then
							r268[s5_1] = nil
						end
					end

					for s8_3 in pairs(r269) do
						if not s16[s8_3] then
							r269[s8_3] = nil
						end
					end

					for s11_6 in pairs(r270) do
						if not s16[s11_6] then
							r270[s11_6] = nil
						end
					end
				end

				table.sort(s15, function(t31, t32)
					if t31.Forced ~= nil ~= t32.Forced ~= nil then
						return t31.Forced ~= nil
					end

					if t31.Forced and t32.Forced and t31.Forced ~= t32.Forced then
						return t31.Forced < t32.Forced
					end

					if t31.Priority ~= t32.Priority then
						return t31.Priority == true
					end

					if t31.RiftOnly ~= t32.RiftOnly then
						return t32.RiftOnly == true
					end

					if t31.Index ~= nil ~= t32.Index ~= nil then
						return t31.Index ~= nil
					end

					if t31.Index and t32.Index and t31.Index ~= t32.Index then
						return t31.Index > t32.Index
					end

					if r274 == r7_4[2] and t31.Weight ~= t32.Weight then
						return t31.Weight > t32.Weight
					end

					if r274 == r7_4[3] and t31.Mutation ~= t32.Mutation then
						return t31.Mutation > t32.Mutation
					end

					if r274 == r7_4[4] and t31.Value ~= t32.Value then
						return t31.Value > t32.Value
					end

					if r274 == r7_4[5] and t31.Value ~= t32.Value then
						return t31.Value < t32.Value
					end

					if t31.Rarity ~= t32.Rarity then
						return t31.Rarity > t32.Rarity
					end

					if t31.Value ~= t32.Value then
						return t31.Value > t32.Value
					end
					return tostring(t31.Uid) < tostring(t32.Uid)
				end)

				return s15
			end
		end

		local r311
		r311 = 6
		local r314, r315, r318, r319, r322

		do
			local r312 = nil
			local r313 = nil

			r314 = function(s6, arg2, s8, s9, s10)
				local s2 = arg2 - s6.Position
				local s4 = s2.Magnitude
				local s13 = math.max(s9, 0.0041666666666666666)
				local s7 = Vector3.zero

				if s4 > 0.01 then
					s7 = s2.Unit * math.min(s8, s4 / s13)
				end

				local s7_1 = s7 + Vector3.new(0, workspace.Gravity * s13 * 0.5, 0)

				if s4 > 2 then
					if not s10.mark then
						s10.mark = s4
						s10.clock = 0
					end

					s10.clock = s10.clock + s9

					if s10.clock >= 0.4 then
						if s10.mark - s4 < s8 * 0.1 then
							pcall(function()
								s6.CFrame = s6.CFrame + s2.Unit * math.min(s4, s8 * s13)
							end)
						end

						s10.mark = s4
						s10.clock = 0
					end
				else
					s10.mark = nil
				end

				pcall(function()
					s6.AssemblyLinearVelocity = s7_1
					s6.AssemblyAngularVelocity = Vector3.zero
				end)

				return s4 <= 0.5
			end

			r315 = function()
				local s2 = r247.Root()

				if s2 then
					pcall(function()
						s2.AssemblyLinearVelocity = Vector3.zero
						s2.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			local r316 = nil
			local r317 = {}

			r318 = function()
				r312 = nil

				if r313 then
					r313:Disconnect()
					r313 = nil
				end

				if r316 then
					r316:Disconnect()
					r316 = nil
				end
			end

			r319 = function()
				local s2 = tonumber(r232:GetAttribute("RagdollEndTime"))
				return s2 ~= nil and s2 > workspace:GetServerTimeNow()
			end

			local r320 = false

			local function r321()
				if r320 then
					return true
				end
				return true
			end

			r322 = function(s33, s34)
				r312 = s33
				r320 = s34 == true
				local s2 = r313
				local s3

				if r313 then
					s3 = s2
				else
					s3 = not s33
				end

				if s3 then
					return
				end
				r317 = {}

				r313 = r137.Heartbeat:Connect(function()
					if not r312 or r321() or r319() or r247.AntiGuard.Busy then
						return
					end
					local t2_1 = r247.Root()
					if not t2_1 then
						return
					end

					pcall(function()
						local u8 = t2_1.CFrame.Rotation
						t2_1.CFrame = CFrame.new(r312) * u8
						t2_1.AssemblyLinearVelocity = Vector3.zero
						t2_1.AssemblyAngularVelocity = Vector3.zero
					end)
				end)

				r316 = r137.PreSimulation:Connect(function(t35)
					if not r312 or not r321() or r319() or r247.AntiGuard.Busy then
						return
					end
					local t32 = r247.Root()

					if t32 then
						r314(t32, r312, r277, t35, r317)
					end
				end)
			end
		end

		r240(r318)
		local r323

		r323 = function()
			r318()
			r247.EndFlight()
			r247.GodMode(false)
			local s5 = r232.Character
			local s10 = s5 and s5:FindFirstChildOfClass("Humanoid")

			if s10 then
				s10.PlatformStand = false
			end
		end

		local r326, r329, r330

		do
			local r325 = 1.5
			r326 = 0.6

			local function r327(s2, s3)
				return (Vector3.new(s2.X, 0, s2.Z) - Vector3.new(s3.X, 0, s3.Z)).Magnitude
			end

			local function r328(s29)
				local s26, s27 = pcall(function()
					return s29:GetPivot().Position
				end)

				return s26 and s27 or nil
			end

			r329 = function(s15, s16, s19)
				local s10 = r327(s15.Position, s19)
				local s6 = workspace:FindFirstChild("AreaEggSlotsClient")

				if s6 then
					for _, s4 in ipairs(s6:GetChildren()) do
						if s4:IsA("Model") and s4.Name ~= s16 then
							local s18_1 = r328(s4)
							if s18_1 and r327(s18_1, s15.Position) + r325 < s10 then
								return false
							end
						end
					end
				end

				for _, s8 in ipairs(workspace:GetChildren()) do
					if s8:IsA("Model") and s8.Name ~= s16 and #s8.Name == 32 and s8:FindFirstChild("Hitbox") then
						local s18_2 = r328(s8)
						if s18_2 and r327(s18_2, s15.Position) + r325 < s10 then
							return false
						end
					end
				end

				return true
			end

			r247.Steal.WrongEgg = function(s20)
				local s1 = r247.Steal
				if type(s20) ~= "string" or not s1.Carrying or s1.CarryUid == s20 then
					return false
				end
				local s2_2 = r234.EggState

				if type(s2_2) == "table" and type(s2_2.DropFieldEgg) == "function" then
					pcall(s2_2.DropFieldEgg, "PlayerRequest")
				end

				local s2_3 = 0

				while s1.Carrying and s2_3 < 1 do
					s2_3 += r137.Heartbeat:Wait()
				end

				s1.Carrying = false
				s1.CarryUid = s20
				return true
			end

			r330 = function(s25, s26, arg3)
				local s27 = arg3 or 14
				local s7 = nil
				local s4 = nil

				for _, s3 in ipairs(workspace:GetChildren()) do
					if s3.Name == "SmartPromptPart" and s3:IsA("BasePart") then
						local s6_1 = s3:FindFirstChild("CarryAreaEgg")

						if s6_1 and s6_1:IsA("ProximityPrompt") then
							local s28_1 = r327(s3.Position, s26)

							if s28_1 < s27 then
								s27 = s28_1
								s7 = s6_1
								s4 = s3
							end
						end
					end
				end

				if not s7 or not s4 then
					return nil
				end

				if type(s25) == "string" and not r329(s4, s25, s26) then
					return nil
				end
				return s7, s4
			end
		end

		local r331

		r331 = function(s36)
			local s1 = r234.EggState

			if type(s36) == "string" and type(s1) == "table" and type(s1.CarryFieldEgg) == "function" then
				pcall(s1.CarryFieldEgg, s36)
			end
		end

		local r336

		do
			local function r332()
				local s2 = r247.Steal.CarryUid
				return type(s2) == "string" and s2 or nil
			end

			local function r333(s33)
				local s1 = r332()
				if not s1 or type(s33) ~= "string" then
					return true
				end
				return s1 == s33
			end

			local function r334(s13)
				if type(s13) ~= "string" then
					return false
				end
				local s7 = r310(false, true)
				if #s7 == 0 then
					return true
				end

				for _, s4 in ipairs(s7) do
					if s4.Uid == s13 then
						return true
					end
				end

				return false
			end

			local function r335(s14)
				local s2 = r234.EggState

				if type(s2) == "table" and type(s2.DropFieldEgg) == "function" then
					pcall(s2.DropFieldEgg, "PlayerRequest")
				end

				local s2_1 = 0

				while r247.Steal.Carrying and s2_1 < 1 and not r295(s14) do
					s2_1 += r137.Heartbeat:Wait()
				end
			end

			r336 = function(s35, s36)
				local s3 = 0

				while not r247.Steal.Carrying and s3 < r326 and not r295(s36) do
					s3 += r137.Heartbeat:Wait()
				end

				if not r247.Steal.Carrying then
					r20_2 = "The egg never reached the hand"
					return false
				end

				if r333(s35) then
					return true
				end
				local s1_1 = r332()
				if r334(s1_1) then
					r20_2 = "Holding another egg that still matches, delivering it"
					return true
				end
				r20_2 = "Wrong egg in hand, dropping it"
				r335(s36)
				return false
			end
		end

		local r337

		r337 = function(s35, s36)
			local s5 = r234.EggState
			local s4 = typeof(s35.CFrame) == "CFrame" and s35.CFrame.Position or nil
			if not s4 then
				return false
			end
			local s8 = 0
			local s9 = math.huge
			local s10 = 0

			while s8 < 1.5 do
				if r295(s36) then
					return false
				end

				if r247.Steal.Carrying and not r247.Steal.WrongEgg(s35.Uid) then
					return true
				end

				if s9 >= 0.06 then
					local s2_3 = r330(s35.Uid, s4)

					if s2_3 then
						pcall(function()
							s2_3.HoldDuration = 0
						end)

						s10 = 0

						if typeof(fireproximityprompt) == "function" then
							pcall(fireproximityprompt, s2_3)
						end
					else
						s10 += 1
						if s10 >= 4 then
							return false
						end

						if type(s5) == "table" and type(s5.CarryFieldEgg) == "function" then
							pcall(s5.CarryFieldEgg, s35.Uid)
						end
					end

					s9 = 0
				end

				local s2_2 = r137.Heartbeat:Wait()
				s8 += s2_2
				s9 += s2_2
			end

			return r247.Steal.Carrying == true
		end

		local r339

		local r338 = r233(function()
			return r181.Shared.Modules.Ragdoll
		end)

		r339 = function()
			local s10 = r232.Character

			if type(r338) == "table" and type(r338.IsRagdolled) == "function" then
				local s4_1, s5 = pcall(r338.IsRagdolled, s10)
				if s4_1 and s5 == true then
					return true
				end
			end

			local s4_2 = tonumber(r232:GetAttribute("RagdollEndTime"))
			if s4_2 and s4_2 > workspace:GetServerTimeNow() then
				return true
			end
			s10 = s10 and s10:FindFirstChildOfClass("Humanoid")
			if s10 then
				local s4_3 = s10:GetState()
				return s4_3 == Enum.HumanoidStateType.Physics or s4_3 == Enum.HumanoidStateType.Ragdoll or s4_3 == Enum.HumanoidStateType.FallingDown
			end
			return false
		end

		local r342, r343, r344, r347, r3_6, r349

		do
			local function r340(s17, s18)
				if r247.Steal.Carrying then
					return true
				end
				local s8 = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not s8 or not s8:IsA("RemoteFunction") then
					return false
				end
				local s7 = 0

				while s7 < 1 do
					if r295(s18) or r247.Steal.Carrying then
						return r247.Steal.Carrying == true
					end
					local s3_1, s4 = pcall(s8.InvokeServer, s8)
					local s6 = s3_1 and type(s4) == "table" and s4.Records or nil

					if type(s6) == "table" then
						local s6_1 = false

						for _, s4_1 in pairs(s6) do
							local s10 = type(s4_1) == "table" and s4_1.Uid == s17
							local s12

							if s10 then
								s12 = s4_1.State == "Slot" or s4_1.State == "Dropped"
							else
								s12 = s10
							end

							if s12 then
								s6_1 = true
								break
							end
						end

						if not s6_1 then
							return r247.Steal.Carrying == true
						end
					end

					s7 += task.wait(0.3)
				end

				return r247.Steal.Carrying == true
			end

			local function r341(s20)
				local s1 = r247.Root()
				local s3 = typeof(s20.CFrame) == "CFrame" and s20.CFrame.Position or nil
				if not s1 or not s3 then
					return math.huge
				end
				return (s1.Position - s3).Magnitude
			end

			r342 = function(s28)
				local s4 = math.huge
				local s5 = nil

				for _, s3 in ipairs(s28) do
					local s7 = r341(s3)

					if s7 < s4 then
						s4 = s7
						s5 = s3
					end
				end

				return s5, s4
			end

			r343 = 20
			r344 = 90
			local r345 = 6

			r347 = function(s30, s31, s32, s33, s34, s35)
				r318()
				local s1 = r247.Root()
				if not s1 then
					return false
				end
				local s5 = r232.Character
				local s6 = s1.Position
				local s8 = {}
				local s9 = nil
				local s10 = nil
				local s11 = nil
				local s12 = 0

				local function s13()
					if s33 ~= nil then
						return true
					end
					return true
				end

				local function s15(arg1)
					s12 += arg1
					if r295(s31) then
						s10 = false
						return nil
					end

					if s32 and not r247.Steal.Carrying then
						s10 = false
						s11 = "dropped"
						return nil
					end

					if s35 then
						local t2 = s35()

						if t2 then
							s10 = false
							s11 = t2
							return nil
						end
					end

					local t4_1 = r247.Root()

					if not t4_1 or s12 >= 25 or r232.Character ~= s5 then
						s10 = false
						s11 = "respawned"
						return nil
					end

					return t4_1
				end

				local s1_1 = r137.Heartbeat:Connect(function(t32)
					if s10 ~= nil or s13() or r247.AntiGuard.Busy then
						return
					end
					local t5 = s15(t32)
					if not t5 then
						return
					end

					if (t5.Position - s6).Magnitude > r311 then
						if s34 then
							s10 = false
							s11 = "displaced"
							return
						end

						s6 = t5.Position
					end

					local t30 = (s33 or r275) * (os.clock() < (r247.SafeCarry.SlowUntil or 0) and r247.SafeCarry.SlowFactor or 1)
					local t29

					if r247.SafeCarry.Enabled and r247.SafeCarry.Pace then
						t29 = math.min(t30, r247.SafeCarry.Pace())
					else
						t29 = t30
					end

					local t2_4 = s30 - s6
					local t30_1 = t29 * t32
					local t6_2 = t2_4.Magnitude <= math.max(t30_1, 0.05)
					s6 = t6_2 and s30 or s6 + t2_4.Unit * t30_1
					local t28 = Vector3.new(t2_4.X, 0, t2_4.Z)
					local t2_5 = t28.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, t28.Unit) or t5.CFrame.Rotation

					pcall(function()
						t5.CFrame = CFrame.new(s6) * t2_5
						t5.AssemblyLinearVelocity = Vector3.zero
						t5.AssemblyAngularVelocity = Vector3.zero
					end)

					if t6_2 then
						s10 = true
					end
				end)

				local s2 = r137.PreSimulation:Connect(function(t22)
					if s10 ~= nil or not s13() or r247.AntiGuard.Busy then
						return
					end
					local t21 = s15(t22)
					if not t21 then
						return
					end
					local t24 = (s33 or r275) * (os.clock() < (r247.SafeCarry.SlowUntil or 0) and r247.SafeCarry.SlowFactor or 1)
					local t23

					if r247.SafeCarry.Enabled and r247.SafeCarry.Pace then
						t23 = math.min(t24, r247.SafeCarry.Pace())
					else
						t23 = t24
					end

					if s34 and s9 and (t21.Position - s9).Magnitude > r311 + t23 * t22 then
						s10 = false
						s11 = "displaced"
						return
					end

					if r314(t21, s30, t23, t22, s8) then
						s10 = true
					end

					s9 = t21.Position
					s6 = t21.Position
				end)

				while s10 == nil do
					r137.Heartbeat:Wait()
				end

				s1_1:Disconnect()
				s2:Disconnect()

				if s13() and not s10 then
					r315()
				end

				if s10 then
					r322(s30, s33 ~= nil)
				end

				return s10, s11
			end

			local r5_8 = {
				{
					Path = { "GearGiver_Slap", "Podium" },
					Offset = Vector3.new(-16.415, 21.072, -6.106),
				},
				{
					Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
				{
					Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
					Offset = Vector3.new(-26.776, 1.75, 18.665),
				},
			}

			r3_6 = function()
				for _, s4 in ipairs(r5_8) do
					local s16 = workspace

					for _, s8 in ipairs(s4.Path) do
						s16 = s16 and s16:FindFirstChild(s8) or nil
					end

					if s16 and s16:IsA("BasePart") then
						return s16.CFrame:PointToWorldSpace(s4.Offset)
					end
				end

				return Vector3.new(528.7, 70.57, -364.11)
			end

			r247.StealHome = r3_6

			r247.InsideBase = function(s5)
				if not s5 then
					s5 = r247.Root()
					s5 = s5 and s5.Position
				end

				if s5 == nil then
					return false
				end
				local s9 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s9 = s9 and s9:FindFirstChild("Areas")
				s9 = s9 and s9:FindFirstChild("SeparationLine")
				return s5.X < (s9 and s9:IsA("BasePart") and s9.Position.X or 552)
			end

			local function r6_8(s9)
				if r247.AntiGuard.Busy then
					return false
				end
				local s11 = r232.Character
				local s13 = r247.Root()
				if not s11 or not s13 then
					return false
				end
				local s3_1 = s13.CFrame.Rotation
				local s15 = CFrame.new(s9) * s3_1

				pcall(function()
					s11:PivotTo(s15)
				end)

				if (s13.Position - s9).Magnitude > 3 then
					pcall(function()
						s13.CFrame = s15
					end)
				end

				for _, s4 in ipairs(s11:GetDescendants()) do
					if s4:IsA("BasePart") then
						pcall(function()
							s4.AssemblyLinearVelocity = Vector3.zero
							s4.AssemblyAngularVelocity = Vector3.zero
						end)
					end
				end

				return true
			end

			local function r12_3(s2)
				if r247.AntiGuard.Busy then
					return
				end
				local s8 = r232.Character
				local s13 = r247.Root()
				if not s8 or not s13 or not s2 then
					return
				end

				if (s13.Position - s2).Magnitude > 6 then
					r6_8(s2)
					return
				end

				for _, s4_1 in ipairs(s8:GetDescendants()) do
					if s4_1:IsA("BasePart") and s4_1 ~= s13 and (s4_1.Position - s13.Position).Magnitude > 12 then
						pcall(function()
							s4_1.CFrame = s13.CFrame
							s4_1.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end

			local function r13_2(s9, s10)
				local s7 = 0

				while true do
					if not (s7 < r345) then
						return not r295(s9)
					else
						if r295(s9) then
							break
						end
						local s15 = r232.Character
						local s18 = r339()

						if not s18 and s15 then
							for _, s4 in ipairs(s15:GetDescendants()) do
								if s4:IsA("Constraint") and string.find(s4.Name, "RagdollConstraint", 1, true) then
									s18 = true
									break
								end
							end
						end

						if not s18 then
							return not r295(s9)
						end
						r12_3(s10)
						s7 += r137.Heartbeat:Wait()
					end
				end

				return false
			end

			local function r348(s13)
				local s10 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s10 = s10 and s10:FindFirstChild("Areas")
				s10 = s10 and s10:FindFirstChild("GuardAreas")
				local s6 = s10 and s13 and s13.AreaId and s10:FindFirstChild(s13.AreaId)
				return s6 and s6:FindFirstChild("Guard") or nil
			end

			r349 = function(s17)
				local s16 = r348(s17)
				return s16 ~= nil and s16:GetAttribute("GuardState") == "Sleeping"
			end

			local r350 = 3

			local function r351(s31)
				local s5 = r348(s31)
				local s6 = typeof(s31.CFrame) == "CFrame" and s31.CFrame.Position or nil
				if not s5 or not s6 then
					return nil, nil
				end

				local s29, s30 = pcall(function()
					return s5:GetPivot().Position
				end)

				if not s29 then
					return nil, nil
				end
				local s1_1 = Vector3.new(s6.X - s30.X, 0, s6.Z - s30.Z)
				if s1_1.Magnitude < 0.1 then
					return nil, nil
				end
				local s4 = s30 + s1_1.Unit * r350
				return Vector3.new(s4.X, s6.Y + 3, s4.Z), s30
			end

			local function r352(s25, arg2)
				local s3 = { Landed = false, Destination = arg2 }
				local s1 = r247.AntiGuard
				s1.HitArms = s1.HitArms + 1
				r247.AntiGuard.HitArmedAt = os.clock()

				s3.Link = r232:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
					if s3.Landed or r295(s25) then
						return
					end
					local t2_1 = tonumber(r232:GetAttribute("RagdollEndTime"))
					if not t2_1 or t2_1 <= workspace:GetServerTimeNow() then
						return
					end
					local t2_2 = r247.Root()
					if not t2_2 then
						return
					end
					s3.Landed = true
					r318()
					r247.SafeCarry.JumpDistance = (s3.Destination - t2_2.Position).Magnitude
					r247.SafeCarry.JumpAt = os.clock()

					pcall(function()
						t2_2.CFrame = CFrame.new(s3.Destination)
						t2_2.AssemblyLinearVelocity = Vector3.zero
					end)
				end)

				s3.Stop = function()
					if s3.Link then
						s3.Link:Disconnect()
						s3.Link = nil
						r247.AntiGuard.HitArms = math.max(0, r247.AntiGuard.HitArms - 1)
					end
				end

				return s3
			end

			local function r353(s8, s9, s10)
				local s4 = r232.Character
				s4 = s4 and s4:FindFirstChildOfClass("Humanoid")

				if s4 then
					s4.PlatformStand = false
				end

				local s2 = 0
				local s4_1 = nil

				while true do
					if not s9.Landed and s2 < r343 then
						if not r295(s8) then
							if s10 then
								s10(s9)
							end

							if not r247.Steal.Carrying then
								s4_1 = s4_1 or s2
								if not (s2 - s4_1 > 1) then
									s2 += r137.Heartbeat:Wait()
									continue
								end
							else
								s2 += r137.Heartbeat:Wait()
								continue
							end
						end
					end

					break
				end

				s9.Stop()
				return s9.Landed
			end

			local r354 = 20

			local function r355(s25, s26, s27, s28)
				local s3 = typeof(s25.CFrame) == "CFrame" and s25.CFrame.Position or nil
				if not s3 then
					return false
				end
				local s6 = 0
				local s7 = math.huge

				while s6 < s27 do
					if r295(s26) then
						return false
					end

					if r247.Steal.Carrying and not r247.Steal.WrongEgg(s25.Uid) then
						return true
					end

					if s7 >= 0.1 then
						local s1_1 = r330(s25.Uid, s3)

						if s1_1 then
							pcall(function()
								s1_1.HoldDuration = 0
							end)

							if typeof(fireproximityprompt) == "function" then
								pcall(fireproximityprompt, s1_1)
							end
						else
							r331(s25.Uid)
						end

						s7 = 0
					end

					if s28 then
						r12_3(s28)
					end

					local s1_2 = r137.Heartbeat:Wait()
					s6 += s1_2
					s7 += s1_2
				end

				return r247.Steal.Carrying == true
			end

			local function r356(s36, s37, s38, s39)
				local s2 = typeof(s36.CFrame) == "CFrame" and s36.CFrame.Position or nil
				if not s2 then
					return false
				end
				local s4 = s2 + Vector3.new(0, 3, 0)
				local s3 = r232.Character
				local s7 = s3 and s3:FindFirstChildOfClass("Humanoid")

				if s7 and s3:FindFirstChildWhichIsA("Tool") then
					pcall(function()
						s7:UnequipTools()
					end)
				end

				if s38 then
					r322(s4, true)
					r20_2 = "Waiting to stand up"
					if not r13_2(s37, s4) then
						return false
					end

					if r247.SafeCarry.Enabled and s39 == nil and r247.SafeCarry.Settle then
						if not r247.SafeCarry.Settle(s37, s36) then
							return false
						end
					end
				else
					r20_2 = "Jumping to the egg"
					local s2_1 = r247.Root()

					if s2_1 and (s4 - s2_1.Position).Magnitude <= r344 then
						pcall(function()
							local t8 = s2_1.CFrame.Rotation
							s2_1.CFrame = CFrame.new(s4) * t8
							s2_1.AssemblyLinearVelocity = Vector3.zero
							s2_1.AssemblyAngularVelocity = Vector3.zero
						end)
					elseif not r347(s4, s37, nil, r277) then
						return false
					end
				end

				if r295(s37) then
					return false
				end
				local s3_2 = s39 and typeof(s39.CFrame) == "CFrame"
				local s2_3 = nil

				if s3_2 then
					s2_3 = r352(s37, s39.CFrame.Position + Vector3.new(0, 3, 0))
				end

				local s5 = "FirstAreaEgg_" .. tostring(r232.UserId)
				local s8 = type(s36.Uid) == "string" and string.sub(s36.Uid, 1, #s5) == s5 and string.match(s36.Uid, "_([%w ]+:Slot_%d+)$") or nil
				s39 = s39 and s8
				local s3_4 = false

				if s39 then
					local s5_1 = r234.EggState

					if type(s5_1) == "table" and type(s5_1.CarryFieldEgg) == "function" then
						r20_2 = "Taking the starter egg"

						task.spawn(function()
							pcall(s5_1.CarryFieldEgg, s36.Uid, s8)
						end)

						local s10_1 = 0

						while not r247.Steal.Carrying and s10_1 < 0.8 do
							if r295(s37) then
								return false
							end
							s10_1 += r137.Heartbeat:Wait()
						end

						s3_4 = r247.Steal.Carrying == true
					end
				end

				if not s3_4 then
					r20_2 = "Taking the egg"
					local s43 = r337(s36, s37)

					if not s43 and not r295(s37) then
						r347(s4, s37, nil, r277)
						s3_4 = r337(s36, s37)
					else
						s3_4 = s43
					end
				end

				if not s3_4 and not r340(s36.Uid, s37) then
					if s2_3 then
						s2_3.Stop()
					end

					r292[s36.Uid] = os.clock() + r293
					r20_2 = "That egg would not come free"
					return false
				end

				if s2_3 then
					local s3_6 = r182:FindFirstChild("RE/GuardPatrol/ForestStrike")
					local s48 = r348(s36) or r348({ AreaId = "Forest" })
					local s10_2 = s48 and s48:FindFirstChild("HumanoidRootPart")

					if s3_6 and s3_6:IsA("RemoteEvent") and s10_2 then
						r20_2 = "Calling the guard strike"

						pcall(function()
							s3_6:FireServer({ EggUid = s36.Uid, GuardCFrame = s10_2.CFrame })
						end)
					end
				end

				r247.Steal.LastFinishedAt = os.clock()
				return true, s2_3
			end

			local r357 = math.huge
			local r358 = math.huge

			local function r360(s23, s24, s25)
				local s9 = nil
				local s21 = nil

				for _, s3 in ipairs(workspace:GetChildren()) do
					if s3.Name == "SmartPromptPart" and s3:IsA("BasePart") then
						local s4 = s3:FindFirstChild("CarryAreaEgg")

						if s4 and s4:IsA("ProximityPrompt") then
							local s5_1 = (s3.Position - s23).Magnitude

							if s5_1 < s24 then
								s24 = s5_1
								s9 = s4
								s21 = s3
							end
						end
					end
				end

				if s9 and s21 and type(s25) == "string" and not r329(s21, s25, s23) then
					return nil
				end
				return s9, s21
			end

			local function r361(s32)
				local s29 = workspace:FindFirstChild("AreaEggSlotsClient")
				local s1 = workspace:FindFirstChild(s32) or s29 and s29:FindFirstChild(s32)
				if not s1 then
					return nil
				end

				local s30_1, s31 = pcall(function()
					return s1:GetPivot().Position
				end)

				return s30_1 and s31 or nil
			end

			local function r362(s7)
				local s3 = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
				if not s3 or not s3:IsA("RemoteFunction") then
					return nil
				end
				local s2_1, s3_1 = pcall(s3.InvokeServer, s3)
				local s3_2 = s2_1 and type(s3_1) == "table" and s3_1.Records or nil
				if type(s3_2) ~= "table" then
					return nil
				end

				for _, s4 in pairs(s3_2) do
					if type(s4) == "table" and s4.Uid == s7 and typeof(s4.BottomCFrame) == "CFrame" then
						return s4.BottomCFrame.Position, true
					end
				end

				return nil, true
			end

			local function r363(s37)
				local s8 = workspace:FindFirstChild(s37)
				if not s8 then
					return false
				end

				for _, s3 in ipairs(s8:GetDescendants()) do
					if s3:IsA("JointInstance") or s3:IsA("WeldConstraint") or s3:IsA("RigidConstraint") then
						local s35, s36, s37_1 = pcall(function()
							return s3.Part0, s3.Part1
						end)

						if s35 then
							for _, s6 in ipairs({ s36, s37_1 }) do
								if typeof(s6) == "Instance" and not s6:IsDescendantOf(s8) then
									local s33 = s6:FindFirstAncestorOfClass("Model")
									if s33 and s33 ~= r232.Character and r136:GetPlayerFromCharacter(s33) then
										return true
									end
								end
							end
						end
					end
				end

				return false
			end

			local function r365(arg1, arg2)
				local state = 1
				local s10, s11, s4, s3, s1, s6, s7, s8, s9, s21, s22, s24, s26, s12, s14, s15, s13, s2, s19, s2_1, s12_1

				while true do
					if state == 1 then
						s10 = arg1
						s11 = arg2

						if s11 then
							state = 3
						else
							state = 2
						end
					elseif state == 2 then
						s11 = r247.Steal.CarryUid
						state = 3
					elseif state == 3 then
						if type(s11) ~= "string" then
							state = 48
						else
							state = 4
						end
					elseif state == 4 then
						r318()
						r20_2 = "Following the egg"
						s4 = nil
						s3 = Vector3.zero

						s1 = r137.PreSimulation:Connect(function(t21)
							local t1 = r247.Root()
							if not t1 or not s4 or r247.Steal.Carrying or r295(s10) then
								return
							end

							if r319() then
								if not r247.SafeCarry.Enabled and (t1.Position - s4).Magnitude > 2 then
									r6_8(s4)
								end

								return
							end

							local t20 = math.max(t21, 0.0041666666666666666)
							local t3_1 = s3 + (s4 - t1.Position) / math.max(0.08, t20)
							local t4 = r247.SafeCarry.Enabled and r247.SafeCarry.Pace() or r277 + s3.Magnitude

							if t4 < t3_1.Magnitude then
								t3_1 = t3_1.Unit * t4
							end

							local t3_2 = t3_1 + Vector3.new(0, workspace.Gravity * t20 * 0.5, 0)

							pcall(function()
								t1.AssemblyLinearVelocity = t3_2
								t1.AssemblyAngularVelocity = Vector3.zero
							end)
						end)

						s6 = 0
						s7 = 0
						s8 = math.huge
						s9 = nil
						s21 = nil
						s22 = 0
						s24 = math.huge
						state = 5
					elseif state == 5 then
						s26 = false

						if not (s6 < r358) then
							state = 45
						else
							state = 6
						end
					elseif state == 6 then
						if r295(s10) then
							state = 45
						else
							state = 7
						end
					elseif state == 7 then
						if r247.Steal.Carrying then
							state = 8
						else
							state = 11
						end
					elseif state == 8 then
						if r247.Steal.WrongEgg(s11) then
							state = 10
						else
							state = 9
						end
					elseif state == 9 then
						s26 = true
						state = 45
					elseif state == 10 then
						r20_2 = "Picked up the wrong egg, dropped it"
						state = 11
					elseif state == 11 then
						s12 = r247.Root()

						if not s12 then
							state = 45
						else
							state = 12
						end
					elseif state == 12 then
						s14 = r361(s11)

						if s14 then
							state = 19
						else
							state = 13
						end
					elseif state == 13 then
						if s8 >= 0.5 then
							state = 14
						else
							state = 20
						end
					elseif state == 14 then
						s14, s15 = r362(s11)

						if s14 then
							state = 18
						else
							state = 15
						end
					elseif state == 15 then
						s8 = 0

						if s15 then
							state = 16
						else
							state = 20
						end
					elseif state == 16 then
						s7 += 1

						if not (s7 >= 4) then
							state = 20
						else
							state = 17
						end
					elseif state == 17 then
						r20_2 = "The egg is gone"
						state = 45
					elseif state == 18 then
						s7 = 0
						s8 = 0
						state = 20
					elseif state == 19 then
						s7 = 0
						state = 20
					elseif state == 20 then
						if s14 then
							state = 21
						else
							state = 30
						end
					elseif state == 21 then
						s13 = os.clock()

						if s9 then
							state = 23
						else
							state = 22
						end
					elseif state == 22 then
						s2 = s9
						state = 24
					elseif state == 23 then
						s2 = s21
						state = 24
					elseif state == 24 then
						if s2 then
							state = 25
						else
							state = 26
						end
					elseif state == 25 then
						s2 = s13 > s21
						state = 26
					elseif state == 26 then
						if s2 then
							state = 27
						else
							state = 29
						end
					elseif state == 27 then
						s19 = (s14 - s9) / math.max(s13 - s21, 0.0041666666666666666)

						if not (s19.Magnitude < 3000) then
							state = 29
						else
							state = 28
						end
					elseif state == 28 then
						s3 = s3:Lerp(s19, 0.3)
						state = 29
					elseif state == 29 then
						s4 = s14 + Vector3.new(0, 3, 0)
						s9 = s14
						s21 = s13
						state = 30
					elseif state == 30 then
						if s22 >= 0.4 then
							state = 31
						else
							state = 34
						end
					elseif state == 31 then
						if r363(s11) then
							state = 33
						else
							state = 32
						end
					elseif state == 32 then
						r20_2 = "Egg dropped, taking it back"
						s22 = 0
						state = 34
					elseif state == 33 then
						r20_2 = "Another player has the egg, following it until it drops"
						s22 = 0
						state = 34
					elseif state == 34 then
						if s4 then
							state = 36
						else
							state = 35
						end
					elseif state == 35 then
						s2_1 = s4
						state = 37
					elseif state == 36 then
						s2_1 = (s4 - s12.Position).Magnitude <= r354
						state = 37
					elseif state == 37 then
						if s2_1 then
							state = 38
						else
							state = 39
						end
					elseif state == 38 then
						s2_1 = s24 >= 0.1
						state = 39
					elseif state == 39 then
						if s2_1 then
							state = 40
						else
							state = 44
						end
					elseif state == 40 then
						s12_1 = r360(s4 - Vector3.new(0, 3, 0), 6, s11)

						if s12_1 then
							state = 42
						else
							state = 41
						end
					elseif state == 41 then
						task.spawn(r331, s11)
						s24 = 0
						state = 44
					elseif state == 42 then
						pcall(function()
							s12_1.HoldDuration = 0
						end)

						s24 = 0

						if typeof(fireproximityprompt) == "function" then
							state = 43
						else
							state = 44
						end
					elseif state == 43 then
						pcall(fireproximityprompt, s12_1)
						state = 44
					elseif state == 44 then
						local s2_2 = r137.Heartbeat:Wait()
						s6 += s2_2
						s24 += s2_2
						s8 += s2_2
						s22 += s2_2
						state = 5
					elseif state == 45 then
						s1:Disconnect()
						r315()

						if s26 then
							state = 47
						else
							state = 46
						end
					elseif state == 46 then
						s26 = r247.Steal.Carrying == true
						state = 47
					elseif state == 47 then
						return s26
					elseif state == 48 then
						return false
					end
				end
			end

			local function r366(s10, s11)
				local s4 = typeof(s10.CFrame) == "CFrame" and s10.CFrame.Position or nil
				if not s4 then
					return false
				end

				if r247.InsideBase() and not r247.InsideBase(s4) then
					local s2_2 = r3_6()

					if s2_2 then
						r20_2 = "Leaving the base through the safe zone"
						if not r347(s2_2 + Vector3.new(0, 3, 0), s11, nil, r277) then
							return false
						end
					end
				end

				r20_2 = "Flying to the egg"
				if not r347(s4 + Vector3.new(0, 3, 0), s11, nil, r277) then
					return false
				end
				r20_2 = "Taking the egg"
				local s13 = r355(s10, s11, 0.6, nil)

				if not s13 and not r295(s11) then
					s13 = r337(s10, s11)
				end

				if not s13 and not r340(s10.Uid, s11) then
					r292[s10.Uid] = os.clock() + r293
					return false
				end
				r247.Steal.LastFinishedAt = os.clock()
				return true
			end

			local r367 = { Uid = nil, Freed = nil, Token = nil }
			local r368 = 3

			local function r369()
				local s5 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s5 = s5 and s5:FindFirstChild("Areas")
				s5 = s5 and s5:FindFirstChild("GuardAreas")
				local s10 = r247.Root()
				if not s5 or not s10 then
					return nil
				end
				local s12 = tostring(r232.UserId)
				local s14 = r247.Steal.CarryAreaId and r348({ AreaId = tostring(r247.Steal.CarryAreaId) }) or nil
				local s16 = math.huge
				local s18 = nil

				for _, s3 in ipairs(s5:GetChildren()) do
					local s8 = s3:FindFirstChild("Guard")

					if s8 then
						if tostring(s8:GetAttribute("TargetPlayer")) == s12 or tostring(s8:GetAttribute("WakeTargetPlayer")) == s12 then
							return s8
						end

						local s6, s7 = pcall(function()
							return s8:GetPivot().Position
						end)

						if s6 then
							local s4 = (s7 - s10.Position).Magnitude

							if s4 < s16 then
								s18 = s8
								s16 = s4
							end
						end
					end
				end

				return s14 or s18
			end

			local function r370(s32, s33, s34)
				local s6 = r369()
				if not s6 then
					return false
				end
				local s1 = r352(s32, s34 + Vector3.new(0, 3, 0))
				local s7 = 0

				while true do
					if not s1.Landed and s7 < r343 and not r295(s32) then
						local s38, s39 = pcall(function()
							return s6:GetPivot().Position
						end)

						local s4 = r247.Root()

						if not (not s38 or not s4) then
							if r350 + 5 < (s39 - s4.Position).Magnitude then
								local s2_2 = Vector3.new(s4.Position.X - s39.X, 0, s4.Position.Z - s39.Z)
								local s2_3 = s39 + (s2_2.Magnitude > 0.1 and s2_2.Unit * r350 or Vector3.zero)

								r347(Vector3.new(s2_3.X, s39.Y + 3, s2_3.Z), s32, nil, r277, true, function()
									if s1.Landed then
										return "hit"
									end
									return nil
								end)
							end

							s7 += r137.Heartbeat:Wait()
							continue
						end
					end

					break
				end

				s1.Stop()
				if not s1.Landed then
					return false
				end
				return r365(s32, s33)
			end

			r247.SafeCarry.Dangers = {}
			r247.SafeCarry.DangerAt = 0

			r247.SafeCarry.RefreshDangers = function()
				local s17 = r247.SafeCarry
				local s3 = s17.DangerAt
				if os.clock() - s3 < 1 then
					return s17.Dangers
				end
				s17.DangerAt = os.clock()
				local s18 = {}

				local function s20(t23)
					local t24, t2, t26 = pcall(function()
						if t23:IsA("Model") then
							return t23:GetBoundingBox()
						end

						if t23:IsA("BasePart") then
							return t23.CFrame, t23.Size
						end
					end)

					if t24 and t2 and t26 then
						local t1_1 = math.abs
						local t4 = t26.Z
						local t26_1 = Vector3.new(math.abs(t26.X), 0, t1_1(t4)) * 0.5
						local t24_1 = (t2 - t2.Position):VectorToWorldSpace(t26_1)
						local t6 = t26_1.X
						local t7 = t26_1.Z
						local t4_1 = math.max(math.abs(t24_1.X), t6, t7)
						local t5 = t26_1.X
						local t27 = t26_1.Z
						local t24_2 = math.max(math.abs(t24_1.Z), t5, t27)

						table.insert(s18, {
							MinX = t2.Position.X - t4_1,
							MaxX = t2.Position.X + t4_1,
							MinZ = t2.Position.Z - t24_2,
							MaxZ = t2.Position.Z + t24_2,
							Name = t23.Name,
						})
					end
				end

				local function s21(t31)
					if t31 == "ScrambleLocalVisuals" or t31 == "DrScrambleEvent" then
						return false
					end
					local t28 = string.lower(t31)
					return string.find(t28, "portal", 1, true) or string.find(t28, "teleport", 1, true) or string.find(t28, "mech", 1, true) or string.find(t28, "arena", 1, true) or string.find(t28, "scramble", 1, true)
				end

				for _, s4 in ipairs(workspace:GetChildren()) do
					if (s4:IsA("Model") or s4:IsA("BasePart") or s4:IsA("Folder")) and s21(s4.Name) then
						if s4:IsA("Folder") then
							for _, s8 in ipairs(s4:GetChildren()) do
								s20(s8)
							end
						else
							s20(s4)
						end
					end
				end

				local s2 = workspace:FindFirstChild("World")
				local s3_2 = s2 and s2:FindFirstChild("Build")

				if s3_2 then
					for _, s12 in ipairs(s3_2:GetChildren()) do
						if s21(s12.Name) then
							for _, s15 in ipairs(s12:GetChildren()) do
								s20(s15)
							end
						end
					end
				end

				s17.Dangers = s18
				return s18
			end

			r247.SafeCarry.Avoid = function(s8, s9)
				for _, s3 in ipairs(r247.SafeCarry.RefreshDangers()) do
					local s13 = s3.MinX - 12
					local s14 = s3.MaxX + 12
					local s19 = s3.MinZ - 12
					local s20 = s3.MaxZ + 12
					local s5, s6, s7 = ipairs({ { s8.X, s9.X - s8.X, s13, s14 }, { s8.Z, s9.Z - s8.Z, s19, s20 } })
					local s21 = true
					local s11 = 0
					local s17 = 1

					for _, s7_1 in s5, s6, s7 do
						local s10 = s7_1[1]
						local s12 = s7_1[2]
						local s16 = s7_1[3]
						local s18 = s7_1[4]

						if math.abs(s12) < 1e-06 then
							if s10 < s16 or s10 > s18 then
								s21 = false
							end
						else
							local s16_1 = (s16 - s10) / s12
							local s10_1 = (s18 - s10) / s12
							local s12_1, s18_1

							if s16_1 > s10_1 then
								s12_1 = s10_1
								s18_1 = s16_1
							else
								s12_1 = s16_1
								s18_1 = s10_1
							end

							local s10_2 = math.max(s11, s12_1)
							local s16_2 = math.min(s17, s18_1)

							if not (s16_2 < s10_2) then
								s11 = s10_2
								s17 = s16_2
							else
								s21 = false
								s11 = s10_2
								s17 = s16_2
							end
						end
					end

					if s21 and not (s8.X >= s13 and s8.X <= s14 and s8.Z >= s19 and s8.Z <= s20) then
						local s1 = s19 - 2
						local s2_1 = s20 + 2
						local s20_1 = math.abs(s8.Z - s1) <= math.abs(s8.Z - s2_1) and s1 or s2_1

						if s20_1 < -440 or s20_1 > -290 then
							s20_1 = s20_1 == s1 and s2_1 or s1
						end

						local s18_2 = math.abs(s8.X - s13) <= math.abs(s8.X - s14) and s13 or s14

						if math.abs(s8.Z - s20_1) < 3 then
							s18_2 = math.abs(s9.X - s13) <= math.abs(s9.X - s14) and s13 or s14
						end

						local s1_1 = s3.Name
						return Vector3.new(s18_2, s9.Y, s20_1), s1_1
					end
				end

				return s9, nil
			end

			r247.SafeCarry.NewHuman = function(s11)
				local s2 = r247.SafeCarry
				local s9 = s2.LaneOffset
				local s3

				s3 = {
					Clock = 0,
					Factor = 1,
					Target = 1,
					NextShift = 0,
					Phase = math.random() * 3.1415926535897931 * 2,
					Period = 2 + math.random() * 2.5,
					PauseUntil = 0,
					Lane = (math.random() * 2 - 1) * s9,
					Step = function(t18, t19, t20)
						s3.Clock = s3.Clock + t18

						if s3.NextShift <= s3.Clock then
							s3.NextShift = s3.Clock + 0.5 + math.random()
							local t1_1 = math.max(s2.SpeedJitter, 0)

							if s11 then
								s3.Target = 1 - math.random() * t1_1
							else
								s3.Target = 1 + (math.random() * 2 - 1) * t1_1
							end
						end

						s3.Factor = s3.Factor + (s3.Target - s3.Factor) * math.min(t18 * 3, 1)
						local t2 = s2.Wobble
						local t1 = math.sin(s3.Clock * 2 * 3.1415926535897931 / s3.Period + s3.Phase) * t2
						local t2_1 = t20 and t19 and s2.JumpsPerMinute > 0

						if t2_1 then
							local t4 = s2.JumpsPerMinute / 60 * t18
							t2_1 = math.random() < t4
						end

						if t2_1 then
							pcall(function()
								t19.Jump = true
							end)
						end

						local t3 = false

						if not s11 then
							if s3.Clock < s3.PauseUntil then
								t3 = true
							else
								local t4_1 = s2.PausesPerMinute > 0

								if t4_1 then
									local t6 = s2.PausesPerMinute / 60 * t18
									t4_1 = math.random() < t6
								end

								if t4_1 then
									s3.PauseUntil = s3.Clock + 0.3 + math.random() * 0.9
									t3 = true
								end
							end
						end

						return s3.Factor, s3.Lane + t1, t3
					end,
				}

				return s3
			end

			r247.SafeCarry.React = function(s35, s36)
				local s32 = math.max(0, math.min(s35, s36))
				local s34 = math.max(s35, s36, 0)
				return s32 + math.random() * (s34 - s32)
			end

			r247.SafeCarry.RunTo = function(s25, s26)
				local s11 = r247.SafeCarry
				local s12 = typeof(s25.CFrame) == "CFrame" and s25.CFrame.Position or nil
				if not s12 then
					return false
				end
				r318()
				local s3 = r232.Character
				local s4 = s3 and s3:FindFirstChildOfClass("Humanoid")

				if s4 then
					s4.PlatformStand = false

					if s3:FindFirstChildWhichIsA("Tool") then
						pcall(function()
							s4:UnequipTools()
						end)
					end
				end

				local s13 = s11.NewHuman(false)
				local s2_1 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s2_1 = s2_1 and s2_1:FindFirstChild("Areas")
				s2_1 = s2_1 and s2_1:FindFirstChild("SeparationLine")
				local s27 = s2_1 and s2_1:IsA("BasePart") and s2_1.Position.X or 552
				local s45 = r3_6()
				local s46 = r247.Root()
				local s47 = "field"
				local s3_1 = s46 and s46.Position.Z or s12.Z

				if s46 and s45 and s46.Position.X < s27 - 2 then
					local s2_3 = s45.Z

					if (Vector3.new(s46.Position.X, 0, s46.Position.Z) - Vector3.new(s45.X, 0, s45.Z)).Magnitude > 20 then
						s47 = "safe"
					end

					s3_1 = s2_3
				end

				local s7 = math.clamp(s3_1 + s13.Lane, -425, -300)
				local s48 = s12.Y + 3

				local function s49()
					local t7 = r247.Root()
					local t9 = r232.Character
					if s11.RunHeight <= 0.5 or not t7 or not t9 then
						return
					end
					local t4_1 = s11.RunHeight
					local t3_1 = math.max(t7.Position.Y, s48) + t4_1

					if t7.Position.Y < t3_1 - 2 then
						pcall(function()
							local u6 = t7.CFrame.Rotation
							t9:PivotTo(CFrame.new(Vector3.new(t7.Position.X, t3_1, t7.Position.Z)) * u6)
							t7.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end

				if s47 == "field" then
					s49()
				end

				local s50 = os.clock()
				local s2_4 = os.clock()
				local s52 = os.clock()
				s46 = s46 and s46.Position or nil

				local function s28(t10, t11, t12, t13)
					local t2 = Vector3.new(t11.X - t10.Position.X, 0, t11.Z - t10.Position.Z)
					local t15 = t2.Magnitude
					local t17 = t15 > 0.01 and t2.Unit or Vector3.zero

					if s11.RunHeight > 0.5 and s47 == "field" and not t13 then
						local t4_1 = s11.RunSpeed
						local t2_2 = math.max(r247.WalkSpeed() * t4_1 * t12, 8)
						local t3_1 = math.clamp(s11.ClimbShare, 0.1, 0.9)
						local t9 = s11.RunHeight * math.sqrt(1 - t3_1 * t3_1) / t3_1
						local t3_2 = math.clamp((s48 + s11.RunHeight * math.clamp(Vector3.new(s12.X - t10.Position.X, 0, s12.Z - t10.Position.Z).Magnitude / math.max(t9, 1), 0, 1) - t10.Position.Y) / 0.12, -t2_2 * t3_1, t2_2 * t3_1)
						local t2_3 = t17 * math.min(math.sqrt(math.max(t2_2 * t2_2 - t3_2 * t3_2, 0)), t15 / 0.05)

						pcall(function()
							t10.AssemblyLinearVelocity = Vector3.new(t2_3.X, t3_2, t2_3.Z)
						end)

						return
					end

					pcall(function()
						local u3 = t13
						local u4

						if t13 then
							u4 = u3
						else
							u4 = t15 <= 0.01
						end

						if u4 then
							if s4 then
								if s11.RunStyle == "Walk" then
									s4:MoveTo(t10.Position)
								end

								s4:Move(Vector3.zero, false)
							end

							if s11.RunStyle ~= "Walk" then
								t10.AssemblyLinearVelocity = Vector3.new(0, t10.AssemblyLinearVelocity.Y, 0)
							end
						elseif s11.RunStyle == "Walk" then
							if s4 then
								s4:MoveTo(t10.Position + t17 * math.min(t15, 30))
							end
						else
							local u4_1 = s11.RunSpeed
							local u2 = t17 * math.min(math.max(r247.WalkSpeed() * u4_1 * t12, 8), t15 / 0.05)
							t10.AssemblyLinearVelocity = Vector3.new(u2.X, t10.AssemblyLinearVelocity.Y, u2.Z)

							if s11.RunAnimate and s4 then
								s4:Move(t17, false)
							end
						end
					end)
				end

				while os.clock() - s50 < 240 do
					if r295(s26) then
						return false
					end
					local s6 = r247.Root()
					if not s6 then
						return false
					end
					local s53 = os.clock()
					local s2_5 = math.max(s53 - s2_4, 0.0041666666666666666)
					local s8 = Vector3.new(s12.X - s6.Position.X, 0, s12.Z - s6.Position.Z)
					if s47 == "field" and s8.Magnitude <= 2.5 and (s11.RunHeight <= 0.5 or s6.Position.Y - s48 < 4) then
						break
					end
					local s2_6, s31, s3_5 = s13.Step(s2_5, s4, s4 and s4.FloorMaterial ~= Enum.Material.Air)

					if s8.Magnitude <= 15 then
						s3_5 = false
					end

					local s32_1 = s12

					if s47 == "safe" and s45 then
						if (Vector3.new(s45.X, 0, s45.Z) - Vector3.new(s6.Position.X, 0, s6.Position.Z)).Magnitude <= 6 then
							s47 = "field"
							s49()
						end

						r20_2 = "Walking out to the safe zone"
						s32_1 = s45
					else
						if not s11.StraightRun and s11.RunHeight <= 0.5 and math.abs(s12.X - s6.Position.X) > 25 then
							s32_1 = Vector3.new(s12.X, s12.Y, math.clamp(s7 + s31, -425, -300))
						end

						r20_2 = string.format("Running to the egg, %d studs left", math.floor(s8.Magnitude + 0.5))
					end

					local s30_1, s31_1 = s11.Avoid(s6.Position, s32_1)

					if s31_1 then
						r20_2 = "Walking around " .. tostring(s31_1)
					end

					s28(s6, s30_1, s2_6, s3_5)

					if s53 - s52 >= 1.5 then
						if not s3_5 and s46 and (s6.Position - s46).Magnitude < 3 and s4 then
							pcall(function()
								s4.Jump = true
							end)
						end

						s46 = s6.Position
						s52 = s53
					end

					r137.Heartbeat:Wait()
					s2_4 = s53
				end

				local s29 = r247.Root()

				if s29 then
					s28(s29, s29.Position, 1, true)
				end

				local s9 = nil

				if s29 then
					local s40 = Vector3.new(s29.Position.X - s12.X, 0, s29.Position.Z - s12.Z)
					local s5_1 = s40.Magnitude > 0.1 and s40.Unit * 2 or Vector3.zero
					s9 = Vector3.new(s12.X + s5_1.X, s29.Position.Y, s12.Z + s5_1.Z)
				end

				local s39 = r137.Heartbeat:Connect(function()
					local t9 = r247.Root()
					if not t9 or not s9 or r247.Steal.Carrying or r247.AntiGuard.Busy then
						return
					end
					local t2_1 = Vector3.new(s9.X - t9.Position.X, 0, s9.Z - t9.Position.Z)

					pcall(function()
						if t2_1.Magnitude > 1.5 then
							local u3 = t9.CFrame.Rotation
							t9.CFrame = CFrame.new(s9.X, t9.Position.Y, s9.Z) * u3
						end

						t9.AssemblyLinearVelocity = Vector3.new(0, math.min(t9.AssemblyLinearVelocity.Y, 0), 0)
					end)
				end)

				local function s55(t19)
					s39:Disconnect()
					return t19
				end

				local s5_2 = r348(s25)
				local s56 = os.clock()
				local s10 = s11.React(s11.ReactMin, s11.ReactMax)

				while true do
					if r295(s26) then
						return (s55(false))
					else
						local s57 = os.clock() - s56
						local s58 = s11.RunWait + s10
						local s59 = not s11.WaitGuard or not s5_2 or s5_2:GetAttribute("GuardState") == "Sleeping"
						if s57 >= s58 and (s59 or s57 >= s58 + 15) then
							break
						end
						r20_2 = s57 < s58 and string.format("Waiting before the grab, %.1fs", s58 - s57) or "Waiting for the guard to sleep"
						r137.Heartbeat:Wait()
					end
				end

				r20_2 = "Taking the egg"
				local s40_1 = r355(s25, s26, 0.8, nil)

				if not s40_1 and not r295(s26) then
					s40_1 = r337(s25, s26)
				end

				s55()
				if not s40_1 then
					return false
				end
				r247.Steal.LastFinishedAt = os.clock()
				return true
			end

			r247.SafeCarry.Pace = function()
				local s2 = r247.SafeCarry
				return math.max(r247.WalkSpeed() * (tonumber(s2.RunSpeed) or 1), 16)
			end

			r247.SafeCarry.Plan = function(s10, s11, s12)
				local s17 = r247.SafeCarry
				local s6 = r232.Character

				if s6 then
					s6:FindFirstChildOfClass("Humanoid")
				end

				local s8 = r247.WalkSpeed()
				local s6_1 = s12 or s17.Mult or 1
				local s5

				if s17.SameSpeedBigEggs then
					s5 = math.max(s6_1, s17.LightMult)
				else
					s5 = s6_1
				end

				local s12_1 = s8 * s17.CarryRatio * s5
				local s6_2 = s12_1 * s17.SpeedRatio
				local s7 = s17.ExcessSeconds * s12_1
				local s5_2

				if s11 and s11 > s7 then
					s5_2 = math.min(s6_2, s12_1 * s11 / (s11 - s7))
				else
					s5_2 = s6_2
				end

				local s6_3 = r234.Guards
				local s8_1 = type(s6_3) == "table" and type(s6_3.Directory) == "table" and s6_3.Directory[tostring(s10)] or nil
				local s10_1 = type(s8_1) == "table" and tonumber(s8_1.WalkSpeed) or 0
				if not s17.BeatGuard then
					return math.max(math.min(s12_1 * s17.EasyRatio, s5_2), s12_1), true, s12_1, s5_2, s10_1
				end
				local s6_4 = math.max(s10_1 + s17.GuardMargin, s12_1 * s17.MinRatio)
				local s7_2 = math.max(s6_4, s10_1 * s17.GuardRatio)

				if s5_2 < s6_4 then
					local s15 = s12_1 * s17.SpeedRatio
					local s8_2 = s17.StretchSeconds * s12_1
					local s14

					if s11 and s11 > s8_2 then
						s14 = math.min(s15, s12_1 * s11 / (s11 - s8_2))
					else
						s14 = s15
					end

					local s8_3 = s10_1 + math.max(s17.GuardMargin, 1)
					if s8_3 <= s14 then
						return s8_3, true, s12_1, s14, s10_1
					end
				end

				return math.max(math.min(s7_2, s5_2), s12_1), s6_4 <= s5_2, s12_1, s5_2, s10_1
			end

			r247.SafeCarry.Unsafe = function(s12)
				local s2 = r247.SafeCarry
				if not s2.Enabled or type(s12) ~= "table" or not s12.Uid or not s2.Blocked[s12.Uid] then
					return nil
				end
				return string.format("the guard caught you with this %s before, skipping it", tostring(s12.Category))
			end

			r247.SafeCarry.Settle = function(s32, s33)
				local s4 = r247.SafeCarry
				local s35 = r232.Character

				if s35 then
					s35:FindFirstChildOfClass("Humanoid")
				end

				local s34 = math.max(r247.WalkSpeed() * s4.CarryRatio * (s4.Seen[tostring(s33.Category)] or s4.GuessMult) * s4.WaitRate, 1)
				local s5_1 = s4.BaseWait + math.max(0, (s4.JumpDistance or 0) - s4.FreeJump) / s34
				local s2_2 = r348(s33)

				while true do
					if r295(s32) then
						return false
					else
						local s6_1 = os.clock() - (s4.JumpAt or 0)
						local s7_1 = not s4.WaitGuard or not s2_2 or s2_2:GetAttribute("GuardState") == "Sleeping"
						if s6_1 >= s5_1 and (s7_1 or s6_1 >= s5_1 + 15) then
							break
						end

						if s6_1 < s5_1 then
							r20_2 = string.format("Letting the jump settle, %.1fs", s5_1 - s6_1)
						else
							r20_2 = "Waiting for the guard to sleep"
						end

						r137.Heartbeat:Wait()
					end
				end

				return true
			end

			r247.SafeCarry.Home = function(s16)
				local s8 = r247.SafeCarry
				local s9 = r3_6()
				local s1 = r247.Root()
				if not s9 or not s1 then
					return false
				end
				r318()
				local s18 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s18 = s18 and s18:FindFirstChild("Areas")
				s18 = s18 and s18:FindFirstChild("SeparationLine")
				local s6 = (s18 and s18:IsA("BasePart") and s18.Position.X or 552) - 7
				local s18_1 = r232.Character
				local s11 = s18_1 and s18_1:FindFirstChildOfClass("Humanoid")

				if s11 then
					s11.PlatformStand = false
				end

				local s3 = os.clock()
				local s12 = 0

				local function s24()
					local t2 = r247.Root()
					if not t2 then
						return
					end
					local t2_1, t7, t8, t5, t6 = s8.Plan(r247.Steal.CarryAreaId, (Vector3.new(t2.Position.X, 0, t2.Position.Z) - Vector3.new(s9.X, 0, s9.Z)).Magnitude + math.max(0, s8.Height) * 2, s8.Mult)
					local t2_2 = t2_1 * s8.CarryScale
					s12 = t2_2
					s8.PlanOk = t7
					s8.FloorSpeed = s8.BeatGuard and math.min(t6 + math.max(s8.GuardMargin, 1), t5) or 0
					r20_2 = string.format("Carrying home at %d (carry %d, guard %d, max %d)%s", math.floor(t2_2 + 0.5), math.floor(t8 + 0.5), math.floor(t6 + 0.5), math.floor(t5 + 0.5), t7 and "" or ", guard is faster, going at your max safe speed")
				end

				local function s25()
					local t2 = math.max(0, s8.Height)
					local t7 = r247.Root()
					local t9 = r232.Character
					if t2 <= 0.5 or not t7 or not t9 then
						return
					end
					local t4 = s9.Y + t2
					if t7.Position.Y >= t4 - 2 then
						return
					end
					local t3_1 = t7.CFrame.Rotation
					local t2_1 = CFrame.new(Vector3.new(t7.Position.X, t4, t7.Position.Z)) * t3_1

					pcall(function()
						t9:PivotTo(t2_1)
						t7.AssemblyLinearVelocity = Vector3.zero
						t7.AssemblyAngularVelocity = Vector3.zero
					end)
				end

				s24()
				local s26 = s8.NewHuman(true)
				local s2 = r247.Root()
				local s2_1 = math.clamp((s2 and s2.Position.Z or s9.Z) + s26.Lane, -425, -300)
				local s27 = os.clock()

				if s8.CarryReact > 0 then
					local s1_8 = os.clock() + s8.React(0, s8.CarryReact)

					while os.clock() < s1_8 and not r295(s16) do
						r137.Heartbeat:Wait()
					end
				end

				local s28 = 0

				if s8.CarryStyle ~= "Walk" then
					s25()
				end

				while not r295(s16) do
					local s31 = r247.Root()
					if not s31 then
						return false
					end

					if not r247.Steal.Carrying then
						if s3 <= s8.LastDelivered then
							return true
						end
						task.wait(0.1)
						if s3 <= s8.LastDelivered then
							return true
						end

						if s3 <= s8.LastFailed then
							r20_2 = "Delivery was rewound, too fast for your speed"
							return false
						end

						if not s8.PlanOk and r247.Steal.CarryUid then
							s8.Blocked[r247.Steal.CarryUid] = true
							r20_2 = string.format("The guard caught you with %s, it is faster than your max safe speed, skipping this egg", tostring(s8.Category))
							return false
						end

						s28 += 1
						if s8.RecoverTries < s28 then
							r20_2 = "The egg is gone"
							return false
						end
						r20_2 = "Egg dropped, taking it back"
						if not r365(s16) then
							r20_2 = "Could not take the egg back"
							return false
						end
						local s4_1 = 0

						while r339() and s4_1 < 4 and not r295(s16) do
							s4_1 += r137.Heartbeat:Wait()
						end

						local s18_2 = math.min(s3, os.clock())
						s24()

						if s8.CarryStyle ~= "Walk" then
							s25()
						end

						s31 = r247.Root()
						if not s31 then
							return false
						end
						s3 = s18_2
					end

					local s32 = os.clock()
					local s1_2 = math.max(s32 - s27, 0.0041666666666666666)
					local s7 = s8.CarryStyle == "Walk"
					local s4_2 = s7 and 0 or math.max(0, s8.Height)
					local s17_1, s18_3 = s26.Step(s1_2, s4_2 <= 0.5 and s11 or nil, s11 and s11.FloorMaterial ~= Enum.Material.Air)
					local s18_4 = math.clamp(s2_1 + s18_3, -425, -300)
					local s1_4 = s31.Position.X > s6 + 2 and Vector3.new(s6, s31.Position.Y, s18_4) or s9
					local s5_2, s19_2 = s8.Avoid(s31.Position, s1_4)

					if not s19_2 then
						s5_2 = s1_4
					end

					local s1_5 = Vector3.new(s5_2.X - s31.Position.X, 0, s5_2.Z - s31.Position.Z)
					if s1_5.Magnitude < 2 and s5_2 == s9 then
						break
					end
					local s18_7 = math.max(s12 * s17_1, s8.FloorSpeed or 0)

					if os.clock() < (s8.SlowUntil or 0) then
						s18_7 *= s8.SlowFactor
					end

					if s7 then
						pcall(function()
							if s11 and s1_5.Magnitude > 0.01 then
								s11:MoveTo(s31.Position + s1_5.Unit * math.min(s1_5.Magnitude, 30))
							end
						end)
					elseif s4_2 > 0.5 then
						local s19_4 = math.clamp(s8.ClimbShare, 0.1, 0.9)
						local s48 = s9.Y
						local s20_2 = math.max(0, s31.Position.X - s6)
						local s21 = s4_2 * math.sqrt(1 - s19_4 * s19_4) / s19_4
						local s51 = s48 + s4_2

						if s5_2 == s9 or s20_2 <= s21 then
							s51 = s48 + s4_2 * math.clamp((s5_2 == s9 and 0 or s20_2) / math.max(s21, 1), 0, 1)
						end

						local s19_5 = math.clamp((s51 - s31.Position.Y) / 0.12, -s18_7 * s19_4, s18_7 * s19_4)
						local s21_1 = math.sqrt(math.max(s18_7 * s18_7 - s19_5 * s19_5, 0))
						local s5_4 = s1_5.Magnitude > 0.01 and s1_5.Unit * math.min(s21_1, s1_5.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							s31.AssemblyLinearVelocity = Vector3.new(s5_4.X, s19_5, s5_4.Z)
						end)
					else
						local s4_5 = s1_5.Magnitude > 0.01 and s1_5.Unit * math.min(s18_7, s1_5.Magnitude / 0.05) or Vector3.zero

						pcall(function()
							s31.AssemblyLinearVelocity = Vector3.new(s4_5.X, s31.AssemblyLinearVelocity.Y, s4_5.Z)

							if s8.RunAnimate and s11 and s1_5.Magnitude > 0.01 then
								s11:Move(s1_5.Unit, false)
							end
						end)
					end

					r137.Heartbeat:Wait()
					s27 = s32
				end

				if s11 then
					pcall(function()
						local t5 = r247.Root()

						if s8.CarryStyle == "Walk" and t5 then
							s11:MoveTo(t5.Position)
						end

						s11:Move(Vector3.zero, false)
					end)
				end

				local s1_6 = 0

				while s1_6 < 2 and not r295(s16) do
					if s3 <= s8.LastDelivered then
						return true
					end

					if s3 <= s8.LastFailed then
						r20_2 = "Delivery was rewound, too fast for your speed"
						return false
					end

					if not r247.Steal.Carrying then
						break
					end
					s1_6 += r137.Heartbeat:Wait()
				end

				if r247.Steal.Carrying then
					task.wait(0.2)
					local s1_7 = r234.EggState

					if type(s1_7) == "table" and type(s1_7.DropFieldEgg) == "function" then
						pcall(s1_7.DropFieldEgg, "PlayerRequest")
					end
				end

				return s8.LastDelivered >= s3
			end

			local function r371(s31)
				local s17 = r247.AntiGuard

				if s17.Enabled then
					local s18 = 0

					while not s17.Busy and s18 < 1 and not r295(s31) do
						r20_2 = "Waiting for Anti Guard to start"
						s18 += r137.Heartbeat:Wait()
					end

					local s21 = s17.Busy
					local s22 = 0

					while s17.Busy and s22 < 30 and not r295(s31) do
						r20_2 = "Anti Guard is slipping past the guard"
						s22 += r137.Heartbeat:Wait()
					end

					if s21 then
						local s2 = 0
						local s3 = 0

						while true do
							if s2 < 10 and not r295(s31) then
								local s4_1 = r339()
								local s33, s34 = pcall(r247.Steal.HeldByMe)
								s33 = s33 and s34 == true
								local s6 = not s4_1

								if not (s6 and not s33) then
									if s6 and s33 and not s17.Busy then
										s3 += r137.Heartbeat:Wait()
										if not (s3 >= 0.3) then
											continue
										end
									else
										r20_2 = s4_1 and "The guard hit you, waiting until you can move" or "Waiting for Anti Guard to finish"
										s2 += r137.Heartbeat:Wait()
										s3 = 0
										continue
									end
								end
							end

							break
						end

						local s33_1, s34_1 = pcall(r247.Steal.HeldByMe)

						if s33_1 and not s34_1 then
							r247.Steal.Carrying = false
						end

						local s2_1 = r247.SafeCarry
						local s3_1 = r3_6()
						local s4_2 = s3_1 and s2_1.Enabled and s2_1.CarryStyle ~= "Walk" and s2_1.Height > 0.5 and s3_1.Y + s2_1.Height or nil
						local s3_2 = 0

						while s3_2 < 0.8 and r247.Steal.Carrying and not r295(s31) do
							r20_2 = s3_2 < 0.6 and "Anti Guard done, rising up" or "Anti Guard done, getting ready"
							local s6_3 = r247.Root()

							if s6_3 and s4_2 then
								local s7_1 = s4_2 - s6_3.Position.Y
								local s2_6 = s3_2 < 0.6 and math.clamp(s7_1 / math.max(0.6 - s3_2, 0.1), -120, 120) or math.clamp(s7_1 / 0.2, -30, 30)

								pcall(function()
									s6_3.AssemblyLinearVelocity = Vector3.new(0, s2_6, 0)
								end)
							end

							s3_2 += r137.Heartbeat:Wait()
						end

						local s33_2, s34_2 = pcall(r247.Steal.HeldByMe)

						if s33_2 and not s34_2 then
							r247.Steal.Carrying = false
						else
							r247.SafeCarry.SlowUntil = os.clock() + 2
						end
					end
				end

				local s2_7 = 0

				while not r247.Steal.Carrying and s2_7 < r326 and not r295(s31) do
					r20_2 = "Checking the egg in hand"
					s2_7 += r137.Heartbeat:Wait()
				end

				if not r247.Steal.Carrying then
					r20_2 = "The egg is gone, staying to look for it"
					if not r365(s31) then
						r20_2 = "The egg is gone"
						return false
					end
				end

				if r247.SafeCarry.Enabled then
					return r247.SafeCarry.Home(s31)
				end
				local s15 = r3_6()
				local s2_8 = r247.Root()
				if not s15 or not s2_8 then
					return false
				end
				local s4_3 = math.max(s2_8.Position.Y, s15.Y) + r276

				local function s39()
					if r367.Uid and r367.Freed and r247.Steal.Carrying then
						return "priority"
					end
					return nil
				end

				local s7_2 = true
				local s41 = 0

				while true do
					local s2_9 = r247.Root()

					if not s2_9 then
						return false
					else
						r20_2 = "Flying home"
						local s2_10 = s2_9.Position
						local s32 = math.max(s4_3, s2_10.Y)
						local s33_3, s6_4 = r347(Vector3.new(s2_10.X + (s15.X - s2_10.X) * 0.25, s2_10.Y + (s32 - s2_10.Y) * 0.7, s2_10.Z + (s15.Z - s2_10.Z) * 0.25), s31, s7_2, nil, nil, s39)

						if s33_3 then
							s33_3, s6_4 = r347(Vector3.new(s15.X, s32, s15.Z), s31, s7_2, nil, nil, s39)
						end

						if s33_3 then
							s33_3, s6_4 = r347(s15, s31, s7_2, nil, nil, s39)
						end

						if s33_3 then
							local s3_5 = r232.Character
							s3_5 = s3_5 and s3_5:FindFirstChildOfClass("Humanoid")

							if s3_5 then
								s3_5.PlatformStand = false
							end

							task.wait(0.2)
							if not r247.Steal.Carrying then
								r20_2 = "Arrived without the egg"
								return false
							end
							local s3_6 = r234.EggState

							if type(s3_6) == "table" and type(s3_6.DropFieldEgg) == "function" then
								pcall(s3_6.DropFieldEgg, "PlayerRequest")
							end

							return true
						end

						if s6_4 == "priority" then
							local s10 = r367.Uid
							local s11 = r367.Freed
							local s8_4 = r367
							r367.Uid = nil
							s8_4.Freed = nil
							local s2_11 = r247.Root()
							if not s2_11 or not s10 or not s11 then
								return false
							end

							if (s11 - s2_11.Position).Magnitude <= r277 * r368 then
								r20_2 = "Best egg fell nearby, swapping eggs"
								local s2_12 = r234.EggState

								if type(s2_12) == "table" and type(s2_12.DropFieldEgg) == "function" then
									pcall(s2_12.DropFieldEgg, "PlayerRequest")
								end

								local s2_13 = 0

								while r247.Steal.Carrying and s2_13 < 1 do
									s2_13 += r137.Heartbeat:Wait()
								end

								if not r365(s31, s10) then
									return false
								end
							else
								r20_2 = "Best egg fell far away, riding a guard hit to it"
								if not r370(s31, s10, s11) then
									return false
								end
							end

							local s2_14 = r247.Root()
							s41 = 0

							if s2_14 then
								s4_3 = math.max(s2_14.Position.Y, s15.Y) + r276
							end

							continue
						end

						if s6_4 == "dropped" and s41 < r357 then
							s41 += 1
							if not r365(s31) then
								return false
							end
							continue
						end

						break
					end
				end

				return false
			end

			local function r372(s37)
				local s2 = tonumber(s37) or 0
				local s28 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local s3 = 1

				while math.abs(s2) >= 1000 and s3 < #s28 do
					s2 /= 1000
					s3 += 1
				end

				return string.format(s3 == 1 and "%.0f%s" or "%.2f%s", s2, s28[s3])
			end

			local function r373(s26)
				if not s26 then
					return "None"
				end
				local s19 = string.format
				local s21 = tostring(s26.Category)
				local s22 = tonumber(s26.Scale) or 0
				local s1 = tostring
				local s2 = s26.AreaId
				local s19_1 = s19("%s  %.2fx  |  value %s  |  %s", s21, s22, r372(s26.Value), s1(s2))

				if s26.State == "Dropped" then
					s19_1 ..= "  |  dropped"
				elseif s26.State == "Carried" then
					s19_1 ..= "  |  carried by a player"
				end

				return s19_1
			end

			local r374 = false
			local r375 = 0.5
			local r376 = 0.6
			local r377 = 0
			local r378 = 0

			local function r379()
				local s14 = r291
				r247.Steal.Active = true
				r247.Steal.Carrying = r247.Steal.Carrying == true

				if not r247.Steal.Carrying then
					r247.Steal.CarryUid = nil
				end

				local s3 = r310(false, true)
				local s18 = nil
				local s5 = nil
				local s6 = nil

				for _, s4 in ipairs(s3) do
					if s4.State == "Carried" then
						s5 = s5 or s4
					else
						local s7 = r247.SafeCarry.Unsafe(s4)

						if s7 then
							s6 = s6 or s7
						else
							s18 = s4
							break
						end
					end
				end

				local s2 = { s18 }
				r294 = s18 and s18.Uid or nil
				r247.Steal.Wanted = s18 ~= nil
				r19_1 = r373(s18)

				if s5 then
					r19_1 ..= "  |  watching " .. tostring(s5.Category)
				end

				if not s18 then
					r247.Steal.Active = false
					s6 = s6 or r247.SafeCarry.LastSkip
					r247.SafeCarry.LastSkip = nil
					r20_2 = s5 and "Best egg is carried, waiting for it" or s6 and "Skipped: " .. s6 or "No egg matches"
					return false
				end

				if not r247.ClaimMovement("steal") then
					r247.Steal.Active = false
					r20_2 = "Waiting for Auto Place"
					return false
				end

				if r247.Treadmill.Riding or r247.OnBelt() then
					r247.ExitBelt()
				end

				r374 = true
				r247.HoldBelt()

				local function s4_1(arg1)
					r20_2 = arg1
					local t20 = r366(s18, s14)
					local t1 = false
					local t2 = nil

					if t20 then
						if r336(s18.Uid, s14) then
							t1 = r371(s14)
							t2 = nil
						else
							t2 = r20_2
						end
					end

					r323()
					r247.Steal.Active = false
					r247.Steal.LastFinishedAt = os.clock()
					r20_2 = t1 and "Delivered" or t2 or t20 and "Run ended" or "That egg would not come free"
					return true
				end

				local s24 = r247.Root()
				local s3_4 = typeof(s18.CFrame) == "CFrame" and s18.CFrame.Position or nil

				if s24 and s3_4 then
					local s5_2 = (s3_4 - s24.Position).Magnitude <= r354
					local s3_5 = s18.AreaId
					local s3_6 = r232:GetAttribute("AreaId") == s3_5
					if s5_2 or s3_6 then
						return (s4_1("Target is right here, taking it"))
					end
				end

				if r247.SafeCarry.Enabled and r247.SafeCarry.Approach == "Run" then
					local s2_1 = r247.SafeCarry.RunTo(s18, s14)
					local s3_8, s4_2

					if s2_1 then
						if r336(s18.Uid, s14) then
							s3_8 = r371(s14)
							s4_2 = nil
						else
							s4_2 = r20_2
							s3_8 = false
						end
					else
						r292[s18.Uid] = os.clock() + r293
						s4_2 = nil
						s3_8 = false
					end

					r323()
					r247.Steal.Active = false
					r247.Steal.LastFinishedAt = os.clock()
					r20_2 = s3_8 and "Delivered" or s4_2 or s2_1 and "Run ended" or "That egg would not come free"
					return true
				end

				local s3_7 = r310(true)
				local s9 = "FirstAreaEgg_" .. tostring(r232.UserId)
				local s10 = {}

				for _, s7_1 in ipairs(s3_7) do
					local s11 = r349(s7_1)
					local s12

					if s11 then
						s12 = s11
					else
						s12 = type(s7_1.Uid) == "string" and string.sub(s7_1.Uid, 1, #s9) == s9
					end

					if s12 then
						table.insert(s10, s7_1)
					end
				end

				if #s10 ~= 0 then
					s3_7 = s10
				end

				local s12_1, s15 = r342(s3_7)

				if not s12_1 then
					r247.Steal.Active = false
					r20_2 = "No egg matches"
					return false
				end

				if s12_1.Uid == s18.Uid then
					return (s4_1("Target is the closest egg, taking it"))
				end
				local s4_3, s16 = r351(s12_1)
				local s13

				if s16 and s24 then
					local s5_5, s6_4, s7_2 = ipairs(s3_7)
					local s3_9 = math.huge
					s13 = s12_1

					for _, s11_2 in s5_5, s6_4, s7_2 do
						local s4_5 = typeof(s11_2.CFrame) == "CFrame" and s11_2.CFrame.Position or nil

						if s11_2.Uid ~= s18.Uid and s11_2.AreaId == s12_1.AreaId and s4_5 then
							local s5_7 = (s4_5 - s24.Position).Magnitude

							if r344 < (s4_5 - s16).Magnitude then
								s5_7 += r344
							end

							if s5_7 < s3_9 then
								s3_9 = s5_7
								s13 = s11_2
							end
						end
					end
				else
					s13 = s12_1
				end

				r20_2 = string.format("Sleeping guard egg %d studs away", math.floor(s15 + 0.5))

				if not s13 then
					r247.Steal.Active = false
					r20_2 = "No egg matches"
					return false
				end

				local s12_2, s3_10 = r356(s13, s14, false, s2[1])
				if not s12_2 then
					r247.Steal.Active = false
					return false
				end
				local s7_3 = nil
				local s9_1 = s18.Uid
				local s10_2 = 0
				local s6_5

				while true do
					if s3_10 and not r295(s14) then
						r20_2 = "Holding for the guard hit"

						if not r353(s14, s3_10, function(t22)
							if not s7_3 and r367.Uid and r367.Freed then
								s7_3 = r367.Uid
								t22.Destination = r367.Freed + Vector3.new(0, 3, 0)
								local t4 = r367
								r367.Uid = nil
								t4.Freed = nil
								r20_2 = "Best egg fell, jumping to it instead"
							end
						end) then
							s6_5 = s9_1
							break
						end

						s10_2 += 1

						if s7_3 then
							r365(s14, s7_3)
							s6_5 = s7_3
							break
						end

						local s5_8 = s2[s10_2]
						s12_2, s3_10 = r356(s5_8, s14, true, s2[s10_2 + 1])
						if not s12_2 then
							s6_5 = s9_1
							break
						end

						if s5_8 and type(s5_8.Uid) == "string" then
							s9_1 = s5_8.Uid
						end

						continue
					end

					s6_5 = s9_1
					break
				end

				if not r336(s6_5, s14) then
					local s2_2 = r20_2
					r323()
					r247.Steal.Active = false
					r247.Steal.LastFinishedAt = os.clock()
					r20_2 = s2_2
					return true
				end

				local s2_3 = r371(s14)
				r323()
				r247.Steal.Active = false
				r247.Steal.LastFinishedAt = os.clock()
				r20_2 = s2_3 and "Delivered" or "Run ended"
				return true
			end

			local r380 = r234.EggState

			if type(r380) == "table" then
				for _, r27_1 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "SnapshotRefreshed" }) do
					local r10_39 = r380[r27_1]

					if type(r10_39) == "table" and type(r10_39.Connect) == "function" then
						local r8_5, r9_4 = pcall(r10_39.Connect, r10_39, function()
							r244.Wake()
						end)

						if r8_5 and r9_4 then
							r240(function()
								pcall(function()
									r9_4:Disconnect()
								end)
							end)
						end
					end
				end
			end

			r244.Add(function()
				local s6 = nil

				if r17_3 then
					s6 = type(r17_3.Set) == "function"
				end

				if s6 then
					pcall(r17_3.Set, nil, r20_2)
				end

				local s6_1 = nil

				if r18_2 then
					s6_1 = type(r18_2.Set) == "function"
				end

				if s6_1 then
					pcall(r18_2.Set, nil, r19_1)
				end

				if not r247.Toggle(r16_2, false) then
					return false
				end
				local s6_2, s5, s8 = r299()

				if s6_2 then
					if s5 == "night" then
						r305()
					end

					r247.Movement.StealFirst = true
					r247.Steal.Wanted = false

					if r21_1 then
						r291 += 1
						r247.Steal.Active = false
						r323()
						r247.StopWalking()
					end

					local s7_1 = math.max(0, math.ceil(s6_2 - s8))

					if s5 == "wall" then
						r20_2 = string.format("Field wall up, %ds", s7_1)
					else
						r20_2 = string.format("Night, going again in %ds", s7_1)
					end

					return false
				end

				if r301 and r302 == math.huge then
					r302 = os.clock() + r300
				end

				if r21_1 then
					return true
				end

				if r306() then
					r20_2 = "Night over, waiting for the field to reset"
					r244.Wake()
					return false
				end

				local s5_1 = r247.Movement.StealFirst
				local s11 = r247.Movement.Owner
				local s6_4 = r247.Movement.PlaceWanted and not s5_1

				if not s6_4 then
					s6_4 = s11 ~= nil and s11 ~= "steal" and s11 ~= "treadmill" and s11 ~= "scramble"
				end

				if s6_4 then
					if r377 <= os.clock() then
						r377 = os.clock() + r375
						local s5_2, s6_7 = pcall(r310, false, false)
						s5_2 = s5_2 and type(s6_7) == "table" and s6_7[1] ~= nil
						r247.Steal.Wanted = s5_2

						if s5_2 then
							r247.Movement.StealFirst = true
						end
					end

					if r247.Steal.Wanted then
						local s6_5 = tostring
						s11 = s11 or "Auto Place"
						r20_2 = "Egg found, waiting for " .. s6_5(s11) .. " to stop"
					else
						r20_2 = "Waiting for " .. tostring(s11 or "Auto Place")
					end

					return true
				end

				if os.clock() < r378 then
					return true
				end
				r247.Movement.StealFirst = false
				r21_1 = true

				task.spawn(function()
					local t1 = pcall(r379)

					if r374 then
						r374 = false
						r247.ReleaseBelt()
					end

					if not t1 then
						r323()
						r247.Steal.Active = false
					end

					local t1_1 = r294
					r294 = nil
					local t3 = t1_1 and r268[t1_1]

					if t3 and t3.Once then
						r268[t1_1] = nil
					end

					local t5 = r367
					local t8 = r367
					r367.Uid = nil
					t5.Freed = nil
					t8.Token = nil

					if r20_2 == "Delivered" and not r247.IsNight() then
						r247.Movement.StealFirst = true
					end

					if not r247.Steal.Wanted then
						r378 = os.clock() + r376
					end

					r247.ReleaseMovement("steal")
					r21_1 = false
					r244.Wake()
				end)

				return true
			end)
		end

		r16_2 = r4_5

		r278 = function()
			r291 += 1
			table.clear(r292)
			r247.Steal.Active = false
			r247.Steal.Wanted = false
			local s5 = r247.Toggle(r16_2, false)
			r247.Shield("steal", s5)

			if not s5 then
				r247.Movement.StealFirst = false
				table.clear(r268)
				table.clear(r269)
				table.clear(r270)
			end

			r323()
			r247.StopWalking()
			r244.Wake()
		end

		do
			local function r1_12()
				r291 += 1
				r247.Steal.Active = false
				r323()
				r247.StopWalking()
			end

			local function r8_3()
				if r247.Toggle(r16_2, false) then
					return true
				end

				if r16_2 and type(r16_2.Set) == "function" then
					pcall(r16_2.Set, r16_2, true)
				end

				return false
			end

			r247.CancelSteal = function(s13)
				if type(s13) ~= "string" then
					return
				end
				r268[s13] = nil
				r269[s13] = nil
				r270[s13] = true

				if r21_1 and r294 == s13 then
					r1_12()
				end

				r244.Wake()
			end

			r247.StealQueue = function()
				local s7 = {}

				for s3 in pairs(r268) do
					table.insert(s7, s3)
				end

				table.sort(s7, function(t5, t6)
					local t2 = r268[t5].At
					local t8 = r268[t6].At
					if t2 ~= t8 then
						return t2 < t8
					end
					return t5 < t6
				end)

				return s7
			end

			r247.PrioritizeSteal = function(s22)
				if type(s22) ~= "string" or r304() then
					return
				end
				local s5 = 0

				for _, s3 in pairs(r268) do
					if s3.At < s5 then
						s5 = s3.At
					end
				end

				r268[s22] = { At = s5 - 1, Once = false }
				r270[s22] = nil
				r292[s22] = nil

				if r8_3() and r21_1 and not r247.Steal.Carrying and r294 ~= s22 then
					r1_12()
				end

				r244.Wake()
			end

			r247.MoveInPlan = function(s10, s11)
				if type(s10) ~= "string" or s11 ~= -1 and s11 ~= 1 or r304() then
					return
				end
				local s15 = r247.StealPlan()
				local s2_1 = table.find(s15, s10)
				local s9 = s2_1 and s2_1 + s11
				if not s9 or s9 < 1 or s9 > #s15 then
					return
				end
				table.remove(s15, s2_1)
				table.insert(s15, s9, s10)
				local s6 = math.max(s2_1, s9)

				for s3_2, s4_1 in ipairs(s15) do
					if s3_2 <= s6 or r268[s4_1] then
						local s7_1 = r268[s4_1]

						if s7_1 then
							s7_1.At = s3_2
						else
							r268[s4_1] = { At = s3_2, Once = false }
						end

						r270[s4_1] = nil
					end
				end

				if r21_1 and not r247.Steal.Carrying and r294 and s15[1] ~= r294 then
					r1_12()
				end

				r244.Wake()
			end

			r247.StealPlan = function()
				if not r247.Toggle(r16_2, false) or r247.IsNight() then
					return {}, nil
				end
				local s10 = {}

				if r294 then
					table.insert(s10, r294)
				end

				local s3_1, s8 = pcall(r310, false, true)

				if s3_1 and type(s8) == "table" then
					for _, s5 in ipairs(s8) do
						if s5.Uid ~= r294 then
							table.insert(s10, s5.Uid)
						end
					end
				end

				return s10, r294
			end

			r247.SetPriority = function(s2, arg2)
				if arg2 then
					r247.PrioritizeSteal(s2)
				else
					r247.CancelSteal(s2)
				end
			end

			r247.ResortSteal = function()
				if r21_1 and not r247.Steal.Carrying and r294 and not r268[r294] then
					local s2, s9 = pcall(r310, false, true)

					if s2 and type(s9) == "table" then
						local s5 = nil

						for _, s4 in ipairs(s9) do
							if s4.State ~= "Carried" then
								s5 = s4
								break
							else
								s5 = nil
							end
						end

						if not s5 or s5.Uid ~= r294 then
							r1_12()
						end
					end
				end

				r244.Wake()
			end

			r247.StealNow = function(s31, s32)
				if type(s31) ~= "string" or r304() then
					return
				end

				if not r268[s31] then
					local s5 = 0

					for _, s4 in pairs(r268) do
						if s5 < s4.At then
							s5 = s4.At
						end
					end

					r268[s31] = { At = s5 + 1, Once = s32 == true }
				end

				r270[s31] = nil
				r292[s31] = nil
				local s3_2 = r8_3() and r21_1 and not r247.Steal.Carrying and r294 ~= s31
				local s2_2

				if s3_2 then
					s2_2 = not (r294 and r268[r294])
				else
					s2_2 = s3_2
				end

				if s2_2 then
					r1_12()
				end

				r244.Wake()
			end
		end

		r240(function()
			r247.GodMode(false)
			r247.ReleaseMovement("steal")
			r323()
		end)

		r247.UiQueue = {}

		r247.UiDefer = function(s33)
			table.insert(r247.UiQueue, s33)
		end

		r247.Notify = function(s25, s26)
			if type(r179) == "table" and type(r179.Notify) == "function" then
				pcall(r179.Notify, s25, s26, 5)
			end
		end

		local r153_2 = r137.Heartbeat:Connect(function()
			local s6 = r247.UiQueue
			if #s6 == 0 then
				return
			end
			r247.UiQueue = {}

			for _, s7 in ipairs(s6) do
				pcall(s7)
			end
		end)

		r240(function()
			pcall(function()
				r153_2:Disconnect()
			end)
		end)

		r247.Rift = { Requirements = {}, At = 0, Busy = false, Next = 0, Handles = {}, Restart = {} }

		r247.RiftOn = function(arg1)
			local s31 = r247.Rift.Handles[arg1]
			return s31 ~= nil and r247.Toggle(s31, false) == true
		end

		do
			local r2_11 = 8

			local function r3_7(s24)
				local s2 = r234.Assets and r234.Assets.Directory
				local s1_1 = type(s2) == "table" and s2[tostring(s24)] or nil
				return type(s1_1) == "table" and s1_1 or nil
			end

			r247.EggRarity = function(arg1)
				local s1 = r3_7(arg1.AssetCategory)
				s1 = s1 and s1.Rarity or nil
				local s2 = type(s1) == "table"

				if s2 then
					s2 = tonumber(s1.RarityNumber or s1.Rank)
				end

				return s2 or 0
			end

			r247.EggIncome = function(s2)
				local s7 = r3_7(s2.AssetCategory)
				s7 = s7 and tonumber(s7.EarningRate) or 0
				local s3 = tonumber(s2.AssetScale) or 0
				if s3 <= 0 then
					return 0
				end
				local s9 = s3 > 5 and (s3 / 5) ^ 1.2 * 19.637875755794113 or s3 ^ 1.85
				local s3_1 = r234.Mutations
				local s1_1 = type(s3_1) == "table" and type(s3_1.EarningsFor) == "function"
				local s11 = 1

				if s1_1 then
					local s1_3, s2_1 = pcall(s3_1.EarningsFor, type(s2.Mutations) == "table" and s2.Mutations or {})

					if s1_3 and type(s2_1) == "number" then
						s11 = s2_1
					end
				end

				return s7 * s9 * s11
			end

			r247.RiftShortfall = function()
				local s18 = {}

				for _, s4 in ipairs(r247.Rift.Requirements) do
					s18[s4] = (s18[s4] or 0) + 1
				end

				if next(s18) == nil then
					return s18
				end
				local s2 = r234.Save
				local s3_1 = type(s2) == "table" and type(s2.Get) == "function"
				local s15 = nil

				if s3_1 then
					local s14
					s14, s15 = pcall(s2.Get)
					s15 = s14 and type(s15) == "table" and s15 or nil
				end

				if not s15 then
					return {}
				end
				local s3_2 = {}
				local s6_1 = pairs
				local s2_1 = s15.EquippedAssets or {}

				for _, s8 in s6_1(s2_1) do
					s3_2[s8] = true
				end

				local s10 = pairs
				local s2_2 = s15.Inventory or {}

				for s11, s12 in s10(s2_2) do
					local s2_3 = type(s12) == "table" and tostring(s12.Category) or nil
					local s4_3

					if s2_3 then
						s4_3 = (s18[s2_3] or 0) > 0
					else
						s4_3 = s2_3
					end

					s4_3 = s4_3 and s12.InFuse ~= true

					if s4_3 and s12.IsFavorite ~= true and not s3_2[s11] then
						s18[s2_3] = s18[s2_3] - 1
					end
				end

				for s15_1, s16 in pairs(s18) do
					if s16 <= 0 then
						s18[s15_1] = nil
					end
				end

				return s18
			end

			local function r5_9()
				for s3 in pairs(r247.Rift.Handles) do
					if r247.RiftOn(s3) then
						return true
					end
				end

				return false
			end

			r244.Add(function()
				local s2 = r247.Rift
				local s5 = s2.Busy
				local s7

				if s5 then
					s7 = s5
				else
					local s9 = s2.Next
					s7 = os.clock() < s9
				end

				if s7 or not r5_9() then
					return false
				end
				s2.Busy = true
				s2.Next = os.clock() + r2_11

				task.spawn(function()
					local t8 = r182:FindFirstChild("RF/Rift/AskState")

					if t8 and t8:IsA("RemoteFunction") then
						local t2, t3 = pcall(t8.InvokeServer, t8)

						if t2 and type(t3) == "table" then
							local t5 = {}

							if t3.Unlocked == true and type(t3.Requirements) == "table" then
								for _, t4 in ipairs(t3.Requirements) do
									table.insert(t5, tostring(t4))
								end
							end

							s2.Requirements = t5
							s2.At = os.clock()
						end
					end

					s2.Busy = false
					r244.Wake()
				end)

				return false
			end)
		end

		local r8_4
		r8_4 = { "Always", "Steal Idle", "After Steal", "Night Only" }
		local r9_3
		r9_3 = { "Biggest Size", "Highest Value", "Smallest Size", "Backpack Order" }
		local r23_1
		r23_1 = r8_4[1]
		local r24_1
		r24_1 = r9_3[2]
		local r25
		r25 = {}
		local r26_1
		r26_1 = {}
		local r27
		r27 = 0

		do
			local function r5_10()
				if type(r247.PlaceEggRefresh) == "function" then
					r247.PlaceEggRefresh()
				end
			end

			local function r6_9(s2)
				local s8 = {}

				if type(s2) == "table" then
					for s3, s4 in pairs(s2) do
						s3 = s4 == true and type(s3) == "string" and s3
						local s6_1

						if s3 then
							s6_1 = s3
						else
							s6_1 = type(s4) == "string" and s4
						end

						s6_1 = s6_1 or nil

						if s6_1 then
							table.insert(s8, s6_1)
						end
					end
				end

				return s8
			end

			r247.PlaceEggStatusRow = r185:CreateText({ Name = "Pen Status", Text = "Pen status unknown" })

			r247.PlaceEggHandle = r185:CreateToggle({
				Name = "Auto Place Egg",
				Default = false,
				Callback = function()
					if type(r247.PlaceEggRestart) == "function" then
						r247.PlaceEggRestart()
					end
				end,
			})

			local r10_2 = r247.PlaceEggHandle

			r185:CreateDropdown({
				Name = "Place Egg Rule",
				Options = r8_4,
				Default = r8_4[1],
				SubOf = r10_2,
				Callback = function(s20)
					if table.find(r8_4, s20) then
						r23_1 = s20
					end
				end,
			})

			r185:CreateDropdown({
				Name = "Place Egg Order",
				Options = r9_3,
				Default = r9_3[2],
				SubOf = r10_2,
				Callback = function(s14)
					if table.find(r9_3, s14) then
						r24_1 = s14
					end
				end,
			})

			local r11_4 = {}

			for r1_13 = 2, #r191 do
				table.insert(r11_4, r191[r1_13])
			end

			if #r11_4 > 0 then
				r243(r185:CreateMultiDropdown({
					Name = "Place Rarities",
					Note = "Only place eggs of the picked rarities (empty = all)",
					Options = r11_4,
					Default = {},
					SubOf = r10_2,
					Callback = function(s31)
						local s5 = {}

						for _, s4 in ipairs(r6_9(s31)) do
							local s6 = r264[s4]

							if s6 and s6 > 0 then
								s5[s6] = true
							end
						end

						r25 = s5
						r5_10()
					end,
				}))
			end

			local r11_5 = {}
			local r12_4 = {}
			local r29 = r234.Assets and r234.Assets.Directory
			local r32 = {}

			if type(r29) == "table" then
				for r29_1, r30 in pairs(r29) do
					local r3_8 = type(r30) == "table" and r30.Rarity or nil
					local r2_13 = type(r3_8) == "table"

					if r2_13 then
						r2_13 = tonumber(r3_8.RarityNumber or r3_8.Rank)
					end

					local r383 = r2_13 or nil

					if r383 then
						table.insert(r32, {
							Category = tostring(r29_1),
							Name = tostring(r30.DisplayName or r29_1),
							Rarity = r383,
							RarityName = tostring(r3_8.DisplayName or r3_8._id or r383),
						})
					end
				end
			end

			table.sort(r32, function(s4, s5)
				if s4.Rarity ~= s5.Rarity then
					return s4.Rarity > s5.Rarity
				end
				return s4.Name < s5.Name
			end)

			for _, r33 in ipairs(r32) do
				local r151_1 = string.format("%s [%s]", r33.Name, r33.RarityName)

				if r12_4[r151_1] then
					r151_1 = string.format("%s [%s] (%s)", r33.Name, r33.RarityName, r33.Category)
				end

				table.insert(r11_5, r151_1)
				r12_4[r151_1] = r33.Category
			end

			if #r11_5 > 0 then
				r243(r185:CreateMultiDropdown({
					Name = "Place Specific Eggs",
					Note = "Only place these eggs (empty = all)",
					Options = r11_5,
					Default = {},
					SubOf = r10_2,
					Callback = function(s32)
						local s4 = {}

						for _, s3 in ipairs(r6_9(s32)) do
							if r12_4[s3] then
								s4[r12_4[s3]] = true
							end
						end

						r26_1 = s4
						r5_10()
					end,
				}))
			end

			local r1_14 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local r2_15 = 0
			local r3_9 = "M/s"

			local function r11_6(s31, s32)
				if s31 ~= nil then
					r2_15 = math.max(0, math.floor(tonumber(s31) or r2_15))
				end

				if s32 ~= nil then
					r3_9 = tostring(s32)
				end

				r27 = r2_15 * (r1_14[r3_9] or r1_14["M/s"]).Mult
			end

			r192(r185, {
				Name = "Min Place Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = r10_2,
				Legacy = "Place Min Value",
				SectionName = "Auto Place Egg",
				OnRaw = function(arg1)
					r11_6(math.floor(arg1 / 1000), "K/s")
				end,
			})
		end

		do
			local r2_16 = 5
			local r3_10 = 26
			local r5_11 = 6
			local r6_10 = 8
			local r14_3 = 0
			local r15_3 = 30
			local r16_3 = 12
			local r396 = nil
			local r397 = nil
			local r398 = "Pen status unknown"
			local r399 = false
			local r400 = {}
			local r401 = 0
			local r402 = nil
			local r403 = 30

			local function r404(s15, s16)
				local s2 = r182:FindFirstChild(s15)
				if not s2 or not s2:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(s2.InvokeServer, s2, s16)
			end

			local function r405(s21)
				local s1 = r234.Assets and r234.Assets.Directory
				local s1_1 = type(s1) == "table" and s1[tostring(s21.AssetCategory)] or nil
				return type(s1_1) == "table" and s1_1 or nil
			end

			local function r406(s14)
				local s2 = r405(s14)
				local s4 = s2 and s2.Rarity or nil
				local s2_1 = type(s4) == "table"

				if s2_1 then
					s2_1 = tonumber(s4.RarityNumber or s4.Rank)
				end

				return s2_1 or 0
			end

			local function r407(s19)
				local s3 = r405(s19)
				s3 = s3 and tonumber(s3.EarningRate) or 0
				local s2 = tonumber(s19.AssetScale) or 0
				if s2 <= 0 then
					return 0
				end
				local s5 = s2 > 5 and (s2 / 5) ^ 1.2 * 19.637875755794113 or s2 ^ 1.85
				local s2_1 = r234.Mutations
				local s4_1 = type(s2_1) == "table" and type(s2_1.EarningsFor) == "function"
				local s16 = 1

				if s4_1 then
					local s15_1
					s15_1, s16 = pcall(s2_1.EarningsFor, type(s19.Mutations) == "table" and s19.Mutations or {})
					s15_1 = s15_1 and type(s16) == "number"
					local s2_3 = 1

					if not s15_1 then
						s16 = s2_3
					end
				end

				return s3 * s5 * s16
			end

			local function r408()
				local s12 = {}
				local s7 = r232:FindFirstChildOfClass("Backpack")
				if not s7 then
					return s12
				end
				local s14 = 0

				for _, s5 in ipairs(s7:GetChildren()) do
					local s6 = s5:GetAttribute("UID")

					if type(s6) == "string" then
						s14 += 1
						s12[s6] = s14
					end
				end

				return s12
			end

			local function r409()
				local s1 = r234.EggState
				if type(s1) ~= "table" or type(s1.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local s4, s7 = pcall(s1.ReadOwnerEggs, r232.UserId)
				if not s4 or type(s7) ~= "table" then
					return {}
				end
				local s9 = r408()
				local s10 = {}

				if r247.RiftOn("Place") then
					s10 = r247.RiftShortfall()

					for _, s3 in pairs(s7) do
						if type(s3) == "table" and s3.Placement ~= nil then
							local s4_2 = tostring(s3.AssetCategory)

							if (s10[s4_2] or 0) > 0 then
								s10[s4_2] = s10[s4_2] - 1
							end
						end
					end
				end

				local s1_2 = {}

				for s5_3, s6 in pairs(s7) do
					if type(s6) == "table" and s6.Placement == nil and not r400[s5_3] then
						local s2_3 = r407(s6)
						local s3_2 = tostring(s6.AssetCategory)
						local s7_1 = next(r25) == nil or r25[r406(s6)] == true
						local s12 = next(r26_1) == nil or r26_1[s3_2] == true
						local s14 = r27 <= 0 or s2_3 >= r27
						local s16_1 = (s10[s3_2] or 0) > 0

						if s16_1 then
							s10[s3_2] = s10[s3_2] - 1
						end

						if s16_1 then
							s14 = s16_1
						else
							s14 = s7_1 and s12 and s14
						end

						if s14 then
							table.insert(s1_2, {
								Uid = s5_3,
								Scale = tonumber(s6.AssetScale) or 0,
								Income = s2_3,
								Slot = s9[s5_3] or math.huge,
								Rift = s16_1,
							})
						end
					end
				end

				table.sort(s1_2, function(t10, t11)
					if t10.Rift ~= t11.Rift then
						return t10.Rift
					end

					if r24_1 == r9_3[2] and t10.Income ~= t11.Income then
						return t10.Income > t11.Income
					end

					if r24_1 == r9_3[3] and t10.Scale ~= t11.Scale then
						return t10.Scale < t11.Scale
					end

					if r24_1 == r9_3[4] and t10.Slot ~= t11.Slot then
						return t10.Slot < t11.Slot
					end
					return t10.Scale > t11.Scale
				end)

				return s1_2
			end

			local function r410(arg1)
				if arg1 == 0 then
					return false
				end
				local s1 = r247.Steal
				if r23_1 == r8_4[2] then
					return not s1.Active and not s1.Carrying
				end

				if r23_1 == r8_4[3] then
					local s3 = s1.LastFinishedAt > 0

					if s3 then
						local s1_1 = s1.LastFinishedAt
						s3 = os.clock() - s1_1 <= r16_3
					end

					return s3
				end

				if r23_1 == r8_4[4] then
					return r247.IsNight()
				end
				return true
			end

			local function r411()
				local s5 = r234.EggState
				local s4 = type(s5) == "table" and type(s5.ReadOwnerEggs) == "function"
				local s17 = 0

				if s4 then
					local s4_1, s8 = pcall(s5.ReadOwnerEggs, r232.UserId)

					if s4_1 and type(s8) == "table" then
						for _, s6 in pairs(s8) do
							if type(s6) == "table" and s6.Placement ~= nil then
								s17 += 1
							end
						end
					end
				end

				local s4_2 = r234.Save
				local s5_2 = type(s4_2) == "table" and type(s4_2.Get) == "function"
				local s15 = nil

				if s5_2 then
					local s14
					s14, s15 = pcall(s4_2.Get)
					s15 = s14 and type(s15) == "table" and s15 or nil
				end

				local s4_3 = s15 and type(s15.EquippedAssets) == "table"
				local s6_1 = 0

				if s4_3 then
					for s9 in pairs(s15.EquippedAssets) do
						s6_1 += 1
					end
				end

				local s5_4 = r233(function()
					return r181.Data.Bases
				end)

				local s4_4 = type(s5_4) == "table" and type(s5_4.GetAssetEquipCapacity) == "function"
				local s11 = nil

				if s4_4 then
					local s12_1
					s11, s12_1 = pcall(s5_4.GetAssetEquipCapacity, s15 and tonumber(s15.BaseUpgradeLevel) or 0)
					s11 = s11 and tonumber(s12_1) or nil
				end

				if not s11 then
					local s4_6 = r182:FindFirstChild("RF/PenRoster/AskWearLimit")

					if s4_6 and s4_6:IsA("RemoteFunction") then
						local s12_3
						s11, s12_3 = pcall(s4_6.InvokeServer, s4_6)
						s11 = s11 and tonumber(s12_3) or nil
					end
				end

				s11 = s11 or 0
				return s11 - s17 - s6_1, s11, s17, s6_1
			end

			local r412 = -0.5
			local r413 = -24

			local function r418()
				local s3 = r234.EggState
				local s9 = {}
				if type(s3) ~= "table" or type(s3.ReadOwnerEggs) ~= "function" then
					return s9
				end
				local s2_1, s5 = pcall(s3.ReadOwnerEggs, r232.UserId)
				if not s2_1 or type(s5) ~= "table" then
					return s9
				end

				for _, s4_1 in pairs(s5) do
					local s6 = type(s4_1) == "table" and s4_1.Placement or nil
					local s7 = type(s6) == "table" and s6.LocalCFrame or nil

					if typeof(s7) == "CFrame" then
						table.insert(s9, Vector2.new(s7.Position.X, s7.Position.Z))
					end
				end

				return s9
			end

			local r419 = Random.new()

			local function r420(s32)
				local s5 = {}

				for s34 = r413, 8, 4 do
					for s4 = 4, 30, 4 do
						local s33 = Vector2.new(s34, s4)
						local s6 = true

						for _, s3 in ipairs(s32) do
							if (s3 - s33).Magnitude < r2_16 then
								s6 = false
								break
							end
						end

						if s6 then
							table.insert(s5, CFrame.new(s34, r412, s4))
						end
					end
				end

				for s36 = #s5, 2, -1 do
					local s33_1 = r419:NextInteger(1, s36)
					local s2_1 = s5[s36]
					s5[s36] = s5[s33_1]
					s5[s33_1] = s2_1
				end

				return s5
			end

			local function r421()
				local s14, s16, s8, s18 = r411()
				local s3 = r234.EggState
				local s2 = type(s3) == "table" and type(s3.ReadOwnerEggs) == "function"
				local s12 = 0

				if s2 then
					local s2_1, s6_1 = pcall(s3.ReadOwnerEggs, r232.UserId)

					if s2_1 and type(s6_1) == "table" then
						for _, s4 in pairs(s6_1) do
							if type(s4) == "table" and s4.Placement == nil then
								s12 += 1
							end
						end
					end
				end

				r398 = string.format("Eggs placed %d/%d  -  %d/%d pets equipped, %d in bag", s8, 30, s18, s16, s12)
				return s14, s8
			end

			local function r422(s37, s38)
				local s2 = r247.Root()
				if not s2 then
					return false
				end
				local s6 = s2.Position
				local s7 = (s37 - s6).Magnitude / math.max(r277, 1) + 3
				local s9 = nil
				local s10 = 0

				local s2_1 = r137.Heartbeat:Connect(function(t30)
					if s9 ~= nil or r247.AntiGuard.Busy then
						return
					end
					s10 += t30
					local t2 = r247.Root()
					if not t2 or s38() or s10 > s7 then
						s9 = false
						return
					end

					if (t2.Position - s6).Magnitude > 6 then
						s6 = t2.Position
					end

					local t1_2 = s37 - s6
					local t27 = r277 * t30
					local t3_1 = t1_2.Magnitude <= math.max(t27, 0.05)
					s6 = t3_1 and s37 or s6 + t1_2.Unit * t27
					local t25 = Vector3.new(t1_2.X, 0, t1_2.Z)
					local t1_3 = t25.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, t25.Unit) or t2.CFrame.Rotation

					pcall(function()
						t2.CFrame = CFrame.new(s6) * t1_3
						t2.AssemblyLinearVelocity = Vector3.zero
						t2.AssemblyAngularVelocity = Vector3.zero
					end)

					if t3_1 then
						s9 = true
					end
				end)

				while s9 == nil do
					r137.Heartbeat:Wait()
				end

				s2_1:Disconnect()
				return s9
			end

			local function r423()
				local s14 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
				s14 = s14 and s14:FindFirstChild("Areas")
				s14 = s14 and s14:FindFirstChild("SeparationLine")
				return s14 and s14:IsA("BasePart") and s14.Position.X or 552
			end

			local r424 = nil

			local function r425(s18)
				local s1 = r247.Root()
				if not s1 or type(r247.StealHome) ~= "function" then
					return nil
				end
				local s3_1 = r423()
				if s1.Position.X < s3_1 == s18.X < s3_1 then
					return nil
				end
				local s16, s17 = pcall(r247.StealHome)
				if not s16 or typeof(s17) ~= "Vector3" then
					return nil
				end

				if (s17 - s18).Magnitude <= 12 or (s1.Position - s17).Magnitude <= 12 then
					return nil
				end
				return s17
			end

			r424 = function(s14, s15, s16, s17)
				local s8 = r247.Root()
				if not s8 then
					return false
				end

				if not s17 then
					local s3 = r425(s14)
					if s3 and not r424(s3, s15, s16, true) then
						return false
					end

					if s15 and s15() then
						return false
					end
					s8 = r247.Root()
					if not s8 then
						return false
					end
				end

				r247.Shield(s16 or "place", true)
				r247.Driving = r247.Driving + 1
				task.wait(0.2)
				local s5 = s14 + Vector3.new(0, 3, 0)
				local s6 = math.max(s8.Position.Y, s5.Y) + r403

				local s17_1, s18 = pcall(function()
					return r422(Vector3.new(s8.Position.X, s6, s8.Position.Z), s15) and r422(Vector3.new(s5.X, s6, s5.Z), s15) and r422(s5, s15)
				end)

				s17_1 = s17_1 and s18 == true
				r247.Driving = math.max(0, r247.Driving - 1)
				r247.Shield(s16 or "place", false)
				return s17_1
			end

			r247.FlyTo = function(arg1, arg2, arg3)
				return r424(arg1, arg2, arg3 or "fly")
			end

			local function r426()
				local s13 = r234.EggState
				if type(s13) ~= "table" or type(s13.PlantEgg) ~= "function" then
					return false
				end
				local s3 = r409()
				if not r410(#s3) then
					return false
				end
				r421()
				local s4, s5, s6 = r411()
				local s14 = r15_3 - (tonumber(s6) or 0)
				if s14 <= 0 then
					return false
				end
				local s16 = r247.PenAnchor()
				if not s16 then
					return false
				end
				r247.Movement.PlaceWanted = true
				if not r247.ClaimMovement("place") then
					return "waiting"
				end
				local s17 = r401

				local function s19()
					if s17 ~= r401 or not r247.Toggle(r396, false) then
						return true
					end

					if r247.IsNight() then
						return false
					end
					return r23_1 == r8_4[4] or r247.Movement.StealFirst
				end

				if r247.Treadmill.Riding or r247.OnBelt() then
					r247.ExitBelt()
				end

				local function s20()
					r247.HoldBelt()
					local t6, t7 = pcall(r424, s16, s19)
					r247.ReleaseBelt()
					return t6 and t7 and true or false
				end

				if r3_10 < r247.DistanceTo(s16) then
					r398 = "Flying to the pen"

					if not s20() then
						r247.LeaveBelt()
						r14_3 = os.clock() + r5_11
						return false
					end
				end

				r247.LeaveBelt()
				if s19() then
					return false
				end

				local function s21()
					if r247.DistanceTo(s16) <= r3_10 then
						return true
					end

					if s19() then
						return false
					end
					r398 = "Pen out of reach, flying back"
					return s20() and r247.DistanceTo(s16) <= r3_10
				end

				if not s21() then
					r398 = "Could not reach the pen, trying again soon"
					r14_3 = os.clock() + r5_11
					return false
				end

				local s22 = r418()
				local s23 = 0
				local s24 = 0

				for _, s4_2 in ipairs(s3) do
					if not (s23 >= s14 or s19()) then
						if not s21() then
							r398 = "Pen out of reach, stopping this pass"
							break
						else
							local s5_2, s6_1 = pcall(s13.WearEggTool, s4_2.Uid)

							if s5_2 and s6_1 ~= false then
								task.wait(0.15)
								local s25 = 0
								local s27 = false

								for _, s7 in ipairs(r420(s22)) do
									if not (s19() or s25 >= r6_10) then
										s25 += 1
										local s9_1, s10_1 = r404("RF/EggWorld/AskPlaceEgg", { Uid = s4_2.Uid, LocalCFrame = s7 })

										if s9_1 and s10_1 ~= false then
											table.insert(s22, Vector2.new(s7.Position.X, s7.Position.Z))
											s23 += 1
											s27 = true
											break
										else
											continue
										end
									end

									break
								end

								if s27 then
									s24 = 0
									continue
								else
									r400[s4_2.Uid] = true
									s24 += 1
									if not (s24 >= 2) then
										continue
									end
								end
							else
								r400[s4_2.Uid] = true
								continue
							end
						end
					end

					break
				end

				if type(s13.DoffEggTool) == "function" then
					pcall(s13.DoffEggTool)
				end

				if s23 == 0 then
					r14_3 = os.clock() + r5_11
				end

				return s23 > 0
			end

			r244.Add(function()
				local s5, s10 = r421()

				if r397 and type(r397.Set) == "function" then
					pcall(r397.Set, r397, r398)
				end

				local s5_1 = tonumber(s10)
				local s6_1 = s5_1 ~= nil and r402 ~= nil and s5_1 < r402

				if s5_1 then
					r402 = s5_1
				end

				if s6_1 then
					table.clear(r400)
				end

				if not r247.Toggle(r396, false) then
					r247.Movement.PlaceWanted = false
					r247.ReleaseMovement("place")
					return false
				end

				if r399 then
					return false
				end

				if os.clock() < r14_3 then
					r247.Movement.PlaceWanted = false
					return false
				end

				if r247.Movement.StealFirst and not r247.IsNight() then
					r247.Movement.PlaceWanted = false
					return false
				end
				r399 = true

				task.spawn(function()
					local t2, t3 = pcall(r426)

					if not (t2 and t3 == "waiting") then
						r247.Movement.PlaceWanted = false
					end

					r247.ReleaseMovement("place")
					r399 = false
					r244.Wake()
				end)

				return false
			end)

			r396 = r247.PlaceEggHandle
			r397 = r247.PlaceEggStatusRow

			r247.PlaceEggRestart = function()
				table.clear(r400)
				r401 += 1
				r247.StopWalking()
				r244.Wake()
			end

			r247.PlaceEggRefresh = function()
				table.clear(r400)
				r244.Wake()
			end

			r247.Rift.Restart.Place = function()
				table.clear(r400)
				r244.Wake()
			end
		end

		local r10_3 = r234.Save

		if type(r10_3) == "table" and type(r10_3.FieldSignal) == "function" then
			for _, r36 in ipairs({ "EggInventory", "EquippedAssets", "BaseUpgradeLevel" }) do
				local r153_4, r154_1 = pcall(r10_3.FieldSignal, r36)

				if r153_4 and type(r154_1) == "table" and type(r154_1.Connect) == "function" then
					local r152_1, r153_5 = pcall(r154_1.Connect, r154_1, function()
						r244.Wake()
					end)

					if r152_1 and r153_5 then
						r240(function()
							pcall(function()
								r153_5:Disconnect()
							end)
						end)
					end
				end
			end
		end

		r247.Steal.HeldByMe = function()
			local s5 = r247.Steal.CarryUid
			local s13 = r232.Character
			if type(s5) ~= "string" or not s13 then
				return false
			end
			local s6 = workspace:FindFirstChild(s5)
			if not s6 then
				return false
			end

			for _, s4 in ipairs(s6:GetDescendants()) do
				if s4:IsA("WeldConstraint") or s4:IsA("JointInstance") then
					local s5_1, s6_1, s7 = pcall(function()
						return s4.Part0, s4.Part1
					end)

					if s5_1 and (s6_1 and s6_1:IsDescendantOf(s13) or s7 and s7:IsDescendantOf(s13)) then
						return true
					end
				end
			end

			return false
		end

		do
			local r10_4 = 0

			local r153_3 = r137.Heartbeat:Connect(function(arg1)
				r10_4 += arg1
				if r10_4 < 0.2 then
					return
				end
				r10_4 = 0
				local s2 = r247.Steal

				if not s2.Carrying then
					if s2.GuessedDrop then
						local s34_1, s35_1 = pcall(s2.HeldByMe)

						if s34_1 and s35_1 then
							s2.GuessedDrop = false
							s2.Carrying = true
							s2.HeldSeenAt = os.clock()
						end
					end

					return
				end

				local s34, s35 = pcall(s2.HeldByMe)
				if not s34 or s35 then
					s2.HeldSeenAt = os.clock()
					return
				end

				if os.clock() - (s2.HeldSeenAt or 0) > 0.8 then
					s2.Carrying = false
					s2.GuessedDrop = true
					s2.LastFinishedAt = os.clock()
					r244.Wake()
				end
			end)

			r240(function()
				pcall(function()
					r153_3:Disconnect()
				end)
			end)
		end

		do
			local r1_16 = r234.EggState
			local r12_5 = type(r1_16) == "table" and r1_16.CarryChanged or nil

			if type(r12_5) == "table" and type(r12_5.Connect) == "function" then
				local r10_5, r11_7 = pcall(r12_5.Connect, r12_5, function(s27)
					local s1 = type(s27) == "table" and s27.IsCarrying == true

					if r247.Steal.Carrying and not s1 then
						r247.Steal.LastFinishedAt = os.clock()
					end

					r247.Steal.GuessedDrop = false

					if s1 then
						r247.Steal.HeldSeenAt = os.clock()
					end

					if s1 and type(s27.Uid) == "string" then
						r247.Steal.CarryUid = s27.Uid
						r247.Steal.CarryAreaId = s27.AreaId
						local s26 = tonumber(s27.SpeedMultiplier)

						if s26 and s26 > 0 then
							r247.SafeCarry.Mult = s26
							r247.SafeCarry.Category = s27.AssetCategory

							if s27.AssetCategory ~= nil then
								local s2_3 = tostring(s27.AssetCategory)
								r247.SafeCarry.Seen[s2_3] = math.min(r247.SafeCarry.Seen[s2_3] or s26, s26)
							end
						end
					end

					r247.Steal.Carrying = s1
					r244.Wake()
				end)

				if r10_5 and r11_7 then
					r240(function()
						pcall(function()
							r11_7:Disconnect()
						end)
					end)
				end
			end
		end

		pcall(function()
			local s8 = r182:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict")
			local s13 = r182:FindFirstChild("RE/Alerts/Raise")

			if s8 and s8:IsA("RemoteEvent") then
				local s15 = s8.OnClientEvent:Connect(function()
					r247.SafeCarry.LastDelivered = os.clock()
				end)

				r240(function()
					s15:Disconnect()
				end)
			end

			if s13 and s13:IsA("RemoteEvent") then
				local s15_1 = s13.OnClientEvent:Connect(function(t16)
					if type(t16) == "table" and type(t16.Text) == "string" and string.find(t16.Text, "Delivery failed", 1, true) then
						r247.SafeCarry.LastFailed = os.clock()
					end
				end)

				r240(function()
					s15_1:Disconnect()
				end)
			end
		end)

		do
			local r11_8 = 10
			local r12_6 = 1
			local r14_4 = 5

			local function r15_4(s6)
				local s11 = r182:FindFirstChild(s6)
				if not s11 or not s11:IsA("RemoteFunction") then
					return false, nil, nil
				end
				local s5_1, s6_1, s7 = pcall(s11.InvokeServer, s11)
				return s5_1, s6_1, s7
			end

			local r426_1 = 0
			local r427 = false

			local function r428(s34, s35, s36)
				if s34 and s35 ~= false then
					r426_1 = 0
					r427 = false
					return true
				end

				if s34 and tostring(s36) == "Already using treadmill" then
					r426_1 = 0
					r427 = false
					return true
				end

				if s34 and tostring(s36) == "Not grounded" and r247.Grounded() then
					r426_1 += 1

					if r426_1 >= 2 then
						r426_1 = 0

						if not r427 then
							r427 = true
							pcall(r247.UndoSwap)
						elseif type(r247.RequestRespawn) == "function" then
							r427 = false
							r247.RequestRespawn()
						end
					end
				end

				return false
			end

			local r5_12 = nil
			local r6_11 = nil
			local r429 = false
			local r430 = 0
			local r431 = false
			local r432 = r247.Treadmill

			local function r433()
				return r247.Toggle(r5_12, false)
			end

			local function r434()
				local s2 = r247.Movement
				local s4 = s2.PlaceWanted or s2.ScrambleWanted or s2.MutationWanted or s2.FracturedWanted
				local s6

				if s4 then
					s6 = s4
				else
					s6 = s2.Owner ~= nil and s2.Owner ~= "treadmill"
				end

				return s6 or r247.Steal.Active or r247.Steal.Carrying
			end

			local function r435()
				local s10 = r430
				if r434() or not r247.ClaimMovement("treadmill") then
					return false
				end

				local function s8()
					return s10 ~= r430 or not r433() or r247.Movement.Owner ~= "treadmill" or r434()
				end

				if r247.BeltHeld() then
					r247.ResetBelt()
				end

				local s4_1 = r247.Belt()
				if not s4_1 then
					return false
				end
				local s4_2 = s4_1.Position + Vector3.new(0, s4_1.Size.Y / 2, 0)

				if r247.DistanceTo(s4_2 + Vector3.new(0, 2, 0)) > r11_8 then
					if type(r247.FlyTo) ~= "function" or not r247.FlyTo(s4_2, s8, "treadmill") then
						return false
					end
				end

				if s8() then
					return false
				end
				r432.Riding = r428(r15_4("RF/Treadmill/AskWearStill"))
				return r432.Riding
			end

			r244.Add(function()
				if not r433() then
					if r432.Riding and not r429 then
						r429 = true

						task.spawn(function()
							pcall(r247.ExitBelt)
							r429 = false
							r244.Wake()
						end)
					end

					return false
				end

				if r429 or r434() then
					return false
				end

				if r432.Riding and r247.Toggle(r6_11, true) and r247.OnBelt() then
					if os.clock() >= (r432.NextCheck or 0) and not r247.Flying and r247.Grounded() then
						r432.NextCheck = os.clock() + r14_4
						r429 = true

						task.spawn(function()
							local t2, t3 = pcall(function()
								return r428(r15_4("RF/Treadmill/AskWearStill"))
							end)

							r432.Riding = t2 and t3 == true

							if not r432.Riding then
								r432.NextTry = 0
							end

							r429 = false
							r244.Wake()
						end)
					end

					return false
				end

				if os.clock() < (r432.NextTry or 0) then
					return false
				end
				r432.NextCheck = 0
				r432.NextTry = os.clock() + (r432.LastFailed and 3 or 4)
				r429 = true

				task.spawn(function()
					local t3, t4 = pcall(r435)
					r432.LastFailed = not (t3 and t4 == true)
					r247.ReleaseMovement("treadmill")
					r429 = false
					r244.Wake()
				end)

				return false
			end)

			task.spawn(function()
				while not r431 do
					task.wait(3)

					if not r433() and not r434() and not r247.Flying and r247.OnBelt() and r247.Grounded() then
						r428(r15_4("RF/Treadmill/AskWearStill"))
					end
				end
			end)

			task.spawn(function()
				local s2 = 0

				while not r431 do
					local s4 = task.wait(0.25)

					if not r433() or not r432.Riding or r434() then
						s2 = 0
					elseif r247.OnBelt() then
						s2 = 0
					else
						s2 += s4

						if s2 >= 1.5 then
							r432.Riding = false
							r432.NextTry = 0
							r244.Wake()
							s2 = 0
						end
					end
				end
			end)

			task.spawn(function()
				local s7 = 0
				local s14 = 0
				local s16 = nil

				while not r431 do
					local s18 = task.wait(0.25)
					s7 = math.max(0, s7 - s18)
					local s9 = r432.Riding and r433() and not r434()
					local s19 = r247.Root()
					local s5 = r232.Character
					s5 = s5 and s5:FindFirstChildOfClass("Humanoid")

					if s9 or not (r247.Flying or r247.Movement.Owner ~= nil or r247.Movement.PlaceWanted or s5 ~= nil and s5.MoveDirection.Magnitude > 0.1) or not s19 or not r247.OnBelt() then
						s16 = s19 and s19.Position
						s14 = 0
						s16 = s16 or nil
					else
						local s2 = Vector3.new(s19.Position.X, 0, s19.Position.Z)
						s16 = s16 and (s2 - Vector3.new(s16.X, 0, s16.Z)).Magnitude < 0.5

						if s16 then
							s14 += s18
						else
							s14 = 0
						end

						s16 = s19.Position

						if s14 >= r12_6 and s7 <= 0 then
							pcall(r247.ExitBelt)
							s7 = 1.5
							s14 = 0
						end
					end
				end
			end)

			r240(function()
				r431 = true
				r432.Riding = false
			end)

			r5_12 = r186:CreateToggle({
				Name = "Auto Treadmill",
				Default = false,
				Callback = function()
					r430 += 1
					r247.StopWalking()
					r244.Wake()
				end,
			})

			r6_11 = r186:CreateToggle({ Name = "Stay On Treadmill", Default = true })
		end

		do
			local r11_9 = 4
			local r12_7 = 10
			local r5_13 = nil
			local r13_3 = false
			local r14_5 = 0
			local r15_5 = {}
			local r441 = { MinRarity = 0, MinIncome = 0, Eggs = {} }

			local function r442(s18, s19)
				local s1 = r182:FindFirstChild(s18)
				if not s1 or not s1:IsA("RemoteFunction") then
					return false, nil
				end
				return pcall(s1.InvokeServer, s1, s19)
			end

			local function r443(s18)
				local s1 = r441.MinRarity > 0

				if s1 then
					local s4 = r441.MinRarity
					s1 = r247.EggRarity(s18) < s4
				end

				if s1 then
					return false
				end
				local s1_1 = r441.MinIncome > 0

				if s1_1 then
					local s4_1 = r441.MinIncome
					s1_1 = r247.EggIncome(s18) < s4_1
				end

				if s1_1 then
					return false
				end

				if next(r441.Eggs) ~= nil and r441.Eggs[tostring(s18.AssetCategory)] ~= true then
					return false
				end
				return true
			end

			local function r444()
				local s10 = r234.EggState
				if type(s10) ~= "table" or type(s10.ReadOwnerEggs) ~= "function" then
					return {}
				end
				local s2, s1_1 = pcall(s10.ReadOwnerEggs, r232.UserId)
				if not s2 or type(s1_1) ~= "table" then
					return {}
				end
				local s12 = r247.Toggle(r5_13, false) == true
				local s14 = r247.RiftOn("Hatch") and r247.RiftShortfall() or {}
				local s16 = {}
				local s8 = {}

				for s3_1, s4 in pairs(s1_1) do
					local s5 = type(s4) == "table" and s4.Placement ~= nil

					if s5 then
						s5 = (r15_5[s3_1] or 0) <= os.clock()
					end

					if s5 then
						local s5_1, s6_1 = pcall(s10.IsReadyToHatch, s3_1)

						if s5_1 and s6_1 == true then
							local s1_4 = tostring(s4.AssetCategory)

							if (s14[s1_4] or 0) > 0 then
								s14[s1_4] = s14[s1_4] - 1
								table.insert(s16, s3_1)
							elseif s12 and r443(s4) then
								table.insert(s8, s3_1)
							end
						end
					end
				end

				for _, s7_1 in ipairs(s8) do
					table.insert(s16, s7_1)
				end

				return s16
			end

			local function r445()
				return r247.Toggle(r5_13, false) or r247.RiftOn("Hatch")
			end

			local function r446()
				local s10 = r14_5
				local s3 = r444()
				local s12 = 0

				for _, s4 in ipairs(s3) do
					if not (s12 >= r11_9 or s10 ~= r14_5 or not r445()) then
						local s6, s7 = r442("RF/EggWorld/AskHatch", s4)

						if s6 and s7 ~= false then
							task.wait(0.35)
							r442("RF/EggWorld/AskFinishHatch", s4)
							s12 += 1
							r15_5[s4] = nil
						else
							r15_5[s4] = os.clock() + r12_7
						end

						task.wait(0.2)
						continue
					end

					break
				end

				return s12 > 0
			end

			r244.Add(function()
				if not r445() or r13_3 then
					return false
				end
				r13_3 = true

				task.spawn(function()
					pcall(r446)
					r13_3 = false
				end)

				return false
			end)

			local function r447()
				r14_5 += 1
				table.clear(r15_5)
				r244.Wake()
			end

			r5_13 = r187:CreateToggle({ Name = "Auto Hatch", Default = false, Callback = r447 })

			r187:CreateDropdown({
				Name = "Hatch Min Rarity",
				Note = "Hatch eggs of the chosen rarity and every rarity above it",
				Options = r191,
				Default = r191[1],
				SubOf = r5_13,
				Callback = function(arg1)
					r441.MinRarity = r264[arg1] or 0
					r447()
				end,
			})

			local r454 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local r455 = { Slider = nil, Value = 0, Unit = "M/s" }

			local function r456(s32, s33)
				if s32 ~= nil then
					r455.Value = math.max(0, math.floor(tonumber(s32) or r455.Value))
				end

				if s33 ~= nil then
					r455.Unit = tostring(s33)
				end

				r441.MinIncome = r455.Value * (r454[r455.Unit] or r454["M/s"]).Mult
				r447()
			end

			r455.Slider = r192(r187, {
				Name = "Min Hatch Value",
				Note = "Skip eggs worth less than this (0 = off)",
				SubOf = r5_13,
				Legacy = "Hatch Min Value",
				SectionName = "Auto Hatch & Equip",
				OnRaw = function(arg1)
					r456(math.floor(arg1 / 1000), "K/s")
				end,
			})

			local r457 = {}
			local r458 = {}
			local r38 = r234.Assets and r234.Assets.Directory
			local r1_18 = 0

			while (type(r38) ~= "table" or next(r38) == nil) and r1_18 < 2 do
				r1_18 += task.wait(0.1)

				if type(r234.Assets) ~= "table" then
					r234.Assets = r233(function()
						return r181.Data.Assets
					end)
				end

				r38 = r234.Assets and r234.Assets.Directory
			end

			local r41 = {}

			if type(r38) == "table" then
				for r38_1, r39 in pairs(r38) do
					local r1_81 = type(r39) == "table" and r39.Rarity or nil
					local r2_67 = type(r1_81) == "table"

					if r2_67 then
						r2_67 = tonumber(r1_81.RarityNumber or r1_81.Rank)
					end

					r2_67 = r2_67 or nil

					if r2_67 then
						table.insert(r41, {
							Category = tostring(r38_1),
							Name = tostring(r39.DisplayName or r38_1),
							Rarity = r2_67,
							RarityName = tostring(r1_81.DisplayName or r1_81._id or r2_67),
						})
					end
				end
			end

			table.sort(r41, function(s31, s32)
				if s31.Rarity ~= s32.Rarity then
					return s31.Rarity > s32.Rarity
				end
				return s31.Name < s32.Name
			end)

			for _, r42 in ipairs(r41) do
				local r151_2 = string.format("%s [%s]", r42.Name, r42.RarityName)

				if r458[r151_2] then
					r151_2 = string.format("%s [%s] (%s)", r42.Name, r42.RarityName, r42.Category)
				end

				table.insert(r457, r151_2)
				r458[r151_2] = r42.Category
			end

			if #r457 > 0 then
				r243(r187:CreateMultiDropdown({
					Name = "Hatch Specific Eggs",
					Note = "Only hatch these eggs (empty = all)",
					Options = r457,
					Default = {},
					SubOf = r5_13,
					Callback = function(s10)
						local s6 = {}

						if type(s10) == "table" then
							for s3, s4 in pairs(s10) do
								s3 = s4 == true and type(s3) == "string" and s3 or type(s4) == "string" and s4 or nil

								if s3 and r458[s3] then
									s6[r458[s3]] = true
								end
							end
						end

						r441.Eggs = s6
						r447()
					end,
				}))
			end

			r247.Rift.Restart.Hatch = r447
		end

		do
			local r12_8 = 5
			local r13_4 = 30
			local r5_14 = nil
			local r14_6 = false
			local r15_6 = 0
			local r471 = {}
			local r472 = 0
			local r473 = true
			local r474 = nil
			local r475 = -math.huge

			local function r476(s13)
				local s2 = r233(function()
					return r181.Data.Bases
				end)

				if type(s2) == "table" and type(s2.GetAssetEquipCapacity) == "function" then
					local s10_1, s11_1 = pcall(s2.GetAssetEquipCapacity, s13 and tonumber(s13.BaseUpgradeLevel) or 0)
					if s10_1 and tonumber(s11_1) then
						return math.floor(tonumber(s11_1))
					end
				end

				if r474 and os.clock() - r475 < r13_4 then
					return r474
				end
				local s2_1 = r182:FindFirstChild("RF/PenRoster/AskWearLimit")

				if s2_1 and s2_1:IsA("RemoteFunction") then
					local s9, s10_3 = pcall(s2_1.InvokeServer, s2_1)

					if s9 and tonumber(s10_3) then
						local s2_3 = math.floor(tonumber(s10_3))
						local s5_1 = os.clock()
						r474 = s2_3
						r475 = s5_1
						return r474
					end
				end

				return r474 or 0
			end

			local function r477(s24)
				local s1 = r234.Assets and r234.Assets.Directory
				local s2 = type(s1) == "table" and s1[tostring(s24.Category)] or nil
				local s1_1 = type(s2) == "table" and tonumber(s2.EarningRate) or 0
				local s2_1 = tonumber(s24.Scale) or 0
				if s1_1 <= 0 or s2_1 <= 0 then
					return 0
				end
				local s3_1 = s2_1 > 5 and (s2_1 / 5) ^ 1.2 * 19.637875755794113 or s2_1 ^ 1.85
				local s2_2 = r234.Mutations
				local s5 = type(s2_2) == "table" and type(s2_2.EarningsFor) == "function"
				local s6 = 1

				if s5 then
					local s20_1, s21_1 = pcall(s2_2.EarningsFor, type(s24.Mutations) == "table" and s24.Mutations or {})

					if s20_1 and type(s21_1) == "number" then
						s6 = s21_1
					end
				end

				return s1_1 * s3_1 * s6
			end

			local function r478()
				local s1 = r234.Save
				local s2 = type(s1) == "table" and type(s1.Get) == "function"
				local s8 = nil

				if s2 then
					local s7
					s7, s8 = pcall(s1.Get)
					s8 = s7 and type(s8) == "table" and s8 or nil
				end

				if not s8 then
					return nil
				end
				local s10 = {}
				local s12 = {}
				local s1_1 = pairs
				local s5 = s8.EquippedAssets or {}

				for _, s3 in s1_1(s5) do
					if type(s3) == "string" then
						s10[s3] = true
						table.insert(s12, s3)
					end
				end

				local s1_2 = {}
				local s5_1 = pairs
				local s2_2 = s8.Inventory or {}

				for s6, s7_1 in s5_1(s2_2) do
					if type(s7_1) == "table" and s7_1.InFuse ~= true then
						table.insert(s1_2, { Uid = s6, Income = r477(s7_1), Equipped = s10[s6] == true })
					end
				end

				table.sort(s1_2, function(t28, t29)
					if t28.Income ~= t29.Income then
						return t28.Income > t29.Income
					end
					return tostring(t28.Uid) < tostring(t29.Uid)
				end)

				return s1_2, s10, #s12, s8
			end

			local function r479(s36, s37)
				local s4 = {}
				local s5 = false

				for s2, s3 in ipairs(s36) do
					if not (s37 < s2) then
						if not s3.Equipped then
							table.insert(s4, s3.Uid)

							if not r471[s3.Uid] then
								s5 = true
							end
						end

						continue
					end

					break
				end

				return s4, s5
			end

			r244.Add(function()
				if not r247.Toggle(r5_14, false) then
					return false
				end
				local s12, s8, s9, s10 = r478()

				if s12 then
					local s8_1 = r476(s10)
					local s9_1, s7_1 = r479(s12, s8_1)

					if (s7_1 or r473) and not r14_6 and os.clock() >= r472 then
						for _, s7_2 in ipairs(s9_1) do
							r471[s7_2] = true
						end

						r473 = false
						r14_6 = true
						r472 = os.clock() + r12_8
						local s5 = r15_6

						task.spawn(function()
							local t11 = r182:FindFirstChild("RF/Haul/FetchWearBestStatus")
							local t7 = t11 and t11:IsA("RemoteFunction")
							local t6 = true

							if t7 then
								local t7_1
								t6, t7_1 = pcall(t11.InvokeServer, t11)
								t6 = t6 and t7_1 ~= false and t7_1 ~= nil
							end

							local t7_2 = r182:FindFirstChild("RF/Haul/WearBest")

							if t6 and s5 == r15_6 and t7_2 and t7_2:IsA("RemoteFunction") then
								pcall(t7_2.InvokeServer, t7_2)
							end

							r14_6 = false
							r244.Wake()
						end)
					end
				end

				return false
			end)

			r5_14 = r187:CreateToggle({
				Name = "Auto Equip Best",
				Note = "Equip Best when a better pet appears",
				Default = false,
				Callback = function()
					r15_6 += 1
					table.clear(r471)
					r472 = 0
					r473 = true
					r244.Wake()
				end,
			})

			local r2_18 = r234.Save

			if type(r2_18) == "table" and type(r2_18.FieldSignal) == "function" then
				for _, r45 in ipairs({ "Inventory", "EquippedAssets" }) do
					local r153_6, r154_2 = pcall(r2_18.FieldSignal, r45)

					if r153_6 and type(r154_2) == "table" and type(r154_2.Connect) == "function" then
						local r152_2, r153_7 = pcall(r154_2.Connect, r154_2, function()
							r473 = true
							r244.Wake()
						end)

						if r152_2 and r153_7 then
							r240(function()
								pcall(function()
									r153_7:Disconnect()
								end)
							end)
						end
					end
				end
			end
		end

		local r485
		r485 = 3
		local r10_6, r488, r489, r490, r491

		do
			local r486 = 50
			r10_6 = { "Rarity Only", "Value Only", "Rarity And Value", "Rarity Or Value" }

			local r487 = r233(function()
				return r181.Shared.Util.AssetItems
			end)

			r488 = {}
			r489 = {}
			r490 = {}
			r491 = {}
			local r47 = r234.Assets and r234.Assets.Directory
			local r1_21 = {}
			local r56 = {}

			if type(r47) == "table" then
				for r47_1, r48 in pairs(r47) do
					local r2_65 = type(r48) == "table" and r48.Rarity or nil
					local r3_22 = type(r2_65) == "table"

					if r3_22 then
						r3_22 = tonumber(r2_65.RarityNumber or r2_65.Rank)
					end

					r3_22 = r3_22 or nil

					if r3_22 then
						local r2_66 = tostring(r2_65.DisplayName or r2_65._id or r3_22)
						r1_21[r3_22] = r1_21[r3_22] or r2_66

						table.insert(r56, {
							Category = tostring(r47_1),
							Name = tostring(r48.DisplayName or r47_1),
							Rarity = r3_22,
							RarityName = r2_66,
						})
					end
				end
			end

			local r53 = {}

			for r50 in pairs(r1_21) do
				table.insert(r53, r50)
			end

			table.sort(r53)

			for _, r54 in ipairs(r53) do
				local r11_10 = string.format("%d - %s", r54, r1_21[r54])
				table.insert(r488, r11_10)
				r489[r11_10] = r54
			end

			table.sort(r56, function(s34, s35)
				if s34.Rarity ~= s35.Rarity then
					return s34.Rarity < s35.Rarity
				end
				return s34.Name < s35.Name
			end)

			for _, r57 in ipairs(r56) do
				local r11_11 = string.format("%s [%s]", r57.Name, r57.RarityName)

				if r491[r11_11] then
					r11_11 = string.format("%s [%s] (%s)", r57.Name, r57.RarityName, r57.Category)
				end

				table.insert(r490, r11_11)
				r491[r11_11] = r57.Category
			end

			local function r18_3(s34)
				for _, s3 in ipairs(r488) do
					if r489[s3] == s34 then
						return s3
					end
				end

				return r488[1]
			end

			local r6_12 = nil
			local r17_4 = nil
			local r5_15 = nil
			local r16_4 = nil
			local r492 = r10_6[1]
			local r493 = 3
			local r494 = 0
			local r495 = true
			local r496 = {}
			local r497 = r10_6[1]
			local r498 = 3
			local r499 = 0
			local r500 = true
			local r501 = {}
			local r502 = false
			local r503 = 0

			local function r504(s14)
				local s14_1 = tonumber(s14) or 0
				local s2 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local s3 = 1

				while math.abs(s14_1) >= 1000 and s3 < #s2 do
					s14_1 /= 1000
					s3 += 1
				end

				return string.format(s3 == 1 and "$%.0f%s" or "$%.2f%s", s14_1, s2[s3])
			end

			local function r505(s32, s33)
				local s4 = {}

				if type(s32) == "table" then
					for s2, s3 in pairs(s32) do
						s2 = s3 == true and type(s2) == "string" and s2

						if s2 then
							s3 = s2
						else
							s3 = type(s3) == "string" and s3
						end

						local s5_2 = s3 or nil

						if s5_2 then
							s4[s33 and s33[s5_2] or s5_2] = true
						end
					end
				end

				return s4
			end

			local function r506(s27)
				local s1 = r234.Assets and r234.Assets.Directory
				local s2 = type(s1) == "table" and s1[tostring(s27)] or nil
				local s1_1 = type(s2) == "table" and s2.Rarity or nil
				local s2_1 = type(s1_1) == "table"

				if s2_1 then
					s2_1 = tonumber(s1_1.RarityNumber or s1_1.Rank)
				end

				return s2_1 or math.huge
			end

			local function r507(s26)
				local s1 = r234.Assets and r234.Assets.Directory
				local s2 = type(s1) == "table" and s1[tostring(s26.Category)] or nil
				local s3 = type(s2) == "table" and tonumber(s2.EarningRate) or 0
				local s1_1 = tonumber(s26.Scale) or 0
				if s3 <= 0 or s1_1 <= 0 then
					return 0
				end
				local s2_2 = s1_1 > 5 and (s1_1 / 5) ^ 1.2 * 19.637875755794113 or s1_1 ^ 1.85
				local s1_2 = r234.Mutations
				local s4 = type(s1_2) == "table" and type(s1_2.EarningsFor) == "function"
				local s23 = 1

				if s4 then
					local s22_1
					s22_1, s23 = pcall(s1_2.EarningsFor, type(s26.Mutations) == "table" and s26.Mutations or {})
					local s1_4 = s22_1 and type(s23) == "number"
					local s6 = 1

					if not s1_4 then
						s23 = s6
					end
				end

				return s3 * s2_2 * s23
			end

			local function r508(s24)
				return type(s24) == "table" and next(s24) ~= nil
			end

			local function r509()
				local s3 = r234.Save
				if type(s3) ~= "table" or type(s3.Get) ~= "function" then
					return nil
				end
				local s2, s3_1 = pcall(s3.Get)
				return s2 and type(s3_1) == "table" and s3_1 or nil
			end

			local function r510()
				local s6 = r509()
				local s11 = {}
				if not s6 then
					return s11, 0
				end
				local s12 = {}
				local s2 = pairs
				local s5 = s6.EquippedAssets or {}

				for _, s4 in s2(s5) do
					s12[s4] = true
				end

				local s5_1 = pairs
				local s2_1 = s6.Inventory or {}
				local s14 = 0

				for s6_1, s7_1 in s5_1(s2_1) do
					local s3_1 = type(s7_1) == "table" and s7_1.InFuse ~= true and s7_1.IsFavorite ~= true and not s12[s6_1] and not r496[tostring(s7_1.Category)]

					if s3_1 then
						s3_1 = not (r495 and r508(s7_1.Mutations))
					end

					if s3_1 then
						local s16 = r507(s7_1)
						local s2_3 = r506(s7_1.Category) <= r493
						local s3_2 = r494 > 0 and s16 < r494

						if r492 ~= r10_6[2] then
							if r492 == r10_6[3] then
								s3_2 = s2_3 and s3_2
							elseif r492 ~= r10_6[4] then
								s3_2 = s2_3
							else
								s3_2 = s2_3 or s3_2
							end
						end

						if s3_2 then
							table.insert(s11, s6_1)
							local s2_4 = type(r487) == "table" and type(r487.SalePrice) == "function"
							local s17 = false
							local s3_3 = nil

							if s2_4 then
								s17, s3_3 = pcall(r487.SalePrice, s7_1)
							end

							s14 += s17 and tonumber(s3_3) or s16 * 100
						end
					end
				end

				return s11, s14
			end

			local function r511()
				local s12 = {}
				local s3 = r234.EggState
				if type(s3) ~= "table" or type(s3.ReadOwnerEggs) ~= "function" then
					return s12, 0
				end
				local s2_1, s5 = pcall(s3.ReadOwnerEggs, r232.UserId)
				if not s2_1 or type(s5) ~= "table" then
					return s12, 0
				end
				local s11 = r232.Character
				s11 = s11 and s11:FindFirstChildWhichIsA("Tool")
				s11 = s11 and s11:GetAttribute("UID") or nil
				local s6 = r234.EggRecords
				local s2_3, s3_2, s4 = pairs(s5)
				local s5_1 = 0

				for s3_3, s4_1 in s2_3, s3_2, s4 do
					local s7 = type(s4_1) == "table" and s4_1.Placement == nil and s3_3 ~= s11 and not r501[tostring(s4_1.AssetCategory)]

					if s7 then
						s7 = not (r500 and r508(s4_1.Mutations))
					end

					if s7 then
						local s7_1 = r507({ Category = s4_1.AssetCategory, Scale = s4_1.AssetScale, Mutations = s4_1.Mutations })
						local s8 = r506(s4_1.AssetCategory) <= r498
						local s9_1 = r499 > 0 and s7_1 < r499

						if r497 == r10_6[2] then
							s8 = s9_1
						elseif r497 == r10_6[3] then
							s8 = s8 and s9_1
						elseif r497 == r10_6[4] then
							s8 = s8 or s9_1
						end

						if s8 then
							table.insert(s12, s3_3)

							if type(s6) == "table" and type(s6.SellPrice) == "function" then
								local s7_3, s8_2 = pcall(s6.SellPrice, s4_1)
								s5_1 += s7_3 and tonumber(s8_2) or 0
							end
						end
					end
				end

				return s12, s5_1
			end

			local function r512(s17, s18)
				local s2 = r182:FindFirstChild("RE/PetSatchel/SellSelection")
				if not s2 or not s2:IsA("RemoteEvent") then
					return false
				end
				local s3_1 = math.max(#s17, #s18)
				local s4 = 1

				while s4 <= s3_1 do
					local s7 = {}
					local s10 = {}

					for s5 = s4, s4 + r486 - 1 do
						if s17[s5] then
							table.insert(s7, s17[s5])
						end

						if s18[s5] then
							table.insert(s10, s18[s5])
						end
					end

					pcall(s2.FireServer, s2, { Eggs = s10, Assets = s7 })
					s4 += r486

					if s4 <= s3_1 then
						task.wait(0.3)
					end
				end

				return true
			end

			local function r513(s13, s14)
				if r502 or #s13 == 0 and #s14 == 0 then
					return
				end
				r502 = true
				r503 = os.clock() + r485

				task.spawn(function()
					pcall(r512, s13, s14)
					r502 = false
					r244.Wake()
				end)
			end

			r244.Add(function()
				local s10 = r247.Toggle(r6_12, false)
				local s11 = r247.Toggle(r17_4, false)
				local s13, s6 = r510()
				local s16, s15 = r511()

				if r5_15 and type(r5_15.Set) == "function" then
					pcall(r5_15.Set, r5_15, string.format("Pet matches  -  %d pets for %s", #s13, r504(s6)))
				end

				if r16_4 and type(r16_4.Set) == "function" then
					pcall(r16_4.Set, r16_4, string.format("Egg matches  -  %d eggs for %s", #s16, r504(s15)))
				end

				local s3_1 = r502
				local s4

				if r502 then
					s4 = s3_1
				else
					s4 = os.clock() < r503
				end

				local s2

				if s4 then
					s2 = s4
				else
					s2 = not (s10 or s11)
				end

				if s2 then
					return false
				end
				r513(s10 and s13 or {}, s11 and s16 or {})
				return false
			end)

			r5_15 = r188:CreateText({ Name = "Pet Sell Preview", Text = "Pet matches  -  0 pets" })

			r6_12 = r188:CreateToggle({
				Name = "Auto Sell Pet",
				Default = false,
				Callback = function()
					r244.Wake()
				end,
			})

			r188:CreateButton({
				Name = "Sell Pets Now",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = r6_12,
				Callback = function()
					r513(r510(), {})
				end,
			})

			r188:CreateDropdown({
				Name = "Sell Pet Rule",
				Note = "Which checks must pass to sell",
				Options = r10_6,
				Default = r10_6[1],
				SubOf = r6_12,
				Callback = function(s32)
					if table.find(r10_6, s32) then
						r492 = s32
						r244.Wake()
					end
				end,
			})

			r188:CreateDropdown({
				Name = "Pet Max Rarity",
				Note = "Sell pets at or below this rarity",
				Options = r488,
				Default = r18_3(3),
				SubOf = r6_12,
				Callback = function(arg1)
					r493 = r489[arg1] or r493
					r244.Wake()
				end,
			})

			local r514 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local function r11_12(s25, s26, s27, s28)
				local s3 = 0
				local s4 = "M/s"

				local function s5(t29, t30)
					if t29 ~= nil then
						s3 = math.max(0, math.floor(tonumber(t29) or s3))
					end

					if t30 ~= nil then
						s4 = tostring(t30)
					end

					s28(s3 * (r514[s4] or r514["M/s"]).Mult)
					r244.Wake()
				end

				return (r192(r188, {
					Name = s25 == "Pet Value Threshold" and "Pet Sell Value" or s25 == "Egg Value Threshold" and "Egg Sell Value" or s25,
					Note = s26,
					SubOf = s27,
					Legacy = s25,
					SectionName = "Auto Sell",
					OnRaw = function(arg1)
						s5(math.floor(arg1 / 1000), "K/s")
					end,
				}))
			end

			r11_12("Pet Value Threshold", "Sell pets worth less than this (0 = off)", r6_12, function(arg1)
				r494 = arg1
			end)

			local r12_9 = nil

			r12_9 = r188:CreateToggle({
				Name = "Keep Mutated Pets",
				Note = "Never sell mutated pets",
				Default = true,
				SubOf = r6_12,
				Callback = function()
					r495 = r247.Toggle(r12_9, true)
					r244.Wake()
				end,
			})

			r243(r188:CreateMultiDropdown({
				Name = "Blacklist Sell Pets",
				Note = "These pets are never sold",
				Options = r490,
				Default = {},
				SubOf = r6_12,
				Callback = function(arg1)
					r496 = r505(arg1, r491)
					r244.Wake()
				end,
			}))

			r16_4 = r188:CreateText({ Name = "Egg Sell Preview", Text = "Egg matches  -  0 eggs" })

			r17_4 = r188:CreateToggle({
				Name = "Auto Sell Egg",
				Note = "Sell bag eggs matching the rules below",
				Default = false,
				Callback = function()
					r244.Wake()
				end,
			})

			r188:CreateButton({
				Name = "Sell Eggs Now",
				Note = "Sell matching eggs once",
				ButtonText = "Sell",
				ConfirmText = "Sold!",
				SubOf = r17_4,
				Callback = function()
					local s2 = r511()
					r513({}, s2)
				end,
			})

			r188:CreateDropdown({
				Name = "Sell Egg Rule",
				Note = "Which checks must pass to sell",
				Options = r10_6,
				Default = r10_6[1],
				SubOf = r17_4,
				Callback = function(s11)
					if table.find(r10_6, s11) then
						r497 = s11
						r244.Wake()
					end
				end,
			})

			r188:CreateDropdown({
				Name = "Egg Max Rarity",
				Note = "Sell eggs at or below this rarity",
				Options = r488,
				Default = r18_3(3),
				SubOf = r17_4,
				Callback = function(arg1)
					r498 = r489[arg1] or r498
					r244.Wake()
				end,
			})

			r11_12("Egg Value Threshold", "Sell eggs worth less than this (0 = off)", r17_4, function(arg1)
				r499 = arg1
			end)

			local r11_13 = nil

			r11_13 = r188:CreateToggle({
				Name = "Keep Mutated Eggs",
				Note = "Never sell mutated eggs",
				Default = true,
				SubOf = r17_4,
				Callback = function()
					r500 = r247.Toggle(r11_13, true)
					r244.Wake()
				end,
			})

			r243(r188:CreateMultiDropdown({
				Name = "Blacklist Sell Eggs",
				Note = "These eggs are never sold",
				Options = r490,
				Default = {},
				SubOf = r17_4,
				Callback = function(arg1)
					r501 = r505(arg1, r491)
					r244.Wake()
				end,
			}))
		end

		local r2_19 = r234.Save

		if type(r2_19) == "table" and type(r2_19.FieldSignal) == "function" then
			for _, r60 in ipairs({ "Inventory", "EggInventory", "EquippedAssets" }) do
				local r153_8, r154_3 = pcall(r2_19.FieldSignal, r60)

				if r153_8 and type(r154_3) == "table" and type(r154_3.Connect) == "function" then
					local r152_3, r153_9 = pcall(r154_3.Connect, r154_3, function()
						r244.Wake()
					end)

					if r152_3 and r153_9 then
						r240(function()
							pcall(function()
								r153_9:Disconnect()
							end)
						end)
					end
				end
			end
		end

		local r19_2
		r19_2 = 2
		local r20_3
		r20_3 = 3
		local r551
		r551 = 20
		local r10_7
		r10_7 = { "Lowest Rarity First", "Highest Rarity First", "Most Copies First", "Lowest Value First" }
		local r5_16
		r5_16 = { "Lowest To Highest", "Highest To Lowest" }
		local r552
		r552 = {}
		local r553
		r553 = {}
		local r554
		r554 = {}
		local r556
		r556 = {}

		do
			local r62 = r234.Assets and r234.Assets.Directory
			local r1_24 = {}
			local r71 = {}

			if type(r62) == "table" then
				for r62_1, r63 in pairs(r62) do
					local r2_63 = type(r63) == "table" and r63.Rarity or nil
					local r3_21 = type(r2_63) == "table"

					if r3_21 then
						r3_21 = tonumber(r2_63.RarityNumber or r2_63.Rank)
					end

					r3_21 = r3_21 or nil

					if r3_21 then
						local r2_64 = tostring(r2_63.DisplayName or r2_63._id or r3_21)
						r1_24[r3_21] = r1_24[r3_21] or r2_64

						table.insert(r71, {
							Category = tostring(r62_1),
							Name = tostring(r63.DisplayName or r62_1),
							Rarity = r3_21,
							RarityName = r2_64,
						})
					end
				end
			end

			local r68 = {}

			for r65 in pairs(r1_24) do
				table.insert(r68, r65)
			end

			table.sort(r68)

			for _, r69 in ipairs(r68) do
				local r11_14 = string.format("%d - %s", r69, r1_24[r69])
				table.insert(r552, r11_14)
				r553[r11_14] = r69
			end

			table.sort(r71, function(s11, s12)
				if s11.Rarity ~= s12.Rarity then
					return s11.Rarity < s12.Rarity
				end
				return s11.Name < s12.Name
			end)

			for _, r72 in ipairs(r71) do
				local r151_3 = string.format("%s [%s]", r72.Name, r72.RarityName)

				if r556[r151_3] then
					r151_3 = string.format("%s [%s] (%s)", r72.Name, r72.RarityName, r72.Category)
				end

				table.insert(r554, r151_3)
				r556[r151_3] = r72.Category
			end
		end

		do
			local function r12_10(s12)
				for _, s4 in ipairs(r552) do
					if r553[s4] == s12 then
						return s4
					end
				end

				return r552[#r552]
			end

			local r11_15 = nil
			local r6_13 = nil
			local r14_7 = r10_7[1]
			local r558 = r5_16[1]
			local r559 = 6
			local r560 = {}
			local r561 = true
			local r562 = true
			local r563 = false
			local r564 = 0
			local r565 = 0
			local r566 = 0
			local r567 = {}

			local function r568(s13, s14)
				local s2 = r182:FindFirstChild(s13)
				if not s2 or not s2:IsA("RemoteFunction") then
					return false, nil
				end

				if s14 == nil then
					return pcall(s2.InvokeServer, s2)
				end
				return pcall(s2.InvokeServer, s2, s14)
			end

			local function r569()
				local s3 = r234.Save
				if type(s3) ~= "table" or type(s3.Get) ~= "function" then
					return nil
				end
				local s2_1, s3_1 = pcall(s3.Get)
				return s2_1 and type(s3_1) == "table" and s3_1 or nil
			end

			local function r570(s16)
				local s1 = r234.Assets and r234.Assets.Directory
				return type(s1) == "table" and s1[tostring(s16)] or nil
			end

			local function r571(s28)
				local s2 = r570(s28)
				local s4 = type(s2) == "table" and s2.Rarity or nil
				local s2_1 = type(s4) == "table"

				if s2_1 then
					s2_1 = tonumber(s4.RarityNumber or s4.Rank)
				end

				return s2_1 or math.huge
			end

			local function r572(s27)
				local s1 = r570(s27)
				return tostring(type(s1) == "table" and s1.DisplayName or s27)
			end

			local function r573(s8)
				local s2 = r570(s8.Category)
				local s10 = type(s2) == "table" and tonumber(s2.EarningRate) or 0
				local s2_1 = tonumber(s8.Scale) or 0
				if s10 <= 0 or s2_1 <= 0 then
					return 0
				end
				local s11 = s2_1 > 5 and (s2_1 / 5) ^ 1.2 * 19.637875755794113 or s2_1 ^ 1.85
				local s2_2 = r234.Mutations
				local s4_2 = type(s2_2) == "table" and type(s2_2.EarningsFor) == "function"
				local s5_1 = 1

				if s4_2 then
					local s4_4
					s4_4, s5_1 = pcall(s2_2.EarningsFor, type(s8.Mutations) == "table" and s8.Mutations or {})
					s4_4 = s4_4 and type(s5_1) == "number"
					local s2_4 = 1

					if not s4_4 then
						s5_1 = s2_4
					end
				end

				return s10 * s11 * s5_1
			end

			local function r574(s34)
				return type(s34) == "table" and next(s34) ~= nil
			end

			local function r575(s33)
				local s2 = tonumber(s33) or 0
				local s25 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local s3 = 1

				while math.abs(s2) >= 1000 and s3 < #s25 do
					s2 /= 1000
					s3 += 1
				end

				return string.format(s3 == 1 and "$%.0f%s" or "$%.2f%s", s2, s25[s3])
			end

			local function r576(s10)
				local s4 = r234.FuseKernel
				if type(s4) ~= "table" or type(s4.PriceFor) ~= "function" then
					return nil
				end
				local s8, s9 = pcall(s4.PriceFor, s10)
				return s8 and tonumber(s9) or nil
			end

			local function r577(s20, s21, s22)
				local s1 = type(s21) == "table" and s21.IsFavorite ~= true and not s22[s20] and r571(s21.Category) <= r559 and (next(r560) == nil or r560[tostring(s21.Category)] == true)

				if s1 then
					s1 = not (r561 and r574(s21.Mutations))
				end

				local s3

				if s1 then
					s3 = (r567[s20] or 0) <= os.clock()
				else
					s3 = s1
				end

				return s3
			end

			local function r578(s32)
				local s21 = type(s32.Inventory) == "table" and s32.Inventory or {}
				local s33 = {}
				local s2 = pairs
				local s5 = s32.EquippedAssets or {}

				for _, s4 in s2(s5) do
					s33[s4] = true
				end

				local s3_1 = {}
				local s8 = {}

				for s2_1 = 1, 3 do
					local s4_1 = type(s32.FusionSlots) == "table" and s32.FusionSlots[s2_1] or nil

					if s4_1 ~= nil and type(s21[s4_1]) == "table" then
						table.insert(s3_1, s4_1)
						s8[s4_1] = true
					end
				end

				local s4_2 = {}

				for s6, s7 in pairs(s21) do
					if not s8[s6] and type(s7) == "table" and s7.InFuse ~= true and r577(s6, s7, s33) then
						local s2_3 = tostring(s7.Category)
						s4_2[s2_3] = s4_2[s2_3] or {}
						table.insert(s4_2[s2_3], { Uid = s6, Item = s7, Income = r573(s7) })
					end
				end

				local function s5_1(arg1)
					table.sort(arg1, function(u28, u29)
						if u28.Income ~= u29.Income then
							if r558 == r5_16[2] then
								return u28.Income > u29.Income
							end
							return u28.Income < u29.Income
						end

						return tostring(u28.Uid) < tostring(u29.Uid)
					end)
				end

				if #s3_1 > 0 then
					local s2_4 = tostring(s21[s3_1[1]].Category)
					local s6_1 = true

					for _, s16 in ipairs(s3_1) do
						local s32_1 = s21[s16]

						if tostring(s32_1.Category) ~= s2_4 or not r577(s16, s32_1, s33) then
							s6_1 = false
						end
					end

					local s4_3 = s4_2[s2_4] or {}

					if s6_1 and #s3_1 + #s4_3 >= 3 then
						s5_1(s4_3)
						local s5_2 = { Category = s2_4, Load = {}, Items = {} }

						for _, s20 in ipairs(s3_1) do
							table.insert(s5_2.Items, s21[s20])
						end

						for s6_2 = 1, 3 - #s3_1 do
							table.insert(s5_2.Load, s4_3[s6_2].Uid)
							table.insert(s5_2.Items, s4_3[s6_2].Item)
						end

						return s5_2
					end

					if r562 then
						return { Category = s2_4, Eject = s3_1 }
					end
					return nil, "Machine holds pets that cannot finish a fuse"
				end

				local s7_1 = nil
				local s14 = nil

				for s9_1, s10_1 in pairs(s4_2) do
					if #s10_1 >= 3 then
						local s2_5 = r571(s9_1)
						local s15_1 = 0

						for _, s13 in ipairs(s10_1) do
							s15_1 += s13.Income
						end

						local s34

						if r14_7 == r10_7[2] then
							s34 = { -s2_5, -#s10_1 }
						elseif r14_7 == r10_7[3] then
							s34 = { -#s10_1, s2_5 }
						elseif r14_7 == r10_7[4] then
							s34 = { s15_1 / #s10_1, s2_5 }
						else
							s34 = { s2_5, -#s10_1 }
						end

						if s7_1 == nil or s34[1] < s7_1[1] or s34[1] == s7_1[1] and (s34[2] < s7_1[2] or s34[2] == s7_1[2] and s9_1 < s14) then
							s7_1 = s34
							s14 = s9_1
						end
					end
				end

				if not s14 then
					return nil, "No three matching pets"
				end
				local s2_7 = s4_2[s14]
				s5_1(s2_7)
				local s7_3 = { Category = s14, Load = {}, Items = {} }

				for s8_1 = 1, 3 do
					table.insert(s7_3.Load, s2_7[s8_1].Uid)
					table.insert(s7_3.Items, s2_7[s8_1].Item)
				end

				return s7_3
			end

			local function r579(s5)
				local s7 = r569()
				if not s7 then
					return
				end

				if s7.FusionLocked == true then
					if type(s7.FusionEggReward) == "table" and os.clock() >= r566 then
						r566 = os.clock() + r20_3
						r568("RF/Fusery/FinishReveal")
					end

					return
				end

				local s8 = r578(s7)
				if not s8 then
					return
				end

				if s8.Eject then
					for _, s4 in ipairs(s8.Eject) do
						if s5 ~= r564 then
							return
						end
						r568("RF/Fusery/EjectPet", s4)
						task.wait(0.35)
					end

					return
				end

				local s2_1 = r576(s8.Items)
				local s3 = tonumber(s7.Money)
				if s2_1 and s3 and s3 < s2_1 then
					return
				end

				for _, s9 in ipairs(s8.Load) do
					if s5 ~= r564 then
						return
					end
					local s2_2, s3_2 = r568("RF/Fusery/LoadPet", s9)
					if not s2_2 or s3_2 == false then
						r567[s9] = os.clock() + r551
						return
					end
					task.wait(0.35)
				end

				if s5 ~= r564 then
					return
				end
				local s7_1, s8_2 = r568("RF/Fusery/BeginFuse")

				if s7_1 and s8_2 ~= false then
					r566 = os.clock() + r20_3
				end
			end

			local function r580(s10)
				if not s10 then
					return "Fuse status unknown"
				end

				if s10.FusionLocked == true then
					return "Machine is fusing, waiting for the egg"
				end
				local s8, s9 = r578(s10)
				if not s8 then
					return s9 or "No three matching pets"
				end

				if s8.Eject then
					return string.format("Would eject %d %s that cannot finish a fuse", #s8.Eject, r572(s8.Category))
				end
				local s12 = r576(s8.Items)
				local s2_1 = tonumber(s10.Money)
				local s13 = s12 and s2_1 and s2_1 < s12 and "  (not enough money)" or ""
				return string.format("Next fuse  -  3 %s for %s%s", r572(s8.Category), s12 and r575(s12) or "?", s13)
			end

			r244.Add(function()
				local s5 = r569()

				if r6_13 and type(r6_13.Set) == "function" then
					pcall(r6_13.Set, r6_13, r580(s5))
				end

				if not r247.Toggle(r11_15, false) or r563 or os.clock() < r565 then
					return false
				end
				r563 = true
				r565 = os.clock() + r19_2
				local s2_1 = r564

				task.spawn(function()
					pcall(r579, s2_1)
					r563 = false
					r244.Wake()
				end)

				return false
			end)

			r6_13 = r189:CreateText({ Name = "Fuse Preview", Text = "Fuse status unknown" })

			r11_15 = r189:CreateToggle({
				Name = "Auto Fuse Machine",
				Note = "Fuse 3 same pets into an egg, nonstop",
				Default = false,
				Callback = function()
					r564 += 1
					table.clear(r567)
					r565 = 0
					r244.Wake()
				end,
			})

			r189:CreateDropdown({
				Name = "Fuse Priority Mode",
				Options = r10_7,
				Default = r10_7[1],
				SubOf = r11_15,
				Callback = function(s28)
					if table.find(r10_7, s28) then
						r14_7 = s28
						r244.Wake()
					end
				end,
			})

			r189:CreateDropdown({
				Name = "Pets To Use",
				Options = r5_16,
				Default = r5_16[1],
				SubOf = r11_15,
				Callback = function(s32)
					if table.find(r5_16, s32) then
						r558 = s32
						r244.Wake()
					end
				end,
			})

			r189:CreateDropdown({
				Name = "Max Rarity to Fuse",
				Options = r552,
				Default = r12_10(6),
				SubOf = r11_15,
				Callback = function(arg1)
					r559 = r553[arg1] or r559
					r244.Wake()
				end,
			})

			r243(r189:CreateMultiDropdown({
				Name = "Specific Species to Fuse",
				Note = "Only fuse these species (empty = all)",
				Options = r554,
				Default = {},
				SubOf = r11_15,
				Callback = function(s3)
					local s6 = {}

					if type(s3) == "table" then
						for s3_1, s4 in pairs(s3) do
							s3_1 = s4 == true and type(s3_1) == "string" and s3_1
							local s8_1

							if s3_1 then
								s8_1 = s3_1
							else
								s8_1 = type(s4) == "string" and s4
							end

							s8_1 = s8_1 or nil

							if s8_1 and r556[s8_1] then
								s6[r556[s8_1]] = true
							end
						end
					end

					r560 = s6
					r244.Wake()
				end,
			}))

			local r12_11 = nil

			r12_11 = r189:CreateToggle({
				Name = "Skip Mutated Pets",
				Default = true,
				SubOf = r11_15,
				Callback = function()
					r561 = r247.Toggle(r12_11, true)
					r244.Wake()
				end,
			})

			local r13_5 = nil

			r13_5 = r189:CreateToggle({
				Name = "Eject Incomplete Slots",
				Note = "Take out pets that can't make a set",
				Default = true,
				SubOf = r11_15,
				Callback = function()
					r562 = r247.Toggle(r13_5, true)
					r244.Wake()
				end,
			})
		end

		local r2_20 = r234.Save

		if type(r2_20) == "table" and type(r2_20.FieldSignal) == "function" then
			for _, r75 in ipairs({
				"Inventory",
				"EquippedAssets",
				"FusionSlots",
				"FusionLocked",
				"FusionEggReward",
				"Money",
			}) do
				local r153_10, r154_4 = pcall(r2_20.FieldSignal, r75)

				if r153_10 and type(r154_4) == "table" and type(r154_4.Connect) == "function" then
					local r152_4, r153_11 = pcall(r154_4.Connect, r154_4, function()
						r244.Wake()
					end)

					if r152_4 and r153_11 then
						r240(function()
							pcall(function()
								r153_11:Disconnect()
							end)
						end)
					end
				end
			end
		end
	end

	do
		local r19_3 = 2
		local r21_2 = 25
		local r22 = 4
		local r5_17 = { "Match Any", "Match All" }
		local r10_8 = { "Golden", "Silver", "Rainbow", "Boss", "Monstrous", "Sakura", "GreatBloom" }
		local r17_5 = "Any Mutation"
		local r3_12 = { "Off" }
		local r602 = {}
		local r603 = {}
		local r604 = {}
		local r6_14 = { "Any Mutation" }
		local r605 = {}
		local r77 = r234.Assets and r234.Assets.Directory
		local r1_27 = {}
		local r86 = {}

		if type(r77) == "table" then
			for r77_1, r78 in pairs(r77) do
				local r2_21 = type(r78) == "table" and r78.Rarity or nil
				local r11_16 = type(r2_21) == "table"

				if r11_16 then
					r11_16 = tonumber(r2_21.RarityNumber or r2_21.Rank)
				end

				r11_16 = r11_16 or nil

				if r11_16 then
					local r2_22 = tostring(r2_21.DisplayName or r2_21._id or r11_16)
					r1_27[r11_16] = r1_27[r11_16] or r2_22

					table.insert(r86, {
						Category = tostring(r77_1),
						Name = tostring(r78.DisplayName or r77_1),
						Rarity = r11_16,
						RarityName = r2_22,
					})
				end
			end
		end

		local r83 = {}

		for r80 in pairs(r1_27) do
			table.insert(r83, r80)
		end

		table.sort(r83)

		for _, r84 in ipairs(r83) do
			local r11_17 = string.format("%d - %s", r84, r1_27[r84])
			table.insert(r3_12, r11_17)
			r602[r11_17] = r84
		end

		table.sort(r86, function(s20, s21)
			if s20.Rarity ~= s21.Rarity then
				return s20.Rarity < s21.Rarity
			end
			return s20.Name < s21.Name
		end)

		for _, r87 in ipairs(r86) do
			local r151_4 = string.format("%s [%s]", r87.Name, r87.RarityName)

			if r604[r151_4] then
				r151_4 = string.format("%s [%s] (%s)", r87.Name, r87.RarityName, r87.Category)
			end

			table.insert(r603, r151_4)
			r604[r151_4] = r87.Category
		end

		local r92 = {}
		local r1_28 = r234.Mutations

		if type(r1_28) == "table" and type(r1_28.IdSet) == "table" then
			for r89 in pairs(r1_28.IdSet) do
				table.insert(r92, tostring(r89))
			end
		end

		if #r92 == 0 then
			r92 = table.clone(r10_8)
		end

		table.sort(r92, function(s12, s13)
			return r263(s12) < r263(s13)
		end)

		for _, r93 in ipairs(r92) do
			local r1_29 = r263(r93)
			table.insert(r6_14, r1_29)
			r605[r1_29] = r93
		end

		local r14_8 = nil
		local r15_7 = nil
		local r16_5 = nil
		local r10_9 = nil
		local r612_1 = r5_17[2]
		local r613 = nil
		local r614 = false
		local r615 = {}
		local r616 = 0
		local r617 = {}
		local r618 = false
		local r619 = 0
		local r620 = {}

		local function r621()
			local s3 = r234.Save
			if type(s3) ~= "table" or type(s3.Get) ~= "function" then
				return nil
			end
			local s2_1, s3_1 = pcall(s3.Get)
			return s2_1 and type(s3_1) == "table" and s3_1 or nil
		end

		local function r622(s29)
			local s2 = r234.Assets and r234.Assets.Directory
			return type(s2) == "table" and s2[tostring(s29)] or nil
		end

		local function r623(s27)
			local s1 = r622(s27)
			local s1_1 = type(s1) == "table" and s1.Rarity or nil
			local s2_1 = type(s1_1) == "table"

			if s2_1 then
				s2_1 = tonumber(s1_1.RarityNumber or s1_1.Rank)
			end

			return s2_1 or 0
		end

		local function r624(s24)
			local s1 = r622(s24.Category)
			local s4 = type(s1) == "table" and tonumber(s1.EarningRate) or 0
			local s1_1 = tonumber(s24.Scale) or 0
			if s4 <= 0 or s1_1 <= 0 then
				return 0
			end
			local s2_2 = s1_1 > 5 and (s1_1 / 5) ^ 1.2 * 19.637875755794113 or s1_1 ^ 1.85
			local s1_2 = r234.Mutations
			local s6 = type(s1_2) == "table" and type(s1_2.EarningsFor) == "function"
			local s21 = 1

			if s6 then
				local s20_1
				s20_1, s21 = pcall(s1_2.EarningsFor, type(s24.Mutations) == "table" and s24.Mutations or {})
				s20_1 = s20_1 and type(s21) == "number"
				local s1_4 = 1

				if not s20_1 then
					s21 = s1_4
				end
			end

			return s4 * s2_2 * s21
		end

		local function r625(s19)
			local s6 = {}

			if type(s19.Mutations) == "table" then
				for s3_1, s4 in pairs(s19.Mutations) do
					if type(s4) == "string" then
						s6[s4] = true
					elseif s4 == true and type(s3_1) == "string" then
						s6[s3_1] = true
					end
				end
			end

			if type(s19.BaseMutation) == "string" and s19.BaseMutation ~= "" then
				s6[s19.BaseMutation] = true
			end

			return s6
		end

		local function r626(s27)
			if r617[tostring(s27.Category)] then
				return true
			end
			local s4 = 0
			local s5 = 0

			if r613 then
				s5 = 1

				if r613 <= r623(s27.Category) then
					s4 = 1
				end
			end

			if r614 or next(r615) ~= nil then
				s5 += 1
				local s2_1 = r625(s27)

				if r614 and next(s2_1) ~= nil then
					s4 += 1
				else
					local s8 = false

					for s2_3 in pairs(s2_1) do
						if r615[s2_3] then
							s8 = true
							break
						end
					end

					if s8 then
						s4 += 1
					end
				end
			end

			local s2_2

			if r616 > 0 then
				local s1 = s5 + 1

				if not (r616 <= r624(s27)) then
					s2_2 = s1
				else
					s4 += 1
					s2_2 = s1
				end
			else
				s2_2 = s5
			end

			if s2_2 == 0 then
				return false
			end

			if r612_1 == r5_17[2] then
				return s4 == s2_2
			end
			return s4 > 0
		end

		local function r627(arg1)
			return (r620[arg1] or 0) > os.clock()
		end

		local function r628(arg1)
			local s10 = {}
			local s2_1, s3_1, s4 = pairs(arg1.Inventory or {})
			local s6_1 = 0

			for s3_2, s4_1 in s2_1, s3_1, s4 do
				if type(s4_1) == "table" and r626(s4_1) then
					s6_1 += 1

					if s4_1.IsFavorite ~= true and not r627(s3_2) then
						table.insert(s10, s3_2)
					end
				end
			end

			return s10, s6_1
		end

		local function r629(s31, s32, s33)
			local s6 = {}
			local s7 = s31.Inventory or {}
			local s1 = pairs
			local s4 = s31.EquippedAssets or {}

			for _, s3 in s1(s4) do
				local s4_1 = s7[s3]

				if type(s4_1) == "table" and not r627(s3) then
					if s32 then
						if s4_1.IsFavorite ~= true then
							table.insert(s6, s3)
						end
					else
						local s8_1 = s4_1.IsFavorite == true

						if s8_1 then
							s8_1 = not (s33 and r626(s4_1))
						end

						if s8_1 then
							table.insert(s6, s3)
						end
					end
				end
			end

			return s6
		end

		local function r630(s5, s6)
			local s3 = r182:FindFirstChild("RE/PetSatchel/WriteFavourite")
			if not s3 or not s3:IsA("RemoteEvent") then
				return
			end

			for s9, s10 in ipairs(s5) do
				if not (r21_2 < s9) then
					r620[s10] = os.clock() + r22
					pcall(s3.FireServer, s3, s10, s6)
					task.wait(0.12)
					continue
				end

				break
			end
		end

		local function r631(s12, s13)
			if r618 or #s12 == 0 then
				return false
			end
			r618 = true
			r619 = os.clock() + r19_3

			task.spawn(function()
				pcall(r630, s12, s13)
				r618 = false
				r244.Wake()
			end)

			return true
		end

		r244.Add(function()
			local s17 = r621()
			if not s17 then
				return false
			end
			local s15 = r247.Toggle(r14_8, false)
			local s12, s9 = r628(s17)

			if r10_9 and type(r10_9.Set) == "function" then
				local s4 = pairs
				local s7 = s17.Inventory or {}
				local s11 = 0

				for _, s6 in s4(s7) do
					if type(s6) == "table" and s6.IsFavorite == true then
						s11 += 1
					end
				end

				pcall(r10_9.Set, r10_9, string.format("Favorite matches  -  %d pets, %d to mark  |  %d favorited", s9, #s12, s11))
			end

			if r618 or os.clock() < r619 then
				return false
			end

			if s15 and r631(s12, true) then
				return false
			end

			if r247.Toggle(r15_7, false) then
				if r631(r629(s17, true, false), true) then
					return false
				end
			elseif r247.Toggle(r16_5, false) then
				r631(r629(s17, false, s15), false)
			end

			return false
		end)

		r10_9 = r190.CreateText
		r10_9 = r10_9(r190, { Name = "Favorite Preview", Text = "Favorite matches  -  0 pets" })

		r14_8 = r190:CreateToggle({
			Name = "Auto Favorite Pet",
			Note = "Favorite pets matching the rules below",
			Default = false,
			Callback = function()
				table.clear(r620)
				r244.Wake()
			end,
		})

		r190:CreateButton({
			Name = "Favorite Pets Now",
			Note = "Favorite matching pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			SubOf = r14_8,
			Callback = function()
				local s3 = r621()

				if s3 then
					r631(r628(s3), true)
				end
			end,
		})

		r190:CreateDropdown({
			Name = "Favorite Rule",
			Note = "Pass any check or all checks",
			Options = r5_17,
			Default = r5_17[2],
			SubOf = r14_8,
			Callback = function(s35)
				if table.find(r5_17, s35) then
					r612_1 = s35
					r244.Wake()
				end
			end,
		})

		r190:CreateDropdown({
			Name = "Favorite Min Rarity",
			Note = "Favorite pets of the chosen rarity and every rarity above it (Off = skip)",
			Options = r3_12,
			Default = "Off",
			SubOf = r14_8,
			Callback = function(arg1)
				r613 = r602[arg1]
				r244.Wake()
			end,
		})

		r243(r190:CreateMultiDropdown({
			Name = "Favorite Mutations",
			Note = "Mutation check (empty = skip)",
			Options = r6_14,
			Default = {},
			SubOf = r14_8,
			Callback = function(s3)
				local s5 = {}
				local s9 = false

				if type(s3) == "table" then
					for s2, s3_1 in pairs(s3) do
						local s11 = s3_1 == true and type(s2) == "string" and s2 or type(s3_1) == "string" and s3_1 or nil

						if s11 == r17_5 then
							s9 = true
						elseif s11 then
							s5[r605[s11] or s11] = true
						end
					end
				end

				r614 = s9
				r615 = s5
				r244.Wake()
			end,
		}))

		local r6_15 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local r11_18 = 0
		local r12_16 = "M/s"

		local function r13_6(s25, s26)
			if s25 ~= nil then
				r11_18 = math.max(0, math.floor(tonumber(s25) or r11_18))
			end

			if s26 ~= nil then
				r12_16 = tostring(s26)
			end

			r616 = r11_18 * (r6_15[r12_16] or r6_15["M/s"]).Mult
			r244.Wake()
		end

		r192(r190, {
			Name = "Min Favorite Value",
			Note = "Value check (0 = skip)",
			SubOf = r14_8,
			Legacy = "Favorite Min Value",
			SectionName = "Auto Favorite",
			OnRaw = function(arg1)
				r13_6(math.floor(arg1 / 1000), "K/s")
			end,
		})

		r243(r190:CreateMultiDropdown({
			Name = "Always Favorite Species",
			Note = "Always favorite these species",
			Options = r603,
			Default = {},
			SubOf = r14_8,
			Callback = function(s29)
				local s4 = {}

				if type(s29) == "table" then
					for s2, s3 in pairs(s29) do
						s2 = s3 == true and type(s2) == "string" and s2

						if s2 then
							s3 = s2
						else
							s3 = type(s3) == "string" and s3
						end

						s3 = s3 or nil

						if s3 and r604[s3] then
							s4[r604[s3]] = true
						end
					end
				end

				r617 = s4
				r244.Wake()
			end,
		}))

		r15_7 = r190:CreateToggle({
			Name = "Auto Favorite Equipped",
			Note = "Keep equipped pets favorited",
			Default = false,
			Callback = function()
				r244.Wake()
			end,
		})

		r16_5 = r190:CreateToggle({
			Name = "Auto Unfavorite Equipped",
			Note = "Unfavorite equipped pets not in the rules",
			Default = false,
			Callback = function()
				r244.Wake()
			end,
		})

		r190:CreateButton({
			Name = "Favorite Equipped Now",
			Note = "Favorite all equipped pets once",
			ButtonText = "Favorite",
			ConfirmText = "Done!",
			Callback = function()
				local s6 = r621()

				if s6 then
					r631(r629(s6, true, false), true)
				end
			end,
		})

		r190:CreateButton({
			Name = "Unfavorite Equipped Now",
			Note = "Unfavorite all equipped pets once",
			ButtonText = "Unfavorite",
			ConfirmText = "Done!",
			Callback = function()
				local s6 = r621()

				if s6 then
					r631(r629(s6, false, false), false)
				end
			end,
		})
	end

	local r2_24 = r234.Save

	if type(r2_24) == "table" and type(r2_24.FieldSignal) == "function" then
		for _, r96 in ipairs({ "Inventory", "EquippedAssets" }) do
			local r153_12, r154_5 = pcall(r2_24.FieldSignal, r96)

			if r153_12 and type(r154_5) == "table" and type(r154_5.Connect) == "function" then
				local r152_5, r153_13 = pcall(r154_5.Connect, r154_5, function()
					r244.Wake()
				end)

				if r152_5 and r153_13 then
					r240(function()
						pcall(function()
							r153_13:Disconnect()
						end)
					end)
				end
			end
		end
	end

	r247.MechBoot = function(s16)
		local s15, s20 = pcall(function()
			return require(r181.Shared.Util.ScrambleBossHazards)
		end)

		local s22 = {
			Handle = nil,
			Row = nil,
			Status = "Idle",
			Shown = nil,
			Busy = false,
			Generation = 0,
			Hazards = {},
			TravelSpeed = 250,
			Radius = 18,
			SwingGap = 0.12,
			Dodge = true,
			TryBall = true,
			Leave = true,
			BaitSpeed = 225,
			Interval = 1800,
			Run = nil,
			SwapTools = true,
			SwapIndex = 1,
			SwapSince = 0,
			MainHold = 0.3,
			SecondHold = 0.4,
			LastSwing = 0,
			Links = {},
		}

		r247.Mech = s22

		local function s23()
			return r247.Toggle(s22.Handle, false) == true
		end

		local function s24()
			return workspace:FindFirstChild("ScrambleArena")
		end

		local function s26()
			return workspace:FindFirstChild("ScrambleArenaPortal")
		end

		local function s27()
			return r232:GetAttribute("InScrambleArena") == true
		end

		s22.StealFirst = function()
			local t8 = r247.Steal
			local t2 = r247.Movement
			if t2.PlaceWanted == true then
				return "Auto Place Egg goes first"
			end

			if t2.MutationWanted == true then
				return "Scrambled Mutation goes first"
			end
			local t2_1 = r247.Toggle(r4_5, false) == true and t8 ~= nil

			if t2_1 then
				t2_1 = t8.Wanted == true or t8.Carrying == true or t8.Active == true
			end

			if t2_1 then
				return "Auto Steal goes first"
			end
			return nil
		end

		pcall(function()
			local t2 = require(r181.Shared.Flags.ScrambleBossFlags).ScheduleIntervalSeconds
			local t4 = type(t2) == "table" and tonumber(t2.Value) or nil

			if t4 and t4 > 0 then
				s22.Interval = t4
			end
		end)

		s22.Clock = function(arg1)
			local t31 = math.max(0, math.floor(arg1 + 0.5))
			return string.format("%d:%02d", math.floor(t31 / 60), t31 % 60)
		end

		s22.Timer = function()
			local t14 = workspace:GetServerTimeNow()
			local t8 = workspace:FindFirstChild("ScrambleArena")
			t8 = t8 and tonumber(t8:GetAttribute("SpawnsAt")) or 0

			if workspace:FindFirstChild("ScrambleArenaPortal") then
				if t14 < t8 then
					return "Mech portal is open  |  boss spawns in " .. s22.Clock(t8 - t14)
				end
				return "Mech portal is open now"
			end

			local t2 = s22.Interval
			return "Next Mech portal in " .. s22.Clock(math.ceil(t14 / t2) * t2 - t14)
		end

		local function s28(t10)
			if not t10 then
				return nil
			end
			local t11 = t10:FindFirstChild("Hitbox", true)
			if t11 and t11:IsA("BasePart") then
				return t11
			end

			for _, t8 in ipairs(t10:GetDescendants()) do
				if t8:IsA("TouchTransmitter") and t8.Parent and t8.Parent:IsA("BasePart") then
					return t8.Parent
				end
			end

			return nil
		end

		local function s29(t14)
			local t2 = r247.Root()
			if not t2 or not t14 or type(firetouchinterest) ~= "function" then
				return
			end

			pcall(function()
				firetouchinterest(t2, t14, 0)
				task.wait(0.05)
				firetouchinterest(t2, t14, 1)
			end)
		end

		local function s31(t11, t12)
			if not s22.Dodge or not s15 or type(s20) ~= "table" or type(s20.Contains) ~= "function" then
				return false
			end

			for t5, t6 in pairs(s22.Hazards) do
				local t8 = tonumber(t6.At) or 0
				local t9 = tonumber(t6.Warn) or 0
				if t8 + (tonumber(t6.Duration) or 0.5) + 1.5 < t12 then
					s22.Hazards[t5] = nil
					continue
				end

				if t12 >= t8 - t9 - 0.1 then
					local t8_1, t9_1 = pcall(s20.Contains, t6, t11, t12)
					if t8_1 and t9_1 then
						return true
					end
				end
			end

			return false
		end

		local function s32()
			local t6 = r232.Character
			local t7 = r232:FindFirstChildOfClass("Backpack")

			for _, t6_1 in ipairs({ t6, t7 }) do
				if t6_1 then
					for _, t9 in ipairs(t6_1:GetChildren()) do
						if t9:IsA("Tool") and tostring(t9:GetAttribute("ItemType")) == "Gear" then
							if string.find(string.lower(tostring(t9:GetAttribute("GearName") or "")), "scrambler", 1, true) then
								return t9
							end
						end
					end
				end
			end

			return nil
		end

		local function s34()
			local t2 = s22.LastSwing
			if os.clock() - t2 < s22.SwingGap then
				return
			end
			s22.LastSwing = os.clock()
			local t7 = r232.Character
			local t1 = t7 and t7:FindFirstChildOfClass("Humanoid")
			local t2_1 = type(r247.FindBat) == "function" and r247.FindBat() or nil
			local t3 = s22.SwapTools and s32() or nil
			local t5

			if t2_1 and t3 and t2_1 ~= t3 then
				local t12 = s22.SwapIndex == 2 and s22.SecondHold or s22.MainHold
				local t14 = s22.SwapSince

				if t12 <= os.clock() - t14 then
					s22.SwapIndex = s22.SwapIndex == 2 and 1 or 2
					s22.SwapSince = os.clock()
				end

				t5 = s22.SwapIndex == 2 and t3 or t2_1
			else
				t5 = t2_1 or t3
			end

			if not t5 or not t1 then
				return
			end

			if t5.Parent ~= t7 then
				pcall(function()
					t1:EquipTool(t5)
				end)
			end

			pcall(function()
				t5:Activate()
			end)
		end

		local function s35(t15, t16)
			local t1 = r232.Character
			local t3 = r247.Root()
			if not t1 or not t3 then
				return
			end

			if (t3.Position - t15).Magnitude > 3 then
				pcall(function()
					t1:PivotTo(CFrame.lookAt(t15, Vector3.new(t16.X, t15.Y, t16.Z)))
					t3.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function s36(t27)
			local t24 = t27:FindFirstChild("Mech")
			local t21 = t24 and t24:FindFirstChild("Hitbox")
			if t21 and t21:IsA("BasePart") then
				return t21.Position, t24
			end

			for _, t4 in ipairs(t27:GetChildren()) do
				if t4:IsA("Model") and t4.Name ~= "Ball" and t4.Name ~= "LeaveTeleport" and t4.Name ~= "Structure" then
					local t5 = t4:FindFirstChild("Hitbox")
					if t5 and t5:IsA("BasePart") then
						return t5.Position, t4
					end
				end
			end

			return nil, nil
		end

		local function s37(t5, t6)
			local t2 = t5:FindFirstChild("Ball")
			if not t2 then
				return false
			end
			local t22 = t2:GetBoundingBox().Position
			local t10 = (tonumber(t5:GetAttribute("FloorY")) or t22.Y) + 3
			local t14 = tonumber(t5:GetAttribute("CoreStage")) or 0

			if t5:GetAttribute("BallStunned") == true then
				s22.Run = nil
				local t15 = Vector3.new(t6.Position.X - t22.X, 0, t6.Position.Z - t22.Z)
				local t3_1 = t15.Magnitude > 1 and t15.Unit or Vector3.new(1, 0, 0)
				s35(Vector3.new(t22.X, t10, t22.Z) + t3_1 * 10, t22)
				s34()
				s22.Status = string.format("Smashing the core  |  stage %d / 3  |  core %s", t14, tostring(t5:GetAttribute("CoreHealth") or "?"))
				return true
			end

			local t8_1 = tostring(t5:GetAttribute("BallTarget"))
			local t12_1 = t5:GetAttribute("BallCoil")

			if not s22.Run and t8_1 == tostring(r232.UserId) and type(t12_1) == "string" and t12_1 ~= "" then
				local t2_5 = t5:FindFirstChild("Coils")
				local t3_2 = t2_5 and t2_5:FindFirstChild(t12_1)
				t3_2 = t3_2 and t3_2:GetAttribute("Home")

				if typeof(t3_2) == "Vector3" then
					local t15_3 = Vector3.new(t3_2.X - t22.X, 0, t3_2.Z - t22.Z)

					if t15_3.Magnitude > 1 then
						s22.Run = {
							Goal = Vector3.new(t3_2.X, t10, t3_2.Z) + t15_3.Unit * 40,
							Until = os.clock() + 8,
							Coil = t12_1,
						}
					end
				end
			end

			if s22.Run then
				local t15_2 = Vector3.new(s22.Run.Goal.X - t6.Position.X, 0, s22.Run.Goal.Z - t6.Position.Z)
				local t2_7 = t15_2.Magnitude < 4
				local t3_3

				if t2_7 then
					t3_3 = t2_7
				else
					local t4 = s22.Run.Until
					t3_3 = os.clock() > t4
				end

				if t3_3 then
					s22.Run = nil

					pcall(function()
						t6.AssemblyLinearVelocity = Vector3.new(0, t6.AssemblyLinearVelocity.Y, 0)
					end)
				else
					local t2_8 = t15_2.Unit * s22.BaitSpeed

					pcall(function()
						t6.AssemblyLinearVelocity = Vector3.new(t2_8.X, t6.AssemblyLinearVelocity.Y, t2_8.Z)
					end)

					s22.Status = string.format("Baiting the ball into %s  |  stage %d / 3", s22.Run.Coil, t14)
				end

				return true
			end

			local t15_1 = Vector3.new(t6.Position.X - t22.X, 0, t6.Position.Z - t22.Z)

			if t15_1.Magnitude > 18 or t15_1.Magnitude < 6 then
				local t2_9 = t15_1.Magnitude < 1 and Vector3.new(1, 0, 0) or t15_1.Unit
				s35(Vector3.new(t22.X, t10, t22.Z) + t2_9 * 12, t22)
			end

			s22.Status = string.format("Ball phase, waiting for it to lock on  |  stage %d / 3", t14)
			return true
		end

		local function s38(t14, t15)
			local t11 = t14:FindFirstChild("ScrambleHuman")
			if not t11 then
				return false
			end
			local t16 = t11:FindFirstChild("HumanoidRootPart") or t11.PrimaryPart or t11:FindFirstChildWhichIsA("BasePart")
			local t6 = t16 and t16.Position or t11:GetPivot().Position
			local t2_1 = t16 and t16.AssemblyLinearVelocity or Vector3.zero
			local t8_1 = t6 + Vector3.new(t2_1.X, 0, t2_1.Z) * 0.15
			local t16_1 = Vector3.new(t15.Position.X - t8_1.X, 0, t15.Position.Z - t8_1.Z)
			local t9 = t16_1.Magnitude > 1 and t16_1.Unit * 5 or Vector3.zero
			local t8_2 = Vector3.new(t8_1.X, t15.Position.Y, t8_1.Z) + t9
			local t9_1 = r232.Character

			pcall(function()
				t9_1:PivotTo(CFrame.lookAt(t8_2, Vector3.new(t6.X, t8_2.Y, t6.Z)))
			end)

			s34()
			s22.Status = string.format("Chasing Dr Scramble  |  hits %s / %s", tostring(t14:GetAttribute("HumanHits") or 0), tostring(t14:GetAttribute("HumanNeeded") or 3))
			return true
		end

		local function s39()
			local t7 = s24()
			local t8 = r247.Root()
			local t6 = r232.Character
			t6 = t6 and t6:FindFirstChildOfClass("Humanoid")
			if not t7 or not t8 then
				return
			end
			local t12 = tostring(t7:GetAttribute("Phase"))
			local t13 = tonumber(t7:GetAttribute("Health")) or 0
			local t14 = tonumber(t7:GetAttribute("MaxHealth")) or 0

			if tostring(t7:GetAttribute("GrabVictim")) == tostring(r232.UserId) and t6 then
				t6.Jump = true
				s34()
				s22.Status = "Grabbed, breaking free"
				return
			end

			if t12 == "Ball" and s22.TryBall and s37(t7, t8) then
				return
			end

			if t12 == "Human" and s38(t7, t8) then
				return
			end
			local t10, t11 = s36(t7)

			if not t10 then
				local t1_6 = (tonumber(t7:GetAttribute("SpawnsAt")) or 0) - workspace:GetServerTimeNow()
				s22.Status = t1_6 > 0 and "In the arena  |  boss spawns in " .. s22.Clock(t1_6) or string.format("Phase %s, waiting for the boss", t12)
				return
			end

			local t1_4 = workspace:GetServerTimeNow()
			local t5 = (tonumber(t7:GetAttribute("FloorY")) or t10.Y) + 3
			local t18 = nil
			local t20 = nil

			for t2_4 = 0, 15 do
				local t2_5 = t2_4 / 16 * 3.1415926535897931 * 2
				local t23 = s22.Radius
				local t6_2 = t10.Z
				local t26 = s22.Radius
				local t3 = Vector3.new(t10.X + math.cos(t2_5) * t23, t5, t6_2 + math.sin(t2_5) * t26)
				local t26_1 = (t3 - t8.Position).Magnitude

				if s31(t3, t1_4) or s31(t3, t1_4 + 0.4) then
					t26_1 += 10000
				end

				if not t18 or t26_1 < t18 then
					t18 = t26_1
					t20 = t3
				end
			end

			if t20 then
				s35(t20, t10)
			end

			s34()
			t11 = t11 and t11:GetAttribute("Overheated") == true
			s22.Status = string.format("Fighting %s  |  boss %d / %d%s", t12, math.floor(t13 + 0.5), math.floor(t14 + 0.5), t11 and "  |  OVERHEAT" or "")
		end

		local function s40()
			local t11 = s24()
			local t4 = s28(t11 and t11:FindFirstChild("LeaveTeleport"))
			if not t4 then
				return
			end
			local t5 = r232.Character

			pcall(function()
				t5:PivotTo(CFrame.new(t4.Position + Vector3.new(0, 3, 0)))
			end)

			task.wait(0.2)
			s29(t4)
		end

		local function s41(t15)
			local t1 = s26()
			local t2 = s28(t1)
			if not t1 or not t2 then
				return false
			end
			local t1_2 = t2.Position
			local t4_1 = os.clock()
			local exitTo = nil
			local t6_1

			while true do
				if not (os.clock() - t4_1 < 60) then
					exitTo = 1
					break
				else
					if t15 ~= s22.Generation or not s23() or s27() or s22.StealFirst() then
						exitTo = 1
						break
					else
						t6_1 = r247.Root()

						if not t6_1 then
							exitTo = 2
							break
						else
							local t11 = Vector3.new(t1_2.X - t6_1.Position.X, 0, t1_2.Z - t6_1.Position.Z)

							if not (t11.Magnitude <= 14) then
								local t7_1 = t11.Unit * math.min(s22.TravelSpeed, t11.Magnitude / 0.05)
								s22.Status = string.format("Going to the Mech portal, %d studs", math.floor(t11.Magnitude + 0.5))

								pcall(function()
									t6_1.AssemblyLinearVelocity = Vector3.new(t7_1.X, t6_1.AssemblyLinearVelocity.Y, t7_1.Z)
								end)

								r137.Heartbeat:Wait()
								continue
							end
						end
					end

					break
				end
			end

			if exitTo ~= 1 then
				if exitTo == 2 then
					return false
				end

				pcall(function()
					t6_1.AssemblyLinearVelocity = Vector3.zero
				end)

				s29(t2)
				task.wait(0.4)

				if not s27() then
					pcall(function()
						local u10 = r182:FindFirstChild("RF/ScrambleBoss/EnterArena")

						if u10 then
							u10:InvokeServer()
						end
					end)
				end
			end

			local t1_3 = os.clock()

			while not s27() and os.clock() - t1_3 < 5 do
				task.wait(0.1)
			end

			return s27()
		end

		local function s42()
			s22.Busy = true
			s22.Generation = s22.Generation + 1
			local t10 = s22.Generation
			r247.Shield("mech", true)

			pcall(function()
				local u2 = r247.Treadmill and r247.Treadmill.Riding
				local u4

				if u2 then
					u4 = u2
				else
					u4 = type(r247.OnBelt) == "function" and r247.OnBelt()
				end

				if u4 then
					r247.ExitBelt()
				end
			end)

			if not s27() and not s22.StealFirst() then
				pcall(s41, t10)
			end

			while t10 == s22.Generation and s23() and s27() and not s22.StealFirst() do
				local t7 = s24()
				t7 = t7 and tostring(t7:GetAttribute("Phase")) or ""

				if t7 == "Defeated" or t7 == "Final" or t7 == "Ended" or t7 == "Won" then
					s22.Status = "Dr Scramble defeated, going back home"
					s22.DefeatedAt = s22.DefeatedAt or os.clock()
					local t2_6 = s22.Leave

					if t2_6 then
						local t4_1 = s22.DefeatedAt
						t2_6 = os.clock() - t4_1 > 15
					end

					if t2_6 then
						pcall(s40)
						task.wait(2)
					else
						task.wait(0.3)
					end
				else
					pcall(s39)
					r137.Heartbeat:Wait()
				end
			end

			if s27() and s22.StealFirst() then
				s22.Status = tostring(s22.StealFirst()) .. ", leaving the arena"
				pcall(s40)
				local t2_7 = 0

				while s27() and t2_7 < 5 do
					t2_7 += task.wait(0.2)
				end
			end

			s22.DefeatedAt = nil
			s22.Run = nil
			r247.Shield("mech", false)
			r247.ReleaseMovement("mech")
			s22.Busy = false
			r244.Wake()
		end

		pcall(function()
			local t9 = r182:FindFirstChild("RE/ScrambleBoss/Hazard")

			if t9 and t9:IsA("RemoteEvent") then
				table.insert(s22.Links, t9.OnClientEvent:Connect(function(u22)
					if type(u22) == "table" then
						s22.Hazards[u22.Id or #s22.Hazards + 1] = u22
					end
				end))
			end
		end)

		s22.Row = s16:CreateText({ Name = "Mech Status", Text = "Idle" })

		s22.Handle = s16:CreateToggle({
			Name = "Auto Mech Boss",
			Default = false,
			Callback = function()
				if not s23() then
					s22.Generation = s22.Generation + 1
				end

				r244.Wake()
			end,
		})

		for _, s3 in ipairs({
			{ "Mech Tween Speed", 100, 1000, 250, 10, "studs/s", "TravelSpeed" },
			{ "Main Weapon Hold", 0, 1.5, 0.3, 0.01, "s", "MainHold" },
			{ "Scrambler Hold", 0, 1.5, 0.4, 0.01, "s", "SecondHold" },
		}) do
			s16:CreateSlider({
				Name = s3[1],
				Min = s3[2],
				Max = s3[3],
				Default = s3[4],
				Increment = s3[5],
				Unit = s3[6],
				SubOf = s22.Handle,
				Callback = function(t26)
					s22[s3[7]] = math.clamp(tonumber(t26) or s3[4], s3[2], s3[3])
				end,
			})
		end

		for _, s6 in ipairs({
			{ "Swap Two Weapons", "SwapTools" },
			{ "Dodge Attacks", "Dodge" },
			{ "Ball And Core Phase", "TryBall" },
			{ "Leave After Fight", "Leave" },
		}) do
			s16:CreateToggle({
				Name = s6[1],
				Default = true,
				SubOf = s22.Handle,
				Callback = function(arg1)
					s22[s6[2]] = arg1 ~= false
				end,
			})
		end

		r244.Add(function()
			local t4 = s22.Row

			if not s23() then
				s22.Status = "Off  |  " .. s22.Timer()
			elseif not s22.Busy then
				if s27() then
					s22.Status = "In the arena"
				else
					s22.Status = s22.Timer()
				end
			end

			if t4 and s22.Shown ~= s22.Status and type(t4.Set) == "function" then
				s22.Shown = s22.Status
				pcall(t4.Set, t4, s22.Status)
			end

			if not s23() or s22.Busy then
				return true
			end

			if s27() or s26() then
				local t3 = s22.StealFirst()
				if t3 then
					s22.Status = t3 .. "  |  " .. s22.Timer()
					return true
				end

				if not r247.ClaimMovement("mech") then
					s22.Status = "Waiting for " .. tostring(r247.Movement.Owner or "movement")
					return true
				end
				task.spawn(s42)
				return true
			end

			return true
		end)

		r240(function()
			s22.Generation = s22.Generation + 1

			for _, t4 in ipairs(s22.Links) do
				pcall(function()
					t4:Disconnect()
				end)
			end

			pcall(r247.Shield, "mech", false)
			pcall(r247.ReleaseMovement, "mech")
		end)
	end

	r247.MechBoot(r184)
	local r18_4
	r18_4 = 6
	local r19_4
	r19_4 = 1.5
	local r20_4
	r20_4 = 400
	local r5_18, r1_31, r655, r656, r657, r659, r660, r661, r662, r663
	local r664, r665, r666, r667, r668, r671, r672, r673, r674, r675
	local r681, r682, r683, r684, r685, r686, r687, r689, r690, r691
	local r692, r694, r695, r696, r698, r699, r702, r703, r707, r708
	local r709, r3_14, r710, r711

	do
		local r22_1 = Vector3.new(2120, -120, -355)
		r5_18 = { "LostPart1", "LostPart2" }

		r1_31 = {
			{ Label = "Experiment #001", Id = "LimitedTimeExperimentPet" },
			{ Label = "Nibbles #013", Id = "Nibbles013" },
			{ Label = "Scrambled Mutation", Id = "MutationConsumable" },
			{ Label = "2x Cash Booster", Id = "CashBooster" },
			{ Label = "1.25x Speed", Id = "SpeedBoost" },
			{ Label = "2x Treadmill Booster", Id = "TreadmillBooster" },
		}

		local r2_25 = {}

		for _, r99 in ipairs(r1_31) do
			r2_25[#r2_25 + 1] = r99.Label
		end

		r655 = {}
		r656 = {}
		r657 = 0
		local r658 = { ["Experiment #001"] = true, ["Nibbles #013"] = true, ["Scrambled Mutation"] = true }
		r659 = nil
		r660 = -math.huge
		r661 = false
		r662 = 0
		r663 = 0
		r664 = ""
		r665 = ""
		r666 = { Tool = nil, EquipAt = 0 }
		r667 = 16
		r668 = false
		r671 = { Index = 1, Since = 0, Tool = nil }
		r672 = { Latch = false, Ended = false }
		r673 = false
		r674 = 0
		r675 = nil

		local function r680()
			local s8 = r181:FindFirstChild("Packages")
			local s15 = s8 and s8:FindFirstChild("Networking")
			s15 = s15 and s15:FindFirstChild("RF/Scramble/Request")
			if s15 and s15:IsA("RemoteFunction") then
				return s15
			end
			return nil
		end

		r681 = function(s24, ...)
			local s1 = r680()
			if not s1 then
				return nil
			end
			local s2 = table.pack(...)

			local s25, s26 = pcall(function()
				return s1:InvokeServer(s24, table.unpack(s2, 1, s2.n))
			end)

			if not s25 or type(s26) ~= "table" then
				return nil
			end

			if type(s26.Snapshot) == "table" then
				r659 = s26.Snapshot
				r660 = os.clock()
			elseif s24 == "Snapshot" and type(s26.State) == "table" then
				r659 = s26
				r660 = os.clock()
			end

			return s26
		end

		r682 = function(arg1)
			if arg1 or r659 == nil or os.clock() - r660 >= r18_4 then
				r681("Snapshot")
			end

			return r659
		end

		r683 = function()
			local s2 = r659
			return type(s2) == "table" and type(s2.State) == "table" and s2.State or nil
		end

		r684 = function()
			local s2 = r659
			if type(s2) ~= "table" or s2.Enabled == false or type(s2.State) ~= "table" then
				return false
			end
			local s7 = tonumber(s2.EventEndsAt)
			return s7 == nil or workspace:GetServerTimeNow() < s7
		end

		r685 = function()
			local s2 = r659
			local s9 = type(s2) == "table" and s2.Window or nil
			if type(s9) ~= "table" then
				return false, nil
			end
			local s11 = workspace:GetServerTimeNow()
			local s3_1 = tonumber(s9.StartsAt)
			local s2_1 = tonumber(s9.EndsAt)
			if s9.Active == true or s3_1 and s2_1 and s11 >= s3_1 and s11 < s2_1 then
				return true, s2_1 and math.max(0, s2_1 - s11) or nil
			end
			local s2_2 = tonumber(s9.NextAt)
			return false, s2_2 and math.max(0, s2_2 - s11) or nil
		end

		r686 = function(s17, s18)
			local s2 = type(s17) == "table" and s17.LostParts or nil
			if type(s2) ~= "table" then
				return false
			end

			if s2[s18] then
				return true
			end

			for _, s3 in pairs(s2) do
				if s3 == s18 then
					return true
				end
			end

			return false
		end

		r687 = function(s3)
			local s13 = 0

			for _, s7 in ipairs(r5_18) do
				if r686(s3, s7) then
					s13 += 1
				end
			end

			return s13
		end

		local function r688(s22)
			local s19_1 = math.max(0, math.floor(tonumber(s22) or 0))
			if s19_1 >= 3600 then
				return string.format("%dh %dm", s19_1 // 3600, s19_1 % 3600 // 60)
			end
			return string.format("%dm %ds", s19_1 // 60, s19_1 % 60)
		end

		r689 = function()
			local s16 = r683()
			if not s16 then
				return "Dr Scramble event is not running"
			end

			if not r684() then
				return "Dr Scramble event has ended"
			end
			local s3, s2 = r685()
			local s14

			if s3 then
				s14 = "Outbreak live " .. r688(s2 or 0)
			else
				s14 = s3
			end

			s14 = s14 or s2 and "Outbreak in " .. r688(s2) or "Outbreak soon"
			local s5_1 = s16.Completed == true and "Vault claimed"

			if not s5_1 then
				s5_1 = string.format("Lost %d/2  Drone %d/3", r687(s16), math.min(3, tonumber(s16.DroneParts) or 0))
			end

			if s3 then
				local s10_1 = 0

				for _, s4_1 in pairs(r655) do
					if (tonumber(s4_1.Health) or 0) > 0 then
						s10_1 += 1
					end
				end

				s14 ..= string.format("  %d drones", s10_1)
			end

			local s2_3 = string.format("Samples %d  -  %s  -  %s", tonumber(s16.Samples) or 0, s5_1, s14)

			if r665 ~= "" and r247.Toggle(nil, false) then
				s2_3 ..= "  -  " .. r665
			end

			if r664 ~= "" then
				s2_3 ..= "  -  " .. r664
			end

			return s2_3
		end

		r690 = function()
			return r247.Root()
		end

		r691 = function(s30, s31, s32, arg4)
			local s2 = arg4 or 400
			local s1 = r690()
			if not s1 then
				return false
			end
			s32 = s32 or 1
			if (s1.Position - s30).Magnitude <= s32 then
				return true
			end
			r247.Shield("scramble", true)
			local s3 = os.clock() + 6

			while not r247.Swapped() and os.clock() < s3 and not s31() do
				r664 = "Waiting for the character to settle"
				r137.Heartbeat:Wait()
			end

			local s4_1 = r690() or s1
			local s3_2 = r232.Character
			r247.Driving = r247.Driving + 1
			local s4_2 = s4_1.Position
			local s5 = nil
			local s6 = (s30 - s4_2).Magnitude / s2 + 3
			local s8 = 0

			local s1_1 = r137.Heartbeat:Connect(function(t16)
				if s5 ~= nil or r247.AntiGuard.Busy then
					return
				end
				s8 += t16
				local t3 = r690()
				if not t3 or s31() or s8 > s6 or r232.Character ~= s3_2 then
					s5 = false
					return
				end

				if (t3.Position - s4_2).Magnitude > 8 then
					s4_2 = t3.Position
				end

				local t2_2 = s30 - s4_2
				local t13 = s2 * t16
				local t6 = t2_2.Magnitude <= math.max(t13, s32)
				s4_2 = t6 and s30 or s4_2 + t2_2.Unit * t13
				local t11 = Vector3.new(t2_2.X, 0, t2_2.Z)
				local t2_3 = t11.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, t11.Unit) or t3.CFrame.Rotation

				pcall(function()
					t3.CFrame = CFrame.new(s4_2) * t2_3
					t3.AssemblyLinearVelocity = Vector3.zero
					t3.AssemblyAngularVelocity = Vector3.zero
				end)

				if t6 then
					s5 = true
				end
			end)

			while s5 == nil do
				r137.Heartbeat:Wait()
			end

			s1_1:Disconnect()
			r247.Driving = math.max(0, r247.Driving - 1)
			r247.Shield("scramble", false)
			return s5
		end

		r692 = function(s22)
			if typeof(s22) ~= "Instance" or not s22:IsA("ProximityPrompt") then
				return false
			end

			local s20 = pcall(function()
				s22:InputHoldBegin()
				local t2_1 = tonumber(type(r247.PromptHold) == "function" and r247.PromptHold(s22) or s22.HoldDuration) or 0

				if t2_1 > 0 then
					task.wait(t2_1 + 0.2)
				end

				s22:InputHoldEnd()
			end)

			if not s20 and type(fireproximityprompt) == "function" then
				s20 = pcall(fireproximityprompt, s22)
			end

			return s20
		end

		local function r693()
			local s9 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			s9 = s9 and s9:FindFirstChild("SecretZones")
			return s9 and s9:FindFirstChild("Cave") or nil
		end

		r694 = function(s29)
			local s4 = r693()
			s4 = s4 and s4:FindFirstChild("Teleporter")
			s4 = s4 and s4:FindFirstChild(s29)
			s4 = s4 and s4:FindFirstChild("SecretZonePrompt", true)
			return s4 and s4:IsA("ProximityPrompt") and s4 or nil
		end

		r695 = function(s30, s31)
			s30 = s30 and s30.Parent
			if s30 and s30:IsA("Attachment") then
				return s30.WorldPosition
			end

			if s30 and s30:IsA("BasePart") then
				return s30.Position
			end
			return s31
		end

		r696 = function()
			local s2 = r690()
			if not s2 then
				return false
			end
			local s10 = s2.Position
			local s2_1 = Vector3.new(s10.X - r22_1.X, 0, s10.Z - r22_1.Z)
			return s10.Y < -60 and s2_1.Magnitude < 160
		end

		local function r697()
			local s9 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			s9 = s9 and s9:FindFirstChild("Areas")
			local s12 = s9 and s9:FindFirstChild("SeparationLine")
			return s12 and s12:IsA("BasePart") and s12.Position.X or 552
		end

		r698 = function(s34)
			if not s34 then
				s34 = r690()
				s34 = s34 and s34.Position
			end

			return s34 ~= nil and s34.X < r697()
		end

		local r153_14 = r232.CharacterAdded:Connect(function()
			r247.ScrambleRespawned = true
			r666.Tool = nil
			r666.EquipAt = 0
		end)

		r240(function()
			pcall(function()
				r153_14:Disconnect()
			end)
		end)

		r699 = function(s2, s3)
			if not r698() then
				r247.ScrambleRespawned = false
				return true
			end

			if s3 and r698(s3) then
				return true
			end

			local function s13()
				r664 = "Respawned, resting in the safe zone"
				local t2 = os.clock() + 0.75

				while os.clock() < t2 do
					if s2() then
						return false
					end
					task.wait(0.1)
				end

				r247.ScrambleRespawned = false
				return true
			end

			local s4 = type(r247.StealHome) == "function" and r247.StealHome() or nil
			if not s4 then
				r247.ScrambleRespawned = false
				return true
			end
			local s15 = r247.ScrambleRespawned == true

			if r247.DistanceTo(s4) <= 12 then
				if s15 then
					return (s13())
				end
				return true
			end

			r664 = s15 and "Respawned, easing out through the safe zone" or "Leaving the base through the safe zone"
			local s9 = r691
			local s3_4 = s9(s4 + Vector3.new(0, 3, 0), s2, 3, s15 and math.min(400, 300) or nil)
			if s3_4 and s15 then
				return (s13())
			end
			return s3_4
		end

		local function r700(s17, s18, s19)
			local s2 = r690()
			if not s2 then
				return false
			end
			r247.Shield("scramblefly", true)
			local s6 = s2.Position
			local s8 = true

			if Vector3.new(s17.X - s6.X, 0, s17.Z - s6.Z).Magnitude > 250 then
				local s2_1 = math.max(s6.Y, s17.Y, 98)
				s8 = r691(Vector3.new(s6.X, s2_1, s6.Z), s18, 2) and r691(Vector3.new(s17.X, s2_1, s17.Z), s18, 2)
			end

			s8 = s8 and r691(s17, s18, math.min(s19, 2))
			r247.Shield("scramblefly", false)
			return s8
		end

		local function r701()
			local s2 = type(r247.StealHome) == "function" and r247.StealHome() or nil
			return s2 and s2 + Vector3.new(0, 3, 0) or nil
		end

		r702 = function(s16, s17, arg3)
			local s18 = arg3 or 6
			if r247.DistanceTo(s16) <= s18 then
				return true
			end
			local s3 = r698()
			local s5 = r698(s16)

			if s3 and not s5 then
				if not r699(s17, s16) then
					return false
				end
			elseif s5 and not s3 then
				local s13 = r701()

				if s13 and (s13 - s16).Magnitude > 12 and r247.DistanceTo(s13) > 12 then
					r664 = "Coming back through the safe zone"
					if not r700(s13, s17, 3) then
						return false
					end
				end
			end

			return r700(s16, s17, s18)
		end

		r703 = function(s31)
			if r698() or s31() or r247.IsNight() or r247.WallSealed() then
				return
			end
			local s30 = r701()

			if s30 then
				r664 = "Coming back through the safe zone"
				r702(s30, s31, 4)
			end
		end

		local function r704(s30)
			if r696() then
				return true
			end
			local s27 = r694("Entry")
			local s26 = r695(s27, Vector3.new(2125.7, 73.1, -295.4))
			r664 = "Flying to the Secret Cave"
			if not r702(s26, s30, 6) then
				return false
			end

			for s2 = 1, 4 do
				if s30() then
					return false
				end
				r664 = "Entering the Secret Cave"
				r692(s27 or r694("Entry"))
				local s4 = os.clock() + 1.5

				while os.clock() < s4 and not r696() do
					r137.Heartbeat:Wait()
				end

				if r696() then
					return true
				end
			end

			r664 = "Cave door missed, flying in"
			local s3_2 = type(r659) == "table" and r659.Quest or nil
			local s4_1 = type(s3_2) == "table" and type(s3_2.EscapedExperiment) == "table" and s3_2.EscapedExperiment.Position or nil

			if typeof(s4_1) == "Vector3" then
				pcall(r247.FlyTo, s4_1, s30, "scramble")
			end

			return r696()
		end

		local function r705(s8)
			local s3 = type(r659) == "table" and r659.Quest or nil
			local s3_1 = type(s3) == "table" and s3[s8] or nil
			local s3_2 = type(s3_1) == "table" and s3_1.Position or nil
			if typeof(s3_2) == "Vector3" then
				return s3_2
			end
			local s10 = workspace:FindFirstChild("DrScrambleEvent")
			s10 = s10 and s10:FindFirstChild(s8)
			if s10 and s10:IsA("Model") then
				return s10:GetPivot().Position
			end
			return nil
		end

		local function r706(s31)
			local s1 = r659
			local s2 = type(s1) == "table" and s1.Interactions or nil
			return math.max(4, (type(s2) == "table" and tonumber(s2[s31]) or 12) - 4)
		end

		r707 = function(s10)
			local s2 = r683()
			if not s2 or s2.Discovered == true then
				return true
			end
			local s9 = r705("EscapedExperiment")
			if not s9 or not r704(s10) then
				return false
			end
			r664 = "Talking to the Escaped Experiment"
			if not r691(s9, s10, r706("NpcRadius")) then
				return false
			end
			local s8 = r681("Discover")
			r682(true)
			return s8 ~= nil and r683() ~= nil and r683().Discovered == true
		end

		r708 = function(s26)
			local s1 = r683()
			local s2 = not s1 or s1.Completed == true

			if not s2 then
				local s5 = #r5_18
				s2 = r687(s1) >= s5
			end

			if s2 then
				return
			end

			if s1.Discovered ~= true and not r707(s26) then
				return
			end

			for _, s3 in ipairs(r5_18) do
				if s26() then
					return
				end

				if not r686(r683(), s3) then
					local s23 = workspace:FindFirstChild("DrScrambleEvent")
					s23 = s23 and s23:FindFirstChild(s3)
					s23 = s23 and s23:FindFirstChild("Hitbox", true)
					local s5_1 = s23 and s23:FindFirstChild("ClaimLostPart", true)
					local s19 = s23 and s23:IsA("BasePart") and s23.Position or r705(s3)

					if s19 then
						r664 = "Flying to " .. (s3 == "LostPart1" and "Lost Part 1" or "Lost Part 2")

						if r702(s19 + Vector3.new(0, 2, 0), s26, 3) then
							r664 = "Collecting the lost part"
							local s6 = s19 + Vector3.new(0, 2.5, 0)
							local s7_1 = r232.Character
							r247.Shield("scramble", true)
							r247.Driving = r247.Driving + 1

							local s27 = r137.Heartbeat:Connect(function()
								local t2 = r247.Root()
								if not t2 or t2.Parent ~= s7_1 or r247.AntiGuard.Busy or r247.Movement.Owner ~= "scramble" then
									return
								end

								pcall(function()
									local u8 = t2.CFrame.Rotation
									t2.CFrame = CFrame.new(s6) * u8
									t2.AssemblyLinearVelocity = Vector3.zero
									t2.AssemblyAngularVelocity = Vector3.zero
								end)
							end)

							for s8 = 1, 4 do
								if not s26() then
									s5_1 = s5_1 or s23 and s23:FindFirstChild("ClaimLostPart", true)
									r692(s5_1)
									task.wait(0.6)
									r682(true)
									if not r686(r683(), s3) then
										continue
									end
								end

								break
							end

							s27:Disconnect()
							r247.Driving = math.max(0, r247.Driving - 1)
							r247.Shield("scramble", false)
							if s26() then
								return
							end
							continue
						end
					end
				end
			end
		end

		r709 = function(s30)
			local s1 = r683()
			if not s1 or s1.Completed == true then
				return
			end
			local s3_1 = tonumber(s1.TotalParts)

			if not s3_1 then
				s3_1 = r687(s1) + (tonumber(s1.DroneParts) or 0)
			end

			if s3_1 < 5 then
				return
			end
			local s29 = r705("ExperimentVault")
			if not s29 or not r704(s30) then
				return
			end
			r664 = "Opening the Experiment Vault"
			if not r691(s29, s30, r706("VaultRadius")) then
				return
			end
			r681("Vault")
			r682(true)
			local s3_2 = r683()

			if s3_2 and s3_2.Completed == true then
				r664 = "Vault opened, The Scrambler unlocked"
			end
		end

		r3_14 = function()
			local function s15(t14)
				if not t14 or not t14:IsA("Tool") then
					return false
				end

				if tostring(t14:GetAttribute("ItemType")) ~= "MutationConsumable" then
					return false
				end
				local t2_1 = t14:GetAttribute("MutationId") or t14:GetAttribute("MutationTemplate")
				if t2_1 ~= nil then
					return tostring(t2_1) == "Scrambled"
				end
				return string.find(string.lower(t14.Name), "scrambled", 1, true) ~= nil
			end

			local s10 = r232.Character

			if s10 then
				for _, s4 in ipairs(s10:GetChildren()) do
					if s15(s4) then
						return s4, true
					end
				end
			end

			local s2 = r232:FindFirstChildOfClass("Backpack")

			if s2 then
				for _, s8 in ipairs(s2:GetChildren()) do
					if s15(s8) then
						return s8, false
					end
				end
			end

			return nil, false
		end

		r710 = function(s13, s14)
			local s3 = type(s13) == "table" and s13.ShopPurchases or nil
			local s2_1 = type(s3) == "table" and s3[s14.Id] or nil
			if type(s2_1) ~= "table" then
				return 0
			end
			local s5 = type(r659) == "table" and r659.ShopPeriod or nil
			if s2_1.Period ~= nil and s5 ~= nil and s2_1.Period ~= s5 then
				return 0
			end
			return tonumber(s2_1.Count) or 0
		end

		r711 = function(s6)
			local s2 = r682(true)
			if type(s2) ~= "table" or type(s2.Shop) ~= "table" then
				return
			end

			for _, s4 in ipairs(r1_31) do
				if s6() then
					return
				end

				if r658[s4.Label] == true then
					for s7 = 1, 10 do
						local s8 = r659
						local s12 = r683()
						local s7_2, s8_1, s9 = ipairs(type(s8) == "table" and s8.Shop or {})
						local s10_1 = nil

						for _, s9_1 in s7_2, s8_1, s9 do
							if type(s9_1) == "table" and s9_1.Id == s4.Id then
								s10_1 = s9_1
							end
						end

						if not (not s10_1 or not s12 or s6()) then
							local s13_1 = tonumber(s10_1.PurchaseLimit)

							if not (s13_1 and r710(s12, s10_1) >= s13_1) then
								if not ((tonumber(s12.Samples) or 0) - (tonumber(s10_1.Price) or math.huge) < r657) then
									local s7_6 = r681("Shop", s10_1.Id, { Quote = s10_1.Quote, Sequence = tonumber(s12.ShopSequence) or 0 })

									if not (type(s7_6) ~= "table" or s7_6.Ok ~= true) then
										r664 = "Bought " .. s4.Label
										task.wait(0.4)
										continue
									end
								end
							end
						end

						break
					end
				end
			end
		end
	end

	local r713, r714, r715, r10_10, r16_6, r719, r720, r721, r736, r755
	local r756, r760, r761, r762

	do
		local r712 = 98
		r713 = 12
		r714 = 20
		r715 = 3

		r10_10 = {
			Vector3.new(2000, 90, -360),
			Vector3.new(2700, 90, -370),
			Vector3.new(3400, 90, -365),
			Vector3.new(4100, 90, -360),
			Vector3.new(4800, 90, -370),
			Vector3.new(5500, 90, -360),
			Vector3.new(5900, 90, -365),
		}

		r16_6 = {}
		local r17_6 = { Link = nil, Goal = nil, Look = nil, Character = nil }
		local r716 = r232.UserId
		local r6_16 = {}

		for _, r102 in ipairs({
			{ Label = "Scrap Drone", Tier = "ScrapDrone" },
			{ Label = "Reactor Drone", Tier = "ReactorDrone" },
			{ Label = "Augmented Drone", Tier = "AugmentedDrone" },
		}) do
			r6_16[#r6_16 + 1] = r102.Label
		end

		local r717 = { ScrapDrone = true, ReactorDrone = true, AugmentedDrone = true }
		local r718 = ({ "Nearest", "Rare First", "Most HP First" })[1]
		r719 = ({ "Tween", "Teleport" })[1]
		r720 = 110
		r721 = 1.5
		local r722 = 0
		local r723 = -math.huge

		local function r724(s22)
			local s1 = type(s22) == "table" and tonumber(s22.OwnerUserId) or nil
			return s1 == nil or s1 == r716
		end

		local function r725(s18)
			if typeof(s18) == "CFrame" then
				return s18.Position
			end

			if typeof(s18) == "Vector3" then
				return s18
			end
			return nil
		end

		local function r2_27(s33, s34)
			local s1 = r182:FindFirstChild(s33)
			if not s1 or not s1:IsA("RemoteEvent") then
				return
			end

			local s36 = s1.OnClientEvent:Connect(function(...)
				pcall(s34, ...)
			end)

			r240(function()
				pcall(function()
					s36:Disconnect()
				end)
			end)
		end

		r2_27("RE/Scramble/Drones", function(s17)
			if type(s17) ~= "table" then
				return
			end
			local s2 = pairs
			local s6 = type(s17.Upserts) == "table" and s17.Upserts or {}

			for _, s4 in s2(s6) do
				if type(s4) == "table" and s4.Id ~= nil and r724(s4) then
					local s6_3 = tostring(s4.Id)
					local s7_1 = type(s4.Attributes) == "table" and s4.Attributes or {}
					local s8 = r655[s6_3] or {}
					s8.Id = s6_3
					s8.Position = r725(s4.CFrame) or s8.Position
					s8.Health = tonumber(s4.Health) or s8.Health or 1
					s8.Tier = tostring(s7_1.ScrambleTier or s8.Tier or "")
					s8.Area = tostring(s7_1.ScrambleArea or s8.Area or "")
					s8.Seen = os.clock()
					r655[s6_3] = s8
				end
			end

			local s6_4 = pairs
			local s2_1 = type(s17.Removed) == "table" and s17.Removed or {}

			for s7_3, s8_1 in s6_4(s2_1) do
				local s2_2 = r655
				local s3_1 = tostring
				s8_1 = type(s8_1) == "string" and s8_1 or s7_3
				s2_2[s3_1(s8_1)] = nil
			end
		end)

		r2_27("RE/Scramble/Effect", function(arg1, s16, s17)
			if arg1 ~= "Hit" or type(s17) ~= "table" or s17.DroneId == nil then
				return
			end
			local s4_1 = r655[tostring(s17.DroneId)]
			if not s4_1 then
				return
			end
			s4_1.Position = r725(s16) or s4_1.Position
			s4_1.Health = (tonumber(s4_1.Health) or 1) - (tonumber(s17.Amount) or 1)

			if type(s17.Motion) == "string" and string.find(s17.Motion, "\"Death\"", 1, true) then
				s4_1.Health = 0
			end

			if s4_1.Health <= 0 then
				r655[s4_1.Id] = nil
			end
		end)

		r2_27("RE/Scramble/Drops", function(s4)
			local s2 = pairs
			s4 = type(s4) == "table" and s4 or {}

			for _, s4_1 in s2(s4) do
				if type(s4_1) == "table" and s4_1.Id ~= nil and r724(s4_1) then
					local s6_1 = r725(s4_1.Position) or r725(s4_1.Origin)

					if s6_1 then
						r656[tostring(s4_1.Id)] = {
							Position = s6_1,
							Radius = tonumber(s4_1.Radius) or 6,
							ExpiresAt = tonumber(s4_1.ExpiresAt),
							Kind = s4_1.Kind,
						}
					end
				end
			end
		end)

		r2_27("RE/Scramble/State", function(s17)
			if type(s17) ~= "table" then
				return
			end

			if s17.Patch == true and type(r659) == "table" then
				for s3_1, s4 in pairs(s17) do
					if s3_1 ~= "Patch" then
						r659[s3_1] = s4
					end
				end
			elseif type(s17.State) == "table" then
				r659 = s17
			end

			r660 = os.clock()
		end)

		r2_27("RE/Scramble/RemoveDrops", function(s37)
			local s1 = pairs
			s37 = type(s37) == "table" and s37 or {}

			for s2_1, s3 in s1(s37) do
				local s4 = r656
				local s6 = tostring
				s3 = type(s3) == "string" and s3 or s2_1
				s4[s6(s3)] = nil
			end
		end)

		local function r726(s10)
			local s7 = workspace:FindFirstChild("ScrambleLocalVisuals")
			return s7 and s7:FindFirstChild("PersonalDrone_" .. s10) or nil
		end

		local r727 = nil
		local r728 = 0

		local function r729()
			if r727 and next(r727) ~= nil then
				return r727
			end
			r727 = nil
			if os.clock() < r728 or type(getgc) ~= "function" or not r685() then
				return nil
			end
			r728 = os.clock() + 15

			for _, s3 in ipairs(getgc(false)) do
				if type(s3) == "function" and islclosure(s3) then
					local s5_1, s6 = pcall(debug.info, s3, "s")

					if s5_1 and type(s6) == "string" and string.find(s6, "PersonalDrones", 1, true) then
						local s5_2, s8 = pcall(debug.getupvalues, s3)

						if s5_2 and type(s8) == "table" then
							for _, s7 in pairs(s8) do
								if type(s7) ~= "table" then
									continue
								end
								local s8_1, s9 = next(s7)
								if type(s9) == "table" and s9.OwnerUserId ~= nil and s9.CFrame ~= nil then
									r727 = s7
									return s7
								end
							end

							continue
						end
					end
				end
			end

			return nil
		end

		local function r730()
			local s10 = r729()
			if not s10 then
				return
			end

			for s3, s4 in pairs(s10) do
				if type(s4) == "table" and r724(s4) then
					local s6_2 = tostring(s4.Id or s3)
					local s13 = type(s4.Attributes) == "table" and s4.Attributes or {}
					local s14 = r655[s6_2]
					local s7_1 = tonumber(s4.Health)

					if not s14 then
						s14 = { Id = s6_2 }
						s7_1 = s7_1 or 1
						s14.Health = s7_1
						r655[s6_2] = s14
					elseif s7_1 then
						s14.Health = math.min(s7_1, tonumber(s14.Health) or s7_1)
					end

					s14.Position = r725(s4.CFrame) or s14.Position
					s14.Tier = tostring(s13.ScrambleTier or s14.Tier or "")
					s14.Area = tostring(s13.ScrambleArea or s14.Area or "")

					if s13.DroneState == "Death" then
						s14.Health = 0
					end
				end
			end

			for s7_5 in pairs(r655) do
				if s10[s7_5] == nil then
					r655[s7_5] = nil
				end
			end
		end

		local function r731()
			pcall(r730)
			local s6 = workspace:FindFirstChild("ScrambleLocalVisuals")
			if not s6 then
				return
			end

			for _, s4 in ipairs(s6:GetChildren()) do
				local s5 = s4:GetAttribute("ScrambleDroneId")

				if s4:IsA("Model") and s5 ~= nil and string.sub(s4.Name, 1, 14) == "PersonalDrone_" then
					local s8 = tostring(s5)

					if s4:GetAttribute("DroneState") == "Death" then
						r655[s8] = nil
					elseif not r655[s8] then
						local s5_1, s6_2 = pcall(s4.GetPivot, s4)

						r655[s8] = {
							Id = s8,
							Position = s5_1 and s6_2.Position or nil,
							Health = tonumber(s4:GetAttribute("Health")) or 1,
							Tier = tostring(s4:GetAttribute("ScrambleTier") or ""),
							Area = tostring(s4:GetAttribute("ScrambleArea") or ""),
							Seen = os.clock(),
						}
					end
				end
			end
		end

		local function r732(s32)
			local s3 = r726(s32.Id)
			local s4 = s3 and s3:FindFirstChild("Hitbox")
			if s4 and s4:IsA("BasePart") then
				return s4.Position
			end

			if s3 and s3.PrimaryPart then
				return s3.PrimaryPart.Position
			end
			return s32.Position
		end

		local function r733()
			local s6 = {}
			local s8 = os.clock()

			for s3, s4 in pairs(r655) do
				local s11 = s4.Tier == nil or s4.Tier == "" or r717[s4.Tier] == true

				if s11 then
					s11 = (tonumber(s4.Health) or 0) > 0
				end

				s11 = s11 and s4.Position

				if s11 then
					s11 = (r16_6[s3] or 0) <= s8
				end

				if s11 then
					s6[#s6 + 1] = s4
				end
			end

			return s6
		end

		local function r734()
			local s4 = r690()
			if not s4 then
				return nil
			end
			local s6 = math.huge
			local s7 = nil

			for _, s3 in ipairs(r733()) do
				local s9_1 = ((r732(s3) or s3.Position) - s4.Position).Magnitude
				local s11 = r718
				local s12

				if s11 == "Rare First" then
					if s3.Tier == "AugmentedDrone" then
						s12 = s9_1 - 200000
					elseif s3.Tier ~= "ReactorDrone" then
						s12 = s9_1
					else
						s12 = s9_1 - 100000
					end
				elseif s11 == "Most HP First" then
					s12 = s9_1 - (tonumber(s3.Health) or 0) * 100000
				else
					s12 = s9_1
				end

				if s12 < s6 then
					s6 = s12
					s7 = s3
				end
			end

			return s7
		end

		local function r735()
			local s4 = r690()
			if not s4 then
				return nil, nil
			end
			local s6 = workspace:GetServerTimeNow()
			local s7 = math.huge
			local s8 = nil
			local s9 = nil

			for s2, s3 in pairs(r656) do
				if s3.ExpiresAt and s3.ExpiresAt < s6 then
					r656[s2] = nil
				else
					local s11_1 = (s3.Position - s4.Position).Magnitude

					if s3.Kind == "Part" then
						s11_1 -= 100000
					end

					if s11_1 < s7 then
						s7 = s11_1
						s8 = s2
						s9 = s3
					end
				end
			end

			return s8, s9
		end

		r736 = function()
			if not r17_6.Link then
				if r17_6.SwapWait then
					r17_6.SwapWait = nil
					r247.Shield("scramble", false)
				end

				return
			end

			r17_6.Link:Disconnect()
			local s3 = r17_6
			local s6 = r17_6
			local s10 = r17_6
			r17_6.Link = nil
			s3.Goal = nil
			s6.Look = nil
			s10.Character = nil
			local s3_1 = r17_6
			local s6_1 = r17_6
			local s10_1 = r17_6
			local s12 = r17_6
			r17_6.Track = nil
			s3_1.Dir = nil
			s6_1.Last = nil
			s10_1.LastAt = nil
			s12.Vel = nil
			r247.Driving = math.max(0, r247.Driving - 1)
			r247.Shield("scramble", false)
		end

		r240(r736)

		local function r737(s27, s28, s29)
			if s29 ~= r17_6.Track then
				local s5_3 = r17_6
				local s7_2 = r17_6
				r17_6.Last = nil
				s5_3.LastAt = nil
				s7_2.Vel = nil
			end

			local s5 = r17_6
			local s7 = r17_6
			r17_6.Goal = s27
			s5.Look = s28
			s7.Track = s29
			local s2 = r232.Character

			if r17_6.Link and r17_6.Character ~= s2 then
				r736()
				local s6 = r17_6
				local s8 = r17_6
				r17_6.Goal = s27
				s6.Look = s28
				s8.Track = s29
			end

			if r17_6.Link or not s2 then
				return
			end

			if not r247.Swapped() then
				r247.Shield("scramble", true)
				r17_6.SwapWait = r17_6.SwapWait or os.clock() + 6
				local s5_2 = r17_6.SwapWait
				if os.clock() < s5_2 then
					r664 = "Waiting for the character to settle"
					return
				end
			end

			if r17_6.SwapWait then
				r17_6.SwapWait = nil
			else
				r247.Shield("scramble", true)
			end

			r17_6.Character = s2
			r247.Driving = r247.Driving + 1

			r17_6.Link = r137.Heartbeat:Connect(function(t3)
				local t13 = r247.Root()
				local t15 = r17_6.Goal
				if not t13 or not t15 or t13.Parent ~= r17_6.Character or r247.AntiGuard.Busy or r247.Movement.Owner ~= "scramble" then
					return
				end
				local t17 = t13.Position

				if r17_6.Track then
					local t8, t9 = pcall(r17_6.Track)

					if t8 and typeof(t9) == "Vector3" then
						local t18 = os.clock()

						if not r17_6.Last or not r17_6.LastAt then
							local t4 = r17_6
							r17_6.Last = t9
							t4.LastAt = t18
						elseif (t9 - r17_6.Last).Magnitude > 0.01 then
							local t4_4 = math.max(t18 - r17_6.LastAt, 0.0041666666666666666)
							local t10 = (t9 - r17_6.Last) / t4_4

							if t10.Magnitude < 400 then
								local t4_6 = math.clamp(t4_4 * 12, 0.2, 0.8)
								r17_6.Vel = r17_6.Vel and r17_6.Vel:Lerp(t10, t4_6) or t10
							end

							local t4_5 = r17_6
							r17_6.Last = t9
							t4_5.LastAt = t18
						elseif t18 - r17_6.LastAt > 0.25 and r17_6.Vel then
							r17_6.Vel = r17_6.Vel:Lerp(Vector3.zero, math.clamp(t3 * 6, 0, 1))
						end

						local t20 = r17_6.Vel or Vector3.zero
						local t18_1 = r17_6.Last + t20 * (math.clamp(t18 - r17_6.LastAt, 0, 0.25) + 0.1)
						local t7 = Vector3.new(t17.X - t18_1.X, 0, t17.Z - t18_1.Z)

						if t7.Magnitude > 0.5 then
							local t6 = t7.Unit
							local t7_1 = math.clamp(t3 * 5, 0, 1)
							local t2_2 = r17_6.Dir and r17_6.Dir:Lerp(t6, t7_1) or t6
							r17_6.Dir = t2_2.Magnitude > 0.01 and t2_2.Unit or t6
						end

						t15 = t18_1 + (r17_6.Dir or Vector3.new(0, 0, 1)) * r667 + Vector3.new(0, -1, 0)
						local t4_1 = r17_6
						r17_6.Goal = t15
						t4_1.Look = t18_1

						if (t15 - t17).Magnitude <= 40 then
							local t8_1 = math.max(t3, 0.0041666666666666666)
							local t22 = t20 + (t15 - t17) / math.max(0.1, t8_1)
							local t4_2 = math.max(400, t20.Magnitude + 80)

							if t4_2 < t22.Magnitude then
								t22 = t22.Unit * t4_2
							end

							local t22_1 = t22 + Vector3.new(0, workspace.Gravity * t8_1 * 0.5, 0)
							local t2_3 = Vector3.new(t18_1.X - t17.X, 0, t18_1.Z - t17.Z)

							pcall(function()
								if t2_3.Magnitude > 0.05 then
									t13.CFrame = CFrame.lookAt(t17, t17 + t2_3.Unit)
								end

								t13.AssemblyLinearVelocity = t22_1
								t13.AssemblyAngularVelocity = Vector3.zero
							end)

							return
						end
					end
				end

				local t4_3

				if Vector3.new(t15.X - t17.X, 0, t15.Z - t17.Z).Magnitude > 250 then
					local t8_2 = math.max(r712, t15.Y)
					t4_3 = t17.Y < t8_2 - 2 and Vector3.new(t17.X, t8_2, t17.Z) or Vector3.new(t15.X, t8_2, t15.Z)
				else
					t4_3 = t15
				end

				local t1_4 = t4_3 - t17
				local t3_1 = r20_4 * t3
				local t3_2 = t1_4.Magnitude <= t3_1 and t4_3 or t17 + t1_4.Unit * t3_1
				t15 = r17_6.Look or t15
				local t7_2 = Vector3.new(t15.X - t3_2.X, 0, t15.Z - t3_2.Z)
				local t1_6 = t7_2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, t7_2.Unit) or t13.CFrame.Rotation

				pcall(function()
					t13.CFrame = CFrame.new(t3_2) * t1_6
					t13.AssemblyLinearVelocity = Vector3.zero
					t13.AssemblyAngularVelocity = Vector3.zero
				end)
			end)
		end

		local function r738(s8)
			if typeof(s8) ~= "Instance" or not s8:IsA("Tool") then
				return false
			end
			local s10 = s8:GetAttribute("GearName")
			local s2_1 = r234.Gears
			local s4_1 = type(s2_1) == "table" and s2_1.Directory or nil
			local s2_2 = type(s10) == "string" and type(s4_1) == "table" and s4_1[s10] or nil
			return type(s2_2) == "table" and (s2_2.ToolController == "Slap" or s2_2.SlapPower ~= nil)
		end

		local function r739(s19)
			if typeof(s19) ~= "Instance" or not s19:IsA("Tool") then
				return false
			end

			if tostring(s19:GetAttribute("ItemType")) ~= "Gear" then
				return false
			end
			local s1_1 = tostring(s19:GetAttribute("GearName") or "")
			if s1_1 == "" then
				return false
			end
			return string.find(string.lower(s1_1), "scrambler", 1, true) ~= nil
		end

		local function r740()
			return r232.Character, r232:FindFirstChildOfClass("Backpack")
		end

		local function r741()
			local s2 = r247.FindBat()
			if s2 then
				return s2
			end
			local s4, s5 = r740()

			for _, s4_1 in ipairs({ s4, s5 }) do
				if s4_1 then
					for _, s7 in ipairs(s4_1:GetChildren()) do
						if r738(s7) or r739(s7) then
							return s7
						end
					end
				end
			end

			return nil
		end

		r666.Valid = function(s22)
			if typeof(s22) ~= "Instance" or not s22:IsA("Tool") then
				return false
			end
			return r247.IsBatTool(s22) or r738(s22) or r739(s22)
		end

		r666.Owned = function(s34)
			if typeof(s34) ~= "Instance" or not s34:IsA("Tool") then
				return false
			end
			local s1, s3 = r740()
			local s4 = s34.Parent
			return s4 ~= nil and (s4 == s1 or s4 == s3)
		end

		r666.Name = function(s23)
			if r739(s23) then
				return "The Scrambler"
			end
			return tostring(s23:GetAttribute("GearName") or s23.Name)
		end

		r666.Put = function(s15, s16, s17)
			local s4 = r666.EquipAt
			if os.clock() - s4 < 0.4 then
				return false
			end
			r666.EquipAt = os.clock()

			pcall(function()
				s16:EquipTool(s15)
			end)

			if s15.Parent ~= s17 then
				pcall(function()
					s15.Parent = s17
				end)
			end

			return s15.Parent == s17
		end

		local function r742()
			local s10 = r232.Character
			local s12 = s10 and s10:FindFirstChildWhichIsA("Humanoid")
			if not s10 or not s12 or s12.Health <= 0 then
				return nil, false
			end
			local s4 = s10:FindFirstChildWhichIsA("Tool")

			if s4 ~= nil and r666.Valid(s4) then
				r666.Tool = s4
				r665 = r666.Name(s4)
				return s4, true
			end

			if not r666.Owned(r666.Tool) then
				r666.Tool = r741()
			end

			local s3_1 = r666.Tool
			if not s3_1 then
				r665 = ""
				return nil, false
			end
			r665 = r666.Name(s3_1)
			r666.Put(s3_1, s12, s10)
			return s3_1, s3_1.Parent == s10
		end

		local function r743()
			local s4, s2 = r742()

			if s4 and s2 then
				if r668 then
					pcall(function()
						s4:Activate()
					end)

					task.defer(function()
						pcall(function()
							s4:Deactivate()
						end)
					end)
				else
					pcall(function()
						s4:Deactivate()
						s4:Activate()
					end)
				end
			end

			return s4 ~= nil
		end

		local function r744()
			local s4, s5 = r740()
			local s9 = nil
			local s11 = nil
			local s13 = nil

			for _, s4_1 in ipairs({ s4, s5 }) do
				if s4_1 then
					for _, s7 in ipairs(s4_1:GetChildren()) do
						if r666.Valid(s7) then
							if r739(s7) then
								s9 = s9 or s7
							elseif r247.IsBatTool(s7) and (s11 == nil or not r247.IsBatTool(s11)) then
								if s13 then
									s11 = s7
								else
									s13 = s11
									s11 = s7
								end
							elseif s11 == nil then
								s11 = s7
							elseif s13 == nil then
								s13 = s7
							end
						end
					end
				end
			end

			return s11, s9 or s13
		end

		local function r745(s27)
			pcall(function()
				s27:Activate()
			end)

			task.defer(function()
				pcall(function()
					s27:Deactivate()
				end)
			end)
		end

		r671.SpamUntil = 0
		r671.List = {}
		r671.Dirty = true
		r671.BuiltAt = 0
		r671.NextBag = 0
		r671.Links = {}

		r671.Click = function(s13)
			pcall(s13.Deactivate, s13)
			pcall(s13.Activate, s13)
		end

		r671.Rebuild = function()
			r671.Dirty = false
			r671.BuiltAt = os.clock()
			table.clear(r671.List)
			local s4, s5 = r740()

			for _, s4_1 in ipairs({ s4, s5 }) do
				if s4_1 then
					for _, s7 in ipairs(s4_1:GetChildren()) do
						if r666.Valid(s7) then
							r671.List[#r671.List + 1] = s7
						end
					end
				end
			end
		end

		r671.Beat = r137.Heartbeat:Connect(function()
			local s2 = os.clock()
			if r671.SpamUntil <= s2 then
				return
			end

			if r671.Dirty or s2 - r671.BuiltAt > 1 then
				r671.Rebuild()
			end

			local s6 = r232.Character
			local s8 = s2 >= r671.NextBag

			if s8 then
				r671.NextBag = s2 + 0.25
			end

			for _, s4_1 in ipairs(r671.List) do
				local s10 = s4_1.Parent

				if s10 == s6 then
					r671.Click(s4_1)
				elseif s8 and s10 ~= nil then
					r671.Click(s4_1)
				end
			end
		end)

		r671.Unwatch = function()
			for s6 = #r671.Links, 1, -1 do
				pcall(function()
					r671.Links[s6]:Disconnect()
				end)

				r671.Links[s6] = nil
			end
		end

		r671.Watch = function(s25)
			r671.Unwatch()
			r671.Dirty = true
			if not s25 then
				return
			end

			r671.Links[#r671.Links + 1] = s25.ChildAdded:Connect(function(t10)
				if not t10:IsA("Tool") then
					return
				end
				r671.Dirty = true
				local t4 = r671.SpamUntil

				if os.clock() < t4 and r666.Valid(t10) then
					r671.Click(t10)
					task.defer(r671.Click, t10)
				end
			end)

			r671.Links[#r671.Links + 1] = s25.ChildRemoved:Connect(function(arg1)
				if arg1:IsA("Tool") then
					r671.Dirty = true
				end
			end)

			task.defer(function()
				local t9 = r232:FindFirstChildOfClass("Backpack") or r232:WaitForChild("Backpack", 5)

				if t9 and r232.Character == s25 then
					r671.Links[#r671.Links + 1] = t9.ChildAdded:Connect(function()
						r671.Dirty = true
					end)

					r671.Links[#r671.Links + 1] = t9.ChildRemoved:Connect(function()
						r671.Dirty = true
					end)
				end
			end)
		end

		r671.Watch(r232.Character)
		r671.CharLink = r232.CharacterAdded:Connect(r671.Watch)

		r240(function()
			r671.SpamUntil = 0
			r671.Unwatch()

			for _, s6 in ipairs({ "Beat", "CharLink" }) do
				if r671[s6] then
					pcall(function()
						r671[s6]:Disconnect()
					end)

					r671[s6] = nil
				end
			end
		end)

		local function r746()
			local s7 = r232.Character
			local s2 = s7 and s7:FindFirstChildWhichIsA("Humanoid")
			if not s7 or not s2 or s2.Health <= 0 then
				return false
			end
			local s4_1, s5 = r744()
			if not s4_1 or not s5 then
				return r743()
			end
			local s3_2 = { s4_1, s5 }
			local s8_1 = { 0.3, 0.4 }
			local s4_2 = s3_2[r671.Index]

			if r671.Tool ~= s4_2 then
				local s5_3 = r671
				local s10_2 = r671
				local s14 = os.clock()
				s5_3.Tool = s4_2
				s10_2.Since = s14
			end

			local s5_1 = s4_2.Parent == s7

			if s5_1 then
				local s10 = r671.Since
				s5_1 = os.clock() - s10 >= s8_1[r671.Index]
			end

			if s5_1 then
				r671.Index = r671.Index == 1 and 2 or 1
				s4_2 = s3_2[r671.Index]
				local s3_3 = r671
				local s8_2 = r671
				local s10_1 = os.clock()
				s3_3.Tool = s4_2
				s8_2.Since = s10_1
			end

			r666.Tool = s4_2
			r665 = r666.Name(s4_2)

			if s4_2.Parent ~= s7 then
				pcall(function()
					s2:EquipTool(s4_2)
				end)

				if s4_2.Parent ~= s7 then
					pcall(function()
						s4_2.Parent = s7
					end)
				end

				r671.Since = os.clock()

				if s4_2.Parent == s7 then
					r745(s4_2)
					task.defer(r745, s4_2)
				end

				return true
			end

			r745(s4_2)
			return true
		end

		local function r747(s29, s30, s31)
			local s5 = os.clock()
			local s6 = s5 + r715

			while os.clock() < s6 and not s29() do
				local s8, s9 = r735()
				local s1_1 = not s9
				local s2

				if s1_1 then
					s2 = s1_1
				elseif s30 then
					s2 = (s9.Position - s30).Magnitude > (s31 or 40)
				else
					s2 = s30
				end

				if s2 then
					if s30 and os.clock() - s5 < 1.2 then
						task.wait(0.1)
						continue
					end
					return
				end

				if r698() and not r698(s9.Position) then
					r736()
					r664 = "Leaving the base through the safe zone"
					if not r702(s9.Position + Vector3.new(0, 2.5, 0), s29, 6) then
						return
					end
					continue
				end

				r664 = s9.Kind == "Part" and "Picking up a Drone Part" or "Picking up Samples"
				r737(s9.Position + Vector3.new(0, 2.5, 0), s9.Position)
				local s1_5 = os.clock() + 2.5

				while r656[s8] and os.clock() < s1_5 and not s29() do
					task.wait(0.1)
				end

				r656[s8] = nil
				s6 = os.clock() + 1.2
			end
		end

		local function r748(s23, s24)
			local s4 = os.clock()
			local s5 = tonumber(s23.Health) or 0
			local s7 = nil
			local s8 = nil
			local s3 = nil
			local s9 = false

			while not s24() do
				local s10 = r655[s23.Id]
				local s1 = not s10

				if not s1 then
					s1 = (tonumber(s10.Health) or 0) <= 0
				end

				if s1 then
					return true
				end
				local s2_1 = r726(s23.Id)
				if s2_1 and s2_1:GetAttribute("DroneState") == "Death" then
					r655[s23.Id] = nil
					return true
				end
				local s1_2 = r690()
				local s11 = s1_2 ~= nil and s10.Position ~= nil
				local s12

				if s11 then
					s12 = (s1_2.Position - (r732(s10) or s10.Position)).Magnitude <= 30
				else
					s12 = s11
				end

				if s12 and not s2_1 then
					s7 = s7 or os.clock()
					if os.clock() - s7 > 1.5 then
						r655[s23.Id] = nil
						return false
					end
				else
					s7 = nil
				end

				local s1_5 = tonumber(s10.Health) or 0

				if s1_5 ~= s5 then
					s8 = nil
					s5 = s1_5
				end

				if r714 < os.clock() - s4 then
					r16_6[s23.Id] = os.clock() + 30
					return false
				end
				local s28 = r732(s10) or s10.Position
				local s1_6 = r690()
				if not s1_6 then
					return false
				end

				if r698() and not r698(s28) then
					r736()
					r664 = "Leaving the base through the safe zone"
					if not r702(s28, s24, 12) then
						return false
					end

					if s24() then
						return false
					end
				end

				if not s3 then
					local s11_2 = nil
					local s12_1 = nil

					s3 = function()
						local t11 = r655[s23.Id]
						if not t11 then
							return nil
						end

						if not s11_2 or not s11_2.Parent then
							s11_2 = r726(s23.Id)
							local t9 = s11_2 and s11_2:FindFirstChild("Hitbox")
							s12_1 = t9 and t9:IsA("BasePart") and t9 or s11_2 and s11_2.PrimaryPart or nil
						end

						if s12_1 and s12_1.Parent then
							return s12_1.Position
						end
						return t11.Position
					end
				end

				if r668 then
					r737(s28 + Vector3.new(0, -1, 16), s28, s3)
				else
					r737(s28 + Vector3.new(0, -1, 5), s28)
				end

				if (s1_6.Position - s28).Magnitude <= 60 and not r668 then
					r742()
				end

				local s2_4 = (s1_6.Position - s28).Magnitude
				local s29 = false

				if r668 then
					s29 = math.max(12, r667 + 7)
				end

				local s1_7 = s2_4 <= (s29 or 12)

				if s1_7 then
					if r668 then
						r671.SpamUntil = os.clock() + 0.2
					end

					local s2_5 = s8 or os.clock()
					if os.clock() - s2_5 > 8 then
						r16_6[s23.Id] = os.clock() + 30
						return false
					end
					local s12_2 = false

					if r668 then
						s12_2 = r746()
					end

					if s12_2 or not r668 and r743() then
						r664 = string.format("Smashing %s  %d HP", s10.Tier ~= "" and s10.Tier or "drone", math.max(0, tonumber(s10.Health) or 0))
						s8 = s2_5
					elseif not s9 then
						r664 = "No bat found, get any bat to smash drones"
						s9 = true
						s8 = s2_5
					else
						s8 = s2_5
					end
				else
					r664 = "Flying to a drone"
				end

				local s2_6 = task.wait
				local s11_4 = false

				if not r668 then
					s1_7 = s11_4
				end

				s2_6(s1_7 and 0.03 or 0.1)
			end

			return false
		end

		local function r749(s29)
			for _, s3 in ipairs(r10_10) do
				if s29() then
					return false
				end
				r664 = "Looking for drones"
				r737(s3)
				local s5 = os.clock() + 12

				while os.clock() < s5 and not s29() do
					r731()
					if #r733() > 0 then
						return true
					end

					if r247.DistanceTo(s3) < 8 then
						break
					end
					task.wait(0.2)
				end
			end

			return #r733() > 0
		end

		local function r750()
			local s6 = workspace:GetServerTimeNow()
			local s2, s3 = r685()
			if s2 and s3 and s3 < 25 then
				return next(r656) ~= nil
			end

			for _, s4_1 in pairs(r656) do
				if s4_1.Kind == "Part" or s4_1.ExpiresAt and s4_1.ExpiresAt - s6 < 30 then
					return true
				end
			end

			return false
		end

		local r751 = nil

		local function r752()
			local s4 = type(r659) == "table" and r659.Window or nil
			return type(s4) == "table" and s4.Index or nil
		end

		local function r753(s27)
			local s1 = r751 ~= nil and r751 == r752()

			while not s27() do
				r137.Heartbeat:Wait()

				if not s27() then
					r731()

					if r750() then
						r747(s27)
					end

					local s2, s3, s2_1, s3_1, s3_2, s4, s5, s6, s8, s8_1, s5_1, s8_2, s22, s25, s5_2, s6_1, s8_3, s10, s10_1

					if r698() then
						r736()

						if r699(s27) then
							s2 = r734()
							s3 = not s2 and next(r656) ~= nil

							if s3 then
								r747(s27)
								r731()
								s2 = r734()
							end

							if not s2 then
								s2_1 = not r685()
								s3_1 = s2_1 or s1

								if not s3_1 then
									r751 = r752()
									s3_2 = true
									s1 = true

									if not r749(s27) then
										break
									else
										continue
									end
								end
							else
								s4 = r732(s2) or s2.Position
								s5 = r690()
								s6 = s5 and (s5.Position - s4).Magnitude or 0
								s8 = r719 == "Teleport"
								s5 = s8 and s5

								if s5 then
									s8_1 = r698() and not r698(s4)
									s5 = not s8_1
								end

								if s5 then
									s5_1 = s6 > r713
									s8_2 = s5_1 and s6 <= r720 and os.clock() >= r722 and os.clock() - r723 >= r721

									if s8_2 then
										r723 = os.clock()
										s22 = Vector3.new
										s25 = false

										if r668 then
											s25 = 16
										end

										s25 = s25 or 5
										s5_2 = s4 + s22(0, -1, s25)
										r737(s5_2, s4)
										s6_1 = r690()

										if s6_1 then
											r664 = "Teleporting to the next drone"

											pcall(function()
												s6_1.CFrame = CFrame.lookAt(s5_2, Vector3.new(s4.X, s5_2.Y, s4.Z))
												s6_1.AssemblyLinearVelocity = Vector3.zero
												s6_1.AssemblyAngularVelocity = Vector3.zero
											end)

											s8_3 = os.clock() + 0.8

											while true do
												s10 = os.clock() < s8_3 and not s27()

												if s10 then
													s10_1 = r690()
													s10_1 = s10_1 and (s10_1.Position - s5_2).Magnitude > 40

													if s10_1 then
														r722 = os.clock() + 30
														r664 = "Teleport pulled back, tweening"
														break
													else
														r137.Heartbeat:Wait()
														continue
													end
												end

												break
											end
										end
									end
								end

								r748(s2, s27)
								continue
							end
						end
					else
						s2 = r734()
						s3 = not s2 and next(r656) ~= nil

						if s3 then
							r747(s27)
							r731()
							s2 = r734()
						end

						if not s2 then
							s2_1 = not r685()
							s3_1 = s2_1 or s1

							if not s3_1 then
								r751 = r752()
								s3_2 = true
								s1 = true

								if not r749(s27) then
									break
								else
									continue
								end
							end
						else
							s4 = r732(s2) or s2.Position
							s5 = r690()
							s6 = s5 and (s5.Position - s4).Magnitude or 0
							s8 = r719 == "Teleport"
							s5 = s8 and s5

							if s5 then
								s8_1 = r698() and not r698(s4)
								s5 = not s8_1
							end

							if s5 then
								s5_1 = s6 > r713
								s8_2 = s5_1 and s6 <= r720 and os.clock() >= r722 and os.clock() - r723 >= r721

								if s8_2 then
									r723 = os.clock()
									s22 = Vector3.new
									s25 = false

									if r668 then
										s25 = 16
									end

									s25 = s25 or 5
									s5_2 = s4 + s22(0, -1, s25)
									r737(s5_2, s4)
									s6_1 = r690()

									if s6_1 then
										r664 = "Teleporting to the next drone"

										pcall(function()
											s6_1.CFrame = CFrame.lookAt(s5_2, Vector3.new(s4.X, s5_2.Y, s4.Z))
											s6_1.AssemblyLinearVelocity = Vector3.zero
											s6_1.AssemblyAngularVelocity = Vector3.zero
										end)

										s8_3 = os.clock() + 0.8

										while true do
											s10 = os.clock() < s8_3 and not s27()

											if s10 then
												s10_1 = r690()
												s10_1 = s10_1 and (s10_1.Position - s5_2).Magnitude > 40

												if s10_1 then
													r722 = os.clock() + 30
													r664 = "Teleport pulled back, tweening"
													break
												else
													r137.Heartbeat:Wait()
													continue
												end
											end

											break
										end
									end
								end
							end

							r748(s2, s27)
							continue
						end
					end
				end

				break
			end

			r747(s27)
			r736()
		end

		local r754 = { LostPart1 = "Mechanical Gear", LostPart2 = "Wiring Harness" }

		r247.ScrambleLostPart = function(s17)
			return r686(r683(), s17)
		end

		r755 = nil

		r756 = function()
			local s16 = r683()
			if not s16 then
				return "Lost Parts: no event data"
			end
			local s12 = workspace:FindFirstChild("DrScrambleEvent")
			local s21 = {}
			local s17 = 0
			local s19 = 0

			for _, s4 in ipairs(r5_18) do
				local s8 = s12 and s12:FindFirstChild(s4)

				if s8 then
					s17 += 1
				end

				if r686(s16, s4) then
					s19 += 1
				elseif s8 then
					local s6, s7 = pcall(s8.GetPivot, s8)
					s6 = s6 and r247.DistanceTo(s7.Position) or nil
					s21[#s21 + 1] = s6 and string.format("%s %d studs", r754[s4], math.floor(s6)) or r754[s4]
				else
					s21[#s21 + 1] = r754[s4] .. " not on map"
				end
			end

			local s12_1 = string.format("Lost Parts on map %d/2  -  Collected %d/2", s17, s19)
			local s3_1

			if #s21 > 0 then
				s3_1 = s12_1 .. "  -  " .. table.concat(s21, "  -  ")
			else
				s3_1 = s12_1
			end

			return s3_1
		end

		local function r757(s27)
			if not r696() then
				return true
			end
			local s25 = r694("Exit")
			local s24 = r695(s25, nil)
			if not s24 then
				return false
			end
			r664 = "Leaving the Secret Cave"
			if not r691(s24, s27, 4) then
				return false
			end

			for s1 = 1, 4 do
				if s27() then
					return false
				end
				r692(s25 or r694("Exit"))
				local s3 = os.clock() + 1.5

				while os.clock() < s3 and r696() do
					r137.Heartbeat:Wait()
				end

				if not r696() then
					return true
				end
			end

			return not r696()
		end

		local function r758()
			return r247.IsNight() or r247.WallSealed()
		end

		local function r759(s10)
			if not r758() then
				return true
			end
			r736()

			while r758() and not s10() do
				r664 = r247.IsNight() and "Night, waiting for the wall to drop" or "Waiting for the wall to drop"
				r137.Heartbeat:Wait()
			end

			return not s10()
		end

		r760 = function()
			if not r247.Toggle(nil, false) or not r684() then
				return false
			end

			if r672.Ended then
				return false
			end

			if r685() then
				return true
			end
			r731()
			return #r733() > 0 or next(r656) ~= nil
		end

		r761 = function()
			local s9 = r683()
			if not s9 or s9.Completed == true or not r684() then
				return false
			end
			local s11 = tonumber(s9.TotalParts)

			if not s11 then
				s11 = r687(s9) + (tonumber(s9.DroneParts) or 0)
			end

			local s2_1 = r247.Toggle(nil, false)

			if s2_1 then
				local s4 = #r5_18
				s2_1 = r687(s9) < s4
			end

			local s3_2 = r247.Toggle(nil, false) and (s11 >= 5 or s9.Discovered ~= true)
			return s2_1 or s3_2
		end

		r762 = function(s7)
			local function s2()
				return s7 ~= r662 or r247.Movement.Owner ~= "scramble"
			end

			local function s4()
				return s2() or not r760() or r758()
			end

			while true do
				if r760() and not s2() then
					if r759(s2) then
						pcall(r753, s4)
						if r758() then
							continue
						end
					end
				end

				break
			end

			r736()
			if s2() or r760() then
				return
			end

			if not r761() then
				r703(s2)
				r664 = ""
				return
			end

			if not r759(s2) then
				return
			end
			r682(true)
			local s4_2 = r683()
			if not s4_2 then
				return
			end

			if not r761() then
				r664 = ""
				return
			end

			if r247.Toggle(nil, false) and s4_2.Discovered ~= true then
				pcall(r707, s2)
			end

			if r247.Toggle(nil, false) then
				pcall(r708, function()
					return s2() or not r247.Toggle(nil, false) or r760() or r758()
				end)
			end

			if r247.Toggle(nil, false) then
				pcall(r709, function()
					return s2() or not r247.Toggle(nil, false) or r760() or r758()
				end)
			end

			if r696() and not s2() then
				pcall(r757, s2)
			end

			if not r696() and not r760() then
				pcall(r703, s2)
			end
		end
	end

	local r763

	r763 = function(s13)
		if not (r247.Treadmill.Riding or r247.OnBelt()) then
			return true
		end

		for s1_1 = 1, 3 do
			if s13() then
				return false
			end
			r664 = "Jumping off the treadmill"
			r247.Treadmill.Riding = false
			task.spawn(r247.LeaveBelt)
			local s3 = r232.Character
			local s1_2 = s3 and s3:FindFirstChildOfClass("Humanoid")

			if s1_2 then
				pcall(function()
					s1_2.Sit = false
					s1_2.Jump = true
					s1_2:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end

			local s3_1 = r690()

			if s3_1 then
				local s3_3 = s3_1.Position
				local s4 = s3_3 + Vector3.new(0, 18, 0)
				local s6 = os.clock()

				while true do
					r137.Heartbeat:Wait()
					local s8 = r690()

					if not s8 then
						break
					else
						local s14 = math.min(1, (os.clock() - s6) / 0.25)

						pcall(function()
							local t3 = s8.CFrame.Rotation
							s8.CFrame = CFrame.new(s3_3:Lerp(s4, s14)) * t3
							s8.AssemblyLinearVelocity = Vector3.zero
							s8.AssemblyAngularVelocity = Vector3.zero
						end)

						if not (s14 >= 1) then
							continue
						end
						break
					end
				end
			end

			if not (r247.Treadmill.Riding or r247.OnBelt()) then
				return true
			end
		end

		return not r247.OnBelt()
	end

	do
		local r11_19 = { "Highest Value", "Best Rarity", "Biggest Size" }
		local r765 = { idle = "#8C93A6", work = "#FFC857", good = "#57E08A", stop = "#FF6B6B" }
		local r766 = 6

		local r767 = {
			Handle = nil,
			BuyHandle = nil,
			Loop = 0,
			MinRarity = 0,
			MinIncome = 0,
			Priority = r11_19[1],
			SkipMutated = true,
			Targets = {},
			Cooldown = 0,
			Status = "Idle",
			State = "idle",
			Detail = "Turn it on to start applying Scrambled",
			RarityColor = "#FFFFFF",
			Icon = "",
			Ui = {},
			Row = nil,
			Left = 0,
			Pen = 0,
			Match = 0,
			Tries = 0,
			Hits = 0,
			Locked = nil,
			Short = false,
			EggOptions = {},
			EggCategory = {},
		}

		local r104 = r234.Assets and r234.Assets.Directory
		local r107 = {}

		if type(r104) == "table" then
			for r104_1, r105 in pairs(r104) do
				local r6_17 = type(r105) == "table" and r105.Rarity or nil
				local r12_17 = type(r6_17) == "table"

				if r12_17 then
					r12_17 = tonumber(r6_17.RarityNumber or r6_17.Rank)
				end

				r12_17 = r12_17 or nil

				if r12_17 then
					table.insert(r107, {
						Category = tostring(r104_1),
						Name = tostring(r105.DisplayName or r104_1),
						Rarity = r12_17,
						RarityName = tostring(r6_17.DisplayName or r6_17._id or r12_17),
					})
				end
			end
		end

		table.sort(r107, function(s7, s8)
			if s7.Rarity ~= s8.Rarity then
				return s7.Rarity > s8.Rarity
			end
			return s7.Name < s8.Name
		end)

		for _, r108 in ipairs(r107) do
			local r151_5 = string.format("%s [%s]", r108.Name, r108.RarityName)

			if r767.EggCategory[r151_5] then
				r151_5 = string.format("%s [%s] (%s)", r108.Name, r108.RarityName, r108.Category)
			end

			table.insert(r767.EggOptions, r151_5)
			r767.EggCategory[r151_5] = r108.Category
		end

		local function r780(s37)
			local s1 = r234.Assets and r234.Assets.Directory
			return type(s1) == "table" and s1[tostring(s37)] or nil
		end

		local function r781(arg1)
			local s1 = r780(arg1.AssetCategory)
			local s2 = type(s1) == "table" and s1.Rarity or nil
			local s1_1 = type(s2) == "table"

			if s1_1 then
				s1_1 = tonumber(s2.RarityNumber or s2.Rank)
			end

			return s1_1 or 0
		end

		local function r782(s37)
			local s1 = r780(s37.AssetCategory)
			local s2 = type(s1) == "table" and tonumber(s1.EarningRate) or 0
			local s1_1 = tonumber(s37.AssetScale) or 0
			if s2 <= 0 or s1_1 <= 0 then
				return 0
			end
			return s2 * (s1_1 > 5 and (s1_1 / 5) ^ 1.2 * 19.637875755794113 or s1_1 ^ 1.85)
		end

		local function r783(s21)
			if tostring(s21.BaseMutation or "") == "Scrambled" then
				return true
			end

			if type(s21.Mutations) == "table" then
				for s2_1, s3 in pairs(s21.Mutations) do
					if type(s3) == "string" and s3 == "Scrambled" then
						return true
					end

					if type(s2_1) == "string" and s2_1 == "Scrambled" and s3 ~= false then
						return true
					end
				end
			end

			return false
		end

		local function r784()
			local s3 = r234.EggState
			if type(s3) ~= "table" or type(s3.ReadOwnerEggs) ~= "function" then
				return {}
			end
			local s2_1, s6 = pcall(s3.ReadOwnerEggs, r232.UserId)
			if not s2_1 or type(s6) ~= "table" then
				return {}
			end
			local s7 = {}

			for s3_2, s4 in pairs(s6) do
				if type(s4) == "table" and s4.Placement ~= nil then
					s4.Uid = s4.Uid or s3_2
					s7[#s7 + 1] = s4
				end
			end

			return s7
		end

		local function r785(s17)
			local s4 = s17 and s17.Uid

			if s4 then
				local s2 = workspace:FindFirstChild("AreaEggSlotsClient")
				s2 = s2 and s2:FindFirstChild(s4)

				if s2 then
					local s15, s16 = pcall(function()
						return s2:GetPivot().Position
					end)

					if s15 and typeof(s16) == "Vector3" then
						return s16
					end
				end
			end

			if type(r247.PenAnchor) == "function" then
				local s15_1, s16_1 = pcall(r247.PenAnchor)
				if s15_1 and typeof(s16_1) == "Vector3" then
					return s16_1
				end
			end

			return nil
		end

		local function r786(s33, s34)
			local s1 = r785(s33)
			if s1 == nil then
				return true
			end

			if r247.DistanceTo(s1) <= r766 then
				return true
			end

			local function s32()
				if s34 ~= r767.Loop or not r247.Toggle(r767.Handle, false) then
					return true
				end

				if r247.Movement.PlaceWanted == true then
					return true
				end
				return r247.Movement.ScrambleWanted == true or r247.Steal.Wanted == true
			end

			if r247.Treadmill.Riding or r247.OnBelt() then
				r247.ExitBelt()
			end

			r247.HoldBelt()
			local s29, s30 = pcall(r247.FlyTo, s1 + Vector3.new(0, 3, 0), s32, "mutation")
			r247.ReleaseBelt()
			r247.LeaveBelt()
			s30 = s29 and s30

			if s30 then
				local s2_1 = r766 + 4
				s30 = r247.DistanceTo(s1) <= s2_1
			end

			return s30
		end

		local r787 = r3_14

		local function r788(s34)
			if not s34 then
				return 0
			end
			local s1 = tonumber(s34:GetAttribute("Uses"))
			if s1 ~= nil then
				return s1
			end
			local s34_1 = string.match(s34.Name, "%[X(%d+)%]")
			return tonumber(s34_1) or 1
		end

		local function r789()
			local s2 = r787()
			if not s2 then
				return nil, 0
			end
			local s6 = r788(s2)
			if s6 <= 0 then
				return nil, 0
			end
			return s2, s6
		end

		r767.Grip = function(s36)
			local s2 = r232.Character
			local s1 = s2 and s2:FindFirstChildOfClass("Humanoid")
			if not s2 or not s1 or not s36 or s36.Parent == nil then
				return false
			end

			if s36.Parent ~= s2 then
				pcall(function()
					s1:EquipTool(s36)
				end)

				if s36.Parent ~= s2 then
					pcall(function()
						s36.Parent = s2
					end)
				end

				task.wait(0.2)
			end

			return s36.Parent == s2
		end

		local function r790()
			if not r247.Toggle(r767.BuyHandle, false) or r673 then
				return false
			end
			r673 = true
			local s5 = false

			local s3_1, s4 = pcall(function()
				s5 = r767.Purchase()
			end)

			r673 = false

			if not s3_1 then
				r767.Status = "Buy failed: " .. tostring(s4)
			end

			return s5
		end

		r767.Purchase = function()
			local s9 = 0
			local s11 = false

			for s1 = 1, 10 do
				local s2 = s9 == 0 and r682(true) or r659
				local s5 = r683()

				if not (type(s2) ~= "table" or type(s5) ~= "table") then
					local s1_4, s2_1, s3 = ipairs(type(s2.Shop) == "table" and s2.Shop or {})
					local s4_1 = nil

					for _, s3_1 in s1_4, s2_1, s3 do
						if type(s3_1) == "table" and s3_1.Id == "MutationConsumable" then
							s4_1 = s3_1
						end
					end

					if s4_1 then
						local s7_1 = tonumber(s4_1.PurchaseLimit)

						if not (s7_1 and r710(s5, s4_1) >= s7_1) then
							local s12_1 = tonumber(s4_1.Price) or math.huge

							if (tonumber(s5.Samples) or 0) - s12_1 < r657 then
								s11 = true

								if s9 == 0 then
									r767.Status = "Need " .. tostring(math.floor(s12_1)) .. " Samples"
								end

								break
							else
								local s1_7 = r681("Shop", s4_1.Id, { Quote = s4_1.Quote, Sequence = tonumber(s5.ShopSequence) or 0 })

								if not (type(s1_7) ~= "table" or s1_7.Ok ~= true) then
									s9 += 1
									task.wait(0.4)
									continue
								end
							end
						end
					end
				end

				break
			end

			if s9 > 0 then
				r767.Status = string.format("Bought %d Scrambled", s9)
				r767.Short = s11
				return true
			end

			r767.Short = s11
			return false
		end

		local function r792()
			local s5 = 0
			local s7 = 0
			local s9 = -1
			local s10 = nil

			for _, s3 in ipairs(r784()) do
				s5 += 1
				local s12 = r767.SkipMutated and r783(s3)
				local s13 = false

				if s12 then
					s13 = true
				end

				local s12_1 = not s13

				if s12_1 then
					local s15 = r767.MinRarity
					s12_1 = r781(s3) < s15
				end

				if s12_1 then
					s13 = true
				end

				local s12_2 = not s13 and r767.MinIncome > 0

				if s12_2 then
					local s15_1 = r767.MinIncome
					s12_2 = r782(s3) < s15_1
				end

				if s12_2 then
					s13 = true
				end

				if not s13 and next(r767.Targets) ~= nil and r767.Targets[tostring(s3.AssetCategory)] ~= true then
					s13 = true
				end

				if not s13 then
					s7 += 1
					local s12_5

					if r767.Priority == r11_19[2] then
						s12_5 = r781(s3) * 1000 + (tonumber(s3.AssetScale) or 0)
					elseif r767.Priority == r11_19[3] then
						s12_5 = tonumber(s3.AssetScale) or 0
					else
						s12_5 = r782(s3)
					end

					local s13_2 = s12_5 > s9

					if not s13_2 and s10 ~= nil and s12_5 == s9 and s3.Uid == r767.Locked then
						s9 = s12_5
						s10 = s3
					elseif s13_2 then
						s9 = s12_5
						s10 = s3
					end
				end
			end

			local s3_1 = r767
			r767.Pen = s5
			s3_1.Match = s7
			return s10
		end

		local function r793(s31)
			if typeof(s31) ~= "Color3" then
				return "#FFFFFF"
			end
			local s2 = math.floor
			local s3 = s31.B * 255 + 0.5
			return string.format("#%02X%02X%02X", math.floor(s31.R * 255 + 0.5), math.floor(s31.G * 255 + 0.5), s2(s3))
		end

		local function r794(s6)
			local s7, s2 = pcall(Color3.fromHex, s6)
			if not s7 or typeof(s2) ~= "Color3" then
				return s6
			end
			local s7_1, s8_1, s9 = s2:ToHSV()
			return r793(Color3.fromHSV(s7_1, math.min(s8_1, 0.78), math.max(s9, 0.82)))
		end

		local function r795(s21)
			local s1_1 = r780(s21 and s21.AssetCategory)
			local s2 = type(s1_1) == "table" and s1_1.Icon or nil
			if s2 == nil then
				return ""
			end

			if tonumber(s2) then
				return "rbxassetid://" .. tostring(s2)
			end
			return tostring(s2)
		end

		local function r796(s16)
			local s2_1 = r780(s16 and s16.AssetCategory)
			local s3 = type(s2_1) == "table" and s2_1.Rarity or nil
			local s2_2 = type(s3) == "table"
			local s4

			if s2_2 then
				s4 = tostring(s3.DisplayName or s3._id or "")
			else
				s4 = s2_2
			end

			s4 = s4 or ""
			local s2_6 = table.pack(r794(r793(type(s3) == "table" and s3.Color or nil)))
			return s4, table.unpack(s2_6, 1, s2_6.n)
		end

		local function r797(s30)
			if type(s30) ~= "table" then
				return "No egg selected"
			end
			local s1 = r780(s30.AssetCategory)
			local s2 = type(s1) == "table"

			if s2 then
				s2 = tostring(s1.DisplayName or s30.AssetCategory)
			end

			return s2 or tostring(s30.AssetCategory)
		end

		local function r798()
			local s2 = r765[r767.State] or r765.idle

			if r767.Ui.Accent and type(r767.Ui.Accent.Set) == "function" then
				r767.Ui.Accent.Set({ Background = s2 })
			end

			if r767.Ui.Title and type(r767.Ui.Title.Set) == "function" then
				r767.Ui.Title.Set({ Text = r767.Status, Color = s2 })
			end

			if r767.Ui.Egg and type(r767.Ui.Egg.Set) == "function" then
				r767.Ui.Egg.Set({ Text = r767.Detail, Color = r767.RarityColor })
			end

			if r767.Ui.Meta and type(r767.Ui.Meta.Set) == "function" then
				r767.Ui.Meta.Set({
					Text = string.format("Charges %d  Eggs %d/%d  Tries %d  Applied %d", r767.Left, r767.Match, r767.Pen, r767.Tries, r767.Hits),
				})
			end

			if r767.Ui.Icon and type(r767.Ui.Icon.Set) == "function" then
				r767.Ui.Icon.Set({ Visible = r767.Icon ~= "", Image = r767.Icon, StrokeColor = r767.RarityColor })
			end

			if r767.Row and type(r767.Row.Set) == "function" then
				pcall(r767.Row.Set, r767.Row, r767.Status .. "  -  " .. r767.Detail)
			end
		end

		local function r799(s20)
			if type(s20) ~= "table" then
				r767.Detail = "No egg matches the filters"
				r767.RarityColor = "#C7CBD6"
				r767.Icon = ""
				return
			end

			local s18, s19 = r796(s20)
			local s4 = tonumber(s20.AssetScale) or 0
			r767.Detail = string.format("%s   %.2f kg", r797(s20), s4)

			if s18 ~= "" then
				r767.Detail = r767.Detail .. "   " .. string.upper(s18)
			end

			r767.RarityColor = s19
			r767.Icon = r795(s20)
		end

		r767.Apply = function(s16, s17)
			if not r767.Grip(s17) then
				r767.State = "work"
				r767.Status = "Could not hold Scrambled"
				r767.Cooldown = os.clock() + 2
				return false
			end

			local s1 = r181:FindFirstChild("Packages")
			s1 = s1 and s1:FindFirstChild("Networking")
			local s2 = s1 and s1:FindFirstChild("RF/BossMastery/AskUseMutationConsumable")

			if not s2 or not s2:IsA("RemoteFunction") then
				r767.State = "stop"
				r767.Status = "Mutation remote is missing"
				r767.Cooldown = os.clock() + 10
				return false
			end

			r767.State = "work"
			r767.Status = "Applying Scrambled"
			r767.Tries = r767.Tries + 1

			local s18, s19 = pcall(function()
				return s2:InvokeServer(s16.Uid)
			end)

			if not s18 or type(s19) ~= "table" then
				r767.Cooldown = os.clock() + 10
				return false
			end

			if s19.Success == true then
				r767.Status = "Scrambled applied"
				r767.Locked = nil
				r767.State = "good"
				r767.Hits = r767.Hits + 1
				return true
			end

			local s1_4 = tostring(s19.Message or "")
			local s19_1 = string.lower(s1_4)
			r767.Status = s1_4 ~= "" and s1_4 or "Try failed"
			r767.State = "work"

			if string.find(s19_1, "not found") or string.find(s19_1, "invalid") then
				r767.Locked = nil
				r767.Cooldown = os.clock() + 3
				return false
			end

			return true
		end

		r767.Settle = function()
			local s7 = os.clock() + 3

			while os.clock() < s7 do
				if r247.Grounded() then
					return
				end
				r137.Heartbeat:Wait()
			end
		end

		r767.Over = function(arg1)
			if arg1 ~= r767.Loop or not r247.Toggle(r767.Handle, false) then
				return true
			end

			if r247.Movement.PlaceWanted == true then
				return true
			end
			return r247.Movement.ScrambleWanted == true or r247.Steal.Wanted == true
		end

		r767.Idle = function(s4, s5, s6)
			r767.State = "idle"
			r767.Status = s4
			r767.Left = 0
			r767.Detail = s5
			r767.RarityColor = "#C7CBD6"
			r767.Icon = ""
			r767.Cooldown = os.clock() + (s6 or 5)
		end

		local function r800(s33)
			if r247.Movement.ScrambleWanted == true or r247.Steal.Wanted == true then
				r767.State = "work"
				r767.Status = r247.Movement.ScrambleWanted == true and "Drone hunt goes first" or "Auto Steal goes first"
				r767.Cooldown = os.clock() + 2
				return
			end

			local s2 = r767.Cooldown
			if os.clock() < s2 then
				return
			end
			local s2_1, s1_2 = r789()

			if not s2_1 then
				pcall(r792)
				if r790() then
					r767.Cooldown = os.clock() + 0.5
					return
				end

				if r767.Short then
					r767.Idle("Out of Samples, waiting for more", "Hunt drones to earn Samples", 10)
					return
				end

				if not string.find(r767.Status, "Samples", 1, true) then
					r767.Status = "Need a Scrambled consumable"
				end

				r767.Idle(r767.Status, "Buy Scrambled from the event shop", 5)
				return
			end

			r767.Left = s1_2
			local s1_3 = r792()

			if not s1_3 or not s1_3.Uid then
				r767.State = "stop"
				r767.Status = "Waiting"
				r799(nil)
				return
			end

			if r247.Movement.PlaceWanted == true then
				r767.State = "work"
				r767.Status = "Auto Place goes first"
				r767.Cooldown = os.clock() + 2
				return
			end

			if not r247.ClaimMovement("mutation") then
				r767.State = "work"
				r767.Status = "Waiting for " .. tostring(r247.Movement.Owner or "movement")
				r767.Cooldown = os.clock() + 2
				return
			end

			r247.Movement.MutationWanted = true

			local s31, s32 = pcall(function()
				while not r767.Over(s33) do
					local t7, t2 = r789()

					if t7 then
						r767.Left = t2
						local t3 = r792()

						if not t3 or not t3.Uid then
							r767.State = "stop"
							r767.Status = "Waiting"
							r799(nil)
							break
						else
							if t3.Uid ~= r767.Locked then
								r767.Locked = t3.Uid
								r767.Status = "New target picked"
							end

							r799(t3)

							if not r786(t3, s33) then
								r767.State = "work"
								r767.Status = "Could not reach the egg"
								r767.Cooldown = os.clock() + 3
								break
							elseif not r767.Over(s33) then
								if r767.Apply(t3, t7) then
									pcall(r798)
									task.wait(0.35)
									continue
								end
							end
						end
					end

					break
				end
			end)

			if not s31 then
				r767.Status = "Stopped: " .. tostring(s32)
				r767.State = "work"
				r767.Cooldown = os.clock() + 3
			end

			r767.Settle()
			r247.Movement.MutationWanted = false
			r247.ReleaseMovement("mutation")
		end

		r767.Handle = r184:CreateToggle({
			Name = "Auto Use Scrambled Mutation",
			Default = false,
			Callback = function(s37)
				r767.Loop = r767.Loop + 1
				r247.Movement.MutationWanted = false
				r247.ReleaseMovement("mutation")
				if s37 ~= true then
					return
				end
				local s2 = r767.Loop

				task.spawn(function()
					while s2 == r767.Loop and r247.Toggle(r767.Handle, false) do
						pcall(r800, s2)
						pcall(r798)
						task.wait(r767.State == "idle" and 3 or 1)
					end
				end)
			end,
		})

		if type(r184.CreateCanvas) == "function" then
			local r12_18 = r184:CreateCanvas({
				Name = "Scrambled Status",
				ShowTitle = false,
				Layout = "free",
				SubOf = r767.Handle,
				Style = {
					TextScale = 1,
					LineHeight = 1.1,
					MinLines = 4,
					MaxLines = 4,
					AutoHeight = true,
					BackgroundTransparency = 0.35,
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(s23)
					r767.Ui.Card = s23:Frame({
						X = 0,
						Y = 0,
						Width = 1,
						Height = 3.6,
						Corner = 0.3,
						Background = "#151821",
						BackgroundTransparency = 0.25,
					})

					r767.Ui.Accent = s23:Frame({
						Parent = r767.Ui.Card,
						X = 0.08,
						Y = 0.18,
						Width = 0.16,
						Height = 3.24,
						Corner = 0.2,
						Background = r765.idle,
					})

					r767.Ui.Icon = s23:Image({
						Parent = r767.Ui.Card,
						X = 0.42,
						Y = 0.3,
						Width = 3,
						Height = 3,
						Corner = 0.3,
						Background = "#242938",
						BackgroundTransparency = 0.1,
						StrokeThickness = 0.06,
						StrokeTransparency = 0,
						Visible = false,
					})

					r767.Ui.Title = s23:Text({
						Parent = r767.Ui.Card,
						X = 3.7,
						Y = 0.32,
						Width = 1,
						Height = 1.05,
						Scale = 1.16,
						Wrap = false,
						Text = r767.Status,
						Color = r765.idle,
						TextStrokeTransparency = 1,
					})

					r767.Ui.Egg = s23:Text({
						Parent = r767.Ui.Card,
						X = 3.7,
						Y = 1.42,
						Width = 1,
						Height = 1,
						Scale = 1,
						Wrap = false,
						Text = r767.Detail,
						Color = "#FFFFFF",
						TextStrokeTransparency = 1,
					})

					r767.Ui.Meta = s23:Text({
						Parent = r767.Ui.Card,
						X = 3.7,
						Y = 2.42,
						Width = 1,
						Height = 0.9,
						Scale = 0.86,
						Wrap = false,
						Text = "Charges 0  Eggs 0/0  Tries 0  Applied 0",
						Color = "#AEB4C6",
						TextStrokeTransparency = 1,
					})

					r798()
				end,
			})

			r240(function()
				pcall(function()
					r12_18:Destroy()
				end)
			end)
		else
			r767.Row = r184:CreateText({ Name = "Scrambled Status", Text = "Idle", SubOf = r767.Handle })
		end

		r184:CreateDropdown({
			Name = "Mutation Min Rarity",
			Note = "Only eggs of this rarity and above are used",
			Options = r191,
			Default = r191[1],
			SubOf = r767.Handle,
			Callback = function(arg1)
				r767.MinRarity = r264[arg1] or 0
			end,
		})

		local r2_28 = {
			["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
			["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
			["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
		}

		local r3_15 = { Slider = nil, Value = 0, Unit = "M/s" }

		local function r6_18(s2, s3)
			if s2 ~= nil then
				r3_15.Value = math.max(0, math.floor(tonumber(s2) or r3_15.Value))
			end

			if s3 ~= nil then
				r3_15.Unit = tostring(s3)
			end

			r767.MinIncome = r3_15.Value * (r2_28[r3_15.Unit] or r2_28["M/s"]).Mult
		end

		r3_15.Slider = r192(r184, {
			Name = "Min Mutation Value",
			Note = "Skip eggs worth less than this (0 = off)",
			SubOf = r767.Handle,
			Legacy = "Mutation Min Value",
			SectionName = "Dr Scramble Event",
			OnRaw = function(arg1)
				r6_18(math.floor(arg1 / 1000), "K/s")
			end,
		})

		r184:CreateDropdown({
			Name = "Mutation Priority",
			Note = "Which egg gets the consumable first",
			Options = r11_19,
			Default = r11_19[1],
			SubOf = r767.Handle,
			Callback = function(s21)
				r767.Priority = tostring(s21)
			end,
		})

		r243(r184:CreateMultiDropdown({
			Name = "Mutation Target Eggs",
			Note = "Only use the consumable on these eggs (empty = all)",
			Options = r767.EggOptions,
			Default = {},
			SubOf = r767.Handle,
			Callback = function(s4)
				local s5 = {}

				if type(s4) == "table" then
					for s3, s4_1 in pairs(s4) do
						s3 = s4_1 == true and type(s3) == "string" and s3 or type(s4_1) == "string" and s4_1
						local s7_1 = s3 or nil

						if s7_1 and r767.EggCategory[s7_1] then
							s5[r767.EggCategory[s7_1]] = true
						end
					end
				end

				r767.Targets = s5
			end,
		}))

		r767.BuyHandle = r184:CreateToggle({
			Name = "Auto Buy Scrambled",
			Note = "Buy another Scrambled from the event shop when you run out",
			Default = false,
			SubOf = r767.Handle,
			Callback = function()
				r767.Cooldown = 0
			end,
		})

		r240(function()
			r767.Loop = r767.Loop + 1
			r247.Movement.MutationWanted = false
			r247.ReleaseMovement("mutation")
		end)
	end

	do
		local r2_29 = nil
		local r3_16 = false
		local r6_19 = false

		r244.Add(function()
			if not r6_19 and os.clock() - r660 >= r18_4 then
				r6_19 = true

				task.spawn(function()
					pcall(r682, true)
					r6_19 = false
				end)
			end

			local s3 = nil

			if r675 then
				s3 = type(r675.Set) == "function"
			end

			if s3 then
				pcall(r675.Set, nil, r689())
			end

			local s3_1 = nil

			if r755 then
				s3_1 = type(r755.Set) == "function"
			end

			if s3_1 then
				pcall(r755.Set, nil, r756())
			end

			local s2_1 = r685()
			local s3_2 = r247.IsNight()

			if s2_1 and not r3_16 then
				r672.Latch = s3_2
				r672.Ended = false
			end

			if not s3_2 then
				r672.Latch = false
			elseif s2_1 and not r672.Latch and not r672.Ended then
				r672.Ended = true
				r664 = "Night arrived, this outbreak is over"
				table.clear(r655)
				table.clear(r656)
			end

			if not s2_1 then
				r672.Ended = false
			end

			if r3_16 and not s2_1 then
				task.delay(15, function()
					if not r685() then
						table.clear(r655)
						table.clear(r16_6)
					end
				end)
			end

			r3_16 = s2_1

			if r247.Toggle(nil, false) and not r673 and os.clock() >= r674 and r684() then
				r673 = true
				r674 = os.clock() + 8

				task.spawn(function()
					pcall(r711, function()
						return not r247.Toggle(nil, false)
					end)

					r673 = false
				end)
			end

			local s11 = r760()
			local s13 = r761()
			r247.Movement.ScrambleWanted = s11 or s13
			local s3_3 = r247.InvisibilityHandle
			local s2_4 = s3_3 ~= nil and r247.Toggle(s3_3, false)

			if s11 then
				r2_29 = nil

				if not r247.InvisSuspended then
					r247.InvisSuspended = true
					s2_4 = s2_4 and type(r179.Notify) == "function"

					if s2_4 then
						pcall(r179.Notify, "Invisibility", "Invisibility is paused for the drone hunt and comes back after it.", 5)
					end
				end
			elseif r247.InvisSuspended and not r661 then
				r2_29 = r2_29 or os.clock() + 5

				if r2_29 <= os.clock() then
					r2_29 = nil
					r247.InvisSuspended = false

					if s2_4 and type(r179.Notify) == "function" then
						pcall(r179.Notify, "Invisibility", "The drone hunt is over, Invisibility is back on.", 5)
					end
				end
			end

			local s3_5 = r232.Character
			if s11 and not r661 and s3_5 and s3_5:GetAttribute("InvisApplied") == true then
				r664 = "Leaving Invisibility for the hunt"
				return true
			end

			if r661 then
				return s11
			end

			if not (s11 or s13) or os.clock() < r663 then
				if not s11 and not s13 then
					r664 = ""
				end

				return false
			end

			local s2_7 = r247.Steal
			if s2_7.Active or s2_7.Carrying or s2_7.Wanted then
				r664 = "Auto Steal goes first"
				return s11
			end

			if not r247.ClaimMovement("scramble") then
				r664 = "Waiting for " .. tostring(r247.Movement.Owner or "movement") .. " to finish"
				return s11
			end
			r661 = true
			r663 = os.clock() + r19_4
			local s2_8 = r662

			task.spawn(function()
				pcall(r763, function()
					return s2_8 ~= r662
				end)

				r247.HoldBelt()
				pcall(r762, s2_8)
				r736()
				r247.ReleaseBelt()
				r247.ReleaseMovement("scramble")
				r661 = false
				r244.Wake()
			end)

			return s11
		end)
	end

	r240(function()
		r662 += 1
		r736()
		r247.InvisSuspended = false
		r247.Movement.ScrambleWanted = false
		r247.ReleaseMovement("scramble")
	end)

	local r189_1, r171

	do
		local r172 = r180:CreateTab({ Name = "Player", SectionsExpanded = true })
		r247.EspSection = r172:CreateSection({ Name = "ESP", Expanded = false })
		local r169 = r172:CreateSection({ Name = "Movement", Expanded = true })
		r189_1 = r172:CreateSection({ Name = "Character", Expanded = true })
		r171 = r172:CreateSection({ Name = "Combat", Expanded = true })
		local r166 = nil
		local r2_30 = 350
		local r3_17 = nil
		local r5_19 = false

		local function r6_20()
			local s8 = r232.Character
			local s10 = s8 and s8:FindFirstChild("HumanoidRootPart")
			s8 = s8 and s8:FindFirstChildOfClass("Humanoid")
			if s10 and s8 and s8.Health > 0 then
				return s10, s8
			end
			return nil, nil
		end

		local function r10_11()
			if not r5_19 then
				return
			end
			r5_19 = false
			local s10, s8 = r6_20()
			if not s10 then
				return
			end
			local s12 = s10.AssemblyLinearVelocity
			local s5 = s8.MoveDirection
			local s3 = Vector3.new(s5.X, 0, s5.Z)
			local s3_1 = s3.Magnitude > 0.001 and s3.Unit * s8.WalkSpeed or Vector3.zero

			pcall(function()
				s10.AssemblyLinearVelocity = Vector3.new(s3_1.X, s12.Y, s3_1.Z)
			end)
		end

		local function r11_20()
			if r3_17 then
				r3_17:Disconnect()
				r3_17 = nil
			end

			r10_11()
			r247.Shield("speed", false)
		end

		local function r12_19()
			if r3_17 then
				return
			end
			r247.Shield("speed", true)

			r3_17 = r137.Heartbeat:Connect(function()
				if r247.Steal.Active or r247.Flying or r247.Driving > 0 or r247.Treadmill.Riding then
					r5_19 = false
					return
				end
				local t9, t7 = r6_20()
				if not t9 or t7.Sit or t7.PlatformStand then
					r5_19 = false
					return
				end
				local t2_2 = tonumber(r232:GetAttribute("RagdollEndTime"))
				if t2_2 and t2_2 > workspace:GetServerTimeNow() then
					r5_19 = false
					return
				end
				local t4 = t7.MoveDirection
				local t2_3 = Vector3.new(t4.X, 0, t4.Z)
				if t2_3.Magnitude <= 0.001 then
					r10_11()
					return
				end
				local t2_4 = t2_3.Unit * r2_30
				local t3_1 = t9.AssemblyLinearVelocity

				pcall(function()
					t9.AssemblyLinearVelocity = Vector3.new(t2_4.X, t3_1.Y, t2_4.Z)
				end)

				r5_19 = true
			end)
		end

		r247.SpeedForced = false

		local function r810()
			if r247.Toggle(r166, false) or r247.SpeedForced then
				r12_19()
			else
				r11_20()
			end
		end

		local r811 = false
		local r812 = false
		local r813 = false

		r247.SetSpeedForced = function(arg1)
			r247.SpeedForced = arg1 == true
			r811 = true
			r810()
		end

		local r1_33 = {
			Name = "Speed Boost",
			Default = false,
			Callback = function()
				if r247.SpeedForced and not r247.Toggle(r166, false) then
					r811 = true
					r813 = true
				end

				r810()
			end,
		}

		r166 = r169.CreateToggle
		r166 = r166(r169, r1_33)

		local r153_15 = r137.Heartbeat:Connect(function()
			if r813 then
				r813 = false

				if type(r179.Notify) == "function" then
					pcall(r179.Notify, "Speed Boost", "Speed Boost must stay on while Invisibility is on.", 5)
				end
			end

			if not r811 then
				return
			end
			r811 = false
			local s8

			if r247.SpeedForced and not r247.Toggle(r166, false) then
				r812 = true
				s8 = true
			else
				local s2_1 = not r247.SpeedForced and r812
				s8 = nil

				if s2_1 then
					r812 = false
					s8 = nil

					if r247.Toggle(r166, false) then
						s8 = false
					end
				end
			end

			if s8 ~= nil then
				for _, s4 in ipairs({ "Set", "SetValue" }) do
					local s5, s6 = pcall(function()
						return r166[s4]
					end)

					if not (s5 and type(s6) == "function" and pcall(s6, r166, s8)) then
						continue
					end
					break
				end
			end
		end)

		r240(function()
			r153_15:Disconnect()
		end)

		r169:CreateSlider({
			Name = "Boost Speed",
			Min = 20,
			Max = 1000,
			Default = 350,
			Increment = 5,
			Unit = "studs/s",
			Callback = function(s21)
				r2_30 = math.clamp(tonumber(s21) or 350, 20, 1000)
			end,
		})

		r240(r11_20)
		local r1_34 = nil
		local r824 = nil

		local function r825()
			if r824 then
				r824:Disconnect()
				r824 = nil
			end

			r247.Shield("jump", false)
		end

		r1_34 = r169:CreateToggle({
			Name = "Infinite Jump",
			Default = false,
			Callback = function()
				if not r247.Toggle(r1_34, false) then
					r825()
					return
				end

				if r824 then
					return
				end
				r247.Shield("jump", true)

				r824 = r139.JumpRequest:Connect(function()
					local t6 = r232.Character
					local t5 = t6 and t6:FindFirstChildOfClass("Humanoid")

					if t5 then
						pcall(function()
							t5:ChangeState(Enum.HumanoidStateType.Jumping)
						end)
					end
				end)
			end,
		})

		r240(r825)
	end

	do
		local r5_20 = nil
		local r6_21 = false
		local r10_12 = true
		local r11_21 = false
		local r12_20 = false
		local r13_7 = false
		local r14_9 = nil
		local r15_8 = nil
		local r829 = 999

		local function r830()
			return r6_21 and not r247.InvisSuspended
		end

		local function r831(s34)
			return s34 and s34:FindFirstChildOfClass("Humanoid") or nil
		end

		local function r832(s12)
			return r182:FindFirstChild(s12)
		end

		local function r833(s17)
			return s17 ~= nil and s17:GetAttribute("InvisApplied") == true
		end

		local function r834()
			local s10 = r832("RF/Treadmill/AskDoff")

			if s10 and s10:IsA("RemoteFunction") then
				for s5_1 = 1, 2 do
					pcall(s10.InvokeServer, s10)
				end
			end
		end

		local function r835(s18)
			local s2 = r832("RE/RigSync/AskRigWipe")

			if s2 and s2:IsA("RemoteEvent") then
				pcall(s2.FireServer, s2, s18)
			end
		end

		local function r836(s30)
			local s31 = r232:FindFirstChildOfClass("Backpack")

			for _, s3 in ipairs(s30:GetChildren()) do
				if s3:IsA("Humanoid") then
					pcall(s3.UnequipTools, s3)
				end
			end

			if s31 then
				for _, s6 in ipairs(s30:GetChildren()) do
					if s6:IsA("Tool") then
						pcall(function()
							s6.Parent = s31
						end)
					end
				end
			end

			for s1 = 1, 3 do
				r137.Heartbeat:Wait()
			end
		end

		local function r837(s19)
			local s1 = r831(s19)
			if not s19 or not s1 then
				return false
			end
			r836(s19)
			r834()

			pcall(function()
				s1:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				s1.BreakJointsOnDeath = true
				s1.RequiresNeck = true
				s1.Health = 0
			end)

			pcall(function()
				s1:ChangeState(Enum.HumanoidStateType.Dead)
			end)

			pcall(function()
				s19:BreakJoints()
			end)

			r835(s19)
			return true
		end

		local function r838(s29)
			local s9 = r831(s29)
			local s4 = os.clock() + 10

			while true do
				if os.clock() < s4 and r10_12 and s29.Parent then
					s9 = s9 or r831(s29)
					if not (s9 and s29:FindFirstChild("HumanoidRootPart") and s29:FindFirstChild("Head")) then
						task.wait()
						continue
					end
				end

				break
			end

			local s5 = s29:FindFirstChild("HumanoidRootPart")
			if not r830() or not s9 or not s5 or not s29:FindFirstChild("Head") then
				return false
			end
			task.wait(0.05)
			if not r830() or s29.Parent == nil then
				return false
			end

			for s2_4 = 1, 2 do
				pcall(s9.UnequipTools, s9)
			end

			if type(replicatesignal) == "function" then
				for s2_6 = 1, 2 do
					pcall(replicatesignal, s9.ServerBreakJoints)
				end
			end

			local s10 = s9.HipHeight

			pcall(function()
				s9.HipHeight = r829
			end)

			for _, s4_1 in ipairs(s29:GetChildren()) do
				if s4_1:IsA("Accessory") or s4_1:IsA("BasePart") and s4_1 ~= s5 then
					pcall(function()
						s4_1.Parent = nil
					end)
				end
			end

			task.wait(0.12)

			local function s2_5()
				pcall(function()
					s9.HipHeight = s10
				end)

				for _, t6 in ipairs(s29:GetChildren()) do
					if t6:IsA("Humanoid") and t6.HipHeight ~= s10 then
						pcall(function()
							t6.HipHeight = s10
						end)
					end
				end
			end

			if s29.Parent == nil then
				s2_5()
				return false
			end
			local s3_3 = Instance.new("Motor6D")
			s3_3.Name = "RightWrist"
			s3_3.C0 = CFrame.new(1.2, 0, 0)
			s3_3.C1 = CFrame.new()
			s3_3.Part0 = s5
			s3_3.Parent = s5
			local s4_2 = Instance.new("Part")
			s4_2.Name = "RightHand"
			s4_2.Size = Vector3.new(0.2, 0.2, 0.2)
			s4_2.Transparency = 1
			s4_2.CanCollide = false
			s4_2.CanTouch = false
			s4_2.CanQuery = false
			s4_2.Massless = true
			s4_2.CFrame = s5.CFrame * s3_3.C0
			s3_3.Part1 = s4_2
			s4_2.Parent = s29

			pcall(function()
				s5.CanCollide = false
			end)

			s2_5()
			s29:SetAttribute("InvisApplied", true)

			task.delay(1, function()
				local t2_1 = (typeof(getgenv) == "function" and getgenv() or _G).ChilliToolKeeper

				if s29.Parent and type(t2_1) == "function" then
					pcall(t2_1)
				end
			end)

			task.delay(0.2, function()
				if s5.Parent then
					pcall(function()
						s5.CanCollide = true
					end)
				end
			end)

			local s3_4 = s29.ChildAdded:Connect(function(t19)
				if t19:IsA("Humanoid") then
					task.defer(function()
						if t19.HipHeight ~= s10 then
							pcall(function()
								t19.HipHeight = s10
							end)
						end
					end)
				end
			end)

			local s4_3 = nil

			s4_3 = s29.AncestryChanged:Connect(function(arg1, arg2)
				if arg2 == nil then
					s3_4:Disconnect()
					s4_3:Disconnect()
				end
			end)

			return true
		end

		local function r839()
			local s4 = r247.Steal.Active or r247.Steal.Carrying or r247.Flying
			local s6_1

			if s4 then
				s6_1 = s4
			else
				s6_1 = (r247.Driving or 0) > 0
			end

			return s6_1
		end

		r247.RequestRespawn = function()
			r13_7 = true
		end

		local function r840()
			r11_21 = true
			local s2 = r13_7

			while r10_12 and (r839() or not r247.ClaimMovement("invisibility")) do
				task.wait(0.2)
			end

			local s4 = r232.Character

			if r10_12 and s4 and (s2 or r833(s4) ~= r830()) and r831(s4) then
				r13_7 = false
				r245.Paused = true
				r247.ShieldPaused = true
				pcall(r247.UndoSwap)
				task.wait()
				r837(r232.Character)
				local s2_1 = os.clock() + 60
				local s6_1 = os.clock() + 8

				while r10_12 and os.clock() < s2_1 and r232.Character == s4 do
					if os.clock() >= s6_1 then
						s6_1 = os.clock() + 8
						r835(s4)
					end

					task.wait(0.05)
				end

				task.wait(0.1)

				while r10_12 and r12_20 do
					task.wait(0.05)
				end
			end

			r245.Paused = false
			r247.ShieldPaused = false
			r247.ReleaseMovement("invisibility")
			r11_21 = false
		end

		local r153_16 = r232.CharacterAdded:Connect(function(s23)
			if not r830() then
				return
			end
			r12_20 = true
			r247.ShieldPaused = true

			task.spawn(function()
				pcall(r838, s23)
				r12_20 = false

				if not r11_21 then
					r247.ShieldPaused = false
				end
			end)
		end)

		local r841 = task.spawn(function()
			while r10_12 do
				local s3 = r232.Character
				local s5 = r831(s3)

				if not r11_21 and not r12_20 and s3 and s5 and s5.Health > 0 and (r13_7 or r833(s3) ~= r830()) then
					r840()
				end

				local s3_1 = r833(r232.Character)

				if s3_1 ~= r14_9 then
					r14_9 = s3_1
					r247.SetSpeedForced(s3_1)
				end

				task.wait(0.25)
			end
		end)

		local r154_6 = r137.Heartbeat:Connect(function()
			local s3 = r232.Character
			if not s3 or not r833(s3) then
				return
			end
			local s10 = s3:FindFirstChild("RightHand")
			local s2_1 = s3:FindFirstChildWhichIsA("Tool")
			local s6 = s2_1 and s2_1:FindFirstChild("Handle")
			if not s10 or not s6 or not s6:IsA("BasePart") then
				return
			end
			local s7 = CFrame.new()

			for _, s4_1 in ipairs(s10:GetChildren()) do
				if s4_1:IsA("JointInstance") and s4_1.Name == "RightGrip" and s4_1.Part1 == s6 then
					s7 = s4_1.C0 * s4_1.C1:Inverse()

					if s4_1.Enabled then
						s4_1.Enabled = false
					end
				end
			end

			pcall(function()
				s6.CFrame = s10.CFrame * s7
				s6.AssemblyLinearVelocity = Vector3.zero
				s6.AssemblyAngularVelocity = Vector3.zero
			end)
		end)

		r240(function()
			r154_6:Disconnect()
		end)

		local r155 = r137.Heartbeat:Connect(function()
			local s7 = r232.Character
			local s10 = r831(s7)
			local s12 = s7 and s7:FindFirstChild("HumanoidRootPart")
			if not s10 or not s12 or s10.Health <= 0 then
				return
			end
			local s3 = r833(s7) and not r247.Steal.Active and not r247.Flying
			local s2_2

			if s3 then
				s2_2 = (r247.Driving or 0) == 0
			else
				s2_2 = s3
			end

			if s2_2 then
				s2_2 = not (r247.Treadmill and r247.Treadmill.Riding)
			end

			if not (s2_2 and not s10.Sit and not s10.PlatformStand) then
				if r15_8 == s10 then
					r15_8 = nil

					pcall(function()
						s10.AutoRotate = true
					end)
				end

				return
			end

			if s10.AutoRotate then
				pcall(function()
					s10.AutoRotate = false
				end)
			end

			r15_8 = s10
			local s4 = s10.MoveDirection
			local s2_3 = Vector3.new(s4.X, 0, s4.Z)

			if s2_3.Magnitude > 0.01 then
				pcall(function()
					s12.CFrame = CFrame.lookAt(s12.Position, s12.Position + s2_3.Unit)
				end)
			end
		end)

		r247.InvisibilityHandle = r189_1:CreateToggle({
			Name = "Invisibility",
			Note = "Makes you invisible to other players",
			Default = false,
			Callback = function()
				local s6 = nil

				if type(r247.CombatActive) == "function" and r247.CombatActive() then
					s6 = "Auto Hit"
				end

				if r247.Toggle(r5_20, false) and s6 then
					r6_21 = false
					local s9 = r5_20

					r247.UiDefer(function()
						pcall(s9.Set, s9, false, false)
						r247.Notify("Invisibility", "Turn off " .. s6 .. " first, both cannot be on at the same time")
					end)

					return
				end

				r6_21 = r247.Toggle(r5_20, false) == true

				if r830() and not r833(r232.Character) and r247.Movement.Owner == nil then
					r247.Movement.Owner = "invisibility"
				end
			end,
		})

		r240(function()
			r10_12 = false
			r153_16:Disconnect()
			r155:Disconnect()
			pcall(task.cancel, r841)
			r245.Paused = false
			r247.ShieldPaused = false
			r247.ReleaseMovement("invisibility")
		end)
	end

	do
		local r5_21 = { BallSocketConstraint = true, NoCollisionConstraint = true, HingeConstraint = true }

		local r6_22 = {
			[Enum.HumanoidStateType.Physics] = true,
			[Enum.HumanoidStateType.Ragdoll] = true,
			[Enum.HumanoidStateType.FallingDown] = true,
		}

		local r10_13 = 0.5
		local r11_22 = 5
		local r12_21 = 0

		local r13_8 = r233(function()
			return r181.Shared.Modules.Ragdoll
		end)

		local r14_10 = nil

		local function r15_9()
			if r14_10 then
				return r14_10
			end

			local s2, s3 = pcall(function()
				return require(r232:WaitForChild("PlayerScripts", 5):WaitForChild("PlayerModule", 5)):GetControls()
			end)

			if s2 then
				r14_10 = s3
			end

			return r14_10
		end

		local r1_35 = nil
		local r841_1 = false
		local r842 = nil
		local r843 = 0
		local r844 = nil
		local r845 = {}
		local r846 = {}
		local r847 = 0
		local r848 = nil
		local r849 = nil

		local function r850(s26)
			for _, s3 in ipairs(s26) do
				if s3.Connected then
					s3:Disconnect()
				end
			end

			table.clear(s26)
		end

		local function r851(arg1)
			r845[#r845 + 1] = arg1
		end

		local function r852(arg1)
			r846[#r846 + 1] = arg1
		end

		local function r853()
			if not r848 or not r849 then
				return
			end
			local s5_1 = r848:FindFirstChild("HumanoidRootPart")
			if not s5_1 then
				return
			end
			local s11 = s5_1.AssemblyLinearVelocity
			local s6 = Vector3.new(s11.X, 0, s11.Z)
			local s7 = r849.WalkSpeed + r11_22
			local s8 = s11.Y
			local s11_1 = false

			if s6.Magnitude > s7 then
				s6 = s6.Unit * s7
				s11_1 = true
			end

			if r12_21 < s8 then
				s8 = r12_21
				s11_1 = true
			end

			if s11_1 then
				pcall(function()
					s5_1.AssemblyLinearVelocity = Vector3.new(s6.X, s8, s6.Z)
				end)
			end
		end

		local function r854()
			if type(r13_8) ~= "table" then
				return
			end

			if type(r13_8.ClearClientRagdoll) == "function" then
				pcall(r13_8.ClearClientRagdoll)
			end

			if type(r13_8.Unragdoll) == "function" then
				pcall(r13_8.Unragdoll, r848)
			end
		end

		local function r855()
			if not r848 or not r848.Parent then
				return
			end

			for _, s4 in ipairs(r848:GetDescendants()) do
				if r5_21[s4.ClassName] then
					pcall(function()
						s4:Destroy()
					end)
				end
			end
		end

		local function r856()
			if not r848 or not r848.Parent then
				return
			end

			for _, s6 in ipairs(r848:GetDescendants()) do
				if s6:IsA("Motor6D") and not s6.Enabled then
					pcall(function()
						s6.Enabled = true
					end)
				elseif s6:IsA("AnimationConstraint") and not s6.Enabled then
					pcall(function()
						s6.Enabled = true
					end)
				end
			end
		end

		local function r857()
			local s4 = r15_9()

			if s4 and s4.controlsEnabled == false then
				pcall(function()
					s4:Enable()
				end)
			end
		end

		local function r858()
			local s2 = workspace.CurrentCamera

			if s2 and r849 and s2.CameraSubject ~= r849 then
				pcall(function()
					s2.CameraSubject = r849
				end)
			end
		end

		local function r859()
			if not r849 or not r849.Parent or r849.Health <= 0 then
				return
			end

			if r6_22[r849:GetState()] then
				pcall(function()
					r849:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end

			if r849.PlatformStand then
				r849.PlatformStand = false
			end
		end

		local function r860()
			if type(r13_8) == "table" and type(r13_8.IsRagdolled) == "function" then
				local s2_1, s3 = pcall(r13_8.IsRagdolled, r848)
				if s2_1 and s3 == true then
					return true
				end
			end

			local s2_2 = tonumber(r232:GetAttribute("RagdollEndTime"))
			return s2_2 ~= nil and s2_2 > workspace:GetServerTimeNow()
		end

		local r861 = 21

		local function r862()
			if r247.AntiGuard.Busy == true then
				return true
			end

			if (tonumber(r247.AntiGuard.HitArms) or 0) <= 0 then
				return false
			end
			return os.clock() - (tonumber(r247.AntiGuard.HitArmedAt) or 0) <= r861
		end

		local function r863()
			if not r849 or not r849.Parent then
				return false
			end

			if r849.PlatformStand then
				return true
			end
			return r6_22[r849:GetState()] == true
		end

		local function r864()
			if not r848 or not r848.Parent then
				return false
			end

			for _, s4 in ipairs(r848:GetChildren()) do
				if r5_21[s4.ClassName] then
					return true
				end

				if s4:IsA("BasePart") then
					for _, s8 in ipairs(s4:GetChildren()) do
						if r5_21[s8.ClassName] then
							return true
						end
					end
				end
			end

			return false
		end

		local function r865()
			r853()
			r854()
			r855()
			r856()
			r859()
			r857()
			r858()
		end

		local function r866()
			if not r841_1 or r862() then
				return
			end
			r843 = os.clock() + r10_13
		end

		local function r867()
			local s9 = r232.Character

			if s9 ~= r848 then
				if s9 then
					r844(s9)
				else
					r847 += 1
					r850(r846)
					r848 = nil
					r849 = nil
				end

				return
			end

			if not r848 then
				return
			end

			if r848:FindFirstChildOfClass("Humanoid") ~= r849 then
				r844(r848)
			end
		end

		local function r868()
			if not r841_1 then
				return
			end
			r867()
			if not r848 or not r849 or r849.Health <= 0 then
				return
			end

			if r862() then
				r843 = 0
				return
			end
			local s2_1 = os.clock()

			if r863() or r860() or r864() then
				r843 = s2_1 + r10_13
			end

			if s2_1 <= r843 then
				r865()
			end
		end

		r844 = function(s17)
			r847 += 1
			local s3 = r847
			r850(r846)
			r848 = s17
			r849 = nil
			if not r841_1 or not s17 then
				return
			end
			r849 = s17:FindFirstChildOfClass("Humanoid")
			if not r841_1 or r847 ~= s3 or s17 ~= r232.Character or not r849 or not r849:IsA("Humanoid") then
				return
			end

			r852(r849.StateChanged:Connect(function(arg1, arg2)
				if r841_1 and r6_22[arg2] then
					r866()
				end
			end))

			r852(r849:GetPropertyChangedSignal("PlatformStand"):Connect(function()
				if r841_1 and r849 and r849.PlatformStand then
					r866()
				end
			end))

			r852(s17.DescendantAdded:Connect(function(arg1)
				if r841_1 and r5_21[arg1.ClassName] then
					r866()
				end
			end))

			r852(s17.ChildAdded:Connect(function(t31)
				if r841_1 and t31:IsA("Humanoid") and t31 ~= r849 then
					task.defer(r867)
				end
			end))

			r858()

			if r860() then
				r866()
			end
		end

		local function r869()
			r841_1 = false
			r847 += 1
			r843 = 0

			if r842 then
				pcall(function()
					r842:Disconnect()
				end)

				r842 = nil
			end

			r850(r846)
			r850(r845)
			r848 = nil
			r849 = nil
		end

		local function r870()
			r869()
			r841_1 = true
			r15_9()
			r842 = r137.Heartbeat:Connect(r868)

			r851(r232.CharacterAdded:Connect(function(t18)
				if r841_1 then
					task.defer(function()
						if r841_1 and t18 == r232.Character then
							r844(t18)
						end
					end)
				end
			end))

			r851(r232.CharacterRemoving:Connect(function(arg1)
				if r841_1 and arg1 == r848 then
					r847 += 1
					r843 = 0
					r850(r846)
					r848 = nil
					r849 = nil
				end
			end))

			r851(r232:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
				if r841_1 then
					r866()
				end
			end))

			local s7 = type(r13_8) == "table" and r13_8.ClientRagdollRemote or nil

			if typeof(s7) == "Instance" and s7:IsA("RemoteEvent") then
				r851(s7.OnClientEvent:Connect(function()
					if r841_1 and not r862() then
						r853()
						r866()
					end
				end))
			end

			r851(r247.OnHumanoidChanged(function()
				if r841_1 and r232.Character then
					r844(r232.Character)
				end
			end))

			if r232.Character then
				r844(r232.Character)
			end
		end

		r240(r869)

		local r3_18 = {
			Name = "Anti Ragdoll",
			Default = true,
			Callback = function()
				if r247.Toggle(r1_35, false) then
					r870()
				else
					r869()
				end
			end,
		}

		r1_35 = r189_1.CreateToggle
		r1_35 = r1_35(r189_1, r3_18)
	end

	do
		local r2_31 = false
		local r3_19 = {}

		local function r5_22()
			for _, s4 in ipairs(r3_19) do
				pcall(function()
					s4:Disconnect()
				end)
			end

			table.clear(r3_19)
		end

		local function r6_23(s36)
			if r2_31 and s36.Parent and s36.Health > 0 and s36.Health < s36.MaxHealth then
				pcall(function()
					s36.Health = s36.MaxHealth
				end)
			end
		end

		local function r10_14(s12)
			r5_22()
			if not r2_31 or not s12 then
				return
			end
			local s2 = s12:FindFirstChildOfClass("Humanoid") or s12:WaitForChild("Humanoid", 5)
			if not r2_31 or not s2 or not s2:IsA("Humanoid") or s12 ~= r232.Character then
				return
			end

			table.insert(r3_19, s2.HealthChanged:Connect(function()
				r6_23(s2)
			end))

			table.insert(r3_19, r137.Heartbeat:Connect(function()
				r6_23(s2)
			end))

			r6_23(s2)
		end

		local r155_1 = r232.CharacterAdded:Connect(function(s28)
			if r2_31 then
				task.defer(r10_14, s28)
			end
		end)

		local r1_36 = r247.OnHumanoidChanged(function()
			if r2_31 and r232.Character then
				r10_14(r232.Character)
			end
		end)

		r240(function()
			r2_31 = false
			r155_1:Disconnect()
			r1_36:Disconnect()
			r5_22()
		end)

		r2_31 = true

		if r232.Character then
			task.spawn(r10_14, r232.Character)
		end
	end

	do
		local r5_23 = nil
		local r10_15 = true
		local r11_23 = {}
		local r12_22 = {}

		local function r13_9(s7)
			if s7:IsA("BasePart") and r11_23[s7] == nil then
				r11_23[s7] = s7.CanTouch

				pcall(function()
					s7.CanTouch = false
				end)
			end
		end

		local function r14_11(s18)
			if not r10_15 or not s18.Parent then
				return
			end
			local s1_1 = r232.Name
			if s18:GetAttribute("Owner") == s1_1 then
				return
			end
			r13_9(s18)

			for _, s3 in ipairs(s18:GetDescendants()) do
				r13_9(s3)
			end

			table.insert(r12_22, s18.DescendantAdded:Connect(function(t36)
				if r10_15 then
					r13_9(t36)
				end
			end))
		end

		local function r15_10()
			for _, s4 in ipairs(r145:GetTagged("PlacedTrap")) do
				r14_11(s4)
			end
		end

		local function r871()
			for s3, s4 in pairs(r11_23) do
				if s3.Parent then
					pcall(function()
						s3.CanTouch = s4
					end)
				end
			end

			table.clear(r11_23)
		end

		table.insert(r12_22, r145:GetInstanceAddedSignal("PlacedTrap"):Connect(function(s26)
			task.defer(r14_11, s26)
		end))

		r5_23 = r189_1:CreateToggle({
			Name = "Anti Trap",
			Note = "Traps from other players cannot catch you",
			Default = true,
			Callback = function()
				r10_15 = r247.Toggle(r5_23, true) == true

				if r10_15 then
					r15_10()
				else
					r871()
				end
			end,
		})

		r15_10()

		r240(function()
			r10_15 = false

			for _, s4 in ipairs(r12_22) do
				pcall(function()
					s4:Disconnect()
				end)
			end

			table.clear(r12_22)
			r871()
		end)
	end

	do
		local r3_20 = nil
		local r1_37 = "CarryAreaEgg"
		local r2_32 = { ClaimLostPart = true }
		local r5_24 = {}
		local r6_24 = nil
		local r10_16 = nil

		local function r11_24(s9)
			if not s9:IsA("ProximityPrompt") or r2_32[s9.Name] then
				return
			end

			if r5_24[s9] == nil then
				if s9.HoldDuration <= 0 and s9.Name ~= r1_37 then
					return
				end
				r5_24[s9] = s9.HoldDuration
			end

			if s9.HoldDuration ~= 0 then
				pcall(function()
					s9.HoldDuration = 0
				end)
			end
		end

		local function r12_23(s2)
			if s2.Name ~= "SmartPromptPart" then
				return nil
			end
			local s10 = s2:FindFirstChild("CarryAreaEgg")
			return s10 and s10:IsA("ProximityPrompt") and s10 or nil
		end

		r247.PromptHold = function(s34)
			local s2 = r5_24[s34]
			if type(s2) == "number" then
				return s2
			end
			return s34.HoldDuration
		end

		local function r872()
			if r6_24 then
				return
			end

			r10_16 = r146.PromptShown:Connect(function(t16)
				if r247.Toggle(r3_20, true) then
					r11_24(t16)
				end
			end)

			for _, s7 in ipairs(workspace:GetChildren()) do
				local s8 = r12_23(s7)

				if s8 then
					r11_24(s8)
				end
			end

			r6_24 = workspace.ChildAdded:Connect(function(t15)
				if t15.Name ~= "SmartPromptPart" then
					return
				end

				task.defer(function()
					local u11 = t15:FindFirstChild("CarryAreaEgg") or t15:WaitForChild("CarryAreaEgg", 2)

					if u11 and u11:IsA("ProximityPrompt") and r247.Toggle(r3_20, true) then
						r11_24(u11)
					end
				end)
			end)
		end

		local function r873()
			for s5, s6 in pairs(r5_24) do
				if s5 and s5.Parent then
					pcall(function()
						s5.HoldDuration = s6
					end)
				end
			end

			table.clear(r5_24)

			if r6_24 then
				r6_24:Disconnect()
				r6_24 = nil
			end

			if r10_16 then
				r10_16:Disconnect()
				r10_16 = nil
			end
		end

		r247.PressStealPrompt = function(s36)
			if typeof(fireproximityprompt) ~= "function" or not s36 then
				return false
			end
			local s6 = nil
			local s7 = math.huge

			for _, s4 in ipairs(workspace:GetChildren()) do
				local s8 = r12_23(s4)

				if s8 and s4:IsA("BasePart") then
					local s5 = (s4.Position - s36).Magnitude

					if s5 < s7 then
						s6 = s8
						s7 = s5
					end
				end
			end

			if not s6 or s7 > 14 then
				return false
			end

			if r247.Toggle(r3_20, true) then
				pcall(function()
					s6.HoldDuration = 0
				end)
			end

			local s36_1 = pcall(fireproximityprompt, s6)

			if s36_1 and s6.HoldDuration > 0 then
				task.wait(s6.HoldDuration + 0.1)
			end

			return s36_1
		end

		r244.Add(function()
			if r247.Toggle(r3_20, true) then
				r872()

				for s3 in pairs(r5_24) do
					if not s3.Parent then
						r5_24[s3] = nil
					elseif s3.HoldDuration ~= 0 then
						pcall(function()
							s3.HoldDuration = 0
						end)
					end
				end
			elseif next(r5_24) ~= nil or r6_24 then
				r873()
			end

			return false
		end)

		r3_20 = r189_1:CreateToggle({
			Name = "Instant Prompts",
			Default = true,
			Callback = function()
				r244.Wake()
			end,
		})

		r240(r873)
	end

	r247.Combat = {}

	do
		local r5_25 = r247.Combat
		local r6_25 = 15
		local r17_7 = 2
		local r879 = 0.05
		local r881 = 1
		local r882 = 0.18
		local r883 = -0.275
		local r884 = 0.6
		local r885 = 6
		local r887 = 1.1
		local r888 = 0.8
		local r889 = 2.5
		local r893 = 35
		local r894 = 0.12
		local r895 = 6
		local r896 = 6
		local r897 = 3
		local r10_17 = { 0.12, 0.2, 0.28, 0.36, 0.46, 0.6 }
		local r11_25 = { ["WALL LEFT"] = true, ["WALL RIGHT"] = true }

		local r12_24 = {
			Trigger = nil,
			LastFire = 0,
			Trace = 0,
			EquipAt = 0,
			Walls = {},
			WallsAt = 0,
			WallSide = setmetatable({}, { __mode = "k" }),
			Tracks = setmetatable({}, { __mode = "k" }),
			Stats = {},
			Option = 3,
			Pending = {},
			Holders = {},
			SpawnRagdoll = nil,
		}

		for r1_38 = 1, #r10_17 do
			r12_24.Stats[r1_38] = { Hits = 0, Shots = 0 }
		end

		local r901 = RaycastParams.new()
		r901.FilterType = Enum.RaycastFilterType.Exclude

		pcall(function()
			r901.RespectCanCollide = true
		end)

		local function r902()
			return workspace:GetServerTimeNow()
		end

		local function r903()
			local s2 = r12_24.Trigger
			if s2 and s2.Parent then
				return s2
			end
			local s2_1 = r182:FindFirstChild("RE/BatSwing/Trigger")
			r12_24.Trigger = s2_1
			return s2_1
		end

		local function r904(arg1)
			return tonumber(arg1:GetAttribute("RagdollEndTime")) or 0
		end

		r5_25.SetLead = function(s18)
			r883 = math.clamp((tonumber(s18) or -275) / 1000, -0.4, 0.1)
		end

		r5_25.SetSweep = function(s9)
			r884 = math.clamp((tonumber(s9) or 60) / 100, 0, 2.5)
		end

		r5_25.Ragdolled = function(s27)
			return r904(s27) > r902()
		end

		r5_25.SelfRagdolled = function()
			local s2 = r904(r232)
			if s2 <= r902() then
				return false
			end
			return s2 ~= r12_24.SpawnRagdoll
		end

		r5_25.Humanoid = function(s21)
			if not s21 then
				return nil
			end
			local s7 = nil

			for _, s3 in ipairs(s21:GetChildren()) do
				if s3:IsA("Humanoid") then
					if s3.Health > 0 then
						return s3
					end
					s7 = s7 or s3
				end
			end

			return s7
		end

		local function r905(s2)
			local s4 = r234.Gears
			local s10 = type(s4) == "table" and s4.Directory or nil
			local s12 = type(s10) == "table"

			if s12 then
				s12 = s10[tostring(s2:GetAttribute("GearName") or s2.Name)]
			end

			local s2_1 = s12 or nil
			local s4_2 = type(s2_1) == "table" and s2_1.BatControllerData or nil
			return type(s4_2) == "table" and tonumber(s4_2.RangeBonus) or 0
		end

		r5_25.Range = function(s32)
			local s1 = workspace:GetAttribute("DragonEggEventActive") == true and 2.5 or 1
			return (r6_25 + r17_7 + (s32 and r905(s32) or 0)) * s1
		end

		r5_25.PickBat = function(s10)
			local s3 = s10:FindFirstChildWhichIsA("Tool")
			if s3 and r247.IsBatTool(s3) then
				return s3
			end
			local s2_1, s3_1, s4 = ipairs({ s10, r232:FindFirstChildOfClass("Backpack") })
			local s12 = -1
			local s14 = nil

			for _, s4_1 in s2_1, s3_1, s4 do
				if s4_1 then
					for _, s7 in ipairs(s4_1:GetChildren()) do
						if r247.IsBatTool(s7) then
							local s10_1 = r905(s7)

							if s12 < s10_1 then
								s12 = s10_1
								s14 = s7
							end
						end
					end
				end
			end

			return s14
		end

		local function r906(s27, s28, s29)
			if s29.Parent == s27 then
				return true
			end
			local s2 = r12_24.EquipAt
			if os.clock() - s2 < 0.2 then
				return false
			end
			r12_24.EquipAt = os.clock()

			pcall(function()
				s28:EquipTool(s29)
			end)

			if s29.Parent ~= s27 then
				pcall(function()
					s29.Parent = s27
				end)
			end

			return s29.Parent == s27
		end

		r5_25.Parts = function(s15)
			s15 = s15 and s15.Character
			local s2 = s15 and s15:FindFirstChild("HumanoidRootPart")
			local s4 = s15 and s15:FindFirstChildOfClass("Humanoid")
			if not s2 or not s4 or s4.Health <= 0 then
				return nil, nil
			end
			return s15, s2
		end

		r5_25.Hittable = function(s9)
			if not s9 or s9 == r232 or s9.Parent ~= r136 then
				return false
			end
			local s4_1, s11 = r5_25.Parts(s9)
			if not s4_1 then
				return false
			end

			if s4_1:GetAttribute("IsTrapped") == true or s9:GetAttribute("InBossArena") then
				return false
			end
			return not r247.InsideBase(s11.Position)
		end

		local function r907()
			local s3 = r12_24.WallsAt
			if os.clock() < s3 then
				return r12_24.Walls
			end
			r12_24.WallsAt = os.clock() + 5
			local s19 = {}
			local s2 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			s2 = s2 and s2:FindFirstChild("Build")

			if s2 then
				for _, s4 in ipairs(s2:GetChildren()) do
					local s6 = s4:FindFirstChild("COLLISIONS")
					s6 = s6 and s6:FindFirstChild("GUARD NO COLLIDE")

					if s6 then
						for _, s8 in ipairs(s6:GetChildren()) do
							if r11_25[s8.Name] then
								if s8:IsA("BasePart") then
									table.insert(s19, s8)
								end

								for _, s12 in ipairs(s8:GetDescendants()) do
									if s12:IsA("BasePart") then
										table.insert(s19, s12)
									end
								end
							end
						end
					end
				end
			end

			r12_24.Walls = s19
			return s19
		end

		local function r908(s35)
			if s35.X <= s35.Y and s35.X <= s35.Z then
				return "X", "Y", "Z"
			end

			if s35.Y <= s35.Z then
				return "Y", "X", "Z"
			end
			return "Z", "X", "Y"
		end

		local function r909(s21)
			local s1 = math.abs(s21.RightVector.Y)
			local s3 = math.abs(s21.UpVector.Y)
			local s4 = math.abs(s21.LookVector.Y)
			if s1 >= s3 and s1 >= s4 then
				return "X"
			end

			if s4 <= s3 then
				return "Y"
			end
			return "Z"
		end

		local function r910(s27, s28, s29, arg4)
			if s29 == arg4 then
				return true
			end
			local s4 = s28[s29] + r895
			return math.abs(s27[s29]) <= s4
		end

		local function r911(s26, s27)
			for _, s4 in ipairs(r907()) do
				if s4.Parent then
					local s11 = s4.CFrame
					local s9 = s4.Size
					local s6, s7, s8 = r908(s9)
					local s17 = r909(s11)
					local s15 = s9 / 2
					local s12 = s11:PointToObjectSpace(s27)

					if r910(s12, s15, s7, s17) and r910(s12, s15, s8, s17) then
						local s8_1 = s11:PointToObjectSpace(s26)
						local s7_1 = math.abs(s8_1[s6])
						local s9_1 = r12_24.WallSide[s4]

						if s7_1 >= s15[s6] + r895 * 0.5 or s9_1 == nil and s7_1 >= s15[s6] then
							s9_1 = s8_1[s6] >= 0 and 1 or -1
							r12_24.WallSide[s4] = s9_1
						elseif s9_1 == nil then
							s9_1 = s8_1[s6] >= 0 and 1 or -1
						end

						local s7_3 = s15[s6] + r895

						if s12[s6] * s9_1 < s7_3 then
							local s13_1 = { X = s12.X, Y = s12.Y, Z = s12.Z, [s6] = s9_1 * s7_3 }
							s27 = s11:PointToWorldSpace(Vector3.new(s13_1.X, s13_1.Y, s13_1.Z))
						end
					end
				end
			end

			return s27
		end

		r5_25.KeepOffWalls = function(s15, s16)
			local s14 = r911(s15, s16)
			local s6 = s14 - s15

			if s6.Magnitude > r895 then
				local s3 = s15

				for s2 = 1, 6 do
					local s4 = s15 + s6 * s2 / r896
					local s2_1 = r911(s3, s4)
					if (s2_1 - s4).Magnitude > 0.01 then
						return r911(s15, s2_1)
					end
					s3 = s2_1
				end
			end

			return s14
		end

		r5_25.ResetWalls = function()
			table.clear(r12_24.WallSide)
		end

		local r912 = 0
		local r913 = nil

		local function r914(s10)
			local s2 = r232.Character

			if os.clock() - r912 > 0.5 or s2 ~= r913 then
				r912 = os.clock()
				r913 = s2
				local s6 = {}

				for _, s4 in ipairs(r136:GetPlayers()) do
					if s4.Character then
						table.insert(s6, s4.Character)
					end
				end

				r901.FilterDescendantsInstances = s6
			end

			local s12 = workspace:Raycast(s10 + Vector3.new(0, 60, 0), Vector3.new(0, -400, 0), r901)
			if s12 and s10.Y < s12.Position.Y + r897 then
				return Vector3.new(s10.X, s12.Position.Y + r897, s10.Z)
			end
			return s10
		end

		local function r915(s21, s22)
			local s6 = r12_24.Tracks[s21]

			if not s6 then
				s6 = { Samples = {}, Smooth = nil, Heading = nil }
				r12_24.Tracks[s21] = s6
			end

			local s1 = os.clock()
			local s2 = s6.Samples
			table.insert(s2, { Time = s1, Position = s22.Position })

			while #s2 > 2 and s1 - s2[1].Time > r894 do
				table.remove(s2, 1)
			end

			local s4_1 = s22.AssemblyLinearVelocity
			local s2_1 = s2[1]
			local s1_1 = s1 - s2_1.Time

			if s1_1 >= 0.03 then
				local s1_2 = (s22.Position - s2_1.Position) / s1_1

				if s1_2.Magnitude <= 1500 and s4_1.Magnitude <= s1_2.Magnitude * 1.4 then
					s4_1 = s1_2
				end
			end

			local s21_1 = Vector3.new(s4_1.X, 0, s4_1.Z)
			s6.Smooth = s6.Smooth and s6.Smooth:Lerp(s21_1, 0.25) or s21_1
			local s22_1 = s6.Smooth

			if s22_1.Magnitude > 1 then
				local s2_3 = s6.Heading and s6.Heading:Lerp(s22_1.Unit, 0.25) or s22_1.Unit
				s6.Heading = s2_3.Magnitude > 0.01 and s2_3.Unit or s22_1.Unit
			end

			return s4_1, s21_1, s22_1, s6
		end

		local function r916()
			local s8 = 0

			for _, s3 in ipairs(r12_24.Stats) do
				s8 += s3.Shots
			end

			local s1 = r12_24.Option
			local s2_1 = -math.huge

			for s6, s7 in ipairs(r12_24.Stats) do
				local s14 = s7.Shots + 1
				local s3_1 = (s7.Hits + 1) / (s7.Shots + 2) + math.sqrt(2 * math.log(s8 + 2) / s14) * 0.35

				if s3_1 > s2_1 then
					s2_1 = s3_1
					s1 = s6
				end
			end

			r12_24.Option = s1
			return s1
		end

		local function r917()
			local s7 = os.clock()

			for s8 = #r12_24.Pending, 1, -1 do
				local s10 = r12_24.Pending[s8]
				local s12 = r12_24.Stats[s10.Option]

				if s10.RagdollBefore + 0.01 < r904(s10.Target) then
					s12.Hits = s12.Hits + 1
					s12.Shots = s12.Shots + 1
					table.remove(r12_24.Pending, s8)
				elseif s10.Wait < s7 - s10.At then
					if (s10.Tool and tonumber(s10.Tool:GetAttribute("CooldownEndTime")) or 0) > s10.CooldownBefore + 0.01 then
						s12.Shots = s12.Shots + 1
					end

					table.remove(r12_24.Pending, s8)
				end
			end
		end

		r5_25.Plan = function(s31, s32, s33, s34)
			if not s33 then
				local s35
				s35, s33 = r5_25.Parts(s31)
			end

			if not s33 or not s33.Parent then
				return nil
			end
			local s1_1 = math.clamp(r232:GetNetworkPing(), 0, 1)
			local s2 = math.clamp(s1_1 + r879, 0.05, 0.35)
			local s35_2, s36_1, s37, s38 = r915(s31 or s33, s33)
			local s4 = r916()
			local s3 = r10_17[s4]
			local s5 = s33.Position
			local s6 = s5 + s35_2 * math.max(0, s3 + s1_1 - s2)
			local s8 = s5 + s35_2 * (s3 + s1_1)
			local s2_1 = s37.Magnitude
			local s9 = s38.Heading

			if not s9 then
				local s38_1 = Vector3.new(s32.Position.X - s5.X, 0, s32.Position.Z - s5.Z)
				s9 = s38_1.Magnitude > 0.1 and s38_1.Unit or Vector3.new(0, 0, 1)
			end

			local s10 = r232.Character
			local s10_1 = r5_25.Range(s10 and r5_25.PickBat(s10) or nil)
			local s11_1 = s5 + s37 * (s1_1 + s3 + r882 + r883) + (s2_1 > 1 and s37.Unit * r885 * r884 or Vector3.zero)
			local s1_3 = math.max(5, math.min(s10_1 * 0.7, 6 + s2_1 * 0.07)) * r884
			local s2_2 = os.clock()
			local s10_2 = (math.sin(s2_2 * 2 * 3.1415926535897931 / r887) * 0.5 + 0.5) * s1_3
			local s3_2 = math.sin(s2_2 * 2 * 3.1415926535897931 / r888) * r889
			local s1_4 = Vector3.new(-s9.Z, 0, s9.X)

			if s1_4:Dot(s32.Position - s11_1) < 0 then
				s1_4 = -s1_4
			end

			local s9_1 = s11_1 + s9 * s10_2 + s1_4 * (s36_1.Magnitude < r893 and 3 or 1.5) + Vector3.new(0, s3_2, 0)
			local s1_5 = s32.Position

			if not s34 then
				s1_5 = r5_25.KeepOffWalls(s32.Position, r914(Vector3.new(s9_1.X, s9_1.Y, s5.Z)))
			end

			return {
				Goal = s1_5,
				Velocity = Vector3.new(s37.X, 0, s37.Z),
				Face = s8,
				Current = s8,
				Historical = s6,
				Option = s4,
				Distance = (s5 - s32.Position).Magnitude,
			}
		end

		r5_25.Steer = function(s22, s23, s24, s25, arg5)
			local s1 = math.max(arg5, 0.0041666666666666666)
			local s3 = s23.Velocity
			local s5 = s3 + (s23.Goal - s22.Position) / math.max(0.12, s1)
			local s24_1 = math.min(s24 + s3.Magnitude, s25)

			if s5.Magnitude > s24_1 then
				s5 = s5.Unit * s24_1
			end

			local s25_1 = s22.Position
			local s26 = s25_1 + s5 * s1
			local s24_2 = r5_25.KeepOffWalls(s25_1, s26)

			if (s24_2 - s26).Magnitude > 0.01 then
				s5 = (s24_2 - s25_1) / s1
			end

			local s24_3 = r5_25.KeepOffWalls(s25_1, s25_1)

			if (s24_3 - s25_1).Magnitude > 0.01 then
				s5 = (s24_3 - s25_1) / math.max(0.12, s1)
			end

			local s5_1 = s5 + Vector3.new(0, workspace.Gravity * s1 * 0.5, 0)

			pcall(function()
				local t2 = Vector3.new(s23.Face.X - s25_1.X, 0, s23.Face.Z - s25_1.Z)

				if t2.Magnitude > 0.05 then
					s22.CFrame = CFrame.lookAt(s25_1, s25_1 + t2.Unit)
				end

				s22.AssemblyLinearVelocity = s5_1
				s22.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		r5_25.TryHit = function(s35, s36)
			r917()
			if workspace:GetAttribute("PvPDisabled") == true then
				return "Player hits are off right now"
			end
			local s2 = r232.Character
			local s1 = s2 and s2:FindFirstChild("HumanoidRootPart")
			local s41 = r5_25.Humanoid(s2)
			if not s1 or not s41 or s41.Health <= 0 then
				return "Waiting for your character"
			end
			local s4_1 = r5_25.PickBat(s2)
			if not s4_1 then
				return "No bat found"
			end

			if not r906(s2, s41, s4_1) then
				return "Equipping " .. tostring(s4_1:GetAttribute("GearName") or s4_1.Name)
			end

			if not r5_25.Hittable(s35) or r5_25.Ragdolled(s35) then
				return nil
			end
			s36 = s36 or r5_25.Plan(s35, s1)
			if not s36 then
				return nil
			end
			local s2_3 = r5_25.Range(s4_1) - r881
			local s1_1 = s1.Position - s1.AssemblyLinearVelocity * r882
			if (s36.Historical - s1_1).Magnitude > s2_3 and (s36.Current - s1_1).Magnitude > s2_3 then
				return nil
			end
			local s2_4 = r903()
			if not s2_4 then
				return nil
			end
			local s39 = math.clamp(r232:GetNetworkPing(), 0, 1)
			local s5_2 = tonumber(s4_1:GetAttribute("CooldownEndTime")) or 0
			if r902() < s5_2 - s39 * 0.5 then
				return nil
			end
			local s6_2 = r12_24.LastFire
			if os.clock() - s6_2 < math.max(0.12, s39 * 1.5) then
				return nil
			end
			r12_24.LastFire = os.clock()
			r12_24.Trace = r12_24.Trace + 1

			table.insert(r12_24.Pending, {
				Target = s35,
				Option = s36.Option,
				At = os.clock(),
				Wait = math.max(0.5, s39 * 2 + 0.3),
				RagdollBefore = r904(s35),
				CooldownBefore = s5_2,
				Tool = s4_1,
			})

			local s38_1 = string.format("%d:%d:%d", r232.UserId, r12_24.Trace, math.floor(r902() * 1000))

			pcall(function()
				s2_4:FireServer(s35, s38_1)
			end)

			return "Hitting " .. s35.DisplayName
		end

		r5_25.ReadyBat = function()
			local s3 = r232.Character
			local s4 = r5_25.Humanoid(s3)
			if not s3 or not s4 or s4.Health <= 0 then
				return false
			end
			local s5 = r5_25.PickBat(s3)
			return s5 ~= nil and r906(s3, s4, s5)
		end

		r5_25.Swing = function()
			if r247.Steal.Active or r247.Steal.Carrying then
				return false
			end
			local s6 = r12_24.LastFire
			local s5_1 = os.clock() - s6 < 0.3

			if not s5_1 then
				s5_1 = os.clock() - (r12_24.LastSwing or 0) < 0.15
			end

			if s5_1 then
				return false
			end
			local s6_2 = r232.Character
			local s7_1 = r5_25.Humanoid(s6_2)
			if not s6_2 or not s7_1 or s7_1.Health <= 0 then
				return false
			end
			local s8_1 = r5_25.PickBat(s6_2)
			if not s8_1 or not r906(s6_2, s7_1, s8_1) then
				return false
			end
			r12_24.LastSwing = os.clock()

			pcall(function()
				s8_1:Activate()
			end)

			return true
		end

		r5_25.HolderOf = function(s19)
			local s11 = workspace:FindFirstChild(s19)
			if not s11 then
				return nil
			end

			for _, s4 in ipairs(s11:GetDescendants()) do
				if s4:IsA("JointInstance") or s4:IsA("WeldConstraint") or s4:IsA("RigidConstraint") then
					local s21, s22, s23 = pcall(function()
						return s4.Part0, s4.Part1
					end)

					if s21 then
						for _, s9 in ipairs({ s22, s23 }) do
							if typeof(s9) == "Instance" and not s9:IsDescendantOf(s11) then
								local s18 = s9:FindFirstAncestorOfClass("Model")

								if s18 then
									s18 = r136:GetPlayerFromCharacter(s18) or r136:FindFirstChild(s18.Name)
								end

								local s14_1 = s18 or nil
								if s14_1 and s14_1 ~= r232 and s14_1:IsA("Player") then
									return s14_1
								end
							end
						end
					end
				end
			end

			return nil
		end

		task.spawn(function()
			while not r247.CombatDisposed do
				local s6 = {}

				if r247.CombatWantsHolders then
					local s3 = r234.EggState

					if type(s3) == "table" and type(s3.ReadFieldEggs) == "function" then
						local s2_1, s3_1 = pcall(s3.ReadFieldEggs)
						local s3_2 = s2_1 and type(s3_1) == "table" and s3_1.Records or nil

						if type(s3_2) == "table" then
							for _, s4 in pairs(s3_2) do
								if type(s4) == "table" and s4.State == "Carried" and type(s4.Uid) == "string" then
									local s8_1 = r5_25.HolderOf(s4.Uid)

									if s8_1 then
										s6[s8_1] = true
									end
								end
							end
						end
					end
				end

				r12_24.Holders = s6
				task.wait(0.3)
			end
		end)

		r5_25.IsHolder = function(arg1)
			return r12_24.Holders[arg1] == true
		end

		local r918 = {}

		r5_25.OnNewLife = function(s18)
			table.insert(r918, s18)
		end

		local function r157()
			table.clear(r12_24.Pending)
			r12_24.LastFire = 0
			r12_24.LastSwing = 0
			r12_24.EquipAt = 0
			table.clear(r12_24.Tracks)
			table.clear(r12_24.WallSide)
			r12_24.SpawnRagdoll = r904(r232)

			for _, s4 in ipairs(r918) do
				pcall(s4)
			end
		end

		local r156 = r232.CharacterAdded
		local r155_2 = r156.Connect
		local r154_7 = { r232.CharacterRemoving:Connect(r157), r155_2(r156, r157) }

		r240(function()
			r247.CombatDisposed = true

			for _, s4 in ipairs(r154_7) do
				pcall(function()
					s4:Disconnect()
				end)
			end
		end)
	end

	do
		local r5_26 = r247.Combat
		local r10_18 = { "Nearest", "Egg Holders", "Specific Player" }
		local r6_26 = 0.7
		local r11_26 = "No other players"

		local r12_25 = {
			Handles = {},
			AuraHandle = nil,
			Row = nil,
			Picker = nil,
			TargetMode = r10_18[1],
			Picked = nil,
			LabelToName = {},
			Speed = 400,
			MaxSpeed = 750,
			Target = nil,
			Plan = nil,
			Moving = false,
			Status = "Idle",
			Shown = nil,
			NamesDirty = true,
		}

		local function r918_1()
			for s3, s4 in ipairs(r10_18) do
				if r247.Toggle(r12_25.Handles[s3], false) then
					return s4
				end
			end

			return nil
		end

		local function r919()
			return r247.Toggle(r12_25.AuraHandle, false) == true
		end

		r247.CombatActive = function()
			return r918_1() ~= nil or r919()
		end

		local function r920(s31)
			if not r5_26.Hittable(s31) then
				return false
			end

			if r12_25.TargetMode == r10_18[2] then
				return r5_26.IsHolder(s31)
			end

			if r12_25.TargetMode == r10_18[3] then
				return r12_25.Picked ~= nil and s31.Name == r12_25.Picked
			end
			return true
		end

		local function r921(s28)
			local s4 = r12_25.Target
			local s6

			if s4 and r920(s4) then
				local s26, s27 = r5_26.Parts(s4)
				s6 = (s27.Position - s28).Magnitude
			else
				s6 = math.huge
				s4 = nil
			end

			local s8 = math.huge
			local s10 = nil

			for _, s3 in ipairs(r136:GetPlayers()) do
				if s3 ~= s4 and r920(s3) and not r5_26.Ragdolled(s3) then
					local s26_1, s27_1 = r5_26.Parts(s3)
					local s13 = (s27_1.Position - s28).Magnitude

					if s13 < s8 then
						s8 = s13
						s10 = s3
					end
				end
			end

			if s4 then
				if s10 and not r5_26.Ragdolled(s4) and s8 < s6 * r6_26 then
					return s10
				end
				return s4
			end

			return s10
		end

		local function r922(s14, s15)
			local s6 = nil

			for _, s3 in ipairs(r136:GetPlayers()) do
				if s3 ~= r232 then
					local s17 = s3.Character
					local s8 = s17 and s17:FindFirstChild("HumanoidRootPart")

					if s8 then
						local s5 = (s8.Position - s14).Magnitude

						if s5 < s15 and r5_26.Hittable(s3) and not r5_26.Ragdolled(s3) then
							s15 = s5
							s6 = s3
						end
					end
				end
			end

			return s6, s15
		end

		local function r923()
			r12_25.Plan = nil

			if r12_25.Moving then
				r12_25.Moving = false
				r247.EndFlight()
				r247.GodMode(false)
				r247.Shield("combat", false)
				r5_26.ResetWalls()
			end

			r247.ReleaseMovement("combat")
		end

		r5_26.OnNewLife(function()
			r12_25.AuraVictim = nil
			r12_25.Target = nil
			r12_25.Plan = nil
			pcall(r923)
		end)

		local function r924()
			local s10 = r247.Movement
			local s2 = r247.Steal.Active or r247.Steal.Carrying or r247.Steal.Wanted and r247.Toggle(r4_5, false)

			if not s2 then
				s2 = s10.Owner ~= nil and s10.Owner ~= "combat" and s10.Owner ~= "treadmill"
			end

			return s2
		end

		local function r925(s35)
			local s1 = r232.Character
			local s1_1 = r5_26.Range(s1 and r5_26.PickBat(s1) or nil) + 6
			local s32, s33 = r922(s35.Position, s1_1 + 24)

			if not s32 or s33 > s1_1 then
				r12_25.AuraVictim = nil

				if s32 then
					r5_26.ReadyBat()
				end

				r12_25.Status = "Aura ready, nobody in reach"
				return
			end

			r12_25.AuraVictim = s32
			r12_25.Status = r5_26.TryHit(s32, r5_26.Plan(s32, s35, nil, true)) or "Aura on " .. s32.DisplayName
		end

		local function r926()
			local s8 = r918_1()

			if s8 and s8 ~= r12_25.TargetMode then
				r12_25.TargetMode = s8
				r12_25.Target = nil
			end

			r247.CombatWantsHolders = s8 == r10_18[2]
			local s9 = r919()
			local s10 = not s8

			if s10 then
				if r12_25.Target or r12_25.Moving then
					r12_25.Target = nil
					r923()
				end
			end

			if s10 and not s9 then
				r12_25.Status = "Idle"
				return
			end
			local s7 = r232.Character
			local s11 = s7 and s7:FindFirstChild("HumanoidRootPart")
			local s6_3 = r5_26.Humanoid(s7)

			if not s11 or not s6_3 or s6_3.Health <= 0 then
				r12_25.Target = nil
				r923()
				r12_25.Status = "Waiting for your character"
				return
			end

			if s10 then
				r925(s11)
				return
			end
			local s6_4 = r921(s11.Position)
			r12_25.Target = s6_4

			if not s6_4 then
				r923()
				if s9 then
					r925(s11)
					return
				end
				r12_25.Status = s8 == r10_18[2] and "Waiting for someone to hold an egg" or s8 == r10_18[3] and "Picked player is not reachable" or "No player to hit"
				return
			end

			local s9_1 = r5_26.Plan(s6_4, s11)
			local s10_1 = s8 ~= r10_18[2]

			if not r924() and (s10_1 or not r5_26.SelfRagdolled()) and r247.ClaimMovement("combat") and not r247.AntiGuard.Busy then
				if not r12_25.Moving then
					r12_25.Moving = true
					r247.Shield("combat", true)
					r247.GodMode(true)
					r247.BeginFlight()
				end

				r247.GodTick()
				r12_25.Plan = s9_1
			else
				if r12_25.Moving then
					r923()
				end

				r12_25.Plan = nil
			end

			local s11_1 = r5_26.TryHit(s6_4, s9_1, s10_1)
			s9_1 = s9_1 and math.floor(s9_1.Distance + 0.5) or 0

			if s11_1 then
				r12_25.Status = s11_1 .. string.format("  %d studs", s9_1)
			elseif r924() then
				r12_25.Status = string.format("Waiting for Auto Steal, near %s", s6_4.DisplayName)
			else
				r12_25.Status = string.format("Chasing %s  %d studs", s6_4.DisplayName, s9_1)
			end
		end

		local function r927()
			local s13 = {}

			for _, s4 in ipairs(r136:GetPlayers()) do
				if s4 ~= r232 then
					table.insert(s13, s4)
				end
			end

			table.sort(s13, function(arg1, t14)
				return string.lower(arg1.DisplayName) < string.lower(t14.DisplayName)
			end)

			local s15 = {}

			for _, s7 in ipairs(s13) do
				s15[s7.DisplayName] = (s15[s7.DisplayName] or 0) + 1
			end

			local s7_1 = {}
			local s17 = {}

			for _, s11 in ipairs(s13) do
				local s2_1 = s11.DisplayName

				if s15[s2_1] > 1 then
					s2_1 = string.format("%s (@%s)", s11.DisplayName, s11.Name)
				end

				table.insert(s7_1, s2_1)
				s17[s2_1] = s11.Name
			end

			if #s7_1 == 0 then
				s7_1[1] = r11_26
			end

			return s7_1, s17
		end

		local function r928(s2)
			for s7, s8 in pairs(r12_25.LabelToName) do
				if s8 == s2 then
					return s7
				end
			end

			return nil
		end

		local r155_3 = r137.PreSimulation:Connect(function(s3)
			local s4 = r12_25.Plan
			if not s4 or not r12_25.Moving then
				return
			end
			local s10 = r247.Root()

			if s10 then
				r5_26.Steer(s10, s4, r12_25.Speed, math.max(r12_25.Speed, r12_25.MaxSpeed), s3)
			end
		end)

		local r929 = 0.05
		local r930 = 0

		local r156_1 = r137.Heartbeat:Connect(function()
			local s2 = r918_1() ~= nil
			local s3 = r919()

			if not s3 then
				r12_25.AuraVictim = nil
			end

			local s4 = os.clock()

			if s2 or not s3 or s4 >= r930 then
				if s3 and not s2 then
					r930 = s4 + r929
				end

				if not pcall(r926) then
					r12_25.Status = "Retrying"
				end
			end

			if s2 or s3 and r12_25.AuraVictim ~= nil then
				pcall(r5_26.Swing)
			end

			local s4_1 = r12_25.Row

			if s4_1 and r12_25.Shown ~= r12_25.Status and type(s4_1.Set) == "function" then
				r12_25.Shown = r12_25.Status
				pcall(s4_1.Set, s4_1, r12_25.Status)
			end

			local s4_2 = r12_25.Picker

			if r12_25.NamesDirty and s4_2 and type(s4_2.SetOptions) == "function" then
				r12_25.NamesDirty = false
				local s5_2, s2_2 = r927()
				r12_25.LabelToName = s2_2
				pcall(s4_2.SetOptions, s4_2, s5_2, r12_25.Picked and r928(r12_25.Picked) or s5_2[1], false)
			end
		end)

		local r157_1 = r136.PlayerAdded:Connect(function()
			r12_25.NamesDirty = true
		end)

		local r158 = r136.PlayerRemoving:Connect(function(s30)
			r12_25.NamesDirty = true

			if r12_25.Target == s30 then
				r12_25.Target = nil
			end
		end)

		r240(function()
			for _, s4 in ipairs({ r155_3, r156_1, r157_1, r158 }) do
				pcall(function()
					s4:Disconnect()
				end)
			end

			r12_25.Target = nil
			r923()
		end)

		local function r931(s8, s9)
			if r247.Toggle(s8, false) and r247.Toggle(r247.InvisibilityHandle, false) then
				r247.UiDefer(function()
					pcall(s8.Set, s8, false, false)
					r247.Notify(s9, "Turn off Invisibility first, both cannot be on at the same time")
				end)

				return true
			end

			return false
		end

		r12_25.Row = r171:CreateText({ Name = "Hit Status", Text = "Idle" })
		local r172_1 = r180:CreateExclusiveGroup({ Name = "Chilli Combat Targets", MaxActive = 1 })

		for r110, r111 in ipairs({ "Auto Hit Nearest Player", "Auto Hit Egg Holders", "Auto Hit Specific Player" }) do
			local r1_39 = nil

			r1_39 = r171:CreateToggle({
				Name = r111,
				Default = false,
				Callback = function()
					r931(r1_39, r111)
				end,
			})

			pcall(r1_39.JoinExclusiveGroup, r1_39, r172_1)
			r12_25.Handles[r110] = r1_39
		end

		local r1_40, r2_33 = r927()
		r12_25.LabelToName = r2_33

		r12_25.Picker = r171:CreateDropdown({
			Name = "Hit Player",
			Options = r1_40,
			Default = r1_40[1],
			SubOf = r12_25.Handles[3],
			Callback = function(s16)
				r12_25.Picked = r12_25.LabelToName[tostring(s16)]
				r12_25.Target = nil
			end,
		})

		r12_25.AuraHandle = r171:CreateToggle({
			Name = "Hit Aura",
			Default = false,
			Callback = function()
				r931(r12_25.AuraHandle, "Hit Aura")
			end,
		})

		pcall(r12_25.AuraHandle.JoinExclusiveGroup, r12_25.AuraHandle, r172_1)
		local r165 = r171:CreateLabel({ Name = "Chase Settings", Text = "Chase Settings" })

		r171:CreateSlider({
			Name = "Hit Tween Speed",
			SubOf = r165,
			Min = 100,
			Max = 1000,
			Default = 400,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(s21)
				r12_25.Speed = math.clamp(tonumber(s21) or 400, 100, 1000)
			end,
		})

		r171:CreateSlider({
			Name = "Hit Max Speed",
			SubOf = r165,
			Min = 100,
			Max = 1000,
			Default = 750,
			Increment = 10,
			Unit = "studs/s",
			Callback = function(s30)
				r12_25.MaxSpeed = math.clamp(tonumber(s30) or 750, 100, 1000)
			end,
		})

		r171:CreateSlider({
			Name = "Hit Lead",
			SubOf = r165,
			Note = "Stand further ahead of the target (+) or closer to them (-)",
			Min = -400,
			Max = 100,
			Default = -275,
			Increment = 1,
			Callback = function(s16)
				r5_26.SetLead(s16)
			end,
		})

		r171:CreateSlider({
			Name = "Hit Sweep",
			SubOf = r165,
			Note = "How far you move back and forth in front of the target",
			Min = 0,
			Max = 250,
			Default = 60,
			Increment = 1,
			Unit = "%",
			Callback = function(s23)
				r5_26.SetSweep(s23)
			end,
		})

		local r2_34 = 2
		local r1_41 = nil

		local function r938()
			local s3 = r180.GetState
			return r180:GetState("Quick Pinned Features"), s3(r180, "Quick Pin Groups")
		end

		local function r939()
			local s11 = {}

			for _, s4 in ipairs({ r12_25.Handles[1], r12_25.Handles[2], r12_25.AuraHandle }) do
				local s5, s6 = pcall(function()
					return s4:GetQuickPath()
				end)

				if s5 and type(s6) == "string" then
					table.insert(s11, s6)
				end
			end

			return s11
		end

		local function r940()
			local s3, s4 = r938()
			if not s3 or not s4 then
				return false
			end
			local s7 = s3:Get()
			local s12 = s4:Get()
			if type(s7) ~= "table" or type(s12) ~= "table" then
				return false
			end
			local s3_1 = r939()
			if #s3_1 == 0 then
				return false
			end

			for _, s4_1 in ipairs(s3_1) do
				if not table.find(s7, s4_1) or tonumber(s12[s4_1]) ~= r2_34 then
					return false
				end
			end

			return true
		end

		local function r941()
			if r1_41 and type(r1_41.SetActionText) == "function" then
				pcall(r1_41.SetActionText, r1_41, r940() and "Remove" or "Add")
			end
		end

		local function r942()
			local s14, s18 = r938()
			if not s14 or not s18 then
				r247.Notify("Quick Bar", "The Quick Bar is not ready yet, try again in a moment")
				return
			end
			local s20 = r940()
			local s19 = {}
			local s22 = {}
			local s2_1 = s14:Get()

			if type(s2_1) == "table" then
				for s2_2, s3 in ipairs(s2_1) do
					s19[s2_2] = s3
				end
			end

			local s6 = s18:Get()

			if type(s6) == "table" then
				for s6_1, s7 in pairs(s6) do
					s22[s6_1] = s7
				end
			end

			for _, s11 in ipairs(r939()) do
				local s1_1 = table.find(s19, s11)

				if s20 then
					if s1_1 then
						table.remove(s19, s1_1)
					end

					s22[s11] = nil
				else
					s22[s11] = r2_34

					if not s1_1 then
						table.insert(s19, s11)
					end
				end
			end

			s18:Set(s22)
			s14:Set(s19)
			r941()
			r247.Notify("Quick Bar", s20 and "Removed the hit toggles from Quick Bar 2" or "Added the hit toggles to Quick Bar 2")
		end

		r1_41 = r171:CreateButton({
			Name = "Add/Remove Hits On Quick Bar 2",
			Note = "Pin or unpin the hit toggles on Quick Bar 2",
			ButtonText = "Add",
			ConfirmText = "Done!",
			Callback = function()
				r247.UiDefer(r942)
			end,
		})

		task.delay(3, function()
			r247.UiDefer(r941)
		end)
	end

	r22_2 = r247.EspSection

	local function r1_42(arg1, arg2)
		local s25, s26 = pcall(Font.new, arg1, arg2, Enum.FontStyle.Normal)
		return s25 and s26 or nil
	end

	r951 = {
		MainFont = r1_42("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		StatusFont = r1_42("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
		Sequence = function(s19)
			local s5 = table.create(#s19)

			for s3, s4 in ipairs(s19) do
				s5[s3] = ColorSequenceKeypoint.new(s4[1], s4[2])
			end

			return ColorSequence.new(s5)
		end,
	}

	r1_43 = Color3.fromRGB
	r14_12 = r951.Sequence
	r16_7 = {}

	do
		local r953 = {}
		local r6_27 = {}
		local r189_2 = { 0, r1_43(255, 231, 158) }
		local r2_35 = { 0.4, r1_43(255, 196, 66) }
		local r5_27 = { 1, r1_43(214, 142, 12) }
		r6_27[1] = r189_2
		r6_27[2] = r2_35
		r6_27[3] = r5_27
		r953.Text = r14_12(r6_27)
		local r6_28 = {}
		local r189_3 = { 0, r1_43(122, 76, 0) }
		local r2_36 = { 0.55, r1_43(62, 38, 0) }
		local r5_28 = { 1, r1_43(20, 12, 0) }
		r6_28[1] = r189_3
		r6_28[2] = r2_36
		r6_28[3] = r5_28
		r953.Stroke = r14_12(r6_28)
		r953.Outline = r1_43(255, 232, 152)
		r16_7.Gold = r953
	end

	do
		local r955 = {}
		local r6_29 = {}
		local r189_4 = { 0, r1_43(255, 198, 132) }
		local r2_37 = { 0.4, r1_43(255, 146, 40) }
		local r5_29 = { 1, r1_43(206, 92, 0) }
		r6_29[1] = r189_4
		r6_29[2] = r2_37
		r6_29[3] = r5_29
		r955.Text = r14_12(r6_29)
		local r6_30 = {}
		local r189_5 = { 0, r1_43(112, 54, 0) }
		local r2_38 = { 0.55, r1_43(56, 27, 0) }
		local r5_30 = { 1, r1_43(18, 8, 0) }
		r6_30[1] = r189_5
		r6_30[2] = r2_38
		r6_30[3] = r5_30
		r955.Stroke = r14_12(r6_30)
		r955.Outline = r1_43(255, 194, 112)
		r16_7.Orange = r955
	end

	do
		local r957 = {}
		local r6_31 = {}
		local r189_6 = { 0, r1_43(255, 105, 105) }
		local r2_39 = { 0.4, r1_43(255, 28, 40) }
		local r5_31 = { 1, r1_43(184, 0, 18) }
		r6_31[1] = r189_6
		r6_31[2] = r2_39
		r6_31[3] = r5_31
		r957.Text = r14_12(r6_31)
		local r6_32 = {}
		local r189_7 = { 0, r1_43(124, 0, 15) }
		local r2_40 = { 0.55, r1_43(61, 0, 9) }
		local r5_32 = { 1, r1_43(18, 0, 3) }
		r6_32[1] = r189_7
		r6_32[2] = r2_40
		r6_32[3] = r5_32
		r957.Stroke = r14_12(r6_32)
		r957.Outline = r1_43(255, 128, 138)
		r16_7.Red = r957
	end

	do
		local r959 = {}
		local r6_33 = {}
		local r189_8 = { 0, r1_43(170, 255, 160) }
		local r2_41 = { 0.45, r1_43(58, 255, 55) }
		local r5_33 = { 1, r1_43(20, 109, 0) }
		r6_33[1] = r189_8
		r6_33[2] = r2_41
		r6_33[3] = r5_33
		r959.Text = r14_12(r6_33)
		local r5_34 = {}
		local r189_9 = { 0, r1_43(10, 52, 6) }
		local r2_42 = { 1, r1_43(3, 16, 0) }
		r5_34[1] = r189_9
		r5_34[2] = r2_42
		r959.Stroke = r14_12(r5_34)
		r959.Outline = r1_43(58, 255, 55)
		r16_7.Accent = r959
	end

	r961 = {}

	do
		local r6_34 = {}
		local r189_10 = { 0, r1_43(255, 255, 255) }
		local r2_43 = { 0.5, r1_43(222, 222, 222) }
		local r5_35 = { 1, r1_43(255, 255, 255) }
		r6_34[1] = r189_10
		r6_34[2] = r2_43
		r6_34[3] = r5_35
		r961.Text = r14_12(r6_34)
	end
end

local r168, r170, r15_13

do
	local r22_3, r1135, r1136, r1137, r1138, r1139, r1140, r1141, r1142, r201_1
	local r202, r203, r204, r205, r158_2, r1_49, r1143, r1144

	do
		do
			local r5_36 = {}
			local r189_11 = { 0, r1_43(8, 8, 8) }
			local r2_44 = { 1, r1_43(8, 8, 8) }
			r5_36[1] = r189_11
			r5_36[2] = r2_44
			r961.Stroke = r14_12(r5_36)
		end

		r961.Outline = r1_43(255, 255, 255)
		r16_7.Sheen = r961
		r951.Palettes = r16_7

		r951.PaletteFromColor = function(s6)
			local s2 = Color3.new(1, 1, 1)
			local s7 = Color3.new(0, 0, 0)
			local s18 = {}
			local s20 = r951.Sequence
			local s15 = {}
			local s3 = { 0, s6:Lerp(s2, 0.5) }
			local s12 = { 0.4, s6:Lerp(s2, 0.1) }
			local s13 = { 1, s6:Lerp(s7, 0.25) }
			s15[1] = s3
			s15[2] = s12
			s15[3] = s13
			s18.Text = s20(s15)
			local s22 = r951.Sequence
			local s17 = {}
			local s5 = { 0, s6:Lerp(s7, 0.55) }
			local s15_1 = { 0.55, s6:Lerp(s7, 0.75) }
			local s11 = { 1, s6:Lerp(s7, 0.92) }
			s17[1] = s5
			s17[2] = s15_1
			s17[3] = s11
			s18.Stroke = s22(s17)
			s18.Outline = s6:Lerp(s2, 0.25)
			return s18
		end

		r951.SizeScale = 1
		local r962 = {}

		r951.OnSizeChanged = function(s37)
			table.insert(r962, s37)
		end

		r951.SetSizeScale = function(s27)
			if r951.SizeScale == s27 then
				return
			end
			r951.SizeScale = s27

			for _, s4 in ipairs(r962) do
				pcall(s4)
			end
		end

		r951.RowHeight = function(s34)
			local s2 = workspace.CurrentCamera
			return math.max(6, math.floor(math.clamp((s2 and s2.ViewportSize.Y or 1080) * 0.014, 13, 19) * (s34 or r951.SizeScale)))
		end

		r951.ScaledWidth = function(arg1, arg2)
			return math.max(30, math.floor(arg1 * (arg2 or r951.SizeScale)))
		end

		r951.CreateRuntime = function()
			local s3 = Instance.new("ScreenGui")
			s3.Name = r238()
			s3.Archivable = false
			s3.ResetOnSpawn = false
			s3.IgnoreGuiInset = true
			s3.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			s3.DisplayOrder = 48
			s3.Parent = r235
			return s3
		end

		r951.CreateTag = function(s31, s32)
			local s4 = Instance.new("BillboardGui")
			s4.Name = r238()
			s4.AlwaysOnTop = true
			s4.LightInfluence = 0
			s4.MaxDistance = s32
			local s6 = Instance.new("Frame")
			s6.Name = r238()
			s6.BackgroundTransparency = 1
			s6.BorderSizePixel = 0
			s6.Size = UDim2.fromScale(1, 1)
			s6.Parent = s4
			local s1 = Instance.new("UIListLayout")
			s1.Name = r238()
			s1.FillDirection = Enum.FillDirection.Vertical
			s1.HorizontalAlignment = Enum.HorizontalAlignment.Center
			s1.VerticalAlignment = Enum.VerticalAlignment.Center
			s1.SortOrder = Enum.SortOrder.LayoutOrder
			s1.Parent = s6
			s4.Parent = s31
			return s4, s6
		end

		r951.CreateTextRow = function(s12, s13, s14, s15)
			local s6 = Instance.new("Frame")
			s6.Name = r238()
			s6.BackgroundTransparency = 1
			s6.BorderSizePixel = 0
			s6.Size = UDim2.fromScale(1, s15)
			s6.LayoutOrder = s14
			s6.Parent = s12

			local function s2(t9)
				local t3 = Instance.new("TextLabel")
				t3.Name = r238()
				t3.BackgroundTransparency = 1
				t3.Size = UDim2.fromScale(1, 1)
				t3.Text = ""
				t3.TextScaled = true
				t3.TextStrokeTransparency = 1
				t3.TextXAlignment = Enum.TextXAlignment.Center
				t3.TextYAlignment = Enum.TextYAlignment.Center
				t3.ZIndex = t9

				if s13 then
					t3.FontFace = s13
				else
					t3.Font = Enum.Font.GothamBold
				end

				t3.Parent = s6
				return t3
			end

			local s3 = s2(2)
			s3.Position = UDim2.fromOffset(1, 1)
			s3.TextColor3 = Color3.new(0, 0, 0)
			s3.TextTransparency = 0.1
			local s2_1 = s2(3)
			s2_1.TextColor3 = Color3.new(1, 1, 1)
			local s4 = Instance.new("UIStroke")
			s4.Name = r238()
			s4.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			s4.LineJoinMode = Enum.LineJoinMode.Round
			s4.Color = Color3.new(1, 1, 1)
			s4.Transparency = 0.05

			s4.Thickness = pcall(function()
				s4.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			end) and 0.05 or 1.2

			s4.Parent = s2_1
			local s8_1 = Instance.new("UIGradient")
			s8_1.Name = r238()
			s8_1.Rotation = 90
			s8_1.Parent = s4
			local s10 = Instance.new("UIGradient")
			s10.Name = r238()
			s10.Rotation = 90
			s10.Parent = s2_1
			return { Holder = s6, Shadow = s3, Label = s2_1, StrokeGradient = s8_1, TextGradient = s10, Palette = nil }
		end

		r951.SetRow = function(s19, s20, s21)
			if s19.Label.Text ~= s20 then
				s19.Label.Text = s20
				s19.Shadow.Text = s20
			end

			if s19.Palette ~= s21 then
				s19.Palette = s21
				s19.TextGradient.Color = s21.Text
				s19.TextGradient.Rotation = s21.Rotation or 90
				s19.StrokeGradient.Color = s21.Stroke
			end
		end

		r951.ReadToggle = function(s19, s20)
			if type(s19) ~= "table" then
				return s20 == true
			end

			local s1, s2 = pcall(function()
				local t2 = s19._controller
				return type(t2) == "table" and type(t2.GetValue) == "function" and t2.GetValue()
			end)

			if s1 and type(s2) == "boolean" then
				return s2
			end

			for _, s3 in ipairs({ "Get", "GetValue" }) do
				local s17, s4 = pcall(function()
					return s19[s3]
				end)

				if s17 and type(s4) == "function" then
					local s17_1, s18_1 = pcall(s4, s19)
					if s17_1 and type(s18_1) == "boolean" then
						return s18_1
					end
				end
			end

			return s20 == true
		end

		r951.SyncSoon = function(s14)
			s14()
			task.delay(0.35, s14)
		end

		r951.GetGuardAreas = function()
			local s7 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
			local s14 = s7 and s7:FindFirstChild("Areas")
			return s14 and s14:FindFirstChild("GuardAreas")
		end

		r951.FindGuardRoot = function(s8)
			local s9 = s8:FindFirstChild("HumanoidRootPart")
			if s9 and s9:IsA("BasePart") then
				return s9
			end

			if s8.PrimaryPart then
				return s8.PrimaryPart
			end
			return s8:FindFirstChildWhichIsA("BasePart", true)
		end

		r951.WatchGuards = function(s24)
			local s6 = {}
			local s5 = r951.GetGuardAreas()
			if not s5 then
				return s6
			end

			local function s28(t10)
				local t6 = t10:FindFirstChild("Guard")

				if t6 and t6:IsA("Model") then
					s24(t10.Name, t6)
				end

				table.insert(s6, t10.ChildAdded:Connect(function(u17)
					if u17.Name == "Guard" and u17:IsA("Model") then
						s24(t10.Name, u17)
					end
				end))
			end

			for _, s4 in ipairs(s5:GetChildren()) do
				s28(s4)
			end

			table.insert(s6, s5.ChildAdded:Connect(s28))
			return s6
		end

		r951.DisconnectAll = function(s27)
			for _, s3 in ipairs(s27) do
				pcall(function()
					s3:Disconnect()
				end)
			end

			table.clear(s27)
		end

		local r963
		r963 = 18
		local r10_19

		r10_19 = {
			"Icon",
			"Name",
			"Rarity",
			"Mutation",
			"Value",
			"Weight",
			"Size",
			"Sell Price",
			"Distance",
			"Area",
			"State",
		}

		local r1_44
		r1_44 = { "Icon", "Name", "Value" }
		local r11_27
		r11_27 = { "Off", "Rare Only", "All Shown" }
		local r965
		r965 = { Icon = 3.2, Name = 1.35, Rarity = 1.2, Mutation = 1, Value = 1.1, Info = 1 }
		local r966

		local function r2_45()
			local s6, s7 = pcall(Font.new, "rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			return s6 and s7 or r951.StatusFont
		end

		r966 = r2_45()
		local r967

		do
			local r19_5 = r951.Sequence
			local r195 = {}
			local r189_12 = { 0, Color3.fromRGB(255, 255, 255) }
			local r2_46 = { 0.2, Color3.fromRGB(206, 212, 224) }
			local r5_37 = { 0.42, Color3.fromRGB(74, 80, 94) }
			local r6_35 = { 0.58, Color3.fromRGB(42, 46, 56) }
			local r193 = { 0.78, Color3.fromRGB(158, 166, 182) }
			local r194 = { 1, Color3.fromRGB(250, 252, 255) }
			r195[1] = r189_12
			r195[2] = r2_46
			r195[3] = r5_37
			r195[4] = r6_35
			r195[5] = r193
			r195[6] = r194
			r967 = r19_5(r195)
		end

		local r968
		r968 = r951.PaletteFromColor(Color3.fromRGB(77, 255, 122))
		local r969
		r969 = {}

		do
			local r5_38 = r951.Sequence
			local r152_6 = {}
			local r153_17 = { 0, Color3.fromRGB(255, 255, 255) }
			local r154_8 = { 0.5, Color3.fromRGB(222, 238, 255) }
			local r155_4 = { 1, Color3.fromRGB(255, 255, 255) }
			r152_6[1] = r153_17
			r152_6[2] = r154_8
			r152_6[3] = r155_4
			r969.Text = r5_38(r152_6)
		end

		do
			local r5_39 = r951.Sequence
			local r153_18 = {}
			local r154_9 = { 0, Color3.fromRGB(8, 8, 8) }
			local r155_5 = { 1, Color3.fromRGB(8, 8, 8) }
			r153_18[1] = r154_9
			r153_18[2] = r155_5
			r969.Stroke = r5_39(r153_18)
		end

		r969.Outline = Color3.fromRGB(255, 255, 255)
		local r972
		r972 = 0.8
		local r973
		r973 = 4.5
		local r974
		r974 = 20
		local r977
		r977 = 0.002
		local r978
		r978 = { Golden = r951.Palettes.Gold }

		do
			local r5_40 = {}
			local r12_26 = r951.Sequence
			local r152_7 = {}
			local r153_19 = { 0, Color3.fromRGB(255, 255, 255) }
			local r154_10 = { 0.45, Color3.fromRGB(214, 222, 232) }
			local r155_6 = { 1, Color3.fromRGB(150, 160, 175) }
			r152_7[1] = r153_19
			r152_7[2] = r154_10
			r152_7[3] = r155_6
			r5_40.Text = r12_26(r152_7)
			local r12_27 = r951.Sequence
			local r152_8 = {}
			local r153_20 = { 0, Color3.fromRGB(60, 66, 78) }
			local r154_11 = { 0.55, Color3.fromRGB(30, 33, 40) }
			local r155_7 = { 1, Color3.fromRGB(10, 11, 14) }
			r152_8[1] = r153_20
			r152_8[2] = r154_11
			r152_8[3] = r155_7
			r5_40.Stroke = r12_27(r152_8)
			r5_40.Outline = Color3.fromRGB(214, 222, 232)
			r978.Silver = r5_40
		end

		r978.Sakura = r951.PaletteFromColor(Color3.fromRGB(255, 158, 216))
		r978.GreatBloom = r951.PaletteFromColor(Color3.fromRGB(124, 255, 196))
		r978.Boss = r951.PaletteFromColor(Color3.fromRGB(255, 122, 122))
		r978.Monstrous = r951.PaletteFromColor(Color3.fromRGB(192, 139, 255))

		do
			local r985 = {}
			local r988 = r951.Sequence
			local r200 = {}
			local r2_47 = { 0, Color3.fromRGB(255, 107, 107) }
			local r5_41 = { 0.2, Color3.fromRGB(255, 179, 107) }
			local r6_36 = { 0.4, Color3.fromRGB(255, 240, 107) }
			local r197 = { 0.6, Color3.fromRGB(107, 255, 138) }
			local r198 = { 0.8, Color3.fromRGB(107, 200, 255) }
			local r199 = { 1, Color3.fromRGB(185, 107, 255) }
			r200[1] = r2_47
			r200[2] = r5_41
			r200[3] = r6_36
			r200[4] = r197
			r200[5] = r198
			r200[6] = r199
			r985.Text = r988(r200)
			local r5_42 = r951.Sequence
			local r153_21 = {}
			local r154_12 = { 0, Color3.fromRGB(20, 20, 30) }
			local r155_8 = { 1, Color3.fromRGB(8, 8, 12) }
			r153_21[1] = r154_12
			r153_21[2] = r155_8
			r985.Stroke = r5_42(r153_21)
			r985.Outline = Color3.fromRGB(255, 255, 255)
			r985.Rotation = 0
			r978.Rainbow = r985
		end

		local r5_43
		r5_43 = r951.PaletteFromColor(Color3.fromRGB(143, 227, 255))
		local r198_1
		r198_1 = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
		local r6_37
		r6_37 = 0
		local r989

		r989 = {
			Eggs = false,
			MinRarity = 5,
			Specific = {},
			MutationSet = {},
			AnyMutation = false,
			NoMutation = false,
			Info = {},
			Highlight = r11_27[1],
			MinValue = 0,
			HighlightMin = 6,
			MaxDistance = math.huge,
			SizeScale = 0.75,
			FixedSize = false,
			OwnBase = true,
		}

		for _, r114 in ipairs(r1_44) do
			r989.Info[r114] = true
		end

		local r990
		r990 = {}
		local r992, r993, r994, r995, r996, r997, r998, r999, r1018, r1022
		local r1026

		do
			local r991 = {}
			r992 = {}
			r993 = nil
			r994 = false
			r995 = 0
			r996 = 0
			r997 = false
			r998 = nil
			r999 = 0

			local function r1000(s37)
				local s1 = r991[s37]
				if s1 then
					return s1
				end
				local s1_1 = r234.Assets and r234.Assets.Directory
				local s5 = type(s1_1) == "table" and s1_1[s37]
				local s6 = type(s5) == "table" and type(s5.Rarity) == "table" and s5.Rarity or nil
				local s4 = s6 and typeof(s6.Color) == "Color3" and s6.Color or Color3.new(1, 1, 1)
				local s7 = r951.PaletteFromColor(s4)
				local s2 = s6 and s6.RarityGradient

				if s6 and typeof(s2) ~= "Instance" then
					local s39 = r181:FindFirstChild("Assets")
					s39 = s39 and s39:FindFirstChild("UI")
					s39 = s39 and s39:FindFirstChild("RarityGradients")

					if s39 then
						s39 = s39:FindFirstChild(tostring(s6._id or s6.DisplayName or ""))
					end

					s2 = s39 and s39:FindFirstChild("RarityGradient") or nil
				end

				if typeof(s2) == "Instance" and s2:IsA("UIGradient") then
					s7.Text = s2.Color
					s7.Rotation = s2.Rotation
				end

				local s1_6

				if s6 then
					s1_6 = tostring(s6.DisplayName or s6._id or "")
				else
					s1_6 = s6
				end

				s1_6 = s1_6 or ""
				local s2_2

				if string.upper(s1_6) ~= "SECRET" then
					s2_2 = s7
				else
					s2_2 = { Text = r967, Stroke = s7.Stroke, Outline = s7.Outline, Rotation = 90 }
				end

				local s3_2 = {}

				if s6 then
					s6 = tonumber(s6.RarityNumber or s6.Rank)
				end

				s3_2.Number = s6 or 0
				s3_2.Name = s1_6
				s3_2.Color = s4
				s3_2.Palette = s7
				s3_2.RarityPalette = s2_2
				local s2_3 = type(s5) == "table"

				if s2_3 then
					s2_3 = tostring(s5.DisplayName or s37)
				end

				s3_2.DisplayName = s2_3 or tostring(s37)
				s3_2.Icon = type(s5) == "table" and s5.Icon or nil
				s3_2.EarningRate = type(s5) == "table" and tonumber(s5.EarningRate) or 0
				r991[s37] = s3_2
				return s3_2
			end

			local function r1001(s36)
				local s1 = workspace:FindFirstChild("AreaEggSlotsClient")
				s1 = s1 and s1:FindFirstChild(s36)
				if s1 and s1:IsA("Model") then
					local s3 = s1:FindFirstChild("Hitbox")
					return s1, s3 and s3:IsA("BasePart") and s3 or nil
				end
				return nil, nil
			end

			local function r1002()
				if not r998 or not r998.Parent then
					r998 = r951.CreateRuntime()
				end
			end

			local function r1003(s18)
				local s2 = tonumber(s18) or 0
				local s9 = { "", "K", "M", "B", "T", "Qa", "Qi" }
				local s4 = 1

				while math.abs(s2) >= 1000 and s4 < #s9 do
					s2 /= 1000
					s4 += 1
				end

				return string.format(s4 == 1 and "%.0f%s" or "%.2f%s", s2, s9[s4])
			end

			local function r1004(s13)
				local s2 = workspace.CurrentCamera
				if not s2 then
					return r989.MaxDistance
				end
				return math.min(r989.MaxDistance, s13 * s2.ViewportSize.Y / 2 * r974 * math.tan(math.rad(s2.FieldOfView) * 0.5))
			end

			local function r1005(s24)
				local s19 = {
					{ s24.IconHolder, r965.Icon, s24.ShowIcon },
					{ s24.NameRow.Holder, r965.Name, s24.ShowName },
					{ s24.RarityRow.Holder, r965.Rarity, s24.ShowRarity },
					{ s24.MutationRow.Holder, r965.Mutation, s24.ShowMutation },
					{ s24.ValueRow.Holder, r965.Value, s24.ShowValue },
					{ s24.ExtraRow.Holder, r965.Info, s24.ShowExtra },
				}

				local s21 = 0

				for _, s7 in ipairs(s19) do
					if s7[3] then
						s21 += s7[2]
					end
				end

				local s20 = math.max(s21, 1)

				for _, s10 in ipairs(s19) do
					s10[1].Visible = s10[3]
					s10[1].Size = UDim2.fromScale(1, s10[3] and s10[2] / s20 or 0)
				end

				local s5_1 = r951.ScaledWidth(120, r989.SizeScale)
				local s20_1 = math.max(1, math.floor(r951.RowHeight(r989.SizeScale) * s20))

				if s24.Width ~= s5_1 or s24.Height ~= s20_1 or s24.Fixed ~= r989.FixedSize then
					s24.Width = s5_1
					s24.Height = s20_1
					s24.Fixed = r989.FixedSize

					if r989.FixedSize then
						local s7_3 = r973 * r989.SizeScale
						s24.Billboard.Size = UDim2.fromScale(s7_3, s7_3 * s20_1 / s5_1)
						s24.Billboard.MaxDistance = r1004(s7_3)
					else
						s24.Billboard.Size = UDim2.fromOffset(s5_1, s20_1)
						s24.Billboard.MaxDistance = r989.MaxDistance
					end
				end
			end

			local function r1006(s37)
				s37.Width = nil
				r1005(s37)
			end

			local function r1007()
				local s2, s3 = r951.CreateTag(r998, r989.MaxDistance)
				local s8 = Instance.new("Frame")
				s8.Name = r238()
				s8.BackgroundTransparency = 1
				s8.BorderSizePixel = 0
				s8.LayoutOrder = 0
				s8.Parent = s3
				local s10 = Instance.new("ImageLabel")
				s10.Name = r238()
				s10.AnchorPoint = Vector2.new(0.5, 1)
				s10.BackgroundTransparency = 1
				s10.Position = UDim2.fromScale(0.5, 1)
				s10.Size = UDim2.fromScale(1, 1)
				s10.ScaleType = Enum.ScaleType.Fit
				s10.Parent = s8
				local s4 = Instance.new("UIAspectRatioConstraint")
				s4.Name = r238()
				s4.AspectRatio = 1
				s4.DominantAxis = Enum.DominantAxis.Height
				s4.Parent = s10

				local s13 = {
					Billboard = s2,
					IconHolder = s8,
					Icon = s10,
					NameRow = r951.CreateTextRow(s3, r951.MainFont, 1, 0.4),
					RarityRow = r951.CreateTextRow(s3, r966, 2, 0.2),
					MutationRow = r951.CreateTextRow(s3, r951.MainFont, 3, 0.2),
					ValueRow = r951.CreateTextRow(s3, r951.MainFont, 4, 0.2),
					ExtraRow = r951.CreateTextRow(s3, r951.MainFont, 5, 0.2),
					Highlight = nil,
					Anchor = nil,
					CFrame = nil,
					Width = nil,
					Height = nil,
					ShowIcon = false,
					ShowName = true,
					ShowRarity = false,
					ShowMutation = false,
					ShowValue = false,
					ShowExtra = false,
				}

				r1005(s13)
				return s13
			end

			local function r1008(s26)
				if s26.Highlight then
					s26.Highlight:Destroy()
					s26.Highlight = nil
					r999 -= 1
				end
			end

			local function r1009(s30, s31)
				local s1 = tonumber(s30.AssetScale) or 1
				local s4 = s1 > 5 and (s1 / 5) ^ 1.2 * 19.637875755794113 or s1 ^ 1.85
				local s1_1 = r234.Mutations
				local s2_1 = type(s1_1) == "table" and type(s1_1.EarningsFor) == "function"
				local s29 = 1

				if s2_1 then
					local s28_1
					s28_1, s29 = pcall(s1_1.EarningsFor, type(s30.Mutations) == "table" and s30.Mutations or {})
					s28_1 = s28_1 and type(s29) == "number"
					local s1_3 = 1

					if not s28_1 then
						s29 = s1_3
					end
				end

				return s31.EarningRate * s4 * s29
			end

			local function r1010()
				local s25 = {}
				local s3 = r234.EggState
				local s2 = workspace:FindFirstChild("PlacedEggRenders")
				if not s2 or type(s3) ~= "table" or type(s3.ReadOwnerEggs) ~= "function" then
					return s25
				end
				local s6_1, s10 = pcall(s3.ReadOwnerEggs, r232.UserId)
				if not s6_1 or type(s10) ~= "table" then
					return s25
				end
				local s13 = tostring(r232.UserId)
				local s17 = {}

				for _, s4_1 in ipairs(s2:GetChildren()) do
					if string.find(s4_1.Name, s13, 1, true) then
						s17[#s17 + 1] = s4_1
					end
				end

				for s7_1, s8 in pairs(s10) do
					if type(s8) == "table" and s8.Placement ~= nil and type(s8.AssetCategory) == "string" then
						local s21 = tostring(s7_1)
						local s3_3 = nil

						for _, s11 in ipairs(s17) do
							if s11.Name == s21 or string.find(s11.Name, s21, 1, true) or s11:GetAttribute("Uid") == s21 then
								s3_3 = s11
								break
							end
						end

						if s3_3 then
							local s22, s23 = pcall(function()
								return s3_3:IsA("Model") and s3_3:GetPivot() or s3_3.CFrame
							end)

							local s4_2 = type(s8.Mutations) == "table" and s8.Mutations or {}

							s25[#s25 + 1] = {
								Uid = "base:" .. s21,
								AssetCategory = s8.AssetCategory,
								AssetScale = s8.AssetScale,
								Mutations = s4_2,
								BaseMutation = s8.BaseMutation or s4_2[1],
								State = "Base",
								AreaId = "Your Base",
								BottomCFrame = s22 and s23 or nil,
								Model = s3_3,
							}
						end
					end
				end

				return s25
			end

			local function r1011(s29, s30)
				if s29.State == "Claimed" then
					return false
				end

				if r989.MinRarity > 0 and s30.Number < r989.MinRarity then
					return false
				end
				local s2_1 = r989.MinValue > 0

				if s2_1 then
					local s3_1 = r989.MinValue
					s2_1 = r1009(s29, s30) < s3_1
				end

				if s2_1 then
					return false
				end
				return true
			end

			local function r1012(s36, s37, s38)
				local s3, s42

				if typeof(s37.Model) == "Instance" then
					s3 = s37.Model
					s42 = s3:FindFirstChild("Hitbox", true) or s3:FindFirstChildWhichIsA("BasePart", true)
					s42 = s42 and s42:IsA("BasePart") and s42 or nil
				else
					s3, s42 = r1001(s37.Uid)
				end

				local s4 = s37.BottomCFrame

				if typeof(s4) == "CFrame" then
					local s1_11 = s42 or workspace.Terrain

					if s36.Anchor ~= s1_11 or s36.CFrame ~= s4 then
						s36.Anchor = s1_11
						s36.CFrame = s4
						s36.Billboard.Adornee = s1_11
						s36.Billboard.StudsOffsetWorldSpace = s4.Position - s1_11.Position + Vector3.new(0, (s42 and s42.Position.Y - s4.Position.Y or 1) + r972, 0)
					end
				end

				local s5 = r989.Info
				local s1 = s37.BaseMutation
				local s6 = type(s1) == "string" and s1 ~= ""
				local s42_1 = tonumber(s37.AssetScale) or 1
				local s7 = s5.Icon == true and s38.Icon ~= nil

				if s7 and s36.Icon.Image ~= tostring(s38.Icon) then
					s36.Icon.Image = tostring(s38.Icon)
				end

				local s8 = s5.Name == true

				if s8 then
					r951.SetRow(s36.NameRow, s38.DisplayName, r969)
				end

				local s9 = s5.Rarity == true and s38.Name ~= ""

				if s9 then
					local s46 = s38.RarityPalette
					r951.SetRow(s36.RarityRow, string.upper(s38.Name), s46)
				end

				s6 = s5.Mutation == true and s6

				if s6 then
					r951.SetRow(s36.MutationRow, string.upper(r263(s1)), r978[s1] or r5_43)
				end

				local s10 = s5.Value == true

				if s10 then
					r951.SetRow(s36.ValueRow, "$" .. r1003(r1009(s37, s38)) .. "/s", r968)
				end

				local s43_1 = {}
				local s1_1 = r234.EggRecords

				if s5.Weight and type(s1_1) == "table" and type(s1_1.WeightKgForScale) == "function" then
					local s39_1, s40 = pcall(s1_1.WeightKgForScale, s37.AssetCategory, s42_1)

					if s39_1 and tonumber(s40) then
						table.insert(s43_1, r1003(s40) .. " kg")
					end
				end

				if s5.Size then
					table.insert(s43_1, string.format("x%.2f", s42_1))
				end

				if s5["Sell Price"] and type(s1_1) == "table" and type(s1_1.SellPrice) == "function" then
					local s44_1, s45_1 = pcall(s1_1.SellPrice, s37)

					if s44_1 and tonumber(s45_1) then
						table.insert(s43_1, "$" .. r1003(s45_1))
					end
				end

				if s5.Distance and typeof(s4) == "CFrame" then
					local s2_6 = r232.Character
					s2_6 = s2_6 and s2_6:FindFirstChild("HumanoidRootPart")

					if s2_6 then
						table.insert(s43_1, string.format("%dm", math.floor((s2_6.Position - s4.Position).Magnitude + 0.5)))
					end
				end

				if s5.Area and s37.AreaId ~= nil then
					table.insert(s43_1, tostring(s37.AreaId))
				end

				if s5.State and s37.State ~= nil and s37.State ~= "Slot" then
					table.insert(s43_1, tostring(s37.State))
				end

				local s1_6 = #s43_1 > 0

				if s1_6 then
					r951.SetRow(s36.ExtraRow, table.concat(s43_1, "  |  "), r951.Palettes.Sheen)
				end

				if s36.ShowIcon ~= s7 or s36.ShowName ~= s8 or s36.ShowRarity ~= s9 or s36.ShowMutation ~= s6 or s36.ShowValue ~= s10 or s36.ShowExtra ~= s1_6 then
					s36.ShowIcon = s7
					s36.ShowName = s8
					s36.ShowRarity = s9
					s36.ShowMutation = s6
					s36.ShowValue = s10
					s36.ShowExtra = s1_6
					r1005(s36)
				end

				if (r989.Highlight == r11_27[3] or r989.Highlight == r11_27[2] and s38.Number >= r989.HighlightMin) and s3 then
					if not s36.Highlight and r999 < r963 then
						local s1_10 = Instance.new("Highlight")
						s1_10.Name = r238()
						s1_10.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						s1_10.FillTransparency = 0.82
						s1_10.OutlineTransparency = 0.05
						s1_10.FillColor = s38.Color
						s1_10.OutlineColor = s38.Palette.Outline
						s1_10.Parent = r998
						s36.Highlight = s1_10
						r999 += 1
					end

					if s36.Highlight and s36.Highlight.Adornee ~= s3 then
						s36.Highlight.Adornee = s3
					end
				else
					r1008(s36)
				end
			end

			local function r1013(s6)
				r1008(s6)
				s6.Billboard:Destroy()
			end

			local function r1014()
				local s2 = r990
				local s4 = r998
				r990 = {}
				r998 = nil
				r999 = 0

				task.spawn(function()
					local t8 = os.clock()

					for _, t4 in pairs(s2) do
						if t4.Highlight then
							t4.Highlight:Destroy()
						end

						t4.Billboard:Destroy()

						if r977 < os.clock() - t8 then
							r137.Heartbeat:Wait()
							t8 = os.clock()
						end
					end

					if s4 then
						s4:Destroy()
					end
				end)
			end

			local function r1015(s37, s38, s39)
				local function s9()
					return s38 == r996 and s39 == r995 and r994
				end

				r1002()
				local s13 = {}
				local s10 = os.clock()

				for _, s4 in pairs(s37) do
					local s11 = type(s4) == "table" and s4.Uid

					if type(s11) == "string" and type(s4.AssetCategory) == "string" then
						local s7 = r1000(s4.AssetCategory)

						if r989.Eggs and r1011(s4, s7) then
							s13[s11] = true
							local s6 = r990[s11]

							if not s6 then
								s6 = r1007()
								r990[s11] = s6
							end

							r1012(s6, s4, s7)
						end
					end

					if not (r977 < os.clock() - s10) then
						continue
					end
					r137.Heartbeat:Wait()
					s10 = os.clock()
					if not s9() then
						return
					end
				end

				if r989.Eggs and r989.OwnBase then
					for _, s7_1 in ipairs(r1010()) do
						local s4_1 = r1000(s7_1.AssetCategory)

						if r1011(s7_1, s4_1) then
							s13[s7_1.Uid] = true
							local s9_1 = r990[s7_1.Uid]

							if not s9_1 then
								s9_1 = r1007()
								r990[s7_1.Uid] = s9_1
							end

							r1012(s9_1, s7_1, s4_1)
						end
					end
				end

				for s9_2, s10_1 in pairs(r990) do
					if not s13[s9_2] then
						r990[s9_2] = nil
						r1013(s10_1)
					end
				end

				return true
			end

			local r1016 = false
			local r1017 = false

			r1018 = function()
				if not r994 or not r993 then
					return
				end
				r1016 = true
				if r1017 then
					return
				end
				r1017 = true

				task.defer(function()
					while r994 and r993 and r1016 do
						r1016 = false
						r996 += 1
						local t6_1, t7_1 = pcall(r1015, r993, r996, r995)

						if t6_1 and t7_1 ~= true then
							r1016 = true
						end

						r137.Heartbeat:Wait()
					end

					r1017 = false
				end)
			end

			local function r1019()
				local s9 = r995

				if r993 and next(r990) == nil then
					r1018()
				end

				local s4_1 = r234.EggState
				local s5 = type(s4_1) == "table" and type(s4_1.ReadFieldEggs) == "function"
				local s7 = nil

				if s5 then
					local s3_1, s4_2 = pcall(s4_1.ReadFieldEggs)
					s3_1 = s3_1 and type(s4_2) == "table" and type(s4_2.Records) == "table"
					s7 = nil

					if s3_1 then
						s7 = s4_2.Records
					end
				end

				if s7 == nil and r198_1 and os.clock() >= r6_37 then
					r6_37 = os.clock() + 30
					local s3_3, s4_3 = pcall(r198_1.InvokeServer, r198_1)

					if s3_3 and type(s4_3) == "table" and type(s4_3.Records) == "table" then
						s7 = s4_3.Records
					end
				end

				if s9 ~= r995 or not r994 then
					return
				end

				if s7 ~= nil then
					local s9_1 = {}

					for s4_4, s5_1 in pairs(s7) do
						s9_1[s4_4] = s5_1
					end

					r993 = s9_1
				end

				if r993 then
					r1018()
				end
			end

			local function r1020()
				task.spawn(pcall, r1019)
			end

			local function r1021()
				if r997 then
					return
				end
				r997 = true

				task.delay(0.5, function()
					r997 = false

					if r994 then
						r1020()
					end
				end)
			end

			r1022 = function()
				for _, s4 in pairs(r990) do
					r1006(s4)
				end
			end

			local function r1023()
				r994 = false
				r995 += 1
				r996 += 1
				r951.DisconnectAll(r992)
				r1014()
			end

			local function r1024()
				if r994 then
					r1020()
					return
				end
				r994 = true
				local s16 = r995
				local s14 = r234.EggState

				if type(s14) == "table" then
					for _, s7 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
						local s12 = s14[s7]

						if type(s12) == "table" and type(s12.Connect) == "function" then
							local s10_1, s11_1 = pcall(s12.Connect, s12, r1021)

							if s10_1 and s11_1 then
								table.insert(r992, s11_1)
							end
						end
					end
				end

				for _, s10 in ipairs({ "AreaEggSlotsClient", "PlacedEggRenders" }) do
					local s11 = workspace:FindFirstChild(s10)

					if s11 then
						table.insert(r992, s11.ChildAdded:Connect(r1021))
						table.insert(r992, s11.ChildRemoved:Connect(r1021))
					end
				end

				task.spawn(function()
					while s16 == r995 do
						task.wait(10)
						if s16 == r995 then
							r1021()
							continue
						end
						break
					end
				end)

				task.spawn(function()
					while s16 == r995 do
						task.wait(1)

						if s16 == r995 then
							if r989.Info.Distance then
								r1018()
							end

							continue
						end

						break
					end
				end)

				r1020()
			end

			local function r1025()
				if r989.Eggs then
					r1024()
				else
					r1023()
				end
			end

			r1026 = { Eggs = nil }
			local r1027 = { Eggs = false }
			local r1028 = false

			local function r1029()
				if r1028 then
					return
				end
				local s5 = r951.ReadToggle(r1026.Eggs, r1027.Eggs)
				if s5 == r989.Eggs and r994 == s5 then
					return
				end
				r989.Eggs = s5
				r1025()
			end

			r240(function()
				r1028 = true
				r989.Eggs = false
				r1023()
			end)

			local function r1030(s31)
				local s4 = {}

				if type(s31) == "table" then
					for s2, s3 in pairs(s31) do
						s2 = s3 == true and type(s2) == "string" and s2 or type(s3) == "string" and s3
						local s5_1 = s2 or nil

						if s5_1 then
							s4[s5_1] = true
						end
					end
				end

				return s4
			end

			r1026.Eggs = r22_2:CreateToggle({
				Name = "ESP Eggs",
				Default = false,
				Callback = function(arg1)
					r1027.Eggs = arg1 == true
					r951.SyncSoon(r1029)
				end,
			})

			r22_2:CreateToggle({
				Name = "ESP Fixed Size",
				Default = false,
				SubOf = r1026.Eggs,
				Callback = function(arg1)
					local s2 = arg1 == true

					if r989.FixedSize ~= s2 then
						r989.FixedSize = s2
						r1022()
					end
				end,
			})

			r22_2:CreateToggle({
				Name = "ESP Own Base Eggs",
				Note = "Also show the eggs placed in your own base",
				Default = true,
				SubOf = r1026.Eggs,
				Callback = function(arg1)
					r989.OwnBase = arg1 ~= false
					r1018()
				end,
			})

			local r199_1 = { "Any" }
			local r20_5 = { Any = 0 }
			local r16_8 = {}
			local r1031 = {}
			local r200_1 = { "Any Mutation", "No Mutation" }
			local r116 = r234.Assets and r234.Assets.Directory
			local r2_48 = {}
			local r125 = {}

			if type(r116) == "table" then
				for r116_1, r117 in pairs(r116) do
					local r12_45 = type(r117) == "table" and r117.Rarity or nil
					local r1034 = type(r12_45) == "table"

					if r1034 then
						r1034 = tonumber(r12_45.RarityNumber or r12_45.Rank)
					end

					r1034 = r1034 or nil

					if r1034 then
						local r12_46 = tostring(r12_45.DisplayName or r12_45._id or r1034)
						r2_48[r1034] = r2_48[r1034] or r12_46

						table.insert(r125, {
							Category = tostring(r116_1),
							Name = tostring(r117.DisplayName or r116_1),
							Rarity = r1034,
							RarityName = r12_46,
						})
					end
				end
			end

			local r122 = {}

			for r119 in pairs(r2_48) do
				table.insert(r122, r119)
			end

			table.sort(r122)

			for _, r123 in ipairs(r122) do
				local r12_28 = string.format("%d - %s", r123, r2_48[r123])
				table.insert(r199_1, r12_28)
				r20_5[r12_28] = r123
			end

			table.sort(r125, function(s26, s27)
				if s26.Rarity ~= s27.Rarity then
					return s26.Rarity > s27.Rarity
				end
				return s26.Name < s27.Name
			end)

			for _, r126 in ipairs(r125) do
				local r156_2 = string.format("%s [%s]", r126.Name, r126.RarityName)

				if r1031[r156_2] then
					r156_2 = string.format("%s [%s] (%s)", r126.Name, r126.RarityName, r126.Category)
				end

				table.insert(r16_8, r156_2)
				r1031[r156_2] = r126.Category
			end

			local r131 = {}
			local r2_49 = r234.Mutations

			if type(r2_49) == "table" and type(r2_49.IdSet) == "table" then
				for r128 in pairs(r2_49.IdSet) do
					table.insert(r131, tostring(r128))
				end
			end

			table.sort(r131)

			for _, r132 in ipairs(r131) do
				table.insert(r200_1, r132)
			end

			local function r2_50(s29)
				for _, s3 in ipairs(r199_1) do
					if r20_5[s3] == s29 then
						return s3
					end
				end

				return r199_1[1]
			end

			r22_2:CreateDropdown({
				Name = "ESP Min Rarity",
				Note = "Show eggs of the chosen rarity and every rarity above it",
				Options = r199_1,
				Default = r2_50(5),
				SubOf = r1026.Eggs,
				Callback = function(s21)
					r989.MinRarity = r20_5[type(s21) == "table" and s21[1] or s21] or 0
					r1018()
				end,
			})

			r243(r22_2:CreateMultiDropdown({
				Name = "ESP Show Info",
				Options = r10_19,
				Default = r1_44,
				SubOf = r1026.Eggs,
				Callback = function(s6)
					r989.Info = r1030(s6)
					r1018()
				end,
			}))
		end

		do
			local r1_45 = {
				["K/s"] = { Min = 0, Max = 1000, Mult = 1000 },
				["M/s"] = { Min = 0, Max = 1000, Mult = 1000000 },
				["B/s"] = { Min = 0, Max = 100, Mult = 1e9 },
			}

			local r2_51 = 0
			local r10_20 = "M/s"

			local function r12_30(s19, s20)
				if s19 ~= nil then
					r2_51 = math.max(0, math.floor(tonumber(s19) or r2_51))
				end

				if s20 ~= nil then
					r10_20 = tostring(s20)
				end

				r989.MinValue = r2_51 * (r1_45[r10_20] or r1_45["M/s"]).Mult
				r1018()
			end

			r192(r22_2, {
				Name = "Min ESP Value",
				SubOf = r1026.Eggs,
				Legacy = "ESP Min Value",
				SectionName = "ESP",
				OnRaw = function(arg1)
					r12_30(math.floor(arg1 / 1000), "K/s")
				end,
			})
		end

		r22_2:CreateSlider({
			Name = "ESP Egg Size",
			Min = 50,
			Max = 200,
			Default = 75,
			Increment = 5,
			Unit = "%",
			SubOf = r1026.Eggs,
			Callback = function(s23)
				local s1 = tonumber(s23)

				if s1 and r989.SizeScale ~= s1 / 100 then
					r989.SizeScale = s1 / 100
					r1022()
				end
			end,
		})

		do
			local r6_38 = 1
			local r10_21 = 0.75

			local r11_28 = {
				Sleeping = r951.Palettes.Accent,
				Waking = r951.Palettes.Gold,
				Chasing = r951.Palettes.Red,
			}

			local r12_31 = r951.Palettes.Orange
			local r1066 = {}
			local r1067 = {}
			local r1068 = false
			local r1069 = nil

			local function r1070(s9)
				local s11 = s9:GetAttribute("GuardState")
				if s11 == "Sleeping" then
					return "Sleeping"
				end

				if s11 == "Waking" then
					return "Waking Up"
				end

				if s11 == "Chasing" then
					local s11_1 = s9:GetAttribute("TargetPlayer")
					if s11_1 == tostring(r232.UserId) then
						return "Chasing You"
					end
					local s4 = tonumber(s11_1) and r136:GetPlayerByUserId(tonumber(s11_1))
					return s4 and "Chasing " .. s4.DisplayName or "Chasing"
				end

				return s11 and tostring(s11) or "Awake"
			end

			local function r1071(s37, s38)
				local s40 = r11_28[s38:GetAttribute("GuardState")] or r12_31
				s37.Highlight.FillColor = s40.Outline
				s37.Highlight.OutlineColor = s40.Outline
				r951.SetRow(s37.StateRow, r1070(s38), s40)
			end

			local function r1072(arg1)
				local s5 = math.floor
				arg1.Tag.Size = UDim2.fromOffset(r951.ScaledWidth(115, r10_21), s5(r951.RowHeight(r10_21) * 1.6))
			end

			local function r1073(s20)
				local s2 = r1066[s20]
				if not s2 then
					return
				end
				r1066[s20] = nil
				r951.DisconnectAll(s2.Connections)
				s2.Highlight:Destroy()
				s2.Tag:Destroy()
			end

			local function r1074(s31, s32)
				if r1066[s32] then
					return
				end
				local s2 = r951.FindGuardRoot(s32)
				if not s2 then
					return
				end

				if not r1069 or not r1069.Parent then
					r1069 = r951.CreateRuntime()
				end

				local s6 = Instance.new("Highlight")
				s6.Name = r238()
				s6.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				s6.FillTransparency = 0.76
				s6.OutlineTransparency = 0.02
				s6.Adornee = s32
				s6.Parent = r1069
				local s33, s34, s35 = pcall(s32.GetBoundingBox, s32)
				s33 = s33 and typeof(s34) == "CFrame"
				local s38 = 6

				if s33 then
					s38 = s34.Position.Y + s35.Y * 0.5 - s2.Position.Y + r6_38
				end

				local s34_1, s35_1 = r951.CreateTag(r1069, math.huge)
				s34_1.Adornee = s2
				s34_1.StudsOffsetWorldSpace = Vector3.new(0, s38, 0)
				local s2_1 = r951.CreateTextRow(s35_1, r951.StatusFont, 1, 0.45)
				local s4 = r951.CreateTextRow(s35_1, r951.StatusFont, 2, 0.55)
				local s36 = r951.Palettes.Sheen
				r951.SetRow(s2_1, tostring(s31) .. " Guard", s36)
				local s7 = { Highlight = s6, Tag = s34_1, StateRow = s4, Connections = {} }
				r1066[s32] = s7
				r1072(s7)
				r1071(s7, s32)

				local function s2_2()
					r1071(s7, s32)
				end

				table.insert(s7.Connections, s32:GetAttributeChangedSignal("GuardState"):Connect(s2_2))
				table.insert(s7.Connections, s32:GetAttributeChangedSignal("TargetPlayer"):Connect(s2_2))

				table.insert(s7.Connections, s32.AncestryChanged:Connect(function()
					if not s32:IsDescendantOf(workspace) then
						r1073(s32)
					end
				end))
			end

			local function r1075()
				r1068 = false
				r951.DisconnectAll(r1067)

				for s6 in pairs(r1066) do
					r1073(s6)
				end

				if r1069 then
					r1069:Destroy()
					r1069 = nil
				end
			end

			local function r1076()
				if r1068 then
					return
				end
				r1068 = true
				r1067 = r951.WatchGuards(r1074)
			end

			local r1_46 = nil
			local r1077 = false
			local r1078 = false

			local function r1079()
				if r1078 then
					return
				end

				if r951.ReadToggle(r1_46, r1077) then
					r1076()
				elseif r1068 then
					r1075()
				end
			end

			r240(function()
				r1078 = true
				r1075()
			end)

			r1_46 = r22_2:CreateToggle({
				Name = "ESP Guards",
				Default = false,
				Callback = function(arg1)
					r1077 = arg1 == true
					r951.SyncSoon(r1079)
				end,
			})

			r22_2:CreateSlider({
				Name = "ESP Guard Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = r1_46,
				Callback = function(s22)
					local s2 = tonumber(s22)

					if s2 and r10_21 ~= s2 / 100 then
						r10_21 = s2 / 100

						for _, s4 in pairs(r1066) do
							r1072(s4)
						end
					end
				end,
			})
		end

		do
			local r199_2 = {
				{ Id = "LostPart1", Label = "Mechanical Gear" },
				{ Id = "LostPart2", Label = "Wiring Harness" },
			}

			local r6_39 = r951.PaletteFromColor(Color3.fromRGB(255, 216, 61))
			local r10_22 = r951.Palettes.Accent
			local r11_29 = nil
			local r12_32 = {}
			local r1091 = false
			local r1092 = nil
			local r1_47 = nil
			local r1093 = false
			local r1094 = false

			local function r1095(s24)
				local s2 = r12_32[s24]
				if not s2 then
					return
				end
				r12_32[s24] = nil

				pcall(function()
					s2.Highlight:Destroy()
					s2.Tag:Destroy()
				end)
			end

			local function r1096()
				local s21 = workspace:FindFirstChild("DrScrambleEvent")

				for _, s3 in ipairs(r199_2) do
					local s12 = s21 and s21:FindFirstChild(s3.Id)
					local s10 = s12 and (s12:FindFirstChild("Hitbox", true) or s12.PrimaryPart or s12:FindFirstChildWhichIsA("BasePart", true))
					local s8 = r12_32[s3.Id]

					if s8 and (s8.Model ~= s12 or not s10) then
						r1095(s3.Id)
						s8 = nil
					end

					if s10 and not s8 then
						if not r11_29 or not r11_29.Parent then
							r11_29 = r951.CreateRuntime()
						end

						local s22 = Instance.new("Highlight")
						s22.Name = r238()
						s22.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						s22.FillTransparency = 0.7
						s22.OutlineTransparency = 0.02
						s22.Adornee = s12
						s22.Parent = r11_29
						local s15, s16 = r951.CreateTag(r11_29, 25000)
						s15.Adornee = s10
						s15.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
						local s7 = math.floor
						s15.Size = UDim2.fromOffset(r951.ScaledWidth(160), s7(r951.RowHeight() * 1.6))
						local s6_1 = r951.CreateTextRow(s16, r951.StatusFont, 1, 0.5)
						local s7_1 = r951.CreateTextRow(s16, r951.StatusFont, 2, 0.5)
						r951.SetRow(s6_1, s3.Label, r951.Palettes.Sheen)
						s8 = { Model = s12, Hitbox = s10, Highlight = s22, Tag = s15, InfoRow = s7_1 }
						r12_32[s3.Id] = s8
					end

					if s8 then
						local s5_3 = type(r247.ScrambleLostPart) == "function" and r247.ScrambleLostPart(s3.Id) == true
						local s6_2 = s5_3 and r10_22 or r6_39
						r951.SetRow(s8.InfoRow, s5_3 and "Collected" or string.format("%d studs", math.floor(r247.DistanceTo(s8.Hitbox.Position))), s6_2)
						s8.Highlight.FillColor = s6_2.Outline
						s8.Highlight.OutlineColor = s6_2.Outline
					end
				end
			end

			local function r1097()
				r1091 = false

				if r1092 then
					r1092:Disconnect()
					r1092 = nil
				end

				for s3 in pairs(r12_32) do
					r1095(s3)
				end

				if r11_29 then
					r11_29:Destroy()
					r11_29 = nil
				end
			end

			local function r1098()
				if r1091 then
					return
				end
				r1091 = true
				local s11 = 1

				r1092 = r137.Heartbeat:Connect(function(arg1)
					s11 += arg1

					if s11 >= 0.3 then
						s11 = 0
						pcall(r1096)
					end
				end)
			end

			local function r1099()
				if r1094 then
					return
				end

				if r951.ReadToggle(r1_47, r1093) then
					r1098()
				elseif r1091 then
					r1097()
				end
			end

			r240(function()
				r1094 = true
				r1097()
			end)

			r1_47 = r22_2:CreateToggle({
				Name = "ESP Lost Parts",
				Default = false,
				Callback = function(arg1)
					r1093 = arg1 == true
					r951.SyncSoon(r1099)
				end,
			})
		end

		local r199_3, r5_45, r2_53, r10_23, r15_11, r16_9, r1103, r1104, r1106, r1108
		local r1109, r1_48, r1110, r1111

		do
			local r158_1 = game:GetService("TextService")
			r199_3 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
			local r5_44 = ColorSequence.new
			local r2_52 = {}
			local r200_2 = ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 255, 205))
			local r201 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 225, 255))
			r2_52[1] = r200_2
			r2_52[2] = r201

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 135, 255)))
				table.move(values, 1, values.n, 3, r2_52)
			end

			r5_45 = r5_44(r2_52)

			r2_53 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 73, 66)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 17, 79)),
			})

			r10_23 = false
			r15_11 = 0
			r16_9 = nil
			r1103 = {}
			r1104 = {}
			r1106 = {}
			local r1107 = {}
			r1108 = 0.75
			r1109 = { Name = true, Username = false, Avatar = false, Tool = true }
			r1_48 = nil
			r1110 = false
			r1111 = false

			local function r1112(arg1)
				local s3_1 = tostring(arg1 or "")
				if s3_1:match("^%d+$") then
					return "rbxassetid://" .. s3_1
				end
				return s3_1
			end

			local function r1113(s2)
				if not s2 or not s2:IsA("Tool") then
					return ""
				end
				local s17 = r1112(s2.TextureId)
				if s17 ~= "" then
					return s17
				end

				for _, s6 in ipairs({ "Icon", "Image", "Thumbnail", "TextureId" }) do
					local s7 = s2:GetAttribute(s6)
					if type(s7) == "string" and r1112(s7) ~= "" then
						return r1112(s7)
					end
				end

				for _, s9 in ipairs(s2:GetDescendants()) do
					if s9:IsA("Decal") or s9:IsA("Texture") then
						s17 = r1112(s9.Texture)
					elseif s9:IsA("ImageLabel") or s9:IsA("ImageButton") then
						s17 = r1112(s9.Image)
					end

					if s17 ~= "" then
						return s17
					end
				end

				return ""
			end

			local function r1114()
				local s2 = workspace.CurrentCamera
				return math.max(1, math.floor(math.clamp((s2 and s2.ViewportSize.Y or 1080) * 0.024, 26, 35) * r1108))
			end

			local function r1115(s30, s31)
				local s8 = s30 .. "@" .. s31
				local s1 = r1107[s8]
				if s1 then
					return s1
				end
				local s6 = Instance.new("GetTextBoundsParams")
				s6.Text = s30
				s6.Font = r199_3
				s6.Size = s31
				s6.Width = 1000

				local s1_1, s2 = pcall(function()
					return r158_1:GetTextBoundsAsync(s6)
				end)

				s6:Destroy()
				s1_1 = s1_1 and s2.X
				local s2_2

				if s1_1 then
					s2_2 = s1_1
				else
					s2_2 = (utf8.len(s30) or #s30) * s31 * 0.56
				end

				r1107[s8] = s2_2
				return s2_2
			end

			local function r1116(s12, s13, s14, s15)
				s12.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				s12.Color = s13
				s12.LineJoinMode = Enum.LineJoinMode.Round
				s12.Transparency = 0

				s12.Thickness = pcall(function()
					s12.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end) and s14 or s15
			end

			local function r1117(s22, s23)
				local s1 = Instance.new("TextLabel")
				s1.Name = r238()
				s1.AnchorPoint = Vector2.new(0, 0.5)
				s1.BackgroundTransparency = 1
				s1.FontFace = r199_3
				s1.Text = ""
				s1.TextScaled = true
				s1.TextStrokeTransparency = 1
				s1.TextXAlignment = Enum.TextXAlignment.Center
				s1.TextYAlignment = Enum.TextYAlignment.Center
				s1.ZIndex = s23
				s1.Parent = s22
				return s1
			end

			local function r1118(s21, s22)
				local s1 = Instance.new("ImageLabel")
				s1.Name = r238()
				s1.AnchorPoint = Vector2.new(0, 0.5)
				s1.BackgroundTransparency = 1
				s1.ScaleType = Enum.ScaleType.Fit
				s1.ZIndex = s22
				s1.Parent = s21
				local s3 = Instance.new("UIAspectRatioConstraint")
				s3.Name = r238()
				s3.AspectRatio = 1
				s3.Parent = s1
				return s1
			end

			local function r1119(s4)
				local s12 = r1114()
				local s13 = r1109.Name == true or r1109.Username == true
				local s14 = r1109.Avatar == true
				local s15 = r1109.Tool == true and s4.ToolIcon.Image ~= ""
				local s17 = s14 and math.floor(s12 * 0.72) or 0
				local s18 = s15 and math.floor(s12 * 0.82) or 0
				local s7 = math.floor(s12 * 0.7)
				local s9 = math.max(1, math.floor(s12 * 0.04))
				local s6 = r1109.Username == true and s4.Player.Name or s4.Player.DisplayName
				s4.Name.Text = s6
				s4.Shadow.Text = s6
				local s2 = s13 and math.floor(math.clamp(r1115(s6, s7) + 4, s7, 230)) or 0
				local s10 = 0
				local s6_1 = 0

				if s14 then
					s10 = 0 + s17
				end

				local s5 = 0

				if s13 then
					if not (s10 > 0) then
						s5 = s10
					else
						s5 = s10 + s9
					end

					s10 = s5 + s2
				end

				local s20 = 0

				if s15 then
					if not (s10 > 0) then
						s20 = s10
					else
						s20 = s10 + s9
					end

					s10 = s20 + s18
				end

				local s9_1 = math.max(s10, 1)
				local s11 = 1 / s9_1
				local s22 = 1 / s12
				s4.Billboard.Size = UDim2.fromOffset(s9_1, s12)
				s4.Avatar.Visible = s14
				s4.Name.Visible = s13
				s4.Shadow.Visible = s13
				s4.ToolIcon.Visible = s15
				s4.ToolShadow.Visible = s15
				s4.Avatar.Position = UDim2.fromScale(s6_1 / s9_1, 0.5)
				s4.Avatar.Size = UDim2.fromScale(s17 / s9_1, s17 / s12)
				s4.Name.Position = UDim2.fromScale(s5 / s9_1, 0.5)
				s4.Name.Size = UDim2.fromScale(s2 / s9_1, s7 / s12)
				s4.Shadow.Position = UDim2.fromScale(s5 / s9_1 + s11, 0.5 + s22)
				s4.Shadow.Size = s4.Name.Size
				s4.ToolIcon.Position = UDim2.fromScale(s20 / s9_1, 0.5)
				s4.ToolIcon.Size = UDim2.fromScale(s18 / s9_1, s18 / s12)
				s4.ToolShadow.Position = UDim2.fromScale(s20 / s9_1 + s11, 0.5 + s22)
				s4.ToolShadow.Size = s4.ToolIcon.Size
			end

			local function r1120(s2, s3, s4, s5)
				local s17 = Instance.new("Highlight")
				s17.Name = r238()
				s17.Adornee = s3
				s17.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				s17.FillColor = Color3.fromRGB(0, 67, 148)
				s17.FillTransparency = 0.76
				s17.OutlineColor = Color3.fromRGB(72, 207, 255)
				s17.OutlineTransparency = 0.02
				s17.Parent = r16_9
				s5 = s5 or s4
				local s3_1 = 3.1

				if s5 ~= s4 then
					s3_1 = math.clamp(s4.Position.Y - s5.Position.Y + 3.1, 3.8, 6)
				end

				local s19 = Instance.new("BillboardGui")
				s19.Name = r238()
				s19.Adornee = s5
				s19.AlwaysOnTop = true
				s19.LightInfluence = 0
				s19.MaxDistance = math.huge
				s19.Size = UDim2.fromOffset(1, 1)
				s19.StudsOffsetWorldSpace = Vector3.new(0, s3_1, 0)
				s19.Parent = r16_9
				local s4_1 = Instance.new("Frame")
				s4_1.Name = r238()
				s4_1.Size = UDim2.fromScale(1, 1)
				s4_1.BackgroundTransparency = 1
				s4_1.Parent = s19
				local s6 = r1118(s4_1, 2)
				s6.ScaleType = Enum.ScaleType.Crop
				local s3_2 = Instance.new("UICorner")
				s3_2.Name = r238()
				s3_2.CornerRadius = UDim.new(1, 0)
				s3_2.Parent = s6
				local s7 = r1117(s4_1, 1)
				s7.TextColor3 = Color3.fromRGB(7, 19, 34)
				s7.TextTransparency = 0.05
				local s8 = r1117(s4_1, 2)
				s8.TextColor3 = Color3.fromRGB(255, 255, 255)
				local s5_1 = Instance.new("UIStroke")
				s5_1.Name = r238()
				r1116(s5_1, Color3.fromRGB(255, 255, 255), 0.044, 1.4)
				s5_1.Parent = s8
				local s3_3 = Instance.new("UIGradient")
				s3_3.Name = r238()
				s3_3.Color = r2_53
				s3_3.Rotation = 90
				s3_3.Parent = s5_1
				local s3_4 = Instance.new("UIGradient")
				s3_4.Name = r238()
				s3_4.Color = r5_45
				s3_4.Rotation = 90
				s3_4.Parent = s8
				local s9 = r1118(s4_1, 1)
				s9.ImageColor3 = Color3.fromRGB(0, 0, 0)
				s9.ImageTransparency = 0.35

				local s4_2 = {
					Player = s2,
					Highlight = s17,
					Billboard = s19,
					Avatar = s6,
					Shadow = s7,
					Name = s8,
					ToolShadow = s9,
					ToolIcon = r1118(s4_1, 2),
				}

				r1119(s4_2)
				return s4_2
			end

			local function r1121(s25)
				if s25.NameHumanoid and s25.NameHumanoid.Parent and s25.NameDistance ~= nil then
					pcall(function()
						s25.NameHumanoid.NameDisplayDistance = s25.NameDistance
					end)
				end

				s25.NameHumanoid = nil
				s25.NameDistance = nil
			end

			local function r1122(s27, s28)
				local s2 = s28 and s28:FindFirstChildOfClass("Humanoid")
				if not s2 then
					return
				end

				if s27.NameHumanoid ~= s2 then
					r1121(s27)
					s27.NameHumanoid = s2
					s27.NameDistance = s2.NameDisplayDistance
				end

				pcall(function()
					s2.NameDisplayDistance = 0
				end)
			end

			local function r1123(s13)
				r951.DisconnectAll(s13.CharacterConnections)

				if s13.Tag then
					pcall(function()
						s13.Tag.Highlight:Destroy()
					end)

					pcall(function()
						s13.Tag.Billboard:Destroy()
					end)

					s13.Tag = nil
				end

				r1121(s13)
				s13.Character = nil
			end

			local function r1124(s31)
				if not s31.Tag or not s31.Character then
					return
				end
				local s1_1 = r1113(s31.Character:FindFirstChildOfClass("Tool"))
				s31.Tag.ToolIcon.Image = s1_1
				s31.Tag.ToolShadow.Image = s1_1
				r1119(s31.Tag)
			end

			local function r1125(s24, s25, s26)
				local s4 = r1106[s25.UserId]

				if s4 == nil then
					local s2, s3_1 = pcall(function()
						return r136:GetUserThumbnailAsync(s25.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					end)

					s4 = s2 and s3_1 or ""
					r1106[s25.UserId] = s4
				end

				if r10_23 and s24.Version == s26 and s24.Tag then
					s24.Tag.Avatar.Image = s4
				end
			end

			local function r1126(s32, s33, s34)
				r1123(s32)
				s32.Version = s32.Version + 1
				local s1 = s32.Version
				if not r10_23 or not s34 then
					return
				end
				s32.Character = s34

				task.spawn(function()
					local t13 = s34:FindFirstChild("Head") or s34:WaitForChild("Head", 5)
					if not r10_23 or s32.Version ~= s1 or not t13 or not t13:IsA("BasePart") or not s34:IsDescendantOf(workspace) then
						return
					end

					if not r16_9 or not r16_9.Parent then
						r16_9 = r951.CreateRuntime()
					end

					local t6_1 = s34:FindFirstChild("HumanoidRootPart")
					s32.Tag = r1120(s33, s34, t13, t6_1 and t6_1:IsA("BasePart") and t6_1 or nil)
					r1122(s32, s34)

					local function t6_2()
						task.defer(function()
							if r10_23 and s32.Version == s1 then
								r1124(s32)
							end
						end)
					end

					table.insert(s32.CharacterConnections, s34.ChildAdded:Connect(function(u26)
						if u26:IsA("Tool") then
							t6_2()
						elseif u26:IsA("Humanoid") then
							r1122(s32, s34)
						end
					end))

					table.insert(s32.CharacterConnections, s34.ChildRemoved:Connect(function(arg1)
						if arg1:IsA("Tool") then
							t6_2()
						end
					end))

					table.insert(s32.CharacterConnections, s34.AncestryChanged:Connect(function()
						if s32.Version == s1 and not s34:IsDescendantOf(workspace) then
							s32.Version = s32.Version + 1
							r1123(s32)
						end
					end))

					r1124(s32)
					r1125(s32, s33, s1)
				end)
			end

			local function r1127(s23)
				local s1 = r1103[s23]
				if not s1 then
					return
				end
				s1.Version = s1.Version + 1
				r1123(s1)
				r951.DisconnectAll(s1.PlayerConnections)
				r1103[s23] = nil
			end

			local function r1128(s24)
				if s24 == r232 or r1103[s24] then
					return
				end

				local s23 = {
					Version = 0,
					Character = nil,
					Tag = nil,
					NameHumanoid = nil,
					NameDistance = nil,
					CharacterConnections = {},
					PlayerConnections = {},
				}

				r1103[s24] = s23

				table.insert(s23.PlayerConnections, s24.CharacterAdded:Connect(function(t32)
					r1126(s23, s24, t32)
				end))

				table.insert(s23.PlayerConnections, s24.CharacterRemoving:Connect(function(arg1)
					if s23.Character == arg1 then
						s23.Version = s23.Version + 1
						r1123(s23)
					end
				end))

				r1126(s23, s24, s24.Character)
			end

			local function r1129()
				for _, s4 in pairs(r1103) do
					if s4.Tag then
						r1119(s4.Tag)
					end
				end
			end

			local function r1130()
				r10_23 = false
				r15_11 += 1
				r951.DisconnectAll(r1104)
				local s10 = {}

				for s6 in pairs(r1103) do
					table.insert(s10, s6)
				end

				for _, s11 in ipairs(s10) do
					r1127(s11)
				end

				if r16_9 then
					r16_9:Destroy()
					r16_9 = nil
				end
			end

			local function r1131()
				if r10_23 then
					return
				end
				r10_23 = true
				r15_11 += 1
				local s11 = r15_11
				r16_9 = r951.CreateRuntime()

				for _, s4 in ipairs(r136:GetPlayers()) do
					r1128(s4)
				end

				table.insert(r1104, r136.PlayerAdded:Connect(r1128))
				table.insert(r1104, r136.PlayerRemoving:Connect(r1127))
				local s4_1 = workspace.CurrentCamera

				if s4_1 then
					table.insert(r1104, s4_1:GetPropertyChangedSignal("ViewportSize"):Connect(r1129))
				end

				task.spawn(function()
					while true do
						if r10_23 and s11 == r15_11 then
							task.wait(1)

							if not (not r10_23 or s11 ~= r15_11) then
								for t6, t7 in pairs(r1103) do
									local t17 = t6.Character
									local t12 = t7.Tag and t7.Tag.Billboard.Parent and t7.Tag.Billboard.Adornee and t7.Tag.Billboard.Adornee:IsDescendantOf(workspace)

									if t17 and t17:IsDescendantOf(workspace) and (t7.Character ~= t17 or not t12) then
										r1126(t7, t6, t17)
									end
								end

								continue
							end
						end

						break
					end
				end)
			end

			local function r1132()
				if r1111 then
					return
				end

				if r951.ReadToggle(r1_48, r1110) then
					r1131()
				elseif r10_23 then
					r1130()
				end
			end

			r240(function()
				r1111 = true
				r1130()
			end)

			r1_48 = r22_2:CreateToggle({
				Name = "ESP Players",
				Default = false,
				Callback = function(arg1)
					r1110 = arg1 == true
					r951.SyncSoon(r1132)
				end,
			})

			r243(r22_2:CreateMultiDropdown({
				Name = "ESP Player Info",
				Options = { "Name", "Username", "Avatar", "Tool" },
				Default = { "Name", "Tool" },
				SubOf = r1_48,
				Callback = function(s27)
					local s4 = { Name = false, Username = false, Avatar = false, Tool = false }

					if type(s27) == "table" then
						for s2, s3 in pairs(s27) do
							if type(s3) == "string" and s4[s3] ~= nil then
								s4[s3] = true
							elseif type(s2) == "string" and s3 == true and s4[s2] ~= nil then
								s4[s2] = true
							end
						end
					end

					r1109 = s4
					r1129()
				end,
			}))

			r22_2:CreateSlider({
				Name = "ESP Player Size",
				Min = 50,
				Max = 200,
				Default = 75,
				Increment = 5,
				Unit = "%",
				SubOf = r1_48,
				Callback = function(s22)
					local s1 = tonumber(s22)

					if s1 and r1108 ~= s1 / 100 then
						r1108 = math.clamp(s1 / 100, 0.5, 2)
						r1129()
					end
				end,
			})
		end

		r22_3 = 3
		r1135 = 0.002
		r1136 = 4
		r1137 = 0.3
		r1138 = 0.62
		r1139 = 0.86
		r1140 = 4.4262295081967213
		r1141 = 1.392
		r1142 = 1.03
		r201_1 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		r202 = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		r203 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		r204 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		r205 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		r158_2 = game:GetService("TweenService")
		r1_49 = Color3.fromRGB

		r1143 = function(s17)
			local s5 = {}

			for s2, s3 in ipairs(s17) do
				s5[s2] = ColorSequenceKeypoint.new(s3[1], s3[2])
			end

			return ColorSequence.new(s5)
		end

		r1144 = {}

		do
			local r11_30 = {}
			local r6_40 = {}
			local r2_54 = { 0, r1_49(0, 118, 255) }
			local r5_46 = { 1, r1_49(72, 204, 255) }
			r6_40[1] = r2_54
			r6_40[2] = r5_46
			r11_30.Color = r1143(r6_40)
			r11_30.Rotation = -90
			r11_30.Stroke = r1_49(0, 28, 76)
			r11_30.Light = r1_49(172, 226, 255)
			r1144.Hud = r11_30
		end

		do
			local r11_31 = {}
			local r6_41 = {}
			local r2_55 = { 0, r1_49(60, 255, 0) }
			local r5_47 = { 1, r1_49(136, 255, 0) }
			r6_41[1] = r2_55
			r6_41[2] = r5_47
			r11_31.Color = r1143(r6_41)
			r11_31.Rotation = -90
			r11_31.Stroke = r1_49(11, 72, 0)
			r11_31.Light = r1_49(190, 255, 180)
			r1144.Steal = r11_31
		end

		do
			local r11_32 = {}
			local r6_42 = {}
			local r2_56 = { 0, r1_49(118, 118, 132) }
			local r5_48 = { 1, r1_49(172, 172, 186) }
			r6_42[1] = r2_56
			r6_42[2] = r5_48
			r11_32.Color = r1143(r6_42)
			r11_32.Rotation = -90
			r11_32.Stroke = r1_49(28, 28, 34)
			r11_32.Light = r1_49(214, 214, 226)
			r1144.Queued = r11_32
		end
	end

	do
		local r11_33 = {}
		local r6_43 = {}
		local r2_57 = { 0, r1_49(255, 247, 0) }
		local r5_49 = { 1, r1_49(255, 136, 0) }
		r6_43[1] = r2_57
		r6_43[2] = r5_49
		r11_33.Color = r1143(r6_43)
		r11_33.Rotation = 90
		r11_33.Stroke = r1_49(0, 0, 0)
		r11_33.Light = r1_49(132, 112, 0)
		r1144.PriorityOn = r11_33
	end

	do
		local r11_34 = {}
		local r6_44 = {}
		local r2_58 = { 0, r1_49(214, 17, 17) }
		local r5_50 = { 1, r1_49(253, 20, 20) }
		r6_44[1] = r2_58
		r6_44[2] = r5_50
		r11_34.Color = r1143(r6_44)
		r11_34.Rotation = -90
		r11_34.Stroke = r1_49(72, 0, 0)
		r11_34.Light = r1_49(255, 103, 103)
		r1144.Cancel = r11_34
	end

	do
		local r11_35 = {}
		local r212 = {}
		local r2_59 = { 0, r1_49(132, 74, 255) }
		local r5_51 = { 0.34, r1_49(178, 74, 255) }
		local r6_45 = { 0.6, r1_49(255, 104, 206) }
		local r210 = { 0.78, r1_49(255, 168, 232) }
		local r211 = { 1, r1_49(146, 66, 255) }
		r212[1] = r2_59
		r212[2] = r5_51
		r212[3] = r6_45
		r212[4] = r210
		r212[5] = r211
		r11_35.Color = r1143(r212)
		r11_35.Rotation = -115
		r11_35.Stroke = r1_49(44, 10, 80)
		r11_35.Light = r1_49(226, 178, 255)
		r1144.Chilli = r11_35
	end

	local r1145

	do
		local r215 = {}
		local r2_60 = { 0, r1_49(255, 255, 255) }
		local r5_52 = { 0.2, r1_49(206, 212, 224) }
		local r6_46 = { 0.42, r1_49(74, 80, 94) }
		local r212_1 = { 0.58, r1_49(42, 46, 56) }
		local r213 = { 0.78, r1_49(158, 166, 182) }
		local r10_24 = { 1, r1_49(250, 252, 255) }
		r215[1] = r2_60
		r215[2] = r5_52
		r215[3] = r6_46
		r215[4] = r212_1
		r215[5] = r213
		r215[6] = r10_24
		local r2_61 = r1143(r215)
		local r5_53 = {}
		local r6_47 = nil

		r1145 = function(s28)
			local s1 = r5_53[s28]
			if s1 then
				return s1
			end
			local s1_1 = r234.Assets and r234.Assets.Directory
			local s4 = type(s1_1) == "table" and s1_1[s28] or nil
			local s5 = type(s4) == "table" and type(s4.Rarity) == "table" and s4.Rarity or nil
			local s3 = s5 and s5.RarityGradient or nil

			if s5 and typeof(s3) ~= "Instance" then
				if r6_47 == nil then
					local s33 = r181:FindFirstChild("Assets")
					local s2_4 = s33 and s33:FindFirstChild("UI")
					r6_47 = s2_4 and s2_4:FindFirstChild("RarityGradients") or false
				end

				s3 = r6_47

				if r6_47 then
					s3 = r6_47:FindFirstChild(tostring(s5._id or s5.DisplayName or ""))
				end

				s3 = s3 and s3:FindFirstChild("RarityGradient") or nil
			end

			local s6_1

			if s5 then
				s6_1 = tostring(s5.DisplayName or s5._id or "")
			else
				s6_1 = s5
			end

			s6_1 = s6_1 or ""
			local s32 = s5 and typeof(s5.Color) == "Color3" and s5.Color or r1_49(255, 255, 255)
			local s2_2 = r1143({ { 0, s32 }, { 1, s32 } })
			local s6_2

			if string.upper(s6_1) == "SECRET" then
				s6_2 = 90
				s2_2 = r2_61
			else
				local s7_2 = typeof(s3) == "Instance" and s3:IsA("UIGradient")
				s6_2 = 90

				if s7_2 then
					s2_2 = s3.Color
					s6_2 = s3.Rotation
				end
			end

			local s1_7 = type(s4) == "table" and s4.Icon or nil

			if tonumber(s1_7) then
				s1_7 = "rbxassetid://" .. tostring(s1_7)
			end

			local s3_1 = {}
			local s8 = type(s4) == "table"
			local s9

			if s8 then
				s9 = tostring(s4.DisplayName or s28)
			else
				s9 = s8
			end

			s3_1.Name = s9 or tostring(s28)
			s3_1.Icon = s1_7 and tostring(s1_7) or ""

			if s5 then
				s5 = tonumber(s5.RarityNumber or s5.Rank)
			end

			s3_1.RarityNumber = s5 or 0
			s3_1.GradientColor = s2_2
			s3_1.GradientRotation = s6_2
			s3_1.EarningRate = type(s4) == "table" and tonumber(s4.EarningRate) or 0
			r5_53[s28] = s3_1
			return s3_1
		end
	end

	local r1146

	r1146 = function(s15, s16)
		local s2 = tonumber(s15.AssetScale) or 1
		local s6 = s2 > 5 and (s2 / 5) ^ 1.2 * 19.637875755794113 or s2 ^ 1.85
		local s14 = type(s15.Mutations) == "table" and s15.Mutations or {}

		if #s14 == 0 and type(s15.BaseMutation) == "string" and s15.BaseMutation ~= "" then
			s14 = { s15.BaseMutation }
		end

		local s2_2 = r234.Mutations
		local s4_1 = type(s2_2) == "table" and type(s2_2.EarningsFor) == "function"
		local s13 = 1

		if s4_1 then
			local s12
			s12, s13 = pcall(s2_2.EarningsFor, s14)
			s12 = s12 and type(s13) == "number"
			local s2_3 = 1

			if not s12 then
				s13 = s2_3
			end
		end

		return s16.EarningRate * s6 * s13
	end

	local r1147
	local r206 = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx" }

	r1147 = function(s26)
		local s1 = tonumber(s26) or 0
		local s3 = 1

		while s1 >= 1000 and s3 < #r206 do
			s1 /= 1000
			s3 += 1
		end

		local s24 = s3 == 1 and tostring(math.floor(s1)) or string.format("%.1f", math.floor(s1 * 10) / 10)
		local s3_1 = r206[s3] .. "/s"
		return "$" .. string.gsub(s24, "%.0$", "") .. s3_1
	end

	local r1148

	r1148 = function(s22, s23)
		if s22 and s22.Text ~= s23 then
			s22.Text = s23
		end
	end

	local r1149
	r1149 = false
	local r1150
	r1150 = 0
	local r1151
	r1151 = false
	local r1154
	r1154 = nil
	local r1155
	r1155 = nil
	local r1156
	r1156 = nil
	local r1157
	r1157 = nil
	local r1158
	r1158 = nil
	local r1159
	r1159 = nil
	local r1160
	r1160 = nil
	local r1161
	r1161 = nil
	local r1162
	r1162 = nil
	local r1163
	r1163 = nil
	local r1164
	r1164 = nil
	local r1165
	r1165 = false
	local r171_1
	r171_1 = r180:CreateState({ Name = "Steal Panel Open", Default = true })
	local r1166
	r1166 = false
	local r1167
	r1167 = nil
	local r1168
	r1168 = nil
	local r1169
	r1169 = 0
	local r1170
	r1170 = nil
	local r1171
	r1171 = nil
	local r1172
	r1172 = 1
	local r1173
	r1173 = {}
	local r1174
	r1174 = {}
	local r1175
	r1175 = {}
	local r1176, r1177, r1178, r1179, r1180, r1181, r1183, r1184, r1185, r1189
	local r1192, r1193

	do
		local r212_2 = setmetatable({}, { __mode = "k" })
		r1176 = nil
		r1177 = nil
		r1178 = false
		r1179 = false
		r1180 = false
		r1181 = nil

		r1183 = function()
			local s4 = r232:FindFirstChildOfClass("PlayerGui")
			local s5 = s4 and s4:FindFirstChild("HUD")
			local s6 = s5 and s5:FindFirstChild("GameHUD")
			local s7 = s6 and s6:FindFirstChild("RightButtons")
			local s11 = s4 and s4:FindFirstChild("ActivePets")

			local s14 = {
				Hud = s5,
				GameHud = s6,
				Column = s7,
				Eggs = s7 and s7:FindFirstChild("EggsButton"),
				Pets = s7 and s7:FindFirstChild("PetsButton"),
				ActivePets = s11,
				GrowingEggs = s4 and s4:FindFirstChild("GrowingEggs"),
			}

			if not (s5 and s6 and s7 and s14.Eggs and s14.Pets and s11 and s11:FindFirstChild("Frame")) then
				return nil
			end
			return s14
		end

		r1184 = function(s7)
			local s11, s2 = pcall(function()
				return s7:Clone()
			end)

			if not s11 or typeof(s2) ~= "Instance" then
				return nil
			end

			for _, s11_1 in ipairs(s2:GetDescendants()) do
				if s11_1:IsA("LuaSourceContainer") then
					s11_1:Destroy()
				end
			end

			return s2
		end

		r1185 = function(s37)
			s37.Name = r238()

			for _, s3 in ipairs(s37:GetDescendants()) do
				s3.Name = r238()
			end
		end

		local r1186 = 2.3120369911193848
		local r1187 = 556
		local r1188 = 86.24
		r1189 = { Panel = r1186, Hud = r1186 }

		local function r1190(arg1)
			if arg1 then
				local s3_1 = r1159 and r1159.AbsoluteSize.X or 0
				return s3_1 > 0 and r1186 * s3_1 / r1187 or nil
			end
			local s3 = r1156 and r1156.Button
			s3 = s3 and s3.Size.X.Offset or 0
			return s3 > 0 and r1186 * s3 / r1188 or nil
		end

		local function r1191(s34, s35)
			local s2 = r1190(s35.Panel)

			if s2 and s34.Parent then
				s34.Thickness = s35.Ratio * s2
			end
		end

		r1192 = function(s30, s31)
			local s5 = s31 and r1189.Panel or r1189.Hud

			if not s5 or s5 <= 0 then
				s5 = 2.3120369911193848
			end

			for _, s3 in ipairs(s30:GetDescendants()) do
				if s3:IsA("UIStroke") then
					local s32, s33 = pcall(function()
						return s3.StrokeSizingMode
					end)

					if not s32 or s33 ~= Enum.StrokeSizingMode.ScaledSize then
						local s4_1 = { Ratio = s3.Thickness / s5, Panel = s31 == true }
						r212_2[s3] = s4_1
						r1191(s3, s4_1)
					end
				end
			end
		end

		r1193 = function()
			for s3, s4 in pairs(r212_2) do
				r1191(s3, s4)
			end
		end
	end

	local r1194

	r1194 = function()
		r1193()
	end

	local r1195

	r1195 = function(s23)
		if not s23 then
			return nil
		end

		return {
			Button = s23,
			Gradient = s23:FindFirstChildOfClass("UIGradient"),
			Stroke = s23:FindFirstChild("UIStroke"),
			Light = s23:FindFirstChild("UIStrokeClr"),
			Label = s23:FindFirstChild("Label") or s23:FindFirstChild("TextLabel"),
			Scale = s23:FindFirstChild("BtnScale"),
		}
	end

	local r1196

	r1196 = function(s7, s8)
		if not s7 or s7.Style == s8 then
			return
		end
		s7.Style = s8

		if s7.Gradient then
			s7.Gradient.Color = s8.Color
			s7.Gradient.Rotation = s8.Rotation
		end

		if s7.Stroke then
			s7.Stroke.Color = s8.Stroke
		end

		if s7.Light then
			s7.Light.Color = s8.Light
		end
	end

	local r1197

	r1197 = function(s27)
		if not s27 then
			return
		end
		local s2 = s27.Scale

		if not s2 then
			s2 = Instance.new("UIScale")
			s2.Parent = s27.Button
			s27.Scale = s2
		end

		local function s3(arg1)
			r158_2:Create(s2, r205, { Scale = arg1 }):Play()
		end

		s27.Button.MouseEnter:Connect(function()
			s3(1.08)
		end)

		s27.Button.MouseLeave:Connect(function()
			s3(1)
		end)

		s27.Button.MouseButton1Down:Connect(function()
			s3(0.94)
		end)

		s27.Button.MouseButton1Up:Connect(function()
			s3(1.08)
		end)
	end

	local r1203

	do
		local r10_25 = TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local r11_36 = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local r12_33 = TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local r1202 = {}

		r1203 = function(s29)
			for _, s4 in ipairs(r1202) do
				pcall(function()
					s4:Cancel()
				end)
			end

			table.clear(r1202)
			if not s29 then
				return
			end

			local function s7(t21)
				r1202[#r1202 + 1] = t21
				t21:Play()
			end

			local s32 = s29.Gradient

			if s32 then
				s32.Rotation = -115
				s32.Offset = Vector2.new(-0.30000001192092896, 0)
				s7(r158_2:Create(s32, r10_25, { Offset = Vector2.new(0.30000001192092896, 0) }))
				s7(r158_2:Create(s32, r11_36, { Rotation = -65 }))
			end

			local s32_1 = s29.Light

			if s32_1 then
				s32_1.Color = r1_49(226, 178, 255)
				s7(r158_2:Create(s32_1, r12_33, { Color = r1_49(255, 245, 255) }))
			end
		end
	end

	do
		local r1204 = setthreadidentity or set_thread_identity

		local function r1205()
			local s9 = r234.EggState

			if type(s9) == "table" and type(s9.ReadFieldEggs) == "function" then
				local s2_1 = nil

				task.spawn(function()
					local t2, t3 = pcall(s9.ReadFieldEggs)

					if t2 and type(t3) == "table" and type(t3.Records) == "table" and next(t3.Records) ~= nil then
						s2_1 = t3.Records
					end
				end)

				if type(r1204) == "function" then
					pcall(r1204, 8)
				end

				if s2_1 then
					return s2_1
				end
			end

			local s7 = r182:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
			if not s7 or not s7:IsA("RemoteFunction") then
				return nil
			end
			local s2_3 = false
			local s3 = nil

			task.spawn(function()
				local t5, t6 = pcall(s7.InvokeServer, s7)

				if t5 and type(t6) == "table" and type(t6.Records) == "table" then
					s3 = t6.Records
				end

				s2_3 = true
			end)

			local s11_1 = os.clock()

			while not s2_3 and os.clock() - s11_1 < r1136 do
				r137.Heartbeat:Wait()
			end

			return s3
		end

		local function r1206()
			local s4 = r1154 ~= nil

			if s4 then
				s4 = r1154.ActivePets and r1154.ActivePets.Enabled or r1154.GrowingEggs and r1154.GrowingEggs.Enabled
			end

			return s4 or false
		end

		local function r1207()
			local s13 = false

			for _, s4 in ipairs({ r1154.ActivePets, r1154.GrowingEggs }) do
				if s4 and s4.Enabled then
					local s10 = s4:FindFirstChild("Frame")
					s10 = s10 and s10:FindFirstChild("Close")
					local s5 = s10 and typeof(getconnections) == "function"
					local s11 = false

					if s5 then
						local s8, s10_1 = pcall(getconnections, s10.Activated)

						if s8 and type(s10_1) == "table" then
							for _, s7 in ipairs(s10_1) do
								if pcall(function()
									s7:Fire()
								end) then
									s11 = true
								end
							end
						end
					end

					if not s11 then
						s4.Enabled = false
					end

					s13 = true
				end
			end

			return s13
		end

		local function r1208(s25, s26)
			local s30 = r1154 and r1154.Column
			if not s30 or not s30.Parent then
				return
			end

			if r1168 then
				r1168:Cancel()
				r1168 = nil
			end

			local s1_1 = s30.Position
			local s6_1 = UDim2.new(s1_1.X.Scale, s25 and math.ceil(s30.AbsoluteSize.X * r1142) or 0, s1_1.Y.Scale, s1_1.Y.Offset)
			if s26 then
				s30.Position = s6_1
				return
			end
			r1168 = r158_2:Create(s30, s25 and r203 or r204, { Position = s6_1 })
			r1168:Play()
		end

		local r1211 = 0.106
		local r13_10 = UDim2.new(0.955, 0, 0.6, 0)
		local r14_13 = UDim2.new(0.955 - r1211, 0, 0.6, 0)
		local r15_12 = UDim2.new(0.2, 0, 0.56, 0)
		local r1216 = 0.955 - r1211

		local function r1217(s13, s14)
			if s13 and s13.Button.Visible ~= s14 then
				s13.Button.Visible = s14
			end
		end

		local function r1218(s20, s21, s22, s23)
			local s1 = s21 ~= nil
			s20.Rank = s21
			r1217(s20.Steal, not s1)
			r1217(s20.Up, s1)
			r1217(s20.Down, s1)
			r1217(s20.Cancel, s1)

			if s1 then
				r1196(s20.Up, s21 > 1 and r1144.Hud or r1144.Queued)
				r1196(s20.Down, s21 < (s23 or s21) and r1144.Hud or r1144.Queued)
			end

			r1196(s20.Star, s21 == 1 and r1144.PriorityOn or r1144.Queued)

			if s20.Badge then
				if s20.Badge.Visible ~= s1 then
					s20.Badge.Visible = s1
				end

				if s1 then
					r1148(s20.Badge, "#" .. s21)
					s22 = s22 and r1144.Steal or r1144.PriorityOn

					if s20.BadgeStyle ~= s22 and s20.BadgeGradient then
						s20.BadgeStyle = s22
						s20.BadgeGradient.Color = s22.Color
						s20.BadgeGradient.Rotation = 90
					end
				end
			end
		end

		local function r1219()
			if not r1170 then
				return
			end
			local s2 = r247.Toggle(r4_5, false)

			if r1170.On ~= s2 then
				r1170.On = s2
				r1196(r1170.Toggle, s2 and r1144.Steal or r1144.Cancel)
				r1148(r1170.Toggle.Label, s2 and "Auto Steal: ON" or "Auto Steal: OFF")
			end

			local s2_1 = r247.AntiGuard.Enabled == true

			if r1170.Guard and r1170.GuardOn ~= s2_1 then
				r1170.GuardOn = s2_1
				r1196(r1170.Guard, s2_1 and r1144.Steal or r1144.Cancel)
				r1148(r1170.Guard.Label, s2_1 and "Anti Guard: ON" or "Anti Guard: OFF")
			end

			if r1162 and r1170.SortShown ~= r274 then
				r1170.SortShown = r274
				r1148(r1162.Label, "Sort: " .. tostring(r274))
			end
		end

		local r1220 = 4
		local r1221 = {}
		local r1222 = {}

		local function r1223()
			if not r1163 then
				return
			end
			r1219()
			local s9 = {}

			for _, s4 in pairs(r1174) do
				table.insert(s9, s4)
			end

			local s3_1 = {}
			local s12 = nil

			if type(r247.StealPlan) == "function" then
				task.spawn(function()
					local t4, t5, t6 = pcall(r247.StealPlan)

					if t4 and type(t5) == "table" then
						s3_1 = t5
						s12 = t6
					end
				end)
			end

			local s24 = {}

			for s6, s7 in ipairs(s3_1) do
				if s24[s7] == nil then
					s24[s7] = s6
				end
			end

			local s26 = r274

			table.sort(s9, function(t16, t17)
				local t1 = s24[t16.Uid]
				local t3 = s24[t17.Uid]
				if t1 ~= nil ~= t3 ~= nil then
					return t1 ~= nil
				end

				if t1 and t3 then
					return t1 < t3
				end

				if s26 == r7_4[1] and t16.Style.RarityNumber ~= t17.Style.RarityNumber then
					return t16.Style.RarityNumber > t17.Style.RarityNumber
				end
				local t1_2 = s26 == r7_4[2]
				local t3_1

				if t1_2 then
					t3_1 = (t16.Weight or 0) ~= (t17.Weight or 0)
				else
					t3_1 = t1_2
				end

				if t3_1 then
					return (t16.Weight or 0) > (t17.Weight or 0)
				end

				if s26 == r7_4[5] and t16.Value ~= t17.Value then
					return t16.Value < t17.Value
				end

				if t16.Value ~= t17.Value then
					return t16.Value > t17.Value
				end
				return t16.Uid < t17.Uid
			end)

			local s4_1 = os.clock()
			local s2 = {}
			local s15 = {}

			for _, s10 in ipairs(s9) do
				local s5 = r1221[s10.Uid]

				if s5 and s5 > s4_1 and r1222[s10.Uid] then
					table.insert(s15, s10)
				else
					r1221[s10.Uid] = nil
					table.insert(s2, s10)
				end
			end

			table.sort(s15, function(arg1, arg2)
				return r1222[arg1.Uid] < r1222[arg2.Uid]
			end)

			for _, s16 in ipairs(s15) do
				table.insert(s2, math.clamp(r1222[s16.Uid], 1, #s2 + 1), s16)
			end

			table.clear(r1222)

			for s18, s19 in ipairs(s2) do
				r1222[s19.Uid] = s18
				local s5_1 = r1173[s19.Uid]

				if s5_1 then
					if s5_1.Frame.LayoutOrder ~= s18 then
						s5_1.Frame.LayoutOrder = s18
					end

					r1218(s5_1, s24[s19.Uid], s19.Uid == s12, #s3_1)
				end
			end
		end

		local function r1224()
			if not r1163 then
				return
			end
			local s6 = math.max(1, math.floor(r1163.AbsoluteSize.X / r1140 + 0.5))
			if s6 == r1169 then
				return
			end
			r1169 = s6

			for _, s4 in pairs(r1173) do
				s4.Frame.Size = UDim2.new(1, 0, 0, s6)
			end
		end

		local function r1225(s12)
			local s14 = r1164:Clone()
			local s9 = s14:FindFirstChild("Spacer")
			local s6 = s9:FindFirstChild("TextLabel")

			local s16 = {
				Uid = s12,
				Frame = s14,
				Icon = s9:FindFirstChild("Icon"),
				Label = s6,
				ValueLabel = s9:FindFirstChild("Value"),
				DetailLabel = s9:FindFirstChild("Detail"),
			}

			s16.Gradient = s6 and s6:FindFirstChildOfClass("UIGradient")
			s16.Steal = r1195(s9:FindFirstChild("Unequip"))
			s16.Cancel = r1195(s9:FindFirstChild("Cancel"))
			s16.Star = r1195(s9:FindFirstChild("Star"))
			s16.Up = r1195(s9:FindFirstChild("Up"))
			s16.Down = r1195(s9:FindFirstChild("Down"))
			s16.Badge = s9:FindFirstChild("Rank")
			s16.BadgeGradient = s16.Badge and s16.Badge:FindFirstChildOfClass("UIGradient") or nil

			if s6 and not s16.Gradient then
				s16.Gradient = Instance.new("UIGradient")
				s16.Gradient.Parent = s6
			end

			r1197(s16.Steal)
			r1197(s16.Cancel)
			r1197(s16.Star)
			r1197(s16.Up)
			r1197(s16.Down)

			for _, s6_1 in ipairs({ { s16.Up, -1 }, { s16.Down, 1 } }) do
				if s6_1[1] then
					s6_1[1].Button.Activated:Connect(function()
						if type(r247.MoveInPlan) == "function" then
							r247.MoveInPlan(s16.Uid, s6_1[2])
						end

						r247.UiDefer(r1223)
					end)
				end
			end

			if s16.Steal then
				s16.Steal.Button.Activated:Connect(function()
					if s16.Rank == nil and type(r247.StealNow) == "function" then
						r247.StealNow(s16.Uid, false)
					end

					r247.UiDefer(r1223)
				end)
			end

			if s16.Cancel then
				s16.Cancel.Button.Activated:Connect(function()
					r1221[s16.Uid] = os.clock() + r1220

					if type(r247.CancelSteal) == "function" then
						r247.CancelSteal(s16.Uid)
					end

					r247.UiDefer(r1223)
				end)
			end

			if s16.Star then
				s16.Star.Button.Activated:Connect(function()
					if type(r247.PrioritizeSteal) == "function" then
						r247.PrioritizeSteal(s16.Uid)
					end

					r247.UiDefer(r1223)
				end)
			end

			r1192(s14, true)
			r1185(s14)
			s14.Size = UDim2.new(1, 0, 0, math.max(r1169, 1))
			s14.Visible = true
			s14.Parent = r1163
			return s16
		end

		local function r1226(s31, s32)
			local s1 = s32.Style

			if s31.Category ~= s32.Category then
				s31.Category = s32.Category

				if s31.Icon then
					s31.Icon.Image = s1.Icon
				end

				if s31.Gradient then
					s31.Gradient.Color = s1.GradientColor
					s31.Gradient.Rotation = s1.GradientRotation
				end
			end

			r1148(s31.Label, s1.Name)
			r1148(s31.ValueLabel, r1147(s32.Value))
			r1148(s31.DetailLabel, s32.Detail or "")
		end

		local function r1227(s23)
			local s23_1 = tonumber(s23) or 0
			local s4 = s23_1 >= 1000 and string.format("%.0f", s23_1) or string.format("%.2f", s23_1)
			local s2, s3 = string.match(s4, "^(%-?%d+)(%.%d+)$")
			s2 = s2 or s4
			local s20

			while true do
				local s21_2
				s20, s21_2 = string.gsub(s2, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if s21_2 ~= 0 then
					s2 = s20
				else
					break
				end
			end

			return s20 .. (s3 or "") .. " Kg"
		end

		local function r1228(s19, s20)
			local s1 = string.format("x%.2f", s20)
			local s4 = r234.EggRecords
			local s2 = type(s4) == "table" and type(s4.WeightKgForScale) == "function"
			local s5 = 0

			if s2 then
				local s20_1, s21 = pcall(s4.WeightKgForScale, s19, s20)

				if s20_1 and tonumber(s21) then
					s5 = tonumber(s21)
					s1 ..= "  " .. utf8.char(183) .. "  " .. r1227(s21)
				end
			end

			return s1, s5
		end

		local r1229 = nil

		local function r1230(s2)
			local s5 = r1205()

			if s5 and s2 == r1150 and r1149 then
				local s11 = {}
				local s12 = os.clock()
				local s13 = -1
				local s14 = nil

				for _, s6 in pairs(s5) do
					local s16 = type(s6) == "table" and s6.Uid or nil
					local s7 = s6.State == "Slot" or s6.State == "Dropped" or s6.State == "Carried"

					if type(s16) == "string" and s7 and type(s6.AssetCategory) == "string" then
						s11[s16] = true
						local s1_3 = r1145(s6.AssetCategory)
						local s18 = r1174[s16]

						if not s18 then
							s18 = { Uid = s16 }
							r1174[s16] = s18
						end

						local s9 = tonumber(s6.AssetScale) or 1

						if s18.Detail == nil or s18.Scale ~= s9 or s18.Category ~= s6.AssetCategory then
							s18.Scale = s9
							local s7_2, s8 = r1228(s6.AssetCategory, s9)
							s18.Detail = s7_2
							s18.Weight = s8
						end

						s18.Category = s6.AssetCategory
						s18.Style = s1_3
						s18.Value = r1146(s6, s1_3)
						s18.Position = typeof(s6.BottomCFrame) == "CFrame" and s6.BottomCFrame.Position or nil

						if (s6.State == "Slot" or s6.State == "Dropped") and s1_3.Icon ~= "" and s18.Value > s13 then
							s13 = s18.Value
							s14 = s18
						end

						if r1165 and r1163 then
							local s1_4 = r1173[s16]

							if not s1_4 then
								s1_4 = r1225(s16)
								r1173[s16] = s1_4
							end

							r1226(s1_4, s18)
						end
					end

					if not (r1135 < os.clock() - s12) then
						continue
					end
					r137.Heartbeat:Wait()
					s12 = os.clock()
					if s2 ~= r1150 or not r1149 then
						return
					end
				end

				for s8_2 in pairs(r1174) do
					if not s11[s8_2] then
						r1174[s8_2] = nil
						local s1_6 = r1173[s8_2]

						if s1_6 then
							r1173[s8_2] = nil
							s1_6.Frame:Destroy()
						end
					end
				end

				local s2_1 = r1157
				local s4

				if r1157 then
					s4 = s14
				else
					s4 = s2_1
				end

				if s4 and r1157.Image ~= s14.Style.Icon then
					r1157.Image = s14.Style.Icon
				end

				r1223()
			end
		end

		local r1231 = 0

		local function r1232(s19)
			if r1179 and os.clock() - r1231 < 10 then
				r1180 = true
				return
			end
			r1179 = true
			r1231 = os.clock()
			pcall(r1230, s19)

			if r1231 == r1231 then
				r1179 = false
			end

			if r1180 then
				r1180 = false
				r1229()
			end
		end

		r1229 = function()
			if r1178 or not r1149 then
				return
			end
			r1178 = true
			local s2 = r1150

			task.delay(r1165 and 0.15 or 1, function()
				r1178 = false

				if r1149 and s2 == r1150 then
					task.spawn(pcall, r1232, s2)
				end
			end)
		end

		local function r1233(s3)
			if r1165 or not r1159 then
				return
			end
			r1165 = true

			if s3 then
				r171_1:Set(true)
			end

			if r1207() then
				r137.Heartbeat:Wait()
				if not r1165 or not r1159 then
					return
				end
			end

			r1208(true)
			r1158.Enabled = true

			if r1167 then
				r1167:Cancel()
			end

			local s5 = r1160.Y.Scale
			local s6 = r1160.Y.Offset
			r1159.Position = UDim2.new(r1160.X.Scale, math.ceil(r1159.AbsoluteSize.X * r1141), s5, s6)
			r1167 = r158_2:Create(r1159, r201_1, { Position = r1160 })
			r1167:Play()
			r1194()
			r1224()
			task.spawn(pcall, r1232, r1150)
		end

		local function r1234(s17, s18)
			if not r1165 or not r1159 then
				return
			end
			r1165 = false

			if s18 then
				r171_1:Set(false)
			end

			if r1167 then
				r1167:Cancel()
			end

			local s6 = r1160.Y.Scale
			local s7 = r1160.Y.Offset
			local s2_1 = r158_2:Create(r1159, r202, { Position = UDim2.new(r1160.X.Scale, math.ceil(r1159.AbsoluteSize.X * r1141), s6, s7) })
			r1167 = s2_1

			s2_1.Completed:Connect(function(arg1)
				if arg1 == Enum.PlaybackState.Completed and r1167 == s2_1 and not r1165 and r1158 then
					r1158.Enabled = false
					r1159.Position = r1160
				end
			end)

			s2_1:Play()

			if s17 then
				r1208(false)
			end
		end

		local function r1235(s23)
			local s2 = Instance.new("ScreenGui")
			s2.Name = r238()
			s2.Archivable = false
			s2.ResetOnSpawn = false
			s2.IgnoreGuiInset = s23.IgnoreGuiInset
			s2.ZIndexBehavior = s23.ZIndexBehavior
			s2.DisplayOrder = s23.DisplayOrder

			pcall(function()
				s2.ScreenInsets = s23.ScreenInsets
			end)

			return s2
		end

		local function r1236()
			if r1155 and r1155.Parent and r1156 and r1156.Button then
				return true
			end
			local s15 = r1184(r1154.Pets)
			if not s15 then
				return false
			end

			for _, s4 in ipairs({ "Notification", "ReadyNotification", "NightImage", "NightText", "ConsoleButton", "Badge" }) do
				local s5 = s15:FindFirstChild(s4)

				if s5 then
					s5:Destroy()
				end
			end

			r1156 = r1195(s15)
			r1157 = s15:FindFirstChild("ImageLabel")

			if r1156.Scale then
				r1156.Scale.Scale = 1
			end

			r1196(r1156, r1144.Chilli)
			r1197(r1156)
			r1203(r1156)
			s15.AnchorPoint = Vector2.new(0.5, 0.5)
			s15.LayoutOrder = 0

			s15.Activated:Connect(function()
				r247.UiDefer(function()
					if not r1158 or not r1158.Parent then
						pcall(r1181)

						r247.UiDefer(function()
							if r1158 and not r1165 then
								pcall(r1233, true)
							end
						end)

						return
					end

					if r1165 then
						r1234(true, true)
					else
						r1233(true)
					end
				end)
			end)

			r1192(s15)
			r1185(s15)
			r1155 = r1235(r1154.Hud)
			s15.Parent = r1155
			r1155.Parent = r235
			return true
		end

		local r1237 = nil
		local r1238 = nil

		local function r1239()
			local s8 = r1156 and r1156.Button
			local s6 = r1154.Eggs
			local s10 = r1154.Pets
			if not s8 or not s6.Parent or not s10.Parent then
				return
			end

			if r1154.Hud.Enabled and r1154.GameHud.Visible and r1154.Column.Visible and s6.Visible and s10.Visible and s6.AbsoluteSize.X > 0 then
				local s2_3 = s6:FindFirstChildOfClass("UIScale")
				s2_3 = s2_3 and s2_3.Scale or 1

				if s2_3 <= 0 then
					s2_3 = 1
				end

				local s5 = s6.AbsolutePosition + s6.AbsoluteSize / 2
				local s2_4 = s6.AbsoluteSize / s2_3
				local s6_1 = r1155.AbsolutePosition
				local s3_2 = UDim2.fromOffset(s5.X - s6_1.X, s5.Y - (s10.AbsolutePosition + s10.AbsoluteSize / 2).Y - s5.Y - s6_1.Y)
				local s4 = UDim2.fromOffset(s2_4.X, s2_4.Y)

				if not r1165 then
					r1237 = s3_2
					r1238 = s4
				end

				if s8.Position ~= s3_2 then
					s8.Position = s3_2
				end

				if s8.Size ~= s4 then
					s8.Size = s4
					r1193()
				end
			elseif not r1165 and r1237 then
				if s8.Position ~= r1237 then
					s8.Position = r1237
				end

				if r1238 and s8.Size ~= r1238 then
					s8.Size = r1238
					r1193()
				end
			end

			if s8.Visible ~= true then
				s8.Visible = true
			end
		end

		local function r1240()
			local s27 = r1154.ActivePets.Frame
			local s17 = r1184(s27)
			if not s17 then
				return false
			end
			local s14 = s17:FindFirstChild("Header")
			local s18 = s17:FindFirstChild("ScrollingFrame")
			local s15 = s17:FindFirstChild("Close")
			local s19 = s18 and s18:FindFirstChild("Template")
			local s21 = s19 and s19:FindFirstChild("Spacer")
			local s16 = s21 and s21:FindFirstChild("Unequip")
			local s23 = s21 and s21:FindFirstChild("TextLabel")
			if not (s14 and s18 and s15 and s21 and s16 and s23) then
				s17:Destroy()
				return false
			end

			for _, s4 in ipairs(s18:GetChildren()) do
				if s4 ~= s19 and s4:IsA("GuiObject") and s4.Name ~= "EmptyLast" then
					s4:Destroy()
				end
			end

			local s2_2 = s17:FindFirstChild("EquipBest")

			if s2_2 then
				s2_2:Destroy()
			end

			local s2_3 = s17:FindFirstChildOfClass("UIAspectRatioConstraint")
			local s3_2 = s2_3 and s2_3.AspectRatio or 1.25
			local s5 = not r139.MouseEnabled
			local s6_1 = s5 and 1.2 or 1
			s5 = s5 and 1.15 or 1
			local s8 = r1139 / s5
			local s9 = s8 / s3_2
			r1171 = { Width = s27.Size.X.Scale, Height = s27.Size.Y.Scale, Aspect = s3_2 }
			s17.Size = UDim2.new(r1137 * s6_1, 0, r1138 * s6_1 * s5, 0)

			if not s2_3 then
				s2_3 = Instance.new("UIAspectRatioConstraint")
				s2_3.Parent = s17
			end

			s2_3.AspectRatio = s8
			s2_3.AspectType = Enum.AspectType.FitWithinMaxSize
			s14.Size = UDim2.new(s14.Size.X.Scale, s14.Size.X.Offset, s14.Size.Y.Scale * s9, s14.Size.Y.Offset)
			s14.Position = UDim2.new(s14.Position.X.Scale, s14.Position.X.Offset, s14.Position.Y.Scale * s9, s14.Position.Y.Offset)
			s15.Size = UDim2.new(s15.Size.X.Scale * 1, s15.Size.X.Offset, s15.Size.Y.Scale * s9, s15.Size.Y.Offset)
			s15.Position = UDim2.new(s15.Position.X.Scale * 1, s15.Position.X.Offset, s15.Position.Y.Scale, s15.Position.Y.Offset)
			local s2_4 = s18.Size.Y.Scale
			local s3_3 = s18.Position.Y.Scale
			local s7 = s18.AnchorPoint.Y
			local s8_1 = (s3_3 - s2_4 * s7) * s9
			local s10 = 1 - (1 - s3_3 + s2_4 * (1 - s7)) * s9
			s18.Size = UDim2.new(s18.Size.X.Scale, s18.Size.X.Offset, s10 - s8_1, 0)
			s18.Position = UDim2.new(s18.Position.X.Scale, s18.Position.X.Offset, s8_1 + (s10 - s8_1) * s7, 0)
			local s2_5 = s18.Size.Y.Scale
			local s8_2 = s18.AnchorPoint.Y
			local s10_1 = s18.Position.Y.Scale - s2_5 * s8_2
			local s11 = s10_1 + s2_5
			local s7_1 = 0.1 * s9
			local s9_1 = 0.02 * s9
			local s12 = Instance.new("Frame")
			s12.BackgroundTransparency = 1
			s12.BorderSizePixel = 0
			s12.AnchorPoint = Vector2.new(0.5, 0)
			s12.Position = UDim2.new(0.5, 0, s10_1 + s9_1, 0)
			s12.Size = UDim2.new(0.9, 0, s7_1, 0)
			s12.Parent = s17
			local s7_2 = s10_1 + s9_1 * 1.5 + s7_1
			s18.Size = UDim2.new(s18.Size.X.Scale, s18.Size.X.Offset, s11 - s7_2, 0)
			s18.Position = UDim2.new(s18.Position.X.Scale, s18.Position.X.Offset, s7_2 + (s11 - s7_2) * s8_2, 0)
			local s7_3 = s16:Clone()
			s7_3.AnchorPoint = Vector2.new(0, 0.5)
			s7_3.Position = UDim2.new(0, 0, 0.5, 0)
			s7_3.Size = UDim2.new(0.37, 0, 1, 0)
			s7_3.Parent = s12
			local s8_3 = r1195(s7_3)
			r1197(s8_3)

			s7_3.Activated:Connect(function()
				local t7 = r4_5
				local t5 = r4_5

				if t7 then
					t5 = type(t7.Set) == "function"
				end

				if t5 then
					pcall(t7.Set, t7, not r247.Toggle(t7, false))
				end

				r247.UiDefer(r1219)
			end)

			local s9_2 = s16:Clone()
			s9_2.Parent = s12
			local s10_2 = r1195(s9_2)
			r1197(s10_2)

			s9_2.Activated:Connect(function()
				local t10 = r247.AntiGuard
				local t8 = not t10.Enabled
				local t7 = t10.Handle

				if t7 and type(t7.Set) == "function" then
					pcall(t7.Set, t7, t8)
				end

				t10.Enabled = t8

				if t10.Render then
					pcall(t10.Render, false)
				end

				r247.UiDefer(r1219)
			end)

			local s5_1 = Instance.new("UIListLayout")
			s5_1.FillDirection = Enum.FillDirection.Horizontal
			s5_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
			s5_1.VerticalAlignment = Enum.VerticalAlignment.Center
			s5_1.SortOrder = Enum.SortOrder.LayoutOrder
			s5_1.Padding = UDim.new(0.06, 0)
			s5_1.Parent = s12
			s7_3.Size = UDim2.new(0.46, 0, 1, 0)
			s7_3.LayoutOrder = 1
			s9_2.Size = UDim2.new(0.46, 0, 1, 0)
			s9_2.LayoutOrder = 2
			r1170 = { Toggle = s8_3, Guard = s10_2 }

			r247.StealPanelSync = function()
				r247.UiDefer(r1219)
			end

			local s2_6 = s14:FindFirstChildOfClass("UIGradient")

			if s2_6 then
				local s4_1 = r1143
				local s5_2 = {}
				local s6_2 = { 0, r1_49(200, 18, 24) }
				local s7_4 = { 0.53, r1_49(255, 88, 90) }
				local s8_4 = { 1, r1_49(214, 28, 34) }
				s5_2[1] = s6_2
				s5_2[2] = s7_4
				s5_2[3] = s8_4
				s2_6.Color = s4_1(s5_2)
			end

			r1161 = s14:FindFirstChild("Title")
			r1148(r1161, "Steal Panel")
			local s25 = s14:FindFirstChild("PlusEquip")
			r1162 = r1195(s25)

			if r1162 then
				r1196(r1162, r1144.Steal)
				r1148(r1162.Label, "Sort: " .. tostring(r274))
				r1197(r1162)
				local s4_2 = 0

				local function s8_5()
					if os.clock() - s4_2 < 0.25 then
						return
					end
					s4_2 = os.clock()
					local t5_1 = r7_4[(table.find(r7_4, r274) or 4) % #r7_4 + 1]
					local t4 = r247.Steal.PriorityHandle

					if t4 and type(t4.Set) == "function" then
						pcall(t4.Set, t4, t5_1)
					end

					if r274 ~= t5_1 then
						r274 = t5_1

						if type(r247.ResortSteal) == "function" then
							r247.ResortSteal()
						end
					end

					r247.UiDefer(function()
						r1148(r1162.Label, "Sort: " .. tostring(r274))
						r1223()
					end)
				end

				pcall(function()
					s25.Active = true
					s25.Interactable = true
					s25.AutoButtonColor = true
				end)

				for _, s7_5 in ipairs(s25:GetDescendants()) do
					if s7_5:IsA("GuiObject") then
						pcall(function()
							s7_5.Active = false
						end)
					end
				end

				s25.Activated:Connect(s8_5)

				s25.InputBegan:Connect(function(t13)
					if t13.UserInputType == Enum.UserInputType.MouseButton1 or t13.UserInputType == Enum.UserInputType.Touch then
						s8_5()
					end
				end)
			end

			local s2_7 = r1195(s15)
			r1197(s2_7)

			s15.Activated:Connect(function()
				r247.UiDefer(function()
					r1234(true, true)
				end)
			end)

			local s5_3 = s16:Clone()
			s5_3.Name = "Cancel"
			s5_3.Parent = s21
			local s2_8 = Instance.new("UIAspectRatioConstraint")
			s2_8.AspectRatio = 1
			s2_8.DominantAxis = Enum.DominantAxis.Height
			s2_8.Parent = s5_3
			s16.Size = UDim2.new(0.24, 0, s16.Size.Y.Scale, 0)
			s16.Position = UDim2.new(0.852, 0, 0.5, 0)
			s5_3.Size = UDim2.new(0.105, 0, s16.Size.Y.Scale, 0)
			s5_3.Position = UDim2.new(0.965, 0, 0.5, 0)
			local s2_9 = s21:FindFirstChild("Icon")

			if s2_9 then
				s2_9.AnchorPoint = Vector2.new(0.5, 0.5)
				s2_9.Size = UDim2.new(0.2, 0, 1.3, 0)
				s2_9.Position = UDim2.new(0.1, 0, 0.5, 0)
			end

			s23.AnchorPoint = Vector2.new(s23.AnchorPoint.X, 0.5)
			s23.Size = UDim2.new(0.38, 0, 0.3, 0)
			s23.Position = UDim2.new(0.415, 0, 0.2, 0)
			r1148(s23, "")
			local s3_4 = s23:Clone()
			s3_4.Name = "Value"
			s3_4.Size = UDim2.new(0.38, 0, 0.23, 0)
			s3_4.Position = UDim2.new(0.415, 0, 0.48, 0)
			local s13 = s3_4:FindFirstChildOfClass("UIGradient")

			if not s13 then
				s13 = Instance.new("UIGradient")
				s13.Parent = s3_4
			end

			s13.Color = r1144.Steal.Color
			s13.Rotation = r1144.Steal.Rotation
			s3_4.Parent = s21
			local s4_3 = s3_4:Clone()
			s4_3.Name = "Detail"
			s4_3.Size = UDim2.new(0.4, 0, 0.3, 0)
			s4_3.Position = UDim2.new(0.415, 0, 0.78, 0)
			local s13_1 = s4_3:FindFirstChildOfClass("UIGradient")

			if s13_1 then
				s13_1.Color = r1144.Hud.Color
				s13_1.Rotation = r1144.Hud.Rotation
			end

			s4_3.Parent = s21
			local s2_10 = r1195(s16)
			r1148(s2_10.Label, "Steal")
			r1196(s2_10, r1144.Steal)
			local s2_11 = r1195(s5_3)
			r1148(s2_11.Label, "X")
			r1196(s2_11, r1144.Cancel)
			s5_3.Position = r13_10
			s5_3.Visible = false
			s16.Position = r14_13
			s16.Size = r15_12
			local s2_12 = s5_3:Clone()
			s2_12.Name = "Star"
			s2_12.AnchorPoint = Vector2.new(1, 0.5)
			s2_12.Size = UDim2.new(0.1, 0, 0.56, 0)
			s2_12.Position = r13_10
			s2_12.Visible = true
			s2_12.Parent = s21
			local s2_13 = r1195(s2_12)
			r1148(s2_13.Label, utf8.char(9733))
			r1196(s2_13, r1144.Queued)
			local s8_6 = ipairs
			local s2_14 = {}
			local s10_3 = {}
			local s12_1 = utf8.char(9650)
			local s13_2 = r1216 - r1211
			s10_3[1] = "Up"
			s10_3[2] = s12_1
			s10_3[3] = s13_2
			local s11_1 = {}
			local s13_3 = utf8.char(9660)
			s11_1[1] = "Down"
			s11_1[2] = s13_3
			s11_1[3] = r1216
			s2_14[1] = s10_3
			s2_14[2] = s11_1

			for _, s10_4 in s8_6(s2_14) do
				local s2_15 = s5_3:Clone()
				s2_15.Name = s10_4[1]
				s2_15.AnchorPoint = Vector2.new(1, 0.5)
				s2_15.Size = UDim2.new(0.1, 0, 0.56, 0)
				s2_15.Position = UDim2.new(s10_4[3], 0, 0.6, 0)
				s2_15.Visible = false
				s2_15.Parent = s21
				local s2_16 = r1195(s2_15)
				r1148(s2_16.Label, s10_4[2])
				r1196(s2_16, r1144.Hud)
			end

			s5_3.AnchorPoint = Vector2.new(1, 0)
			s5_3.Position = UDim2.new(0.99, 0, 0.04, 0)
			s5_3.Size = UDim2.new(0.06, 0, 0.28, 0)
			s5_3.ZIndex = 8

			for _, s13_4 in ipairs(s5_3:GetDescendants()) do
				if s13_4:IsA("GuiObject") then
					s13_4.ZIndex = s13_4.ZIndex + 8
				end
			end

			local s3_5 = s3_4:Clone()
			s3_5.Name = "Rank"
			s3_5.AnchorPoint = Vector2.new(0, 0)
			s3_5.Position = UDim2.new(0.012, 0, 0.03, 0)
			s3_5.Size = UDim2.new(0.1, 0, 0.36, 0)
			s3_5.TextXAlignment = Enum.TextXAlignment.Left
			s3_5.ZIndex = 6
			s3_5.Visible = false
			r1148(s3_5, "#1")
			local s14_1 = s3_5:FindFirstChildOfClass("UIGradient")

			if s14_1 then
				s14_1.Color = r1144.PriorityOn.Color
				s14_1.Rotation = 90
			end

			s3_5.Parent = s21
			s19.Visible = false
			s19.Parent = nil
			r1164 = s19
			r1163 = s18
			r1159 = s17
			r1160 = s27.Position
			s17.Position = r1160
			r1192(s17, true)
			r1185(s17)
			r1158 = r1235(r1154.ActivePets)
			r1158.Enabled = false
			s17.Parent = r1158
			r1158.Parent = r235
			table.insert(r1175, s18:GetPropertyChangedSignal("AbsoluteSize"):Connect(r1224))
			table.insert(r1175, s17:GetPropertyChangedSignal("AbsoluteSize"):Connect(r1194))
			return true
		end

		local function r1182()
			if not r1149 then
				return
			end
			r1149 = false
			r1150 += 1
			r1178 = false
			r1180 = false

			if r1165 then
				r1165 = false

				if not r1206() then
					r1208(false, true)
				end
			end

			if r1167 then
				r1167:Cancel()
				r1167 = nil
			end

			r951.DisconnectAll(r1175)
			table.clear(r1173)
			table.clear(r1174)

			if r1158 then
				r1158:Destroy()
			end

			if r1164 then
				r1164:Destroy()
			end

			r1158 = nil
			r1159 = nil
			r1160 = nil
			r1161 = nil
			r1162 = nil
			r1163 = nil
			r1164 = nil
			r1169 = 0
			r1170 = nil
			r1171 = nil
			r1172 = 1
			r1154 = nil
		end

		r1181 = function()
			if r1149 then
				return
			end
			local s2 = r1183()

			if not s2 then
				if not r1151 then
					r1151 = true

					task.delay(2, function()
						r1151 = false

						if not r1149 and r247.Toggle(nil, true) then
							r1181()
						end
					end)
				end

				return
			end

			r1154 = s2
			r1149 = true
			r1150 += 1
			local s17 = r1150
			r1176 = r1154.ActivePets.Frame:FindFirstChildOfClass("UIStroke")
			r1177 = r1176 and r1176.Thickness or nil
			local s2_1 = r1189
			local s5 = r1177
			local s6

			if r1177 then
				s6 = s5
			else
				s6 = 2.3120369911193848
			end

			s2_1.Panel = s6
			local s2_2 = r1154.Pets:FindFirstChild("UIStrokeClr")
			r1189.Hud = s2_2 and s2_2:IsA("UIStroke") and s2_2.Thickness or 2.3120369911193848
			if not r1236() or not r1240() then
				r1182()
				return
			end

			if r1166 then
				r1166 = false
				task.spawn(r1233)
			end

			table.insert(r1175, r137.RenderStepped:Connect(r1239))

			if r1176 then
				table.insert(r1175, r1176:GetPropertyChangedSignal("Thickness"):Connect(r1193))
			end

			for _, s4_1 in ipairs({ r1154.ActivePets, r1154.GrowingEggs }) do
				if s4_1 then
					table.insert(r1175, s4_1:GetPropertyChangedSignal("Enabled"):Connect(function()
						if s4_1.Enabled and r1165 then
							r1234(false)
						end
					end))
				end
			end

			local s3_3 = r234.EggState

			if type(s3_3) == "table" then
				for _, s7_1 in ipairs({ "FieldRefreshed", "FieldShifted", "FieldGone", "FieldClaimed", "SnapshotRefreshed" }) do
					local s10 = s3_3[s7_1]

					if type(s10) == "table" and type(s10.Connect) == "function" then
						local s8, s9_1 = pcall(s10.Connect, s10, r1229)

						if s8 and s9_1 then
							table.insert(r1175, s9_1)
						end
					end
				end
			end

			local s9 = workspace:FindFirstChild("AreaEggSlotsClient")

			if s9 then
				table.insert(r1175, s9.ChildAdded:Connect(r1229))
				table.insert(r1175, s9.ChildRemoved:Connect(r1229))
			end

			task.spawn(function()
				local t9 = 0

				while true do
					if r1149 and s17 == r1150 then
						t9 += task.wait(0.5)

						if not (not r1149 or s17 ~= r1150) then
							if not (r1154.Eggs:IsDescendantOf(game) and r1154.ActivePets:IsDescendantOf(game)) then
								task.defer(function()
									r1182()

									if r247.Toggle(nil, true) then
										r1181()
									end
								end)

								break
							else
								if r22_3 <= t9 then
									r1229()
									t9 = 0
								elseif r1165 then
									r1223()
								end

								continue
							end
						end
					end

					break
				end
			end)

			task.spawn(pcall, r1232, s17)
		end

		r240(function()
			r1182()

			if r1155 then
				r1155:Destroy()
			end

			r1203(nil)
			r1155 = nil
			r1156 = nil
			r1157 = nil
		end)

		r247.RestoreStealPanel = function()
			if r171_1:Get() ~= true then
				return
			end

			if r1149 and r1158 and not r1165 then
				task.spawn(r1233)
			else
				r1166 = true
			end
		end
	end

	task.defer(r1181)
	local r169_1

	do
		local r2_62 = r180:CreateTab({ Name = "Predictor", SectionsExpanded = true })
		r168 = r2_62:CreateSection({ Name = "Discord Webhook", Expanded = false })
		r169_1 = r2_62:CreateSection({ Name = "Egg Predictor", Expanded = true })
		r170 = r2_62:CreateSection({ Name = "Fuse Predictor", Expanded = false })

		local function r1_50(arg1, arg2)
			local s25, s26 = pcall(Font.new, arg1, arg2, Enum.FontStyle.Normal)
			return s25 and s26 or nil
		end

		r15_13 = {
			Ready = type(r169_1.CreateCanvas) == "function",
			Bullet = utf8.char(8226),
			Color = {
				Text = "#FFFFFF",
				Income = "#4DFF7A",
				Clock = "#FFC24D",
				Ready = "#4DFF7A",
				Growing = "#FFC24D",
				Inventory = "#7FD8FF",
				Weight = "#CDE7FF",
				Scale = "#FFDF8A",
				Separator = "#7A8CC0",
				Hint = "#9FB8FF",
			},
			NameFont = r1_50("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold),
		}

		r15_13.RarityFont = r1_50("rbxassetid://12187365977", Enum.FontWeight.Bold) or r1_50("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular)
		local r5_54 = r951.Sequence
		local r152_9 = {}
		local r153_22 = { 0, Color3.fromRGB(255, 255, 255) }
		local r154_13 = { 0.5, Color3.fromRGB(222, 238, 255) }
		local r155_9 = { 1, Color3.fromRGB(255, 255, 255) }
		r152_9[1] = r153_22
		r152_9[2] = r154_13
		r152_9[3] = r155_9
		r15_13.NameGradient = r5_54(r152_9)
		local r11_37 = r951.Sequence
		local r208 = {}
		local r209 = { 0, Color3.fromRGB(255, 255, 255) }
		local r210_1 = { 0.2, Color3.fromRGB(206, 212, 224) }
		local r1_51 = { 0.42, Color3.fromRGB(74, 80, 94) }
		local r5_55 = { 0.58, Color3.fromRGB(42, 46, 56) }
		local r6_48 = { 0.78, Color3.fromRGB(158, 166, 182) }
		local r215_1 = { 1, Color3.fromRGB(250, 252, 255) }
		r208[1] = r209
		r208[2] = r210_1
		r208[3] = r1_51
		r208[4] = r5_55
		r208[5] = r6_48
		r208[6] = r215_1
		r15_13.SecretGradient = r11_37(r208)
		r15_13.SecretRotation = 90

		r15_13.Paint = function(arg1, s9)
			return string.format("<font color=\"%s\">%s</font>", arg1, s9)
		end

		r15_13.Bold = function(s14)
			return "<b>" .. tostring(s14) .. "</b>"
		end

		r15_13.Escape = function(s11)
			return (string.gsub(tostring(s11), "[<>&]", { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" }))
		end

		r15_13.Separator = function()
			return r15_13.Paint(r15_13.Color.Separator, "  " .. r15_13.Bullet .. "  ")
		end

		r15_13.FormatRate = function(s37)
			local s2 = tonumber(s37) or 0
			if s2 >= 1e12 then
				return string.format("%.2fT/s", s2 / 1e12)
			end

			if s2 >= 1e9 then
				return string.format("%.2fB/s", s2 / 1e9)
			end

			if s2 >= 1000000 then
				return string.format("%.2fM/s", s2 / 1000000)
			end

			if s2 >= 1000 then
				return string.format("%.1fK/s", s2 / 1000)
			end
			return string.format("%d/s", math.floor(s2))
		end

		r15_13.FormatWeight = function(s7)
			local s8 = tonumber(s7) or 0
			local s10 = s8 >= 1000 and string.format("%.0f", s8) or string.format("%.2f", s8)
			local s8_1, s12 = string.match(s10, "^(%-?%d+)(%.%d+)$")
			s8_1 = s8_1 or s10
			local s4_1

			while true do
				local s5_1
				s4_1, s5_1 = string.gsub(s8_1, "^(%-?%d+)(%d%d%d)", "%1,%2")

				if s5_1 ~= 0 then
					s8_1 = s4_1
				else
					break
				end
			end

			return s4_1 .. (s12 or "") .. " Kg"
		end

		r15_13.FormatClock = function(s27)
			local s24_1 = math.max(0, math.floor(tonumber(s27) or 0))
			return string.format("%02dh %02dm %02ds", math.floor(s24_1 / 3600), math.floor(s24_1 % 3600 / 60), s24_1 % 60)
		end

		r15_13.ScaleFactor = function(s10)
			if s10 > 5 then
				return (s10 / 5) ^ 1.2 * 19.637875755794113
			end
			return s10 ^ 1.85
		end

		r15_13.MutationMultiplier = function(s24)
			s24 = type(s24) == "table" and s24 or {}
			local s1_1 = r234.Mutations

			if type(s1_1) == "table" and type(s1_1.EarningsFor) == "function" then
				local s22, s23 = pcall(s1_1.EarningsFor, s24)
				if s22 and type(s23) == "number" then
					return s23
				end
			end

			return 1
		end

		local r1_52 = {
			Golden = "#FFD34D",
			Silver = "#E6EEF7",
			Sakura = "#FF9ED8",
			GreatBloom = "#7CFFC4",
			Boss = "#FF7A7A",
			Monstrous = "#C08BFF",
		}

		local r208_1 = { "#FF6B6B", "#FFB36B", "#FFF06B", "#6BFF8A", "#6BC8FF", "#B96BFF" }

		r15_13.MutationText = function(s24)
			local s7 = {}

			if type(s24) == "table" then
				for _, s4 in ipairs(s24) do
					local s22 = string.upper(r263(s4))

					if s4 == "Rainbow" or s4 == "Prismatic" then
						local s6_1 = {}

						for s23_1 = 1, #s22 do
							table.insert(s6_1, r15_13.Paint(r208_1[(s23_1 - 1) % #r208_1 + 1], string.sub(s22, s23_1, s23_1)))
						end

						local s9_1 = table.insert
						local s6_3 = table.pack(r15_13.Bold(table.concat(s6_1)))
						s9_1(s7, table.unpack(s6_3, 1, s6_3.n))
					else
						table.insert(s7, r15_13.Bold(r15_13.Paint(r1_52[s4] or "#8FE3FF", r15_13.Escape(s22))))
					end
				end
			end

			return table.concat(s7, " ")
		end

		local r5_56 = nil

		local function r6_49(s6)
			if type(s6) == "table" and typeof(s6.RarityGradient) == "Instance" then
				return s6.RarityGradient
			end

			if r5_56 == nil then
				local s8_1 = r181:FindFirstChild("Assets")
				s8_1 = s8_1 and s8_1:FindFirstChild("UI")
				r5_56 = s8_1 and s8_1:FindFirstChild("RarityGradients") or false
			end

			if not r5_56 or type(s6) ~= "table" then
				return nil
			end
			local s10_1 = r5_56:FindFirstChild(tostring(s6._id or s6.DisplayName or ""))
			return s10_1 and s10_1:FindFirstChild("RarityGradient") or nil
		end

		local r10_26 = {}

		r15_13.AssetInfo = function(s28)
			local s13 = tostring(s28)
			local s2 = r10_26[s13]
			if s2 then
				return s2
			end
			local s3 = r234.Assets and r234.Assets.Directory
			local s14 = type(s3) == "table" and s3[s13] or nil

			if s14 == nil and type(s3) == "table" then
				local s24 = string.gsub(string.lower(s13), "[^%a%d]", "")

				for s3_2, s4 in pairs(s3) do
					local s16

					if type(s4) == "table" then
						local s12 = {}
						local s8 = tostring(s3_2)
						local s9 = tostring(s4._id or "")
						local s6_1 = tostring
						local s7_1 = s4.DisplayName or ""
						local t53_67_1 = table.pack(s6_1(s7_1))
						s12[1] = s8
						s12[2] = s9

						do
							local values = table.pack(table.unpack(t53_67_1, 1, t53_67_1.n))
							table.move(values, 1, values.n, 3, s12)
						end

						local s7_2 = type(s4.Egg) == "table" and s4.Egg or nil

						if s7_2 ~= nil then
							s12[#s12 + 1] = tostring(s7_2.ModelName or "")
						end

						for _, s8_1 in ipairs(s12) do
							if s8_1 ~= "" and string.gsub(string.lower(s8_1), "[^%a%d]", "") == s24 then
								s14 = s4
								break
							end
						end

						s16 = s14
					else
						s16 = s14
					end

					if s16 ~= nil then
						s14 = s16
						break
					else
						s14 = s16
					end
				end
			end

			local s3_1 = type(s14) == "table" and type(s14.Rarity) == "table" and s14.Rarity or nil
			local s4_1 = type(s14) == "table" and s14.Icon or nil
			local s6_5

			if s3_1 then
				s6_5 = tostring(s3_1.DisplayName or s3_1._id or "Common")
			else
				s6_5 = s3_1
			end

			s6_5 = s6_5 or "Common"
			local s2_3 = s3_1 and typeof(s3_1.Color) == "Color3" and s3_1.Color or Color3.fromRGB(255, 255, 255)
			local s7_6 = {}
			local s9_2 = type(s14) == "table"

			if s9_2 then
				s9_2 = tostring(s14.DisplayName or s13)
			end

			s7_6.Name = s9_2 or s13
			s7_6.Category = s13
			s7_6.Rarity = s6_5
			local s8_4

			if s3_1 then
				s8_4 = tonumber(s3_1.RarityNumber or s3_1.Rank)
			else
				s8_4 = s3_1
			end

			s7_6.RarityNumber = s8_4 or 0
			s7_6.Color = s2_3
			s7_6.Hex = "#" .. string.upper(s2_3:ToHex())
			s7_6.Gradient = r6_49(s3_1)
			s7_6.EarningRate = type(s14) == "table" and tonumber(s14.EarningRate) or 0
			s7_6.Icon = type(s4_1) == "string" and s4_1 ~= "" and s4_1 or nil
			r10_26[s13] = s7_6
			return s7_6
		end

		r15_13.Income = function(s26, s27, s28)
			if type(s27) ~= "number" or s27 <= 0 then
				return 0
			end
			return math.max(math.round(s26.EarningRate * r15_13.ScaleFactor(s27) * r15_13.MutationMultiplier(s28)), 1)
		end

		local function r11_38(s21)
			if typeof(s21) ~= "Instance" or not s21:IsDescendantOf(game) then
				return false
			end

			while s21 do
				if s21:IsA("GuiObject") and not s21.Visible then
					return false
				end

				if s21:IsA("LayerCollector") then
					return s21.Enabled
				end
				s21 = s21.Parent
			end

			return false
		end

		r15_13.PageVisible = function()
			local s4, s5 = pcall(function()
				return r2_62.Page
			end)

			if not s4 or typeof(s5) ~= "Instance" then
				return true
			end
			return r11_38(s5) and s5.AbsoluteSize.X > 0
		end

		r15_13.IsShown = r11_38
	end

	local r211_1
	r211_1 = { "Value", "Rarity", "Time Left" }
	local r212_3

	r212_3 = {
		{ Key = "Ready", Title = "READY TO HATCH", Color = r15_13.Color.Ready },
		{ Key = "Growing", Title = "GROWING", Color = r15_13.Color.Growing },
		{ Key = "Inventory", Title = "IN INVENTORY", Color = r15_13.Color.Inventory },
	}

	local r5_57
	r5_57 = 1
	local r6_50
	r6_50 = r15_13.Paint
	local r14_14
	r14_14 = r15_13.Bold
	local r16_10
	r16_10 = r15_13.Color
	local r1243
	r1243 = { Sort = r211_1[1], Spotlight = true }
	local r1244
	r1244 = nil
	local r1245
	r1245 = 0.0909
	local r1246
	r1246 = nil
	local r1247
	r1247 = {}
	local r1248
	r1248 = {}
	local r1249
	r1249 = {}
	local r1250
	r1250 = {}
	local r1251
	r1251 = 0
	local r1252
	r1252 = 0
	local r1253
	r1253 = 0.06
	local r1254
	r1254 = -1
	local r1256, r1257, r1258, r1259, r1260, r1261, r1262, r1263, r1264, r1265

	do
		local r1255 = -1
		r1256 = -1
		r1257 = 4
		r1258 = 3
		r1259 = false
		r1260 = 0
		r1261 = true
		r1262 = 0
		r1263 = false
		r1264 = nil

		r1265 = function()
			r1261 = true
		end

		local function r1266(s33)
			if not s33 or s33.DiffWrapped then
				return s33
			end
			local s1_1 = s33.Set
			s33.DiffWrapped = true

			s33.Set = function(t4)
				if type(t4) ~= "table" then
					return s1_1(t4)
				end
				local t7 = s33.Spec
				local t9 = nil

				for t4_1, t5 in pairs(t4) do
					if t7[t4_1] ~= t5 then
						t9 = t9 or {}
						t9[t4_1] = t5
					end
				end

				if t9 then
					s1_1(t9)
				end

				return s33
			end

			return s33
		end

		local function r1267(arg1, s19)
			local s15_1 = string.gsub(tostring(arg1.Spec.Text or ""), "%d", "0")
			return tostring(r1252) .. "|" .. tostring(s19) .. "|" .. s15_1
		end

		local function r1268(s22, s23)
			local s2 = r234.EggRecords
			if type(s2) ~= "table" or type(s2.GrowthSecondsRemaining) ~= "function" then
				return 0, 0
			end
			local s1_1 = 1

			if type(s2.GrowthSpeedMultiplier) == "function" then
				local s20_2
				s20_2, s1_1 = pcall(s2.GrowthSpeedMultiplier, s22)
				s20_2 = s20_2 and type(s1_1) == "number"
				local s3_1 = 1

				if not s20_2 then
					s1_1 = s3_1
				end
			end

			local s20, s1_2 = pcall(s2.GrowthSecondsRemaining, s22, s23, s1_1)
			s20 = s20 and type(s1_2) == "number"
			local s3 = 0

			if not s20 then
				s1_2 = s3
			end

			local s21_1 = 0

			if type(s2.GrowthDuration) == "function" then
				local s20_1
				s20_1, s21_1 = pcall(s2.GrowthDuration, s22)
				s20_1 = s20_1 and type(s21_1) == "number"
				local s2_1 = 0

				if not s20_1 then
					s21_1 = s2_1
				end
			end

			return s1_2, s21_1
		end

		local function r1269(s13)
			local s2 = r234.EggRecords

			if type(s2) == "table" and type(s2.WeightKg) == "function" then
				local s11, s12 = pcall(s2.WeightKg, s13)
				if s11 and type(s12) == "number" then
					return s12
				end
			end

			return 0
		end

		local function r1270()
			local s17 = r234.EggState
			if type(s17) ~= "table" or type(s17.ReadOwnerEggs) ~= "function" then
				return nil
			end
			local s3, s1 = pcall(s17.ReadOwnerEggs, r232.UserId)
			if not s3 or type(s1) ~= "table" then
				return nil
			end
			local s10 = workspace:GetServerTimeNow()
			local s21 = {}

			for s4_2, s5 in pairs(s1) do
				if type(s5) == "table" then
					local s7 = r15_13.AssetInfo(s5.AssetCategory)
					local s8 = tonumber(s5.AssetScale) or 0
					local s9 = type(s5.Mutations) == "table" and s5.Mutations or {}

					local s1_1 = {
						Id = s4_2,
						Info = s7,
						Scale = s8,
						Weight = r1269(s5),
						Mutations = s9,
						Income = r15_13.Income(s7, s8, s9),
						Status = "Inventory",
						Remaining = math.huge,
						Percent = 0,
					}

					if s5.Placement ~= nil then
						local s6, s7_1 = pcall(s17.IsReadyToHatch, s4_2)

						if s6 and s7_1 then
							s1_1.Status = "Ready"
							s1_1.Remaining = 0
							s1_1.Percent = 100
						else
							local s8_1, s9_1 = r1268(s5, s10)
							s1_1.Status = "Growing"
							s1_1.Remaining = s8_1

							if s9_1 > 0 then
								s1_1.Percent = math.clamp(math.floor((1 - s8_1 / s9_1) * 100), 0, 100)
							end
						end
					end

					table.insert(s21, s1_1)
				end
			end

			return s21
		end

		local function r1271(arg1)
			local s1 = r1243.Sort

			table.sort(arg1, function(t30, t31)
				if s1 == r211_1[2] and t30.Info.RarityNumber ~= t31.Info.RarityNumber then
					return t30.Info.RarityNumber > t31.Info.RarityNumber
				end

				if s1 == r211_1[3] and t30.Remaining ~= t31.Remaining then
					return t30.Remaining < t31.Remaining
				end
				return t30.Income > t31.Income
			end)
		end

		local function r1272(s13)
			if s13.Status == "Ready" then
				return r14_14(r6_50(r16_10.Ready, "Ready to hatch"))
			end

			if s13.Status == "Growing" then
				return r14_14(r6_50(r16_10.Clock, r15_13.FormatClock(s13.Remaining))) .. r15_13.Separator() .. r6_50(r16_10.Growing, s13.Percent .. "%")
			end
			return r6_50(r16_10.Inventory, "In inventory")
		end

		local function r1273(s2)
			local s10 = {}
			local s12 = r15_13.MutationText(s2.Mutations)
			local s7 = table.insert
			local s4 = table.pack(r14_14(r6_50(r16_10.Income, r15_13.FormatRate(s2.Income))))
			s7(s10, table.unpack(s4, 1, s4.n))
			table.insert(s10, r6_50(r16_10.Scale, string.format("%.2fx", s2.Scale)))
			table.insert(s10, r6_50(r16_10.Weight, r15_13.FormatWeight(s2.Weight)))

			if s12 ~= "" then
				table.insert(s10, s12)
			end

			return table.concat(s10, r15_13.Separator())
		end

		local r1274 = 5
		local r1275 = r1274 + 0.8
		local r1276 = 1.2
		local r1277 = 1.2
		local r1278 = 0.936
		local r1279 = 2.3
		local r1280 = 0.25
		local r1281 = 0.18
		local r1282 = r1279 + 0.6
		local r1283 = 0.24
		local r1284 = 0.22

		local function r1286(s27)
			if string.upper(tostring(s27.Rarity)) == "SECRET" then
				return r15_13.SecretGradient
			end
			return s27.Gradient
		end

		local function r1287(s12)
			return r1286(s12) ~= nil and Color3.fromRGB(255, 255, 255) or s12.Color
		end

		local function r1288(arg1)
			if string.upper(tostring(arg1.Rarity)) == "SECRET" then
				return r15_13.SecretRotation
			end
			return nil
		end

		local function r1289(s14)
			local s1 = s14 and s14.Get()
			if not s1 or r1252 <= 0 then
				return nil
			end

			if s1.Text ~= tostring(s14.Spec.Text or "") then
				return nil
			end
			return s1
		end

		local function r1290(s3)
			local s2 = r1267(s3, "w")
			if s3.WidthKey == s2 then
				return s3.WidthUnits
			end
			local s10 = r1289(s3)
			if not s10 then
				return nil
			end
			local s13 = s10.Size
			local s14 = s10.TextWrapped
			s10.TextWrapped = false
			s10.Size = UDim2.fromOffset(100000, math.max(1, s13.Y.Offset))
			local s4 = s10.TextBounds.X
			s10.Size = s13
			s10.TextWrapped = s14
			if s4 <= 0 then
				return nil
			end
			local s4_1 = s4 / r1252
			s3.WidthKey = s2
			s3.WidthUnits = s4_1
			return s3.WidthUnits
		end

		local function r1291(s19, s20)
			local s3 = r1267(s19, math.floor(s20 * 100 + 0.5))
			if s19.HeightKey == s3 then
				return s19.HeightUnits
			end
			local s4 = r1289(s19)
			if not s4 then
				return nil
			end
			local s6 = s4.Size
			s4.Size = UDim2.fromOffset(math.max(1, math.floor(s20 * r1252 + 0.5)), 100000)
			local s2 = s4.TextBounds.Y
			s4.Size = s6
			if s2 <= 0 then
				return nil
			end
			local s2_1 = s2 / r1252
			s19.HeightKey = s3
			s19.HeightUnits = s2_1
			return s19.HeightUnits
		end

		local function r1292(s22)
			local s19 = r182:FindFirstChild("RF/EggWorld/AskHatch")
			if not s19 or not s19:IsA("RemoteFunction") then
				return false
			end
			local s17, s18 = pcall(s19.InvokeServer, s19, s22)
			if not s17 or s18 == false then
				return false
			end
			task.wait(0.35)
			local s19_1 = r182:FindFirstChild("RF/EggWorld/AskFinishHatch")

			if s19_1 and s19_1:IsA("RemoteFunction") then
				pcall(s19_1.InvokeServer, s19_1, s22)
			end

			return true
		end

		r1247.RunAction = function()
			local s2 = r1247.Focus
			if type(s2) ~= "table" or s2.Id == nil then
				return
			end
			local s13 = tostring(s2.Id)

			if s2.Status == "Inventory" then
				local s3_1 = r234.EggState
				if type(s3_1) == "table" and type(s3_1.WearEggTool) == "function" and pcall(s3_1.WearEggTool, s13) then
					return
				end
				local s2_1 = r182:FindFirstChild("RF/EggWorld/AskWearTool")

				if s2_1 and s2_1:IsA("RemoteFunction") then
					pcall(s2_1.InvokeServer, s2_1, s13)
				end

				return
			end

			if s2.Status == "Ready" then
				if not r1247.Hatching then
					r1247.Hatching = true
					pcall(r1292, s13)
					r1247.Hatching = false
				end

				return
			end

			if r1247.Flying or type(r247.FlyTo) ~= "function" then
				return
			end
			local s6 = workspace:FindFirstChild("PlacedEggRenders")
			local s21 = nil

			if s6 then
				for _, s4 in ipairs(s6:GetChildren()) do
					if string.find(s4.Name, s13, 1, true) or s4:GetAttribute("Uid") == s13 then
						s21 = s4
						break
					end
				end
			end

			if not s21 then
				return
			end

			local s15, s16 = pcall(function()
				return s21:IsA("Model") and s21:GetPivot() or s21.CFrame
			end)

			if not s15 then
				return
			end
			local s2_3 = r247.Movement
			if s2_3.Owner ~= nil and s2_3.Owner ~= "treadmill" or s2_3.PlaceWanted or r247.Steal.Active or r247.Steal.Wanted or r247.Steal.Carrying then
				return
			end
			r1247.Flying = true

			if r247.ClaimMovement("predictor") then
				if r247.Treadmill.Riding or r247.OnBelt() then
					pcall(r247.ExitBelt)
				end

				pcall(r247.FlyTo, s16.Position + Vector3.new(0, 3, 0), function()
					return false
				end, "fly")

				r247.ReleaseMovement("predictor")
			end

			r1247.Flying = false
		end

		local function r1293(s29)
			r1246 = s29
			s29:SetDock(5, { Gap = r1284, DividerColor = Color3.fromRGB(170, 174, 184) })
			local s2 = s29:Dock()

			r1247.Icon = s29:Image({
				Parent = s2,
				X = 0,
				Y = 0,
				Width = r1274,
				Height = r1274,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.26,
				StrokeThickness = r1245,
				StrokeTransparency = 0,
				ZIndex = 8,
			})

			r1247.Name = s29:Text({
				Parent = s2,
				X = r1275,
				Y = 0,
				Height = r1276,
				Scale = r1277,
				Wrap = false,
				Gradient = r15_13.NameGradient,
				TextStrokeTransparency = 1,
				ZIndex = 9,
			})

			r1247.Rarity = s29:Text({
				Parent = s2,
				X = r1275,
				Y = 0,
				Height = r1276,
				Scale = r1278,
				Wrap = false,
				Font = r15_13.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				ZIndex = 9,
			})

			r1247.Info = s29:Text({ Parent = s2, X = r1275, Y = r1276, Height = r1274 - r1276, Wrap = false, ZIndex = 9 })

			r1247.Action = s29:Button({
				Parent = s2,
				X = 0,
				Y = 0,
				Width = 5,
				Height = r1276 - 0.1,
				Text = "",
				Scale = 1,
				Background = "#000000",
				BackgroundTransparency = 0.55,
				HoverTransparency = 0.3,
				PressTransparency = 0.15,
				Corner = 0.35,
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeThickness = r1245,
				StrokeTransparency = 0.6,
				Visible = false,
				ZIndex = 10,
				Callback = function()
					if type(r1247.RunAction) == "function" then
						task.spawn(r1247.RunAction)
					end
				end,
			})

			s29:OnResize(function(arg1, t25, t26)
				if t25 == r1254 and t26 == r1255 then
					return
				end
				r1254 = t25
				r1255 = t26
				r1251 = t25 / math.max(t26, 1)
				r1252 = t26
				r1260 = 2
				r1253 = 0.9 / math.max(s29:TextSize(), 1)
				r1247.Rarity.Set({ StrokeThickness = r1253 })

				for _, t4 in ipairs(r1248) do
					t4.Rarity.Set({ StrokeThickness = r1253 })
				end
			end)

			for _, s4 in ipairs({ "Icon", "Name", "Rarity", "Info", "Action" }) do
				r1266(r1247[s4])
			end
		end

		local function r1294(s6)
			local s4 = r1249[s6]

			if not s4 then
				s4 = r1246:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
				r1249[s6] = r1266(s4)
			end

			return s4
		end

		local function r1295(s15)
			local s13 = r1248[s15]
			if s13 then
				return s13
			end
			local s13_1 = {}

			s13_1.Frame = r1246:Button({
				Name = "Entry",
				Text = "",
				Background = "#000000",
				BackgroundTransparency = 0.74,
				HoverTransparency = 0.46,
				PressTransparency = 0.3,
				Corner = 0.35,
				X = 0,
				Y = 0,
				Width = 1,
				Height = 1,
				Visible = false,
				Callback = function()
					if s13_1.Id ~= nil then
						r1244 = s13_1.Id
						r1265()
					end
				end,
			})

			s13_1.Icon = r1246:Image({
				Parent = s13_1.Frame,
				X = r1280,
				Y = 0,
				Width = r1279,
				Height = r1279,
				Corner = 0.35,
				Background = "#000000",
				BackgroundTransparency = 0.45,
				StrokeThickness = r1245,
				StrokeTransparency = 0,
			})

			s13_1.Name = r1246:Text({
				Parent = s13_1.Frame,
				X = r1280 + r1282,
				Y = 0,
				Width = 1,
				Height = r1276,
				Scale = r1277,
				Wrap = false,
				Gradient = r15_13.NameGradient,
				TextStrokeTransparency = 1,
			})

			s13_1.Rarity = r1246:Text({
				Parent = s13_1.Frame,
				X = r1280 + r1282,
				Y = 0,
				Width = 1,
				Height = r1276,
				Scale = r1278,
				Wrap = false,
				Font = r15_13.RarityFont,
				TextStrokeTransparency = 1,
				StrokeTransparency = 0.08,
				StrokeThickness = r1253,
			})

			s13_1.Detail = r1246:Text({
				Parent = s13_1.Frame,
				X = r1280 + r1282,
				Y = r1276,
				Width = math.max(1, r1251 - r1282 - r1280 * 2),
				Height = 1,
				Wrap = true,
			})

			s13_1.Status = r1246:Text({ Parent = s13_1.Frame, X = 0, Y = 0, Width = 1, Height = r1276, Wrap = false, Align = "Right" })

			for _, s4 in ipairs({ "Frame", "Icon", "Name", "Rarity", "Detail", "Status" }) do
				r1266(s13_1[s4])
			end

			r1248[s15] = s13_1
			return s13_1
		end

		local function r1296(s35)
			local s4 = { Ready = 0, Growing = 0, Inventory = 0 }
			local s5 = 0
			local s6 = nil

			for _, s3 in ipairs(s35) do
				local s7 = s3.Status
				s4[s7] = s4[s7] + 1
				s5 += s3.Income

				if not s6 or s3.Income > s6.Income then
					s6 = s3
				end
			end

			return r14_14(r6_50(r16_10.Text, tostring(#s35) .. " eggs")) .. r15_13.Separator() .. r14_14(r6_50(r16_10.Ready, s4.Ready .. " ready")) .. r15_13.Separator() .. r14_14(r6_50(r16_10.Growing, s4.Growing .. " growing")) .. r15_13.Separator() .. r14_14(r6_50(r16_10.Inventory, s4.Inventory .. " in bag")) .. r15_13.Separator() .. r6_50(r16_10.Text, "Total") .. " " .. r14_14(r6_50(r16_10.Income, r15_13.FormatRate(s5))), s6
		end

		local function r1297(s11, s12)
			if s12 == "" then
				return true
			end
			local s10 = " " .. s11.Status
			local s8 = string.lower(tostring(s11.Info.Name) .. " " .. tostring(s11.Info.Rarity) .. s10)

			for _, s4 in ipairs(s11.Mutations) do
				s8 ..= " " .. string.lower(tostring(s4))
			end

			return string.find(s8, s12, 1, true) ~= nil
		end

		local function r1298(s19)
			local s2 = {}
			local s3 = r14_14(r6_50(r16_10.Income, r15_13.FormatRate(s19.Income)))
			local s16 = r6_50(r16_10.Scale, string.format("%.2fx", s19.Scale)) .. r15_13.Separator() .. r6_50(r16_10.Weight, r15_13.FormatWeight(s19.Weight))
			s2[1] = s3
			s2[2] = s16

			do
				local values = table.pack(r1272(s19))
				table.move(values, 1, values.n, 3, s2)
			end

			local s15 = r15_13.MutationText(s19.Mutations)
			table.insert(s2, s15 ~= "" and s15 or r6_50(r16_10.Hint, "Tap an egg below to preview it"))
			return table.concat(s2, "\n")
		end

		local function r1299(s20)
			local s1 = r1243.Spotlight and s20 ~= nil

			if r1264 ~= s1 then
				r1264 = s1
				r1246:SetDock(s1 and 5 or 0, { Gap = r1284 })
			end

			r1247.Icon.Set({ Visible = s1 })
			r1247.Name.Set({ Visible = s1 })
			r1247.Rarity.Set({ Visible = s1 })
			r1247.Info.Set({ Visible = s1 })
			r1247.Action.Set({ Visible = s1 })
			r1247.Focus = s1 and s20 or nil
			if not s1 then
				return
			end
			local s1_1 = s20.Info

			r1247.Action.Set({
				Text = s20.Status == "Inventory" and r14_14(r6_50(r16_10.Inventory, "Hold egg")) or s20.Status == "Ready" and r14_14(r6_50(r16_10.Ready, "Hatch egg")) or r14_14(r6_50(r16_10.Growing, "Fly to egg")),
			})

			r1247.Icon.Set({ Visible = s1_1.Icon ~= nil, Image = s1_1.Icon or "", StrokeColor = s1_1.Color })
			r1247.Name.Set({ Text = r15_13.Escape(s1_1.Name) })

			r1247.Rarity.Set({
				Text = string.upper(tostring(s1_1.Rarity)),
				Color = r1287(s1_1),
				Gradient = r1286(s1_1),
				GradientRotation = r1288(s1_1),
			})

			r1247.Info.Set({ Text = r1298(s20) })
		end

		local function r1300(s13, s14)
			local s2 = s14.Info
			s13.Id = s14.Id
			s13.Frame.Set({ Visible = true, BackgroundTransparency = s14.Id == r1244 and 0.12 or 0.74 })
			s13.Icon.Set({ Visible = s2.Icon ~= nil, Image = s2.Icon or "", StrokeColor = s2.Color })
			s13.Name.Set({ Text = r15_13.Escape(s2.Name) })

			s13.Rarity.Set({
				Text = string.upper(tostring(s2.Rarity)),
				Color = r1287(s2),
				Gradient = r1286(s2),
				GradientRotation = r1288(s2),
			})

			s13.Detail.Set({ Text = r1273(s14) })
			s13.Status.Set({ Text = r1272(s14) })
		end

		local function r1301()
			if r1251 <= 0 then
				return
			end
			r1259 = false
			local s16 = math.max(1, r1251 - r1275)
			local s5 = r1290(r1247.Action)

			if s5 then
				r1247.ActionUnits = s5 + 1.4
			else
				r1259 = true
			end

			local s17_1 = math.min(r1247.ActionUnits or 5, s16 * 0.45)
			local s18_1 = math.max(1, s16 - s17_1 - r1283)
			r1247.Action.Set({ X = r1251 - s17_1, Y = 0.05, Width = s17_1, Height = r1276 - 0.1 })
			local s5_1 = r1290(r1247.Rarity)

			if s5_1 then
				r1258 = s5_1 + 0.1
			else
				r1259 = true
			end

			local s6 = r1290(r1247.Name)

			if s6 then
				r1257 = math.min(s6 + 0.1, math.max(1, s18_1 - r1258 - r1283))
			else
				r1259 = true
			end

			r1247.Name.Set({ X = r1275, Y = 0, Width = r1257, Height = r1276 })

			r1247.Rarity.Set({
				X = r1275 + r1257 + r1283,
				Y = 0,
				Width = math.max(0.5, math.min(r1258, s18_1 - r1257 - r1283)),
				Height = r1276,
			})

			r1247.Info.Set({ X = r1275, Y = r1276, Width = s16, Height = math.max(1, r1274 - r1276) })
			local s10 = math.max(1, r1251 - r1282 - r1280 * 2)
			local s23 = 0

			for _, s7 in ipairs(r1250) do
				if s7.Kind == "text" then
					local s18_2 = s7.Handle
					local s17_2 = r1291(s18_2, r1251)

					if s17_2 then
						s7.Height = s17_2
					else
						r1259 = true
					end

					local s19_1 = math.max(1, s7.Height or 1)
					s18_2.Set({ X = 0, Y = s23 + (s7.Gap and 0.5 or 0), Width = r1251, Height = s19_1 })
					s23 += s19_1 + r1284 * 0.5 + (s7.Gap and 0.5 or 0)
				else
					local s21_1 = s7.Item
					local s8_2 = r1291(s21_1.Detail, s10)

					if s8_2 then
						s21_1.DetailUnits = s8_2
					else
						r1259 = true
					end

					local s8_4 = math.clamp(s21_1.DetailUnits or 1, 1, 4)
					local s9_2 = r1290(s21_1.Status)

					if s9_2 then
						s21_1.StatusUnits = s9_2 + 0.23
					else
						r1259 = true
					end

					local s9_4 = math.min(s10 * 0.42, math.max(2.73, s21_1.StatusUnits or 2.73))
					local s11 = math.max(1, s10 - s9_4 - r1283)
					local s12_1 = r1290(s21_1.Rarity)

					if s12_1 then
						s21_1.RarityUnits = s12_1 + 0.1
					else
						r1259 = true
					end

					local s13_2 = math.min(s21_1.RarityUnits or 3, s11 * 0.5)
					local s12_2 = r1290(s21_1.Name)

					if s12_2 then
						s21_1.NameUnits = s12_2 + 0.1
					else
						r1259 = true
					end

					local s15 = math.min
					local s16_1 = math.max
					local s18_5 = s21_1.NameUnits or 4
					local s17_4 = math.max
					local s19_2 = s11 - s13_2 - r1283
					local s15_1 = s15(s16_1(1, s18_5), s17_4(1, s19_2))
					local s11_1 = r1281 * 2
					local s16_2 = math.max(s8_4 + r1276, 2.3) + s11_1
					local s14_1 = (s16_2 - s8_4 - r1276) / 2
					s21_1.Frame.Set({ X = 0, Y = s23, Width = r1251, Height = s16_2 })
					s21_1.Icon.Set({ Y = (s16_2 - r1279) / 2 })
					s21_1.Name.Set({ X = r1280 + r1282, Y = s14_1, Width = s15_1 })
					s21_1.Rarity.Set({ X = r1280 + r1282 + s15_1 + r1283, Y = s14_1, Width = math.max(0.5, s13_2) })
					s21_1.Detail.Set({ X = r1280 + r1282, Y = s14_1 + r1276, Width = s10, Height = s8_4 })

					s21_1.Status.Set({
						Visible = s7.HasStatus,
						X = r1280 + r1282 + s10 - s9_4,
						Y = s14_1,
						Width = math.max(0.5, s9_4),
					})

					s23 += s16_2 + r1284
				end
			end

			local s18_6 = math.max(1, s23)

			if math.abs(s18_6 - r1256) > 0.01 then
				r1256 = s18_6
				r1246:SetContentLines(s18_6)
			end
		end

		local function r1302()
			if not r1246 then
				return
			end
			r1260 = 2
			local s10 = r1270()
			table.clear(r1250)
			local s19 = 0

			local function s21(t4, t5)
				s19 += 1
				local t2 = r1294(s19)
				t2.Set({ Visible = true, Text = t4 })
				table.insert(r1250, { Kind = "text", Handle = t2, Gap = t5 })
			end

			local s23

			if not s10 then
				r1299(nil)
				s21(r14_14(r6_50(r16_10.Hint, "Egg data is not available yet")), false)
				s23 = 0
			else
				r1271(s10)
				local s5, s9 = r1296(s10)
				s21(s5, false)
				local s11 = nil

				if r1244 ~= nil then
					s11 = nil

					for _, s3_1 in ipairs(s10) do
						if s3_1.Id == r1244 then
							s11 = s3_1
							break
						else
							s11 = nil
						end
					end
				end

				r1299(s11 or s9)
				local s16 = string.lower(r1246:Query())
				local s2 = {}

				for _, s7 in ipairs(s10) do
					if r1297(s7, s16) then
						table.insert(s2, s7)
					end
				end

				if #s2 == 0 then
					s21(r6_50(r16_10.Hint, #s10 == 0 and "No eggs yet" or string.format("No results for \"%s\"", r15_13.Escape(s16))), false)
					s23 = 0
				else
					s23 = 0

					for _, s11_1 in ipairs(r212_3) do
						local s1_3 = {}

						for _, s14_1 in ipairs(s2) do
							if s14_1.Status == s11_1.Key then
								table.insert(s1_3, s14_1)
							end
						end

						if #s1_3 > 0 then
							local s3 = #r1250 > 0
							s21(string.format("<b><font color=\"%s\">%s</font></b> <font color=\"#AAAAAA\">(%d)</font>", s11_1.Color, s11_1.Title, #s1_3), s3)

							for _, s17 in ipairs(s1_3) do
								s23 += 1
								local s1_4 = r1295(s23)
								r1300(s1_4, s17)
								table.insert(r1250, { Kind = "item", Item = s1_4, HasStatus = true })
							end
						end
					end
				end
			end

			for s1 = s19 + 1, #r1249 do
				r1249[s1].Set({ Visible = false })
			end

			for s1_1 = s23 + 1, #r1248 do
				r1248[s1_1].Frame.Set({ Visible = false })
			end

			r1301()
			r1260 = 2
		end

		r15_13.RequestEggRefresh = r1265

		if not r15_13.Ready then
			r169_1:CreateText({
				Name = "Egg Predictor",
				Text = "Update the Chilli Library to use the predictor canvas.",
			})
		else
			r169_1:CreateDropdown({
				Name = "Sort By",
				Options = r211_1,
				Default = r211_1[1],
				Callback = function(s12)
					if table.find(r211_1, s12) then
						r1243.Sort = s12
						r1265()
					end
				end,
			})

			r169_1:CreateToggle({
				Name = "Preview Card",
				Default = true,
				Callback = function(arg1)
					r1243.Spotlight = arg1 == true
					r1265()
				end,
			})

			local r213_1 = r169_1:CreateCanvas({
				Name = "Egg Predictor",
				Search = true,
				SearchPlaceholder = "Search eggs...",
				Layout = "free",
				Style = {
					TextScale = 0.84,
					LineHeight = 1.1,
					MinLines = 16,
					MaxLines = 32,
					BackgroundTransparency = 0.5,
					ScrollBarColor = Color3.fromRGB(170, 174, 184),
					TextColor = Color3.fromRGB(255, 255, 255),
					TextStrokeTransparency = 0.7,
				},
				Build = function(s11)
					r1293(s11)
					r1265()
				end,
			})

			r240(function()
				r213_1:Destroy()
			end)

			local r158_4 = r137.Heartbeat:Connect(function(s29)
				local s1 = r15_13.PageVisible()
				local s3 = s1 and (r1246 == nil or r15_13.IsShown(r1246:Root()))

				if s3 and not r1263 then
					r1261 = true
				end

				r1263 = s3
				if not s1 then
					return
				end
				r1262 += s29

				if s3 and r1261 or r1262 >= r5_57 then
					r1262 = 0

					if s3 then
						r1261 = false
						pcall(r1302)
					end

					if r15_13.RefreshFuse then
						pcall(r15_13.RefreshFuse)
					end
				end

				if s3 and (r1260 > 0 or r1259) then
					if r1260 > 0 then
						r1260 -= 1
					end

					pcall(r1301)
				end

				if r15_13.PlaceFuse then
					r15_13.PlaceFuse()
				end
			end)

			r240(function()
				r158_4:Disconnect()
			end)
		end
	end
end

local r1_53, r5_58, r6_51, r10_27

do
	local r203_1 = {
		{ min = 0.85, max = 1.05, weight = 2000 },
		{ min = 1.45, max = 1.55, weight = 250 },
		{ min = 1.9, max = 2.1, weight = 125 },
		{ min = 2.85, max = 3.15, weight = 62.5 },
		{ min = 3.8, max = 4.2, weight = 31.25 },
		{ min = 0.3, max = 0.45, weight = 18 },
		{ min = 0.1, max = 0.2, weight = 5 },
		{ min = 5.8, max = 6.2, weight = 15.625 },
		{ min = 9.5, max = 12.5, weight = 3 },
		{ min = 12, max = 17, weight = 0.05 },
		{ min = 20, max = 35, weight = 0.0001 },
	}

	r1_53 = r15_13.Paint
	r5_58 = r15_13.Bold
	r6_51 = r15_13.Color
	r10_27 = 5
	local r11_39 = r10_27 + 0.8
	local r12_34 = 1.2
	local r1304 = 1.2
	local r1305 = 0.936
	local r1306 = 2.3
	local r1307 = 0.25
	local r1308 = 0.18
	local r1309 = r1306 + 0.6
	local r1310 = 0.24
	local r1311 = 0.22
	local r1313 = 0.0909
	local r1314 = nil
	local r1315 = {}
	local r1316 = {}
	local r1317 = {}
	local r1318 = {}
	local r1319 = 0
	local r1320 = 0
	local r1321 = 0.06
	local r1322 = -1
	local r1323 = -1
	local r1324 = -1
	local r1325 = 4
	local r1326 = 3
	local r1327 = false
	local r1328 = 0
	local r1329 = nil

	local r204_1 = {
		{ Min = 0, Color = "#8F98A8" },
		{ Min = 0.3, Color = "#C6CDDA" },
		{ Min = 0.85, Color = "#FFFFFF" },
		{ Min = 1.45, Color = "#7CFF9E" },
		{ Min = 1.9, Color = "#4FE0FF" },
		{ Min = 2.85, Color = "#6FA0FF" },
		{ Min = 3.8, Color = "#C08BFF" },
		{ Min = 5.8, Color = "#FF9A3D" },
		{ Min = 9.5, Color = "#FF5C5C" },
		{ Min = 12, Color = "#FFD34D" },
		{ Min = 20, Color = "#FF4DE8" },
	}

	local function r1352(s25)
		local s5 = -math.huge
		local s6 = "#FFFFFF"

		for _, s3 in ipairs(r204_1) do
			if s25 + 0.001 >= s3.Min and s3.Min > s5 then
				s6 = s3.Color
				s5 = s3.Min
			end
		end

		return s6
	end

	local function r1353(s11, s12)
		local s2 = r234.EggRecords
		if type(s2) ~= "table" or type(s2.WeightKgForScale) ~= "function" then
			return nil
		end
		local s9, s10 = pcall(s2.WeightKgForScale, s11, s12)
		if s9 and type(s10) == "number" and s10 > 0 then
			return s10
		end
		return nil
	end

	local function r1354(s35)
		if type(s35) ~= "table" or #s35 == 0 then
			return nil
		end
		local s5 = -math.huge
		local s6 = nil

		for _, s4 in ipairs(s35) do
			local s7 = r15_13.MutationMultiplier({ s4 })

			if s5 < s7 then
				s5 = s7
				s6 = s4
			end
		end

		return s6
	end

	local function r1355()
		if r1329 then
			return r1329
		end
		local s4 = r234.EggRecords
		local s3 = type(debug) == "table" and debug.getupvalues or getupvalues

		if type(s4) == "table" and type(s4.DrawAssetScale) == "function" and type(s3) == "function" then
			local s6, s8 = pcall(s3, s4.DrawAssetScale)

			if s6 and type(s8) == "table" then
				for _, s4_1 in pairs(s8) do
					if type(s4_1) == "table" and type(s4_1[1]) == "table" and s4_1[1].min and s4_1[1].weight then
						r1329 = s4_1
						break
					end
				end
			end
		end

		r1329 = r1329 or r203_1
		return r1329
	end

	local function r1356(s6, s7, s8)
		local s5 = r234.FuseKernel

		if type(s5) == "table" and type(s5.BandWeightBias) == "function" then
			local s4_1, s5_1 = pcall(s5.BandWeightBias, s6, s7, s8)
			if s4_1 and type(s5_1) == "number" then
				return s5_1
			end
		end

		return math.exp(math.log((s6[1] + s6[2] + s6[3]) / 3) / 0.69314718055994529 * math.log((s7 + s8) / 2) / 0.69314718055994529 * 0.6)
	end

	local function r1357()
		local s3 = r234.Save
		if type(s3) ~= "table" or type(s3.Get) ~= "function" then
			return nil
		end
		local s2_1, s3_1 = pcall(s3.Get)
		if not s2_1 or type(s3_1) ~= "table" then
			return nil
		end
		local s2_3 = type(s3_1.FusionSlots) == "table" and s3_1.FusionSlots or {}
		local s9 = type(s3_1.Inventory) == "table" and s3_1.Inventory or {}
		local s11 = {}

		for s5_1 = 1, 3 do
			local s5_2 = s2_3[s5_1]
			local s6 = s5_2 ~= nil and s9[s5_2] or nil

			if type(s6) == "table" then
				table.insert(s11, {
					Category = s6.Category,
					Scale = tonumber(s6.Scale) or 1,
					Mutations = type(s6.Mutations) == "table" and s6.Mutations or {},
				})
			end
		end

		return {
			Items = s11,
			Locked = s3_1.FusionLocked == true,
			Duration = tonumber(s3_1.FusionDuration) or 0,
			Reward = s3_1.FusionEggReward ~= nil and s3_1.FusionEggReward ~= false,
		}
	end

	local function r1358(s36)
		if string.upper(tostring(s36.Rarity)) == "SECRET" then
			return r15_13.SecretGradient
		end
		return s36.Gradient
	end

	local function r1359(s25)
		return r1358(s25) ~= nil and Color3.fromRGB(255, 255, 255) or s25.Color
	end

	local function r1360(arg1)
		if string.upper(tostring(arg1.Rarity)) == "SECRET" then
			return r15_13.SecretRotation
		end
		return nil
	end

	local function r1361(s12)
		r1314 = s12
		s12:SetDock(5, { Gap = r1311, DividerColor = Color3.fromRGB(170, 174, 184) })
		local s3 = s12:Dock()

		r1315.Icon = s12:Image({
			Parent = s3,
			X = 0,
			Y = 0,
			Width = r10_27,
			Height = r10_27,
			Corner = 0.35,
			Background = "#000000",
			BackgroundTransparency = 0.26,
			StrokeThickness = r1313,
			StrokeTransparency = 0,
			ZIndex = 8,
		})

		r1315.Name = s12:Text({
			Parent = s3,
			X = r11_39,
			Y = 0,
			Height = r12_34,
			Scale = r1304,
			Wrap = false,
			Gradient = r15_13.NameGradient,
			TextStrokeTransparency = 1,
			ZIndex = 9,
		})

		r1315.Rarity = s12:Text({
			Parent = s3,
			X = r11_39,
			Y = 0,
			Height = r12_34,
			Scale = r1305,
			Wrap = false,
			Font = r15_13.RarityFont,
			TextStrokeTransparency = 1,
			StrokeTransparency = 0.08,
			ZIndex = 9,
		})

		r1315.Info = s12:Text({ Parent = s3, X = r11_39, Y = r12_34, Height = r10_27 - r12_34, Wrap = false, ZIndex = 9 })

		s12:OnResize(function(arg1, t23, t24)
			if t23 == r1322 and t24 == r1323 then
				return
			end
			r1322 = t23
			r1323 = t24
			r1319 = t23 / math.max(t24, 1)
			r1320 = t24
			r1328 = 2
			r1321 = 0.9 / math.max(s12:TextSize(), 1)
			r1315.Rarity.Set({ StrokeThickness = r1321 })

			for _, t3 in ipairs(r1316) do
				t3.Rarity.Set({ StrokeThickness = r1321 })
			end
		end)
	end

	local function r1362(s28)
		local s2 = s28 and s28.Get()
		if not s2 or r1320 <= 0 then
			return nil
		end

		if s2.Text ~= tostring(s28.Spec.Text or "") then
			return nil
		end
		return s2
	end

	local function r1363(s37)
		local s2 = r1362(s37)
		if not s2 then
			return nil
		end
		local s4 = s2.Size
		local s5 = s2.TextWrapped
		s2.TextWrapped = false
		s2.Size = UDim2.fromOffset(100000, math.max(1, s4.Y.Offset))
		local s6 = s2.TextBounds.X
		s2.Size = s4
		s2.TextWrapped = s5
		if s6 <= 0 then
			return nil
		end
		return s6 / r1320
	end

	local function r1364(s35, s36)
		local s1 = r1362(s35)
		if not s1 then
			return nil
		end
		local s3 = s1.Size
		s1.Size = UDim2.fromOffset(math.max(1, math.floor(s36 * r1320 + 0.5)), 100000)
		local s5 = s1.TextBounds.Y
		s1.Size = s3
		if s5 <= 0 then
			return nil
		end
		return s5 / r1320
	end

	local function r1365(s27)
		local s3 = r1317[s27]

		if not s3 then
			s3 = r1314:Text({ Name = "Line", X = 0, Y = 0, Width = 1, Height = 1, Wrap = true, Visible = false })
			r1317[s27] = s3
		end

		return s3
	end

	local function r1366(s37)
		local s6 = r1316[s37]
		if s6 then
			return s6
		end

		local s7 = {
			Frame = r1314:Frame({
				Name = "Slot",
				Background = "#000000",
				BackgroundTransparency = 0.74,
				Corner = 0.35,
				X = 0,
				Y = 0,
				Width = 1,
				Height = 1,
				Visible = false,
			}),
		}

		s7.Icon = r1314:Image({
			Parent = s7.Frame,
			X = r1307,
			Y = 0,
			Width = r1306,
			Height = r1306,
			Corner = 0.35,
			Background = "#000000",
			BackgroundTransparency = 0.45,
			StrokeThickness = r1313,
			StrokeTransparency = 0,
		})

		s7.Name = r1314:Text({
			Parent = s7.Frame,
			X = r1307 + r1309,
			Y = 0,
			Width = 1,
			Height = r12_34,
			Scale = r1304,
			Wrap = false,
			Gradient = r15_13.NameGradient,
			TextStrokeTransparency = 1,
		})

		s7.Rarity = r1314:Text({
			Parent = s7.Frame,
			X = r1307 + r1309,
			Y = 0,
			Width = 1,
			Height = r12_34,
			Scale = r1305,
			Wrap = false,
			Font = r15_13.RarityFont,
			TextStrokeTransparency = 1,
			StrokeTransparency = 0.08,
			StrokeThickness = r1321,
		})

		s7.Detail = r1314:Text({
			Parent = s7.Frame,
			X = r1307 + r1309,
			Y = r12_34,
			Width = math.max(1, r1319 - r1309 - r1307 * 2),
			Height = 1,
			Wrap = true,
		})

		s7.Status = r1314:Text({
			Parent = s7.Frame,
			X = 0,
			Y = 0,
			Width = 1,
			Height = r12_34,
			Wrap = false,
			Align = "Right",
			Color = r6_51.Hint,
		})

		r1316[s37] = s7
		return s7
	end

	local function r1367()
		if r1319 <= 0 then
			return
		end
		r1327 = false
		local s13 = math.max(1, r1319 - r11_39)
		local s2 = r1363(r1315.Rarity)

		if s2 then
			r1326 = s2 + 0.1
		else
			r1327 = true
		end

		local s3 = r1363(r1315.Name)

		if s3 then
			r1325 = math.min(s3 + 0.1, math.max(1, s13 - r1326 - r1310))
		else
			r1327 = true
		end

		r1315.Name.Set({ X = r11_39, Y = 0, Width = r1325, Height = r12_34 })

		r1315.Rarity.Set({
			X = r11_39 + r1325 + r1310,
			Y = 0,
			Width = math.max(0.5, math.min(r1326, s13 - r1325 - r1310)),
			Height = r12_34,
		})

		r1315.Info.Set({ X = r11_39, Y = r12_34, Width = s13, Height = math.max(1, r10_27 - r12_34) })
		local s7 = math.max(1, r1319 - r1309 - r1307 * 2)
		local s22 = 0

		for _, s4 in ipairs(r1318) do
			if s4.Kind == "text" then
				local s14 = s4.Handle
				local s13_1 = r1364(s14, r1319)

				if s13_1 then
					s4.Height = s13_1
				else
					r1327 = true
				end

				local s15_1 = math.max(1, s4.Height or 1)
				s14.Set({ X = 0, Y = s22 + (s4.Gap and 0.5 or 0), Width = r1319, Height = s15_1 })
				s22 += s15_1 + r1311 * 0.5 + (s4.Gap and 0.5 or 0)
			else
				local s17_1 = s4.Slot
				local s5_2 = r1364(s17_1.Detail, s7)

				if s5_2 then
					s17_1.DetailUnits = s5_2
				else
					r1327 = true
				end

				local s5_4 = math.clamp(s17_1.DetailUnits or 1, 1, 4)
				local s6_3 = r1363(s17_1.Status)

				if s6_3 then
					s17_1.StatusUnits = s6_3 + 0.23
				else
					r1327 = true
				end

				local s6_5 = math.min(s7 * 0.42, math.max(2.73, s17_1.StatusUnits or 2.73))
				local s8_1 = math.max(1, s7 - s6_5 - r1310)
				local s9_1 = r1363(s17_1.Rarity)

				if s9_1 then
					s17_1.RarityUnits = s9_1 + 0.1
				else
					r1327 = true
				end

				local s10_2 = math.min(s17_1.RarityUnits or 3, s8_1 * 0.5)
				local s9_3 = r1363(s17_1.Name)

				if s9_3 then
					s17_1.NameUnits = s9_3 + 0.1
				else
					r1327 = true
				end

				local s12 = math.min
				local s13_3 = math.max
				local s15_2 = s17_1.NameUnits or 4
				local s14_3 = math.max
				local s16_1 = s8_1 - s10_2 - r1310
				local s12_1 = s12(s13_3(1, s15_2), s14_3(1, s16_1))
				local s8_2 = r1308 * 2
				local s13_4 = math.max(s5_4 + r12_34, 2.3) + s8_2
				local s11_1 = (s13_4 - s5_4 - r12_34) / 2
				s17_1.Frame.Set({ X = 0, Y = s22, Width = r1319, Height = s13_4 })
				s17_1.Icon.Set({ Y = (s13_4 - r1306) / 2 })
				s17_1.Name.Set({ X = r1307 + r1309, Y = s11_1, Width = s12_1 })
				s17_1.Rarity.Set({ X = r1307 + r1309 + s12_1 + r1310, Y = s11_1, Width = math.max(0.5, s10_2) })
				s17_1.Detail.Set({ X = r1307 + r1309, Y = s11_1 + r12_34, Width = s7, Height = s5_4 })
				s17_1.Status.Set({ X = r1307 + r1309 + s7 - s6_5, Y = s11_1, Width = math.max(0.5, s6_5) })
				s22 += s13_4 + r1311
			end
		end

		local s14_4 = math.max(1, s22)

		if math.abs(s14_4 - r1324) > 0.01 then
			r1324 = s14_4
			r1314:SetContentLines(s14_4)
		end
	end

	local function r1368(s15, s16)
		local s2 = s15 ~= nil
		r1314:SetDock(s2 and 5 or 0, { Gap = r1311 })
		r1315.Icon.Set({ Visible = s2 })
		r1315.Name.Set({ Visible = s2 })
		r1315.Rarity.Set({ Visible = s2 })
		r1315.Info.Set({ Visible = s2 })
		if not s2 then
			return
		end
		r1315.Icon.Set({ Visible = s15.Icon ~= nil, Image = s15.Icon or "", StrokeColor = s15.Color })
		r1315.Name.Set({ Text = r15_13.Escape(s15.Name) })

		r1315.Rarity.Set({
			Text = string.upper(tostring(s15.Rarity)),
			Color = r1359(s15),
			Gradient = r1358(s15),
			GradientRotation = r1360(s15),
		})

		local s2_2 = r1_53(r6_51.Text, string.format("Fusing %d of 3 pets", #s16.Items))

		if s16.Reward then
			s2_2 = r5_58(r1_53(r6_51.Ready, "Fuse finished, claim your egg"))
		elseif s16.Locked then
			local s6_2 = s16.Duration > 1e9 and s16.Duration - workspace:GetServerTimeNow() or 0
			s2_2 = r5_58(r1_53(r6_51.Clock, s6_2 > 0 and "Fusing" .. r15_13.Separator() .. r15_13.FormatClock(s6_2) or "Fusing"))
		end

		local s5 = r1315.Info.Set
		local s6_1 = {}
		local s13 = table.concat
		local s14 = {}
		local s15_1 = r5_58(r1_53(r6_51.Income, r15_13.FormatRate(r15_13.Income(s15, s16.Items[1].Scale, s16.Items[1].Mutations))))
		local s16_1 = r1_53(r6_51.Text, string.format("%d/3 loaded", #s16.Items))
		s14[1] = s15_1
		s14[2] = s16_1
		s14[3] = s2_2
		s6_1.Text = s13(s14, "\n")
		s5(s6_1)
	end

	local function r1369()
		if not r1314 then
			return
		end
		r1328 = 2
		table.clear(r1318)
		local s31 = 0

		local function s32(t30, t31)
			s31 += 1
			local t1 = r1365(s31)
			t1.Set({ Visible = true, Text = t30 })
			table.insert(r1318, { Kind = "text", Handle = t1, Gap = t31 })
		end

		local function s34(t8, arg2)
			local t6 = #r1318 > 0
			s32(string.format("<b><font color=\"%s\">%s</font></b>", arg2, t8), t6)
		end

		local s9 = r1357()
		local s36

		if not s9 then
			r1368(nil, nil)
			s32(r5_58(r1_53(r6_51.Hint, "Fuse machine data is not available yet")), false)
			s36 = 0
		elseif #s9.Items == 0 then
			r1368(nil, nil)
			s32(r5_58(r1_53(r6_51.Text, "Machine is empty")), false)
			s32(r1_53(r6_51.Hint, "Load 3 pets of the same species to see the result odds"), false)
			s36 = 0
		else
			local s23 = s9.Items
			local s19 = r15_13.AssetInfo(s23[1].Category)
			r1368(s19, s9)
			local s2_2 = r6_51.Text
			s34(string.format("FUSE MACHINE STATUS (%d/3 PETS)", #s23), s2_2)
			s32(r1_53(r6_51.Hint, "Species") .. "  " .. r5_58(r1_53(s19.Hex, "[" .. string.upper(tostring(s19.Rarity)) .. "]")) .. " " .. r5_58(r1_53(r6_51.Text, r15_13.Escape(s19.Name))), false)
			s36 = 0

			for s2_3 = 1, 3 do
				local s3 = s23[s2_3]
				s36 += 1
				local s4 = r1366(s36)
				s4.Frame.Set({ Visible = true })
				s4.Status.Set({ Text = "SLOT " .. s2_3 })

				if s3 then
					s4.Icon.Set({ Visible = s19.Icon ~= nil, Image = s19.Icon or "", StrokeColor = s19.Color })
					s4.Name.Set({ Text = r15_13.Escape(s19.Name) })

					s4.Rarity.Set({
						Text = string.upper(tostring(s19.Rarity)),
						Color = r1359(s19),
						Gradient = r1358(s19),
						GradientRotation = r1360(s19),
					})

					local s24 = r1353(s3.Category, s3.Scale)
					local s2_5 = r5_58(r1_53(r6_51.Scale, string.format("%.2fx", s3.Scale)))

					if s24 then
						s2_5 ..= r15_13.Separator() .. r1_53(r6_51.Weight, r15_13.FormatWeight(s24))
					end

					local s5_1 = s2_5 .. r15_13.Separator() .. r5_58(r1_53(r6_51.Income, r15_13.FormatRate(r15_13.Income(s19, s3.Scale, s3.Mutations))))
					local s24_1 = r15_13.MutationText(s3.Mutations)

					s4.Detail.Set({
						Text = s5_1 .. r15_13.Separator() .. (s24_1 ~= "" and s24_1 or r1_53(r6_51.Hint, "Normal")),
					})
				else
					s4.Icon.Set({ Visible = false })
					s4.Name.Set({ Text = r1_53(r6_51.Hint, "Empty") })
					s4.Rarity.Set({ Text = "", Gradient = nil })
					s4.Detail.Set({ Text = r1_53(r6_51.Hint, "Add a pet to this slot") })
				end

				table.insert(r1318, { Kind = "slot", Slot = s4 })
			end

			local s5_2 = 0

			for _, s4_1 in ipairs(s23) do
				s5_2 += s4_1.Scale
			end

			local s26 = s5_2 / #s23
			local s24_2 = r1353(s23[1].Category, s26)
			local s2_7 = r1_53(r6_51.Hint, "Average Scale") .. "  " .. r5_58(r1_53(r6_51.Scale, string.format("%.2fx", s26)))

			if s24_2 then
				s2_7 ..= r15_13.Separator() .. r1_53(r6_51.Weight, r15_13.FormatWeight(s24_2))
			end

			s32(s2_7, false)
			local s22 = nil

			for _, s7_1 in ipairs(s23) do
				local s26_1 = r1354(s7_1.Mutations)

				if s26_1 then
					if (s22 and r15_13.MutationMultiplier({ s22 }) or 0) < r15_13.MutationMultiplier({ s26_1 }) then
						s22 = s26_1
					end
				end
			end

			local s21 = s22 and { s22 } or {}
			s34("PREDICTED SIZE PROBABILITIES", r6_51.Income)

			if #s23 == 3 then
				local s24_3 = { s23[1].Scale, s23[2].Scale, s23[3].Scale }
				local s2_9 = {}
				local s6_1 = 0

				for _, s11 in ipairs(r1355()) do
					local s3_4 = s11.weight * r1356(s24_3, s11.min, s11.max)
					s6_1 += s3_4
					table.insert(s2_9, { Min = s11.min, Max = s11.max, Weight = s3_4, Color = r1352(s11.min) })
				end

				table.sort(s2_9, function(arg1, arg2)
					return arg1.Weight > arg2.Weight
				end)

				local s7_2 = s2_9[1]

				for _, s14 in ipairs(s2_9) do
					local s5_3 = s6_1 > 0 and s14.Weight / s6_1 * 100 or 0
					local s9_1 = r5_58(r1_53(s14.Color, string.format("%.2fx - %.2fx", s14.Min, s14.Max)))
					local s25 = r1353(s23[1].Category, s14.Min)
					local s26_2 = r1353(s23[1].Category, s14.Max)

					if s25 and s26_2 then
						local s4_2 = r6_51.Weight
						local s24_4 = string.format
						local s11_1 = r15_13.FormatWeight
						s9_1 ..= r15_13.Separator() .. r1_53(s4_2, s24_4("%s - %s", r15_13.FormatWeight(s25), s11_1(s26_2)))
					end

					s32(s9_1 .. r15_13.Separator() .. r5_58(r1_53(s5_3 >= 10 and r6_51.Income or s5_3 >= 1 and r6_51.Clock or r6_51.Hint, string.format(s5_3 >= 1 and "%.1f%%" or "%.3f%%", s5_3))), false)
				end

				s34("RESULT PREDICTION", r6_51.Text)
				s32(r1_53(r6_51.Hint, "Predicted Mutation") .. "  " .. (s22 and r15_13.MutationText(s21) or r1_53(r6_51.Text, "Normal")), false)

				if s7_2 then
					s32(r1_53(r6_51.Hint, "Estimated Value") .. "  " .. r5_58(r1_53(r6_51.Income, r15_13.FormatRate(r15_13.Income(s19, s7_2.Min, s21)) .. " ~ " .. r15_13.FormatRate(r15_13.Income(s19, s7_2.Max, s21)))) .. r15_13.Separator() .. r1_53(r6_51.Hint, "at ") .. r5_58(r1_53(s7_2.Color, string.format("%.2fx - %.2fx", s7_2.Min, s7_2.Max))), false)
				end

				local s3_8 = nil

				for _, s17 in ipairs(s2_9) do
					if not s3_8 or s17.Max > s3_8.Max then
						s3_8 = s17
					end
				end

				if s3_8 then
					s32(r1_53(r6_51.Hint, "Best Case") .. "  " .. r5_58(r1_53(s3_8.Color, string.format("%.2fx - %.2fx", s3_8.Min, s3_8.Max))) .. "  " .. r5_58(r1_53(r6_51.Income, r15_13.FormatRate(r15_13.Income(s19, s3_8.Max, s21)))), false)
				end
			else
				s32(r1_53(r6_51.Hint, string.format("Load %d more of the same species to see the odds", 3 - #s9.Items)), false)
			end
		end

		for s2 = s31 + 1, #r1317 do
			r1317[s2].Set({ Visible = false })
		end

		for s2_1 = s36 + 1, #r1316 do
			r1316[s2_1].Frame.Set({ Visible = false })
		end

		r1367()
		r1328 = 2
	end

	if not r15_13.Ready then
		r170:CreateText({ Name = "Fuse Predictor", Text = "Update the Chilli Library to use the predictor canvas." })
	else
		local r169_8 = r170:CreateCanvas({
			Name = "Fuse Predictor",
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = 16,
				MaxLines = 34,
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = function(s20)
				r1361(s20)

				if type(r15_13.RequestEggRefresh) == "function" then
					r15_13.RequestEggRefresh()
				end
			end,
		})

		r15_13.RefreshFuse = r1369

		r15_13.PlaceFuse = function()
			if r1328 > 0 or r1327 then
				if r1328 > 0 then
					r1328 -= 1
				end

				pcall(r1367)
			end
		end

		r240(function()
			r169_8:Destroy()
		end)
	end
end

do
	local r169_2 = r180:CreateTab({ Name = "Progress", SectionsExpanded = true }):CreateSection({ Name = "Auto Progression", Expanded = true })
	local r5_59 = {}
	local r16_11

	r16_11 = {
		Remote = function(s28)
			local s1 = r5_59[s28]
			if s1 ~= nil then
				return s1 or nil
			end
			local s26 = r182:FindFirstChild(s28)
			r5_59[s28] = s26 or false
			return s26
		end,
		Invoke = function(s8, ...)
			local s6 = r16_11.Remote(s8)
			if not s6 or not s6:IsA("RemoteFunction") then
				return false, nil
			end
			local s9, s10 = pcall(s6.InvokeServer, s6, ...)
			return s9, s10
		end,
		Fire = function(s33, ...)
			local s2 = r16_11.Remote(s33)
			if not s2 or not s2:IsA("RemoteEvent") then
				return false
			end
			return pcall(s2.FireServer, s2, ...)
		end,
	}

	local function r6_52()
		local s5 = r234.Save
		if type(s5) ~= "table" or type(s5.Get) ~= "function" then
			return nil
		end
		local s4_1, s5_1 = pcall(s5.Get)
		return s4_1 and type(s5_1) == "table" and s5_1 or nil
	end

	r16_11.SaveData = r6_52
	local r209_1 = { "Money", "Cash", "Coins", "Currency", "Balance" }

	r16_11.Money = function()
		local s8 = r6_52()

		if s8 then
			for _, s4 in ipairs(r209_1) do
				local s9 = tonumber(s8[s4])
				if s9 then
					return s9
				end
			end
		end

		local s2 = r232:FindFirstChild("leaderstats")

		if s2 then
			for _, s10 in ipairs(r209_1) do
				local s12 = s2:FindFirstChild(s10)
				if s12 and tonumber(s12.Value) then
					return tonumber(s12.Value)
				end
			end
		end

		return nil
	end

	r16_11.AddWorker = r244.Add
	r16_11.Backoff = r244.Backoff

	local r1_54 = {
		"Money",
		"BaseUpgradeLevel",
		"TreadmillUpgradeLevel",
		"TrailInventory",
		"PendingOfflineMoney",
	}

	local r10_28 = r234.Save

	if type(r10_28) == "table" and type(r10_28.FieldSignal) == "function" then
		for _, r135 in ipairs(r1_54) do
			local r158_6, r159_1 = pcall(r10_28.FieldSignal, r135)

			if r158_6 and type(r159_1) == "table" and type(r159_1.Connect) == "function" then
				local r157_2, r158_7 = pcall(r159_1.Connect, r159_1, function()
					r244.Wake()
				end)

				if r157_2 and r158_7 then
					r240(function()
						pcall(function()
							r158_7:Disconnect()
						end)
					end)
				end
			end
		end
	end

	local r1_55 = nil
	local r6_53 = nil
	local r10_29 = {}

	local function r11_41()
		local s2 = r233(function()
			return r181.Data.Trails
		end)

		local s3 = type(s2) == "table" and s2.Directory or nil
		if type(s3) ~= "table" then
			return {}
		end
		local s6 = {}

		for s3_1, s4 in pairs(s3) do
			if type(s4) == "table" then
				table.insert(s6, { Id = tostring(s4._id or s3_1), Price = tonumber(s4.Price) or math.huge })
			end
		end

		table.sort(s6, function(arg1, arg2)
			return arg1.Price < arg2.Price
		end)

		return s6
	end

	local function r12_35(s29)
		if not r951.ReadToggle(r1_55, false) then
			return false
		end
		r6_53 = r6_53 or r11_41()
		local s1 = r16_11.SaveData()
		if not s1 or #r6_53 == 0 then
			return false
		end
		local s4 = type(s1.TrailInventory) == "table" and s1.TrailInventory or {}
		local s5 = tonumber(s1.Money) or 0

		for _, s3 in ipairs(r6_53) do
			if s4[s3.Id] ~= true and not r10_29[s3.Id] and s3.Price <= s5 then
				local s26, s27 = r16_11.Invoke("RF/Trailwear/AskPurchase", s3.Id)
				if s26 and s27 ~= false then
					return true
				end
				r10_29[s3.Id] = true
				r16_11.Backoff(s29)
				return false
			end
		end

		return false
	end

	r1_55 = r169_2:CreateToggle({
		Name = "Auto Buy Trail",
		Note = "Automatically buy available trails when affordable",
		Default = false,
		Callback = function()
			table.clear(r10_29)
			r6_53 = nil
		end,
	})

	r16_11.AddWorker(r12_35)
	local r1_56 = nil

	local function r6_54()
		if not r951.ReadToggle(r1_56, false) then
			return false
		end
		local s7 = r16_11.SaveData()
		if not s7 then
			return false
		end

		local s3 = r233(function()
			return r181.Data.Bases
		end)

		local s8 = type(s3) == "table" and s3.BASES or nil
		if type(s8) ~= "table" then
			return false
		end
		local s10 = tonumber(s7.BaseUpgradeLevel) or 0
		local s2 = nil

		if type(s3.GetMaxBaseLevel) == "function" then
			local s3_2
			s2, s3_2 = pcall(s3.GetMaxBaseLevel)
			s2 = s2 and tonumber(s3_2) or nil
		end

		if s2 and s10 >= s2 then
			return false
		end
		local s2_1 = s8[s10 + 1]
		local s3_1 = type(s2_1) == "table" and tonumber(s2_1.Cost) or nil
		local s2_2

		if s3_1 then
			s2_2 = (tonumber(s7.Money) or 0) >= s3_1
		else
			s2_2 = s3_1
		end

		if s2_2 then
			return r16_11.Fire("RE/Homestead/AskBaseTierRaise")
		end
		return false
	end

	r1_56 = r169_2:CreateToggle({
		Name = "Auto Upgrade Base",
		Note = "Automatically upgrade base when money is available",
		Default = false,
	})

	r16_11.AddWorker(r6_54)
	local r1_57 = nil

	local function r6_55()
		if not r951.ReadToggle(r1_57, false) then
			return false
		end
		local s7 = r16_11.SaveData()
		if not s7 then
			return false
		end

		local s4 = r233(function()
			return r181.Data.Treadmills
		end)

		if type(s4) ~= "table" or type(s4.GetByUpgradeLevel) ~= "function" then
			return false
		end
		local s3_1, s4_1 = pcall(s4.GetByUpgradeLevel, (tonumber(s7.TreadmillUpgradeLevel) or 0) + 1)
		if not s3_1 or type(s4_1) ~= "table" then
			return false
		end
		local s5_2 = s4_1._id
		local s3_3 = tonumber(s4_1.Price) or math.huge
		local s4_2 = type(s5_2) == "string"

		if s4_2 then
			s4_2 = (tonumber(s7.Money) or 0) >= s3_3
		end

		if s4_2 then
			local s3_4, s4_3 = r16_11.Invoke("RF/Treadmill/AskTierRaise", s5_2)
			return s3_4 and s4_3 ~= false
		end
		return false
	end

	r1_57 = r169_2:CreateToggle({
		Name = "Auto Upgrade Treadmill",
		Note = "Automatically upgrade treadmill when money is available",
		Default = false,
	})

	r16_11.AddWorker(r6_55)
	local r5_60 = 15
	local r1_58 = nil
	local r1394 = 15
	local r1396 = os.clock()

	local function r1397()
		if not r951.ReadToggle(r1_58, false) then
			return false
		end
		local s2 = os.clock()
		r1394 += s2 - r1396
		r1396 = s2
		local s4 = r16_11.SaveData()
		s4 = s4 and tonumber(s4.PendingOfflineMoney) or nil

		if s4 == nil then
			local s2_2, s3_2 = r16_11.Invoke("RF/AwayEarnings/PendingCheck")
			s4 = s2_2 and s3_2 ~= false and s3_2 ~= nil and 1 or 0
		end

		local s2_1 = false

		if s4 > 0 then
			local s3_1
			s2_1, s3_1 = r16_11.Invoke("RF/AwayEarnings/AskCollect")
			s2_1 = s2_1 and s3_1 ~= false
		end

		local s9

		if r1394 >= r5_60 then
			r1394 = 0
			local s3, s4_1 = r16_11.Invoke("RF/Codex/AskRedeemAll")
			s2_1 = s2_1 or s3 and s4_1 ~= false
			r16_11.Invoke("RF/Codex/AskRedeemLimitedEgg")
			s9 = s2_1
		else
			s9 = s2_1
		end

		return s9
	end

	r1_58 = r169_2:CreateToggle({
		Name = "Auto Claim",
		Note = "Claim offline money & index rewards",
		Default = false,
		Callback = function()
			r1394 = r5_60
		end,
	})

	r16_11.AddWorker(r1397)

	r247.IndexClaimHandle = r169_2:CreateToggle({
		Name = "Auto Claim Index",
		Note = "Claim index rewards as soon as they unlock",
		Default = false,
		Callback = function()
			if type(r247.IndexClaimRestart) == "function" then
				r247.IndexClaimRestart()
			end
		end,
	})
end

local r17_8

r17_8 = function(s20, s21)
	if type(r179.Notify) == "function" then
		pcall(r179.Notify, s20, s21, 5)
	end
end

local r169_3
r169_3 = r180:CreateTab({ Name = "Server", SectionsExpanded = true }):CreateSection({ Name = "Server", Expanded = true })
local r158_5
r158_5 = game:GetService("TeleportService")
local r159
r159 = game:GetService("HttpService")
local r160
r160 = game:GetService("GuiService")

do
	local function r14_15()
		if type(queue_on_teleport) == "function" then
			return queue_on_teleport
		end

		if type(queueonteleport) == "function" then
			return queueonteleport
		end

		if type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
			return syn.queue_on_teleport
		end

		if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
			return fluxus.queue_on_teleport
		end
		return nil
	end

	local function r1402(s17)
		pcall(function()
			r158_5:SetTeleportSetting("__ChilliAutoLoadScriptEnabled", s17)
		end)

		if not s17 then
			return true
		end
		local s2 = r14_15()
		if not s2 then
			return false
		end

		if rawget(_G, "__ChilliAutoLoadQueued") ~= true then
			if not pcall(s2, [[local TeleportService = game:GetService("TeleportService")
local enabled = true
pcall(function()
    enabled = TeleportService:GetTeleportSetting("__ChilliAutoLoadScriptEnabled") == true
end)
if enabled then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player and not player.Character then
            player.CharacterAdded:Wait()
        end
    end)
    task.wait(1.5)
    local ok, source = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua")
    end)
    if ok and type(source) == "string" then
        local chunk = loadstring(source)
        if chunk then
            chunk()
        end
    end
end
]]) then
				return false
			end

			_G.__ChilliAutoLoadQueued = true
		end

		return true
	end

	local r1_59 = nil

	local function r1403()
		if r1_59 and r247.Toggle(r1_59, false) then
			r1402(true)
		end
	end

	r1_59 = r169_3:CreateToggle({
		Name = "Auto Load Script",
		Default = true,
		Callback = function(arg1)
			local s2 = arg1 == true

			if not r1402(s2) and s2 then
				task.defer(function()
					r1402(false)

					if r1_59 and type(r1_59.Set) == "function" then
						pcall(r1_59.Set, r1_59, false, false)
					end

					r17_8("Auto Load Unavailable", "This executor does not support queue on teleport.")
				end)
			end
		end,
	})

	local r1404 = "Least Players"
	local r1405 = 10
	local r1408 = 0
	local r1409 = nil
	local r1410 = {}
	local r1411 = false
	local r1412 = 0
	local r1413 = false
	local r1414 = nil
	local r1415 = ""
	local r1416 = 0
	local r1417 = 60

	local function r1418(s28)
		r1408 = 0
		r1409 = nil

		if s28 then
			r1410[s28] = true
		end
	end

	pcall(function()
		r158_5.TeleportInitFailed:Connect(function(arg1, t36, t37)
			if not r1409 then
				return
			end
			r1418(r1409)
			r1413 = true

			if not r1411 then
				r17_8("Server Hop Failed", tostring(t37 ~= "" and t37 or t36))
			end
		end)
	end)

	local function r1419(s24)
		local s8 = tostring(game.JobId or "")
		local s9 = {}
		local s10 = s24 == "Random"
		local s6 = s24 == "Least Players" and "Asc" or "Desc"
		local s22 = s10 and 3 or 6
		local s24_1 = nil

		for s2_1 = 1, s22 do
			local s20 = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100", game.PlaceId, s6)

			if s24_1 and s24_1 ~= "" then
				s20 ..= "&cursor=" .. r159:UrlEncode(s24_1)
			end

			local s22_1, s23 = pcall(function()
				return r159:JSONDecode(game:HttpGet(s20))
			end)

			if not s22_1 or type(s23) ~= "table" then
				return s9, false
			end
			local s2_4 = ipairs
			local s7 = s23.data or {}

			for _, s4_1 in s2_4(s7) do
				local s7_2 = tostring(s4_1.id or "")
				local s12_1 = tonumber(s4_1.playing) or math.huge
				local s13 = tonumber(s4_1.maxPlayers) or 0

				if s7_2 ~= "" and s7_2 ~= s8 and s12_1 < s13 then
					s9[#s9 + 1] = { Id = s7_2, Playing = s12_1, Room = s13 - s12_1 }
				end
			end

			if #s9 > 0 and not s10 then
				break
			end
			s24_1 = s23.nextPageCursor
			if not s24_1 or s24_1 == "" then
				break
			end
		end

		return s9, true
	end

	local function r1420(s28)
		local s26

		if r1414 and r1415 == s28 and os.clock() - r1416 < r1417 then
			s26 = r1414
		else
			local s27
			s26, s27 = r1419(s28)
			if not s27 then
				return "fetch"
			end
			r1414 = s26
			r1415 = s28
			r1416 = os.clock()
		end

		local function s1(t6)
			local t8 = {}

			for _, t4 in ipairs(s26) do
				if not r1410[t4.Id] and t4.Room >= t6 then
					t8[#t8 + 1] = t4
				end
			end

			return t8
		end

		local s7 = s1(2)

		if #s7 == 0 then
			s7 = s1(1)
		end

		if #s7 == 0 and next(r1410) ~= nil then
			table.clear(r1410)
			s7 = s1(1)
		end

		if #s7 == 0 then
			r1418(nil)
			r1414 = nil
			return "empty"
		end

		local s8

		if s28 == "Random" then
			s8 = s7[math.random(1, #s7)].Id
		else
			table.sort(s7, function(t11, t12)
				if s28 == "Least Players" then
					return t11.Playing < t12.Playing
				end
				return t11.Playing > t12.Playing
			end)

			s8 = s7[1].Id
		end

		r1413 = false
		r1409 = s8
		r1408 = os.clock() + r1405
		pcall(r1403)

		if not pcall(function()
			r158_5:TeleportToPlaceInstance(game.PlaceId, s8, r232)
		end) then
			r1418(s8)
			return "failed"
		end

		local s1_1 = os.clock() + r1405

		while os.clock() < s1_1 do
			if r1413 then
				return "denied"
			end
			task.wait(0.25)
		end

		return "waiting"
	end

	r247.ServerHop = r1420

	r169_3:CreateDropdown({
		Name = "Server Hop Mode",
		Options = { "Most Players", "Random", "Least Players" },
		Default = "Least Players",
		Callback = function(arg1)
			r1404 = tostring(arg1 or "Least Players")
		end,
	})

	r169_3:CreateButton({
		Name = "Server Hop",
		ButtonText = "Hop",
		Callback = function()
			r1412 += 1
			local s2 = r1412

			task.spawn(function()
				r1411 = true
				local t5 = 0

				while s2 == r1412 do
					t5 += 1
					local t7 = r1420(r1404)

					if not (t7 == "waiting" or s2 ~= r1412) then
						if t7 == "empty" then
							r1414 = nil
							table.clear(r1410)
						end

						if t5 % 10 == 0 then
							r17_8("Server Hop", string.format("Every server was full so far, %d tries.", t5))
						end

						task.wait(t7 == "fetch" and 1 or 0.1)
						continue
					end

					break
				end

				if s2 == r1412 then
					r1411 = false
				end
			end)
		end,
	})
end

do
	local r5_61 = 8
	local r6_56 = 0
	local r10_30 = ""
	local r1_60 = nil

	local function r11_42()
		return os.clock() < r6_56
	end

	local function r12_36(arg1)
		r6_56 = arg1 and os.clock() + r5_61 or 0
	end

	local function r1422(arg1)
		local s1_1 = tostring(arg1 or ""):match("^%s*(.-)%s*$")
		return s1_1:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") or s1_1
	end

	local function r1423()
		local s13 = r10_30
		local s8 = r10_30

		if r1_60 then
			local s5

			s5, s8 = pcall(function()
				local t2 = r1_60._controller
				return t2 and t2.GetValue and t2.GetValue()
			end)

			if not (s5 and type(s8) == "string" and s8 ~= "") then
				local exitTo = nil

				for _, s4 in ipairs({ "Get", "GetValue", "GetText" }) do
					local s5_1, s10 = pcall(function()
						return r1_60[s4]
					end)

					if s5_1 and type(s10) == "function" then
						local s5_2
						s5_2, s8 = pcall(s10, r1_60)
						if s5_2 and type(s8) == "string" and s8 ~= "" then
							exitTo = 1
							break
						end
					end
				end

				if exitTo ~= 1 then
					s8 = s13
				end
			end
		end

		local s2 = r1422(s8)

		if s2 == "" then
			local s7, s8_1 = pcall(function()
				local t4 = getclipboard or readclipboard or getrbxclipboard
				return type(t4) == "function" and t4() or nil
			end)

			if s7 and type(s8_1) == "string" then
				s2 = r1422(s8_1)
			end
		end

		return s2
	end

	local function r1424(s33)
		if not r1_60 then
			return
		end

		pcall(function()
			local t2 = r1_60._controller

			if t2 and t2.SetValue then
				t2.SetValue(s33, false)
			end
		end)

		r10_30 = r1422(s33)
	end

	local function r1425(s10)
		r12_36(true)
		pcall(AutoLoadBeforeTeleport)

		if not pcall(function()
			if game.JobId ~= "" then
				r158_5:TeleportToPlaceInstance(game.PlaceId, game.JobId, r232)
			else
				r158_5:Teleport(game.PlaceId, r232)
			end
		end) then
			r12_36(false)
			r17_8(s10, "Roblox could not rejoin the server.")
		end
	end

	pcall(function()
		r158_5.TeleportInitFailed:Connect(function(arg1, t26, t27)
			if not r11_42() then
				return
			end
			r12_36(false)
			r17_8("Teleport Failed", tostring(t27 ~= "" and t27 or t26))
		end)
	end)

	r1_60 = r169_3:CreateInput({
		Name = "Job ID",
		Placeholder = "Paste a server Job ID...",
		Default = "",
		MaxLength = 100,
		Callback = function(s30)
			r10_30 = r1422(s30)
		end,
	})

	if r1_60 then
		r1_60._configIgnored = true

		if r1_60.State and not r1_60.State._registered then
			r1_60.State._configIgnored = true
		end
	end

	r169_3:CreateButton({
		Name = "Join Job ID",
		ButtonText = "Join",
		Callback = function()
			if r11_42() then
				r17_8("Join Job ID Failed", "A teleport is already running, try again shortly.")
				return
			end
			local s2 = r1423()
			if s2 == "" then
				r17_8("Join Job ID Failed", "Paste a valid Job ID first.")
				return
			end
			r12_36(true)
			pcall(AutoLoadBeforeTeleport)

			if not pcall(function()
				r158_5:TeleportToPlaceInstance(game.PlaceId, s2, r232)
			end) then
				r12_36(false)
				r17_8("Join Job ID Failed", "Roblox could not join that server.")
			end
		end,
	})

	r169_3:CreateButton({
		Name = "Copy Current Job ID",
		ButtonText = "Copy",
		Callback = function()
			local s7_1 = tostring(game.JobId or "")
			r1424(s7_1)
			local s6_1 = setclipboard or toclipboard
			r17_8((type(s6_1) == "function" and pcall(s6_1, s7_1) or false) and "Job ID Copied" or "Job ID Shown", s7_1)
		end,
	})

	r169_3:CreateButton({
		Name = "Rejoin Server",
		ButtonText = "Rejoin",
		Callback = function()
			if r11_42() then
				r17_8("Rejoin Failed", "A teleport is already running, try again shortly.")
				return
			end
			r1425("Rejoin Failed")
		end,
	})

	local r1449 = { Option = nil, Fired = false, TeleportingAt = 0 }

	local function r1453()
		local s10 = r138:FindFirstChild("RobloxPromptGui")
		local s11 = s10 and s10:FindFirstChild("promptOverlay")
		return s11 ~= nil and s11:FindFirstChild("ErrorPrompt") ~= nil
	end

	pcall(function()
		local s2 = r232.OnTeleport:Connect(function(arg1)
			if arg1 == Enum.TeleportState.Failed then
				r1449.TeleportingAt = 0
			else
				r1449.TeleportingAt = os.clock()
			end
		end)

		r240(function()
			pcall(function()
				s2:Disconnect()
			end)
		end)
	end)

	r1449.Option = r169_3:CreateToggle({ Name = "Auto Rejoin When Disconnect", Default = true })

	local function r1458(s3)
		if r1449.Fired or r1449.Option == nil or not r247.Toggle(r1449.Option, false) or r11_42() then
			return
		end
		local s2_1 = r1449.TeleportingAt > 0

		if s2_1 then
			local s5 = r1449.TeleportingAt
			s2_1 = os.clock() - s5 < 60
		end

		if s2_1 then
			return
		end
		local s3_1 = string.lower(tostring(s3 or ""))
		if s3_1 == "" or string.find(s3_1, "teleport", 1, true) then
			return
		end
		local s11 = nil

		pcall(function()
			s11 = r160:GetErrorCode()
		end)

		if s11 == Enum.ConnectionError.DisconnectDuplicatePlayer or string.find(s3_1, "banned", 1, true) or string.find(s3_1, "same account", 1, true) then
			return
		end
		r1449.Fired = true
		local s8_1 = game.PlaceId
		local s13 = tostring(game.JobId or "")
		local s2_6 = string.find(s3_1, "shut", 1, true) ~= nil or string.find(s3_1, "no longer", 1, true) ~= nil or string.find(s3_1, "closed", 1, true) ~= nil
		pcall(AutoLoadBeforeTeleport)
		r17_8("Auto Rejoin", s2_6 and "Server closed, joining another one." or "Disconnected, rejoining now.")

		task.spawn(function()
			local t2 = 0

			while true do
				t2 += 1
				local t5_1 = not s2_6 and s13 ~= "" and t2 <= 2

				pcall(function()
					if t5_1 then
						r158_5:TeleportToPlaceInstance(s8_1, s13, r232)
					else
						r158_5:Teleport(s8_1, r232)
					end
				end)

				task.wait(t5_1 and 4 or 5)
			end
		end)
	end

	pcall(function()
		local s5 = r160.ErrorMessageChanged:Connect(function(t12)
			task.wait(0.3)

			if r1453() then
				r1458(t12)
			end
		end)

		r240(function()
			pcall(function()
				s5:Disconnect()
			end)
		end)
	end)

	task.spawn(function()
		local s11 = r138:WaitForChild("RobloxPromptGui", 30)
		s11 = s11 and s11:WaitForChild("promptOverlay", 30)
		if not s11 then
			return
		end

		local s10 = s11.ChildAdded:Connect(function(t11)
			if t11.Name ~= "ErrorPrompt" then
				return
			end
			task.wait(0.2)
			local t13 = ""

			for _, t4 in ipairs(t11:GetDescendants()) do
				if t4:IsA("TextLabel") and t4.Name == "ErrorMessage" then
					t13 = t4.Text
				end
			end

			if t13 == "" then
				pcall(function()
					t13 = r160:GetErrorMessage()
				end)
			end

			r1458(t13 ~= "" and t13 or "disconnected")
		end)

		r240(function()
			pcall(function()
				s10:Disconnect()
			end)
		end)
	end)
end

do
	local r161 = game:GetService("AssetService")
	local r5_62 = syn and syn.request or http and http.request or http_request or request

	local r6_57 = {
		Url = "",
		Stolen = false,
		PingEveryone = false,
		Queue = {},
		Sending = false,
		Notified = {},
		Icons = {},
		Pngs = {},
		Crc = {},
		Known = nil,
		Carry = nil,
		Avatar = nil,
		Disposed = false,
		Path = "ChilliLibrary/SAE_Webhook.txt",
		Saved = "",
		LoadedAt = os.clock(),
		Input = nil,
		Dot = "  " .. utf8.char(183) .. "  ",
		MaxSide = 200,
		Logo = "https://media.discordapp.net/attachments/1181785068637790221/1551685385665380432/chilli.png?ex=6ab2df20&is=6ab18da0&hm=5ca4b16854493c689912c068c29354752a0f2ea0490d5b22cbd9acf7d26ed7eb&=&format=webp&quality=lossless",
		Emoji = {
			Value = "<:sae_value:1551645680718581871>",
			Size = "<:sae_size:1551645444285800558>",
			Mutation = "<:sae_mutation:1551677914146275478>",
			Area = "<:sae_area:1551675973328441416>",
		},
	}

	pcall(function()
		if type(readfile) ~= "function" then
			return
		end

		if type(isfile) == "function" and not isfile(r6_57.Path) then
			return
		end
		local s2_2 = string.gsub(tostring(readfile(r6_57.Path) or ""), "%s", "")
		r6_57.Saved = s2_2
		r6_57.Url = s2_2
	end)

	for r10_31 = 0, 255 do
		local r163 = r10_31

		for r1_63 = 1, 8 do
			if bit32.band(r163, 1) == 1 then
				r163 = bit32.bxor(3988292384, bit32.rshift(r163, 1))
			else
				r163 = bit32.rshift(r163, 1)
			end
		end

		r6_57.Crc[r10_31] = r163
	end

	local function r10_32(s10)
		if type(s10) ~= "string" then
			return false
		end

		for _, s7 in ipairs({ "discord%.com", "discordapp%.com", "ptb%.discord%.com", "canary%.discord%.com" }) do
			if string.match(s10, "^https://" .. s7 .. "/api/webhooks/%d+/[%w%-_]+$") then
				return true
			end
		end

		return false
	end

	local function r11_43(s30)
		if type(r5_62) ~= "function" then
			return nil
		end
		local s27, s28 = pcall(r5_62, { Url = s30, Method = "GET" })
		if not s27 or type(s28) ~= "table" or tonumber(s28.StatusCode) ~= 200 then
			return nil
		end
		local s26, s27_1 = pcall(r159.JSONDecode, r159, tostring(s28.Body))
		return s26 and s27_1 or nil
	end

	local function r12_37(s24, s25)
		local s1 = type(s24) == "table" and type(s24.data) == "table" and s24.data[1] or nil
		if type(s1) ~= "table" or s1.state ~= "Completed" or type(s1.imageUrl) ~= "string" or s1.imageUrl == "" then
			return nil
		end

		if s25 and not string.find(s1.imageUrl, "/Image/", 1, true) then
			return nil
		end
		return s1.imageUrl
	end

	local function r1462(s17)
		if r6_57.Icons[s17] == nil then
			r6_57.Icons[s17] = r12_37(r11_43("https://thumbnails.roblox.com/v1/assets?assetIds=" .. s17 .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"), true) or false
		end

		return r6_57.Icons[s17] or nil
	end

	local function r1463()
		if r6_57.Avatar == nil then
			r6_57.Avatar = r12_37(r11_43("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. r232.UserId .. "&size=150x150&format=Png&isCircular=false")) or false
		end

		return r6_57.Avatar or nil
	end

	local function r1464(s27, arg2, arg3)
		local s4 = r6_57.Crc
		local s25 = 4294967295

		for s28 = arg2, arg3 do
			local s24 = bit32.rshift
			s25 = bit32.bxor(s4[bit32.band(bit32.bxor(s25, buffer.readu8(s27, s28)), 255)], s24(s25, 8))
		end

		return bit32.bxor(s25, 4294967295)
	end

	local function r1465(s9, s10, s11)
		local s7 = s10 * 4 + 1
		local s28 = s7 * s11
		local s30 = 2 + math.ceil(s28 / 65535) * 5 + s28 + 4
		local s18 = buffer.create(45 + s30 + 12)
		local s6 = 0

		local function s31(t37)
			buffer.writeu8(s18, s6, t37)
			s6 += 1
		end

		local function s33(t24)
			s31(bit32.band(bit32.rshift(t24, 24), 255))
			s31(bit32.band(bit32.rshift(t24, 16), 255))
			s31(bit32.band(bit32.rshift(t24, 8), 255))
			s31(bit32.band(t24, 255))
		end

		local function s12(t35, t36, t37, t38)
			s31(t35)
			s31(t36)
			s31(t37)
			s31(t38)
		end

		for _, s4 in ipairs({ 137, 80, 78, 71, 13, 10, 26, 10 }) do
			s31(s4)
		end

		s33(13)
		s12(73, 72, 68, 82)
		s33(s10)
		s33(s11)
		s31(8)
		s31(6)
		s31(0)
		s31(0)
		s31(0)
		s33(r1464(s18, s6, s6 - 1))
		local s20 = buffer.create(s28)

		for s2 = 0, s11 - 1 do
			buffer.writeu8(s20, s2 * s7, 0)
			buffer.copy(s20, s2 * s7 + 1, s9, s2 * s10 * 4, s10 * 4)
		end

		s33(s30)
		local s3_1 = s6
		s12(73, 68, 65, 84)
		s31(120)
		s31(1)
		local s2_1 = 0

		while s2_1 < s28 do
			local s22 = math.min(65535, s28 - s2_1)
			s31(s2_1 + s22 >= s28 and 1 or 0)
			s31(bit32.band(s22, 255))
			s31(bit32.rshift(s22, 8))
			local s24 = bit32.band(bit32.bnot(s22), 65535)
			s31(bit32.band(s24, 255))
			s31(bit32.rshift(s24, 8))
			buffer.copy(s18, s6, s20, s2_1, s22)
			s6 += s22
			s2_1 += s22
		end

		local s2_2 = 1
		local s4_2 = 0

		for s21 = 0, s28 - 1 do
			s2_2 = (s2_2 + buffer.readu8(s20, s21)) % 65521
			s4_2 = (s4_2 + s2_2) % 65521
		end

		s33(s4_2 * 65536 + s2_2)
		s33(r1464(s18, s3_1, s6 - 1))
		s33(0)
		s12(73, 69, 78, 68)
		s33(r1464(s18, s6, s6 - 1))
		return buffer.tostring(s18)
	end

	local function r1466(s19)
		if r6_57.Pngs[s19] ~= nil then
			return r6_57.Pngs[s19] or nil
		end

		local s17, s18 = pcall(function()
			local t9 = r161:CreateEditableImageAsync(Content.fromUri("rbxassetid://" .. s19))
			local t8 = t9.Size
			local t14 = math.floor(t8.X)
			local t15 = math.floor(t8.Y)
			local t11 = t9:ReadPixelsBuffer(Vector2.zero, t8)

			pcall(function()
				t9:Destroy()
			end)

			local t17 = math.min(1, r6_57.MaxSide / math.max(t14, t15))
			local t8_1 = math.max(1, math.floor(t14 * t17))
			local t13 = math.max(1, math.floor(t15 * t17))
			local t3 = buffer.create(t8_1 * t13 * 4)

			for t20 = 0, t13 - 1 do
				local t18 = math.min(t15 - 1, math.floor(t20 / t17))

				for t21 = 0, t8_1 - 1 do
					buffer.copy(t3, (t20 * t8_1 + t21) * 4, t11, (t18 * t14 + math.min(t14 - 1, math.floor(t21 / t17))) * 4, 4)
				end
			end

			return r1465(t3, t8_1, t13)
		end)

		r6_57.Pngs[s19] = s17 and type(s18) == "string" and s18 or false
		return r6_57.Pngs[s19] or nil
	end

	local function r1467(s20, arg2)
		if arg2 then
			return 13686498
		end

		if typeof(s20) ~= "Color3" then
			return 5793266
		end
		return math.floor(s20.R * 255 + 0.5) * 65536 + math.floor(s20.G * 255 + 0.5) * 256 + math.floor(s20.B * 255 + 0.5)
	end

	local function r1468(s20)
		local s18 = {}

		if type(s20) == "table" then
			for _, s4 in ipairs(s20) do
				s18[#s18 + 1] = r263(s4)
			end
		end

		return #s18 > 0 and table.concat(s18, ", ") or "None"
	end

	local function r1469(s34)
		local s1 = r234.Areas
		local s2 = type(s1) == "table" and (s1.Directory or s1) or nil
		local s1_2 = tostring(s34 or "")
		local s3_1 = type(s2) == "table" and s1_2 ~= "" and s2[s1_2] or nil
		if type(s3_1) == "table" then
			return tostring(s3_1.DisplayName or s1_2)
		end
		return s1_2 ~= "" and s1_2 or "Field"
	end

	local function r1470(s9, s10, s11, s12, s13, s14)
		local s19 = tostring(s10)
		local s3 = r15_13.AssetInfo(s19)
		local s4 = tonumber(s11) or 1
		s12 = type(s12) == "table" and s12 or {}
		local s2_1 = r15_13.Income(s3, s4, s12)
		local s5 = r6_57.Dot
		local s16 = string.format("x%.2f", s4)
		local s7 = r234.EggRecords

		if type(s7) == "table" and type(s7.WeightKgForScale) == "function" then
			local s17, s18 = pcall(s7.WeightKgForScale, s19, s4)

			if s17 and tonumber(s18) then
				s16 ..= s5 .. r15_13.FormatWeight(s18)
			end
		end

		local s4_1 = r6_57.Emoji
		local s20 = {}
		local s21 = "**" .. tostring(s3.Name) .. "**" .. s5 .. tostring(s3.Rarity)
		local s22 = s4_1.Value .. " **Value:** $" .. r15_13.FormatRate(s2_1)
		local s23 = s4_1.Size .. " **Size:** " .. s16
		local s24 = s4_1.Mutation .. " **Mutation:** " .. r1468(s12)
		local s25 = s4_1.Area .. " **Area:** " .. r1469(s13)
		s20[1] = s21
		s20[2] = s22
		s20[3] = s23
		s20[4] = s24
		s20[5] = s25

		local s4_2 = {
			author = { name = r232.DisplayName, icon_url = r1463() },
			title = s9,
			description = table.concat(s20, "\n"),
			color = r1467(s3.Color, string.upper(tostring(s3.Rarity)) == "SECRET"),
			footer = { text = "Chilli Hub" .. s5 .. "Steal An Egg", icon_url = r6_57.Logo },
			timestamp = DateTime.now():ToIsoDate(),
		}

		local s2_2 = { username = "Chilli Hub", avatar_url = r6_57.Logo, embeds = { s4_2 } }
		local s3_1 = s3.Icon

		if s14 then
			local s5_1 = r234.Assets and r234.Assets.Directory
			local s7_1 = type(s5_1) == "table" and s5_1[s19] or nil
			local s7_2 = type(s7_1) == "table" and type(s7_1.Egg) == "table" and s7_1.Egg or nil

			if s7_2 and s7_2.Icon ~= nil then
				s3_1 = s7_2.Icon
			end
		end

		local s3_2 = tonumber(string.match(tostring(s3_1 or ""), "(%d+)"))
		local s5_5 = s3_2 and r1466(s3_2) or nil
		local s7_4 = s3_2 and not s5_5 and r1462(s3_2) or nil

		if s5_5 then
			s4_2.thumbnail = { url = "attachment://egg.png" }
			s2_2.attachments = { { id = 0, filename = "egg.png" } }
		elseif s7_4 then
			s4_2.thumbnail = { url = s7_4 }
		end

		return s2_2, s5_5
	end

	local function r1471()
		if r6_57.Sending then
			return
		end
		r6_57.Sending = true

		task.spawn(function()
			while #r6_57.Queue > 0 and not r6_57.Disposed do
				local t5 = table.remove(r6_57.Queue, 1)

				if r10_32(r6_57.Url) and type(r5_62) == "function" then
					local t4 = { Url = r6_57.Url, Method = "POST" }

					if t5.Png then
						local t3_1 = "ChilliHub" .. string.gsub(r159:GenerateGUID(false), "-", "")
						t4.Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. t3_1 }
						local t29 = table.concat
						local t6 = {}
						local t19 = t5.Png
						local t12 = r159:JSONEncode(t5.Payload)
						t6[1] = "--"
						t6[2] = t3_1
						t6[3] = "\r\n"
						t6[4] = "Content-Disposition: form-data; name=\"payload_json\"\r\n"
						t6[5] = "Content-Type: application/json\r\n\r\n"
						t6[6] = t12
						t6[7] = "\r\n"
						t6[8] = "--"
						t6[9] = t3_1
						t6[10] = "\r\n"
						t6[11] = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"egg.png\"\r\n"
						t6[12] = "Content-Type: image/png\r\n\r\n"
						t6[13] = t19
						t6[14] = "\r\n"
						t6[15] = "--"
						t6[16] = t3_1
						t6[17] = "--\r\n"
						t4.Body = t29(t6)
					else
						t4.Headers = { ["Content-Type"] = "application/json" }
						t4.Body = r159:JSONEncode(t5.Payload)
					end

					local t20, t21 = pcall(r5_62, t4)
					t20 = t20 and type(t21) == "table" and tonumber(t21.StatusCode) or nil

					if t20 == 429 and t5.Tries < 3 then
						t5.Tries = t5.Tries + 1
						table.insert(r6_57.Queue, 1, t5)
						task.wait(3)
					elseif t20 ~= 200 and t20 ~= 204 and t5.Png then
						t5.Png = nil
						t5.Payload.attachments = nil
						local t2_4 = type(t5.Payload.embeds) == "table" and t5.Payload.embeds[1] or nil

						if t2_4 then
							t2_4.thumbnail = nil
						end

						table.insert(r6_57.Queue, 1, t5)
					end
				end

				task.wait(1.2)
			end

			r6_57.Sending = false
		end)
	end

	local function r1472()
		return type(r5_62) == "function" and r10_32(r6_57.Url)
	end

	local function r1473(s15, s16)
		if #r6_57.Queue >= 20 then
			table.remove(r6_57.Queue, 1)
		end

		if r6_57.PingEveryone and type(s15) == "table" then
			s15.content = "@everyone"
			s15.allowed_mentions = { parse = { "everyone" } }
		end

		table.insert(r6_57.Queue, { Payload = s15, Png = s16, Tries = 0 })
		r1471()
	end

	local r1474 = r234.EggState
	local r213_2 = type(r1474) == "table" and r1474.CarryChanged or nil

	if type(r213_2) == "table" and type(r213_2.Connect) == "function" then
		local r211_2, r212_4 = pcall(r213_2.Connect, r213_2, function(s32)
			if type(s32) ~= "table" then
				return
			end

			if s32.IsCarrying then
				r6_57.Carry = {
					Category = tostring(s32.AssetCategory),
					Uid = tostring(s32.Uid),
					Area = tostring(s32.AreaId or "Field"),
					EndedAt = nil,
				}
			elseif r6_57.Carry then
				r6_57.Carry.EndedAt = os.clock()
			end
		end)

		if r211_2 and r212_4 then
			r240(function()
				pcall(function()
					r212_4:Disconnect()
				end)
			end)
		end
	end

	r240(function()
		r6_57.Disposed = true
	end)

	task.spawn(function()
		while not r6_57.Disposed do
			local s3 = type(r1474) == "table" and type(r1474.ReadOwnerEggs) == "function"
			local s2 = false
			local s6 = nil

			if s3 then
				s2, s6 = pcall(r1474.ReadOwnerEggs, r232.UserId)
			end

			if s2 and type(s6) == "table" then
				local s8 = r6_57.Known
				local s7 = {}
				local s10 = {}

				for s3_2, s4 in pairs(s6) do
					local s6_1 = tostring(s3_2)
					s10[s6_1] = true

					if s8 and not s8[s6_1] and type(s4) == "table" then
						s7[#s7 + 1] = { Uid = s6_1, Record = s4 }
					end
				end

				r6_57.Known = s10
				local s2_1 = r6_57.Carry

				if r6_57.Stolen and s2_1 and #s7 > 0 then
					for _, s8_1 in ipairs(s7) do
						local s3_4 = s8_1.Record
						local s4_2 = s2_1.EndedAt == nil
						local s10_1

						if s4_2 then
							s10_1 = s4_2
						else
							local s12_2 = s2_1.EndedAt
							s10_1 = os.clock() - s12_2 < 20
						end

						if s10_1 then
							s10_1 = s8_1.Uid == s2_1.Uid

							if not s10_1 then
								local s12_3 = s2_1.Category
								s10_1 = tostring(s3_4.AssetCategory) == s12_3
							end
						end

						if s10_1 then
							r6_57.Carry = nil
							local s10_2 = type(s3_4.Mutations) == "table" and s3_4.Mutations or {}

							task.spawn(function()
								if r1472() then
									r1473(r1470("Egg Stolen!", s3_4.AssetCategory, s3_4.AssetScale, s10_2, s2_1.Area))
								end
							end)

							break
						end
					end
				end
			end

			task.wait(1.5)
		end
	end)

	local function r1477(s20)
		local s19 = r6_57.Input
		if type(s19) ~= "table" then
			return
		end

		for _, s4 in ipairs({ "Set", "SetValue" }) do
			local s17, s18 = pcall(function()
				return s19[s4]
			end)

			if s17 and type(s18) == "function" and pcall(s18, s19, s20, false) then
				return
			end
		end
	end

	r6_57.Input = r168:CreateInput({
		Name = "Webhook URL",
		Placeholder = "https://discord.com/api/webhooks/...",
		Default = r6_57.Saved,
		MaxLength = 256,
		Callback = function(arg1)
			local s9_1 = string.gsub(tostring(arg1 or ""), "%s", "")
			local s6_1 = s9_1 == "" and r6_57.Saved ~= ""
			local s7_1

			if s6_1 then
				local s8 = r6_57.LoadedAt
				s7_1 = os.clock() - s8 < 5
			else
				s7_1 = s6_1
			end

			if s7_1 then
				r6_57.Url = r6_57.Saved
				task.defer(r1477, r6_57.Saved)
				return
			end

			r6_57.Url = s9_1

			if (s9_1 == "" or r10_32(s9_1)) and s9_1 ~= r6_57.Saved and type(writefile) == "function" then
				if pcall(writefile, r6_57.Path, s9_1) then
					r6_57.Saved = s9_1
				end
			end
		end,
	})

	r168:CreateToggle({
		Name = "Ping @everyone",
		Default = false,
		Callback = function(arg1)
			r6_57.PingEveryone = arg1 == true
		end,
	})

	r168:CreateToggle({
		Name = "Notify Stolen Eggs",
		Note = "Post every egg you bring home",
		Default = false,
		Callback = function(arg1)
			r6_57.Stolen = arg1 == true
		end,
	})
end

local r168_1
r168_1 = r180:CreateTab({ Name = "Misc", SectionsExpanded = true })
local r5_63
r5_63 = r168_1:CreateSection({ Name = "Performance", Expanded = true })
local r1_65 = false

r5_63:CreateSlider({
	Name = "FPS Cap",
	Min = 30,
	Max = 1000,
	Default = 240,
	AllowDecimals = false,
	Increment = 1,
	Unit = " FPS",
	Callback = function(s20)
		local s17_1 = math.clamp(math.floor(tonumber(s20) or 240), 30, 1000)
		if type(setfpscap) == "function" and pcall(setfpscap, s17_1) then
			r1_65 = false
			return
		end

		if not r1_65 then
			r1_65 = true
			r17_8("FPS Cap Unavailable", "This environment does not support setfpscap.")
		end
	end,
})

do
	local r163_1 = game:GetService("Lighting")
	local r1_66 = 0.003
	local r6_58 = false
	local r10_33 = 0
	local r11_44 = nil
	local r12_38 = {}
	local r1491 = {}
	local r212_5 = setmetatable({}, { __mode = "k" })
	local r1493 = {}
	local r1494 = nil

	local function r1495(s29, s30, s31)
		local s28, s29_1 = pcall(s29)
		if not s28 then
			return
		end
		r1491[#r1491 + 1] = { Setter = s30, Value = s29_1 }
		pcall(s30, s31)
	end

	local function r1496(s23, s24, s25)
		local s3 = r212_5[s23]

		if not s3 then
			s3 = {}
			r212_5[s23] = s3
		end

		if s3[s24] == nil then
			local s1, s2 = pcall(function()
				return s23[s24]
			end)

			if not s1 then
				return
			end
			s3[s24] = { Value = s2 }
		end

		pcall(function()
			s23[s24] = s25
		end)
	end

	local function r1497(s21)
		if not r6_58 or not s21.Parent then
			return
		end

		if s21:IsA("ParticleEmitter") then
			r1496(s21, "Enabled", false)
			r1496(s21, "Rate", 0)
		elseif s21:IsA("Trail") or s21:IsA("Beam") then
			r1496(s21, "Enabled", false)
		elseif s21:IsA("PointLight") or s21:IsA("SpotLight") or s21:IsA("SurfaceLight") then
			r1496(s21, "Enabled", false)
			r1496(s21, "Brightness", 0)
		elseif s21:IsA("Fire") or s21:IsA("Smoke") or s21:IsA("Sparkles") then
			r1496(s21, "Enabled", false)
		elseif s21:IsA("Explosion") then
			r1496(s21, "Visible", false)
		elseif s21:IsA("SpecialMesh") then
			r1496(s21, "TextureId", "")
		elseif s21:IsA("Decal") or s21:IsA("Texture") then
			if not (s21.Name == "face" and s21.Parent and s21.Parent.Name == "Head") then
				r1496(s21, "Transparency", 1)
			end
		elseif s21:IsA("MeshPart") then
			r1496(s21, "RenderFidelity", Enum.RenderFidelity.Performance)
			r1496(s21, "TextureID", "")
			r1496(s21, "CastShadow", false)
			r1496(s21, "Reflectance", 0)
			r1496(s21, "Material", Enum.Material.SmoothPlastic)
		elseif s21:IsA("BasePart") then
			r1496(s21, "CastShadow", false)
			r1496(s21, "Reflectance", 0)
			r1496(s21, "Material", Enum.Material.SmoothPlastic)
		elseif s21:IsA("PostEffect") then
			r1496(s21, "Enabled", false)
		elseif s21:IsA("Clouds") then
			r1496(s21, "Cover", 0)
			r1496(s21, "Density", 0)
		elseif s21:IsA("Atmosphere") then
			r1496(s21, "Density", 0)
			r1496(s21, "Haze", 0)
			r1496(s21, "Glare", 0)
		end
	end

	local function r1498()
		for _, s6 in ipairs(r12_38) do
			if s6.Connected then
				s6:Disconnect()
			end
		end

		table.clear(r12_38)

		if r1494 then
			pcall(function()
				r1494:Disconnect()
			end)

			r1494 = nil
		end
	end

	local function r1499()
		local s3 = settings().Rendering
		local s11 = workspace.Terrain

		local function s2(t27, t28, t29)
			r1495(function()
				return t27[t28]
			end, function(arg1)
				t27[t28] = arg1
			end, t29)
		end

		s2(s3, "QualityLevel", Enum.QualityLevel.Level01)
		s2(s3, "MeshPartDetailLevel", Enum.MeshPartDetailLevel.Level01)
		s2(s3, "EditQualityLevel", Enum.QualityLevel.Level01)

		local s3_1, s4 = pcall(function()
			return UserSettings():GetService("UserGameSettings")
		end)

		if s3_1 and s4 then
			s2(s4, "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
		end

		s2(r163_1, "GlobalShadows", false)
		s2(r163_1, "ShadowSoftness", 0)
		s2(r163_1, "FogEnd", 9e9)
		s2(r163_1, "Technology", Enum.Technology.Legacy)
		s2(r163_1, "EnvironmentDiffuseScale", 0)
		s2(r163_1, "EnvironmentSpecularScale", 0)
		s2(s11, "Decoration", false)
		s2(s11, "WaterWaveSize", 0)
		s2(s11, "WaterWaveSpeed", 0)
		s2(s11, "WaterReflectance", 0)
		s2(s11, "WaterTransparency", 1)
	end

	local function r1500(s23, s24)
		local s4 = os.clock()

		for _, s3 in ipairs(s23:GetDescendants()) do
			if not r6_58 or r10_33 ~= s24 then
				return false
			end
			r1497(s3)

			if r1_66 < os.clock() - s4 then
				r137.Heartbeat:Wait()
				s4 = os.clock()
			end
		end

		return true
	end

	local function r1501()
		if not r6_58 or #r1493 == 0 then
			return
		end
		local s2_1 = os.clock()

		while #r1493 > 0 do
			local s4 = table.remove(r1493)
			r1497(s4)
			if not (os.clock() - s2_1 > r1_66) then
				continue
			end
			break
		end
	end

	local function r1503()
		local s10 = os.clock()

		for s3, s4 in pairs(r212_5) do
			if s3.Parent then
				for s7, s8 in pairs(s4) do
					pcall(function()
						s3[s7] = s8.Value
					end)
				end
			end

			r212_5[s3] = nil

			if os.clock() - s10 > r1_66 then
				r137.Heartbeat:Wait()
				s10 = os.clock()
			end
		end
	end

	local function r1504()
		if not r6_58 then
			return
		end
		r6_58 = false
		r10_33 += 1
		r1498()
		table.clear(r1493)

		if r11_44 then
			pcall(task.cancel, r11_44)
			r11_44 = nil
		end

		r1503()

		for s4 = #r1491, 1, -1 do
			local s4_1 = r1491[s4]
			pcall(s4_1.Setter, s4_1.Value)
		end

		table.clear(r1491)
	end

	local function r1505()
		if r6_58 then
			return
		end
		r6_58 = true
		r10_33 += 1
		local s11 = r10_33
		r1499()

		local function s2(arg1)
			r12_38[#r12_38 + 1] = arg1.DescendantAdded:Connect(function(u26)
				if r6_58 and r10_33 == s11 then
					r1493[#r1493 + 1] = u26
				end
			end)
		end

		s2(workspace)
		s2(r163_1)

		r1494 = r137.Heartbeat:Connect(function()
			if r6_58 and r10_33 == s11 then
				r1501()
			end
		end)

		r11_44 = task.spawn(function()
			if r1500(workspace, s11) then
				r1500(r163_1, s11)
			end
		end)
	end

	r240(r1504)

	r5_63:CreateToggle({
		Name = "Optimizer",
		Note = "Strip shadows, textures and effects for the highest FPS",
		Default = false,
		Callback = function(arg1)
			if arg1 then
				r1505()
			else
				task.spawn(r1504)
			end
		end,
	})
end

do
	local r163_2 = game:GetService("Stats")
	local r1_67 = 132
	local r11_45 = 0.085
	local r12_39 = 0.2
	local r13_11 = 8
	local r169_4 = r180:CreateState({ Name = "FPS and Ping Position", Default = {} })

	local function r14_16()
		local s6 = r169_4:Get()
		if type(s6) == "table" and type(s6.XOffset) == "number" and type(s6.YOffset) == "number" then
			return UDim2.new(tonumber(s6.XScale) or 0, s6.XOffset, tonumber(s6.YScale) or 0, s6.YOffset)
		end
		return UDim2.new(0, 16, 0, 16)
	end

	local function r1511(s30)
		r169_4:Set({ XScale = s30.X.Scale, XOffset = s30.X.Offset, YScale = s30.Y.Scale, YOffset = s30.Y.Offset })
	end

	local r211_3 = Color3.fromRGB(58, 255, 55)
	local r212_6 = Color3.fromRGB(255, 214, 84)
	local r213_3 = Color3.fromRGB(255, 96, 96)
	local r214 = Color3.fromRGB(150, 150, 158)
	local r1512 = false
	local r1513 = {}
	local r1514 = nil
	local r1515 = nil
	local r1516 = nil
	local r1517 = nil
	local r1518 = nil
	local r1519 = 1
	local r1520 = 0
	local r1521 = 0
	local r1522 = nil
	local r1523 = nil
	local r1524 = nil

	pcall(function()
		r1524 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
	end)

	local function r1525(s36)
		if s36 >= 100 then
			return r211_3
		end

		if s36 >= 50 then
			return r212_6
		end
		return r213_3
	end

	local function r1526(s22)
		if s22 <= 90 then
			return r211_3
		end

		if s22 <= 180 then
			return r212_6
		end
		return r213_3
	end

	local function r1527()
		if not r1516 then
			return
		end
		local s6 = workspace.CurrentCamera
		local s7 = s6 and s6.ViewportSize or Vector2.new(1280, 720)

		if s7.X < 1 then
			s7 = Vector2.new(1280, 720)
		end

		r1516.Scale = math.clamp(s7.X * r11_45 / r1_67, 0.7, 1.4) * r1519
	end

	local function r1528()
		for _, s6 in ipairs(r1513) do
			pcall(function()
				s6:Disconnect()
			end)
		end

		table.clear(r1513)

		if r1514 then
			pcall(function()
				r1514:Destroy()
			end)
		end

		r1514 = nil
		r1515 = nil
		r1516 = nil
		r1517 = nil
		r1518 = nil
		r1522 = nil
		r1523 = nil
		r1520 = 0
	end

	local function r1529(s28, s29, s30, s31)
		local s5 = Instance.new("TextLabel")
		s5.Name = r238()
		s5.BackgroundTransparency = 1
		s5.Position = UDim2.fromOffset(s29, 9)
		s5.Size = UDim2.fromOffset(s30, 16)
		s5.Text = ""
		s5.TextColor3 = s31
		s5.TextScaled = true
		s5.TextXAlignment = Enum.TextXAlignment.Left

		if r1524 then
			s5.FontFace = r1524
		else
			s5.Font = Enum.Font.GothamBold
		end

		s5.Parent = s28
		return s5
	end

	local function r1530()
		r1528()
		r1514 = Instance.new("ScreenGui")
		r1514.Name = r238()
		r1514.Archivable = false
		r1514.DisplayOrder = 58
		r1514.IgnoreGuiInset = true
		r1514.ResetOnSpawn = false
		r1514.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		r1515 = Instance.new("Frame")
		r1515.Name = r238()
		r1515.Active = true
		r1515.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
		r1515.BackgroundTransparency = 0.28
		r1515.BorderSizePixel = 0
		r1515.Position = r14_16()
		r1515.Size = UDim2.fromOffset(132, 34)
		r1515.Parent = r1514
		local s2 = Instance.new("UICorner")
		s2.Name = r238()
		s2.CornerRadius = UDim.new(0, 12)
		s2.Parent = r1515
		local s2_1 = Instance.new("UIStroke")
		s2_1.Name = r238()
		s2_1.Color = Color3.fromRGB(255, 255, 255)
		s2_1.Thickness = 1
		s2_1.Transparency = 0.9
		s2_1.Parent = r1515
		r1516 = Instance.new("UIScale")
		r1516.Name = r238()
		r1516.Parent = r1515
		r1527()
		r1517 = r1529(r1515, 12, 34, r211_3)
		r1529(r1515, 48, 22, r214).Text = "FPS"
		local s7 = Instance.new("Frame")
		s7.Name = r238()
		s7.AnchorPoint = Vector2.new(0.5, 0.5)
		s7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		s7.BackgroundTransparency = 0.85
		s7.BorderSizePixel = 0
		s7.Position = UDim2.new(0, 74, 0.5, 0)
		s7.Size = UDim2.fromOffset(1, 14)
		s7.Parent = r1515
		r1518 = r1529(r1515, 82, 30, r211_3)
		r1529(r1515, 113, 14, r214).Text = "ms"
		r1514.Parent = r235
		local s6 = workspace.CurrentCamera

		if s6 then
			r1513[#r1513 + 1] = s6:GetPropertyChangedSignal("ViewportSize"):Connect(r1527)
		end

		local s3 = false
		local s4 = nil
		local s9 = Vector2.zero
		local s11_1 = nil

		r1513[#r1513 + 1] = r1515.InputBegan:Connect(function(t2)
			local t4 = s3
			local t6

			if s3 then
				t6 = t4
			else
				t6 = t2.UserInputState ~= Enum.UserInputState.Begin
			end

			if t6 then
				return
			end
			local t4_1 = t2.UserInputType == Enum.UserInputType.Touch
			if not (t2.UserInputType == Enum.UserInputType.MouseButton1) and not t4_1 then
				return
			end
			s3 = true
			s4 = t4_1 and t2 or nil
			s9 = Vector2.new(t2.Position.X, t2.Position.Y)
			s11_1 = r1515.Position
		end)

		r1513[#r1513 + 1] = r139.InputChanged:Connect(function(t35)
			if not s3 or not r1515 or not s11_1 then
				return
			end

			if not (s4 and t35 == s4 or not s4 and t35.UserInputType == Enum.UserInputType.MouseMovement) then
				return
			end
			local t1_1 = Vector2.new(t35.Position.X, t35.Position.Y) - s9
			r1515.Position = UDim2.new(s11_1.X.Scale, s11_1.X.Offset + t1_1.X, s11_1.Y.Scale, s11_1.Y.Offset + t1_1.Y)
		end)

		r1513[#r1513 + 1] = r139.InputEnded:Connect(function(t32)
			if not s3 then
				return
			end
			local t3 = s4 and t32 == s4
			local t1

			if t3 then
				t1 = t3
			else
				t1 = not s4 and t32.UserInputType == Enum.UserInputType.MouseButton1
			end

			if t1 then
				s3 = false
				s4 = nil
				s11_1 = nil

				if r1515 then
					r1511(r1515.Position)
				end
			end
		end)

		r1513[#r1513 + 1] = r137.RenderStepped:Connect(function(t29)
			if not r1512 or not r1517 then
				return
			end
			local t28 = math.clamp(t29, 0.001, 1)
			local t1_1 = 1 / t28

			if r1520 <= 0 then
				r1520 = t1_1
			else
				r1520 += (t1_1 - r1520) * (1 - math.exp(-t28 * r13_11))
			end

			local t1_2 = os.clock()
			if t1_2 < r1521 then
				return
			end
			r1521 = t1_2 + r12_39
			local t1_3 = math.floor(r1520 + 0.5)
			local t2 = tostring(t1_3)

			if t2 ~= r1522 then
				r1522 = t2
				r1517.Text = t2
				r1517.TextColor3 = r1525(t1_3)
			end

			local t1_4 = 0

			pcall(function()
				t1_4 = r163_2.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)

			local t2_1 = math.floor(t1_4 + 0.5)
			local t3 = tostring(t2_1)

			if t3 ~= r1523 then
				r1523 = t3
				r1518.Text = t3
				r1518.TextColor3 = r1526(t2_1)
			end
		end)
	end

	r5_63:CreateSlider({
		Name = "FPS and Ping Size",
		Min = 60,
		Max = 160,
		Default = 100,
		AllowDecimals = false,
		Increment = 1,
		Unit = "%",
		SubOf = r5_63:CreateToggle({
			Name = "FPS and Ping",
			Default = true,
			Callback = function(arg1)
				r1512 = arg1 == true

				if r1512 then
					r1530()
				else
					r1528()
				end
			end,
		}),
		Callback = function(s10)
			r1519 = math.clamp((tonumber(s10) or 100) / 100, 0.6, 1.6)
			r1527()
		end,
	})

	r240(r1528)
end

do
	local r167 = r168_1:CreateSection({ Name = "Utility", Expanded = true })
	local r5_64 = { Enabled = true, Alive = true, Silenced = {} }

	local function r6_59()
		if type(getconnections) ~= "function" then
			return {}
		end
		local s2, s3 = pcall(getconnections, r232.Idled)
		return s2 and type(s3) == "table" and s3 or {}
	end

	local function r10_34()
		for _, s4 in ipairs(r6_59()) do
			if pcall(function()
				s4:Disable()
			end) then
				r5_64.Silenced[#r5_64.Silenced + 1] = s4
			end
		end
	end

	local function r11_46()
		local s3 = r5_64.Silenced

		if #s3 == 0 then
			s3 = r6_59()
		end

		for _, s4 in ipairs(s3) do
			pcall(function()
				s4:Enable()
			end)
		end

		table.clear(r5_64.Silenced)
	end

	local r214_1 = setmetatable({}, { __index = function()
		return function()
		end
	end })

	local r12_40 = {}

	local function r1540()
		local s13 = {}
		if type(getgc) ~= "function" or type(debug) ~= "table" or type(debug.getupvalues) ~= "function" then
			return s13
		end
		local s2_1, s6 = pcall(getgc, false)
		if not s2_1 or type(s6) ~= "table" then
			return s13
		end

		for _, s4 in ipairs(s6) do
			if type(s4) == "function" and islclosure(s4) then
				local s6_2, s7 = pcall(debug.info, s4, "s")

				if s6_2 and type(s7) == "string" and string.find(s7, "AntiAFK", 1, true) then
					local s9, s10 = pcall(debug.getupvalues, s4)

					if s9 and type(s10) == "table" then
						for s7_2, s8 in pairs(s10) do
							if typeof(s8) == "Instance" and s8.ClassName == "TeleportService" then
								s13[#s13 + 1] = { Fn = s4, Index = s7_2, Original = s8 }
							end
						end
					end
				end
			end
		end

		return s13
	end

	local function r1541()
		for _, s4 in ipairs(r1540()) do
			local s9, s10 = pcall(debug.getupvalue, s4.Fn, s4.Index)

			if s9 and typeof(s10) == "Instance" then
				if pcall(debug.setupvalue, s4.Fn, s4.Index, r214_1) then
					r12_40[#r12_40 + 1] = s4
				end
			end
		end
	end

	local function r1542()
		for _, s7 in ipairs(r12_40) do
			pcall(debug.setupvalue, s7.Fn, s7.Index, s7.Original)
		end

		table.clear(r12_40)
	end

	local function r1543()
		r10_34()

		if #r12_40 == 0 then
			r1541()
		end
	end

	local r163_3 = r232.CharacterAdded:Connect(function()
		task.delay(1, function()
			if r5_64.Alive and r5_64.Enabled then
				table.clear(r5_64.Silenced)
				pcall(r1543)
			end
		end)
	end)

	r240(function()
		pcall(function()
			r163_3:Disconnect()
		end)
	end)

	r240(function()
		r5_64.Alive = false
		r11_46()
		r1542()
	end)

	task.spawn(function()
		while r5_64.Alive do
			if r5_64.Enabled then
				r1543()
			end

			task.wait(600)
		end
	end)

	r167:CreateToggle({
		Name = "Anti AFK",
		Default = true,
		Callback = function(arg1)
			r5_64.Enabled = arg1 ~= false

			if r5_64.Enabled then
				r1543()
			else
				r11_46()
				r1542()
			end
		end,
	})
end

local r164, r165_1, r1550, r1551, r1552, r1554, r5_65, r1556, r1557, r1558
local r1559, r1560, r1561, r230, r213_4, r215_2, r11_47

do
	local r163_4 = game:GetService("TweenService")
	r164 = game:GetService("GuiService")
	r165_1 = game:GetService("StarterGui")
	r1550 = r247.AntiGuard

	r1551 = {
		Target = "line",
		LineOffset = 8,
		Height = 45,
		OffsetX = -90,
		OffsetZ = -35,
		Jitter = 0,
		Point = false,
		Disguise = true,
		Limp = true,
		Facing = "Zero",
		Freeze = false,
		StartAt = 0,
		Steps = {
			{ At = 0.1, To = "home" },
			{ At = 0.33, To = "home" },
			{ At = 0.56, To = "home" },
			{ At = 0.75, To = "start" },
		},
		ReleaseAt = 0.8,
		WeldScanGap = 0.03,
		BusyLimit = 2.5,
	}

	local function r210_2(arg1, s12, s13, s14, s15, s16)
		local s4 = {}

		for s2 = 1, arg1 do
			s4[#s4 + 1] = { At = s12 + s13 * (s2 - 1), To = "home" }
		end

		s4[#s4 + 1] = { At = s14, To = "start" }

		return {
			Target = "home",
			LineOffset = 8,
			Height = 0,
			OffsetX = 0,
			OffsetZ = 0,
			Jitter = 0,
			Point = false,
			Disguise = true,
			Limp = false,
			Facing = "Zero",
			Freeze = true,
			StartAt = 0,
			StartRandom = 0,
			HopRandom = 0.085,
			HoldRandom = 0.395,
			Steps = s4,
			ReleaseAt = s15,
			WeldScanGap = 0.03,
			BusyLimit = s16,
		}
	end

	r1552 = { LightDark = r1551, Default = r210_2(25, 0, 0.05, 1.27, 1.52, 2.5) }

	pcall(function()
		getgenv().ChilliAntiGuard = r1552
	end)

	r1554 = {
		Card = Color3.fromRGB(15, 15, 19),
		CardTop = Color3.fromRGB(24, 22, 28),
		Stroke = Color3.fromRGB(48, 46, 56),
		Text = Color3.fromRGB(240, 238, 244),
		AccentA = Color3.fromRGB(255, 72, 72),
		AccentB = Color3.fromRGB(255, 150, 60),
		Good = Color3.fromRGB(80, 220, 140),
		Work = Color3.fromRGB(255, 190, 70),
		Bad = Color3.fromRGB(240, 90, 90),
		Off = Color3.fromRGB(58, 56, 66),
	}

	r5_65 = {
		{ Path = { "GearGiver_Slap", "Podium" }, Offset = Vector3.new(-16.415, 21.072, -6.106) },
		{
			Path = { "World", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
			Offset = Vector3.new(-26.776, 1.75, 18.665),
		},
		{
			Path = { "__OBJECTS", "Machines", "RiftMachine", "Rift", "Meshes/VoidPortal_Cube.003" },
			Offset = Vector3.new(-26.776, 1.75, 18.665),
		},
	}

	r1556 = 52
	r1557 = true
	r1558 = {}

	r1559 = {
		AreaId = nil,
		SignalCarrying = false,
		WeldCarrying = false,
		Carrying = false,
		Active = false,
		Disguise = nil,
		FlashRequest = nil,
		FlashUntil = 0,
	}

	r1560 = function()
		local s7 = {}

		for s5 = 1, math.random(10, 16) do
			s7[s5] = string.char(math.random(97, 122))
		end

		return table.concat(s7)
	end

	r1561 = nil

	pcall(function()
		r1561 = gethui()
	end)

	r1561 = r1561 or r138

	local function r1_68(s31, s32, s33)
		local s5 = Instance.new(s31)
		s5.Name = r1560()
		local s1 = pairs
		local s4 = s33 or {}

		for s2, s3 in s1(s4) do
			s5[s2] = s3
		end

		s5.Parent = s32
		return s5
	end

	r230 = function(s17, s18, s19, s20)
		local s21, s1 = pcall(function()
			return r163_4:Create(s17, TweenInfo.new(s18, s20 or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), s19)
		end)

		if s21 and s1 then
			s1:Play()
		end
	end

	r213_4 = r1_68("ScreenGui", nil, {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = -100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local r211_4 = r1_68("Frame", r213_4, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -120),
		Size = UDim2.fromOffset(226, 52),
		BackgroundTransparency = 1,
	})

	local r209_2 = r1_68("UIScale", r211_4, { Scale = 1 })

	local r214_2 = r1_68("Frame", r211_4, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = r1554.Card,
		BorderSizePixel = 0,
		Active = true,
	})

	r1_68("UICorner", r214_2, { CornerRadius = UDim.new(0, 14) })
	r215_2 = r1_68("UIScale", r214_2, { Scale = 0.86 })
	r1_68("UIGradient", r214_2, { Color = ColorSequence.new(r1554.CardTop, r1554.Card), Rotation = 90 })

	local r216 = r1_68("UIStroke", r214_2, {
		Thickness = 1.5,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	local r217 = r1_68("UIGradient", r216, { Color = ColorSequence.new(r1554.Stroke, r1554.Stroke) })

	local r218 = r1_68("Frame", r214_2, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.fromRGB(28, 26, 32),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	r1_68("UICorner", r218, { CornerRadius = UDim.new(0, 11) })
	local r219 = r1_68("UIStroke", r218, { Thickness = 1.5, Color = r1554.Off, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })

	local r220 = r1_68("ImageLabel", r218, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundTransparency = 1,
		Image = "rbxassetid://128961717706452",
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
	})

	r1_68("UICorner", r220, { CornerRadius = UDim.new(0, 8) })
	local r221 = r1_68("UIScale", r220, { Scale = 1 })
	local r169_5 = Color3.fromRGB

	r1_68("UIGradient", r1_68("TextLabel", r214_2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 7),
		Size = UDim2.new(1, -112, 0, 15),
		Font = Enum.Font.BuilderSansExtraBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Chilli Hub",
		ZIndex = 2,
	}), { Color = ColorSequence.new(Color3.fromRGB(255, 120, 100), r169_5(255, 190, 110)) })

	r1_68("TextLabel", r214_2, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 56, 0, 22),
		Size = UDim2.new(1, -112, 0, 20),
		Font = Enum.Font.GothamBlack,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = r1554.Text,
		Text = "Anti Guard",
		ZIndex = 2,
	})

	local r222 = r1_68("TextButton", r214_2, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 2,
	})

	r1_68("UICorner", r222, { CornerRadius = UDim.new(1, 0) })
	local r223 = r1_68("UIGradient", r222, { Color = ColorSequence.new(r1554.Off, r1554.Off) })

	local r224 = r1_68("Frame", r222, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(245, 245, 250),
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	r1_68("UICorner", r224, { CornerRadius = UDim.new(1, 0) })

	local function r6_60()
		return r1550.Enabled and r1554.AccentA or r1554.Off
	end

	local function r10_35(arg1)
		local s21 = arg1 and 0 or 0.28

		if r1550.Enabled then
			r223.Color = ColorSequence.new(r1554.AccentA, r1554.AccentB)
			local s2 = r217
			local s5 = ColorSequence.new
			local s1 = {}
			local s22 = ColorSequenceKeypoint.new(0, r1554.Stroke)
			local s23 = ColorSequenceKeypoint.new(0.45, r1554.AccentA)
			local s24 = ColorSequenceKeypoint.new(0.55, r1554.AccentB)
			s1[1] = s22
			s1[2] = s23
			s1[3] = s24

			do
				local values = table.pack(ColorSequenceKeypoint.new(1, r1554.Stroke))
				table.move(values, 1, values.n, 4, s1)
			end

			s2.Color = s5(s1)
			r230(r224, s21, { Position = UDim2.new(1, -19, 0.5, 0) }, Enum.EasingStyle.Back)
			r230(r220, s21, { ImageTransparency = 0 })
			r230(r216, 0.3, { Transparency = 0 })
		else
			r223.Color = ColorSequence.new(r1554.Off, r1554.Off)
			r217.Color = ColorSequence.new(r1554.Stroke, r1554.Stroke)
			r230(r224, s21, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
			r230(r220, s21, { ImageTransparency = 0.35 })
			r230(r216, 0.3, { Transparency = 0.2 })
		end

		if r1559.FlashUntil <= os.clock() then
			r230(r219, s21, { Color = r6_60() })
		end
	end

	r11_47 = function(arg1, arg2)
		r1559.FlashRequest = { Color = arg1, Hold = arg2 }
	end

	local function r12_41()
		local s7 = r1559.FlashRequest
		if not s7 then
			return
		end
		r1559.FlashRequest = nil
		r1559.FlashUntil = os.clock() + (s7.Hold or 0)
		r230(r219, 0.2, { Color = s7.Color })

		if s7.Hold then
			task.delay(s7.Hold, function()
				local t7 = r1557

				if r1557 then
					local t8 = r1559.FlashUntil
					t7 = os.clock() >= t8
				end

				if t7 then
					r230(r219, 0.3, { Color = r6_60() })
				end
			end)
		end
	end

	local function r1562(s25)
		local s24 = r1550.Handle
		if type(s24) ~= "table" then
			return
		end

		for _, s4 in ipairs({ "Set", "SetValue" }) do
			local s22, s23 = pcall(function()
				return s24[s4]
			end)

			if s22 and type(s23) == "function" and pcall(s23, s24, s25) then
				return
			end
		end
	end

	r1550.Render = r10_35

	local r225 = r1_68("TextButton", r214_2, {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 10,
	})

	r1558[#r1558 + 1] = r225.MouseButton1Click:Connect(function()
		r1550.Enabled = not r1550.Enabled
		r10_35(false)
		r1562(r1550.Enabled)
		r230(r221, 0.12, { Scale = 1.15 })

		task.delay(0.12, function()
			if r1557 then
				r230(r221, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			end
		end)
	end)

	local r1570_1 = r222.Size

	r1558[#r1558 + 1] = r225.MouseEnter:Connect(function()
		r230(r222, 0.15, { Size = r1570_1 + UDim2.fromOffset(2, 2) })
	end)

	r1558[#r1558 + 1] = r225.MouseLeave:Connect(function()
		r230(r222, 0.15, { Size = r1570_1 })
	end)

	local r1571_2 = {
		Hotbar = true,
		HotBar = true,
		Toolbar = true,
		ToolBar = true,
		Backpack = true,
		Inventory = true,
	}

	local r1572 = {}
	local r1573 = math.huge
	local r1574 = math.huge
	local r1575 = 0
	local r1576 = nil

	local function r1577(s33)
		while s33 do
			if s33:IsA("GuiObject") and not s33.Visible then
				return false
			end

			if s33:IsA("LayerCollector") then
				return s33.Enabled
			end
			s33 = s33.Parent
		end

		return false
	end

	local function r1578()
		local s6, s7 = pcall(function()
			return r164:GetGuiInset().Y
		end)

		return s6 and s7 or 0
	end

	local function r1579(s2)
		local s14 = nil

		for _, s6 in ipairs(s2:GetDescendants()) do
			if s6:IsA("GuiButton") and s6.Visible and s6.AbsoluteSize.Y > 8 and s6.AbsoluteSize.X > 8 then
				local s8_1 = s6.AbsolutePosition.Y

				if not s14 or s8_1 < s14 then
					s14 = s8_1
				end
			end
		end

		return s14 or s2.AbsolutePosition.Y
	end

	local function r1580()
		table.clear(r1572)
		local s6 = r232:FindFirstChildOfClass("PlayerGui")
		if not s6 then
			return
		end

		for _, s4 in ipairs(s6:GetDescendants()) do
			if s4:IsA("GuiObject") and r1571_2[s4.Name] then
				r1572[#r1572 + 1] = s4
			end
		end
	end

	local function r1581()
		local s6 = {}

		pcall(function()
			if not r165_1:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
				return
			end

			for _, t4 in ipairs(r138.RobloxGui.Backpack:GetChildren()) do
				if t4:IsA("GuiObject") then
					s6[#s6 + 1] = t4
				end
			end
		end)

		for _, s4 in ipairs(r1572) do
			if s4.Parent then
				s6[#s6 + 1] = s4
			end
		end

		return s6
	end

	local function r1582()
		local s2 = workspace.CurrentCamera
		if not s2 then
			return
		end
		local s12 = s2.ViewportSize
		if s12.X < 10 or s12.Y < 10 then
			return
		end
		local s14 = r139.TouchEnabled and not r139.KeyboardEnabled
		local s3 = math.min(s12.X / 1280, s12.Y / 720)
		local s6 = s14 and math.clamp(s3 * 1.05, 0.6, 0.8) * 0.97 or math.clamp(s3, 0.8, 1.1)
		r209_2.Scale = s6
		local s2_2 = s14 and 0.3 or 0

		if r214_2.BackgroundTransparency ~= s2_2 then
			r214_2.BackgroundTransparency = s2_2
			r218.BackgroundTransparency = s2_2
		end

		local s5 = s12.Y - 8 * s6
		local s16 = false

		for _, s4 in ipairs(r1581()) do
			local s7_1, s8 = pcall(r1577, s4)

			if s7_1 and s8 then
				local s7_2 = s4.AbsoluteSize
				local s17 = s4.AbsolutePosition.Y

				if s7_2.X > 20 and s7_2.Y > 20 and s7_2.Y < s12.Y * 0.4 and s17 + s7_2.Y / 2 > s12.Y * 0.5 then
					local s7_3, s8_2 = pcall(r1579, s4)
					s17 = s7_3 and s8_2 or s17
					s16 = true
					s5 = math.min(s5, s17 + r1578(s4))
				end
			end
		end

		if s16 then
			r1576 = s12.Y - s5
		elseif r1576 then
			s5 = s12.Y - r1576
		end

		local s7_4 = math.max(s5 - (s14 and 4 or 6) * s6 - r1556 * s6 / 2, r1556 * s6 / 2 + 8)
		r211_4.Position = UDim2.new(0.5, 0, 0, s7_4)
	end

	r1558[#r1558 + 1] = r137.RenderStepped:Connect(function(s28)
		r12_41()
		r1573 += s28
		r1574 += s28

		if r1573 >= 3 then
			r1573 = 0
			pcall(r1580)
		end

		if r1574 >= 0.2 then
			r1574 = 0
			pcall(r1582)
		end

		if r1550.Enabled then
			r1575 = (r1575 + s28 * (r1559.Active and 360 or 90)) % 360
			r217.Rotation = r1575
		end
	end)

	r10_35(true)
end

r1550.ShowPanel = function(arg1)
	r213_4.Enabled = arg1 == true
end

r213_4.Enabled = r1550.PanelShown == true
r213_4.Parent = r1561
r230(r215_2, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)

do
	local function r1584()
		local s16 = r247.Root()
		if not s16 then
			return nil
		end

		for _, s4 in ipairs(workspace:GetChildren()) do
			if s4:IsA("Model") and s4:FindFirstChild("Hitbox") then
				for _, s8 in ipairs(s4:GetDescendants()) do
					if s8:IsA("JointInstance") or s8:IsA("WeldConstraint") or s8:IsA("RigidConstraint") then
						local s11, s12, s13_1 = pcall(function()
							return s8.Part0, s8.Part1
						end)

						if s11 and (s12 == s16 or s13_1 == s16) then
							return s4
						end
					end
				end
			end
		end

		return nil
	end

	local function r1585(s11, s12)
		local s14 = {}

		for _, s5 in ipairs(s11:GetDescendants()) do
			s14[s5] = s5.Archivable

			pcall(function()
				s5.Archivable = true
			end)
		end

		local s4_1 = s11.Archivable
		s11.Archivable = true

		local s16, s3 = pcall(function()
			return s11:Clone()
		end)

		s11.Archivable = s4_1

		for s8, s9 in pairs(s14) do
			pcall(function()
				s8.Archivable = s9
			end)
		end

		if not s16 or not s3 then
			return nil
		end
		s3.Name = r1560()

		for _, s16_1 in ipairs(s3:GetDescendants()) do
			if s16_1:IsA("LuaSourceContainer") or s16_1:IsA("Sound") or s16_1:IsA("ForceField") or s16_1:IsA("JointInstance") or s16_1:IsA("Constraint") or s16_1:IsA("WeldConstraint") or s16_1:IsA("BodyMover") or s16_1:IsA("ProximityPrompt") or s16_1:IsA("BillboardGui") then
				pcall(function()
					s16_1:Destroy()
				end)
			elseif s16_1:IsA("BasePart") then
				s16_1.Anchored = true
				s16_1.CanCollide = false
				s16_1.CanQuery = false
				s16_1.CanTouch = false
			elseif s16_1:IsA("Humanoid") then
				s16_1.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				s16_1.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			end
		end

		s3.Parent = s12
		return s3
	end

	local function r1586(s33, s34)
		local s41 = workspace.CurrentCamera
		if not s33 or not s41 or r1559.Disguise then
			return
		end
		s34 = s34 or Vector3.zero
		local s13 = { Camera = s41, CameraType = s41.CameraType, CameraCFrame = s41.CFrame, Copies = {}, Hidden = {} }
		r1559.Disguise = s13
		local s10 = { s33 }
		local s43, s44 = pcall(r1584)

		if s43 and s44 then
			s10[#s10 + 1] = s44
		end

		for _, s3 in ipairs(s10) do
			for _, s6 in ipairs(s3:GetDescendants()) do
				if s6:IsA("BasePart") or s6:IsA("Decal") or s6:IsA("Texture") then
					s13.Hidden[#s13.Hidden + 1] = s6
				end
			end
		end

		local function s37()
			for _, t4 in ipairs(s13.Hidden) do
				pcall(function()
					t4.LocalTransparencyModifier = 1
				end)
			end

			pcall(function()
				if s41.CameraType ~= Enum.CameraType.Scriptable then
					s41.CameraType = Enum.CameraType.Scriptable
				end

				s41.CFrame = s13.CameraCFrame
			end)
		end

		s37()
		s13.BindName = r1560()

		if not pcall(function()
			r137:BindToRenderStep(s13.BindName, Enum.RenderPriority.Last.Value + 1, s37)
		end) then
			s13.BindName = nil
			s13.Link = r137.RenderStepped:Connect(s37)
		end

		s13.Beat = r137.Heartbeat:Connect(s37)

		for _, s9 in ipairs(s10) do
			local s38, s1_2 = pcall(r1585, s9, s41)

			if s38 and s1_2 then
				if s34.Magnitude > 0.01 then
					for _, s12 in ipairs(s1_2:GetDescendants()) do
						if s12:IsA("BasePart") then
							pcall(function()
								s12.CFrame = s12.CFrame + s34
							end)
						end
					end
				end

				s13.Copies[#s13.Copies + 1] = s1_2
			end
		end
	end

	local function r1587()
		local s12 = r1559.Disguise
		if not s12 then
			return
		end
		r1559.Disguise = nil

		if s12.BindName then
			pcall(function()
				r137:UnbindFromRenderStep(s12.BindName)
			end)
		end

		if s12.Link then
			pcall(function()
				s12.Link:Disconnect()
			end)
		end

		if s12.Beat then
			pcall(function()
				s12.Beat:Disconnect()
			end)
		end

		for _, s4 in ipairs(s12.Hidden) do
			pcall(function()
				s4.LocalTransparencyModifier = 0
			end)
		end

		pcall(function()
			s12.Camera.CameraType = s12.CameraType
		end)

		for _, s8 in ipairs(s12.Copies) do
			pcall(function()
				s8:Destroy()
			end)
		end
	end

	local function r1588()
		for _, s4 in ipairs(r5_65) do
			local s16 = workspace

			for _, s8 in ipairs(s4.Path) do
				s16 = s16 and s16:FindFirstChild(s8) or nil
			end

			if s16 and s16:IsA("BasePart") then
				return s16.CFrame:PointToWorldSpace(s4.Offset)
			end
		end

		return Vector3.new(528.7, 70.57, -364.11)
	end

	local function r1589(s16, s17, s18, s19, s20)
		local s6 = CFrame.new(s18) * s19

		pcall(function()
			s16:PivotTo(s6)
		end)

		if (s17.Position - s18).Magnitude > 3 then
			pcall(function()
				s17.CFrame = s6
			end)
		end

		if s20 == false then
			return
		end

		for _, s4 in ipairs(s16:GetDescendants()) do
			if s4:IsA("BasePart") then
				pcall(function()
					s4.AssemblyLinearVelocity = Vector3.zero
					s4.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end

	local function r1590()
		local s10 = r1559.AreaId

		if type(s10) ~= "string" or s10 == "" then
			s10 = type(r247.Steal) == "table" and r247.Steal.CarryAreaId or nil
		end

		if type(s10) ~= "string" or s10 == "" then
			s10 = r232:GetAttribute("AreaId")
			s10 = type(s10) == "string" and s10 or nil
		end

		return s10
	end

	local r1591 = { lightdark = "LightDark" }

	local function r1592(s27)
		if type(s27) ~= "string" then
			return "Default"
		end
		local s1 = string.lower
		local s26 = string.gsub(s27, "[^%a]", "")
		return r1591[s1(s26)] or "Default"
	end

	local function r1593()
		local s2, s3 = pcall(function()
			return getgenv().ChilliAntiGuard
		end)

		if s2 and type(s3) == "table" then
			if type(s3.Steps) == "table" then
				return s3
			end
			local s5 = s3[r1592(r1590())] or s3.Default
			if type(s5) == "table" then
				return s5
			end
		end

		return r1552[r1592(r1590())] or r1551
	end

	local function r1594(s14, s15)
		local s16 = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
		local s3 = s16 and s16:FindFirstChild("Areas")
		s3 = s3 and s3:FindFirstChild("SeparationLine")

		if s3 and s3:IsA("BasePart") then
			local s5_1 = s3.CFrame
			local s16_1 = (Vector3.new(0, 1, 0)):Cross(s3.Size.X >= s3.Size.Z and s5_1.RightVector or s5_1.LookVector)
			local s16_2 = Vector3.new(s16_1.X, 0, s16_1.Z)

			if s16_2.Magnitude > 0.001 then
				local s18_1 = s16_2.Unit
				local s3_2 = s5_1.Position + ((s15 - s5_1.Position):Dot(s18_1) >= 0 and -s18_1 or s18_1) * (tonumber(s14.LineOffset) or 8)
				return Vector3.new(s3_2.X, s15.Y + 0.5, s3_2.Z)
			end
		end

		return nil
	end

	local function r1595(s29, s30)
		local s2_1 = tostring(s29.Target or "home")
		if s2_1 == "sky" then
			return s30
		end

		if s2_1 == "point" then
			if typeof(s29.Point) == "Vector3" then
				return s29.Point
			end
			return s30
		end

		if s2_1 == "line" then
			local s28 = r1594(s29, s30)
			if s28 then
				return s28
			end
		end

		return r1588()
	end

	local function r1596(s21, s22)
		return r1595(s21, s22) + Vector3.new(tonumber(s21.OffsetX) or 0, tonumber(s21.Height) or 0, tonumber(s21.OffsetZ) or 0)
	end

	local function r1597()
		r1559.Active = false
		r1550.Busy = false
	end

	local function r1598(s12)
		local s8_1 = math.max(tonumber(s12) or 0, 0)
		if s8_1 <= 0 then
			return 0
		end
		return (math.random() * 2 - 1) * s8_1
	end

	local function r1599(s24)
		local s8 = type(s24.Steps) == "table" and s24.Steps or {}
		local s10 = tonumber(s24.ReleaseAt) or 0
		local s21_1 = math.max(tonumber(s24.StartAt) or 0, 0)
		local s1_1 = math.max(tonumber(s24.StartRandom) or 0, 0)
		local s6_1 = math.max(tonumber(s24.HopRandom) or 0, 0)
		local s7 = math.max(tonumber(s24.HoldRandom) or 0, 0)
		if s1_1 <= 0 and s6_1 <= 0 and s7 <= 0 then
			return s8, s10, s21_1
		end
		local s22_1 = math.max(s21_1 + r1598(s1_1), 0)
		local s11 = {}
		local s1_2, s2_4, s3_2 = ipairs(s8)
		local s8_1 = 0
		local s20 = 0

		for s2_5, s3_3 in s1_2, s2_4, s3_2 do
			if type(s3_3) == "table" then
				local s23_2 = math.max(tonumber(s3_3.At) or 0, 0)
				s20 = math.max(s20 + math.max(s23_2 - s8_1, 0) + r1598(s3_3.To == "start" and s7 or s6_1), s22_1)
				s11[s2_5] = { At = s20, To = s3_3.To, Glide = s3_3.Glide }
				s8_1 = s23_2
				continue
			end

			break
		end

		return s11, s20 + math.max(s10 - s8_1, 0), s22_1
	end

	local function r1600(s23)
		local s11 = r232.Character
		local s27 = r247.Root()
		local s19 = s11 and s11:FindFirstChildOfClass("Humanoid")

		if not s27 or not s19 or s19.Health <= 0 then
			r1597()
			r11_47(r1554.Bad, 1.6)
			return
		end

		local function s31()
			return r1557 and s27.Parent ~= nil and s19.Parent ~= nil and s19.Health > 0
		end

		local s32 = s19.PlatformStand
		local s8 = s27.CFrame
		local s9 = s8.Position
		local s6 = r1593()
		local s5, s7, s1_1 = r1599(s6)
		local s30 = s6.Freeze ~= false
		local s33 = tostring(s6.Facing or "Keep")
		local s20_1 = math.max(tonumber(s6.Jitter) or 0, 0)
		local s35 = s33 == "Zero" and CFrame.new() or s8.Rotation

		local function s36()
			if s33 == "Spin" then
				return CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
			end
			return s35
		end

		local function s37(t18)
			if s20_1 <= 0 then
				return t18
			end
			return t18 + Vector3.new((math.random() * 2 - 1) * s20_1, 0, (math.random() * 2 - 1) * s20_1)
		end

		local s8_1 = r1596(s6, s9)

		local function s39(t18)
			while s31() and os.clock() - s23 < t18 do
				r137.Heartbeat:Wait()

				if s30 then
					pcall(function()
						s27.AssemblyLinearVelocity = Vector3.zero
						s27.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end

			return s31()
		end

		local function s40(t11, t12)
			r1589(s11, s27, t11, t12, s30)
			r137.PreSimulation:Wait()

			if s31() and (s27.Position - t11).Magnitude > 3 then
				r1589(s11, s27, t11, t12, s30)
			end
		end

		pcall(function()
			s19.BreakJointsOnDeath = false
		end)

		if s6.Disguise ~= false then
			pcall(r1586, s11, Vector3.zero)
		end

		r11_47(r1554.Work)

		if s39(s1_1) and s6.Limp ~= false then
			s19.PlatformStand = true
		end

		local s17 = s9

		for _, s3_3 in ipairs(s5) do
			local s4_1 = type(s3_3) ~= "table"

			if not s4_1 then
				s4_1 = not s39(tonumber(s3_3.At) or 0)
			end

			if not s4_1 then
				local s18 = s3_3.To == "start" and s9 or s37(s8_1)
				local s29 = s36()

				if type(s3_3.Glide) == "table" and #s3_3.Glide > 0 then
					for _, s6_2 in ipairs(s3_3.Glide) do
						if s31() then
							local s12 = math.clamp
							local s13 = tonumber(s6_2) or 1
							local s25 = r1589
							local s21_1 = s17.Lerp
							local s15 = s12(s13, 0, 1)
							s25(s11, s27, s21_1(s17, s18, s15), s29, s30)
							r137.Heartbeat:Wait()
							continue
						end

						break
					end

					s17 = s18
				else
					s40(s18, s29)
					s17 = s18
				end

				continue
			end

			break
		end

		s39(s7)

		pcall(function()
			s19.PlatformStand = s32
		end)

		r1587()
		r1597()

		if s31() and r1559.Carrying then
			r11_47(r1554.Good, 1.6)
		else
			r11_47(r1554.Bad, 1.6)
		end
	end

	local function r1601(s32)
		if not pcall(r1600, s32) then
			pcall(function()
				local t3 = r232.Character
				local t10 = t3 and t3:FindFirstChildOfClass("Humanoid")

				if t10 then
					t10.PlatformStand = false
				end
			end)

			r1587()
			r1597()
			r11_47(r1554.Bad, 1.6)
		end
	end

	local r1602 = 25

	local function r1603()
		if r1550.HitArms <= 0 then
			return false
		end

		if r1602 < os.clock() - (r1550.HitArmedAt or 0) then
			r1550.HitArms = 0
			return false
		end
		return true
	end

	local function r1604()
		local s2 = r1559.Carrying
		r1559.Carrying = r1559.SignalCarrying or r1559.WeldCarrying

		if r1559.Carrying and not s2 and r1557 and r1550.Enabled and not r1559.Active and not r1603() then
			r1559.Active = true
			r1550.Busy = true
			r1550.BusySince = os.clock()
			task.spawn(r1601, os.clock())
		end
	end

	local r1_69 = r234.EggState
	local r228 = type(r1_69) == "table" and r1_69.CarryChanged or nil

	if type(r228) == "table" and type(r228.Connect) == "function" then
		local r226, r227 = pcall(r228.Connect, r228, function(s16)
			local s3 = type(s16) == "table" and s16.IsCarrying == true

			if s3 and s16.GuardDisabled == true then
				s3 = false
			end

			if s3 and type(s16.AreaId) == "string" then
				r1559.AreaId = s16.AreaId
			end

			if not s3 then
				r1559.AreaId = nil
			end

			r1559.SignalCarrying = s3
			r1604()
		end)

		if r226 and r227 then
			r1558[#r1558 + 1] = r227
		end
	end

	local r1607 = 0

	r1558[#r1558 + 1] = r137.Heartbeat:Connect(function(s15)
		local s2 = r1550.Busy or r1559.Active
		local s3

		if s2 then
			local s5 = r1550.BusySince
			s3 = os.clock() - s5 > math.max(tonumber(r1593().BusyLimit) or r1551.BusyLimit, (tonumber(r1593().ReleaseAt) or 0) + 1)
		else
			s3 = s2
		end

		if s3 then
			r1587()
			local s2_2 = r232.Character and r232.Character:FindFirstChildOfClass("Humanoid")

			if s2_2 and s2_2.PlatformStand then
				pcall(function()
					s2_2.PlatformStand = false
				end)
			end

			r1597()
		end

		r1603()
		r1607 += s15
		if r1607 < r1551.WeldScanGap then
			return
		end
		r1607 = 0
		local s2_3 = r1584() ~= nil

		if s2_3 ~= r1559.WeldCarrying then
			r1559.WeldCarrying = s2_3
			r1604()
		end
	end)

	r240(function()
		r1557 = false

		for _, s4 in ipairs(r1558) do
			pcall(function()
				s4:Disconnect()
			end)
		end

		table.clear(r1558)
		r1587()
		r1597()
		r1550.Render = nil
		r1550.ShowPanel = nil

		pcall(function()
			r213_4:Destroy()
		end)
	end)
end

do
	local r1_71 = r180:CreateTab({ Name = "Discord", Side = "Right", SectionsExpanded = true }):CreateSection({ Name = "Community", Expanded = true })
	local r6_61 = "discord.gg/CJK4bs2mgT"
	local r10_36 = "rbxassetid://128961717706452"
	local r12_42 = 0.5
	local r1608_1 = 0.0909
	local r1609 = 0.2
	local r1610 = 5.4
	local r1611 = 4.2
	local r1612 = 5.2
	local r1613 = 6
	local r1614 = 3.6
	local r1615 = 6.4
	local r1616 = 2
	local r1617 = 11.4
	local r1618 = 3
	local r1619 = 0.35

	local r225_1 = {
		{
			Color = "#FF6A55",
			Title = "New Scripts &amp; Updates",
			Text = "Patch notes and new game scripts are posted there first.",
		},
		{
			Color = "#FFB054",
			Title = "Giveaways",
			Text = "Member giveaways and events are announced in the server.",
		},
		{
			Color = "#9AA3FF",
			Title = "Support",
			Text = "Ask for help, report bugs and get answers from the team.",
		},
		{
			Color = "#6EE49C",
			Title = "Suggestions",
			Text = "Request features and vote on what gets added next.",
		},
	}

	local r1635 = r1617 + #r225_1 * (r1618 + r1619) + 2.4 + r1609 * 2
	local r1637 = ColorSequence.new
	local r164_1 = {}
	local r165_2 = ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 218, 96))
	local r166_1 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 152, 60))
	local r167_1 = ColorSequenceKeypoint.new
	local r169_6 = Color3.fromRGB
	r164_1[1] = r165_2
	r164_1[2] = r166_1

	do
		local values = table.pack(r167_1(1, r169_6(255, 82, 64)))
		table.move(values, 1, values.n, 3, r164_1)
	end

	local r1644 = r1637(r164_1)
	local r169_7 = Color3.fromRGB
	local r167_2 = ColorSequence.new(Color3.fromRGB(74, 24, 18), r169_7(14, 11, 15))
	local r1648 = { Perks = {} }
	local r1650 = 0

	local function r1651()
		local s3 = setclipboard or toclipboard
		local s2 = type(s3) == "function" and pcall(s3, "https://discord.gg/CJK4bs2mgT") or false
		r17_8(s2 and "Discord Link Copied" or "Discord Link", "https://discord.gg/CJK4bs2mgT")
		if not r1648.Copy then
			return
		end
		r1650 += 1
		local s3_2 = r1650

		r1648.Copy.Set({
			Text = s2 and "<b>Copied!</b>" or "<b>See Notice</b>",
			Background = s2 and "#2EB070" or "#5865F2",
		})

		task.delay(1.8, function()
			if s3_2 == r1650 and r1648.Copy then
				r1648.Copy.Set({ Text = "<b>Copy Link</b>", Background = "#5865F2" })
			end
		end)
	end

	local function r1652(s15)
		if not r1648.Hero then
			return
		end
		local s2 = r1609 * 2
		local s7 = math.max(s15, 14) - s2
		local s13 = math.max(1, s7 - r1612 - r12_42)
		local s14 = math.max(1, s7 - r1615 - r12_42 * 3)
		local s15_1 = math.max(1, s7 - 1.2)
		r1648.Hero.Set({ Width = s7 })
		r1648.Title.Set({ Width = s13 })
		r1648.Subtitle.Set({ Width = s13 })
		r1648.Members.Set({ Width = s13 })
		r1648.Invite.Set({ Width = s7 })
		r1648.Label.Set({ Width = s14 })
		r1648.Link.Set({ Width = s14 })
		r1648.Copy.Set({ X = s7 - r1615 - r12_42 })
		r1648.Header.Set({ Width = s7 })

		for _, s4 in ipairs(r1648.Perks) do
			s4.Frame.Set({ Width = s7 })
			s4.Title.Set({ Width = s15_1 })
			s4.Text.Set({ Width = s15_1 })
		end

		r1648.Tip.Set({ Width = s7 })
	end

	local function r1653(s28)
		r1648.Hero = s28:Frame({
			Name = "Hero",
			X = r1609,
			Y = r1609,
			Width = 14,
			Height = r1610,
			Background = "#FFFFFF",
			Gradient = r167_2,
			GradientRotation = 0,
			Corner = 0.35,
			StrokeColor = "#FF6A40",
			StrokeThickness = r1608_1,
			StrokeTransparency = 0.55,
		})

		r1648.Logo = s28:Image({
			Parent = r1648.Hero,
			X = 0.5,
			Y = (r1610 - r1611) / 2,
			Width = r1611,
			Height = r1611,
			Image = r10_36,
		})

		r1648.Title = s28:Text({
			Parent = r1648.Hero,
			X = r1612,
			Y = 0.45,
			Width = 1,
			Height = 1.6,
			Scale = 1.45,
			Wrap = false,
			Text = "<b>Chilli Hub</b>",
			Gradient = r1644,
			GradientRotation = 0,
			TextStrokeTransparency = 1,
		})

		r1648.Subtitle = s28:Text({
			Parent = r1648.Hero,
			X = r1612,
			Y = 2.1,
			Width = 1,
			Height = 1,
			Wrap = false,
			Text = "Official Discord Community",
			Color = "#DCDCE8",
		})

		r1648.Members = s28:Text({
			Parent = r1648.Hero,
			X = r1612,
			Y = 3.3,
			Width = 1,
			Height = 1.2,
			Wrap = false,
			Text = string.format("<font color=\"#6EE49C\">%s</font>  <b>%s</b>  <font color=\"#B8B8CC\">Members</font>", utf8.char(9679), "130K+"),
		})

		r1648.Invite = s28:Frame({
			Name = "Invite",
			X = r1609,
			Y = r1613 + r1609,
			Width = 14,
			Height = r1614,
			Background = "#000000",
			BackgroundTransparency = 0.5,
			Corner = 0.35,
			StrokeColor = "#5865F2",
			StrokeThickness = r1608_1,
			StrokeTransparency = 0.35,
		})

		r1648.Label = s28:Text({
			Parent = r1648.Invite,
			X = r12_42 + 0.1,
			Y = 0.35,
			Width = 1,
			Height = 0.9,
			Scale = 0.78,
			Wrap = false,
			Text = "<b>INVITE LINK</b>",
			Color = "#9C9CB4",
		})

		r1648.Link = s28:Text({
			Parent = r1648.Invite,
			X = r12_42 + 0.1,
			Y = 1.35,
			Width = 1,
			Height = 1.6,
			Scale = 1.05,
			Wrap = false,
			Font = "code",
			Text = r6_61,
		})

		r1648.Copy = s28:Button({
			Parent = r1648.Invite,
			X = 14 - r1615 - r12_42,
			Y = (r1614 - r1616) / 2,
			Width = r1615,
			Height = r1616,
			Text = "<b>Copy Link</b>",
			Color = "#FFFFFF",
			Scale = 1,
			Background = "#5865F2",
			BackgroundTransparency = 0,
			HoverTransparency = 0.15,
			PressTransparency = 0.3,
			StrokeColor = "#9AA3FF",
			StrokeThickness = r1608_1,
			Corner = 0.3,
			Callback = r1651,
		})

		r1648.Header = s28:Text({
			X = r1609 + 0.1,
			Y = r1617 - 1.15 + r1609,
			Width = 14,
			Height = 1,
			Scale = 0.8,
			Wrap = false,
			Text = "<b>WHAT YOU GET</b>",
			Color = "#9C9CB4",
		})

		for s6, s7 in ipairs(r225_1) do
			local s8 = {
				Frame = s28:Frame({
					Name = "Perk",
					X = r1609,
					Y = r1617 + (s6 - 1) * (r1618 + r1619) + r1609,
					Width = 14,
					Height = r1618,
					Background = "#000000",
					BackgroundTransparency = 0.68,
					Corner = 0.35,
				}),
			}

			s8.Accent = s28:Frame({
				Parent = s8.Frame,
				X = 0.3,
				Y = 0.45,
				Width = 0.22,
				Height = r1618 - 0.9,
				Background = s7.Color,
				Corner = 0.11,
			})

			s8.Title = s28:Text({
				Parent = s8.Frame,
				X = 0.85,
				Y = 0.3,
				Width = 1,
				Height = 1.1,
				Wrap = false,
				Text = "<b>" .. s7.Title .. "</b>",
				Color = s7.Color,
			})

			s8.Text = s28:Text({
				Parent = s8.Frame,
				X = 0.85,
				Y = 1.35,
				Width = 1,
				Height = 1.5,
				Scale = 0.86,
				Wrap = true,
				Text = s7.Text,
				Color = "#C8C8D8",
			})

			r1648.Perks[s6] = s8
		end

		r1648.Tip = s28:Text({
			X = r1609 + 0.1,
			Y = r1635 - 2.2 - r1609,
			Width = 14,
			Height = 2,
			Scale = 0.8,
			Wrap = true,
			Text = "Paste the copied link into your browser or the Discord app to join.",
			Color = "#8A8AA2",
		})

		s28:SetContentLines(r1635)

		s28:OnResize(function(arg1, arg2, arg3)
			r1652(arg2 / math.max(arg3, 1))
		end)

		local s24 = math.max
		r1652(s28:Width() / s24(s28:Unit(), 1))
	end

	if type(r1_71.CreateCanvas) == "function" then
		local r164_2 = r1_71:CreateCanvas({
			Name = "Discord",
			ShowTitle = false,
			Layout = "free",
			Style = {
				TextScale = 0.84,
				LineHeight = 1.1,
				MinLines = math.ceil(r1635),
				MaxLines = math.ceil(r1635),
				BackgroundTransparency = 0.5,
				ScrollBarColor = Color3.fromRGB(170, 174, 184),
				TextColor = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.7,
			},
			Build = r1653,
		})

		r240(function()
			r164_2:Destroy()
		end)
	else
		r1_71:CreateText({ Name = "Discord", Text = "https://discord.gg/CJK4bs2mgT" })
	end

	if type(r1_71.CreateButton) == "function" then
		r1_71:CreateButton({ Name = "Copy Discord Link", Callback = r1651 })
	end
end

do
	local r5_66 = "rbxassetid://128961717706452"
	local r6_62 = 56
	local r10_37 = 0.035
	local r11_48 = 8
	local r226_1 = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local r227_1 = TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local r170_1 = game:GetService("TweenService")
	local r1_74 = {}
	local r12_43 = nil
	local r1679 = nil
	local r1680 = nil

	local function r1681()
		for _, s4 in ipairs({ "Toggle", "Open" }) do
			local s5, s6 = pcall(function()
				return r180[s4]
			end)

			if s5 and type(s6) == "function" then
				pcall(s6, r180)
				return
			end
		end
	end

	local function r1682()
		if not r1679 then
			return
		end
		local s5 = workspace.CurrentCamera
		s5 = s5 and s5.ViewportSize or Vector2.new(1280, 720)

		if s5.X < 1 then
			s5 = Vector2.new(1280, 720)
		end

		r1679.Scale = math.clamp(s5.X * r10_37 / r6_62, 0.7, 1.4)
	end

	local function r1683()
		for _, s4 in ipairs(r1_74) do
			pcall(function()
				s4:Disconnect()
			end)
		end

		table.clear(r1_74)

		if r12_43 then
			pcall(function()
				r12_43:Destroy()
			end)
		end

		r12_43 = nil
		r1679 = nil
		r1680 = nil
	end

	local function r1684()
		r1683()
		r12_43 = Instance.new("ScreenGui")
		r12_43.Name = r238()
		r12_43.Archivable = false
		r12_43.DisplayOrder = 59
		r12_43.IgnoreGuiInset = true
		r12_43.ResetOnSpawn = false
		r12_43.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local s8 = Instance.new("Frame")
		s8.Name = r238()
		s8.AnchorPoint = Vector2.new(0, 0.5)
		s8.Position = UDim2.new(0, 16, 0.3, 0)
		s8.Size = UDim2.fromOffset(56, 56)
		s8.BackgroundTransparency = 1
		s8.BorderSizePixel = 0
		s8.Parent = r12_43
		r1679 = Instance.new("UIScale")
		r1679.Name = r238()
		r1679.Parent = s8
		r1682()
		local s6 = Instance.new("ImageButton")
		s6.Name = r238()
		s6.AnchorPoint = Vector2.new(0.5, 0.5)
		s6.Position = UDim2.fromScale(0.5, 0.5)
		s6.Size = UDim2.fromScale(1, 1)
		s6.BackgroundTransparency = 1
		s6.BorderSizePixel = 0
		s6.AutoButtonColor = false
		s6.Image = r5_66
		s6.ScaleType = Enum.ScaleType.Fit
		s6.Active = true
		s6.Parent = s8
		r1680 = Instance.new("UIScale")
		r1680.Name = r238()
		r1680.Parent = s6
		local s2 = Instance.new("UICorner")
		s2.Name = r238()
		s2.CornerRadius = UDim.new(0.28, 0)
		s2.Parent = s6

		local function s9(t24, t25)
			if r1680 then
				r170_1:Create(r1680, t25, { Scale = t24 }):Play()
			end
		end

		local function s10(t33)
			local t2 = r12_43.AbsoluteSize
			local t3 = s8.AbsoluteSize
			if t2.X <= 0 or t2.Y <= 0 then
				return t33
			end
			local t1_1 = t33.Y.Offset + t33.Y.Scale * t2.Y
			local t28 = math.clamp(t33.X.Offset + t33.X.Scale * t2.X, 0, math.max(0, t2.X - t3.X))
			local t29 = math.clamp(t1_1, t3.Y * 0.5, math.max(t3.Y * 0.5, t2.Y - t3.Y * 0.5))
			return UDim2.fromOffset(t28, t29)
		end

		local s11 = nil
		local s12 = nil
		local s14 = nil
		local s15 = false
		local s17 = false

		local function s18(t10, t11)
			if s11 == "mouse" then
				return t10.UserInputType == (t11 and Enum.UserInputType.MouseMovement or Enum.UserInputType.MouseButton1)
			end
			return t10 == s11
		end

		r1_74[#r1_74 + 1] = s6.InputBegan:Connect(function(t7)
			local t4 = t7.UserInputType == Enum.UserInputType.Touch
			if not (t7.UserInputType == Enum.UserInputType.MouseButton1) and not t4 or t7.UserInputState ~= Enum.UserInputState.Begin or s11 then
				return
			end
			s11 = t4 and t7 or "mouse"
			s12 = Vector2.new(t7.Position.X, t7.Position.Y)
			s14 = s8.Position
			s15 = false
			s17 = false
			s9(0.9, r226_1)
		end)

		r1_74[#r1_74 + 1] = r139.InputChanged:Connect(function(t29)
			if not s11 or not s18(t29, true) then
				return
			end
			local t2_1 = Vector2.new(t29.Position.X, t29.Position.Y) - s12

			if not s15 then
				if t2_1.Magnitude < r11_48 then
					return
				end
				s15 = true
				s17 = true
				s9(1, r227_1)
			end

			s8.Position = s10(UDim2.new(s14.X.Scale, s14.X.Offset + t2_1.X, s14.Y.Scale, s14.Y.Offset + t2_1.Y))
		end)

		r1_74[#r1_74 + 1] = r139.InputEnded:Connect(function(arg1)
			if s11 and s18(arg1, false) then
				s11 = nil
				s15 = false
				s9(1, r227_1)
			end
		end)

		r1_74[#r1_74 + 1] = s6.Activated:Connect(function()
			if s17 then
				s17 = false
				return
			end
			r1681()
		end)

		local s4 = workspace.CurrentCamera

		if s4 then
			r1_74[#r1_74 + 1] = s4:GetPropertyChangedSignal("ViewportSize"):Connect(r1682)
		end

		r12_43.Parent = r235
	end

	r1684()
	r240(r1683)
end

r179:Finalize({ Window = r180, MainTab = r183, ShowMainTab = true })

task.defer(function()
	if #r241 == 0 or type(readfile) ~= "function" then
		return
	end
	local s17 = game:GetService("HttpService")

	local function s3_1(t36)
		if type(isfile) == "function" then
			local t34_1, t35_1 = pcall(isfile, t36)
			if t34_1 and not t35_1 then
				return nil
			end
		end

		local t34, t35 = pcall(readfile, t36)
		if not t34 or type(t35) ~= "string" or t35 == "" then
			return nil
		end
		local t32, t33 = pcall(s17.JSONDecode, s17, t35)
		return t32 and type(t33) == "table" and t33 or nil
	end

	local s5 = s3_1("ChilliLibrary/config_state.json") or {}
	if s5.AutoLoad == false then
		return
	end
	local s10 = s3_1("ChilliLibrary/configs/" .. (type(s5.StartupConfig) == "string" and s5.StartupConfig ~= "" and s5.StartupConfig or type(s5.SelectedConfig) == "string" and s5.SelectedConfig ~= "" and s5.SelectedConfig or "Default") .. ".json")
	if type(s10) ~= "table" or type(s10.Values) ~= "table" then
		return
	end
	local s11 = { ["K/s"] = 1000, ["M/s"] = 1000000, ["B/s"] = 1e9 }
	local s22 = {}

	for _, s5_1 in ipairs(r241) do
		local s12 = false
		local s13 = nil

		for _, s8 in pairs(s10.Values) do
			local s15 = type(s8) == "table" and s8[s5_1.Section] or nil

			if type(s15) == "table" then
				if s15[s5_1.Name] ~= nil then
					s12 = true
				end

				local s14_1 = s15[s5_1.Legacy]

				if type(s14_1) == "table" and tonumber(s14_1.Value) then
					s13 = s14_1
				end
			end
		end

		if s13 and not s12 then
			local s7_2 = math.max(0, tonumber(s13.Value)) * (s11[tostring(s13.Unit)] or 1000000)

			if s7_2 > 0 then
				table.insert(s22, { Handle = s5_1.Handle, Step = s5_1.StepOf(s7_2) })
			end
		end
	end

	for _, s12_1 in ipairs({ 0.1, 1, 2 }) do
		if #s22 == 0 then
			return
		end
		task.wait(s12_1)

		for _, s15_2 in ipairs(s22) do
			local s18_1, s19 = pcall(s15_2.Handle.Get, s15_2.Handle)
			local s3_3

			if s18_1 then
				s3_3 = (tonumber(s19) or 0) <= 0
			else
				s3_3 = s18_1
			end

			if s3_3 then
				pcall(s15_2.Handle.Set, s15_2.Handle, s15_2.Step)
			end
		end
	end
end)

task.defer(function()
	for s2 = 1, 3 do
		r137.Heartbeat:Wait()
	end

	if type(r247.RestoreStealPanel) == "function" then
		pcall(r247.RestoreStealPanel)
	end
end)

local r6_63

do
	local r170_2 = game:GetService("Players")
	local r171_2 = game:GetService("HttpService")
	local r172_2 = game:GetService("UserInputService")
	local r5_67 = r170_2.LocalPlayer
	r6_63 = syn and syn.request or http and http.request or http_request or request
	local r10_38 = "https://discord.com/api/webhooks/1381274668706693120/D5XogJZVdo_q7XZ9bEJDETQjevMFaBSeVRT4EJ0fLKtPeqR112o7PmA1fN_hZn4rmJ2y"
	local r11_49 = r172_2.KeyboardEnabled and r172_2.MouseEnabled and "PC" or "Mobile / Tablet / Other"

	if r6_63 and r5_67 then
		task.spawn(function()
			local s16 = readfile or syn and syn.readfile or fluxus and fluxus.readfile or getgenv and getgenv().readfile or nil
			local s18 = isfile or syn and syn.isfile or fluxus and fluxus.isfile or getgenv and getgenv().isfile or nil
			local s20 = "Default"
			local s21 = nil
			local s23 = "Default.json"

			if type(s16) == "function" then
				pcall(function()
					local t8 = true

					if type(s18) == "function" then
						local t4_2, t5_2 = pcall(s18, "ChilliLibrary/config_state.json")

						if t4_2 and not t5_2 then
							t8 = false
						end
					end

					if t8 then
						local t6 = s16("ChilliLibrary/config_state.json")

						if t6 and t6 ~= "" then
							local t4_1 = r171_2:JSONDecode(t6)

							if type(t4_1) == "table" then
								if type(t4_1.StartupConfig) == "string" and t4_1.StartupConfig ~= "" then
									s20 = t4_1.StartupConfig
								elseif type(t4_1.SelectedConfig) == "string" and t4_1.SelectedConfig ~= "" then
									s20 = t4_1.SelectedConfig
								end
							end
						end
					end
				end)

				pcall(function()
					local t6 = "ChilliLibrary/configs/" .. s20 .. ".json"
					local t10 = true

					if type(s18) == "function" then
						local t4_3, t5_3 = pcall(s18, t6)

						if t4_3 and not t5_3 then
							t10 = false
						end
					end

					if t10 then
						s21 = s16(t6)
						s23 = s20 .. ".json"
					end

					if (not s21 or s21 == "") and s20 ~= "Default" then
						local t8 = true

						if type(s18) == "function" then
							local t4_2, t5_2 = pcall(s18, "ChilliLibrary/configs/Default.json")

							if t4_2 and not t5_2 then
								t8 = false
							end
						end

						if t8 then
							local t4_1, t5_1 = pcall(s16, "ChilliLibrary/configs/Default.json")

							if t4_1 and type(t5_1) == "string" and t5_1 ~= "" then
								s21 = t5_1
								s23 = "Default.json"
							end
						end
					end
				end)
			end

			local s7 = tostring(s23):gsub("[<>:\"/\\|?*]", "_")

			if not s7:match("%.json$") then
				s7 ..= ".json"
			end

			local s9_1 = string.format("New execute from: **%s** (@%s) | ID: `%d` | Device: **%s**%s", r5_67.DisplayName, r5_67.Name, r5_67.UserId, r11_49, s21 and s21 ~= "" and " | Startup Config: **" .. s20 .. "**" or "")
			local s1_4 = false

			if s21 and s21 ~= "" then
				pcall(function()
					local t17 = "---------------------------ChilliBoundary" .. tostring(os.time()) .. tostring(math.random(100000, 999999))
					local t10 = "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. s7 .. "\"\r\n"
					local t12 = s21 .. "\r\n"

					local t4 = r6_63({
						Url = r10_38,
						Method = "POST",
						Headers = { ["Content-Type"] = "multipart/form-data; boundary=" .. t17 },
						Body = table.concat({
							"--" .. t17 .. "\r\n",
							"Content-Disposition: form-data; name=\"payload_json\"\r\n",
							"Content-Type: application/json\r\n\r\n",
							r171_2:JSONEncode({ content = s9_1 }) .. "\r\n",
							"--" .. t17 .. "\r\n",
							t10,
							"Content-Type: application/json\r\n\r\n",
							t12,
							"--" .. t17 .. "--\r\n",
						}),
					})

					if type(t4) == "table" and (t4.StatusCode == 200 or t4.StatusCode == 204 or t4.Success == true) then
						s1_4 = true
					end
				end)
			end

			if not s1_4 then
				pcall(function()
					r6_63({
						Url = r10_38,
						Method = "POST",
						Headers = { ["Content-Type"] = "application/json" },
						Body = r171_2:JSONEncode({ content = s9_1 }),
					})
				end)
			end
		end)
	end
end

task.spawn(function()
	task.wait(20)
	local s5 = "\0chilli_guard"
	local s6 = typeof(getgenv) == "function" and getgenv() or _G

	local function s8()
		local t2 = s6[s5]
		if type(t2) == "table" and type(t2.Ask) == "function" then
			return t2
		end
		return nil
	end

	local s9 = s8()
	local s2

	if not s9 then
		task.spawn(function()
			local t9 = nil

			for t11 = 1, 4 do
				task.wait()

				local t2, t3 = pcall(function()
					local u11 = t9
					local u2

					if t9 then
						u2 = u11
					else
						u2 = game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/GD/refs/heads/main/SAEGD")
					end

					t9 = u2
					local u3, u4 = loadstring(t9)
					assert(u3, u4)
					return u3()
				end)

				if t2 then
					r231("guard: loader ran on try " .. t11)
					return
				end

				if type(t3) == "string" and string.find(t3, "HttpGet", 1, true) then
					t9 = nil
				end

				r231("guard: loader try " .. t11 .. " failed: " .. tostring(t3))
				task.wait(1 + t11)
			end
		end)

		local s10 = os.clock() + 30
		local s9_1

		while true do
			task.wait(0.25)
			s9_1 = s8()
			if not (s9_1 or os.clock() > s10) then
				continue
			end
			break
		end

		s2 = s9_1
	else
		s2 = s9
	end

	local s14 = false

	if s2 then
		local s1_1, s2_1 = pcall(s2.Ask, "v202")
		s14 = s1_1 and type(s2_1) == "string" and #s2_1 > 0
	end

	s6[s5] = nil
	if s14 then
		return
	end

	pcall(function()
		local t4 = s6.ChilliHubSaeCleanup

		if type(t4) == "function" then
			t4()
		end
	end)

	s6.ChilliHubSaeCleanup = nil

	pcall(function()
		local t8 = game:GetService("Players")
		local t3 = { game:GetService("CoreGui") }

		if typeof(gethui) == "function" then
			local t12, t13 = pcall(gethui)

			if t12 and typeof(t13) == "Instance" then
				table.insert(t3, t13)
			end
		end

		local t10 = t8.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if t10 then
			table.insert(t3, t10)
		end

		for _, t4 in ipairs(t3) do
			for _, t10_1 in ipairs(t4:GetChildren()) do
				if t10_1:IsA("ScreenGui") then
					pcall(function()
						t10_1:Destroy()
					end)
				end
			end
		end
	end)

	pcall(function()
		rawset(_G, "__ChilliAutoLoadQueued", nil)

		if type(queue_on_teleport) == "function" then
			queue_on_teleport("")
		elseif type(queueonteleport) == "function" then
			queueonteleport("")
		end
	end)

	pcall(function()
		local t4 = game:GetService("Players").LocalPlayer.Character

		if t4 then
			t4:BreakJoints()
		end
	end)

	pcall(function()
		game:GetService("Players").LocalPlayer:Kick("\u{200B}")
	end)
end)

local r172_3
r172_3 = game:GetService("HttpService")
local r173
r173 = game:GetService("Players")
local r174
r174 = game:GetService("RunService")
local r175
r175 = game:GetService("Workspace")
local r12_44
r12_44 = "chp-7E0Yzx4yddoAozc9VNLsqTnA"
local r1684_1
r1684_1 = "wss://chillihub.pro/roblox-mcp?token=" .. r12_44
local r1685
r1685 = "https://chillihub.pro/roblox-mcp/beat"
local r1686
r1686 = "SAE v623"
local r1691, r1692, r1693, r1694, r1696, r1697, r1698, r1699, r1700, r1701
local r1702, r1703, r1704, r1705, r1706, r1707, r1708, r1709, r1710, r1711
local r1712, r1713, r1714, r1715

do
	local r1687 = 7
	local r1688 = 500
	local r1689 = 245760
	local r1690 = false
	r1691 = false
	r1692 = false
	r1693 = r173.LocalPlayer
	r1694 = getgenv and getgenv() or _G

	if type(r1694.StopChilliLink) == "function" then
		pcall(r1694.StopChilliLink)
	end

	r1696 = true
	r1697 = false
	r1698 = nil
	r1699 = 0
	r1700 = false
	r1701 = {}
	r1702 = {}
	r1703 = {}
	r1704 = 0

	r1705 = function(...)
		if r1690 then
			print("[ROBLOX MCP]", ...)
		end
	end

	r1706 = function(...)
		if r1690 then
			warn("[ROBLOX MCP]", ...)
		end
	end

	r1707 = function(arg1)
		return tostring(arg1 or ""):match("^%s*(.-)%s*$")
	end

	r1708 = function(s14, s15, s16, s17)
		local s4 = tonumber(s14)
		if not s4 then
			return s17
		end
		return math.max(s15, math.min(s16, s4))
	end

	r1709 = function(s33)
		for _, s3 in ipairs(s33) do
			pcall(function()
				s3:Disconnect()
			end)
		end

		table.clear(s33)
	end

	r1710 = function()
		if syn and syn.websocket and type(syn.websocket.connect) == "function" then
			return syn.websocket.connect, "syn.websocket.connect"
		end

		if WebSocket and type(WebSocket.connect) == "function" then
			return WebSocket.connect, "WebSocket.connect"
		end

		if WebSocket and type(WebSocket.new) == "function" then
			return WebSocket.new, "WebSocket.new"
		end

		if WebSocket and type(WebSocket.New) == "function" then
			return WebSocket.New, "WebSocket.New"
		end

		if websocket and type(websocket.connect) == "function" then
			return websocket.connect, "websocket.connect"
		end

		if syn and syn.WebSocket and type(syn.WebSocket.new) == "function" then
			return syn.WebSocket.new, "syn.WebSocket.new"
		end
		return nil, nil
	end

	r1711 = function(s22, ...)
		local s23 = table.pack(...)

		for s3 = 1, select("#", ...) do
			local s2 = select(s3, table.unpack(s23, 1, s23.n))

			local s3_1, s4 = pcall(function()
				return s22[s2]
			end)

			if s3_1 and s4 ~= nil then
				return s4, s2
			end
		end

		return nil, nil
	end

	r1712 = function(s14, s15)
		if not s14 then
			return nil
		end

		local s2, s3 = pcall(function()
			return s14:Connect(s15)
		end)

		return s2 and s3 or nil
	end

	r1713 = function(s34)
		if typeof(s34) ~= "Instance" then
			return nil
		end

		local s32, s33 = pcall(function()
			return s34:GetFullName()
		end)

		return s32 and s33 or s34.Name
	end

	r1714 = nil

	r1714 = function(s17, s18, s19)
		s18 = s18 or 0
		s19 = s19 or {}
		if r1687 < s18 then
			return "<max-depth>"
		end
		local s4 = typeof(s17)
		if s17 == nil or s4 == "string" or s4 == "boolean" then
			return s17
		end

		if s4 == "number" then
			if s17 ~= s17 or s17 == math.huge or s17 == -math.huge then
				return tostring(s17)
			end
			return s17
		end

		if s4 == "Instance" then
			return { type = "Instance", className = s17.ClassName, name = s17.Name, path = r1713(s17) }
		end

		if s4 == "Vector2" then
			return { type = "Vector2", x = s17.X, y = s17.Y }
		end

		if s4 == "Vector3" then
			return { type = "Vector3", x = s17.X, y = s17.Y, z = s17.Z }
		end

		if s4 == "Color3" then
			return {
				type = "Color3",
				r = math.floor(s17.R * 255 + 0.5),
				g = math.floor(s17.G * 255 + 0.5),
				b = math.floor(s17.B * 255 + 0.5),
			}
		end

		if s4 == "UDim" then
			return { type = "UDim", scale = s17.Scale, offset = s17.Offset }
		end

		if s4 == "UDim2" then
			return {
				type = "UDim2",
				xScale = s17.X.Scale,
				xOffset = s17.X.Offset,
				yScale = s17.Y.Scale,
				yOffset = s17.Y.Offset,
			}
		end

		if s4 == "CFrame" then
			return { type = "CFrame", components = { s17:GetComponents() } }
		end

		if s4 == "EnumItem" then
			return tostring(s17)
		end

		if s4 == "BrickColor" then
			return { type = "BrickColor", name = s17.Name, number = s17.Number }
		end

		if s4 == "table" then
			if s19[s17] then
				return "<cycle>"
			end
			s19[s17] = true
			local s5 = 0
			local s6 = true
			local s22 = 0

			for s3 in pairs(s17) do
				s5 += 1

				if not (r1688 < s5) then
					if type(s3) ~= "number" or s3 < 1 or s3 % 1 ~= 0 then
						s6 = false
					elseif s3 > s22 then
						s22 = s3
					end

					continue
				end

				break
			end

			local s12

			if s6 and s22 <= r1688 then
				s12 = {}

				for s2_4 = 1, s22 do
					s12[s2_4] = r1714(s17[s2_4], s18 + 1, s19)
				end
			else
				s12 = {}
				local s5_1, s3_1, s4_2 = pairs(s17)
				local s2_3 = 0

				for s6_1, s7 in s5_1, s3_1, s4_2 do
					s2_3 += 1

					if r1688 < s2_3 then
						s12.__truncated = true
						break
					else
						s12[tostring(s6_1)] = r1714(s7, s18 + 1, s19)
					end
				end
			end

			s19[s17] = nil
			return s12
		end

		return tostring(s17)
	end

	r1715 = function(s16)
		if not r1697 or not r1698 then
			return false, "not connected"
		end

		local s17, s1 = pcall(function()
			return r172_3:JSONEncode(r1714(s16))
		end)

		if not s17 then
			return false, "JSON encode failed: " .. tostring(s1)
		end

		if r1689 < #s1 then
			if not (type(s16) == "table" and s16.type == "rpc_result") then
				return false, "message too large"
			end

			s1 = r172_3:JSONEncode({
				type = "rpc_result",
				requestId = s16.requestId,
				success = false,
				error = string.format("Result is too large to send (%d KB). Return less data.", math.floor(#s1 / 1024)),
			})
		end

		local s18_1, s19 = pcall(function()
			r1698:Send(s1)
		end)

		if not s18_1 then
			return false, "WebSocket send failed: " .. tostring(s19)
		end
		return true
	end
end

local r1716

r1716 = function(arg1, arg2)
	r1715({ type = "rpc_event", event = arg1, data = arg2 or {} })
end

local r1719

do
	local r1717 = {
		Game = game,
		game = game,
		Workspace = r175,
		workspace = r175,
		Players = r173,
		Lighting = game:GetService("Lighting"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		ReplicatedFirst = game:GetService("ReplicatedFirst"),
		StarterGui = game:GetService("StarterGui"),
		StarterPlayer = game:GetService("StarterPlayer"),
		SoundService = game:GetService("SoundService"),
		Teams = game:GetService("Teams"),
		LocalPlayer = r1693,
	}

	local function r1718(s24)
		local s8 = {}

		for s2 in r1707(s24):gmatch("[^%.]+") do
			table.insert(s8, s2)
		end

		return s8
	end

	r1719 = function(s14)
		local s7 = r1718(s14)
		if #s7 == 0 then
			return nil, "path is empty"
		end
		local s2 = r1717[s7[1]]

		if not s2 then
			local s11

			s11, s2 = pcall(function()
				return game:GetService(s7[1])
			end)

			if not (s11 and s2) then
				return nil, "unknown root: " .. s7[1]
			end
		end

		for s4_1 = 2, #s7 do
			local s6 = s7[s4_1]

			if s2 == r173 and s6 == "LocalPlayer" then
				s2 = r1693
			elseif s2 == r1693 and s6 == "PlayerGui" then
				s2 = r1693:FindFirstChildOfClass("PlayerGui")
			elseif s2 == r1693 and s6 == "Character" then
				s2 = r1693.Character
			elseif s2 == r175 and s6 == "CurrentCamera" then
				s2 = r175.CurrentCamera
			elseif typeof(s2) == "Instance" then
				s2 = s2:FindFirstChild(s6)
			else
				s2 = nil
			end

			if not s2 then
				return nil, "path not found at: " .. s6
			end
		end

		return s2
	end
end

local r217_1

do
	local r1720 = {
		Archivable = true,
		Anchored = true,
		AssemblyAngularVelocity = true,
		AssemblyLinearVelocity = true,
		AutomaticSize = true,
		BackgroundColor3 = true,
		BackgroundTransparency = true,
		BrickColor = true,
		CanCollide = true,
		CanQuery = true,
		CanTouch = true,
		CanvasPosition = true,
		CanvasSize = true,
		CFrame = true,
		ClipsDescendants = true,
		Color = true,
		Enabled = true,
		FieldOfView = true,
		Health = true,
		Image = true,
		ImageColor3 = true,
		ImageTransparency = true,
		JumpPower = true,
		LayoutOrder = true,
		Material = true,
		MaxHealth = true,
		MoveDirection = true,
		Orientation = true,
		Position = true,
		RichText = true,
		Rotation = true,
		Size = true,
		Text = true,
		TextColor3 = true,
		TextSize = true,
		TextTransparency = true,
		TextWrapped = true,
		Transparency = true,
		Value = true,
		Velocity = true,
		Visible = true,
		WalkSpeed = true,
	}

	r217_1 = {
		"Archivable",
		"Position",
		"Size",
		"CFrame",
		"Color",
		"Transparency",
		"Visible",
		"Enabled",
		"Text",
		"Value",
		"Health",
		"MaxHealth",
	}

	local function r1721(s19, s20)
		if not r1720[s20] then
			return nil, "not_allowed"
		end

		local s1, s2 = pcall(function()
			return s19[s20]
		end)

		if s1 then
			return r1714(s2)
		end
		return nil, "unavailable"
	end

	local function r1722(s25)
		return {
			name = s25.Name,
			className = s25.ClassName,
			path = r1713(s25),
			parentPath = s25.Parent and r1713(s25.Parent) or nil,
		}
	end

	local function r1723(s34, s35, s36)
		local s6 = s34:GetChildren()
		local s8 = 1
		local s40 = 0

		while s8 <= #s6 and s40 < s35 do
			local s2_1 = s6[s8]
			s8 += 1
			s40 += 1
			if s36(s2_1, s40) then
				return s40, true
			end

			if #s6 < s35 then
				local s3 = s2_1:GetChildren()

				for _, s4 in ipairs(s3) do
					if not (s35 <= #s6) then
						table.insert(s6, s4)
						continue
					end
					break
				end
			end
		end

		return s40, false
	end

	local r1724 = "CodexMCP"

	local r1725 = {
		Frame = true,
		TextLabel = true,
		TextButton = true,
		TextBox = true,
		ImageLabel = true,
		ImageButton = true,
		ScrollingFrame = true,
		UICorner = true,
		UIStroke = true,
		UIListLayout = true,
		UIGridLayout = true,
		UIPadding = true,
		UIAspectRatioConstraint = true,
		UISizeConstraint = true,
	}

	local r1726 = {
		Active = true,
		AnchorPoint = true,
		AutomaticCanvasSize = true,
		AutomaticSize = true,
		BackgroundColor3 = true,
		BackgroundTransparency = true,
		BorderSizePixel = true,
		CanvasPosition = true,
		CanvasSize = true,
		ClipsDescendants = true,
		CornerRadius = true,
		DisplayOrder = true,
		Enabled = true,
		FillDirection = true,
		Font = true,
		HorizontalAlignment = true,
		Image = true,
		ImageColor3 = true,
		ImageTransparency = true,
		LayoutOrder = true,
		LineJoinMode = true,
		MaxTextSize = true,
		MinTextSize = true,
		Name = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
		Position = true,
		RichText = true,
		Rotation = true,
		ScrollBarThickness = true,
		Size = true,
		SortOrder = true,
		Text = true,
		TextColor3 = true,
		TextScaled = true,
		TextSize = true,
		TextStrokeColor3 = true,
		TextStrokeTransparency = true,
		TextTransparency = true,
		TextTruncate = true,
		TextWrapped = true,
		TextXAlignment = true,
		TextYAlignment = true,
		Thickness = true,
		Transparency = true,
		VerticalAlignment = true,
		Visible = true,
		ZIndex = true,
	}

	local r1727 = {
		BackgroundColor3 = true,
		BorderColor3 = true,
		Color = true,
		ImageColor3 = true,
		TextColor3 = true,
		TextStrokeColor3 = true,
	}

	local r1728 = { CanvasPosition = false, CanvasSize = true, Position = true, Size = true }
	local r1729 = { AnchorPoint = true, CanvasPosition = true }

	local r1730 = {
		CornerRadius = true,
		Padding = true,
		PaddingBottom = true,
		PaddingLeft = true,
		PaddingRight = true,
		PaddingTop = true,
	}

	local r1731 = {
		AutomaticCanvasSize = Enum.AutomaticSize,
		AutomaticSize = Enum.AutomaticSize,
		FillDirection = Enum.FillDirection,
		Font = Enum.Font,
		HorizontalAlignment = Enum.HorizontalAlignment,
		LineJoinMode = Enum.LineJoinMode,
		SortOrder = Enum.SortOrder,
		TextTruncate = Enum.TextTruncate,
		TextXAlignment = Enum.TextXAlignment,
		TextYAlignment = Enum.TextYAlignment,
		VerticalAlignment = Enum.VerticalAlignment,
	}

	local function r1743(s25)
		if type(s25) ~= "table" then
			return nil
		end
		local s1_1 = tonumber(s25[1] or s25.r)
		local s3_2 = tonumber(s25[2] or s25.g)
		local s4_2 = tonumber(s25[3] or s25.b)
		if not s1_1 or not s3_2 or not s4_2 then
			return nil
		end

		if s1_1 <= 1 and s3_2 <= 1 and s4_2 <= 1 then
			return Color3.new(s1_1, s3_2, s4_2)
		end
		local s11 = math.floor
		return Color3.fromRGB(math.floor(r1708(s1_1, 0, 255, 0)), math.floor(r1708(s3_2, 0, 255, 0)), s11(r1708(s4_2, 0, 255, 0)))
	end

	local function r1744(s13)
		if type(s13) ~= "table" then
			return nil
		end
		return UDim2.new(tonumber(s13[1] or s13.xScale) or 0, tonumber(s13[2] or s13.xOffset) or 0, tonumber(s13[3] or s13.yScale) or 0, tonumber(s13[4] or s13.yOffset) or 0)
	end

	local function r1745(s34)
		if type(s34) ~= "table" then
			return nil
		end
		return Vector2.new(tonumber(s34[1] or s34.x) or 0, tonumber(s34[2] or s34.y) or 0)
	end

	local function r1746(s19)
		if type(s19) == "number" then
			return UDim.new(0, s19)
		end

		if type(s19) ~= "table" then
			return nil
		end
		return UDim.new(tonumber(s19[1] or s19.scale) or 0, tonumber(s19[2] or s19.offset) or 0)
	end

	local function r1747(s5, s6)
		if r1727[s5] then
			return r1743(s6)
		end

		if r1728[s5] then
			return r1744(s6)
		end

		if r1729[s5] then
			return r1745(s6)
		end

		if r1730[s5] then
			return r1746(s6)
		end

		if r1731[s5] then
			if typeof(s6) == "EnumItem" then
				return s6
			end
			return r1731[s5][tostring(s6):match("([^%.]+)$")]
		end

		return s6
	end

	local function r1748(s25, s26)
		if type(s26) ~= "table" then
			return { applied = 0, rejected = {} }
		end
		local s7 = {}
		local s8 = 0

		for s2, s3 in pairs(s26) do
			if not r1726[s2] then
				table.insert(s7, { property = tostring(s2), reason = "not_allowed" })
			else
				local s4 = r1747(s2, s3)

				if s4 == nil then
					table.insert(s7, { property = s2, reason = "invalid_value" })
				else
					local s26_1, s27 = pcall(function()
						s25[s2] = s4
					end)

					if s26_1 then
						s8 += 1
					else
						table.insert(s7, { property = s2, reason = tostring(s27) })
					end
				end
			end
		end

		return { applied = s8, rejected = s7 }
	end

	local function r1749()
		return r1693:FindFirstChildOfClass("PlayerGui") or r1693:WaitForChild("PlayerGui", 10)
	end

	local function r1750(s17)
		local s3 = r1749()
		if not s3 then
			return nil, "PlayerGui is unavailable"
		end
		local s18 = s3:FindFirstChild("CodexMCP")

		if not s18 and s17 then
			local s1_1 = Instance.new("ScreenGui")
			s1_1.Name = r1724
			s1_1.ResetOnSpawn = false
			s1_1.IgnoreGuiInset = false
			s1_1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			s1_1.Parent = s3
			s18 = s1_1
		end

		return s18
	end

	local function r1751(s2)
		local s10, s11 = r1750(false)
		if not s10 then
			return nil, s11 or "managed UI does not exist"
		end
		local s5_1 = r1707(s2)
		if s5_1 == "" or s5_1 == r1724 then
			return s10
		end

		for s5_2 in s5_1:gmatch("[^%.]+") do
			if s5_2 == r1724 then
				continue
			end
			s10 = s10:FindFirstChild(s5_2)
			if not s10 then
				return nil, "managed UI path not found: " .. s5_2
			end
		end

		return s10
	end

	local r1752 = { Activated = true, MouseButton1Click = true, FocusLost = true }

	local function r1753(s24, s25)
		if type(s25) ~= "table" then
			return
		end

		for _, s3 in ipairs(s25) do
			if r1752[s3] then
				local s25_1, s4 = pcall(function()
					return s24[s3]
				end)

				if s25_1 and s4 and type(s4.Connect) == "function" then
					local s25_2 = s4:Connect(function(...)
						local t9 = { ... }
						r1716("ui." .. s3, { path = r1713(s24), name = s24.Name, className = s24.ClassName, arguments = r1714(t9) })
					end)

					table.insert(r1703, s25_2)
				end
			end
		end
	end

	local r1754 = nil

	r1754 = function(s2, s3, s4, s5)
		if s4 > 10 then
			error("UI tree exceeds maximum depth of 10")
		end

		if s5.count >= 250 then
			error("UI tree exceeds maximum of 250 objects")
		end

		if type(s2) ~= "table" then
			error("UI node must be an object")
		end

		local s16 = r1707(s2.class or s2.className)

		if not r1725[s16] then
			error("UI class is not allowed: " .. s16)
		end

		s5.count = s5.count + 1
		local s17 = Instance.new(s16)
		s17.Name = r1707(s2.name) ~= "" and r1707(s2.name):sub(1, 64) or s16 .. s5.count
		local s11 = r1748(s17, s2.props)
		s17.Parent = s3
		r1753(s17, s2.events)
		local s9_1 = type(s2.children) == "table" and s2.children or {}

		for _, s10_1 in ipairs(s9_1) do
			r1754(s10_1, s17, s4 + 1, s5)
		end

		return s17, s11
	end

	local r1755 = nil

	r1755 = function(s5, s6, s7)
		local s14 = r1722(s5)
		if s6 >= s7 then
			s14.truncated = #s5:GetChildren() > 0
			return s14
		end
		s14.children = {}

		for _, s3 in ipairs(s5:GetChildren()) do
			table.insert(s14.children, r1755(s3, s6 + 1, s7))
		end

		return s14
	end

	local r1757 = 60000
	local r1758 = 80
	local r1759 = {}

	local function r1760(...)
		local s17 = table.pack(...)
		local s1 = {}

		for s14 = 1, select("#", ...) do
			local s3 = tostring
			local s13 = select(s14, table.unpack(s17, 1, s17.n))
			s1[s14] = s3(s13)
		end

		return table.concat(s1, " ")
	end

	local function r1761(s35, s36)
		local s2_1 = tostring(s35 or "")

		if s2_1:match("^%s*$") then
			error("Code is empty", 0)
		end

		local s39 = "=" .. tostring(s36 or "WebConsole"):sub(1, 60)
		local s1_2, s3 = loadstring(s2_1, s39)

		if not s1_2 then
			local s37_1 = loadstring("return " .. s2_1, s39)
			if s37_1 then
				return s37_1
			end
			error("Syntax error: " .. tostring(s3), 0)
		end

		return s1_2
	end

	local function r1762(s34)
		local s2 = getfenv(0)

		local s30 = setmetatable({}, {
			__index = s2,
			__newindex = function(arg1, arg2, arg3)
				s2[arg2] = arg3
			end,
		})

		rawset(s30, "print", function(...)
			local t33 = table.pack(...)
			s34("print", r1760(...))

			if r1691 then
				print(table.unpack(t33, 1, t33.n))
			end
		end)

		rawset(s30, "warn", function(...)
			local t12 = table.pack(...)
			s34("warn", r1760(...))

			if r1691 then
				warn(table.unpack(t12, 1, t12.n))
			end
		end)

		return s30
	end

	local function r1763(s32)
		local s2 = typeof(s32)
		local s1, s30 = pcall(tostring, s32)

		return {
			type = s2,
			text = (s1 and tostring(s30) or "<unprintable>"):sub(1, 4000),
			value = s2 ~= "nil" and r1714(s32) or nil,
		}
	end

	local function r1764(s14, s15, s16, s17)
		local s5 = {}
		local s6 = {}

		for s1 = 2, s14.n do
			s5[s1 - 1] = r1714(s14[s1])
			s6[s1 - 1] = r1763(s14[s1])
		end

		return {
			output = table.concat(s16, "\n"),
			outputTruncated = s17 or nil,
			returns = s5,
			returnsInfo = s6,
			returnCount = s14.n - 1,
			elapsedMs = s15,
		}
	end

	local function r1765(s33)
		return debug.traceback(tostring(s33), 2)
	end

	local function r1766(s22)
		if #s22.pending == 0 then
			return
		end
		local s2 = s22.pending
		s22.pending = {}
		r1716("exec.output", { runId = s22.id, label = s22.label, lines = s2 })
	end

	local function r1767(s34, s35)
		local s3 = s34.Character
		local s2 = s3 and s3:FindFirstChildOfClass("Humanoid")
		local s36 = s3 and s3:FindFirstChild("HumanoidRootPart")

		return {
			name = s34.Name,
			displayName = s34.DisplayName,
			userId = s34.UserId,
			accountAge = s34.AccountAge,
			team = s34.Team and s34.Team.Name or nil,
			neutral = s34.Neutral,
			character = s3 and s3.Name or nil,
			health = s2 and s2.Health or nil,
			maxHealth = s2 and s2.MaxHealth or nil,
			position = s35 and s36 and r1714(s36.Position) or nil,
		}
	end

	local r1756 = {
		["system.ping"] = function(arg1)
			return { pong = true, echo = arg1, clientTime = DateTime.now().UnixTimestampMillis }
		end,
		["game.info"] = function()
			return {
				placeId = game.PlaceId,
				gameId = game.GameId,
				jobId = game.JobId,
				placeVersion = game.PlaceVersion,
				privateServerId = game.PrivateServerId,
				privateServerOwnerId = game.PrivateServerOwnerId,
				playerCount = #r173:GetPlayers(),
				localPlayer = { name = r1693.Name, displayName = r1693.DisplayName, userId = r1693.UserId },
			}
		end,
		execute_lua = function(s19)
			local s17 = r1761(s19.code, s19.label)
			local s3 = {}
			local s10 = 0
			local s8 = false

			local s2 = r1762(function(t18, t19)
				if s8 then
					return
				end
				local t1_1 = (t18 == "warn" and "[warn] " or "") .. t19
				s10 = s10 + #t1_1 + 1

				if r1757 < s10 then
					s8 = true
					table.insert(s3, "... output truncated ...")
					return
				end

				table.insert(s3, t1_1)
			end)

			setfenv(s17, s2)
			local s2_1 = os.clock()
			local s5 = table.pack(xpcall(s17, r1765))
			local s6 = math.floor((os.clock() - s2_1) * 1000 + 0.5)

			if not s5[1] then
				error(string.format("Runtime error: %s\n--- output ---\n%s", tostring(s5[2]), table.concat(s3, "\n"):sub(-20000)), 0)
			end

			return r1764(s5, s6, s3, s8)
		end,
		["exec.async"] = function(s29)
			local s2 = r1761(s29.code, s29.label)
			local s3 = { id = r172_3:GenerateGUID(false):sub(1, 8) }
			s3.label = tostring(s29.label or "Script"):sub(1, 60)
			s3.startedAt = os.clock()
			s3.pending = {}
			s3.lineCount = 0
			s3.dropped = 0

			local s1_1 = r1762(function(t31, t32)
				s3.lineCount = s3.lineCount + 1
				if #s3.pending >= r1758 then
					s3.dropped = s3.dropped + 1
					return
				end
				table.insert(s3.pending, { kind = t31, text = t32:sub(1, 1000) })
			end)

			setfenv(s2, s1_1)
			r1759[s3.id] = s3

			task.spawn(function()
				while r1759[s3.id] == s3 do
					task.wait(0.3)

					if s3.dropped > 0 then
						table.insert(s3.pending, { kind = "warn", text = string.format("... %d line(s) skipped ...", s3.dropped) })
						s3.dropped = 0
					end

					r1766(s3)
				end
			end)

			s3.thread = task.defer(function()
				local t3 = table.pack(xpcall(s2, r1765))
				if r1759[s3.id] ~= s3 then
					return
				end
				r1759[s3.id] = nil
				r1766(s3)
				local t5 = s3.startedAt
				local t4 = math.floor((os.clock() - t5) * 1000 + 0.5)
				local t8 = { runId = s3.id, label = s3.label, ok = t3[1] == true, elapsedMs = t4 }

				if t3[1] then
					local t2 = r1764(t3, t4, {}, false)
					t8.returnsInfo = t2.returnsInfo
					t8.returnCount = t2.returnCount
				else
					t8.error = tostring(t3[2]):sub(1, 4000)
				end

				r1716("exec.finished", t8)
			end)

			return { runId = s3.id, label = s3.label }
		end,
		["exec.cancel"] = function(arg1)
			local s2_1 = r1759[tostring(arg1.runId or "")]
			if not s2_1 then
				return { cancelled = false, reason = "not running" }
			end
			r1759[s2_1.id] = nil
			pcall(task.cancel, s2_1.thread)
			r1766(s2_1)
			local s12 = s2_1.startedAt

			r1716("exec.finished", {
				runId = s2_1.id,
				label = s2_1.label,
				ok = false,
				cancelled = true,
				error = "Cancelled from the web console",
				elapsedMs = math.floor((os.clock() - s12) * 1000 + 0.5),
			})

			return { cancelled = true, runId = s2_1.id }
		end,
		["exec.list"] = function()
			local s5 = {}

			for s2, s3 in pairs(r1759) do
				local s15 = s3.startedAt

				table.insert(s5, {
					runId = s2,
					label = s3.label,
					lines = s3.lineCount,
					elapsedMs = math.floor((os.clock() - s15) * 1000 + 0.5),
				})
			end

			return { count = #s5, runs = s5 }
		end,
		["console.tail"] = function(s24)
			local s6 = game:GetService("LogService"):GetLogHistory()
			local s19 = r1708(s24.limit, 1, 500, 200)
			local s7 = tonumber(s24.since) or 0
			local s3 = {}

			for s2 = #s6, 1, -1 do
				local s8 = s6[s2]

				if not (s8.timestamp <= s7 or #s3 >= s19) then
					table.insert(s3, 1, {
						message = tostring(s8.message):sub(1, 1000),
						kind = s8.messageType.Name,
						time = s8.timestamp,
					})

					continue
				end

				break
			end

			return { count = #s3, entries = s3, latest = s6[#s6] and s6[#s6].timestamp or s7 }
		end,
		["players.list"] = function(arg1)
			local s7 = {}
			local s5 = arg1.includePosition ~= false

			for _, s3 in ipairs(r173:GetPlayers()) do
				table.insert(s7, r1767(s3, s5))
			end

			table.sort(s7, function(arg1, t13)
				return string.lower(arg1.name) < string.lower(t13.name)
			end)

			return { count = #s7, players = s7 }
		end,
		["players.get"] = function(arg1)
			local s5 = arg1.query
			local s6 = tonumber(s5)
			local s8 = string.lower(r1707(s5))

			for _, s4 in ipairs(r173:GetPlayers()) do
				if s6 and s4.UserId == s6 or string.lower(s4.Name) == s8 or string.lower(s4.DisplayName) == s8 then
					return r1767(s4, true)
				end
			end

			error("player not found: " .. tostring(s5))
		end,
		["characters.list"] = function()
			local s14 = {}

			for _, s4 in ipairs(r173:GetPlayers()) do
				local s8 = s4.Character
				local s9 = s8 and s8:FindFirstChildOfClass("Humanoid")
				local s10 = s8 and s8:FindFirstChild("HumanoidRootPart")

				table.insert(s14, {
					player = s4.Name,
					userId = s4.UserId,
					characterPath = s8 and r1713(s8) or nil,
					health = s9 and s9.Health or nil,
					maxHealth = s9 and s9.MaxHealth or nil,
					walkSpeed = s9 and s9.WalkSpeed or nil,
					jumpPower = s9 and s9.JumpPower or nil,
					moveDirection = s9 and r1714(s9.MoveDirection) or nil,
					state = s9 and tostring(s9:GetState()) or nil,
					position = s10 and r1714(s10.Position) or nil,
					velocity = s10 and r1714(s10.AssemblyLinearVelocity) or nil,
				})
			end

			return { count = #s14, characters = s14 }
		end,
		["workspace.summary"] = function(arg1)
			local s8 = math.floor(r1708(arg1.maxDescendants, 1, 5000, 2000))
			local s10 = {}
			local s13 = {}

			for _, s4 in ipairs(r175:GetChildren()) do
				table.insert(s13, r1722(s4))
			end

			local s3_1 = r1723(r175, s8, function(t34)
				s10[t34.ClassName] = (s10[t34.ClassName] or 0) + 1
				return false
			end)

			return {
				topLevel = s13,
				topLevelCount = #s13,
				scannedDescendants = s3_1,
				truncated = s3_1 >= s8,
				classCounts = s10,
			}
		end,
		["instance.find"] = function(s31)
			local s29_1, s30 = r1719(s31.root or "Workspace")

			if not s29_1 then
				error(s30)
			end

			local s6 = string.lower(r1707(s31.nameContains))
			local s7 = r1707(s31.className)
			local s9 = math.floor(r1708(s31.limit, 1, 200, 50))
			local s1_1 = {}

			local s28 = r1723(s29_1, math.floor(r1708(s31.scanLimit, 1, 10000, 3000)), function(t28)
				local t2 = s6 == "" or string.find(string.lower(t28.Name), s6, 1, true) ~= nil
				local t4 = false

				if s7 ~= "" and t28.ClassName ~= s7 then
					pcall(function()
						t4 = t28:IsA(s7)
					end)
				end

				if t2 and (s7 == "" or t28.ClassName == s7 or t4) then
					table.insert(s1_1, r1722(t28))
				end

				return #s1_1 >= s9
			end)

			return { root = r1713(s29_1), scanned = s28, count = #s1_1, matches = s1_1 }
		end,
		["instance.children"] = function(s19)
			local s1, s21 = r1719(s19.path)

			if not s1 then
				error(s21)
			end

			local s21_1 = math.floor(r1708(s19.limit, 1, 500, 100))
			local s2 = s1:GetChildren()
			local s3 = {}

			for s5 = 1, math.min(#s2, s21_1) do
				table.insert(s3, r1722(s2[s5]))
			end

			return { parent = r1722(s1), total = #s2, returned = #s3, children = s3 }
		end,
		["instance.inspect"] = function(s7)
			local s9, s14 = r1719(s7.path)

			if not s9 then
				error(s14)
			end

			local s14_1 = {}

			for _, s4 in ipairs(r217_1) do
				s14_1[s4] = true
			end

			if type(s7.properties) == "table" then
				for _, s8 in ipairs(s7.properties) do
					s14_1[tostring(s8)] = true
				end
			end

			local s6 = {}
			local s7_1 = {}

			for s14_2 in pairs(s14_1) do
				local s2, s3_1 = r1721(s9, s14_2)

				if s3_1 then
					s7_1[s14_2] = s3_1
				else
					s6[s14_2] = s2
				end
			end

			return {
				instance = r1722(s9),
				attributes = r1714(s9:GetAttributes()),
				tags = r1714(s9:GetTags()),
				childCount = #s9:GetChildren(),
				properties = s6,
				unavailable = s7_1,
			}
		end,
		["instance.attributes"] = function(arg1)
			local s1, s34 = r1719(arg1.path)

			if not s1 then
				error(s34)
			end

			return { instance = r1722(s1), attributes = r1714(s1:GetAttributes()) }
		end,
		["camera.get"] = function()
			local s2 = r175.CurrentCamera

			if not s2 then
				error("CurrentCamera is unavailable")
			end

			return {
				path = r1713(s2),
				cameraType = tostring(s2.CameraType),
				fieldOfView = s2.FieldOfView,
				viewportSize = r1714(s2.ViewportSize),
				cframe = r1714(s2.CFrame),
				focus = r1714(s2.Focus),
				subject = r1714(s2.CameraSubject),
			}
		end,
		["telemetry.snapshot"] = function()
			local s2 = r174.RenderStepped:Wait()
			local s4 = nil

			pcall(function()
				s4 = game:GetService("Stats"):GetTotalMemoryUsageMb()
			end)

			return {
				fpsEstimate = s2 > 0 and math.floor(1 / s2 + 0.5) or nil,
				frameDeltaMs = s2 * 1000,
				memoryMb = s4,
				playerCount = #r173:GetPlayers(),
				placeId = game.PlaceId,
				jobId = game.JobId,
				distributedGameTime = r175.DistributedGameTime,
				timestamp = DateTime.now().UnixTimestampMillis,
			}
		end,
		["ui.create"] = function(s21)
			local s5, s20 = r1750(true)

			if not s5 then
				error(s20)
			end

			if s21.replace ~= false then
				r1709(r1703)

				for _, s4 in ipairs(s5:GetChildren()) do
					s4:Destroy()
				end
			end

			local s2 = { count = 0 }
			local s17, s18 = r1754(s21.tree, s5, 1, s2)
			return { created = r1722(s17), objectCount = s2.count, propertyResult = s18 }
		end,
		["ui.update"] = function(s7)
			local s8, s9 = r1751(s7.path)

			if not s8 then
				error(s9)
			end

			return { instance = r1722(s8), result = r1748(s8, s7.props) }
		end,
		["ui.delete"] = function(arg1)
			local s3 = r1707(arg1.path)
			local s2, s27 = r1751(s3)

			if not s2 then
				if s3 == "" then
					return { deleted = false, reason = "managed UI does not exist" }
				end
				error(s27)
			end

			r1709(r1703)
			local s3_1 = r1713(s2)
			s2:Destroy()
			return { deleted = true, path = s3_1 }
		end,
		["ui.list"] = function(s34)
			local s32, s33 = r1750(false)
			if not s32 then
				return { exists = false, reason = s33 or "managed UI does not exist" }
			end
			local s34_1 = math.floor(r1708(s34.maxDepth, 1, 10, 6))
			return { exists = true, tree = r1755(s32, 0, s34_1) }
		end,
		["ui.notify"] = function(s7)
			local s10, s11 = r1750(true)

			if not s10 then
				error(s11)
			end

			local s4 = s10:FindFirstChild("Notifications")

			if not s4 then
				s4 = Instance.new("Frame")
				s4.Name = "Notifications"
				s4.AnchorPoint = Vector2.new(1, 0)
				s4.Position = UDim2.new(1, -16, 0, 16)
				s4.Size = UDim2.fromOffset(360, 500)
				s4.BackgroundTransparency = 1
				s4.Parent = s10
				local s9 = Instance.new("UIListLayout")
				s9.Padding = UDim.new(0, 8)
				s9.HorizontalAlignment = Enum.HorizontalAlignment.Right
				s9.SortOrder = Enum.SortOrder.LayoutOrder
				s9.Parent = s4
			end

			local s15 = Instance.new("TextLabel")
			s15.Name = "Notification_" .. r172_3:GenerateGUID(false)
			s15.Size = UDim2.fromOffset(340, 64)
			s15.BackgroundColor3 = r1743(s7.color) or Color3.fromRGB(25, 35, 52)
			s15.BackgroundTransparency = 0.08
			s15.Text = tostring(s7.text):sub(1, 500)
			s15.TextColor3 = Color3.fromRGB(240, 247, 255)
			s15.TextSize = 16
			s15.Font = Enum.Font.GothamSemibold
			s15.TextWrapped = true
			s15.Parent = s4
			local s2 = Instance.new("UICorner")
			s2.CornerRadius = UDim.new(0, 10)
			s2.Parent = s15
			local s10_1 = r1708(s7.duration, 0.5, 30, 4)

			task.delay(s10_1, function()
				if s15.Parent then
					s15:Destroy()
				end
			end)

			return { shown = true, name = s15.Name, duration = s10_1 }
		end,
	}

	local function r1768(s26)
		local s1_1 = tostring(s26.requestId or "")
		local s2_2 = tostring(s26.method or "")
		local s3_1 = r1756[s2_2]
		if s1_1 == "" then
			return
		end

		if not s3_1 then
			r1715({
				type = "rpc_result",
				requestId = s1_1,
				success = false,
				error = "Unknown or disallowed method: " .. s2_2,
			})

			return
		end

		task.spawn(function()
			local t3, t11 = xpcall(function()
				return s3_1(type(s26.params) == "table" and s26.params or {})
			end, function(u4)
				return debug.traceback(tostring(u4), 2)
			end)

			if t3 then
				r1715({ type = "rpc_result", requestId = s1_1, success = true, data = r1714(t11) })
			else
				r1715({ type = "rpc_result", requestId = s1_1, success = false, error = tostring(t11):sub(1, 2000) })
			end
		end)
	end

	local function r1769(s33)
		local s31, s32 = pcall(function()
			return r172_3:JSONDecode(tostring(s33))
		end)

		if not s31 or type(s32) ~= "table" then
			r1706("Invalid JSON message")
			return
		end

		if s32.type == "identify_ok" then
			r1705("Connected to bridge. Client ID:", tostring(s32.clientId))
			local s5 = {}

			for s2 in pairs(r1756) do
				table.insert(s5, s2)
			end

			table.sort(s5)
			r1716("agent.ready", { clientId = s32.clientId, methods = s5, playerCount = #r173:GetPlayers() })
			return
		end

		if s32.type == "pong" then
			r1705("PONG", tostring(s32.seq or ""))
			return
		end

		if s32.type == "rpc_request" then
			r1768(s32)
			return
		end

		if s32.type == "identify_error" then
			r1706("Bridge rejected identity:", tostring(s32.error))
		end
	end

	local function r1770()
		r1697 = false
		r1709(r1702)
		if not r1698 then
			return
		end

		pcall(function()
			if type(r1698.Close) == "function" then
				r1698:Close()
			elseif type(r1698.close) == "function" then
				r1698:close()
			end
		end)

		r1698 = nil
	end

	local function r1771()
		local s16, s11 = r1710()
		if not s16 then
			r1706("No supported WebSocket API found")
			return false
		end
		r1699 += 1
		local s18 = r1699
		r1705("Connecting to", r1684_1, "using", s11)

		local s10, s11_1 = pcall(function()
			return s16(r1684_1)
		end)

		if not s10 or not s11_1 then
			r1706("Connection failed:", tostring(s11_1))
			return false
		end
		r1698 = s11_1
		r1697 = true
		local s3_1 = r1711(r1698, "OnMessage", "MessageReceived")
		local s7 = r1711(r1698, "OnClose", "Closed", "OnDisconnect")
		local s9 = r1711(r1698, "OnError", "Error")

		local s2_1 = r1712(s3_1, function(t2)
			if s18 == r1699 then
				r1769(t2)
			end
		end)

		if s2_1 then
			table.insert(r1702, s2_1)

			local s6 = r1712(s7, function(...)
				if s18 == r1699 then
					r1697 = false
					r1706("Socket closed", ...)
				end
			end)

			if s6 then
				table.insert(r1702, s6)
			end

			local s8 = r1712(s9, function(...)
				if s18 == r1699 then
					r1706("Socket error", ...)
					r1697 = false
				end
			end)

			if s8 then
				table.insert(r1702, s8)
			end

			local s10_1, s11_2 = r1715({
				type = "identify",
				clientType = "roblox",
				token = r12_44,
				name = r1693.Name,
				displayName = r1693.DisplayName,
				userId = r1693.UserId,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = r1686,
			})

			if not s10_1 then
				r1706(s11_2)
				r1697 = false
			end

			task.spawn(function()
				while r1696 and r1697 and s18 == r1699 do
					task.wait(20)

					if r1696 and r1697 and s18 == r1699 then
						r1704 += 1
						local t2_1, t3_2 = r1715({ type = "ping", seq = r1704 })

						if not t2_1 then
							r1706("Heartbeat failed:", tostring(t3_2))
							r1697 = false
						end
					end
				end
			end)

			while r1696 and r1697 and s18 == r1699 do
				task.wait(0.5)
			end

			if s18 == r1699 then
				r1770()
			end

			return true
		end

		r1706("Socket has no supported message event")
		r1770()
		return false
	end

	table.insert(r1701, r173.PlayerAdded:Connect(function(s22)
		if r1692 then
			r1716("player.added", r1767(s22, true))
		end
	end))

	table.insert(r1701, r173.PlayerRemoving:Connect(function(s20)
		if r1692 then
			r1716("player.removing", r1767(s20, true))
		end
	end))

	r1694.StopChilliLink = function()
		if not r1696 then
			return
		end
		r1705("Stopping agent")
		r1696 = false
		r1699 += 1
		r1709(r1701)
		r1709(r1703)
		r1770()
	end

	local r1_80 = syn and syn.request or http_request or request or r6_63 and r6_63.request or fluxus and fluxus.request

	local function r1773_1()
		if type(r1_80) ~= "function" then
			return nil
		end

		local s2, s3 = pcall(function()
			return r172_3:JSONEncode({
				token = r12_44,
				userId = r1693.UserId,
				name = r1693.Name,
				displayName = r1693.DisplayName,
				placeId = game.PlaceId,
				jobId = game.JobId,
				version = r1686,
			})
		end)

		if not s2 then
			return nil
		end
		local s2_1, s3_1 = pcall(r1_80, { Url = r1685, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = s3 })
		if not s2_1 or type(s3_1) ~= "table" or tonumber(s3_1.StatusCode) ~= 200 then
			return nil
		end

		local s4_1, s5 = pcall(function()
			return r172_3:JSONDecode(tostring(s3_1.Body))
		end)

		if s4_1 and type(s5) == "table" then
			return s5
		end
		return nil
	end

	task.spawn(function()
		while r1696 do
			local s13 = r1773_1()
			local s3 = 60

			if s13 then
				s3 = r1708(s13.interval, 5, 600, 60)

				if s13.connect == true and not r1700 and not r1697 then
					r1700 = true

					task.spawn(function()
						pcall(r1771)
						r1700 = false
					end)
				end
			end

			task.wait(s3 * (0.85 + math.random() * 0.3))
		end

		r1705("Agent stopped")
	end)
end
