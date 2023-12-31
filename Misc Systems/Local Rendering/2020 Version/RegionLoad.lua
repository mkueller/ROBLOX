regionParts = {}
isRegionLoaded = {}
regions = {}
regionData = script.Parent:WaitForChild("regionData")
regionCount = 1

--function to find the regions within replicated storage
function findRegions(object)
	if object:IsA("IntValue") and object.Name == "region" then
		object.Value = regionCount
		regionCount = regionCount + 1
		table.insert(regionParts,object.Parent.regionPart)
		table.insert(isRegionLoaded,false)
	end
	for i,v in pairs(object:GetChildren()) do
		findRegions(v)
	end
end
findRegions(game.ReplicatedStorage)

--function to create the region3's based on the tables created when finding regions
function createRegion(regionPart)
	local pos1, pos2 = (regionPart.Position - (regionPart.Size/2)), (regionPart.Position + (regionPart.Size/2))
	local region = Region3.new(pos1,pos2)
	table.insert(regions,region)
end
--iterate through all the found regions to make region3's
for i=1,#regionParts do
	createRegion(regionParts[i],i)
end
--everything above runs only when the player joins ^^^ 

--runs every second to find if a player is in a region
function checkRegion()
	print("rujj")
	for count=1,#regionParts do
		local partsInRegion = 
workspace:FindPartsInRegion3WithWhiteList(regions[count],game.Players.LocalPlayer.Character:GetDescendants())
		for i,part in pairs(partsInRegion) do
			if part.Parent:FindFirstChild("Humanoid") and part.Parent.Name == game.Players.LocalPlayer.Name and not 
isRegionLoaded[count] then
				isRegionLoaded[count] = true
				regionData.regionPart.Value = regionParts[count]
			end
		end
	end
end

--runs when the regionload script detects when a player leaves a region
regionData.regionDeleting.Changed:Connect(function()
	print("running")
	isRegionLoaded[regionData.regionDeleting.Value] = false
	regionData.regionDeleting.Value = nil
end)

function main()
	while true do wait(1)
		for i=1,#isRegionLoaded do
			print(isRegionLoaded[i],i)
		end
		checkRegion()
	end
end
main()
