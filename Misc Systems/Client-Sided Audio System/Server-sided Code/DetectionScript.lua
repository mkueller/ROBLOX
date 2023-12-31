local gameState = workspace:WaitForChild("Globals"):WaitForChild("GameState")

local detectionRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("DetectionRemote")
local removalRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("RemovalRemote")
local searchRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("SearchRemote")


local audios = script.Parent.Parent.Parent:WaitForChild("Data"):WaitForChild("Audios"):GetChildren()
local detectionOptions = script.Parent:WaitForChild("Data"):GetChildren()
local regionPart = script.Parent
local audioRegion = script.Parent.Parent.Parent

local doDebugging = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Data"):WaitForChild("Debug").Value
local detectVal = script.Parent.Parent.Parent.Parent.Parent:WaitForChild("Data"):WaitForChild("Detect")

local playersInRegion = {}

local detecting = false
local debounce = false



local function canDetect()
	for i = 1, #detectionOptions do
		if detectionOptions[i]:IsA("StringValue") and detectionOptions[i].Value == gameState.Value or detectionOptions[i].Value 
== "Always" then
			detecting = true
			return
		end
	end
	detecting = false
end

function detect(hit)
	if not debounce and detecting then 
		debounce = true
		if hit.Parent:FindFirstChild("Humanoid") then
			if doDebugging then
				print("DEBUG - Audio Region System, Dynamic: Player touched region brick")
			end
			searchRemote:Fire (game.Players:GetPlayerFromCharacter(hit.Parent), script.Parent, doDebugging)
		end
		wait(.3)
		debounce = false
	end
end

script.Parent.Touched:Connect(function(hit)
	detect(hit)
end)

detectVal.Changed:Connect(function()
	canDetect()
end)



