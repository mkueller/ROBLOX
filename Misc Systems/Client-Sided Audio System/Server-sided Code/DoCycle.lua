if not script.Parent:WaitForChild("CycleAudioGroup").Value then
	script:Destroy()
	print("no cycle audio")
end

local gameState = workspace:WaitForChild("Globals"):WaitForChild("GameState")
local audios = script.Parent.CycleAudioGroup.Value:GetChildren()

 groups = {"Port", "Voyage", "Sinking", "SinkingStage2", "SinkingStage3", "SinkingStage4", "SinkingStage5", "PostSinking", "Always"} 
--groups
 cycleAudios = {} --2D array for storing audios in each group

for i = 1, #groups do
	table.insert(cycleAudios, table.create(1)) -- Create a table for each group
end

 currentGroup = cycleAudios[table.find(groups, gameState.Value)]
 currentAudio = nil	
 currentTimePos = 0
 changeGroup = false

local doDebugging = script.Parent.Parent.Parent.Parent.Parent.Data:WaitForChild("Debug").Value


local function getAudioGroups(audio)
	local audioChildren = audio.SoundData:GetChildren()
	local audioGroups = {}
	for i = 1, #audioChildren do
		if audioChildren[i].Name == "WhenToPlay" then
			table.insert(audioGroups, audioChildren[i].Value)
		end
	end
	return audioGroups
end

for i = 1, #audios do
	if audios[i].SoundData.Order.Value >= 0 then --Cycle audio detected
		local audioGroups = getAudioGroups(audios[i])
		for j = 1, #groups do
			if doDebugging then
				print("DEBUG - Audio Region System, Dynamic: audiogroup found: " .. groups[j] )
			end
			if table.find(audioGroups, "Always") or table.find(audioGroups, groups[j]) then
				table.insert(cycleAudios[table.find(groups, groups[j])], audios[i])
			end
			--if not inserted then
			--	table.insert(cycleAudios[table.find(groups, audioGroups[j])], audios[i]) -- get group, find spot of 
group in groups table, insert into that spot in cycle audios table
			--end
		end
	end
	
end

repeat wait(1) until audios[1].IsLoaded

for i = 1, #cycleAudios do --ensure each audio is sorted
	table.sort(cycleAudios[i], function(a, b)
		return a.SoundData.Order.Value < b.SoundData.Order.Value
	end)
end

local function cycle()
	while true do wait()
		if #currentGroup == 0 then
			break
		end
		for i = 1, #currentGroup do
			script.Parent.TimePos.Value = 0
			script.Parent.Audio.Value = currentGroup[i]
			local audioLength = math.ceil(currentGroup[i].TimeLength)
			for j = 1, audioLength do
				script.Parent.TimePos.Value += 1
				wait(1)
			end
		end
		if changeGroup then
			changeGroup = false
			break
		end
	end
end
cycle()

gameState.Changed:Connect(function()
	currentGroup = cycleAudios[table.find(groups, gameState.Value)]
	changeGroup = true
	script.Parent.Audio.Value = currentGroup[1]
	script.Parent.TimePos.Value = 0
	cycle()
end)

