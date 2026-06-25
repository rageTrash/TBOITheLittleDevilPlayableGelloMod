--[[
	Start:
		Health : R R

	On Selection:
		Pocket : VI - The Lovers

	Stats:
		+ 0.3 tears
		- 1 damage
		+ 0.15 shot speed

	Ability:
		tears have a 20% to charm enemies
		disparar recarga la habilidad de encantar (por 2 seg) a los enemigos cercanos a isaac

	LV1:
		lagrimas tienen un 45% de encantar enemigos

	LV2:
		aumenta el rango de la habilidad enemigos que estan mas lejos son afectados por menos tiempo
		aumenta la duracion del encanto

	LV3:
		reduce el tiempo de recarga de la habilidad
		
]]
local Mod = GelloCharMod
local game = Mod.Game
local pTools = Mod.PlayerTools

local CHARM_CHANCE = 20-- 5%
local IGNORE_ENT_FLAGS = EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_QUERY


return {
	Id = Mod.Enum.Character.GELLO_B5,

	InitPlayer = function(player, init)
		if init then pTools.ReplacePlayerHealth(player, {MaxHearts = 2, Hearts = 4}) end
		player:AddCard(Card.CARD_LOVERS)
	end,


	TearUpdate = function(tear, rng, parent)
		if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			if rng:RandomInt(CHARM_CHANCE * 10) == 0 then
				tear:AddTearFlags(TearFlags.TEAR_CHARM)
			end
			return
		end
		if tear.FrameCount == 0 and rng:RandomInt(CHARM_CHANCE) == 0 then
			tear:AddTearFlags(TearFlags.TEAR_CHARM)
		end
	end,

	PostRoom = function(player)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return end
		local tab = {}
		for _, e in ipairs(Isaac.GetRoomEntities()) do
			if e:CanShutDoors() and e:IsActiveEnemy() and not (e:HasEntityFlags(IGNORE_ENT_FLAGS) or e:IsBoss() or e:IsDead()) then
				table.insert(tab, e)
			end
		end

		tab = Mod.TableTools.Shuffle(tab, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
		local ref = EntityRef(player)
		for i=1, math.min(#tab, 3) do
			tab[i]:AddCharmed(ref, 75)
		end
	end,
}