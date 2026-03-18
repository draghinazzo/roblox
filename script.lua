-- GUI + VUELO CORREGIDO REAL

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 230)
frame.Position = UDim2.new(0.5, -150, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0,200,0,50)
flyBtn.Position = UDim2.new(0.5,-100,0.3,0)
flyBtn.Text = "Activar vuelo5"

--------------------------------------------------
-- PERSONAJE
--------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60

local bv
local bg

--------------------------------------------------
-- INPUT ALTURA
--------------------------------------------------

local up = false
local down = false

UIS.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.Space then up = true end
	if i.KeyCode == Enum.KeyCode.LeftControl then down = true end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.Space then up = false end
	if i.KeyCode == Enum.KeyCode.LeftControl then down = false end
end)

--------------------------------------------------
-- VUELO
--------------------------------------------------

local function startFly()
	flying = true
	flyBtn.Text = "Detener vuelo"

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1,1,1)*100000
	bv.Parent = root

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1,1,1)*100000
	bg.Parent = root

	-- IMPORTANTE: NO usar PlatformStand
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

local function stopFly()
	flying = false
	flyBtn.Text = "Activar vuelo5"

	if bv then bv:Destroy() end
	if bg then bg:Destroy() end

	humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

--------------------------------------------------
-- MOVIMIENTO CORRECTO
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	if flying and bv and bg then
		
		local moveDir = humanoid.MoveDirection -- 🔥 JOYSTICK REAL
		local y = 0

		if up then y = 1 end
		if down then y = -1 end

		local move = Vector3.new(moveDir.X, y, moveDir.Z)

		if move.Magnitude > 0 then
			bv.Velocity = move.Unit * speed
		else
			bv.Velocity = Vector3.new(0,0,0)
		end

		-- solo rotación visual
		bg.CFrame = camera.CFrame
	end
end)

--------------------------------------------------
-- BOTÓN
--------------------------------------------------

flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
	else
		startFly()
	end
end)

--------------------------------------------------
-- RESET
--------------------------------------------------

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
	stopFly()
end)