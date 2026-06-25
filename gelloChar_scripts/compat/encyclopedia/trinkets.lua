if not Encyclopedia then return end
local Mod = GelloCharMod
local trinketEnum = Mod.Enum.Trinket
local modName = "Gello Character"


for trinketID, data in pairs({
    [trinketEnum.WEIRD_CANDY] = {
        Name = "Weird Candy",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Familiars do 20% more damage" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Ultra Greed" },
                { str = "As Gello" },
            }
        },
        Unlock = function() return Mod:IsUnlock("Weird Candy") end,
        UnlockNote = "Defeate Ultra Greed as Gello"
    },
    [trinketEnum.EGG] = {
        Name = "Egg",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Familiars do 20% more damage" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Satan, The Lamb, Isaac and ???" },
                { str = "As Tainted Gello" },
            }
        },
        Unlock = function() return Mod:IsUnlock("Egg") end,
        UnlockNote = "Defeate Satan, The Lamb, Isaac and ??? as Tainted Gello"
    },
    [trinketEnum.STRANGE_STONE] = {
        Name = "Strange Stone",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "When entering a unclear room has a 33% to gives a random familiar for the current room" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Mother" },
                { str = "As Tainted Gello" },
            }
        },
        Unlock = function() return Mod:IsUnlock("Strange Stone") end,
        UnlockNote = "Defeate Mother as Tainted Gello"
    },
}) do
    Encyclopedia.AddTrinket({
        ModName = modName,
        Class = modName,
        Name = data.Name,
        ID = trinketID,
        WikiDesc = data.Desc,
        UnlockFunc = function(self)
            if not data.Unlock() then
                self.Desc = data.UnlockNote
                return self
            end
        end,
    })
end
