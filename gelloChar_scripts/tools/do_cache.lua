local Mod = GelloCharMod
local pTools = Mod.PlayerTools


Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	pTools.ForEach(function(player)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end)
end)


Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheflag)
	if player.Variant ~= 0 then return end
	local stats = Mod.SaveHandler.Player("Perma Stats", player):Get({})

	if (cacheflag & CacheFlag.CACHE_SPEED) == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + (stats.SPEED or 0) * MultiplierHandler:GetPlayerSpeedMult(player)

	elseif (cacheflag & CacheFlag.CACHE_RANGE) == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + (stats.RANGE or 0) * 40 * MultiplierHandler:GetPlayerRangeMult(player)

	elseif (cacheflag & CacheFlag.CACHE_FIREDELAY) == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = pTools.AddCappedTears(player, (stats.TEARS or 0) * MultiplierHandler:GetPlayerTearsMult(player) )

	elseif (cacheflag & CacheFlag.CACHE_DAMAGE) == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (stats.DAMAGE or 0) * MultiplierHandler:GetPlayerDamageMult(player)

	elseif (cacheflag & CacheFlag.CACHE_LUCK) == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + (stats.LUCK or 0)

	elseif (cacheflag & CacheFlag.CACHE_SHOTSPEED) == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + (stats.SHOTSPEED or 0) * MultiplierHandler:GetPlayerShotSpeedMult(player)
	end
end)


Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	pTools.ForEach(function(player)
		Mod.SaveHandler.Player("Perma Stats", player):Set({})
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end)
end, CollectibleType.COLLECTIBLE_GENESIS)