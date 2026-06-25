--[[
	Start:
		Health : R S S
		Pocket : 1 Bomb

	On Selection:
		Pocket : Random Rune

	Stats:
		+ 0.5 damage
		- 0.2 tears
		- 0.1 speed

	Ability:
		al entrar a un cuarto (que tenga piedras), 1 a 2 piedras seran marcadas. al romperlas generaran 1 a 3 pickup or un cofre
		matar a un enemigo tiene 16% de dropear una runa
		usar la pala (we need to go deeper) en una decoracion generara 1 a 3 pickup

	LV1:
		al entrar a un cuarto nuevo cuarto tiene un 50% de dar la pala (we need to go deeper) de un solo uso por la duracion del cuarto
		matar a un enemigo tiene 30% de dropear una runa
	
	LV2:
		disparar recarga la habilidad de petrificar a los enemigos cercanos a isaac. matar a estos enemigos generaran 1 a 2 pickups pero no podran tirar un runa.
		los enemigos quedan petrificados por 2 seg

	LV3:
		al entrar a un cuarto (que tenga piedras), 2 a 4 piedras seran marcadas
		isaac puede romper estas piedras con su lagrimas
		aumenta el rango de la petrificacion
		
]]
local Mod = GelloCharMod
local pTools = Mod.PlayerTools
local game = Mod.Game
local itemPool = game:GetItemPool()
local roomRNG = RNG()

return {
	Id = Mod.Enum.Character.GELLO_B12,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 1, Hearts = 2, Soul = 4}) end
		player:AddBombs(1)

		local seed = game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed
		if seed == 0 then seed = player.InitSeed end
		player:AddCard(itemPool:GetCard(seed, false, true, true))
	end,

	PostRoom = function(player)
		if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, true, ActiveSlot.SLOT_POCKET2)
		end

		local room = game:GetRoom()
		if not room:IsFirstVisit() then return end

		local seed = player.InitSeed + room:GetDecorationSeed()
		if seed == 0 then seed = 1  end

		roomRNG:SetSeed(seed, 30)

		if roomRNG:RandomInt(5) == 0 then
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, ActiveSlot.SLOT_POCKET2, true)
		end
	end,
}