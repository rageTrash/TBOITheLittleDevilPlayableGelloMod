--[[
	Start:
		Health : B B
		Pocket : 1 Bomb

	Stats:
		- 0.15 size
		- 1 damage
		+ 0.15 speed
		x 0.75 tears

	Ability:
		inmune al fuego
		disparar recarga la habilidad de explotar (no hace daño a isaac pero no rompe piedras/obtaculos)

	LV1:
		al explotar, disparas 4 fuegos en los angulos cardinales

	LV2:
		double tap al disparar hace que isaac large una gran cantidad de fuego

	LV3:
		se puede sobre cargar la habilidad de explotar, esto rompera piedras y obtaculos pero tambien dañara a isaac por un corazon
		al explotar dispara 8 fuegos en los angulos cardinales
		
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

return {
	Id = Mod.Enum.Character.GELLO_B6,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {Black = 4}) end
		player:AddBombs(1)
	end,
}