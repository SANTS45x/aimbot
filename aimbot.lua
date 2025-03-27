local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local aimbotActive = false
local silentAimActive = false
local visibleCheck = false
local KeybindAimbot = Enum.KeyCode.F
local KeybindToggleMenu = Enum.KeyCode.Insert
local targetPart = "Head"
local menuOpen = true
local lockedTarget = nil
local predictionValue = 0
local fovSize = 50 -- Tamanho do FOV
local showFov = false -- Mostrar FOV do silent aim

local function isTargetVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).unit * (target.Position - origin).magnitude
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit:IsDescendantOf(target.Parent)
end

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character:FindFirstChild(targetPart) or player.Character:FindFirstChild("Head")
            if target then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen and (not visibleCheck or isTargetVisible(target)) then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestEnemy = target
                    end
                end
            end
        end
    end
    return closestEnemy
end

local function toggleAimbot(value)
    aimbotActive = value
    if value then
        lockedTarget = getClosestEnemy()
    else
        lockedTarget = nil
    end
end

local function toggleSilentAim(value)
    silentAimActive = value
end

local function updateAimbotTarget()
    if aimbotActive and lockedTarget then
        local targetPos = lockedTarget.Position
        targetPos = targetPos + (lockedTarget.Velocity * predictionValue)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
end

local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        Init:Show()
    else
        Init:Hide()
    end
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
library.rank = "developer"
local Wm = library:Watermark("Aimbot | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
local LoadingXSX = Notif:Notify("Loading Aimbot.", 5, "information")
library.title = "Aimbot"
library:Introduction()

wait(1)
local Init = library:Init()

-- Aba "AIMBOT"
local Tab1 = Init:NewTab("AIMBOT")
local Section1 = Tab1:NewSection("Aimbot Settings")

local Toggle1 = Tab1:NewToggle("Aimbot Toggle", false, function(value)
    toggleAimbot(value)
end)

local ToggleVisible = Tab1:NewToggle("Visible Check", false, function(value)
    visibleCheck = value
end)

local TextboxKeybind = Tab1:NewTextbox("Keybind para Aimbot", tostring(KeybindAimbot), "Digite a tecla", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]
    if key then
        KeybindAimbot = key
        TextboxKeybind:SetText(val:upper())
    end
end)

local Selector1 = Tab1:NewSelector("Parte do Corpo", "Head", {"Head", "HumanoidRootPart", "Any"}, function(part)
    targetPart = part
end)

local TextboxPrediction = Tab1:NewTextbox("Prediction", tostring(predictionValue), "Digite a predição (número)", "all", "medium", true, false, function(val)
    local prediction = tonumber(val)
    if prediction then
        predictionValue = prediction
        TextboxPrediction:SetText(tostring(predictionValue))
    end
end)

-- Aba "SILENT AIM"
local TabSilentAim = Init:NewTab("SILENT AIM")
local SectionSilentAim = TabSilentAim:NewSection("Silent Aim Settings")

-- Toggle para ativar/desativar o Silent Aim
local ToggleSilentAim = TabSilentAim:NewToggle("Silent Aim Toggle", false, function(value)
    toggleSilentAim(value)
end)

-- Slide para modificar o tamanho do FOV
local SliderFovSize = TabSilentAim:NewSlider("FOV Size", 50, 200, fovSize, function(value)
    fovSize = value
end)

-- Toggle para mostrar o FOV
local ToggleShowFov = TabSilentAim:NewToggle("Mostrar FOV", false, function(value)
    showFov = value
end)

-- Seletor para escolher a parte do corpo a ser mirado
local SelectorSilentAim = TabSilentAim:NewSelector("Parte do Corpo", "Head", {"Head", "HumanoidRootPart", "Any"}, function(part)
    targetPart = part
end)

-- Monitorando teclas para ativar/desativar
local function onKeyPress(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == KeybindAimbot then
            toggleAimbot(not aimbotActive)
            Toggle1:Set(aimbotActive)
        elseif input.KeyCode == KeybindToggleMenu then
            toggleMenu()
        end
    end
end
UserInputService.InputBegan:Connect(onKeyPress)

-- Atualiza o aimbot
RunService.RenderStepped:Connect(updateAimbotTarget)

local FinishedLoading = Notif:Notify("Aimbot Loaded", 4, "success")
