local Mod = GelloCharMod
local game = Mod.Game
local pool = game:GetItemPool()
local config = Isaac.GetItemConfig()
local pTools = Mod.PlayerTools

local STARTING_PLAYER_TYPE = -1

local ModdedItems = {
	[Mod.Enum.Item.LIL_HAMSTER] =      function() return Mod:IsUnlock("Lil Hamster") end,
	[Mod.Enum.Item.LIL_HAMSTER_2] =    function() return false end,
	[Mod.Enum.Item.LIL_HAMSTER_3] =    function() return false end,
	[Mod.Enum.Item.LIL_HAMSTER_4] =    function() return false end,
	[Mod.Enum.Item.BEELZEBUB] =        function() return Mod:IsUnlock("Beelzebub") end,
	[Mod.Enum.Item.FETAL_JAR] =        function() return Mod:IsUnlock("Fetal Jar") end,
	[Mod.Enum.Item.MOTHERLY_CHICKEN] = function() return Mod:IsUnlock("Motherly Chicken") end,
	[Mod.Enum.Item.USE_PLACENTA] =     function() return Mod:IsUnlock("Use Placenta") end,
	[Mod.Enum.Item.CURSED_PLUSHIE] =   function() return Mod:IsUnlock("Cursed Plushie") end,
	[Mod.Enum.Item.GALLUS] =           function() return Mod:IsUnlock("Gallus") end,
	[Mod.Enum.Item.LARRY_JR_JR] =      function() return Mod:IsUnlock("Larry Jr Jr") end,
	[Mod.Enum.Item.CENTEPIED] =        function() return Mod:IsUnlock("Centepied") end,
	[Mod.Enum.Item.FRIENDLY_BITE] =    function() return Mod:IsUnlock("Friendly Bite") end,
	[Mod.Enum.Item.FRIENDLY_BITE_ALT] =function() return Mod:IsUnlock("Friendly Bite") end,
	[Mod.Enum.Item.VOID_STOMACH] =     function() return Mod:IsUnlock("Void Stomach") end,
	[Mod.Enum.Item.LIL_BITER] =        function() return Mod:IsUnlock("Lil Biter") end,
	[Mod.Enum.Item.LIL_COW] =          function() return Mod:IsUnlock("Lil Cow") end,
	[Mod.Enum.Item.LIL_EMBRION] =      function() return Mod:IsUnlock("Lil Embrion") end,
}

local ModdedTrinkets = {
	[Mod.Enum.Trinket.WEIRD_CANDY] =   function() return Mod:IsUnlock("Weird Candy") end,
	[Mod.Enum.Trinket.EGG] =           function() return Mod:IsUnlock("Egg") end,
	[Mod.Enum.Trinket.STRANGE_STONE] = function() return Mod:IsUnlock("Strange Stone") end,
}

local ModdedCards = {
	[Mod.Enum.Card.SACRIFICIAL_DAGGER] = function() return Mod:IsUnlock("Sacrificial Dagger") end,
	[Mod.Enum.Card.SOUL_OF_GELLO] =      function() return Mod:IsUnlock("Soul of Gello") end,
}


function GelloCharMod.AddUnlockableToCheck(t, id, fun)
	if t == "item" then ModdedItems[id] = fun
	elseif t == "trinket" then ModdedTrinkets[id] = fun
	elseif t == "card" then ModdedCards[id] = fun
	end
end


Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -100, function(_, con)
	if con then return end
	local player = Isaac.GetPlayer(0)
	if Mod:IsTaintedGello(player) then
		STARTING_PLAYER_TYPE = Mod.Enum.Character.GELLO
	else
		STARTING_PLAYER_TYPE = player:GetPlayerType()
	end

	for id, fun in pairs(ModdedItems) do
		if not fun() then pool:RemoveCollectible(id) end
	end


	for id, fun in pairs(ModdedTrinkets) do
		if not fun() then pool:RemoveTrinket(id) end
	end
end)


local SOUL_STONE_CHANCE = 0.35 / 100
Mod:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, cardID, includePlayCards, includeRunes, onlyRunes)
	local fun = ModdedCards[cardID]
	if not fun then return end
	if cardID == Mod.Enum.Card.SACRIFICIAL_DAGGER and not fun() then
		return pool:GetCard(rng:Next(), includePlayCards, includeRunes, onlyRunes)
	elseif cardID == Mod.Enum.Card.SOUL_OF_GELLO and not fun() then
		return pool:GetCard(rng:Next(), includePlayCards, includeRunes, onlyRunes)
	end
end)

local MAX_RESELECT_TRYES = 10
local trys = 0
Mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, function(_, itemID, _, decrease, seed)
	local fun = ModdedItems[itemID]
	if not fun or trys > 0 then return end
	
	
	if not fun() then
		pool:RemoveCollectible(itemID)

		pool:AddRoomBlacklist(itemID)
		local newItemID = pool:GetCollectible(pool:GetLastPool(), false, seed)
		while trys < MAX_RESELECT_TRYES do
			fun = ModdedItems[newItemID]
			if fun and not fun() then
				pool:AddRoomBlacklist(newItemID)
			else
				trys = 0
				break
			end

			trys = trys +1
			newItemID = pool:GetCollectible(pool:GetLastPool(), false, seed)
		end
		if decrease then pool:RemoveCollectible(newItemID) end

		if trys >= 20 then
			trys = 0
			return CollectibleType.COLLECTIBLE_BREAKFAST
		end
		if Mod.GetSetting("FriendlyBiteAltMode") and newItemID == Mod.Enum.Item.FRIENDLY_BITE then return Mod.Enum.Item.FRIENDLY_BITE_ALT end
		return newItemID
	end
	if Mod.GetSetting("FriendlyBiteAltMode") and itemID == Mod.Enum.Item.FRIENDLY_BITE then return Mod.Enum.Item.FRIENDLY_BITE_ALT end
end)
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	for _, ent in ipairs(Isaac.FindByType(5, 100)) do
		local p = ent:ToPickup()
		if p and p.SubType > 0 then
			local ID = p.SubType
			local fun = ModdedItems[ID]
			if fun then
				while ( fun and not fun()) or not config:GetCollectible(ID):IsAvailable() do
					ID = ID -1
					data = ModdedItems[ID]
				end

				p:Morph(5, 100, ID)
			end
		end
	end
end, CollectibleType.COLLECTIBLE_SPINDOWN_DICE)


local trinketTrys = 0
Mod:AddCallback(ModCallbacks.MC_GET_TRINKET, function(_, trinketID, RNG)
	local fun = ModdedTrinkets[trinketID]
	if not fun or trinketTrys > 0 then return end

	if not fun() then
		local newTrinketID = pool:GetTrinket()
		while trinketTrys < MAX_RESELECT_TRYES do
			fun = ModdedTrinkets[newItemID]
			if not (fun and not fun()) then
				trys = 0
				break
			end

			trinketTrys = trinketTrys +1
			newTrinketID = pool:GetTrinket()
		end

		if trinketTrys >= MAX_RESELECT_TRYES then
			pool:ResetTrinkets()
			trinketTrys = 0
			return pool:GetTrinket()
		end
		return newTrinketID
	end
end)


local gellosGfxs = {
	"character_gello_b_12_5.png",
	"character_gello.png",
	"character_gello_b_2.png",
	"character_gello_b_3.png",
	"character_gello_b_4.png",
	"character_gello_b_5.png",
	"character_gello_b_6.png",
	"character_gello_b_7.png",
	"character_gello_b_8.png",
	"character_gello_b_9.png",
	"character_gello_b_10.png",
	"character_gello_b_11.png",
	"character_gello_b_12.png",
}
local ANIM_PATH = "gfx/006.014_isaac (gello).anm2"
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if not game:GetRoom():IsFirstVisit() or not MarksNAchievHelper:IsAchievementsEnable(true) then return end
	if Mod:IsUnlock("Tainted Gello") then return end
	local level = game:GetLevel()
	local desc = level:GetCurrentRoomDesc()
	if level:GetStage() ~= LevelStage.STAGE8 or desc.SafeGridIndex ~= 94 then return end

	if STARTING_PLAYER_TYPE ~= Mod.Enum.Character.GELLO then return end

	for _, ent in ipairs(Isaac.FindByType(5)) do ent:Remove() end
	for _, ent in ipairs(Isaac.FindByType(17)) do ent:Remove() end

	local taintedSlot = Isaac.FindByType(6, 14)[1]
	if taintedSlot == nil then
		taintedSlot = Mod:Spawn(6, 14, 0, game:GetRoom():GetCenterPos(), Vector.Zero, nil)
	end
	local sp = taintedSlot:GetSprite()
	
	sp:Load(ANIM_PATH, true)
	sp:ReplaceSpritesheet(0, "gfx/characters/costumes/"..gellosGfxs[ (taintedSlot.InitSeed % 13 +1) ])
	sp:LoadGraphics()
	
	sp:Play("Idle", true)
end)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if not MarksNAchievHelper:IsAchievementsEnable(true) then return end
	if Mod:IsUnlock("Tainted Gello") then return end
	if STARTING_PLAYER_TYPE ~= Mod.Enum.Character.GELLO then return end

	local level = game:GetLevel()
	if level:GetStage() ~= LevelStage.STAGE8 or level:GetCurrentRoomDesc().SafeGridIndex ~= 94 then return end
	
	for _, e in ipairs(Isaac.FindByType(6, 14)) do
		if e:GetSprite():IsFinished("PayPrize") then Mod:TriggerUnlock("Tainted Gello") end
	end
end)
