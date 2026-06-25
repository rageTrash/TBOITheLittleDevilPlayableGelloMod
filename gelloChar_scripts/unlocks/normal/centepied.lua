local Mod = GelloCharMod
local game = Mod.Game
local pSave = Mod.SaveHandler.Player
local SFX = Mod.SFX

local pTools = Mod.PlayerTools

local SPAWN_MULT = 4
local SEGMENT_DISTANCE = 12
local MIN_NUM = 4

local DIVIDED = 3
local RAD = 360 / DIVIDED


local function generateStatesTable(num)
	local tab = {}
	for i=1, num do
		tab[i] = 0
	end
	return tab
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

local function GetSpawnPos(spawner)
	local data = Mod:GetEntityData(spawner, "Centepied_SpawnData")
	if data == nil or data.Size ~= spawner.Size then
		data = {}
		data.Size = spawner.Size
		local pos = math.max(SPAWN_MULT * data.Size, 30)
		data.Pos = Vector(0,  pos)

		Mod:SetEntityData(spawner, "Centepied_SpawnData", data)
	end
	return data.Pos
end

local function GetAngleStr(effect)
	local spawner = effect.SpawnerEntity
	if not spawner then
		return "S"
	end
	local angle = (effect.Position - spawner.Position):Normalized():GetAngleDegrees()


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


local function UpdateCentepiedAmount(ent)
	local data = Mod:GetCentepiedData(ent)
	local num = data and not data.IsBroken and data.Num or 0
	local ptr = GetPtrHash(ent)
	local head

	for _, e in ipairs(Isaac.FindByType(1000, Mod.Enum.Effect.CENTEPIED, 0)) do
		local spawner = e.SpawnerEntity
		if e and e.Child ~= nil and e.Parent == nil and spawner and GetPtrHash(spawner) == ptr then
			head = e
			break
		end
	end

	if not head then
		if num > MIN_NUM then
			local spawnPos = GetSpawnPos(ent)
			head = Mod:Spawn(1000, Mod.Enum.Effect.CENTEPIED, 0, spawnPos, Vector.Zero, ent)
			head:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			head:ToEffect().State = data.States and data.States[1] or 0

			local sp = head:GetSprite()
			sp:Play("Head0S", true)
			sp:SetFrame(4)

		else return end
	end
	local tab = { head }
	local child = head.Child
	while child do
		table.insert(tab, child)
		child = child.Child
	end

	if #tab < num then
		local tail = tab[#tab]
		local dir = GetAngleStr(tail)
		local pos = tail.Position
		for i = #tab+1, num do
			local newTail = Mod:Spawn(1000, Mod.Enum.Effect.CENTEPIED, 1, pos, Vector.Zero, ent)
			tail.Child = newTail
			newTail.Parent = tail
			tail = newTail

			data.States[i] = data.States and data.States[i] or 0

			local sp = tail:GetSprite()
			sp:Play("Body0"..dir, true)
			sp:SetFrame((i % 2) * 4)

			tail:ToEffect().State = data.States[i]
			tail:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end

	elseif #tab > num then
		for i = #tab, num+1, -1 do
			tab[i]:Remove()
		end
	end

	if #data.States > num then
		for i = #data.States, num+1, -1 do
			table.remove(data.States, i)
		end
	end
	
	Mod:SetCentepiedData(ent, data)
end

function GelloCharMod:GiveCentepiedShield(ent, num)
	if ent and (ent:ToNPC() or ent:ToPlayer()) and num > MIN_NUM then
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



Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = Mod:GetCentepiedData(player)
	if data ~= nil and (player.Variant > 0 or not player:HasCollectible(Mod.Enum.Item.CENTEPIED)) then
		Mod:RemoveCentepiedShield(player)

	elseif data == nil and player.Variant == 0 and player:HasCollectible(Mod.Enum.Item.CENTEPIED) then
		Mod:GiveCentepiedShield(player, 10)
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local spawner = effect.SpawnerEntity
	if spawner == nil then
		effect:Remove()
		return
	end
	if effect.State == nil then effect.State = 0 end

	local stateChange = false
	local partition
	if spawner:ToPlayer() then
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

	local pos = Mod:GetEntityData(effect, "Pos")
	if pos == nil or pos <0 then
		pos = 0
		local parent = effect.Parent
		while parent do
			pos = pos+1
			parent = parent.Parent
		end
		Mod:SetEntityData(effect, "Pos", pos)
	end

	if effect.State > 3 then
		local child = effect.Child
		if effect.Parent then
			effect.Parent.Child = child
		end
		if child then
			child.Parent = effect.Parent
			if effect.SubType == 0 then
				if child then child.SubType = 0 end
			end
			while child do
				Mod:SetEntityData(child, "Pos", Mod:GetEntityData(child, "Pos", 0)-1)
				local sp = child:GetSprite()
				sp:SetFrame((sp:GetFrame() +4) % 8)
				child = child.Child
			end
		end

		local data = Mod:GetCentepiedData(spawner)
		if data then

			data.IsBroken = data.Num <= MIN_NUM
			data.Num = data.Num -1
			if data.States[pos+1] == nil then
				print("try removing "..pos.." but is nil")
			else
				table.remove(data.States, pos+1)
			end
			Mod:SetCentepiedData(spawner, data)

			if data.IsBroken then
				UpdateCentepiedAmount(spawner)
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

		local data = Mod:GetCentepiedData(spawner)
		if data then
			data.States[pos+1] = effect.State
			Mod:SetCentepiedData(spawner, data)
		end
		if effect:GetDropRNG():RandomInt(2) == 0 then
			SFX:Play(SoundEffect.SOUND_BONE_BREAK, 0.5, nil, false, 0.75)
		else
			SFX:Play(SoundEffect.SOUND_FORTUNE_COOKIE, 0.5, nil, false, 0.8)
		end
	end


	local sp = effect:GetSprite()
	local anim
	if effect.SubType == 0 then
		anim = "Head"
	--elseif effect.Child == nil then
	--	anim = "Tail"
	else
		anim = "Body"
	end
	anim = anim..tostring(effect.State) .. GetAngleStr(effect)

	if not sp:IsPlaying(anim) then
		sp:SetAnimation(anim, false)
	end

	if effect.Parent then
		local parentPos = effect.Parent.Position
		local head = effect:GetLastParent()
		if head then
			effect.Position = GetSpawnPos(spawner):Rotated( (head.FrameCount % RAD *DIVIDED) - SEGMENT_DISTANCE *pos ) + spawner.Position + spawner.Velocity
		end
	else
		effect.Position = GetSpawnPos(spawner):Rotated( effect.FrameCount % RAD *DIVIDED ) + spawner.Position + spawner.Velocity
	end
end, Mod.Enum.Effect.CENTEPIED)


local function ResetCentepied(player)
	if player:HasCollectible(Mod.Enum.Item.CENTEPIED) then
		local data = Mod:GetCentepiedData(player)
		if not data then return end

		data.Num = data.OgNum
		data.IsBroken = false
		data.States = generateStatesTable(data.OgNum)
		local ptr = GetPtrHash(player)

		UpdateCentepiedAmount(player)

		for _, ent in ipairs(Isaac.FindByType(1000, Mod.Enum.Effect.CENTEPIED, -1)) do
			local spawner = ent.SpawnerEntity
			if ent and spawner and GetPtrHash(spawner) == ptr then
				ent:ToEffect().State = 0
			end
		end
		Mod:SetCentepiedData(player, data)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() pTools.ForEach(ResetCentepied) end)


local function ResyncCentepied(player) if player:HasCollectible(Mod.Enum.Item.CENTEPIED) then UpdateCentepiedAmount(player) end end
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function() pTools.ForEach(ResyncCentepied) end)