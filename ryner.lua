local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Settings
local Settings = {
    Enabled = false,
    FOV = 180,
    Prediction = 0.12,
}

-- Role check
local function getRole(player)
    if player.Team then
        local name = player.Team.Name:lower()
        if name:find("killer") then
            return "Killer"
        elseif name:find("survivor") then
            return "Survivor"
        end
    end
    return nil
end

local function isEnemy(player)
    local myRole = getRole(me)
    local theirRole = getRole(player)
    if not myRole or not theirRole then return false end

    if myRole == "Survivor" then
        return theirRole == "Killer"
    elseif myRole == "Killer" then
        return theirRole == "Survivor"
    end
    return false
end

local function getRightHand(character)
    return character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
end

local function getClosest()
    local target, closest = nil, Settings.FOV
    local cam = workspace.CurrentCamera
    local mousePos = cam.ViewportSize / 2

    for _, v in plrs:GetPlayers() do
        if v \~= me and v.Character and isEnemy(v) then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local hand = getRightHand(v.Character)
            if not hand then continue end

            local screenPos, onScreen = cam:WorldToViewportPoint(hand.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < closest then
                target = hand
                closest = dist
            end
        end
    end
    return target
end

local function getPredictedPos(part)
    if Settings.Prediction <= 0 then
        return part.Position
    end
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    return part.Position + (vel * Settings.Prediction)
end

-- Hook
local orig
orig = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if method == "FireServer" and self.Name == "ShootBullet" and Settings.Enabled then
        local hand = getClosest()
        if hand then
            local predicted = getPredictedPos(hand)
            local dir = (predicted - workspace.CurrentCamera.CFrame.Position).Unit
            return orig(self, dir)
        end
    end

    return orig(self, ...)
end))

-- ==================== GUI (CoreGui) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VerityAim"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- Logo
local Logo = Instance.new("TextButton")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 48, 0, 48)
Logo.Position = UDim2.new(0, 15, 0, 15)
Logo.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Logo.BorderSizePixel = 0
Logo.Text = "V"
Logo.TextColor3 = Color3.fromRGB(255, 80, 80)
Logo.TextSize = 24
Logo.Font = Enum.Font.GothamBold
Logo.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = Logo

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 230, 0, 210)
Main.Position = UDim2.new(0, 15, 0, 70)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "Verity Aim | VD (Hand)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
ToggleBtn.Text = "Status: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    if Settings.Enabled then
        ToggleBtn.Text = "Status: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
    else
        ToggleBtn.Text = "Status: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    end
end)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.9, 0, 0, 20)
FOVLabel.Position = UDim2.new(0.05, 0, 0, 85)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "Radius (FOV): " .. Settings.FOV
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 12
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Main

local FOVBox = Instance.new("TextBox")
FOVBox.Size = UDim2.new(0.9, 0, 0, 26)
FOVBox.Position = UDim2.new(0.05, 0, 0, 105)
FOVBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FOVBox.Text = tostring(Settings.FOV)
FOVBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVBox.TextSize = 13
FOVBox.Font = Enum.Font.Gotham
FOVBox.Parent = Main

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 6)
FOVCorner.Parent = FOVBox

FOVBox.FocusLost:Connect(function()
    local num = tonumber(FOVBox.Text)
    if num and num > 0 then
        Settings.FOV = num
        FOVLabel.Text = "Radius (FOV): " .. num
    else
        FOVBox.Text = tostring(Settings.FOV)
    end
end)

local PredLabel = Instance.new("TextLabel")
PredLabel.Size = UDim2.new(0.9, 0, 0, 20)
PredLabel.Position = UDim2.new(0.05, 0, 0, 140)
PredLabel.BackgroundTransparency = 1
PredLabel.Text = "Prediction: " .. Settings.Prediction
PredLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PredLabel.TextSize = 12
PredLabel.Font = Enum.Font.Gotham
PredLabel.TextXAlignment = Enum.TextXAlignment.Left
PredLabel.Parent = Main

local PredBox = Instance.new("TextBox")
PredBox.Size = UDim2.new(0.9, 0, 0, 26)
PredBox.Position = UDim2.new(0.05, 0, 0, 160)
PredBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
PredBox.Text = tostring(Settings.Prediction)
PredBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PredBox.TextSize = 13
PredBox.Font = Enum.Font.Gotham
PredBox.Parent = Main

local PredCorner = Instance.new("UICorner")
PredCorner.CornerRadius = UDim.new(0, 6)
PredCorner.Parent = PredBox

PredBox.FocusLost:Connect(function()
    local num = tonumber(PredBox.Text)
    if num and num >= 0 then
        Settings.Prediction = num
        PredLabel.Text = "Prediction: " .. num
    else
        PredBox.Text = tostring(Settings.Prediction)
    end
end)

Logo.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

print("[Verity] Script loaded. Cari logo V di pojok kiri atas.")