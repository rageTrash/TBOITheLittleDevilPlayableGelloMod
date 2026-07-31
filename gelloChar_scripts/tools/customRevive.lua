local YR_MOD = GelloCharMod
local VERSION = 1.4

if IDK_CustomRevive ~= nil and IDK_CustomRevive.Version and IDK_CustomRevive.Version >= VERSION then return end
IDK_CustomRevive = IDK_CustomRevive or {}

IDK_CustomRevive.Version = VERSION
if IDK_CustomRevive.Mod ~= nil then
	if REPENTOGON then
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, IDK_CustomRevive.PrePlayerTriggerDeath)
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_PRE_PLAYER_REVIVE, IDK_CustomRevive.PrePlayerRevive)
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, IDK_CustomRevive.PlayerUpdateCallback)
	else
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, IDK_CustomRevive.EntityTakeDMGCallback)
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, IDK_CustomRevive.PlayerUpdateCallback)
	end
	if IDK_CustomRevive.GameStart then
		IDK_CustomRevive.Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, IDK_CustomRevive.GameStart)
	end
end
IDK_CustomRevive.Mod = YR_MOD

local RevivePriority = {
	HIGH = 0,
	SOUL_OF_LAZARUS = 1,
	ONE_UP = 2,
	LAZARUS_INHERENT = 3,
	DEAD_CAT = 4,
	INNER_CHILD = 5,
	GUPPYS_COLLAR = 6,
	LAZARUS_RAGS = 7,
	ANKH = 8,
	BROKEN_ANKH = 9,
	JUDAS_SHADOW = 10,
	MISSING_POSTER = 11,
	TAINTED_LOST_BIRTHRIGHT = 12,
	LOW = 13,
}

local ReviveType = {
	ITEM = 0,
	TRINKET = 1,
	NULL = 2,
}

IDK_CustomRevive.Callbacks = IDK_CustomRevive.Callbacks or {
	CAN_PLAYER_REVIVE_CHECK = {},    --- arg : [ EntityPlayer, ItemConfig, AdvanceRNG(bool) ] return : [ bool ]
	ON_PLAYER_REVIVE = {},           --- arg : [ EntityPlayer, ItemConfig ]
}
IDK_CustomRevive.Callbacks.PRE_CUSTOM_REVIVE_ITEM  = IDK_CustomRevive.Callbacks.CAN_PLAYER_REVIVE_CHECK
IDK_CustomRevive.Callbacks.POST_CUSTOM_REVIVE_ITEM = IDK_CustomRevive.Callbacks.ON_PLAYER_REVIVE


local checkItems = {
	[0] = function() return false end,
	[1] = function(player)
		return player:GetEffects():HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
	end,
	[2] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_1UP)
	end,
	[3] = function(player)
		return player:GetPlayerType() == PlayerType.PLAYER_LAZARUS --- laz is not dead
	end,
	[4] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
	end,
	[5] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_CHILD)
	end,
	[6] = function(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR) then
			local seed = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR):GetSeed()
			return seed % 2 == 0
		end
		return false
	end,
	[7] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_LAZARUS_RAGS)
	end,
	[8] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH)
	end,
	[9] = function(player)
		if player:HasTrinket(TrinketType.TRINKET_BROKEN_ANKH) then
			local seed = player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_ANKH):GetSeed()
			return seed % 45 % 5 == 0
		end
		return false
	end,
	[10] = function(player)
		return player:HasCollectible(CollectibleType.COLLECTIBLE_JUDAS_SHADOW)
	end,
	[11] = function(player)
		return player:HasTrinket(TrinketType.TRINKET_MISSING_POSTER)
	end,
	[12] = function(player)
		return player:GetPlayerType() == PlayerType.PLAYER_THELOST_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	end,
	[13] = function() return false end,
}



IDK_CustomRevive.RevivePriority = RevivePriority
IDK_CustomRevive.ReviveType = ReviveType
IDK_CustomRevive.RevivalList = IDK_CustomRevive.RevivalList or {}
for t, val in pairs(RevivePriority) do
	IDK_CustomRevive.RevivalList[val] = IDK_CustomRevive.RevivalList[val] or {}
end


local cache_GetData = {}
function IDK_CustomRevive.GetData(player)
	local ptr = GetPtrHash(player)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end

	return cache_GetData[ptr]
end


function IDK_CustomRevive.AddCustomRevive(ItemId, priority, reviveType)
	if type(ItemId) ~= "number" or math.floor(ItemId) ~= ItemId or ItemId < CollectibleType.NUM_COLLECTIBLES then
		error("argument #1 is an invalid value", 2)
		return
	end
	local priority = priority or RevivePriority.HIGH
	local reviveType = reviveType or ReviveType.ITEM

	table.insert(IDK_CustomRevive.RevivalList[priority], {ID = ItemId, ReviveType = reviveType})
end


function IDK_CustomRevive.CanPlayerRevive(player, priority, advanceRNG)
	if not player or type(player) ~= "userdata" then return false end
	local priority = priority or 0
	if type(priority) ~= "number" or priority < 0 or priority > 13 then return false end
	local advanceRNG = type(advanceRNG) == "boolean" and advanceRNG or true
	local effects = player:GetEffects()

	local itemConfig = Isaac.GetItemConfig()
	for _, data in ipairs(IDK_CustomRevive.RevivalList[priority]) do
		local con = nil
		if data.ReviveType == ReviveType.ITEM then
			con = itemConfig:GetCollectible(data.ID)
		elseif data.ReviveType == ReviveType.TRINKET then
			con = itemConfig:GetTrinket(data.ID)
		elseif data.ReviveType == ReviveType.NULL then
			con = itemConfig:GetNullItem(data.ID)
		end
		if con then
			for _, call in ipairs(Isaac.GetCallbacks(IDK_CustomRevive.Callbacks.CAN_PLAYER_REVIVE_CHECK)) do
				local res = call.Function(call.Mod, player, con, advanceRNG)
				if type(res) == "boolean" and res == true then
					return true, con
				end
			end
		end
	end

	return false
end


function IDK_CustomRevive.WillPlayerRevive(player)
	local revive = false
	for i=0, #checkItems do
		if not checkItems[i](player) then
			revive = IDK_CustomRevive.CanPlayerRevive(player, i, false)
		else
			return true
		end
		if revive then return true end
	end
	return false
end

local MAX_BERSERK_CHARGE = 100000
function IDK_CustomRevive.IsPlayerGoingToDie(player, dmg, src)
	local pType = player:GetPlayerType()

	if pType == PlayerType.PLAYER_JACOB_B and src.Type == EntityType.ENTITY_DARK_ESAU then return false end

	local effect = player:GetEffects()

	if effect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then return false end
	if pType == PlayerType.PLAYER_SAMSON_B and player.SamsonBerserkCharge <= MAX_BERSERK_CHARGE + 10000 then return false end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES) then
		if not effect:HasNullEffect(NullItemID.ID_SPIRIT_SHACKLES_DISABLED) and not effect:HasNullEffect(NullItemID.ID_SPIRIT_SHACKLES_SOUL)  then
			return false
		end
	end
	if pType == PlayerType.PLAYER_JACOB2_B then return true end
	if effect:HasNullEffect(NullItemID.ID_LOST_CURSE) then return true end

	local redHearts = player:GetHearts()
	local soulHearts = player:GetSoulHearts()
	local boneHearts = player:GetBoneHearts()
	local rottenHearts = player:GetRottenHearts()
	local eternalHearts = player:GetEternalHearts()
	if redHearts + soulHearts + boneHearts + eternalHearts - rottenHearts > dmg then return false end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_HEARTBREAK) then
		local add = 2
		if pType == PlayerType.PLAYER_KEEPER or pType == PlayerType.PLAYER_KEEPER_B then add = 1 end
		if player:GetHeartLimit() / 2 > player:GetBrokenHearts() + add then return false end
	end

	if (redHearts > 0 and soulHearts > 0) or
	   (redHearts > 0 and boneHearts > 0) or
	   (soulHearts > 0 and boneHearts > 0) or
	   (soulHearts > 0 and eternalHearts > 0) or
	   boneHearts >= 2 then

		return false
	end

	return true
end
local game = Game()
function IDK_CustomRevive.SetPlayerRevive(player)
	local data = IDK_CustomRevive.GetData(player)
	if data.Num and data.Num > 0 then return true end

	local revive = false
	local config = nil

	for i=0, #checkItems do
		if not checkItems[i](player) then
			revive, config = IDK_CustomRevive.CanPlayerRevive(player, i)
		else return false end
		if revive then break end
	end

	if revive then
		player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
		local lazSouls = data.Num and data.Num or 0
		data.Config = config
		data.ForceRemove = game:GetFrameCount() +2
		data.Num = lazSouls +1
		return true
	end
end

if not REPENTOGON and not IDK_CustomRevive.EntityMetadataSet then
	local META, META0
	local function BeginClass(T)
		META = {}
		if type(T) == "function" then
			META0 = getmetatable(T())
		else
			META0 = getmetatable(T).__class
		end
	end

	local function EndClass()
		local oldIndex = META0.__index
		local newMeta = META
		
		rawset(META0, "__index", function(self, k)
			return newMeta[k] or oldIndex(self, k)
		end)
	end


	--- this is so the save data isn't remove
	BeginClass(Entity)
	local ogDie = META0.Die
	function META:Die()
		local player = self:ToPlayer()
		if player then IDK_CustomRevive.SetPlayerRevive(player) end
		ogDie(self)
	end

	local ogKill = META0.Kill
	function META:Kill()
		local player = self:ToPlayer()
		if player then IDK_CustomRevive.SetPlayerRevive(player) end
		ogKill(self)
	end

	EndClass()

	BeginClass(EntityPlayer)
	local ogDie = META0.Die
	function META:Die()
		IDK_CustomRevive.SetPlayerRevive(self)
		ogDie(self)
	end

	local ogKill = META0.Kill
	function META:Kill()
		IDK_CustomRevive.SetPlayerRevive(self)
		ogKill(self)
	end

	EndClass()

	IDK_CustomRevive.EntityMetadataSet = true
end


function IDK_CustomRevive.GameStart() cache_GetData = {} end
IDK_CustomRevive.Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, IDK_CustomRevive.GameStart)


if REPENTOGON then
	function IDK_CustomRevive.PrePlayerTriggerDeath(_, player)
		IDK_CustomRevive.SetPlayerRevive(player)
	end
	function IDK_CustomRevive.PrePlayerRevive(_, player)
		local data = IDK_CustomRevive.GetData(player)
		if data == nil then return end
		
		player:Revive()
		player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)
		if player:GetSoulHearts() >0 then player:AddSoulHearts(-player:GetSoulHearts()) end

		for _, call in ipairs(Isaac.GetCallbacks(IDK_CustomRevive.Callbacks.ON_PLAYER_REVIVE)) do
			call.Function(call.Mod, player, data.Config)
		end
		data = nil
	end
	function IDK_CustomRevive.PlayerUpdateCallback(_, player)
		if game:GetFrameCount() <= 0 then return end
		local data = IDK_CustomRevive.GetData(player)
		if data == nil then return end
		
		if player:IsHoldingItem() then
			data.ForceRemove = game:GetFrameCount() +2
		elseif player:IsExtraAnimationFinished() then
			if game:GetFrameCount() >= data.ForceRemove then
				player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)
				data = nil
			end
		end
	end

	IDK_CustomRevive.Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, (2^32 -1), IDK_CustomRevive.PrePlayerTriggerDeath)
	IDK_CustomRevive.Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_REVIVE, (2^32 -1), IDK_CustomRevive.PrePlayerRevive)
	IDK_CustomRevive.Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, (2^32 -1), IDK_CustomRevive.PlayerUpdateCallback, 0)
else
	function IDK_CustomRevive.EntityTakeDMGCallback(_, ent, amount, dmgFlags, src)
		local player = ent:ToPlayer()
		if not player or dmgFlags & DamageFlag.DAMAGE_FAKE > 0 then return end

		if IDK_CustomRevive.IsPlayerGoingToDie(player, amount, src) then
			IDK_CustomRevive.SetPlayerRevive(player)
		end
	end
	function IDK_CustomRevive.PlayerUpdateCallback(_, player)
		if game:GetFrameCount() <= 0 then return end
		local data = IDK_CustomRevive.GetData(player)

		if player:GetMaxHearts() + player:GetBoneHearts() + player:GetSoulHearts() == 0 and data == nil then
			IDK_CustomRevive.SetPlayerRevive(player)
			return
		end

		local sp = player:GetSprite()
		if sp:GetAnimation():match("Death") then
			if data == nil then
				IDK_CustomRevive.SetPlayerRevive(player)
			elseif sp:IsFinished() and data ~= nil then
				player:Revive()
				player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)
				if player:GetSoulHearts() >0 then player:AddSoulHearts(-player:GetSoulHearts()) end

				for _, call in ipairs(Isaac.GetCallbacks(IDK_CustomRevive.Callbacks.ON_PLAYER_REVIVE)) do
					call.Function(call.Mod, player, data.Config)
				end
				data = nil
			end
		elseif data ~= nil then
			if player:IsHoldingItem() then
				data.ForceRemove = game:GetFrameCount() +2
			elseif player:IsExtraAnimationFinished() then
				if game:GetFrameCount() >= data.ForceRemove then
					player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)
					data = nil
				end
			end
		end
	end
	IDK_CustomRevive.Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, (2^32 -1), IDK_CustomRevive.EntityTakeDMGCallback, 1)
	IDK_CustomRevive.Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, (2^32 -1), IDK_CustomRevive.PlayerUpdateCallback, 0)
end
