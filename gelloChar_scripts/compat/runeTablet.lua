local Mod = GelloCharMod

local config = Isaac.GetItemConfig()
--local MAX_TEMP_DMG = 560 -- 14 dmg
local MAX_TEMP_DMG = 14

Mod.AddModPath("RunicTablet", function()
    if not REPENTOGON then return end

    -- soul of gello give +0.5 more damage per familiar
    -- also pass the 10 dmg boost, gives +0.5 dmg until it hit 14
    RunicTablet.Collectible.RunicTablet.POST_USE[Mod.Enum.Card.SOUL_OF_GELLO] = function(player)
        
        if flags & UseFlag.USE_CARBATTERY > 0 then return end

        local itemEffect = player:GetEffects()
        local dmg = Mod:GetSlowTempDamage(player)
        --if Mod.RepentogonPlus then
        --    dmg = itemEffect:GetNullEffectNum(Mod.Enum.NullItem.TEMP_DMG_SLOW)
        --else dmg = itemEffect:GetCollectibleEffectNum(Mod.Enum.Item.TEMP_DMG_SLOW) end
        if dmg > MAX_TEMP_DMG then return end

        --local mult = 20 -- 0.5 dmg
        --if flags & UseFlag.USE_MIMIC > 0 then mult = 10 end -- 0.25 dmg
        local mult = 0.5
        if flags & UseFlag.USE_MIMIC > 0 then mult = 0.25 end

        local famNum = 0 -- 0 dmg
        for itemID, num in pairs(Mod.PlayerTools.GetPlayerItems(player, true)) do
            if config:GetCollectible(itemID).Type == ItemType.ITEM_FAMILIAR then
                if famNum >= MAX_TEMP_DMG then break end
                famNum = famNum + (num *mult)
            end
        end

        if dmg + famNum > MAX_TEMP_DMG then famNum = MAX_TEMP_DMG
        else famNum = dmg + famNum end
        
        Mod:AddSlowTempDamage(player, famNum - dmg)
        --if Mod.RepentogonPlus then
        --    dmg = itemEffect:AddNullEffect(Mod.Enum.NullItem.TEMP_DMG_SLOW, false, famNum - dmg)
        --else dmg = itemEffect:AddCollectibleEffect(Mod.Enum.Item.TEMP_DMG_SLOW, false, famNum - dmg) end
    end

    RunicTablet.Collectible.RunicTablet:ReplaceRunicTablet(Mod.Enum.Card.SOUL_OF_GELLO, {"0.5", "1"})
end)