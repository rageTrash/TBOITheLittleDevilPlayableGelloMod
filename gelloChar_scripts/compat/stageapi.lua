if not StageAPI then return end
local Mod = GelloCharMod

local charEnum = Mod.Enum.Character
local portraitRute = "stageapi/none.png"
local nameRute = "gfx/ui/boss/playername_gello.png"
local extraAnmRute = "gfx/ui/stage/stageapi/"

StageAPI.AddPlayerGraphicsInfo(
    charEnum.GELLO,
    portraitRute,
    nameRute,
    true,
    extraAnmRute.."gello_portrait.anm2"
)



StageAPI.AddPlayerGraphicsInfo(
    charEnum.GELLO_B1,
    portraitRute,
    nameRute,
    true,
    extraAnmRute.."gello_portrait.anm2"
)
for id = charEnum.GELLO_B12, charEnum.GELLO_B2 do
    local num = charEnum.GELLO_B1 - id +1
    StageAPI.AddPlayerGraphicsInfo(
        id,
        portraitRute,
        nameRute,
        true,
        extraAnmRute.."gello_b_"..num.."_portrait.anm2"
    )
end
StageAPI.AddPlayerGraphicsInfo(
    charEnum.GELLO_B13,
    portraitRute,
    nameRute,
    true,
    extraAnmRute.."gello_b_12_5_portrait.anm2"
)