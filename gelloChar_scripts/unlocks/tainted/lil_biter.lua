local Mod = GelloCharMod
local game = Mod.Game
local sfx = Mod.SFX

local pTools = Mod.PlayerTools
local fTools = Mod.FamiliarTools

local config = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.LIL_BITER)

local BITE_SPRITE_SCALE = Vector(0.8, 0.8)
local BFFS_BITE_SPRITE_SCALE = Vector(1, 1)
local BITE_RADIUS = 40
local BFFS_BITE_RADIUS = 50
local FIRE_COOLDOWN = 75


local State = {
	IDLE = 0,
	STARE = 1,
	BITE = 2
}



local function getSideAnim(fam, targetPos)
	local angle = ((targetPos - fam.Position):GetAngleDegrees()+360) %360

	if angle > 45 and angle < 135 then
		return "Down"
	elseif angle >= 135 and angle <= 225 then
		return "Left"
	elseif angle > 225 and angle < 315 then
		return "Up"
	end
	return "Right"
end


local function TEST_TARGET(target, clear)
	local color = target.Color
	if clear then
		color:SetColorize(0, 0, 0, 0)
	else
		color:SetColorize(2, 0, 0, 1)
	end
	target.Color = color
end

local function canDamageEntity(ent)
	return ent:IsVisible() and ent:IsVulnerableEnemy() and Mod:CanTargetEntity(ent)
end

local function clearBiteData(tab, fam)
	local giveTemDmg = 0
	local addDmg = 14 -- 0.35 dmg

	for _, ent in ipairs(tab) do
		if giveTemDmg >= MAX_TEMP_DMG then break end
		if not ent or not ent:Exists() or ent:IsDead() then
			giveTemDmg = giveTemDmg + addDmg
		end
	end

	fam.Coins = fam.Coins + giveTemDmg
end

local function doBiting(fam, targetPos)
	local e = Mod:Spawn(1000, Mod.Enum.Effect.BITE, 0, fam.Position, Vector.Zero, fam):ToEffect()
	local sp = e:GetSprite()

	local BFFS = fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
	local biteRad = BFFS and BFFS_BITE_RADIUS or BITE_RADIUS

	sp.Rotation = (targetPos - fam.Position):GetAngleDegrees() -90
	local biteOffset = Vector(0, fam.Size + biteRad/2)
	
	local dmg = 5 + (fam.Coins *0.025)
	sfx:Play(Mod.Enum.Sound.BITE, 1, 0, false, Mod:RandomFloat(0.74, 1, fam:GetDropRNG() ))

	if BFFS then
		dmg = dmg *2
		sp.Scale = BFFS_BITE_SPRITE_SCALE
	else sp.Scale = BITE_SPRITE_SCALE end

	local checkPartition = EntityPartition.ENEMY
	if fTools.IsCharmBySiren(fam) then
		dmg = 1
		checkPartition = EntityPartition.PLAYER
	end

	local entDataTab = {}
	for _, e in ipairs(Isaac.FindInRadius(fam.Position + (biteOffset:Rotated(sp.Rotation)), biteRad, checkPartition)) do
		if canDamageEntity(e) then
			e:TakeDamage(dmg, 0, EntityRef(fam), 30)
			table.insert(entDataTab, e)
		end
	end
	Mod:RunLater(1, clearBiteData, entDataTab, fam)
end



Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)

	player:CheckFamiliar(Mod.Enum.Familiar.LIL_BITER,
		player:GetCollectibleNum(Mod.Enum.Item.LIL_BITER) + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.LIL_BITER),
		player:GetCollectibleRNG(Mod.Enum.Item.LIL_BITER),
		config)
end, CacheFlag.CACHE_FAMILIARS)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam:AddToFollowers()
	fam.State = State.IDLE
	fam.FireCooldown = FIRE_COOLDOWN
end, Mod.Enum.Familiar.LIL_BITER)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local sp = fam:GetSprite()
	local checkPartition = EntityPartition.ENEMY

	local fireCooldown = fam.FireCooldown
	if fTools.IsCharmBySiren(fam) then
		if fam.Target and not fam.Target:ToPlayer() then fam.Target = nil end
		checkPartition = EntityPartition.PLAYER
		if fireCooldown > 0 then
			fam.FireCooldown = fireCooldown -1
		end
	elseif fireCooldown > 0 then
		if fam.Player and fam.Player:HasTrinket(141) then
			fam.FireCooldown = fireCooldown -2
		else
			fam.FireCooldown = fireCooldown -1
		end
	end
	local state = fam.State


	if state == State.BITE then
		if sp:IsFinished() then
			sp:Play("IdleDown", true)
			fam.State = State.IDLE
		end
	else
		local anim = "Idle"
		if fam.Target then
			anim = anim..getSideAnim(fam, fam.Target.Position)
		else
			anim = anim.."Down"
		end
		sp:SetAnimation(anim, false)
	end


	local famPos = fam.Position
	if state == State.IDLE and fam.Target == nil then
		if fam:IsFrame(3, 0) then
			local target
			local distance = 0
			for _, e in ipairs(Isaac.FindInRadius(famPos, 160, checkPartition)) do
				local enemyPos = e.Position:Distance(famPos)
				if canDamageEntity(e) and (not target or distance > enemyPos) then
					target = e
					distance = enemyPos
				end
			end
			--if target then TEST_TARGET(target) end

			fam.Target = target
			fam.State = State.STARE
		end
	elseif state == State.STARE then
		if fam.Target == nil then
			fam.State = State.IDLE
			return
		end
		if fam:IsFrame(10, 0) then
			local checkVeryCloseEnemies = Isaac.FindInRadius(famPos, 100, checkPartition)
			if #checkVeryCloseEnemies > 0 then
				local target
				local distance = 0
				for _, e in ipairs(checkVeryCloseEnemies) do
					local enemyPos = e.Position:Distance(famPos)
					if canDamageEntity(e) and (not target or distance > enemyPos) then
						target = e
						distance = enemyPos
					end
				end
				if target then
					--if GetPtrHash(target) ~= GetPtrHash(fam.Target) then TEST_TARGET(target); TEST_TARGET(fam.Target, true) end

					fam.Target = target
				end
			end
		end
		if fam.FireCooldown <= 0 then
			if fam.Target.Position:Distance(famPos) <= 50 then
				doBiting(fam, fam.Target.Position)

				fam.FireCooldown = FIRE_COOLDOWN
				fam.State = State.BITE
				sp:Play("Bite"..getSideAnim(fam, fam.Target.Position), true)
			end

		elseif fam.Target.Position:Distance(famPos) >= 240 or not canDamageEntity(fam.Target) then
			--TEST_TARGET(fam.Target, true)

			fam.Target = nil
			fam.State = State.IDLE
		end
	elseif state == State.IDLE and fam.Target ~= nil then
		fam.State = State.STARE
	elseif state ~= State.BITE then
		fam.State = State.IDLE
	end

	if fam.Coins > 0 and fam:IsFrame(10, 0) then fam.Coins = fam.Coins -1 end

	fam:FollowParent()
end, Mod.Enum.Familiar.LIL_BITER)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, e in pairs(Isaac.FindByType(3, Mod.Enum.Familiar.LIL_BITER)) do
		e.Target = nil
		local fam = e:ToFamiliar()
		fam.State = State.IDLE
		fam.Coins = 0
	end
end)