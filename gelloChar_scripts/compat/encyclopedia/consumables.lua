if not Encyclopedia then return end
local Mod = GelloCharMod
local cardEnum = Mod.Enum.Card
local modName = "Gello Character"


Encyclopedia.AddCard({
    ModName = modName,
    Class = modName,
    Name = "Sacrificial Dagger",
    ID = cardEnum.SACRIFICIAL_DAGGER,
    WikiDesc = {
        {
            { str = "Effect", fsize = 2, clr = 3, halign = 0 },
            { str = "Spawns coins that their value amount 15 coins" },
            { str = "Removes a random familiar item from Isaac" },
            { str = "Quality 0 familiars spawns 10 coins" },
            { str = "Quality 4 familiars spawns 20 coins" },
            { str = "Spawns a Sacrificial Dagger if Isaac doesn't have familiars" },
        },
        {
            { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
            { str = "Unlocked by defeating Ultra Greedier" },
            { str = "As Tainted Gello" },
        }
    },
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Sacrificial Dagger") then
            self.Desc = "Defeate Ultra Greedier as Tainted Gello"
            return self
        end
    end,
})

Encyclopedia.AddSoul({
    ModName = modName,
    Class = modName,
    Name = "Soul of Gello",
    ID = cardEnum.SOUL_OF_GELLO,
    WikiDesc = {
        {
            { str = "Effect", fsize = 2, clr = 3, halign = 0 },
            { str = "+ 1 TEMPORARY DAMAGE" },
            { str = "Per each familiar collectible" },
            { str = "+ 0.5 TEMPORARY DAMAGE" },
            { str = "Has a 33% to spawn a Soul of Gello on use" },
        },
        {
            { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
            { str = "Unlocked by completing Boss Rush and defeating Hush" },
            { str = "As Tainted Gello" },
        }
    },
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Soul of Gello") then
            self.Desc = "Complete Boss Rush and defeate Hush as Tainted Gello"
            return self
        end
    end,
})
