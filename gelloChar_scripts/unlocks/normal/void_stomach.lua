local Mod = GelloCharMod
local game = Mod.Game
local config = Isaac.GetItemConfig()

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags, slot)
	if flags & UseFlag.USE_CARBATTERY > 0 then return end

	local closestPickup = nil
    local dis = nil
    local playerPos = player.Position
    for _, pickup in ipairs(Isaac.FindInRadius(playerPos, 60, EntityPartition.PICKUP)) do
        if pickup.SubType > 0 and Mod:CanEatPickup(pickup) and (dis == nil or pickup.Position:Distance(playerPos) < dis) and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and Mod.PlayerTools.CanPlayerPayPickup(player, pickup) then
            dis = pickup.Position:Distance(playerPos)
            closestPickup = pickup
        end
    end
	if closestPickup ~= nil then
        closestPickup = closestPickup:ToPickup()
        local sub = closestPickup.SubType
        local ent = Mod:Spawn(1000, Mod.Enum.Effect.EAT, 1, closestPickup.Position, nil, closestPickup)
        
		if Mod:GelloTryConsumePickup(player, closestPickup, true) then
            return flags & UseFlag.USE_NOANIM == 0
        end
        ent:Remove()
	end

	return { Discharge = false, ShowAnim = false }
end, Mod.Enum.Item.VOID_STOMACH)