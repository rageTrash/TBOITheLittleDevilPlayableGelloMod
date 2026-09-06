local VERSION = 1.0
CustomReviveLibThing = CustomReviveLibThing or {}

return function(YR_MOD)
    if CustomReviveLibThing ~= nil and CustomReviveLibThing.Version and CustomReviveLibThing.Version > VERSION then return end

local lib = CustomReviveLibThing
local game = Game()

lib.Version = VERSION
if lib.Mod ~= nil then -- removing previous callbacks to not duplicate them
    if REPENTOGON then
        lib.Mod:RemoveCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, lib.PrePlayerTriggerDeath)
        lib.Mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, lib.PostPlayerRevive)
    else
        lib.Mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, lib.EntityTakeDMGCallback)
        lib.Mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, lib.PlayerUpdateCallback)
    end
    lib.Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, lib.GameStart)
end
lib.Mod = YR_MOD


--- enums

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


lib.RevivePriority = RevivePriority
lib.RevivalList = lib.RevivalList or {}
for t, val in pairs(RevivePriority) do
    lib.RevivalList[val] = lib.RevivalList[val] or {}
end

lib.Callbacks = lib.Callbacks or {
    -- calls to check if the player will revive
    PLAYER_REVIVE_CHECK = {},   --- arg : [ EntityPlayer, ItemConfig, AdvanceRNG(bool) ]
                                    --- return : [ bool ]             | notes: ( true = revive )
                                    --- extra param : [ ItemConfig ]
    -- calls as the player revive
    ON_PLAYER_REVIVE = {},          --- arg : [ EntityPlayer, ItemConfig ]
                                    --- extra param : [ ItemConfig ]
}
local Callbacks = lib.Callbacks



--- bellow all that makes this work

local cachePlayerData = {}
function lib.GameStart() cachePlayerData = {} end
lib.Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -2000, lib.GameStart)


local checkItems = {
    [0] = function() return false end,
    [1] = function(player)
        for idx=0, 3 do if player:GetCard(idx) == Card.CARD_SOUL_LAZARUS then return true end end

        if REPENTOGON then
            return player:GetEffects():HasNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
        end

        local dontCount = 0
        local data = cachePlayerData[ GetPtrHash(player) ]
        if data ~= nil then
            if (data.Num and data.Num > 0) then dontCount = dontCount + data.Num end
        end

        return (player:GetEffects():GetNullEffectNum(NullItemID.ID_LAZARUS_SOUL_REVIVE) - dontCount) > 0 -- not counting the soul of laz used for this
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
            return seed % 45 % 5 == 0 -- 22.22%
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




local function ConvertItemConfigItemParam(param) -- this was taken from repentogon's "main_ex.lua"
	if param and type(param) == "userdata" then
        local metatype = getmetatable(param).__name or getmetatable(param).__type
        if (REPENTOGON and metatype == "Item") or metatype == "const Item" then
		    return GetPtrHash(param)
        end
	end
end
function lib.AddCustomRevive(itemConfig, priority)
    local asParam = ConvertItemConfigItemParam(itemConfig)
    if asParam == nil then
        error("argument #1 is not an ItemConfig of any type", 2)
        return
    end

    local priority = priority or RevivePriority.HIGH
    if type(priority) ~= "number" then
        error("argument #2 is not a number", 2)
        return
    elseif math.floor(priority) ~= priority or priority < RevivePriority.HIGH or priority > RevivePriority.LOW then
        error("argument #2 is an invalid value", 2)
        return
    end
    
    table.insert(lib.RevivalList[priority], {Config = itemConfig, AsParam = asParam})
end


function lib.CanPlayerRevive(player, priority, advanceRNG)
    if not player or player.Variant ~= 0 then return false end
    local priority = priority or 0
    if type(priority) ~= "number" or priority < RevivePriority.HIGH or priority > RevivePriority.LOW then return false end
    if type(advanceRNG) ~= "boolean" then advanceRNG = true end

    local effects = player:GetEffects()

    for _, data in ipairs(lib.RevivalList[priority]) do
        for _, call in ipairs(Isaac.GetCallbacks(Callbacks.PLAYER_REVIVE_CHECK)) do
            local param = ConvertItemConfigItemParam(call.Param)

            if call.Param == nil or (param ~= nil and param == data.AsParam) then
                local res = call.Function(call.Mod, player, data.Config, advanceRNG)
                if type(res) == "boolean" and res == true then
                    return true, data
                end
            end
        end
    end

    return false
end


function lib.WillPlayerRevive(player)
    local revive = false
    for i=0, #checkItems do
        if not checkItems[i](player) then
            revive = lib.CanPlayerRevive(player, i, false)
        else
            return true
        end
        if revive then return true end
    end
    return false
end

local MAX_BERSERK_CHARGE = 100000
function lib.IsPlayerGoingToDie(player, dmg, src) -- this was base of isaacscript "IsPlayerGoingToDie" function
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


function lib.SetPlayerRevive(player)
    local data = cachePlayerData[ GetPtrHash(player) ]
    if data ~= nil then
        if data.DontCheck then return false
        elseif (data.Num and data.Num > 0) then return true
        end
    end

    local revive = false
    local revData = nil

    for i=0, #checkItems do
        if not checkItems[i](player) then
            revive, revData = lib.CanPlayerRevive(player, i, true)
        else break end
        if revive then break end
    end

    if revive then
        if not REPENTOGON then
            player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE)
        end
        local lazSouls = data and data.Num or 0
        cachePlayerData[ GetPtrHash(player) ] = {
            ReviveData = revData,
            ForceRemove = game:GetFrameCount() +2,
            Num = lazSouls +1,
        }
        return true
    end

    if not REPENTOGON then
        cachePlayerData[ GetPtrHash(player) ] = { DontCheck = true }
    end
    return false
end


if not lib.EntityMetadataSet and not REPENTOGON then
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
        if player then lib.SetPlayerRevive(player) end
        ogDie(self)
    end

    local ogKill = META0.Kill
    function META:Kill()
        local player = self:ToPlayer()
        if player then lib.SetPlayerRevive(player) end
        ogKill(self)
    end

    EndClass()

    BeginClass(EntityPlayer)
    local ogDie = META0.Die
    function META:Die()
        lib.SetPlayerRevive(self)
        ogDie(self)
    end

    local ogKill = META0.Kill
    function META:Kill()
        lib.SetPlayerRevive(self)
        ogKill(self)
    end

    EndClass()
    lib.EntityMetadataSet = true
end


if REPENTOGON then
    function lib.PrePlayerTriggerDeath(_, player)
        if lib.SetPlayerRevive(player) then
            return false
        end
    end

    function lib.PostPlayerRevive(_, player)
        local data = cachePlayerData[ GetPtrHash(player) ]
        if data == nil then return end

        if data.Num and data.Num >0 then
            player:AddSoulHearts( -player:GetSoulHearts() )

            for _, call in ipairs(Isaac.GetCallbacks(Callbacks.ON_PLAYER_REVIVE)) do
                local param = ConvertItemConfigItemParam(call.Param)
                if call.Param == nil or (param ~= nil and param == data.ReviveData.AsParam) then
                    call.Function(call.Mod, player, data.ReviveData.Config)
                end
            end
        end

        cachePlayerData[ GetPtrHash(player) ] = nil
    end

    lib.Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, -(2^32 -1), lib.PrePlayerTriggerDeath)
    lib.Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, -(2^32 -1), lib.PostPlayerRevive)
else
    function lib.EntityTakeDMGCallback(_, ent, amount, dmgFlags, src)
        local player = ent:ToPlayer()
        if not player or dmgFlags & DamageFlag.DAMAGE_FAKE > 0 then return end

        if lib.IsPlayerGoingToDie(player, amount, src) then
            lib.SetPlayerRevive(player)
        end
    end
    function lib.PlayerUpdateCallback(_, player)
        if game:GetFrameCount() <= 0 then return end
        local data = cachePlayerData[ GetPtrHash(player) ]

        if data and data.ClearOn then
            if data.ClearOn <= game:GetFrameCount() then
                cachePlayerData[ GetPtrHash(player) ] = nil
            end
            return
        end

        local sp = player:GetSprite()
        if sp:GetAnimation():match("Death") then
            if data == nil then
                lib.SetPlayerRevive(player)
            elseif sp:IsFinished() then
                if data and data.Num and data.Num >0 then
                    player:Revive()
                    player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)

                    player:AddSoulHearts( -player:GetSoulHearts() )

                    for _, call in ipairs(Isaac.GetCallbacks(Callbacks.ON_PLAYER_REVIVE)) do
                        local param = ConvertItemConfigItemParam(call.Param)
                        if call.Param == nil or (param ~= nil and param == data.ReviveData.AsParam) then
                            call.Function(call.Mod, player, data.ReviveData.Config)
                        end
                    end
                    player.Visible = true --fix for the player set as invisible after death (for whatever reason)

                    data.ClearOn = game:GetFrameCount() +1
                else
                    data.ClearOn = game:GetFrameCount() +1
                end
            end
        elseif data ~= nil then
            if player:IsHoldingItem() then
                data.ForceRemove = game:GetFrameCount() +1
            elseif player:IsExtraAnimationFinished() then
                if data and data.ForceRemove and game:GetFrameCount() >= data.ForceRemove then
                    player:GetEffects():RemoveNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, data.Num)
                    cachePlayerData[ GetPtrHash(player) ] = nil
                end
            end
        end
    end
    lib.Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, (2^32 -1), lib.EntityTakeDMGCallback, 1)
    lib.Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, -(2^32 -1), lib.PlayerUpdateCallback, 0)
end

end