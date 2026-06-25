local spawnableFams = {}

local config = Isaac.GetItemConfig()
local itemSize = config:GetCollectibles().Size -1
local Set = false

GelloCharMod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 200, function(_, continued)
	if continued and Set then return end
	
	spawnableFams = {}
	for itemID=1, itemSize do
		local itemConfig = config:GetCollectible(itemID)
		if itemConfig and itemConfig:IsAvailable() and itemConfig:HasTags(ItemConfig.TAG_MONSTER_MANUAL) and not itemConfig:HasTags(ItemConfig.TAG_UNIQUE_FAMILIAR | ItemConfig.TAG_QUEST) and not itemConfig.Hidden then
			table.insert(spawnableFams, {ID = itemID, IsTrinket = false})
		end
	end

	local trinketSize = config:GetTrinkets().Size -1
	for trinketID=1, trinketSize do
		local trinketConfig = config:GetTrinket(trinketID)
		if trinketConfig and trinketConfig:IsAvailable() and trinketConfig:HasTags(ItemConfig.TAG_MONSTER_MANUAL) and not trinketConfig:HasTags(ItemConfig.TAG_UNIQUE_FAMILIAR | ItemConfig.TAG_QUEST) then
			table.insert(spawnableFams, {ID = trinketID, IsTrinket = true})
		end
	end

	Set = true
end)


function GelloCharMod:GetRandomSpawnableFam(RNG)
	local RNG = RNG or GelloCharMod.RNG

	return spawnableFams[ RNG:RandomInt(#spawnableFams)+1 ]
end