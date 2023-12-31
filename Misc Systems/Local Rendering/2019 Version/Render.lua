regionParts = {}
regions = {}
regionsSelected = {}
regionSelected = nil
playerInRegion = {}
function findRegions(object)
	if object:IsA("IntValue") and object.Name == "region" then
		table.insert(regionParts,object.Parent.regionPart)
	end
	for i,v in pairs(object:GetChildren()) do
		findRegions(v)
	end
end
findRegions(game.ReplicatedStorage)

function createRegion(regionPart)
	local pos1, pos2 = (regionPart.Position - (regionPart.Size/2)), (regionPart.Position + (regionPart.Size/2))
	local region = Region3.new(pos1,pos2)
	table.insert(regions,region)
end
for i=1,#regionParts do
	createRegion(regionParts[i])
end

function begin()
	while true do
		for i=1,#regionParts do
			checkRegion(regions[i],i)
		end
		wait(1)
		for i=1,#regionsSelected do
			regionsSelected[i] = nil
		end
	end
end

function cloneModel(i,condition)
	if condition then
		for i=1,#regionsSelected do
			
		end
		regionSelected.Parent = workspace
		waitToLeave()
	else
		regionSelected:Destroy()
		playerInRegion[1] = false
		playerInRegion[2] = nil
		begin()
	end
end
function waitToLeave(region,i)
	local partsInRegion = workspace:FindPartsInRegion3WithWhiteList(region,game.Players.LocalPlayer.Character:GetDescendants())
	for i,part in pairs(partsInRegion) do
		if part.Parent ~= nil then
			if part.Parent:FindFirstChild("Humanoid") and part.Parent.Name == game.Players.LocalPlayer.Name then
				wait(.5)
				waitToLeave(region)
			end
		end
	end
	cloneModel(i,region,false)
end
function checkRegion(region,count)
	local partsInRegion = workspace:FindPartsInRegion3WithWhiteList(region,game.Players.LocalPlayer.Character:GetDescendants())
	for i,part in pairs(partsInRegion) do
		if part.Parent:FindFirstChild("Humanoid") and part.Parent.Name == game.Players.LocalPlayer.Name then
			table.insert(regionsSelected,region)
			cloneModel(count,true)
		end
	end
end

begin()
