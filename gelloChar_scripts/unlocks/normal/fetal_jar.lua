local Mod = GelloCharMod
local game = Mod.Game
local pSave = GelloCharMod.SaveHandler.Player

IDK_CustomRevive.AddCustomRevive(Mod.Enum.Item.FETAL_JAR, IDK_CustomRevive.RevivePriority.SOUL_OF_LAZARUS, false)


local function reviveFun(p)
	p:AnimateCollectible(Mod.Enum.Item.FETAL_JAR)

	if p:GetEffectiveMaxHearts() <= 0 then
		p:AddMaxHearts(2)
	end
	p:AddHearts(99)
	if Mod.RepentogonPlus then
		player:GetEffects():AddNullEffect(Mod.Enum.NullItem.FETAL_JAR_STATS)
	else
		pSave("Fetal Jar revives", p):Set( pSave("Fetal Jar revives", p):Get(0) +1 )
		Mod.PlayerTools.DoCache(p, CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SIZE)
	end
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


Mod:AddCallback(IDK_CustomRevive.Callbacks.PRE_CUSTOM_REVIVE_ITEM, function(_, player, _, isTrinket)
	if isTrinket then return end
	local effects = player:GetEffects()
	if Mod.RepentogonPlus then
		return effects:HasNullEffect(Mod.Enum.NullItem.FETAL_JAR_LIVES)
	end

	return effects:HasCollectibleEffect(Mod.Enum.Item.FETAL_JAR)
end, Mod.Enum.Item.FETAL_JAR)

Mod:AddCallback(IDK_CustomRevive.Callbacks.POST_CUSTOM_REVIVE_ITEM, function(_, player, _, isTrinket)
	if isTrinket then return end
	removeCollectibleEffect(player)

	local level = game:GetLevel()
	local enterDir = level.EnterDoor
	local room = level:GetCurrentRoom()
	-- base from Fiend Folio
	if enterDir == -1 or room:GetDoor(enterDir) == nil or level:GetCurrentRoomIndex() == level:GetPreviousRoomIndex() then
		game:StartRoomTransition(level:GetCurrentRoomIndex(), -1, RoomTransitionAnim.ANKH)
	else
		local doorData = room:GetDoor(enterDir)
		level.LeaveDoor = -1
		game:StartRoomTransition(doorData.TargetRoomIndex, doorData.Direction, RoomTransitionAnim.ANKH)
	end

	if not REPENTOGON then Mod:RunLater(1, reviveFun, player) end
end, Mod.Enum.Item.FETAL_JAR)