--[[
	Start:
		Health : R S
		Pocket : 5 coins

	On Selection:
		Pocket : IX - The Hermit

	Stats:
		- 0.1 speed
		- 0.15 tears
		- 0.5 damage

	Ability:
		money = power (innate)
		al matar a un enemigos tiene un 20% de generan una moneda

	LV1:
		monedas son mas comunes
		al matar a un enemigos tiene un 35% de generan una moneda

	LV2:
		shopkeepers dropean mas monedas al matarlos
		tiendas, sala del jefe, del diablo y del angle generan un (extra) objeto a la venta

	LV3:
		monedas son mas comunes
		al matar a un enemigos tiene un 45% de generan una moneda
		tiendas, sala del jefe, secreta, del diablo y del angle generan multiples objetos a la venta
		
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

return {
	Id = Mod.Enum.Character.GELLO_B8,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 1, Hearts = 2, Soul = 2}) end

		player:AddCoins(5)
		player:AddCard(Card.CARD_HERMIT)
	end,

}