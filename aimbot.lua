local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local aimbotActive = false
local KeybindAimbot = Enum.KeyCode.F -- Tecla padrão para ativar/desativar o aimbot
local KeybindToggleMenu = Enum.KeyCode.M -- Tecla para abrir/fechar o menu
local targetPart = "Head" -- Parte do corpo para mirar (Head, HumanoidRootPart, etc.)
local menuOpen = true -- Estado do menu

-- Função para encontrar o inimigo mais próximo da mira
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character:FindFirstChild(targetPart) or player.Character:FindFirstChild("Head")
            if target then
                local screenPosition, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
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
end

-- Função para mover a mira suavemente para o alvo
local function updateAimbotTarget()
    if aimbotActive then
        local target = getClosestEnemy()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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
local Wm = library:Watermark("Silent | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
local LoadingXSX = Notif:Notify("Loading Aimbot.", 5, "information") 
library.title = "Silent"
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
