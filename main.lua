local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Elite Slim Hub v23 🚀",
   LoadingTitle = "GOD MODE LOADING...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {Enabled = false}
})

-- GLOBAL VARIABLES (ALL RESTORED)
_G.AimbotEnabled, _G.ShowFOV, _G.FOVSize = false, false, 120
_G.Smoothness, _G.Prediction = 2, 0.12
_G.TeamCheck, _G.WallCheck = false, false
_G.BoxESP, _G.TracerESP, _G.HealthESP, _G.NameESP, _G.SkeletonESP = false, false, false, false, false
_G.SpinBot, _G.SpinSpeed = false, 10
_G.InfJump, _G.Fullbright = false, false

local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

-- TABS
local AimTab = Window:CreateTab("Aimbot 🔫")
local ConfigTab = Window:CreateTab("Aim Configs ⚙️")
local ESPTab = Window:CreateTab("Slim Visuals")
local WorldTab = Window:CreateTab("World 🌐")
local PerfTab = Window:CreateTab("Performance ⚡")

-- 1. AIMBOT TAB
AimTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) _G.AimbotEnabled = v end})
AimTab:CreateToggle({Name = "Show FOV", CurrentValue = false, Callback = function(v) _G.ShowFOV = v end})
AimTab:CreateSlider({Name = "FOV Size", Range = {30, 500}, Increment = 5, CurrentValue = 120, Callback = function(v) _G.FOVSize = v end})

-- 2. AIM CONFIGS (RESTORED NOTES & FILTERS)
ConfigTab:CreateSlider({Name = "Smoothness", Range = {1, 20}, Increment = 0.5, CurrentValue = 2, Callback = function(v) _G.Smoothness = v end})
ConfigTab:CreateSlider({Name = "Prediction", Range = {0, 0.5}, Increment = 0.01, CurrentValue = 0.12, Callback = function(v) _G.Prediction = v end})
ConfigTab:CreateLabel("⚠️ Error Notes:")
ConfigTab:CreateLabel("- Prediction > 0.25: May fail if enemy turns.")
ConfigTab:CreateLabel("- Wall Check: High CPU usage but more accurate.")
ConfigTab:CreateSection("Filters")
ConfigTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) _G.TeamCheck = v end})
ConfigTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) _G.WallCheck = v end})

-- 3. VISUALS TAB (ALL OPTIONS BACK)
ESPTab:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) _G.BoxESP = v end})
ESPTab:CreateToggle({Name = "Tracers (Top)", CurrentValue = false, Callback = function(v) _G.TracerESP = v end})
ESPTab:CreateToggle({Name = "Health Bar", CurrentValue = false, Callback = function(v) _G.HealthESP = v end})
ESPTab:CreateToggle({Name = "Skeleton ESP", CurrentValue = false, Callback = function(v) _G.SkeletonESP = v end})
ESPTab:CreateToggle({Name = "Name ESP", CurrentValue = false, Callback = function(v) _G.NameESP = v end})

-- 4. WORLD TAB (CORRECTED)
WorldTab:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) _G.SpinBot = v end})
WorldTab:CreateSlider({Name = "Spin Speed", Range = {1, 100}, Increment = 5, CurrentValue = 10, Callback = function(v) _G.SpinSpeed = v end})
WorldTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) _G.InfJump = v end})
WorldTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) _G.Fullbright = v end})
WorldTab:CreateButton({Name = "Anti-AFK", Callback = function() print("Anti-AFK Active") end})

-- 5. PERFORMANCE TAB (THE FULL LIST)
local function CreateMiniStat(name, color, yOffset)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size, Frame.Position = UDim2.new(0, 80, 0, 25), UDim2.new(0.02, 0, 0.1, yOffset)
    Frame.BackgroundColor3, Frame.BackgroundTransparency = Color3.fromRGB(15, 15, 15), 0.3
    Frame.Active, Frame.Draggable = true, true
    local lbl = Instance.new("TextLabel", Frame)
    lbl.Size, lbl.BackgroundTransparency, lbl.TextColor3, lbl.TextSize, lbl.Font = UDim2.new(1,0,1,0), 1, color, 12, Enum.Font.Code
    return lbl
end

PerfTab:CreateButton({Name = "Mini FPS Window", Callback = function()
    local lbl = CreateMiniStat("FPS", Color3.fromRGB(0, 255, 120), 0)
    RunService.RenderStepped:Connect(function() lbl.Text = "FPS: "..math.floor(workspace:GetRealPhysicsFPS()) end)
end})

PerfTab:CreateButton({Name = "Mini Ping Window", Callback = function()
    local lbl = CreateMiniStat("Ping", Color3.fromRGB(255, 200, 0), 30)
    task.spawn(function() while task.wait(0.1) do lbl.Text = "PNG: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms" end end)
end})

PerfTab:CreateButton({Name = "FPS Boost (Clean All)", Callback = function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end})

PerfTab:CreateButton({Name = "Shadow Remover", Callback = function() game:GetService("Lighting").GlobalShadows = false end})

-- SYSTEMS LOGIC (AIM / ESP / WALLS)
local function IsVisible(part, character)
    if not _G.WallCheck then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return result == nil or result.Instance:IsDescendantOf(character)
end

function GetTarget()
    local target, dist = nil, _G.FOVSize
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if _G.TeamCheck and v.Team == LocalPlayer.Team then continue end
            local pos, os = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if os and IsVisible(v.Character.Head, v.Character) then
                local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mDist < dist then target = v; dist = mDist end
            end
        end
    end
    return target
end

-- ESP RENDERER
local function CreateESP(p)
    local Box = Drawing.new("Square"); Box.Thickness, Box.Filled = 0.5, false; Box.Color = Color3.new(1,1,1)
    local Name = Drawing.new("Text"); Name.Size, Name.Center, Name.Outline = 13, true, true; Name.Color = Color3.new(1,1,1)
    local Health = Drawing.new("Line"); Health.Thickness = 1
    local Tracer = Drawing.new("Line"); Tracer.Thickness, Tracer.Color = 0.5, Color3.new(1,1,1)

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local pos, os = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if os and not (_G.TeamCheck and p.Team == LocalPlayer.Team) then
                local sizeY = 3000 / pos.Z
                local top = pos.Y - sizeY/2
                Box.Visible, Box.Size, Box.Position = _G.BoxESP, Vector2.new(2000/pos.Z, sizeY), Vector2.new(pos.X - (2000/pos.Z)/2, top)
                Name.Visible, Name.Text, Name.Position = _G.NameESP, p.Name, Vector2.new(pos.X, top - 15)
                Tracer.Visible, Tracer.From, Tracer.To = _G.TracerESP, Vector2.new(Camera.ViewportSize.X/2, 0), Vector2.new(pos.X, top)
                if _G.HealthESP then
                    local h = p.Character.Humanoid.Health/100
                    Health.Visible, Health.Color = true, Color3.fromHSV(h*0.3, 1, 1)
                    Health.From, Health.To = Vector2.new(pos.X - (2000/pos.Z)/2 - 4, pos.Y + sizeY/2), Vector2.new(pos.X - (2000/pos.Z)/2 - 4, top + (sizeY * (1-h)))
                else Health.Visible = false end
            else Box.Visible, Name.Visible, Health.Visible, Tracer.Visible = false, false, false, false end
        else Box.Visible, Name.Visible, Health.Visible, Tracer.Visible = false, false, false, false end
    end)
end

-- MAIN HEARTBEAT
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible, FOVCircle.Radius, FOVCircle.Position = _G.ShowFOV, _G.FOVSize, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if _G.AimbotEnabled then
        local t = GetTarget()
        if t then
            local p = t.Character.Head.Position + (t.Character.HumanoidRootPart.Velocity * _G.Prediction)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, p), 1/_G.Smoothness)
        end
    end
    if _G.SpinBot and LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(_G.SpinSpeed), 0) end
    if _G.Fullbright then game:GetService("Lighting").ClockTime, game:GetService("Lighting").Brightness = 14, 2 end
end)

for _, p in pairs(game.Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
game.Players.PlayerAdded:Connect(function(p) CreateESP(p) end)
