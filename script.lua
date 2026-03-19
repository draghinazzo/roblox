-- GUI + VUELO + BOTONES (FUNCIONAL)

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
frame.Size = UDim2.new(0, 300, 0, 280)
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

-- Botón vuelo
local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0, 200, 0, 40)
flyBtn.Position = UDim2.new(0.5, -100, 0.2, -20)
flyBtn.Text = "Activar vuelo"

-- Botón clonación (simulado)
local cloneBtn = Instance.new("TextButton", frame)
cloneBtn.Size = UDim2.new(0, 200, 0, 40)
cloneBtn.Position = UDim2.new(0.5, -100, 0.4, -20)
cloneBtn.Text = "Simular golpes"
cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)

-- Teleport
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0, 200, 0, 40)
tpBtn.Position = UDim2.new(0.5, -100, 0.6, -20)
tpBtn.Text = "Ir hacia donde miro"

-- Botones flotantes
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "+"
openBtn.Visible = false

local upBtn = Instance.new("TextButton", gui)
upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(0, 60, 0, 10)
upBtn.Text = "U"
upBtn.Visible = false

local vBtn = Instance.new("TextButton", gui)
vBtn.Size = UDim2.new(0, 40, 0, 40)
vBtn.Position = UDim2.new(0, 110, 0, 10)
vBtn.Text = "V"
vBtn.Visible = false

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
-- "CLONACIÓN" (SIMULADA)
--------------------------------------------------

local cloning = false

local function startCloning()
    cloning = true
    cloneBtn.Text = "Detener"
    cloneBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    clBtn.Text = "XX"
end

local function stopCloning()
    cloning = false
    cloneBtn.Text = "Simular golpes"
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    clBtn.Text = "CL"
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

closeBtn.MouseButton1Click:Connect(function()
    stopCloning()
    gui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
    upBtn.Visible = true
    vBtn.Visible = true
    clBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
    upBtn.Visible = false
    vBtn.Visible = false
    clBtn.Visible = false
end)

flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)

vBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)

cloneBtn.MouseButton1Click:Connect(function()
    if cloning then
        stopCloning()
    else
        startCloning()
    end
end)

clBtn.MouseButton1Click:Connect(function()
    if cloning then
        stopCloning()
    else
        startCloning()
    end
end)

-- SUBIR
upBtn.MouseButton1Down:Connect(function()
    subirBtnActivo = true
end)

upBtn.MouseButton1Up:Connect(function()
    subirBtnActivo = false
end)

-- TELEPORT
tpBtn.MouseButton1Click:Connect(function()
    local ray = Ray.new(camera.CFrame.Position, camera.CFrame.LookVector * 500)
    local part, position = workspace:FindPartOnRay(ray, character)

    if position then
        root.CFrame = CFrame.new(position + Vector3.new(0,5,0))
    end
end)