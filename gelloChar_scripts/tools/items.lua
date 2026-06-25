local Mod = GelloCharMod
local game = Mod.Game

function GelloCharMod:IsQuestItem(itemID)
	return Isaac.GetItemConfig():GetCollectible(itemID):HasTags(ItemConfig.TAG_QUEST)
end

function GelloCharMod:IsActiveItem(itemID)
	return Isaac.GetItemConfig():GetCollectible(itemID).Type == ItemType.ITEM_ACTIVE
end

function GelloCharMod:IsNoRerollItem(itemID)
	return CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE == itemID or CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE == itemID
end

function GelloCharMod:CanGenerateWisps(flags)
	return UseFlag.USE_NOANIM & flags == 0 and UseFlag.USE_ALLOWWISPSPAWN & flags > 0
end


function GelloCharMod:GetFreeGroup()
	local groupIndex = 1

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		local pickup = ent:ToPickup()
		if pickup.OptionsPickupIndex >= groupIndex then
			groupIndex = pickup.OptionsPickupIndex +1
		end
	end

	return groupIndex
end


function GelloCharMod:SpawnItem(itemID, position, spawner)
	Mod:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, position, Vector.Zero, nil)
	return Mod:Spawn(5, 100, itemID, position, Vector.Zero, spawner):ToPickup()
end


local config = Isaac.GetItemConfig()
function GelloCharMod:TrySpawnItem(itemID, position, spawner, ignorePool, ignoreModifires)
	local ignorePool = ignorePool or false
	local ignoreModifires = ignoreModifires or false

	local ignoreActives = false
	local goodQualityOnly = false
	local noLostBR = false
	local noKeeper = false
	local noGreedMode = false
	local offensiveOnly = false


	if not ignoreModifires then
		ignoreActives = Mod.PlayerTools.AnyPlayerHasTrinket(TrinketType.TRINKET_NO)
		goodQualityOnly = Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB)
		noLostBR = Mod.PlayerTools.PlayerTypeHasCollectible(PlayerType.PLAYER_THELOST, CollectibleType.COLLECTIBLE_BIRTHRIGHT)
		noKeeper = Mod.PlayerTools.IsPlayerPresent({PlayerType.PLAYER_KEEPER, PlayerType.PLAYER_KEEPER_B})
		noGreedMode = game:IsGreedMode()
		offensiveOnly = Mod.PlayerTools.IsPlayerPresent(PlayerType.PLAYER_THELOST_B)

		
		if ignoreActives and config:GetCollectible(itemID).Type == ItemType.ITEM_ACTIVE then return nil
		elseif noGreedMode and config:GetCollectible(itemID):HasTags(ItemConfig.TAG_NO_GREED) then return nil
		elseif noLostBR and config:GetCollectible(itemID):HasTags(ItemConfig.TAG_NO_LOST_BR) then return nil
		elseif noKeeper and config:GetCollectible(itemID):HasTags(ItemConfig.TAG_NO_KEEPER) then return nil
		elseif offensiveOnly and config:GetCollectible(itemID):HasTags(ItemConfig.TAG_OFFENSIVE) then return nil
		elseif goodQualityOnly and config:GetCollectible(itemID).Quality < 2 then return nil end
	end

	if ignorePool or game:GetItemPool():RemoveCollectible(itemID) then
		Mod:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, position, Vector.Zero, nil)
		return Mod:Spawn(5, 100, itemID, position, Vector.Zero, spawner):ToPickup()
	end
end


--- base from Epiphany ---
function GelloCharMod:GetChoiceGroup(pickup)
	if pickup.OptionsPickupIndex == 0 then return {} end
	local group = {}

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		local entPickup = ent:ToPickup()
		if pickup.OptionsPickupIndex == entPickup.OptionsPickupIndex and GetPtrHash(pickup) ~= GetPtrHash(entPickup) then
			table.insert(group, entPickup)
		end
	end

	return group
end


--- copy from Epiphany ---
function GelloCharMod:RemovePickup(pickup, sound, soundLevel, doPoofEffect)
	GelloCharMod:TryStartAmbush()
	local doPoofEffect = doPoofEffect or false
	
	if sound then
		Mod.SFX:Play(sound, (soundLevel or 1))
	else
		pickup:PlayPickupSound()
	end
	pickup.Velocity = Vector.Zero
	pickup.EntityCollisionClass = 0
	if pickup:Exists() and doPoofEffect then
		local effect = Mod:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):ToEffect()
		effect.Timeout = pickup.Timeout
	end
	local sprite = pickup:GetSprite()
	sprite:Load(pickup:GetSprite():GetFilename(), false)
	sprite:LoadGraphics()
	sprite:Play("Collect", true)

	for _, ent in pairs(GelloCharMod:GetChoiceGroup(pickup)) do
		Mod:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)
		ent:Remove()
	end
	pickup:Remove()
end



--- Copy from Fiend Folio
function GelloCharMod:AttractPickup(pickup, chaceCond)
	local chaceCond = chaceCond or function() return true end
	local ClosestPlayer = nil
	local Distance = 9999999
	Mod.PlayerTools.ForEach(function(player)
		if not (player:HasCollectible(CollectibleType.COLLECTIBLE_MAGNETO) or
			player:HasTrinket(TrinketType.TRINKET_SUPER_MAGNET) or
			(Mod.Repentogon and player:HasGoldenTrinket(TrinketType.TRINKET_BROKEN_MAGNET))) then return end
		
		if not chaceCond(player, pickup) then return end

		local PlayerDist = pickup.Position:Distance(player.Position)
		if not ClosestPlayer or Distance > PlayerDist then
			ClosestPlayer = player
			Distance = PlayerDist
		end
	end)

	if ClosestPlayer then
		local Vel = (ClosestPlayer.Position - pickup.Position):Resized(2)
		pickup.Velocity = GelloCharMod:Lerp(pickup.Velocity, Vel, 0.2)

		local ogColl = Mod:GetEntityData(pickup, "PickupOGCollision", nil) or pickup.GridCollisionClass
		Mod:SetEntityData(pickup, "PickupOGCollision", coll)

		pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

	elseif Mod:GetEntityData(pickup, "PickupOGCollision", nil) then
		pickup.GridCollisionClass = Mod:GetEntityData(pickup, "PickupOGCollision", nil)
		Mod:SetEntityData(pickup, "PickupOGCollision", nil)
	end
end



if Mod.Repentogon then
function GelloCharMod:GetRoomPool()
	local pool = game:GetRoom():GetItemPool(Mod.RunSeed)

	if pool == ItemPoolType.POOL_NULL then
		if game:IsGreedMode() then
			pool = ItemPoolType.POOL_GREED_TREASURE
		else
			pool = ItemPoolType.POOL_TREASURE
		end
	end

	return pool
end
else
function GelloCharMod:GetRoomPool()
	local room = game:GetRoom()
	local rType = room:GetType()
	local level = game:GetLevel()
	local pool = game:GetItemPool():GetPoolForRoom(rType, Mod.RunSeed)

	if pool == ItemPoolType.POOL_NULL then
		if game:IsGreedMode() then
			pool = ItemPoolType.POOL_GREED_TREASURE
		else
			pool = ItemPoolType.POOL_TREASURE
		end
	end

	if rType == RoomType.ROOM_CHALLENGE and level:HasBossChallenge() then
		pool = ItemPoolType.POOL_BOSS
	end

	if rType == RoomType.ROOM_BOSS and (level:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED) or room:GetBossID() == 23) then -- boss 23 == fallen
		pool = ItemPoolType.POOL_DEVIL
	end

	if game:IsGreedMode() and level:GetCurrentRoomIndex() == 98 then
		pool = ItemPoolType.POOL_GREED_BOSS
	end

	return pool
end
end


function GelloCharMod:GetGlobalCollectibleNum(ItemID)
	local num = 0
	Mod.PlayerTools.ForEach(function(player)
		if player:HasCollectible(ItemID) then
			num = num + player:GetCollectibleNum(ItemID)
		end
	end)

	return num
end



function GelloCharMod:GetGlobalTrinketMultiplier(TrinketID, ExcludeMomsBox)
	local ExcludeMomsBox = ExcludeMomsBox or false
	local Mult = 0
	Mod.PlayerTools.ForEach(function(player)
		if player:HasTrinket(TrinketID | TrinketType.TRINKET_GOLDEN_FLAG) then
			Mult = Mult + player:GetTrinketMultiplier(TrinketID)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and ExcludeMomsBox then
				Mult = Mult -1
			end
		end
	end)

	return Mult
end



function GelloCharMod:IsHorsePill(Pill)
	return Pill & PillColor.PILL_GIANT_FLAG > 0
end


local PressentPools = {
	Normal = {
		ItemPoolType.POOL_TREASURE,
		ItemPoolType.POOL_SHOP,
		ItemPoolType.POOL_BOSS,
		ItemPoolType.POOL_DEVIL,
		ItemPoolType.POOL_ANGEL,
		ItemPoolType.POOL_SECRET,
		ItemPoolType.POOL_LIBRARY,
		ItemPoolType.POOL_GOLDEN_CHEST,
		ItemPoolType.POOL_RED_CHEST,
		ItemPoolType.POOL_BEGGAR,
		ItemPoolType.POOL_DEMON_BEGGAR,
		ItemPoolType.POOL_CURSE,
		ItemPoolType.POOL_KEY_MASTER,
		ItemPoolType.POOL_BATTERY_BUM,
		--ItemPoolType.POOL_MOMS_CHEST,
		ItemPoolType.POOL_CRANE_GAME,
		ItemPoolType.POOL_ULTRA_SECRET,
		ItemPoolType.POOL_BOMB_BUM,
		ItemPoolType.POOL_PLANETARIUM,
		ItemPoolType.POOL_OLD_CHEST,
		ItemPoolType.POOL_BABY_SHOP,
		ItemPoolType.POOL_WOODEN_CHEST,
		ItemPoolType.POOL_ROTTEN_BEGGAR,
	},
	Greed = {
		ItemPoolType.POOL_GREED_TREASURE,
		ItemPoolType.POOL_GREED_SHOP,
		ItemPoolType.POOL_GREED_BOSS,
		ItemPoolType.POOL_GREED_DEVIL,
		ItemPoolType.POOL_GREED_ANGEL,
		ItemPoolType.POOL_GREED_CURSE,
		ItemPoolType.POOL_GREED_SECRET,
		ItemPoolType.POOL_GOLDEN_CHEST,
		ItemPoolType.POOL_RED_CHEST,
		ItemPoolType.POOL_BEGGAR,
		ItemPoolType.POOL_DEMON_BEGGAR,
		ItemPoolType.POOL_KEY_MASTER,
		ItemPoolType.POOL_BATTERY_BUM,
		ItemPoolType.POOL_CRANE_GAME,
		ItemPoolType.POOL_ULTRA_SECRET,
		ItemPoolType.POOL_BOMB_BUM,
		ItemPoolType.POOL_OLD_CHEST,
		ItemPoolType.POOL_BABY_SHOP,
		ItemPoolType.POOL_WOODEN_CHEST,
		ItemPoolType.POOL_ROTTEN_BEGGAR,
	}
}
local roomPoolRNG = RNG()
function GelloCharMod:GetRandomPool(ignoreGreedPool, seed)
	local ignoreGreedPool = ignoreGreedPool or false
	if seed then roomPoolRNG:SetSeed(seed, 30); roomPoolRNG:Next(); roomPoolRNG:Next() end

	if not ignoreGreedPool and game:IsGreedMode() then
		if seed then return PressentPools.Greed[ Mod:RandomInt(1, #PressentPools.Greed, roomPoolRNG) ] end
		return PressentPools.Greed[ Mod:RandomInt(1, #PressentPools.Greed) ]
	end
	if seed then return PressentPools.Normal[ Mod:RandomInt(1, #PressentPools.Normal, roomPoolRNG) ] end
	return PressentPools.Normal[ Mod:RandomInt(1, #PressentPools.Normal) ]
end



function GelloCharMod:GetRandomTrinket(dontAdvanceRNG, forceGolden)
	local dontAdvanceRNG = dontAdvanceRNG or false
	local forceGolden = forceGolden or false

	local trinketID = game:GetItemPool():GetTrinket(dontAdvanceRNG)

	if forceGolden and trinketID & TrinketType.TRINKET_GOLDEN_FLAG == 0 then
		trinketID = trinketID + TrinketType.TRINKET_GOLDEN_FLAG
	end

	return trinketID
end



function GelloCharMod:GetRandomCollectible(pool, decrease, seed, default, ignoreRoomPool, ignoreGreedPool)
	local pool = pool or -1
	local decrease = decrease or true
	local gamePools = game:GetItemPool()

	local seed = seed or Random()
	if seed < 1 then
		seed = Random()
		if seed < 1 then seed = 1 end
	end

	if pool < 0 then
		if not ignoreRoomPool then
			pool = Mod:GetRoomPool()
		else
			pool = Mod:GetRandomPool(ignoreGreedPool, seed)
		end
	end

	return gamePools:GetCollectible( pool, decrease, seed, (default or CollectibleType.COLLECTIBLE_NULL) )
end



function GelloCharMod:GenerateGlitchItems(amount, generationType)
	local amount = amount or 1
	local generationType = Mod:Clamp((generationType or 0), 0, 2)
	local player = Isaac.GetPlayer()
	if amount < 1 then return {} end

	local list = {}
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER, 0, false)
	while #list < amount do
		local item = game:GetItemPool():GetCollectible(0)
		local itemType = ItemConfig(item).Type
		if generationType == 1 then
			if itemType ~= ItemType.ITEM_ACTIVE then
				table.insert(list, item)
			end
		elseif generationType == 2 then
			if itemType == ItemType.ITEM_ACTIVE then
				table.insert(list, item)
			end
		else
			table.insert(list, item)
		end
	end
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)

	return list
end
