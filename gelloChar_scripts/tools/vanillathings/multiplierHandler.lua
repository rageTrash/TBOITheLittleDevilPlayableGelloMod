local VERSION = 1.171
local YOUR_MOD = GelloCharMod

if YOUR_MOD == nil then
	error("MultiplierHandler.Mod is nil")
	return
end

if MultiplierHandler and MultiplierHandler.Version ~= nil and MultiplierHandler.Version >= VERSION then return end

MultiplierHandler = MultiplierHandler or {}
MultiplierHandler.Version = VERSION
MultiplierHandler.CacheData = MultiplierHandler.CacheData or {}
if MultiplierHandler.Mod == nil then
	MultiplierHandler.Mod = YOUR_MOD
else
	if MultiplierHandler.EpiphoraTracker then
		MultiplierHandler.Mod:RemoveCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MultiplierHandler.EpiphoraTracker)
	end

	MultiplierHandler.Mod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, MultiplierHandler.RemoveCacheEntityData)
	MultiplierHandler.Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, MultiplierHandler.ClearCache)
	MultiplierHandler.Mod = YOUR_MOD
end

if MultiplierHandler.Game == nil then MultiplierHandler.Game = Game() end
local game = MultiplierHandler.Game

local epiphoraFrameMult = 1/270
local epiphoraFrameMult_RepPlus = 1/180


local defaultStats = {
	DAMAGE = 3.5,
	TEARS = 2.73,
	SPEED = 1,
	RANGE = 6.5,
	SHOTSPEED = 1,
	LUCK = 0
}


MultiplierHandler.MultiplierGroupType = {
	GROUP_CRICKETSHEAD_DMG = 1, GROUP_MAGICMUSH_DMG = 1,
	GROUP_IPECAC_RANGE = 2, GROUP_CRICKETSBODY_RANGE = 2,
	GROUP_FORGOTTEN_TEARS = 3, GROUP_BERSERK_TEARS = 3
}

local MultGroupType = MultiplierHandler.MultiplierGroupType



local function HasItem(player, itemID)
	return player:HasCollectible(itemID)
end

local function HasItemEffect(player, itemID)
	return player:GetEffects():HasCollectibleEffect(itemID)
end

local function HasItemXNumber(player, itemID, min, max)
	local min = min or 0
	local max = max or 9999999999999
	if min > max then
		local tran = max
		max = min
		min = tran
	end
	local totalNum = player:GetCollectibleNum(itemID)

	return totalNum >= min and totalNum <= max
end

local function HasItemEffectXNumber(player, itemID, min, max)
	local min = min or 0
	local max = max or 9999999999999
	if min > max then
		local tran = max
		max = min
		min = tran
	end
	local totalNum = player:GetEffects():GetCollectibleNum(itemID)

	return totalNum >= min and totalNum <= max
end


local function HasTrinket(player, itemID)
	return player:HasTrinket(itemID)
end

local function HasTrinketEffect(player, itemID)
	return player:GetEffects():HasTrinketEffect(itemID)
end


local function HasNull(player, itemID)
	return player:GetEffects():HasNullEffect(itemID)
end


local function HasTrinketXNumber(player, itemID, min, max)
	local min = min or 0
	local max = max or 9999999999999
	if min > max then
		local tran = max
		max = min
		min = tran
	end
	local totalNum = player:GetTrinketNum(itemID)

	return totalNum >= min and totalNum <= max
end

local function HasTrinketEffectXNumber(player, itemID, min, max)
	local min = min or 0
	local max = max or 9999999999999
	if min > max then
		local tran = max
		max = min
		min = tran
	end
	local totalNum = player:GetEffects():GetTrinketNum(itemID)

	return totalNum >= min and totalNum <= max
end


local function IsPlayerType(player, pTypes)
	local checkTypes = checkTypes
	if type(checkTypes) ~= "table" then checkTypes = {checkTypes} end
	local pType = player:GetPlayerType()

	for _, cType in ipairs(checkTypes) do
		if pType == cType then return true end
	end
	return false
end

local cache_GetData = {}
local function getData(ent, key)
	if not ent then return end
	local ptr = GetPtrHash(ent)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end

	local data = cache_GetData[ptr] or {}
	local val = data[key]

	return val ~= nil and val
end

local function setData(ent, key, val)
	if not ent then return end
	local ptr = GetPtrHash(ent)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end

	local data = cache_GetData[ptr] or {}
	data[key] = val
	
	cache_GetData[ptr] = data
end
MultiplierHandler.RemoveCacheEntityData = function(_, ent) cache_GetData[ GetPtrHash(ent) ] = nil end
MultiplierHandler.ClearCache = function() cache_GetData = {} end
MultiplierHandler.Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 10000, MultiplierHandler.RemoveCacheEntityData)
MultiplierHandler.Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, MultiplierHandler.ClearCache)





local playerDmgMult = {
	[PlayerType.PLAYER_CAIN] = 1.2,
	[PlayerType.PLAYER_JUDAS] = 1.35,
	[PlayerType.PLAYER_BLUEBABY] = 1.05,
	--[PlayerType.PLAYER_EVE] = function (player)
	--	if HasItemEffect(player, CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then return 1 end
	--	return 0.75
	--end,
	[PlayerType.PLAYER_AZAZEL] = 1.5,
	[PlayerType.PLAYER_LAZARUS2] = 1.4,
	[PlayerType.PLAYER_BLACKJUDAS] = 2,
	[PlayerType.PLAYER_KEEPER] =  1.2,
	[PlayerType.PLAYER_THEFORGOTTEN] = 1.5,

	-- Tainted Characters
	[PlayerType.PLAYER_MAGDALENE_B] = 0.75,
	[PlayerType.PLAYER_CAIN_B] = 1.2,
	[PlayerType.PLAYER_EVE_B] = 1.2,
	[PlayerType.PLAYER_AZAZEL_B] = 1.5,
	[PlayerType.PLAYER_THELOST_B] = 1.3,
	[PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
	[PlayerType.PLAYER_LAZARUS2_B] = 1.5,
}

local playerTearsMult = {
	[PlayerType.PLAYER_AZAZEL] = 0.267,
	[PlayerType.PLAYER_THEFORGOTTEN] = 0.5,

	-- Tainted Characters
	[PlayerType.PLAYER_EVE_B] = 0.66,
	[PlayerType.PLAYER_AZAZEL_B] = 1/3,
	[PlayerType.PLAYER_THEFORGOTTEN_B] = 0.5,
}





local multGroup = {
	[MultGroupType.GROUP_CRICKETSHEAD_DMG] = function(player)
		return (HasItem(player, CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR) and HasItemEffect(player, CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL)) or
			HasItem(player, CollectibleType.COLLECTIBLE_CRICKETS_HEAD) or HasItem(player, CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
	end,
	[MultGroupType.GROUP_IPECAC_RANGE] = function(player)
		return HasItem(player, CollectibleType.COLLECTIBLE_HAEMOLACRIA) or
			HasItem(player, CollectibleType.COLLECTIBLE_IPECAC) or
			HasItem(player, CollectibleType.COLLECTIBLE_CRICKETS_BODY)
	end,
	[MultGroupType.GROUP_FORGOTTEN_TEARS] = function(player)
		local pType = player:GetPlayerType()
		return HasItemEffect(player, CollectibleType.COLLECTIBLE_BERSERK) or IsPlayerType(player, {PlayerType.PLAYER_THEFORGOTTEN, PlayerType.PLAYER_THEFORGOTTEN_B})
	end
}



function MultiplierHandler:HasMultiplierGroup(player, multGroupType)
	local fun = multGroup[multGroupType]
	return fun and fun(player) or false
end

--[[ -- i test this with 10000 cache callbacks (for each stat (at the same time (so like 60000 callbacks in total) ) ) and the game get frozen for like 1-2 seconds but with the hallowed effect it was a little longer
local HolyCreepFlag = (1<<6)
function MultiplierHandler:InHallowMultRange(player)
	local data = player:GetData()._MultiplierHandler_HallowMult_Cache or {}
	local frameCount = game:GetFrameCount()
	if data.UpdateFrame and data.UpdateFrame >= frameCount then return data.InHallowRange, data.InStarBethRange end -- is updated every even frame just to not tank to much the frames
	local hallow = false
	local starBeth = false
	local checkCreep = false
	local isDone = false
	local room = game:GetRoom()

	for _, ent in ipairs( Isaac.FindByType(3, 236) ) do
		if ent.Position:Distance(player.Position) <= 68 then
			starBeth = true
			hallow = true

			isDone = true
			break
		end
	end

	if not isDone then
		for _, ent in ipairs(Isaac.FindByType(1000, EffectVariant.HALLOWED_GROUND) ) do
			local spawner = ent.SpawnerEntity
			if spawner == nil then
				if ent.Position:Distance(player.Position) <= 80 then
					local grid = room:GetGridEntityFromPos(ent.Position)
					if grid and grid:GetType() == 14 and grid:GetVariant() == 6 then
						hallow = true
						break
					end
				end

			elseif spawner.Type == 3 then
				if spawner.Variant == 236 then
				elseif spawner.Variant == 201 and spawner.SubType == 6 and spawner.Position:Distance(player.Position) <= 32.55 then
					hallow = true
					break
				end
			elseif spawner.Type == 245 and spawner.Variant == 16  then
				if spawner.Position:Distance(player.Position) <= 80 then
					hallow = true
					break
				else
					checkCreep = true
				end
			end
		end

		if checkCreep and not hallow then
			for _, ent in ipairs(Isaac.FindByType(1000, EffectVariant.CREEP_LIQUID_POOP)) do
				if ent:ToEffect().State & HolyCreepFlag > 0 and ent.Position:Distance(player.Position) <= 20 then
					hallow = true
					break
				end
			end
		end
	end

	data.UpdateFrame = frameCount +2
	data.InHallowRange = hallow
	data.InStarBethRange = starBeth
	player:GetData()._MultiplierHandler_HallowMult_Cache = data

	return data.InHallowRange, data.InStarBethRange
end
]]


function MultiplierHandler:GetPlayerTearCap(player)
	return MultiplierHandler:GetPlayerTearsMult(player) * 5
end




local damageTableCheck = {
	{Name = "HasCricketGroup",       Fun = function(player, data) return MultiplierHandler:HasMultiplierGroup(player, MultGroupType.GROUP_CRICKETSHEAD_DMG) end},
	{Name = "HasHaemolacria",        Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_HAEMOLACRIA) end},
	{Name = "HasBrimstone",          Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_BRIMSTONE) end},
	{Name = "HasKnife",              Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_MOMS_KNIFE) end},
	{Name = "HasDoubleBrim",         Fun = function(player, data) return not data.HasKnife and HasItemXNumber(player, CollectibleType.COLLECTIBLE_BRIMSTONE, 2) end},
	{Name = "HasTechnology",         Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_TECHNOLOGY) end},
	{Name = "HasAlmondMilk",         Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_ALMOND_MILK) end},
	{Name = "HasSoyMilk",            Fun = function(player, data) return not data.HasAlmondMilk and HasItem(player, CollectibleType.COLLECTIBLE_SOY_MILK) end},
	{Name = "Has2020",               Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_20_20) end},
	{Name = "HasPoly",               Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_POLYPHEMUS) and not (HasItem(player, CollectibleType.COLLECTIBLE_C_SECTION) or  HasItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER) or HasItem(player, CollectibleType.COLLECTIBLE_INNER_EYE) ) end},
	{Name = "HasCrownOfLightEffect", Fun = function(player, data) return HasItemEffect(player, CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) end},
	{Name = "HasThinMush",           Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN) end},
	{Name = "HasSacredHeart",        Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_SACRED_HEART) end},
	{Name = "HasEvesMascara",        Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_IMMACULATE_HEART) end},
	{Name = "HasMegaMush",           Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_EVES_MASCARA) end},
	{Name = "HasImmaculateHeart",    Fun = function(player, data) return HasItemEffect(player, CollectibleType.COLLECTIBLE_MEGA_MUSH) end},

	{Name = "EveWhoreOfBabylon",     Fun = function(player, data) return player:GetPlayerType() == PlayerType.PLAYER_EVE and not HasItemEffect(player, CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) end},
	{Name = "JudasDamoclesBirthright", Fun = function(player, data) return IsPlayerType(player, {PlayerType.PLAYER_JUDAS, PlayerType.PLAYER_BLACKJUDAS}) and HasItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and HasItem(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) end},
	{Name = "AzazelApplySpecialMult", Fun = function(player, data) return IsPlayerType(player, {PlayerType.PLAYER_AZAZEL, PlayerType.PLAYER_AZAZEL_B}) and not (data.HasBrimstone or data.HasKnife) end},
	{Name = "AzazelTechX",           Fun = function(player, data) return data.AzazelApplySpecialMult and HasItem(player, CollectibleType.COLLECTIBLE_TECH_X) end},
	{Name = "AzazelLudo",            Fun = function(player, data) return data.AzazelApplySpecialMult and HasItem(player, CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) end},
	{Name = "AzazelTechnology",      Fun = function(player, data) return data.AzazelApplySpecialMult and data.HasTechnology end},
}

local function shouldUpdateDamageMult(player)
	local data = getData(player, "DAMAGE") or {}
	local updateData = data.MultState or {}

	local lastFrameUpdate = data.FrameUpdate or -1
	local gameFrame = game:GetFrameCount()
	if gameFrame == lastFrameUpdate then return false end
	data.FrameUpdate = gameFrame

	local update = false

	for i=1, #damageTableCheck do
		local name = damageTableCheck[i].Name
		local val = damageTableCheck[i].Fun(player, updateData)
		if not updateData[name] or updateData[name] ~= val then update = true end
		updateData[name] = val
	end
	data.MultState = updateData
	setData(player, "DAMAGE", data) 

	return update
end


local function getVarialMultDamage(player)
	if player:IsDead() then return 1 end
	local data = getData(player, "DAMAGE") or {}
	local multState = data.MultState or {}

	--local InHallowRange, InStarBethRange = MultiplierHandler:InHallowMultRange(player)

	local mult = 1
	if HasTrinket(player, TrinketType.TRINKET_CRACKED_CROWN) and player.Damage > defaultStats.DAMAGE then
		mult = mult * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN) * 0.2))
	end

	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player.Damage > defaultStats.DAMAGE then
		mult = mult *0.75
	end

	--if not multState.HasImmaculateHeart --[[and InHallowRange]] then mult = mult *1.2 end

	--if InStarBethRange then mult = mult *1.5 end

	for _, e in ipairs(Isaac.FindInRadius(player.Position, 85.75, EntityPartition.FAMILIAR)) do
		if e.Variant == FamiliarVariant.SUCCUBUS then mult = mult *1.5 end
	end


	if REPENTOGON then
		mult = mult * player:GetD8DamageModifier()
		if HasItem(player, CollectibleType.COLLECTIBLE_DEAD_EYE) and not multState.HasTechnology then
			mult = mult * (1 + (player:GetDeadEyeCharge() * 0.25))
		end
	end


	return mult
end


function MultiplierHandler:GetPlayerDamageMult(player)
	local data = getData(player, "DAMAGE") or {}
	if not shouldUpdateDamageMult(player) then

		local mult = data.Mult or 1
		mult = mult * getVarialMultDamage(player)

		return mult
	end

	local pType = player:GetPlayerType()
	local multState = data.MultState or {}
	local mult = playerDmgMult[pType] or 1

	if multState.EveWhoreOfBabylon then
		mult = 0.75
	elseif multState.AzazelApplySpecialMult then
		if AzazelTechX then mult = mult *0.35 end
		if AzazelLudo then mult = mult *0.5 end
		if AzazelTechnology then mult = mult * 1.5 end
	elseif multState.JudasDamoclesBirthright then mult = mult * 1.4 end


	if multState.HasCricketGroup then
		mult = mult *1.5
	end

	if multState.HasHaemolacria then
		mult = mult * 1.5
	elseif multState.HasBrimstone and not multState.HasKnife then
		if multState.HasDoubleBrim then
			mult = mult * 1.2
		elseif multState.HasTechnology then
			mult = mult * 1.5
		end
	end

	if multState.HasAlmondMilk then
		mult = mult * 0.33
	elseif multState.HasSoyMilk then
		mult = mult * 0.2
	end


	if multState.Has2020 then
		mult = mult *0.8

	elseif multState.HasPoly then
		mult = mult * 2
	end

	if multState.HasCrownOfLightEffect then mult = mult *2 end
	if multState.HasThinMush then mult = mult *0.9 end
	if multState.HasSacredHeart then mult = mult *2.3 end
	if multState.HasEvesMascara then mult = mult *2 end
	if multState.HasMegaMush then mult = mult *4 end
	if multState.HasImmaculateHeart then mult = mult *1.2 end

	data.Mult = mult
	setData(player, "DAMAGE", data)
	
	mult = mult * getVarialMultDamage(player)

	return mult
end




local tearTableCheck = {
	{Name = "IsAzazel", Fun = function(player, data) return IsPlayerType(player, {PlayerType.PLAYER_AZAZEL, PlayerType.PLAYER_AZAZEL_B}) end},

	{Name = "HasTearGroup", Fun = function(player, data) return MultiplierHandler:HasMultiplierGroup(player, MultGroupType.GROUP_FORGOTTEN_TEARS) end},
	{Name = "HasCSection", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_C_SECTION) end},
	{Name = "HasHaemolacria", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_HAEMOLACRIA) end},
	{Name = "HasSpiritSword", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_SPIRIT_SWORD) end},
	{Name = "CancelTears", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_EPIC_FETUS) or HasItem(player, CollectibleType.COLLECTIBLE_MOMS_KNIFE) end},
	{Name = "HasDrFetus", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_DR_FETUS) end},
	{Name = "HasBrimstone", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_BRIMSTONE) end},
	{Name = "HasTechX", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_TECH_X) end},
	{Name = "HasTechnology", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_TECHNOLOGY) end},
	{Name = "HasLudo", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) end},
	{Name = "HasIpecac", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_IPECAC) end},

	{Name = "HasMonstroLung", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_MONSTROS_LUNG) end},
	{Name = "HasAlmondMilk", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_ALMOND_MILK) end},
	{Name = "HasSoyMilk", Fun = function(player, data) return not data.HasAlmondMilk and HasItem(player, CollectibleType.COLLECTIBLE_SOY_MILK) end},
	{Name = "Has2020", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_20_20) end},
	{Name = "HasMutantGroup", Fun = function(player, data) return not data.Has2020 and (HasItem(player, CollectibleType.COLLECTIBLE_MUTANT_SPIDER) or (HasItem(player, CollectibleType.COLLECTIBLE_POLYPHEMUS) and not data.HasCSection)) end},
	{Name = "HasInnerEyeGroup", Fun = function(player, data) return not data.Has2020 and HasItem(player, CollectibleType.COLLECTIBLE_INNER_EYE) or HasNull(player, NullItemID.ID_REVERSE_HANGED_MAN) end},
	{Name = "HasTechnology2", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_TECHNOLOGY_2) end},
	{Name = "HasEvesMascara", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_EVES_MASCARA) end},
	{Name = "HasReverseChariot", Fun = function(player, data) return HasNull(player, NullItemID.ID_REVERSE_CHARIOT) or HasNull(player, NullItemID.ID_REVERSE_CHARIOT_ALT) end},

	{Name = "CancelTaintedAzazelBaseTearMult", Fun = function(player, data) return IsPlayerType(player, PlayerType.PLAYER_AZAZEL_B) and (data.HasHaemolacria or data.HasSpiritSword or data.CancelTears or data.HasDrFetus or data.HasBrimstone) end},
	{Name = "CancelAzazelBaseTearMult", Fun = function(player, data) return IsPlayerType(player, PlayerType.PLAYER_AZAZEL) and (data.HasHaemolacria or data.HasSpiritSword or data.CancelTears or data.HasDrFetus or data.HasBrimstone or data.HasTechX) end},
}

local function shouldUpdateTearMult(player)
	local data = getData(player, "TEARS") or {}
	local updateData = data.MultState or {}

	local lastFrameUpdate = data.FrameUpdate or -1
	local gameFrame = game:GetFrameCount()
	if gameFrame == lastFrameUpdate then return false end
	data.FrameUpdate = gameFrame

	local update = false

	for i=1, #tearTableCheck do
		local name = tearTableCheck[i].Name
		local val = tearTableCheck[i].Fun(player, updateData)
		if not updateData[name] or updateData[name] ~= val then update = true end
		updateData[name] = val
	end
	data.MultState = updateData
	setData(player, "TEARS", data)

	return update
end


local function getVarialMultTear(player)
	if player:IsDead() then return 1 end
	--local InHallowRange ,_ = MultiplierHandler:InHallowMultRange(player)

	local mult = 1
	if HasTrinket(player, TrinketType.TRINKET_CRACKED_CROWN) and player.MaxFireDelay > defaultStats.TEARS then
		mult = mult * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN) * 0.2))
	end

	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player.MaxFireDelay > defaultStats.TEARS then
		mult = mult *0.75
	end


	if REPENTOGON then
		mult = mult * player:GetD8FireDelayModifier()
		
		local charge = player:GetEpiphoraCharge()
		if REPENTANCE_PLUS then
			mult = mult * ( 1+ epiphoraFrameMult_RepPlus * math.min(charge, 180) )
		else
		    if charge >= 270 then
		        mult = mult *2
		    elseif charge >= 180 then
		        mult = mult *1.66
		    elseif charge >= 90 then
		        mult = mult *1.33
		    end
		end
	elseif HasItem(player, CollectibleType.COLLECTIBLE_EPIPHORA) then
		local charge = (getData(player, "Epiphora") or {}).Timer or 0

		if REPENTANCE_PLUS then
			mult = mult * ( 1+ epiphoraFrameMult_RepPlus * math.min(charge, 180) )
		else
		    if charge >= 270 then
		        mult = mult *2
		    elseif charge >= 180 then
		        mult = mult *1.66
		    elseif charge >= 90 then
		        mult = mult *1.33
		    end
		end
	end

	--if InHallowRange then mult = mult *2.5 end

	return mult
end


function MultiplierHandler:GetPlayerTearsMult(player)
	local data = getData(player, "TEARS") or {}
	if not shouldUpdateTearMult(player) then
		local mult = data.Mult or 1
		mult = mult * getVarialMultTear(player)

		return mult
	end

	local pType = player:GetPlayerType()
	local multState = data.MultState or {}
	local mult = playerTearsMult[pType] or 1

	if multState.CancelTaintedAzazelBaseTearMult or multState.CancelAzazelBaseTearMult then mult = 1 end
	
	if not multState.Has2020 then
		if multState.HasMutantGroup then
			mult = mult *0.42
		elseif multState.HasInnerEyeGroup then
			mult = mult *0.51
		end
	end
	
	
	if not multState.CancelTears or multState.HasCSection or multState.HasSpiritSword then

		if multState.HasIpecac and not multState.IsAzazel then mult = mult *(1/3) end

		if not (multState.HasCSection or multState.HasSpiritSword) then
			if multState.HasHaemolacria and not multState.HasLudo then mult = mult *0.5 end

			if multState.HasBrimstone then
				if not multState.HasTechX then mult = mult *(1/3) end

			elseif multState.HasMonstroLung then
				if not (multState.IsAzazel or multState.HasTechnology or multState.HasLudo) then
					if multState.HasTechX then
						mult = mult *(1/3.1)
					else
						mult = mult *(1/4.3)
					end
				end
			elseif multState.HasDrFetus then
				if not multState.HasHaemolacria then mult = mult *0.4 end
			end

			if multState.HasIpecac and multState.HasHaemolacria and not multState.HasLudo then mult = mult *1.79 end
		end
	end
	
	if multState.HasTearGroup then mult = mult *0.5 end

	if multState.HasTechnology2 then mult = mult *0.66 end
	if multState.HasEvesMascara then mult = mult *0.66 end

	if multState.HasAlmondMilk then
		mult = mult *4
	elseif multState.HasSoyMilk then
		mult = mult *5.5
	end

	if multState.HasReverseChariot then mult = mult *4 end

	data.Mult = mult
	setData(player, "TEARS", data)

	mult = mult * getVarialMultTear(player)

	return mult
end





local rangeTableCheck = {
	{Name = "HasRangeGroup", Fun = function(player, data) return MultiplierHandler:HasMultiplierGroup(player, MultGroupType.GROUP_IPECAC_RANGE) end},
	{Name = "HasNumberOne", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_NUMBER_ONE) end},
	{Name = "HasMyReflection", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_MY_REFLECTION) end},
}

local function shouldUpdateRangeMult(player)
	local data = getData(player, "RANGE") or {}
	local updateData = data.MultState or {}
	
	local lastFrameUpdate = data.FrameUpdate or -1
	local gameFrame = game:GetFrameCount()
	if gameFrame == lastFrameUpdate then return false end
	data.FrameUpdate = gameFrame

	local update = false

	for i=1, #rangeTableCheck do
		local name = rangeTableCheck[i].Name
		local val = rangeTableCheck[i].Fun(player, updateData)
		if not updateData[name] or updateData[name] ~= val then update = true end
		updateData[name] = val
	end
	data.MultState = updateData
	setData(player, "RANGE", data)

	return update
end


local function getVarialMultRange(player)
	if player:IsDead() then return 1 end
	local mult = 1
	if HasTrinket(player, TrinketType.TRINKET_CRACKED_CROWN) and player.TearRange > defaultStats.RANGE then
		mult = mult * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN) * 0.2))
	end

	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player.TearRange > defaultStats.RANGE then
		mult = mult *0.75
	end

	if REPENTOGON then
		mult = mult * player:GetD8RangeModifier()
	end

	return mult
end

function MultiplierHandler:GetPlayerRangeMult(player)
	local data = getData(player, "RANGE") or {}
	if not shouldUpdateRangeMult(player) then
		local mult = data.Mult or 1
		mult = mult * getVarialMultRange(player)

		return mult
	end

	local pType = player:GetPlayerType()
	local multState = data.MultState or {}
	local mult = 1
	
	if multState.HasRangeGroup then mult = mult * 0.8 end
	if multState.HasNumberOne then mult = mult * 0.8 end
	if multState.HasMyReflection then mult = mult * 2 end

	data.Mult = mult
	setData(player, "RANGE", data)

	mult = mult * getVarialMultRange(player)
	return mult
end





local shotSpeedTableCheck = {
	{Name = "HasIpecac", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_IPECAC) end},
	{Name = "HasMyReflection", Fun = function(player, data) return HasItem(player, CollectibleType.COLLECTIBLE_MY_REFLECTION) end},
}

local function shouldUpdateShotSpeedMult(player)
	local data = getData(player, "RANGE") or {}
	local updateData = data.MultState or {}

	local lastFrameUpdate = data.FrameUpdate or -1
	local gameFrame = game:GetFrameCount()
	if gameFrame == lastFrameUpdate then return false end
	data.FrameUpdate = gameFrame

	local update = false

	for i=1, #shotSpeedTableCheck do
		local name = shotSpeedTableCheck[i].Name
		local val = shotSpeedTableCheck[i].Fun(player, updateData)
		if not updateData[name] or updateData[name] ~= val then update = true end
		updateData[name] = val
	end
	data.MultState = updateData
	setData(player, "RANGE", data)

	return update
end


local function getVarialMultShotSpeed(player)
	if player:IsDead() then return 1 end
	local mult = 1
	if HasTrinket(player, TrinketType.TRINKET_CRACKED_CROWN) and player.ShotSpeed > defaultStats.SHOTSPEED then
		mult = mult * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN) * 0.2))
	end

	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player.ShotSpeed > defaultStats.SHOTSPEED then
		mult = mult *0.75
	end
	return mult
end

function MultiplierHandler:GetPlayerShotSpeedMult(player)
	local data = getData(player, "SHOTSPEED") or {}
	if not shouldUpdateShotSpeedMult(player) then
		local mult = data.Mult or 1
		mult = mult * getVarialMultShotSpeed(player)

		return mult
	end

	local pType = player:GetPlayerType()
	local multState = data.MultState or {}
	local mult = 1

	if multState.HasIpecac then mult = mult * 0.2 end
	if multState.HasMyReflection then mult = mult * 1.6 end

	data.Mult = mult
	setData(player, "SHOTSPEED", data)

	mult = mult * getVarialMultShotSpeed(player)
	return mult
end



local function getVarialMultMoveSpeed(player)
	local mult = 1
	if HasTrinket(player, TrinketType.TRINKET_CRACKED_CROWN) and player.MoveSpeed > defaultStats.SPEED then
		mult = mult * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN) * 0.2))
	end

	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player.MoveSpeed > defaultStats.SPEED then
		mult = mult *0.75
	end

	if REPENTOGON then
		mult = mult * player:GetD8SpeedModifier()
	end

	return mult
end

function MultiplierHandler:GetPlayerSpeedMult(player)
	return 1 * getVarialMultMoveSpeed(player)
end



if not REPENTOGON then
	
	MultiplierHandler.EpiphoraTracker = function(_, player)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA) then return end
		local data = getData(player, "Epiphora") or {}
		local fireDir = player:GetFireDirection()
		data.LastFireDir = data.LastFireDir or Direction.NO_DIRECTION

		if fireDir ~= Direction.NO_DIRECTION and (data.LastFireDir == Direction.NO_DIRECTION or fireDir == data.LastFireDir) then
			if (data.Timer or 0) <= 270 then data.Timer = (data.Timer or 0) +1 end
		else
			data.Timer = 0
		end
		data.LastFireDir = fireDir
		setData(player, "Epiphora", data)
	end
	MultiplierHandler.Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MultiplierHandler.EpiphoraTracker)
end