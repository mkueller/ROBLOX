local detectionRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("DetectionRemote")
local removalRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("RemovalRemote")
local searchRemote = 
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AudioRegionSystem"):WaitForChild("Dynamic"):WaitForChild("SearchRemote")

local gameState = workspace:WaitForChild("Globals"):WaitForChild("GameState")

local module = require(game:GetService("ReplicatedStorage"):WaitForChild("ModuleScripts"):WaitForChild("AudioSystemModule"))

local tweenservice = game:GetService("TweenService")

local detect = workspace:WaitForChild("AudioRegionSystem"):WaitForChild("Data"):WaitForChild("Detect")
local doDebugging = workspace:WaitForChild("AudioRegionSystem"):WaitForChild("Data"):WaitForChild("Debug").Value
local cycleOngoing = false
local audioRemoving = false
local removing = false
local adding = false

local queue = {}
local queueItemInProg = false
local queueDebug =  workspace:WaitForChild("AudioRegionSystem"):WaitForChild("Data"):WaitForChild("QueueDebug").Value

local currentRegions = {}
local currentRegionBricks = {}

function finish(audio)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
	tweenservice:Create(audio, tweenInfo, {Volume = 0}):Play()
	wait(1)
	audio:Stop()
end

function complete()
	wait(1)
	audioRemoving = false
end

local taskCoro = coroutine.create(finish)


function begin(audio)
	if doDebugging then
		print("DEBUG - Audio Region System, Dynamic: Coroutine status " .. coroutine.status(taskCoro))
	end
	repeat wait() until not audioRemoving
	audio.Volume = 0
	audio:Play()
	local volume = audio.SoundData.Volume.Value
	if audio:FindFirstChild("VolumeAdjustment") then
		if doDebugging then
			--print("DEBUG - Audio Region System, Dynamic: Volume adjustment of " ..  audio.VolumeAdjustment.Value)
		end
		volume = audio.VolumeAdjustment.Value
	end
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
	tweenservice:Create(audio, tweenInfo, {Volume = volume}):Play()
end

function regionCycle(region, audios, doDebugging)
	local cycleAudios = module.getCycleAudio(region)
	local cycleAudioData = region.Data.CycleAudioData

	if not cycleAudioData.CycleAudioGroup.Value or not cycleAudioData.Audio.Value then
		return
	end
	cycleOngoing = true

	local currentAudio = cycleAudioData.Audio.Value
	local curAudioIndex = cycleAudioData.Audio.Value.SoundData.Order.Value
	cycleAudioData.Audio.Value.TimePosition = cycleAudioData.TimePos.Value

	cycleAudioData.Audio.Value.TimePosition = cycleAudioData.TimePos.Value

	while table.find(currentRegions, region) do
		if doDebugging then
			print("DEBUG - Audio Region System, Dynamic: Cycle audio playing")
		end
		cycleAudioData.Audio.Value.TimePosition = cycleAudioData.TimePos.Value
		begin(cycleAudioData.Audio.Value)
		cycleAudioData.Audio.Changed:Wait()
		if doDebugging then
			print("DEBUG - Audio Region System, Dynamic: Cycle audio changed")
		end
		finish(currentAudio)
		currentAudio = cycleAudioData.Audio.Value
		wait(1)
	end
	cycleOngoing = false
end

function detected(region)
	adding = true
	if doDebugging then
		--print("DEBUG - Audio Region System, Dynamic: Client side" )
	end
	local audios = region.Data.Audios:GetChildren()

	for i = 1, #audios do
		if (audios[i].SoundData.WhenToPlay.Value == gameState.Value or audios[i].SoundData.WhenToPlay.Value == "Always") 
			and audios[i].SoundData.Order.Value < 0 then
			--audios[i]:Play()
			begin(audios[i])
			if doDebugging or queueDebug then
				print("DEBUG - Audio Region System, Dynamic: Audio Playing ".. audios[i].Name)
			end
		end
	end
	if doDebugging then
		print("DEBUG - Audio Region System, Dynamic: adding = false" )
	end
	adding = false
	regionCycle(region, audios, doDebugging)
end

function remove(region)
	removing = true
	
	audioRemoving = true
	local audios = region.Data.Audios:GetChildren()
	for i = 1, #audios do
		taskCoro = coroutine.create(finish)

		coroutine.resume(taskCoro, audios[i])
	end
	taskCoro = coroutine.create(complete)
	--coroutine.resume(taskCoro)
	complete()
	--for i = 1, 10 do wait(.1)
	--	print("Status: " .. coroutine.status((taskCoro)))
	--end
	if doDebugging then
		print("DEBUG - Audio Region System, Dynamic: removing = false" )
	end
	removing = false
end

local function audioOptions(regionPart)
	local currentEffects = regionPart.AudioOptions:GetChildren()

	local audioOptions = regionPart.AudioOptions

	local region = regionPart.Parent.Parent
	local audios = region.Data.Audios:GetChildren()

	--remove old effects
	for i = 1, #audios do
		local audioChildren = audios[i]:GetChildren()
		for j = 1, #audioChildren do
			if audioChildren[j]:FindFirstChild("AudioGroups") then --all effects have the AudioGroup folder
				audioChildren[j]:Destroy()
			end
			if not audios[i]:FindFirstChild("VolumeAdjustment") then
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
				tweenservice:Create(audios[i], tweenInfo, {Volume = audios[i].SoundData.Volume.Value}):Play()
			end
		end
	end

	if #currentEffects == 0 then
		return
	end

	for i = 1, #currentEffects do
		local specificAudios = currentEffects[i].SpecificAudios:GetChildren()

		--to ensure a customization can apply to an audio
		if currentEffects[i].AudioGroups.Ambience.Value or  currentEffects[i].AudioGroups.Cycle.Value or #specificAudios > 0 
then
			if doDebugging then
				print("DEBUG - Audio Region System, Dynamic: Audio Effects. Effect found" )
			end
			if #specificAudios > 0 then --customization will apply to specific audios
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Audio Effects. Effect for spec audio" )
				end
				for j = 1, #specificAudios do
					if specificAudios[j].Value then --ensure audio was assigned
						local effect = currentEffects[i]:Clone()
						effect.Parent = specificAudios[j].Value
						if currentEffects[i].Name == "VolumeAdjustment" and specificAudios[j].Value.Playing then
							local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, 
Enum.EasingDirection.In, 0, false, 0)
							tweenservice:Create(specificAudios[j], tweenInfo, {Volume = 
currentEffects[i].Value}):Play()
						end
					else
						warn("WARNING: Audio Region System. Audio configuation not applied to an audio.")
					end
				end
			end
			if currentEffects[i].AudioGroups.Ambience.Value then --customization will apply to ambience audios
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Audio Effects. Effect for ambience" )
				end
				local ambienceAudios = module.getAmbienceAudio(region)

				for j = 1, #ambienceAudios do
					local effect = currentEffects[i]:Clone()
					effect.Parent = ambienceAudios[j]
				end
			end
			if currentEffects[i].AudioGroups.Cycle.Value then --customization will apply to cycle audios
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Audio Effects. Effect for cycle audios" )
				end
				local cycleAudios = module.getCycleAudio(region)

				for j = 1, #cycleAudios do
					local effect = currentEffects[i]:Clone()
					effect.Parent = cycleAudios[j]
					if currentEffects[i].Name == "VolumeAdjustment" and cycleAudios[j].Playing then
						local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, 
false, 0)
						tweenservice:Create(cycleAudios[j], tweenInfo, {Volume = 
currentEffects[i].Value}):Play()
					end
				end
			end
		else 
			warn("WARNING: Audio Region System. No audio configuation selected.")
		end
	end
end

detect.Changed:Connect(function()
	if #currentRegionBricks > 0 and not adding and not removing then
		local detectedRegions = table.clone(currentRegions)
		local detectedRegionBricks = table.clone(currentRegionBricks) --create table to match detectedregionbricks.  This way, 
if one is removed during the main loop, it'll remain intact


		for i = 1, #currentRegionBricks do
			if doDebugging then
				print("DEBUG - Audio Region System, Dynamic: Region Brick Detecting for region ".. 
currentRegionBricks[i].Parent.Parent.Name )
			end
			local overlapParems = OverlapParams.new()
			overlapParems.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
			overlapParems.FilterType = Enum.RaycastFilterType.Include

			local curRegion = currentRegionBricks[i].Parent.Parent

			local partsInRegion = workspace:GetPartsInPart(currentRegionBricks[i], overlapParems )

			if #partsInRegion == 0 then --player not found in this regionbrick, remove
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Player no longer in region " .. 
currentRegionBricks[i].Parent.Parent.Name )
				end
				currentRegionBricks[i].DetectionScript.Enabled = true
				table.remove(detectedRegionBricks, table.find(currentRegionBricks, currentRegionBricks[i]))

				--Attempt to find in currentRegions. See if there's a region in detectRegBricks i.
				--If this is true, there is another regionbrick the player is touching attached to the current region
				local regionStillPresent = false

				for j = 1, #detectedRegionBricks do
					if detectedRegionBricks[j].Parent.Parent.Name == curRegion.Name then
						if doDebugging then
							print("DEBUG - Audio Region System, Dynamic: Player left, but region still 
present " .. currentRegionBricks[i].Parent.Parent.Name )
						end
						regionStillPresent = true
					end
				end
				if not regionStillPresent then
					table.remove(currentRegions, table.find(currentRegions, currentRegionBricks[i].Parent.Parent))
					--if adding or removing then 
					--	repeat wait() until not adding and not removing
					--end
					remove(curRegion)
				end
			elseif not table.find(currentRegions, currentRegionBricks[i].Parent.Parent) then --player not in region already
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Player located in region ".. 
currentRegionBricks[i].Parent.Parent.Name )
				end
				table.insert(currentRegions, currentRegionBricks[i].Parent.Parent)
				if adding or removing then 
					repeat wait() until not adding and not removing
				end
				detected(currentRegionBricks[i].Parent.Parent)

			else --player already in region
				if doDebugging then
					print("DEBUG - Audio Region System, Dynamic: Player already in region ".. 
currentRegionBricks[i].Parent.Parent.Name )
				end
				if not cycleOngoing then
					regionCycle(currentRegionBricks[i].Parent.Parent, 
currentRegionBricks[i].Parent.Parent.Data.Audios:GetChildren(), doDebugging )
				end
			end
		end
		currentRegionBricks = detectedRegionBricks
	end
end)

searchRemote.Event:Connect(function(Player, regionBrick, doDebugging)
	if Player.Name == game.Players.LocalPlayer.Name then
		
		if not table.find(currentRegionBricks, regionBrick) then
			if doDebugging then
				print("DEBUG - Audio Region System, Dynamic: RegionBrick added locally" )
			end

			table.insert(currentRegionBricks, regionBrick)
			regionBrick.DetectionScript.Enabled = false
			audioOptions(regionBrick)
		end
	end
end)


