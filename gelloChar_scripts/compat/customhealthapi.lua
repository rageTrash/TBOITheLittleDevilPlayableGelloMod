local Mod = GelloCharMod

Mod.AddModPath("CustomHealthAPI", function()
    CustomHealthAPI.Library.AddCallback("GelloCharMod", CustomHealthAPI.Enums.Callbacks.PRE_RENDER_LIVES, 0, function(player, numLives)
        return {
            Lives = numLives + player:GetEffects():GetCollectibleEffectNum(Mod.Enum.Item.FETAL_JAR)
        }
    end)
end)