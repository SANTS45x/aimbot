local UserInputService = game:GetService("UserInputService")
local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local aimbotActive = false
local targetCharacter = nil  -- O personagem que será o alvo do aimbot
local targetPart = "Head"  -- Valor padrão para o aimbot (cabeça)
local KeybindAimbot = Enum.KeyCode.F  -- Valor padrão para o keybind do aimbot
local KeybindToggleMenu = Enum.KeyCode.M  -- Tecla padrão para abrir/fechar o menu

local menuOpen = true  -- Estado do menu (aberto ou fechado)

-- Função para ativar/desativar o aimbot
local function toggleAimbot(value)
    aimbotActive = value
    if aimbotActive then
        -- Quando o aimbot é ativado, definimos o alvo como o personagem que o mouse está apontando
        if mouse.Target and mouse.Target.Parent and mouse.Target.Parent:FindFirstChild("Humanoid") then
            targetCharacter = mouse.Target.Parent
        end
    else
        -- Quando desativado, limpamos o alvo
        targetCharacter = nil
    end
end

-- Função para atualizar a mira do aimbot para o alvo selecionado
local function updateAimbotTarget()
    if aimbotActive and targetCharacter then
        local humanoid = targetCharacter:FindFirstChild("Humanoid")
        if humanoid then
            -- Procurando pela parte selecionada do personagem
            local part = targetCharacter:FindFirstChild(targetPart)
            if part then
                -- Ajustando a câmera para o alvo selecionado (head, HumanoidRootPart ou qualquer outra parte)
                camera.CFrame = CFrame.new(camera.CFrame.Position, part.Position)
            end
        end
    end
end

-- Função para abrir/fechar o menu
local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        -- Exibe o menu
        Init:Show()
    else
        -- Minimiza o menu (oculta o GUI)
        Init:Hide()
    end
end

-- GUI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
library.rank = "developer"
local Wm = library:Watermark("xsx  | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)

coroutine.wrap(function()
    while wait(.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
local LoadingXSX = Notif:Notify("Loading Silent.", 5, "information") 
library.title = "Silent"
library:Introduction()

wait(1)
local Init = library:Init()

-- Aba "AIMBOT"
local Tab1 = Init:NewTab("AIMBOT")
local Section1 = Tab1:NewSection("Aimbot Settings")

-- Exemplo do Toggle para ativar/desativar o aimbot
local Toggle1 = Tab1:NewToggle("Aimbot Toggle", false, function(value)
    local vers = value and "on" or "off"
    print("Aimbot " .. vers)
    toggleAimbot(value)  -- Chama a função para ativar/desativar o aimbot
end)

-- Opção para configurar a tecla do keybind
local TextboxKeybind = Tab1:NewTextbox("Keybind para Aimbot (tecla)", tostring(KeybindAimbot), "Digite a tecla aqui", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]  -- Converte para maiúscula
    if key then
        KeybindAimbot = key
        print("Tecla do aimbot definida como: " .. val:upper())  -- Exibe a tecla em maiúscula
        TextboxKeybind:SetText(val:upper())  -- Atualiza o campo de texto com a tecla em maiúscula
    else
        print("Tecla inválida!")
    end
end)

-- Seletor para escolher a parte do corpo a ser mirado (cabeça, peito ou qualquer parte)
local Selector1 = Tab1:NewSelector("Selecione a Parte do Corpo", "Head", {"Head", "HumanoidRootPart", "Any"}, function(part)
    targetPart = part
    print("Aimbot agora mira em: " .. part)
end)

-- Keybind para ativar/desativar o aimbot
local function onKeyPress(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == KeybindAimbot then
            -- Alterna o estado do aimbot
            toggleAimbot(not aimbotActive)
            -- Atualiza o estado do Toggle na interface gráfica
            Toggle1:Set(aimbotActive)
            print("Aimbot " .. (aimbotActive and "Ativado" or "Desativado"))
        elseif input.KeyCode == KeybindToggleMenu then
            -- Alterna o estado do menu
            toggleMenu()
        end
    end
end

-- Conectar o evento para o keybind
UserInputService.InputBegan:Connect(onKeyPress)

-- Aba "Settings"
local Tab2 = Init:NewTab("Settings")
local Section2 = Tab2:NewSection("Zombie Settings")

-- Botão "Zombie Animation"
local ButtonZombie = Tab2:NewButton("Zombie Animation", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SANTS45x/animation/refs/heads/main/animatio.lua"))()
    print("Zombie Animation Executada!")
end)

-- Keybind para abrir/fechar o menu
local TextboxMenuKeybind = Tab2:NewTextbox("Keybind para abrir/fechar menu", tostring(KeybindToggleMenu), "Digite a tecla aqui", "all", "medium", true, false, function(val)
    local key = Enum.KeyCode[val:upper()]  -- Converte para maiúscula
    if key then
        KeybindToggleMenu = key
        print("Tecla para abrir/fechar o menu definida como: " .. val:upper())  -- Exibe a tecla em maiúscula
        TextboxMenuKeybind:SetText(val:upper())  -- Atualiza o campo de texto com a tecla em maiúscula
    else
        print("Tecla inválida!")
    end
end)

-- Monitorando o movimento da câmera
game:GetService("RunService").Heartbeat:Connect(function()
    updateAimbotTarget()  -- Atualiza o alvo do aimbot
end)

local FinishedLoading = Notif:Notify("Silent", 4, "success")
