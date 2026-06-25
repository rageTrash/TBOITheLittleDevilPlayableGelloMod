local Mod = GelloCharMod
local playerSave = Mod.SaveHandler.Player

local config = Isaac.GetItemConfig()
local MAX_TEMP_DMG = 400 -- 10 dmg

Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player, flags)
	if flags & UseFlag.USE_CARBATTERY > 0 then return end

	--Mod.SFX:Play(Mod.Enum.Sound.SOUL_OF_GELLO)

	local RNG = player:GetCardRNG(Mod.Enum.Card.SACRIFICIAL_DAGGER)
	if flags & UseFlag.USE_MIMIC == 0 and RNG:RandomInt(3) == 0 then
		local ent = Mod:Spawn(5, 300, Mod.Enum.Card.SOUL_OF_GELLO, player.Position + Vector(0,40), Vector.Zero, player)

		if Epiphany then
			Epiphany:AddMidasImmunity(ent:ToPickup())
		end
	end

	local itemEffect = player:GetEffects()
	local dmg = itemEffect:GetCollectibleEffectNum(Mod.Enum.Item.TEMP_DMG_SLOW)
	if dmg > MAX_TEMP_DMG then return end

	local mult = 20 -- 0.5 dmg
	if flags & UseFlag.USE_MIMIC > 0 then mult = 10 end -- 0.25 dmg

	local famNum = 40 -- 1 dmg
	for itemID, num in pairs(Mod.PlayerTools.GetPlayerItems(player, true)) do
		if config:GetCollectible(itemID).Type == ItemType.ITEM_FAMILIAR then
			if famNum >= MAX_TEMP_DMG then break end
			famNum = famNum + (num *mult)
		end
	end

	if dmg + famNum > MAX_TEMP_DMG then famNum = MAX_TEMP_DMG
	else famNum = dmg + famNum end
	
	itemEffect:AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG_SLOW, false, famNum - dmg)
end, Mod.Enum.Card.SOUL_OF_GELLO)