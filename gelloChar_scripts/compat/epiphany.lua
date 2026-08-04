local Mod = GelloCharMod
local game = Mod.Game
local itemEnum = Mod.Enum.Item
local cardEnum = Mod.Enum.Card

Mod.AddModPath("Epiphany",function()
	local epi = Epiphany
	local epiItem = epi.Item

	--Mod:AddFamiliarToBlackList({epiItem.WOOLEN_CAP.ID})
	
	Mod:AddConsumeItemEffect(
		{ Id = epiItem.OLD_KNIFE.ID, Stats = {ForceDmg = 1.65, ForceTempDmg = 0.66}}
		,{ Id = epiItem.CARDBOARD_CUTOUT.ID,
			Fun = function(player, rng)
				local pos = player.Position
				local room = game:GetRoom()

				local freeIndex = Mod:GetFreeGroup()
				Mod:Spawn(5, 10, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex
				Mod:Spawn(5, 20, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex
				Mod:Spawn(5, 30, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex
				Mod:Spawn(5, 40, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex
				Mod:Spawn(5, 70, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex
				Mod:Spawn(5, 300, 0, room:FindFreePickupSpawnPosition(pos, 40, true)):ToPickup().OptionsPickupIndex = freeIndex

			end,
			EID = {
				en_us = "Spawns a heart, coin, key, bomb, pill and card#Only one can be pick up",
				spa = "Genera un corazón, moneda, llave, bomba, pildora y carta#Solo uno se puede agarrar",
			}
		}
		,{ Id = epiItem.ACTIVE_SACK.ID,
			Fun = function(player, rng)
				local pos = player.Position
				local room = game:GetRoom()

				local freeIndex = Mod:GetFreeGroup()
				for i=1, 3 do
					local ID = epiItem.ACTIVE_SACK:GetOneUseItemFromWeightedPool(rng)
					local OneUseItem = Mod:Spawn(5,
						Epiphany.Pickup.ONE_TIME_USE_ITEM.ID,
						ID or CollectibleType.COLLECTIBLE_KAMIKAZE,
						room:FindFreePickupSpawnPosition(pos, 40, true))
					
					OneUseItem:ToPickup().OptionsPickupIndex = freeIndex
				end
			end,
			EID = {
				en_us = "Spawns 3 single use active item#Only one can be pick up",
				spa = "Genera 3 activas de un solo uso#Solo uno se puede agarrar",
			}
		}
	)
	
	Mod.CustomPricesTable[epi.PickupPrice.PRICE_TWO_BROKEN_HEARTS] = function(player)
		epi.SHOP_ITEMS.PAY_PRICE[epi.PickupPrice.PRICE_TWO_BROKEN_HEARTS](player)
	end
	Mod.CustomPricesTable[epi.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS] = function(player)
		epi.SHOP_ITEMS.PAY_PRICE[epi.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS](player)
	end
	Mod.CustomPricesTable[epi.PickupPrice.PRICE_KEYS] = function(player, pickup)
		if not epi.SHOP_ITEMS.CAN_BUY[Mod.PickupPrice.PRICE_KEYS](player, pickup) then return false end
		epi.SHOP_ITEMS.PAY_PRICE[epi.PickupPrice.PRICE_KEYS](player)
	end

	Mod.CanPayCustomPricesTable[epi.PickupPrice.PRICE_TWO_BROKEN_HEARTS] = function(player) return true end
	Mod.CanPayCustomPricesTable[epi.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS] = function(player) return true end
	Mod.CanPayCustomPricesTable[epi.PickupPrice.PRICE_KEYS] = function(player, pickup) return epi.SHOP_ITEMS.CAN_BUY[Mod.PickupPrice.PRICE_KEYS](player, pickup) end
end)


local ModdedItems = {
	[itemEnum.LIL_HAMSTER] =      function() return Mod:IsUnlock("Lil Hamster") end,
	[itemEnum.LIL_HAMSTER_2] =    function() return false end,
	[itemEnum.LIL_HAMSTER_3] =    function() return false end,
	[itemEnum.LIL_HAMSTER_4] =    function() return false end,
	[itemEnum.BEELZEBUB] =        function() return Mod:IsUnlock("Beelzebub") end,
	[itemEnum.FETAL_JAR] =        function() return Mod:IsUnlock("Fetal Jar") end,
	[itemEnum.MOTHERLY_CHICKEN] = function() return Mod:IsUnlock("Motherly Chicken") end,
	[itemEnum.USE_PLACENTA] =     function() return Mod:IsUnlock("Use Placenta") end,
	[itemEnum.CURSED_PLUSHIE] =   function() return Mod:IsUnlock("Cursed Plushie") end,
	[itemEnum.GALLUS] =           function() return Mod:IsUnlock("Gallus") end,
	[itemEnum.LARRY_JR_JR] =      function() return Mod:IsUnlock("Larry Jr Jr") end,
	[itemEnum.CENTEPIED] =        function() return Mod:IsUnlock("Centepied") end,
	[itemEnum.FRIENDLY_BITE] =    function() return Mod:IsUnlock("Friendly Bite") end,
	[itemEnum.VOID_STOMACH] =    function() return Mod:IsUnlock("Void Stomach") end,

	[itemEnum.LIL_BITER] =        function() return Mod:IsUnlock("Lil Biter") end,
	[itemEnum.LIL_COW] =          function() return Mod:IsUnlock("Lil Cow") end,
	[itemEnum.LIL_EMBRION] =      function() return Mod:IsUnlock("Lil Embrion") end,
}

local function gelloPatch()
    local epi = Epiphany
    local eAPI = Epiphany.API

	epi.UnlockChecker:AddModdedItems("PlayableGello", itemEnum.LIL_HAMSTER, itemEnum.LIL_EMBRION, function(itemId)
		return ModdedItems[itemId]()
	end)

    --[[
	eAPI:AddSlotsToSlotGroup("Beggars", { V = Mod.Enum.Slot.MISSING_POSTER } )
	eAPI:AddSlotsToSlotGroup("SpecialBeggars", { V = Mod.Slot.DRUNK_BEGGAR } )]]

	eAPI:AddItemsToEdenBlackList(
		itemEnum.LIL_COW,
		itemEnum.MOTHERLY_CHICKEN,
		itemEnum.CENTEPIED
	)

	eAPI:AddCardsToCardGroup("Object", { V = cardEnum.SACRIFICIAL_DAGGER } )
	eAPI:AddCardsToCardGroup("Soul", { V = cardEnum.SOUL_OF_GELLO } )

	epi:AddToDictionary(KEEPER.PickupVariants, {
		[300] = {
			[cardEnum.SACRIFICIAL_DAGGER] = 7,
		}
	})

    epi:AddExtraCallback(epi.ExtraCallbacks.PRE_UNLOCK_CACHE, function(cardUnlocks)
		cardUnlocks[cardEnum.SACRIFICIAL_DAGGER] = Mod:IsUnlock("Sacrificial Dagger")
		cardUnlocks[cardEnum.SOUL_OF_GELLO] =      Mod:IsUnlock("Soul of Gello")
	end)
end
Mod.AddModPath("Epiphany", function()
	Epiphany.PatchesLoader:RegisterPatch("GELLO_CHAR_MOD", gelloPatch)
end, true)