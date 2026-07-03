local rute = "character."
local Mod = GelloCharMod

for _, load in ipairs({
	"gello",
	"Tainted._loader",
}) do GelloCharMod.Include(rute..load) end


local tearRepleaceTo = {
	[TearVariant.BLUE] = TearVariant.BLOOD,
	[TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
	[TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
	[TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
	[TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
	[TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
	[TearVariant.EYE] = TearVariant.EYE_BLOOD,
	[TearVariant.BLUE] = TearVariant.BLOOD,
}

--[[
function GelloCharMod:IsTaintedGello(player) return false end
function GelloCharMod:GetGlitchClassCopyDMG(player) return player:GetPlayerType() end
function GelloCharMod:GetGlitchClassCopyTears(player) return player:GetPlayerType() end
function GelloCharMod:GetGlitchClassCopySpeed(player) return player:GetPlayerType() end
function GelloCharMod:GetGlitchClassCopyShotSpeed(player) return player:GetPlayerType() end
function GelloCharMod:GetGlitchClassCopyShotSize(player) return player:GetPlayerType() end
function GelloCharMod:GetGlitchClassCopyAbility(player) return player:GetPlayerType() end
]]


Mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_UPDATE,-100, function(_, tear)
    if not tear.Parent or tear.FrameCount ~= 0 then return end

    local player = tear.Parent:ToPlayer()
    if not (player and (player:GetPlayerType() == Mod.Enum.Character.GELLO or Mod:IsTaintedGello(player)) and tear.CanTriggerStreakEnd) then return end
    local repleace = tearRepleaceTo[tear.Variant]
    if repleace then
        tear:ChangeVariant(repleace)
    end
end)