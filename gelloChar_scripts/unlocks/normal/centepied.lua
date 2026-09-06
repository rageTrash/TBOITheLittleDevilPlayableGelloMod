local Mod = GelloCharMod
local game = Mod.Game
local pSave = Mod.SaveHandler.Player
local SFX = Mod.SFX

local pTools = Mod.PlayerTools

local SPAWN_MULT = 2
local SEGMENT_DISTANCE = 12
local MIN_NUM = 4

local DIVIDED = 3
local RAD = 720


local function generateStatesTable(num)
	local tab = {}
	for i=1, num do
		tab[i] = 0
	end
	return tab
end


local function GetAngleStr(effect)
	local parent = effect.Parent
	if not parent then
		return "S"
	end
	local angle = (effect.Position - parent.Position):Normalized():GetAngleDegrees()


	if angle <= 22.5 and angle >= -22.5 then
		return "E"
	elseif angle <= -67.5 and angle >= -112.5 then
		return "N"
	elseif angle >= 67.5 and angle <= 112.5 then
		return "S"
	elseif angle >= 157.5 or angle <= -157.5 then
		return "W"
	elseif angle > -67.5 and angle < -22.5 then
		return "NE"
	elseif angle > -157.5 and angle < -112.5 then
		return "NW"
	elseif angle > 22.5 and angle < 67.5 then
		return "SE"
	elseif angle > 112.5 and angle < 157.5 then
		return "SW"
	end
end



local function UpdateCentepiedAmount(ent, fullClear)
	local data = Mod:GetCentepiedData(ent)
	if data == nil then return end

	local num = not data.IsBroken and data.Num or 0
	local ptr = GetPtrHash(ent)
	local tab = {}

	if fullClear or data.IsBroken then
		for _, e in ipairs(Isaac.FindByType(1000, Mod.Enum.Effect.CENTEPIED)) do
			if GetPtrHash(e.Parent) == ptr then
				e:Remove()
			end
		end
	else
		for _, e in ipairs(Isaac.FindByType(1000, Mod.Enum.Effect.CENTEPIED)) do
			if e:Exists() and GetPtrHash(e.Parent) == ptr then
				tab[e.SubType +1] = e:ToEffct()
			end
		end

		for i=1, #tab do -- clamping the sections
			
			if tab[i] == nil then
				for x=i+1, #tab do
					if tab[x] ~= nil then
						local section = tab[x]
						section.SubType = i +1
						tab[i] = section
						tab[x] = nil
						break
					end
				end
			end
		end
		if #tab > 200 then
			for i= #tab, 201, -1 do
				tab[i]:Remove()
				tab[i] = nil
			end
		end
	end

	if #tab == 0 and num > MIN_NUM then
		local spawnPos = Vector(0,math.max(SPAWN_MULT * ent.Size, 40)):Rotated(ent.FrameCount *DIVIDED) * ent.SizeMulti
		local head = Mod:Spawn(1000, Mod.Enum.Effect.CENTEPIED, 0, spawnPos, Vector.Zero, ent)
		head:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		head:ToEffect().State = data.States and data.States[0] or 0
		head:ToEffect():FollowParent(ent)

		local sp = head:GetSprite()
		sp:Play("Head0"..GetAngleStr(head) , true)
		sp:SetFrame(4)

		tab[1] = head
	else return end
	
	if #tab < num then
		local tail = tab[#tab]
		local dir = GetAngleStr(tail)
		local pos = tail.Position
		for i = #tab, num do
			local newTail = Mod:Spawn(1000, Mod.Enum.Effect.CENTEPIED, i, pos, Vector.Zero, ent):ToEffect()
			newTail:FollowParent(ent)

			data.States[i +1] = data.States and data.States[i +1] or 0
			
			local sp = newTail:GetSprite()
			sp:Play("Body".. data.States[i +1] ..dir, true)
			sp:SetFrame((i % 2) * 4)

			newTail.State = data.States[i +1]
			newTail:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			tab[i +1] = newTail
		end

	elseif #tab > num then
		for i = #tab, num+1, -1 do
			tab[i]:Remove()
			tab[i] = nil
		end
	end
	
	Mod:SetEntityData(ent, "Centepied entlist", tab)

	if #data.States > num then
		for i = #data.States, num+1, -1 do
			table.remove(data.States, i)
		end
	end
	
	Mod:SetCentepiedData(ent, data)
end

function GelloCharMod:GetCentepiedData(ent)
	if ent and (ent:ToNPC() or ent:ToPlayer()) then
		if ent:ToPlayer() then
			return pSave("Centepied_Data", ent:ToPlayer()):Get(nil)
		else
			return Mod:GetEntityData(ent, "Centepied_Data", nil)
		end
	end
end

function GelloCharMod:SetCentepiedData(ent, data)
	if ent and (ent:ToNPC() or ent:ToPlayer()) then
		if ent:ToPlayer() then
			local player = ent:ToPlayer()
			local sData = pSave("Centepied_Data", player):Get(nil)

			pSave("Centepied_Data", player):Set({
				IsBroken = data.IsBroken or sData and sData.IsBroken,
				Num = data.Num or sData and sData.Num,
				OgNum = data.OgNum or sData and sData.OgNum,
				States = data.States or sData and sData.States,
			})
		else
			local entData = Mod:GetEntityData(ent, "Centepied_Data", nil)
			Mod:SetEntityData(ent, "Centepied_Data", {
				IsBroken = data.IsBroken or entData and entData.IsBroken,
				Num = data.Num or entData and entData.Num,
				OgNum = data.OgNum or entData and entData.OgNum,
				States = data.States or entData and entData.States,
			})
		end
	end
end

function GelloCharMod:RemoveCentepiedShield(ent)
	if ent and (ent:ToNPC() or ent:ToPlayer()) then
		if ent:ToPlayer() then
			pSave("Centepied_Data", ent:ToPlayer()):Set(nil)
		else
			Mod:SetEntityData(ent, "Centepied_Data", nil)
		end
		UpdateCentepiedAmount(ent)
	end
end

--- give centepied shield is below all this local functions
function GelloCharMod:GiveCentepiedShield(ent, num)
	if ent and (ent:ToNPC() or ent:ToPlayer()) and num > MIN_NUM then
		num = math.min(num, 200)
		local data = Mod:GetCentepiedData(ent)
		if data then
			data.IsBroken = false
			if num > data.OgNum then
				data.OgNum = num
				data.Num = num
				for i = #data.States, num do
					data.States[i] = 0
				end
			else
				data.Num = math.min(data.OgNum, data.Num + num)
				for i = #data.States, data.Num do
					data.States[i] = 0
				end
			end
			Mod:SetCentepiedData(ent, data)
		else
			Mod:SetCentepiedData(ent, {
				IsBroken = false,
				Num = num,
				OgNum = num,
				States = generateStatesTable(num),
			})
		end
		UpdateCentepiedAmount(ent)
		return true
	end
	return false
end


local function setUpSection(section, idx)
	local sp = section:GetSprite()
	sp:SetFrame((sp:GetFrame() +4) % 8)
	section.SubType = idx -1
end


Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = Mod:GetCentepiedData(player)
	if data ~= nil and (player.Variant > 0 or not player:HasCollectible(Mod.Enum.Item.CENTEPIED)) then
		Mod:RemoveCentepiedShield(player)

	elseif data == nil and player.Variant == 0 and player:HasCollectible(Mod.Enum.Item.CENTEPIED) then
		Mod:GiveCentepiedShield(player, 10)
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local parent = effect.Parent
	if parent == nil or parent:IsDead() or not parent:Exists() then
		effect:Remove()
		return
	end
	if effect.State == nil then effect.State = 0 end

	local stateChange = false
	local partition
	if parent:ToPlayer() then
		partition = EntityPartition.BULLET
	else
		partition = EntityPartition.TEAR
	end
	for _, proj in pairs(Isaac.FindInRadius(effect.Position, 10, partition)) do
		proj:Die()
		if effect:GetDropRNG():RandomInt(5) > 1 then -- 40% to not break
			effect.State = effect.State +1
			stateChange = true
		end
	end

	local centList = Mod:GetEntityData(parent, "Centepied entlist")
	if centList == nil then
		effect:Remove()
		return
	end
	local pos = effect.SubType +1
	if centList[pos] == nil then
		Mod:Error("Centepied Item - centepied section [".. pos.."] was not in the list" , 0, true)
		effect:Remove()
		return
	elseif GetPtrHash(centList[pos]) ~= GetPtrHash(effect) then
		if not centList[pos]:Exists() then
			Mod:Error("Centepied Item - centepied section [".. pos.."] is sharing positions and replace it" , 0, true)
			centList[pos] = effect
		else
			Mod:Error("Centepied Item - centepied section [".. pos.."] is sharing positions" , 0, true)
			effect:Remove()
			return
		end
	end

	if effect.State > 3 then
		for idx = pos, #centList -1 do
			local section = centList[idx +1]
			if section and section:Exists() then
				setUpSection(section, idx)
				centList[idx] = section
			else
				if section ~= nil then section:Remove() end

				for x= idx +1, #centList -1 do -- looking for a valid section
					local sec = centList[x +1]
					if sec and sec:Exists() then
						setUpSection(sec, idx)
						centList[idx] = sec
						centList[x +1] = nil
					else
						if sec ~= nil then sec:Remove() end
						centList[x +1] = nil
					end
				end
			end
		end
		centList[#centList] = nil


		local data = Mod:GetCentepiedData(parent)
		if data then

			data.IsBroken = data.Num <= MIN_NUM
			data.Num = data.Num -1
			if data.States[pos] == nil then
				Mod:Error("Centepied Item - try removing "..pos.." but is nil" , 0, true)
			else
				table.remove(data.States, pos)
			end
			Mod:SetCentepiedData(parent, data)

			if data.IsBroken then
				UpdateCentepiedAmount(parent)
			end
		end
		if effect:GetDropRNG():RandomInt(2) == 0 then
			SFX:Play(SoundEffect.SOUND_BONE_SNAP, 0.75, nil, false, 0.8)
		else
			SFX:Play(SoundEffect.SOUND_SHOVEL_DIG, 0.75, nil, false, 0.8)
		end
		SFX:Play(SoundEffect.SOUND_BONE_BREAK)

		effect:Remove()
		return
	elseif stateChange then

		local data = Mod:GetCentepiedData(parent)
		if data then
			data.States[pos] = effect.State
			Mod:SetCentepiedData(parent, data)
		end
		if effect:GetDropRNG():RandomInt(2) == 0 then
			SFX:Play(SoundEffect.SOUND_BONE_BREAK, 0.5, nil, false, 0.75)
		else
			SFX:Play(SoundEffect.SOUND_FORTUNE_COOKIE, 0.5, nil, false, 0.8)
		end
	end


	local sp = effect:GetSprite()
	local anim
	if pos == 1 then
		anim = "Head"
	--elseif effect.Child == nil then
	--	anim = "Tail"
	else
		anim = "Body"
	end
	anim = anim..tostring(effect.State) .. GetAngleStr(effect)
	sp:Play(anim)

	local size = math.max(SPAWN_MULT * parent.Size, 40)
	local mult = 40 / size
	effect.ParentOffset =  Vector(0,size):Rotated( (parent.FrameCount *DIVIDED - SEGMENT_DISTANCE * (pos-1)) *mult ) * parent.SizeMulti

end, Mod.Enum.Effect.CENTEPIED)


local function ResetCentepied(player)
	if player:HasCollectible(Mod.Enum.Item.CENTEPIED) then
		local data = Mod:GetCentepiedData(player)
		if not data then return end

		data.Num = data.OgNum
		data.IsBroken = false
		data.States = generateStatesTable(data.OgNum)
		Mod:SetCentepiedData(player, data)

		UpdateCentepiedAmount(player, true)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() pTools.ForEach(ResetCentepied) end)


local function ResyncCentepied(player) if player:HasCollectible(Mod.Enum.Item.CENTEPIED) then UpdateCentepiedAmount(player) end end
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() pTools.ForEach(ResyncCentepied) end)