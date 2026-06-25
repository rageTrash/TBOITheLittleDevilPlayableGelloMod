--[[
	Start:
		Health : B B B

	On Selection:
		Pocket : Random Card

	Stats:
		- 1 dmg
		+ 0.2 speed
		+ 0.15 shotspeed

	Ability:
		Tears have a 50% to have a random tear effect

	LV1:
		Tears to have 1-2 random tear effects
		Gives a random innate passive item

	LV2:
		Tears to have 2-4 random tear effects

	LV3:
		Tears to have 4-8 random tear effects
		Gives 2 random innate passive item
		
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools
local kTools = Mod.KnifeTools
local itemPool = game:GetItemPool()

local JESTER_ITEMS = {
	CollectibleType.COLLECTIBLE_BBF,
	CollectibleType.COLLECTIBLE_BOBS_BRAIN,
	CollectibleType.COLLECTIBLE_ANTI_GRAVITY,
	CollectibleType.COLLECTIBLE_E_COLI,
	CollectibleType.COLLECTIBLE_MY_REFLECTION,
	CollectibleType.COLLECTIBLE_LIL_DELIRIUM,
	CollectibleType.COLLECTIBLE_PURGATORY,
	CollectibleType.COLLECTIBLE_CURSED_EYE,
	CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER,
	CollectibleType.COLLECTIBLE_THE_WIZ,
	CollectibleType.COLLECTIBLE_TINY_PLANET,
	CollectibleType.COLLECTIBLE_IBS,
	CollectibleType.COLLECTIBLE_FANNY_PACK,
	CollectibleType.COLLECTIBLE_GNAWED_LEAF,
	CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
	CollectibleType.COLLECTIBLE_LOKIS_HORNS,
	CollectibleType.COLLECTIBLE_PIGGY_BANK,
	CollectibleType.COLLECTIBLE_PUNCHING_BAG,
	CollectibleType.COLLECTIBLE_SAMSONS_CHAINS,
	CollectibleType.COLLECTIBLE_IT_HURTS,
	CollectibleType.COLLECTIBLE_EYE_OF_GREED,
	CollectibleType.COLLECTIBLE_FRUIT_CAKE
}

function GelloCharMod.AddJesterItem(...)
	for _, id in ipairs({...}) do
		table.insert(JESTER_ITEMS, id)
	end
end


local roomRNG = RNG()

local CARD_FLAGS = UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM
return {
	Id = Mod.Enum.Character.GELLO_B2,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {Black = 6}) end

		local seed = game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed
		if seed == 0 then seed = player.InitSeed end

		player:AddCard(itemPool:GetCard(seed, true, false, false))
	end,

	BombInit = function(bomb, rng, parent)
		Mod.API.AddRandomBombEffect(bomb, rng:RandomInt(4), rng)
	end,
	TearUpdate = function(tear, rng, parent)
		if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			Mod.API.AddRandomTearEffect(tear, rng:RandomInt(4), rng, true)
			return
		end
		if tear.FrameCount == 0 then
			Mod.API.AddRandomTearEffect(tear, rng:RandomInt(4), rng, false)
		end
	end,
	LaserUpdate = function(laser, rng, parent)
		if laser.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO then
			Mod.API.AddRandomLaserEffect(laser, rng:RandomInt(4), rng, true)
			return
		end
		if laser.FrameCount == 0 then
			Mod.API.AddRandomLaserEffect(tear, rng:RandomInt(4), rng, false)
		end
	end,
	KnifeUpdate = function(knife, rng, parent)
		if knife:IsFlying() then
			Mod.API.AddRandomKnifeEffect(knife, rng:RandomInt(4), rng)
		elseif kTools.DoesKnifeSwing(knife) then
			if (kTools.IsKnifeSwinging(knife) or kTools.IsKnifeSpining(knife)) and knife:GetSprite():GetFrame() == 1 then
				Mod.API.AddRandomKnifeEffect(knife, rng:RandomInt(4), rng)
			end
		end
	end,

	PostRoom = function(player)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or player:HasCurseMistEffect() then return end
		local roomDesc = game:GetLevel():GetCurrentRoomDesc()
		if roomDesc.Clear then return end

		local seed = player.InitSeed + roomDesc.DecorationSeed + (roomDesc.VisitedCount * 5)
		if seed == 0 then seed = 1 end

		roomRNG:SetSeed(seed, 30)
		local effect = roomRNG:RandomInt(#JESTER_ITEMS +1)
		local addedItem = false
		if effect > 0 then
			local itemTab = Mod.TableTools.CopyLite(JESTER_ITEMS)

			while #itemTab > 0 do
				local idx = roomRNG:RandomInt(#itemTab) +1
				local itemID = itemTab[ idx ]
				if not player:HasCollectible(itemID) then
					Mod.HiddenItemManager:AddAddForRoom(player, itemID, -1, 1)
					addedItem = true
					break
				end
				table.remove(itemTab, idx)
			end
		end

		if addedItem then player:UseCard(Card.CARD_TOWER, CARD_FLAGS) end
	end,
}