local Mod = GelloCharMod
local game = Mod.Game
local posterSave = Mod.SaveHandler.Save("MissingPost_Quest")
local beggarSave = Mod.SaveHandler.Save("MissingPost_Beggar")
local SFX = Mod.SFX

local pTools = Mod.PlayerTools
local anyPlayerHas = pTools.AnyPlayerHasCollectible
local fTools = Mod.FamiliarTools

local config = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.MISSING_HANDLER)


-- copy paste from here https://wofsauge.github.io/IsaacDocs/rep/Room.html?h=devil#getdevilroomchance
local function anyPlayerHasCollectible(collectible)
	if REPENTOGON then
		return PlayerManager.AnyoneHasCollectible(collectible)
	else
		for i = 0, game:GetNumPlayers() - 1 do
			local player = game:GetPlayer(i)

			if player:HasCollectible(collectible, false) then
				return true
			end
		end
	end
	return false
end

-- the same tainted lazarus + repentogon logic applies to trinkets (rosary bead)
local function anyPlayerHasTrinket(trinket)
	if REPENTOGON then
		return PlayerManager.AnyoneHasTrinket(trinket)
	else
		for i = 0, game:GetNumPlayers() - 1 do
			local player = game:GetPlayer(i)

			if player:HasTrinket(trinket, false) then
				return true
			end
		end

	end
	return false
end

local function getDevilAngelRoomChance()
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local totalChance = math.min(room:GetDevilRoomChance(), 1.0)

	local angelRoomSpawned = game:GetStateFlag(GameStateFlag.STATE_FAMINE_SPAWNED) -- repurposed
	local devilRoomSpawned = game:GetStateFlag(GameStateFlag.STATE_DEVILROOM_SPAWNED)
	local devilRoomVisited = game:GetStateFlag(GameStateFlag.STATE_DEVILROOM_VISITED)

	local devilRoomChance = 1.0
	if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_EUCHARIST) then
		devilRoomChance = 0.0
	elseif devilRoomSpawned and devilRoomVisited and game:GetDevilRoomDeals() > 0 then -- devil deals locked in
		if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) or
			anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) or
			level:GetAngelRoomChance() > 0.0 -- confessional, sac room
		then
			devilRoomChance = 0.5
		end
	elseif devilRoomSpawned or anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) or level:GetAngelRoomChance() > 0.0 then
		if not (devilRoomVisited or angelRoomSpawned) then
			devilRoomChance = 0.0
		else
			devilRoomChance = 0.5
		end
	end

	-- https://bindingofisaacrebirth.fandom.com/wiki/Angel_Room#Angel_Room_Generation_Chance
	if devilRoomChance == 0.5 then
		if anyPlayerHasTrinket(TrinketType.TRINKET_ROSARY_BEAD) then
			devilRoomChance = devilRoomChance * (1.0 - 0.5)
		end
		if game:GetDonationModAngel() >= 10 then -- donate 10 coins
			devilRoomChance = devilRoomChance * (1.0 - 0.5)
		end
		if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			devilRoomChance = devilRoomChance * (1.0 - 0.25)
		end
		if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			devilRoomChance = devilRoomChance * (1.0 - 0.25)
		end
		if level:GetStateFlag(LevelStateFlag.STATE_EVIL_BUM_KILLED) then
			devilRoomChance = devilRoomChance * (1.0 - 0.25)
		end
		if level:GetStateFlag(LevelStateFlag.STATE_BUM_LEFT) and not level:GetStateFlag(LevelStateFlag.STATE_EVIL_BUM_LEFT) then
			devilRoomChance = devilRoomChance * (1.0 - 0.1)
		end
		if level:GetStateFlag(LevelStateFlag.STATE_EVIL_BUM_LEFT) and not level:GetStateFlag(LevelStateFlag.STATE_BUM_LEFT) then
			devilRoomChance = devilRoomChance * (1.0 + 0.1)
		end
		if level:GetAngelRoomChance() > 0.0 or
			(level:GetAngelRoomChance() < 0.0 and (anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) or anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)))
		then
			devilRoomChance = devilRoomChance * (1.0 - level:GetAngelRoomChance())
		end
		if anyPlayerHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			devilRoomChance = devilRoomChance * (1.0 - 0.25)
		end
		devilRoomChance = math.max(0.0, math.min(devilRoomChance, 1.0))
	end

	local angelRoomChance = 1.0 - devilRoomChance
	return totalChance * devilRoomChance, totalChance * angelRoomChance
end



function GelloCharMod:CanSpawnMissingPost()
	local level = game:GetLevel()
	local stage = level:GetStage()
	local data = posterSave:Get({})

	if not Mod:IsUnlock("Missing Post") or data.StopFutureQuest or data.ActiveQuest or data.PlayerHasFam or data.NotSpawnOnFloor or data.AlreadySpawn or level:IsAscent() or level:IsPreAscent() then return false end

	if Mod.LevelTools.IsAltPath() then
		if not level:GetCurrentRoom():IsMirrorWorld() and stage < LevelStage.STAGE3_2 then
			if stage == LevelStage.STAGE3_1 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 then return false end
			return true
		end
	elseif stage ~= 1 and stage < LevelStage.STAGE3_2 then
		if stage == LevelStage.STAGE3_1 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 then return false end
		return true
	end
	return false
end


local SLOT_SPAWN_POSITION = Vector(200, 160)
local SHOT_VEL = Vector(10, 0)
local FAM_SPEED = Vector(5, 0)
local FAM_SPEED_HALF = Vector(2.5, 0)
local FAM_TARGET = Vector(32,0)

local ROOM_TYPE_CHANCE = {
	[RoomType.ROOM_SHOP] = 4,       -- 25%
	[RoomType.ROOM_SECRET] = 3,     -- 33.33%
	[RoomType.ROOM_SUPERSECRET] = 3,-- 33.33%
}

local FAMILIAR_SUBTYPES = {
	NULL = 0,
	ANGRY = 1,
	SHY = 2,
	FRIENDLY = 3,
	ASTRAL = 4,  -- looks like andromeda  -  find it in the treasure room or secret / super secret room ¿¿
	SPIDER = 5,  -- looks like arachna    -  idk

	MAX_FAM = 3,
}

local FAMILIAR_SPRITE_RUTE = {
	"gfx/familiar/missing_post/error.png",
	"gfx/familiar/missing_post/evil.png",
	"gfx/familiar/missing_post/shy.png",
	"gfx/familiar/missing_post/friendly.png",
	"gfx/familiar/missing_post/astral.png",
	"gfx/familiar/missing_post/spider.png",
}

local FAMILIAR_FIRECOOLDOWN = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = 24,
	[FAMILIAR_SUBTYPES.SHY] = 15,
	[FAMILIAR_SUBTYPES.FRIENDLY] = 19,
	[FAMILIAR_SUBTYPES.ASTRAL] = 20,
	[FAMILIAR_SUBTYPES.SPIDER] = 45,
}

local FAMILIAR_DAMAGE = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = 5,
	[FAMILIAR_SUBTYPES.SHY] = 2.2,
	[FAMILIAR_SUBTYPES.FRIENDLY] = 1.6,
	[FAMILIAR_SUBTYPES.ASTRAL] = 3,
	[FAMILIAR_SUBTYPES.SPIDER] = 2.8,
}

local FAMILIAR_TEAR_SIZE = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = 1.012,
	[FAMILIAR_SUBTYPES.SHY] = 0.89222,
	[FAMILIAR_SUBTYPES.FRIENDLY] = 0.72,
	[FAMILIAR_SUBTYPES.ASTRAL] = 1.0099,
	[FAMILIAR_SUBTYPES.SPIDER] = 1.0088,
}

local FAMILIAR_TEAR_TYPE = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = TearVariant.BLOOD,
	[FAMILIAR_SUBTYPES.SHY] = TearVariant.BLUE,
	[FAMILIAR_SUBTYPES.FRIENDLY] = TearVariant.BLUE,
	[FAMILIAR_SUBTYPES.ASTRAL] = TearVariant.BLUE,
	[FAMILIAR_SUBTYPES.SPIDER] = TearVariant.BLUE,
}

local FAMILIAR_TEAR_AMOUNT = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = 1,
	[FAMILIAR_SUBTYPES.SHY] = 1,
	[FAMILIAR_SUBTYPES.FRIENDLY] = 1,
	[FAMILIAR_SUBTYPES.ASTRAL] = 1,
	[FAMILIAR_SUBTYPES.SPIDER] = 4,
}

local FAMILIAR_TEAR_ANGLE = {
	[FAMILIAR_SUBTYPES.NULL] = nil,
	[FAMILIAR_SUBTYPES.ANGRY] = 0,
	[FAMILIAR_SUBTYPES.SHY] = 0,
	[FAMILIAR_SUBTYPES.FRIENDLY] = 0,
	[FAMILIAR_SUBTYPES.ASTRAL] = 0,
	[FAMILIAR_SUBTYPES.SPIDER] = 2.2,
}

local shootDirToAnim = {
	[Direction.NO_DIRECTION]= "Down",
	[Direction.LEFT] 		= "Left",
	[Direction.UP] 			= "Up",
	[Direction.RIGHT] 		= "Right",
	[Direction.DOWN] 		= "Down",
}

local dirPathCheck = {
	Vector(0,40),
	Vector(40,0),
	Vector(0,-40),
	Vector(-40,0),
}
local function FindPath(room, start, finish)
	local npc = Mod:Spawn(17, 0,0, start, Vector.Zero, nil):ToNPC()
	local hasPath = npc.Pathfinder:HasPathToPos(finish, true)
	npc:Remove()
	return hasPath
end

local function shootTears(fam, player, vel, RNG, amount, angle, controledByKingBB)
	local startAngle = angle * ((amount-1)/ 2) 
	local tearShot = {}
	local famType = fam.SubType

	for i=0, amount-1 do
		local tear = Mod:Spawn(2, (FAMILIAR_TEAR_TYPE[famType] or RNG:RandomInt(51)), 0, fam.Position, vel:Rotated(startAngle + angle*i), fam):ToTear()
		if not controledByKingBB and not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
			tear.Velocity = tear.Velocity + player:GetTearMovementInheritance(player:GetAimDirection())
		end

		tear.Parent = fam
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			tear.CollisionDamage = (FAMILIAR_DAMAGE[famType] or Mod:RandomFloat(2, 5, RNG)) *2
			tear.Scale = (FAMILIAR_TEAR_SIZE[famType] or Mod:RandomFloat(1.0082, 1.12, RNG)) * 1.09
		else
			tear.CollisionDamage = (FAMILIAR_DAMAGE[famType] or Mod:RandomFloat(2, 5, RNG))
			tear.Scale = (FAMILIAR_TEAR_SIZE[famType] or Mod:RandomFloat(1.0082, 1.12, RNG))
		end
		tear.CanTriggerStreakEnd = false
		tear.FallingSpeed = 0.4
		tear.Height = -24
		table.insert(tearShot, tear)
	end
	return tearShot
end

local function FamShoot(fam)
	local player = fam.Player
	if fTools.IsCharmBySiren(fam) then
		local target = game:GetNearestPlayer(fam.Position)
		local angle = (target.Position - fam.Position):GetAngleDegrees()
		local vel = SHOT_VEL:Rotated(angle)
		
		local tearAmount = (FAMILIAR_TEAR_AMOUNT[famType] or 1)
		local shotAngle = (FAMILIAR_TEAR_ANGLE[famType] or 0)
		local startAngle = shotAngle * ((amount-1)/ 2)

		for i=0, tearAmount-1 do
			local proj = Mod:Spawn(9, 0, 0, fam.Position, vel:Rotated(startAngle + shotAngle*i), fam):ToProjectile()
		end
		return
	end
	local famType = fam.SubType
	local RNG = fam:GetDropRNG()

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

	local tearAmount = (FAMILIAR_TEAR_AMOUNT[famType] or 1)
	local shotList = shootTears(fam, player, vel, RNG, tearAmount, (FAMILIAR_TEAR_ANGLE[famType] or 0) , kingBBTarget ~= nil)
	for i=1, #shotList do
		local tear = shotList[i]
		if hasBabySpoon then tear:AddTearFlags(TearFlags.TEAR_HOMING) end

		if famType == FAMILIAR_SUBTYPES.NULL then
			for i=0, RNG:RandomInt(2) do
				tear:AddTearFlags( BitSet128(1<< RNG:RandomInt(TearFlags.TEAR_EFFECT_COUNT) ,0) )
			end
		elseif famType == FAMILIAR_SUBTYPES.SHY then
			if RNG:RandomInt(12) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_FEAR)
			end
		elseif famType == FAMILIAR_SUBTYPES.FRIENDLY then
			if RNG:RandomInt(5) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_CHARM | TearFlags.TEAR_SPECTRAL)
			end
		elseif famType == FAMILIAR_SUBTYPES.ASTRAL then
			tear:AddTearFlags(TearFlags.TEAR_ORBIT)
		elseif famType == FAMILIAR_SUBTYPES.SPIDER then
			if RNG:RandomInt(6) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_SLOW)
			end
		end

		if isHologram then
			local color = tear.Color
			color.A = color.A /4
			tear.Color = color
		end
	end
end



--- Ent Familiar Logic
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)
	player:CheckFamiliar(Mod.Enum.Familiar.MISSING_FAM,
		(player:GetEffects():HasCollectibleEffect(Mod.Enum.Item.MISSING_HANDLER) and 1 or 0),
		player:GetCollectibleRNG(Mod.Enum.Item.MISSING_HANDLER),
		config,
		(posterSave:Get({}).FamSubType or 0))

end, CacheFlag.CACHE_FAMILIARS)

local fakeFamLastPos
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	local sp = fam:GetSprite()
	sp:ReplaceSpritesheet(0, FAMILIAR_SPRITE_RUTE[ fam.SubType +1 ])
	sp:LoadGraphics()
	
	fam:AddToFollowers()
	if fakeFamLastPos then fam.Position = fakeFamLastPos end
end, Mod.Enum.Familiar.MISSING_FAM)

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local player = fam.Player
	if player == nil then return end

	local dir = player:GetFireDirection()
	local sp = fam:GetSprite()

	if dir ~= -1 then
		local kingBBTarget = fTools.GetKingBabyTarget(player)
		if kingBBTarget then
			dir = math.floor( (( (kingBBTarget.Position - fam.Position):GetAngleDegrees() +360 ) %360 /90 +2) %4 )
		end
	end

	local fireCooldown = fam.FireCooldown

	if fireCooldown > 0 then
		if dir ~= -1 then
			local playAnim = "Shoot"..shootDirToAnim[dir]
			if Mod:GetEntityData(fam, "FireCooldown max", nil) ~= nil and fireCooldown <= Mod:GetEntityData(fam, "FireCooldown max", nil) then
				playAnim = "Idle"..shootDirToAnim[dir]
			end
			if not sp:IsPlaying(playAnim) then
				sp:SetAnimation(playAnim, false)
			end
		end
	elseif dir == -1 and not sp:IsPlaying("IdleDown") then
		sp:SetAnimation("IdleDown", false)
	end

	
	if dir > -1 and fireCooldown <= 0 then
		FamShoot(fam)
		local fireCool = (FAMILIAR_FIRECOOLDOWN[fam.SubType] or Mod:RandomInt(24, 60, fam:GetDropRNG()))
		fam.FireCooldown = fireCool
		Mod:SetEntityData(fam, "FireCooldown max", math.floor(fireCool /2)-1 )
		sp:SetAnimation("Shoot"..shootDirToAnim[dir], false)
	elseif fireCooldown > 0 then
		if not fTools.IsCharmBySiren(fam) and player:HasTrinket(141) then
			fam.FireCooldown = fireCooldown -2
		else
			fam.FireCooldown = fireCooldown -1
		end
	end

	local slots = Isaac.FindByType(6, Mod.Enum.Slot.MISSING_POSTER, 1)
	if #slots <= 0 then
		fam:FollowParent()
	elseif fam.Visible then
		local mainSlot = slots[1]
		local slotSp = mainSlot:GetSprite()
		if not slotSp:IsPlaying("FamiliarIsComming") then slotSp:Play("FamiliarIsComming", true) end
		
		local targetPos = mainSlot.Position + FAM_TARGET
		if fam.Position:Distance(targetPos) < 30 then
			slotSp:Play("PickupFamiliar", true)
			fam.Visible = false
			Mod:SetEntityData(mainSlot, "Target Ents", {Player = player, Fam = fam})
		elseif fam.Position:Distance(targetPos) < 80 then
			fam.Velocity = FAM_SPEED_HALF:Rotated( (targetPos - fam.Position):GetAngleDegrees() )
		else
			fam.Velocity = FAM_SPEED:Rotated( (targetPos - fam.Position):GetAngleDegrees() )
		end
	end
end, Mod.Enum.Familiar.MISSING_FAM)


--- Missing Post Generation
local MissingPostRNG = RNG()
local function SpawnSlot()
	if not Mod:IsUnlock("Missing Post") then return end
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end

	local door = game:GetLevel().EnterDoor
	if door == -1 or not Mod:CanSpawnMissingPost() then return end
	local playerStart = room:GetDoorSlotPosition(door)

	local rType = room:GetType()

	if ROOM_TYPE_CHANCE[rType] then
		MissingPostRNG:SetSeed(room:GetDecorationSeed(), 35)
		if MissingPostRNG:RandomInt(ROOM_TYPE_CHANCE[rType]) == 0 and FindPath(room, SLOT_SPAWN_POSITION, playerStart) then

			for _, e in ipairs(Isaac.GetRoomEntities()) do
				if e.Position:Distance(SLOT_SPAWN_POSITION) < 30 then
					e:Remove()
				end
			end

			local post = Mod:Spawn(6, Mod.Enum.Slot.MISSING_POSTER, 0, SLOT_SPAWN_POSITION, Vector.Zero)

			local data = posterSave:Get({})
			data.AlreadySpawn = true
			if anyPlayerHas(258) or anyPlayerHas(405) or anyPlayerHas(721) then -- Missing No. - GB Bug - TMTRAINER
				data.FamSubType = FAMILIAR_SUBTYPES.NULL
			else
				data.FamSubType = MissingPostRNG:RandomInt(FAMILIAR_SUBTYPES.MAX_FAM) +1
			end
			posterSave:Set(data)

			local sp = post:GetSprite()
			sp:ReplaceSpritesheet(3, FAMILIAR_SPRITE_RUTE[data.FamSubType+1])
			sp:LoadGraphics()

		end
	end
end


Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	local level = game:GetLevel()
	if not Mod.GameStart then return end
	local data = posterSave:Get({})
	if not data.ActiveQuest and data.AlreadySpawn and not data.NotSpawnOnFloor then -- if spawned in the previous floor make so it doesn't spawns in the current one
		data.NotSpawnOnFloor = true
		posterSave:Set(data)
		return
	end

	if level:IsAscent() or level:IsPreAscent() then
		data.ActiveQuest = false
		posterSave:Set(data)
	elseif data.ActiveQuest then
		if data.SpawnedCount then data.SpawnedCount = data.SpawnedCount +1
		else data.SpawnedCount = 0 end
		
		if data.SpawnedCount >= 2 then
			posterSave:Set(nil)
			return
		end

		if anyPlayerHas(258) or anyPlayerHas(405) or anyPlayerHas(721) then -- Missing No. - GB Bug - TMTRAINER
			data.FamSubType = FAMILIAR_SUBTYPES.NULL
		end
		
		
		local beggar = Mod:Spawn(6, Mod.Enum.Slot.MISSING_POSTER, 1, SLOT_SPAWN_POSITION, Vector.Zero)
		local sp = beggar:GetSprite()
		sp:ReplaceSpritesheet(2, FAMILIAR_SPRITE_RUTE[data.FamSubType+1])
		sp:LoadGraphics()

		local level = game:GetLevel()
		local count = 0
		data.LevelRoomAmount = math.floor(Mod.LevelTools.GetRoomCount() *0.6) -5

	elseif data.NotSpawnOnFloor then
		posterSave:Set(nil)
		return
	end
	posterSave:Set(data)
end)


--- Slot Logic
local function removeFamiliar(slot)
	local ents = Mod:GetEntityData(slot,  "Target Ents")

	if ents.Player then ents.Player:GetEffects():RemoveCollectibleEffect(Mod.Enum.Item.MISSING_HANDLER, 2)
	else error("Missing Post Beggar player target is nil", 1) end
	if ents.Fam then ents.Fam:Remove() -- idk why but if the familiar is not visible when removing an item it doesn't disappear
	else error("Missing Post Beggar familiar target is nil", 1) end
end

local function slotCollision(slot, coll)
	local player = coll:ToPlayer()
	if not player then return end

	local sp = slot:GetSprite()
	if sp:IsPlaying("Idle") then
		sp:Play("PickupPaper", true)
	end
end


local function missingPostUpdate(slot)
	local sp = slot:GetSprite()
	if sp:IsFinished("PickupPaper") then
		local data = posterSave:Get({})
		data.ActiveQuest = true
		posterSave:Set(data)

		sp:Play("IdleNoPaper", true)
	end
end



local function beggarUpdate(slot)
	local sp = slot:GetSprite()
	
	if sp:IsPlaying("Idle") then
		if sp:GetOverlayAnimation() ~= "" then
			sp:RemoveOverlay()
		end
	elseif sp:IsPlaying("FamiliarIsComming") then
		if sp:GetOverlayAnimation() == "" then
			sp:PlayOverlay("PosterFallOverlay", true)
		end
	elseif sp:IsFinished("PickupFamiliar") then
		sp:Play("Payout", true)
	elseif sp:IsPlaying("Payout") then
		if sp:IsEventTriggered("Prize") then
			removeFamiliar(slot)
			local rng = slot:GetDropRNG()
			local coinTable = Mod:GenerateTableCoins( Mod:RandomInt(2, 4, rng) *5, rng)

			for i=1, #coinTable do
				Mod:Spawn(5, 20, coinTable[i], slot.Position, Mod:RandomVector(-3.5,3.5, rng), slot)
			end

			local data = beggarSave:Get({})
			local level = game:GetLevel()
			local dealChance = getDevilAngelRoomChance() /2.25
			level:AddAngelRoomChance( dealChance )
			data.DealAdded = -dealChance
			data.Payout = true
			beggarSave:Set(data)

			posterSave:Set({ NotSpawnOnFloor = true, AlreadySpawn = true })  -- makes it so it doesn't spawn in the current floor but resets on the next
		elseif sp:IsEventTriggered("Disappear") then
			slot:Remove()
		end
	end
end


local function missingPostKill(slot)
	local pos = slot.Position
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

	local newSlot = Mod:Spawn(slot.Type, slot.Variant, slot.SubType, pos, Vector.Zero, slot.SpawnerEntity, slot.InitSeed)
	slot:Remove()
	local sp = newSlot:GetSprite()
	sp:Play("IdleNoPaper", true)

	Mod:RemoveSlotDrops(slot)
end

local function beggarKill(slot)
	local data = beggarSave:Get({})

	Mod:RemoveSlotDrops(slot)
	if not data.Payout then
		local anim = slot:GetSprite():GetAnimation()
		local level = game:GetLevel()
		if anim == "Payout" or anim == "PickupFamiliar" then
			removeFamiliar(slot)
			if not data.SuperEvil then
				SFX:Play(SoundEffect.SOUND_SATAN_GROW)
				local dealChance = getDevilAngelRoomChance() /1.75 /100
				level:AddAngelRoomChance( -dealChance - (data.DealAdded or 0) ) -- canceling the previous deal chance
				data.DealAdded = dealChance

				data.SuperEvil = true
			end
		elseif anim == "FamiliarIsComming" then
			if not (data.SuperEvil or data.Evil) then
				local dealChance = getDevilAngelRoomChance() /2.5 /100
				level:AddAngelRoomChance( -dealChance - (data.DealAdded or 0) ) -- canceling the previous deal chance
				data.DealAdded = dealChance
				data.Evil = true
			end
		elseif not (data.SuperEvil or data.Evil or data.Dead) then
			local dealChance = getDevilAngelRoomChance() /5 /100
			level:AddAngelRoomChance( -dealChance )
			data.DealAdded = dealChance

			data.Dead = true
		end
		beggarSave:Set(data)
		local rng = slot:GetDropRNG()
		local coinTable = Mod:GenerateTableCoins( 5, rng)

		local pos = slot.Position
		for i=1, #coinTable do
			Mod:Spawn(5, 20, coinTable[i], pos, Vector.FromAngle(Mod:RandomFloat(0,360, rng)) * 3.5, nil)
		end

		local postData = posterSave:Get({})
		postData.ActiveQuest = false
		postData.StopFutureQuest = true
		posterSave:Set(postData)
	end

	slot:BloodExplode()
	slot:Remove()
end


if Mod.Repentogon then
	Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, function(_, slot)
		local sub = (posterSave:Get({}).FamSubType or 0) +1
		if slot.SubType == 0 then
			local sp = slot:GetSprite()
			sp:ReplaceSpritesheet(3, FAMILIAR_SPRITE_RUTE[sub])
			sp:LoadGraphics()
			
			local data = posterSave:Get({})
			if data.StopFutureQuest or data.ActiveQuest then
				sp:Play("IdleNoPaper", true)
			end
		elseif slot.SubType == 1 then
			local sp = slot:GetSprite()
			sp:ReplaceSpritesheet(2, FAMILIAR_SPRITE_RUTE[sub])
			sp:LoadGraphics()
		end
	end, Mod.Enum.Slot.MISSING_POSTER)

	Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, function(_, slot, coll)
		if slot.SubType == 0 then
			slotCollision(slot, coll)
		end
	end, Mod.Enum.Slot.MISSING_POSTER)

	Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, function(_, slot)
		if slot.SubType == 0 then
			missingPostUpdate(slot)
		elseif slot.SubType == 1 then
			beggarUpdate(slot)
		end
	end, Mod.Enum.Slot.MISSING_POSTER)

	Mod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, function(_, slot)
		if slot.SubType == 0 then
			missingPostKill(slot)
		elseif slot.SubType == 1 then
			beggarKill(slot)
		end
		return false
	end, Mod.Enum.Slot.MISSING_POSTER)
else

	Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_, player)

		for _, slot in pairs(Isaac.FindByType(6, Mod.Enum.Slot.MISSING_POSTER)) do
			if not Mod:GetEntityData(slot, "Slot init", false) then
				local sub = (posterSave:Get({}).FamSubType or 0) +1
				if slot.SubType == 0 then
					local sp = slot:GetSprite()
					sp:ReplaceSpritesheet(3, FAMILIAR_SPRITE_RUTE[sub])
					sp:LoadGraphics()
					
					local data = posterSave:Get({})
					if data.StopFutureQuest or data.ActiveQuest then
						sp:Play("IdleNoPaper", true)
					end
				elseif slot.SubType == 1 then
					local sp = slot:GetSprite()
					sp:ReplaceSpritesheet(2, FAMILIAR_SPRITE_RUTE[sub])
					sp:LoadGraphics()
				end
				Mod:SetEntityData(slot, "Slot init", true)
			end

			if slot.SubType == 0 then
				missingPostUpdate(slot)
			elseif slot.SubType == 1 then
				beggarUpdate(slot)
			end

			if slot.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND and not Mod:GetEntityData(slot, "Slot Explode Check", false) then

				if slot.SubType == 0 then
					missingPostKill(slot)
				elseif slot.SubType == 1 then
					beggarKill(slot)
				end

				Mod:SetEntityData(slot, "Slot Explode Check", true)

			elseif slot.SubType == 0 then
				for i=0, game:GetNumPlayers()-1 do
					local player = Isaac.GetPlayer(i)

					if player.Variant == 0 and slot.Position:DistanceSquared(player.Position) <= (slot.Size + player.Size) ^ 2 then
						slotCollision(slot, player)
					end
				end
			end
		end
	end)
end


--- Get Familiar Logic

local SpawnFamiliarRNG = RNG()
local function SpawnFamiliar()
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then return end

	local data = posterSave:Get({})
	local room = level:GetCurrentRoom()
	if not data.ActiveQuest or not room:IsFirstVisit() or data.FamRoom ~= nil then return end
	SpawnFamiliarRNG:SetSeed(room:GetDecorationSeed(), 35)
	local roomsLeft = data.LevelRoomAmount
	if roomsLeft == nil then return end
	
	data.LevelRoomAmount = data.LevelRoomAmount -1

	if roomsLeft <= 0 or SpawnFamiliarRNG:RandomInt( roomsLeft ) == 0 then
		local desc = level:GetCurrentRoomDesc()
		local gridIndex = desc.SafeGridIndex
		if gridIndex < 0 then return end
		
		if data.FamSubType == FAMILIAR_SUBTYPES.NULL then
			data.FamRoom = gridIndex

			local list = pTools.GetCurrentPlayers()
			local player = list[ SpawnFamiliarRNG:RandomInt(#list) +1]
			player:GetEffects():AddCollectibleEffect(Mod.Enum.Item.MISSING_HANDLER, 1)
		elseif data.FamSubType == FAMILIAR_SUBTYPES.ANGRY then
			if not room:IsClear() then
				data.FamRoom = gridIndex
			end
		elseif data.FamSubType == FAMILIAR_SUBTYPES.SHY then
			local count = 0
			local door = level.EnterDoor
			if door > -1 then
				local playerStart = room:GetDoorSlotPosition(door)

				local rocksTab = {}
				for i=0, room:GetGridSize()-1 do
					local grid = room:GetGridEntity(i)
					if grid and grid:ToRock() and grid.State == 1 then
						local pos = grid.Position
						for i=1, #dirPathCheck do
							local checkPos = pos + dirPathCheck[i]
							if room:GetGridPathFromPos(checkPos) <= 950 and FindPath(room, checkPos, playerStart) then
								table.insert(rocksTab, pos)
							end
						end
					end
				end

				if #rocksTab > 0 then
					rocksTab = Mod.TableTools.Shuffle(rocksTab, SpawnFamiliarRNG)
					
					data.FamRoom = gridIndex
					data.ExtraInfo = rocksTab[1]
				end
			end
		elseif data.FamSubType == FAMILIAR_SUBTYPES.FRIENDLY then
			data.FamRoom = gridIndex
			data.ExtraInfo = SpawnFamiliarRNG:RandomInt(360)
		end
	end
	posterSave:Set(data)
end



local function setFamSpritesheet(sp, sub)
	sp:ReplaceSpritesheet(0, FAMILIAR_SPRITE_RUTE[sub+1])
	sp:LoadGraphics()
end
local SpawnFriendlyPos = Vector(920, 0)
local function HandleFamLoading()
	local data = posterSave:Get({})
	if not data.ActiveQuest or data.FamRoom == nil then return end
	local level = game:GetLevel()
	local desc = level:GetCurrentRoomDesc()
	if data.FamRoom ~= desc.SafeGridIndex or data.PlayerHasFam then return end

	local room = level:GetCurrentRoom()
	if data.FamSubType == FAMILIAR_SUBTYPES.ANGRY then
		local ent = Mod:Spawn(EntityType.ENTITY_SPIDER, Mod.Enum.NPC.MISSING_NPC, 0, room:GetCenterPos(), Vector.Zero)
		
	elseif data.FamSubType == FAMILIAR_SUBTYPES.SHY then
		local ent = Mod:Spawn(1000, Mod.Enum.Effect.FAM_RENDER, data.FamSubType, data.ExtraInfo+ Vector(0,-10), Vector.Zero)
		
	elseif data.FamSubType == FAMILIAR_SUBTYPES.FRIENDLY then
		local pos = room:GetCenterPos()
		if room:IsFirstVisit() then
			pos = pos + Vector((room:GetGridHeight() + room:GetGridWidth()) *40 /2 *1.25, 0):Rotated(data.ExtraInfo)
		end

		local ent = Mod:Spawn(1000, Mod.Enum.Effect.FAM_RENDER, data.FamSubType, pos, Vector.Zero)
	end
end


Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	SpawnSlot()
	SpawnFamiliar()
	HandleFamLoading()
	fakeFamLastPos = nil

	for _, e in ipairs(Isaac.FindByType(3, Mod.Enum.Familiar.MISSING_FAM)) do
		e.Visible = true
	end
end)


local function giveFam(player, fakeFam)
	fakeFamLastPos = fakeFam.Position
	player:GetEffects():AddCollectibleEffect(Mod.Enum.Item.MISSING_HANDLER)
	fakeFam:Remove()
	local data = posterSave:Get({})
	data.PlayerHasFam = true
	posterSave:Set(data)
end

local CLOSE_MAX_TIMER = 60
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, fakeFam)
	local sp = fakeFam:GetSprite()
	if fakeFam.FrameCount == 0 then setFamSpritesheet(sp, fakeFam.SubType) end
	
	if fakeFam.SubType == FAMILIAR_SUBTYPES.ANGRY then
		local ent = Mod:Spawn(EntityType.ENTITY_SPIDER, Mod.Enum.NPC.MISSING_NPC, 0, room:GetCenterPos(), Vector.Zero)
		setFamSpritesheet(ent:GetSprite(), FAMILIAR_SUBTYPES.ANGRY)
		fakeFam:Remove()
	elseif fakeFam.SubType == FAMILIAR_SUBTYPES.SHY then
		local room = game:GetRoom()
		local spawnPos = posterSave:Get({}).ExtraInfo
		local grid = room:GetGridEntityFromPos(spawnPos)
		local player = game:GetNearestPlayer( spawnPos )

		if not grid or not grid:ToRock() or grid.State == 2 then
			giveFam(player, fakeFam)
			return
		end

		local closeFrameCount = (fakeFam.State or 0)
		if player.Position:Distance(spawnPos) <= 60 then
			closeFrameCount = closeFrameCount +1
		else
			closeFrameCount = math.max(closeFrameCount-1, 0)
		end
		
		local color = fakeFam.Color
		color.A = math.min((closeFrameCount +20) / CLOSE_MAX_TIMER, 1)
		fakeFam.Color = color

		if closeFrameCount >= CLOSE_MAX_TIMER then
			giveFam(player, fakeFam)
			SFX:Play(SoundEffect.SOUND_THUMBSUP)
		else
			fakeFam.State = closeFrameCount
		end

	elseif fakeFam.SubType == FAMILIAR_SUBTYPES.FRIENDLY then
		local player = game:GetNearestPlayer(fakeFam.Position)
		local angle = (player.Position - fakeFam.Position):GetAngleDegrees()
		fakeFam.Velocity = FAM_SPEED:Rotated(angle)

		if fakeFam.Position:Distance(player.Position) < 60 then
			giveFam(player, fakeFam)
			SFX:Play(SoundEffect.SOUND_THUMBSUP)
		end
	end

end, Mod.Enum.Effect.FAM_RENDER)




local projectileParam = ProjectileParams()
local DONOTHING_TIME = 90
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_, fakeFam)

	if fakeFam.Variant == Mod.Enum.NPC.MISSING_NPC then
		
		if fakeFam.Target == nil or fakeFam:IsFrame(10, 0) then
			fakeFam.Target = game:GetNearestPlayer(fakeFam.Position)
		end
		local target = fakeFam.Target
		local angle = ((target.Position - fakeFam.Position):GetAngleDegrees()+360) % 360
		local distance = target.Position:Distance(fakeFam.Position)

		if distance < 120 then
			fakeFam.Velocity = Mod:Lerp( fakeFam.Velocity, FAM_SPEED:Rotated(angle -180), 0.1)
		else
			fakeFam.Velocity = Mod:Lerp( fakeFam.Velocity, FAM_SPEED:Rotated(angle), 0.1)
		end
		
		
		local famFrameCount = fakeFam.FrameCount
		local fireCooldown = fakeFam.ProjectileCooldown
		if famFrameCount > DONOTHING_TIME then
			if fireCooldown <= 0 and distance < 120 then
				local proj = fakeFam:FireProjectiles(fakeFam.Position, SHOT_VEL:Rotated(angle), 0, projectileParam)
				fakeFam.ProjectileCooldown = FAMILIAR_FIRECOOLDOWN[FAMILIAR_SUBTYPES.ANGRY]
			else
				local sp = fakeFam:GetSprite()
				if fireCooldown < 15 then
					if angle <= 45 or angle >= 315 then
						sp:SetAnimation("IdleRight", false)
					elseif angle > 45 and angle < 135 then
						sp:SetAnimation("IdleDown", false)
					elseif angle >= 135 and angle <= 225 then
						sp:SetAnimation("IdleLeft", false)
					elseif angle > 225 and angle < 315 then
						sp:SetAnimation("IdleUp", false)
					end
				else
					if angle <= 45 or angle >= 315 then
						sp:SetAnimation("ShootRight", false)
					elseif angle > 45 and angle < 135 then
						sp:SetAnimation("ShootDown", false)
					elseif angle >= 135 and angle <= 225 then
						sp:SetAnimation("ShootLeft", false)
					elseif angle > 225 and angle < 315 then
						sp:SetAnimation("ShootUp", false)
					end
				end
				if fireCooldown > 0 then
					fakeFam.ProjectileCooldown = fireCooldown-1
				end
			end
		end
		return true
	end
end, EntityType.ENTITY_SPIDER)
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
	if npc.Variant ~= Mod.Enum.NPC.MISSING_NPC then return end
	fakeFamLastPos = npc.Position
	game:GetNearestPlayer(npc.Position):GetEffects():AddCollectibleEffect(Mod.Enum.Item.MISSING_HANDLER)
	SFX:Play(SoundEffect.SOUND_THUMBSUP)
	
	local data = posterSave:Get({})
	data.PlayerHasFam = true
	posterSave:Set(data)

end, EntityType.ENTITY_SPIDER)