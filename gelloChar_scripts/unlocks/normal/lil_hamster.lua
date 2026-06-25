local Mod = GelloCharMod
local game = Mod.Game

local IGNORE_FLAGS = EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN | EntityFlag.FLAG_NO_QUERY

local heartOffset = Vector(-20, -40)

local isItem = {
	[Mod.Enum.Item.LIL_HAMSTER] = true,
	[Mod.Enum.Item.LIL_HAMSTER_2] = true,
	[Mod.Enum.Item.LIL_HAMSTER_3] = true,
	[Mod.Enum.Item.LIL_HAMSTER_4] = true,
}

local itemToIndex = {
	Mod.Enum.Item.LIL_HAMSTER,
	Mod.Enum.Item.LIL_HAMSTER_2,
	Mod.Enum.Item.LIL_HAMSTER_3,
	Mod.Enum.Item.LIL_HAMSTER_4,
}

local itemToEffect = {
	[Mod.Enum.Item.LIL_HAMSTER] = function(player)
		local dmg = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 50 or 30

		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:ToNPC() ~= nil and ent:GetEntityFlags() & (IGNORE_FLAGS) == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then

				ent:TakeDamage(dmg, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
			end
		end
	end,
	[Mod.Enum.Item.LIL_HAMSTER_2] = function(player)
		local hasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
		
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:ToNPC() ~= nil and ent:GetEntityFlags() & (IGNORE_FLAGS) == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then

				Mod.EffectTools.AddIce(ent, EntityRef(player), 150)

				if hasCarBattery then ent:TakeDamage(20, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0) end
			end
		end
	end,
	[Mod.Enum.Item.LIL_HAMSTER_3] = function(player)
		local dmg = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 0.85 or 0.5

		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:ToNPC() ~= nil and ent:GetEntityFlags() & (IGNORE_FLAGS) == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then

				ent:AddBurn(EntityRef(player), 150, dmg)
			end
		end
	end,
	[Mod.Enum.Item.LIL_HAMSTER_4] = function(player)
		local healAmount = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 4 or 2

		local effect
		if player:GetEffectiveMaxHearts() - player:GetHearts() > 0 then
			player:AddHearts(healAmount)
			effect = Mod:Spawn(1000, EffectVariant.HEART, 0, player.Position, Vector.Zero, player):ToEffect()
		else
			player:AddSoulHearts(healAmount)
			effect = Mod:Spawn(1000, EffectVariant.HEART, 4, player.Position, Vector.Zero, player):ToEffect()
		end
		effect:GetSprite().Offset = heartOffset
		effect:FollowParent(player)
		Mod.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
	end,
}


local config = Isaac.GetItemConfig()
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, _, player, flags, slot)
	if not isItem[itemID] or flags & UseFlag.USE_CARBATTERY > 0 then return end

	if flags & UseFlag.USE_VOID > 0 then
		itemToEffect[ itemToIndex[ player:GetCollectibleRNG(itemID):RandomInt(4)+1 ] ](player)
		return flags & UseFlag.USE_NOANIM == 0
	else
		itemToEffect[itemID](player)
	end

	if slot >= 0 and slot <= 2 then
		local rng = player:GetCollectibleRNG(itemID)
		local nItemID = itemToIndex[rng:RandomInt(4)+1]

		local charge = math.min(config:GetCollectible(itemID).MaxCharges, (player:GetBatteryCharge(slot) or 0))
		player:AddCollectible(nItemID, charge, false, slot)
	end

	return flags & UseFlag.USE_NOANIM == 0
end)