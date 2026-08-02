local Mod = GelloCharMod
local game = Mod.Game
local pSave = GelloCharMod.SaveHandler.Player

local ExtraParam
if Mod.RepentogonPlus then
	CustomReviveLibThing.AddCustomRevive(
		Isaac.GetItemConfig():GetNullItem(Mod.Enum.NullItem.FETAL_JAR_LIVES),
		CustomReviveLibThing.RevivePriority.SOUL_OF_LAZARUS
	)
	ExtraParam = Isaac.GetItemConfig():GetNullItem(Mod.Enum.NullItem.FETAL_JAR_LIVES)
else
	CustomReviveLibThing.AddCustomRevive(
		Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.FETAL_JAR),
		CustomReviveLibThing.RevivePriority.SOUL_OF_LAZARUS
	)
	ExtraParam = Isaac.GetItemConfig():GetCollectible(Mod.Enum.Item.FETAL_JAR)
end


local function removeCollectibleEffect(player)
	if Mod.RepentogonPlus then
		player:GetEffects():RemoveNullEffect(Mod.Enum.NullItem.FETAL_JAR_LIVES, 1)
	else
		player:GetEffects():RemoveCollectibleEffect(Mod.Enum.Item.FETAL_JAR, 1)
	end
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags, slot)
	if flags & UseFlag.USE_CARBATTERY > 0 then return end

	local rng = player:GetCollectibleRNG(Mod.Enum.Item.FETAL_JAR)
	local tab = {}
	for itemID, num in pairs(Mod.PlayerTools.GetPlayerItems(player, true)) do
		if itemID ~= Mod.Enum.Item.FETAL_JAR then
			for i=1, num do table.insert(tab, itemID) end
		end
	end
	if #tab > 0 then
		if Mod.RepentogonPlus then player:GetEffects():AddNullEffect(Mod.Enum.NullItem.FETAL_JAR_LIVES) end
		player:RemoveCollectible(tab[rng:RandomInt(#tab)+1], true)
		return flags & UseFlag.USE_NOANIM == 0
	end

	if not Mod.RepentogonPlus then Mod:RunLater(1, removeCollectibleEffect, player) end
	return { Discharge = false, ShowAnim = false }
end, Mod.Enum.Item.FETAL_JAR)


Mod:AddCallback(CustomReviveLibThing.Callbacks.CAN_PLAYER_REVIVE_CHECK, function(_, player, config)
	local effects = player:GetEffects()
	if Mod.RepentogonPlus then
		print("Is Null", config:IsNull(), config.ID == Mod.Enum.NullItem.FETAL_JAR_LIVES)
		return effects:HasNullEffect(Mod.Enum.NullItem.FETAL_JAR_LIVES)
	else
		print("Is Collectible", config:IsCollectible(), config.ID == Mod.Enum.Item.FETAL_JAR)
		return effects:HasCollectibleEffect(Mod.Enum.Item.FETAL_JAR)
	end
end, ExtraParam)

Mod:AddCallback(CustomReviveLibThing.Callbacks.ON_PLAYER_REVIVE, function(_, player, config)
	local effects = player:GetEffects()
	print("Revive", ((config:IsNull() and "Null") or (config:IsCollectible() and "Collectible") or (config:IsTrinket() and "Trinket")), config.ID)
	--if Mod.RepentogonPlus then
	--	if not (config:IsNull() and config.ID == Mod.Enum.NullItem.FETAL_JAR_LIVES) then return end
	--elseif not (config:IsCollectible() and config.ID == Mod.Enum.Item.FETAL_JAR) then return
	--end
	removeCollectibleEffect(player)

	--local level = game:GetLevel()
	--local enterDir = level.EnterDoor
	--local room = level:GetCurrentRoom()
	---- base from Fiend Folio
	--if enterDir == -1 or room:GetDoor(enterDir) == nil or level:GetCurrentRoomIndex() == level:GetPreviousRoomIndex() then
	--	game:StartRoomTransition(level:GetCurrentRoomIndex(), -1, RoomTransitionAnim.ANKH)
	--else
	--	local doorData = room:GetDoor(enterDir)
	--	level.LeaveDoor = -1
	--	game:StartRoomTransition(doorData.TargetRoomIndex, doorData.Direction, RoomTransitionAnim.ANKH)
	--end

	if player:GetEffectiveMaxHearts() <= 0 then
		player:AddMaxHearts(2)
	end
	player:AddHearts(99)
	player:SetMinDamageCooldown(30)

	local ref = EntityRef(player)
	local dmg = 15 + (player.Damage / 10)
	for _, ent in ipairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.ENEMY)) do
		ent:TakeDamage(dmg, 0, ref, 0)
	end

	if Mod.RepentogonPlus then
		player:GetEffects():AddNullEffect(Mod.Enum.NullItem.FETAL_JAR_STATS)
	else
		pSave("Fetal Jar revives", player):Set( pSave("Fetal Jar revives", player):Get(0) +1 )
		Mod.PlayerTools.DoCache(player, CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SIZE)
	end

	player:AnimateCollectible(Mod.Enum.Item.FETAL_JAR)
end, ExtraParam)