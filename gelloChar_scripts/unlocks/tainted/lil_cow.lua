local Mod = GelloCharMod
local game = Mod.Game
local SFX = Mod.SFX

local pTools = Mod.PlayerTools
local fTools = Mod.FamiliarTools

local config = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.LIL_COW)


local MOVE_COOLDOWN = 90
local REVIVE_COOLDOWN = 10
local REVIVE_COOLDOWN_BFF = 7

local MOVE_SPEED = Vector(4, 0)
local CHECK_VECTOR = Vector(20,0)
local heartOffset = Vector(-20, -40)

local State = {
	IDLE = 0,
	MOVING = 1,
	IDLE_HEALING = 2,
	MOVING_HEALING = 3,
	DEAD = 4,
	DEAD_ALT = 5
}


local function KillCow(fam)
	local wasHealing = fam.State > 1
	local sp = fam:GetSprite()
	local type = Mod.GetSetting("LilCowDead")
	if type == 0 then
		type = fam:GetDropRNG():RandomInt(2)
	else type = type -1 end
	fam.State = type +State.DEAD

	if fam.State == State.DEAD then
		sp:Play("DoomDie", true)
	else
		sp:Play("MinecraftDie", true)
	end
	sp:RemoveOverlay()
	
	if wasHealing then return end
	local isSirenCharm, helper = fTools.IsCharmBySiren(fam)
	if isSirenCharm then
		local siren = helper.SpawnerEntity
		if siren then
			local hitPoints = siren.HitPoints
			local healPoints = siren.MaxHitPoints // 6
			if hitPoints > siren.MaxHitPoints then
			elseif hitPoints + healPoints > siren.MaxHitPoints then
				siren.HitPoints = siren.MaxHitPoints
			else
				siren.HitPoints = hitPoints + healPoints
			end

			local effect = Mod:Spawn(1000, EffectVariant.HEART, 0, siren.Position, Vector.Zero, siren):ToEffect()
			effect:FollowParent(siren)
		end
	elseif fam.Player then
		local player = fam.Player
		local effect
		if player:CanPickRedHearts() then
			player:AddHearts(6)
			effect = Mod:Spawn(1000, EffectVariant.HEART, 0, player.Position, Vector.Zero, player):ToEffect()
		else
			player:AddSoulHearts(2)
			effect = Mod:Spawn(1000, EffectVariant.HEART, 4, player.Position, Vector.Zero, player):ToEffect()
		end
		effect:GetSprite().Offset = heartOffset
		effect:FollowParent(player)
	end
end



Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)

	player:CheckFamiliar(Mod.Enum.Familiar.LIL_COW,
		player:GetCollectibleNum(Mod.Enum.Item.LIL_COW) + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.LIL_COW),
		player:GetCollectibleRNG(Mod.Enum.Item.LIL_COW),
		config)
end, CacheFlag.CACHE_FAMILIARS)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	fam.State = State.IDLE
	fam.FireCooldown = MOVE_COOLDOWN
end, Mod.Enum.Familiar.LIL_COW)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local state = fam.State
	local sp = fam:GetSprite()
	local RNG = fam:GetDropRNG()
	local moveSpeed = fam.Velocity:Length()

	if state == State.IDLE or state == State.IDLE_HEALING then
		if fam.FireCooldown <= 0 then
			local rotated = RNG:RandomInt(360)
			local room = game:GetRoom()
			local trys = 0
			while trys < 20 do
				local target = CHECK_VECTOR:Rotated(rotated)
				if room:CheckLine(target, fam.Position, 3) and room:GetGridPathFromPos(target) < 950 then
					break
				end
				rotated = RNG:RandomInt(360)
				trys = trys +1
			end
			
			fam.Velocity = MOVE_SPEED:Rotated(rotated)

			if state == State.IDLE_HEALING then
				fam.State = State.MOVING_HEALING
			else
				fam.State = State.MOVING
			end
			fam.FireCooldown = MOVE_COOLDOWN

			Mod:SetEntityData(fam, "MoveTime", 15 * (RNG:RandomInt(3)+1) + game:GetFrameCount() )
		else
			fam.FireCooldown = fam.FireCooldown -1
		end
		if not sp:IsPlaying("Idle") and not (sp:GetAnimation():match("Revive") and sp:IsPlaying()) then
			sp:Play("Idle", true)
		end
	elseif state == State.MOVING or state == State.MOVING_HEALING then
		if game:GetFrameCount() > Mod:GetEntityData(fam, "MoveTime", -1) or moveSpeed < 3.8 then
			fam.Velocity = Vector.Zero
			if state == State.MOVING_HEALING then
				fam.State = State.IDLE_HEALING
			else
				fam.State = State.IDLE
			end
			Mod:SetEntityData(fam, "MoveTime", -1)
		elseif not sp:IsPlaying("Move") then
			sp:Play("Move", true)
			if math.abs(fam.Velocity:GetAngleDegrees()) > 90 then
				sp.FlipX = true
			else
				sp.FlipX = false
			end
		end
	elseif state >= State.DEAD then

		local anim = "Minecraft"
		if state == State.DEAD then anim = "Doom" end
		if not sp:IsPlaying(anim.."DieIdle") and sp:IsFinished(anim.."Die") then
			sp:Play(anim.."DieIdle", true)
		else
			local targetClear = REVIVE_COOLDOWN
			if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				targetClear = REVIVE_COOLDOWN_BFF
			end
			if fam.RoomClearCount >= targetClear then
				sp:Play(anim.."Revive", true)
				fam.State = State.IDLE
			end
		end
	end

	if state < State.DEAD then
		if state == State.IDLE_HEALING or state == State.MOVING_HEALING then
			if not sp:IsOverlayPlaying("Healing") then
				if sp:GetAnimation():match("Revive") == nil then
					sp:PlayOverlay("Healing", true)
					sp:SetOverlayRenderPriority(false)
				end
			end

			local targetClear = REVIVE_COOLDOWN
			if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				targetClear = REVIVE_COOLDOWN_BFF
			end
			if fam.RoomClearCount >= targetClear then
				fam.State = State.IDLE
				fam.RoomClearCount = 0
			end
		else
			if sp:IsOverlayPlaying("Healing") then sp:RemoveOverlay() end
			fam.RoomClearCount = 0
		end

		if fTools.IsCharmBySiren(fam) then
			for _, e in ipairs(Isaac.FindInRadius(fam.Position, 24, EntityPartition.TEAR))   do e:Die() end
		else
			for _, e in ipairs(Isaac.FindInRadius(fam.Position, 24, EntityPartition.BULLET)) do e:Die() end
		end
	else
		fam:MultiplyFriction(0.66)
	end
end, Mod.Enum.Familiar.LIL_COW)


Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, e in ipairs(Isaac.FindByType(3, Mod.Enum.Familiar.LIL_COW)) do
		local fam = e:ToFamiliar()
		if fam then
			if fam.State == State.MOVING then
				fam.FireCooldown = MOVE_COOLDOWN / 3
				fam.State = State.IDLE
			elseif fam.State == State.MOVING_HEALING then
				fam.FireCooldown = MOVE_COOLDOWN / 3
				fam.State = State.IDLE_HEALING
			end
			e.Velocity = Vector.Zero
		end
	end
end)



Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	for _, e in ipairs(Isaac.FindByType(3, Mod.Enum.Familiar.LIL_COW)) do
		local fam = e:ToFamiliar()
		if fam and fam.State >= State.DEAD then
			local anim = fam.State == State.DEAD and "Doom" or "Minecraft"
			local sp = fam:GetSprite()
			sp:Play(anim.."Revive", true)
			fam.State = State.IDLE_HEALING
		end
	end
end)


Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, exp)
	if exp.FrameCount > 1 then return end

	local spawner = exp.SpawnerEntity
	if spawner then
		if not (spawner:ToPlayer() or (spawner.Type == 4 and spawner.SpawnerEntity and spawner.SpawnerEntity:ToPlayer()) or
			(spawner.Type == 1000 and spawner.Variant == EffectVariant.ROCKET and spawner.SpawnerEntity and spawner.SpawnerEntity:ToPlayer())) then
			return
		end
	end
	for _, e in ipairs(Isaac.FindInRadius(exp.Position, 90, EntityPartition.FAMILIAR)) do
		local fam = e:ToFamiliar()
		if fam.Variant == Mod.Enum.Familiar.LIL_COW and fam.State < State.DEAD then
			KillCow(fam)
		end
	end
end, EffectVariant.BOMB_EXPLOSION)