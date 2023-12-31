--Elvator script circa 2020. 

--Service/Module declarations
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
local module = require(game.ServerScriptService.DoorModule)


--Elevator surrounding variables
elev = script.Parent
PrimaryPart = elev.PrimaryPart
doorss = {script.Parent.Parent.D1,script.Parent.Parent.D2,script.Parent.Parent.D3,script.Parent.Parent.D4}

--Floor click buttons. Used to call the elevator. 
cl1 = script.Parent.Parent.E1
cl2 = script.Parent.Parent.E2
cl3 = script.Parent.Parent.E3

--Level parts act as the position for the floor. The elevator will travel to match the Y position of these parts.
lv1 = script.Parent.Parent.LV1
lv2 = script.Parent.Parent.LV2
lv3 = script.Parent.Parent.LV3

--Elevator state variables
tweenConstant = 4 --A variable that controlls speed. 
currentFloor = 1
isMoving = false

--Function to create a tween to move the elevator. Tweening is a ROBLOX service that allows for enhancements and customizations for moving objects.
--Tweening can be used to dynamically change any property of an object. Documentation: https://create.roblox.com/docs/reference/engine/classes/Tween
function createTween(distance,rate)
	--tweeninfo is a service to create a tween. It takes parameters for the style of movement, the direction, if the tween will repeat, if it reverses,
	--and the delaytime before it begins. Documentation: https://create.roblox.com/docs/reference/engine/datatypes/TweenInfo
	tweenInfo = TweenInfo.new(rate,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0) 
	
	--tweenService:Create() creates a tween with the given tweenInfo, specifies the part to be moved, as well as the distance. 
	return tweenService:Create(PrimaryPart,tweenInfo,{CFrame = PrimaryPart.CFrame * CFrame.new(0,distance,0)})
end

--Weld all objects in the elevator to the PrimaryPart. That way, by moving the PrimaryPart, all objects in the elevator move with it. 
--This script is available separately. 
module.weld(script.Parent,script.Parent.PrimaryPart)

--Algorithm for determining how far the elevator will move, the direction, and the time the elevator will take to arrive at its destination. 
--Parameters:
--floor: destination floor
--CurrentFloor: current floor
--Part: the call button
--lvl: The level part for the destination floor. 
function elevatorLogic(floor,CurrentFloor,part,lvl)
	isMoving = true
	local amtMoving = lvl.Position.Y - PrimaryPart.Position.Y --Calculate total Y distance
	local tweenTime = math.abs(amtMoving)/tweenConstant --Calculates time/speed. tweenConstant will determine the overall speed. 
	createTween(amtMoving,tweenTime):Play()
	wait(tweenTime)
	currentFloor = floor
	part.Material = "Plastic" --Setting the material to plastic signifies the elevator arrived to destination
	
	--Loop to find door of destination floor. 
	for i=1,#doorss do
		if i == currentFloor then
			doors(doorss[i])
		end
	end
	isMoving = false
end

--This function ensures that the elevator cannot be called while it is moving. If it is, each call is added to a queue. 
function delagate(floor,currentFloor,part,lvl)
	repeat wait() until isMoving == false
	elevatorLogic(floor,currentFloor,part,lvl)
end

--Below are event functions for activating the elevator. 
cl1.ClickDetector.MouseClick:Connect(function()
	local part = cl1
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(1,currentFloor,part,lv1)
		else
			delagate(1,currentFloor,part,lv1)
		end
		
	end
end)
cl2.ClickDetector.MouseClick:Connect(function()
	local part = cl2
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(2,currentFloor,part,lv2)
		else
			delagate(2,currentFloor,part,lv2)
		end
	end
end)
cl3.ClickDetector.MouseClick:Connect(function()
	local part = cl3
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(3,currentFloor,part,lv3)
		else
			delagate(3,currentFloor,part,lv3)
		end
		
	end
end)
elev.F1.ClickDetector.MouseClick:Connect(function()
	local part = script.Parent.F1
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(1,currentFloor,part,lv1)
		else
			delagate(1,currentFloor,part,lv1)
		end
		
	end
end)
elev.F2.ClickDetector.MouseClick:Connect(function()
	local part = script.Parent.F2
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(2,currentFloor,part,lv2)
		else
			delagate(2,currentFloor,part,lv2)
		end
		
	end
end)
elev.F3.ClickDetector.MouseClick:Connect(function()
	local part = script.Parent.F3
	if part.Material ~= "Neon" then
		part.Material = "Neon"
		if isMoving == false then
			elevatorLogic(3,currentFloor,part,lv3)
		else
			delagate(3,currentFloor,part,lv3)
		end
		
	end
end)
function doors(outer)
	for i,v in pairs(elev:GetChildren()) do
		if v.Name ~= "Master" and v.Name ~= "PrimaryPart" then
			v.Anchored = true
		end
	end
	for i=1,25 do
		for i,v in pairs(elev:GetChildren()) do
			if v.Name == "DL" then
				v.CFrame = v.CFrame * CFrame.new(-.1,0,0)
			end
			if v.Name == "DR" then
				v.CFrame = v.CFrame * CFrame.new(.1,0,0)
			end
		end
		for i,v in pairs(outer:GetChildren()) do
			if v.Name == "DL" then
				v.CFrame = v.CFrame * CFrame.new(-.1,0,0)
			end
			if v.Name == "DR" then
				v.CFrame = v.CFrame * CFrame.new(.1,0,0)
			end
		end
		wait(.01)
	end
	wait(4)
	for i=1,25 do
		for i,v in pairs(elev:GetChildren()) do
			if v.Name == "DL" then
				v.CFrame = v.CFrame * CFrame.new(.1,0,0)
			end
			if v.Name == "DR" then
				v.CFrame = v.CFrame * CFrame.new(-.1,0,0)
			end
		end
		for i,v in pairs(outer:GetChildren()) do
			if v.Name == "DL" then
				v.CFrame = v.CFrame * CFrame.new(.1,0,0)
			end
			if v.Name == "DR" then
				v.CFrame = v.CFrame * CFrame.new(-.1,0,0)
			end
		end
		wait(.01)
	end
	for i,v in pairs(elev:GetChildren()) do
		if v.Name ~= "Master" and v.Name ~= "PrimaryPart" then
			v.Anchored = false
		end
	end
end