module = require(game.ServerScriptService.DoorModule)
module.weld(script.Parent.Phone,script.Parent.Phone.PrimaryPart)

data = script.Parent.Data
sounds = {1468236750,1462632803} --1: Change, 2: Ringing

phoneCFrame = script.Parent.Phone.PrimaryPart.CFrame
isActive = data.Active.Value
isTalking = false
number = data.Number.Value
ringing = data.Ringing.Value
newWeld = nil
otherPhone = nil

function sound(sound,id,startPoint,endPoint)
	sound.SoundId = "rbxassetid://"..id
	sound.TimePosition = startPoint
	sound:Play()
	wait(endPoint)
	sound:Stop()
end
function message(phone,msg)
	game:GetService("Chat"):Chat(phone.Click,msg)
end

function findPhone(newNumber,isDialing)
	local parts = workspace:GetDescendants()
	for i=1,#parts do
		if parts[i]:IsA("IntValue") then
			if parts[i].Name == "Number" then
				if parts[i].Value == tonumber(newNumber) and (not parts[i].Parent.Active.Value or not isDialing) and not 
parts[i].Parent.Ringing.Value then
					return parts[i].Parent.Parent
				end
			end
		end
	end
end
function call(Player)
	local msg = Player.Chatted:Wait()
	if otherPhone.Data.Active.Value and not otherPhone.Data.Ringing.Value then
		message(otherPhone,msg)
	end
	if data.Active.Value then
		call(Player)
	end
end
function disconnect(Player)
	newWeld:Destroy()
	script.Parent.Phone.PrimaryPart.CFrame = phoneCFrame
	sound(script.Parent.Click.Sound,sounds[1],1.5,.5)
	Player.Character.Humanoid.WalkSpeed = 16
	Player.Character.Humanoid.JumpPower = 50
	if otherPhone then
		if otherPhone.Data.Active.Value then
			message(otherPhone,"[LINE DISCONNECTED]")
		end
		if otherPhone.Data.Ringing.Value then
			otherPhone.Data.Ringing.Value = false
			otherPhone.Click.Ringing:Stop()
		end
		otherPhone = nil
	end
	data.IncomingNumber.Value = 0
	data.Active.Value = false
end
function pickUp(Player)
	if not data.Ringing.Value then
		data.Active.Value = true
		sound(script.Parent.Click.Sound,sounds[1],0,.5)
		script.Parent.Phone.PrimaryPart.CFrame = Player.Character.Head.CFrame * CFrame.new(.8,-.274,-.6) * 
CFrame.Angles(math.rad(10.29),math.rad(91.49),math.rad(-60.56))
		newWeld = Instance.new("WeldConstraint")
		newWeld.Parent = Player.Character.Head
		newWeld.Part0 = script.Parent.Phone.PrimaryPart
		newWeld.Part1 = Player.Character.Head
		message(script.Parent,"[DIAL NUMBER]")
		Player.Character.Humanoid.WalkSpeed = 0
		Player.Character.Humanoid.JumpPower = 0
		local dialNum = Player.Chatted:Wait()
		otherPhone = findPhone(dialNum,true)
		while not otherPhone do
			if not data.Active.Value then
				break
			end
			message(script.Parent,"[NUMBER NOT FOUND OR BUSY, DIAL AGAIN]")
			dialNum = Player.Chatted:Wait()
			otherPhone = findPhone(dialNum,true)
		end
		otherPhone.Data.Ringing.Value = true
		otherPhone.Data.IncomingNumber.Value = number
		otherPhone.Click.Ringing:Play()
		call(Player)
	else
		data.Active.Value = true
		data.Ringing.Value = false
		sound(script.Parent.Click.Sound,sounds[1],0,.5)
		script.Parent.Click.Ringing:Stop()
		script.Parent.Phone.PrimaryPart.CFrame = Player.Character.Head.CFrame * CFrame.new(.8,-.274,-.6) * 
CFrame.Angles(math.rad(10.29),math.rad(91.49),math.rad(-60.56))
		newWeld = Instance.new("WeldConstraint")
		newWeld.Parent = Player.Character.Head
		newWeld.Part0 = script.Parent.Phone.PrimaryPart
		newWeld.Part1 = Player.Character.Head
		otherPhone = findPhone(data.IncomingNumber.Value,false)
		call(Player)
	end
end

script.Parent.Click.ClickDetector.MouseClick:Connect(function(Player)
	if not data.Active.Value then
		pickUp(Player)
	elseif data.Active.Value then
		disconnect(Player)
	end
end)

