local Mod = GelloCharMod
local game = Mod.Game
local SFX = Mod.SFX

local config = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.LARRY_JR_JR)


local MOVE_SPEED = Vector(5, 0)
local TEAR_SPEED = Vector(15,0)
local MAX_POS_DATA = 5


local State = {
	PRIORITY_REROLL = -1,
	NORMAL = 0,
	BLUE = 1,
	GREEN = 2,
	ROCKY = 3,

	GHOST = 4,
	WARPED = 5,
}

local dirTable = {
	Vector(40, 0),
	Vector(0, 40),
	Vector(-40, 0),
	Vector(0, -40),

	Vector(80, 0),
	Vector(0, 80),
	Vector(-80, 0),
	Vector(0, -80),
}

local anglesTable = {
	180,
	-90,
	0,
	90,
}

local idkTable = {
	{3, 7},
	{4, 8},
	{1, 5},
	{2, 6},
}


local function getFlysSpawned(fam)
	local ptr = GetPtrHash(fam)
	local count = 0
	for _, e in ipairs(Isaac.FindByType(3, FamiliarVariant.BLUE_FLY)) do
		local spawner = e.SpawnerEntity
		if spawner and GetPtrHash(spawner) == ptr then
			count = count +1
		end
	end

	return count
end


local function clampPos(pos)
	local x = pos.X % 40
	local y = pos.Y % 40
	if x >= 20 then
		pos.X = pos.X + (40- x)
	else pos.X = pos.X - x
	end
	if y >= 20 then
		pos.Y = pos.Y + (40- y)
	else pos.Y = pos.Y - y
	end

	return pos
end


local function setTarget(fam)
	local sPos = fam.Position
	local tab = Mod.TableTools.CopyLite(dirTable)
	local room = game:GetRoom()
	local RNG = fam:GetDropRNG()
	local target
	local prevDir = math.ceil((Mod:RoundToClosest(fam.Velocity:GetAngleDegrees(), 1) +360) /90) % 4 +1
	--print(fam.Velocity:GetAngleDegrees())
	--print(anglesTable[prevDir])
	--print(sPos)
	if room:CheckLine(tab[ prevDir ] + sPos, sPos, 3) and room:GetGridPathFromPos(tab[ prevDir ] + sPos) < 900 and RNG:RandomInt(3) > 0 then
		for i=2, 1, -1 do table.remove(tab, idkTable[prevDir][i]) end
	end

	while #tab > 0 do
		target = tab[RNG:RandomInt(#tab)+1] + sPos
		if room:CheckLine(target, sPos, 3) and room:GetGridPathFromPos(target) < 950 then
			--print(target)
			return clampPos(target)
		end
	end
	--print(target)
	return nil
end



Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)
	local num = (player:GetCollectibleNum(Mod.Enum.Item.LARRY_JR_JR) + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.LARRY_JR_JR)) > 0 and 1 or 0
	local RNG = player:GetCollectibleRNG(Mod.Enum.Item.LARRY_JR_JR)
	player:CheckFamiliar(Mod.Enum.Familiar.LARRY_JR_JR, num, RNG, config, 0)
end, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	if fam.SubType ~= 0 then return end
	fam.State = -1
	fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	
	fam:GetSprite():Play("IdleHeadFront0", true)
	local prev = fam
	for i=1, 2 do
		local f = Mod:Spawn(3, Mod.Enum.Familiar.LARRY_JR_JR, 1, fam.Position, Vector.Zero, fam):ToFamiliar()
		f.State = -1
		f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		f.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		f:GetSprite():Play("IdleMiddle0", true)

		prev.Child = f
		f.Parent = prev
		prev = f
	end

	local tail = Mod:Spawn(3, Mod.Enum.Familiar.LARRY_JR_JR, 2, fam.Position, Vector.Zero, fam):ToFamiliar()
	tail.State = -1
	tail.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	tail.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
	tail:GetSprite():Play("IdleButtFront0", true)

	prev.Child = tail
	tail.Parent = prev
end, Mod.Enum.Familiar.LARRY_JR_JR)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	if fam.SubType == 0 and fam.Child == nil then
		fam:Remove()
		return
	elseif fam.SubType == 1 and fam.Parent == nil then
		fam:Remove()
		return
	elseif fam.SubType == 2 and fam.Parent == nil then
		fam:Remove()
		return
	end
	
	local head = fam:GetLastParent()
	local player
	if fam.SubType == 0 or head then player = head.Player
	else
		fam:Remove()
		return
	end

	local data = Mod:GetEntityData(fam, "PrevPos", {})
	if #data >= MAX_POS_DATA then
		table.remove(data, #data)
	end
	table.insert(data, 1, fam.Position)
	Mod:SetEntityData(fam, "PrevPos", data)

	local target = Mod:GetEntityData(fam, "TargetPos")
	if fam.SubType == 0 then
		if fam.Velocity:Length() < 3 then
			target = nil
			Mod:SetEntityData(fam, "TargetPos", nil)
			fam.Velocity = Vector.Zero
		end

		if not target or fam.Position:Distance(target) < 4 then
			target = setTarget(fam)
			Mod:SetEntityData(fam, "TargetPos", target)
		end
	elseif fam.Parent ~= nil then
		target = Mod:GetEntityData(fam.Parent, "PrevPos", {})[MAX_POS_DATA]
	end

	if target then
		if fam.SubType > 0 and target:Distance(fam.Position) > 20 then
			fam.Position = target
			Mod:SetEntityData(fam, "PrevPos", {})
			local child = fam.Child
			while child do
				child.Position = target
				Mod:SetEntityData(child, "PrevPos", {})
				child = child.Child
			end
		else
			local angle = (target - fam.Position):GetAngleDegrees()
			fam.Velocity = MOVE_SPEED:Rotated(angle)
		end
	else
		fam.Velocity = Vector.Zero
	end

	local RNG = fam:GetDropRNG()
	if fam:IsFrame(15, 0) and not game:GetRoom():IsClear() then
		if fam.State == State.BLUE then
			if fam.SubType > 0 and (fam.SubType == 1 and RNG:RandomInt(6) == 0 or fam.SubType == 2 and RNG:RandomInt(3) == 0) then
				local creep = Mod:Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, fam.Position, Vector.Zero, fam):ToEffect()
				if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					creep.CollisionDamage = 0.5
				else
					creep.CollisionDamage = 0.25
				end
				creep.Timeout = 90
			end
		elseif fam.State == State.GREEN then
			if fam.SubType > 0 and (fam.SubType == 1 and RNG:RandomInt(10) == 0 or fam.SubType == 2 and RNG:RandomInt(5) == 0) then
				local addSpeed = fam.Velocity*0.6
				for i=1, Mod:RandomInt(3, 5, RNG) do
					local tear = Mod:Spawn(2, 1, 0, fam.Position, TEAR_SPEED:Resized(Mod:RandomFloat(-5, 2, RNG)):Rotated(RNG:RandomInt(360)) + addSpeed, fam):ToTear()
					tear.Parent = fam
					if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
						tear.CollisionDamage = 5
					else
						tear.CollisionDamage = 2.5
					end
					tear.CanTriggerStreakEnd = false
					tear.FallingAcceleration = 0.65
					tear.FallingSpeed = -8
					tear.Height = -16

					tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				end
			end
		elseif fam.State == State.ROCKY then
			if fam.SubType > 0 and getFlysSpawned(fam) < 1 and
				(fam.SubType == 1 and RNG:RandomInt(10) == 0 or fam.SubType == 2 and RNG:RandomInt(5) == 0) then

				Mod:Spawn(1000, EffectVariant.POOF01, 1, fam.Position, Vector.Zero, fam)
				local fly = Mod:Spawn(3, FamiliarVariant.BLUE_FLY, 0, fam.Position, Vector.Zero, player):ToFamiliar()
				fly.SpawnerEntity = fam
			end
		end
	end

	if fam.State <= State.NORMAL then
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.CollisionDamage = 6
		else
			fam.CollisionDamage = 3
		end
	else
		if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.CollisionDamage = 3
		else
			fam.CollisionDamage = 1.5
		end
	end


	local sp = fam:GetSprite()
	local anim = "Idle"

	if fam.SubType == 0 then
		anim = anim.."Head"
	elseif fam.SubType == 1 then
		anim = anim.."Middle"
	elseif fam.SubType == 2 then
		anim = anim.."Butt"
	end

	local angle = fam.Velocity:GetAngleDegrees()
	if angle >= -45 and angle <= 45 then
		if fam.SubType == 0 or fam.SubType == 2 then anim = anim.."Side" end
		sp.FlipX = false
	elseif angle < -45 and angle > -135 then
		if fam.SubType == 0 or fam.SubType == 2 then anim = anim.."Back" end
		sp.FlipX = false
	elseif angle >= 135 or angle <= -135 then
		if fam.SubType == 0 or fam.SubType == 2 then anim = anim.."Side" end
		sp.FlipX = true
	elseif angle > 45 and angle < 135 then
		if fam.SubType == 0 or fam.SubType == 2 then anim = anim.."Front" end
		sp.FlipX = false
	end
	anim = anim..tostring(math.max(fam.State, 0))

	if not sp:IsPlaying(anim) then sp:SetAnimation(anim, false) end
end, Mod.Enum.Familiar.LARRY_JR_JR)


Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, dmgFlags, src)
	local srcEnt = src.Entity
	if not srcEnt or not (srcEnt.Type == 3 and srcEnt.Variant == Mod.Enum.Familiar.LARRY_JR_JR and srcEnt.SubType == 0) then return end
	Mod:SetEntityData(ent, "WasKilledByLarry", {F = game:GetFrameCount(), E = srcEnt:ToFamiliar()})
end)

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, ent)
	local data = Mod:GetEntityData(ent, "WasKilledByLarry")
	if data and game:GetFrameCount() == data.F+1 then
		if data.E and data.E:Exists() then
			local fam = data.E

			if fam.State == State.BLUE then
				local creep = Mod:Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, ent.Position, Vector.Zero, fam):ToEffect()
				creep.Size = creep.Size * 1.5
				creep.SizeMulti = creep.SizeMulti * 1.5
				if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					creep.CollisionDamage = 1.0
				else
					creep.CollisionDamage = 0.5
				end
				creep.Timeout = 90
			elseif fam.State == State.GREEN then
				local vel = TEAR_SPEED:Rotated( fam.Velocity:GetAngleDegrees() )
				for i=0, 2 do
					local tear = Mod:Spawn(2, 1, 0, ent.Position, vel:Rotated(-24 + 24 *i), fam):ToTear()
					tear.Parent = fam
					if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
						tear.CollisionDamage = 7
					else
						tear.CollisionDamage = 3.5
					end
					tear.CanTriggerStreakEnd = false
					tear.FallingSpeed = 0.4
					tear.Height = -24
				end
			elseif fam.State == State.ROCKY then
				SFX:Play(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND)
				local wave = Mod:Spawn(1000, EffectVariant.SHOCKWAVE, 0, ent.Position, Vector.Zero, fam):ToEffect()
				wave.Parent = fam
				wave.MinRadius = 20
				
				if fam.Player and fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					wave.MaxRadius = 80
				else
					wave.MaxRadius = 40
				end
				
				wave.Timeout = 2

				wave.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			end

			local RNG = fam:GetDropRNG()

			local tabPriority = {}
			local tab = {}
			if fam.State == -1 then
				table.insert(tabPriority, fam)
			else
				table.insert(tab, fam)
			end
			do
				local child = fam.Child
				while child ~= nil do
					local f = child:ToFamiliar()
					if f then
						if f.State == -1 then
							table.insert(tabPriority, f)
						else
							table.insert(tab, f)
						end
					end
					child = f.Child
				end
			end
			if #tabPriority > 0 then
				local upFam = tabPriority[RNG:RandomInt(#tabPriority)+1]
				upFam.State = RNG:RandomInt(4)
			elseif #tab > 0 then
				local upFam = tab[RNG:RandomInt(#tab)+1]
				upFam.State = RNG:RandomInt(4)
			end
		end
	end
end)


Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, e in pairs(Isaac.FindByType(3, Mod.Enum.Familiar.LARRY_JR_JR)) do
		Mod:SetEntityData(e, "TargetPos", nil)
		Mod:SetEntityData(e, "PrevPos", nil)
	end
end)


--- adapted(?) from Fiend Folio
if not Mod.RepentogonPlus then
local hiddenFromSiren = {}
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.LATE, function(_, siren)
	for _, e in ipairs(Isaac.FindByType(3, Mod.Enum.Familiar.LARRY_JR_JR)) do
		e:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
		table.insert(hiddenFromSiren, e)
	end
end, EntityType.ENTITY_SIREN)

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, siren)
	for _,familiar in ipairs(hiddenFromSiren) do
		familiar:ClearEntityFlags(EntityFlag.FLAG_NO_QUERY)
	end
	hiddenFromSiren = {}
end, EntityType.ENTITY_SIREN)
end



Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, _, _, src)
	local srcEnt = src.Entity
	if not srcEnt or not (srcEnt.Type == 3 and srcEnt.Variant == Mod.Enum.Familiar.LARRY_JR_JR) then return end
	if ent.Type == 1 or ent.Type == 3 then return false end
end)