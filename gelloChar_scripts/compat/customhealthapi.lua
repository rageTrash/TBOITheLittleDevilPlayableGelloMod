local Mod = GelloCharMod

Mod.AddModPath("CustomHealthAPI", function()
    CustomHealthAPI.Library.AddCallback("GelloCharMod", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_LIVES, 0, function(player, numLives)

        local effects = player:GetEffects()
        local num = 0
        if Mod.RepentogonPlus then
            num = effects:GetNullEffectNum(Mod.Enum.NullItem.FETAL_JAR_LIVES)
        else
            num = effects:GetCollectibleEffectNum(Mod.Enum.Item.FETAL_JAR)
        end
        return { Lives = numLives + num }
    end)
end)