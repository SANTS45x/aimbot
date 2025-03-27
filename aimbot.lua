local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local aimbotActive = false
local visibleCheck = false -- Novo toggle para verificar visibilidade
local KeybindAimbot = Enum.KeyCode.F -- Tecla padrão para ativar/desativar o aimbot
local KeybindToggleMenu = Enum.KeyCode.Insert -- Tecla para abrir/fechar o menu
local targetPart = "Head" -- Parte do corpo para mirar (Head, HumanoidRootPart, etc.)
local menuOpen = true -- Estado do menu
local lockedTarget = nil -- Alvo fixo do aimbot
local predictionValue = 0 -- Valor de predição (novo)
local spinbotActive = false -- Variável para o spinbot
local spinbotSpeed = 10 -- Velocidade do spinbot
local bunnyhopActive = false -- Variável para o bunnyhop
local bunnyhopSpeed = 50 -- Velocidade do bunnyhop

-- Função para verificar se um alvo está visível
local function isTargetVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).unit * (target.Position - origin).magnitude
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return hit and hit:IsDescendantOf(target.Parent)
end

-- Função para encontrar o inimigo mais próximo da mira
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

-- Função para ativar/desativar o aimbot
local function toggleAimbot(value)
    aimbotActive = value
    if value then
        lockedTarget = getClosestEnemy()
    else
        lockedTarget = nil
    end
end

-- Função para mover a mira suavemente para o alvo
local function updateAimbotTarget()
    if aimbotActive and lockedTarget then
        local targetPos = lockedTarget.Position
        -- Aplicando a predição ao movimento do alvo
        targetPos = targetPos + (lockedTarget.Velocity * predictionValue) -- Predição
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
end

-- Função para ativar/desativar o spinbot
local function toggleSpinbot(value)
    spinbotActive = value
end

-- Função para ativar/desativar o bunnyhop
local function toggleBunnyhop(value)
    bunnyhopActive = value
end

-- Função para mover o personagem com o spinbot
local function updateSpinbot()
    if spinbotActive then
        LocalPlayer.Character:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed), 0))
    end
end

-- Função para fazer o personagem realizar o bunnyhop
local function updateBunnyhop()
    if bunnyhopActive then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:Move(Vector3.new(0, bunnyhopSpeed, 0))
        end
    end
end

-- Função para abrir/fechar o menu
local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        Init:Show()
    else
        Init:Hide()
    end
end

-- GUI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
library.rank = "developer"
local Wm = library:Watermark("Silent Aim | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
local LoadingXSX = Notif:Notify("Loading Silent Aim.", 5, "information") 
library.title = "Silent Aim"
library:Introduction()

wait(1)
local Init = library:Init()

-- Aba "AIMBOT"
local Tab1 = Init:NewTab("AIMBOT")
local Section1 = Tab1:NewSection("Aimbot Settings")

-- Toggle para ativar/desativar o aimbot
local Toggle1 = Tab1:NewToggle("Aimbot Toggle", false, function(value)
    toggleAimbot(value)
end)

-- Toggle para verificar visibilidade
local ToggleVisible = Tab1:NewToggle("Visible Check", false, function(value)
    visibleCheck = value
end)

-- Opção para configurar a tecla do keybind
local TextboxKeybind = Tab1:NewTextbox("Keybind para Aimbot", tostring(KeybindAimbot), "Digite a tecla", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]
    if key then
        KeybindAimbot = key
        TextboxKeybind:SetText(val:upper())
    end
end)

-- Seletor para escolher a parte do corpo a ser mirado
local Selector1 = Tab1:NewSelector("Parte do Corpo", "Head", {"Head", "HumanoidRootPart", "Any"}, function(part)
    targetPart = part
end)

-- Adicionando a opção de Prediction
local TextboxPrediction = Tab1:NewTextbox("Prediction", tostring(predictionValue), "Digite a predição (número)", "all", "medium", true, false, function(val)
    local prediction = tonumber(val)
    if prediction then
        predictionValue = prediction
        TextboxPrediction:SetText(tostring(predictionValue))
    end
end)

-- Aba "SETTINGS"
local Tab2 = Init:NewTab("SETTINGS")
local Section2 = Tab2:NewSection("Misc Settings")

-- Botão para executar animação Zombie
local ButtonZombie = Tab2:NewButton("Zombie Animation", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SANTS45x/animation/refs/heads/main/animatio.lua"))()
end)

-- Aba "RAGE"
local Tab3 = Init:NewTab("RAGE")
local Section3 = Tab3:NewSection("Rage Settings")

-- Toggle para spinbot
local ToggleSpinbot = Tab3:NewToggle("Spinbot", false, function(value)
    toggleSpinbot(value)
end)

-- Keybind para ativar/desativar o spinbot
local TextboxSpinbotKeybind = Tab3:NewTextbox("Keybind para Spinbot", "X", "Digite a tecla", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]
    if key then
        KeybindSpinbot = key
        TextboxSpinbotKeybind:SetText(val:upper())
    end
end)

-- Slider para configurar a velocidade do spinbot
local SliderSpinbotSpeed = Tab3:NewSlider("Spinbot Speed", 0, 100, 10, function(value)
    spinbotSpeed = value
end)

-- Toggle para bunnyhop
local ToggleBunnyhop = Tab3:NewToggle("Bunnyhop", false, function(value)
    toggleBunnyhop(value)
end)

-- Keybind para ativar/desativar o bunnyhop
local TextboxBunnyhopKeybind = Tab3:NewTextbox("Keybind para Bunnyhop", "C", "Digite a tecla", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]
    if key then
        KeybindBunnyhop = key
        TextboxBunnyhopKeybind:SetText(val:upper())
    end
end)

-- Slider para configurar a velocidade do bunnyhop
local SliderBunnyhopSpeed = Tab3:NewSlider("Bunnyhop Speed", 0, 100, 50, function(value)
    bunnyhopSpeed = value
end)

-- Monitorando teclas para ativar/desativar
local function onKeyPress(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == KeybindAimbot then
            toggleAimbot(not aimbotActive)
            Toggle1:Set(aimbotActive)
        elseif input.KeyCode == KeybindToggleMenu then
            toggleMenu()
        elseif input.KeyCode == KeybindSpinbot then
            toggleSpinbot(not spinbotActive)
        elseif input.KeyCode == KeybindBunnyhop then
            toggleBunnyhop(not bunnyhopActive)
        end
    end
end
UserInputService.InputBegan:Connect(onKeyPress)

-- Atualiza o aimbot, spinbot e bunnyhop
RunService.RenderStepped:Connect(function()
    updateAimbotTarget()
    updateSpinbot()
    updateBunnyhop()
end)

local FinishedLoading = Notif:Notify("Silent Aim Loaded", 4, "success")
