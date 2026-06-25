local Mod = GelloCharMod
local game = Mod.Game
local sfx = Mod.SFX

local playerSave = Mod.SaveHandler.Player

local MAX_TEMP_DMG = 300 -- 7.5 dmg
local BITE_RADIUS = 50
local GORE_AMOUNT = 4

local validPlayerTypes = {
	[Mod.Enum.Character.GELLO] = true,
	[Mod.Enum.Character.GELLO_B1] = true,
}

--local flashColor = Color(1,1,1,1, 0.5, 0.25, 0.25)
local biteSize = Vector(1, 1)
local gelloBiteSize = Vector(1.5, 1.5)

local function canDamageEntity(ent)
	return ent:IsVisible() and ent:IsVulnerableEnemy() and Mod:CanTargetEntity(ent)
end


local function angleAngle(player, vec)
	local angle = (vec:GetAngleDegrees()+360) %360
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		if angle >= 22.5 and angle <= 67.5 then
			return -45
		elseif angle > 67.5 and angle < 112.5 then
			return 0
		elseif angle >= 112.5 and angle <= 157.5 then
			return 45
		elseif angle > 157.5 and angle < 202.5 then
			return 90
		elseif angle >= 202.5 and angle <= 247.5 then
			return 135
		elseif angle > 247.5 and angle < 292.5 then
			return 180
		elseif angle >= 292.5 and angle <= 337.5 then
			return -135
		end
		return -90
	end

	if angle > 45 and angle < 135 then
		return 0
	elseif angle >= 135 and angle <= 225 then
		return 90
	elseif angle > 225 and angle < 315 then
		return 180
	end
	return -90
end

local function GetAngle(player)
	return angleAngle(player, player:GetAimDirection())
end


local function GetAngleAlt(player)
	local shot = player:GetAimDirection()
	if shot:Length() == 0 then
		local dir = player:GetHeadDirection()
		if dir == Direction.LEFT then
			return 90
		elseif dir == Direction.UP then
			return 180
		elseif dir == Direction.RIGHT then
			return -90
		end
		return 0
	end
	return angleAngle(player, shot, true)
end


local GibRNG = RNG()
local GibVel = Vector(16, 0)
local function GenerateGore(seed, pos, angle, amount)
	GibRNG:SetSeed(seed, 35)

	for i=1, amount do
		Mod:Spawn( 1000, EffectVariant.BLOOD_PARTICLE, GibRNG:RandomInt(3), pos, ( Vector(Mod:RandomInt( 10, 16, GibRNG), 0) ):Rotated( angle + Mod:RandomInt( -7, 7, GibRNG) ) )
	end

	if amount > GORE_AMOUNT then
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1.1, 1, false)
		sfx:Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH, 0.66, 1, false)
	else
		sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 0.8, 1, false)
	end
end


local function clearBiteData(tab, player)
	local giveTemDmg = 0
	local addDmg = 20 -- 0.5 dmg
	if player:GetPlayerType() == Mod.Enum.Character.GELLO and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		addDmg = 30 -- 0.75 dmg
	end
	for _, data in ipairs(tab) do
		if giveTemDmg >= MAX_TEMP_DMG then break end
		local ent = data.E
		if not ent or not ent:Exists() or ent:IsDead() then
			giveTemDmg = giveTemDmg + addDmg
			if data.Overkill then GenerateGore(data.InitSeed, data.Pos, data.Angle, GORE_AMOUNT *2)
			else GenerateGore(data.InitSeed, data.Pos, data.Angle, GORE_AMOUNT) end
		end
	end

	if giveTemDmg > 0 then
		local itemEffect = player:GetEffects()
		local dmg = itemEffect:GetCollectibleEffectNum(Mod.Enum.Item.TEMP_DMG)

		if dmg > MAX_TEMP_DMG then
		elseif dmg + giveTemDmg > MAX_TEMP_DMG then giveTemDmg = MAX_TEMP_DMG
		else giveTemDmg = dmg + giveTemDmg end

		itemEffect:AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG, false, giveTemDmg - dmg)
	end
end

local function doBiting(player, shotAngle)
	local e = Mod:Spawn(1000, Mod.Enum.Effect.BITE, 0, player.Position, Vector.Zero, player):ToEffect()
	local sp = e:GetSprite()

	if Mod.GetSetting("FriendlyBiteAltMode") then
		sp.Rotation = shotAngle
	else
		-- if the player is still aiming we take the current aim else the og aim
		-- this is to make aim diagonaly easier
		if player:GetAimDirection():Length() > 0 then
			sp.Rotation = GetAngle(player)
		else
			sp.Rotation = shotAngle
		end
	end

	local pType = player:GetPlayerType()
	local isTaintedGello = Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B1

	if pType == Mod.Enum.Character.GELLO and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		sp.Scale = gelloBiteSize
	else
		sp.Scale = biteSize
	end

	if not Mod.GetSetting("FriendlyBiteAltMode") then
		if (pType == Mod.Enum.Character.GELLO or isTaintedGello) and player:HasCollectible(Mod.Enum.Item.FRIENDLY_BITE) then
			Mod:SetEntityData(player, "Friendly Bite Cooldown", game:GetFrameCount() +75)
		else
			Mod:SetEntityData(player, "Friendly Bite Cooldown", game:GetFrameCount() +150)
		end
	end
end



Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player.Variant ~= 0 then return end
	if Mod.GetSetting("FriendlyBiteAltMode") then return end
	local flashData = Mod:GetEntityData(player, "Friendly Bite Flash")
	if flashData then
		if game:GetFrameCount() <= flashData then
			local color = player.Color
			color:SetColorize(1.5, 0.5, 0.5, (flashData - game:GetFrameCount() +1) /2)
			player.Color = color
		else
			local color = player.Color
			color:SetColorize(0, 0, 0, 0)
			player.Color = color
			Mod:SetEntityData(player, "Friendly Bite Flash", nil)
		end
	end

	if (validPlayerTypes[Mod:GetGlitchClassCopyAbility(player)] or player:HasCollectible(Mod.Enum.Item.FRIENDLY_BITE)) and player:IsExtraAnimationFinished() and not player:IsHoldingItem() then
		local cool = Mod:GetEntityData(player, "Friendly Bite Cooldown", -1)
		
		if cool == -1 then
			local tapData = Mod:GetEntityData(player, "Friendly Bite DoubleTap", {})
			local isAiming = player:GetAimDirection():Length() > 0.24 -- small offset for controllers (i dont have a controller so idk if it does something)
			local dir = player:GetFireDirection()

			if isAiming ~= tapData.PrevAimState then

				if dir >= 0 and tapData.HasPaused and isAiming and tapData.LastDirPress and tapData.LastDirPress == dir and tapData.LastTimePress and game:GetFrameCount() <= tapData.LastTimePress then

					sfx:Play(Mod.Enum.Sound.BITE, 1, 0, false, Mod:RandomFloat(0.74, 1, player:GetCollectibleRNG(Mod.Enum.Item.FRIENDLY_BITE) ))
					player.FireDelay = player.FireDelay +4
					Mod:RunLater(2, doBiting, player, GetAngle(player))
					Mod:SetEntityData(player, "Friendly Bite DoubleTap", nil)
				else
					Mod:SetEntityData(player, "Friendly Bite DoubleTap", nil)
				end

				if dir >= 0 then
					tapData.LastDirPress = dir
					tapData.LastTimePress = game:GetFrameCount() +7
				end

				tapData.HasPaused = tapData.PrevAimState == true and isAiming == false
				tapData.PrevAimState = isAiming

				Mod:SetEntityData(player, "Friendly Bite DoubleTap", tapData)
			end

		elseif cool ~= -1 and game:GetFrameCount() >= cool then
			Mod:SetEntityData(player, "Friendly Bite Flash", game:GetFrameCount()+2)
			sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 0.666)

			Mod:SetEntityData(player, "Friendly Bite Cooldown", -1)
		end
	end
end)


Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 400, function(_, ent)
	if Mod.GetSetting("FriendlyBiteAltMode") then return end
	local player = ent:ToPlayer()
	if player and (validPlayerTypes[Mod:GetGlitchClassCopyAbility(player)] or player:HasCollectible(Mod.Enum.Item.FRIENDLY_BITE)) then
		if Mod:GetEntityData(player, "Friendly Bite Cooldown", -1) < 0 then return end
		
		Mod:SetEntityData(player, "Friendly Bite Flash", game:GetFrameCount()+2)
		sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 0.666)

		Mod:SetEntityData(player, "Friendly Bite Cooldown", -1)
	end
end, 1)


Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local sp = effect:GetSprite()
	if sp:IsFinished() then effect:Remove() end
	if not sp:IsPlaying("Bite") then sp:Play("Bite", true) end

	if effect.FrameCount == 2 then
		local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
		if player then
			local dmg = player.Damage * 1.5
			local mult = 1
			if player:GetPlayerType() == Mod.Enum.Character.GELLO and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				mult = 1.5
			elseif Mod:GetGlitchClassCopyAbility(player) == Mod.Enum.Character.GELLO_B1 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					mult = 1.6666
				else
					mult = 1.15
				end
			end
			dmg = dmg + Mod.LevelTools.GetLevelsTravel() *0.5
			dmg = dmg *mult

			local radius = (BITE_RADIUS * mult)
			local biteOffset = Vector(0, (player.Size + radius /2) * mult)

			local entTab = Isaac.FindInRadius(effect.Position + (biteOffset:Rotated(sp.Rotation)), radius, EntityPartition.ENEMY )
			local bitPos = effect.Position
			
			local entDataTab = {}
			for _, e in ipairs(entTab) do
				if canDamageEntity(e) then
					e:TakeDamage(dmg, 0, EntityRef(effect), 0)
					table.insert(entDataTab, {E = e, Pos = e.Position, Overkill = e.MaxHitPoints < dmg, Angle = (e.Position - bitPos):GetAngleDegrees(), InitSeed = e.InitSeed })
				end
			end

			if Mod.GetSetting("GelloFamiliarConsumeType") == 2 and player:GetPlayerType() == Mod.Enum.Character.GELLO then
				local gelloPos = player.Position
				local prevDist = 99999999
				local pickup
				for _, e in ipairs(Isaac.FindInRadius(effect.Position + (biteOffset:Rotated(sp.Rotation)), radius, EntityPartition.PICKUP )) do
					local p = e:ToPickup()
					if p.Variant == 100 then
						if pickup == nil or p.Position:Distance(gelloPos) < prevDist then
							pickup = p
							prevDist = p.Position:Distance(gelloPos)
						end
					end
				end
				if pickup then
					Mod:GelloTryConsumePickup(player, pickup)
				end
			end

			Mod:RunLater(1, clearBiteData, entDataTab, player)
		end
	end
end, Mod.Enum.Effect.BITE)



Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags, slot)
	if flags & UseFlag.USE_CARBATTERY > 0 then return end
	sfx:Play(Mod.Enum.Sound.BITE, 1, 0, false, Mod:RandomFloat(0.74, 1, player:GetCollectibleRNG(Mod.Enum.Item.FRIENDLY_BITE_ALT) ))
	Mod:RunLater(2, doBiting, player, GetAngleAlt(player))

	return false
end, Mod.Enum.Item.FRIENDLY_BITE_ALT)
