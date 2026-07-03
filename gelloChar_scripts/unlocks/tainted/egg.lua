local Mod = GelloCharMod
local game = Mod.Game
local pSave = Mod.SaveHandler.Player

local pTools = Mod.PlayerTools
local runNormalTab = {}

local CHANCE = 50 -- 2%


local function strangeStone(player)
	if player:HasTrinket(Mod.Enum.Trinket.EGG) then
		local RNG = player:GetTrinketRNG(Mod.Enum.Trinket.EGG)
		local totalChance = player:HasCollectible(Mod.Enum.Item.MOTHERLY_CHICKEN) and CHANCE /2 or CHANCE

		if RNG:RandomInt( totalChance ) > 0 then return end

		Mod.SFX:Play(SoundEffect.SOUND_BONE_BREAK, 1, 1)

		local trinketNum = player:GetTrinketMultiplier(Mod.Enum.Trinket.EGG)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
			trinketNum = trinketNum -1
		end
		player:TryRemoveTrinket(Mod.Enum.Trinket.EGG)

		local save = pSave("PermaFamiliars", player):Get({ Items = {}, Trinkets = {} })

		local effects = player:GetEffects()
		for i=1, trinketNum - player:GetTrinketMultiplier(Mod.Enum.Trinket.EGG) do
			local data = Mod:GetRandomSpawnableFam(RNG)
			if data.IsTrinket then -- the ids are a string so the save doesn't get clamped when loading
				save.Trinkets[tostring(data.ID)] = (save.Trinkets[tostring(data.ID)] or 0)+1
				effects:AddTrinketEffect(data.ID, 1)
			else
				save.Items[tostring(data.ID)] = (save.Items[tostring(data.ID)] or 0)+1
				effects:AddCollectibleEffect(data.ID, 1)
			end
		end
		pSave("PermaFamiliars", player):Set(save)
	end
end

local function sync(player)
	local save = pSave("PermaFamiliars", player):Get(nil)
	if save == nil then return end
	local effects = player:GetEffects()
	if save.Items then
		for idStr, num in pairs(save.Items) do
			local ID = tonumber(idStr)
			if ID then
				effects:AddCollectibleEffect(ID, true, num)
			end
		end
	end
	if save.Trinkets then
		for idStr, num in pairs(save.Trinkets) do
			local ID = tonumber(idStr)
			if ID then
				effects:AddTrinketEffect(ID, true, num)
			end
		end
	end
end

local function samefunction_1() pTools.ForEach(strangeStone) end
local function syncAllPlayers() pTools.ForEach(sync) end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -200, samefunction_1)
Mod:AddCallback(ModCallbacks.WC_WAVE_CHANGE, samefunction_1, WaveHelper.WaveType.ALL_WAVES_NO_GIDEON)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, syncAllPlayers)
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, syncAllPlayers)


local function spawnItem(player, slot)
	for _, e in ipairs(Isaac.FindByType(5, 100)) do
		if e.FrameCount <= 2 then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, false, slot)
			break
		end
	end
	runNormalTab = {}
end

local function reRunAltar(player, flags, slot, vardata)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, flags, slot, vardata)
	Mod:RunLater(1, spawnItem, player, flags, slot, vardata)
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, -10000, function(_, _, _, player, flags, slot, vardata)--- priority higher that the one of hidden item manager
	local save = pSave("PermaFamiliars", player):Get(nil)
	if save == nil then return end
	local ptr = GetPtrHash(player)
	if runNormalTab[ptr] then return end
	runNormalTab[ptr] = true

	local effects = player:GetEffects()
	for idStr, num in pairs(save.Items) do
		local ID = tonumber(idStr)
		if ID then
			effects:RemoveCollectibleEffect(ID, num)
		end
	end
	for idStr, num in pairs(save.Trinkets) do
		local ID = tonumber(idStr)
		if ID then
			effects:RemoveTrinketEffect(ID, num)
		end
	end
	
	Mod:RunLater(1, reRunAltar, player, flags, slot, vardata)
	return true
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags, slot, vardata)
	local ptr = GetPtrHash(player)
	if runNormalTab[ptr] then
		runNormalTab[ptr] = nil
		sync(player)
	end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)