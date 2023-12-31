regionsSelected = {}
regionPartsSelected = {}
regionPartsInWorkspace = {}
regionData = script.Parent:WaitForChild("regionData")
isRunning = false

function createRegion(regionPart)
	if regionPart ~= nil then
		local pos1, pos2 = (regionPart.Position - (regionPart.Size/2)), (regionPart.Position + (regionPart.Size/2))
		local region = Region3.new(pos1,pos2)
		table.insert(regionsSelected,region)
		cloneModels(regionPart)
	end
end


function checkIfInRegion()
	for count=1,#regionsSelected do
		if regionsSelected[count] ~= nil and regionPartsSelected[count].Parent ~= nil then
			local partsInRegion = 
workspace:FindPartsInRegion3WithWhiteList(regionsSelected[count],game.Players.LocalPlayer.Character:GetDescendants())
			if table.getn(partsInRegion) == 0 then
				regionData.regionDeleting.Value = regionPartsSelected[count].Parent.region.Value
				regionPartsSelected[count].Parent:Destroy()
				wait(.5)
			end
		end
	end
end

function cloneModels(regionPart)
	if regionPart ~= nil then
		local newregion = regionPart.Parent:Clone()
		newregion.Parent = workspace
		table.insert(regionPartsSelected,newregion.regionPart)
	end
	checkIfInRegion()
end

regionData.regionPart.Changed:Connect(function()
	print("running region check")
	createRegion(regionData.regionPart.Value)
	regionData.regionPart.Value = nil
end)

while true do wait()
	checkIfInRegion()
end

