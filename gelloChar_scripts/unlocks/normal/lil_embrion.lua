local Mod = GelloCharMod
local game = Mod.Game

local pTools = Mod.PlayerTools
local fTools = Mod.FamiliarTools

local trinketConfig = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.LIL_EMBRION)


local shootDirToAnim = {
	[Direction.NO_DIRECTION]= "Down",
	[Direction.LEFT] 		= "Left",
	[Direction.UP] 			= "Up",
	[Direction.RIGHT] 		= "Right",
	[Direction.DOWN] 		= "Down",
}

local SHOT_ANGLE = 5
local SHOT_VEL = Vector(10, 0)

local function multishot(amount, fam, player)
	local amount = math.min(amount, 16)
	local startAngle = -SHOT_ANGLE * ((amount-1)/ 2) 

	if fTools.IsCharmBySiren(fam) then
		local target = game:GetNearestPlayer(fam.Position)
		local vel = SHOT_VEL:Rotated( (target.Position - fam.Position):GetAngleDegrees() )
		for i=0, amount-1 do
			local proj = Mod:Spawn(9, 0, 0, fam.Position, vel:Rotated(startAngle + SHOT_ANGLE * i), fam):ToProjectile()
		end
		return
	end

	local kingBBTarget = fTools.GetKingBabyTarget(player)
	local angle

	if kingBBTarget then
		angle = (kingBBTarget.Position - fam.Position):GetAngleDegrees()
	else
		local shootingDir = fTools.GetShootingVector(fam)
		
		if shootingDir then
			angle = shootingDir:GetAngleDegrees()
		else
			return
		end
	end

	local vel = SHOT_VEL:Rotated(angle)
	local velInherit = player:GetTearMovementInheritance(player:GetAimDirection())
	local hasBabySpoon = player:HasTrinket(127)
	local hasBFFS = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
	local hasMarked = player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)

	local isHologram = pTools.IsFakeTwin(player, false) and not pTools.IsTaintedForgotten(player)

	for i=0, amount-1 do
		local tear = Mod:Spawn(2, TearVariant.BLOOD, 0, fam.Position, vel:Rotated(startAngle + SHOT_ANGLE * i), fam):ToTear()
		if not kingBBTarget and not hasMarked then tear.Velocity = tear.Velocity + velInherit end

		tear.Parent = fam
		if hasBFFS then
			tear.CollisionDamage = 7
			tear.Scale = 1.12
		else
			tear.CollisionDamage = 3.5
			tear.Scale = 1.009999
		end
		tear.CanTriggerStreakEnd = false
		tear.FallingSpeed = 0.4
		tear.Height = -24
		if hasBabySpoon then tear:AddTearFlags(TearFlags.TEAR_HOMING) end

		if isHologram then
			local color = tear.Color
			color.A = color.A /4
			tear.Color = color
		end
	end
end


local function shot(fam, player, offset)
	local offsetVector = Vector(0, offset)

	if fTools.IsCharmBySiren(fam) then
		local target = game:GetNearestPlayer(fam.Position)
		local angle = (target.Position - fam.Position):GetAngleDegrees()
		local vel = SHOT_VEL:Rotated(angle)
			
		local proj = Mod:Spawn(9, 0, 0, fam.Position +offsetVector:Rotated(angle), vel, fam):ToProjectile()
		return
	end

	local kingBBTarget = fTools.GetKingBabyTarget(player)
	local angle

	if kingBBTarget then
		angle = (kingBBTarget.Position - fam.Position):GetAngleDegrees()
	else
		angle = fTools.GetShootingVector(fam):GetAngleDegrees()
	end

	local vel = SHOT_VEL:Rotated(angle)
	local hasBabySpoon = player:HasTrinket(127)

	local isHologram = pTools.IsFakeTwin(player, false) and not pTools.IsTaintedForgotten(player)

	local tear = Mod:Spawn(2, TearVariant.BLOOD, 0, fam.Position +offsetVector:Rotated(angle), vel, fam):ToTear()
	if not kingBBTarget and not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		tear.Velocity = tear.Velocity + player:GetTearMovementInheritance(player:GetAimDirection())
	end

	tear.Parent = fam
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		tear.CollisionDamage = 7
		tear.Scale = 1.12
	else
		tear.CollisionDamage = 3.5
		tear.Scale = 1.009999
	end
	tear.CanTriggerStreakEnd = false
	tear.FallingSpeed = 0.4
	tear.Height = -24
	if hasBabySpoon then tear:AddTearFlags(TearFlags.TEAR_HOMING) end

	if isHologram then
		local color = tear.Color
		color.A = color.A /4
		tear.Color = color
	end
end




Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)
	player:CheckFamiliar(
		Mod.Enum.Familiar.LIL_EMBRION_FAM,
		player:GetCollectibleNum(Mod.Enum.Item.LIL_EMBRION) + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.LIL_EMBRION),
		player:GetCollectibleRNG(Mod.Enum.Item.LIL_EMBRION),
		trinketConfig)
end, CacheFlag.CACHE_FAMILIARS)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	local player = fam.Player
	if not player then return end

	fam:AddToFollowers()

	local playerTPS = pTools.GetTearsToTPS(player)
	local tearCool = math.ceil(pTools.GetTPSToTears(playerTPS* 0.265))
	fam.FireCooldown = tearCool // 2 +1
	Mod:SetEntityData(fam, "FireCooldown max", tearCool )
	
end, Mod.Enum.Familiar.LIL_EMBRION_FAM)


Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local player = fam.Player
	if not player then return end
	local dir = player:GetFireDirection()

	--if fam.FrameCount <= 1 then fam:AddToFollowers() end

	if dir ~= -1 then
		local kingBBTarget = fTools.GetKingBabyTarget(player)
		if kingBBTarget then
			dir = math.floor( (( (kingBBTarget.Position - fam.Position):GetAngleDegrees() +360 ) %360 /90 +2) %4 )
			--print(dir)
		end
	end

	local sp = fam:GetSprite()
	local fireCooldown = fam.FireCooldown
	if fireCooldown > 0 then
		if dir ~= -1 then
			local playAnim = "Float"
			if Mod:GetEntityData(fam, "FireCooldown max", nil) ~= nil and fireCooldown <= Mod:GetEntityData(fam, "FireCooldown max", nil) then
				playAnim = playAnim.."Idle"..shootDirToAnim[dir]
			else
				playAnim = playAnim.."Shoot"..shootDirToAnim[dir]
			end
			if not sp:IsPlaying(playAnim) then
				sp:SetAnimation(playAnim, false)
			end
		end
	elseif dir == -1 and not sp:IsPlaying("FloatIdleDown") then
		sp:SetAnimation("FloatIdleDown", false)
	end

	if fireCooldown <= 0 then
		if dir >= 0 then
			local playerTPS = pTools.GetTearsToTPS(player)
			if playerTPS > 7.2 then
				shot(fam, player, 0)

			elseif playerTPS > 5 then
				shot(fam, player, 8)
				shot(fam, player, -8)

			elseif playerTPS > 3.7 then 	multishot(3, fam, player)
			elseif playerTPS > 2.71 then 	multishot(4, fam, player)
			elseif playerTPS > 1.9 then		multishot(5, fam, player)
			elseif playerTPS > 1.4 then 	multishot(6, fam, player)
			elseif playerTPS > 1.15 then	multishot(8, fam, player)
			elseif playerTPS > 0.83 then	multishot(10, fam, player)
			elseif playerTPS > 0.56 then	multishot(12, fam, player)
			elseif playerTPS > 0.24 then	multishot(14, fam, player)
			else							multishot(16, fam, player)
			end

			local tearCool = math.ceil(pTools.GetTPSToTears(playerTPS* 0.265))
			fam.FireCooldown = tearCool
			Mod:SetEntityData(fam, "FireCooldown max", math.floor(tearCool /2)-1 )

			sp:SetAnimation("FloatShoot"..shootDirToAnim[dir], false)
		end
	else
		if not fTools.IsCharmBySiren(fam) and player:HasTrinket(141) then
			fam.FireCooldown = fireCooldown -2
		else
			fam.FireCooldown = fireCooldown -1
		end
	end

	fam:FollowParent()
end, Mod.Enum.Familiar.LIL_EMBRION_FAM)