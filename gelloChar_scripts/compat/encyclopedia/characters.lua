if not Encyclopedia then return end
local Mod = GelloCharMod
local modName = "Gello Character"
local charEnum = Mod.Enum.Character


--- copy from Andromeda because i'm so done trying to show the character sprite ----
local KnownFilePathsByName = {
	["resources/scripts/"] = true
}

local KnownFilePathsByIndex = {
	"resources/scripts/"
}
local function GetCurrentModPath()
	--use some very hacky trickery to get the path to this mod
	local _, err = pcall(require, "")
	local _, basePathStart = string.find(err, "no file '", 1)
	local _, modPathStart = string.find(err, "no file '", basePathStart)
	local modPathEnd, _ = string.find(err, ".lua'", modPathStart)
	local modPath = string.sub(err, modPathStart+1, modPathEnd-1)
	modPath = string.gsub(modPath, "\\", "/")
	
	if not KnownFilePathsByName[modPath] then
		KnownFilePathsByName[modPath] = true
		table.insert(KnownFilePathsByIndex, 2, modPath)
	end
	
	return modPath
end

local marksTable = {
	[MarksNAchievHelper.MarkType.MOMS_HEART] = "MomsHeart",
	[MarksNAchievHelper.MarkType.SATAN] = "Satan",
	[MarksNAchievHelper.MarkType.ISAAC] = "Isaac",
	[MarksNAchievHelper.MarkType.THE_LAMB] = "Lamb",
	[MarksNAchievHelper.MarkType.BLUE_BABY] = "BlueBaby",
	[MarksNAchievHelper.MarkType.BOSS_RUSH] = "BossRush",
	[MarksNAchievHelper.MarkType.MEGA_SATAN] = "MegaSatan",
	[MarksNAchievHelper.MarkType.HUSH] = "Hush",
	[MarksNAchievHelper.MarkType.GREED] = "GreedMode",
	[MarksNAchievHelper.MarkType.DELIRIUM] = "Delirium",
	[MarksNAchievHelper.MarkType.MOTHER] = "Mother",
	[MarksNAchievHelper.MarkType.THE_BEAST] = "Beast",
}

local function getMarks(id)
	
	local CharMarks = {}

    for markType, nameMark in pairs(marksTable) do
        local val = Mod:GetMark(id, markType)
        CharMarks[nameMark] = {Unlock = val > 0, Hard = val == 2}
    end

	return CharMarks
end



local GelloDesc = {
    { -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Stats:"},
        {str = "- HP: 2 Red Hearts, 1 Black Heart"},
        {str = "- Speed: 1.12"},
        {str = "- Tear Rate: 2.43"},
        {str = "- Damage: 4.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Double tapping the fire button to the same direction will make a bite"},
        {str = "This bite give + 0.5 TEPORARY DAMAGE by each enemy kill"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "The bite radius and damage increase and gives more TEMPORARY DAMAGE per kill"},
    }, --[[
    {
        {str = "Notes", fsize = 2, clr = 3, halign = 0},
    },
    {
        {str = "Trivia", fsize = 2, clr = 3, halign = 0},
    },]]
}

local TaintedGelloDesc = {
    { -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Depending of what class is selected"},
        {str = "Class Fighter:"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 2 Black Heart"},
        {str = "- Speed: 0.85"},
        {str = "- Tear Rate: 2.43"},
        {str = "- Damage: 6.25 (x1.25)"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Double tapping the fire button to the same direction will make a bite"},
        {str = "This bite give + 0.5 TEPORARY DAMAGE by each enemy kill"},
        {str = ""},
        {str = "Class Jester:"},
        {str = "Stats:"},
        {str = "- HP: 3 Black Heart"},
        {str = "- Speed: 1.20"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 3.00"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.15"},
        {str = "- Luck: 0.00"},
        {str = "Tears, Bombs, Laser and Knifes get 0 to 3 random tear effects"},
        {str = ""},
        {str = "Class Tank:"},
        {str = "Stats:"},
        {str = "- HP: 3 Red Hearts, 1 Soul Heart"},
        {str = "- Speed: 0.80"},
        {str = "- Tear Rate: 2.58"},
        {str = "- Damage: 3.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Shooting charges a charge bar that when is releace makes a shock wave"},
        {str = "This shock wave damages and confiuses enemies around it"},
        {str = ""},--[[
        {str = "Class Scout:"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 1 Soul Heart"},
        {str = "- Speed: 1.30"},
        {str = "- Tear Rate: 2.93"},
        {str = "- Damage: 2.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = ""},]]
        {str = "Class Singer:"},
        {str = "Stats:"},
        {str = "- HP: 2 Red Hearts"},
        {str = "- Extra: The Lovers"},
        {str = "- Speed: 1.00"},
        {str = "- Tear Rate: 3.03"},
        {str = "- Damage: 2.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.15"},
        {str = "- Luck: 0.00"},
        {str = "Shooting charges a charge bar that when is releace charms nearby enemies"},
        {str = "The charm duration depends of how close the enemy was to Gello"},
        {str = ""},
        {str = "Class Explosivo:"},
        {str = "Stats:"},
        {str = "- HP: 2 Black Hearts"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 1.15"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 2.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Shooting charges a charge bar that when is releace will cause a small explosion that doesnt destroid obtacles"},
        {str = "This can be charge a secound time to cause a bigger explosion that can destroids obstacles but does a full heart of damage to Gello"},
        {str = ""},
        {str = "Class Gravediger:"},
        {str = "Stats:"},
        {str = "- HP: 1 Bone Heart"},
        {str = "- Extra: Death"},
        {str = "- Speed: 0.80"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 2.75"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Killing an enemy has a 50% to spawn a friendly skeleton"},
        {str = "The skeleton has the same health of the killed enemy"},
        {str = "Doesn't spawn more skeletons if the total health points is 100 or more"},
        {str = ""},--[[
        {str = "Class Merchant:"},
        {str = "Stats:"},
        {str = "- HP: 3 Black Heart"},
        {str = "- Speed: 1.20"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 3.00"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.15"},
        {str = "- Luck: 0.00"},
        {str = ""},]]
        {str = "Class Healer:"},
        {str = "Stats:"},
        {str = "- HP: 2 Red Hearts"},
        {str = "- Speed: 0.80"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 2.75"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Friendly enemies very close to Gello heals"},
        {str = "When an enemy die has a 20% to revive as a friendly"},
        {str = ""},
        {str = "Class Botanic:"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 1 Bone Heart"},
        {str = "- Speed: 1.15"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 2.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Shooting charges a charge bar that when is releace will cause a wave of plants to emerge to the shooted direction"},
        {str = "Enemies that touch the plants they get trapped by it and they receave damage for 5 seconds"},
        {str = ""},
        {str = "Class Venom:"},
        {str = "Stats:"},
        {str = "- HP: 1 Black Heart"},
        {str = "- Speed: 1.20"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 4.50"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Shooting charges a charge bar that when is releace will make Gello vomit poisoning tears for 7 seconds"},
        {str = "Getting hit by an enemy it will poison them"},
        {str = ""},
        {str = "Class Geologist:"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 2 Soul Hearts"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 0.90"},
        {str = "- Tear Rate: 2.58"},
        {str = "- Damage: 4.00"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
        {str = "Makes some rocks in the room special"},
        {str = "Destroing this rocks will drop 1 to 3 pickups"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "It depends"},
    },
}

local GelloSprite =      Encyclopedia.RegisterSprite(GetCurrentModPath() .. "content/gfx/characterportraits.anm2",    "Gello", 0 )
local TGelloSprite =     Encyclopedia.RegisterSprite(GetCurrentModPath() .. "content/gfx/characterportraitsalt.anm2", "Gello", 0 )
local TGelloLockSprite = Encyclopedia.RegisterSprite(GetCurrentModPath() .. "content/gfx/characterportraitsalt.anm2", "Gello", 1 )

Encyclopedia.AddCharacter({
    ModName = modName,
    Name = "Gello",
    ID = charEnum.GELLO,
    WikiDesc = GelloDesc,
    Sprite = GelloSprite,
    CompletionTrackerFuncs = {
        function() return getMarks(charEnum.GELLO) end,
    },
})


--local GELLO_TITLE = "Unsettled"
--local GELLO_TITLE = "Ever-changing"
--local GELLO_TITLE = "Changeful"
--local GELLO_TITLE = "Erratic"
local GELLO_TITLE = "Haphazard"
local GELLO_B_UNLOCKED = {
    ModName = modName,
    Name = "Gello",
    ID = charEnum.GELLO_B13,
    Description = GELLO_TITLE,
    WikiDesc = TaintedGelloDesc,
    Sprite = TGelloSprite,
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Tainted Gello") then
            --self.Spr = TGelloLockSprite
            self.Desc = "Unlocked by opening the secret closet in home as Gello"
            self.TargetColor = Encyclopedia.VanillaColor
            return self
        end
    end,
    CompletionTrackerFuncs = { function() return getMarks(charEnum.GELLO_B13) end, },
}
local GELLO_B_LOCKED = {
    ModName = modName,
    Name = "Gello",
    ID = charEnum.GELLO_B13,
    Description = GELLO_TITLE,
    WikiDesc = TaintedGelloDesc,
    Sprite = TGelloLockSprite,
    UnlockFunc = function(self)
        if not Mod:IsUnlock("Tainted Gello") then
            --self.Spr = TGelloLockSprite
            self.Desc = "Unlocked by opening the secret closet in home as Gello"
            self.TargetColor = Encyclopedia.VanillaColor
            return self
        end
    end,
    CompletionTrackerFuncs = { function() return getMarks(charEnum.GELLO_B13) end, },
}
Encyclopedia.AddCharacterTainted(GELLO_B_UNLOCKED)

for i= charEnum.GELLO_B12, charEnum.GELLO_B1 do
    Encyclopedia.AddCharacterTainted({
        ModName = modName,
        Name = "Gello",
        ID = i,
        Description = GELLO_TITLE,
        WikiDesc = TaintedGelloDesc,
        Sprite = TGelloSprite,
        UnlockFunc = function(self)
            self.Spr:Render(Vector(200, 200))
            if not Mod:IsUnlock("Tainted Gello") then
                --self.Spr = TGelloLockSprite
                self.Desc = "Unlocked by opening the secret closet in home as Gello"
                self.TargetColor = Encyclopedia.VanillaColor
                return self
            end
        end,
        CompletionTrackerFuncs = { function() return getMarks(i) end, },
        Hide = true,
    }) 
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if Mod:IsUnlock("Tainted Gello") then -- it was bother me that the main sprite wasnt chaging idk if is just a me thing
        Encyclopedia.UpdateCharacterTainted(charEnum.GELLO_B13, GELLO_B_UNLOCKED, "modded")
    else
        Encyclopedia.UpdateCharacterTainted(charEnum.GELLO_B13, GELLO_B_LOCKED, "modded")
    end
end)
