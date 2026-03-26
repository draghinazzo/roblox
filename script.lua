--------------------------------------------------
-- FANTASMA PRO (NOCLIP + ANTI TODO)
--------------------------------------------------

local noclipConnection
local velocityLockConnection
local godConnection

local function setGhost(state)
	ghost = state

	if state then
		ghostBtn.Text = "Desactivar Fantasma"
		ghostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
		fBtn.Text = "XX"

		-- 👻 NOCLIP + SIN MASA
		noclipConnection = RunService.Heartbeat:Connect(function()
			if character then
				for _, v in pairs(character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
						v.Transparency = 0.6
						v.Massless = true
					end
				end
			end
		end)

		-- 🛡️ ANTI EMPUJES / EXPLOSIONES
		velocityLockConnection = RunService.Heartbeat:Connect(function()
			if root then
				local vel = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
			end
		end)

		-- ❤️ REGENERACIÓN DE VIDA (modo dios parcial)
		godConnection = RunService.Heartbeat:Connect(function()
			if humanoid and humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)

	else
		ghostBtn.Text = "Modo Fantasma"
		ghostBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
		fBtn.Text = "F"

		-- Desconectar todo
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end

		if velocityLockConnection then
			velocityLockConnection:Disconnect()
			velocityLockConnection = nil
		end

		if godConnection then
			godConnection:Disconnect()
			godConnection = nil
		end

		-- Restaurar normal
		if character then
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = true
					v.Transparency = 0
					v.Massless = false
				end
			end
		end
	end
end