-- Variables
local UpdateRate = 1/20
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local Plr = Players.LocalPlayer
local Root, Neck, R6
local LastNeckC0

function HandleCharacter(Char)
	Root, Neck = Char:WaitForChild("HumanoidRootPart"), Char:FindFirstChild("Neck", true)
	
	while not Neck or not Char:FindFirstChildOfClass("Humanoid") do
		wait()
		Neck = Char:FindFirstChild("Neck", true)
	end
	
	R6 = Char:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6
end

Plr.CharacterAdded:Connect(HandleCharacter)
HandleCharacter(Plr.Character or Plr.CharacterAdded:Wait())

local HeadRotationRemote = ReplicatedStorage:WaitForChild("HeadRotationRemote")
HeadRotationRemote.OnClientEvent:Connect(function(Rotations)
	for _, Rot in ipairs(Rotations) do
		local Neck = Rot[1].Character and Rot[1].Character:FindFirstChild("Neck", true)
		if Neck then
			local neckTween = TweenService:Create(Neck, TweenInfo.new(UpdateRate, Enum.EasingStyle.Linear), {C0 = Rot[2]})
			neckTween:Play()
		end
	end
end)

RunService.Stepped:Connect(function()
	if Root and Neck and workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA("Humanoid") and workspace.CurrentCamera.CameraSubject.Parent == Plr.Character then
		local CameraDirection = Root.CFrame:toObjectSpace(workspace.CurrentCamera.CFrame).lookVector.unit
		if R6 then
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(0, -math.asin(CameraDirection.x), 0) * CFrame.Angles(-math.pi/2 + math.asin(CameraDirection.y), 0, math.pi)
		else
			Neck.C0 = CFrame.new(Neck.C0.p) * CFrame.Angles(math.asin(CameraDirection.y), -math.asin(CameraDirection.x), 0)
		end
	end
	
	for _, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer.Character and OtherPlayer.Character:FindFirstChild("Head") then
			local Humanoid = OtherPlayer.Character:FindFirstChildOfClass("Humanoid")
			
			if Humanoid and Humanoid.Health ~= 0 then
				OtherPlayer.Character.Head.CanCollide = false
			end
		end
	end
end)

while wait(UpdateRate) do
	if Neck and LastNeckC0 ~= Neck.C0 then
		HeadRotationRemote:FireServer(Neck.C0)
		LastNeckC0 = Neck.C0
	end
end
-- Place this code in StarterPlayerScript
