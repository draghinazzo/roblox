-- GUI + VUELO + BOTONES (FANTASMA + VUELO PERFECTO)

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--------------------------------------------------
-- VARIABLES DINÁMICAS
--------------------------------------------------

local character
local humanoid
local root

local function updateCharacter(char)
	character = char
	humanoid = char:FindFirstChildOfClass("Humanoid")
	root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart

	if not root then
		char:GetPropertyChangedSignal("PrimaryPart"):Wait()
		root = char.PrimaryPart
	end
end

updateCharacter(player.Character or player.CharacterAdded:Wait())

player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	updateCharacter(char)
end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"

local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(0, 200, 0, 40)
flyBtn.Position = UDim2.new(0.5, -100, 0.2, -20)
flyBtn.Text = "Activar vuelo"

local ghostBtn = Instance.new("TextButton", frame)
ghostBtn.Size = UDim2.new(0, 200, 0, 40)
ghostBtn.Position = UDim2.new(0.5, -100, 0.4, -20)
ghostBtn.Text = "Modo Fantasma"
ghostBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)

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

local fBtn = Instance.new("TextButton", gui)
fBtn.Size = UDim2.new(0, 40, 0, 40)
fBtn.Position = UDim2.new(0, 160, 0, 10)
fBtn.Text = "F"
fBtn.Visible = false
fBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)

--------------------------------------------------
-- ESTADOS
--------------------------------------------------

local flying = false
local speed = 60
local subirBtnActivo = false
local ghost = false

--------------------------------------------------
-- FANTASMA (NOCLIP REAL SIN CONFLICTO)
--------------------------------------------------

local noclipConnection

local function setGhost(state)
	ghost = state

	if state then
		ghostBtn.Text = "Desactivar Fantasma"
		ghostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
		fBtn.Text = "XX"

		noclipConnection = RunService.Heartbeat:Connect(function()
			if character then
				for _, v in pairs(character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
						v.Transparency = 0.6
					end
				end
			end
		end)

	else
		ghostBtn.Text = "Modo Fantasma"
		ghostBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
		fBtn.Text = "F"

		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end

		if character then
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
					v.Transparency = 0
				end
			end
		end
	end
end

--------------------------------------------------
-- VUELO
--------------------------------------------------

local function startFlying()
	if not root then return end
	flying = true
	flyBtn.Text = "Detener vuelo"
	vBtn.Text = "XX"
end

local function stopFlying()
	flying = false
	flyBtn.Text = "Activar vuelo"
	vBtn.Text = "V"

	if root then
		root.AssemblyLinearVelocity = Vector3.new(0,0,0)
	end
end

--------------------------------------------------
-- MOVIMIENTO (PERFECTO)
--------------------------------------------------

RunService.Heartbeat:Connect(function()
	if flying and root then
		
		local moveDir = Vector3.new(0,0,0)

		if humanoid then
			moveDir = humanoid.MoveDirection
		end

		local y = 0

		-- SUBIR
		if (humanoid and humanoid.Jump) or subirBtnActivo then
			y = 1
		end

		-- BAJAR
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			y = -1
		end

		local move = Vector3.new(moveDir.X, y, moveDir.Z)

		if move.Magnitude > 0 then
			root.AssemblyLinearVelocity = Vector3.new(
				move.Unit.X * speed,
				y * speed,
				move.Unit.Z * speed
			)
		else
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end

		root.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
	end
end)

--------------------------------------------------
-- BOTONES
--------------------------------------------------

closeBtn.MouseButton1Click:Connect(function()
	stopFlying()
	setGhost(false)
	gui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
	upBtn.Visible = true
	vBtn.Visible = true
	fBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
	upBtn.Visible = false
	vBtn.Visible = false
	fBtn.Visible = false
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

ghostBtn.MouseButton1Click:Connect(function()
	setGhost(not ghost)
end)

fBtn.MouseButton1Click:Connect(function()
	setGhost(not ghost)
end)

upBtn.MouseButton1Down:Connect(function()
	subirBtnActivo = true
end)

upBtn.MouseButton1Up:Connect(function()
	subirBtnActivo = false
end)

tpBtn.MouseButton1Click:Connect(function()
	if not root then return end

	local ray = Ray.new(camera.CFrame.Position, camera.CFrame.LookVector * 500)
	local part, position = workspace:FindPartOnRay(ray, character)

	if position then
		root.CFrame = CFrame.new(position + Vector3.new(0,5,0))
	end
end)