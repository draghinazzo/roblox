-- GUI + SISTEMA DE VUELO COMPLETO MEJORADO

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--------------------------------------------------
-- CREAR GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- Ventana
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 230)
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
flyBtn.Position = UDim2.new(0.5, -100, 0.35, -25)
flyBtn.Text = "Activar vuelo3"
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)

-- Botón teleport
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0, 200, 0, 40)
tpBtn.Position = UDim2.new(0.5, -100, 0.7, -20)
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
	flyBtn.Text = "Activar vuelo3"

	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	humanoid.PlatformStand = false
end

--------------------------------------------------
-- MOVIMIENTO MEJORADO (JOYSTICK + ALTURA)
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		
		local moveDir = humanoid.MoveDirection
		local y = 0

		-- SUBIR (móvil y PC)
		if humanoid.Jump then
			y = 1
		end

		-- BAJAR (PC)
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			y = -1
		end

		local move = Vector3.new(moveDir.X, y, moveDir.Z)

		if move.Magnitude > 0 then
			bodyVelocity.Velocity = move.Unit * speed
		else
			bodyVelocity.Velocity = Vector3.new(0,0,0)
		end

		-- Mirar hacia la cámara
		bodyGyro.CFrame = camera.CFrame
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

-- Teleport
tpBtn.MouseButton1Click:Connect(function()
	local lookVector = camera.CFrame.LookVector
	local distance = 50
	root.CFrame = root.CFrame + (lookVector * distance)
end)

--------------------------------------------------
-- REINICIAR AL MORIR
--------------------------------------------------

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	stopFlying()
end)