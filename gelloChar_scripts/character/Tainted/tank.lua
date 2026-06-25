--[[
	Start:
		Health : R R R S

	Stats:
		- 0.2 speed
		- 0.15 tears
		+ 0.15 size

	Ability:
		All damage is reduce by half (innate wafer)
		firing fill a charge. let it go when fully charge creates a shock wave, knocking/confusing enemies and damaging these enemies

	LV1:
		now it can destroid rocks

	LV2:
		walking to enemies with a speed > 1.3 will knock them out

	LV3:
		the shock wave is bigger
		
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

return {
	Id = Mod.Enum.Character.GELLO_B3,

	InitPlayer = function(player, init) if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 3, Hearts = 6, Soul = 2}) end end

}