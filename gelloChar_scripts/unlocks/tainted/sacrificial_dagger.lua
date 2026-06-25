local Mod = GelloCharMod

local config = Isaac.GetItemConfig()

Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player, flags)
	if flags & UseFlag.USE_CARBATTERY > 0 then return end

	local RNG = player:GetCardRNG(Mod.Enum.Card.SACRIFICIAL_DAGGER)
	local tab = {}
	for itemID, num in pairs(Mod.PlayerTools.GetPlayerItems(player, true)) do
		if config:GetCollectible(itemID).Type == ItemType.ITEM_FAMILIAR then
			for i=1, num do table.insert(tab, itemID) end
		end
	end
	if #tab > 0 then
		local itemID = tab[ RNG:RandomInt(#tab)+1 ]
		player:RemoveCollectible(itemID, true)
		local coinSpawn = 3
		local quality = config:GetCollectible(itemID).Quality

		if quality <= 0 then coinSpawn = coinSpawn -1
		elseif quality >= 4 then coinSpawn = coinSpawn +1
		end

		local coinTable = Mod:GenerateTableCoins(coinSpawn*5, RNG)
		for i=1, #coinTable do
			Mod:Spawn(5, 20, coinTable[i], player.Position, Mod:RandomVector(-3.5,3.5, RNG), player)
		end
		
	elseif flags & UseFlag.USE_MIMIC == 0 then
		local ent = Mod:Spawn(5, 300, Mod.Enum.Card.SACRIFICIAL_DAGGER, player.Position + Vector(0,40), Vector.Zero, player)

		if Epiphany then
			Epiphany:AddMidasImmunity(ent:ToPickup())
		end
	end
end, Mod.Enum.Card.SACRIFICIAL_DAGGER)