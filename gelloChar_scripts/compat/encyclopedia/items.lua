if not Encyclopedia then return end
local Mod = GelloCharMod
local itemEnum = Mod.Enum.Item
local modName = "Gello Character"


local Pools = {
	--Treasure
	["Treasure"] = "POOL_TREASURE",
	["TreasureGreed"] = "POOL_GREED_TREASURE",
	--Secret
	["Secret"] = "POOL_SECRET",
	["SecretGreed"] = "POOL_GREED_SECRET",
	--Shop
	["Shop"] = "POOL_SHOP",
	["ShopGreed"] = "POOL_GREED_SHOP",
	--Devil
	["Devil"] = "POOL_DEVIL",
	["DevilGreed"] = "POOL_GREED_DEVIL",
	--Angel
	["Angel"] = "POOL_ANGEL",
	["AngelGreed"] = "POOL_GREED_ANGEL",
	--Curse
	["Curse"] = "POOL_CURSE",
	["CurseGreed"] = "POOL_GREED_CURSE",
	--Boss
	["Boss"] = "POOL_BOSS",
	["BossGreed"] = "POOL_GREED_BOSS",
	--Ultra Secret
	["UltraSecret"] = "POOL_ULTRA_SECRET",
	--Crane Game
	["CraneGame"] = "POOL_CRANE_GAME",
	--Chests
	["GoldenChest"] = "POOL_GOLDEN_CHEST",
	["WoodenChest"] = "POOL_WOODEN_CHEST",
	["RedChest"] = "POOL_RED_CHEST",
	["OldChest"] = "POOL_OLD_CHEST",
	["MomsChest"] = "POOL_MOMS_CHEST",
	--Beggars
	["BombBum"] = "POOL_BOMB_BUM",
	["BatteryBum"] = "POOL_BATTERY_BUM",
	["Beggar"] = "POOL_BEGGAR",
	["KeyMaster"] = "POOL_KEY_MASTER",
	["DevilBeggar"] = "POOL_DEMON_BEGGAR",
	["RottenBeggar"] = "POOL_ROTTEN_BEGGAR",
	["ShellGame"] = "POOL_SHELL_GAME",
	--Baby Shop
	["BabyShop"] = "POOL_BABY_SHOP",
	--Library
	["Library"] = "POOL_LIBRARY",
}

local function GetPools(pool)
	if not pool or type(pool) ~= "table" then return {} end
	local totalPools = {}
	for i, PoolName in pairs(pool) do
		totalPools[i] = Encyclopedia.ItemPools[ Pools[PoolName] ]
	end
	return totalPools
end



for itemID, data in pairs({
    [itemEnum.LIL_HAMSTER] = {
        Name = "Lil Hamster",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Depending how it looks", clr = 2 },
                { str = "Does 30 points of damage to all enemies in the room", clr = 2 },
                { str = "Slows all enemies in the room 5 seconds" },
                { str = "On death they freeze", clr = 2 },
                { str = "Sets all enemies in the room on fire for 5 seconds", clr = 2 },
                { str = "Heals Isaac for 1 Heart", clr = 2 },
                { str = "If Isaac doesn't have space for Hearts it gives 1 Soul Heart", clr = 2 },
                { str = "Swaps the item to one of these" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Isaac" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "TreasureGreed", "Shop", "ShopGreed", "Devil", "CraneGame", "GoldenChest", "RedChest", "DevilBeggar" },
        Unlock = function() return Mod:IsUnlock("Lil Hamster") end,
        UnlockNote = "Defeate Isaac as Gello"
    },
    [itemEnum.BEELZEBUB] = {
        Name = "Beelzebub",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Gives a familiar that follows Isaac" },
                { str = "The familiar will get tired after some time" },
                { str = "This will create a rock wave around them that can damage enemies" },
                { str = "After some time it will get up again and follow Isaac" },
                { str = "The familiar will get tire quicker if it is moving" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by completing Boss Rush" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "Devil", "DevilGreed", "BabyShop" },
        Unlock = function() return Mod:IsUnlock("Beelzebub") end,
        UnlockNote = "Complete Boss Rush as Gello"
    },
    [itemEnum.FETAL_JAR] = {
        Name = "Fetal Jar",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "On use" },
                { str = "+1 LIFE" },
                { str = "Removes an item from Isaac" },
                { str = "When respawning" },
                { str = "+ 0.5 DAMAGE" },
                { str = "+ 0.24 TEARS" },
                { str = "Size down" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Delirium" },
                { str = "As Gello" },
            }
        },
        Pools = { "Devil", "DevilGreed", "UltraSecret", "RedChest" },
        Unlock = function() return Mod:IsUnlock("Fetal Jar") end,
        UnlockNote = "Defeate Delirium as Gello"
    },
    [itemEnum.MOTHERLY_CHICKEN] = {
        Name = "Motherly Chicken",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Clearing a room or wave has a 25% to give a random familiar for the floor" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Mother" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "ShopGreed" },
        Unlock = function() return Mod:IsUnlock("Motherly Chicken") end,
        UnlockNote = "Defeate Mother as Gello"
    },
    [itemEnum.USE_PLACENTA] = {
        Name = "Use Placenta",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "+ 2 SOUL HEARTS" },
                { str = "Killing an enemy has a 7.5% to drop Half a Soul Heart" },
                { str = "Some times drops a Full Soul Heart" },
                { str = "And Rarely drops a Black Heart" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating The Beast" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "ShopGreed", "Boss", "BossGreed", "RottenBeggar" },
        Unlock = function() return Mod:IsUnlock("Use Placenta") end,
        UnlockNote = "Defeate The Beast as Gello"
    },
    [itemEnum.CURSED_PLUSHIE] = {
        Name = "Cursed Plushie",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "+ 1 BLACK HEART" },
                { str = "+ 1.5 DAMAGE" },
                { str = "Per Half a Black Heart" },
                { str = "+ x0.025 DAMAGE MULTIPLIER" },
                { str = "Black hearts are slightly more common" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Mega Satan" },
                { str = "As Gello" },
            }
        },
        Pools = { "Devil", "DevilGreed", "UltraSecret" },
        Unlock = function() return Mod:IsUnlock("Cursed Plushie") end,
        UnlockNote = "Defeate Mega Satan as Gello"
    },
    [itemEnum.GALLUS] = {
        Name = "Gallus",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Killing an enemy has a 10% to spawn a special mini isaac" },
                { str = "This mini isaac has more health and does more damage" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating The Lamb" },
                { str = "As Gello" },
            }
        },
        Pools = { "ShopGreed", "Devil", "DevilGreed", "Curse", "CurseGreed" },
        Unlock = function() return Mod:IsUnlock("Gallus") end,
        UnlockNote = "Defeate The Lamb as Gello"
    },
    [itemEnum.LARRY_JR_JR] = {
        Name = "Larry Jr Jr",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Gives a familiar with many sections that moves around the room" },
                { str = "If the familiar kill an enemy may give one of these effects to one of its sections", clr = 2 },
                { str = "Skin : Does more contact damage", clr = 2 },
                { str = "Blue : From time to time spawns a creep that petrify and damage enemies" },
                { str = "If the head kill an enemy spawns a bigger version of the creep", clr = 2 },
                { str = "Green : From time to time one of the sections will shoots 3 to 5 tears" },
                { str = "If the head kill an enemy shoots 3 tears to the direction that its moving", clr = 2 },
                { str = "Rocky : From time to time one of the sections will spawn a blue fly" },
                { str = "If the head kill an enemy it will create a rock wave around the head" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Blue Baby" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "ShopGreed", "CraneGame", "BabyShop" },
        Unlock = function() return Mod:IsUnlock("Larry Jr Jr") end,
        UnlockNote = "Defeate Blue Baby as Gello"
    },
    [itemEnum.CENTEPIED] = {
        Name = "Centepied",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Spawns a centepied around Isaac that shield them from enemies projectiles" },
                { str = "Each section of the centepied will be destroid after taking certain amount of hits" },
                { str = "The centepied will disappear if it has 4 or less sections" },
                { str = "The centepied its regenerated at the start of a new floor" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Ultra Greedier" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "Secret", "ShopGreed" },
        Unlock = function() return Mod:IsUnlock("Centepied") end,
        UnlockNote = "Defeate Ultra Greedier as Gello"
    },
    [itemEnum.LIL_EMBRION] = {
        Name = "Lil Embrion",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Gives a familiar that follows Isaac" },
                { str = "The familiar loosely copied half of Isaac tear rate" },
                { str = "The slower it is the tear rate is the more tears it shoots" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Hush" },
                { str = "As Gello" },
            }
        },
        Pools = { "Treasure", "TreasureGreed", "ShopGreed", "UltraSecret", "BabyShop" },
        Unlock = function() return Mod:IsUnlock("Lil Embrion") end,
        UnlockNote = "Defeate Hush as Gello"
    },
    [itemEnum.LIL_BITER] = {
        Name = "Lil Biter",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Give a familiar that follow Isaac" },
                { str = "The familiar will automaticly target the closest enemy to them" },
                { str = "When the enemy is close enough it will bite them and any thing close to them" },
                { str = "Each enemy kill by the familiar it will give it small damage boost" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating The Beast" },
                { str = "As Tainted Gello" },
            }
        },
        Pools = { "Treasure", "ShopGreed", "Devil", "BabyShop" },
        Unlock = function() return Mod:IsUnlock("Lil Biter") end,
        UnlockNote = "Defeate The Beast as Tainted Gello"
    },
    [itemEnum.LIL_COW] = {
        Name = "Lil Cow",
        Desc = {
            {
                { str = "Effect", fsize = 2, clr = 3, halign = 0 },
                { str = "Give a familiar that moves around the room blocking enemies projectiles" },
                { str = "Isaac can explode the familiar to give them 3 Hearts" },
                { str = "The familiar revivies after clearing 10 rooms or when entering a new floor" },
                { str = "It gives 1 Soul Hearts if Isaac doesn't have space" },
            },
            {
                { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
                { str = "Unlocked by defeating Delirium" },
                { str = "As Tainted Gello" },
            }
        },
        Pools = { "Devil", "DevilGreed", "BabyShop" },
        Unlock = function() return Mod:IsUnlock("Lil Cow") end,
        UnlockNote = "Defeate Delirium as Tainted Gello"
    },
}) do
    Encyclopedia.AddItem({
        ModName = modName,
        Class = modName,
        Name = data.Name,
        ID = itemID,
        WikiDesc = data.Desc,
        Pools = GetPools(data.Pools),
        UnlockFunc = function(self)
            if not data.Unlock() then
                self.Desc = data.UnlockNote
                return self
            end
        end,
    })
end


Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Friendly Bite",
    ID = itemEnum.FRIENDLY_BITE,
    WikiDesc = {
        {
            { str = "Effect", fsize = 2, clr = 3, halign = 0 },
            { str = "Double-tapping a fire key make Isaac bite" },
            { str = "Per each enemy kill by the bite" },
            { str = "+ 0.5 TEMPORARY DAMAGE" },
            { str = "The damage caps at + 7.5 DAMAGE" },
            { str = "The bite does 150% of Isaac damage" },
            { str = "Getting hit recharges the bite" },
        },
        {
            { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
            { str = "Unlocked by defeating Satan" },
            { str = "As Gello" },
        }
    },
    Pools = GetPools({ "Devil", "DevilGreed", "UltraSecret" }),
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Friendly Bite") then
            self.Desc = "Defeate Satan as Gello"
            return self
        end
    end,
    Hide = function() return Mod.GetSetting("FriendlyBiteAltMode") end
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Friendly Bite",
    ID = itemEnum.FRIENDLY_BITE_ALT,
    WikiDesc = {
        {
            { str = "Effect", fsize = 2, clr = 3, halign = 0 },
            { str = "On use makes Isaac bite on his current fire or moving direction" },
            { str = "Per each enemy kill by the bite" },
            { str = "+ 0.5 TEMPORARY DAMAGE" },
            { str = "The damage caps at + 7.5 DAMAGE" },
            { str = "The bite does 150% of Isaac damage" },
        },
        {
            { str = "Achievement", fsize = 2, clr = 3, halign = 0 },
            { str = "Unlocked by defeating Satan" },
            { str = "As Gello" },
        }
    },
    Pools = GetPools({ "Devil", "DevilGreed", "UltraSecret" }),
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Friendly Bite") then
            self.Desc = "Defeate Satan as Gello"
            return self
        end
    end,
    Hide = function() return not Mod.GetSetting("FriendlyBiteAltMode") end
})



Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Lil Hamster",
    ID = itemEnum.LIL_HAMSTER_2,
    Hide = true
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Lil Hamster",
    ID = itemEnum.LIL_HAMSTER_3,
    Hide = true
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Lil Hamster",
    ID = itemEnum.LIL_HAMSTER_4,
    Hide = true
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Missing Familiar",
    ID = itemEnum.MISSING_HANDLER,
    Hide = true
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Missing Familiar",
    ID = itemEnum.TEMP_DMG,
    Hide = true
})
Encyclopedia.AddItem({
    ModName = modName,
    Class = modName,
    Name = "Missing Familiar",
    ID = itemEnum.TEMP_DMG_SLOW,
    Hide = true
})