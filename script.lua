-- GUI + SISTEMA DE VUELO COMPLETO

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- CREAR GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Ventana
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 230) -- AUMENTÉ ALTURA
frame.Position = UDim2.new(0.5, -150, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

-- Botón cerrar (X)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Botón minimizar (-)
local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)

-- Botón vuelo
local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0, 200, 0, 50)
flyBtn.Position = UDim2.new(0.5, -100, 0.4, -25)
flyBtn.Text = "Activar vuelo"
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)

-- NUEVO BOTÓN (acción)
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0, 200, 0, 40)
tpBtn.Position = UDim2.new(0.5, -100, 0.75, -20)
tpBtn.Text = "Ir hacia donde miro"
tpBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)

-- Botón restaurar (+)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "+"
openBtn.Visible = false
openBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

--------------------------------------------------
-- VARIABLES DE PERSONAJE
--------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60

local bodyVelocity
local bodyGyro

--------------------------------------------------
-- FUNCIONES DE VUELO
--------------------------------------------------

local function startFlying()
	flying = true
	flyBtn.Text = "Detener vuelo"

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
	bodyVelocity.Velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1,1,1) * 100000
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	humanoid.PlatformStand = true
end

local function stopFlying()
	flying = false
	flyBtn.Text = "Activar vuelo"

	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	humanoid.PlatformStand = false
end

--------------------------------------------------
-- MOVIMIENTO (JOYSTICK / WASD)
--------------------------------------------------

game:GetService("RunService").RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		
		local moveDir = humanoid.MoveDirection
		local camCF = camera.CFrame

		local move = (camCF.LookVector * moveDir.Z) + (camCF.RightVector * moveDir.X)

		bodyVelocity.Velocity = move * speed
		bodyGyro.CFrame = camCF
	end
end)

--------------------------------------------------
-- BOTONES GUI
--------------------------------------------------

-- Cerrar
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Minimizar
minBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)

-- Restaurar
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
end)

-- Activar / desactivar vuelo
flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFlying()
	else
		startFlying()
	end
end)

-- NUEVA FUNCIÓN (teleport)
tpBtn.MouseButton1Click:Connect(function()
	local lookVector = camera.CFrame.LookVector
	local distance = 50 -- distancia a donde te manda
	
	root.CFrame = root.CFrame + (lookVector * distance)
end)

--------------------------------------------------
-- SI MUERE EL JUGADOR (REINICIAR)
--------------------------------------------------

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	stopFlying()
end)