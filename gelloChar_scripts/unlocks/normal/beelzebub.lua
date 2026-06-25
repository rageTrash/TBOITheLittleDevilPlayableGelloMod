local Mod = GelloCharMod
local game = Mod.Game
local SFX = Mod.SFX

local pTools = Mod.PlayerTools
local fTools = Mod.FamiliarTools

local itemConfig = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.BEELZEBUB)


local FALL_COOLDOWN = 300
local REST_COOLDOWN = 90
local OVER_SPEED = 8

local BASE_SPEED = Vector(4.5,0)
local FAST_SPEED = Vector(10,0)
local MOVEAWAY_SPEED = Vector(2, 0)

local State = {
	FOLLOW = 0,
	RESTING = 1
}


Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	
	player:CheckFamiliar(Mod.Enum.Familiar.BEELZEBUB,
		player:GetCollectibleNum(Mod.Enum.Item.BEELZEBUB) + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.BEELZEBUB),
		player:GetCollectibleRNG(Mod.Enum.Item.BEELZEBUB),
		itemConfig)
end, CacheFlag.CACHE_FAMILIARS)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam.State = State.FOLLOW

	fam.FireCooldown = FALL_COOLDOWN
end, Mod.Enum.Familiar.BEELZEBUB)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local sp = fam:GetSprite()

	local followEnt
	if fTools.IsCharmBySiren(fam) then
		followEnt = Isaac.FindByType(EntityType.ENTITY_SIREN)[1]
	else
		followEnt = fam.Player
	end

	if sp:IsFinished("RiseAgain") then sp:Play("FloatIdle", true) end

	if followEnt and fam.State == State.FOLLOW and not sp:IsPlaying("RiseAgain") then
		local targetVel = Vector.Zero
		local targetPos = followEnt.Position
		targetPos.X = targetPos.X -40 -- idk why but beelzebub targets just a tile to the right of the player
		local dis = fam.Position:Distance(targetPos)
		local angle = (targetPos - fam.Position):Normalized():GetAngleDegrees()
		
		if dis > 90 then
			targetVel = FAST_SPEED:Rotated(angle)
		elseif dis > 50 then
			targetVel = BASE_SPEED:Rotated(angle)
		end

		if fam:IsFrame(5,0) then
			for _, e in ipairs(Isaac.FindInRadius(fam.Position, 6, EntityPartition.FAMILIAR)) do
				if e.Variant == Mod.Enum.Familiar.BEELZEBUB then
					local angle = (fam.Position - e.Position):GetAngleDegrees()
					targetVel = targetVel + (MOVEAWAY_SPEED:Rotated(angle))
				end
			end
		end
		fam.Velocity = Mod:Lerp(fam.Velocity, targetVel, 0.1)
	end

	local vel = fam.Velocity:Length()
	local fireCooldown = fam.FireCooldown

	if fam.State == State.FOLLOW then
		if not sp:IsPlaying("RiseAgain") then

			local anim = "FloatIdle"
			if vel > OVER_SPEED then
				anim = "FloatIdleFast"
			end
			if not sp:IsPlaying(anim) then
				sp:SetAnimation(anim, false)
			end
		end
	elseif fam.State == State.RESTING then
		fam.Velocity = Vector.Zero
		if sp:IsPlaying("Fall") and sp:IsEventTriggered("MakeWave") then
			SFX:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
			local wave = Mod:Spawn(1000, EffectVariant.SHOCKWAVE, 0, fam.Position, Vector.Zero, fam):ToEffect()
			wave.Parent = fam
			wave.MinRadius = 20
			if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
				wave.MaxRadius = 80
			else
				wave.MaxRadius = 40
			end
			wave.Timeout = 2
			
			if fTools.IsCharmBySiren(fam) then
				wave.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			else
				wave.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			end
		end
		if sp:IsFinished("Fall") then
			sp:Play("TireIdle", true)
		end
	else fam.State = State.FOLLOW end

	if fireCooldown > 0 and not sp:IsPlaying("RiseAgain") and not game:GetRoom():IsClear() then
		if vel > 1 or vel <= 1 and fam:IsFrame(5, 0) == 0 then
			local remove = 1
			if vel > OVER_SPEED then remove = 2 end

			if not fTools.IsCharmBySiren(fam) and fam.Player and fam.Player:HasTrinket(141) then
				remove = remove *2
			end
			fam.FireCooldown = fireCooldown - remove
		end

	elseif fireCooldown <= 0 then
		if fam.State == State.FOLLOW then
			fam.Velocity = Vector.Zero
			
			sp:Play("Fall", true)
			fam.FireCooldown = REST_COOLDOWN
			fam.State = State.RESTING

		elseif fam.State == State.RESTING then
			sp:Play("RiseAgain", true)
			fam.FireCooldown = FALL_COOLDOWN
			fam.State = State.FOLLOW
		end
	end

end, Mod.Enum.Familiar.BEELZEBUB)



Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, e in pairs(Isaac.FindByType(3, Mod.Enum.Familiar.BEELZEBUB)) do
		local fam = e:ToFamiliar()
		if fam then
			fam:GetSprite():Play("FloatIdle", true)
			fam.Velocity = Vector.Zero
			fam.FireCooldown = FALL_COOLDOWN
			fam.State = State.FOLLOW
		end
	end
end)


Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, _, _, src)
	local srcEnt = src.Entity
	if not srcEnt or not (srcEnt.Type == 3 and srcEnt.Variant == Mod.Enum.Familiar.BEELZEBUB) then return end
	
	if fTools.IsCharmBySiren(srcEnt) and ent:ToNPC() then
		return false
	elseif ent.Type == 1 then
		return false
	end
end)