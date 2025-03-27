local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local aimbotActive = false
local silentAimActive = false -- Novo toggle para silent aim
local visibleCheck = false -- Novo toggle para verificar visibilidade
local KeybindAimbot = Enum.KeyCode.F -- Tecla padrão para ativar/desativar o aimbot
local KeybindToggleMenu = Enum.KeyCode.Insert -- Tecla para abrir/fechar o menu
local targetPart = "Head" -- Parte do corpo para mirar (Head, HumanoidRootPart, etc.)
local menuOpen = true -- Estado do menu
local lockedTarget = nil -- Alvo fixo do aimbot
local predictionValue = 0 -- Valor de predição (novo)
local fovSize = 100 -- Tamanho do FOV para silent aim
local showFov = false -- Toggle para mostrar o FOV do silent aim

-- Função para verificar se um alvo está visível
local function isTargetVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).unit * (target.Position - origin).magnitude
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit:IsDescendantOf(target.Parent)
end

-- Função para encontrar o inimigo mais próximo da mira dentro do FOV
local function getClosestEnemyInFOV()
    local closestEnemy = nil
    local shortestDistance = fovSize

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

-- Função para ativar/desativar o silent aim
local function toggleSilentAim(value)
    silentAimActive = value
end

-- Função para aplicar silent aim
local function applySilentAim()
    if silentAimActive then
        local target = getClosestEnemyInFOV()
        if target then
            target.Position = target.Position + (target.Velocity * predictionValue) -- Aplicando predição
        end
    end
end

-- GUI
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

-- Toggle para ativar/desativar o aimbot
local Toggle1 = Tab1:NewToggle("Aimbot Toggle", false, function(value)
    aimbotActive = value
end)

-- Aba "SILENT AIM"
local TabSilent = Init:NewTab("SILENT AIM")
local SectionSilent = TabSilent:NewSection("Silent Aim Settings")

-- Toggle para ativar/desativar o silent aim
local ToggleSilent = TabSilent:NewToggle("Silent Aim Toggle", false, function(value)
    toggleSilentAim(value)
end)

-- Slider para modificar o tamanho do FOV
local SliderFov = TabSilent:NewSlider("FOV Size", 10, 300, fovSize, function(value)
    fovSize = value
end)

-- Toggle para mostrar o FOV do silent aim
local ToggleShowFov = TabSilent:NewToggle("Show FOV", false, function(value)
    showFov = value
end)

-- Seletor para escolher a parte do corpo a ser mirado
local SelectorSilent = TabSilent:NewSelector("Target Part", "Head", {"Head", "HumanoidRootPart", "Any"}, function(part)
    targetPart = part
end)

-- Adicionando a opção de Prediction
local TextboxPredictionSilent = TabSilent:NewTextbox("Prediction", tostring(predictionValue), "Digite a predição (número)", "all", "medium", true, false, function(val)
    local prediction = tonumber(val)
    if prediction then
        predictionValue = prediction
        TextboxPredictionSilent:SetText(tostring(predictionValue))
    end
end)

-- Monitorando teclas para ativar/desativar
local function onKeyPress(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == KeybindAimbot then
            aimbotActive = not aimbotActive
            Toggle1:Set(aimbotActive)
        elseif input.KeyCode == KeybindToggleMenu then
            menuOpen = not menuOpen
            if menuOpen then
                Init:Show()
            else
                Init:Hide()
            end
        end
    end
end
UserInputService.InputBegan:Connect(onKeyPress)

-- Atualiza o silent aim
RunService.RenderStepped:Connect(applySilentAim)

local FinishedLoading = Notif:Notify("Aimbot Loaded", 4, "success")
