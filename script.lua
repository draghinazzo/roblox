local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Ventana
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 280) -- Aumentado para el nuevo botón
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

-- Cerrar
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"

-- Minimizar
local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"

-- Botón vuelo dentro
local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0, 200, 0, 40)
flyBtn.Position = UDim2.new(0.5, -100, 0.2, -20)
flyBtn.Text = "Activar vuelo"

-- Botón clonar dentro
local cloneBtn = Instance.new("TextButton", frame)
cloneBtn.Size = UDim2.new(0, 200, 0, 40)
cloneBtn.Position = UDim2.new(0.5, -100, 0.4, -20)
cloneBtn.Text = "Iniciar clonación"
cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)

-- Teleport
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0, 200, 0, 40)
tpBtn.Position = UDim2.new(0.5, -100, 0.6, -20)
tpBtn.Text = "Ir hacia donde miro"

-- Botón +
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "+"
openBtn.Visible = false

-- BOTÓN U (subir)
local upBtn = Instance.new("TextButton", gui)
upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(0, 60, 0, 10)
upBtn.Text = "U"
upBtn.Visible = false

-- BOTÓN V (vuelo toggle)
local vBtn = Instance.new("TextButton", gui)
vBtn.Size = UDim2.new(0, 40, 0, 40)
vBtn.Position = UDim2.new(0, 110, 0, 10)
vBtn.Text = "V"
vBtn.Visible = false

-- BOTÓN CL (clonar toggle)
local clBtn = Instance.new("TextButton", gui)
clBtn.Size = UDim2.new(0, 40, 0, 40)
clBtn.Position = UDim2.new(0, 160, 0, 10)
clBtn.Text = "CL"
clBtn.Visible = false
clBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)

--------------------------------------------------
-- PERSONAJE
--------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60

local bodyVelocity
local bodyGyro

local subirBtnActivo = false

--------------------------------------------------
-- CLONACIÓN DE ÁRBOLES
--------------------------------------------------

local treeInstance = nil
local axeInstance = nil
local hitId = nil
local hitCFrame = nil
local cloning = false
local cloningThread = nil
local toolDamageObject = nil

-- Buscar el RemoteFunction correcto
for _, item in pairs(ReplicatedStorage:GetDescendants()) do
    if item:IsA("RemoteFunction") and item.Name == "ToolDamageObject" then
        toolDamageObject = item
        break
    end
end

if not toolDamageObject then
    warn("No se encontró ToolDamageObject RemoteFunction")
else
    -- Hook para capturar los datos del primer golpe
    local originalInvoke = toolDamageObject.InvokeServer
    toolDamageObject.InvokeServer = function(self, ...)
        local args = {...}
        
        if #args >= 4 and not treeInstance then
            treeInstance = args[1]
            axeInstance = args[2]
            hitId = args[3]
            hitCFrame = args[4]
            
            print("Datos del árbol capturados: " .. (treeInstance and treeInstance.Name or "N/A"))
        end
        
        return originalInvoke(self, ...)
    end
end

local function startCloning()
    if not treeInstance or not toolDamageObject then
        warn("No hay datos del árbol capturados. Golpea un árbol primero.")
        return
    end
    
    cloning = true
    cloneBtn.Text = "Detener clonación"
    cloneBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    clBtn.Text = "XX"
    clBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    
    cloningThread = coroutine.create(function()
        while cloning do
            pcall(function()
                toolDamageObject:InvokeServer(treeInstance, axeInstance, hitId, hitCFrame)
            end)
            wait(0.1) -- Ajustable para cambiar la velocidad
        end
    end)
    
    coroutine.resume(cloningThread)
end

local function stopCloning()
    cloning = false
    cloneBtn.Text = "Iniciar clonación"
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    clBtn.Text = "CL"
    clBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end

--------------------------------------------------
-- VUELO
--------------------------------------------------

local function startFlying()
    flying = true
    flyBtn.Text = "Detener vuelo"
    vBtn.Text = "XX"

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1,1,1) * 100000
    bodyGyro.Parent = root

    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    flyBtn.Text = "Activar vuelo"
    vBtn.Text = "V"

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    humanoid.PlatformStand = false
end

--------------------------------------------------
-- MOVIMIENTO
--------------------------------------------------

RunService.RenderStepped:Connect(function()
    if flying and bodyVelocity and bodyGyro then
        
        local moveDir = humanoid.MoveDirection
        local y = 0

        if humanoid.Jump or subirBtnActivo then
            y = 1
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            y = -1
        end

        local move = Vector3.new(moveDir.X, y, moveDir.Z)

        if move.Magnitude > 0 then
            bodyVelocity.Velocity = move.Unit * speed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end

        bodyGyro.CFrame = camera.CFrame
    end
end)

--------------------------------------------------
-- BOTONES
--------------------------------------------------

-- Cerrar
closeBtn.MouseButton1Click:Connect(function()
    stopCloning()
    gui:Destroy()
end)

-- Minimizar
minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
    upBtn.Visible = true
    vBtn.Visible = true
    clBtn.Visible = true
end)

-- Restaurar
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
    upBtn.Visible = false
    vBtn.Visible = false
    clBtn.Visible = false
end)

-- Botón interno vuelo
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)

-- BOTÓN V (toggle vuelo)
vBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)

-- BOTÓN U (subir mientras presionas)
upBtn.MouseButton1Down